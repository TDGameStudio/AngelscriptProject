---
replan_id: replan-20260905-025410-unique-tokenizer-implementation
status: applied
source: implementation
source_ref: openspec/archive/changes/angelscript/2026-09-05-refactor-frontend-source-diagnostics-model/attachments/implementation/issue-20260905-023432-ubt-duplicate-source-basename.md
scope: UBT tokenizer implementation-unit basename identity
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 076460fe8e6b788e2bf026b3fb01f2e379637bc609ab14c75d643db1421f6a30
result_tasks_sha256: f850bc543d020349d1062f5414d0e3d384365d5008398cb4e47846902f5e37b9
created_at: 2026-09-05T02:54:10+08:00
resume_task: 1.1
---

# Replan: give the isolated tokenizer implementation a unique basename

## Trigger and Evidence

The completed source-diagnostics Change proved with real UBT run `8d50869f797a421ebf421d793298f080` that distinct directories do not disambiguate equal `.cpp` basenames within one UE module. This Change preserves production `source/as_tokenizer.cpp`, so the planned `source/frontend/as_tokenizer.cpp` would repeat the established failure before C++ compilation.

## Decision

Use `source/frontend/as_frontend_tokenizer.cpp` for the new implementation unit. Keep the final class name `frontend::asCTokenizer`, header `frontend/as_tokenizer.h`, public-internal behavior, and production-isolation boundary unchanged.

## Impact

Tasks `1.2` and `2.1` now name the unique implementation file. No requirement, dependency edge, verification command, token contract, or runtime route changes.

## Old Task Disposition

No Lexer task had started. Task `1.1` remains the ready entry and all downstream tasks remain incomplete.

## Diff Snapshot

- Task changes: two `.cpp` paths and one Replan context block.
- Edge changes: none.
- Design changes: one explicit UBT build-artifact identity note.
- Product changes: none at Replan capture.

## Preserved Work

All proposal, lexical requirements, streaming ownership, test prefix, task sequencing, and Clang research remain valid.

## References and Result

- Evidence owner: `openspec/archive/changes/angelscript/2026-09-05-refactor-frontend-source-diagnostics-model/attachments/implementation/issue-20260905-023432-ubt-duplicate-source-basename.md`.
- Result: begin Task `1.1`; later tokenizer implementation uses the unique basename.

