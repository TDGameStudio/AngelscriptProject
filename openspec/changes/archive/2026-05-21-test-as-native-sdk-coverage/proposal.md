## Why

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` currently provides only 17 `TEST_METHOD` cases across the four layers of the AS native compiler core (lexing / parsing / AST / bytecode): `AngelscriptTokenizerTests.cpp` 5, `AngelscriptParserTests.cpp` 5, `AngelscriptScriptNodeTests.cpp` 3, and `AngelscriptBytecodeTests.cpp` 4. This is sample-level white-box coverage. Each layer already has the minimum access infrastructure (`FTokenizerAccessor`, `FParserAccessor`, direct `asCByteCode` construction), but many branches remain unlocked: token types, operator matrices, AST node shapes, opcode buckets, jump resolution, and error recovery. For a fork that has reached maturity and selectively backports from upstream AS 2.38 (see `Documents/Guides/AngelscriptForkStrategy.md`), this sample coverage is not enough to catch behavior drift early during selective backports. This change systematically fills in white-box coverage for the four layers, increasing the native unit-test scale from 17 to ~132 without changing product code.

## What Changes

- Add 12 native unit-test files across four layers, three themed files per layer:
  - Tokenizer: `AngelscriptNativeTokenizer{Literals,Operators,Whitespace}Tests.cpp`
  - Parser: `AngelscriptNativeParser{Declarations,Expressions,Errors}Tests.cpp`
  - ScriptNode: `AngelscriptNativeScriptNode{Shape,SourceRange,Copy}Tests.cpp`
  - Bytecode: `AngelscriptNativeBytecode{Opcodes,Jumps,Optimize}Tests.cpp`
- Add seven inline header-only helpers to `AngelscriptNativeTestSupport.h` (`CreateBareSdkEngine`, `TokenizeAll`, `CountNodesOfType`, `NodeTypeHistogram`, `MaxNodeDepth`, `DumpBytecodeOpcodes`, `EmitToBuffer`) without affecting existing helpers.
- Add ~115 `TEST_METHOD` cases (Tokenizer ~30, Parser ~35, ScriptNode ~25, Bytecode ~25), all auto-collected by the existing `AngelscriptNative` group.
- Update `Documents/Guides/TestCatalog.md` counts (17 → ~132), `Documents/Guides/Test.md` SDK sub-prefix example commands, and `Plugins/Angelscript/AGENTS.md` native test scale numbers.
- Do **not** modify the existing four core test files' class names / Automation prefixes, avoiding discovery regressions.
- Do **not** modify product code, `Build.cs`, or engine `.ini` configuration.
- Do **not** directly port the Reference SDK native `test_compiler.cpp` (6286 lines); use it only as scenario inspiration.

## Capabilities

### New Capabilities

- `as-native-sdk-test-coverage`: a systematic white-box unit-test coverage contract for the four AS native compiler-core layers (lexing, parsing, AST, bytecode). It defines test-file placement, layered Automation prefixes, accessor pattern reuse, helper sharing location, and sub-prefix regression commands.

### Modified Capabilities

(None — this change does not modify existing spec requirement behavior.)

## Impact

- **Code paths**: add 12 files under `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`; append inline helpers to `AngelscriptNativeTestSupport.h`.
- **APIs**: no public API changes; tests use existing fork-internal access paths (`asCTokenizer::GetToken` promoted through a protected accessor, `asCParser::ParseScript/ParseExpression/ParseStatement`, public `asCByteCode` construction).
- **Dependencies**: only depend on fields already present in the current fork baseline, `2.33 + selective 2.38` (`Documents/Guides/AngelscriptForkStrategy.md`).
- **Build**: `AngelscriptTest.Build.cs` already recursively scans directories, so new `.cpp` files are included automatically without modification.
- **Runtime budget**: ~115 cases are all in-memory-level tests (no module `Build()` path), estimated accumulated runtime < 10s, far below the 600000ms default budget (`Documents/Guides/Test.md` mandatory rule).
- **Existing test discovery**: before each phase submission, run the full `Angelscript.TestModule.AngelScriptSDK` prefix to confirm the existing 17 cases still pass 100%.
- **Documentation**: update `TestCatalog.md`, `Test.md`, and `Plugins/Angelscript/AGENTS.md`; `TechnicalDebtInventory.md` does not need an update because this change does not close a listed debt item.
