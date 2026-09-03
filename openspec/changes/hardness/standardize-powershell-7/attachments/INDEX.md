# Attachment Index

## Current position

The project has selected PowerShell 7 as the only supported Hardness host. The runner, module manifests, maintained entry documentation, current capability spec, and Task DAG example now expose only the PowerShell 7/Core contract. The PS7-only Integration profile passes `10/10`: five script checks, one performance check, and four route checks. Independent fixed-snapshot review is closed with `APPROVE` and no findings; all four Task DAG nodes are complete, so the change is ready for completed archive and one post-move PS7 Quick gate without changing either completed dual-host archive.

## Historical boundary

- `openspec/archive/changes/hardness/2026-09-03-refactor-skill-system/` remains the immutable original dual-host delivery record.
- `openspec/archive/changes/hardness/2026-09-03-fix-post-archive-gates/` remains the immutable post-archive dual-host repair record.
- Existing PS5 raw and aggregate results are historical evidence, not current support claims.

## Current evidence

- `data/hardness-performance-powershell7-20260903-075347.json` — accepted privacy-trimmed PS7-only Integration and performance aggregate for fixed commit `3867512b`; SHA-256 `de720d6a0601a898761aed8ad0494d97e16ae97a348680987b39d10121d84333`. It records `10/10 PASS`, all ten check durations, 54 correct performance samples, scenario statistics, source hashes, and ignored raw-artifact hashes.
- The summed check duration is `77.992s`; the five Quick scripts account for `66.949s`, including `40.770s` for the single real Workspace Git/worktree check. This is retained as workflow evidence, not a portable timing guarantee.
- `reviews/review-20260903-075859-powershell7-fixed-snapshot.md` — closed independent `APPROVE` review of commit `c1a5876c`, the executable host surface, manifests, aggregate/raw/source hashes, historical archive immutability, and package/Unreal exclusions; SHA-256 `e99ee2e94066883f00cfd6fdf28b6d4bd8585685127bd25f95e26491d30f4ecd`.
