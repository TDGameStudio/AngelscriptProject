# Sigil and UE-AngelScript Standalone Feasibility

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


## Research Question

Can the Angelscript plugin provide a Sigil-like standalone workflow that validates native AngelScript and UE-AngelScript, including final UE symbols, registered templates, and asset paths, without loading Unreal Editor?

The answer is yes, but the host must expose two profiles rather than treating every script equally. Native AngelScript can use a bounded portable runtime, while UE-AngelScript remains compile/analysis-only. Neither profile can be produced by directly rebuilding the current plugin unchanged outside UE. The feasible boundary is:

- UE exports facts only UE can know;
- shared compiler/frontend code becomes genuinely portable;
- standalone reconstructs compile-time registrations with non-executable adapters;
- native scripts run only against a bounded portable standard-library profile;
- UE remains authoritative for reflection allocation and runtime behavior.

## Sigil Reference Findings

The local Sigil repository and its Knot knowledge base show a consistent architecture:

- `SigilCore` owns parser/schema/expansion/IR and has no UE dependency.
- `SigilBridge` translates between UE assets/reflection and the core model.
- `SigilEditor` owns commandlets/editor integration.
- `Standalone/Base` supplies a standard-C++ compatibility environment.
- the CLI and viewer consume the same core and exported schema/corpus;
- offline commands validate parse, format, round-trip, manifests, cache parity, and reconciliation.

The important lesson is not that UE can be reproduced outside UE. Sigil makes its text/IR core portable and treats UE as a producer of serialized information.

AngelScript differs in three ways:

1. the maintained compiler fork itself contains UE types and utilities;
2. compiling a source depends on the final registered type/function/template surface;
3. template callbacks and value layouts participate in semantic analysis and bytecode generation.

Therefore AngelScript requires both compiler portability and a richer replay contract.

## Existing Angelscript Export Surfaces

### State dump

`FAngelscriptStateDump` already captures 27+ CSV tables and normalized snapshots. It is valuable for diagnostics and diffs, but it is not replayable:

- registered type rows are largely name/declaration/has-UClass summaries;
- bind database tables emphasize counts;
- internal engine tables expose counts and broad type/function state;
- member relationships, complete behaviors, template callbacks, engine properties, provenance, and availability are incomplete.

The new exporter should remain a pure observer like StateDump but use a purpose-built contract.

### DebugDatabase

DebugServer already exports much of the IDE-facing semantic surface:

- engine settings;
- functions, return/argument types, defaults and qualifiers;
- object properties, methods, constructors, subtypes and selected inheritance;
- global functions/variables and enum values;
- Unreal names, selected metadata, documentation and keywords.

This makes it a useful implementation reference and a future projection consumer. It is not canonical because it filters internal/deprecated items and omits complete object flags/layouts, interfaces, behaviors, funcdefs, template callbacks, origin/module/plugin provenance, stable compatibility identity, and an offline manifest.

### AssetDatabase

DebugServer's asset database maps package paths to script or asset class names and supports editor updates. It does not provide:

- normalized package/object/generated-class distinctions;
- redirects;
- mount/plugin origin;
- registry completeness;
- asset tags needed for type compatibility;
- integrity/version metadata.

A new `assets.jsonl` projection is required for reliable resource diagnostics.

## Compiler Fork Portability Audit

The vendored fork contains no standalone CMake target. At least these source files directly use UE facilities:

- `as_atomic.cpp`;
- `as_builder.cpp/.h`;
- `as_compiler.cpp/.h`;
- `as_context.cpp/.h`;
- `as_memory.cpp/.h`;
- `as_module.cpp/.h`;
- `as_objecttype.h`;
- `as_scriptengine.cpp/.h`;
- `as_scriptobject.cpp`;
- `as_string.cpp`.

Observed coupling includes:

- `FPlatformAtomics`;
- `FMemory`;
- `FMath`;
- `TArray`, `TMap`, `TInlineAllocator`, `TPair`;
- `MoveTemp`;
- `check`;
- `UE_LOG`;
- hot-reload and tracked-reference maps;
- editor-only source block positions.

The plugin Core, Preprocessor, and ClassGenerator layers have substantially broader UE coupling. Attempting to compile them unchanged against shadow UE headers would make a large, fragile compatibility clone.

Recommended treatment:

- convert compiler internals to compiler-owned or standard C++ unconditionally;
- inject host services only at actual host boundaries;
- extract portable preprocessing/declaration logic from UE discovery and reflection;
- keep ClassGenerator runtime behavior UE-only.

## Registration and Symbol Strategy

### Why final-state observation is required

The final language surface comes from:

- manual `Bind_*.cpp`;
- UHT-generated bindings;
- native module function-address features;
- reflective fallback;
- optional plugins;
- runtime/reflected type discovery;
- engine properties and feature flags.

Parsing C++ registration source would miss conditional runtime facts and duplicate the plugin's binding logic. The exporter must inspect the initialized `asIScriptEngine` and supplement gaps from `FAngelscriptType` and UE reflection.

### Stable identity

AngelScript type/function IDs depend on registration order and cannot be persisted. Stable identity must derive from:

```text
namespace + owner + symbol kind + normalized complete declaration
```

The bundle records engine settings, loaded module/plugin scope, schema and adapter hashes so consumers can reject incompatible snapshots rather than producing false results.

### Compile-only replay

Standalone reconstructs declarations in dependency passes. Native pointers are replaced with a generic stub that must never execute. Value/reference/object types retain only the layout and behavior declarations needed by the compiler.

If the public registration API cannot express a UE inheritance relationship exactly, the contract supplies base metadata and effective member views. Any remaining semantic gap is classified explicitly instead of silently flattened.

### Cached snapshot selection

The standalone consumer does not need to compile `Bind_*.cpp`, parse registration source, or ask the manual Binding architecture to serialize descriptors. The UE producer enumerates the final initialized engine once and persists a purpose-built `manifest.json` + `symbols.jsonl` + `assets.jsonl` bundle.

Two complete snapshot kinds cover the supported use cases:

- a release-generated `default-engine` snapshot from the checked-in `AngelscriptProject` host contains that repository host's complete final registered surface, including its normally enabled optional plugins and project bindings;
- a project-generated snapshot contains the invoking consumer project's complete final registered surface, including its enabled optional plugins and project bindings.

The approved release policy intentionally uses the repository host rather than adding a canonical minimal-host fixture. `default-engine` is a selection/distribution role, not an engine-only content filter; its exact producer, loaded module/plugin scope, script baseline, and asset scope remain manifest-visible.

The project snapshot replaces the default snapshot. The consumer never unions the two, never interprets the project file as a delta, and never silently falls back after an explicit project bundle fails validation. This is intentionally larger than an incremental overlay but eliminates deletion/tombstone rules and prevents disabled or conditionally absent registrations from leaking out of the default surface.

## Container and Template Audit

### TArray

The UE binding registers `TArray<class T>` as a value template, a default array type, constructors/destructor, indexed access, assignment, comparison, mutations, queries, iteration and iterators.

Its template callback rejects subtypes that:

- are not valid template subtypes;
- cannot construct, destruct or copy;
- have zero value size.

It additionally records element size/alignment, copy/destruct requirements, object-pointer state, and optional script comparison.

### TMap

`TMap<class K, class V>` requires:

- key construct/destruct/copy/compare/hash;
- value construct/destruct/copy;
- current nested-template restrictions;
- optional script `Hash` support.

Its runtime uses UE map layout and GC/reference behavior, which are irrelevant and unavailable in standalone. Its template callback and method surface are compile-relevant and must be adapted.

### TSet

`TSet<class T>` requires construct/destruct/copy/compare/hash and enforces the current nested-template policy. Like maps, UE sparse-array layout and GC are runtime-only.

### TOptional

`TOptional<T>` requires construct/destruct/copy and uses a subtype-determines-size flag. Standalone needs a deterministic subtype-derived compile layout but must not claim UE ABI equality.

### Object wrappers

`TSubclassOf`, `TObjectPtr`, `TWeakObjectPtr`, `TSoftObjectPtr`, and `TSoftClassPtr` use template callbacks to enforce object/reference subtypes. Soft pointer declarations also provide the highest-value typed contexts for asset-path validation.

### Adapter conclusion

The supported templates need standalone-owned adapters, not `#if` branches in the existing UE binds. Method declarations come from the exported final registration surface; adapter code owns only callbacks, traits, layout policy and generic stubs. Adapter ID/version/surface hashes make drift observable.

## Resource Path Strategy

Resource validation must be syntax- and type-aware. Candidate contexts include:

- `FSoftObjectPath`/`FSoftClassPath`;
- `TSoftObjectPtr<T>`/`TSoftClassPtr<T>`;
- `LoadObject`/`LoadClass`;
- callable parameters marked by the contract as resource paths.

The validator must understand:

- package versus object path;
- generated Blueprint class `_C`;
- `/Game`, `/Engine`, `/Script` and plugin mounts;
- redirects;
- target type compatibility;
- incomplete or filtered Asset Registry scope.

It must not inspect arbitrary strings or treat a legal late-bound soft reference as an unconditional error. Missing soft references are warnings by default and strict errors by option.

## Alternatives Considered

### Persist the current DebugDatabase and stop

Lowest cost, useful for LSP completion and static diagnostics, but it does not exercise the actual fork compiler or bytecode builder and cannot fully represent template/registration semantics. Rejected as the primary product; retained as a future projection.

### Compile the same Bind files in a symbol-only macro mode

Representative binds require concrete UE types, member-function pointers, offsets, reflection iteration, type finders, and dynamic declaration expansion. Hiding those dependencies behind `#if` would place two implementations in the same translation unit rather than create one portable implementation. Rejected. Existing binds remain UE-only and the final initialized engine is the single observation point.

### Merge a default snapshot with project symbols

A direct union cannot represent symbols removed by configuration, disabled plugins, or conditional registration and would produce false-positive compilation. A correct delta format would require base hashes, upserts, tombstones, ordering, and upgrade policy. Both are rejected for v1 in favor of one selected complete snapshot.

### Compile existing plugin code against broad UE compatibility headers

Similar to Sigil's pragmatic compatibility layer, but the Angelscript plugin touches reflection, properties, GC, ClassGenerator and editor services far beyond a pure text core. This would recreate too much Unreal behavior and spread conditional compilation. Rejected except for narrowly owned host abstractions.

### Maintain a second upstream AngelScript fork

Would compile easily outside UE but diverge from the actual 2.33-based fork and selective 2.38 changes. Rejected.

### Require UE-loadable bytecode

Would freeze platform ABI, object/value layout, registration IDs, calling conventions and native behavior. It is unnecessary for feature iteration and offline validation. Rejected from this change.

### Execute non-UE bytecode offline without a bounded profile

Unrestricted execution would require an open-ended native API, filesystem/network policy, add-on surface, and security model. Rejected. The approved design instead executes native AngelScript only through a versioned generic-binding profile with string/array/dictionary/math/print/assert, no external I/O or arbitrary FFI, and default time/memory limits. UE-validation bytecode remains non-executable.

## Difficulty and Risk

| Area | Difficulty | Evidence |
|---|---:|---|
| CMake, CLI, and native runtime | 4/5 | Execution adds standard-library, exception, cancellation, allocation-limit, and artifact-profile work |
| Shared fork portability | 4/5 | Direct UE dependencies across compiler/runtime files |
| Native bytecode parity | 4/5 | Diverged 2.33 fork with selective later behavior |
| Portable UE-AS preprocessing | 5/5 | Current integration depends on UE source/module/reflection services |
| Final symbol exporter | 3/5 | Existing StateDump and DebugDatabase provide substantial reference code |
| Compile-only registration | 4/5 | Order, inheritance, behaviors, flags, layouts and optional plugins |
| Container adapters | 5/5 | Template callbacks, traits, nested restrictions and subtype-derived layout |
| Resource validation | 3/5 | Asset Registry data is available; typed-context policy is the main challenge |
| Differential maintenance | 4/5 | Requires durable normalized comparisons and explicit deferred cases |

Overall difficulty is high. Native execution is bounded by its closed host profile and resource limits; UE-AngelScript remains bounded by the no-execution, validation-only bytecode boundary. Reducing `#if` increases the initial portability refactor but materially reduces long-term divergence during compiler feature iteration.

## Recommended Delivery Gates

1. Standalone builds with no UE include/library paths.
2. Native SDK selected corpus has no unexplained compile or execution-result differences and native limits terminate safely.
3. Bundle export is deterministic and integrity-checked; the packaged default and explicit project snapshot paths both select one complete symbol surface without merging or fallback.
4. UE-AngelScript core annotations and registered symbols compile through the real fork.
5. Each container adapter passes valid/invalid differential fixtures.
6. Resource validation distinguishes found, missing, incompatible and unknown.
7. Architecture scans show no new unapproved standalone-specific conditions in shared/plugin code.
8. The CLI reports supported versus partial validation honestly and emits deterministic validation bytecode.
