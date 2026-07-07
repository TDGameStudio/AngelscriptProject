## Why

The `AngelScriptSDK/` test directory had grown a structural problem: duplicated helper code, verbose per-file `_Private` namespaces, and the historical `ASSDK` naming made it hard to tell which tests were raw AngelScript SDK coverage and which helpers were intentionally shared. That cleanup is mostly represented in the current plugin code, but the original OpenSpec also accumulated broad behavior-coverage tasks that are not part of the namespace/helper refactor and should not block closing this change.

This change record is therefore narrowed to the structural SDK test cleanup that matches the current engineering state. Remaining runtime semantic coverage gaps are recorded as follow-up candidates rather than unfinished work in this refactor.

## What Changes

- Consolidate duplicated SDK test helpers into shared support headers:
  - `AngelscriptNativeTestSupport.h` for shared native engine, tokenizer, parser, bytecode, save/load, and diagnostic helpers.
  - `AngelscriptSDKTestExecutionHelpers.h` for raw-engine execution helpers such as `FSdkFunctionInvoker`, `ExecuteScriptFunction<T>()`, and `ExecuteScriptVoidFunction()`.
  - `AngelscriptSDKTestUtilities.h` for compatibility aliases during migration.
- Remove verbose `AngelscriptTest_*_Private` namespaces from `AngelScriptSDK/*.cpp`. File-local helpers may remain anonymous or uniquely named where Unity Build would otherwise collide.
- Collapse source/automation naming from `ASSDK` to `SDK` for the SDK test code and automation paths. Remaining prose references in test guides are tracked as documentation terminology cleanup, not source-level namespace residue.
- Preserve the raw bare-engine boundary for `AngelScriptSDK/` tests. These tests run below `FAngelscriptEngine`, so script-reference-class runtime behavior, UE string registration, and similar wrapper-dependent behavior are not forced into this refactor.
- Record the current gap split:
  - Structural cleanup: closeable in this change.
  - Behavior coverage expansion: defer to a future dedicated change such as `test-as-sdk-behavior-coverage`.
- Replace stale completion claims with current-state notes: the latest local audit sees 76 SDK `.cpp` files and 433 source-level `TEST_METHOD` definitions, but no fresh clean AngelScriptSDK test pass was established in the current audit.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `as-native-sdk-test-coverage`: clarify that this change modifies SDK test organization, naming, helper sharing, and the bare-engine coverage boundary. It no longer claims to complete all high-priority SDK runtime behavior coverage.

## Impact

- OpenSpec record: `openspec/changes/refactor-as-sdk-test-namespace-consolidation/*`.
- Code already reflected by current plugin state: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`.
- Deferred follow-up scope: object/OOP runtime execution gaps, string/atomic/thread disabled SDK tests, true suspend/resume semantics, Thiscall investigation, and broader runtime semantic coverage.
