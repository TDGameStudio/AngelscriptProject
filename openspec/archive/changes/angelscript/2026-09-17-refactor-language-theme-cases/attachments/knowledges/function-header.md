# Function header contract

Disposition: candidate

## Reusable Insight

A Language callable that C++ may later Prepare is marked with a function-header block: `@function`, `@summary`, `@inputs`, `@return`, optional `@covers`. The live declaration is dumped after compile. Compile-fail cases have no mark.

## Evidence

Pending function comments already carried Inputs/Return. Q14 named `@function`. Q17 reused `@summary`. R20 accepted the function-header placement.

## Boundaries

Not `UFUNCTION(meta=(AngelscriptTest))`. Not bind-surface `// AS-facing API`. Not a one-token `@point` mark. Kind tables stay out of this Language cut.

## Application

Put the block immediately before the script function. File and case headers still have their own `@summary`. One-function cases may repeat the same sentence.

## Sources

[function-comment-fields.md](../drafts/findings/function-comment-fields.md). Approval R20.
