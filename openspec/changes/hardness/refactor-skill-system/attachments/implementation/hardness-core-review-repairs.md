---
record_id: hardness-core-review-repairs
status: resolved
source: review
source_ref: attachments/reviews/review-20260903-012643-hardness-core-fixed-snapshot.md
created_at: 2026-09-03T01:29:26.4121259+08:00
resolving_task: "2.4"
---

# Hardness Core Review Repairs

## Triage

The four Required findings are reproducible implementation and record-state defects inside the existing Task `2.4` Review Gate. They do not change a requirement, design boundary, task ownership boundary, dependency edge, or required artifact, so they do not trigger Replan.

## Repair scope

- Bind Goal contexts and routed leaf execution to the canonical registered workspace boundary.
- Verify the packaged OpenSpec identity rather than treating EXE existence as installation health.
- Reconcile historical review states and extracted UE finding dispositions with the closure protocol.
- Bound and safely drain fresh-process performance samples.

The repair remains limited to Hardness, Workspace/OpenSpec package verification reuse, performance tests, and change records. It does not restore UE routes, apply the UE stash, or require UE validation.

## Resolution evidence

- `Hardness.Tests.ps1` and `Test-Hardness.Tests.ps1` pass in Windows PowerShell 5.1 and PowerShell 7.
- `Protocol.Tests.ps1` passes in both hosts after scanning every current review and its Critical/Required finding state.
- The exact Quick gate passes `10/10` across both hosts.
- The formal Performance gate passes `2/2` with `WarmupRuns=3`, `MeasurementRuns=15`, and unique run `gate-20260902T174450411Z-f11306fb-{PS5,PS7}`.
- `attachments/data/hardness-performance-baseline-20260903-014536.json` is source-bound, privacy-trimmed, and matches the retained raw Summary/Samples hashes.
- No UE leaf, wrapper, build, Editor, Automation, All, or StaticJIT validation was loaded or executed.

Independent approval is closed by `attachments/reviews/review-20260903-014644-hardness-core-rereview.md` at SHA-256 `9c3e09bbd9c3ee4005cc600877ab23bc5c30fa1a433f39f4e060778c7cff0782` with no new finding.
