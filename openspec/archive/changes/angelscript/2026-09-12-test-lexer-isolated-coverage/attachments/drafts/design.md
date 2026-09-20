# Isolated lexer test coverage

First Change from draft `angelscript/test-framework-completion`. English record; user-facing discussion may stay Chinese.

## Context

The reconstructed pull lexer (`asCTokenizer`) is already isolated in `NewVersion/NativeEngine/LexerTests.cpp`: one `TEST_CLASS Lexer`, sixteen contract methods, public filter `Angelscript.UnitTest.NativeEngine.Lexer.*` (class token, flat TestDir). Helpers live in a file-level anonymous namespace. About 26 of 115 `as_token_kinds.def` kinds are named. The planning-only Change `angelscript/refactor-testing-unified-framework` owns TestCode / `AS_TEST_SOURCE` and is not reopened here.

Settled research: Q3 helper-only `TestFramework/`; Q7 `LexTestHelper.h`; Q23/Q24 TestDir `Angelscript.UnitTest.NativeEngine.Lexer`; Q27 A kind matrix; Q31–Q35 namespace `LexerTest`; Q37 Change ID; Q38 move out of `NewVersion`; Q39–Q41 paths, classes, and helper types.

## Goals / Non-Goals

**Goals:**

- Give lexer tests a durable home outside `NewVersion/`: helper in `TestFramework/`, TUs under `NativeEngine/Lexer/`.
- Replace the anonymous namespace with `namespace LexerTest` and class-scope `using LexerTest::…`.
- Nest TestDir so the public prefix is `Angelscript.UnitTest.NativeEngine.Lexer`.
- Keep the sixteen contract methods and add the Q27 spelled-kind matrix plus maximal-munch pairs.
- Prove the slice with Harness `ue.test` on that prefix.

**Non-Goals:**

- Product tokenizer changes, unless a new RED proves a bug; then fix that bug in this Change.
- `FTestAST`, preprocessor, Sema, Bindings, or relocating the rest of `NewVersion/`.
- `FTestInputs` / `AS_TEST_SOURCE` / TestCode (Q34 and the existing testing Change).
- Deciding the `SourceDiagnostics` public prefix.
- Walking AST `.def` tables.

## Decisions

### Split layout (Q3, Q38, Q39)

```text
AngelscriptTest/
├─ TestFramework/NativeEngine/LexTestHelper.h    // helpers only
│  └─ namespace LexerTest
└─ NativeEngine/Lexer/                           // tests; not TestFramework; not NewVersion
   ├─ LexerContractsTests.cpp
   └─ LexerSpelledKindsTests.cpp
```

Delete `NewVersion/NativeEngine/LexerTests.cpp` after the move. UBT already compiles the module tree; `ModuleDirectory` remains an include root (`#include "TestFramework/NativeEngine/LexTestHelper.h"`).

Rejected: leaving TUs in `NewVersion` (Q38). Rejected: tests under `TestFramework/` (Q3).

### Public identities (Q23, Q24, Q40)

| Piece | Value |
|---|---|
| TestDir | `Angelscript.UnitTest.NativeEngine.Lexer` |
| Classes | `Contracts`, `SpelledKinds` |
| Filters | `…Lexer.Contracts.*`, `…Lexer.SpelledKinds.*`, or `…Lexer` for both |

Today’s `TEST_CLASS Lexer` is renamed so the path is not `…Lexer.Lexer.*`. Existing method names stay.

### Helper surface (Q41)

`namespace LexerTest` in `LexTestHelper.h`:

- `FLexerSource` — move from the anonymous namespace; still builds a frozen snapshot via today’s `AngelscriptNativeEngineTest::FSourceInput::FromText` (no `FTestInputs`).
- `CheckLex` — Clang-shaped: source + expected `asETokenKind` sequence (non-trivia by default).
- `CaptureTokenProjection` — keep for contract tests that compare projection strings.

`MakeRepresentativeLexerCorpus`, `FLexerMeasurement`, and `MeasureLexer` stay in `TEST_CLASS Contracts` `private:` (Q18). They are not shared helper API.

CQTest TUs do not wrap `TEST_CLASS` in a namespace. They write `using LexerTest::FLexerSource;` / `using LexerTest::CheckLex;` in `private:`.

Rejected: `FTestLexer` (Q41). Rejected: file-scope `using namespace` (Q32).

### Kind matrix (Q27)

One (or few) `TEST_METHOD`s on `SpelledKinds`:

- Walk `asETokenKind`; skip empty `asGetTokenSpellingAnsi`; for each remaining spelling, snapshot that exact UTF-8 text and assert the first non-trivia token’s kind and range length.
- Extra pair rows: `">>"` is one `ShiftRight`, not two `Greater`; same idea for `**`, `>>>`, `>>=`, `>>>=`, `**=`.
- Do not hand-copy 107 pairs. Do not add 107 methods. Do not drop the sixteen contract methods.

Empty-spelling kinds (Invalid, EOF, whitespace, comments, Identifier, numeric, string) stay on `Contracts`.

### Product and other Changes

Default: tests only. A matrix or moved contract that fails because the tokenizer is wrong is an ordinary local repair in this Change.

Do not edit `angelscript/refactor-testing-unified-framework`. Do not add `AS_TEST_SOURCE`.

No lexing product spec delta unless a tokenizer bugfix changes observable contract. Public test identity may be recorded in a testing spec during Ensure plan if that Change needs a durable filter contract.

## Risks / Trade-offs

- First files at `AngelscriptTest/NativeEngine/` and `AngelscriptTest/TestFramework/` set the later migration shape. Later units should copy this split, not invent a third tree.
- Old filter `Angelscript.UnitTest.NativeEngine.Lexer.<OldMethod>` disappears; automation that pinned a method under the flat class must use `…Lexer.Contracts.<Method>`.
- `LexTestHelper.h` depending on `NativeEngineTestSupport.h` for `FSourceInput` is temporary until the source framework (Q34).
- Kind-matrix overlap with existing `class` / `>>` tests is intentional.

## Verification

Smallest proof: Harness `ue.test` with prefix `Angelscript.UnitTest.NativeEngine.Lexer` after a matching `ue.build` of `AngelscriptProjectEditor` (Win64, Development) when the binary would otherwise be stale.

Feature group (TDD): helper + move + TestDir/class rename + spelled-kind matrix + maximal-munch pairs. Observe RED on the new `SpelledKinds` methods and on discovery of the new public names; implement; GREEN the same prefix.

Do not treat `Quick`, Performance, Integration, or a full suite as a gate. Omit PP/Sema/VM prefixes unless a product tokenizer fix changes those callers.

Intentionally omitted: line-coverage run; Clang lit port; SourceDiagnostics relocation.
