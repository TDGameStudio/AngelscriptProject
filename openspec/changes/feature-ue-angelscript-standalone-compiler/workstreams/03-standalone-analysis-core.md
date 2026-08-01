# Workstream 03: Standalone Analysis Core

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


## Context

The native-runtime workstream provides a no-UE build of the maintained fork. The offline-contract workstream provides a deterministic final environment snapshot. The remaining core problem is replaying enough declarations and frontend semantics to compile real UE-AngelScript without linking UE.

Current `FAngelscriptPreprocessor` creates useful class/function/property descriptors but is interwoven with `FString`, `TArray`, `UClass`, source providers, reflection lookups, settings, and engine/compiler services. `FAngelscriptClassDesc` also mixes semantic facts with `UClass*`, `UStruct*`, and `asITypeInfo*`. The production ClassGenerator must not be ported or simulated.

This workstream deliberately stops before full container adapters and typed resource validation. Those capabilities return explicit `unsupported`/`ue-required` classifications until they are completed by later workstreams.

## Goals / Non-Goals

**Goals:**

- Load and verify the canonical bundle.
- Resolve one complete symbol snapshot from the packaged default or an explicit project path without merging or fallback.
- Reconstruct compile-only types, relationships, members, globals, and callables in deterministic order.
- Compile selected UE-AngelScript source closures through portable preprocessing and the maintained compiler.
- Replace matching exported script baselines with current source modules.
- Emit source-located diagnostics, validation-only bytecode, resolved stable symbol IDs, and portable class models.
- Preserve UE preprocessor/compiler behavior for supported fixtures through differential tests.

**Non-Goals:**

- Executing any UE symbol or validation bytecode.
- UE-loadable bytecode.
- UClass/UFunction/FProperty/CDO/component/World/Blueprint VM/RPC/GC/reinstancing simulation.
- Complete UE container/object-wrapper template callbacks.
- Typed asset-path diagnostics beyond bundle availability and deferred classification.

## Decisions

### 1. Separate production components by responsibility

Create:

```text
Standalone/Source/Contract/
  AngelscriptOfflineManifest.*
  AngelscriptOfflineRecords.*
  AngelscriptOfflineBundleLoader.*

Standalone/Source/Registration/
  AngelscriptRegistrationPlan.*
  AngelscriptRegistrationLoader.*
  AngelscriptCompileOnlyStub.*
  AngelscriptCapabilityClassification.*

Standalone/Source/Compiler/
  AngelscriptStandaloneUECompiler.*
  AngelscriptValidationArtifact.*

AngelscriptRuntime/Portable/Frontend/
  AngelscriptStandaloneLanguageSourceAdapter.*
  AngelscriptStandaloneBundleTypeOracle.*
```

UE-owned adapters live with the current Runtime preprocessor/compiler integration. ClassGenerator files remain unchanged except for consuming the existing descriptor produced by the adapter.

### 2. Use pinned RapidJSON only in standalone

Vendor a pinned MIT-licensed RapidJSON release under `Standalone/ThirdParty/RapidJSON/` with source/version/license notes. UE writes JSON with UE facilities; standalone streams JSONL with RapidJSON. No runtime/build dependency on Sigil or `Reference/` is introduced.

The loader validates manifest first, then each JSONL stream against declared schema, count, hash, stable identity, duplicate consistency, and supported compatibility fields before registering any symbol.

### 3. Select exactly one complete bundle

Bundle resolution happens before manifest loading:

1. explicit `--bundle <directory>` selects that directory alone;
2. omission selects the distribution's allowlisted `default-engine` directory;
3. explicit input never merges with or falls back to the default;
4. missing/invalid/incompatible explicit input exits `2`;
5. missing/invalid packaged default exits `2` as an installation error;
6. `symbolScope.complete` must be true, while `assetScope.complete` may be false;
7. no environment variable, current-project scan, most-recent cache, union, overlay, or delta is supported in v1.

The selection result records `packaged-default` or `explicit`, bundle kind, resolved path, and bundle hash. Frozen default-only/project-only fixtures prove replacement instead of union.

### 4. Compute source closure before script replay

The portable source host normalizes roots, logical module names, virtual source identities, includes/imports, and deterministic conditions. It discovers the selected entry closure before registration planning.

Registration planning:

1. load every `host-surface` record;
2. suppress every `script-baseline` record whose stable module ID is in the source closure;
3. retain closure-external script baselines;
4. reject ambiguous duplicate module identity or incompatible records;
5. topologically sort declarations and source modules.

Current source always wins for the exact stable module identity; filename order never decides replacement.

### 5. Reconstruct registrations in deterministic passes

Passes:

1. engine properties, feature flags, namespaces;
2. primitives, enums, typedefs, funcdefs;
3. object/reference/value/template skeletons;
4. base/interfaces/assignability/effective member views;
5. behaviors, properties, methods, globals;
6. supported built-in/declarative shims;
7. current source compilation.

Cycles, missing owners/subtypes, illegal relationship kinds, duplicate incompatible declarations, unknown required adapters, and unsupported engine properties fail before source compilation.

Where the public AngelScript registration API cannot express UE inheritance precisely, exported base metadata and effective member views drive lookup/cast/override validation. Such projection is `compile-shim`, not `exact`.

### 6. Make every native UE callable a trap-backed declaration

All imported callables use one `asCALL_GENERIC` compile-only trap. They participate in overload resolution, defaults, accessors, qualifiers, casts, constructors/behaviors, and bytecode generation.

An internal attempt to execute the trap is a host invariant failure. No callable returns a fabricated value.

Each registration maps the resulting engine function/type descriptor to the contract stable symbol ID for diagnostics and analysis artifacts. Runtime IDs and pointers remain process-local.

### 7. Rely on AngelScript signature relocation, not addresses

The bundle contains declarations and stable IDs. Live standalone bytecode references its current registered descriptors. Save-bytecode converts callable references to AngelScript used-function identity/signature records.

Validation artifact metadata records resolved stable symbol IDs separately so CI and IDE consumers can explain resolution. It does not alter the maintained bytecode format or inject UE addresses.

### 8. Extract a portable frontend without cloning the preprocessor

Portable ownership:

- normalized UTF-8 source records and source locations;
- logical modules, include/import graph, entry closure;
- deterministic condition evaluation using exported settings;
- macro/annotation recognition and declaration IR;
- host-neutral diagnostics;
- lowering inputs for the maintained compiler.

Host interfaces:

- source enumeration/read;
- symbol/type lookup;
- asset lookup placeholder;
- setting/feature lookup;
- diagnostic sink.

UE adapters retain directory watchers, source-provider events, reflection, editor state, settings objects, and compilation delegates. Standalone adapters use ordinary filesystem, bundle indices, and deterministic options.

No parallel second parser is introduced. Supported current fixtures must traverse the new portable path in both hosts.

### 9. Define the portable declaration/class model

LanguageCore declaration IR and related records use standard C++ value types and contain:

- stable semantic ID, module ID, namespace, name, kind, source range;
- base, interfaces, flags, access;
- properties and their type/access/metadata/default details;
- functions/events/delegates and complete signature/metadata;
- class metadata and default-expression validation;
- resolved contract stable symbol IDs;
- `exact`/`compile-shim`/`ue-required`/`unsupported` findings.

The UE adapter converts this semantic model to existing `FAngelscriptClassDesc`/function/property descriptors. UE-only pointer fields are populated only inside UE. `asPreClassData` may support compiler lowering but is not serialized or exposed as class-model state.

### 10. Validate class semantics without materialization

Offline-supported rules include:

- UCLASS/USTRUCT/UENUM/delegate/method/property macro shape and supported specifier combinations;
- class/struct kind and base/interface validity;
- duplicate/shadowed members;
- override/event signature and availability;
- property/function/argument/default types;
- access and exported metadata syntax;
- default-expression symbol/type resolution;
- global UFUNCTION and statics-class declaration behavior;
- source/module diagnostics.

UE-required rules include real reflection allocation/layout, CDO/default application, component templates/overrides, dynamically unavailable Blueprint members, ProcessEvent, RPC/replication routing, GC, World/subsystem state, hot reload, and reinstancing.

### 11. Emit stable analysis artifacts and statuses

Output:

```text
result.json
diagnostics.jsonl
modules/<module-id>.asbc
modules/<module-id>.classes.jsonl
```

UE bytecode is marked `ue-validation-only` with compiler/profile/input/module graph/bundle/adapter identity. `result.json` records resolved bundle source/kind/path/hash and independent symbol/asset completeness. `classes.jsonl` contains declarations, validation outcomes, symbol IDs, classifications, and UE-required reasons—never pointers or fake UE layouts.

Statuses:

- `complete`: no unsupported or used UE-required capability;
- `partial`: UE-required was explicitly allowed and no failure remains;
- `failed`: source/unsupported/disallowed deferred or infrastructure failure.

Without `--allow-ue-required`, used UE-required behavior exits `1`. With it, a partial result exits `0`. Unsupported behavior always exits `1`. Bundle/integrity/internal failure exits `2`.

### 12. Establish an explicit initial support slice

This workstream claims support for native AS language constructs plus exported non-template declarations, class/struct/enum/delegate metadata, inheritance/interfaces/effective member lookup, functions/properties/defaults/events/overrides, includes/imports/conditions, and script-to-script calls.

UE container/object-wrapper template callbacks are reported unsupported unless purely declarative and already proven by a fixture. Typed resource literals are recorded as deferred contexts but not checked against `assets.jsonl` until the resource-validation workstream.

## Risks / Trade-offs

- **[Portable extraction changes UE diagnostics]** → Route identical fixtures through both hosts and compare normalized category/location/declaration IR.
- **[Registration order differs from UE]** → Use dependency planning and stable semantic resolution; compare outcome/symbol identity, not runtime IDs.
- **[Effective member views hide an inheritance gap]** → Mark projection compile-shim and retain base/owner provenance in diagnostics.
- **[Script baseline replacement is wrong]** → Test full, changed-module, renamed-module, duplicate identity, cycle, and closure-external dependency cases.
- **[Project and default symbols are accidentally unioned]** → Build disjoint frozen fixtures and assert that explicit project selection cannot resolve default-only symbols.
- **[Invalid explicit input silently uses the default]** → Treat explicit selection as authoritative intent and assert exit `2` before any default open or source compilation.
- **[Class model grows into fake reflection]** → Prohibit UE pointers/layout/materialization fields through architecture scans.
- **[Trap is accidentally executable]** → No UE run command, profile isolation, and direct invariant tests for trap invocation.
- **[Unsupported templates make early tool less useful]** → Publish an honest support matrix and deliver adapters in the immediately following workstream.

## Migration Plan

1. Add deterministic default/explicit bundle selection, complete-scope checks, and frozen-contract integrity tests.
2. Add source closure and registration plan without compiling source.
3. Replay non-template declarations with traps and stable-ID maps.
4. Extract portable source/module/preprocessor primitives and keep UE differential green.
5. Add declaration/class IR and UE adapter.
6. Lower supported UE-AS into the real compiler and emit analysis artifacts.
7. Run default/project replacement, project/preprocessor/compiler differential fixtures and publish the initial support matrix.

Rollback removes standalone consumer code. Portable frontend extraction is retained only if UE preprocessor/compiler suites remain green.

## Open Questions

None for the core slice. Multi-bundle merging, incremental overlays, automatic cache discovery, templates, typed resources, VS Code projection, UE-loadable bytecode, and UE execution are outside this workstream.
