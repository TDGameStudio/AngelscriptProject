## Why

Host-api flattened nine container types into `Containers/<Type>.as`. Those FileTags name only the type, several `@begin` tags disagree with their bodies, and TMap dumps risk C4883. Coverage is thin on a type-axis, but the pockets must be rewritten before they are thickened.

## What Changes

- Replace each flat container pocket with a type directory of observation-named authors (`Containers/TArray/AddAndOrder.as`).
- Hand-write quality splits and bind-surface coverage. Do not convert Pending with a script.
- Project the new FileTags and publish prefix queries on `host-api-fixtures`.
- Prove `Get(Containers/TArray/AddAndOrder, AddAndOrder)` and retire exact `Containers/TArray`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/host-api-fixtures`: admitted container FileTags are `Containers/<Type>/<Observation>` prefixes, not flat type pockets.

## Impact

Parent repository: `AngelscriptTestCode/Containers/`, CodeGenTool author tests, host-api-fixtures spec.
Plugin submodule: `Generated/Containers/`, `HostApiFixtureCorpusTests.cpp`.

## Non-goals

Language. Unreal first-batch. A new `Math/` root. Pending dumps. Bindings axis files. Parser changes. AngelScript compile or execute.
