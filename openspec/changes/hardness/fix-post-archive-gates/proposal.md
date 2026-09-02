## Why

The completed Hardness dogfood change passed its pre-archive gates, but the same Quick gate failed after the record moved from `openspec/changes/` to the archive. Two reusable tests had treated that active record as a fixture. The failure also left the newly accepted performance run only in ignored `Saved/` output because the original archive is immutable.

## What Changes

- Make the default TaskStatus performance sample create and remove its own temporary OpenSpec Task Graph while preserving explicit `-TaskChange` measurement of an active project change.
- Audit the completed dogfood Review/Replan history at its immutable archive path instead of treating it as current execution state.
- Require reusable closure gates to avoid active-change coupling, register accepted performance aggregates before archive, and run an applicable non-destructive lifecycle gate after the archive move.
- Retain a privacy-trimmed PS5/PS7 aggregate for this repair and state why its TaskStatus latency is not directly comparable with the earlier active-change baseline.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `hardness/core`: Make reusable gates archive-stable and make performance evidence retention explicit at the closure boundary.

## Impact

- Hardness test runner, performance fixture, protocol test, and concise Skill guidance.
- Hardness closure guidance and the OpenSpec archive lifecycle entry.
- No OpenSpec CLI or packaged executable change, no `Tools/openspec` gitlink change, and no Unreal Engine build or test.
- The completed `2026-09-03-refactor-skill-system` archive remains byte-for-byte untouched.
