# peter.aufner.org

Personal one-page site of Peter Aufner, live at <https://peter.aufner.org>.
Plain HTML, CSS and JavaScript. No framework, no build step, no third-party requests.

## Layout

```
index.html          single page (German, lang="de-AT")
css/styles.css      design tokens in :root, then components (BEM-style names)
js/main.js          mobile menu, smooth scroll, active-section highlighting
fonts/              self-hosted woff2 subsets plus their OFL licence texts
images/             favicon (hexagon monogram), portrait
robots.txt, sitemap.xml, .htaccess
deploy/deploy.sh    deployment script (see below)
media/              original, unprocessed portrait (not deployed)
plans/              planning notes from the Astro era, superseded (local only, ignored by git)
AGENTS.md           project rules and Peter's recorded decisions (CLAUDE.md only imports it)
.agents/            agent session state (handoff)
```

## Local preview

```bash
python3 -m http.server 8765
```

Open <http://localhost:8765>. Hard-refresh after edits, browsers cache CSS and images.

## Deploy

```bash
deploy/deploy.sh --dry-run   # build + lint, no network
deploy/deploy.sh             # upload, smoke test, rollback on failure
```

The script deploys the committed `HEAD`, restricted to an allowlist of paths. It refuses to run with
uncommitted changes in those paths, lints references, binary file types and the styleguide, backs up
the remote directory, uploads over a single SSH connection, smoke-tests the live URL and restores the
backup if anything fails. Target: SSH alias `aufner.org`, directory `peter.aufner.org`. Override with
`DEPLOY_HOST`, `DEPLOY_DIR`, `DEPLOY_URL`. If the host has banned this machine's IP, deploy through a
jump host: `DEPLOY_VIA=m11x deploy/deploy.sh` (SSH via `-J`, smoke test through a SOCKS tunnel on the
same host; `DEPLOY_JUMP` is still accepted as an alias).

Deploying is the final step of every update (see `AGENTS.md`).

## Design system: "Bioluminescent Night"

Source: `~/.config/ai/BRANDING.md`. Enforced by the lint in `deploy/deploy.sh`.

| Token | Value | Use |
|---|---|---|
| Void Charcoal | `#121212` | page background |
| Deep Slate | `#1E1E1E` | cards, footer |
| Starlight Grey | `#E0E0E0` | body text |
| Digital Fern | `#4ADE80` | links, calls to action, active state |
| Cyber-Mint | `#A7F3D0` | softer highlight |
| Signal Amber | `#F59E0B` | alerts, used sparingly |

Fonts: Space Grotesk (headings), Inter (body), JetBrains Mono (code and labels). All OFL 1.1,
latin subsets from `@fontsource`, licence texts in `fonts/`.

## Accessibility and security

- Skip link, semantic landmarks, visible focus states, German ARIA labels, `prefers-reduced-motion`
- Muted text is derived from the palette (about 7:1 contrast on Void Charcoal)
- CSP via meta tag in `index.html`; full header set (CSP with `frame-ancestors`, nosniff,
  X-Frame-Options, Permissions-Policy, caching) in `.htaccess`
- Portrait is metadata-free; keep it that way when replacing it

## Legal

The footer carries the minimal provider disclosure (`#offenlegung`, § 25 MedienG, § 5 ECG) and a short
GDPR Art. 13 notice on the server logs (`#datenschutz`). The site sets no cookies, uses no Local Storage
and makes no third-party requests; adding any of these requires updating `#datenschutz` in the same change.
