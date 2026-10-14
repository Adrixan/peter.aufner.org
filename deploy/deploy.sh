#!/usr/bin/env bash
# Deploy peter.aufner.org -> https://peter.aufner.org
#
# Ships the committed state of HEAD (git archive, allowlist only) to the SSH host as a tar stream
# (there is no rsync on the server). The whole run uses ONE multiplexed SSH connection, so the
# host's brute-force protection sees a single login instead of dozens.
#
# Flow: preflight -> build + static checks + styleguide lint -> [--dry-run stops here, no network]
#       -> backup -> upload -> smoke test (automatic rollback on failure) -> remove stale files
#       -> write manifest.
#
# Usage:  deploy/deploy.sh [-n|--dry-run]
# Config: DEPLOY_HOST (SSH alias from ~/.ssh/config, default aufner.org)
#         DEPLOY_DIR  (relative to the SSH home, default peter.aufner.org)
#         DEPLOY_URL  (default https://peter.aufner.org)
#         DEPLOY_JUMP (optional SSH alias of a jump host, e.g. m11x. Use it when this machine's IP is
#                      blocked by the host: SSH goes via -J, and the smoke test curl calls go through
#                      a SOCKS tunnel over the same jump host)
# No credentials in this script: authentication goes through ~/.ssh/config and the SSH key.

set -euo pipefail

HOST="${DEPLOY_HOST:-aufner.org}"
REMOTE_DIR="${DEPLOY_DIR:-peter.aufner.org}"
SITE_URL="${DEPLOY_URL:-https://peter.aufner.org}"
JUMP="${DEPLOY_JUMP:-}"
KEEP_BACKUPS=10

# Only these paths are ever deployed. Anything else in the repo (plans/, *.md, .kilocode, deploy/)
# stays private by construction.
INCLUDE=(index.html robots.txt sitemap.xml .htaccess css js fonts images)
# Inside the allowlist, but unused by the page
EXCLUDE=(images/placeholders)

DRY_RUN=0
case "${1:-}" in
    -n|--dry-run) DRY_RUN=1 ;;
    "") ;;
    *) echo "Unknown option: $1 (allowed: -n | --dry-run)" >&2; exit 2 ;;
esac

log()  { printf '[deploy] %s\n' "$*"; }
warn() { printf '[deploy] WARNING: %s\n' "$*" >&2; }
die()  { printf '[deploy] ERROR: %s\n' "$*" >&2; exit 1; }

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
WORK="$ROOT/.scratch/deploy"
BUILD="$WORK/build"
BACKUPS="$ROOT/.scratch/deploy-backups"
STAMP="$(date +%Y%m%d-%H%M%S)"

SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=15
          -o ControlMaster=auto -o ControlPath="$WORK/ssh.sock" -o ControlPersist=120)
[ -z "$JUMP" ] || SSH_OPTS+=(-J "$JUMP")
remote() { ssh "${SSH_OPTS[@]}" "$HOST" "$@"; }
JUMP_CTL="$WORK/jump.sock"
close_ssh() {
    ssh "${SSH_OPTS[@]}" -O exit "$HOST" >/dev/null 2>&1 || true
    [ -z "$JUMP" ] || ssh -o ControlPath="$JUMP_CTL" -O exit "$JUMP" >/dev/null 2>&1 || true
}
# curl runs locally, or through a SOCKS tunnel on the jump host when DEPLOY_JUMP is set
CURL=(curl)

# ---------------------------------------------------------------- Preflight (local)
dirty="$(git status --porcelain --untracked-files=all -- "${INCLUDE[@]}")"
[ -z "$dirty" ] || die $'Uncommitted changes in deployable paths (commit them first):\n'"$dirty"
git diff --quiet && git diff --cached --quiet || warn "Tracked changes outside the allowlist are not committed (not deployed)."
COMMIT="$(git rev-parse --short HEAD)"
BRANCH="$(git branch --show-current)"
if upstream="$(git rev-parse -q --verify '@{u}' 2>/dev/null)"; then
    [ "$(git rev-parse HEAD)" = "$upstream" ] || warn "HEAD is not pushed to its upstream yet."
else
    warn "Branch $BRANCH has no upstream (not pushed)."
fi
log "Commit $COMMIT on $BRANCH -> $HOST:$REMOTE_DIR -> $SITE_URL"

# ---------------------------------------------------------------- Build
rm -rf "$WORK"; mkdir -p "$BUILD" "$BACKUPS"
git archive HEAD -- "${INCLUDE[@]}" | tar -x -C "$BUILD"
for e in "${EXCLUDE[@]}"; do rm -rf "${BUILD:?}/$e"; done
(cd "$BUILD" && find . -type f | sed 's|^\./||' | LC_ALL=C sort) > "$WORK/manifest.new"
[ -s "$WORK/manifest.new" ] || die "Build is empty."
for f in index.html css/styles.css js/main.js .htaccess; do
    grep -qx "$f" "$WORK/manifest.new" || die "Required file $f is missing from the build."
done
log "Build: $(wc -l < "$WORK/manifest.new") files, $(du -sk "$BUILD" | cut -f1) KB"

# ---------------------------------------------------------------- Static checks + styleguide lint
python3 -I - "$BUILD" <<'PY' || die "Static checks failed (see above). Nothing was uploaded."
import pathlib, re, sys

build = pathlib.Path(sys.argv[1]).resolve()
errors = []

def local_target(ref, base_file):
    ref = ref.strip().split("#")[0].split("?")[0]
    if not ref or re.match(r"^(?:[a-z][a-z0-9+.-]*:|//)", ref, re.I):
        return None  # external, mailto:, data:, pure anchor
    t = (build / ref.lstrip("/")) if ref.startswith("/") else (base_file.parent / ref)
    return t.resolve()

def resolves(t):
    return t is None or (t.is_relative_to(build) and (t.is_file() or (t / "index.html").is_file()))

# 1. Every local reference in HTML and CSS must resolve inside the build
html = build / "index.html"
for ref in re.findall(r"""(?:href|src)\s*=\s*["']([^"']+)["']""", html.read_text(encoding="utf-8")):
    if not resolves(local_target(ref, html)):
        errors.append(f"index.html references missing file: {ref}")
for css in build.rglob("*.css"):
    for ref in re.findall(r"""url\(\s*["']?([^)"']+?)["']?\s*\)""", css.read_text(encoding="utf-8")):
        if not resolves(local_target(ref, css)):
            errors.append(f"{css.relative_to(build)} references missing file: {ref}")

# 2. Binary assets must be what their extension claims (catches saved error pages)
magic = {".woff2": b"wOF2", ".jpg": b"\xff\xd8\xff", ".jpeg": b"\xff\xd8\xff", ".png": b"\x89PNG"}
for f in build.rglob("*"):
    if not f.is_file():
        continue
    head = f.read_bytes()[:512]
    ext = f.suffix.lower()
    if ext in magic and not head.startswith(magic[ext]):
        errors.append(f"{f.relative_to(build)} is not a valid {ext} file")
    if ext in {".css", ".js", ".svg", ".txt", ".xml"} and re.search(rb"<!doctype html", head, re.I):
        errors.append(f"{f.relative_to(build)} contains an HTML document")

# 3. Styleguide lint (BRANDING.md, Bioluminescent Night)
palette_hex = {"#121212", "#1e1e1e", "#e0e0e0", "#4ade80", "#a7f3d0", "#f59e0b"}
palette_rgb = {(18, 18, 18), (30, 30, 30), (224, 224, 224), (74, 222, 128), (167, 243, 208),
               (245, 158, 11), (0, 0, 0)}  # (0,0,0): shadows and print only
families = {"space grotesk", "inter", "jetbrains mono"}
generic = {"system-ui", "-apple-system", "sans-serif", "ui-monospace", "monospace"}
for f in list(build.rglob("*.css")) + list(build.rglob("*.svg")):
    text = f.read_text(encoding="utf-8")
    rel = f.relative_to(build)
    for h in set(re.findall(r"#[0-9a-fA-F]{3,8}\b", text)):
        h = h.lower()
        h = "#" + "".join(c * 2 for c in h[1:]) if len(h) == 4 else h
        if h not in palette_hex and h != "#000000":
            errors.append(f"{rel}: off-palette colour {h}")
    for m in re.findall(r"rgba?\(\s*(\d+)[\s,]+(\d+)[\s,]+(\d+)", text):
        if tuple(map(int, m)) not in palette_rgb:
            errors.append(f"{rel}: off-palette colour rgb({' '.join(m)})")
    if f.suffix == ".css":
        # Font stacks live in --font-family-* tokens as well as in plain font-family declarations
        for decl in re.findall(r"(?:--font-family-[\w-]+|font-family)\s*:\s*([^;}]+)", text):
            for name in (n.strip().strip("\"'").lower() for n in decl.split(",")):
                if name and not name.startswith("var(") and name not in families | generic:
                    errors.append(f"{rel}: font family outside the styleguide: {name}")

if errors:
    for e in sorted(set(errors)):
        print(f"[deploy]   FAIL {e}", file=sys.stderr)
    sys.exit(1)
print("[deploy] Static checks and styleguide lint passed")
PY

if [ "$DRY_RUN" -eq 1 ]; then
    log "Dry run, nothing uploaded. Would upload:"
    sed 's/^/    /' "$WORK/manifest.new"
    exit 0
fi

# ---------------------------------------------------------------- Remote preflight
trap close_ssh EXIT
if [ -n "$JUMP" ]; then
    SOCKS_PORT="$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')"
    ssh -o BatchMode=yes -o ConnectTimeout=15 -o ExitOnForwardFailure=yes \
        -o ControlMaster=yes -o ControlPath="$JUMP_CTL" -o ControlPersist=300 \
        -fN -D "127.0.0.1:$SOCKS_PORT" "$JUMP" \
        || die "Cannot open SOCKS tunnel via jump host $JUMP."
    CURL=(curl --socks5-hostname "127.0.0.1:$SOCKS_PORT")
    log "Using jump host $JUMP for SSH and smoke test"
fi
remote "true" || die "SSH connection to $HOST failed (host unreachable or this IP is blocked). Not retrying."
if ! remote "test -d '$REMOTE_DIR'"; then
    warn "Remote directory $REMOTE_DIR does not exist, creating it (check that the vhost docroot points here)."
    remote "mkdir -p '$REMOTE_DIR'"
fi

# ---------------------------------------------------------------- Stale list
remote "cat '$REMOTE_DIR/.deploy-manifest' 2>/dev/null || true" > "$WORK/manifest.old"
LC_ALL=C sort -o "$WORK/manifest.old" "$WORK/manifest.old"
LC_ALL=C grep -vxFf "$WORK/manifest.new" "$WORK/manifest.old" > "$WORK/delete.files" || true
if [ ! -s "$WORK/manifest.old" ]; then
    log "No previous manifest (first deploy). Existing top-level entries on the server:"
    remote "ls -A '$REMOTE_DIR'" | sed 's/^/    /' || true
fi

# ---------------------------------------------------------------- Backup
BACKUP="$BACKUPS/peter.aufner.org-$STAMP.tar.gz"
remote "tar -C '$REMOTE_DIR' -czf - ." > "$BACKUP"
tar -tzf "$BACKUP" >/dev/null || die "Backup is not readable: $BACKUP"
log "Backup: $BACKUP ($(wc -c < "$BACKUP") bytes)"
ls -1t "$BACKUPS"/peter.aufner.org-*.tar.gz | tail -n +$((KEEP_BACKUPS + 1)) | xargs -r rm -f --

rollback() {
    warn "Rolling back to $BACKUP"
    tar -tzf "$BACKUP" | sed 's|^\./||' | grep -v '/$' | LC_ALL=C sort > "$WORK/backup.list" || true
    LC_ALL=C grep -vxFf "$WORK/backup.list" "$WORK/manifest.new" > "$WORK/rollback.rm" || true
    if [ -s "$WORK/rollback.rm" ]; then
        remote "cd '$REMOTE_DIR' && xargs -r -d '\n' rm -f --" < "$WORK/rollback.rm"
    fi
    remote "tar -xzf - -C '$REMOTE_DIR' --no-same-owner --no-overwrite-dir" < "$BACKUP"
    warn "Rollback finished."
}

# ---------------------------------------------------------------- Upload
log "Uploading ..."
tar -C "$BUILD" -cf - -T "$WORK/manifest.new" \
    | remote "tar -xf - -C '$REMOTE_DIR' --no-same-owner --no-same-permissions --no-overwrite-dir"

# ---------------------------------------------------------------- Smoke test
http_code() { "${CURL[@]}" -s -o /dev/null --max-time 20 -w '%{http_code}' "$1" || true; }
fail=0
check() {  # check <path> <expected-code>
    local code; code="$(http_code "$SITE_URL$1")"
    if [ "$code" = "$2" ]; then log "  ok   $1 ($code)"; else warn "  FAIL $1 expected $2, got $code"; fail=1; fi
}
log "Smoke test ..."
sleep 2
check / 200
while IFS= read -r f; do
    [ "$f" = ".htaccess" ] && continue
    check "/$f" 200
done < "$WORK/manifest.new"
for f in $(grep '\.woff2$' "$WORK/manifest.new"); do
    m="$( ("${CURL[@]}" -s --max-time 20 "$SITE_URL/$f" | head -c4) || true)"
    [ "$m" = "wOF2" ] || { warn "  FAIL /$f is not served as a real woff2 file"; fail=1; }
done
body="$("${CURL[@]}" -s --max-time 20 "$SITE_URL/" || true)"
case "$body" in *"Widerstandsfähige Systeme aufbauen"*) log "  ok   homepage has expected content" ;;
                *) warn "  FAIL homepage without expected content"; fail=1 ;; esac
case "$body" in *googleapis.com*|*gstatic.com*) warn "  FAIL third-party font reference on homepage"; fail=1 ;; esac

if [ "$fail" -ne 0 ]; then
    rollback
    die "Smoke test failed, previous state restored. Details above."
fi

# ---------------------------------------------------------------- Cleanup + manifest
if [ -s "$WORK/delete.files" ]; then
    remote "cd '$REMOTE_DIR' && xargs -r -d '\n' rm -f --" < "$WORK/delete.files"
fi
remote "cat > '$REMOTE_DIR/.deploy-manifest'" < "$WORK/manifest.new"

# Soft checks (warnings only)
hdrs="$("${CURL[@]}" -sI --max-time 20 "$SITE_URL/" | tr -d '\r' | tr 'A-Z' 'a-z' || true)"
for h in content-security-policy x-content-type-options x-frame-options referrer-policy strict-transport-security; do
    case "$hdrs" in *"$h:"*) log "  ok   header $h" ;; *) warn "header $h missing (is .htaccess honoured?)" ;; esac
done
for p in /.htaccess /.deploy-manifest /.git/HEAD /deploy/deploy.sh /README.md; do
    c="$(http_code "$SITE_URL$p")"
    case "$c" in 404|403) log "  ok   $p blocked ($c)" ;; *) warn "$p is reachable ($c)" ;; esac
done

log "Done: $COMMIT live at $SITE_URL"
