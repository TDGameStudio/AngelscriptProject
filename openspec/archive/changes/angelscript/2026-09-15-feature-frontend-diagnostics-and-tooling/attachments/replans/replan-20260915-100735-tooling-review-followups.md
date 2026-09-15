---
replan_id: replan-20260915-100735-tooling-review-followups
status: applied
source: review
source_ref: attachments/reviews/review-20260915-095353-frontend-diagnostics-independent-inline.md; user request to replan
scope: tooling acceptance and completion evidence, explicit Review closure
base_commit: c76d28ccd3c4366f3b33b190afa2b08bede26f56
base_tasks_sha256: 309b0abdb4e9753fe601be60df5c2967af7dae3d7cfa9eba14192ff47229a640
result_tasks_sha256: 31d3916984c65372fd85d7f142f98eeec34e23d6810fabd7c89ed341c4709ec5
created_at: 2026-09-15T10:07:35.326485+08:00
resume_task: 7.1
---

## Trigger and Evidence

Both indexed user Reviews remain open and CHANGES_REQUIRED. Reauthenticated all 204 manifest entries in Saved/Harness/Reviews/review-20260915-093506-frontend-diagnostics-final: zero mismatches; its product bytes still equal the live checkout. Snapshot manifest SHA-256: 4660e3c23cd4f40dd898c77439289f89118e7c0dc1b5eea25cc4dfb7889cd16c.

Source traces confirm path-only fallback identity, enum-only member filtering, flattened prefix scope, dropped query-error statuses and a signature result unable to carry candidates. Earlier four-line freeze flag and repeated declaration Builder observations also hold. These are verified source observations; no new runtime reproduction or corruption is claimed.

The invalid planning truth is completion evidence: the old 16/16 GREEN plan exposes no remaining work although accepted tooling boundaries are unmet. Severity alone is not the trigger. Requirements and design behavior remain valid. Exact active Change strict validation passed before this update, zero issues.

## Decision

Preserve original completed nodes and add seven bounded repair outcomes plus final-content verification and closure of the two explicitly requested Reviews. No new product scope or user-owned naming choice. Current design gets implementation constraints for its existing contracts; original handoff/specs stay intact. This is a planning-only operation.

## Impact

| Review finding | Owner and disposition |
|---|---|
| Old F01; independent F02 | 7.3 grammar/expected-type completion, 7.5 owned signature payload/parity |
| Old F02; independent F03 | 7.4 context-aware access |
| Old F03; independent F01 | 7.1 source/environment identity |
| Independent F04 | 7.3 live lexical scope |
| Old F05; independent F05 | 7.2 status propagation |
| Old F04 | 7.1 navigation probes, 7.2 cancel/position, 7.3/7.5 cursor oracles, 8.1 honest coverage/RED provenance |
| Old F06 | 7.6 existing ownership-audit requirement; no demonstrated production corruption |
| Old F07 | 7.7 accepted in-Change single-preparation follow-up |
| Both Review lifecycles | 8.2 after 8.1 |

A third discovered test method is not intrinsically required; actual missing assertions are. Historical RED cannot be recreated. Retain that provenance gap and observe repair RED honestly. No finding is resolved or deferred merely by this plan.

## Old Task Disposition

3.3, 4.1-4.4 and 6.1 need follow-up; append their new owners without changing original evidence. All sixteen completed checkboxes remain checked. Other completed work is preserved. No IDs are reused or removed.

## Diff Snapshot

Affected parent status before update: `?? openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/`.
Affected parent diff stat: `(empty: Change is untracked)`.
Plugin observation: as_ast_context.cpp modified; as_cursor_context.cpp/as_tooling_completion.cpp/as_tooling_navigation.cpp untracked. This operation does not edit product paths.
Task +: 7.1-7.7, 8.1-8.2; task -: none; task ~: historical follow-up annotations, current constraints and coverage.
Edge +: {"7.1": ["4.1", "4.3"], "7.2": ["4.1", "4.4"], "7.3": ["4.2", "4.4"], "7.4": ["7.3", "3.3"], "7.5": ["7.3", "3.3"], "7.6": ["4.1"], "7.7": ["4.2", "4.4"], "8.1": ["6.1", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7"], "8.2": ["8.1"]}
Edge -: none. Shared files restrict scheduling, not prerequisites.
Artifact ~: proposal.md, design.md, tasks.md, attachments/INDEX.md, attachments/data/planning-validation.md. Artifact +: this applied record.
Candidate validated before active writes: graph/body key equality, unique IDs, existing dependencies, no cycles, sixteen completed nodes preserved, nine bounded cards with exact existing file paths and proving commands. Canonical CLI verification of the applied candidate is recorded separately in planning-validation.md so this record remains immutable.

## Preserved Work

NativeEngine 1150/1150, integration 3/3 and Baseline 2+1-with-warning remain authentic historical evidence for the reviewed snapshot, not proof of later repairs. Diagnostic/parallel-Lex work, original requirements/exports, predecessor archive and unrelated dirty paths remain intact.

## References and Result

Read tasks.md as the sole live DAG, and both indexed Reviews for original findings. Resume 7.1; additional initial Ready nodes are 7.2, 7.3, 7.6 and 7.7, with sequential edits/builds wherever files or execution leases overlap. No product implementation, UE run, spec synchronization, archive or Git mutation is part of this update.
