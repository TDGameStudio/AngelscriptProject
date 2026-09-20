## Why

UClass and World programs are UE features. They must not enter Language. The Bindings directory name is rejected. The corpus needs an admitted `Unreal/` root.

## What Changes

- Create `AngelscriptTestCode/Unreal/` and rewrite 124 Language UClass files plus 124 Pending/World files into the named theme pockets.
- Project those FileTags through the existing CodeGen discovery path.
- Add capability `angelscript/testing/unreal-fixtures` and a Framework corpus test.

## Capabilities

### New Capabilities

- `angelscript/testing/unreal-fixtures`: admitted UE-feature author pockets under `Unreal/`.

### Modified Capabilities

None. Language inventory stays core-language.

## Impact

Parent repository: `AngelscriptTestCode/Unreal/**`, CodeGenTool tests, angelscript-test Skill routing, OpenSpec unreal-fixtures.
Plugin submodule: `TestCode/Generated/Unreal/**`, `UnrealFixtureCorpusTests.cpp`.

## Non-goals

Language second-wave themes. 580 Bindings leftovers. Parser changes. World execution. 122 generators.
