# peter.aufner.org

Static one-page personal site (plain HTML, CSS, JS, no build step). Live at https://peter.aufner.org.

## Standing rule: deploy is the final step of every update

An update is not finished until it is live. After every change that touches the site:

1. Verify locally (`python3 -m http.server 8765`, hard-refresh; the browser caches CSS and images).
2. Commit (Conventional Commits) and push. Never commit on `main` directly; use a feature branch.
3. Run `deploy/deploy.sh` and confirm the smoke test passes. Report the result.

`deploy/deploy.sh --dry-run` builds and lints without touching the network. Config via `DEPLOY_HOST`
(SSH alias `aufner.org`), `DEPLOY_DIR` (`peter.aufner.org`, relative to the SSH home), `DEPLOY_URL` and
`DEPLOY_VIA` (jump host; `DEPLOY_JUMP` still works as an alias).
Only the allowlist at the top of the script is ever uploaded. A backup is taken before every upload
and restored automatically if the smoke test fails.

If SSH or HTTPS to `aufner.org` answers "connection refused" on 22, 80 and 443, the host has blocked
the current public IP (seen on 2026-10-13 and again for m11x on 2026-10-14 right after a deploy).
Probable trigger: scanner-like requests such as `/.git/HEAD`, so the smoke test does not send them
unless `DEPLOY_PROBE_BLOCKED=1`. When blocked, report it and do not retry in a loop. Rule
(knowledge map, aufner.org): one SSH attempt before a deploy; if it is refused, the standing fallback
is `DEPLOY_VIA=m11x deploy/deploy.sh` (fails too if m11x is banned). Never fetch the live site with
agent tools (crawler user agents get the IP banned); live checks only in a browser or with a desktop
`User-Agent`.

## Styleguide

Source of truth: `~/.config/ai/BRANDING.md` ("Bioluminescent Night"). The deploy script lints the CSS
and SVG for it, so violations fail the deploy.

- Colours only from the palette tokens in `css/styles.css` `:root`: Void Charcoal `#121212`,
  Deep Slate `#1E1E1E`, Starlight Grey `#E0E0E0`, Digital Fern `#4ADE80`, Cyber-Mint `#A7F3D0`,
  Signal Amber `#F59E0B` (sparingly).
- Fonts: Space Grotesk (headings), Inter (body), JetBrains Mono (code). Self-hosted in `fonts/`,
  no third-party font requests. `@font-face` URLs are relative to `css/`, so they start with `../fonts/`.
- Monogram is a hexagon with "PA" (`--shape-hexagon`, `images/favicon.svg`).
- Dark mode only, glassmorphism panels, generous negative space.
- German UI copy, `lang="de-AT"`, so ARIA labels and alt texts are German too.

## Web platform (Peter, 2026-11-11)
- New or changed HTML, CSS and client-side JS start from skill `modern-web-guidance` (installed CLI `modern-web-guidance`, not `npx`) and are checked in the browser with the `chrome-devtools` MCP.
- One-off modernization: `web-modernize` (2026-11-15, list `~/sync/ai/web-projects.txt`) runs `legacy-scan`, applies only verified behaviour-preserving fixes through this file's test and publish rules, and files larger changes in `.agents/to-do.md`; after that the rule above is the standard for all web work here.

## Decisions (Peter, 2026-11-14, `Open tasks.md` D14 and D31)
- D14 A: provider disclosure (§ 25 MedienG, § 5 ECG) stays minimal: name, Graz, contact `peter@aufner.org`,
  purpose of the site, no address block, no Impressum. The site has no privacy page, so it sits in the
  footer (`#offenlegung`, same wording as prof.aufner.org `/datenschutz/#offenlegung`). Keep it there.
- D31 A: the copy stays as Peter wrote it (spaced en dashes, "X statt Y"): his voice, do not rewrite it.
  Server leftovers removed 2026-11-14 (`agents.md`, `.gitignore`, `.gitmodules`, `.kilocode/`,
  `media/` with the EXIF portrait). `httpdocs/` (Plesk placeholder) and `gragustl2026/` (school
  material) moved out of the docroot to `~/peter.aufner.org-outside-docroot-20261114/` on the host;
  backup `.scratch/deploy-backups/peter.aufner.org-leftovers-20261114-184349.tar.gz`. The docroot holds
  only the deploy allowlist plus `.deploy-manifest`.


## Decisions (Peter, 2026-11-15, `Open tasks.md` D52)
- `/gragustl2026/` (school material) stays offline outside the docroot (`~/peter.aufner.org-outside-docroot-20261114/`
  on the host). Settled: do not restore it unless Peter asks (restore = one `mv` back into `peter.aufner.org/`).
- Short GDPR Art. 13 privacy notice for the server logs lives in the footer next to `#offenlegung` as `#datenschutz`
  (one paragraph, no separate page). Facts it states that must stay true (change the text with them): controller
  Peter Aufner, Graz, `peter@aufner.org`; logged fields IP, time, URL, status, bytes, referrer, user agent; purpose
  secure operation, Art. 6(1)(f); netcup GmbH (Germany) as processor, AVV signed (see prof.aufner.org AGENTS.md);
  Plesk logs rotated daily: current log, then `.processed`, then 14 rotated files, so at most 16 days (re-checked on the host 2026-11-15 06:30: oldest entry 30 Oct 13:13 still present, page says "spätestens nach 16 Tagen", same as prof.aufner.org); no cookies,
  no Local Storage, no third-party requests; rights Art. 15 to 21, complaint to the Datenschutzbehörde.
  Adding cookies, analytics, embeds or a form requires updating this paragraph in the same change.
