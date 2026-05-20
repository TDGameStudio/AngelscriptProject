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

<!-- SUPERPOWER-BEGIN: openspec-artifact-awareness -->
Superpowers skills (brainstorming, writing-plans, TDD, etc.) do not know about OpenSpec. When invoking their thinking methods, you must supply the following context so they produce output compatible with the OpenSpec artifact structure.

### Artifact structure and dependency chain

```
proposal.md ──┬──► design.md ──┐
              │                 ├──► tasks.md
              └──► specs/*.md ──┘
```

`applyRequires: [tasks]` — apply cannot start until `tasks.md` exists.

### What each artifact must contain

**`proposal.md`** — Why this change exists
- **Why**: Problem or opportunity (1-2 sentences). Why now?
- **What Changes**: Concrete list of new/modified/removed capabilities. Mark breaking changes with `**BREAKING**`.
- **Capabilities**: New and modified capability names (kebab-case). Each new capability creates `specs/<name>/spec.md`. Each modified capability references an existing spec.
- **Impact**: Affected code paths, APIs, dependencies, systems.

**`specs/<name>/spec.md`** — User-observable requirements per capability
- Acceptance criteria or behavior scenarios (Given/When/Then or equivalent).
- Only externally observable behavior — no implementation details.
- If a spec involves testable behavior in this Unreal project, include a `## Testing Requirements` section declaring:
  - Target test layer (from `Documents/Guides/TestConventions.md` layer matrix: Runtime CppTests / Editor / Native Core / Runtime Integration / UE Functional / Bindings CQTest / Learning)
  - Expected Automation prefix (e.g., `Angelscript.TestModule.<Theme>.*`)
  - Recommended helper/harness (e.g., `FAngelscriptTestWorld`, `FCoverageModuleScope`, `AngelscriptNativeTestSupport.h`)
  - Verification entry point command (from `Documents/Guides/Test.md` standard entries)

**`design.md`** — Technical approach
- Current state, goals/non-goals, technical approach, tradeoffs, risks.
- Architecture and data flow decisions that inform task decomposition.
- In this Unreal project, reference existing module structure from root `AGENTS.md` Architecture Overview when relevant.

**`tasks.md`** — Executable implementation plan (the ONLY plan)
- Checkbox tasks (`- [ ]`) with TDD/Non-TDD markers.
- Each task: file scope, expected change, verification command.
- Verification commands must use project unified runners (`Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`). Never hand-write UBT/Build.bat/RunUBT.bat commands.
- TDD tasks involving tests must follow project test conventions:
  - New test files start with `Angelscript` prefix.
  - Choose test layer by answering: needs `FAngelscriptEngine`? needs real `UObject`/`World`/`Actor`? is Editor-only?
  - Use existing helpers: `FAngelscriptTestWorld` for actor/component/lifecycle, `FCoverageModuleScope` for bindings coverage, `AngelscriptNativeTestSupport.h` for pure AS SDK.
  - Automation prefix follows theme-first naming for functional tests (`Angelscript.TestModule.<Theme>.*`) and layer-first for native/learning.
  - Templates in `Plugins/Angelscript/Source/AngelscriptTest/Template/` are recommended starting points.

### Project docs to read when generating artifacts

- `Documents/Guides/TestConventions.md` — test layer matrix, naming rules, standard flow
- `Documents/Guides/Test.md` — test entry points, CQTest usage, harness patterns, templates
- `Documents/Guides/Build.md` — build entry points and constraints
- `Plugins/Angelscript/AGENTS.md` — plugin-internal test layering rules
<!-- SUPERPOWER-END: openspec-artifact-awareness -->

## Input

The user should provide either a kebab-case change name or a description of what they want to build or fix. If the request is unclear, ask what change they want and stop until they answer.

### Change name convention

OpenSpec change names in this project should use:

```text
<type>-<scope>-<outcome>
```

- Use lowercase kebab-case only.
- Prefix every new change with one of: `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, `chore`.
- Prefer the type that describes the main intent, not every artifact touched:
  - `feature`: new user/script/tool-visible capability.
  - `fix`: incorrect behavior, crash, compile failure, or test failure.
  - `refactor`: structural boundary, responsibility, dependency, or module-shape change with compatible behavior.
  - `improve`: quality, diagnostics, performance, readability, or ergonomics improvement without a major structural boundary change.
  - `docs`: documentation/spec/process text.
  - `test`: test coverage, fixtures, harnesses, or test data.
  - `chore`: build, config, tooling, dependency, or workflow maintenance.
- Use `feature` rather than `feat` for OpenSpec readability, even though Git commits use `Feat`.
- Keep names outcome-focused and avoid implementation-file inventories. Good examples: `refactor-as-compilation-event-hook`, `improve-as-preprocessor-diagnostics`, `feature-as-blueprint-impact-commandlet`.

## Steps

1. **Clarify and confirm the design**

   Follow the `propose-thinking-flow` adapter block. Do not create files until the user has confirmed the design direction.

2. **Create or continue the OpenSpec change**

<!-- SUPERPOWER-BEGIN: openspec-cli-compat -->
OpenSpec CLI metadata is authoritative. Do not create a bare `openspec/changes/<name>` directory by hand.

Before writing `proposal.md` Capabilities, check existing specs to correctly classify new vs modified:

   ```powershell
   openspec list --specs --json
   ```

If specs exist, capabilities matching existing spec names are `Modified Capabilities`; all others are `New Capabilities`. Do not mark an existing spec as new or omit a modified spec.

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

3. **Generate artifacts until apply-ready**

   Continue in dependency order until every artifact required by `applyRequires` is complete. Re-run `openspec status --change "<name>" --json` after each artifact.

   Codex on Windows note: OpenSpec CLI creates and tracks the change metadata, but the agent still writes artifact files. If the local `apply_patch` command resolves to a `.bat` wrapper, PowerShell may corrupt multi-line patch arguments or pipelines and report errors such as "requires a UTF-8 PATCH argument" or mismatched first/last patch lines. Treat this as a patch transport issue, not an OpenSpec CLI failure. Keep using patch-based edits; in Codex, call the underlying `codex.exe --codex-run-as-apply-patch` with the patch string, or use the platform-native patch tool when available. Do not switch to `cat`/Python file-writing workarounds for artifacts.

4. **Use `tasks.md` as the implementation plan**

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

5. **Validate artifacts before finishing**

   Run structural validation on the completed change:

   ```powershell
   openspec validate "<name>" --strict --json
   ```

   If validation reports errors (missing required sections, malformed structure, unresolved capability references), fix the affected artifacts before proceeding. Warnings may be reported to the user without blocking.

6. **Finish propose**

   Show the change name, artifact paths, and current OpenSpec status. Tell the user they may review and manually edit `proposal.md`, `design.md`, `specs/*`, or `tasks.md` before apply; run the `openspec-apply-change` skill (or `/opsx:apply <name>`) when ready.

## Guardrails

- Propose must not edit application code.
- Keep all generated artifacts under OpenSpec CLI output paths.
- If a user asks to implement while still proposing, explain that implementation starts with the `openspec-apply-change` skill (or `/opsx:apply`) after artifacts are ready.
