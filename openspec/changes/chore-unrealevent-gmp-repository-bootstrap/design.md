## Context

The memo `Documents/UnrealEvent_GMP核心迁移备忘.md` defines `UnrealEvent` as a GMP-core migration path, not as a continuation of the old lightweight `D:\Workspace\UnrealEvent\Plugins\UnrealEvent` prototype. The local GMP source is available at `D:\Workspace\UnrealEvent\Plugins\GenericMessagePlugin`, with upstream remote `git@github.com:wangjieest/GenericMessagePlugin.git` and observed commit `421f572`.

`AngelscriptProject` already consumes plugin deliverables as submodules under `Plugins/`, so `UnrealEvent` should follow the same boundary as `Plugins/Angelscript` and `Plugins/AngelscriptGAS`.

## Goals / Non-Goals

**Goals:**

- Create a fresh `UnrealEventPlugin` repository from the GMP source snapshot without importing GMP git history.
- Add the new repository to `AngelscriptProject` as `Plugins/UnrealEvent`.
- Preserve Apache 2.0 license text and clear GMP attribution.
- Keep the bootstrap mechanically small so later changes can make deliberate retain/remove/refactor decisions.

**Non-Goals:**

- Do not design or implement the UnrealEvent runtime API.
- Do not prune GMP editor, script, serializer, MessageTags, or ThirdParty code in this change.
- Do not import the old lightweight `D:\Workspace\UnrealEvent\Plugins\UnrealEvent` prototype as source of truth.
- Do not add AngelScript bindings, Blueprint nodes, or tests for event dispatch behavior.

## Decisions

- **Start from a GMP snapshot with a fresh initial commit.** This gives the new repository the full source baseline needed for later裁剪 while satisfying the requirement not to inherit GMP git history. Alternative considered: adding GMP as a submodule, rejected because it keeps the old repository identity and complicates later rewrite boundaries.
- **Use `TDGameStudio/UnrealEventPlugin` as the remote.** This avoids making the repository name look like an Epic-owned engine feature while keeping the plugin identity as `UnrealEvent`.
- **Add `Plugins/UnrealEvent` as a host submodule.** This matches existing plugin delivery practice and keeps `UnrealEventRuntime` independent from `AngelscriptRuntime`.
- **Keep license attribution in the standalone repo.** Because the bootstrap copies source from Apache-licensed GMP, the new repo must include the Apache 2.0 license and a notice describing the GMP-derived origin.
- **Defer pruning.** The first commit may include GMP modules that later changes remove; the important boundary here is repository/submodule ownership, not final runtime shape.

## Risks / Trade-offs

- **Large initial snapshot** -> Exclude generated artifacts (`Binaries/`, `Intermediate/`, `Saved/`, IDE folders, caches) and keep only source/config/docs/license material.
- **UBT discovery failures from partial rename** -> Rename the plugin descriptor and module identities only as far as needed for a coherent bootstrap; record any remaining compile issues for the next change.
- **License ambiguity** -> Include explicit notice text and original Apache license before pushing the standalone repo.
- **Host dirty state** -> Execute in an isolated worktree and do not revert unrelated main-worktree changes.

## Migration Plan

- Create the OpenSpec artifacts for this change.
- Create a new local standalone repository outside the host worktree from the GMP source snapshot.
- Commit the standalone repository with a fresh initial commit and set `origin` to `git@github.com:TDGameStudio/UnrealEventPlugin.git`.
- Add the standalone repository as the `Plugins/UnrealEvent` submodule in `AngelscriptProject`.
- Enable the plugin in `AngelscriptProject.uproject` after the plugin descriptor is coherent.
- Validate OpenSpec structure, git metadata, submodule metadata, and host build discovery.

## Open Questions

- None for this bootstrap. Runtime feature retention and pruning decisions belong to follow-up OpenSpec changes.
