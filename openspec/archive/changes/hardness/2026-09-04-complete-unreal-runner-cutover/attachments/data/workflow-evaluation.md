---
record: hardness-workflow-evaluation-v1
result: passed
change: hardness/complete-unreal-runner-cutover
captured_at: 2026-09-04T01:19:29+08:00
---

# Workflow Evaluation

## Elapsed lifecycle stages

- Planning and first implementation pass: completed before the focused closure request.
- Scope correction and stable-name replan: completed on 2026-09-04.
- Isolated verification and real UE evidence: completed on 2026-09-04.
- Spec synchronization and closure preparation: completed on 2026-09-04.

## Material friction

- The original closure task combined the short-path repair with broad root `Tools` deletion; the user narrowed this small Change to the runner cutover.
- Stable data and registry names initially carried decorative version suffixes; the user required stable unsuffixed names.
- The real mapped build exposed an existing generated-JIT compilation error unrelated to path projection. The user explicitly deferred that repair and accepted normal UE startup as the current gate.
- The parent worktree contains unrelated active refactor changes, so verification and commit scope must remain path-exact.

## Corrective actions

- Applied two evidence-backed replans and retained the completed implementation nodes.
- Kept broad root wrapper deletion and the Hardness-to-Harness rename outside this Change.
- Ran isolated Unreal groups, a mapped default-executor build attempt, and a real mapped `AngelscriptSmoke` run.
- Synchronized only the verified Unreal contract into the current specification.

## Superseded owners

- The original Task `3.3` ownership of broad root Tools deletion was removed; no successor Change is claimed by this closure.
- The original successful-build acceptance in Task `3.2` was superseded by the user's explicit startup acceptance.

## Raw-data provenance

- Build run `4977707ef2ea4c1f88025665c25df982` under `Saved/Hardness/Unreal/Runs/` records mapped UBT launch, default executor behavior, progress, terminal failure, and exact mapping cleanup.
- Smoke run `8540d17f10f443c8baeb3ccef21a8d2c` under `Saved/Hardness/Unreal/Runs/` records mapped UnrealEditor-Cmd launch, successful Automation completion, and terminal mapping cleanup.
- Focused PowerShell test output was observed directly from the seven isolated Unreal test groups; no generated performance aggregate is claimed.
