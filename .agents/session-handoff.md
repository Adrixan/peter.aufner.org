# Session handoff: peter.aufner.org (2026-11-15, D52)

## Trajectory
Brief from the Greeter via `rc code --brief` (Peter's ticks in `Open tasks.md` D52, lines 140 and 141, verified in the saved 05:14 copy, md5 67e8aaa6). Both items are done and recorded in AGENTS.md under "Decisions (Peter, 2026-11-15)".

## State
- LIVE: `main` 7781eeb (commit fbc418c), deployed 2026-11-15 by direct SSH; smoke test all ok; live check with a desktop User-Agent shows `#datenschutz`.
- `/gragustl2026/`: stays offline outside the docroot (record only, nothing changed on the host).
- Privacy notice: one footer paragraph `#datenschutz` after `#offenlegung` (Sie form like the rest of the page). Verified in Chrome DevTools at 375 px and desktop: no overflow, no console messages, no cookies, no Local Storage, no third-party requests.
- Retention checked on the host: `~/logs/peter.aufner.org/` rotates daily and keeps 14 rotated files (oldest dated 2026-11-01), so entries live at most 15 days; the notice says "nach höchstens 15 Tagen".
- web-modernize 2026-11-15 (earlier run): report `~/sync/ai/web-modernize/2026-11-15/peter.aufner.org.md`; `js/main.js:147` IME match is a verified false positive.

## Open (low, optional)
- prof.aufner.org `/datenschutz/` says "nach 14 Tagen gelöscht" with the same Plesk rotation (14 rotated files plus the current log, so up to about 15 days). Belongs to the prof.aufner.org session; reported to Code.
- README.md is ignored by `*.md` (track with `!README.md`?); no browser-support policy in AGENTS.md (Baseline Widely available applied).

## Needs Peter
Nothing.
