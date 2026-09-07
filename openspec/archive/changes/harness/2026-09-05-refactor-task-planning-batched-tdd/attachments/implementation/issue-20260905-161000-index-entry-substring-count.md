---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-161000-index-entry-substring-count
status: resolved
resolved_at: 2026-09-05T16:43:34.0665824+08:00
resolution_ref: attachments/data/verification.md
source: verification
source_ref: baseline Protocol.Tests.ps1 before guidance implementation
affected_tasks: ["1.1"]
created_at: 2026-09-05T16:10:00+08:00
---

## Symptom

The owner Protocol test fails on an unchanged closure-v1 archive, reporting two index entries for knowledges/clang-source-provenance.md.

## Investigation Log

- Baseline invocation exits 1 before any protocol implementation change.
- The historical INDEX has one actual attachment entry; its summary links the promoted durable knowledge path ending in the same relative suffix.
- Test-AttachmentIndexCompatibility counts regex substring occurrences throughout INDEX rather than exact listed attachment entries. The implementation-issue index check repeats that algorithm.

## Root Cause

Unbounded substring counting confuses an actual index entry with explanatory text, a promoted path or a sibling filename. It can falsely reject a valid index and accept a missing entry mentioned only in prose.

## Disposition

Add executable positive and negative fixtures and repair only the internal Protocol test helper to count exact supported entry paths. Keep missing/duplicate rejection; do not edit historical archives or public Harness/CLI behavior.

## Evidence

### Failure Evidence (RED)

- Command: `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`
- Artifact: unchanged archive `openspec/archive/changes/angelscript/2026-09-05-refactor-frontend-source-diagnostics-model/attachments/INDEX.md`.
- Result: exit 1, expected zero compatibility issues; actual one issue reporting the knowledge entry count as 2.

### Resolution Evidence (GREEN)

- Command: `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`.
- Artifact: `attachments/data/verification.md`; script SHA-256 82FBBF29AB92B0D1DC6BAB61DFFA717987B02A2E00C024748176D07CB633CC0C.
- Result: PASS after exact-entry fixture RED/GREEN for compatibility and active issue indexing. Real missing/duplicate entries still fail; historical records are unchanged.

### What This Proves

The directly selected Protocol gate has a demonstrated exact-entry classification bug.

### What This Does Not Prove

The archive is not corrupt, and this diagnosis does not establish a UE or portable OpenSpec executor defect.

## Links

- `../../tasks.md`, task 1.1.
- `.agents/skills/harness/tests/Protocol.Tests.ps1`.
