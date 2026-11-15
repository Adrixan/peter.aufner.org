# Session handoff: peter.aufner.org (2026-11-15, D52 follow-up)

## Trajectory
Brief from the Greeter via `rc code --brief`: follow-up to the D52 privacy notice (Peter's tick, `~/code/.agents/archive/open-tasks-2026-11-15.md` line 141, verified in the saved 05:14 copy). Code reported that prof.aufner.org's host check found 15 to 16 days of log retention; task was to verify the same here and align the text.

## State
- LIVE: `main` 17274cc (commit 002a4fc), deployed 2026-11-15 ~06:35 by direct SSH (`deploy/deploy.sh` printed "Done: 17274cc live"); smoke test all ok (files, content, security headers); live check with a desktop User-Agent shows "rotiert und spätestens nach 16 Tagen gelöscht".
- Host check 2026-11-15 06:30, `~/logs/peter.aufner.org/`: current `access_ssl_log` (since 14 Nov 18:44), `.processed` (13 Nov 14:37 to 14 Nov 00:21), `.processed.1` to `.14`; `.14` still holds entries from 30 Oct 13:13, deleted at the next daily rotation (about 11:45), so the maximum is just under 16 days. Same layout for `access_log` and `error_log`. AGENTS.md D52 fact line updated to "at most 16 days" with the evidence.
- Privacy notice `#datenschutz` otherwise unchanged; `/gragustl2026/` stays offline (record only).
- web-modernize 2026-11-15 (earlier run): report `~/sync/ai/web-modernize/2026-11-15/peter.aufner.org.md`; `js/main.js:147` IME match is a verified false positive.

## Open (low, optional)
- README.md is ignored by `*.md` (track with `!README.md`?); no browser-support policy in AGENTS.md (Baseline Widely available applied).

## Needs Peter
Nothing.
