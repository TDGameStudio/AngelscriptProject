# Class-level Blueprint writes with explicit barriers

## Context

Parallel preparation already exists, but registration commit is serial. Direct host construction makes real write concurrency possible only with explicit ownership.

## Evidence

[Worker findings](../drafts/findings/blueprint-worker-pool.md), [inheritance findings](../drafts/findings/blueprint-parallel.md) and [phase ordering](../drafts/findings/keep-bind-phases.md) establish separate class tables, lazy reflection state and inherited lookup.

## Options

Serialize the complete graph behind a lock; parallelize preparation only; or fan out independent class writes with short index synchronization. Q51 selected real fan-out.

## Settled Decision

Prepare/prewarm on GameThread; use fixed workers, one UClass per atomic-index claim, shell/base/member barriers, own properties only, and serial globals. WriteWorkers defaults to 1 and 0 means 1. Prepare has its existing independent switch.

## Consequences and Flip Condition

A worker owns one class table but not the shared index or UE lazy state. Equivalent serial/parallel behavior and actual overlap must be proved. Evidence of an unavoidable UE-thread dependency moves that operation to the serial boundary without replacing the agreed class fan-out with an entire-callback lock; larger scope changes require replan.

## Visual

Snapshot/prewarm -> shell workers -> join/base relationships -> member workers -> join/seal.

## Sources

Local-source provenance: bindings-gap-audit Q51-Q58; confirmed carryover Q68. See the [accepted design](../drafts/design.md).
