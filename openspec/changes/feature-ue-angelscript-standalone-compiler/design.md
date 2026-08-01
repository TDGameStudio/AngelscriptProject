## Context

`Plugins/Angelscript` contains the authoritative AngelScript 2.33 WIP fork with selective 2.38 compatibility, UE-AngelScript preprocessing, bytecode generation/restoration, final native and reflective registrations, ClassGenerator, native SDK tests, and engine-state exports. None of these currently form a supported host boundary that can be built and used without Unreal Engine.

Sigil demonstrates the useful pattern: UE produces facts only UE can know, a deterministic contract crosses the process boundary, and a portable core consumes that contract. AngelScript needs a richer boundary because compiler correctness depends on engine properties, registered type flags and behaviors, inheritance, templates, layouts, callable declarations, and source preprocessing.

The original plan treated all standalone artifacts as non-executable. The approved product intent now distinguishes native AngelScript from UE-AngelScript:

- native AngelScript is a real standalone runtime;
- UE-AngelScript is offline analysis and validation only.

The existing change is retained as the single target architecture. High-risk portability, export, frontend, adapter, resource, and release work is organized as internal workstreams with independent milestone evidence rather than separate OpenSpec lifecycles.

## Goals / Non-Goals

**Goals:**

- Build the maintained fork on Win64 without an Unreal installation, Unreal include/library paths, generated code, installation paths, or process startup by resolving its existing UE Core includes through a CMake-only compatibility facade.
- Compile and run native AngelScript through a bounded `native-runtime` engine profile.
- Compile bundle-backed UE-AngelScript through a non-executable `ue-validation` engine profile.
- Provide a generated `default-engine` snapshot from this repository's normal `AngelscriptProject` host for bundle-free startup and accept one explicit project-generated complete snapshot as its full replacement.
- Let any Unreal project with the `Angelscript` plugin invoke the plugin-owned Commandlet to export its own final initialized symbol, script-baseline, adapter, and asset contract.
- Emit deterministic native-runtime or UE-validation bytecode with non-interchangeable profile identities.
- Export a deterministic final registration, script-baseline, adapter, engine-setting, scope, and asset contract.
- Produce a portable class semantic model for UE-AngelScript without producing fake Unreal reflection objects.
- Reproduce supported compile-time container, wrapper, override, and typed resource rules with differential evidence.
- Minimize fork changes by preserving its existing UE spellings, selecting a standalone compatibility include tree and target-owned translation units at CMake build time, and keeping standalone-specific conditionals out of fork language behavior.

**Non-Goals:**

- Executing any UE-AngelScript callable or UE-backed bytecode.
- Loading UE-validation bytecode into Unreal Engine.
- Reproducing UObject memory, UClass/UFunction/FProperty allocation, CDOs, GC, World, Blueprint VM, RPC routing, hot reload, or ClassGenerator reinstancing.
- Exporting native pointers, live UObject addresses, C++ source, executable code, asset payloads, or mutable editor runtime state.
- Providing native script file, filesystem, socket, network, process, dynamic-library, or arbitrary FFI access.
- Replacing UE headless compilation as the final integration authority.
- Merging default and project symbol sets, incremental bundle deltas/tombstones, automatic old-cache discovery, or fallback from an invalid explicit project bundle.
- First-release Linux/macOS packaging or a VS Code offline projection.

## Decisions

### 1. Keep one authoritative fork, add a CMake-only compatibility facade, and keep the frontend host-owned

CMake and UE Build.cs compile the same maintained fork sources. The fork keeps the UE Core spellings already present in the authoritative source (`TArray`, `TMap`, `TMultiMap`, `TPair`, `FMemory`, `FMath`, `FPlatformAtomics`, `FMemStackBase`, `FAngelscriptEngine`, and `UASClass`) instead of replacing them throughout the compiler/runtime with standard-library or newly named fork-owned types. UE Build.cs resolves those names to Unreal. Standalone CMake places `Standalone/Compat` before the Runtime Core and fork include roots so the same includes resolve to a deliberately bounded standard-C++ facade.

The compatibility facade is not a general Unreal clone and is not available to UBT. It implements only the API operations exercised by the maintained fork and `FunctionCallers.h`; its container, allocator, atomic, string/hash, assertion, type-trait, engine-policy, and raw-script-object behavior is covered by focused standalone tests. `CoreMinimal.h`, `CoreTypes.h`, `Containers/Array.h`, `HAL/Platform.h`, `HAL/PlatformAtomics.h`, `UObject/Object.h`, `UObject/Script.h`, `AngelscriptEngine.h`, `AngelscriptSettings.h`, and `ClassGenerator/ASClass.h` are compatibility entry points selected by include order, not public plugin options.

Functions whose UE definitions live outside the fork, including string scanning and `asIScriptObject::GetObjectType`, are supplied by standalone-owned translation units. Thread cleanup/lock functions and allocator installation are likewise target-owned when they are needed only by the standalone/add-on profile. The UE Runtime keeps its original direct implementations and does not install a process-global standalone host-service table.

Maintained-fork edits are allowed only for host-independent language/runtime behavior that cannot be expressed at the build boundary. The V1 allowlist covers read-only semantic observation, typed user data needed by that observer, unnamed registration parameters, prompt instruction-callback abort, template/generic-call correctness, script-struct bytecode restore symmetry, and repeatable engine teardown. Each retained edit requires focused standalone coverage and a UE/NativeCore regression path. Add-on compatibility that is needed only by standalone is adapted in `Standalone/Compat` rather than backported opportunistically into the public fork API.

The UE and Standalone frontends have separate owners. The existing public `FAngelscriptPreprocessor` remains the authoritative UE frontend with its `AddFile`, `AddSource`, `Preprocess`, `GetModulesToCompile`, `GetSummary`, `OnProcessChunks`, and `OnPostProcessCode` contracts. It continues to own UE source providers, asynchronous loading, settings conversion, event/progress dispatch, engine/reflection queries, and the mature `FAngelscriptModuleDesc` / `FAngelscriptClassDesc` graph.

Standalone owns a private standard-C++ frontend under `Standalone/Source/Compiler/Frontend` in the nested `AngelscriptStandalone::Frontend` namespace. Its responsibilities are source identity/mapping, lexing, preprocessing session, declarations, rewrites, and structured diagnostics. Its value contract includes `FSourceInput`, UTF-8 `FSourceSpan`, host-neutral configuration and type facts, `ITypeOracle`, value-only declaration records, `FRewriteEdit`, `FRewritePlan`, and `FFrontendSession`. It is compiled directly into `AngelscriptStandaloneHost`; there is no shared Runtime library, public plugin surface, or standalone language macro.

The two frontends exchange no in-memory descriptors or sessions. UE exports one complete final JSON contract after registration and successful active-script compilation; Standalone consumes that bundle through read-only value adapters. This is sufficient for project-v7 and avoids a second UE parse, portable descriptor lowering, or ClassGenerator simulation.

SHA-256 remains a contract algorithm but not a reason to recreate a shared Language layer. Standalone owns its streaming implementation under `Standalone/Source/Support`. The UE offline-contract producer owns a bounded one-shot implementation inside its new Dump identity translation unit because UE 5.8 declares `FPlatformMisc::GetSHA256Signature` but its generic implementation asserts and Windows supplies no override. Canonical known-vector tests lock both hosts to the same digest values without adding a module dependency or shared frontend API.

Future source-level compatibility is governed by `refactor-as-language-core-ue-facade-parity`, now redefined as algorithm-by-algorithm evidence work. Short-term duplication is accepted. A helper may be shared later only when both hosts require identical behavior and the helper remains smaller than the duplicated implementations without owning IO, descriptors, reflection, callbacks, or lifecycle.

Host-specific filesystem, diagnostics forwarding, reflection/type knowledge, assets, and platform behavior outside the maintained fork are supplied through narrow adapters and target-selected translation units. Existing binds and ClassGenerator gain no standalone business-logic branches. The private, non-propagated build-policy definition `AS_USE_EXCEPTIONS=1` applies only to `AngelscriptMaintainedFork` so the fork's existing application-exception guards can convert bounded-library allocation failure into a script exception; UBT retains `AS_NO_EXCEPTIONS`. `ANGELSCRIPT_LANGUAGE_STANDALONE`, `WITH_ANGELSCRIPT_STANDALONE`, `AS_STANDALONE`, and standalone business-logic conditionals inside the maintained fork are prohibited.

A copied upstream compiler is rejected because it creates permanent semantic drift. Sigil remains the implementation reference for compiling UE-spelled maintained-fork source through a CMake-first compatibility include directory. The compatibility facade must not escape `Standalone/Compat`, appear in UBT include paths, claim UObject/World/GC emulation, or become a dependency of ordinary standalone host records.

### 2. Use two isolated engine profiles

`native-runtime`:

- commands: `compile --dialect native` and `run`;
- provides portable UTF-8 `string`, `array<T>`, `dictionary`, math, `print`, and `assert`;
- uses generic host bindings and contains no UE bundle registrations;
- executes only `void main(const array<string> args)` or `int main(const array<string> args)`;
- defaults to a 5000 ms wall-clock deadline and a 256 MiB counted runtime allocation limit, with a 16 MiB minimum engine-bootstrap budget;
- exposes no file, network, process, dynamic-library, or arbitrary native FFI APIs.

`ue-validation`:

- command: `compile --dialect ue`;
- loads the packaged compatible `default-engine` bundle when no bundle is specified, or exactly one explicitly selected compatible complete bundle;
- registers callable declarations with non-executable generic trap stubs;
- emits analysis and bytecode but has no run/execute path;
- rejects any attempt to load the artifact into `run`.

Every artifact records its profile hash. Native-runtime and UE-validation bytecode are not interchangeable.

### 3. Use selected official add-ons as a patched native standard-library profile

The pinned AngelScript reference supplies `scriptstdstring`, `scriptarray`, `scriptdictionary`, and `scriptmath` as import sources. Reviewed copies are maintained under the standalone third-party directory with source version, license, and fork-difference notes.

Only the bounded profile is registered. Engine, context, script-object, Compat container, array, dictionary object/key/map, and script string/stream/constant-cache allocations route through the standalone counting allocator. CLI/result, diagnostic/JSON, C/C++ runtime, and OS allocations are documented exclusions. `regexFind` is not registered because `std::regex` cannot transitively honor the counted allocator. Context callbacks enforce cancellation and deadline checks. A normal `int main` result is written as `scriptResult`; it does not replace the CLI process exit code.

### 4. Define stable CLI and artifact contracts

Commands:

```text
as-standalone compile --dialect native|ue
  --script-root <directory>
  --entry <file-or-module>
  [--bundle <directory>]
  --output <directory>
  --diagnostics text|json
  --emit-bytecode
  --strict-resources
  --allow-ue-required

as-standalone run
  --script-root <directory>
  --entry <file-or-module>
  --timeout-ms <milliseconds>
  --memory-limit-mb <megabytes>
  --diagnostics text|json
  -- <arguments...>
```

`--bundle`, `--strict-resources`, and `--allow-ue-required` are UE-validation options. `--bundle` is optional: omission selects the packaged `default-engine` bundle, while an explicit path selects that complete bundle alone. `run` is native-only.

Exit codes:

- `0`: requested operation completed; an explicitly allowed UE-required result may be `partial`;
- `1`: source, symbol, template, resource, bytecode-generation, unsupported, or disallowed UE-required failure;
- `2`: usage, file, bundle, compatibility, integrity, or internal infrastructure failure;
- `3`: native script exception or abort;
- `4`: native timeout or memory-limit termination.

Output:

```text
<output>/
  result.json
  diagnostics.jsonl
  modules/
    <module-id>.asbc
    <module-id>.classes.jsonl
```

`result.json` records schema, profile, fork/compiler/profile, input/module graph, resolved bundle source/kind/path/hash, independent symbol/asset completeness, and adapter identities; complete/partial/failed status; module outputs; diagnostic counts; capability summary; and native `scriptResult` when applicable.

### 5. Keep UE bytecode address-free and validation-only

In live bytecode, system calls refer to an `asCScriptFunction`; the actual native interface and current-process function address live behind that registered descriptor. `SaveByteCode` serializes used-function identity/signature references rather than UE absolute addresses, and `LoadByteCode` resolves those references against registrations in the target engine.

The offline bundle therefore exports normalized owner, namespace, kind, complete declaration, qualifiers, traits, provenance, availability, and stable symbol ID—never an address. Standalone compilation resolves those declarations to trap-backed descriptors. UE startup independently registers real native interfaces in its own process.

UE-loadable bytecode would require a separate compatibility contract covering exact fork, engine properties, type/layout ABI, adapters, registration behavior, and loader verification. It is excluded here.

### 6. Split the bundle into host surface and script baseline

The physical bundle remains:

```text
manifest.json
symbols.jsonl
assets.jsonl
```

Symbol records carry an origin layer:

- `host-surface`: manual, UHT-generated, reflective, Blueprint/reflection, and optional-plugin declarations;
- `script-baseline`: declarations from the last successful UE script compilation.

Standalone always replays host-surface records. It computes the selected source/module closure, suppresses matching baseline records by stable module identity, compiles those modules from current source, and retains only closure-external baseline declarations as dependencies. Baseline records contain declarations and relationships, not function bodies or bytecode.

This avoids duplicate types while supporting both full-project and changed-module validation.

### 7. Observe the final engine and export a deterministic contract

The exporter runs after engine configuration, manual binds, UHT-generated binds, reflective fallback, optional plugin registration, successful script compilation, and required Asset Registry scanning. It observes the final `asIScriptEngine`; neither current nor future `Bind_*.cpp` providers gain exporter calls, JSON records, standalone modes, or standalone compilation branches.

`manifest.json` records `bundleKind` (`default-engine` or `project`), schema, producer, fork/compiler contract, platform/configuration, engine properties, feature flags, loaded module/plugin scope, complete symbol scope, independent asset scope/completeness, adapter identities, record counts, and SHA-256 hashes. `symbols.jsonl` and `assets.jsonl` use canonical UTF-8 serialization and deterministic ordering. A staging directory is atomically published only after all records, counts, and hashes are complete.

Persistent IDs derive from normalized semantic identity, never process-local AngelScript type/function IDs.

### 7A. Select one complete symbol snapshot without merging

The Win64 distribution contains exactly one generated `default-engine` bundle. Release automation invokes the plugin-owned export Commandlet against the repository's checked-in `AngelscriptProject.uproject` and normal release configuration. The snapshot therefore contains that host's complete final initialized environment: its supported UE version, core `Angelscript` registrations, checked-in project registrations, normally enabled optional plugins such as `AngelscriptGameplayTags` or `AngelscriptGAS` when loaded, successful active script baseline, and declared asset scope.

`default-engine` describes the bundle's distribution and selection role; it does not mean "engine-only" or "minimal host." The manifest records the exact producer project identity, loaded module/plugin scope, feature flags, symbol completeness, script baseline, and independent asset scope so consumers never mistake the convenience default for their own project's exact contract. Machine-absolute paths, source text, implementation bodies, addresses, bytecode, and asset payloads remain forbidden.

The same Commandlet is owned by `AngelscriptEditor`, not by this repository's host project module or release scripts. Any Unreal project with the plugin installed can invoke it with `BundleKind=Project` after that project's normal plugin registration and successful script initialization. The result is a complete snapshot of the invoking project's final environment, including enabled optional plugins, project bindings, active script baseline, and declared asset scope. It is not a delta against the packaged default and requires no change to `Bind_*.cpp`, UHT-generated shards, reflective providers, or third-party binding code.

`BundleKind=DefaultEngine` uses the same final-engine traversal as `BundleKind=Project`; the kinds do not select or filter symbols. `DefaultEngine` is reserved by the official packaging workflow to label the one snapshot selected when `--bundle` is omitted. `Project` labels a user/project export selected explicitly. The official default is generated from `AngelscriptProject`; a separate minimal-host fixture is not created or maintained.

Bundle selection is deterministic:

1. explicit `--bundle <directory>` selects that bundle alone;
2. otherwise the packaged `default-engine` bundle is selected;
3. the selected bundle must have `symbolScope.complete: true`;
4. a missing, invalid, or incompatible explicit bundle exits `2` and never falls back;
5. a missing or incompatible packaged default exits `2` as an installation/release error;
6. v1 performs no union, overlay, automatic project search, environment-variable lookup, or "latest cache" selection.

This permits different projects to expose different final symbol surfaces without introducing merge semantics or a second source of handwritten declarations.

### 8. Keep a value-only Standalone declaration model

The Standalone-private frontend produces standard-C++ declaration IR containing:

- stable semantic identity, module, namespace, name, kind, and source range;
- base, interfaces, flags, properties, methods, events, delegates, access, parameter directions/defaults, and qualifiers;
- metadata and default-expression validation;
- resolved bundle stable symbol IDs;
- per-rule support classifications and UE-required reasons.

The standalone data flow is:

```text
UE-AS source
  -> Standalone private frontend
  -> value declaration IR + rewrite plan + source map
  -> bundle-backed semantic validation
  -> maintained AngelScript builder/compiler
  -> script object type + validation bytecode + classes.jsonl
```

The UE data flow remains the existing preprocessor/descriptor/ClassGenerator path and does not consume the Standalone declaration model. The Standalone model never stores `FString`, `FName`, `TArray`, `TMap`, `UClass*`, `UStruct*`, `asITypeInfo*`, UE property offsets, or fake object layouts. `asPreClassData` may assist standalone compiler lowering but is not the frontend contract.

Declaration, inheritance, interface, conflict, override signature, member type, annotation/metadata syntax, default-expression typing, and exported Blueprint/native member rules are offline-checkable. UObject materialization, CDO writes, component templates, unexported Blueprint state, ProcessEvent, RPC/replication runtime behavior, GC, World, and reinstancing are `ue-required`.

### 9. Reconstruct registrations in dependency order with explicit support classes

Registration passes:

1. engine properties, feature flags, namespaces;
2. primitives, enums, typedefs, funcdefs;
3. type/template skeletons;
4. base, interfaces, assignability, effective member views;
5. behaviors, properties, methods, globals;
6. standalone template adapters;
7. source compilation and bytecode save.

Every imported capability is `exact`, `compile-shim`, `ue-required`, or `unsupported`. Nothing is silently dropped.

Without `--allow-ue-required`, a used UE-required construct exits `1`. With the option, compilation continues, returns `0` if no other failure exists, and records `partial` plus `complete: false`. Unsupported constructs always exit `1`.

### 10. Keep UE template adapters standalone-owned

Standalone adapters cover `TArray`, `TMap`, `TSet`, `TOptional`, their iterators, `TSubclassOf`, `TObjectPtr`, `TWeakObjectPtr`, `TSoftObjectPtr`, and `TSoftClassPtr`.

Final declarations come from the bundle; adapters provide only non-declarative callbacks, compile traits, deterministic non-UE layouts, and trap stubs. Existing UE `Bind_*.cpp` files are not compiled into standalone and gain no standalone branches.

Adapter ID, version, and registration-surface hash make drift a load-time incompatibility rather than a silent change.

### 11. Validate resources only in typed contexts

`assets.jsonl` records normalized package/object/generated-class paths, class/base relationship, mount, origin, redirects, availability, minimal type-check tags, and snapshot completeness. Asset completeness is independent of mandatory complete symbol scope: an incomplete asset index keeps compilation usable but can produce only `unknown` outside its proven scope.

Validation applies only to `FSoftObjectPath`, `FSoftClassPath`, soft pointer/class wrappers, `LoadObject`, `LoadClass`, and bundle-marked path parameters. Ordinary path-looking strings are ignored. Missing soft references warn by default and fail under `--strict-resources`. Incomplete scope returns `unknown`.

### 12. Organize delivery as one lifecycle with internal workstreams

Required order:

0. feasibility and contract freeze;
1. portable core and native runtime;
2. offline contract export;
3. standalone analysis core;
4. template adapters;
5. resource validation;
6. release evidence.

`feature-vscode-offline-contract-projection` is optional and does not block the standalone release.

This change owns the final target, canonical specs, implementation tasks, and archive. Detailed workstream designs live under `workstreams/`; milestone evidence lives under `verification/`. Each phase may use scoped commits and may rewrite later tasks as evidence changes the design, but no phase is independently archived. The complete change is archived once after all first-release requirements pass.

### 13. Gate support claims with differential evidence

Native language/runtime, UE frontend, registration, container, resource, and representative project fixtures compile in the relevant hosts. Comparisons cover outcome, normalized diagnostic category/location, resolved stable symbol IDs, support classification, class model, and bytecode-generation completion.

UE and standalone bytecode bytes are not compared. Each profile's own artifacts must be deterministic for identical inputs. A supported corpus performance baseline records cold startup, module count, source LOC, total time, and peak memory; a later regression above 20% on the fixed baseline environment fails the release gate.

### 14. Prove the architecture before broad implementation

`workstreams/00-feasibility-gates.md` is a mandatory precondition. It proves:

- a no-UE build of the maintained fork;
- deterministic native save-bytecode;
- canonical schema and stable identity rules;
- compile-only registration and address-free linkage;
- script-baseline replacement;
- portable declaration IR;
- read-only compiler semantic observation;
- mixed UE/CTest runner dispatch;
- CLI output and allocation-accounting boundaries.

A failed proof changes this design and the later task plan. Later workstreams do not compensate with fake Unreal behavior, a copied compiler, text-only semantic guesses, or undocumented nondeterminism.

### 15. Publish machine-readable schemas and exact canonicalization

The offline contract, analysis result, diagnostics, class/resource records, corpus index, and package manifest use versioned machine-readable schemas shipped with the Win64 package.

Canonical identity and serialization rules explicitly cover Unicode normalization, declaration/default normalization, logical module and virtual source identity, UE path case/spelling, JSON scalar encoding, object-key/record order, unknown fields, and major/minor compatibility. Producer and consumer golden tests use the same normative schema fixtures even though their C++ record implementations remain host-owned.

### 16. Observe resolved compiler semantics for resource analysis

Typed resource discovery uses a host-neutral, read-only compiler observation sink installed at resolved call, construct, assignment, argument, and supported constant-string boundaries. The sink observes the maintained compiler's overload/type decisions; it is not a second parser and does not change bytecode generation when absent.

Observed runtime IDs and descriptors are translated to stable contract identities before artifact serialization. This boundary is established in the analysis-core workstream before resource validation begins.

### 17. Generalize repository suite dispatch

Repository suite entries distinguish UE Automation prefix runs from standalone CMake/CTest runs. `RunTestSuite.ps1`, the parallel runner, shard planner, catalog output, report isolation, timeout/failure propagation, and self-tests consume the same entry-kind contract.

`Standalone` remains isolated until release soak passes. Adding it to `All` cannot cause a CTest entry to be interpreted as a UE Automation prefix.

### 18. Freeze CLI output and allocation-accounting contracts

Both `compile` and `run` have explicit output-directory/default/stdout behavior and never publish a manifest-valid partial result. Deterministic compile identity excludes execution telemetry.

The native runtime documents exactly which engine, context, script object, Compat, and selected add-on allocations count toward the configured 256 MiB limit, the 16 MiB bootstrap minimum, and which CLI/result, compiler-artifact, JSON/diagnostic, C/C++ runtime, OS, and process allocations are excluded. Limit rejection before backing allocation, application-exception conversion, active-context termination, peak accounting, repeated allocator ownership, and shutdown cleanup are tested as one contract.

## Risks / Trade-offs

- **[The compatibility facade diverges from the UE subset used by the fork]** → Implement only observed operations, test them directly, compile the same fork sources in both hosts, and keep UE/NativeCore regression gates at every compatibility milestone.
- **[Mechanical portability leaks back into the fork]** → Scan maintained sources for standalone-only headers/macros and for replacements of the established UE container/memory/atomic spellings; maintain an explicit semantic-change allowlist.
- **[Compatibility headers accidentally affect UBT or the private frontend]** → Add `Standalone/Compat` only to the CMake maintained-fork target, inspect generated project/include paths, and reject Compat includes from Build.cs, Standalone frontend, bindings, and ClassGenerator.
- **[Native execution broadens security and runtime scope]** → Keep a fixed generic-binding standard library, default 5000 ms/256 MiB limits, counted allocations, cancellation callbacks, and no external I/O/FFI surface.
- **[Patched add-ons drift from the fork]** → Pin source provenance, preserve licenses, record modifications, hash the profile surface, and cover execution/save-load behavior.
- **[Bundle script records conflict with current source]** → Use stable module identities and source-closure baseline suppression before replay.
- **[Portable class IR becomes a shadow UObject system]** → Store declarations and validation only; keep all reflection allocation and object lifecycle in the UE adapter/ClassGenerator.
- **[Registration inheritance cannot be replayed exactly]** → Export base metadata and effective member views, then classify irreducible cases instead of approximating silently.
- **[Container layout appears UE-compatible]** → Mark layouts profile-specific, validation-only, non-UE-ABI, and prohibit cross-profile loading.
- **[Asset snapshots are incomplete or stale]** → Record scope/completeness and report unknown outside authoritative coverage.
- **[Default and explicit project registrations are accidentally combined]** → Select exactly one complete snapshot, reject incomplete symbol scope, and test that explicit project input cannot inherit packaged-default-only symbols.
- **[An invalid project cache silently falls back]** → Treat an explicit path as authoritative intent and exit `2` on every path, integrity, or compatibility failure.
- **[The packaged default is mistaken for a universal UE/core surface]** → Define `default-engine` as a distribution role, expose exact `AngelscriptProject` producer/module/plugin/asset scope in the manifest and documentation, and direct consumers needing exact parity to export and select their own project bundle.
- **[The checked-in host's enabled-plugin set changes release behavior]** → Generate twice from the same revision and release configuration, require byte identity, record the full loaded scope and bundle hash, and review scope changes as release-contract changes.
- **[Conditional compilation spreads]** → Enforce source scans and an explicit minimal allowlist.
- **[One lifecycle hides long-running progress]** → Phase-grouped tasks, focused workstream designs, scoped commits, and independent verification records expose progress without multiplying OpenSpec deltas.

## Migration Plan

1. Consolidate the former child records into this change without losing requirements, scenarios, design decisions, or tasks.
2. Complete feasibility proofs and freeze schemas/contracts before broad implementation.
3. Replace the initial fork-wide standard-library portability pass with the approved Compat-first boundary: establish failing architecture tests, add the CMake-only facade and target-owned definitions, restore UE-spelled fork code, then retain and verify only the semantic allowlist.
4. Implement or reverify workstreams 1–6 in dependency order, recording fresh milestone evidence without archiving intermediate phases.
5. Generate the release `default-engine` bundle twice by running the plugin-owned Commandlet against the checked-in `AngelscriptProject.uproject` and its normal enabled-plugin set, verify byte identity, and package that one allowlisted default snapshot.
6. After each workstream, update the support matrix and later tasks without marking unverified capabilities complete.
7. Run final UE, NativeCore, Standalone, differential, architecture, privacy, determinism, performance, packaging, and strict OpenSpec gates.
8. Archive this change once so its four complete capability specs become canonical.

Rollback is workstream-scoped. Standalone targets, Compat, and exporters can be removed without changing existing UE runtime behavior. Retained fork semantic changes remain only if focused standalone tests plus UE and NativeCore regression gates pass.

## Open Questions

None for the recorded first-release architecture. Incremental/delta bundles, multi-bundle merging, automatic cache discovery, native bytecode file execution, broader official add-ons, arbitrary FFI, UE-loadable bytecode, Linux/macOS packaging, and VS Code bundle projection require separate changes.
