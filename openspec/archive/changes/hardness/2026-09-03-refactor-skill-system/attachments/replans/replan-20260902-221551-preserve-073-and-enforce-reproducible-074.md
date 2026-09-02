---
replan_id: replan-20260902-221551-preserve-073-and-enforce-reproducible-074
status: applied
source: verification
source_ref: "Independent cargo build --release --locked target directories for annotated v0.7.3"
scope: openspec-msvc-byte-reproducibility-and-release-identity
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: d6fd67e86dac556520c40139d4eab5748d35db6d7ede37aa788fd8b46859b8ac
result_tasks_sha256: e7047637324e591e53c28ce2c3a93311a1c89b208927e8ba862276b8944657c0
created_at: 2026-09-02T22:15:51.6407808+08:00
resume_task: "1.5"
---

# Replan — Preserve 0.7.3 and enforce reproducible 0.7.4

## Trigger and Evidence

Task 1.5 verification rebuilt annotated `v0.7.3` in an independent Cargo target directory. The packaged and rebuilt executables had the same `2,894,848` byte size and identical code/layout, but their SHA-256 values differed: packaged `3395c30f36d1c6f79300a4338481812ef71a49b3016b35edb215e29bd3830a30` versus isolated `9cfbafe25658fe91b032d859b6ba71ada00cbb0e7e9eb4040c3b7c96f6f6253d`.

Binary inspection found only 20 differing bytes: the PE and three debug-directory timestamps plus the 16-byte PDB GUID. Two fresh isolated builds with MSVC `/Brepro` were byte-identical at SHA-256 `d8bdf4a84134667aedf4db5718fed6b46353ba9c9ae5c9b7d2d5efa150e45cbe`. The containment behavior, 152 tests, and package contract remained correct; the failed boundary was reproducible release identity.

This verification triggers Replan because the delta spec requires a reproducible executable and the immutable `v0.7.3` tag cannot be changed to include deterministic linker configuration or a publisher gate.

## Decision

- Preserve source commit `9f35d443eaebc20c85ec65e30adf114af14d5308`, annotated `v0.7.3`, tag object `3c3a5847a3813283db200157e53cdc30731d5f08`, its package hash, and the failed reproducibility evidence without moving the tag.
- Keep Task `1.5` pending but advance its release target to 0.7.4.
- Add deterministic MSVC linker configuration to the tagged Rust source and make the publisher build in an isolated target directory and require a byte-identical EXE before replacement.
- Advance Task `1.3`, Task `3.1`, proposal, design, delta spec, and INDEX to the immutable 0.7.4 release truth.
- Preserve all Harness/UE work and the independent Ready Task `2.5`.

## Impact

The Task DAG keeps the same 14 nodes and dependencies; only the pending OpenSpec release/review/package descriptions advance from 0.7.3 to 0.7.4. Proposal, design, delta spec, and INDEX record why. The Rust submodule receives one new deterministic release commit and annotated tag; the parent package is republished only after its new isolated rebuild gate passes.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1, 1.2, 1.4, 2.1, 2.2, 2.3 | done | preserved unchanged | Historical completion and evidence remain valid |
| 1.5 | pending/Ready for 0.7.3 | modified, remains Ready for 0.7.4 | Functional repair passed; deterministic release identity did not |
| 1.3 | pending | review target advanced to 0.7.4 | Fixed-snapshot review must inspect the distributed immutable release |
| 3.1 | pending | package target advanced to 0.7.4 | The bundled EXE must match the deterministic release |
| 2.5, 2.4, 3.2, 4.1, 4.2 | pending | preserved unchanged | Their dependencies and acceptance boundaries remain valid |

## Diff Snapshot

```text
affected path/status: M Tools/openspec gitlink; M .agents/skills/openspec package; M OpenSpec records; 95 total worktree status entries at trigger
tasks: ~1.5 ~1.3 ~3.1; 14 nodes and six completed checkboxes preserved
edges: unchanged; Ready remains 1.5/2.5
artifacts: ~proposal ~design ~delta-spec ~tasks ~INDEX +replan
release evidence: v0.7.3 same-size isolated rebuild mismatch; /Brepro A/B byte-identical
```

## Preserved Work

All prior release tags, Replans, reviews, UID/alias identity, command docs, physical-containment fixes, publisher path-safety fixes, English gates, and Harness/UE changes remain intact. The existing packaged 0.7.3 file is only an intermediate failed candidate and will be transactionally replaced after the immutable 0.7.4 gates pass. No patch sidecar is needed.

## References and Result

- `attachments/replans/replan-20260902-213906-preserve-072-and-publish-073.md`
- `attachments/replans/replan-20260902-220447-repair-goal-and-unreal-review-boundaries.md`
- `attachments/reviews/review-20260902-openspec-072-rereview.md`
- Before and after the change, the DAG is 14/6/8 with Ready `1.5`/`2.5` and zero issues.
- The tasks hash advances from `d6fd67e86dac556520c40139d4eab5748d35db6d7ede37aa788fd8b46859b8ac` to `e7047637324e591e53c28ce2c3a93311a1c89b208927e8ba862276b8944657c0`; strict validation remains `1/1`.
- The change UID remains `change_96d0ba36-d839-423e-8a76-f49973b87e18`, and the old alias continues to resolve to the current record.
