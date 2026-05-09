---
name: openspec-propose
description: Use when the user starts or updates an OpenSpec change proposal in AngelscriptProject, including /opsx:propose or /openspec:proposal, and needs Superpowers-backed thinking before OpenSpec artifacts are generated.
---

# OpenSpec Propose With Superpowers Adapter

Create or continue an OpenSpec change. In this project, propose is a design and artifact workflow, not implementation.

<!-- SUPERPOWER-BEGIN: superpowers-dispatch-rule -->
Use the relevant Superpowers skill at the phase where it applies; this skill only defines the OpenSpec workflow and project override rules.
<!-- SUPERPOWER-END: superpowers-dispatch-rule -->

<!-- SUPERPOWER-BEGIN: propose-thinking-flow -->
Before creating or editing OpenSpec artifacts, use `superpowers:brainstorming` for requirement discovery and design confirmation.

Apply only the thinking portion of brainstorming:
- Explore the project context first.
- Ask focused questions until the goal, scope, constraints, and success criteria are clear.
- Present 2-3 viable approaches with tradeoffs and a recommendation when meaningful.
- Present the chosen design and wait for explicit user confirmation before writing artifacts.

OpenSpec overrides for brainstorming:
- Do not write `docs/superpowers/specs`.
- Do not create `docs/plans` or `docs/superpowers/plans` during brainstorming.
- Store the approved design in OpenSpec CLI artifact paths instead of separate documents.
- When implementation planning is needed, use the `plan-as-tasks-md` rule.

Design consensus mapping:
- `proposal.md`: why, what changes, and impact.
- `design.md`: current state, goals/non-goals, technical approach, tradeoffs, and risks.
- `specs/*`: user-observable requirements as requirements/scenarios.
- `tasks.md`: executable tasks and verification commands; this is the only implementation plan.
<!-- SUPERPOWER-END: propose-thinking-flow -->

## Input

The user should provide either a kebab-case change name or a description of what they want to build or fix. If the request is unclear, ask what change they want and stop until they answer.

## Steps

1. **Clarify and confirm the design**

   Follow the `propose-thinking-flow` adapter block. Do not create files until the user has confirmed the design direction.

2. **Check worktree safety**

<!-- SUPERPOWER-BEGIN: worktree-check -->
Choose worktree use from user intent and current workspace state. Check the current Git context with non-mutating commands such as:

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

3. **Create or continue the OpenSpec change**

<!-- SUPERPOWER-BEGIN: openspec-cli-compat -->
OpenSpec CLI metadata is authoritative. Do not create a bare `openspec/changes/<name>` directory by hand.

For a new change, run:

   ```powershell
   openspec new change "<name>"
   ```

Then inspect artifact state:

   ```powershell
   openspec status --change "<name>" --json
   ```

For each ready artifact, get current schema instructions:

   ```powershell
   openspec instructions <artifact-id> --change "<name>" --json
   ```

Use the returned `outputPath`, `template`, `instruction`, `context`, `rules`, and dependency list. Read dependency artifacts before generating dependent artifacts. Preserve `.openspec.yaml` and all OpenSpec CLI state.
<!-- SUPERPOWER-END: openspec-cli-compat -->

4. **Generate artifacts until apply-ready**

   Continue in dependency order until every artifact required by `applyRequires` is complete. Re-run `openspec status --change "<name>" --json` after each artifact.

5. **Use `tasks.md` as the implementation plan**

<!-- SUPERPOWER-BEGIN: plan-as-tasks-md -->
`tasks.md` is created by the OpenSpec propose artifact flow. Get the tasks artifact `outputPath`, `template`, and `instruction` with `openspec instructions <tasks-artifact-id> --change "<name>" --json`, then write to that path.

When generating `tasks.md`, you may use the planning method from `superpowers:writing-plans`: explicit file scope, task size, TDD steps, verification commands, and risk checks.

OpenSpec overrides:
- Do not use the default `superpowers:writing-plans` save path.
- Do not create `docs/superpowers/plans` or `docs/plans`.
- Do not add standalone commit steps; commits are decided by the later development flow.
- `openspec/changes/<name>/tasks.md` is the only implementation plan.

The plan is complete when:
- OpenSpec apply-required artifacts are generated through the OpenSpec CLI flow.
- `tasks.md` has explicit, runnable verification commands for each implementation task.
- TDD and non-TDD tasks are distinguishable.
- The user has enough context to review and run `/opsx:apply`.
<!-- SUPERPOWER-END: plan-as-tasks-md -->

<!-- SUPERPOWER-BEGIN: tasks-template -->
When creating implementation tasks, define only what OpenSpec `tasks.md` must carry. Do not copy Superpowers execution steps into this skill.

Task requirements:
- Mark new behavior, bug fixes, behavior changes, and complex logic with `<!-- TDD -->`.
- Mark documentation, mechanical config, dependency updates, generated files, and work without an appropriate failing behavioral test with `<!-- Non-TDD -->`.
- Each task must state the relevant file scope, expected change, and verification entry point.
- TDD tasks must be sufficient to trigger and execute the current `superpowers:test-driven-development`; task decomposition may follow the current `superpowers:writing-plans`.
- Non-TDD tasks must still include verification or completeness checks; do not write tasks that only say to edit files.

For this Unreal project, do not hardcode verification command templates in the skill. When generating `tasks.md`, choose verification entry points from the project docs for the task scope:
- Build guidance: `Documents/Guides/Build.md`
- Test guidance: `Documents/Guides/Test.md`
- Test naming and organization: `Documents/Guides/TestConventions.md`

Task verification commands must use the project unified runner or documented entry points. Do not hand-write UBT, Build.bat, RunUBT.bat, or dotnet UnrealBuildTool commands.
<!-- SUPERPOWER-END: tasks-template -->

6. **Finish propose**

   Show the change name, artifact paths, and current OpenSpec status. Tell the user they may review and manually edit `proposal.md`, `design.md`, `specs/*`, or `tasks.md` before apply; run `/opsx:apply <name>` when ready.

## Guardrails

- Propose must not edit application code.
- Keep all generated artifacts under OpenSpec CLI output paths.
- If a user asks to implement while still proposing, explain that implementation starts with `/opsx:apply` after artifacts are ready.
