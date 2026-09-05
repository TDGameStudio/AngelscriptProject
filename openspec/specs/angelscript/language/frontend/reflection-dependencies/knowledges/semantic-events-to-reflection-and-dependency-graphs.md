# Project typed semantic events into concrete host output

## Status

Current. The Reflection and ModuleGraph NativeEngine tests prove the result assembly, descriptor lifecycle, source anchors, typed dependency evidence, deterministic SCCs, and graph separation.

## Rule

Resolve language meaning once in Parser/Sema, then let concrete consumers project the accepted typed declarations. A host descriptor consumer and a dependency collector may observe the same declarations, attributes, canonical type uses, owners, and source ranges; neither consumer reparses source text or repairs missing meaning.

```text
immutable source + configuration
  -> directives select active tokens
  -> Parser/Sema owns typed meaning
       -> concrete FAngelscript*Desc projection (Resolved)
       -> declaration dependency use sites -> SCC/condensation graph
       -> optional body references -> separate invalidation graph
  -> later publisher alone creates Runtime/UE objects (Materialized)
```

This keeps three lifetimes distinct:

| Concept | Authority | Allowed state |
|---|---|---|
| Language meaning | Typed AST and Sema | Snapshot-local, sealed after resolution |
| Host creation request | Concrete descriptor | `Parsed`, then `Resolved` |
| Live host/runtime object | Publisher or materializer | `Materialized` generation |

## Dependency discipline

- Keep one edge per distinct typed use site so diagnostics retain reason, authored range, and completeness.
- Derive SCC adjacency from those edges without discarding the original evidence.
- Do not treat every cycle as invalid; Sema rejects the particular completeness rule that cannot be satisfied.
- Keep calls, global references, and other body-only facts out of declaration layout scheduling.
- Order durable output by stable keys and source anchors, never pointers, Runtime IDs, `FName` indices, file enumeration, or worker completion.

## Boundaries

- The concrete descriptor family may use UE container and string types because this product deliberately permits that coupling; it still may not consult live Engine or reflection registries during resolution.
- Inactive conditional branches remain queryable through the preprocessing record but do not become active descriptors or graph vertices.
- A generic reflection IR or string-keyed DTO would duplicate the typed AST's semantic authority and is not part of this pattern.
- Source membership comes from the compilation request. A source-level `import` construct is neither required nor inferred.
- Runtime publication, body execution, bytecode, VM, and Standalone behavior remain separate capabilities.

## Application

When adding another consumer such as documentation output, editor indexing, or a later materializer:

1. consume sealed typed declarations or explicit typed Sema callbacks;
2. retain stable identities and source anchors from the semantic objects;
3. expose the consumer's concrete lifecycle explicitly;
4. fail transactionally when required semantic facts are absent;
5. keep declaration scheduling and body invalidation in different graph types.

The stable verification oracles are `Angelscript.UnitTest.NativeEngine.Reflection`, `Angelscript.UnitTest.NativeEngine.ModuleGraph`, and the adjacent Lexer, Declarations, and Bodies families.
