# Topic is not an enum

Disposition: candidate

## Reusable Insight

`@topic` is an open nonempty string. Unknown words are filters, not format errors. Polarity of compile versus runtime is a file split, not an official topic table.

## Evidence

Parser and Builder only reject empty topics. The user corrected the closed-enum attempt (Q10 withdrawn).

## Boundaries

Does not add execution meaning to a topic. `Negative` remains a conventional label, not a verdict.

## Application

Authors may add new topic words without a schema change. Do not invent a registry of allowed topics in this Change.

## Sources

[topics-open.md](../drafts/findings/topics-open.md). Approval R20.
