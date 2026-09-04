---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-route-context-authority
captured_at: 2026-09-04T11:11:13.8407296+08:00
---

# Workflow Evaluation

## Lifecycle exercised

The repair used a strict active Change, a focused public-dispatcher RED/GREEN cycle, current-spec synchronization, and terminal closure checks in the exact selected main workspace.

## Findings and corrections

- The initial regression used an incomplete temporary Git repository and reached a leaf failure instead of demonstrating dispatcher retargeting. It was corrected to use the initialized `Tools/openspec` repository, producing the intended RED: a main Context successfully returned status for the alternate repository.
- The dispatcher previously filled only missing values for most routes and allowed internal callers to replace `Context`. One normalizer now rejects blank, conflicting, or mismatched dispatcher-owned paths, removes duplicate aliases, and injects the canonical selected value.
- `git.integrate` previously converted a linked selected Context into its primary root. It now requires the selected Context itself to be primary; `SourceWorkspaceRoot` remains the explicit different-root input validated by the Git leaf.

## Evidence

- Table-driven Harness fixtures cover every workspace route, Git target routes, all published `ue.*` routes, all internal routes, matching and conflicting aliases, linked integration rejection, and a legal primary integration preview.
- The focused Harness test passes after the implementation and rejected operations return `ContextAuthorityMismatch` with no leaf data.
- Strict spec/change validation, Quick Harness, terminal evolution, archived audit, and the post-archive focused gate are the closure checks for this record.

## Outcome

The repair centralizes route authority without changing leaf contracts or native OpenSpec syntax. The resulting behavior is deterministic across primary and linked Contexts and preserves explicit source-workspace selection only where integration requires it.
