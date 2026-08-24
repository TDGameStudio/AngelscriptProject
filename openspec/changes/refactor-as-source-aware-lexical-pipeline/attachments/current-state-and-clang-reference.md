# Current lexical baseline and Clang architecture reference

## Evidence boundary

This attachment records the code and reference snapshot inspected when the OpenSpec was created. It is architectural evidence, not an implementation import list. Line numbers refer to the repository state on 2026-08-21 and may move during implementation; symbol names and Git object paths are the durable lookup keys.

The Clang/LLVM reference is the local `Reference/llvm-project` repository at:

```text
9bc4fd0fafb58ff1fb50231e39a882a678542dac
2026-08-09 02:08:29 +0000
```

The checkout may be sparse, but every cited path is available through:

```powershell
git -C Reference/llvm-project show HEAD:<path>
```

No source in `Reference/llvm-project` is copied, linked, or edited by this change.

## Current maintained-fork token path

| Concern | Current evidence | Consequence |
|---|---|---|
| Tokenizer entry | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.h:55`, `as_tokenizer.cpp:134` | Tokenization accepts a raw pointer/length and returns one kind/length at a time |
| Public single-token API | `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h:921` | `asIScriptEngine::ParseToken` is a compatibility contract and cannot simply disappear |
| Parser token record | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptnode.h:100` | `sToken` is a minimal Parser-oriented position record rather than a source-managed lexical object |
| Parser acquisition | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp:962` | Parser owns token traversal and skips trivia by repeatedly requesting tokens |
| Direct tokenizer call | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp:988` | Parser indexes `script->code` by byte position and calls `engine->tok.GetToken` directly |
| Parser rewind | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp:1007` | Speculation/error paths restore byte position, causing the same text to be tokenized again |
| Row/column conversion | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptcode.cpp:153` | Source location resolution is separate from the token and has no general authored/generated mapping authority |
| Token definitions | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokendef.h` | Current token kinds are AngelScript language contracts/oracles, not Clang token kinds to replace wholesale |

`as_parser.cpp` contains many `GetToken`/`RewindTo` pairs across grammar functions. The migration must therefore introduce a compatibility cursor layer and move grammar clusters incrementally; a one-shot mechanical signature replacement would not prove recovery/lookahead equivalence.

## Current UE host lexical duplication

| Concern | Current evidence | Consequence |
|---|---|---|
| Main chunk scanner | `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:3510` | `ParseIntoChunks` performs low-level character scanning and host interpretation together |
| Local lexical states | same file around lines 3521-3523 and 4481-4559 | Comments and strings are tracked independently from `asCTokenizer` |
| Directive recognition | same file around line 3812 | Directive markers are filtered through local comment/string state |
| UE declaration recognition | same file around lines 4169-4171 | UCLASS/USTRUCT/UENUM interpretation is host behavior and must remain outside RawLexer |
| Additional scanners | same file around lines 4662, 4867, and `FindScopeCloseBracket` at 5049 | Several helpers repeat comment/string/delimiter state rather than consume one lexical truth |
| Boundary anomaly | same file around line 3617 checks `PrevChar >= '0' && PrevChar <= '1'` | This is evidence of scanner drift/defect risk; implementation must first add a focused regression oracle rather than silently fold an unrelated semantic correction into refactoring |

The correct target is not “delete the preprocessor.” The target is to delete duplicated raw boundary recognition while retaining host directives, provider policy, descriptors, rewrites, generated source, mappings, and events.

## Existing regression surfaces

Native frontend coverage already exists under:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeTokenizer*.cpp`;
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeParser*.cpp`;
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeScriptCodePositionTests.cpp`;
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp`.

UE host coverage already exists under:

- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/`;
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/SourceProvenance/`;
- automation prefix `Angelscript.TestModule.Preprocessor`.

These tests are baselines to extend and reorganize, not justification to skip differential corpus and malformed-input coverage.

## Clang concepts used as architecture evidence

| Clang path | Useful idea | AngelScript translation |
|---|---|---|
| `clang/include/clang/Basic/SourceLocation.h` | Compact locations separated from file/source storage | `asCSourceLocation`/`asCSourceRange` refer into one AngelScript SourceManager |
| `clang/include/clang/Basic/SourceManager.h` | Central buffer identity, line/column, and source mapping authority | Stable logical source keys plus build-local IDs and authored/processed/generated mappings |
| `clang/include/clang/Lex/Token.h` | Compact token separate from AST and source ownership | `asCToken` carries kind/range/flags plus optional build-local refs |
| `clang/include/clang/Lex/Lexer.h` | Monotonic physical spelling recognition | `asCRawLexer` scans one immutable AS buffer and guarantees progress |
| `clang/include/clang/Lex/Preprocessor.h` | Token-producing layer between Lexer and Parser | AS uses classification/source-preparation adapters, not the C preprocessor feature set |
| `clang/include/clang/Parse/Parser.h` | Parser consumes tokens and performs grammar lookahead/recovery | `asCParser` consumes `asCTokenCursor` and later invokes AS Sema actions |
| `clang/include/clang/Basic/TokenKinds.h` | Centralized token vocabulary | Existing AS `eTokenType` remains the semantic baseline; numeric/kind sets are not copied |
| `clang/lib/Lex/Lexer.cpp` | Boundary, progress, raw identifier, and literal handling organization | Inform internal layering and tests without source copying |
| `clang/lib/Lex/Preprocessor.cpp` | Separation of raw lexing from higher token production | Inform the host/core boundary without adopting macros/header search/PCH/modules |

## Explicit non-adoption list

The following Clang elements are out of scope:

- concrete `clang::Token`, `clang::Lexer`, `clang::Preprocessor`, `clang::SourceManager`, or diagnostics classes;
- C/C++/Objective-C token numbers, language modes, contextual keyword tables, or literal semantics;
- macro expansion, token pasting/stringification, header search, pragma handlers, module maps, PCH, and precompiled preambles;
- Clang allocator, LLVM ADT, LLVM support library, or LLVM IR dependencies in the maintained frontend;
- licensing/provenance shortcuts that treat architectural reference as permission to copy implementation.

## Research conclusion

Clang supports the layering decision, not a code-reuse decision. The AS-native target is one source identity system, one raw spelling authority, buffered/indexed Parser consumption, and host-specific source preparation above the raw lexer. The accepted AngelScript/UE behavior and maintained test suite remain authoritative whenever Clang's design differs.
