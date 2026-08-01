# Workstream 05: Resource Validation

## Context

The offline-contract producer exports normalized asset, generated-class, redirect, type/base, mount, origin, availability, and scope/completeness facts. The analysis core can identify source expressions and resolved callable/property types. Template adapters add soft object/class wrappers. This workstream combines those facts into static diagnostics.

Soft references may legally target late-created or out-of-scope assets, so absence is not always an error. Conversely, simply scanning strings for `/Game/` creates unacceptable false positives. Resource analysis must be driven by resolved types and authoritative scope.

## Goals / Non-Goals

**Goals:**

- Discover statically knowable path values only in typed resource contexts.
- Normalize UE package/object/generated-class and mount forms consistently with the exporter.
- Resolve redirects safely and validate requested type assignability.
- Distinguish missing from unknown using declared scan scope/completeness.
- Provide configurable severity and differential evidence.

**Non-Goals:**

- Loading packages/assets/classes, reading payloads, or executing constructors/load functions.
- Validating arbitrary strings or dynamically computed runtime paths.
- Proving an asset will cook, stream, deserialize, or be available in a World.
- Rebuilding the Asset Registry outside UE.

## Decisions

### 1. Separate index, context discovery, and policy

Create:

```text
Standalone/Source/Resources/
  AngelscriptAssetPath.*
  AngelscriptAssetIndex.*
  AngelscriptResourceContext.*
  AngelscriptResourceValidator.*
  AngelscriptResourceDiagnostics.*
```

- `AssetPath` parses/canonicalizes supported UE path forms.
- `AssetIndex` owns immutable asset, generated-class, redirect, mount, type, and scope indices.
- `ResourceContext` describes source range, normalized value, requested type, object/class expectation, softness, and origin declaration.
- `ResourceValidator` returns a structured result independent of CLI severity.
- `ResourceDiagnostics` maps result/policy to stable diagnostics and artifact records.

### 2. Build an immutable validated asset index

The bundle loader already verifies JSONL integrity. The resource index additionally validates:

- unique normalized path identities;
- package/object/generated-class relationships;
- known asset class/base stable IDs;
- mount/origin consistency;
- redirect target form, cycle, and maximum depth;
- availability and scope membership.

Invalid internal relationships are bundle infrastructure errors (`2`), not source missing-asset errors.

### 3. Support explicit path forms

Normalize and preserve evidence for:

- package path;
- object path;
- generated Blueprint class `_C`;
- `/Game`, `/Engine`, `/Script`, and plugin mounts;
- class/object wrapper literal forms accepted by current UE-AS bindings.

The canonical result retains original spelling, normalized lookup key, final redirect target, and whether normalization changed the source representation.

### 4. Discover contexts after type resolution

Recognized contexts:

- `FSoftObjectPath` and `FSoftClassPath` construction/assignment;
- `TSoftObjectPtr<T>` and `TSoftClassPtr<T>` construction/assignment;
- `LoadObject` and `LoadClass` path arguments;
- callable parameters explicitly marked path-bearing by the bundle;
- portable property/default expressions whose resolved target type is one of the above.

Context discovery uses resolved declaration stable IDs/type kinds, not function names alone. An ordinary string, logging text, UI text, or custom function argument is ignored even when it resembles a UE path.

### 5. Evaluate a bounded constant-string subset

Supported values:

- direct string/name literal accepted by the target declaration;
- compile-time const declaration initialized by a supported value;
- deterministic concatenation of supported constant strings.

Runtime function results, mutable variables, format calls, condition-dependent values, and unknown conversions produce no found/missing claim. The analyzer records a deferred dynamic resource context only when useful, without failing compilation.

### 6. Return structured resource states

Validation states:

- `found`: path exists and requested type is assignable;
- `redirected`: source resolves to a final existing compatible target;
- `missing`: complete authoritative scope proves the normalized path absent;
- `incompatible`: target exists but asset/generated class is not assignable;
- `unknown`: asset scope/completeness/availability cannot decide.

Redirect cycles or malformed bundle redirect graphs are infrastructure failures. A redirected source emits a stable informational/warning result according to policy and records the final target.

### 7. Use bundle relationships for type assignability

Object references compare requested object type with asset class. Class references compare requested base/class wrapper type with the generated class and known base chain. Blueprint asset path and generated-class path are not conflated.

If required asset/generated-class base information is missing because the asset scope is incomplete, the result is unknown/ue-required rather than incompatible. The selected bundle's symbol scope remains complete.

### 8. Define severity policy

Default:

- found: no diagnostic;
- redirected: warning with final target;
- missing soft reference: warning;
- missing hard/load context: error;
- incompatible: error;
- unknown: informational/ue-required according to the context's compilation significance.

With `--strict-resources`, every authoritative missing result is an error. The option does not convert unknown into missing.

Resource errors contribute exit `1`. Bundle/index integrity errors contribute exit `2`.

### 9. Emit resource evidence in existing artifacts

`diagnostics.jsonl` carries stable diagnostic code, state, source range, original/normalized/final path, requested/resolved type IDs, context symbol ID, scope evidence, and severity.

`result.json` records counts by state and strict policy. Class/default records reference related resource diagnostic IDs. No separate asset database output is created.

### 10. Differential fixtures use producer-owned asset snapshots

Editor tests produce frozen fixture bundles containing known native assets, Blueprint generated classes, plugin mounts, redirects, incompatible types, and deliberately incomplete roots. Standalone compiles identical source contexts.

Comparison covers state, normalized/final path, requested/resolved type identity, principal source location, diagnostic category, and severity policy. No asset is loaded during standalone tests.

## Risks / Trade-offs

- **[Path spelling differs across UE APIs]** → Pin normalization with exporter/consumer golden pairs and preserve original spelling in diagnostics.
- **[Incomplete scope causes false missing]** → Require authoritative membership before missing; otherwise unknown.
- **[Name-based context matching causes false positives]** → Use resolved stable declarations/types and explicit bundle path-bearing metadata.
- **[Constant evaluation grows into an interpreter]** → Support only literal/const/concatenation and defer the rest.
- **[Blueprint asset versus generated class is confused]** → Keep separate path/type records and context-specific lookup.
- **[Redirect loops hide contract corruption]** → Validate redirect graph at load/index time and fail infrastructure.

## Migration Plan

1. Add path normalization and exporter-consumer golden cases.
2. Build asset/scope/redirect/type indices.
3. Add typed context discovery and bounded constant evaluation.
4. Add structured validation states and severity policy.
5. Add artifact integration and differential corpus.
6. Promote resource support only after complete/incomplete scope fixtures agree.

Rollback removes consumer diagnostics and returns typed contexts to deferred status; the canonical asset contract remains useful to later consumers.

## Open Questions

None for the bounded static resource slice. Cook validation, dependency graphs, package payload inspection, and runtime streaming availability are separate changes.
