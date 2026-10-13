# peter.aufner.org

Static one-page personal site (plain HTML, CSS, JS, no build step). Live at https://peter.aufner.org.

## Standing rule: deploy is the final step of every update

An update is not finished until it is live. After every change that touches the site:

1. Verify locally (`python3 -m http.server 8765`, hard-refresh; the browser caches CSS and images).
2. Commit (Conventional Commits) and push. Never commit on `main` directly; use a feature branch.
3. Run `deploy/deploy.sh` and confirm the smoke test passes. Report the result.

`deploy/deploy.sh --dry-run` builds and lints without touching the network. Config via `DEPLOY_HOST`
(SSH alias `aufner.org`), `DEPLOY_DIR` (`peter.aufner.org`, relative to the SSH home) and `DEPLOY_URL`.
Only the allowlist at the top of the script is ever uploaded. A backup is taken before every upload
and restored automatically if the smoke test fails.

If SSH or HTTPS to `aufner.org` answers "connection refused", the host has most likely blocked the
current public IP. Report it and do not retry in a loop, and do not route around the block.

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
