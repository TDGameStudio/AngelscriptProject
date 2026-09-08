---
replan_id: replan-20260908-091029-lifetime-fixture-ownership
status: applied
source: implementation
source_ref: 6.8-existing-fixture-preflight
scope: exact-wire-and-shutdown-lifetime-fixtures
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 835b190a0b0c0042291554ea50b4a222e4633c3d95385fec6d9561d71fde6e7e
result_tasks_sha256: fdb9c483259f1f19d8ddc70f272093a0976f214ec36171c43de5f7a858d5209d
created_at: 2026-09-08T09:10:29.560919+08:00
resume_task: 6.8
---

## Trigger and Evidence

VMWireFormat.CanonicalOrderRoundtripPreservesContractsFrameAndCleanup puts a Both cleanup at RET without allocation. VMShutdownDrain.ShutdownAbortsSuspendedAndReleasesRoot has real ALLOC/FREE but its Both record defaults to PSF index zero. These producers violate the verified transition contract and their paths were omitted from 6.8 Files.

## Decision and Impact

Add exactly these two test paths to 6.8. Migrate records to actual ALLOC initialization and FREE destruction. Preserve canonical byte equality, witness corruption, source/result metadata and exact shutdown destructor count. No requirement, public scenario, runtime boundary, task ID or edge changes.

## Old Task Disposition

All 46 completed and two pending tasks preserved. 6.8 remains Ready; 11.4 awaits it.

## Diff Snapshot

Task ~: 6.8 Files adds two paths. Task +/- and Edge +/-: none. Artifacts ~: tasks.md, INDEX and this applied record.

## Preserved Work

Focused lifetime build 7bbf5d6531c5438ea3f8cdaa76ec3e8b and run aa5ad449c1dc4eee881506deb5137861 passed all twelve new cases without warnings. No historical success is replaced.

## References and Result

Candidate changes only ownership; checkbox counts and DAG remain intact. Strict validation follows before fixture edits. Resume 6.8 adjacent producer verification.
