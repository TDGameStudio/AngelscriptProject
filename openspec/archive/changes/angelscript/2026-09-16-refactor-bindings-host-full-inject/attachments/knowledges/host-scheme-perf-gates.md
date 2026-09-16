# Host scheme and perf completion gates

## Reusable Insight

After a shared host freeze, correctness is inject-only plus compiled script calls plus shared identity. Performance is recorded once-capture / no-rerun / survive-destroy / call samples, not a required speedup.

## Evidence

[verification-gates.md](../drafts/findings/verification-gates.md) S1-S6 / P1-P4. [verification-after-host.md](../drafts/findings/verification-after-host.md) explains why Legacy Performance and old observability numbers are the wrong oracle.

## Boundaries

Disposition: candidate. Family migration is not these gates. Insights, WriteWorkers speedup, and unconditional Quick/Integration stay excluded unless a later Change approves them.

## Application

New binding Changes should keep one method per gate, write P* numbers into `attachments/data/`, and refuse empty-diagnostic freeze failures.

## Sources

Confirmed carryover Q78. Canonical truth is the Change tasks.
