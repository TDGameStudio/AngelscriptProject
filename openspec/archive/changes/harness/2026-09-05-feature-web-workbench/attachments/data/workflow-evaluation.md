---
record: harness-workflow-evaluation-v1
result: passed
change: harness/feature-web-workbench
closure_kind: completed
input_sha256: 29b2ee90bc6406cc8abe662c67ea42cbe310576d6d2ba89bc63479fa7fff81ee
captured_at: 2026-09-05T03:20:10.0172868+00:00
---

# Workflow evaluation

The accepted local workbench and subsequent user-directed layout refinement were implemented in the selected workspace, verified through the owning package and synchronized to the current harness/web capability. The valid TaskPlan has nine complete tasks and no remaining nodes. The diagnosed Windows archive compatibility issue is resolved. All required application acceptance passed; the unrelated repository-wide language-scan failure and intentionally omitted Unreal gates are recorded in verification.md.

The Change was created at 2026-09-05T02:01:52Z. The original combined acceptance log spans 02:50:28Z through 02:51:18Z, approximately 50 seconds for typecheck, 55 unit tests, production build and nine browser workflows. The subsequent refinement batch passed typecheck, 59 unit tests and build; eleven browser workflows passed in 27.1 seconds against that build after a test-only responsive-transition wait correction. Earlier planning, library setup and parallel implementation stages were not individually instrumented; no synthetic stage timings are asserted.

The user explicitly changed execution cadence during integration: related code and tests were completed in coherent batches, followed by consolidated acceptance. Existing focused RED/GREEN observations were retained. Subsequent focused runs addressed demonstrated failures only: browser storage setup under Node 25, delayed-workspace panel restoration, source highlights across rerenders and excluded-directory watcher traversal. User feedback then replaced the selected-record layout through an applied replan. A separate indexed issue and applied replan preserve the evidence that Windows native watch handles blocked archival; polling now passes actual CLI archive and post-move refresh tests. Final acceptance includes these corrections, live editor/concurrent-save behavior and the new layout.

Backend, editor and workbench owners used disjoint source paths; root integrated shared contracts, package dependencies, browser fixtures and closure. No implementation owner was superseded or transferred into a separate Change. External libraries provide established editing, graph, chart, search, layout and transport behavior; project-specific code owns native TaskPlan semantics, safe file scope and protected document boundaries.

The current capability and package README carry durable behavior and operational guidance. The two MIT research checkouts remain pinned references without copied source or runtime dependency. Source hashes are retained in source-identity.json; raw final output, browser screenshots and startup observations live under ignored Tools/harness-web artifact directories. Verification uses independent temporary Git fixtures and contains no dependency on this Change remaining active.
