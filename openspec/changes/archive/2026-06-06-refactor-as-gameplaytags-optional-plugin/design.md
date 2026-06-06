## Context

`Bind_FGameplayTag.cpp` currently owns both the script-visible GameplayTag bindings and the process-level cache used to prevent duplicate global variables. It also owns the explicit `AngelscriptRebindGameplayTagsToCurrentEngine()` path for tests and late engine attachment. That is a feature boundary, not a core runtime concern.

The runtime extension seam from `refactor-as-engine-extension-hooks` gives us the missing host mechanism. This change uses that seam to move GameplayTag support into an optional plugin so projects that do not use GameplayTags do not carry the runtime cost.

## Goals / Non-Goals

**Goals:**

1. Move GameplayTag bindings, cache state, and rebind behavior out of the core runtime module.
2. Make GameplayTag support optional at the plugin level.
3. Preserve existing GameplayTag behavior for enabled users, including deduped registration and replay to the current engine.
4. Keep the extension implementation reusable without depending on GAS.

**Non-Goals:**

- Redesigning GameplayTags themselves.
- Changing the meaning of GameplayTag names or lookup semantics.
- Replacing GAS functionality unrelated to GameplayTag binding.
- Removing the ability to rebind cached tags to a newly current engine.

## Decisions

### D1: Move GameplayTag support out of core runtime rather than keep it in `AngelscriptRuntime`

The existing code already behaves like an optional extension: it carries state, replays to the current engine, and is not fundamental to Angelscript compilation or engine lifecycle. Keeping it in runtime would continue to burden every user.

Alternatives considered:

- Keep the code in runtime but guard it behind a flag. Rejected because the core module would still own the logic and dependencies.
- Move it into GAS. Rejected because users may want GameplayTags without GAS.

### D2: Make GameplayTag support a plugin-level extension, not a GAS requirement

The plugin boundary is the right level of optionality. It lets the extension depend on `GameplayTags` directly and avoids making GAS a transitive requirement for projects that only want tag bindings.

Alternatives considered:

- Put the code in `AngelscriptGAS`. Rejected because the dependency surface is too wide for a GameplayTag-only feature.
- Split the support into a separate module inside the main Angelscript plugin. Rejected because the user explicitly wants optionality outside the core runtime.

### D3: Preserve the current cache-and-replay behavior inside the extension

The `TChunkedArray` and dedup lookup are still useful. They should move with the extension because they define the current user-visible behavior: first-time registration, duplicate suppression, and rebind to the active engine.

Alternatives considered:

- Recompute tags from source data on every engine attach. Rejected because it would duplicate work and lose the current low-overhead replay model.
- Delete the cache and force users to re-register manually. Rejected because that breaks the existing late-attach behavior.

### D4: Keep `AngelscriptGAS` free to focus on GAS-specific bindings

If GAS still needs GameplayTag-facing functionality later, it can depend on the optional plugin or expose its own narrow integration layer. But the core GameplayTag binding surface should not be locked to GAS ownership.

### D5: Name the standalone plugin `AngelscriptGameplayTags`

The plugin name uses Unreal's plural `GameplayTags` naming to match the engine module and the existing `AngelscriptGAS` naming style. `AngelscriptGAS` depends on both `Angelscript` and `AngelscriptGameplayTags`, while `AngelscriptGameplayTags` does not depend on GAS.

## Risks / Trade-offs

- [The optional plugin introduces one more module boundary] -> Mitigation: keep the plugin small and let it depend only on the runtime extension seam plus `GameplayTags`.
- [Projects may need to update plugin enablement] -> Mitigation: document the plugin as the new optional home for GameplayTag bindings and keep runtime failure mode obvious when the plugin is disabled.
- [GameplayTag replay bugs could appear during engine swap] -> Mitigation: preserve the existing cache/rebind tests and add coverage for engine reattachment.

## Migration Plan

1. Introduce the runtime extension seam if it is not already available.
2. Create the optional GameplayTag plugin and move the binding/cache/rebind logic into it.
3. Remove the GameplayTag-specific runtime binding code and its direct `GameplayTags` dependency from the core runtime module if no other runtime code needs it.
4. Add tests that prove the plugin remains optional and that GameplayTag replay still works when enabled.

## Resolved Questions

- The optional plugin lives under `Plugins/AngelscriptGameplayTags/` and has its own remote repository.
- The public replay API remains `AngelscriptRebindGameplayTagsToCurrentEngine()` for test and compatibility usage; extension attach establishes an engine scope before replay.
- The optional plugin owns its own `AngelscriptGameplayTagsTest` module and uses the `Angelscript.GameplayTags.*` automation prefix.
