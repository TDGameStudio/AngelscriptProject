# JIT Interface 2.38, Test Module, Cache V2, And Live Coding Research

> **Historical layout note (2026-08-12):** The evidence in this document remains useful, but its per-function-slice/fixed-32-bucket recommendation was superseded by the user-approved strict one-AS-module-per-profile-`<Module>.jit.cpp` design. `design.md` and the delta specs are authoritative.

> Date: 2026-08-12
> Status: original design evidence for this OpenSpec refactor. Milestone 1 implementation evidence is recorded in section 13 and `verification.md`.
> Authority: local source trees and current repository code. Normative decisions live in `proposal.md`, `design.md`, capability deltas, and `tasks.md`.

## 1. Questions Resolved

This research closes the questions raised before implementation:

1. What did AngelScript 2.38 improve in its JIT interface?
2. Should this fork copy the upstream v2 interface or redesign it?
3. How should the complete Unreal-specific VM/Raw/Parms entry family be owned and released?
4. Where should test-generated JIT code live?
5. How should a real project receive its own generated JIT module?
6. Can Cache V2 stable identities and fresh-engine restoration be reused without coupling StaticJIT to cache persistence?
7. Is UE Live Coding useful for Editor StaticJIT refresh, and what are its limits?

The resulting answer is:

- adopt the useful 2.38 lifecycle semantics—function-ready notification, delayed publication, cleanup on replacement/destruction;
- do not copy its v1/v2 switch or single-pointer boundary;
- replace the fork interface with one maintained-fork-owned, non-versioned complete-binding lifecycle;
- use `AngelscriptTestJIT` only as an Editor/test generated-code carrier;
- generate product code into the fixed project module `AngelscriptJIT`;
- reuse Cache V2 identity and neutral engine-local route/reference values, not its store as a JIT provider;
- use Live Coding only as an explicit Editor refresh step after the module's first normal full build.

## 2. AngelScript 2.38 Evidence

### 2.1 Primary local sources

- `Reference/angelscript-v2.38.0/sdk/angelscript/include/angelscript.h`
- `Reference/angelscript-v2.38.0/sdk/angelscript/source/as_scriptfunction.cpp`
- `Reference/angelscript-v2.38.0/sdk/docs/doxygen/source/doc_adv_jit.h`

The documentation states that two JIT interface versions are supported and version 2 must be selected through `asEP_JIT_INTERFACE_VERSION`. The 2.38 public header contains:

- `asIJITCompilerAbstract` as a common type accepted by `SetJITCompiler`;
- v1 `asIJITCompiler::CompileFunction(..., asJITFunction*)` and `ReleaseJITFunction(...)`;
- v2 `asIJITCompilerV2::NewFunction(asIScriptFunction*)` and `CleanFunction(asIScriptFunction*, asJITFunction)`;
- `asIScriptFunction::SetJITFunction` and `GetJITFunction`;
- the `asEP_JIT_INTERFACE_VERSION` engine property.

The 2.38 `as_scriptfunction.cpp` behavior is the important part:

- after a function is ready it calls v2 `NewFunction`; the JIT compiler may compile now, later, or never;
- the compiler can publish later through `SetJITFunction`;
- replacing a non-null JIT function calls `CleanFunction` for the retired pointer;
- function cleanup/destruction also calls the selected interface's release/clean callback.

The release history identifies this v2 lifecycle as introduced in the 2.37 line and present in 2.38. Therefore it is a valid selective-backport reference, not evidence that the maintained fork already owns these semantics.

### 2.2 What 2.38 improves

The upstream v2 shape removes the forced synchronous “compile this one function now” behavior. That matters for StaticJIT because a generator or global optimizer can first observe the complete function set, do cross-function work, then attach results later. It also gives the engine a clear callback when an attached entry is replaced or destroyed.

These are real improvements over the current fork:

- delayed JIT publication;
- explicit function-ready notification;
- cleanup tied to script-function lifecycle;
- no need for a generator to masquerade as a synchronous execution compiler for every collection pass.

### 2.3 What 2.38 does not solve

The upstream interface remains insufficient for this plugin:

- only one `asJITFunction` pointer is published;
- it does not represent the fork's `jitFunction_Raw` and `jitFunction_ParmsEntry` entries;
- it has no binding-level user data or engine-local stable-reference slots;
- it has no stable function identity, execution-content identity, profile, environment, or ABI key;
- it has no provider/module generation or safe provider unload model;
- it does not define multi-engine ownership for externally compiled immutable code;
- it retains two public interfaces plus an engine property to select them.

Copying v2 literally would leave Raw/Parms ownership outside the lifecycle and would make the Runtime adapter maintain a second release protocol. That would perpetuate the current split rather than fix it.

## 3. Current Fork Evidence

### 3.0 Implementation recheck on 2026-08-12

Immediately before implementation, the current `main` checkout was re-read
against the pinned 2.38 source. The lifecycle evidence below still holds, with
one important fork drift from the original research wording:

- `Core/angelscript.h` now declares `asEP_JIT_INTERFACE_VERSION = 35`, and
  `as_scriptengine.cpp` accepts/stores values 1 or 2. This was added by the
  earlier stock-2.38 public-property-number compatibility work.
- The stored value is inert for JIT dispatch. `SetJITCompiler` still accepts
  only `asIJITCompiler*`; the public header still exposes only
  `CompileFunction` / `ReleaseJITFunction`; there is no
  `asIJITCompilerAbstract`, `asIJITCompilerV2`, `NewFunction`,
  `SetJITFunction`, `GetJITFunction`, or `CleanFunction` in the maintained
  fork.
- `asIScriptFunction` exposes only `GetByteCode` for JIT compilation. The
  internal `asCScriptFunction` still stores `jitFunction`,
  `jitFunction_Raw`, and `jitFunction_ParmsEntry` as three independently
  mutable public fields.
- `asCModule::Build` and `LoadByteCode` still call `JITCompile`, which invokes
  the synchronous old callback. `asCScriptFunction::DestroyInternal` still
  has no JIT retirement step, so the native SDK test's module-discard release
  limitation remains reproducible in source.

This drift strengthens rather than changes the selected design: task 1 removes
the inert version-selection property while keeping subsequent stock property
numeric values stable, and replaces the split old lifecycle with the single
maintained-fork complete-Binding contract. It does not add upstream v1/v2
adapters merely because the compatibility property was previously restored.

### 3.1 Primary local sources

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.h/.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITHeader.h/.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Embedding/AngelscriptNativeJitCompilerTests.cpp`

The current public fork interface still requires synchronous `CompileFunction` and exposes `ReleaseJITFunction(asJITFunction)`. The fork separately defines Raw and Parms entry types, while current script functions/generated dispatch use `jitFunction_Raw` and `jitFunction_ParmsEntry` beyond that release payload.

The native SDK tests explicitly preserve a known limitation: module discard does not call `ReleaseJITFunction`; a direct interface invocation is used to keep the missing engine-owned release visible. This is direct evidence that lifecycle repair belongs in the AS fork, not only in the UE provider layer.

### 3.2 Current global/static coupling

Current StaticJIT code contains several process-local assumptions:

- `FJITDatabase::Get()` returns one static database;
- generated registration uses numeric FunctionId;
- generated diagnostics markers are keyed by FunctionId;
- `FStaticJITCompiledInfo` has a single active-info constraint;
- generated info is paired to `FAngelscriptPrecompiledData::DataGuid`;
- generation temporarily calls `ScriptEngine->SetJITCompiler(&JIT)` and later restores the previous compiler;
- some generated call logic uses `FAngelscriptEngine::Get()` or engine arrays indexed by current numeric ids.

These facts explain why simply moving the existing generated `.cpp` into another UE module is not sufficient. The code would be physically external but still semantically tied to one process's cache/function-number layout and one global active database.

Static constructors from more than one generated translation unit—and potentially more than one loaded UE module—do all reach the single `FJITDatabase::Get()` accumulator. That gives the current code a limited “many registration sites” behavior, but not true multi-module ownership:

- `Functions.Add(FunctionId, ...)` overwrites/collides by process-local FunctionId;
- entries do not record the UE module or Provider that owns them;
- `FStaticJITCompiledInfo` enforces one active precompiled-data identity;
- `FJITDatabase::Clear()` clears every registration together;
- reference arrays and diagnostics are global rather than Provider/Engine scoped;
- module unload and Live Coding replacement cannot unregister one Provider generation precisely.

The new design therefore does not rename `FJITDatabase` and keep its semantics. It replaces it with a real multi-provider Registry plus per-Engine routes.

### 3.3 Comparison

| Concern | Current fork | AS 2.38 v2 | Selected design |
|---|---|---|---|
| ready notification | synchronous compile request | `NewFunction` | one `OnFunctionReady`-style callback |
| delayed publication | no | `SetJITFunction` | `SetJITBinding` for complete entry family |
| published payload | VM pointer plus separate unmanaged fork fields | one VM pointer | VM + Raw + Parms + UserData binding |
| cleanup | VM-only callback; incomplete module lifecycle | `CleanFunction` on replace/destroy | exactly-once complete binding retirement |
| interface selection | one old fork interface | v1/v2 property | one current non-versioned interface |
| stable identity | no | no | stable module/type/function/content/profile/ABI keys |
| external providers | global database | no | validated current-revision provider generations |
| multi-engine | global assumptions | unspecified | provider code shared, routes/refs/bindings engine-local |
| UE reflected calls | separate Raw/Parms fields | not represented | same lifecycle and provider entry |

## 4. Selected Unified JIT Lifecycle

The normative design uses one conceptual binding:

```cpp
struct asSJITFunctionBinding
{
    asJITFunction VMEntry;
    asJITFunction_Raw RawEntry;
    asJITFunction_ParmsEntry ParmsEntry;
    void* UserData;
};
```

The interface notifies the compiler after the function is ready and later allows a complete binding to be published. The engine/script function owns the current binding and calls the compiler's release callback exactly once when it is superseded or destroyed.

Implementation must explicitly cover:

- binding never published after a failed compile;
- replacing all entries atomically;
- clearing without a replacement;
- module/function/engine destruction;
- compiler replacement or removal;
- re-entrant execution while replacement occurs;
- the old compiler retaining release responsibility for bindings it created;
- safe delayed release when active calls retain an immutable snapshot.

Names can be adjusted to match upstream style during implementation, but the lifecycle and complete payload cannot be weakened.

## 5. Cache V2 Relationship

### 5.1 Evidence already present

`Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h/.cpp` already defines stable module/type/function/global/property identity builders, canonical hashing, function source/input digests, separate execution/debug content hashes, and profile/compatibility/context identity. The Cache V2 tests include stable identity, route snapshot, dependency, incremental generation, and fresh-engine restoration coverage.

This is the correct basis for StaticJIT matching. Reintroducing a StaticJIT-only GUID or matching a persisted numeric FunctionId would duplicate solved identity work and diverge from cache restoration.

### 5.2 Shared versus separate responsibilities

Shared neutral layer:

- stable identities and canonical hashes;
- immutable engine-local route/binding values;
- stable reference descriptor/value kinds;
- typed selection/miss information;
- safe generation publication primitives when identical.

Cache V2 remains responsible for:

- persisted cache records, manifests, filesystem transactions, compaction;
- semantic module/class/function restoration;
- dependency invalidation and startup policy.

StaticJIT remains responsible for:

- generated C++ and profiles;
- provider ABI and Native pointers;
- reference requirements for generated entries;
- provider generation, Editor refresh, Live Coding, JIT diagnostics.

The design therefore calls for renaming/extracting Cache-prefixed route/reference value types where they are genuinely general. It does not create a second StaticJIT route manager, and it does not make the cache store load shared libraries.

### 5.3 Fresh-engine proof

The strongest practical test is not loading the old hand-authored AOT `.Cache`. It is:

1. compile committed virtual AS fixtures in Engine A;
2. match and execute the test provider;
3. write Cache V2 to an isolated automation root;
4. destroy Engine A;
5. construct Engine B from scratch;
6. restore the unchanged artifact set;
7. resolve Engine B's local references and bind the same logical provider entries;
8. execute and compare behavior.

This proves stable identity without hiding process-local state inside a cloned Engine. The physical temporary script file is only backing storage; its virtual path is the identity input.

## 6. AngelscriptTestJIT Module Decision

### 6.1 Current state

Generated AOT fixture files currently live under:

- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/ASStaticJITAotFixture.as.jit.hpp`
- `.../AngelscriptJitInfo.jit.cpp`
- `.../AngelscriptJitCode_0.jit.cpp`

The test commandlet/generation/fixture code also lives in `AngelscriptTest/StaticJIT/AOT/`. This proves generation and execution, but it does not prove an external provider-module boundary because generated code is compiled into the same module that owns automation.

### 6.2 Selected module shape

Add `AngelscriptTestJIT` as Editor/PostDefault in `Angelscript.uplugin`:

```text
AngelscriptRuntime
    ^
    |
AngelscriptTestJIT       generated provider + test-native probes only
    ^
    |
AngelscriptTest          automation + test-only commandlet + fixtures + runner
```

This module is not a fourth product layer and is not a project JIT module. It exists only to exercise the real provider registration/link/load boundary and to compile checked-in code generated from plugin-owned test fixtures. It must be absent from non-Editor targets. It is predeclared in `Angelscript.uplugin`; project Scaffold never creates, renames, reads, verifies, or updates it.

Its inputs and outputs are fixed to the plugin test domain:

```text
AngelscriptTest committed fixtures
        -> -run=AngelscriptTestJIT -Mode=Generate|Verify
        -> AngelscriptTestJIT/Private/Generated
        -> fixed plugin-test ProviderId
```

It never reads the host project `Script/` root or JIT settings, derives a module name from `.uproject`, mutates `.uproject`, or writes into project `Source/`.

The test module remains free to create virtual AS paths, temporary physical backing files, isolated Cache V2 roots, multiple fresh engines, deterministic probes, and verbose logs. These facilities belong in small focused test helpers/files rather than production Engine methods.

### 6.3 Why not put commandlet in TestJIT

The generated carrier should remain replaceable and mechanically generated. Putting orchestration in it would reverse dependencies or make generator behavior part of generated output. `AngelscriptTest` already owns test commandlets and automation dependencies, so it is the stable owner of the separate `-run=AngelscriptTestJIT -Mode=Generate|Verify` plugin-fixture workflow.

## 7. Project Module Tool Decision

A real project uses the fixed UE module name `AngelscriptJIT` at `Source/AngelscriptJIT`. It is Runtime/PostDefault and privately depends on `AngelscriptRuntime`. The project commandlet belongs to `AngelscriptEditor`, not `AngelscriptTest`, so projects can use it without either test module. The ProviderId remains derived from the canonical project/source ownership domain rather than the fixed module name alone.

The commandlet contract is:

```text
-run=AngelscriptJIT -Mode=Scaffold
-run=AngelscriptJIT -Mode=Generate [-Profile=EditorDevelopment|GameDevelopment|GameShipping]
-run=AngelscriptJIT -Mode=Verify   [-Profile=EditorDevelopment|GameDevelopment|GameShipping]
```

Scaffold owns only explicitly marked generated/module boilerplate and performs structured `.uproject` mutation. Generate writes content-addressed per-function slices and exactly 32 stable bucket translation units. Verify regenerates elsewhere and compares without writes. The generator must retain unchanged bytes and refuse to overwrite user-owned conflicts.

The 32-bucket choice balances stable UBT source discovery with bounded incremental C++ compilation. One `.cpp` per AS function would make UBT project/source management excessively granular; one monolithic `.cpp` would rebuild all JIT code after any change. Stable per-function include slices inside fixed bucket translation units preserve fine-grained generated ownership while bounding the compile graph.

## 7.1 Multi-provider and multi-module decision

The Runtime Registry must support three distinct multiplicities:

1. **Several UE provider modules:** for example `AngelscriptTestJIT`, one project JIT module, and optional plugin-owned JIT modules may all be loaded concurrently.
2. **Several AS modules inside one Provider:** one project Provider normally contains functions from many `.as` files/modules; entries retain StableModuleKey and StableFunctionKey.
3. **Several AS Engines:** the process catalog is reusable, but every Engine resolves its own current functions, stable reference slots, Bindings, routes, miss reasons, and counters.

Each provider view carries a stable full ProviderId, diagnostic module/name, and content-derived ProviderGeneration. A newer generation of the same ProviderId supersedes the older generation at a safe point. Different ProviderIds coexist and unregister independently.

If different ProviderIds exactly claim the same complete current function identity, Runtime must not choose based on module load, feature registration, name order, or pointer address. The function receives `AmbiguousExactProvider` and uses VM while diagnostics list the candidates. If one conflicting Provider departs, the remaining unique exact entry may be published Native without invalidating Cache V2 or recompiling AS.

`AngelscriptTestJIT` follows this normal Registry path with a fixed plugin-test ProviderId. It may coexist with a project Provider in the Editor, but their source domains, StableModuleKeys, commands, manifests, outputs, and lifecycles are unrelated.

## 8. Editor And Live Coding Evidence

### 8.1 Local UE API evidence

The locally configured engine source (`C:/Program Files/Epic Games/UE_5.8`) exposes in `Engine/Source/Developer/Windows/LiveCoding/Public/ILiveCodingModule.h`:

- `IsEnabledForSession()`;
- `Compile()` and a result-bearing `Compile(flags, result)` overload;
- `IsCompiling()`;
- `GetOnPatchCompleteDelegate()`.

The implementation broadcasts the patch-complete delegate after the Live Coding reload phase. This is enough to build an explicit Editor state machine: generate → request compile → wait for patch completion → rediscover/validate a newer provider → publish routes.

The repository guidance identifies UE 5.7 as the product baseline while this machine's `AgentConfig.ini` currently points to UE 5.8. Therefore this API inspection proves local feasibility, not cross-version support by itself. Implementation must verify the same public surface on the actual supported engine version and keep all Live Coding references in the Editor module.

### 8.2 What Live Coding helps with

It can compile changed bucket translation units and load new content-addressed generated symbols without closing the Editor. A newly loaded module patch can publish a higher provider generation; Runtime can then validate it and replace affected engine-local bindings.

### 8.3 What Live Coding does not do

- It does not compile `.as`; normal AS hot reload remains first.
- It does not discover a brand-new module that has never completed normal UBT generation/build reliably enough to remove the first-build requirement.
- Patch completion alone does not prove the desired provider was compiled or is compatible.
- It is not available in packaged Runtime/Shipping.
- It should not run automatically on every save because C++ compile latency and errors would degrade the normal safe VM hot-reload loop.

The Editor action must therefore require exact newer provider validation after the delegate fires. Failure leaves VM execution correct and produces a diagnostic state.

## 9. Execution Identity And Edit Behavior

StaticJIT matching uses multiple dimensions instead of asking a text preprocessor to classify an edit heuristically:

- stable function key: logical declaration/owner/kind identity;
- execution-content hash: bytecode/semantic inputs that affect generated behavior;
- debug/source hash: line/source mapping that does not necessarily affect execution;
- profile/environment key: build/runtime assumptions;
- ABI revision: provider and helper layout/calling contract;
- stable reference requirements: engine-local dependencies needed by generated code.

Consequences:

- spaces, line endings, comments: normally keep execution content, may change debug/source identity;
- function body logic: changes execution content for that function and captured dependents;
- signature/UFUNCTION/metadata: changes function/ABI/reflection inputs and can trigger ClassGenerator work;
- property layout/base/interface/class structure: changes structural artifacts and affected dependent functions; Editor hot reload owns reinstancing;
- unchanged functions: keep exact provider eligibility even when a neighbor changes;
- deleted/renamed function: old binding is retired; its slice is removed on Generate.

StaticJIT does not independently decide dependency propagation. It consumes the compiler/Cache V2 semantic artifact identities and current function graph.

## 10. Rejected Approaches

### Copy upstream `asIJITCompilerV2` unchanged

Rejected because it manages one pointer and leaves Raw/Parms outside cleanup. The useful lifecycle is adopted into one complete fork interface instead.

### Keep both old and new JIT APIs

Rejected because no released compatibility target requires them. Dual APIs would complicate ownership and tests and encourage partial binding.

### Externalize only the current generated `.cpp`

Rejected because FunctionId, DataGuid, `FJITDatabase`, active compiled info, process addresses, and global Engine assumptions would remain.

### Give StaticJIT its own stable-key implementation and route manager

Rejected because Cache V2 already owns the canonical artifact identity inputs and has fresh-engine route tests. Shared concepts become neutral Runtime artifacts.

### Make one `.cpp` per function

Rejected as the UBT source graph would churn excessively at project scale. Per-function include slices plus 32 fixed translation units preserve deterministic incremental ownership.

### Keep one monolithic generated `.cpp`

Rejected because every script logic change would cause one large compile and impede Live Coding iteration.

### Auto-Generate and Live Code on every `.as` save

Rejected because AS hot reload should return to correct VM execution immediately. Native refresh is an explicit optimization step with its own compile/failure state.

### Put automation or commandlets in `AngelscriptTestJIT`

Rejected because the carrier must remain generated-code-only and one-way dependent. Test orchestration stays in `AngelscriptTest`.

### Let project generation depend on `AngelscriptTest` tooling

Rejected because test modules are not product tooling and are Editor-test scoped. Project `AngelscriptJIT` Scaffold/Generate/Verify belongs to `AngelscriptEditor`; only deterministic Runtime emission/ABI primitives are shared with the test generator.

### Keep one global merged FunctionId database for several modules

Rejected because registration/load order, FunctionId collision, all-provider clear, single active info, and missing owner-scoped unload make it unsafe for tests, project Providers, plugins, Live Coding, and multiple Engines.

### Require a legacy `.Cache` beside generated test C++

Rejected because it repeats the old whole-cache/DataGuid coupling and does not prove Cache V2 fresh-engine identity reconstruction.

## 11. Implementation Consequences

The first implementation code must be AS lifecycle tests and lifecycle ownership, not module scaffolding. Creating `AngelscriptTestJIT` first would only move code while preserving an unsafe interface and unstable matching.

The old global route must remain temporarily as a comparison path until the new provider route passes source-engine, Cache V2 fresh-engine, multi-engine, UASFunction, Editor, and packaged parity. It is removed late and in one explicit cutover; it is not retained as compatibility.

Testing should be split by responsibility:

- native AS lifecycle;
- neutral artifact/route values;
- provider ABI/layout;
- stable reference resolution;
- generator/scaffold/verify;
- test-provider source engine;
- test-provider Cache V2 fresh engine;
- route/UASFunction refresh;
- Editor action/Live Coding state machine;
- packaged profiles;
- diagnostics/dump tooling.

This avoids growing the already-large AOT, diagnostics, or Cache schema test files into a new monolith.

## 12. Final Decision Record

- **JIT API:** one breaking, non-versioned complete-binding lifecycle in the maintained AS fork.
- **Stable match:** full function + execution content + profile/environment + ABI identity; numeric FunctionId never persists.
- **References:** provider declares stable descriptors; each Engine resolves immutable local slots.
- **Routes:** neutral Runtime artifact routes shared conceptually with Cache V2, owned per Engine.
- **Test module:** Editor-only `AngelscriptTestJIT`, generated code/probes only.
- **Test owner:** `AngelscriptTest`, including the isolated `AngelscriptTestJIT` Generate/Verify commandlet and runner; it has no project inputs.
- **Project module:** fixed `AngelscriptJIT` at `Source/AngelscriptJIT`; no project-name prefix/suffix.
- **Project tool owner:** `AngelscriptEditor`, providing project `AngelscriptJIT` Scaffold/Generate/Verify without test-module dependencies.
- **Registry:** several UE Provider modules and multi-AS-module Providers coexist by ProviderId; same-Provider generations replace safely; cross-Provider exact conflicts use VM.
- **Generation:** content-addressed function slices, exactly 32 fixed bucket translation units, explicit profiles.
- **Editor:** current AS compile/hot reload authoritative; exact JIT is optional.
- **Live Coding:** explicit Generate/Refresh after one full build; validate newer provider before binding.
- **Shipping:** immutable exact provider where available, correct VM fallback/rejection policy, no Editor dependency.
- **Compatibility:** none for old JIT APIs, providers, FunctionId maps, DataGuid pairing, or test `.Cache`.

## 13. Milestone 1 Implementation Follow-Up

The 2026-08-12 implementation rechecked the research against the maintained fork and completed the first lifecycle cut:

- `asIJITCompiler` is now one non-versioned `OnFunctionReady` / `ReleaseFunctionBinding` contract;
- `asSJITFunctionBinding` owns VM, Raw, Parms, and opaque user data as one public value;
- eligible source-compiled, detached-compiled, and bytecode-restored functions receive readiness notification without requiring immediate publication;
- `asCScriptFunction` clears a retired Binding before the callback and releases it exactly once on replacement, clear, module discard, function destruction, compiler replacement/removal, and engine shutdown;
- delayed publication is valid while the publishing compiler remains installed on the function's engine;
- source generation now enumerates completed module functions explicitly and no longer installs itself as the engine's execution compiler;
- the removed fork callbacks, separate public JIT entry fields, and interface-version engine property have no remaining source use.

Active-reader snapshot retention and concurrent Native publication are intentionally not claimed here; they remain task 4.5.

## 14. Milestone 2 Neutral Artifact Follow-Up

The pre-implementation recheck found that canonical module, type, function,
execution-content, debug-content, profile, environment, and compatibility
identity builders were already neutral Runtime artifacts under
`Core/Artifacts`. The remaining reusable concepts were the Cache-named stable
reference value, execution route, live route, snapshot, ordinal, and
per-Engine route state. Cache persistence policy and restore coordination were
not moved into StaticJIT.

The implementation therefore:

- introduced `FAngelscriptArtifactReference` with the existing frozen reference-kind wire values;
- introduced neutral `FAngelscriptFunctionRoute`, typed route generation, immutable shared snapshots, and `EAngelscriptArtifactMatchResult`;
- made `FAngelscriptEngine` the sole per-Engine owner of the neutral route state and renamed the public lookup to `ResolveFunctionRoute`;
- migrated Cache V2 codecs, restore, diagnostics, dependency graphs, tests, ClassGenerator, dump, and StaticJIT consumers to the neutral value vocabulary without adding a second identity or route manager;
- retained Cache diagnostics' `PublicationOrdinal` field as a Cache-specific DTO compatibility surface while sourcing it from the neutral typed generation;
- proved equal stable identity and independent live function/reference resolution in two Engines whose transient FunctionIds were deliberately reordered.

Provider matching, stable provider reference slots, ProviderId generations,
and multi-Provider ambiguity policy are not claimed by this milestone; they
begin in task group 3.
