# AngelscriptProject Skills

`hardness` is the project entrypoint. It selects a static route and loads only the matching leaf Skill/reference. It is not a daemon, workflow database, or custom agent loop.

The prepared harness requires PowerShell 7.0 or later (`Core`) and uses `pwsh.exe`; Windows PowerShell 5.1 is not a supported Skill host.

```text
new feature / architecture / major behavior -> deep Explore -> decision-complete handoff -> create Change -> planning
explicit/discovered WorkspaceRoot -> Ready task -> lightweight local investigation -> verify -> close/archive -> ready to integrate
Codex /goal -> external unattended continuation of the same workspace lifecycle; no repository mode or branch convention
```

Workspace selection and Codex `/goal` continuation never automatically integrate, push, publish, or remove a worktree. Integration, non-force push, and cleanup are separate user-requested operations.

## Hardness command surface

```text
workspace.{status,list,new,bootstrap,verify,remove,activate,config.status,config.get,config.set}
git.{status,commit,integrate,push}
openspec.{init,doctor,status,instructions,validate,domain,spec,change,workflow,completion}
task.status
hardness.{status,observe,evolution.status}
openspec.maintenance.status
```

The current core publishes no `ue.*` or `toolchain.check` route.

## Supporting Skills

- `hardness` — context, command routing, result envelope, and progressive-loading rules.
- `workspace-lifecycle` — workspace identity, exact submodule bootstrap, local configuration, session activation, verification, and explicit cleanup.
- `git-operations` — scoped parent/submodule commits, reviewed local integration, and explicit non-force push.
- `systematic-debugging` — evidence-first diagnosis before fixes or replan.
- `test-driven-development` — RED/GREEN/refactor for behavior changes.
- `code-review/code-reviewer` — fixed-snapshot Review only after an explicit user or external-agent request.
- `angelscript-test-guide` — project C++/CQTest/inline AngelScript testing patterns.
- `hazelight-update-audit` — upstream comparison and adoption decisions.

## OpenSpec lifecycle Skills

OpenSpec is used only when the user explicitly names a Change or the accepted work requires one. A Codex `/goal` may continue that work unattended but does not create a second lifecycle. The portable Rust CLI provides deterministic record primitives; Hardness owns orchestration, evidence-gated Replan, and explicit Review intake.

For OpenSpec-scoped work, an accepted exploration handoff is not execution state: resolve the canonical active Change and Ready Task DAG in the selected workspace before implementation mutation.

- `openspec` — binary/package contract, command lookup, and lifecycle routing.
- `openspec-explore` — deep read-only discovery before creating a new feature, architecture refactor, or major behavior-change Change; it produces a decision-complete handoff and is never invoked after target Change creation.
- `openspec-continue-change` — create the next missing artifact.
- `openspec-update-change` — revise existing artifacts and apply an evidence-gated replan.
- `openspec-apply-change` — implement Ready Task DAG nodes.
- `openspec-verify-change` — completion verification and explicitly requested fixed-snapshot Review input.
- `openspec-sync-specs` — agent-driven durable-spec merge.
- `openspec-archive-change` — explicit closure policy plus deterministic archive primitive.

Record schemas are focused references under `openspec/references/`, not an independently triggered Skill. Task-local technical uncertainty remains in `openspec-apply-change`; material root-cause history uses the implementation-issue reference, and reusable learning follows the capability-knowledge promotion reference.

## Other leaves

- `unreal-engine-develop` remains an existing standalone Skill, but the prepared Hardness core does not route it yet. UE integration and replacement of legacy root `Tools` PowerShell wrappers require a separate planned and verified change.
- Use `visual-explain` proactively when three or more relationships, a sequence/state transition, hierarchy/layout, or a decision structure is materially clearer visually. Skip trivial one-step work. Other specialized work remains under `external/` and `web/`.

## Maintenance

- Skills, references, and maintained OpenSpec records are English; only files explicitly named with exact uppercase `_ZH` remain temporarily exempt.
- Validate every changed Skill with the system `quick_validate.py` and execute changed scripts against controlled inputs.
- Root `Tools` PowerShell entrypoints are legacy deletion candidates and are not the live Hardness command surface. `Tools/openspec` is the intentional tracked-source exception: commit/tag that submodule first, while runtime uses `.agents/skills/openspec/bin/openspec.exe`. For each release, the parent records only one final accepted package commit containing the gitlink, manifest/docs, and bundled EXE; never stage or commit candidate EXE builds.
- Keep entry Skills short. Move conditional schemas or procedures to a linked reference and load only the one needed.
