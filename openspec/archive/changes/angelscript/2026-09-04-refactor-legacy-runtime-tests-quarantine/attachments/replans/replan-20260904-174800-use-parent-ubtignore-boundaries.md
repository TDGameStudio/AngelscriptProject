---
replan_id: replan-20260904-174800-use-parent-ubtignore-boundaries
status: applied
source: evidence
source_ref: c1417a7ff9f44eb4977934e616d11806
scope: legacy test source-discovery boundary and reusable UE knowledge
base_commit: 47d38dffc062a79e8f9e7c319981406ea79772c3
base_tasks_sha256: 68d29c34eb4a19019cfe065129aa85012504bcb4f92925ff3b2dd6c792d04d84
result_tasks_sha256: cc25b62a7e9f5b608dcc850b7c6bea7109bb0fd685365de99ceeb3fdf0f627c5
created_at: 2026-09-04T17:48:00+08:00
resume_task: "3.2"
---

# Use source-free parent `.ubtignore` boundaries

## Trigger and Evidence

The complete-file macro implementation from Task `3.1` removed test registration but also removed definitions required by UHT-generated reflection thunks. Build `af2fd14ba73c4f4994a65d805b7846a3` failed with unresolved reflected fixture methods in `AngelscriptEditor` and `AngelscriptTest`.

Guarding the matching headers was not viable: build `c1417a7ff9f44eb4977934e616d11806` showed that UHT explicitly rejects Unreal reflection macros inside arbitrary `WITH_ANGELSCRIPT_UNITTESTS` blocks. Restoring old file contents and placing `.ubtignore` directly inside source-owning leaf directories then produced a split graph in builds `fecbd75868d4471eba4d36302a7eb396` and `fc74b516f56c4516b69be7e1256041c2`: UHT excluded the reflected headers while normal UBT enumeration still compiled `.cpp` files located beside each marker.

UE 5.8 source inspection explains the split. `UEBuildModuleCPP.FindInputFilesFromDirectory()` records same-directory inputs while noticing `.ubtignore`; its recursive caller stops only before descendants. UHT has its own early ignored-directory checks. The marker therefore must be encountered in a source-free parent before either system visits the old code.

## Decision

Retain the old corpus beneath five owning `Legacy/` parents and place one `.ubtignore` in each parent:

- `AngelscriptTest/Legacy/`
- `AngelscriptEditor/Legacy/`
- `AngelscriptGameplayTagsTest/Private/Legacy/`
- `AngelscriptGASTest/Private/Legacy/`
- `AngelscriptProjectTest/Legacy/`

Keep module implementations, the active `AngelscriptTestModule.h`, `NewVersion`, and passive TestJIT generated-ABI support outside ignored parents. Preserve old source contents rather than wrapping them. Keep `WITH_ANGELSCRIPT_UNITTESTS=0` as the policy gate for active module-shell behavior and legacy dependency declarations, but do not promise macro-only reactivation.

Use one `-NoUBTMakefiles` transition build after changing the source topology. Build `8cbf894039494de5ad132e5ab00ee870` discovered only 15 actions and passed, proving that the parent-marker layout excludes C++ and UHT consistently. Fast-headless run `427f9ed3a4ac4588a79c3e55adf9f00d` then discovered and passed exactly the three replacement baseline tests.

At the user's request, preserve the non-obvious `.ubtignore` rule in the testing capability spec and a focused `angelscript-test-guide` reference rather than in `Documents/`.

## Impact

- Task `3.2` owns the final directory isolation, transition build, baseline proof, and focused Skill reference.
- Task `3.1` retains its corpus inventory and RED/audit history, but its mechanical whole-file guard is superseded.
- Proposal, design, testing delta, and attachment index now describe retained `Legacy/` trees instead of in-place macro wrapping.
- No runtime API, Harness API, generated JIT artifact, lexer, or AST implementation changes.

## Old Task Disposition

The old Task `3.1` outer-guard implementation is reverted. Its inventory evidence remains valid. Task `3.2` replaces the invalid mechanism without unchecking completed work or discarding the observed failures.

## Diff Snapshot

- Source layout: five ignored `Legacy/` parent trees, active module shells and `NewVersion` outside.
- Build boundary: `AngelscriptTest.Build.cs`, module shell macro gates, unchanged passive TestJIT probe ABI.
- Knowledge: testing delta spec and `.agents/skills/angelscript-test-guide/references/legacy-source-isolation.md`.
- Audit: validates corpus counts, parent markers, active exclusions, replacement gate, and generated artifacts.
- DAG edges: unchanged; Task `3.2` remains the ready node.

## Preserved Work

Hard Runtime/Editor/JIT/extension dormancy, separate old/new macros, the final public test namespace, exact-prefix fast-headless verification, and all earlier passing evidence remain unchanged.

## References and Result

- UE source: `Engine/Source/Programs/UnrealBuildTool/Configuration/UEBuildModuleCPP.cs`
- UE source: `Engine/Source/Programs/UnrealBuildTool/System/UHTExecution.cs`
- Successful transition build: `8cbf894039494de5ad132e5ab00ee870`
- Successful replacement baseline: `427f9ed3a4ac4588a79c3e55adf9f00d`
- `tasks.md`

The updated Task DAG resumes at Task `3.2`.
