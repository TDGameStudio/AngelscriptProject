# Semantic events to reflection and dependency graphs

## Reusable Insight

When a language frontend must feed a host reflection system, the safest boundary is one typed semantic authority with multiple concrete projections. Parser/Sema resolves declarations, attributes, ownership, types, and source locations once; a host descriptor consumer and a dependency collector observe those same accepted objects. Neither consumer reparses text or repairs missing meaning.

This keeps three distinct concepts explicit:

| Concept | Authority | Lifetime |
|---|---|---|
| Language meaning | Typed AST and Sema | Frontend snapshot |
| Host creation request | Concrete resolved descriptor | Parsed, then Resolved |
| Live host/runtime object | Publisher/materializer | Materialized generation |

## Evidence

The current plugin demonstrates the cost of conflating these stages. `FAngelscript*Desc` holds useful pre-materialization facts alongside `UClass`, `UFunction`, `asITypeInfo`, `asIScriptFunction`, and `asCModule` pointers (`Core/AngelscriptEngine.h:1465-2026`). Meanwhile, the legacy preprocessor independently recognizes declaration shapes with regex and constructs descriptors at several separate call sites (`AngelscriptPreprocessor.cpp:1192-1391, 1951, 2908, 3293-3325`). Parser/Sema and reflection extraction can therefore disagree.

Dependencies require the same semantic precision. A string module-name set cannot explain whether an edge came from a base, stored property, function signature, generic argument, or delegate, and cannot state whether a declaration or complete definition is required. Source-aware typed use-site edges preserve that evidence; SCCs then summarize module cycles without discarding the original causes.

The user's valid Temp questions identify the relationship between preprocessing and UE's type system ([Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 175-177) and ask how property type dependencies are handled beyond inheritance ([Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 761-763). The assistant material that follows is non-authoritative. Current source supplies the implementation evidence and corrects its overstatement about ordering: `GetModulesToCompile()` only collects unique modules (`AngelscriptPreprocessor.cpp:466-474`), while explicit import processing mutates dependency names elsewhere (`802`, `1044-1087`).

## Boundaries

- A typed AST may broadly be described as an intermediate representation, but that does not justify a second generic reflection IR or string-keyed DTO between Sema and concrete host descriptors.
- Host descriptors may use host-native types when the product boundary explicitly permits that coupling. Runtime objects and mutable registries still belong to materialization, not semantic analysis.
- Declaration dependencies and body invalidation have different meanings. Layout/signature completeness and SCC scheduling belong only to the declaration graph; calls and body-only references belong to an invalidation graph.
- A dependency cycle is not automatically an error. Sema rejects the specific use that requires an unavailable complete definition; the graph preserves legal recursive declaration groups.
- Inactive conditional branches remain preprocessing records. They do not create descriptors or active dependency vertices for the selected configuration.
- Keep physical and C++ ownership aligned: reconstructed leaves use `source/frontend/` and the lowercase `frontend` namespace inside `BEGIN_AS_NAMESPACE`, with final names rather than `V2` shadows.
- Do not use the assembly-oriented [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 1-1400, the later suggestion for a separate annotation scanner, generic interface/DTO proposals, or unverified claims that the legacy importer already computes the desired graph.

## Application

Apply this pattern when adding another frontend consumer such as documentation output, editor indexing, or a later materializer:

1. consume sealed typed declarations or explicit typed Sema callbacks;
2. retain stable identity and source anchors from the semantic object;
3. make the consumer's concrete output state explicit;
4. fail rather than reconstruct missing facts from text;
5. keep graph edge reasons and completeness visible until the final scheduling or invalidation decision.

For deterministic parallel analysis, collect per-declaration or per-body fragments and merge them by stable key and source range. Never use pointer value, registration order, absolute path, numeric Runtime type ID, `FName` index, or worker completion order as durable identity or ordering input.

## Sources

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:1465-2026`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:466-474, 802, 1044-1087, 1192-1391, 1951, 2908, 3293-3325`
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 1401-1417, 1925-1976, 2283-2335
- [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 175-177,761-763
- [AngelScript pipeline-decoupling research](../../../../../../Temp/AngelScript%E7%BC%96%E8%AF%91%E6%89%A7%E8%A1%8C%E7%AE%A1%E7%BA%BF%E8%A7%A3%E8%80%A6%E4%B8%8E%E6%A8%A1%E5%9D%97%E6%9B%BF%E6%8D%A2%E7%A0%94%E7%A9%B6.md), lines 421-445, 534-582
