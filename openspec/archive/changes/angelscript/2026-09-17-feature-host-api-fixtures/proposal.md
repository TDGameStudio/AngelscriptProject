## Why

Bindings leftovers are a host-API corpus, not Language and not the Unreal first batch. Value containers need an admitted `Containers/` root. The remaining Bindings types belong under `Unreal/<Type>`. Pending/Containers Fail and pointer cases must merge with the Bindings axis files so nothing is dropped.

## What Changes

- Admit `AngelscriptTestCode/Containers/` and rewrite T* / SoftObjectPath / Pending/Containers into `@begin` pockets plus Fail siblings.
- Rewrite remaining Bindings type folders (and overlapping Pending/Math) into `Unreal/<Type>` pockets, merging when they collide with Unreal first-batch themes.
- Project the new FileTags and add capability `angelscript/testing/host-api-fixtures`.

## Capabilities

### New Capabilities

- `angelscript/testing/host-api-fixtures`: admitted host-API author pockets under `Containers/` and additional `Unreal/<Type>` type folders from Bindings leftovers.

### Modified Capabilities

None. Language inventory stays core-language. Unreal first-batch UClass+World stays in `unreal-fixtures`.

## Impact

Parent repository: `AngelscriptTestCode/Containers/**`, additional `AngelscriptTestCode/Unreal/<Type>.as`, CodeGenTool tests, angelscript-test Skill routing, OpenSpec host-api-fixtures.
Plugin submodule: `TestCode/Generated/Containers/**`, additional `TestCode/Generated/Unreal/**`, `HostApiFixtureCorpusTests.cpp`.

## Non-goals

Language second-wave themes. Unreal first-batch 124 UClass + 124 World sources. GAS Optional. TestFramework Usage. Definitions / Feature / Gameplay / HotReload. Parser changes. Container execution. 122 generators.
