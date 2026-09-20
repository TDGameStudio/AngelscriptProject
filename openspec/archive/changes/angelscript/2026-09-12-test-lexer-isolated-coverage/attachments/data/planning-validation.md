# Plan-acceptance self-review

Change: `angelscript/test-lexer-isolated-coverage`
Date: 2026-09-12

## Coverage

- The proposal's layout, standard-library ownership, exact UE/product adapters, Unity-safe class-alias boundary, all-seventeen-contract move, new empty/pure-trivia contract, source slicing, repeated EOF, and old-TU removal map to task 1.1.
- The 115-row accepted-vocabulary fingerprint, 107 non-empty round trips, six maximal-munch spellings, and case-sensitive keyword matrix map to task 1.2.
- The bounded 16-row malformed generator, exact UTF-8/NUL/unknown/Unicode/string/comment/CRLF/trivia assertions, buffer-tail rows, RawDirective parity, and BOM RED/repair map to task 1.3.
- Testing/baseline delta examples map to the matching task. The lexing delta's leading-BOM behavior maps to task 1.3's exact RetainTrivia and SkipTrivia rows.
- Shared final acceptance maps to sibling tasks 1.2 and 1.3 after their common prerequisite 1.1. The expected final method inventory is 18 Contracts, four SpelledKinds, and nine Recovery methods.

Every proposal acceptance line and each delta-spec observable/boundary is represented in the Requirement coverage table and at least one task Case. Heavier suites are explicitly excluded because the demonstrated impact stops at the tokenizer boundary; the product BOM change neither changes token kinds after byte 3 nor expands to downstream PP/Parser behavior.

## Placeholders

Scanned `proposal.md`, `design.md`, `tasks.md`, and both delta specs for `TBD`, `TODO`, `implement later`, `fill in details`, `add appropriate error handling`, `add validation`, `handle edge cases`, `write tests for the above`, `similar to Task`, `known values`, `existing fixtures`, and unqualified `preserve behavior`. None occur.

Every behavior card has inspected/future Interfaces fences, literal Given/When/Then cases, one direct Files fence, and one direct executable Verification fence. Task IDs and direct dependency edges remain complete: `1.1` is the root; `1.2` and `1.3` depend only on `1.1`.

## Symbols

Current planning truth consistently uses:

- namespace `LexerTest`, global CQTest scenario classes, and the exact private alias sets recorded per class;
- fixture `FNativeEngineTokenizerTest` with `FromText`, `FromUtf8Bytes`, `WithOptions`, `GetSourceBytes`, `GetTokens`, `GetDiagnostics`, `GetRepeatedEndOfFile`, `Describe`, `CheckKinds`, `Check`, and `GenerateMalformedUtf8Cases`;
- expectation types `FExpectedToken`, `FExpectedLexDiagnostic`, `FLexExpectation`, and `FMalformedUtf8Case`;
- standard types `std::string`, `std::string_view`, `std::vector`, `std::span`, `std::unique_ptr`, and `std::initializer_list` at owned/view/convenience boundaries;
- TestDir `Angelscript.UnitTest.NativeEngine.Lexer` and classes `Contracts`, `SpelledKinds`, `Recovery`;
- files `NativeEngineTokenizerTest.h/.cpp`, `LexerContractsTests.cpp`, `LexerSpelledKindsTests.cpp`, `LexerRecoveryTests.cpp`, and live product path `frontend/Lexer/as_tokenizer.cpp`.

The historical draft/glossary names `FLexerSource`, `CheckLex`, two scenario classes, `AngelscriptNativeEngineTest`, class-scope using declarations, and 16 contract methods are superseded. Direct source inspection finds 17 current `TEST_METHOD` declarations; task 1.1 adds one. The reserved tokenizer helper pair supplies the landing name; sibling `1.h` and `NativeEngineASTTest.*` placeholders stay outside scope.

## Oracle and API checks

- The table-driven spelled-kind round trip is retained as execution coverage but is not described as independent. Fixed `0xa912c3f84387564e`, `Count == 115`, and `non-empty == 107` freeze the accepted table; exact source slicing proves ranges refer back to authored bytes.
- The negative generator produces only 16 stable name/byte rows. Its fixed `0x5b75772962a8f9f5` digest is independent of tokenizer output; Recovery expectations are authored separately.
- `std::string_view` and `std::string` retain explicit byte counts for embedded NUL/malformed input. `FTCHARToUTF8` and `FUTF8ToTCHAR` are length-aware conversion boundaries; `TConstArrayView<uint8>` is a temporary AddFile adapter, not helper ownership.
- One primary EOF remains in ordinary token expectations. A distinct second Lex probe and `GetRepeatedEndOfFile` retain the current sticky-EOF assertion within a `byte_count + 2` total-pull bound.
- Current `LexUnicodeOrInvalid` distinguishes malformed UTF-8, policy-disabled Unicode, and valid nonidentifier Unicode. U+00A2 supplies the third exact branch without expanding identifier category policy.
- AngelScript 2.38 explicitly recognizes `EF BB BF` as three-byte whitespace. The live reconstructed tokenizer's current Unicode diagnostic is therefore an evidence-backed grouped RED, and task 1.3 owns only the minimum corresponding product file.
- `FNoDiscardAsserter&` remains explicit because CQTest assertion macros are class-bound. The global CQTest macros require no helper import. `Contracts` aliases three helper types, `SpelledKinds` one, and `Recovery` five under `private:`, then each class restores `public:` before `TEST_METHOD`; no helper name leaks into a Unity translation unit.
