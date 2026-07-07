# as-native-sdk-test-coverage Specification

## Purpose
Track the native AngelScript SDK white-box test coverage expected from `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`, especially the Tokenizer, Parser, ScriptNode, Bytecode, and AS reference-derived layers that protect the fork's compiler-core behavior.
## Requirements
### Requirement: Native SDK 4 layers SHALL each have themed white-box unit test coverage

The `AngelscriptTest` module SHALL provide systematic white-box `TEST_METHOD` coverage for AngelScript native compiler core in four layers — Tokenizer (lexical analysis), Parser (syntax analysis), ScriptNode (AST), and Bytecode — beyond the existing sample-level baseline.

#### Scenario: Themed test files exist per layer

- **WHEN** the `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` directory is inspected after this change is applied
- **THEN** each of the four layers has at least three themed test files following the `AngelscriptNative<Layer><Topic>Tests.cpp` naming convention (Tokenizer: Literals/Operators/Whitespace; Parser: Declarations/Expressions/Errors; ScriptNode: Shape/SourceRange/Copy; Bytecode: Opcodes/Jumps/Optimize)
- **AND** the existing `AngelscriptTokenizerTests.cpp` / `AngelscriptParserTests.cpp` / `AngelscriptScriptNodeTests.cpp` / `AngelscriptBytecodeTests.cpp` files remain unchanged in class name and Automation prefix

#### Scenario: Tokenizer coverage exercises full token taxonomy

- **WHEN** the Tokenizer themed test files are inspected
- **THEN** the test methods collectively cover identifier / keyword / numeric literal varieties (decimal / hex / float exponent / suffixes) / string literal escape sequences / character literals / full operator matrix (arithmetic / bitwise / comparison / logical / assignment / increment / ternary / scope / handle) / whitespace / comments / BOM / EOF / error recovery
- **AND** each test method directly invokes `asCTokenizer::GetToken` via the project's `FTokenizerAccessor` pattern (`struct FTokenizerAccessor : asCTokenizer { using asCTokenizer::GetToken; };`)

#### Scenario: Parser coverage exercises declarations / expressions / errors

- **WHEN** the Parser themed test files are inspected
- **THEN** the test methods cover function / class / interface / namespace / enum / typedef / funcdef / import / property accessor / operator overload declarations, expression precedence / associativity / cast / member access / index / named arg, and error recovery scenarios
- **AND** each test method directly invokes `asCParser::ParseScript` / `ParseExpression` / `ParseStatement` via the project's `FParserAccessor` pattern

#### Scenario: ScriptNode coverage exercises tree shape / source range / copy

- **WHEN** the ScriptNode themed test files are inspected
- **THEN** the test methods collectively cover representative `eScriptNode` shapes (function / parameter list / statement block / return / break / continue / do-while / switch / case / enum / interface / import / funcdef / typedef / virtual property), source range (line/col) propagation, and `CreateCopy` fidelity including deep-nesting stack safety

#### Scenario: Bytecode coverage exercises opcode buckets / jumps / optimize

- **WHEN** the Bytecode themed test files are inspected
- **THEN** the test methods collectively cover representative opcodes from each `asEBCType` bucket (push / load / call / branch / misc / ret / math / compare), forward and backward jump resolution, multiple labels resolved independently, error path for unresolved labels, optimize pass effect, and output buffer round-trip stability

### Requirement: Native SDK tests SHALL register under the existing AngelscriptNative group without configuration changes

The new themed test files SHALL be discoverable through the existing `AngelscriptNative` Automation group declared in `Config/DefaultEngine.ini` (which globs `Angelscript.TestModule.AngelScriptSDK.*` via `MatchFromStart=true`). No new Automation group, no new `DefaultEngine.ini` entry, and no change to `AngelscriptTest.Build.cs` SHALL be required.

#### Scenario: Layer-themed automation prefixes are auto-discovered

- **WHEN** the Unreal automation framework scans tests after this change is applied
- **THEN** new test classes registered under `Angelscript.TestModule.AngelScriptSDK.<Layer>.<Topic>` (where `<Layer>` is `Tokenizer` / `Parser` / `ScriptNode` / `Bytecode` and `<Topic>` is the file's themed sub-area) are listed
- **AND** they are matched by the existing `AngelscriptNative` group filter without any new group declaration

#### Scenario: Build system requires no explicit file listing

- **WHEN** new themed test `.cpp` files are added under `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`
- **THEN** the standard build via `Tools\RunBuild.ps1` discovers and compiles them automatically
- **AND** `AngelscriptTest.Build.cs` is not modified to list any new file

### Requirement: Existing native SDK tests SHALL remain green after each phase

Each phase landing of this change SHALL preserve the existing 17 native SDK `TEST_METHOD` cases and their Automation prefixes; no test discovery or pass-rate regression is acceptable.

#### Scenario: Existing test classes are untouched

- **WHEN** the source tree is diffed against the pre-change baseline after each phase
- **THEN** `AngelscriptTokenizerTests.cpp` / `AngelscriptParserTests.cpp` / `AngelscriptScriptNodeTests.cpp` / `AngelscriptBytecodeTests.cpp` retain their existing `TEST_CLASS_WITH_FLAGS` class names and Automation prefix paths
- **AND** their existing `TEST_METHOD` names are unchanged

#### Scenario: AngelscriptNative group regression remains green

- **WHEN** `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK"` is executed at each phase boundary
- **THEN** the run reports zero failures across both pre-existing and newly-added test methods

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

### Requirement: Native SDK tests SHALL respect project test conventions and inline AS formatting rules

All new test files SHALL conform to `Documents/Guides/TestConventions.md` (file naming, Automation prefix layering, `AngelscriptTest` module placement) and `Documents/Rules/ASInlineFormattingRule.md` (raw string delimiter, column-0 origin, Tab indentation, Allman braces, no `\n` concatenation).

#### Scenario: File naming follows ASSDK / Native rule

- **WHEN** new test file names are inspected
- **THEN** they follow the `AngelscriptNative<Layer><Topic>Tests.cpp` pattern as specified in `TestConventions.md` §2 ASSDK / Native rules

#### Scenario: Inline AS code uses raw strings at column 0

- **WHEN** new test files contain inline AS code via `TEXT(R"(...)")` or `TEXT(R"AS(...)AS")`
- **THEN** the AS content begins at column 0 (independent of surrounding C++ indentation), uses Tab indentation, Allman braces, and one blank line between functions / `UPROPERTY` groups / `UCLASS` definitions

#### Scenario: ASSDK tests do not use `\n` string concatenation

- **WHEN** any new ASSDK-layer test file is inspected
- **THEN** AS source fragments are expressed as raw string literals, not `"\n"`-concatenated string sequences

### Requirement: Native SDK test coverage SHALL document its current scale in the test catalog

When this change is applied through its final phase, the project test documentation SHALL reflect the new native SDK coverage scale.

#### Scenario: TestCatalog reflects new TEST_METHOD count

- **WHEN** `Documents/Guides/TestCatalog.md` is inspected after the final phase
- **THEN** the AngelScriptSDK section reports 151 new native SDK coverage cases and the latest `Angelscript.TestModule.AngelScriptSDK` verification snapshot of `301/301 PASS`
- **AND** it includes the per-layer breakdown: Tokenizer 40, Parser 35, ScriptNode 25, Bytecode 23, Reference 28

#### Scenario: Test guide lists per-layer entry commands

- **WHEN** `Documents/Guides/Test.md` is inspected after the final phase
- **THEN** the SDK section lists `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.<Layer>"` example commands for each of the four layers
- **AND** all listed commands include explicit `-TimeoutMs` parameters per the project's mandatory rule (`Documents/Guides/Test.md` "Mandatory Rules")

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

