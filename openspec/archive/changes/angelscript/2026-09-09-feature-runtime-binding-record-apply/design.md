## Context

Current native registration accepts complete frozen `asCMetadataImage` objects and connects native functions by stable identity. Legacy string registration methods are unsupported. Runtime providers nevertheless preserve the authoritative UE-facing binding surface and contain substantial adapter, reflection, lifecycle and caller policy. The reference workspace has uncommitted TypeBindInfo work; use its recorded file hashes, not its branch name alone, as source provenance.

## Goals / Non-Goals

Complete all Runtime binding families under current build conditions and make them usable through an explicitly owned Engine and VM Context. Keep default startup dormant. Exclude separate extension plugins, script compilation integration, hot reload, runtime module-load updates, JIT execution and production parallel preparation.

## Decisions

### Detached record and immutable snapshot

`FAngelscriptTypeBindInfoStore` owns type/member descriptions, provider provenance, target conditions and native/UE recipes. `FAngelscriptTypeBindInfoRecorder` executes providers serially on GameThread for reflection safety. `FAngelscriptBinds(Store)` supplies the recording facade; record constructors, methods, properties, enums, template definitions, adapters and function modifiers without any script engine. A successful `Seal` closes mutation and exposes immutable views. Repeated sealing is harmless; rejected mutations preserve the sealed content and report a diagnostic. Duplicate incompatible declarations and unresolved required declarations fail with provenance.

Retain source declarations for authoring and diagnostics, while typed uses and stable identities drive installation. Store entries cannot own engine type/function pointers, IDs, per-engine adapter operations or mutable caches. Native addresses and immutable UE reflection facts may be captured with an explicit host lifetime: the provider modules and reflected types must outlive engines using the snapshot. Same-snapshot engines must not re-execute providers.

### Serial metadata application

`FAngelscriptTypeBindInfoApply` builds an engine-local installation result. First collect all names and nominal identities, then resolve layout/base/template dependencies, then define members and native call descriptions. Forward references are legal; inheritance and by-value layout cycles are diagnosed. Use stable provider/phase/declaration order for deterministic diagnostics and nondependency ordering.

Reuse the new frontend's tokenizer and type grammar through a focused binding-declaration entry point rather than restoring SDK Register* parsing. Preserve namespaces, defaults, const/ref/handle qualifiers, overloads and function identity kinds. Supply recorded definition modifiers to the binding parser before function interning, so metadata Freeze validates the complete canonical descriptor. Complete type facts, layouts, properties, behaviours, signatures and interfaces through validated metadata mutations, finalize and freeze, register the image with this engine, and connect callers. Any failure destroys the unpublished engine and installation state; callers never receive partial success.

Images and mutable UE adapter operations are per Engine. Types and members are completed before freezing; freezing a shell and appending its methods later is forbidden. Missing native metadata facts require a checked API extension and focused native regression tests, not direct writes to frozen legacy fields.

Native auxiliary addresses belong to the callable binding generation. Generic invocations receive the exact acquired sidecar's auxiliary address; they must not fetch runtime call data from frozen function metadata.

Runtime owner helpers resolve the active Context's exact Engine before any ambient scope. Both native caller and generic invocation paths expose their acquired generation's auxiliary data for the bounded call duration and restore it after nested calls. Runtime binding helpers consume this active invocation data rather than re-acquiring the latest sidecar or reading frozen metadata.

### Templates, UE reflection and finalization

Record template definitions and recipes. Materialize required concrete instances in the building image, and later requested instances in complete additional images depending on already frozen definitions. Cache instances per Engine by canonical type use; reject invalid element lifetimes/layouts. Adapt old template callbacks to explicit instance inputs and engine-local operations rather than hidden current-engine lookup.

Snapshot eligible loaded UClasses/UStructs/UEnums and generated/native binding maps before application. Preserve manual/generated/reflection precedence, TypeFinder, property conversion, world-context handling, static namespaces, mixins, delegates, GC and lifecycle semantics. Split old immediate-query providers into record and apply work. Classify every Finalization/ReplayOnly provider explicitly; none may fall through to disabled legacy registration. A new snapshot is required for modules/types loaded after capture. Existing alternate native transports retain explicit installation paths and tests, without changing the selected backend configuration.

### Explicit owner lifecycle

Add `FAngelscriptEngine::CreateForBindings` overloads for a fresh full Runtime snapshot and a shared sealed Store, returning `TUniquePtr<FAngelscriptEngine>` and a diagnostic result. A private binding-construction path bypasses legacy cache/config-source/service initialization. Own the ScriptEngine, binding TypeDB, images, contexts, reflection/native sidecars and adapter state. Resolve owner-dependent calls through the exact ScriptEngine or a bounded explicit call scope, never a process-global default Engine.

Initialization and failure cleanup share deterministic ownership. Drain/release owned contexts and callable resources before metadata and ScriptEngine release. Destroying one owner leaves another owner's metadata, calls and cached template operations valid. Default subsystem/module startup and legacy test gates stay unchanged.

### Dependency prepass for bounded family migration

The task preflight exposes actual signature cycles: FString uses TArray<FString>, while FText uses formatting arguments, arrays and maps. Extract real provider declaration/lifetime callbacks and template-instance foundations before migrating complete member families. `RecordRuntimeTypeDeclarations` and the loaded UE nominal snapshot provide native layout, identity and lifecycle recipes without claiming full API completion. Family verification composes these real dependencies with the family member records in a fresh image before Freeze. Full snapshot creation and provider completeness remain separate integration acceptance; no frozen type is reopened and no synthetic test type substitutes for a Runtime dependency.

`FAngelscriptTypeBindInfoReflection` captures loaded or explicitly supplied UE nominal roots on GameThread. Its immutable `FAngelscriptReflectedTypeSnapshot` copies native paths, parents/interfaces, nested property type uses, enum values and delegate signature flags. Owning class/struct/enum providers supply eligibility and native adaptation recipes. A Store retains the snapshot, which pins the reflected objects and property type dependencies until all owners release it. Declaration providers reuse that same snapshot across phases; this prepass records types while later reflection tasks install members and adapters.

### Intended AS surface inspection and offline validation

The new export entry receives a sealed Store, not a global Engine. Existing as.DumpEngineState/FAngelscriptStateDump Classes, RegisteredTypes and BindRegistrations tables guide readable columns; their initialized-global-Engine, active-module and adapter queries are not the new entry path. Script-defined compiled classes remain outside this binding-only change.

Add FAngelscriptTypeBindInfoInspection with Collection-only and sealed-Store projections. Collection inspection executes no callbacks and works before migration completes. Store output distinguishes intended AS types/classes/enums/interfaces/templates/aliases, base/interface relationships, methods/behaviours/properties and namespace globals from captured-only UE identities, exclusions and explicit effects. Label stage and scope (collection-only, selected-family, full-runtime). Resolve canonical referenced-type facts through the existing engine-free declaration parser/resolver; Python does not parse AngelScript again.

Use versioned UTF-8 JSON and types/classes, members, globals, providers and exclusions CSV tables plus a summary from one projection. Identities are case-sensitive qualified symbols/signatures and module/provider/phase provenance. Normalize repository-relative source paths; exclude pointer addresses, timestamps and allocation-dependent IDs from comparable output. Preserve meaningful recipe order and explicit provider execution ordinal. Describe native/auxiliary/global targets with stable binding identity, presence, convention and lifetime category without dereferencing or invoking them. Preserve reflected int64 enum values as decimal strings. Retain opaque/unknown categories explicitly. This is diagnostic interchange, not executable persistence.

The process-wide Collection owns callbacks; each Capture creates a policy-specific Store. Types, Namespace scopes/globals, members and provenance are copied; Engine consumers share const Store ownership. TypeDatabase, metadata and mutable adapters belong to each Engine. Store-bound index handles and lookup maps are not persistent identities. Native code and borrowed auxiliary/global addresses require host lifetime spanning all consumers. Reflection snapshots pin UObject identities/dependencies without freezing external UE objects. Reject policy mismatch before attachment or mutation.

Add stdlib-only Plugins/Angelscript/Tools/BindingInspection/validate_bindings.py and diff_bindings.py with unittest fixtures and README usage. Validate version/schema, qualified identities, typed references, native layout, provider provenance, exclusions and independent expected symbols. Detect inheritance/by-value cycles while allowing handle cycles. Explicit categories cover builtins/template parameters/external dependencies. Semantic comparison reports added/removed/changed declarations and modifiers. Collection-only/partial output cannot satisfy full-runtime expectations. Successful static validation does not prove native ABI, calls or GC.

Full Runtime 8.2 joins source inventory, compiled Collection, sealed manifest and installed effects using independently maintained family expectations. Compiled-out alternatives require inventory/build evidence. Keep complete JSON/CSV and Python reports under the Harness run with build/policy/source provenance; keep bounded durable summaries and hashes.

### Validation after Seal

Seal closes record writes and preserves any recording failure; it is not complete installation validation. Add FAngelscriptTypeBindInfoValidation::ValidateSealed with a deterministic read-only result carrying stage/symbol/provider/source diagnostics. Reuse current engine-free declaration parsing, nominal/dependency/layout and member-identity checks rather than reproducing these rules in the exporter. Validate policy/provenance consistency, required nominal references, legal base/by-value dependencies, native layout/property bounds, member uniqueness/modifiers and presence of required native descriptors. Do not invoke callbacks, dereference borrowed addresses or create an Engine. Template parameter and handle-reference rules follow existing canonical type semantics.

Explicit binding creation calls this gate before allocating a native Engine. Dump includes seal state plus validation outcome/diagnostics; a sealed but semantically invalid Store can still be dumped for diagnosis and is never labeled ready. Declaration-only/family inspection reports its explicit scope and unresolved requirements without being presented as full-runtime installation readiness. Validators return external results without mutating the sealed Store, including on failure. Python validation independently checks the exported facts; VM/ABI/lifecycle tests remain required for actual execution behavior.

### Migration and proof

The current main Runtime provider inventory is the coverage authority. Compare each provider with the reference workspace and record target conditions and destination stage. Keep selected-workspace changes and reference-workspace edits separate. Preserve all existing public binding declarations unless current native semantics explicitly reject them with an investigated contract correction.

Replacement fixtures live in NewVersion/Bindings under `Angelscript.UnitTest.RuntimeBindings.<Group>.<Scenario>`. They borrow semantic cases from dormant tests, not their shared engine pool or full-script helper. Full installation checks account for all eligible providers and declarations; calls exercise independent ABI/lifecycle families, not every gameplay method. RED/GREEN uses managed UE runs on bounded groups, and native shared-contract changes receive adjacent native tests.

## Risks / Trade-offs

Serial recording avoids known TypeDB/mixin races and gives a deterministic first implementation. No performance threshold is promised. Record phase timings for later optimization. Full provider migration is substantially larger than the initial FVector/FString tests; completion requires the inventory to close, not merely the first successful Engine.

Rollback is an ordinary revert of owned changes; there is no default-startup toggle enabling the old runtime. Dormant baseline tests remain an independent regression gate. Preserve the existing baseline clauses and add only the new explicit-owner capability.
