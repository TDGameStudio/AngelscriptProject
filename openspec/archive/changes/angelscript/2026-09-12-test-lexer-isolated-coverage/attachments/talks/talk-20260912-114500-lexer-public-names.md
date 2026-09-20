# Nested Lexer TestDir and scenario classes

## Context

CQTest registers `TestDir.Class.Method`. Today TestDir is flat `Angelscript.UnitTest.NativeEngine` and the class is `Lexer`, so the filter `…NativeEngine.Lexer.*` already works. Nesting TestDir to `…NativeEngine.Lexer` while keeping class `Lexer` would publish `…Lexer.Lexer.*`.

## Evidence

- Q23 A: nest NativeEngine TestDir as `Angelscript.UnitTest.NativeEngine.<Unit>`.
- Q24 A: public unit token is `Lexer`, not `Lex`.
- Q40 A: classes `Contracts` (16 existing methods) and `SpelledKinds` (matrix).

## Options

| Option | Result |
| --- | --- |
| A. `Contracts` + `SpelledKinds` | Separable filters; no `Lexer.Lexer` |
| B. One class `Contracts` | One prefix, matrix mixed with stories |
| C. Keep class `Lexer` after nesting | Redundant `…Lexer.Lexer.*` |

## Settled Decision

Option A. Public paths are `…Lexer.Contracts.*` and `…Lexer.SpelledKinds.*`. The old `…NativeEngine.Lexer.<Method>` path goes away.

## Consequences and Flip Condition

Automation that pinned a method under the flat class must retarget. If later units keep a single class, that is a per-unit choice; Lexer already has a vocabulary suite that should not live in the contract class.

## Sources

- `attachments/drafts/findings/test-prefix.md`
- `attachments/drafts/findings/lexer-design-names.md`
- `attachments/drafts/design.md`
- Draft `log.md` Q23, Q24, Q40
