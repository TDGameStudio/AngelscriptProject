# AngelscriptProject Skills

`hardness` is the project entrypoint. It selects a static route and loads only the matching leaf Skill/reference. It is not a daemon, workflow database, or custom agent loop.

The prepared harness requires PowerShell 7.0 or later (`Core`) and uses `pwsh.exe`; Windows PowerShell 5.1 is not a supported Skill host.

```text
new feature / architecture / major behavior -> deep Explore -> decision-complete handoff -> create Change -> planning
Goal mode    -> .worktrees/<goal> on goal/<goal> -> Ready task -> local exploration -> verify -> impact disposition -> ready to integrate
Current mode -> current workspace -> protect existing changes -> the same lifecycle in place
```

Neither mode automatically merges, pushes, publishes, or removes a worktree.

## Hardness command surface

```text
workspace.{status,new,bootstrap,verify,finish,remove}
openspec.{init,doctor,status,instructions,validate,domain,spec,change,workflow,completion}
task.status
```

The current core publishes no `ue.*` or `toolchain.check` route.

## Supporting Skills

- `hardness` — context, command routing, result envelope, and progressive-loading rules.
- `git-workflow` (`using-git-worktrees`) — safe workspace lifecycle and submodule ordering.
- `systematic-debugging` — evidence-first diagnosis before fixes or Replan.
- `test-driven-development` — RED/GREEN/refactor for behavior changes.
- `code-review/code-reviewer` — fixed-snapshot Incident, impact-gated Final, or explicit External Review.
- `angelscript-test-guide` — project C++/CQTest/inline AngelScript testing patterns.
- `hazelight-update-audit` — upstream comparison and adoption decisions.

## OpenSpec lifecycle Skills

OpenSpec is used only when the user/Goal explicitly names or owns an OpenSpec change. The portable Rust CLI provides deterministic record primitives; Hardness owns orchestration and Replan/Review policy.

For OpenSpec-scoped work, an accepted exploration handoff is not execution state: resolve the canonical active Change and Ready Task DAG before implementation mutation in either Current or Goal mode.

- `openspec` — binary/package contract, command lookup, and lifecycle routing.
- `openspec-explore` — deep read-only discovery before creating a new feature, architecture refactor, or major behavior-change Change; it produces a decision-complete handoff and is never invoked after target Change creation.
- `openspec-continue-change` — create the next missing artifact.
- `openspec-update-change` — revise current artifacts and apply an evidence-gated Replan.
- `openspec-apply-change` — implement Ready Task DAG nodes.
- `openspec-verify-change` — fixed-snapshot verification and Review Gate input.
- `openspec-sync-specs` — agent-driven durable-spec merge.
- `openspec-archive-change` — explicit closure policy plus deterministic archive primitive.

Record schemas are focused references under `openspec/references/`, not an independently triggered Skill. Task-local technical uncertainty remains in `openspec-apply-change`; material root-cause history uses the implementation-issue reference, and reusable learning follows the capability-knowledge promotion reference.

## Other leaves

- `unreal-engine-develop` remains an existing standalone Skill, but the current Hardness core does not route it. UE integration and public wrapper migration require a separate planned and verified change.
- Presentation and specialized work remain under `visual-explain`, `external/`, and `web/`. Read their `SKILL.md` only when the request matches.

## Maintenance

- Skills, references, and maintained OpenSpec records are English; only files explicitly named with exact uppercase `_ZH` remain temporarily exempt.
- Validate every changed Skill with the system `quick_validate.py` and execute changed scripts against controlled inputs.
- `Tools/openspec` is a submodule: commit/tag it first. For each release, the parent records only one final accepted package commit containing the gitlink, manifest/docs, and bundled `openspec.exe`; never stage or commit candidate EXE builds.
- Keep entry Skills short. Move conditional schemas or procedures to a linked reference and load only the one needed.
