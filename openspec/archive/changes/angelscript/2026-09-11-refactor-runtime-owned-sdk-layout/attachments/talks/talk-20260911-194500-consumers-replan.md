# Other active Changes replan old SDK paths

## Context

This layout Change retargets live include paths and current specs after the SDK left `ThirdParty/angelscript`. Several active Changes still name that tree in Files blocks.

## Evidence

- On-disk move: `Source/AngelscriptRuntime/ThirdParty/angelscript/source/` deleted; `Source/AngelscriptRuntime/angelscript/` present.
- User confirmed Round 1 `other_changes=replan_list` (draft log, 2026-09-11): this Change lists consumers and does not rewrite their `tasks.md`.

## Options

| Option | Result |
| --- | --- |
| A. List consumers; they replan | Ownership stays with the Change that still implements those files |
| B. Mechanically rewrite their Files here | This Change would mutate unrelated Task DAGs |

## Settled Decision

Option A.

## Consequences and Flip Condition

`feature-frontend-diagnostics-tooling`, `refactor-sdk-drop-native-gc`, and any remaining Files under `ThirdParty/angelscript` must replan before they implement those nodes. If an active Change is abandoned instead, drop it from the consumer list.

## Sources

- `attachments/drafts/handoff.md` OpenSpec Handoff
- `attachments/drafts/findings/directory-moves.md`
