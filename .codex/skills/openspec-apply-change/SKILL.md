---
name: openspec-apply-change
description: Use when the user wants to implement, continue, verify, or work through tasks from an OpenSpec change in AngelscriptProject, including /opsx:apply or /openspec:apply.
---

# OpenSpec Apply With Superpowers Adapter

Implement tasks from an OpenSpec change. OpenSpec remains the task source; Superpowers provides execution discipline when its trigger conditions apply.

<!-- SUPERPOWER-BEGIN: superpowers-dispatch-rule -->
Phase mapping:
- Use `superpowers:test-driven-development` for tasks marked `<!-- TDD -->` or for new behavior, bug fixes, behavior changes, and complex logic.
- Use `superpowers:systematic-debugging` for unexpected test failures, build failures, runtime bugs, or unclear behavior.
- Use `superpowers:verification-before-completion` before claiming a task, change, build, or test run is complete or passing.
- Use `superpowers:receiving-code-review` before implementing review feedback from a user or reviewer.
- Use `superpowers:requesting-code-review` when a major feature, shared behavior, or merge-ready change needs review and the environment can support the review workflow.
- Use `superpowers:finishing-a-development-branch` only after implementation is complete and fresh verification evidence exists.
<!-- SUPERPOWER-END: superpowers-dispatch-rule -->

<!-- SUPERPOWER-BEGIN: project-test-conventions -->
Superpowers skills (TDD, debugging, verification) do not know this project's test conventions. When executing TDD tasks or writing tests, apply these project rules:

- New test files must start with `Angelscript` prefix (e.g., `AngelscriptMyFeatureTests.cpp`).
- Choose test layer first (before writing any file):
  - Needs `FAngelscriptEngine` but no UObject/World? → Runtime Integration (`AngelscriptTest/<Theme>/`)
  - Needs real `UObject`/`World`/`Actor` lifecycle? → UE Functional (`AngelscriptTest/<Theme>/`)
  - Only Editor internals? → Editor (`AngelscriptEditor/Tests/`)
  - Pure AngelScript SDK, no engine? → Native Core (`AngelscriptTest/AngelScriptSDK/`)
  - Per-type binding coverage? → CQTest Bindings (`AngelscriptTest/Bindings/`)
- Automation prefix: theme-first for functional (`Angelscript.TestModule.<Theme>.*`), layer-first for native/learning.
- Use existing harness — do not hand-write spawn/tick/lifecycle helpers:
  - `FAngelscriptTestWorld` for actor/component/lifecycle tests (see `Template_WorldTick.cpp`, `Template_GameLifetime.cpp`)
  - `FCoverageModuleScope` + CQTest for bindings (see `Template_CQTest.cpp`)
  - `AngelscriptNativeTestSupport.h` / `AngelscriptTestAdapter.h` for pure SDK tests
- Verification commands: only `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`. Never hand-write UBT/Build.bat/RunUBT.bat.
- Reference docs: `Documents/Guides/TestConventions.md`, `Documents/Guides/Test.md`, `Plugins/Angelscript/AGENTS.md`.
<!-- SUPERPOWER-END: project-test-conventions -->

## Input

The user may specify a change name. If omitted, infer only when unambiguous. If multiple active changes exist, ask the user to choose.

## Steps

1. **Select and inspect the OpenSpec change**

   Run:

   ```powershell
   openspec status --change "<name>" --json
   openspec instructions apply --change "<name>" --json
   ```

   Use the returned schema, task progress, dynamic instruction, and `contextFiles`. If the apply instruction reports a blocked or missing-artifact state, stop and report the missing artifacts.

2. **Read OpenSpec context files**

   Read every file listed in `contextFiles`. Do not assume file names; OpenSpec schema output is authoritative.

   If `contextFiles` is empty (e.g., change is blocked or artifacts are missing), fall back to reading the change directory contents directly: `.openspec.yaml`, `README.md`, and any artifact files already generated under the change path.

   Apply uses the OpenSpec artifacts currently on disk, including any manual edits the user made after propose.

<!-- SUPERPOWER-BEGIN: plan-as-tasks-md -->
`tasks.md` is the only implementation plan. During apply, do not create `docs/plans` or `docs/superpowers/plans`, and do not write implementation plans outside the current OpenSpec change.

If task decomposition needs revision, you may use the planning method from `superpowers:writing-plans`, but the result must be written back to the current change's `tasks.md`.

During apply, read and update only the `tasks.md` under the current OpenSpec change:
- Do not write task execution logs, review notes, or temporary commentary into `tasks.md`.
- Update checkboxes only after the task is actually complete.

If implementation reveals a design or requirement problem, update the relevant OpenSpec artifact for the current change, then continue from the updated task list.
<!-- SUPERPOWER-END: plan-as-tasks-md -->

3. **Check worktree safety before editing code**

<!-- SUPERPOWER-BEGIN: worktree-check -->
Before making any code changes, check the current Git context with non-mutating commands:

```powershell
git rev-parse --show-toplevel
git rev-parse --git-dir
git rev-parse --git-common-dir
git worktree list --porcelain
```

Decision rules:
- If the user explicitly asks to create, switch to, or implement in a worktree, create or switch to a feature worktree before continuing.
- If the user does not explicitly request a worktree and the current main/master working tree is clean, continue in the current workspace.
- If the user does not explicitly request a worktree and the current workspace has uncommitted or untracked changes, stop and ask whether to create/switch worktree, continue in the current directory, or cancel.

If the user chooses to create a worktree, use `superpowers:using-git-worktrees` as guidance, but do not silently edit `.gitignore`, commit changes, or move work without explicit confirmation.
<!-- SUPERPOWER-END: worktree-check -->

4. **Analyze tasks before editing code**

<!-- SUPERPOWER-BEGIN: execution-mode-selection -->
Before implementation, summarize pending tasks and classify them as TDD or non-TDD from `tasks.md` markers and task content.

Recommend execution mode:
- `agent` for up to 5 mostly sequential tasks or tightly coupled changes.
- `subagent` only for clearly independent tasks or when the user explicitly wants delegated agent work.

Stop for user selection before spawning subagents. In Codex, use subagents only when explicitly selected or requested by the user.
<!-- SUPERPOWER-END: execution-mode-selection -->

5. **Execute tasks from `tasks.md`**

<!-- SUPERPOWER-BEGIN: tdd-discipline -->
For TDD tasks, use the current `superpowers:test-driven-development`. Do not write implementation code for a TDD task before observing the failing test required by that skill.
<!-- SUPERPOWER-END: tdd-discipline -->

<!-- SUPERPOWER-BEGIN: non-tdd-discipline -->
For non-TDD tasks, execute the stated change, run the listed verification command, and check affected references before marking the task complete.
<!-- SUPERPOWER-END: non-tdd-discipline -->

<!-- SUPERPOWER-BEGIN: debugging-discipline -->
When any verification, build, test, or runtime behavior is unexpected, use `superpowers:systematic-debugging` before attempting fixes. Do not guess at fixes or stack patches without root cause evidence.
<!-- SUPERPOWER-END: debugging-discipline -->

6. **Update task checkboxes carefully**

   Update `tasks.md` only after the corresponding task or subtask is actually complete. Prefer a minimal patch that changes only `[ ]` to `[x]` on the relevant line. Do not add logs, review notes, or execution commentary to `tasks.md`.

7. **Verify before completion claims**

<!-- SUPERPOWER-BEGIN: verification-gate -->
Use `superpowers:verification-before-completion` before claiming success.

Fresh evidence must come from the task's verification command. Before running verification, choose the entry point from the project docs for the task scope:
- Build guidance: `Documents/Guides/Build.md`
- Test guidance: `Documents/Guides/Test.md`
- Test naming and organization: `Documents/Guides/TestConventions.md`

Verification must use the project unified runner or documented entry points. Do not hand-write UBT, Build.bat, RunUBT.bat, or dotnet UnrealBuildTool commands.
<!-- SUPERPOWER-END: verification-gate -->

8. **Handle review feedback with technical verification**

<!-- SUPERPOWER-BEGIN: review-policy -->
When receiving review feedback, use `superpowers:receiving-code-review` before implementing suggestions. Verify the feedback against this codebase, ask when unclear, and push back with technical evidence when a suggestion is wrong or out of scope.

Use `superpowers:requesting-code-review` for major or shared changes when review delegation is available. If no reviewer workflow is available, do a local review pass against OpenSpec requirements, changed files, tests, and integration risks, then report that no external reviewer was used.
<!-- SUPERPOWER-END: review-policy -->

9. **Finish or pause**

   If all tasks are done, run final verification and then use `superpowers:finishing-a-development-branch` to present branch completion options. If blocked, report the blocker, current progress, and the next decision needed.

<!-- SUPERPOWER-BEGIN: safe-rollback -->
Never run broad rollback commands such as `git checkout -- .` or `git reset --hard` as part of this workflow. If rollback is requested, show `git status --short` and `git diff --stat`, ask which paths to revert, and only revert explicitly confirmed paths.
<!-- SUPERPOWER-END: safe-rollback -->

## Guardrails

- Keep changes scoped to the current OpenSpec change.
- Do not skip task verification.
- Do not mark tasks complete based only on expectation or partial evidence.
