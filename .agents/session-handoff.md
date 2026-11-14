# Session handoff: peter.aufner.org (2026-11-14)

## Trajectory
Brief from the dispatcher "Code" (Peter's decisions in `Open tasks.md`, 2026-11-14 18:24): D14 A and D31 A. Both done and live.

## State
- LIVE: `main` 80372c7 deployed 2026-11-14 ~18:45 directly (first SSH attempt worked, no jump host). Smoke test all ok. Live check with a desktop User-Agent: `#offenlegung` present; `/media/…portrait.jpg`, `/gragustl2026/`, `/httpdocs/` answer 404.
- D14 A: provider disclosure (§ 25 MedienG, § 5 ECG; name, Graz, `peter@aufner.org`, purpose) in the footer, anchor `#offenlegung`; the site has no privacy page. Wording mirrors prof.aufner.org.
- D31 A: copy unchanged. Server: removed `agents.md`, `.gitignore`, `.gitmodules`, `.kilocode/`, `media/` (EXIF portrait). Moved `httpdocs/` (Plesk "Hier entsteht eine neue Webseite" placeholder) and `gragustl2026/` (school material: Word, PowerPoint, Excel exercises) to `~/peter.aufner.org-outside-docroot-20261114/` on the host. Backups: `.scratch/deploy-backups/peter.aufner.org-leftovers-20261114-184349.tar.gz` (fresh) and the 2026-10-20 full backup (md5-identical for these folders).
- Deploy script: jump host variable is now `DEPLOY_VIA` (as in prof.aufner.org), `DEPLOY_JUMP` kept as alias. AGENTS.md updated with the D14/D31 decisions and the map's aufner.org rule (one SSH attempt, fallback `DEPLOY_VIA=m11x`, no agent fetches of the live site).

## Needs Peter (optional)
- `peter.aufner.org/gragustl2026/` is offline now. If students still use it: `ssh aufner.org 'mv peter.aufner.org-outside-docroot-20261114/gragustl2026 peter.aufner.org/'` (the deploy's stale-file cleanup only touches files listed in `.deploy-manifest`, so it would survive later deploys).
- Not decided, only an option: a short privacy notice (GDPR Art. 13: Plesk access logs store IPs) for this site. Today it has none; the D14 disclosure covers MedienG/ECG only.

## Leftovers from earlier sessions (still open, not part of this brief)
- prof.aufner.org deploy script still sends blocked-path probes (that repo's session).
- README.md is ignored by `*.md` (track it with `!README.md`?).
