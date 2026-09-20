# Choose reload width and replacement model

## Context

Initial join is archived. Hot reload still dies in Stage1. The live module name and the single Initial definition set block a second Register.

## Evidence

[reload-join.md](../drafts/findings/reload-join.md). Draft log R8. AskQuestion W1=S, R1=P.

## Options

- W1 F: skip the dead block only for `FullReload`.
- W1 S: skip it for `FullReload` and `SoftReloadOnly`; keep existing PIE Soft downgrade.
- R1 P: one definition set per file; retire those sets on reload.
- R1 K: replace-by-StableKey inside the live set.

## Settled Decision

W1=S. R1=P. Implementation: one Builder+Register per preprocessor `ModuleDesc`, Dependencies = host graph + already attached script sets.

## Consequences

Initial ownership must split before reload can retire a file. ClassGen Soft/Full algorithms stay.

## Flip Condition

Re-open W1 if in-PIE Soft must stay on the dead Stage path. Re-open R1 if Initial cannot become per-file sets.

## Sources

[design](../drafts/design.md), [reload-join](../drafts/findings/reload-join.md). Provenance: draft log R8.
