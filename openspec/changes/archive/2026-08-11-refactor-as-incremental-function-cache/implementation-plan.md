# Cache V2 Vertical Execution Plan

This is the current implementation handbook. The superseded horizontal plan and
its exact source-authoring packets are preserved at
`history/pre-vertical-refactor-2026-08-09/implementation-plan.md`. Historical
evidence remains in `verification.md`; it is not repeated here.

## 1. Outcome and non-negotiable boundaries

The completed change delivers one Runtime-owned Cache V2 service that:

- creates its first Saved generation from a normal authoritative compile;
- restores an unchanged generation with zero preprocess, parse and function-
  compiler calls;
- preprocesses/parses a changed module through the existing authoritative
  frontend, then retains unchanged function artifacts through per-invocation
  `FunctionInputDigest` decisions;
- persists function/type/state records granularly but activates a complete
  `ModuleSnapshot` atomically;
- exposes stable function/content/profile identity to the sibling StaticJIT
  provider without exposing Cache storage or publication state;
- works in Editor, PIE, Development and Shipping, with real PIE/package matrices
  deliberately executed last;
- removes the production `PrecompiledScript.Cache` path without compatibility,
  migration or dual-write support.

The following are not simplifications available to an implementation slice:

1. `StableFunctionKey`, `FunctionSourceDigest`, `FunctionInputDigest` and
   `FunctionContentHash` remain distinct full-width identities.
2. Numeric FunctionId, pointers, source lines, absolute paths and generation/
   pack/provider IDs never become persistent function identity.
3. FunctionBody may be reused independently; TypeSchema, ModuleState and active
   module publication still obey their atomic graph/lifecycle boundaries.
4. A cache failure is a miss/recompile. Different-source stale behavior is never
   authorized at fresh startup.
5. StaticJIT mismatch changes only Native/VM routing. It does not invalidate a
   valid VM FunctionBody or Cache generation.

`vertical-execution-refactor-2026-08-09.md` is the concise rationale and flow
authority for this execution reordering.

## 2. Runtime paths to build and prove

### 2.1 Exact unchanged path

The lookup path consumes only directly discoverable inputs before selecting a
historical dependency candidate:

```text
DirectSourceInputs
  raw bytes, logical path, mount/provider identity, explicit options,
  profile/context and stable provider/hook versions
        |
        v
canonical direct-input digest -> Current SourceIndex candidate
        |
        v
validate persisted include/generated/preprocess dependency fingerprints
        |
        +-- mismatch/unavailable -> changed path
        |
        +-- exact -> validate generation and restore ModuleSnapshot
                     Preprocess = Parse = FunctionCompiler = 0
```

The loader must not rerun the preprocessor merely to reconstruct the candidate's
include graph. Candidate state is bounded and disposable; a lost candidate causes
normal compilation.

### 2.2 Changed-module path

```text
direct input or candidate dependency changed
        |
        v
existing preprocess / parse / declaration / layout authority
        |
        v
ModuleInterface + TypeSchema + environment authority ready
        |
        v
per stable function invocation:
  source digest differs       -> compile
  dependency cannot resolve   -> compile
  input digest differs        -> compile
  exact input + valid body    -> attach cached FunctionBody
  unstable persistent coords  -> NotCacheable, compile without capture
        |
        v
ModuleState + graph + ClassGenerator/lifecycle success
        |
        v
reuse equal RecordIds, write only new content, publish complete generation
```

A full compile of every function is always the authoritative fallback and the
clean-vs-cached oracle. It is not the final incremental-hit requirement.

## 3. Vertical dependency graph

```text
V0 accepted identity/wire + execution reset
  |
  +--> V1 complete in-memory module artifact transaction
  |       record codecs -> one factory -> ModuleSnapshot graph -> clean capture
  |
  +--> V2 generation data plane and immutable Store
  |       Pack/Manifest -> filesystem publication -> cold generation
  |
  +--> V3 exact source candidate and warm restore
  |       DirectSourceInputs -> candidate validation -> zero-work restore
  |
  +--> V4 changed-module fallback/oracle
  |       full compile -> semantic RecordId diff -> incremental publication
  |
  +--> V5 per-function compiler reuse
  |       invocation hook -> actual deps -> input digest -> VM attach -> parity
  |
  +--> V6 lifecycle and StaticJIT isolation
  |       Editor/PIE/runtime -> routes -> Current/Pending -> diagnostics
  |
  +--> V7 cutover and final acceptance
          old cache removal -> package -> real PIE -> Dev/Shipping -> benchmark
```

Pure Pack/Manifest and Store work may proceed as soon as their immutable byte
contracts are available; it need not wait for every TypeSchema negative matrix.
Conversely, no untrusted Saved module may activate until all records reachable by
that selected ModuleSnapshot pass their required decoder, Budget, private VM codec
and graph validation.

## 4. File and ownership map

Existing Runtime ownership:

- `Core/Artifacts/AngelscriptArtifactIdentity.*` — shared stable identity and
  StaticJIT-facing function artifact tuple.
- `Cache/AngelscriptCacheArchive.*` — record envelope and common result taxonomy.
- `Cache/AngelscriptCacheSemanticRecords.*` — SourceIndex/ModuleInterface and
  common semantic DTOs/builders.
- `Cache/AngelscriptCacheTypeSchema.*` — TypeSchema producer/private decoder and
  local validation.
- `Cache/AngelscriptCacheRemainingRecordTypes.h` — remaining pointer-free DTOs.
- `Cache/AngelscriptCacheDecodedRecord.*` — sole candidate/factory/final immutable
  record boundary.
- `Cache/AngelscriptCacheManifestPack.*` — deterministic Pack/Manifest data plane.

Planned Runtime files should remain separated by responsibility:

- `Cache/AngelscriptCacheModuleGraph.*` — sole `ValidateModuleSnapshotGraph`.
- `Cache/AngelscriptCacheStore.*` — Saved namespace, immutable object publication,
  pinned read sessions and root slots; no compiler semantics.
- `Cache/AngelscriptCacheSourcePlanner.*` — DirectSourceInputs, canonical digest,
  bounded candidate validation and affected-module planning.
- `Cache/AngelscriptCacheCompilerBridge.*` — host side of the maintained-fork
  invocation hook, actual dependency capture and clean-vs-cached counters.
- `Cache/AngelscriptCacheVmArtifactCodec.*` — private versioned function execution/
  debug validation and attachment.
- `Cache/AngelscriptCacheService.*` — one per-engine lifecycle/orchestration owner.
- `Cache/AngelscriptCacheDiagnostics.*` — deterministic snapshot/JSON reporting.

The maintained AngelScript fork owns only Unreal-free hook descriptors and the VM
adapter needed to restore `asCScriptFunction`. It must not know Pack, Manifest,
filesystem, UObject, PIE or StaticJIT Provider concepts.

Test ownership:

- keep narrow families in separate `AngelscriptTest/Cache/*.cpp` files;
- use a real isolated `FAngelscriptEngine` fixture for compiler/module behavior;
- inline AS fixtures follow `Documents/Rules/ASInlineFormattingRule.md` and the
  repository Angelscript test guide;
- test-only observers inspect the production path and compile out of Shipping;
- no test serializer, semantic rule table, Store or graph alternative is allowed.

## 5. V0 — accepted foundation and plan reset

Accepted and retained:

- domain-separated full-width stable keys and function artifact coordinates;
- common canonical writer/reader, record envelope and Budget baseline;
- SourceIndex/ModuleInterface baseline;
- frozen remaining-record, TypeSchema, Manifest/Pack and Store byte authorities;
- current TypeSchema physical decoder and partial shared local validation;
- historical verification and implementation issue ledgers.

V0 closes when the current OpenSpec refactor passes strict validation and its
historical plan/tasks/status copies match their recorded hashes. It does not claim
new Runtime behavior.

## 6. V1 — complete in-memory module artifact transaction

Goal: a representative real AS module can be authoritatively compiled, frozen to
the complete pointer-free record graph, decoded through the sole factory, validated
and compared in memory without filesystem or active-module mutation shortcuts.

Execution order:

1. Finish the current small Dependency family as a linear exact-set validator.
   It validates TypeSchema record self-consistency only; no source classifier or
   dependency database is introduced.
2. Finish remaining TypeSchema local/hash/layout obligations needed by supported
   real module forms. Unsupported/unrepresentable forms fail closed.
3. Implement private decoders for ModuleState, FunctionBody, DebugSidecar and
   ModuleSnapshot plus seven-kind RecordId recomputation and immutable promotion.
4. Implement the sole per-module graph traversal and exact Required/Forbidden
   coverage/owner/reference validation.
5. Add an isolated clean-compile capture fixture that produces one SourceIndex,
   ModuleInterface, TypeSchema set, ModuleState and per-function bodies/sidecars.
6. Round-trip the complete selected module in memory and prove no partial output or
   engine mutation on every failure.

V1 exit evidence:

- complete `Angelscript.TestModule.Cache.Archive` and module-artifact focused
  prefixes GREEN;
- one full Runtime/Test module build after all new test TUs compile;
- clean capture produces stable keys/content hashes in two independent engines;
- all selected records pass one factory/graph path and one cumulative Budget;
- corruption or unsupported private VM payload becomes a typed miss before attach.

## 7. V2 — generation data plane, Store and cold publication

Goal: the in-memory record set becomes a deterministic generation and is published
under a disposable isolated cache root using real filesystem semantics.

Execution order:

1. Implement deterministic Pack payload/index construction and None/Zlib codec
   validation from canonical semantic payloads.
2. Implement complete Manifest roots, record locations and exact reachability.
3. Prove serial, reverse and seeded-random input order yields identical bytes/IDs.
4. Implement strict Saved-only namespaces and `-as-cache-root` replacement.
5. Implement temporary write, flush/close, final reopen validation and immutable
   publish-if-absent for Packs and Manifests.
6. Implement namespace lock, reread/rebase and old-or-new root publication.
7. Implement pinned read sessions and cumulative cross-record Budget; keep GC/
   compaction explicit and outside startup.
8. Connect successful clean capture to cold generation publication without forced
   process exit.

V2 exit evidence:

- deterministic Pack/Manifest prefix GREEN;
- Store fault-injection covers every write/flush/rename/root boundary;
- a cold test-engine compile writes a valid generation and reopens it in a fresh
  read session;
- cancellation/corruption never damages a previously committed root;
- no compaction runs during cold or warm startup.

Pack target 64 MiB remains writer policy. V7 benchmarks 4/16/64 MiB before any
performance claim.

## 8. V3 — direct source candidate and exact warm restore

Goal: a second unchanged launch restores the V2 generation without invoking the
preprocessor, parser or function compiler.

Execution order:

1. Define `DirectSourceInputs` and its canonical digest from raw bytes, typed logical coordinates, stable
   provider/hook identity/version/configuration, explicit options and profile.
2. Separate persisted include/generated/preprocess edges and fingerprints as one
   bounded, disposable candidate inside the Current SourceIndex; V1 adds no
   separate action-index database or history file.
3. Implement SourceIndex production discovery and action/candidate selection.
4. Validate candidate dependency contents without reconstructing them through the
   preprocessor.
5. Restore declarations/types/state/functions, rebuild current-engine numeric IDs
   and stable routes, then atomically activate the complete module.
6. Record exact counters and guarantee that an unchanged launch writes no new
   generation solely because it started.

V3 exit evidence:

- cold then warm isolated test-engine scenario;
- warm counters exactly `Preprocess=0`, `Parse=0`, `FunctionCompiler=0`;
- add/delete/rename/include/options/provider/profile mutations reject the exact
  candidate with deterministic reasons;
- an unrelated ineligible provider/hook scope does not poison another module;
- bad cache bytes miss/rebuild rather than authorize stale different-source code.

## 9. V4 — changed-module full-compile oracle and incremental publication

Goal: changed source uses the existing authoritative frontend, compares new
semantic artifacts with the previous generation and writes only new content.

Execution order:

1. Reprocess the affected module closure using existing preprocessor/HotReload
   ownership; do not add file-diff semantic heuristics.
2. Force a clean/full function compile mode and capture the complete new artifact
   transaction.
3. Compare semantic RecordIds, not Pack bytes, to classify Interface, TypeSchema,
   ModuleState, FunctionBody and DebugSidecar changes.
4. Reuse unchanged RecordIds/packs and publish a new complete ModuleSnapshot and
   Manifest containing only the exact reachable set.
5. Use module/public-interface and typed semantic dependencies for conservative
   dependent-module propagation; uncertainty is a safe miss.

V4 exit evidence includes body-only, signature, class/property/layout, global/
initializer, include/options and debug-only mutations. A body-only change must keep
its StableFunctionKey, change its content when semantics change, retain unaffected
record IDs and avoid unrelated-module invalidation. The executable coordinate,
production-admission and evidence matrix is frozen in
`v4.5-clean-oracle-mutation-matrix.md`; cleanly mutating already-serialized test
fixtures is insufficient producer evidence.

## 10. V5 — per-function compiler reuse and equivalence

Goal: changed modules retain valid FunctionBodies before `asCCompiler` is invoked
for those individual builder invocations.

Execution order:

1. Add the Unreal-free, kind-tagged invocation descriptor to normal/generated/
   factory/public-single/lambda builder families.
2. Produce `FunctionSourceDigest` after authoritative parse/declaration state is
   available; it never classifies a file before preprocessing.
3. Capture canonical actual dependencies on successful misses and resolve them
   against current ModuleInterface/TypeSchema/ModuleState/environment authorities.
4. Compute `FunctionInputDigest` and select `Restored`, `Miss`, `RejectedCorrupt`
   or `NotCacheable` per invocation.
5. Validate/rebuild the full private VM function artifact before any active-engine
   mutation; raw bytecode copy is forbidden.
6. Compare cached mode with forced-clean mode for every supported invocation family
   and observable behavior.

V5 exit evidence:

- one isolated body edit compiles only the correct invocation closure;
- unchanged functions are real compiler hits, not merely post-compile dedupe;
- dependency ABI/layout/hard-value mutations selectively miss consumers;
- clean and cached ModuleInterface/TypeSchema/ModuleState/function content and VM
  behavior are equal;
- unstable lambda/snippet coordinates are explicit `NotCacheable` and compile
  normally;
- two engines never share current FunctionId or mutable hook state.

## 11. V6 — Editor, PIE, packaged runtime and StaticJIT isolation

Goal: one per-engine Cache service maintains generations through real lifecycle
transactions while the sibling provider independently selects Native routes.

Execution order:

1. Add the per-engine service and reentrancy-defined mutation gate.
2. Freeze pointer-free publication DTOs only after successful module swap,
   ClassGenerator/reflection and required reinstancing.
3. Implement Editor initial compile, code-only reload, structural reload, PIE
   active-Current versus `PendingColdStart`, post-PIE promotion and last-good
   active behavior.
4. Implement bounded shutdown flush with no late discovery/compile.
5. Implement settings, C++/Blueprint/console APIs and the full
   `cache-v2-debuggability.md` capability set: a minimal Engine-native C++ live
   DTO/JSON producer and bounded decision trace, plus Python-first offline
   explain/diff/verify/report correlation. Share stable schemas and avoid
   duplicating presentation logic across languages.
6. Implement packaged Disabled/Manual/Automatic reload policy; structural live
   change returns `RequiresRestart`.
7. Rebuild Engine-owned `StableFunctionKey -> current function/FunctionId` maps and
   immutable Native/VM routes after compile/restore.
8. Through the Cache-owned safe-point route-refresh seam, inject already selected
   sibling-Provider outcomes and prove absence/removal/content/profile/ABI/Live
   Coding failure changes only per-function routing and leaves valid Cache
   generations intact. Provider ABI/catalog matching and the Live Coding state
   machine themselves remain implementation/evidence owned by
   `refactor-as-static-jit-external-module`; this change must not duplicate them.

V6 uses focused automation and test-engine lifecycle first. Real PIE remains V7.

## 12. V7 — direct cutover and final acceptance

Execution order:

1. Prove legacy cache/DataGuid/pointer relocation cannot satisfy Cache V2 while
   `Binds.Cache` remains supported.
2. Remove the old production reader/writer/generator/forced-exit and package
   pre-generation path after V2 parity.
3. Stage loose NonUFS script source and add isolated CachePackage helpers. **Done:**
   package preflight is pure/tested, real Development/Shipping entries stay outside
   `All`, and C++ `-as-cache-report` supplies each later launch's stable session JSON.
4. Run complete Cache and affected HotReload/StaticJIT prefixes. **Done:** the
   route-snapshot/HotReload lifetime defect exposed by the first full run is fixed;
   complete Cache is `495/495`, complete HotReload is `122/122`, and the dedicated
   generated-AOT StaticJIT workflow is `30/30`.
5. Run real PIE cold/warm/body/structural/failure/promote scenarios.
6. Run real Development and Shipping cold/warm/edit/invalid/restored/structural
   multi-launch matrices last.
7. Benchmark cold/warm/body/type/global, serial/parallel and 4/16/64 MiB Pack
   policies; record raw CSV under `benchmarks/`.
8. Update Chinese guidance first, then English guidance, and archive the change.

## 13. Verification commands

Use the repository wrappers and the configured EngineRoot. Representative commands
from the worktree root are:

```powershell
& .\Tools\RunBuild.ps1 `
  -Label cache-vN-build `
  -TimeoutMs 1800000 `
  -NoXGE

& .\Tools\RunTests.ps1 `
  -TestPrefix 'Angelscript.TestModule.Cache' `
  -Label cache-vN-focused `
  -TimeoutMs 1200000

& .\Tools\RunTests.ps1 `
  -TestPrefix 'Angelscript.TestModule.Cache.Archive.TypeSchema' `
  -Label cache-typeschema-regression `
  -TimeoutMs 600000
```

SingleFile builds may be used while splitting or compiling one test TU, but they
prove syntax only. A milestone that changes Runtime linkage requires a full module
build; a behavior claim requires focused Automation; lifecycle/package claims
require their named integration level.

Test-file organization is opportunistic rather than a vertical gate. New semantic
families start in focused files (`Dependency`, `Manifest`, `Store`, `WarmReuse`,
`Invalidation`), while moving historical methods is deferred unless a touched file
must be decomposed to make the current feature safe to change.

OpenSpec closure checks:

```powershell
openspec validate refactor-as-incremental-function-cache --strict
```

If the installed CLI exposes a different command spelling, record the exact
successful invocation in `verification.md`; never claim strict validation from a
command that discovered no change.

## 14. Execution discipline

- Work serially in the current worktree unless the user explicitly re-authorizes
  independent parallel tasks.
- Do not create a worktree, commit, stage, push, archive the active change or update
  the parent gitlink without explicit instruction.
- Use TDD for implementation. Add exact-SHA review packets only for frozen byte/
  identity, ownership/allocation, publication or other shared safety contracts;
  ordinary local families do not require a new packet ceremony.
- Put new tests in focused files. Do not continue growing the existing TypeSchema TU
  for unrelated Dependency, Store, compiler, lifecycle or StaticJIT tests, and do
  not pause a functional slice merely to reorganize already-existing tests.
- Record genuine implementation problems and resolved design defects in
  `implementation-issues.md`; record executed evidence in `verification.md` and
  current truth only in `status.md`.
- Update `tasks.md` at vertical checkpoint boundaries. Checkbox count is not a
  progress percentage.
