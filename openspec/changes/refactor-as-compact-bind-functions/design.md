## Context

The manual-binding architecture intentionally replaced direct registration lambdas with stable named functions owned by `FAngelscript<Name>Binds`. Its first migration recorded a uniform companion-file convention. Review now shows that a substantial group of companion implementations are tiny while their registrations, documentation, and owner relationship live in the adjacent `Bind_<Name>.cpp`.

The desired boundary is therefore based on implementation weight, not on whether a callable needs a stable name. The source snapshot contains 95 `_Functions.cpp` files; 70 are below 100 physical lines. Thirteen core geometry families remain deliberately separate, leaving 57 selected compact providers after the compact `FVector4` and `FVector4f` function/type implementations were reviewed and included.

## Goals / Non-Goals

**Goals:**

- Make compact registrar-to-wrapper relationships locally readable.
- Preserve every runtime and script contract of the moved callable.
- Keep headers only where a sibling `_Type.cpp` needs the owner declaration.
- Use behavior tests and compilation rather than source-text layout assertions.

**Non-Goals:**

- Changing an AngelScript declaration, bind phase, registration order, callable address, native/trivial form, StaticJIT classification, or module dependency.
- Moving template definitions out of headers.
- Merging the high-complexity geometry families merely because their current implementation files are short.

## Decisions

### Selection is a fixed two-gate inventory

A provider is selected only when its current `_Functions.cpp` is fewer than 100 physical lines and it is not one of:

`FVector`, `FVector2D`, `FVector2f`, `FVector3f`, `FIntVector`, `FIntVector2`, `FIntVector4`, `FQuat`, `FQuat4f`, `FRotator`, `FRotator3f`, `FTransform`, `FTransform3f`.

The inventory freezes the resulting 55 files. Future providers require a separate review rather than silently entering this refactor.

### Definitions follow the final registrar in the owning cpp

Each selected owner keeps the same named `FAngelscript<Name>Binds` static members. The declaration remains visible before the registrar. The non-template definitions move after the file's final `FAngelscriptBind` definition, so registrations stay together and implementation bodies remain in the same source file. No anonymous namespace or new inline registration lambda is introduced.

If a sibling `_Type.cpp` includes the family header, the header remains the canonical declaration owner. Otherwise, the owner declaration becomes private to the main cpp and the redundant header is removed. Existing header includes become direct includes in the main cpp.

### Source layout is not a UE automation contract

`AngelscriptBindSourceLayoutTests.cpp` tests source strings and physical file placement rather than AS-visible behavior. It is removed in full. Existing Binding CQTests and StaticJIT AOT tests remain the behavioral regression layer.

## Risks / Trade-offs

- **A required declaration is removed with a header** → retain each family header whenever `_Type.cpp` includes it; confirm no other source consumer exists before deletion.
- **A relocation changes include reachability or linking** → preserve declarations and signatures, build the plugin, and run StaticJIT AOT after the full migration.
- **A source-only test removal hides API regressions** → run the existing full Bindings prefix, which exercises script compilation and representative dispatch rather than source structure.

## Migration Plan

1. Record and validate the fixed 55-provider inventory.
2. Migrate selected providers in value/utility, platform/system, and UObject/component groups without changing registration bodies.
3. Remove the obsolete source-layout suite and reconcile the conflicting active OpenSpec wording.
4. Build once all file moves are complete, then run Binding and StaticJIT AOT prefixes and strict OpenSpec validation.
