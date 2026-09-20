# Unpack: Contracts, SpelledKinds, FLexerSource, CheckLex, kind matrix

User 2026-09-12 asked what those design words mean. Not new product behavior.

---

## Two TEST_CLASS names (Q40)

After TestDir becomes `Angelscript.UnitTest.NativeEngine.Lexer`, the **class** is the next segment. Today the class is also `Lexer`, so nesting would register `…Lexer.Lexer.FrozenOptionsAreValueOwned`. So the old class is renamed.

**Contracts** = the 16 methods that already exist. They test the lexer *rules*: options do not come from the engine, tokens point at snapshot bytes, `UDELEGATE` is not a keyword, `0x1e+2` does not swallow `+`, bad bytes still advance, and so on. Stories, not a vocabulary list.

Public example after the move:

`Angelscript.UnitTest.NativeEngine.Lexer.Contracts.FrozenOptionsAreValueOwned`

**SpelledKinds** = new class. “Spelled” = the `.def` row has a fixed spelling (`class`, `+`, `>>`). One loop checks those 107 rows. Maximal-munch pairs (`>>` vs two `>`) live here too.

Public example:

`Angelscript.UnitTest.NativeEngine.Lexer.SpelledKinds.<MatrixMethod>`

`ue.test …NativeEngine.Lexer` runs both classes. `…Lexer.Contracts` runs only the old stories.

---

## FLexerSource (already in the file)

Today, anonymous-namespace helper: put text in a frozen snapshot so `asCTokenizer` has a range.

```
FLexerSource Source(TEXT("class Thing { }"));
// Snapshot + FileID + byte count; then CaptureTokenProjection / Lex
```

This Change only **moves** it to `namespace LexerTest`. Same job. Not `FTestAST` (that would parse).

---

## CheckLex (new, Clang-shaped)

Today contract tests call `CaptureTokenProjection` and then `ASSERT` kinds one by one (`Tokens[0] == KwClass`, …). That is verbose.

`CheckLex` is one helper: give source and the expected kind list.

```
CheckLex(TEXT("class"), { asETokenKind::KwClass, asETokenKind::EndOfFile });
```

The kind matrix calls this in a loop. Contract tests may keep `CaptureTokenProjection` when they care about flags, diagnostics, or projection strings.

---

## 种类矩阵 (Q27)

Not 107 `TEST_METHOD`s. One method walks `asETokenKind`, skips empty spellings (Identifier / number / string / … already in Contracts), and for each non-empty `asGetTokenSpellingAnsi`:

```
spelling "if"     → Lex → first non-trivia must be KwIf
spelling "++"     → Lex → PlusPlus
spelling ">>"     → Lex → one ShiftRight, length 2   // extra pair, not two Greater
```

If someone deletes `AS_TOKEN(KwIf, "if", …)` from the `.def`, `if` becomes Identifier and this method fails.

---

```text
LexerTests.cpp today
├─[anon] FLexerSource / CaptureTokenProjection
└─[class] Lexer ×16 methods

after this Change
├─ LexTestHelper.h / LexerTest
│  ├─ FLexerSource          // same snapshot wrapper
│  ├─ CheckLex              // source + Kind[]
│  └─ CaptureTokenProjection
├─ Contracts                // the same 16 stories
└─ SpelledKinds             // 107 spellings + >> / ** pairs
```
