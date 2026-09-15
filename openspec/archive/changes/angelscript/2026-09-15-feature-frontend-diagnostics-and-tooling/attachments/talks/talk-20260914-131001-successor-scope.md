# One successor for diagnostics, parallel Lex/PP and native tooling

## Context

The predecessor has fourteen unimplemented product outcomes, while the draft adds a missing production convention and a concurrent lexical/preprocessor execution model.

## Evidence

Topic angelscript/diagnostic-engine Q6 chose supersession, N3 named this Change, Q9 accepted diagnostics, Q12 combined scopes, Q13–Q17 settled concurrency, and Q10/Q18 confirmed carryover. See [replacement finding](../drafts/findings/succeed-tooling-change.md).

## Options

Keep two overlapping Changes, rewrite the predecessor in place, or create one explicit successor and close the predecessor as superseded. The user selected the last route. A separate producer-framework Change is not created.

## Settled Decision

Create angelscript/feature-frontend-diagnostics-and-tooling. Preserve all predecessor diagnostic/tooling acceptance boundaries, add Diag production and queued same-thread Lex/PP, and archive the predecessor only after the new complete plan is validated. Every old unchecked task receives an explicit transfer disposition and remains unchecked.

## Consequences and Flip Condition

Only this successor schedules future work. No server, extension migration or parallel declaration collection is introduced. Creation is planning-only. A requirement to split independently owned future products would require an explicit update; it does not follow from task count or attachment size.

## Visual

```text
Accepted predecessor contracts        // Fourteen pending product boundaries
└─ Combined successor                 // Adds production and parallel Lex/PP
   └─ Predecessor superseded          // Transfer each pending task, no false completion
```

## Sources

[Handoff](../drafts/handoff.md), [design](../drafts/design.md), and [carryover](../drafts/findings/carryover-candidates.md). Historical predecessor identity is provenance; this plan is the active authority.
