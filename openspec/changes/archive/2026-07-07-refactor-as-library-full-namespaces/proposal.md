## Why

Blueprint function library namespaces currently use a separate shortening layer based on `ScriptName` metadata and configurable prefix/suffix stripping. That made hand-written scripts terse, but it now creates noisy, non-obvious APIs for AI-assisted coding because generated script often has to infer names that do not match the underlying Unreal class names.

This change makes Blueprint library function access follow the same naming boundary as ordinary Blueprint/UClass types: use the registered Angelscript type name.

## What Changes

- **BREAKING**: Remove Blueprint library namespace shortening based on class `ScriptName` metadata.
- **BREAKING**: Remove configurable Blueprint library namespace prefix and suffix stripping.
- **BREAKING**: Replace the hand-written `Subsystem::Get*Subsystem(...)` helper namespace with the full `USubsystemLibrary::Get*Subsystem(...)` namespace.
- **BREAKING**: Replace generated editor subsystem helper calls from `EditorSubsystem::GetEditorSubsystem(...)` to `UEditorSubsystemLibrary::GetEditorSubsystem(...)`.
- Keep function-level `ScriptName` behavior for UFUNCTION names, events, properties, mixins, and explicit method renames.
- Keep ordinary type/static utility namespaces that are not part of Blueprint library namespace shortening, such as `FVector::` and `FMath::`.

## Capabilities

### New Capabilities

- `as-library-full-namespaces`: Defines that reflected Blueprint library functions bind under the full registered Angelscript type namespace, including subsystem helper libraries.

### Modified Capabilities

- None.

## Impact

- Runtime namespace generation in `FAngelscriptFunctionSignature`.
- Angelscript settings and engine state that currently carry library namespace shortening config.
- Subsystem helper binding and generated subsystem accessor code.
- Binding and preprocessor tests that currently expect `Subsystem::` or shortened Blueprint library namespaces.
- Script examples and documentation that reference shortened library namespaces.
