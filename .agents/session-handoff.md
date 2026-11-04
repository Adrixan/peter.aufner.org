# Session handoff: peter.aufner.org (2026-10-14)

## State
- LIVE: commit b9f7659 deployed 2026-10-14 09:41 via `DEPLOY_JUMP=m11x deploy/deploy.sh`.
  Backup of the previous server state: `.scratch/deploy-backups/peter.aufner.org-20261014-094156.tar.gz` (10 MB).
  Smoke test: 27/27 ok (files, real woff2, content, CSP/nosniff/XFO/referrer/HSTS headers).
- Branch `fix/styleguide-audit-and-deploy` pushed, not merged into `main`. HEAD 9c93ae6 only changes
  deploy/ and CLAUDE.md (not deployed, no redeploy needed).
- Source IPs blocked on aufner.org ports 22/80/443 (TCP refused, ICMP fine): school IP <school IP>
  since 2026-10-13 ~15:40 (still on 2026-10-14 09:44, likely long ban) and m11x <m11x IP> since
  right after the deploy. Probable trigger: blocked-path probes (/.git/HEAD etc.) in the smoke test.
  Now opt-in (`DEPLOY_PROBE_BLOCKED=1`). Unconfirmed; check Plesk > Tools > IP Address Banning.
- Server dir `peter.aufner.org/` still contains legacy leftovers from an earlier whole-repo copy:
  agents.md, .gitignore, .gitmodules, .kilocode/, media/ (original portrait with EXIF), plus unknown
  `httpdocs/` and `gragustl2026/`. Not removed (not requested). Exposure could not be verified (blocked).
  .htaccess blocks dotfiles and *.md.
- Sibling repo ~/code/prof.aufner.org was changed by someone else in parallel: now on `main` with commit
  19e5e3e (DEPLOY_VIA jump host) on top of my multiplexing commit a741658. Variable name differs from
  DEPLOY_JUMP here. Its blocked-path probes are still there and likely ban the IP on every deploy.

## Pending decisions (user)
- Unban both IPs in Plesk (or wait). Do not deploy again until then; a redeploy is only needed for site changes.
- Remove legacy leftovers on the server? (backup exists; `httpdocs` and `gragustl2026` need your call).
- Same probe fix for prof.aufner.org/deploy/deploy.sh; align DEPLOY_VIA / DEPLOY_JUMP naming.
- Merge `fix/styleguide-audit-and-deploy` into `main`; track README.md (`!README.md`).
- Copy decisions untouched: spaced en dashes, "X statt Y" phrasing, missing Impressum.

## Housekeeping 2026-11-01
- `.scratch/` cleaned; the only deploy backup left is `.scratch/deploy-backups/peter.aufner.org-20261020-151458.tar.gz`.
