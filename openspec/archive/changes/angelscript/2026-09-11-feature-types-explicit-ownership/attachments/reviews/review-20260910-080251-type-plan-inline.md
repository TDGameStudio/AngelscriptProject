---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
closed_at: 2026-09-10T08:08:23+00:00
assigned_at: 2026-09-10T08:02:51+00:00
reviewed_at: 2026-09-10T08:03:45+00:00
snapshot_ref: openspec/changes/angelscript/feature-types-external-ownership/attachments/reviews/snapshot-20260910-080251-before.json
snapshot_sha256: 32e0143793c9e6ce43bd8ea1da73d80985114c4e0068761905aed504243b652b
verdict: CHANGES_REQUIRED
---

# Current type ownership plan review

Assignment: user requested “再处理和review 下当前的方案/”. Inline review of the embedded immutable planning snapshot: SDK ownership, registration/withdrawal, query lifetime, Engine isolation/GC boundaries, Task DAG and binding prerequisite. Product implementation and unrelated dirty files are excluded. Snapshot parts and digests were reproduced; task test contracts were read before design/source context. Prior static validation is supplied evidence only, not product RED/GREEN.

## R1 — Registration unit and prerequisites disagree

severity: Required
status: resolved

File/line: SDK design.md:29-31; specs/angelscript/runtime/type-registry/spec.md:171; tasks.md:131-136 (all paths relative to feature-types-external-ownership in the snapshot).

Original observation: dependencies must already be registered in one paragraph, but Register claims the entire unclaimed closure in the next. Generation is per Image in design and per batch in the specification. Publication.AtomicFailure rejects an already-claimed Image while CreatorOwned accepts repeat host registration. Publication.Closure also requires a private Engine rejection before task 3.1 supplies its integration.

Impact: two plausible implementations assign different generations or reject different valid inputs; the proposed proving groups cannot decide which contract is correct and an early task can depend on a later interface.

Evidence/reproduction: freeze host Root -> Leaf with neither registered, then Register(Root); compare permitted outcome and generation cardinality under the two clauses. Repeat Register(Root) against the two task oracles. This is a verified plan contradiction, not an observed runtime failure.

Resolution condition: choose complete closure registration or registered-only dependencies, define generation and rollback unit and repeat behavior consistently, test partially registered and wholly new closures including overlap/failure, and place actual private integration rejection under 3.1.

## R2 — Last temporary graph release on query failure is not proved

severity: Required
status: resolved

File/line: SDK design.md:70 and section 5 synchronization; tasks.md:226; source as_typeinfo.cpp:118-145 and as_metadata_image.cpp:49-57 in the snapshot.

Original observation: lookup pins a weak Image under the directory mutex, but the plan does not specify destruction order for that temporary reference on failure or rollback. NoCycle tests final caller Release after successful acquisition. Existing TypeInfo::Release deliberately moves its final graph release outside metadataReferenceMutex; Image destruction deletes contained metadata. The proposed Image destructor additionally removes weak directory entries.

Impact: a failed generation/liveness check or rollback can drop the last temporary shared_ptr while the directory/owner locks are held, re-enter cleanup and deadlock. The high-level prohibition on locked destructors is valid but its dangerous error path is absent from the proving contract.

Evidence/reproduction: pause a typed acquisition after locking the weak Image, drop the final host reference, resume a forced rejected query and make destruction perform a Registry lookup. A lock-scoped local pin would destroy under the mutex. This schedule demonstrates a missing plan obligation; no product implementation or test run is claimed.

Resolution condition: every success, rejection, rollback and exception path releases graph/dependency/control temporary references after all relevant locks; add deterministic bounded coverage of last-owner loss on a failed query and transaction rollback. State the strong owner of retained ID/control records so old references remain readable without a cycle.

## R3 — Output ownership matrix contradicts the chosen API

severity: Required
status: resolved

File/line: SDK design.md:70; attachments/data/query-contract.md:35,45; tasks.md:181,223.

Original observation: design requires null input Out and returns existing mutable-interface pointers with AddRef; the matrix promises a const Pair lease and clearing outputs on any failure. Behavior for non-null Out is undefined, and clearing an already-owned pointer would lose the caller's reference.

Impact: implementations and tests can silently overwrite or leak a reference, or introduce the custom/const lease surface explicitly removed by the ownership decision.

Evidence/reproduction: pass an existing acquired pointer as Out to a malformed or wrong-generation call; matrix clearing and caller ownership disagree. Compare the promised const lease to asITypeInfo*& in design.

Resolution condition: define non-null-output rejection without mutation or refcount change, align statuses and all retained result wording with AddRef/Release, and add type/function success, null-failure and non-null-rejection reference-balance cases.

## Verification and verdict

CHANGES_REQUIRED for these three planning-contract findings. The main host/Engine ownership split, registry non-ownership, explicit Engine admission and per-instance GC separation remain viable. No independent claim of runtime correctness, deadlock freedom, compilation or GC pass follows from this review. No additional architecture owner or public lease class is needed to resolve the findings.

## Coordinator disposition and re-review

Resolved at 2026-09-10T08:08:23+00:00. Original observations, impacts, evidence and resolution conditions above are retained. Coordinator verified R1-R3 against the original materialized snapshot and applied openspec/changes/angelscript/feature-types-external-ownership/attachments/replans/replan-20260910-080251-type-plan-review.md. R1 maps to Closure/AtomicFailure/CreatorOwned/OverlappingClosure/HostPrivateDependency; R2 to RejectedAcquireRelease/RollbackRelease and explicit unlocked owner release; R3 to ReferenceBalance/Invalid and unchanged non-null outputs.

The deliverable content changed, so this CHANGES_REQUIRED report is superseded rather than rewritten as APPROVE. Final re-review openspec/changes/angelscript/feature-types-external-ownership/attachments/reviews/review-20260910-080251-type-plan-rereview-inline.md reproduces snapshot openspec/changes/angelscript/feature-types-external-ownership/attachments/reviews/snapshot-20260910-080251-after.json (997a89fbe1a129954dde7beaca7c447a052cc7d5fdd65f7f22d1930811f16920) and resolves all three plan findings. Static validation is recorded in openspec/changes/angelscript/feature-types-external-ownership/attachments/data/replan-20260910-080251-type-plan-review-validation.md. Product acceptance tests remain pending.
