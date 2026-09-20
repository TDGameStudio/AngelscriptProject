# Image’s cross-module TypeInfo holder is asCModuleDefinitionSet

## Context

Deleting `asCMetadataImage` removed the Frozen unique owner that a later Builder named through `Options.Dependencies`. CompileOutput cannot hold TypeInfo. Engine must not be the compile-time type library.

## Evidence

- Snapshot Builder `TakeDefinitions` moved `TUniquePtr<asCMetadataImage>`; `AddExternalDefinitions` closed over Frozen Image*.
- After Image deletion, pending arrays on Builder are not takeable; destroying the Builder dangling later units.
- User confirmed one takeable type per compile unit; name `asCModuleDefinitionSet` (Module = compile unit, not `asCModule`).

## Options

| Option | Result |
| --- | --- |
| A. Per-unit takeable set | DAG nodes exist; Registration consumes UniquePtrs |
| B. Keep all Builders alive | No product to Take; debug and ownership unclear |
| C. Process-wide pending type library | Reintroduces a global bag |

## Settled Decision

Option A: `asCModuleDefinitionSet`. Builder UniquePtr until `TakeModuleDefinitionSet`. Later units hold non-owning `asCModuleDefinitionSet*`.

## Consequences and Flip Condition

Do not put the set on `asCModule` or inside `asCCompileOutput`. Flip if BindInfo must share this type in the same Change (it still constructs Image).

## Visual

```text
Builder A → UniquePtr<asCModuleDefinitionSet>
Take → caller holds UniquePtr
Builder B.Dependencies = { A* }
Registration consumes UniquePtrs → Engine
```

## Sources

- attachments/drafts/design.md
- attachments/drafts/findings/cross-module-definition-holder.md
- attachments/drafts/findings/metadata-image-removed.md
- draft log.md Round 8 Q21 / N1
