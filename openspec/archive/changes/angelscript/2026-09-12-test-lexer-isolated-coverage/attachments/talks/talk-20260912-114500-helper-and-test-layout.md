# Helper in TestFramework, tests in NativeEngine/Lexer

## Context

The first lexer Change had to leave `NewVersion/` without putting test TUs inside `TestFramework/`, which is helpers only.

## Evidence

- Q3: `TestFramework/` holds shared helpers; area tests live beside the product area.
- User (Round 26): move lexer work out; put part in the new test framework and the new directory tree; migrate `NewVersion` gradually.
- Q39 A: test TUs at `AngelscriptTest/NativeEngine/Lexer/`.

## Options

| Option | Result |
| --- | --- |
| A. Leave TUs in `NewVersion` | Fastest, delays the agreed home |
| B. Helper in `TestFramework/`, tests in `NativeEngine/Lexer/` | Matches Q3 and the move-out request |
| C. Tests under `TestFramework/` | Conflicts with helper-only `TestFramework/` |

## Settled Decision

Option B.

## Consequences and Flip Condition

Later NativeEngine units copy this split. If `TestFramework/` is later redefined to own tests, revisit this talk before moving other units.

## Sources

- `attachments/drafts/findings/lexer-change-scope.md`
- `attachments/drafts/design.md`
- Draft `log.md` Rounds 26–27 (original wording stays in the draft)
