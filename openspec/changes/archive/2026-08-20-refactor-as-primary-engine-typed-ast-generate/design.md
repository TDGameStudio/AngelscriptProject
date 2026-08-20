## Context

Typed semantic HIR already lives on `asCScriptFunction::scriptData->typedSemanticFunction` after a capture-on source compile. TypedASTJIT emits C++ from that in-memory HIR. Today Generate still creates a second `FAngelscriptEngine` (`EAngelscriptEnginePurpose::StaticJITGeneration`) because:

1. The requested artifact profile may differ from the live Editor (`EditorDevelopment` vs `GameShipping`).
2. Cache V2 ExactStartup restores bytecode only, so a restarted Editor has no HIR.
3. Native-form / reviewed native-call descriptors are collected only when `bCollectStaticJITCompatibilityBinds` is true (default false on the primary Engine).
4. Generation source-graph scope historically excluded plugin script roots and skipped ClassGenerator materialization.

The product decision is: freeze Static backend and matching target profile at Editor start; restart to switch; keep StaticJIT as a development-time generator. A sibling Engine for the *matching* profile is waste. The contained generation Engine is **kept** as the way to compile a *different* profile (Editor convenience or commandlet/CI). HIR capture is optional per Engine: `"bytecode"` never captures; `"typed-ast"` captures only on the Engine compiling that request.

`feature-as-typed-semantic-aot` forbade Cache V2 HIR. This change overturns that persistence rule with an optional sidecar. Dump files remain write-only diagnostics.

## Goals / Non-Goals

**Goals:**

- Matching-profile Editor Generate reads the primary Engine and never constructs a generation Engine for that request.
- Primary HIR capture is optional and frozen at Engine create. `"typed-ast"` matching Generate requires that HIR already be present; it does not spawn an extra Engine to obtain it. Hot Reload refreshes captured HIR.
- Cache V2 ExactStartup can restore HIR through an optional sidecar when capture-on sessions need it.
- Explain and improve Collect binds so Generate can emit reviewed direct native calls without forcing a permanent per-Engine collect flag.
- Editor and commandlet MAY emit multiple `.jit.cpp` trees in one action: matching profile from primary, other profiles from sequential generation Engines. Commandlet remains the pack-time entry.

**Non-Goals:**

- Holding two target-profile generation Engines alive at once. Sequential extra Engines are allowed.
- A production `"dual"` backend, Runtime JIT, or LLVM/MIR work.
- Reloading `.hir.txt` / `.hir.json` as compiler input.
- Serializing raw `asCTypedSemanticFunction` pointers or engine-local `resolvedFunctionId` values.
- Changing packaged-game execution: packaged runtime still consumes already-built Provider DLLs, not Generate.
- Making a native-form display name imply cross-DLL linkability.
- Skipping per-Engine bind lambda replay by caching all bind information at process start. See `attachments/bind-replay-vs-cached-bind-snapshot.md`.

## Decisions

### 1. Matching-profile Generate uses the primary Engine

**Choice:** When the Generate request's `TargetProfile` equals the primary Engine's frozen target profile, orchestration builds `CompiledSourceGraph` from the live engine (plus a read-only source-inventory freshness check). `"bytecode"` uses the primary bytecode graph. `"typed-ast"` uses primary verified HIR. Neither path may construct a generation Engine for that matching request.

**Why not a sibling Engine:** Bind replay, preprocess, and compile of the full graph already happened for the Editor. A second Engine drifts (plugin roots, ExactStartup skip, collect-binds, purpose flags) and doubles RAM/CPU.

**Rules:**

- Freeze the Hot Reload queue for the request. Do not ForceClean, FullReload, or reinstance as part of Generate.
- If source inventory/content/profile is stale, return `AuthoritativeEngineStale` and tell the caller to use the normal Hot Reload path first.
- If `"typed-ast"` matching Generate runs while primary capture is off or HIR is missing, return `CaptureRequired` / `MissingTypedHIR`. Do **not** silently create a generation Engine to fetch matching-profile HIR.
- BytecodeJIT matching-profile Generate follows the same "no sibling Engine" rule. Do not leave BytecodeJIT on a temp Engine and TypedASTJIT on primary.
- ClassGenerator on the primary Engine has already materialized script reflection. Generate must still be side-effect-free with respect to packages, routes, and UObject mutation: read descriptors and HIR, write only owned Provider files.

### 2. Non-matching profiles keep the generation Engine (Editor or commandlet)

**Choice:** Keep `EAngelscriptEnginePurpose::StaticJITGeneration` for any Generate whose target profile is **not** the primary Engine profile. Editor and `UAngelscriptJITCommandlet` share that path. Both MAY request multiple profiles in one action.

**How a batch works:**

1. Matching profile (`EditorDevelopment` in a live Editor): emit from the primary Engine. No extra Engine.
2. Each remaining profile (`GameDevelopment`, `GameShipping`): create one generation Engine, apply that profile's traits, compile (capture HIR only if that request is `"typed-ast"`), emit `Generated/<Profile>/`, destroy the Engine. At most one extra Engine is alive.
3. Commandlet/CI with no live Editor primary: every requested profile uses a generation Engine, sequentially. This remains the pack-time entry (`Tools\RunAngelscriptJIT.ps1`).

**Why keep the extra Engine at all:** Dev/Shipping script surfaces are not the Editor surface. One `asCScriptEngine` cannot host both. Recreating the primary Engine as Shipping would destroy Editor semantics. Spawning a commandlet from a live Editor is valid but heavy; an explicit in-Editor "Generate Shipping" may use the same contained Engine the commandlet already uses.

**Why not two extra Engines at once:** RAM and containment. Sequential is enough to produce three trees.

**HIR is optional on that Engine:** `"bytecode"` Generate does not enable capture. `"typed-ast"` Generate enables capture on *that* generation Engine only, then throws the Engine away. Dump remains a separate optional request.

Existing output layout stays: `Source/AngelscriptJIT/Generated/<Profile>/` and TestJIT `Generated/EditorDevelopment`. Filenames already include the profile.

### 3. Cache V2 TypedHIR sidecar

**Choice:** Add optional record kind `TypedHIRSidecar` (next kind after `ModuleSnapshot = 7`), linked from `FunctionBody` the same way `DebugSidecar` is linked. Payload is pointer-free, versioned, and keyed by stable function identity (the dump's `stableTarget` idea: module key + declaration), not engine-local IDs.

**Store:**

- Nodes use integer IDs inside the sidecar (same arena shape as live HIR).
- Call/global/type references use stable keys + declaration ABI, never `asCScriptFunction*`.
- Absence is an unset optional plus a profile-specific `function-typed-hir-absent` coordinate, never a zero RecordId or empty-payload hash.
- FunctionBody bytecode bytes stay HIR-free. Capture-on vs capture-off bytecode archives remain equal when both omit the sidecar (bytecode-only Editor) and differ only by sidecar records when capture-on Editor publishes HIR.

**Restore:**

- ExactStartup remaps sidecar → new `asCTypedSemanticFunction` on the restored function.
- Missing sidecar on a capture-on typed-ast Engine is an ExactStartup miss for that module/function closure (prefer miss-and-source-compile over bytecode-without-HIR). Do not invent HIR from bytecode.
- Old caches without the kind remain valid bytecode caches. Unknown-kind readers treat a new kind as ineligibility, not silent skip, unless the loader is explicitly version-gated to ignore optional sidecars. v1 of this change: typed-ast Editor that requires HIR refuses ExactStartup when the selected generation lacks sidecars.
- `"bytecode"` sessions never require the sidecar and never restore it onto functions.

**Still forbidden:** `SaveByteCode`, public `angelscript.h` IR ABI, dump-file reload, packing raw C++ object graphs.

This is the same observer-style split as DebugSidecar: execution content stays independently verifiable; HIR is optional developer/generate payload.

### 4. Collect binds: what it is, and how to improve it

**What it is today:** `FAngelscriptEngineConfig.bCollectStaticJITCompatibilityBinds` (default `false`). Comment: collect native-form bindings without publishing them into the live route snapshot.

The process does **not** store finished bind data. Static `FAngelscriptBind` objects register callbacks into a sealed collection (`void (*)(FAngelscriptBinds&)`). Every `FAngelscriptEngine` initialization calls `ExecuteRegisteredBinds`, which **replays every lambda into that Engine**. The lambda both:

1. Registers types/functions into that Engine's `asIScriptEngine` (required, per Engine).
2. Calls `.NativeFunction` / `.NativeMethod` / `ExternalNativeCall`, which currently try to hang a `FScriptFunctionNativeForm` and reviewed descriptor on **that Engine's** `asIScriptFunction*`.

If collect is off, step 2 allocates then immediately `delete`s. If collect is on, the form lives in `FAngelscriptNativeFormState` until that Engine dies. Generate looks up by pointer on the Engine that just bound.

So `NativeFunction` **does run once per Engine bind replay today**. A generation Engine is not an extra "from native" pass; it is a full bind replay plus compile. The collect flag only decides whether the side-effect heap is kept.

**Improvement:** keep per-Engine bind replay. Add a process-lifetime **recipe catalog** filled as a side effect of those replays, keyed by stable declaration identity (and bind-surface / target profile, because Editor vs cooked bind sets can differ). The first replay that actually registers a declaration inserts the recipe (C++ spelling, HeaderInline descriptor, ABI snapshot). Later replays of the same declaration upsert or no-op. Generate looks up by declaration key from the compiled call, not by `asIScriptFunction*`.

The catalog is **not** filled at static-init from lambdas alone: ABI identity needs the registered function. It is **not** a substitute for replaying lambdas into a generation Engine that has a different profile. It **does** mean matching-profile Editor Generate can emit reviewed calls after the primary Engine's normal bind replay, with collect left false and without a sibling Engine whose only job is collect.

Per-Engine `AddNativeForm` MAY remain for BytecodeJIT pointer lookup until emit is switched to the catalog. Missing catalog entries still degrade to bridge.

Store Header / Include on the recipe (`NativeFunctionHeader`, reviewed `ExternalNativeCall`). BytecodeJIT already collects those via `GenerateCall` + type `CppHeader`; see `attachments/bytecodejit-native-form-and-headers.md`. A display name without Include is not HeaderInline.

**Still true:** missing linkage degrades to bridge or typed fallback; HeaderInline vs module-exported remain distinct; a display name is not DLL-linkable.

Discussion notes: `attachments/collect-binds-and-native-form-catalog.md`.

### 5. Capture flag is optional and frozen at Engine create

Capture remains frozen at `asCScriptEngine` create (`SetTypedSemanticIRCapture` / `bCaptureTypedSemanticIR`). It is **not** required for every Editor session.

- `"bytecode"` primary and `"bytecode"` generation Engines stay capture-off.
- A `"typed-ast"` generation Engine turns capture on for that request only.
- A primary Engine MAY start capture-on so matching-profile TypedASTJIT Generate can read live HIR (and ExactStartup can restore sidecars). It MAY stay capture-off; then matching `"typed-ast"` Generate fails closed instead of creating an extra Engine.
- Hot Reload Full/Soft recompile goes through `CompileModules`; when capture is on, new functions get HIR and discarded functions drop it with the old module. `as.Cache.ForceClean` FullReload recaptures from source (and republishes sidecars).

Static backend or capture-policy change still requires Editor restart. Do not toggle capture on a live Engine.

### 6. HIR dump stays a separate request

`UAngelscriptHIRDumpCommandlet` remains independent of Generate. Matching-profile dump MAY read primary HIR. Non-matching-profile dump still uses an isolated Engine inside that commandlet process. Dump files are never TypedASTJIT inputs.

## Risks / Trade-offs

- [Sidecar size] → HIR can dwarf bytecode. Keep it optional, profile-specific, Saved-only; Shipping packaged runtime does not need it. Budget limits follow existing Cache V2 read limits.
- [Restore remap bugs] → Verifier must re-run after remap; failure is ExactStartup miss, not a half-attached IR graph. Golden tests compare dump-stable keys, not pointers.
- [Primary Generate mutates Editor] → Freeze Hot Reload; before/after containment snapshots on packages, routes, CDOs. Write only owned JIT files.
- [Catalog vs per-Engine forms] → BytecodeJIT generation Engines may keep attach-on-function until catalog lookup is proven; both paths must yield identical emit for the same declaration.
- [Commandlet vs Editor drift] → Editor non-matching Generate and commandlet Generate must call the same generation-Engine helper. Verify mode already exists. Do not fork a second emitter.
- [Optional primary capture vs typed-ast Generate] → matching `"typed-ast"` without primary HIR fails with `CaptureRequired`; never auto-spawn an extra Engine for the matching profile.
- [CRLF goldens] → TestJIT generated files must stay LF; do not "fix" determinism by rewriting goldens as CRLF.

## Migration Plan

1. Add sidecar kind + codec + tests; old caches remain bytecode-valid.
2. Make primary capture optional; ExactStartup restores sidecars only into capture-on Engines.
3. Switch matching-profile Generate off the temporary Engine (bytecode and typed-ast).
4. Introduce native-form catalog; keep the collect flag as a compatibility overlay until tests pass.
5. Keep generation Engines for non-matching profiles; wire Editor batch and commandlet through the same sequential helper.
6. Gate matching-profile Editor so it can no longer construct a generation Engine.

Rollback: leave generation Engines in place for every profile, including matching. Cache generations without sidecars remain loadable as bytecode.

## Knowledge attachments

Narrative notes from the 2026-08-18 discussion (not additional requirements):

- `attachments/scheme-overview.md`
- `attachments/collect-binds-and-native-form-catalog.md`
- `attachments/bytecodejit-native-form-and-headers.md`
- `attachments/bind-replay-vs-cached-bind-snapshot.md`

## Open Questions

- Whether GameDevelopment/GameShipping are offered in the Editor Generate UI by default, or only via explicit profile lists / commandlet (recommend: explicit; pack-time still uses commandlet).
- Whether typed-ast ExactStartup misses the whole generation or only functions lacking sidecars (recommend: module-level miss; mixed bytecode-without-HIR inside a capture-on module is illegal).
- Whether developer HIR dump for `EditorDevelopment` reads primary HIR in-process or always uses the dump commandlet process (recommend: in-process read of primary when capture is on; dump commandlet / generation Engine for isolation tests and other profiles).
