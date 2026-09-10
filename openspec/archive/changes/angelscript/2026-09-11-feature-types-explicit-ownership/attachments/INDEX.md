# INDEX

## Current position

DAG 12/12 complete. Specs synchronized. Closing as completed.

## Hard conclusions

- Durable pre-Engine class information lives in BindInfoStore, not in Image.
- `asCMetadataImage` is `TUniquePtr`. Each Engine uniquely owns TypeInfo. A and B share publication IDs, never TypeInfo pointers.
- Registry issues process IDs only. No `std::shared_ptr` for Image or TypeInfo.
- Private AS TypeInfo belongs only to the receiving Engine.

## Forbidden

- No Image-owned long-lived TypeInfo graph and no `std::shared_ptr` Image registration.
- No sharing TypeInfo pointers across Engines.
- No BoundEngine as execution authority.
- No global query as implicit Engine admission.

## Attachment index

- `talks/talk-20260910-182000-image-intermediate-no-shared-ptr.md` — user overturn of Image-as-owner.
- `talks/talk-20260910-064731-ue-component-id-assessment.md` — ID allocation; Image-owner conclusion superseded.
- `talks/talk-20260910-075318-type-ownership-and-gc.md` — host vs Engine ownership and GC.
- `replans/replan-20260910-182000-image-intermediate-no-shared-ptr.md` — DAG 7.x, superseded 2.1-6.2.
- `replans/replan-20260910-064731-process-type-id-registry.md` — allocator retained; Register(Image) superseded.
- `replans/replan-20260910-075318-creator-owned-type-metadata.md` — host vs Engine ownership retained.
- `replans/replan-20260910-080251-type-plan-review.md` — plan-review correction.
- `replans/replan-20260910-083124-vm-performance-preservation.md` — execution-vs-prepare gate.
- `data/verification-baseline.md` — 1.1 old Image-owned contract, 5/5.
- `data/verification-final.md` — 7.9 unique-TypeInfo Baseline 5/5.
- `data/sdk-handoff.json` — external-types-handoff-v1.
- `data/baseline-expectations.json` — literal oracles and proving run.
- `data/consumer-migration.csv` — GetBoundEngine/GetEngine sites.
- `data/query-contract.md` — publication-ID / distinct TypeInfo matrix.
- `data/source-evidence.md` — inspected Image/shared_ptr source.
- `data/validation-baseline.json` — named formatting repairs.
- `data/planning-validation.md` — creation-session validation.
- `data/rename-20260910-081751-explicit-ownership.md` — old-ID alias.
- `data/replan-20260910-064731-process-type-id-registry-validation.md` — registry replan validation.
- `data/replan-20260910-075318-creator-owned-type-metadata-validation.md` — creator-owned replan validation.
- `data/replan-20260910-080251-type-plan-review-validation.md` — plan-review validation.
- `scripts/Test-SdkHandoff.ps1` — UID and source-hash gate.
- `reviews/review-20260910-080251-type-plan-inline.md` — superseded plan review.
- `reviews/review-20260910-080251-type-plan-rereview-inline.md` — superseded re-review.
- `reviews/review-20260910-141459-process-typeids.md` — superseded; Required findings resolved by 2.3/7.x.
- `reviews/snapshot-20260910-080251-before.json` — before-plan snapshot parent.
- `reviews/snapshot-20260910-080251-before-part1.json` — before snapshot part 1.
- `reviews/snapshot-20260910-080251-before-part2.json` — before snapshot part 2.
- `reviews/snapshot-20260910-080251-before-part3.json` — before snapshot part 3.
- `reviews/snapshot-20260910-080251-before-part4.json` — before snapshot part 4.
- `reviews/snapshot-20260910-080251-before-part5.json` — before snapshot part 5.
- `reviews/snapshot-20260910-080251-after.json` — after-plan snapshot parent.
- `reviews/snapshot-20260910-080251-after-part1.json` — after snapshot part 1.
- `reviews/snapshot-20260910-080251-after-part2.json` — after snapshot part 2.
- `reviews/snapshot-20260910-080251-after-part3.json` — after snapshot part 3.
- `reviews/snapshot-20260910-080251-after-part4.json` — after snapshot part 4.
- `reviews/snapshot-20260910-080251-after-part5.json` — after snapshot part 5.
- `reviews/snapshot-20260910-080251-after-part6.json` — after snapshot part 6.
- `reviews/snapshot-20260910-141459-process-typeids.md` — process-TypeId review snapshot.
- `implementation/issue-20260910-081511-review-replan-tooling-gap.md` — rejected; Harness snapshot tooling out of SDK scope.
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1.
