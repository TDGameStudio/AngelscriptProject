---
replan_id: replan-20260908-083136-wire-contract-oracle-ownership
status: applied
source: implementation
source_ref: 6.7-wire-consumer-preflight
scope: exact-wire-and-independent-contract-test-ownership
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 2267ea5dc8be2bde672e53f5cb52b63ddfa096905cb1110e38f72f7a3f208908
result_tasks_sha256: 5a495892c8ec92c267bd25f8adcb2c3006919299e6d221f14536ac99b475b932
created_at: 2026-09-08T08:31:36.629853+08:00
resume_task: 6.7
---

## Trigger and Evidence

Preflight found VMByteCodeImageTests.cpp:135 and VMWireFormatTests.cpp:71 assert the explicit previous wire revision; VMImageContractsTests.cpp:55 independently serializes the complete requirement contract. The accepted 6.7 wire change cannot preserve these consumer oracles without owning their exact paths.

## Decision

Add these three existing test translation units to 6.7 Files. Preserve independent contract construction and old-version rejection; migrate expected bytes/revision when implementation changes. No test is removed. Also own exactly the missing as_ast_cast.h include in frontend/as_frontend_sema_initializer.cpp: RED build beb8ef2306dd46288e73d823a85e5097 failed C3861 at lines 11/53/57/60, while adjacent sema units include that declaration explicitly. This is a preexisting Unity include dependency, not behavioral RED.

## Impact

Verification remains VMCallAdmission plus justified adjacent wire/image groups. No design, requirement, new task or edge changes.

## Old Task Disposition

All 45 checked nodes preserved. Pending 6.7 keeps its outcome and ID.

## Diff Snapshot

- Task ~: 6.7 Files adds three test paths and one exact compile-dependency repair; Task +/-: none; Edge +/-: none.
- Artifact ~: tasks.md and attachments/INDEX.md; new immutable replan.
- Base tasks already contain the prior three-node applied replan; recover its exact text from the earlier record's result hash and this narrowly described append.

## Preserved Work

The initial RED build is terminal Failed; no behavior ran. No implementation is changed by this planning operation. The previous applied record's result_tasks_sha256 represents the pre-write LF text; Python's Windows text output wrote CRLF. This record captures the actual base bytes and writes exact UTF-8 bytes so its resulting content digest is reproducible without newline translation. The previous record remains immutable.

## References and Result

Candidate preserves all 48 nodes, edge bytes and checkbox states. Strict validation follows before test migration. Existing 6.7 assignment and W01 remain authoritative.
