# Attachment Index

## Current position

The project has selected PowerShell 7 as the only supported Hardness host. The runner, module manifests, maintained entry documentation, current capability spec, and Task DAG example now expose only the PowerShell 7/Core contract. The PS7-only Integration profile passes `10/10`: five script checks, one performance check, and four route checks. The fixed-snapshot review and closure status remain to be indexed here without changing either completed dual-host archive.

## Historical boundary

- `openspec/archive/changes/hardness/2026-09-03-refactor-skill-system/` remains the immutable original dual-host delivery record.
- `openspec/archive/changes/hardness/2026-09-03-fix-post-archive-gates/` remains the immutable post-archive dual-host repair record.
- Existing PS5 raw and aggregate results are historical evidence, not current support claims.

## Current evidence

- `data/hardness-performance-powershell7-20260903-075347.json` — accepted privacy-trimmed PS7-only Integration and performance aggregate for fixed commit `3867512b`; SHA-256 `de720d6a0601a898761aed8ad0494d97e16ae97a348680987b39d10121d84333`. It records `10/10 PASS`, all ten check durations, 54 correct performance samples, scenario statistics, source hashes, and ignored raw-artifact hashes.
- The summed check duration is `77.992s`; the five Quick scripts account for `66.949s`, including `40.770s` for the single real Workspace Git/worktree check. This is retained as workflow evidence, not a portable timing guarantee.
- `reviews/` — pending independent fixed-snapshot review.
