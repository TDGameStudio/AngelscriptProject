# Scheme and perf gates are S1-S6 and P1-P4

## Context

The user asked to lock scheme and performance verification after bind, and to stop writing packed Host tests. Predecessor 6.1 omitted Quick/Performance/Insights by design.

## Evidence

[Verification after host](../drafts/findings/verification-after-host.md) lists the missing compile/call/timing proofs. [Gates](../drafts/findings/verification-gates.md) are Q78=A. [Style](../drafts/findings/host-test-style.md) requires one method per scene.

## Options

Reuse unadapted Legacy Performance as the gate; require "faster than DirectBinds"; or lock comparable invariants plus recorded numbers with no speed threshold. The user chose the last option.

## Settled Decision

S1-S6 are hard scheme gates. P1-P4 are hard invariants plus required `attachments/data/` records. There is no "must be faster" bar. Not gates: old 310 as-is, unadapted Legacy Performance, WriteWorkers speedup, Insights traces, unconditional Quick/Integration.

## Consequences and Flip Condition

A perf node cannot complete without the numeric attachment. Relaxing a gate or adding a speed ratio requires an explicit replan. Family migration stays a separate checkbox from S/P.

## Visual

```text
S1 inject-only  S2 compile  S3 call
S4 shared ids   S5 freeze   S6 no half graph
P1 capture time P2 no rerun P3 survive P4 samples
```

## Sources

Local provenance: bindings-gap-audit Q78 and the 2026-09-16 style request. Canonical truth is the Change tasks and verification-gates finding.
