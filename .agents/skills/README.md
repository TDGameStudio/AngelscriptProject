# AngelscriptProject Skills

`harness` is the project entrypoint. It selects a static route and loads only the matching leaf Skill/reference. It is not a daemon, workflow database, or custom agent loop.

Harness requires PowerShell 7.0 or later (`Core`). Import it once and run ordinary routes directly in the current PowerShell 7 process; Windows PowerShell 5.1 is not a supported Skill host. Child `pwsh` processes are intentional only for isolated tests, hooks or native fixtures, and Harness-managed Unreal workers.

```text
new feature / architecture / major behavior -> brainstorming (openspec/drafts/) -> approved design + confirmed carryover -> openspec-create-change (Change + talks/knowledge seeded) -> planning
                                            -> parked / abandoned draft (no Change)
explicit/discovered WorkspaceRoot -> Ready task -> lightweight local investigation -> verify -> close/archive -> ready to integrate
unattended continuation -> same workspace lifecycle; no repository mode or branch convention (defined once in harness/SKILL.md)
```

Workspace selection and unattended continuation never automatically integrate, push, publish, or remove a worktree. Integration, non-force push, and cleanup are separate user-requested operations.

## Harness command surface

```text
workspace.{status,list,new,bootstrap,verify,remove,activate,config.status,config.get,config.set}
git.{status,commit,integrate,push}
openspec.{init,doctor,status,instructions,validate,domain,spec,change,workflow,completion}
task.status
harness.{status,observe,evolution.status}
openspec.maintenance.status
ue.{status,engine.list,target.list,process.list,ubt.capabilities,ubt.invoke,build,test,commandlet,suite.list,suite.plan,suite.run,run.status,run.cancel}
```

Every `ue.*` route uses the selected Harness workspace, lazy-loads one maintained Unreal module, and rejects a mismatched caller-supplied root. Use `PlanOnly` before execution, `NoWait` for an asynchronous `RunId`, `ue.run.status` for one managed run, and `ue.process.list` for bounded machine-wide UE/UBT visibility. Progress remains explicitly unknown when a process cannot be correlated to trusted run-local evidence.

## Supporting Skills

- `harness` — context, command routing, result envelope, and progressive-loading rules.
- `workspace-lifecycle` — workspace identity, exact submodule bootstrap, local configuration, session activation, verification, and explicit cleanup.
- `git-operations` — scoped parent/submodule commits, verified linked-workspace integration, and explicit non-force push.
- `unreal-engine-develop` — UE 5.8 discovery, typed builds, Automation tests and suites, commandlets, UBT capabilities, process observation, progress, and explicit cancellation through `ue.*` routes.
- `systematic-debugging` — evidence-first diagnosis before fixes or replan.
- `test-driven-development` — RED/GREEN/refactor for behavior changes.
- `code-review` — reviewer stance for a fixed-snapshot Review, only after an explicit user or external-agent request; coordinator intake and triage stay in `harness/references/review.md`.
- `angelscript-test-guide` — project C++/CQTest/inline AngelScript testing patterns.
- `hazelight-update-audit` — upstream comparison and adoption decisions.

## OpenSpec lifecycle Skills

OpenSpec is used only when the user explicitly names a Change or the accepted work requires one. Unattended continuation may carry that work forward but does not create a second lifecycle, and it never opens `brainstorming`. The portable Rust CLI provides deterministic record primitives; Harness owns orchestration, evidence-gated Replan, and explicit Review intake.

For OpenSpec-scoped work, an accepted exploration handoff is not execution state: resolve the canonical active Change and Ready Task DAG in the selected workspace before implementation mutation. Drafts under `openspec/drafts/` are working records owned by `brainstorming`; they carry no task state and are not scanned by Harness or validated by the CLI.

New Change IDs use `<domain>/<type>-<scope>-<outcome>` with `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, or `chore`; use `feature`, not `feat`. The OpenSpec record-schema reference owns the full distinction and immutable-archive boundary.

- `openspec` — binary/package contract, command lookup, and lifecycle routing.
- `brainstorming` — explore an idea in grilling rounds and record everything under `openspec/drafts/<domain>/<topic>/` (git-ignored, local). Three entry modes share one layout: `research` (findings and diagrams), `proposal` (write the proposal first, then grill around it), `design` (required before a new feature, architecture refactor, or major behavior change, and whenever a user-owned decision is unconfirmed). It grills naming, ends the round sequence with a user-confirmed carryover list, and leaves the draft `designed`, `parked`, or `abandoned`. `design` mode is never reopened for a Change that already exists; `research` drafts may be opened at any time.
- `openspec-create-change` — create the Change from a designed draft and seed its attachments: draft copies, the confirmed talks and knowledge candidates, INDEX. The only route that runs `change create` for major work.
- `openspec-continue-change` — create the next missing artifact.
- `openspec-update-change` — revise existing artifacts and apply an evidence-gated replan.
- `openspec-apply-change` — implement Ready Task DAG nodes.
- `openspec-verify-change` — completion verification and explicitly requested fixed-snapshot Review input.
- `openspec-sync-specs` — agent-driven durable-spec merge.
- `openspec-archive-change` — explicit closure policy plus deterministic archive primitive.

Record schemas are focused references under `openspec/references/`, not an independently triggered Skill. Task-local technical uncertainty remains in `openspec-apply-change`; material root-cause history uses the implementation-issue reference, and reusable learning follows the capability-knowledge promotion reference.

Durable specifications use progressive Scenario Cards defined in `.agents/skills/openspec/references/specs.md`. For every new or modified `GIVEN`, `WHEN`, `THEN`, `AND`, or `BUT`, actively evaluate what helps a zero-context reader and prefer the smallest useful combination of quoted notes, prose, ordered or unordered lists, examples, and tables in an immediately indented clause-owned detail block. Every form remains optional and is omitted when it adds no durable information; cards carry no Task state, and specs never acquire checkboxes, a DAG, Ready state, file ownership, or execution state.

## Other leaves

- Use `visual-explain` proactively when three or more relationships, a sequence/state transition, hierarchy/layout, or a decision structure is materially clearer visually. Skip trivial one-step work. Other specialized work remains under `external/` and `web/`.

## Maintenance

- Skills, references, and maintained OpenSpec records are English; only files explicitly named with exact uppercase `_ZH` remain temporarily exempt.
- Validate every changed Skill with the system `quick_validate.py` and execute changed scripts against controlled inputs.
- Root `Tools` PowerShell entrypoints are legacy deletion candidates and are not the live Harness command surface. `Tools/openspec` is the intentional tracked-source exception: commit/tag that submodule first, while runtime uses `.agents/skills/openspec/bin/openspec.exe`. For each release, the parent records only one final accepted package commit containing the gitlink, manifest/docs, and bundled EXE; never stage or commit candidate EXE builds.
- Keep entry Skills short. Move conditional schemas or procedures to a linked reference and load only the one needed.
