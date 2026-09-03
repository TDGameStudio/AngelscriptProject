---
record: harness-workflow-evaluation-v1
result: passed
change: harness/rename-hardness-to-harness
captured_at: 2026-09-04T02:14:18+08:00
---

# Workflow Evaluation

The hard public identity cutover is complete. The maintained entry module, PowerShell symbols, routes, environment variables, Saved paths, machine-local registry, OpenSpec namespace, tests, hooks, and live documentation now use Harness. No old public alias is retained.

## Verification

| Gate | Result |
|---|---|
| Fresh-process Harness cutover contract | PASS |
| Harness core and protocol fixtures | PASS |
| Workspace lifecycle and safety fixtures | PASS |
| Git operations fixtures | PASS |
| OpenSpec Skill fixtures | PASS |
| Unreal integration, discovery, foundation, and report fixtures | PASS |
| `Test-Harness.ps1 -Profile Quick` | 8/8 PASS |
| `Test-Harness.ps1 -Profile Integration` | 13/13 PASS |
| OpenSpec doctor | valid, zero diagnostics |
| Strict active Change validation | 1/1 PASS |
| Strict current specification validation | 5/5 PASS |
| Strict all validation | 6/6 PASS |
| Maintained-live old-name audit | 17 matched files, 17 allowlisted, 0 unexpected |
| Immutable historical archive audit | `openspec/archive/changes/hardness/**` unchanged |
| Actual workspace config migration | `[Hardness]` schema v2 removed; `[Harness]` schema v3 valid |
| Unreal registry PlanOnly check | old file unchanged; new file absent |
| Unreal real-operation migration | old file removed; unsuffixed Harness file written with `harness-unreal-drive-assignments` schema |
| Real `AngelscriptSmoke` run `d24adffbe4b24b66a3a0a974f2bea4c4` | Succeeded in 153395 ms; 73 total, 62 succeeded, 11 succeeded with warnings, 0 failed, 0 skipped, 0 errors |

## Scope and provenance

- Implementation started from parent HEAD `01b21f4655ab3830ba3c47a7586f0c7470225a41` after the prior evolution-loop Change was archived and committed.
- Current specifications were merged additively into `harness/core`, `harness/workspace`, `harness/git`, and `harness/unreal`.
- Stable OpenSpec object aliases remain only in domain/spec manifests; immutable historical archives remain in their original `hardness` directories.
- The pre-existing README additions remain isolated in `stash@{0}` until after the exact rename commit.
- The previously deferred product build failure was not retried, as authorized; this Change verifies normal editor/test startup only.

## Terminal assessment

There are no material implementation issues, deferred owners, unresolved review findings, or incomplete cutover tasks. The Change is ready for completed archive after the final terminal gate.
