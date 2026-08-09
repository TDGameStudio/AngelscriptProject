## Context

The plugin has five script-author bases: runtime `UScriptEngineSubsystem`, `UScriptGameInstanceSubsystem`, `UScriptWorldSubsystem`, and `UScriptLocalPlayerSubsystem`, plus editor-only `UScriptEditorSubsystem`. Each bridges selected UE lifecycle virtuals to Blueprint/AngelScript events and checks that the generated class belongs to the currently executing AngelScript engine before invoking script.

`UAngelscriptSubsystem` is different: it is an internal `UEngineSubsystem` that owns or adopts the primary `FAngelscriptEngine`. Generic reflection currently gives every eligible native subsystem, including this internal host, an AngelScript `Type::Get()` accessor. Script authors should instead create their own `UScript*Subsystem` classes.

## Goals / Non-Goals

**Goals:**

- Establish one safe lifecycle state machine for all tickable script subsystem bases.
- Let scripts express UE subsystem initialization dependencies without exposing a raw `FSubsystemCollectionBase` reference.
- Keep the runtime engine host out of the script-author API while preserving its C++ ownership and test access.
- Test the real UE subsystem-collection path, not only generated-class compilation or manually created instances.

**Non-Goals:**

- Renaming `UAngelscriptSubsystem` or changing its primary-engine ownership model.
- Making arbitrary native subsystem classes script-extensible.
- Adding `UScriptDynamicSubsystem` or changing module/plugin dynamic-subsystem lifecycle in this change.
- Replacing the existing `UScript*Subsystem` type names or the public `Get()` conventions.

## Decisions

### 1. Normalize lifecycle state before adding new surface

Each base SHALL call its UE `Super` lifecycle implementation and maintain an initialized flag that prevents Tick after deinitialization. `UScriptEngineSubsystem` will be brought in line with GameInstance, World, and Editor behavior. The exact callback ordering must be documented and covered by tests so a script callback can make reliable decisions about whether its subsystem is initialized.

This is preferred over a broad shared UObject base because UE subsystem bases have incompatible inheritance roots. Small shared C++ helper logic is acceptable only if it preserves each UE base's native lifecycle contract.

### 2. Expose dependency declaration as a narrow, initialization-scoped API

The implementation SHALL retain the active `FSubsystemCollectionBase` only while dispatching the script initialization callback. A script-visible helper accepts a validated `UClass` and invokes the matching UE dependency operation. Calls outside initialization, null classes, or classes outside the compatible subsystem family fail deterministically and do not mutate a collection.

This is preferred over binding `FSubsystemCollectionBase`: scripts need dependency declaration, not unrestricted collection access or a temporary native reference with unclear lifetime.

### 3. Treat `UAngelscriptSubsystem` as internal even though it is a native UCLASS

The generic native Subsystem `::Get()` registration SHALL exclude the plugin runtime host. The host remains callable from C++ through its existing static `Get()` and remains available to runtime tests. User-authored script subsystems retain preprocessor-generated `Get()` accessors, and other eligible native UE subsystem classes retain their existing accessors.

This is preferred over renaming the class because the issue is API exposure, not its internal C++ identity.

### 4. Test collection-owned lifecycle behavior by scope

Tests SHALL use UE-owned subsystem collections and suitable project fixtures for each scope. Assertions cover creation filtering, callback order, dependency resolution, concrete `Get()` retrieval, Tick while initialized, no Tick after deinitialization, and owner-scope isolation. Manual `NewObject` tests remain useful for hot reload dispatch but do not prove collection behavior.

## Risks / Trade-offs

- **Calling dependency helpers after initialization** → Reject it with a precise script diagnostic; tests cover rejection and prevent delayed collection mutation.
- **Hot reload changes a class while a collection owns an instance** → Preserve the existing owner-engine checks and add coverage around lifecycle dispatch rather than assuming manual-instance results apply.
- **Editor lifecycle has different engine availability and world context** → Keep its tests in the Editor layer and retain `FEditorScriptExecutionGuard` for script Tick.
- **Hiding the host `::Get()` breaks accidental user scripts** → This is an intentional API-boundary tightening; document `UScriptEngineSubsystem` as the supported replacement for project-global state.

## Migration Plan

1. Add failing lifecycle and accessor-boundary tests.
2. Normalize the five base implementations and add the scoped dependency helper.
3. Exclude the internal runtime host from native accessor emission while preserving all other native classes.
4. Update examples and Chinese-first subsystem/editor guidance.
5. Run focused automation prefixes and a plugin build, recording any unrelated build blocker separately.

## Open Questions

- Whether dependency declaration should be named `InitializeDependency`, `RequireSubsystem`, or be metadata-driven. The implementation phase will choose one public spelling after checking existing UE/AS naming conventions; the behavior contract is the important part.
- Whether `UScriptLocalPlayerSubsystem` needs a tickable variant. This change records the gap but does not add a new lifecycle family without a concrete UE-supported use case.
