## Why

`AngelscriptTest` already contains reusable helpers that extension plugin test modules need, but the public helper boundary is implicit. `AngelscriptGASTest` currently works around that ambiguity by hardcoding a path into `Plugins/Angelscript/Source/AngelscriptTest`, which couples it to source layout instead of the `AngelscriptTest` module contract.

## What Changes

- Formalize `AngelscriptTest` as the supported provider of reusable test helpers for Angelscript extension plugin test modules.
- Document the curated helper include surface that external test modules may use through an `AngelscriptTest` module dependency.
- Remove the `AngelscriptGASTest` hardcoded `PrivateIncludePaths` entry that points into the Angelscript plugin source tree.
- Keep current helper file layout stable; do not introduce a new `AngelscriptTestSupport` module in this change.
- Keep internal test directories such as `Core`, `Debugger`, `Dump`, `Preprocessor`, and `ClassGenerator` outside the stable extension helper API unless a later change explicitly promotes them.
- Update test documentation so the public helper paths match the actual `Shared/...` and `AngelScriptSDK/...` layout.

## Capabilities

### New Capabilities

- `angelscript-test-helper-api`: Defines how extension plugin test modules consume reusable helpers from `AngelscriptTest` without hardcoded source paths.

### Modified Capabilities

- None.

## Impact

- Build rules: `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` and `Plugins/AngelscriptGAS/Source/AngelscriptGASTest/AngelscriptGASTest.Build.cs`.
- Documentation: `Documents/Guides/TestConventions.md` and related test guidance where helper include paths are described.
- Test consumers: `Plugins/AngelscriptGAS/Source/AngelscriptGASTest` as the first extension plugin validation target.
- OpenSpec: a new `angelscript-test-helper-api` capability under this change.
