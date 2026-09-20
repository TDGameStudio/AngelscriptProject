## Why

Reconstructed `asCTokenizer` tests already isolate the pull lexer, but they still live under `NewVersion/`, hide helpers in an anonymous namespace, register a flat `NativeEngine` TestDir, and name only about 26 of 115 token kinds. The live TU contains seventeen contract methods. The user asked for a small first Change that is easy to inspect and prove, then a gradual move out of `NewVersion`.

The original helper plan also retained UE containers throughout. A later revision selected standard-library ownership for `FNativeEngineTokenizerTest` and imported the whole helper namespace at file scope. The user has now rejected that translation-unit-wide import because Unreal Unity builds may concatenate scenario files and leak short helper names into unrelated code. CQTest's registration and assertion macros are global macros, while `TEST_CLASS_WITH_FLAGS` expands to a global `struct`; each scenario class can therefore declare only the helper aliases it actually uses as private class members and return to `public:` before its `TEST_METHOD` registrations.

The creation plan used `asGetTokenSpellingAnsi(Kind)` as both the source generator and the vocabulary oracle. Because the tokenizer consumes the same `.def` table, deleting a row removes it from the loop and retargeting a unique spelling can make both producer and consumer change together. The current plan keeps table-driven execution but adds an independent accepted fingerprint and exact source-slice assertions.

A fixed inspection of LLVM/Clang 22.1.8 found 11 `clang/unittests/Lex` C++ files and 143 tests. Only the mixed 29-test `LexerTest.cpp` and four pull-style HLSL Root Signature tests are close to this tokenizer; the other 110 tests mostly exercise preprocessing, dependencies, headers, modules, and callbacks. Their transferable gaps are buffer-edge termination, authored spelling recovered through token ranges, raw/normal lexical parity, and an explicit case policy. The same audit found that the reconstructed tokenizer rejects UTF-8 BOM even though the AngelScript 2.38 tokenizer classifies `EF BB BF` as whitespace.

`angelscript/refactor-testing-unified-framework` already owns generic TestCode, source catalogs, typed data rows, generators, and the common frontend fixture. This Change does not implement that path; it makes Lexer the narrow, isolated pilot whose standard-library source/result/check seams can later be adapted by that framework.

## What Changes

- Populate the reserved `TestFramework/NativeEngine/NativeEngineTokenizerTest.h/.cpp` pair with `LexerTest::FNativeEngineTokenizerTest`. It owns byte strings, result collections, row names, and stable run indirection with `std::string`, `std::vector`, and `std::unique_ptr`, and exposes `std::string_view` / `std::span` read-only views.
- Keep `FromText(FStringView)` as the authored UE-text boundary and use `FromUtf8Bytes(std::string_view)` for explicit byte sequences. `FromText` converts once with `FTCHARToUTF8`; the snapshot adapter and `FNoDiscardAsserter::Fail(FString)` conversion are the only UE-container/string boundaries in the helper flow.
- Move all seventeen contract methods to `AngelscriptTest/NativeEngine/Lexer/LexerContractsTests.cpp` as `TEST_CLASS Contracts`, add `EmptyAndTriviaOnlySourcesReachStableEOF`, and retain the existing post-EOF pull assertion through an explicit repeated-EOF observation.
- Add `TEST_CLASS SpelledKinds` with 107 non-empty spelling round trips, an independently fixed fingerprint for all 115 rows, maximal-munch pairs, and a negative matrix that freezes case-sensitive keyword recognition.
- Add `TEST_CLASS Recovery` with bounded deterministic malformed-UTF-8 rows, exact diagnostic/range checks, valid-but-nonidentifier Unicode, string and comment buffer edges, CRLF state, and full RetainTrivia/RawDirective lexical projection parity.
- Add a grouped RED for leading UTF-8 BOM as whitespace and repair `frontend/Lexer/as_tokenizer.cpp` minimally after that RED is observed.
- Delete `NewVersion/NativeEngine/LexerTests.cpp`.
- Keep each `TEST_CLASS_WITH_FLAGS` at global scope and outside every namespace. Inside the generated class body, declare only the needed private aliases in the form `using X = LexerTest::X;`, then restore `public:` before every `TEST_METHOD`; do not introduce a file-scope helper import or alias.
- Record the Lexer nested public identity in the testing baseline delta and BOM behavior in the lexing delta.
- Before synchronizing those deltas, repair only the pre-existing two-space Scenario Card detail indentation in the two affected current specs. Preserve every word, behavior clause, detail block, and owning Scenario; this is a validator-format prerequisite, not a behavior change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/baseline`: Lexer tests use nested TestDir `Angelscript.UnitTest.NativeEngine.Lexer` with scenario classes `Contracts`, `SpelledKinds`, and `Recovery`. Replacement CQTest compiles under `WITH_ANGELSCRIPT_TESTS` from `AngelscriptTest/NativeEngine/`, not only `NewVersion/NativeEngine`.
- `angelscript/language/frontend/lexing`: A leading UTF-8 BOM is whitespace/trivia, retains its three source bytes in ranges, does not emit a Unicode diagnostic, and does not alter the configured Unicode-identifier policy.

All other added cases prove existing lexing behavior rather than expanding product scope.

## Impact

`AngelscriptTest` owns the helper and scenario move. `AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp` receives one BOM repair only after the task 1.3 grouped RED proves the documented mismatch. Old public path `Angelscript.UnitTest.NativeEngine.Lexer.<Method>` is replaced by `…Lexer.Contracts.<Method>`.

The Change does not edit `angelscript/refactor-testing-unified-framework` or implement TestCode. The lexer helper remains tokenizer-specific: it does not become a source catalog, generic frontend fixture, runtime test registrar, artifact sink, or general recipe engine.

## Boundaries

- No `FTestAST`, preprocessor, Sema, or Bindings helpers.
- No `FTestInputs` / `AS_TEST_SOURCE`.
- No dynamic Automation registration from generated negative rows; one statically registered Recovery method runs bounded named rows and includes the row name/bytes in failures.
- No macro provenance, token-paste, header search, preamble, split-token, lookahead, or C/C++ escaped-newline behavior copied from Clang.
- No decision in this Change for CR-only line policy, valid three/four-byte Unicode identifier categories, invalid bytes inside comments/strings, or ordinary unterminated strings meeting a physical newline.
- No relocation of the rest of `NewVersion/`.
- No `SourceDiagnostics` prefix decision.
- Do not wrap `TEST_CLASS_WITH_FLAGS` in a namespace, add a namespace-wide using-directive, or expose helper aliases at translation-unit scope.

## Acceptance

After this Change:

1. `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Lexer` discovers `Contracts`, `SpelledKinds`, and `Recovery`, and all three pass.
2. `Contracts` exposes the seventeen migrated method names plus `EmptyAndTriviaOnlySourcesReachStableEOF`; `NewVersion/NativeEngine/LexerTests.cpp` is gone.
3. `FNativeEngineTokenizerTest` is `std`-owned internally, retains one primary EOF plus one separate stable repeated-EOF probe, and can recover exact authored spelling from every captured token range.
4. The dynamic spelled-kind walk covers 107 non-empty rows, while fixed `0xa912c3f84387564e` FNV-1a fails if the accepted 115-row kind/spelling sequence is deleted, reordered, or retargeted.
5. `">>"` is one `ShiftRight`, `"**"` is one `Power`, the remaining overlapping shift/power spellings retain maximal munch, and keyword recognition passes the exact `class/Class/CLASS`, `Cast/cast`, and `UPROPERTY/UProperty/uproperty` case matrix.
6. The deterministic negative generator covers invalid UTF-8 leader, truncation, bad continuation, overlong, surrogate, and out-of-range families with stable row labels; every row asserts exact progress and first diagnostic range.
7. Empty source, pure trivia, comment-at-EOF, dangling string escape, valid nonidentifier Unicode, embedded NUL, unexpected input, Unicode-policy recovery, unterminated strings/comments, CRLF, and trivia transitions assert exact token progress, flags, diagnostic IDs, and ranges.
8. RetainTrivia and RawDirective produce identical tokenizer-stage kind/range/flag projections for the inspected directive-shaped source; interpretation of `#` remains preprocessor-owned.
9. With RetainTrivia, leading `EF BB BF` produces `Whitespace [0,3)` and no diagnostic; with SkipTrivia, BOM followed by `class` produces `KwClass [3,8)` with `StartOfLine | LeadingSpace` and exact EOF at byte 8.
10. The affected current lexing and testing-baseline specs pass strict validation before and after delta synchronization, with their pre-existing Scenario Card content and parentage unchanged except for required four-space ownership indentation.
