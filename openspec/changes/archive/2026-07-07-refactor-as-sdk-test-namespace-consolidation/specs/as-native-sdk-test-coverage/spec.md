# as-native-sdk-test-coverage (delta)

## ADDED Requirements

### Requirement: SDK namespace consolidation SHALL stay separate from SDK behavior coverage expansion

The native SDK test coverage record SHALL distinguish structural test-suite cleanup from new runtime semantic coverage. Helper consolidation, namespace cleanup, and naming convergence MAY be closed independently from broader language/runtime behavior expansion when current source evidence supports that split.

#### Scenario: Structural cleanup can close without behavior roadmap completion

- **WHEN** the `refactor-as-sdk-test-namespace-consolidation` change is evaluated for archive
- **THEN** helper consolidation, `_Private` namespace removal, and `ASSDK` to `SDK` naming cleanup are evaluated as the scope of that refactor
- **AND** remaining object/OOP/string/runtime-control/Thiscall/container coverage gaps are recorded as follow-up work rather than unchecked tasks in the namespace consolidation change

### Requirement: Native SDK behavior coverage SHALL respect the bare-engine boundary

Native SDK tests SHALL use raw `asIScriptEngine` / `asCScriptEngine` coverage for behavior that is executable on the bare engine. Behavior that depends on UE wrapper registration, string factory compatibility, script-reference-class runtime instantiation, or unexported internal symbols SHALL be covered by compile/metadata/expected-exception assertions or moved to a dedicated follow-up change in the appropriate test layer.

#### Scenario: Bare-engine limitations are documented instead of hidden

- **WHEN** a native SDK behavior case cannot execute on the bare engine
- **THEN** the test or OpenSpec record documents whether the case is covered by compile/metadata checks, expected-exception checks, or a deferred follow-up
- **AND** the namespace consolidation change does not claim that runtime behavior is fully covered

### Requirement: Native SDK tests SHALL use SDK naming and explicit behavior boundaries

The SDK test directory SHALL use `SDK` naming for source files, test classes, helper types, and automation IDs instead of the historical `ASSDK` prefix. Operator and behavior tests SHALL name whether they execute runtime behavior, validate compile/metadata behavior, or record a known bare-engine limitation.

#### Scenario: ASSDK source and automation naming is collapsed to SDK

- **WHEN** SDK test source files, helper names, test class names, and automation paths are inspected
- **THEN** there are no `ASSDK` file names, `FAngelscriptASSDK*` class names, `FASSDK*` helper types, or `Angelscript.TestModule.AngelScriptSDK.ASSDK.*` automation paths
- **AND** their `SDK`-named equivalents exist instead

#### Scenario: Behavior gaps are not represented as completed structural cleanup

- **WHEN** SDK tests still contain compile-only behavior cases, disabled raw SDK files, or bare-engine limitations
- **THEN** those cases are tracked as current-state audit findings or follow-up changes
- **AND** they do not prevent the namespace/helper consolidation change from being represented accurately

## MODIFIED Requirements

### Requirement: Native SDK tests SHALL share helpers via AngelscriptNativeTestSupport.h

Cross-file helper utilities SHALL be shared rather than copy-pasted per SDK test file. Helpers that are duplicated across two or more SDK test files SHALL be defined once in `namespace AngelscriptNativeTestSupport` in `AngelscriptNativeTestSupport.h`, or in a dedicated SDK support header such as `AngelscriptSDKTestExecutionHelpers.h` when the helper is specifically about raw-engine function execution. Truly file-local, single-use helpers MAY remain in a file's anonymous namespace. Verbose `AngelscriptTest_*_Private` named namespaces SHALL NOT be used; uniqueness needed under Unity Build SHALL be achieved by sharing common symbols and giving genuinely divergent helpers file-unique names.

#### Scenario: Shared helpers live in SDK support headers

- **WHEN** the SDK test support headers are inspected
- **THEN** shared tokenizer, parser, bytecode, save/load, module, and diagnostic helpers live in `AngelscriptNativeTestSupport.h`
- **AND** shared raw-engine execution helpers such as `FSdkFunctionInvoker`, `ExecuteScriptFunction<T>()`, and `ExecuteScriptVoidFunction()` live in `AngelscriptSDKTestExecutionHelpers.h`

#### Scenario: No verbose private namespaces remain

- **WHEN** the SDK test directory is searched for `namespace AngelscriptTest_*_Private`
- **THEN** there are zero source matches
- **AND** any remaining file-local helpers are anonymous or uniquely named so Unity Build does not create symbol collisions

#### Scenario: Module compiles under Unity Build

- **WHEN** `Tools\RunBuild.ps1` builds the editor target with Unity Build enabled
- **THEN** the `AngelscriptTest` module compiles with zero redefinition errors from merged SDK test translation units
