---
replan_id: replan-20260905-160000-in-process-language-service
status: applied
source: user
source_ref: user confirmation to add in-process asCLanguageService to this Change without JSON-RPC
scope: compile-time SDK language service for diagnostic format, structured note/fix query and in-memory apply
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: dbc81a7eea838aa7ea5c8dd11efbfc6d8d04d21831f9eaea16656eaea5736406
result_tasks_sha256: f6dbeb9e56137728992d51b6a68d79cd3de78e215d6cbeaada847b791e90b75b
created_at: 2026-09-05T16:00:00Z
resume_task: 1.1
---

## Trigger and Evidence

The user directed a Replan of `angelscript/feature-frontend-diagnostics-tooling` so the plugin SDK exposes an in-process `asCLanguageService`. Compilation failures must format Clang-style suggestion text and inspect notes/fixes as structured data. JSON-RPC, stdio/pipe servers and VS Code migration stay out of scope. The prior non-goal that treated all language-service surface as later LSP work is therefore invalid.

## Decision

Add `asCLanguageService` as a library facade over the planned renderer and edit applier. Strengthen 1.2 Clang-style text. Keep `asCToolingSession` as the query API. Reserved query feature bits on the language service report unavailability.

## Impact

Proposal, tooling/source-diagnostics deltas, design, inventory ownership, INDEX and the Task DAG now include compile-time SDK consumption. Product code, tests, current specs, Git and apply authorization are unchanged.

## Old Task Disposition

| ID | Disposition |
|---|---|
| 1.1, 2.1, 2.2, 3.1, 3.2, 3.3 | preserved |
| 1.2 | preserved, scope widened for caret-suggestion rendering |
| 4.1 | preserved, now depends on 5.1 and consumes the facade |
| 5.1 | added |

## Diff Snapshot

- Path status: the Change directory remains untracked (`?? openspec/changes/angelscript/feature-frontend-diagnostics-tooling/`); HEAD `d4f69984b0611ca44956577c242266edad24002b` has no committed baseline for these files.
- Diff stat: not available from Git for an untracked tree. Edited planning files: `change.yaml`, `proposal.md`, `design.md`, `tasks.md`, `specs/angelscript/language/frontend/{source-diagnostics,tooling}/spec.md`, `attachments/INDEX.md`, `attachments/data/diagnostic-migration-inventory.md`; added `attachments/talks/talk-20260905-160000-in-process-language-service.md` and this record.
- Tasks: `5.1` +; `1.2` ~; `4.1` ~.
- Edges: `5.1 -> {1.2, 2.2}` +; `4.1 -> 5.1` +.
- Artifacts: proposal/spec/design ~; talk +; replan +.

## Preserved Work

No implementation nodes were complete. Producer migration, tooling queries, inventory coverage and the JSON-RPC exclusion remain.

## References and Result

Talk `attachments/talks/talk-20260905-160000-in-process-language-service.md`. Resume at Ready `1.1` after a later explicit apply authorization.
