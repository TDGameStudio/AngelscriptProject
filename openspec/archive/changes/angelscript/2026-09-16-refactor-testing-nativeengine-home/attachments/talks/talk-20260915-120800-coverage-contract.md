# Coverage means layer completeness plus a language matrix to the VM

## Context

The user required comprehensive coverage in the same program as the move. Completeness without a finish line is not implementable.

## Evidence

[Coverage gaps](../drafts/findings/coverage-gaps.md): no Parser tree; LanguageSurface is not an operator matrix; source-to-VM is thinner than VM. TestCode `.as` counts are not execution evidence.

## Options

| Option | Result |
|---|---|
| A. Layer completeness only | Finishable, but leaves the named language holes |
| B. Layer completeness plus the language core matrix through VM | Matches "comprehensive" with a table contract |
| C. Legacy Frontend corpus parity | Ties reconstruction to old corpus shape |

## Settled Decision

Option B. The axis table in the accepted design is the contract. Bindings expansion, JIT, Legacy mapping, and TestCode file counts are not acceptance.

## Consequences and Flip Condition

Phase 2 is grouped RED/GREEN along that table. Axes outside the table require a design update first. If foreach becomes a supported product, reopen the retired-syntax axis; do not change the product inside a task.

## Visual

```text
source -> lex -> parse -> sema -> SourceExecution -> VM result or typed rejection
```

## Sources

Exploration Round 2 Q3 and Round 4 Q10. [Coverage gaps](../drafts/findings/coverage-gaps.md).
