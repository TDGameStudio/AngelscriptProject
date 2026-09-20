# First Change: isolated lexer tests

User 2026-09-12: create a Change for the lexer slice first — easier to inspect and prove. Do not implement here.

Does not reopen design mode for `angelscript/refactor-testing-unified-framework` (TestCode / `AS_TEST_SOURCE` / data-driven). That Change stays planning-only. This slice must not implement that source framework (Q34 held).

---

## Why lexer first

Product `asCTokenizer` is pull-only, engine-independent, already isolated in `LexerTests.cpp` (16 methods). Public filter `Angelscript.UnitTest.NativeEngine.Lexer.*` already works. The missing piece is the Q27 kind matrix plus the settled helper/namespace/TestDir rules — not Parser or Sema.

---

## In (if this Change is created)

- `TestFramework/NativeEngine/LexTestHelper.h` (Q7). Namespace `LexerTest` (Q33/Q35).
- Move today’s file-local `FLexerSource` / `CaptureTokenProjection` out of the anonymous namespace (rejected).
- Keep the 16 contract methods.
- Q27 A: one table-driven method over 107 non-empty `asGetTokenSpellingAnsi` rows + extra maximal-munch pairs (`>>`, `**`, …).
- Still feed UTF-8 through today’s `FSourceInput::FromText` (not `FTestInputs` / `AS_TEST_SOURCE`).
- Prove with Harness `ue.test` on `Angelscript.UnitTest.NativeEngine.Lexer`.
- Tests-only unless a new RED proves a product tokenizer bug; then fix that bug in this Change.

## Out

- `FTestAST`, AST/Sema/PP/Bindings helpers.
- Unified source framework / `FTestInputs` home (Q34).
- Editing `refactor-testing-unified-framework`.
- Relocating the rest of `NewVersion/`.
- `SourceDiagnostics` prefix (held).
- Walking AST `.def` tables.

---

## Three ways to land it

```text
A  In place + first helper                         ◆ recommended
   NewVersion/NativeEngine/LexerTests.cpp stays
   + TestFramework/NativeEngine/LexTestHelper.h
   + TestDir …NativeEngine.Lexer  (Q23/Q24)
   + kind matrix
   // smallest Change that still applies the settled Lex rules

B  Also leave NewVersion for this unit
   NativeEngine/Lexer/*.cpp + the same helper/TestDir/matrix
   // starts the “NewVersion is not the later home” move; more path churn

C  Matrix only, no TestDir / no TestFramework yet
   add the loop to today’s TEST_CLASS Lexer
   // easy green; leaves Q23/Q24/helper/anonymous-namespace debt
```

Recommendation: **A**. Easy `ue.test` prefix, first real `TestFramework/` file, no tree move. Flip to B if this Change must be the first unit out of `NewVersion`. Flip to C if they want coverage only and will nest TestDir later.

---

## Settled from Round 26

| ID | Choice | Meaning |
|---|---|---|
| Q37 A | `angelscript/test-lexer-isolated-coverage` | First Change ID. |
| Q38 | Move out of `NewVersion` | User: 搬出来，一部分进新测试框架和新目录架构；`NewVersion` 以后再迁。Interpreted as approach B plus the Q3 split: helper → `TestFramework/`; tests → new area tree, not inside `TestFramework/`. |

## Settled from Round 27

| ID | Choice | Meaning |
|---|---|---|
| Q39 A | `AngelscriptTest/NativeEngine/Lexer/` | Test TUs here. |
| Q40 A | `Contracts` + `SpelledKinds` | After TestDir nesting. |
| Q41 A | `FLexerSource` + `CheckLex` | No `FTestLexer`. |

Design written to `design.md`. Handoff waits on user review.
