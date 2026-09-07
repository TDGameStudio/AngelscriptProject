---
replan_id: replan-20260905-162548-guidance-content-scope
status: applied
source: verification
source_ref: issue-20260905-161909-guidance-language-scope
scope: extend explicit owner-test input selection to repository content audits
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 51468076dc7884ec73fc84870741b16737c95b774c8edacadb47f826478c32b4
result_tasks_sha256: 8772540dc483fc5b71cd8eb4a2126fbbb75af5ef71181535bf1c9c32385ace38
created_at: 2026-09-05T16:25:48.6917068+08:00
resume_task: "2.1"
---

## Trigger and Evidence

The LanguagePaths fixture and selected English check passed, then the unchanged repository-wide knowledge audit rejected eight unrelated pre-existing backtick-only indexes. Narrowing only language left the same proving-scope coupling at the next content audit.

## Decision

Use explicit SurfacePaths for actual repository English, knowledge-index and active-attachment-index inputs. All package, authoring/link assertions and hermetic fixtures remain active. Selecting a child includes its complete owning index; invalid selections fail. Default remains a full scan and its existing failures remain reported. Do not modify unrelated records or archives.

## Impact

The unshipped test-only LanguagePaths argument is replaced by SurfacePaths. Public Harness and portable CLI APIs remain unchanged. Exact task 2.1 command and its stable path list are updated; no subject-active path is required for reusable proof.

## Old Task Disposition

All three nodes and dependency edges are preserved; completed 1.1 remains checked. Candidate graph is unchanged from the validated TaskPlan; only the proving input/command changes.

## Diff Snapshot

- ~2.1 verify and command context; no node/edge additions or removals.
- ~design.md, ~INDEX, ~the existing scope issue; +this record.
- Same owned parent prompt/test edits; plugin and unrelated dirty baseline preserved.

## Preserved Work

Previous applied language-scope record remains immutable, documenting its actual intermediate result. No full-scan success is inferred.

## References and Result

Resume 2.1 for grouped fixture RED/GREEN, scoped owner proof and strict validation. The source issue records the exact eight baseline knowledge findings and default invocation.
