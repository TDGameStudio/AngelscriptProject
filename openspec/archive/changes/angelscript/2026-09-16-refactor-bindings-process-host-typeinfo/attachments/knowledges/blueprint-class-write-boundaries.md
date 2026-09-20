# Safe boundaries for parallel Blueprint definition writes

## Reusable Insight

Separate reflection snapshot/prewarming from class-local mutation. Parallel work is independent only after all referenced shells and base relations are available.

## Evidence

[Blueprint inheritance](../drafts/findings/blueprint-parallel.md) and [worker selection](../drafts/findings/blueprint-worker-pool.md) describe own-member lookup, lazy UE state and uneven class sizes.

## Boundaries

Disposition: promoted. 5.1 HostBlueprintWrites proves WriteWorkers 0→1, overlap latch and inherited X/Y counted once. Blueprint ExcludeSuper is not an automatic change to UStruct. Serial global registration and thread-affine operations remain distinct.

## Application

Assign one mutable class table per work item, claim items dynamically, join dependency waves and compare deterministic results for worker counts 0/1/2/4. Measure performance separately from proving correctness and overlap.

## Sources

Confirmed carryover Q68 and source rounds Q51-Q58; the accepted design and later task evidence determine final applicability.
