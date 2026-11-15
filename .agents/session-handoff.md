# Session handoff: peter.aufner.org (2026-11-15)

## Trajectory
Standing order web-modernize (Peter, 2026-11-11), timer run 2026-11-15, unattended. Report: `~/sync/ai/web-modernize/2026-11-15/peter.aufner.org.md`.

## State
- LIVE: `main` 108a1de deployed 2026-11-15 (direct SSH, smoke test all ok).
- legacy-scan on `index.html`, `css/`, `js/`: 4 findings. Kept and fixed: `customize-scrollbar-color-and-thickness` (standard `scrollbar-color`/`scrollbar-width`, WebKit rules kept as fallback in `@supports not (scrollbar-color: auto)`). Dropped: `ime-safe-enter-submit` (skip-link Enter handler, no text input).
- Re-scan of `css/` is clean. `js/main.js:147` keeps matching the static IME rule; it is a verified false positive, leave it as it is.
- From now on the AGENTS.md "Web platform" rule is the standard: new or changed HTML, CSS and JS start from `modern-web-guidance`, checked with chrome-devtools.

## Still open from 2026-11-14 (Peter, optional)
- `gragustl2026/` sits outside the docroot on the host; restore command is in the 2026-11-14 handoff (git history) if students need it.
- Optional GDPR Art. 13 privacy notice (Plesk access logs store IPs): not decided.
- README.md is ignored by `*.md` (track it with `!README.md`?).
- No browser-support policy in AGENTS.md; the Baseline Widely available default was applied.
