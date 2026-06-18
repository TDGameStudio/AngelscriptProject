---
name: openspec-work
description: "Use to explore, think through, start, continue, propose, record, plan, apply, implement, or archive an OpenSpec change in AngelscriptProject, including /opsx:work, /opsx:explore, /opsx:propose, /opsx:apply, /opsx:archive, and the /openspec equivalents. Supports explore/think-only sessions, record-only proposals (no immediate implementation), record-while-implementing, and closing/archiving — all in a single flow."
---

# OpenSpec Work (Explore + Record + Implement + Archive, One Flow)

`openspec-work` is the single entry point for the whole change lifecycle: exploring/thinking, recording a change, implementing it, and archiving it when done. OpenSpec is a lightweight record, not a gate. You may:

- just explore and think;
- record intent only and stop;
- record and implement in the same session;
- continue implementing an already-recorded change;
- or just archive a finished one.

Initial plans are disposable — overturn and rewrite them whenever reality demands.

This skill merges the former `openspec-explore`, `openspec-propose`, `openspec-apply-change`, and `openspec-archive-change`. There is no phase wall: you may think, edit OpenSpec artifacts, and edit application code together, in any order, and archive is an ordinary closing action — not a gate.

## Core stance

- **OpenSpec = records, Superpowers = method.** Lighten OpenSpec's own ceremony, but keep using Superpowers methods actively for the actual work.
- **First-class usages — detect intent first:**
  1. **Explore / think only** — investigate, compare options, and clarify requirements without committing to a change yet. Lean read-only; record nothing until the direction is worth keeping. Use `superpowers:brainstorming` thinking.
  2. **Plan-only deliverable (plan now, implement later)** — produce a complete, ready-to-execute plan as the deliverable, then stop without implementing. The plan must reach `superpowers:writing-plans` quality (file map, bite-sized tasks, exact verification commands), not a skeleton. Implementation can happen later or in another session on the same change.
  3. **Record + implement now** — evolve a lean record and the code together; expand the record as you go.
  4. **Continue implementing** — pick up an existing recorded change and implement it.
  5. **Archive / close** — finalize a finished change via the CLI (see the archive step). Archiving is an ordinary closing action, not a verification gate.
  At the start, identify which usage applies, then match record depth to intent. Do not assume a change must be created or code must be written immediately — pure exploration and plan-only are valid sessions, and a plan-only deliverable should be thorough, not minimal.
- **Plans are disposable.** `tasks.md` is a living record you can rewrite or throw away at any time, not a binding contract.

Actively use Superpowers methods as the "how" of the work:
- Use `superpowers:brainstorming` when discovering requirements or comparing designs.
- Use `superpowers:test-driven-development` for tasks marked `<!-- TDD -->` or for new behavior, bug fixes, behavior changes, and complex logic.
- Use `superpowers:systematic-debugging` for unexpected test failures, build failures, runtime bugs, or unclear behavior — investigate root cause instead of guessing.
- Use `superpowers:verification-before-completion` at key milestones before claiming a step is done or passing (see verification rule below).
- Use `superpowers:receiving-code-review` before implementing review feedback; `superpowers:requesting-code-review` for major or shared changes when review is available.
- Use `superpowers:finishing-a-development-branch` when implementation is complete and you want to integrate.

These remain the recommended default methodology. What is relaxed is OpenSpec's procedural ceremony, not Superpowers thinking.

Superpowers skills (TDD, debugging, verification) do not know this project's test conventions. When executing TDD tasks or writing tests, actively follow these project rules:

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

## Input

The user provides either a kebab-case change name or a description of what they want to record/build/fix. If a change name is omitted and one is needed, infer only when unambiguous; if multiple active changes exist and the target is unclear, ask which one.

### Change name convention

```text
<type>-<scope>-<outcome>
```

- Lowercase kebab-case only.
- Prefix with one of: `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, `chore`.
- Pick the type that describes the main intent:
  - `feature`: new user/script/tool-visible capability.
  - `fix`: incorrect behavior, crash, compile failure, or test failure.
  - `refactor`: structural boundary, responsibility, dependency, or module-shape change with compatible behavior.
  - `improve`: quality, diagnostics, performance, readability, or ergonomics improvement without a major structural boundary change.
  - `docs`: documentation/spec/process text.
  - `test`: test coverage, fixtures, harnesses, or test data.
  - `chore`: build, config, tooling, dependency, or workflow maintenance.
- Use `feature` rather than `feat` for OpenSpec readability, even though Git commits use `Feat`.
- Keep names outcome-focused. Good: `refactor-as-compilation-event-hook`, `improve-as-preprocessor-diagnostics`.

## Steps

1. **Classify the session**

   Decide whether this is:
   - explore / think only;
   - plan-only deliverable;
   - record-and-implement now;
   - continue an existing change;
   - archive / close.

   If an existing change may be involved, run:

   ```powershell
   openspec list --json
   ```

   If the target is ambiguous, ask which change to use. For pure exploration, stay read-leaning and do not create artifacts until there is a direction worth recording.

2. **Inspect or create the change**

   For an existing change:

   ```powershell
   openspec status --change "<name>" --json
   openspec instructions apply --change "<name>" --json
   ```

   Use the returned `contextFiles`; if none are returned, read `.openspec.yaml`, `proposal.md`, `tasks.md`, and other files under `openspec/changes/<name>/`.

   For a new change:

   ```powershell
   openspec new change "<name>"
   ```

   Do not hand-create `openspec/changes/<name>`; let the CLI track metadata.

3. **Check workspace before writing**

   Before editing any OpenSpec artifact or code, check the workspace context:

   ```powershell
   git rev-parse --show-toplevel
   git worktree list --porcelain
   ```

   Continue in the current workspace/main checkout by default. Only create, switch to, or continue work inside a git worktree when the user explicitly asks to create/use a worktree for that task (then use `superpowers:using-git-worktrees`). If the target is inside a submodule (e.g. `Plugins/UnrealEvent`), inspect submodule state (`git submodule status`) and follow `Documents/Guides/SubmoduleWorktreeWorkflow.md`.

4. **Explore or design when needed**

   Use `superpowers:brainstorming` when requirements, scope, or design choices are unclear: explore context, ask focused questions, compare approaches, recommend one. Capture stable decisions in OpenSpec artifacts (`proposal.md` / `design.md`), not separate ad-hoc plan files.

   For explore-only sessions, stop after giving findings, tradeoffs, and a recommended direction unless the user asks to record or implement.

5. **Record artifacts to match intent**

   Before writing specs, inspect existing capabilities:

   ```powershell
   openspec list --specs --json
   ```

   For any artifact you write, get current schema instructions and use the returned `outputPath`, `template`, `instruction`, `context`, and `rules`:

   ```powershell
   openspec instructions <artifact-id> --change "<name>" --json
   ```

   **Plan-only deliverables** — produce a ready-to-execute plan at `superpowers:writing-plans` quality: a file map (what each task creates / modifies / tests, exact paths), bite-sized tasks (file scope, expected change, exact verification command), and `<!-- TDD -->` / `<!-- Non-TDD -->` markers. Write `design.md` / `specs/*` when the change involves architecture or user-observable behavior. Then **stop cleanly without implementing** — note it can be implemented later on the same change.

   **Record-and-implement sessions** — start lean with `proposal.md` and `tasks.md`; add `design.md` or `specs/*` only when they clarify architecture, requirements, or user-observable behavior. There is no required dependency chain before touching code.

6. **Implement and update the record**

   Work through `tasks.md`, evolving OpenSpec artifacts alongside code.
   - Use `superpowers:test-driven-development` for TDD tasks, new behavior, bug fixes, and complex logic.
   - Use `superpowers:systematic-debugging` for unexpected failures or unclear runtime behavior.
   - If implementation reveals a design or requirement problem, rewrite the affected artifact and continue — overturning the initial plan is expected.
   - Mark `- [x]` only when the task is actually complete.
   - Keep `tasks.md` a clean checklist; put logs, notes, benchmark data, and investigation output in separate files under the change directory.

7. **Verify, finish, or archive**

   Use `superpowers:verification-before-completion` before claiming meaningful progress or completion. Validate only through project entry points:

   ```powershell
   Tools\RunBuild.ps1
   Tools\RunTests.ps1
   Tools\RunTestSuite.ps1
   ```

   At a stopping point, summarize the change name, what was recorded or implemented, verification status, and the next decision. If implementation is complete, optionally use `superpowers:finishing-a-development-branch`.

   When the user wants to close a finished change:

   ```powershell
   openspec archive "<name>"
   ```

   Surface incomplete tasks and `git status --short` for awareness, but do not block archive solely because the plan changed or tasks remain unchecked. The CLI handles directory moves, spec updates, and validation (`-y` to skip confirmation, `--skip-specs` for no-spec-impact changes). Do not use `openspec instructions archive`.

## Guardrails

- OpenSpec is a record, not a gate: do not block code work on having complete artifacts, and do not block recording on having code.
- Keep `tasks.md` a clean checklist; store background, notes, logs, and benchmark data as separate files in the change directory.
- Keep records and code in roughly the same change scope, but feel free to overturn and rewrite the plan as you learn.
- Archiving is a normal closing action via `openspec archive "<name>"` — not a verification gate. Use the CLI; never `openspec instructions archive`. Do not delete or rewrite OpenSpec history outside the current change.
- Default to working in the current session; use a delegated/subagent execution mode only when the user explicitly wants it.
- Review is conditional, not every session: when a review happens, use `superpowers:receiving-code-review` before implementing feedback (verify against this codebase, push back with evidence when wrong), and `superpowers:requesting-code-review` for major or shared changes when a reviewer workflow is available.
- Never run broad rollback commands such as `git checkout -- .` or `git reset --hard`. If rollback is requested, show `git status --short` and `git diff --stat`, ask which paths to revert, and revert only explicitly confirmed paths.
