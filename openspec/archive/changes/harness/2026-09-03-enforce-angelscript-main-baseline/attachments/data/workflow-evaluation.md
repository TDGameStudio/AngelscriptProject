---
record: harness-workflow-evaluation-v1
result: passed
change: harness/enforce-angelscript-main-baseline
captured_at: 2026-09-04T02:37:11+08:00
---

# Workflow Evaluation

## Baseline evidence

- Parent starting gitlink: `ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`.
- Selected plugin local main: `5472045b6408e0144ece63b4c05e67056a3d2907`.
- Explicitly fetched `origin/main`: `974e2811c76b5d80b0f2dc6f4c7a28955765bf80`.
- Relationship: starting gitlink is 57 commits behind local main; origin/main is an ancestor and local main is 69 commits ahead.
- Local main contains the completed CanonicalAST sequence following the Typed Semantic HIR/TypedASTJIT commit.

## Verification

| Gate | Result |
|---|---|
| Workspace baseline TDD RED | Expected failure: detailed status lacked `AngelscriptMainBaseline` |
| Workspace baseline fixture GREEN | PASS |
| Workspace safety | PASS |
| Harness core | PASS |
| Unreal fixture suite | All PASS |
| Harness Quick | 8/8 PASS |
| Harness Integration | 13/13 PASS |
| Strict current specs | PASS |
| Strict all active records | PASS |
| Full guarded UE build `d50aef11af7c4c589cccd7c1403c42b6` | Succeeded, exit 0, 206/206 actions, 169130 ms |
| Post-guard incremental build `7ae853562cf046d0ab5587c152034478` | Succeeded, exit 0, 1266 ms |
| Real detailed baseline status | Applicable, configured, initialized, aligned; HEAD equals local main; origin contained |

## Friction and disposition

- The initial assumption that the submodule was behind remote main was disproved. The fetched remote was older; the stale state was the parent gitlink and working checkout relative to the already integrated local main.
- No plugin source fix was required because the complete integrated main compiled successfully.
- Harness remains deliberately network-free during status and execution. Remote-tracking freshness requires an explicit fetch, while execution deterministically rejects any mismatch against the latest known refs.
- No material implementation issue, Review, Replan, deferred owner, or push authority was introduced.

## Terminal assessment

The parent main workspace now selects the integrated plugin main tip, the complete UE build passes, and Harness prevents future primary-main execution on an intermediate known plugin commit. The Change is ready for completed archive.
