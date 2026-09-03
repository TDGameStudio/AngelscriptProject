# Harness Identity Cutover

## Context

On 2026-09-04 the user recognized that the framework name `Hardness` was a vocabulary mistake: the system is a harness, not a measure of hardness. The correction was explicitly classified as a major mistake to fix immediately in the main workspace through one fast OpenSpec Change.

## Evidence

- The live framework exposes the mistaken word in Skill/module paths, PowerShell symbols, three route names, environment variables, AgentConfig schema, local evidence roots, Unreal drive-registry paths, OpenSpec domains/specs, tests, hooks, and documentation.
- Historical OpenSpec archives and pinned source/release text also contain the old word, but rewriting those records would destroy provenance or mutate independent source history.
- Machine-local AgentConfig and Unreal registry data need bounded migration so the public break does not strand a valid selected workspace or drive assignment.

## Considered options

1. Keep `Hardness` as an internal codename. Rejected because public and internal identities would continue diverging and future code would keep propagating the mistake.
2. Add permanent aliases from Hardness to Harness. Rejected because the user selected a direct cutover and the framework has not established a compatibility obligation for the mistaken public API.
3. Rename live code and explicitly migrate only persisted data. Accepted because it produces one coherent identity while preserving valid local state and immutable evidence.

## Settled decision

Use `Harness` everywhere in the maintained live surface. Remove old public imports, functions, routes, environment variables, and default commit scopes. Move live OpenSpec identity with the CLI and retain its generated aliases, but do not rewrite immutable archives. Migrate `[Hardness]` v2 only through `workspace.bootstrap`; reject it during normal operations until repaired. Move the Unreal drive registry only during the first real UE operation under the normal registry lock; `PlanOnly` must not mutate it.

New evidence uses `Saved/Harness`, `%LOCALAPPDATA%/TDGameStudio/Harness`, and `harness-*` schemas. Readers may retain narrow old-name constants solely to discover historical Saved/registry/evaluation inputs. Such constants are migration inputs, not public aliases.

## Consequences and flip condition

The cutover intentionally breaks callers that still import `Hardness.psd1`, invoke `*-Hardness*`, use `hardness.*`, or depend on `HARDNESS_*`. Repository tests must prove those names are absent. A future compatibility layer would require a separate user-approved Change with a demonstrated external consumer; it is not inferred from this refactor.

## Exclusions

- No edits to immutable `openspec/archive/changes/hardness/**` records.
- No edits to `Documents/`, `Reference/`, ignored historical `Saved/Hardness`, or unrelated dirty files.
- No update, tag, release, or publication of `Tools/openspec`.
- No Unreal build repair; one normal Smoke launch is the real-engine acceptance boundary.
- No broad deletion or resurrection of legacy root Tools wrappers.

## Canonical mapping

| Concern | Canonical owner after cutover |
|---|---|
| Framework router and evolution | `.agents/skills/harness/`; `openspec/specs/harness/core/` |
| Workspace identity and config migration | `.agents/skills/workspace-lifecycle/`; `openspec/specs/harness/workspace/` |
| Exact Git operations | `.agents/skills/git-operations/`; `openspec/specs/harness/git/` |
| Unreal execution and registry migration | `.agents/skills/unreal-engine-develop/`; `openspec/specs/harness/unreal/` |
| Active implementation record | `openspec/changes/harness/rename-hardness-to-harness/` after the domain move |

## Sources

- User instruction on 2026-09-04 to rename Hardness to Harness as an immediate major correction.
- Accepted decision-complete implementation plan in the same conversation.
- Live repository identifier audit performed before Change creation.
