## Why

`AngelscriptHotReloadPropertyTests.cpp` still had gaps around property hot reload behavior: soft reload only checked compilation, full reload lacked failure isolation, property removal/type/specifier coverage, multi-class modules, and AS parent/child reload chains. Expanding the coverage also exposed a real UE reparenting edge case when an AS base class and AS child class are replaced in the same full reload.

## What Changes

- Refactor the property hot reload tests into CQTest classes that follow `Documents/UnitTest/UnitTest.md`.
- Expand soft reload coverage to assert member function behavior on existing and new objects, plus unrelated module preservation.
- Expand full reload coverage for added properties/defaults, enum defaults, failed reload isolation, property removal, type change, specifier flags, multi-class modules, and inheritance chains.
- Fix AS class full reload reparenting so simultaneous parent/child replacement does not corrupt CDO/template handling.

## Capabilities

### New Capabilities

- `as-hotreload-property-coverage`: Covers observable property hot reload behavior for soft reload, full reload, failed reload, and inheritance-chain replacement.

### Modified Capabilities

- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadPropertyTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.cpp`
- `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h`
