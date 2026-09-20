# This Change does not implement TestCode

## Context

`angelscript/refactor-testing-unified-framework` already owns `FAngelscriptTestCode`, `AS_TEST_SOURCE`, and data-driven rows. Q34 held the home of `FTestInputs` for a later unified source framework.

## Evidence

- That Change is planning-only and must not be reopened in design mode.
- Lexer helpers today already call `FSourceInput::FromText`.
- User deferred source-input design.

## Options

| Option | Result |
| --- | --- |
| A. Keep `FSourceInput` in this Change | Lexer ships without TestCode |
| B. Implement `AS_TEST_SOURCE` here | Crosses the other Change's boundary |
| C. Block lexer tests until TestCode lands | User asked for an easy first slice |

## Settled Decision

Option A. Snapshots stay on `AngelscriptNativeEngineTest::FSourceInput::FromText` until Q34.

## Consequences and Flip Condition

If the source framework lands first and `FSourceInput` is deleted, this helper must retarget in a follow-on task, not by expanding this Change into TestCode.

## Sources

- `attachments/drafts/handoff.md`
- `openspec/changes/angelscript/refactor-testing-unified-framework/proposal.md`
- Draft `log.md` Q34
