# One Change; Task DAG relocates then covers

## Context

Layout and coverage are independently describable, but the user chose one delivery after the designs were written as siblings.

## Evidence

Layout verification is build plus identity smoke. Coverage verification is per-axis RED/GREEN after `Parser/` and `SourceExecution/` exist. Combining them in one Change keeps a single ID; the DAG must still sequence the phases.

## Options

| Option | Result |
|---|---|
| A. Two Changes | Cleaner archives; user rejected this packaging |
| B. One Change, relocate then cover | One ID; long task list |
| C. Direct edits without a Change | User selected OpenSpec |

## Settled Decision

Option B. Change ID `angelscript/refactor-testing-nativeengine-home`. Phase 1 tasks are prerequisites of phase 2.

## Consequences and Flip Condition

Ensure plan writes one Task DAG with that edge. Do not start Parser matrix tasks before the homes exist. Reopen packaging only if the DAG cannot express the dependency without splitting the Change.

## Visual

```text
phase 1 relocate + nest names
 └─[depends] phase 2 Parser then language matrix groups
```

## Sources

Exploration Round 4 Q8 and Round 8 Q15.
