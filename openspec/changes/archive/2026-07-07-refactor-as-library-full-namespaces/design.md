## Context

`FAngelscriptFunctionSignature::GetScriptNamespaceForClass()` currently derives Blueprint library namespaces through a special path: class-level `ScriptName` metadata can replace the namespace, then configured prefix and suffix lists can shorten the result. That means reflected library calls can appear under names that do not match the underlying UClass or the registered Angelscript type.

Ordinary UClass binding already has a stable naming boundary: `FAngelscriptType::GetBoundClassName()` uses the C++ prefix plus class name, and registered AS type names are then used throughout type binding. The new library rule should reuse that boundary rather than maintain a second namespace policy for Blueprint function libraries.

Subsystem helpers are the main known special case. `Bind_Subsystems.cpp` manually exposes helpers under `Subsystem::`, and the preprocessor emits generated subsystem `Get()` wrappers that call `Subsystem::...` or `EditorSubsystem::...`. These helpers need to move to the full library namespaces so generated code and user code follow the same rule.

## Goals / Non-Goals

**Goals:**

- Make reflected Blueprint library namespaces match the registered Angelscript type name.
- Remove config-driven namespace shortening and class-level `ScriptName` namespace substitution for Blueprint libraries.
- Migrate subsystem helper APIs and generated subsystem accessors to full library namespaces.
- Keep the change explicit and breaking rather than preserving short-name compatibility aliases.

**Non-Goals:**

- Do not remove function-level `ScriptName` behavior for individual UFUNCTION names, events, properties, mixins, or explicit method renames.
- Do not redesign all manually chosen utility namespaces in the plugin, such as math/vector/static utility namespaces that are not produced by Blueprint library shortening.
- Do not add a migration compatibility toggle.

## Decisions

- Use `FAngelscriptType::GetAngelscriptTypeName()` as the Blueprint library namespace source. This matches ordinary Blueprint/UClass behavior and avoids inventing a second definition of "full C++ name".
- Remove namespace trim settings from `UAngelscriptSettings` and `FAngelscriptEngine`. Keeping disabled settings would suggest an unsupported compatibility path and would still add AI-discoverable noise.
- Treat subsystem helpers as part of this change because their current `Subsystem::` and `EditorSubsystem::` names are short helper namespaces, and generated subsystem accessors depend on them.
- Preserve type/static namespaces that are intentionally authored as the script API rather than produced by Blueprint library namespace policy. This keeps the change focused on the ambiguous reflection-derived library names.

## Risks / Trade-offs

- Existing scripts that call shortened namespaces will fail to compile → mitigate with focused tests, example updates, and documentation that names the new full namespace form.
- Removing settings may break project config that still contains the old keys → Unreal should ignore stale config keys, and the change should document that they no longer affect binding.
- Some tests currently validate per-engine isolation for namespace trim config → replace those assertions with coverage that the full-name rule is stable across engine contexts rather than preserving removed behavior.
- Hidden call sites may depend on `Subsystem::` in test fixtures or generated script snippets → mitigate with repository-wide searches for `Subsystem::`, `EditorSubsystem::`, and removed config names during implementation.

## Migration Plan

- First update tests to assert full namespaces for Blueprint libraries and subsystem helpers.
- Then remove namespace-shortening settings and engine state, and simplify namespace generation.
- Update subsystem binding and preprocessor generation to call `USubsystemLibrary::...` and `UEditorSubsystemLibrary::...`.
- Update examples/docs that mention shortened helper namespaces.
- Verify with focused binding/preprocessor tests and a standard build.

Rollback means reverting the OpenSpec change implementation branch before release. No runtime compatibility switch is planned.
