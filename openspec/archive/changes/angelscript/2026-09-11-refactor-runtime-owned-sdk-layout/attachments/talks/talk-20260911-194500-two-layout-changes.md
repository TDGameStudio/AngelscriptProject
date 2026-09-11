# Two layout Changes, not one

## Context

The plugin performed two directory moves in one working tree. The user asked for two Changes to handle surrounding path contracts.

## Evidence

- SDK move and Standalone→AngelscriptLSP move are independent owners (UBT vs CMake/docs) with one coupling: host CMake fork root.
- User confirmed Round 1 `split=two_layout`.

## Options

| Option | Result |
| --- | --- |
| A. Two layout Changes | SDK include/specs vs host directory/docs |
| B. One combined Change | Mixed verification (Editor build vs path grep/CMake) |

## Settled Decision

Option A. The host Change depends on the new SDK path string but does not own `AngelscriptRuntime.Build.cs`.

## Consequences and Flip Condition

Do not merge the Task DAGs. If the SDK folder is moved again, only the SDK Change's include-root task changes.

## Sources

- `attachments/drafts/handoff.md`
- `attachments/drafts/findings/directory-moves.md`
