# Consumers replan Standalone paths

## Context

`refactor-sdk-drop-native-gc` and possibly others still list `Plugins/Angelscript/Standalone/` in Files.

## Evidence

- User confirmed Round 1 `other_changes=replan_list`.
- `refactor-sdk-drop-native-gc` tasks still name `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp`.

## Options

| Option | Result |
| --- | --- |
| A. List consumers for their replan | Keeps Task DAG ownership |
| B. Rewrite their Files here | This Change would mutate unrelated plans |

## Settled Decision

Option A.

## Consequences and Flip Condition

Those Changes cannot implement Standalone-path nodes until they replan to `AngelscriptLSP/`. If they drop the host inventory instead, remove them from the consumer list.

## Sources

- `attachments/drafts/handoff.md`
- `openspec/changes/angelscript/refactor-sdk-drop-native-gc/tasks.md`
