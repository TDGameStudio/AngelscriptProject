# Direct descriptors and dependency authority

## Context

The reconstructed frontend must perform the UHT-like part of AngelScript preprocessing: understand the existing `UCLASS`, `USTRUCT`, `UENUM`, `UFUNCTION`, `UPROPERTY`, and `UMETA` spellings, return concrete information that a later UE publisher can materialize, and discover module relationships without `import`.

The decision is not whether reflection metadata exists. It is where its semantic authority lives and whether callers receive the established `FAngelscript*Desc` family directly or another intermediary that must later be reconciled.

## Evidence

- The current descriptor family already expresses the intended UE-facing class, enum, delegate, function, argument, property, metadata, and module information. It also mixes in later Runtime pointers, which motivates an explicit lifecycle rather than a duplicate structure (`Core/AngelscriptEngine.h:1465-2026`).
- The legacy preprocessor constructs descriptors itself at multiple points (`AngelscriptPreprocessor.cpp:606`, `1192`, `1391`, `1951`, `2908`, and `3325`) after separate regex/chunk analysis (`1367-1421`, `1632-1653`, and `3293-3314`). That is an independent semantic path, not merely output formatting.
- `GetModulesToCompile()` currently adds unique modules in stored file order (`AngelscriptPreprocessor.cpp:466-474`). Explicit dependency mutation happens through `ProcessImports` (`802`, `1044-1087`). Therefore Temp descriptions of an already-complete automatic topological graph must not be accepted without current-source proof.
- The user's Temp questions establish the useful goal: the preprocessor is closely related to UE's type system ([Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 175-177), and property type uses must be considered in addition to inheritance ([Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 761-763). The assistant material that follows those questions is non-authoritative research and is accepted only where current source independently supports it.
- Some proposed mechanisms are not accepted. [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2283-2335 suggests a separate annotation scanner, while [AngelScript pipeline-decoupling research](../../../../../../Temp/AngelScript%E7%BC%96%E8%AF%91%E6%89%A7%E8%A1%8C%E7%AE%A1%E7%BA%BF%E8%A7%A3%E8%80%A6%E4%B8%8E%E6%A8%A1%E5%9D%97%E6%9B%BF%E6%8D%A2%E7%A0%94%E7%A9%B6.md), lines 421-445 suggests generic extractor interfaces and import-fed graph construction. Both would duplicate the accepted Parser/Sema authority for this reconstruction.
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 1-1400 is invalid research input because it analyzed “AS” as assembly; the user correction begins at lines 1401-1409. None of that earlier architecture is carried forward.

## Options

### Separate regex or annotation scanner

This could produce FDesc early, but it would parse declarations and attributes twice, reproduce the current drift risk, and either guess type resolution or require a reconciliation pass. Rejected.

### Generic reflection DTO or metadata IR

This could appear host-neutral, but the product explicitly allows UE types inside this fork and the actual consumer needs `FAngelscript*Desc`. A generic layer would introduce another schema between typed AST and the concrete contract without an in-scope second host. Rejected.

### Build FDesc only during Runtime publication

This keeps the frontend host-neutral but prevents preprocessing callers from inspecting the concrete UHT-like result and couples semantic extraction back to a live Runtime generation. Rejected.

### Project typed Sema events directly into FDesc and typed graphs

One typed declaration/attribute event stream builds the AST and calls a concrete descriptor consumer. The same resolved type uses create source-aware declaration edges. A later publisher consumes only the complete `Resolved` result. Selected.

## Settled Decision

`asCPreprocessor` directly returns `FAngelscriptPreprocessResult`. Its descriptors are the existing single `FAngelscript*Desc` family, populated by a concrete consumer from the exact typed `Decl`, `Attr`, canonical type-use, and source-range objects accepted by Sema.

The reconstructed leaves live under `source/frontend/` and, within `BEGIN_AS_NAMESPACE`, the lowercase `frontend` namespace. Their names are final; no `Frontend` namespace, `V2` leaf, or compatibility twin is introduced.

Descriptor construction transitions `Parsed -> Resolved` inside this frontend. `Materialized` is reserved for a later Runtime publisher, and all live pointers remain null here. Failed declaration semantics return diagnostics without a publishable resolved descriptor set.

Automatic declaration dependencies come from resolved semantic uses, never `import` or textual spelling. Use-site edges retain reason, range, and completeness. SCCs represent cycles without declaring all cycles invalid. Body call/reference invalidation uses a separate graph and cannot alter declaration SCCs.

## Consequences and Flip Condition

The ThirdParty fork is intentionally UE-aware at this boundary, and the descriptor header extraction can affect Core include structure even though production routing remains unchanged. Tests must prove a single definition, null materialization pointers, and deterministic output.

Reconsider the direct concrete result only if a separately approved non-UE product host becomes an actual deliverable and demonstrates that the typed AST plus a host-specific consumer cannot serve it. Even then, the default response is another typed consumer, not a string-keyed DTO inserted into this UE path.

If later evidence shows a required resolved fact cannot be represented in `FAngelscript*Desc` without a live object, extend the concrete descriptor with a stable semantic field and preserve the lifecycle boundary. Do not fill a Runtime pointer early or recover the fact by reparsing text.

## Visual

```text
active preprocessed tokens
          |
          v
    Parser <-> Sema
                 |
                 +--> typed Decl / Attr / Type in sealed AST
                 |
                 +--> FAngelscriptDescriptorConsumer
                 |       `--> Parsed FDesc --resolve--> Resolved FDesc
                 |
                 `--> typed declaration edges --SCC--> condensation DAG

optional body facts ---------------------------> body invalidation graph

later, separate Change: Resolved FDesc --publisher--> Materialized pointers
```

## Sources

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:1465-2026`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:466-474, 606, 802, 1044-1087, 1192, 1367-1421, 1391, 1632-1653, 1951, 2908, 3293-3325`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h:112, 304, 334`
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 1401-1417, 1925-1976, 2283-2335
- [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 175-177,761-763
- [AngelScript pipeline-decoupling research](../../../../../../Temp/AngelScript%E7%BC%96%E8%AF%91%E6%89%A7%E8%A1%8C%E7%AE%A1%E7%BA%BF%E8%A7%A3%E8%80%A6%E4%B8%8E%E6%A8%A1%E5%9D%97%E6%9B%BF%E6%8D%A2%E7%A0%94%E7%A9%B6.md), lines 421-445, 534-582, 586-602
