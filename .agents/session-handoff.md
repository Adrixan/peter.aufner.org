# Session handoff: peter.aufner.org (2026-11-16, README tracking and DEPLOY_VIA check)

## Trajectory
Brief from the dispatcher via `rc code --brief` (Peter, 2026-11-15 ~08:05: retire the shared open-tasks list, ask remaining
decisions directly, sessions with remaining work proceed). Tasks: track README.md; confirm the DEPLOY_JUMP vs DEPLOY_VIA
alignment from 2026-11-14.

## State
- DEPLOY_VIA alignment: complete. `deploy/deploy.sh:29` reads `DEPLOY_VIA`, falls back to `DEPLOY_JUMP`; header comment and
  AGENTS.md document both; same name as prof.aufner.org and the knowledge map fallback (`DEPLOY_VIA=m11x`). No other file
  used `DEPLOY_JUMP` (commits ba3f49b, 4f6c40f).
- README.md now tracked (`!README.md` in `.gitignore`), refreshed: DEPLOY_VIA fallback, points to AGENTS.md instead of
  CLAUDE.md, `plans/` marked local-only, AGENTS.md and `.agents/` in the layout, new "Legal" section (`#offenlegung`,
  `#datenschutz`). Not part of the deploy allowlist, so no deploy needed; `deploy/deploy.sh --dry-run` passes.
- Peter chose 2026-11-16: browser support floor = Baseline Widely available (recorded in AGENTS.md).
- LIVE unchanged: 17274cc (deployed 2026-11-15 ~06:35).

## Notes (low, no action needed)
- `media/Peter.Aufner.portrait.jpg` (tracked, public repo, not deployed) still has EXIF: camera model SM-S908B and
  2024-11-08 timestamp, no GPS. Removing it from history would need a force-push (forbidden), so left as is.

## Open decisions
None.

## Needs Peter
Nothing.
