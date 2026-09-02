# AngelscriptProject Skills

`hardness` is the project entrypoint. It selects a static route and loads only the matching leaf Skill/reference. It is not a daemon, workflow database, or custom agent loop.

The prepared harness requires PowerShell 7.0 or later (`Core`) and uses `pwsh.exe`; Windows PowerShell 5.1 is not a supported Skill host.

```text
Goal mode    -> .worktrees/<goal> on goal/<goal> -> implement -> verify -> review -> ready to integrate
Current mode -> current workspace -> protect existing changes -> implement and verify in place
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
- `code-review/code-reviewer` — fixed-snapshot five-dimension review.
- `angelscript-test-guide` — project C++/CQTest/inline AngelScript testing patterns.
- `hazelight-update-audit` — upstream comparison and adoption decisions.

## OpenSpec lifecycle Skills

OpenSpec is used only when the user/Goal explicitly names or owns an OpenSpec change. The portable Rust CLI provides deterministic record primitives; Hardness owns orchestration and Replan/Review policy.

- `openspec` — binary/package contract, command lookup, and lifecycle routing.
- `openspec-explore` — read-only investigation of unclear work.
- `openspec-continue-change` — create the next missing artifact.
- `openspec-update-change` — revise current artifacts and apply an evidence-gated Replan.
- `openspec-apply-change` — implement Ready Task DAG nodes.
- `openspec-verify-change` — fixed-snapshot verification and Review Gate input.
- `openspec-sync-specs` — agent-driven durable-spec merge.
- `openspec-archive-change` — explicit closure policy plus deterministic archive primitive.

Record schemas are references under `openspec/references/`, not an independently triggered Skill.

## Other leaves

- `unreal-engine-develop` remains an existing standalone Skill, but the current Hardness core does not route it. UE integration and public wrapper migration require a separate planned and verified change.
- Presentation and specialized work remain under `visual-explain`, `external/`, and `web/`. Read their `SKILL.md` only when the request matches.

## Maintenance

- Skills, references, and maintained OpenSpec records are English; only files explicitly named with exact uppercase `_ZH` remain temporarily exempt.
- Validate every changed Skill with the system `quick_validate.py` and execute changed scripts against controlled inputs.
- `Tools/openspec` is a submodule: commit/tag it first. For each release, the parent records only one final accepted package commit containing the gitlink, manifest/docs, and bundled `openspec.exe`; never stage or commit candidate EXE builds.
- Keep entry Skills short. Move conditional schemas or procedures to a linked reference and load only the one needed.
