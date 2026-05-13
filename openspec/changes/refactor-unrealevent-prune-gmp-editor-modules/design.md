## Context

`Plugins/UnrealEvent` was bootstrapped from a GMP source snapshot and is tracked as a standalone submodule. The plugin descriptor now declares only the `GMP` runtime module; the former GMP editor-side modules `GMPEditor`, `MessageTags`, and `MessageTagsEditor` are no longer loaded through `UnrealEvent.uplugin`.

The source directories remain under `Plugins/UnrealEvent/Source/GMPEditor/` because they may still be useful as implementation reference while the UnrealEvent runtime API is being designed. This change plans the later cleanup boundary rather than deleting that reference source immediately.

## Goals / Non-Goals

**Goals:**

- Physically remove or archive the disabled `GMPEditor`, `MessageTags`, and `MessageTagsEditor` module source from the `UnrealEvent` plugin after auditing references.
- Keep `UnrealEvent.uplugin` focused on the runtime `GMP` module unless a future change deliberately introduces UnrealEvent-specific editor modules.
- Remove editor-only plugin dependencies that exist only to support the disabled GMP editor modules.
- Verify that the host project still discovers and builds `UnrealEvent` after the cleanup.

**Non-Goals:**

- Do not remove those source directories as part of the current descriptor-only commit.
- Do not redesign GMP runtime dispatch, serializer, protobuf, HTTP, Python console, or ThirdParty code in this change.
- Do not add replacement editor tooling, message tag authoring UI, or UnrealEvent-specific graph pins.
- Do not change `AngelscriptRuntime` or `AngelscriptEditor` behavior.

## Decisions

- **Remove from descriptor first, delete source later.** The descriptor has already stopped loading the modules, which reduces build surface immediately while leaving source available for reference. Deleting files is deferred until the team confirms no reference value remains.
- **Treat `MessageTags` as part of the editor-pruning scope.** Although its name does not include `Editor`, it lives under `Source/GMPEditor`, is declared as `UncookedOnly`, and primarily supports the editor-side GMP tag workflow.
- **Keep runtime `GMP` dependencies until audited separately.** `StructUtils` and `PythonScriptPlugin` are still referenced by `Source/GMP/GMP.Build.cs`, so this cleanup only removes dependencies proven to belong to the disabled editor/tag modules.
- **Use OpenSpec tasks as the execution checklist.** The physical removal will be tracked in this change's `tasks.md`; no legacy `Documents/Plans` file should be created.

## Risks / Trade-offs

- **Hidden runtime reference to MessageTags** -> Run a repository-wide search before deletion and keep any genuinely required runtime data model in `Source/GMP` or a future UnrealEvent runtime module.
- **Loss of useful reference code** -> Archive decisions should happen before deletion; if retained externally, document the reference location or rely on git history after the removal commit.
- **Descriptor and Build.cs drift** -> Validate JSON, inspect `.uplugin` plugin dependency entries, and run the unified build after cleanup.
- **Dirty host repository state** -> Stage only `Plugins/UnrealEvent` gitlink and this OpenSpec change in the host repository.

## Migration Plan

- Keep the current descriptor-only commit as the first, low-risk step.
- Audit all references to `GMPEditor`, `MessageTags`, and `MessageTagsEditor` from runtime source, descriptors, docs, config, and build files.
- Remove or archive the three module directories only after confirming they are not needed for runtime compilation or near-term reference.
- Remove obsolete editor plugin dependencies from `UnrealEvent.uplugin` and verify the descriptor remains valid JSON.
- Run the project build through `Tools\RunBuild.ps1` and validate this OpenSpec change before committing the cleanup.

## Open Questions

- Should removed GMP editor/tag source rely only on git history, or should a separate external reference copy be retained before deletion?
- Will UnrealEvent later need its own editor module, or should the plugin stay runtime-only until a concrete tool requirement appears?
