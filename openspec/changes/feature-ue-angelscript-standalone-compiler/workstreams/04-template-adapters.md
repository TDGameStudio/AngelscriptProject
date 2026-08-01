# Workstream 04: Template Adapters

## Context

UE container bindings are not declarative-only. Template callbacks inspect subtype flags and behavior support, construct subtype-specific metadata, apply nested-template rules, and influence value size/alignment used by the compiler. Runtime implementations depend on UE script containers, properties, GC schemas, and allocators and cannot be reused outside UE.

The offline contract exports the final declaration surface, adapter ID/version/surface hash, and compile traits. The analysis core supplies dependency-ordered registration, trap-backed functions, classification, and differential artifacts. This workstream supplies only the non-declarative template semantics required for compilation.

## Goals / Non-Goals

**Goals:**

- Make the named UE templates compile with representative UE-equivalent positive/negative results.
- Reject unsupported subtype traits and nested combinations deterministically.
- Reconstruct deterministic compile-only layouts without implying UE ABI.
- Detect registration-surface drift before compilation.
- Preserve an absolute no-execution boundary.

**Non-Goals:**

- Runtime container values, mutation, iteration, GC, serialization, UE allocator behavior, or reflection layout.
- Binary compatibility with `FScriptArray`, `FScriptMap`, `FScriptSet`, UE `TOptional`, or UObject wrappers.
- Every project-specific template; unknown adapters remain unsupported.
- Replacing native profile `array<T>` or `dictionary`.

## Decisions

### 1. Create one registry and trait vocabulary

Create:

```text
Standalone/Source/Adapters/
  AngelscriptAdapterRegistry.*
  AngelscriptTemplateTraits.*
  AngelscriptArrayAdapter.*
  AngelscriptMapAdapter.*
  AngelscriptSetAdapter.*
  AngelscriptOptionalAdapter.*
  AngelscriptObjectWrapperAdapters.*
```

`AngelscriptAdapterRegistry` maps stable adapter IDs to version, supported surface hash, template declaration, callback, layout policy, and support classification.

`AngelscriptTemplateTraits` normalizes:

```text
constructible
destructible
copyable
comparable
hashable
templateSubtypeEligible
objectHandleCompatible
isObjectReference
isValueType
valueSize
valueAlignment
requiresGC
```

Traits originate from contract records and script type behavior inspection. Missing required facts produce unsupported, never optimistic defaults.

### 2. Validate adapter handshake before registration

The bundle's adapter ID and semantic version must be recognized. Its canonical exported method/behavior surface hash must exactly match the supported adapter surface. Required engine properties and trait-schema version must match.

Mismatch is an infrastructure compatibility error (`2`) before source compilation. A declarative-only template bypasses adapter lookup only when the contract explicitly marks it declarative.

### 3. Keep method declarations contract-driven

The registration loader continues to register final exported behaviors/methods with generic traps. Adapters do not maintain a second hard-coded public API. They own:

- template callback and subtype validation;
- deterministic compile-only size/alignment;
- subtype metadata needed by the compiler;
- specialization/iterator relationship;
- any registration ordering the callback requires.

A surface hash prevents silent drift between exported declarations and adapter expectations.

### 4. Use deterministic non-UE layout policies

Layouts only need internal consistency for standalone compiler/bytecode generation:

- handle/reference wrappers use a canonical pointer-sized compile layout;
- `TOptional<T>` uses checked aligned subtype storage plus a canonical presence flag;
- container and iterator adapters use canonical opaque value layouts specified by adapter version;
- zero-size/invalid alignment/overflow is rejected.

Artifacts mark these layouts `standalone-compile-layout` and `non-ue-abi`. UE-validation bytecode remains validation-only.

### 5. Reproduce current `TArray<T>` rules

Element type must be template-eligible, constructible, destructible, copyable, and non-zero-size. Object handle/reference state and subtype size/alignment are recorded. Current nested-container restrictions are enforced.

Mutable and const iterator templates bind to the exact array specialization and expose only final contract declarations. Index/ref/const return semantics participate in type checking, but execution traps.

### 6. Reproduce current `TMap<K,V>` rules

Key requires construct, destruct, copy, comparison, and hash. Value requires construct, destruct, and copy. Script-provided hash/comparison behavior is accepted only when it matches the exported/fork rules.

Current nested-template restrictions, index/find/out-ref signatures, iterator key/value types, constness, and append/assignment declarations are validated.

### 7. Reproduce current `TSet<T>` rules

Element requires construct, destruct, copy, comparison, and hash. Current script hash and nested-template policies are enforced. Mutable/const iteration and final contract methods participate only in compilation.

### 8. Reproduce `TOptional<T>` compile semantics

Subtype requires valid construct/destruct/copy traits. Layout is deterministically derived with checked alignment and a presence flag. Null/has-value/access/assignment declarations come from the bundle. The result is never described as UE `TOptional` ABI.

### 9. Reproduce UObject wrapper subtype rules

`TObjectPtr`, `TWeakObjectPtr`, and `TSoftObjectPtr` require UObject-derived reference subtypes. `TSubclassOf` and `TSoftClassPtr` require compatible class/object subtypes. Ordinary value types are rejected.

Base/derived covariance, assignment, cast, null, soft-path construction, and class compatibility follow exported declarations and relationship data. No object load, weak resolution, GC, or class lookup executes.

### 10. Treat nested-template policy as exported behavior

The adapter uses the current rule version and contract traits, including any recorded `TSubclassOf` exception. It does not generally permit arbitrary nesting just because a standalone layout can be constructed.

Any future UE rule change changes the adapter version/surface or trait policy and requires an explicit adapter update.

### 11. Differential tests are the support authority

For each template, identical valid/invalid snippets compile in UE and standalone. Compare:

- accept/reject;
- normalized diagnostic category and principal source location;
- missing trait/nested rule;
- resulting specialization relationships;
- resolved declaration stable IDs;
- support classification and bytecode completion.

Runtime output and bytecode bytes are not compared.

## Risks / Trade-offs

- **[Compile layout influences bytecode unexpectedly]** → Use fixed versioned policies, deterministic tests, and never load output into UE.
- **[Contract declarations drift]** → Reject adapter surface hash mismatch before compilation.
- **[Trait export is incomplete]** → Unsupported with the missing trait name; never infer from size/name alone.
- **[Script comparison/hash differs from UE]** → Differential positive/negative fixtures pin current fork behavior.
- **[Hard-coded adapter methods duplicate bundle]** → Keep public declarations contract-driven; adapters own callbacks/layout only.
- **[Native `array<T>` conflicts with UE `TArray<T>`]** → Separate native-runtime and UE-validation engine profiles and type namespaces/surfaces.

## Migration Plan

1. Add registry/traits and handshake tests.
2. Implement array plus iterators and differential matrix.
3. Implement map and set plus hash/compare/nested matrices.
4. Implement optional.
5. Implement UObject wrappers.
6. Run the combined template corpus, update the support matrix, and remove only proven unsupported entries from analysis core.

Rollback unregisters adapters and returns the templates to explicit unsupported diagnostics; no UE runtime bind changes are required.

## Open Questions

None for the listed v1 adapter set. Additional templates require their own adapter/version and differential evidence.
