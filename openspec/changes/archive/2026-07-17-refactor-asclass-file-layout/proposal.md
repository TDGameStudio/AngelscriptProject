## Why

`ASClass.h` and `ASClass.cpp` currently mix generated class metadata, object construction, script dispatch, optimized calls, RPC thunk handling, and specialized `UASFunction` subclasses in one large pair of files. This makes focused maintenance risky and makes small changes harder to review.

## What Changes

- Split `UASFunction` declarations into a dedicated public header while keeping `ASClass.h` as the compatibility include entry point.
- Split the large `ASClass.cpp` implementation into focused `.cpp` files by runtime responsibility.
- Preserve all public type names, UCLASS names, function signatures, generated reflection names, include compatibility, and runtime behavior.
- Do not introduce new user-visible behavior or change OpenSpec requirements.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None.

## Impact

- Affected source is limited to `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/`.
- Existing consumers of `ClassGenerator/ASClass.h` remain source-compatible.
- Build and verification rely on the standard project runners: `Tools/RunBuild.ps1` and `Tools/RunTests.ps1`.
