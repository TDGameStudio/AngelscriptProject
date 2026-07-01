## ADDED Requirements

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

Cross-file helper utilities introduced by this change SHALL be inline header-only, added to the existing `AngelscriptNativeTestSupport` namespace in `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h`. No new helper header file SHALL be created.

#### Scenario: New helpers are inline and namespaced

- **WHEN** the helpers added by this change are inspected
- **THEN** `CreateBareSdkEngine`, `TokenizeAll`, `CountNodesOfType`, `NodeTypeHistogram`, `MaxNodeDepth`, `DumpBytecodeOpcodes`, and `EmitToBuffer` exist as inline functions inside `namespace AngelscriptNativeTestSupport`
- **AND** they reside in the same `AngelscriptNativeTestSupport.h` file as the existing `FNativeMessageCollector` / `CreateNativeEngine` / `CompileNativeModule` helpers

#### Scenario: Per-file accessor structs remain local

- **WHEN** a themed test file uses internal AS classes (`asCTokenizer` / `asCParser`) requiring protected-method access
- **THEN** the corresponding `FTokenizerAccessor` / `FParserAccessor` struct is defined in the test file's own anonymous or `_Private` namespace, not in the shared header

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

## Testing Requirements

- **Target test layer** (per `Documents/Guides/TestConventions.md` §1): Native Core (`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`).
- **Expected Automation prefix**: `Angelscript.TestModule.AngelScriptSDK.<Layer>.<Topic>` (per the layer-first strategy in `TestConventions.md` §4).
- **Recommended helper / harness**: `AngelscriptNativeTestSupport.h` (existing + new inline helpers); per-file `FTokenizerAccessor` / `FParserAccessor` accessor structs sourced from the existing pattern in `AngelscriptTokenizerTests.cpp` / `AngelscriptParserTests.cpp`; engine creation via the project's `ASTEST_CREATE_ENGINE_NATIVE()` macro then `reinterpret_cast` to `asCScriptEngine*`.
- **Verification entry-point command** (per `Documents/Guides/Test.md` standard entries):
  - Per-layer: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.<Layer>" -Label sdk-<layer> -TimeoutMs 600000`
  - Full SDK suite: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label sdk-all -TimeoutMs 600000`
