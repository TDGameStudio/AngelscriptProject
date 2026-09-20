Draft: `angelscript/test-framework-completion` (lexer slice accepted 2026-09-12)

# Problem

Reconstructed `asCTokenizer` tests are isolated in behavior but not in layout: one `TEST_CLASS Lexer` lives under `NewVersion/`, helpers sit in an anonymous namespace, TestDir is flat `NativeEngine`, and only about 26 of 115 token kinds are named. The user wants a small, easy-to-prove first Change for this unit, then a gradual move out of `NewVersion`.

# Success Criteria

- Helper header `TestFramework/NativeEngine/LexTestHelper.h` owns `namespace LexerTest` with `FLexerSource`, `CheckLex`, and `CaptureTokenProjection`.
- Contract methods live in `AngelscriptTest/NativeEngine/Lexer/` as `TEST_CLASS Contracts` with TestDir `Angelscript.UnitTest.NativeEngine.Lexer`.
- `TEST_CLASS SpelledKinds` walks 107 non-empty `asGetTokenSpellingAnsi` rows plus maximal-munch pairs.
- `NewVersion/NativeEngine/LexerTests.cpp` is gone. CQTest uses class-scope `using LexerTest::…`, not an anonymous namespace and not `using namespace` in the class.
- `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Lexer` discovers and passes both classes.
- No TestCode / `AS_TEST_SOURCE` / `FTestInputs` work. No product lexer change unless a new RED proves a tokenizer bug.

# Evidence

- Live suite: `LexerTests.cpp`, 16 methods, filter `…NativeEngine.Lexer.*` via class name.
- `as_token_kinds.def`: 115 rows; 8 empty spellings; 107 spelled.
- Settled Q23/Q24, Q27 A, Q31–Q41, Q42 A. Source framework Q34 held.
- Planning-only Change `angelscript/refactor-testing-unified-framework` owns TestCode.

# Scope and Exclusions

In: `LexTestHelper.h`; move contracts; nest TestDir; `Contracts` + `SpelledKinds`; kind matrix; delete old TU; optional testing-baseline delta that replacement tests are not `NewVersion/`-only.

Out: `FTestAST`; PP/Sema/Bindings; rest of `NewVersion/`; TestCode / `FTestInputs`; `SourceDiagnostics` prefix; AST `.def` tables; Clang lit port.

# Constraints

- Do not implement or edit `angelscript/refactor-testing-unified-framework`.
- Feed snapshots through existing `FSourceInput::FromText` until Q34.
- Tests-only unless RED proves a tokenizer defect.
- `WITH_ANGELSCRIPT_TESTS` remains the replacement gate.

# Options

Compared in `findings/lexer-change-scope.md`. In-place-only (A) and matrix-only (C) rejected. User chose move-out: helper in `TestFramework/`, tests in `NativeEngine/Lexer/`.

# Decision and Rationale

First Change is `angelscript/test-lexer-isolated-coverage`. Lexer is pull-only and already filterable, so layout + vocabulary coverage can be proven with one prefix without waiting for TestCode.

# Flip Condition

If the unified source framework must land before any new helper, park this Change and do not add `FLexerSource` on `FSourceInput`. If product lexer work is required first, this test Change is the wrong owner.

# Architecture, Components, and Data Flow

See `design.md`. Split: `TestFramework/` helpers, `NativeEngine/Lexer/` tests. `CheckLex` consumes `FLexerSource` and asserts kind sequences. `SpelledKinds` walks generated spellings from `as_token.h`.

```text
FLexerSource(text)
└─[uses] FSourceInput::FromText → frozen snapshot
   └─[feeds] asCTokenizer.Lex
      ├─[Contracts] 16 existing stories
      └─[SpelledKinds] CheckLex per spelled kind + >> / ** pairs
```

# Failures and Edge Cases

- Empty-spelling kinds are not matrix rows (`lex("")` is EOF, not Invalid).
- `">>"` must be one `ShiftRight`, not two `Greater`.
- Old public method path `…NativeEngine.Lexer.<Method>` disappears; new path is `…Lexer.Contracts.<Method>`.

# Verification

Harness `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Lexer` after a matching editor `ue.build` when the binary would be stale. Do not gate on Quick, Performance, Integration, or PP/Sema/VM prefixes unless a tokenizer bugfix changes those callers.

# OpenSpec Handoff

- Change ID: `angelscript/test-lexer-isolated-coverage`
- Title: Isolate NativeEngine lexer tests and kind coverage
- Goal: Move reconstructed `asCTokenizer` tests out of `NewVersion`, add `LexerTest` helpers and spelled-kind coverage, and prove them with the `…NativeEngine.Lexer` prefix.
- Workflow: `angelscript`
- Affected areas: `angelscript/testing`
- Required artifacts: proposal, design, tasks. Specs: testing/baseline delta only if current text requires replacement tests to live under `NewVersion/`.
- Task boundaries: (1) `LexTestHelper.h` + `LexerTest` surface; (2) move 16 contracts to `NativeEngine/Lexer/` with nested TestDir and delete the old TU; (3) `SpelledKinds` matrix and maximal-munch pairs.

# Exploration Carryover

Confirmed by Q42 A, which authorized handoff and Change creation.

Talk candidates:

- `log.md` Round 26–27 Q38/Q39 + `findings/lexer-change-scope.md` → talk: helper in `TestFramework/`, tests in `NativeEngine/Lexer/`, leave `NewVersion`.
- `log.md` Q23/Q24/Q40 + `findings/test-prefix.md` → talk: TestDir `…Lexer` and classes `Contracts` / `SpelledKinds`, not `Lexer.Lexer`.
- `log.md` Q27 + `findings/lexer-kind-matrix-plan.md` → talk: walk `asGetTokenSpellingAnsi`, keep 16 contracts, add munch pairs.
- `log.md` Q34 hold + existing testing Change → talk: this Change does not implement TestCode / `FTestInputs`.

Knowledge candidates:

- `findings/lexing-overview.md` + `findings/lexer-design-names.md` + `findings/clang-lexer-tests.md` → knowledge: isolated lexer tests use `FLexerSource` + `CheckLex` + a spelled-kind walk; `FTestAST` is not for Lex.

Discard: Bindings namespace spelling; full TestFramework for other units; anonymous-namespace debate beyond this TU; SourceDiagnostics prefix.
