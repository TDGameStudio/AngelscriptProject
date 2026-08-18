# Typed Semantic AOT Implementation Progress

This attachment records implementation checkpoints, unexpected behavior,
root-cause evidence, and verification results while `tasks.md` remains the
concise completion checklist.

## 2026-08-18 — official Generate collect-binds gap (8.6)

Review of the landed group-8 tree found that official Editor
Generate/Refresh builds its disposable Engine in
`FAngelscriptProjectSourceGraph::Compile` without
`ApplyToEngineConfig()`. `bCollectStaticJITCompatibilityBinds` stays
false, so native forms and reviewed HeaderInline / ExportedSymbol
descriptors are discarded during Bind. Group 5 tests stay green because
they call `ApplyToEngineConfig()` themselves. Details:
`research/task-official-generate-collect-binds.md`. Task **8.6** is `[x]`.
Official `Compile` now `ApplyToEngineConfig()` for `StaticJITArtifact`.
RED 0/1 then GREEN 1/1 on
`Angelscript.TestModule.StaticJIT.ProjectSourceGraph`.

## 2026-08-18 — 8.4 official All finished (exact counts)

`Tools\RunTestSuite.ps1 -Suite All -LabelPrefix semantic-aot-all-final`
from `V:\` **exited 0** after 5068.34 s. All 37 prefixes wrote
`Summary.json` + `RunMetadata.json`. Do **not** copy 2396/2396.

| Scope | pass | fail | skip | timeout |
| --- | ---: | ---: | ---: | --- |
| Suite All (37 prefixes, including All's Standalone entry) | **3558** | **0** | **0** | false (0/37) |
| Unreal automation only (prefixes 01–36) | **3538** | **0** | **0** | false |
| All entry 37 Standalone CTest | **20** | **0** | **0** | false |
| Separate 8.4 Suite Standalone `semantic-aot-standalone-final` | **20** | **0** | **0** | false |

Post-fix prefixes that previously stopped All:

- Cache **549/549** (`20260818_121051_813_4bce2f4d`)
- Compiler **81/81** (`20260818_122602_361_75916cb8`)
- StaticJIT **408/408** (`20260818_125621_901_3e2f84c3`) — same prefix as 8.3
- AngelScriptSDK **762/762** (contains 8.3's Compiler 188)

`tasks.md` 8.4 is `[x]`. Evidence: `Saved/Tests/semantic-aot-all-final_*`,
`Saved/StandaloneTests/semantic-aot-all-final_37_Standalone/20260818_131228_772_16e210e0`,
and `{SCRATCH}/8.4/counts.txt`.

8.3 remains the earlier focused labels: Build exit 0 / 1623 ms;
Compiler **188/188**; StaticJIT **408/408**. No failed All prefix to re-run.

8.5 was re-run after All: probes 28/24/20 PASS; schema-v3 21 + 10/10;
`openspec validate --strict` valid; parent and submodule `git diff --check`
exit 0. Default backend still `bytecode`. `TEXT("dual")` appears only as a
rejected parse in `AngelscriptStaticJITBackendTests.cpp`.

## 2026-08-18 — 8.4 All mid-run (superseded; All finished)

Official `Tools\RunTestSuite.ps1 -Suite All -LabelPrefix semantic-aot-all-final`
from `V:\` later finished (see the 8.4 official All finished note). Mid-run
snapshot after prefixes 01–23 was 2715/2715 fail=0; kept only as history.

## 2026-08-18 — 8.4 All incidents (recorded; All still in flight)

Two official-All stops and their fixes live under `research/`:

1. **Cache provenance crash** —
   `research/task-84-cache-provenance-crash.md`.
   Prefix 09 crashed at `AngelscriptEngine.cpp:7281` because
   `OnPostProcessCode` shortened `CACHE_EXTERNAL_VALUE` after a trailing
   `StaticClassHelper` range was recorded. Production remaps those ranges
   after the hook. Cache later **549/549**.
2. **Compiler.Events TypeIdMapCount** —
   `research/task-84-compiler-events-typeid.md`.
   Prefix 11 was **80/81**. The test required `TypeIdMapCount` `Changed`
   for a function-only compile; the real dump field is
   `AllScriptDeclaredTypeCount`. Fixture now declares a script class.
   Compiler.Events **7/7**.

Historical note: those two stops blocked earlier All attempts. The later
`semantic-aot-all-final` run finished; 8.4 is now `[x]` with **3558/0/0**.

## 2026-08-18 — group 8 (8.1–8.3, 8.5) recorded; 8.4 All in flight

Closed:

- **8.1** `[x]` — `benchmarks/first-version-isolated.csv` has HIR
  2835.414 ms / 239964160 B, BytecodeJIT generate 3117.025 ms / 5829 B,
  TypedASTJIT generate 3165.067 ms / 6122 B, scalar 20.312 ns, direct
  20.703 ns, bridge 162.500 ns, official compile 1623 ms (8.3
  `semantic-aot-final` up-to-date). Default backend remains `bytecode`.
- **8.2** `[x]` — ZH first (`RT_StaticJIT.md`, `AGENTS_ZH.md`,
  `Documents/Guides/Test.md`), then EN (`Plugins/Angelscript/README.md`,
  `AGENTS.md`). All 8.2 checklist phrases present.
- **8.3** `[x]` — from `V:\`: build exit 0 1623 ms; Compiler **188/188**;
  StaticJIT **408/408** (prefix timeout raised to 1200000 ms). Fail=0
  skip=0 timeout=false.
- **8.5** `[x]` — probes 28/24/20 PASS; schema-v3 21 + 10/10; OpenSpec
  valid; `git diff --check` exit 0; audit in
  `research/task-85-forbidden-claim-audit.md`.

Historical note: 8.4 was still `[ ]` at this checkpoint because All had
crashed on Cache. That All later finished; see the 8.4 official All
finished note for **3558/0/0**.

## 2026-08-18 — 5.7 / 5.9 umbrella close GREEN

Closed:

- **5.7** `[x]` and **5.9** `[x]`. The 2026-08-15 note that production
  still rejects a script/internal-helper closure is stale. Clause owners
  are in `research/task-57-59-clause-map.md`. 5.10 superseded 5.7's
  non-inline export wording: those calls use `InvokeBoundNative`, while
  `HeaderInline` remains a literal symbol.

Named-file goldens added to
`AngelscriptStaticJITNativeBridgeTests.cpp` as
`NativeBridge.PublishedGoldens`:

- recursion fixture keeps `ASJIT_Helper_TypedASTFrameHelper_*` raw call
  plus immediate `bExceptionThrown` check
- private-bridge fixture keeps `InvokeBound<float, float>(Execution,
  ASJIT_Call_Sqrt_..., ...)` and names `InvokeBoundViaVM`
- core fixture keeps `return IsRunningCommandlet();`

Official `Angelscript.TestModule.StaticJIT.NativeBridge` **14/14 PASS**
(`Saved/Tests/semantic-aot-57-goldens/20260818_094048_569_c120504c`).
That count is the previous 11 NativeBridge cases plus the three
published goldens.

Left `[ ]`: **8.1–8.5**.

Partial group-8 notes (not `[x]`):

- 8.1 started under `benchmarks/`: TestJIT generated sizes and official
  wall-clock rows only. HIR capture time/memory, isolated Typed vs
  Bytecode generation time, and scalar/direct/bridged execution
  nanoseconds are still unmeasured.
- 8.2 started: `Documents/Knowledges/ZH/RT_StaticJIT.md` now records
  the TypedASTJIT complement/fallback/evaluation/cleanup/call-route
  boundaries. English consumer docs are not updated yet.

## 2026-08-18 — 6.1 ineligible mixin / external / lifecycle AOT rows GREEN

Closed:

- **6.1** `[x]` — Added AOT fixture module
  `ASStaticJITAotIneligibleReceiverFixture` plus
  `StaticJIT/AOT/Generation/AngelscriptStaticJITAotIneligibleReceiverFallbackTests.cpp`.
  Official RED was **0/3**
  (`Saved/Tests/semantic-aot-61-red/20260818_011305_409_065a676d`)
  because the stub source had only `IneligibleReceiverPlaceholder`.
  Official GREEN is **3/3 PASS**, 0 fail, 0 skip
  (`Saved/Tests/semantic-aot-61-green5/20260818_012409_916_d7e23983`).

What the three rows prove:

- `MixinReceiverRoot` calls a mixin on a `UCLASS` host.
- `ExternalReceiverRoot` is a global `UFUNCTION` with
  `external_implicit_this`.
- `GeneratedLifecycleRoot` is a final instance `UFUNCTION` on a
  default-initialized `UCLASS` host.
- Requested backend is `typed-ast`; each root's `ActualBackendId` is
  `bytecode` and Typed selection count stays 0.
- The same bodies stay VM-executable (`RunMixinReceiverRoot=15`,
  `RunExternalReceiverRoot=12`, `RunGeneratedLifecycleRoot=17`).

Not done as part of 6.1:

- These roots are not baked into official TestJIT Complete Generate.
  A standalone generation Engine is enough for the fallback counters;
  wiring them into Complete would change the Provider digest and
  require official Generate.
- UObject factory calls inside generated helpers still have no stable
  ScriptFunction slot, so VM wrappers stay test-only.

Left `[ ]`: **5.7 / 5.9**, **8.1–8.5**.

## 2026-08-18 — 0.7 BytecodeJIT reverse exception cleanup GREEN

Closed:

- **0.7** `[x]` — Recreated
  `AngelscriptStaticJITExceptionCleanupTests.cpp`. RED was
  `Later-declared live locals must be destroyed first during exception cleanup`
  (`Saved/Tests/semantic-aot-07-red-final/20260818_004708_533_22e46211`).
  Production change is only the isolated Positions loop reversal in
  `BytecodeJIT/AngelscriptBytecodeJIT.cpp` (the old
  `AngelscriptStaticJIT.cpp` path no longer exists). Focused
  `ExceptionCleanup` prefix **2/2 PASS**
  (`Saved/Tests/semantic-aot-exception-cleanup-green/20260818_004813_068_38a22990`).
  Official TestJIT Generate
  (`Saved/Commandlet/semantic-aot-07-generate/20260818_004853_660_515a1d24`,
  exit 0). Official `StaticJIT` prefix **401/401 PASS**
  (`Saved/Tests/semantic-aot-07-staticjit/20260818_005038_547_43fdbfcd`;
  the extra case is the new cleanup-order test).

Left `[ ]` after this checkpoint: **5.7 / 5.9**, **6.1**, **8.1–8.5**.
6.1 is now closed; see the 6.1 GREEN note above.

## 2026-08-18 — 4.18 official StaticJIT prefix GREEN

Closed:

- **4.18** `[x]` — official `Angelscript.TestModule.StaticJIT` prefix
  **400/400 PASS**, 0 fail, 0 skip
  (`Saved/Tests/semantic-aot-emitter/20260818_002710_465_d9d438ce`,
  exit 0, ~735s). Timeout was 900s so the 400-case prefix could finish;
  the task text still names 600s.

4.18 was not marked from the earlier **397/400** or **398/400** runs.

What landed to make the prefix GREEN:

1. Earlier 4.18 work (still required): `PackageBackendResults` seeds
   `RequestedBackendId` (Code=65), EnvironmentAbi current-Engine resolver
   fallback, generate-side ScriptFunction ExpectedAbi rewritten to Entry
   ABI, official TestJIT Generate, TestJIT ownership counts 7 `.jit.cpp` /
   31 `.cpp`.
2. HiddenFirst was **not** a missing snapshot function. Official 397/400
   failed at `Root->VerifiedTypedHIR == nullptr`. Capture diagnostic:
   `Unverified cleanup state must not claim a cleanup plan`.
3. `PublishManagedCleanupPlans()` walked transfer edges and attached
   empty reverse-live plans, then returned early when `NextSlot == 0`,
   leaving `cleanupPlanState == Unverified` with a non-empty plan arena.
   Fix: roll back those plans before returning. HiddenFirst
   **1/1 PASS**
   (`Saved/Tests/semantic-aot-418-hidden-green/20260818_000647_215_42c887ce`).
   4.17 cleanup-plan native **4/4 PASS**
   (`Saved/Tests/semantic-aot-418-cleanup-reg/20260818_000748_878_0929c52e`).
4. After that compiler fix, checked TestJIT output went stale
   (`Provider.generated.cpp: Owned generated bytes are stale`). Official
   `Tools\RunCommandlet.ps1 -Commandlet AngelscriptTestJIT -ExtraArgs "-Mode=Generate"`
   (`Saved/Commandlet/semantic-aot-418-generate/20260818_002005_829_2b1f7cdc`,
   exit 0). GenerationVerification **4/4 PASS**
   (`Saved/Tests/semantic-aot-418-verify-gen/20260818_002203_699_eae2eafe`).

Left `[ ]`:

- **0.7** — BytecodeJIT reverse cleanup loop; 4.17/4.18 no longer block it.
- **5.7 / 5.9** — remaining umbrella clauses.
- **6.1** — explicit ineligible mixin / external-receiver /
  generated-lifecycle AOT counter rows.
- **8.1–8.5** — group 8 stays last; 8.4 is the `All` suite.

## 2026-08-17 — 4.17 HIR lifetime slots and isolated destructor GREEN

Closed:

- **4.17** `[x]` — Compiler `PublishManagedCleanupPlans()` walks the HIR
  statement tree and authors per-edge reverse-live slot lists. Official
  `semantic-aot-cleanup-green-hir` **4/4 PASS**
  (`Saved/Tests/semantic-aot-cleanup-green-hir/20260817_222454_216_5174d9fa`)
  plus isolated destructor **1/1 PASS**
  (`Saved/Tests/semantic-aot-cleanup-green-isolated/20260817_222334_163_f6558deb`)
  and scalar transfer-cleanup **1/1 PASS**
  (`Saved/Tests/semantic-aot-cleanup-green-transfer/20260817_222615_150_5f3a438b`).
  Typed emission remains fail-closed on NonEmpty/PartialConstruction/ScriptDestructor.

Landed production:

- `asCTypedSemanticIRBuilder::PublishManagedCleanupPlans()` after managed
  cleanup is observed (and not a compiler exception region).
- `AngelscriptDestroyScriptObjectIsolated()` as a child-context VM cleanup
  bridge; BytecodeJIT script-struct `CallDestroy` uses it instead of
  `FCallScriptFunction(..., bIgnoreExceptions=true)` on the failed Execution.

4.18 (`StaticJIT` prefix) was started and is **not GREEN**. Official
`semantic-aot-emitter` (`Saved/Tests/semantic-aot-emitter/20260817_222851_281_219e7730`)
failed then crashed: stale `Provider.generated.cpp` on two generation-verification
cases, TypedAST exception routes not selecting Native (null binding), frame-recursion
null binding, and a fatal error in
`DepthAndActiveFunctionAreSharedAndEveryExitRestoresOuterState`. Do not mark 4.18
`[x]` from this run. Regenerating checked AOT/BytecodeJIT fixtures after the
`CallDestroy` isolated-bridge emit change is the next 4.18 action.

## 2026-08-17 — Unmarked-task close/leave inventory

Closed this session:

- **6.10–6.10d** `[x]` — Script-corpus inline tests. Official
  `semantic-aot-script-corpus` build exit 0
  (`Saved/Build/semantic-aot-script-corpus/20260817_195832_171_2ae5c92a`)
  and prefix **4/4 PASS**
  (`Saved/Tests/semantic-aot-script-corpus/20260817_195851_170_d79d08a9`).

Left `[ ]` with the task's own blocker:

- **0.7** — research-only BytecodeJIT cleanup still requires applying
  the isolated source-loop reversal after the remaining exception/cleanup
  GREEN (4.17). Not landed here.
- **4.17** — closed later this session; see the 4.17 GREEN note above.
- **4.18** — official `StaticJIT` prefix remains the group gate after 4.17.
- **5.7 / 5.9** — remaining umbrella clauses still open: production
  Provider still rejects a direct script/internal-helper closure for the
  required raw-call golden, and `InvokeBoundViaVM` still does not adopt
  the first nested VM exception payload exactly once. 5.8/5.9a/5.9b/5.10+
  stay `[x]`.
- **6.1** — AOT fixture still lacks the explicit ineligible mixin /
  external-receiver / generated-lifecycle counter rows named by this
  umbrella; 6.2–6.9/6.10 do not substitute that checklist.
- **8.1–8.5** — group 8 stays last; 4.17 is not GREEN, and 8.4's `All`
  suite cannot finish in this session.

## 2026-08-17 — Script function corpus inline tests recorded (no code)

The user asked to adapt some `Script/` function cases into C++ unit tests,
then asked to **record OpenSpec first** and wait before implementing.

Added:

- `specs/as-static-jit-aot-test/spec.md` — Script-root function corpus
  requirement and four scenarios (scalar VM, class VM, Typed selection,
  class/array fallback)
- `tasks.md` 6.10–6.10d (all `[ ]`)
- `research/script-function-corpus-inline-tests.md` — source map and
  proposed `TEST_METHOD`s

No C++ test file, no generate, and no build/test run was started in this
record-only step. Implementation waits for an explicit decision.

## 2026-08-17 — Tasks 4.9b/4.10b/4.10c match, withdraw, regenerate GREEN

Adoption matching now consumes each copied Provider catalog slice against the
selected Engine. `FunctionContent` compares to the current route execution
identity and entry ABI; `Signature` compares ABI only; hard-value, layout, and
storage rows require a unique matching `ValidatedFunctionArtifactReferenceSets`
row. Missing, ambiguous, wrong-kind, wrong-ABI, or changed rows reject that
entry as `EAngelscriptArtifactMatchResult::SemanticDependencyMismatch` (18).
The Router sets `FAngelscriptJITFunctionMatchInput.CurrentRoutes` from the
Engine snapshot and owns an Engine-local reverse index on the Coordinator
(`kind + target hash` → dependents). Helper-only refresh rematches every
already-verified route so dependents withdraw immediately; already-leased
calls finish, later calls fall back to BytecodeJIT/VM, and unrelated or
dynamic-routed entries stay installed. No generated-body hot-path lookup,
process-global cross-Engine cache, forced DLL unload, or Cache V2
`Signature` semantic change was added.

Header-inline native generation first failed
`ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot` because the
analyzer required compiler `EnvironmentAbi` for SystemFunction/header-inline
uses while the compiler omitted those rows. The analyzer now synthesizes
`EnvironmentAbi` plus `RequiredReference` when they are missing; the backend
skips unserializable extra compiler rows (invalid/zero ABI) unless they are
`FunctionContent`/`HardValue`, which still fail closed.

Regenerated fixtures (not hand-edited digests):

- TestJIT EditorDevelopment `providerAbiRevision=8`
- project AngelscriptJIT EditorDevelopment / GameShipping `providerAbiRevision=8`
- project GameDevelopment remains `providerAbiRevision=2` with a different
  `ProviderId`; `-Profile=All` correctly refused to overwrite that foreign
  owner. An old ABI-2 Provider stays fail-closed at match time.

Fresh official verification from `V:\` after the header-inline rebuild
(`Saved/Build/semantic-aot-dependency-provider/20260817_185006_373_2799711c`,
exit 0):

```text
Dependencies 32/32 PASS  (0 fail / 0 skip / 0 timeout)
  Saved/Tests/semantic-aot-dependency-provider/20260817_185839_896_e1540617
  ValidDirectClosuresUseTypedBackendWithCompilerSignatureOnly = Success
  RejectsOldAbiRevisionAndRowOrViewSize = Success

Provider 22/22 PASS  (0 fail / 0 skip / 0 timeout)
  Saved/Tests/semantic-aot-dependency-provider/20260817_190018_786_ecc2e482

ProjectGeneration.Engine 30/30 PASS  (0 fail / 0 skip / 0 timeout)
  Saved/Tests/semantic-aot-dependency-provider/20260817_190054_348_38b506f6
  ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot = Success
```

Tasks 4.9, 4.9a, 4.9b, 4.10, 4.10a, 4.10b, and 4.10c are now `[x]`. Do not
start 4.17/4.18, 5.7/5.9, 6.1, 0.7, or group 8 from this checkpoint.

## 2026-08-17 — Tasks 4.9a/4.10a Provider semantic-dependency table

Provider ABI revision is now 8. Each view owns one flat
`FAngelscriptJITSemanticDependencyRow` table; each entry addresses a
slice with `SemanticDependencyStartIndex`/`SemanticDependencyCount`.
`CanonicalizeSemanticDependencies` sorts, deduplicates identical
kind+target rows, rejects conflicting hashes, and requires
`ExpectedContentOrValue` for `FunctionContent` and `HardValue`.
Generation packs those rows into digest identity and emitted C++.
TypedASTJIT backend flattens the root compiler/synthesized rows plus
transitive helper `FunctionContent`, skipping a root self-content row.

A first generation-validation attempt failed with
`InvalidSemanticDependencyRange` because `DigestView` did not yet
point at the packed table. After attaching the table, focused
verification is:

```text
Build semantic-aot-task49a-digestview: PASS
Dependencies: 19/19 PASS
  Saved/Tests/semantic-aot-task49a-green/20260817_174748_265_272448f1
```

Checked-in TestJIT/project Provider artifacts still advertise revision
7. Task 4.10c must regenerate them. Matcher reverse-index work remains
4.9b/4.10b.

## 2026-08-17 — Tasks 4.9/4.10 lowering-based classification GREEN

The approved per-entry Semantic Dependency Table still belongs to
4.9a/4.10a, but the analyzer/backend classification contract is now
implemented independently of that ABI bump.

RED evidence (`semantic-aot-task49-red`, 7/14 fail for the intended
reasons):

- production-like self-recursion required `ScriptCallContent` /
  `FunctionContent` against a compiler `Signature`-only row;
- a helper with `bRequiresFunctionContent=false` stayed valid but
  synthesized no content use;
- production self-recursion generation selected BytecodeJIT
  (`TypedASTJIT self-recursion AOT fixture did not use production
  TypedAST backend`).

The analyzer now classifies from lowering, not the leftover flag:

- script-plan target key equal to the current function key is
  self-recursion: `Signature` only, no `ScriptCallContent`;
- any other script plan preserves compiler `Signature` and synthesizes
  one `FunctionContent` row/use, copying the callee `ExecutionHash`
  when `Graph.Functions` has it;
- current-route native/bridge/import/folded/mutable uses keep their
  existing kinds and never gain callee content.

The backend sets `bRequiresFunctionContent` only when
`CalleeFunctionKey != CallerFunctionKey`. Fresh focused verification:

```text
Build semantic-aot-task410-green: PASS
Dependencies: 14/14 PASS
  Saved/Tests/semantic-aot-task410-green/20260817_173055_127_499dd42e
```

Tasks 4.9a-4.10c remain open: Provider ABI revision 7 still has no
serialized per-entry table, matcher reverse index, or fixture
regeneration.

## 2026-08-17 — Task 4.2 shared StaticJIT Entry Plan complete

`FStaticJITEntryPlan` is now the Runtime-owned pointer-free authority for C++
body/entry spellings, native-object versus declared receiver identity, formal
parameter order, VM frame offsets, reflected parameter order, generated
WorldContext suffix, return placement, wrapper availability and required
includes. The generation snapshot owns the plan once per function and applies
descriptor-only reflected-layout overlays before exposing immutable function
and descriptor graph views.

TypedASTJIT copies only the frozen plan into its provider adapter. BytecodeJIT
consumes representable entry facts while retaining the existing compatibility
adapter for complex shapes and its bytecode-owned body analysis. A real backend
test proves that an unmodified shared adapter is text-identical to the complete
legacy-compatibility adapter, then mutates a frozen carrier and swaps two real
VM slots to prove the backend does not silently re-derive those facts.

Investigation rejected three misleading test seams: ordinary full-provider
identity on the isolated generation Engine, direct calls to unexported
`FStaticJITContext` methods, and a null Entry Plan after the compiled-graph
contract became mandatory. The existing provider regression also had a stale
substring assertion that confused valid `FStaticJITFunction::` Runtime helper
calls with the removed numeric FunctionId registration object; it now rejects
the exact legacy constructor shape. Full evidence and root-cause notes are in
`research/task-4-2-shared-entry-plan.md`.

Fresh verification:

```text
Build semantic-aot-task42-final-build: PASS
EntryPlan: 5/5 PASS
Bytecode Provider compatibility: 1/1 PASS
Generation profile freeze: 1/1 PASS
Generation snapshot graph/emit set: 1/1 PASS
```

## 2026-08-14 — generation Engine CacheV2 delay eliminated

The long pause after script compilation was measured rather than attributed to
Engine binding replay. A focused `GeneratedOutputVerify` baseline showed each
generation Engine spending 45.8 seconds in full clean Cache V2 capture, while
the actual AS compile took 1-2 ms. The snapshot only consumed verified function
identity/reference facts, but the old path still built and validated every
serialized Cache record.

TDD added an audit contract requiring generation snapshots to contain zero
input Cache records. The runtime RED run observed 9 records. A first facts-only
early return removed record/pack work but still took about 27 seconds. Sub-phase
timing then proved 23.0 seconds came from per-function
`ResolveCurrentFunctionInput`; its `FunctionInputDigest` is Cache invalidation
state and is not part of generation output.

The final production path reuses the existing exact semantic capture front half
and, only for StaticJIT generation, omits record serialization and the unused
input-digest resolution. Stable actual dependencies, cross-module references,
artifact/debug content hashes, and the execution envelope remain validated.
Normal runtime/reload Cache capture is unchanged. An unsuccessful attempt to
generalize the diagnostics helper was removed after it failed to model
reflection-only `StaticsClass`; the final diff keeps that helper's prior
behavior.

Final evidence:

```text
Build: staticjit-generation-cache-facts-cleanup-build
  Result: Succeeded

Large facts: staticjit-generation-cache-facts-cleanup-green
  Result: 1/1 passed
  Function facts: 12.823 ms total; class graph: 12.238 ms
  Input Cache records: 0

Generation Engine: staticjit-generation-engine-facts-final-green
  Result: 3/3 passed

Generated output: staticjit-generation-generated-output-final-green
  Exported report: 1/1 success, 0 warnings, 0 errors
  Repeated module JIT/Provider/manifest output remained byte-identical.
```

The measured large-module generation boundary improved from 45.8 seconds to
about 12.2 ms. Exact measurements, failed-hypothesis notes, and the distinction
between generation and the intentionally Cache-backed ordinary Provider test
fixture are recorded in
`performance/generation-engine-initialization.md`. With this detour closed,
implementation returns to the Typed Semantic JIT task sequence.

## 2026-08-14 — isolated worktree bootstrap

- Parent worktree:
  `D:/Workspace/AngelscriptProject/.worktree/feature-as-typed-semantic-aot`.
- Parent branch: `feature-as-typed-semantic-aot`, based on parent commit
  `6ded86387f54339b3bef28d2fc7f49abf80b6191`.
- Core plugin branch: `feature-as-typed-semantic-aot`, based on plugin commit
  `5a1d0e68f54fb31850d8fcebac0231ae39f31c04`, exactly matching the parent
  gitlink.
- The requested `.worktree/` root was already excluded through the main
  repository's `.git/info/exclude`; creating the linked worktree did not
  modify the main checkout.
- `BootstrapWorktree.ps1` initialized all four registered submodules. Standard
  `git submodule update` could not fetch the locally committed
  `Plugins/Angelscript` gitlink, so the documented local-object-store fallback
  created an independent plugin worktree/branch at the exact gitlink commit.
  `AngelscriptGAS`, `AngelscriptGameplayTags`, and `Wiki` initialized normally.
- `AgentConfig.ini` uses the same UE root as the main checkout,
  `C:/Program Files/Epic Games/UE_5.8`, while `ProjectFile` correctly points to
  the isolated worktree. The Hazelight reference root was also normalized to
  the same main-workspace value.
- Bootstrap generated the isolated `Intermediate/TargetInfo.json`. UBT emitted
  the existing nullable-annotation warnings from `AngelscriptRuntime.Build.cs`;
  prewarm otherwise succeeded.

The main checkout had eight uncommitted TypedSemantic OpenSpec files. They
were reproduced in the isolated worktree through `apply_patch`; no stash,
temporary commit, index mutation, or source checkout affected main. All eight
files compare equal after newline normalization. The worktree uses CRLF for
the checked-out copies while main currently has LF bytes, which explains raw
SHA-256 differences without a textual difference. The synchronized change
retains the same `304 insertions / 38 deletions` diff and passes:

```text
openspec validate feature-as-typed-semantic-aot --type change --strict --no-interactive
Change 'feature-as-typed-semantic-aot' is valid
```

## 2026-08-14 — baseline build path-length failure

The first isolated canonical build failed before compilation:

```text
Saved/Build/typed-semantic-worktree-baseline/20260814_081101_281_d4791c84
Result: Failed (OtherCompilationError)
```

UBT rejected five generated binding action paths at 260–265 characters. The
longest failing path was the generated
`AS_FunctionBinding_AngelscriptRuntime_Aggregator.cpp` action at 265
characters. The equivalent path under the main checkout is 225 characters;
the requested worktree prefix adds exactly 40 characters. No production or
test source had changed, UHT generation completed, and the error occurred at
UBT's action-path validation, so this is an isolated workspace-path issue
rather than a code baseline failure.

The worktree remains at the requested `.worktree/feature-as-typed-semantic-aot`
location. The minimal hypothesis is to expose that same directory through an
unused local short drive and invoke the worktree runner/config through that
alias. This changes neither repository contents nor `EngineRoot`; it only
shortens UBT-visible project/plugin action paths. The next build is the
verification of that single-variable hypothesis.

## 2026-08-14 — short-path baseline build succeeds

The worktree was exposed as `V:/` with Windows `subst`, and the ignored
worktree-local `AgentConfig.ini` was pointed at
`V:/AngelscriptProject.uproject`. The physical worktree, parent/plugin branches,
and UE root remained unchanged. This reduced the longest previously failing UBT
action path from 265 characters to 196 characters.

The same canonical Editor Development build then passed:

```text
Tools/RunBuild.ps1 -Label typed-semantic-worktree-baseline-shortpath \
  -TimeoutMs 1800000 -NoXGE
Result: Succeeded
Actions: 193/193
DurationMs: 199557
Evidence: Saved/Build/typed-semantic-worktree-baseline-shortpath/
          20260814_081225_360_f524b4cf
```

This confirms the earlier failure was caused only by the UBT-visible path
length. All subsequent UE build/test commands for this worktree must run
through the `V:/` alias (recreating the same `subst` mapping after a reboot or
new machine session) while the implementation remains physically isolated
under the requested `.worktree/` directory.

## 2026-08-14 — implementation sequencing and guidance drift

- A dependency review found that the separate
  `fix-as-angelscript-type-correctness` change recommends repairing ordinary
  Runtime type-adapter correctness before later Runtime-facing Typed Semantic
  lowering. This does not block the current change's maintained-fork,
  host-neutral HIR model/capture and pure-emitter P1-P4 vertical slice. The
  implementation will therefore proceed through that slice first and treat any
  later `FAngelscriptType`-dependent lowering as an explicit gate, rather than
  silently absorbing another 52-task change into this branch.
- The root testing guidance refers to `Plugins/Angelscript/AGENTS.md`, but that
  file does not exist at plugin baseline
  `5a1d0e68f54fb31850d8fcebac0231ae39f31c04`; `rg --files -g AGENTS.md`
  finds only the repository root guidance and an unrelated RalphLoop test
  guidance file. The root `AGENTS.md`, `Documents/UnitTest/UnitTest.md`,
  `Documents/Guides/Test.md`, `Documents/Guides/TestConventions.md`, and
  `Documents/Rules/ASInlineFormattingRule.md` remain authoritative for this
  implementation.

## 2026-08-14 — P1 RED evidence and first reference audit

The first vertical-slice tests were added before production support in both
test hosts:

- UE CQTest:
  `Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR`.
- Standalone CTest:
  `AngelscriptStandalone.TypedSemanticIR`.

The canonical UE build failed for the intended missing-production reason:

```text
Tools/RunBuild.ps1 -Label semantic-ir-model-red -TimeoutMs 1800000 -NoXGE
Result: Failed (OtherCompilationError)
ProcessExitCode: 6
DurationMs: 11423
Evidence: Saved/Build/semantic-ir-model-red/20260814_082429_500_aa828cc2

AngelscriptNativeTypedSemanticIRTests.cpp(10,1): fatal error C1083:
source/as_typed_semantic_ir.h: No such file or directory
```

This is the expected RED boundary: both tests describe the function-owned HIR
model, deterministic verifier/dump, and `asCScriptFunction` lifetime seam while
the maintained fork did not yet contain that API.

For implementation-time reference research, the local Fuzzilli checkout at
revision `357cc311e8513cb4ef68ea4f3efef5fd1c418abc` supplied a useful precedent
for function-local numeric identities, insertion-time arena indexing, and an
independent verifier. Exact files, applied observations, and non-copying
boundaries are recorded in
`research/implementation-reference-notes.md`. The local reference answered the
current question, so no network repository was fetched.

## 2026-08-14 — P1 first GREEN build and Standalone include-boundary failure

The first production implementation added the fork-private HIR model,
verifier/dumper, and `asCScriptFunction` ownership seam without changing the
public `angelscript.h` ABI. The isolated Editor Development build passed:

```text
Tools/RunBuild.ps1 -Label semantic-ir-model-green-candidate \
  -TimeoutMs 1800000 -NoXGE
Result: Succeeded
Actions: 126/126
DurationMs: 128718
Evidence: Saved/Build/semantic-ir-model-green-candidate/
          20260814_083458_131_520ac53b
```

The focused UE prefix then passed `4/4`:

```text
Tools/RunTests.ps1 \
  -TestPrefix Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR \
  -Label semantic-ir-model-green -TimeoutMs 600000
Totals: total=4 passed=4 failed=0 skipped=0
DurationMs: 42708
Evidence: Saved/Tests/semantic-ir-model-green/
          20260814_083716_063_db5f0dc1
```

The first independent Standalone suite attempt failed while compiling only the
new test target:

```text
Tools/RunTestSuite.ps1 -Suite Standalone \
  -LabelPrefix semantic-ir-model-standalone -TimeoutMs 600000
Result: Failed during CMake build
AngelscriptTypedSemanticIRTests.cpp -> Core/angelscript.h(42,10):
fatal error C1083: CoreMinimal.h: No such file or directory
```

Root cause: `AngelscriptMaintainedFork` deliberately keeps the Standalone
compatibility include directory private so it does not leak a fake UE SDK
surface. Each executable that consumes the maintained-fork headers must opt in
to that compatibility include tree. The new test linked the correct library
but was omitted from the existing `ANGELSCRIPT_STANDALONE_COMPAT_CONSUMERS`
list, so nested `as_datatype.h` resolution selected the UE-spelled public
`Core/angelscript.h` instead of `Standalone/Compat/CoreMinimal.h`. The minimal
fix adds only the new test executable to that established private-consumer
list; production headers and the maintained-fork public interface remain
unchanged.

The same official Standalone suite passed after that boundary fix:

```text
Tools/RunTestSuite.ps1 -Suite Standalone \
  -LabelPrefix semantic-ir-model-standalone-fixed -TimeoutMs 600000
Result: Succeeded
CTest: 20/20 passed, 0 failed
TypedSemanticIR: 1/1 passed
Total CTest time: 46.59 seconds
```

The suite baseline increased from 19 to 20 only because this change adds the
independent `AngelscriptStandalone.TypedSemanticIR` target; it is not combined
with UE Automation counts.

## 2026-08-14 — P1 model/lifetime checkpoint complete

P1 hardening added exact normalized-dump oracles in both hosts, stable failures
for non-block roots, missing unsupported categories and non-contiguous IDs, an
engine-local resolved-call ID/pointer-free sentinel, exact type/source identity
checks, and a Standalone architecture assertion that the fork-private surface
does not appear in public `Core/angelscript.h`.

Fresh checkpoint evidence:

```text
Build: semantic-ir-model-p1-hardening
  Result: Succeeded, 4/4 incremental actions
  Evidence: Saved/Build/semantic-ir-model-p1-hardening/
            20260814_084314_864_b3298987

Focused UE: semantic-ir-model-p1-hardening
  TypedSemanticIR: 4/4 passed
  Evidence: Saved/Tests/semantic-ir-model-p1-hardening/
            20260814_084332_434_9ae60dbf

Standalone: semantic-ir-model-p1-hardening
  CTest: 20/20 passed, including TypedSemanticIR and Architecture
  Total CTest time: 42.96 seconds

Full UE Compiler prefix: semantic-ir-model-p1-compiler
  Tests: 126/126 Success
  Process exit: 0
  Evidence: Saved/Tests/semantic-ir-model-p1-compiler/
            20260814_084523_337_08574f57
```

Task 0.2 is complete. This does not claim the broader 1.1-1.12 matrix: capture
switching, parser/capture transactions, all receiver/trait forms, persistence
negative coverage, and the snapshot helper remain later tasks.

## 2026-08-14 — P2 capture RED

The next test-first slice adds direct coverage for the private Engine capture
switch, capture-on/off bytecode and VM parity, repeated deterministic capture,
post-parser HIR validity, and the `asCExprContext` identity propagation table.
The official RED build failed at the intended missing production seams:

```text
Tools/RunBuild.ps1 -Label semantic-ir-capture-red \
  -TimeoutMs 1800000 -NoXGE
Result: Failed (OtherCompilationError)
DurationMs: 4573
Evidence: Saved/Build/semantic-ir-capture-red/
          20260814_085010_411_77ac3e0e

asCExprContext has no member typedSemanticExpression
asCScriptEngine has no member IsTypedSemanticIRCaptureEnabled
asCScriptEngine has no member SetTypedSemanticIRCapture
```

The first RED compile also caught a test-authoring typo,
`ENativeEvidence::Behavior`, which is not a catalog value. It was replaced by
the exact `Compile | Runtime | Bytecode | Metadata | Isolation` evidence set
before production work; this typo is independent of the intended RED seam.

After fixing only that test-authoring typo, a clean RED build confirmed the
same intended missing production API without unrelated test errors:

```text
Build: semantic-ir-capture-red-clean
Result: Failed at the intended missing capture/context seams
Evidence: Saved/Build/semantic-ir-capture-red-clean/
          20260814_085046_527_be116dff
```

## 2026-08-14 — P2 first GREEN compile diagnostic

The first production candidate introduced a compile-local provisional builder,
expression identity propagation, and scalar statement/expression capture. The
official incremental build reached 110/122 XGE actions and reported one
localized compiler error:

```text
Build: semantic-ir-capture-green-candidate
Result: Failed (OtherCompilationError)
Evidence: Saved/Build/semantic-ir-capture-green-candidate/
          20260814_090119_221_fe44ca43

as_compiler.cpp: ConvertPosToRowCol(size_t, int*, int*)
cannot accept the asUINT* row/column fields stored by the owned HIR span.
```

Root cause: the existing compiler position API intentionally uses signed
`int` output parameters, while the immutable sidecar stores normalized
non-negative `asUINT` coordinates. The fix preserves both contracts: capture
uses local `int` values, then converts positive results into the owned span.
No public API, bytecode path, or HIR field layout changed.

The corrected candidate then passed both the official incremental build and
the focused UE Automation prefix:

```text
Build: semantic-ir-capture-green-candidate-2
Result: Succeeded, 13/13 actions
Evidence: Saved/Build/semantic-ir-capture-green-candidate-2/
          20260814_090603_120_ff0b5f44

Focused UE: semantic-ir-capture-green
Prefix: Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR
Result: 6/6 passed, 0 failed, 0 skipped
Evidence: Saved/Tests/semantic-ir-capture-green/
          20260814_090635_343_3ae61355
```

The focused test proves the first real compiler-captured scalar path:

- capture defaults off per Engine and publishes no sidecar;
- capture-on and capture-off bytecode arrays are identical;
- four branch/arithmetic VM cases produce identical results;
- the captured function remains valid after parser teardown;
- repeated compilation produces the same normalized pointer-free dump;
- expression-context `Copy`, `Merge`, `Clear`, and explicit void transitions
  preserve or invalidate the typed expression identity as specified.

This is a vertical-slice checkpoint, not completion of the full capture matrix.
Receivers, complete trait normalization, calls/conversions/assignment and all
control-flow/unsupported forms remain open in the task checklist.

## 2026-08-14 — P3 pure TypedASTJIT emitter RED

Tests were added first for the provider-independent scalar analyzer/emitter,
the frozen C++ golden, deterministic output, forbidden bytecode/provider
tokens, invalid HIR, unsupported expressions/types, and zero partial output.
The official RED build contained the intended missing production seam:

```text
Build: typed-ast-emitter-red
Result: Failed (OtherCompilationError)
Evidence: Saved/Build/typed-ast-emitter-red/
          20260814_091032_919_c8e73fdb

AngelscriptTypedASTJITGeneratedOutputTests.cpp:
fatal error C1083: StaticJIT/TypedASTJIT/AngelscriptTypedASTJITEmitter.h
```

Adding the test source invalidated the UBT makefile and reshuffled adaptive
unity shards. That independently exposed a pre-existing test-isolation defect:
`AngelscriptNativeForeachProtocolTests.cpp` included the support header that
declares `AngelscriptNativeTestSupport::AppendGeneratedAsLine`, but used the
name unqualified and had previously compiled only because another unity
neighbor leaked a namespace using-directive. The narrow correction adds an
explicit using-declaration in that test file. It changes no runtime behavior
and keeps the TypedASTJIT RED distinguishable from the unrelated unity defect.

## 2026-08-14 — P3 first GREEN compile diagnostic

The first provider-independent analyzer/emitter candidate was compiled with
the official project runner. It failed only in the new production slice:

```text
Build: typed-ast-emitter-green-candidate
Result: Failed (OtherCompilationError)
Evidence: Saved/Build/typed-ast-emitter-green-candidate/
          20260814_091339_636_e806097b
```

Two implementation assumptions were invalid under the plugin's actual build
mode:

- UBT unity compilation places separately included `.cpp` files in the same
  translation unit. Generic anonymous-namespace helper names such as
  `MakeFailure` therefore collided between the analyzer and emitter.
- maintained-fork `asCArray` is an indexed container and does not provide the
  standard `begin`/`end` protocol required by a C++ range-for loop.

The correction gives every file-local helper a TypedASTJIT-specific name and
iterates `asCArray` children by `GetLength()` plus index. This is a compile
isolation/host-container correction only; the eligibility or generated-output
contract is unchanged.

The corrected candidate passed the official incremental build and the focused
generated-output prefix:

```text
Build: typed-ast-emitter-green-candidate-2
Result: Succeeded, 5/5 actions
Evidence: Saved/Build/typed-ast-emitter-green-candidate-2/
          20260814_091704_962_eff69988

Focused UE: typed-ast-emitter-green
Prefix: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Result: 2/2 passed, 0 failed, 0 skipped
Evidence: Saved/Tests/typed-ast-emitter-green/
          20260814_091736_523_72becf76
```

This closes task 0.4's pure boundary: the analyzer/emitter accepts only a
verified function-owned HIR plus a resolved scalar shape; emits the frozen
parameter/local/literal/arithmetic/comparison/block/if/return C++ golden; and
returns no includes, declaration, or definition for invalid or unsupported
input. It neither accepts nor reads bytecode, provider, reflection, module, or
runtime publication state.

## 2026-08-14 — P4 compiled AOT probe RED

The first task-0.5 test patch adds one exact scalar declaration to the existing
committed AOT source fixture and requires isolated interpreter, current
BytecodeJIT Provider, and direct compiled TypedASTJIT-probe results to match
for all four cookbook rows. The direct probe counter must finish at exactly
four.

The first RED compile stopped on a test-only overload ambiguity before reaching
the intended missing seams: `UE_ARRAY_COUNT` is `SIZE_T`, while the actual
counter is `int32`, so UE's `TestEqual` overload could not choose a common
type. The expected count is now explicitly normalized to `int32`; this changes
no product or fixture behavior.

```text
Build: typed-ast-aot-probe-red
Result: Failed on test-authoring type ambiguity
Evidence: Saved/Build/typed-ast-aot-probe-red/
          20260814_092137_824_1f4d5314
```

After the test-only type correction, the clean RED build reached exactly the
four missing task-0.5 seams: the interpreter-session factory and the three
compiled-probe wrapper/count symbols.

```text
Build: typed-ast-aot-probe-red-clean
Result: Failed at four intended unresolved symbols
Evidence: Saved/Build/typed-ast-aot-probe-red-clean/
          20260814_092208_669_0a5d6eb8
```

The first implementation shaped the three probe wrappers inside the generated
translation unit. That cannot bootstrap: `AngelscriptTest` must link against
`AngelscriptTestJIT` before the generation commandlet can run, but those exports
would not exist until after generation and the second build. The stable carrier
now owns the exported wrapper/counter and a function-pointer registration seam;
the generated file owns only the emitted native body and its static
registration. This preserves the dependency direction
`Runtime <- TestJIT <- Test` and lets the maintained Generate/rebuild workflow
start from a clean checkout.

The corrected generator compiled successfully:

```text
Build: typed-ast-aot-generator-green-candidate-2
Result: Succeeded, 8/8 actions
Evidence: Saved/Build/typed-ast-aot-generator-green-candidate-2/
          20260814_092531_229_98c2975a
```

Its first Generate command then found a pre-existing generated-file-store
portability defect without writing partial output. Git had checked the owned
`.jit.cpp` out with CRLF, while the in-memory expected marker used LF. The
store compared the complete marker line including its newline and therefore
misclassified an otherwise exact revision-2 owned file as an ownership
conflict instead of stale generated content.

```text
Commandlet: typed-ast-aot-probe-generate
Result: Failed closed before publication
Evidence: Saved/Commandlet/typed-ast-aot-probe-generate/
          20260814_092602_776_0a6ee4a7

Diagnostic: ASStaticJITAotFixture...jit.cpp target exists without the expected
ownership marker
```

A focused regression now recreates a CRLF checkout and requires `Compare` to
report `ContentMismatch`, never `OwnershipConflict`, and `Publish` to safely
regenerate it. It failed RED at the ownership-conflict assertion:

```text
Focused UE: jit-owned-marker-crlf-red
Result: 0/1 passed (expected RED)
Evidence: Saved/Tests/jit-owned-marker-crlf-red/
          20260814_092845_834_8edb7000
```

The store correction compares the ownership marker text independently of a
following LF/CRLF terminator while still requiring a complete marker-line
boundary. Revision, kind, Provider inventory, and user/cross-profile conflict
checks remain unchanged.

The first correction covered text-owned C++ files and passed its focused test,
but the next real Generate attempt exposed the same checkout normalization on
JSON-owned files. `OwnedFiles.generated.json` and the manifest begin with a
multi-line ownership prefix, so their CRLF prefix also required equivalent
recognition. The regression was expanded to rewrite every owned file, not just
one module source, before compare/publish. The generalized text-plus-JSON
correction passed:

```text
Build: jit-owned-marker-all-crlf-green-build
Result: Succeeded, 7/7 actions
Evidence: Saved/Build/jit-owned-marker-all-crlf-green-build/
          20260814_093323_416_1e135e66

Focused UE: jit-owned-marker-all-crlf-green
Result: 1/1 passed
Evidence: Saved/Tests/jit-owned-marker-all-crlf-green/
          20260814_093345_888_681f720d
```

The maintained Generate command then succeeded and wrote the provider update,
owned inventory, and dedicated TypedASTJIT test probe:

```text
Commandlet: typed-ast-aot-probe-generate-3
Result: Succeeded
Evidence: Saved/Commandlet/typed-ast-aot-probe-generate-3/
          20260814_093437_624_660f8736
```

The required source-set rebuild correctly invalidated the UBT makefile for the
new `.generated.cpp`, then found one carrier configuration omission: sources
beneath `Generated/EditorDevelopment` could not include the module-root
`AngelscriptTestJITProbes.h`. `AngelscriptTestJIT.Build.cs` now explicitly adds
its own module root as a private include path, matching the already-established
flat-root probe ownership without introducing a `Public` or `Private` wrapper.

```text
Build: typed-ast-aot-probe-compiled
Result: Failed at the generated probe's module-root include
Evidence: Saved/Build/typed-ast-aot-probe-compiled/
          20260814_093607_120_45a8a985
```

Adding the module root as a private include path resolved that source-layout
issue. The required post-generation rebuild then passed and compiled the new
generated translation unit:

```text
Build: typed-ast-aot-probe-compiled-2
Result: Succeeded, 11/11 actions
Evidence: Saved/Build/typed-ast-aot-probe-compiled-2/
          20260814_093653_730_9ca2b495
```

The first two-test P4 execution produced one substantive GREEN result and one
determinism RED result:

```text
Focused UE: typed-ast-aot-probe-green
Report: Saved/Tests/typed-ast-aot-probe-green/
        20260814_093717_627_19bcc474/Report/index.json

TypedASTScalarProbeMatchesInterpreterAndBytecodeJIT: Success (36.41 s)
GeneratedOutputVerify: Fail (72.79 s)
```

The passing parity test proves all four required rows agree through the
isolated interpreter, the compiled BytecodeJIT Provider, and the generated
TypedASTJIT native probe, with the direct TypedAST probe counter ending at
exactly four. The failing test compared two complete normalized HIR dumps from
fresh generation Engines. Every semantic node, type, local ID, source offset,
and generated C++ byte was identical; only the physical automation fixture
root differed (`.../<GUID>/Script/...`). The GUID is deliberately unique for
filesystem and Engine isolation and is not source semantics.

Root-cause decision: keep the actual captured HIR and source spans unchanged,
but make the generation adapter's diagnostic `TypedASTNormalizedHIR` view map
its known isolated physical `Script` root to the stable virtual
`/Angelscript/Game` source root. The mapping fails closed when the physical
root is absent or survives normalization. This is narrower than weakening the
HIR verifier/dump or making fixture directories globally shared, and directly
tests the OpenSpec requirement that the normalized view be deterministic.

The minimal adapter correction passed its incremental build and the exact
previously failing test:

```text
Build: typed-ast-aot-hir-normalization
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-aot-hir-normalization/
          20260814_094336_712_38e4c27f

Focused UE: typed-ast-aot-hir-normalization-green
GeneratedOutputVerify: 1/1 passed
DurationMs: 149573
Evidence: Saved/Tests/typed-ast-aot-hir-normalization-green/
          20260814_094357_211_587d75af/Report/index.json
```

The two fresh Engines used different physical GUID roots in this GREEN run,
so the equality is not an accidental reuse of one fixture. Both the normalized
HIR and generated C++ comparisons passed.

Adding the dedicated test-only generated probe also invalidated one older
fixture-shape assumption. The Provider ownership test still expected exactly
three generated `.cpp` files. Its focused RED run proved the only failure was
the intended `3` versus actual `4` count:

```text
Focused UE: typed-ast-aot-ownership-count-red
Result: 0/1 passed (expected RED)
Diagnostic: Expected 3 to equal 4
Evidence: Saved/Tests/typed-ast-aot-ownership-count-red/
          20260814_094724_465_6332e6ba/Report/index.json
```

The ownership contract remains strict: the fixture has exactly two non-empty
AngelScript modules and therefore exactly two `*.jit.cpp` module sources. The
fourth general `.cpp` is asserted separately by its exact test-only name,
`TypedASTJITScalarProbe.generated.cpp`; it is not treated as a third AS module
or a production Provider entry.

The corrected fixture-shape contract passed the incremental build and the
whole TestJIT ownership class, not only the formerly failing assertion:

```text
Build: typed-ast-aot-ownership-count-green
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-aot-ownership-count-green/
          20260814_094833_631_936c006a

Focused UE: typed-ast-aot-ownership-green
Result: 8/8 passed
Evidence: Saved/Tests/typed-ast-aot-ownership-green/
          20260814_094856_663_f35b2ce3/Report/index.json
```

Together with the earlier three-route parity PASS, exact four-entry counter,
two-fresh-Engine HIR/C++ determinism PASS, maintained Generate command PASS,
and required post-generation build PASS, this closes task 0.5. It remains a
test-only compiled probe and makes no production Provider or UASFunction
attachment claim.

## 2026-08-14 — P1-P4 combined gate and generation performance follow-up

The combined final build and compiler gate passed on the task-0.5 state:

```text
Build: semantic-aot-scalar-final
Result: Succeeded; target up to date after the immediately preceding 4/4 build
Evidence: Saved/Build/semantic-aot-scalar-final/
          20260814_095135_911_372dcefb

Compiler: semantic-aot-scalar-compiler-final
Result: 128/128 passed
Evidence: Saved/Tests/semantic-aot-scalar-compiler-final/
          20260814_095145_899_244cb855/Report/index.json

StaticJIT: semantic-aot-scalar-staticjit-final
Result: 162/162 completed, 0 failed
Evidence: Saved/Tests/semantic-aot-scalar-staticjit-final/
          20260814_095248_336_864bc7eb/Report/index.json
```

The StaticJIT gate took 564.5 seconds and isolated a repeated 34-38 second
post-compile Cache V2 capture interval in the AOT fixture. The user explicitly
requested investigation and, if safe, removal of unnecessary Cache work from
StaticJIT test/generation Engines. Detailed evidence and the corrective audit
are tracked in `performance/generation-engine-initialization.md`.

After the generation-only Cache correction, the current incremental Editor
Development build passed as
`staticjit-generation-cache-facts-cleanup-build`. The directly affected
generation Engine prefix passed 3/3, the large AOT generation-facts contract
passed 1/1, and the exported `GeneratedOutputVerify` report remained 1/1
success with unchanged golden artifacts.

The independent current-code Standalone gate then completed through the
official suite runner:

```text
Standalone: semantic-aot-scalar-standalone-final-rerun_01_Standalone
Result: 20/20 passed, 0 failed
Total CTest time: 44.88 seconds
Evidence: Saved/StandaloneTests/
          semantic-aot-scalar-standalone-final-rerun_01_Standalone/
          20260814_105551_141_4c765de6
```

The earlier attempt with label `semantic-aot-scalar-standalone-final` was not a
test failure: its outer 60-second command window terminated CTest while the
41-second Package case was still running, after 16 successes. It is retained as
incomplete evidence and is not counted. The rerun used the runner's full
600-second execution window and produced `Summary.json` plus the complete
20/20 `CTest.log`.

This closes task 0.6 and the P1-P4 scalar vertical-slice milestone. It does not
claim the remaining compiler-form matrix, call/DLL linkage, production backend
selection, UASFunction publication, or final diagnostics groups.

## 2026-08-14 — Unified StaticJIT prerequisite confirmation

Task 3.1 is closed against the archived
`refactor-as-unified-jit-coordinator` implementation rather than reimplementing
its boundaries. The archived task record shows groups 1-3 complete, and the
current plugin history retains the corresponding production commits:

```text
95a5ec7 [StaticJIT] Refactor: extract bytecode generation backend
6fe367c [StaticJIT] Feat: add backend-neutral generation contract
56c51fb [StaticJIT] Feat: isolate generation engine snapshots
```

The current source still exposes the required seams: `FAngelscriptBytecodeJIT`,
the Runtime-owned private `IAngelscriptStaticJITBackend` factory contract,
immutable `CompiledSourceGraph` plus independent `EmitModuleSet`, and the
`StaticJITGeneration` Engine purpose. Generation snapshots are built while the
disposable Engine is alive and the generation purpose suppresses ordinary
script reflection materialization. This confirmation does not claim task 3.2:
backend selection still has to freeze the matching HIR capture profile before
the first source-module build and prove same-compilation consumption.

The first task-3.2 TDD cell fixes the pure selection contract before touching
Engine creation. The test requests frozen profiles for `bytecode`, `typed-ast`,
and an invalid ID. It requires the first two to map to Bytecode/no-HIR and
VerifiedTypedHIR capture respectively, and requires invalid diagnostics to
name both legal values. The first runner invocation from the physical worktree
path was rejected before UBT because `AgentConfig.ini` intentionally names the
same worktree through its `V:` subst path. That infrastructure invocation is
not RED evidence. Re-running the same official runner from `V:\\` reached UBT
and produced the intended missing-production-API failure:

```text
Build: typed-ast-jit-profile-red
Result: expected RED; missing StaticJIT/AngelscriptStaticJITGenerationProfile.h
Evidence: Saved/Build/typed-ast-jit-profile-red/
          20260814_110554_151_0b85c1fa/Build.log
```

The first GREEN introduced a frozen `FAngelscriptStaticJITGenerationProfile`
that accepts only `bytecode` and `typed-ast`, maps them to the exact capture
profile, and applies that selection to `FAngelscriptEngineConfig` before the
Engine exists:

```text
Build: typed-ast-jit-profile-green
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-profile-green/
          20260814_110656_292_24e2f9cb

Focused UE: typed-ast-jit-profile-green
Result: Backend contract 8/8 passed
Evidence: Saved/Tests/typed-ast-jit-profile-green/
          20260814_110720_329_44dd5179/Report/index.json
```

The next RED moved the proof onto a real disposable generation Engine. It
required the raw AngelScript Engine capture setting, the immutable snapshot
capture profile, and each same-compilation HIR pointer to agree. The intended
compile failure showed that Engine configuration, snapshot profile and backend
view fields did not yet exist:

```text
Build: typed-ast-jit-capture-red
Result: expected RED; missing profile application/capture-view API
Evidence: Saved/Build/typed-ast-jit-capture-red/
          20260814_110853_772_8f5ef619/Build.log
```

The implementation now freezes private HIR capture immediately after the raw
Engine is created and before any target source is compiled. The generation
snapshot records the exact profile, and its per-function backend view points
at the verified HIR owned by that same `asCScriptFunction`. No serialized HIR
or second compilation is used. An intermediate compile correction changed the
maintained-fork forward declaration from `struct` to its real `class` tag and
exported the Engine-config application method across the Runtime/Test module
boundary; these were build integration corrections, not behavioral REDs.

```text
Build: typed-ast-jit-capture-green
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-capture-green/
          20260814_111321_938_f4eddc11

Focused UE: typed-ast-jit-capture-green
Result: Generation Engine 4/4 passed
Evidence: Saved/Tests/typed-ast-jit-capture-green/
          20260814_111345_697_e45a81a6/Report/index.json
```

The third RED exercised the exported programmatic Provider-artifact entry with
real snapshots. It found two concrete contract gaps: the invalid-ID diagnostic
did not enumerate both legal IDs, and a `bytecode` request incorrectly accepted
a graph captured with the `typed-ast` profile because the boundary retained
only a lossy `bHasVerifiedTypedHIR` boolean.

```text
Focused UE: typed-ast-jit-profile-validation-red
Result: expected RED, 0/2 passed
Evidence: Saved/Tests/typed-ast-jit-profile-validation-red/
          20260814_111627_848_d6c6aa99/Report/index.json
```

The backend-neutral graph and programmatic request now carry the exact capture
enum. The generator resolves the required profile from the requested backend,
rejects either mismatch direction before constructing a backend, and reports
both supported IDs for invalid input. The matching build and full generation
Engine test class are GREEN:

```text
Build: typed-ast-jit-profile-validation-green
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-profile-validation-green/
          20260814_112110_337_9f08f395

Focused UE: typed-ast-jit-profile-validation-green
Result: Generation Engine 6/6 passed
Evidence: Saved/Tests/typed-ast-jit-profile-validation-green/
          20260814_112232_025_9b62d781/Report/index.json
```

An intervening invocation targeted the non-existent prefix without the CQTest
class segment and therefore reported `No automation tests matched`; it did not
execute product code and is retained only as runner-discovery evidence under
`Saved/Tests/typed-ast-jit-profile-validation-green/20260814_112135_523_9a63d621`.

Exact matching then exposed a genuine legacy AOT-fixture mismatch: the fixture
enabled typed HIR after Engine creation but requested the `bytecode` backend.
The pre-fix existing generated-output verification produced the expected RED:

```text
Focused UE: typed-ast-jit-aot-profile-red
Result: expected RED, 0/1 passed
Diagnostic: CaptureProfileMismatch; bytecode requested against verified-typed-hir
Evidence: Saved/Tests/typed-ast-jit-aot-profile-red/
          20260814_112512_711_a2a84e76/Report/index.json
```

The fixture no longer calls `SetTypedSemanticIRCapture()` after creating the
Engine. It resolves the `typed-ast` generation profile first, applies it to the
Engine config, compiles once, and submits the resulting exact snapshot through
the same programmatic generator. Runtime now registers a task-created typed
backend for this stable ID; until task 3.5 opens real production Provider
emission, it records per-function `Unsupported` and deterministically falls
through to the existing BytecodeJIT backend. This is an explicit fallback
shell, not a claim that production TypedASTJIT entries are emitted yet. The
test-only scalar probe continues consuming the same compilation's HIR in
memory.

```text
Build: typed-ast-jit-aot-profile-green
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-aot-profile-green/
          20260814_112832_819_ba3e909d

Focused UE: typed-ast-jit-aot-profile-green
Result: GeneratedOutputVerify 1/1 passed
Evidence: Saved/Tests/typed-ast-jit-aot-profile-green/
          20260814_112859_280_aa5b5cf6/Report/index.json
```

The final characterization also searches the isolated typed-generation root
for `*.hir.txt` and `*.hir.json` and requires none. Together with pointer
identity against `asCScriptFunction::GetTypedSemanticFunction()`, this proves
there is no second HIR Engine or persisted default dump in this flow. Fresh
completion verification is:

```text
Build: typed-ast-jit-profile-final
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-profile-final/
          20260814_113102_501_2ef83cc6

Focused UE: typed-ast-jit-profile-final-engine
Result: Generation Engine 6/6 passed
Evidence: Saved/Tests/typed-ast-jit-profile-final-engine/
          20260814_113139_550_624a0351/Report/index.json

Focused UE: typed-ast-jit-profile-final-backend-rerun
Result: Backend contract 8/8 passed
Evidence: Saved/Tests/typed-ast-jit-profile-final-backend-rerun/
          20260814_113248_582_dc57e211/Report/index.json
```

An attempted parallel backend-contract invocation was rejected by the
worktree runner's single-command guard before launching UE. The sequential
`-rerun` above is the authoritative result. Task 3.2 is therefore closed;
task 3.5 remains responsible for replacing the explicit typed-unsupported
shell with real Provider entries and routing project generation to it.

## 2026-08-14 — task 3.3 CDO-free descriptor analysis boundary

The first task-3.3 characterization found three creating reads in the
ClassGenerator analysis path used by the generation Engine. `Analyze()` read
settings through `UAngelscriptSettings::StaticClass()->GetDefaultObject()`,
and both `DefaultComponent` and `OverrideComponent` validation used an
unconditional native-superclass `GetDefaultObject()`. The latter two calls
materialized an otherwise absent native CDO while the disposable Engine was
supposed to perform descriptor-only analysis.

The failure case could not initially be observed to the end of an Automation
test. A deliberately invalid generation compile correctly selected the
noninteractive startup-failure policy, which called
`RequestExitWithStatus(true, 3)` and terminated the entire Editor-Cmd host
before the CDO and diagnostic assertions ran. The test first expressed a
narrow dependency callback and produced the intended compile-time RED:

```text
Build: typed-ast-jit-generation-exit-seam-red
Result: expected RED; FAngelscriptEngineDependencies had no
        HandleStartupCompileFailureExit member
Evidence: Saved/Build/typed-ast-jit-generation-exit-seam-red/
          20260814_115604_260_8e9ee97b/Build.log
```

`FAngelscriptEngineDependencies::CreateDefault()` now supplies that callback
with the unchanged production side effects: it sets `GIsCriticalError` and
calls `FPlatformMisc::RequestExitWithStatus()` with the resolved force/status
request. The generation fixture replaces only that dependency and records the
request, so a test can inspect a fail-closed Engine without adding a
production `ForTesting` API or weakening real startup behavior. The full build
after introducing the seam passed:

```text
Build: typed-ast-jit-generation-exit-seam-green
Result: Succeeded, 139/139 actions
Evidence: Saved/Build/typed-ast-jit-generation-exit-seam-green/
          20260814_115631_423_267961d5
```

The now-observable behavioral RED proved both creating reads. The
`DefaultComponent` probe incorrectly compiled successfully after creating its
direct native-parent CDO. The `OverrideComponent` probe created the same kind
of CDO before returning the ordinary missing-target diagnostic:

```text
Focused UE: typed-ast-jit-generation-cdo-behavior-red
Result: expected RED, total=8 passed=6 failed=2
Evidence: Saved/Tests/typed-ast-jit-generation-cdo-behavior-red/
          20260814_115927_344_783c3a90/Report/index.json
```

The final RED split override analysis into the two required semantic cases.
An existing `ACharacter` ancestor CDO containing `CollisionCylinder` is
sufficient read-only evidence and must not cause the direct native-parent CDO
to be created. Conversely, a target absent from every existing descriptor,
property and ancestor CDO is unprovable when any native superclass has no CDO,
so generation must fail closed with the stable missing-reflection diagnostic.
The existing implementation failed both cases, in addition to the default
component case:

```text
Build: typed-ast-jit-generation-cdo-boundary-red
Result: Succeeded; test-only incremental build 4/4 actions
Evidence: Saved/Build/typed-ast-jit-generation-cdo-boundary-red/
          20260814_120210_920_6e574c8e

Focused UE: typed-ast-jit-generation-cdo-boundary-red
Result: expected RED, total=9 passed=6 failed=3
Evidence: Saved/Tests/typed-ast-jit-generation-cdo-boundary-red/
          20260814_120232_526_8b2d9c33/Report/index.json
```

Generation analysis now reads the Engine-owned `ConfigSettings` pointer
instead of asking the settings class for a default object. Its two remaining
native CDO queries pass `false` whenever
`bStaticJITGenerationAnalysis` is set. Override validation first checks
structural `FProperty` evidence, then reads only already-existing CDOs while
continuing through ancestors. A proven ancestor target succeeds without
materializing the direct parent. If the target remains unresolved and at
least one required native CDO was absent, analysis emits a stable diagnostic
beginning with:

```text
Static JIT generation cannot analyze component metadata because native superclass
```

and marks the descriptor analysis as an error. Default-component attachment
validation is also null-safe and does not add a misleading missing-attach
diagnostic after this unprovable-reflection result.

The production delta compiled incrementally and the same complete generation
Engine class is GREEN:

```text
Build: typed-ast-jit-generation-cdo-green
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-jit-generation-cdo-green/
          20260814_120445_990_11b0ecf0

Focused UE: typed-ast-jit-generation-cdo-green
Result: total=9 passed=9 failed=0 skipped=0; process exit 0;
        GIsCriticalError=0
Evidence: Saved/Tests/typed-ast-jit-generation-cdo-green/
          20260814_120505_262_1205a480/Report/index.json
```

A source audit of `AngelscriptClassGenerator_Analyze.cpp` finds only the two
explicitly parameterized native CDO queries described above; there is no bare
or settings-class `GetDefaultObject()` remaining in that analysis unit. This
closes the CDO/fail-closed slice of task 3.3.

### Complete graph, exactly-once compile, and output-only filtering

The remaining task-3.3 test was strengthened before adding production APIs.
Its two source modules now include a native `Math::Abs` call so a successful
typed capture must carry an external-native dependency, rather than passing
with an accidentally empty token set. The characterization requires:

- one and only one complete Bind replay for the disposable Engine;
- one source compile pass for the full two-module target/provider graph;
- non-empty module, function, type, global, descriptor, dependency and
  external-native-call views;
- at least one function carrying verified same-compilation Typed HIR;
- every complete-graph count to be observable at the backend boundary;
- one selected emit module while the backend still processes every function;
- a duplicated/non-exact complete graph to fail before backend construction.

The resulting compile-time RED was limited to the deliberately missing
exactly-once counter and pointer-free diagnostics summary:

```text
Build: typed-ast-jit-generation-complete-graph-red
Result: expected RED; SourceCompilePassCount and
        FAngelscriptStaticJITCompiledSourceGraphSummary did not exist
Evidence: Saved/Build/typed-ast-jit-generation-complete-graph-red/
          20260814_121005_645_4d45ae42/Build.log
```

The generation Engine now resets a request-local counter before initial
compile and increments it only when a generation-purpose Engine actually
enters `CompileModules()`. Snapshot freeze copies that count and refuses any
value other than one. `FAngelscriptStaticJITCompiledSourceGraph` carries the
same immutable value, and generator diagnostics expose a pointer-free summary
of the actual backend input: source-pass, module, function, type, global,
descriptor, dependency, external-native-call and emit-module counts plus the
presence of verified Typed HIR.

The programmatic generator now requires the supplied complete module set to
match the snapshot exactly. Count equality plus per-snapshot-module identity
membership rejects missing, extra and duplicate modules. `EmitModuleSet`
remains a separately validated subset and affects only Provider packaging;
the backend receives all snapshot functions and all semantic/dependency data.
The request member itself remains a const view, with a compile-time assertion
in the backend contract tests.

Production and focused verification are GREEN:

```text
Build: typed-ast-jit-generation-complete-graph-green-candidate
Result: Succeeded, 139/139 actions
Evidence: Saved/Build/typed-ast-jit-generation-complete-graph-green-candidate/
          20260814_121205_584_4ef2295c

Focused UE: typed-ast-jit-generation-complete-graph-green-candidate
Result: Generation Engine total=9 passed=9 failed=0 skipped=0;
        process exit 0, GIsCriticalError=0
Evidence: Saved/Tests/typed-ast-jit-generation-complete-graph-green-candidate/
          20260814_121554_048_c5c51ca7/Report/index.json

Focused UE: typed-ast-jit-generation-complete-graph-backend
Result: Backend contract total=8 passed=8 failed=0 skipped=0;
        process exit 0, GIsCriticalError=0
Evidence: Saved/Tests/typed-ast-jit-generation-complete-graph-backend/
          20260814_121740_553_df3a124f/Report/index.json
```

The final source audit confirms the generation branch calls
`SetupForStaticJITGeneration()`, whose entire body is `SetupModule()` followed
by `Analyze()` and error inspection. It swaps compiled AngelScript modules
into the disposable Engine only to retain their VM/semantic state; the
`PerformSoftReload()` / `PerformFullReload()` switch is confined to the
ordinary-Engine branch. Existing test assertions cover absence of script
UClass/UStruct/delegate UObjects, reload callbacks, compilation events,
Bind-cache writes, on-screen registration and function-route publication.
Together with the CDO cases above, this closes task 3.3.

### Typed body execution-context boundary clarification

During review of the intended generated C++ shape, the user explicitly
required ordinary TypedASTJIT code to avoid `FAngelscriptJITExecutionContext`.
The current ABI audit confirms that the maintained shared VM and parameter
entries carry `FScriptExecution&`; `FAngelscriptJITExecutionContext` is a
Runtime-side dispatcher/scope utility used by existing callers, not a value
that a generated arithmetic expression needs.

The design and task-4 golden/emitter requirements now make that distinction
testable: generated typed implementations, pure scalar helpers, and direct
typed helper calls must not receive, construct, or name the generic dispatcher
class. Pure wrap/narrow/normalization/shift helpers remain context-free and
force-inlineable. Only genuinely failing operations enter the narrow
`FScriptExecution` exception contract, and dynamic legacy/VM calls go through
the dedicated TypedASTJIT scalar bridge. Existing entry thunks may retain the
`FScriptExecution&` already required by the shared ABI; this does not license
threading a generic context object through otherwise ordinary C++ expressions.

### Generation package/context-pool containment slice

The first task-3.4 containment audit found two process-global side effects in
`FAngelscriptEngine::PreInitialize_GameThread()`: every Engine construction
released the primary thread's complete pooled-context array, and every Engine
acquired process-owned `/Script/Angelscript` plus
`/Script/AngelscriptAssets` package references. A disposable generation Engine
is neither a new process epoch nor an owner of those primary packages, so both
operations violated the generation boundary.

The test was written first. It seeds a primary-Engine context in the TLS pool,
captures both process package reference counts, constructs and destroys a
successful generation fixture, and requires all observations to remain exact
during and after the request. Its compile-time RED was the intentionally
missing test-only package-reference observation API:

```text
Build: typed-ast-jit-generation-containment-package-pool-red
Result: expected RED; FAngelscriptProcessPackageReferenceCounts and
        GetProcessPackageReferenceCountsForTesting did not exist
Evidence: Saved/Build/typed-ast-jit-generation-containment-package-pool-red/
          20260814_122601_406_1b2dc6ee/Build.log
```

Generation-purpose initialization now borrows only already-existing package
pointers through `FindPackage`, without create/root/ref-count ownership, and
skips the process-epoch context-pool sweep. Ordinary Engine initialization is
unchanged. Generation teardown continues to release only contexts whose exact
`asIScriptEngine` matches the disposable Engine.

```text
Build: typed-ast-jit-generation-containment-package-pool-green-candidate
Result: Succeeded, 139/139 actions
Evidence: Saved/Build/typed-ast-jit-generation-containment-package-pool-green-candidate/
          20260814_122708_960_8bfdc8bb/Build.log

Focused UE: typed-ast-jit-generation-containment-package-pool-green-candidate
Result: Generation Engine total=10 passed=10 failed=0 skipped=0; exit 0
Evidence: Saved/Tests/typed-ast-jit-generation-containment-package-pool-green-candidate/
          20260814_123024_305_6bf1e0eb/Report/index.json
```

This closes only the package/TLS-pool success slice. Task 3.4 remains open
until success plus Bind replay, source compile, HIR verification, descriptor
analysis, backend emission, and packaging failures all prove the full primary
state snapshot and request-owned cleanup boundary.

### Complete primary-containment observer and early-failure matrix

The next task-3.4 slice replaced the narrow package/pool assertions with a
reusable primary-process snapshot. It observes the primary Engine StateDump,
package ownership, Provider and script-test registries, primary context/TLS
pool, Blueprint-event and Editor-class caches, UObject/permanent-object and
world-context counts, crash-extension active Engine set, primary reload and
on-screen delegate bindings, and the primary coverage pointer. Generation
fixtures separately require DebugServer, Runtime extensions, Hot Reload
thread, script-test hot-reload runner, coverage recorder and runtime routes to
remain absent.

The first compile-time RED proved that the intended generation-service
observations did not yet exist:

```text
Build: typed-ast-jit-generation-containment-matrix-red
Result: expected RED; generation DebugServer/extension/HotReload-thread
        observation methods did not exist
Evidence: Saved/Build/typed-ast-jit-generation-containment-matrix-red/
          20260814_123900_291_ff1ad2de/Build.log
```

The smallest production addition was three const test-only observations on
the Engine plus the already-local Editor class-cache count. The first complete
matrix run then reported `10/12 PASS`: source-compile failure had incomplete
expected diagnostics, while both ordinary success in a fresh Editor process
and Bind-failure teardown appeared to add exactly 23 primary TypeId entries.
The latter signal was investigated rather than ignored.

The root cause was the observer itself. `FAngelscriptStateSnapshotBuilder`
recorded the primary `typeIdSeqNbr` and `mapTypeIdToTypeInfo`, then called
`asCTypeInfo::GetTypeId()` while emitting later type rows. That public query
assigns missing IDs lazily, so the supposedly read-only first snapshot mutated
the Engine after recording its own pre-mutation state. A dedicated StateDump
test was added first and reproduced the problem without constructing any
generation Engine:

```text
Build: typed-ast-jit-statedump-pure-observer-red
Result: Succeeded, 5/5 actions
Evidence: Saved/Build/typed-ast-jit-statedump-pure-observer-red/
          20260814_124904_558_6752d90f/Build.log

Focused UE: typed-ast-jit-statedump-pure-observer-red
Result: expected RED; total=1 passed=0 failed=1 skipped=0;
        TypeIdSeqNbr changed during two consecutive captures
Evidence: Saved/Tests/typed-ast-jit-statedump-pure-observer-red/
          20260814_124926_742_e8cdc910/Report/index.json
```

The fix reads the already-stored internal `typeId` for diagnostic identity and
value instead of invoking the allocating query. It does not prewarm the Engine
or suppress TypeId diffs. StateDump is again a pure observer, matching the
repository's dump architecture rule. The new regression and the surrounding
StateDiff tests are GREEN:

```text
Build: typed-ast-jit-statedump-pure-observer-green-candidate
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-jit-statedump-pure-observer-green-candidate/
          20260814_125035_397_ab6dc6b6/Build.log

Focused UE: typed-ast-jit-statedump-pure-observer-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-statedump-pure-observer-green-candidate/
          20260814_125053_894_07a5520d/Report/index.json

Focused UE: typed-ast-jit-statedump-pure-observer-regression
Result: StateDiff total=4 passed=4 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-statedump-pure-observer-regression/
          20260814_125731_339_ae98f67f/Report/index.json
```

Fresh-process exact reruns then proved successful generation, injected Bind
publication failure, and source compile failure all preserve the complete
primary snapshot. Bind diagnostics now require one-or-more occurrences rather
than an order-dependent exact count; source failure records all four actual
compiler/startup diagnostics. The final narrow build and complete generation
class are GREEN:

```text
Build: typed-ast-jit-generation-containment-source-diagnostic-green-candidate
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-jit-generation-containment-source-diagnostic-green-candidate/
          20260814_125614_053_51a5674f/Build.log

Focused UE: typed-ast-jit-generation-containment-success-after-statedump-fix
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-generation-containment-success-after-statedump-fix/
          20260814_125146_874_9fef527b/Report/index.json

Focused UE: typed-ast-jit-generation-containment-bind-failure-green
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-generation-containment-bind-failure-green/
          20260814_125413_102_700f03e2/Report/index.json

Focused UE: typed-ast-jit-generation-containment-source-failure-green-final
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-generation-containment-source-failure-green-final/
          20260814_125636_246_503968d9/Report/index.json

Focused UE: typed-ast-jit-generation-containment-matrix-green
Result: Generation Engine total=12 passed=12 failed=0 skipped=0; exit 0
Evidence: Saved/Tests/typed-ast-jit-generation-containment-matrix-green/
          20260814_125827_027_06661f17/Report/index.json
```

Task 3.4 remains open: HIR verification, descriptor analysis, backend emission
and packaging failures still need the same complete snapshot and cleanup
proof, including absence of Cache V2 persistence/substitution artifacts.

### HIR, descriptor, emission and packaging containment closure

The remaining task-3.4 stages now use the same full primary snapshot and the
same persistence audit as success, Bind replay and source compilation. The
persistence audit recursively rejects `Binds.Cache`, every file below the
fixture-owned `CacheV2` root, and every `*.hir*` substitute/readback artifact.
It is applied to successful generation and all six failure stages before the
request root is removed.

HIR verification uses a dev-automation-only, one-shot corruption seam in the
generation-owned snapshot builder. It changes the root statement ID of one
otherwise valid, same-compilation HIR immediately before the real maintained
fork verifier runs. The ordinary verifier therefore supplies the actual
failure and startup diagnostic; no invalid HIR becomes a supported compiler
state and no production build has an equivalent switch. The initial RED was
the deliberately absent configuration member, followed by a full public-header
rebuild and exact GREEN:

```text
Build: typed-ast-jit-hir-verification-containment-red
Result: expected RED; bInjectInvalidTypedSemanticIRForTesting did not exist
Evidence: Saved/Build/typed-ast-jit-hir-verification-containment-red/
          20260814_130612_574_fa2d0591/Build.log

Build: typed-ast-jit-hir-verification-containment-green-candidate
Result: Succeeded, 139/139 actions
Evidence: Saved/Build/typed-ast-jit-hir-verification-containment-green-candidate/
          20260814_130658_561_496393aa/Build.log

Focused UE: typed-ast-jit-hir-verification-containment-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-hir-verification-containment-green-candidate/
          20260814_130931_105_a8cdfe93/Report/index.json
```

Descriptor containment reuses the real missing-native-CDO failure from task
3.3. The primary baseline is captured after the test-owned transient native
class is rooted, so the comparison does not hide the fixture's own UObject.
ClassGenerator fails closed without materializing that CDO; after destroying
the generation Engine, the complete primary state and persistence audit remain
exact:

```text
Build: typed-ast-jit-descriptor-containment-green-candidate
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-jit-descriptor-containment-green-candidate/
          20260814_131343_087_8e9b934e/Build.log

Focused UE: typed-ast-jit-descriptor-containment-green-final
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-descriptor-containment-green-final/
          20260814_131512_458_b99ef0b4/Report/index.json
```

Backend emission and packaging use a test-local
`FAngelscriptStaticJITBackendRegistry`; they never register a process-global
backend or Provider. A request-owned adapter maps every module, function,
type, global, descriptor, dependency and external-native-call view from the
actual immutable generation snapshot. The fake TypedAST backend records that
it received the complete two-module/twenty-three-function graph and at least
one verified HIR. In the emission case it returns a stable failure and is
destroyed before `Generate()` returns. In the packaging case it emits a valid
module/function result and the real packager rejects an intentionally zero
ProviderId.

The first emission run was a useful test-fixture RED: the snapshot canonical
module name is `StaticJIT.GenerationOnly.StaticJITGenerationEmit`, not the
source-file short name. The selection now follows the canonical-name suffix
already used by the production-facing graph test rather than inventing an
exact short-name identity. No production change was made for this RED.

Packaging exposed a separate diagnostic bug first in the pure backend
contract: `FAngelscriptJITGeneration::Generate()` returned the correct error,
but `PackageBackendResults()` bypassed the generator's `Fail` path, leaving
`Diagnostics.TaskError` empty. The minimal fix captures the package error and
routes it through that existing failure path; it neither changes packaging
acceptance nor permits partial Provider output.

```text
Build: typed-ast-jit-packaging-diagnostic-red
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-packaging-diagnostic-red/
          20260814_130300_781_c2986765/Build.log

Focused UE: typed-ast-jit-packaging-diagnostic-red
Result: expected RED; total=1 passed=0 failed=1 skipped=0;
        external error was set while Diagnostics.TaskError was empty
Evidence: Saved/Tests/typed-ast-jit-packaging-diagnostic-red/
          20260814_130324_703_49ad74ea/Report/index.json

Focused UE: typed-ast-jit-packaging-diagnostic-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-packaging-diagnostic-green-candidate/
          20260814_130442_577_22f210aa/Report/index.json

Focused UE: typed-ast-jit-backend-emission-containment-red
Result: expected fixture RED; total=1 passed=0 failed=1 skipped=0;
        exact short module name did not match canonical snapshot identity
Evidence: Saved/Tests/typed-ast-jit-backend-emission-containment-red/
          20260814_132021_689_e57b3f9c/Report/index.json

Focused UE: typed-ast-jit-backend-emission-containment-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-backend-emission-containment-green-candidate/
          20260814_132153_762_f4b28571/Report/index.json

Focused UE: typed-ast-jit-packaging-containment-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-packaging-containment-green-candidate/
          20260814_132243_847_3ac92545/Report/index.json
```

The final matrix also adds the persistence audit to the pre-existing success,
Bind replay failure and source compile failure cases. Bind replay uses a unique
project/cache root through injected Engine dependencies, so it proves failure
before Engine publication cannot write to the ordinary project. The final
focused gates are GREEN in one Editor process, which additionally proves that
the sequence of contained Engines does not accumulate shared state:

```text
Build: typed-ast-jit-generation-containment-matrix-final-candidate
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-jit-generation-containment-matrix-final-candidate/
          20260814_132407_410_78baec12/Build.log

Focused UE: typed-ast-jit-generation-containment-matrix-final
Result: Generation Engine total=15 passed=15 failed=0 skipped=0; exit 0
Evidence: Saved/Tests/typed-ast-jit-generation-containment-matrix-final/
          20260814_132434_428_6910c0d2/Report/index.json

Focused UE: typed-ast-jit-backend-contract-containment-final
Result: Backend Contract total=9 passed=9 failed=0 skipped=0; exit 0
Evidence: Saved/Tests/typed-ast-jit-backend-contract-containment-final/
          20260814_132608_512_fead0869/Report/index.json
```

This closes task 3.4. Success and Bind replay, source compile, HIR verify,
descriptor analysis, backend emission and packaging failure now all prove the
same complete primary/process containment boundary and request-owned cleanup.

### One-shot TypedAST backend and Project/AOT production routing

Task 3.5 replaces the anonymous TypedAST placeholder with the Runtime-owned,
named `FAngelscriptTypedASTJIT`. Its factory still participates only through
`FAngelscriptStaticJITGenerator`, so one generator call creates exactly one
TypedAST instance, invokes it once with the complete synchronous graph, and
destroys it before the generation task returns. A dev-automation observation
records construction, invocation, destruction, accepted/rejected task counts,
and the number of exact same-compilation HIR views; it stores no Engine or HIR
pointer.

The backend is deliberately one-shot, including after a failed first request.
It rejects a second task on the same instance, a graph without exactly one
authoritative source compile pass, modules from multiple Engines, functions
outside the exact task module graph, functions from another Engine, and every
non-null HIR pointer that is not exactly the current HIR object owned by that
`asCScriptFunction`. The latter makes serialized, reconstructed, stale and
cross-Engine HIR inputs fail closed. No Engine or HIR pointer is retained when
`Generate()` returns.

Project generation previously constructed a bytecode-profile generation
Engine and left the backend ID at its bytecode default. It now freezes the
`typed-ast` generation profile before the first source compile and passes
`BackendId="typed-ast"` to the existing provider-generation entry. AOT already
froze that profile and requested the same backend; its real Generate/Verify
test now proves the lifecycle count for two fresh tasks independently. Until
eligibility and production emission land in tasks 3.6 onward, unsupported
functions continue through the generator's deterministic per-function
BytecodeJIT fallback.

The previously completed P4 `TypedASTJITScalarProbe.generated.cpp` remains the
explicit test-only, non-Provider-entry parity artifact described in design and
task 0.5. It still uses its own compiled-probe adapter after formal Provider
packaging and does not count as a second backend instance or as production
TypedAST publication. This boundary is retained intentionally until the real
eligibility/indexing/emission tasks replace the need for that bootstrap proof.

The RED test patch referenced the new Runtime-owned header and lifecycle API
before they existed. The official build failed only at those missing includes:

```text
Build: typed-ast-jit-task-contract-red
Result: expected RED; missing
        StaticJIT/TypedASTJIT/AngelscriptTypedASTJITBackend.h
Evidence: Saved/Build/typed-ast-jit-task-contract-red/
          20260814_133740_138_f8c38576/Build.log
```

After implementing the one-shot backend and Project route, the candidate build
and the three exact behavior paths passed. The direct ownership test creates
two independent generation Engines, accepts the first task, rejects reuse for
the second Engine/task, rejects a foreign-Engine function view, and rejects a
detached `asCTypedSemanticFunction` that models reconstructed/serialized HIR.

```text
Build: typed-ast-jit-task-contract-green-candidate
Result: Succeeded, 11/11 actions
Evidence: Saved/Build/typed-ast-jit-task-contract-green-candidate/
          20260814_133952_151_76b3c080/Build.log

Focused UE: typed-ast-jit-task-ownership-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-task-ownership-green-candidate/
          20260814_134031_751_cee9195c/Report/index.json

Focused UE: typed-ast-jit-project-route-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-project-route-green-candidate/
          20260814_134122_020_96d74358/Report/index.json

Focused UE: typed-ast-jit-aot-route-green-candidate
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-aot-route-green-candidate/
          20260814_134212_013_695cf122/Report/index.json
```

The final audit strengthened the contract so the backend also requires one
source compile pass and exact function-to-task-module membership. The test's
reuse attempt now passes the second Engine's request rather than repeating the
first request. Fresh official build and impact-matched regressions are GREEN:

```text
Build: typed-ast-jit-task-contract-final-candidate
Result: Succeeded, 7/7 actions
Evidence: Saved/Build/typed-ast-jit-task-contract-final-candidate/
          20260814_134513_336_b9373fa6/Build.log

Focused UE: typed-ast-jit-generation-engine-final
Result: Generation Engine total=16 passed=16 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-generation-engine-final/
          20260814_134551_903_126e13d8/Report/index.json

Focused UE: typed-ast-jit-backend-contract-final
Result: Backend Contract total=9 passed=9 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-backend-contract-final/
          20260814_134741_516_1b843357/Report/index.json

Focused UE: typed-ast-jit-generated-output-final
Result: TypedAST generated output total=2 passed=2 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-generated-output-final/
          20260814_134829_021_09594fda/Report/index.json

Focused UE: typed-ast-jit-project-route-final
Result: production Project Generate/Verify total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-project-route-final/
          20260814_134913_564_088bda7f/Report/index.json

Focused UE: typed-ast-jit-aot-route-final
Result: two-fresh-Engine AOT Verify total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-aot-route-final/
          20260814_135004_346_d380b5d2/Report/index.json
```

The pure TypedAST emitter golden now also rejects
`FAngelscriptJITExecutionContext` by name. The Runtime-owned TypedAST backend
directory contains no reference to that legacy VM/BytecodeJIT convenience
type. Typed scalar bodies and pure helpers remain context-free; only later
operations that can actually fail may use the narrow existing
`FScriptExecution` exception contract, while VM fallback remains a separate
bridge. This closes task 3.5 without claiming the still-open eligibility,
UFUNCTION root indexing or production TypedAST body-emission tasks.

### Final descriptor graph UFUNCTION root index

Tasks 3.6 and 3.7 now expose the resolved generation-only module descriptor
roots alongside the existing synchronous compiled module/function/descriptor
views. `BuildAngelscriptTypedASTJITRootIndex()` walks the authoritative
`FAngelscriptModuleDesc::Classes` and `FAngelscriptClassDesc::Methods` graph,
then exact-matches every `FunctionDesc->ScriptFunction` against both the
compiled function view and the flattened descriptor row. Function names,
canonical declarations and receiver text are diagnostic-only and never
participate in root identity.

The root index retains Engine/descriptor pointers only as synchronous
generation-task handles. Each output row also carries the stable module,
function and descriptor identities needed by later eligibility and Provider
packaging. Results are sorted by stable function hash, so input module/class,
method, function and descriptor ordering cannot change generated ordering.
Distinct roots with duplicate stable identities and every incomplete or
inconsistent pointer graph fail closed before backend emission.

Global UFUNCTIONs naturally enter the index through the preprocessor-created
statics class (`bIsStaticsClass`); ordinary instance UFUNCTIONs enter through
their real class descriptor. Ordinary script helpers appear in the complete
compiled function graph but not in `ClassDesc::Methods`, so they do not publish
an independent root. Overloads remain distinct because the resolved
`asIScriptFunction*` and stable function key, rather than shared text, define
identity. The production `FAngelscriptTypedASTJIT` now builds this index for
every accepted task and reports `NotUFunctionRoot` versus `MissingTypedHIR`
before the broader task-3.8/3.9 capability matrix is implemented.

The dedicated TDD file was first compiled before the Runtime eligibility API
existed. The official build failed only at the missing new header:

```text
Build: typed-ast-jit-eligibility-red
Result: expected RED; missing
        StaticJIT/TypedASTJIT/AngelscriptTypedASTJITEligibility.h
Evidence: Saved/Build/typed-ast-jit-eligibility-red/
          20260814_140005_713_5e888c88/Build.log
```

The finalized test matrix covers exact pointer selection with deliberately
colliding root/helper text, statics/global and instance roots, two overloads,
complete-input reordering, a missing descriptor graph and a mismatched stable
root identity. The latter two lock stable diagnostic prefixes and zero partial
root output. AOT lifecycle observation now also requires a positive resolved
UFUNCTION root count, proving the real production generation graph is consumed
rather than merely accepting an empty synthetic index.

```text
Build: typed-ast-jit-root-index-final-candidate
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-jit-root-index-final-candidate/
          20260814_141310_287_9f1b0e92/Build.log

Focused UE: typed-ast-jit-root-index-final
Result: eligibility total=3 passed=3 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-root-index-final/
          20260814_141332_921_e9e05b46/Report/index.json

Focused UE: typed-ast-jit-root-index-generation-engine
Result: generation Engine total=16 passed=16 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-root-index-generation-engine/
          20260814_140718_761_593bea40/Report/index.json

Focused UE: typed-ast-jit-root-index-project-route
Result: production Project Generate/Verify total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-root-index-project-route/
          20260814_140938_144_077ed8f6/Report/index.json

Focused UE: typed-ast-jit-root-index-aot-final
Result: AOT Verify with positive real root count total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-root-index-aot-final/
          20260814_141423_017_953ac24c/Report/index.json
```

The user explicitly reaffirmed that Typed Semantic AOT needs first-class debug
tools. This checkpoint therefore keeps root-index failures as stable tokens
(`TypedASTJITDescriptorGraphMissing`, `TypedASTJITDescriptorGraphMismatch`,
`TypedASTJITRootDescriptorMismatch`, `TypedASTJITRootIdentityMismatch`, and
duplicate/invalid variants) that later diagnostics can expose without parsing
free-form prose. The planned `UAngelscriptHIRDumpCommandlet` in task 3.14 and
`as.StaticJIT.DumpDiagnostics` plus typed function-level diagnostic records in
tasks 7.1-7.2 remain required deliverables; this checkpoint does not claim
those still-open tools are implemented.

The Runtime TypedASTJIT directory still contains no
`FAngelscriptJITExecutionContext` reference. Root indexing is pure
generation-time analysis and does not create or propagate an execution
context. This closes tasks 3.6 and 3.7 without claiming the task-3.8/3.9
eligibility matrix or any production TypedAST body publication.

### Typed scalar eligibility and compiler-verified empty cleanup

Tasks 3.8 and 3.9 now provide the production eligibility boundary after the
resolved UFUNCTION root index. The normalized input combines the exact
generation-task function/root with final compiler traits, invocation and
receiver shape, reflected UFUNCTION flags, and concrete parameter/return
types. The evaluator accepts only by-value void/bool/integer/float/double/enum
signatures and fails closed for every task-listed function kind, trait,
receiver, Unreal dispatch flag, complex signature, unsupported HIR node,
suspend state, lifetime state, and verifier failure. Output is a pointer-free
`FAngelscriptTypedASTJITEligibility` carrying a frozen reason token,
deterministic detail, and processed source span.

The stable fallback vocabulary is implemented as the exact 30-value task-3.9
set. `LexToString()` has an exhaustive test so commandlets and later
`as.StaticJIT.DumpDiagnostics` code do not need to parse prose or expose
Engine-local pointers. An invalid root span falls back deterministically to
the first owned statement/expression span, preserving a useful source anchor
for malformed HIR diagnostics.

Eligibility also requires affirmative compiler proof that cleanup is empty.
After normal function finalization, the maintained compiler marks a scalar
function `VerifiedEmpty` only when its final signature, allocations,
object-variable state, try/catch metadata, return ownership, and function kind
prove that no managed cleanup is required. The HIR verifier requires exactly
one empty universal cleanup plan and coverage of all transfers. Unverified,
non-empty, partial-construction, script-destructor, and compiler-internal
exception-region states are rejected. This deliberately pulls forward only a
scalar universal-empty foundation; task 4.17 remains open for lifetime slots,
per-edge cleanup, partial construction, reverse live destruction, and cleanup
bridge behavior.

The TDD build was first run before the cleanup/eligibility API existed and
failed at those missing symbols as intended:

```text
Build: typed-ast-jit-eligibility-matrix-red
Result: expected RED; cleanup-plan and eligibility APIs were absent
Evidence: Saved/Build/typed-ast-jit-eligibility-matrix-red/
          20260814_143219_337_55617e5d/Build.log
```

Issues discovered during GREEN were fixed at their owning boundary:

- the maintained `asCArray` does not expose Unreal's `IsEmpty()` API, so HIR
  validation uses `GetLength() == 0`;
- a synthetic enum test initially constructed `asCEnumType` without an owning
  script Engine, so it now borrows the active test Engine and exercises the
  real type path;
- malformed root statements initially lost source location, so diagnostic
  span selection now falls back to another owned HIR span;
- the first Generation Engine verification command used a stale test prefix
  and matched no tests; the corrected current prefix is
  `Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine`.

Fresh impact-matched verification is GREEN:

```text
Build: typed-ast-jit-eligibility-matrix-green-candidate-3
Result: Succeeded, 7/7 actions
Evidence: Saved/Build/typed-ast-jit-eligibility-matrix-green-candidate-3/
          20260814_144658_554_e5b0c5d7/Build.log

Focused UE: typed-ast-jit-eligibility-matrix-green-2
Result: eligibility/root index total=7 passed=7 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-eligibility-matrix-green-2/
          20260814_144727_951_54653abd/Report/index.json

Focused UE: typed-ast-jit-eligibility-generated-output
Result: generated output total=2 passed=2 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-eligibility-generated-output/
          20260814_144841_098_bad11c69/Report/index.json

Focused UE: typed-ast-jit-eligibility-native-hir
Result: native compiler HIR total=6 passed=6 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-eligibility-native-hir/
          20260814_144933_638_8a952d7b/Report/index.json

Focused UE: typed-ast-jit-eligibility-generation-engine-2
Result: generation Engine total=16 passed=16 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-eligibility-generation-engine-2/
          20260814_145309_811_9dd3838f/Report/index.json

Standalone: typed-ast-jit-eligibility-standalone_01_Standalone
Result: total=20 passed=20 failed=0
Evidence: Saved/StandaloneTests/
          typed-ast-jit-eligibility-standalone_01_Standalone/
          20260814_145748_657_4162ae25/Summary.json
```

The Standalone count is now 20 because the new host-neutral TypedSemanticIR
test is an additional CTest; it must not be copied as the historical 19-test
baseline. The production backend currently records exact eligibility or
fallback diagnostics but still does not publish general TypedAST C++ bodies;
helper-call closure, shared entry planning, emitter publication and Provider
attachment remain later tasks. The user-required debug-tool foundation is
therefore present, while task 3.14 (`UAngelscriptHIRDumpCommandlet`) and tasks
7.1-7.2 (`as.StaticJIT.DumpDiagnostics`) remain explicitly open.

### Task 3.10 sequencing clarification

Current implementation inspection found that task 3.10 mixed two separate
milestones: deterministic whole-root call-closure planning, and actual helper
C++ body/direct-call emission. The latter already belongs to task 4.12 and
depends on the shared Entry Plan, frame/depth RAII and recursion guard. Task
3.10 is therefore clarified to build and validate the complete normalized
closure and choose `InternalSemanticHelper`, `Bridge`, or exact caller
fallback without publishing symbols. Task 4.12 remains responsible for
materializing every planned internal helper/direct SCC and proving bounded
recursive execution. This preserves the final requirement while preventing a
closure-analysis task from claiming unimplemented Provider output.

Three implementation shapes were considered. Walking Engine pointers inside
the emitter was rejected because failure after partial emission could leave an
undeclared cross-backend helper. Planning directly over the raw generation
graph was rejected as the public algorithm boundary because it couples SCC
and capability tests to disposable Engine objects. The selected shape first
normalizes exact task-local function IDs, stable keys, verified HIR,
eligibility inputs, bridge availability and capability facts, then runs one
pure deterministic closure planner. Production builds those facts from the
same frozen generation graph; tests can exercise ordering, SCCs and failure
spans without fabricating persistent Engine pointers. Only the planner's
pointer-free result may cross the backend output boundary.

### Task 3.10 intermediate checkpoint: planner GREEN, source-call feed still RED

The pure deterministic call-closure planner and its production backend seam
are now implemented. It traverses reachable `ResolvedCall` nodes in the
recorded evaluation order, classifies direct UFUNCTION roots, internal
semantic helpers, proven bridges and unsupported callees, reports the exact
offending call span, computes deterministic Tarjan SCCs, adds the recursion
budget requirement for recursive components, and intersects direct execution
capabilities over the complete reachable direct set. The pointer-free plan is
built once per selected root before backend output is populated; actual helper
C++ symbols and bounded entry remain owned by task 4.12.

The TDD RED build proved that no call-closure API existed:

```text
Build: typed-ast-jit-call-closure-red
Result: expected RED; missing AngelscriptTypedASTJITCallClosure.h
Evidence: Saved/Build/typed-ast-jit-call-closure-red/
          20260814_150830_914_8716bce5/Build.log
```

During the first GREEN compile, the maintained `asCArray` was incorrectly
treated as a range-for container. The two operand/child walks were changed to
the fork's indexed `GetLength()`/`operator[]` contract. The first focused run
then passed five cases and exposed only a CQTest diagnostic-conversion ensure:
`FAngelscriptStableFunctionKey` has equality but no CQTest `ToString` adapter,
so the two key assertions now compare through `IsTrue(operator==)`.

```text
Build (expected implementation compile failure):
  typed-ast-jit-call-closure-green-candidate/
  20260814_152035_363_7004d008/Build.log
  Failure: asCArray has no begin/end

Focused UE (test-harness RED after production compiled):
  typed-ast-jit-call-closure-green/
  20260814_152219_794_b86fe259/Report/index.json
  Result: total=6 passed=5 failed=1; CQTest key ToString ensure

Build: typed-ast-jit-call-closure-green-candidate-3
Result: Succeeded, 4/4 actions
Evidence: Saved/Build/typed-ast-jit-call-closure-green-candidate-3/
          20260814_152339_487_9941953f/Build.log

Focused UE: typed-ast-jit-call-closure-green-2
Result: call closure total=6 passed=6 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-call-closure-green-2/
          20260814_152411_881_3745e360/Report/index.json

Focused UE: typed-ast-jit-call-closure-eligibility-regression
Result: eligibility plus call closure total=13 passed=13 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-call-closure-eligibility-regression/
          20260814_152511_732_d77bcdb9/Report/index.json

Focused UE: typed-ast-jit-call-closure-generated-output
Result: generated-output sentinels total=2 passed=2 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-call-closure-generated-output/
          20260814_152617_728_fb9e6505/Report/index.json

Focused UE: typed-ast-jit-call-closure-generation-engine
Result: generation Engine total=16 passed=16 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-call-closure-generation-engine/
          20260814_152728_314_efa14d86/Report/index.json

Focused UE: typed-ast-jit-call-closure-project-route
Result: real Project Generate/Verify route total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-call-closure-project-route/
          20260814_153159_148_231a6e15/Report/index.json
```

The final project-route inspection found an important remaining dependency,
so task 3.10 is intentionally not checked yet. The real fixture compiles
`ProjectEntry() -> ProjectHelper()`, but the current maintained compiler
vertical slice does not yet create `ResolvedCall` HIR from source; the call
node exists only in synthetic planner tests. Consequently the backend seam is
live, but production cannot yet prove that this real root/helper edge entered
the closure. Work is reordered to add a native source-to-HIR call RED test,
capture the resolved target plus unique formal bindings and authoritative
evaluation permutation in the existing compiler call path, then expose an
exact production closure observation. This advances the call portions of
tasks 2.2 and 2.11-2.16 without claiming those broader capture matrices are
complete. Scalar bridge availability, live capability profiles and helper
body emission remain tasks 5.9, 3.13 and 4.12 respectively.

### Task 3.10 final checkpoint: source call feed and production closure GREEN

The missing production feed is now implemented for the bounded global-script
call form. The maintained compiler records a `ResolvedCall` only after normal
call resolution has selected an exact `asFUNC_SCRIPT` target and the complete
typed argument set is representable. Operands are stored in formal-parameter
order, while a separate unique evaluation permutation records the maintained
fork's authoritative reverse argument-evaluation order. Function IDs remain
Engine-local lookup coordinates and are normalized to stable function keys by
the generation-task planner before any result can cross the backend boundary.
Methods, mixins, funcdefs, imports and native/system calls remain fail-closed
until their dedicated capture forms are implemented; no partial inner-call HIR
is retained when an enclosing unsupported call makes the function sidecar
incomplete.

The native compiler RED test first proved that a real source call did not
produce a `ResolvedCall`:

```text
Focused UE RED: typed-semantic-source-call-red
Result: expected failure in
  ResolvedGlobalCallCapturesFormalBindingsAndReverseEvaluation
Evidence: Saved/Tests/typed-semantic-source-call-red/
          20260814_153822_476_459912d9/Report/index.json
```

The first implementation compile then exposed a local-variable shadowing
warning promoted to error (`C4456`); the builder local was renamed without
changing call semantics. The fresh compile and focused source test passed:

```text
Build GREEN: typed-semantic-source-call-green-candidate-2
Result: Succeeded
Evidence: Saved/Build/typed-semantic-source-call-green-candidate-2/
          20260814_154127_475_b3c16719/Build.log

Focused UE GREEN: typed-semantic-source-call-green
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-semantic-source-call-green/
          20260814_154140_913_52aedb59/Report/index.json
```

The real Project Generate/Verify fixture now declares a global `UFUNCTION`
root `ProjectEntry()` calling the non-root `ProjectHelper()`. Production
backend observations prove the root has a closure, the real source edge is
planned, and the callee is classified as `InternalSemanticHelper` in both
Generate and Verify. This integration uncovered two reflection-only statics
surface assumptions: a global `UFUNCTION` creates one descriptor-only
`bIsStaticsClass` with no `ScriptType`, which generation-only function-fact
capture and current-module authority had mistaken for the root-class vertical.
Generation function-fact capture now recognizes that exact surface as the
global-function vertical; ordinary Cache V2 clean-capture admission is not
broadened. Current authority likewise routes that exact reflection-only
surface through global-function identity resolution.

```text
Production UE GREEN: typed-ast-jit-production-closure-internal-helper-green
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-production-closure-internal-helper-green/
          20260814_155305_056_81ee7efe/Report/index.json
```

The closure regression also found that malformed call evaluation data was
being collapsed to generic `InvalidTypedHIR`. The verifier now reports the
append-only `InvalidCallEvaluationSequence` error and eligibility maps it to
the existing source-located fallback reason. It rejects invalid lengths and
non-permutations before planning any call.

```text
Focused UE GREEN: typed-ast-jit-call-evaluation-diagnostic-green
Result: eligibility plus closure total=13 passed=13 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-call-evaluation-diagnostic-green/
          20260814_155738_150_1803799f/Report/index.json

Focused UE GREEN: typed-ast-jit-closure-generated-output-regression
Result: generated-output sentinels total=2 passed=2 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-closure-generated-output-regression/
          20260814_155826_091_65d70e5b/Report/index.json
```

One Generation Engine regression selected
`EvaluateGenerationEmit_65C28A()`, which contains both a supported script
call and the intentionally unsupported native `Math::Abs` call, while the
test's actual contract is only that the selected capture profile is frozen
before target source compilation. Keeping the whole function fail-closed was
correct. The test now observes the adjacent fully representable scalar
`IncrementGenerationEmit_65C28A()` instead of weakening native-call capture.
The fresh build and complete Engine prefix are GREEN:

```text
Build GREEN: typed-ast-jit-profile-test-scope-green-2
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-profile-test-scope-green-2/
          20260814_160338_255_c7bb3059/Build.log

Focused UE GREEN: typed-ast-jit-closure-generation-engine-green
Result: total=16 passed=16 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-closure-generation-engine-green/
          20260814_160533_475_9ebfe7bf/Report/index.json
```

The exact Cache impact set proves the reflection-only statics classification
does not change ordinary global-function/root-class persistence or StaticJIT
route isolation:

```text
GlobalFunctionOnlyRestore: 1/1 PASS
  Saved/Tests/typed-ast-jit-cache-global-function-green/
  20260814_160735_258_dc95cccb/Summary.json
RootClassRestore: 1/1 PASS
  Saved/Tests/typed-ast-jit-cache-root-class-green/
  20260814_160735_258_1fdc9ec5/Summary.json
ClassGraphReflectionRestore: 2/2 PASS
  Saved/Tests/typed-ast-jit-cache-class-graph-green/
  20260814_160735_259_7de312ac/Summary.json
StaticJITIsolation: 3/3 PASS
  Saved/Tests/typed-ast-jit-cache-static-jit-isolation-green/
  20260814_160735_259_1b82544f/Summary.json
```

The shared maintained-fork changes also pass the independent host suite:

```text
Standalone: typed-ast-jit-call-closure-final_01_Standalone
Result: total=20 passed=20 failed=0
Evidence: Saved/StandaloneTests/
          typed-ast-jit-call-closure-final_01_Standalone/
          20260814_160844_463_0759bb3c/Summary.json
```

The final sentinel scan finds no `FAngelscriptJITExecutionContext` reference
under `StaticJIT/TypedASTJIT`, and both parent/plugin `git diff --check` pass
(only existing line-ending conversion warnings are printed). Task 3.10 is
therefore complete as a pointer-free deterministic closure-planning milestone:
transitive internal helpers, generated/external-implicit-this bridge or exact
fallback, mixin rejection, recursive SCC capability closure, malformed task
coordinates, missing targets and source-located evaluation errors are covered.
Actual helper C++ body/direct-call materialization remains task 4.12; broader
method/mixin/import/native source capture remains within the open 2.x capture
matrix; live execution profiles and developer diagnostics remain tasks 3.13,
3.14 and 7.1-7.2.

### Task 3.11: per-function selection and fallback isolation GREEN

The generator already owned the required per-function backend merge from the
unified StaticJIT prerequisite: an emitted primary result is never overwritten
by a later fallback backend, an unsupported primary result accumulates an
ordered backend-attempt chain, an emitted Bytecode result replaces only that
function, and a final unsupported Bytecode result leaves the VM route
authoritative. Task 3.11 therefore added exact characterization rather than a
second selection implementation.

The backend contract fixture now names and distinguishes three same-module
roots: `EligibleTypedRoot`, `RequiredCalleeFallbackRoot`, and
`VmFallbackRoot`. It proves the first has exactly one successful `typed-ast`
attempt, the second preserves the source-located Typed `UnsupportedCall`
attempt before a successful `bytecode` attempt, and the third retains two
unsupported attempts with no emitted function so VM remains authoritative.
Only the first two functions enter the packaged Provider, and the module still
owns one generated translation unit.

A closure-level fixture independently plans an eligible leaf root and a second
root whose required callee carries a valid `PropertyAccess` unsupported marker.
The initial RED exposed two test-construction mistakes rather than a production
selection defect: the first run asserted an internal callee reason through the
root-detail string, and the second had built a half-normalized mixin receiver,
correctly producing `InvalidEffectiveReceiver`. The final fixture uses valid
HIR and checks the typed fields directly: the affected root reports
`UnsupportedCall` at `73:11`, its call records callee reason
`UnsupportedExpression`, and the independent root remains eligible before and
after planning the failed closure.

```text
Focused UE RED: typed-ast-jit-per-function-closure-green-2
Result: total=7 passed=6 failed=1; root/callee diagnostic-layer assertion
Evidence: Saved/Tests/typed-ast-jit-per-function-closure-green-2/
          20260814_161723_581_7d702714/Summary.json

Focused UE RED: typed-ast-jit-per-function-closure-green-3
Result: total=7 passed=6 failed=1; malformed half-normalized mixin fixture
Evidence: Saved/Tests/typed-ast-jit-per-function-closure-green-3/
          20260814_161926_592_23c8ece9/Summary.json

Build GREEN: typed-ast-jit-per-function-selection-green-2
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-per-function-selection-green-2/
          20260814_162046_522_97262217/Build.log

Focused UE GREEN: typed-ast-jit-per-function-backend-green
Result: backend contract total=9 passed=9 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-per-function-backend-green/
          20260814_161623_884_d420d7c5/Summary.json

Focused UE GREEN: typed-ast-jit-per-function-closure-green-4
Result: call closure total=7 passed=7 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-per-function-closure-green-4/
          20260814_162108_284_afe07965/Summary.json
```

This closes the selection/merge contract only. Production Typed C++ body
publication remains tasks 4.1-4.10 and 7.5; task 3.11 does not relabel the
current analysis-only Typed backend output as emitted code.

### Tasks 3.12-3.13: execution capability profile RED

The existing call-closure planner already carried the eight conceptual direct
capability bits and failed closed on a missing intersection, but the production
Typed backend still supplied `None` for every function and an empty requirement
set for every root. There was no explicit immutable generation capability
profile, current-requirements snapshot, or stable profile/content identity.

The next TDD checkpoint adds a table-driven route matrix for position-only,
breakpoint, step, locals, coverage, loop timeout, abort/suspend polling and
recursion budget; an unknown-bit fail-closed case; deterministic capability,
requirements and profiled-content hashes; and an instrumented-root to
uninstrumented-child closure failure at the exact call span. The first official
build fails only because the intentionally referenced profile API does not yet
exist:

```text
Build RED: typed-ast-jit-execution-profile-red
Expected failure: C1083 missing
  StaticJIT/TypedASTJIT/AngelscriptTypedASTJITExecutionProfile.h
Evidence: Saved/Build/typed-ast-jit-execution-profile-red/
          20260814_163319_128_7d6dc12c/Build.log
```

The implementation boundary is deliberately narrower than a Provider ABI
change. Capability data receives its own stable identity and later Typed
emission combines that identity with the authoritative function execution
hash. It does not change `ProviderId`, does not reinterpret Cache V2's source
`ArtifactProfile`, and does not invent a temporary long-lived catalog field
before tasks 7.3-7.5 confirm the shared Provider contract.

### Tasks 3.12-3.13: execution capability profile GREEN

`AngelscriptTypedASTJITExecutionProfile.h/.cpp` now owns the normalized
generation capability profile and current execution-requirements snapshot for
frame position, line callback, debugger step/locals, coverage, loop-timeout
safe points, abort/suspend polling and recursion budget. Both records reject
unknown bits, have schema-scoped deterministic identities and expose stable
normalized dumps. The profiled-content identity combines the authoritative
source execution hash with the generation capability identity without
changing `ProviderId` or reinterpreting Cache V2's source artifact profile.

The production request, compiled-source graph and Typed backend closure path
now carry these explicit records. Every directly emitted function contributes
its capability profile to closure validation. Recursive SCC discovery adds
the recursion-budget requirement before routing. A missing observability or
control capability produces the typed fallback reason plus an ordered stable
detail, and an instrumented root cannot directly call a child whose generation
profile lacks the same requirements.

The first implementation build exposed two local integration mistakes: the
new header used `AS_CAN_GENERATE_JIT` before including `StaticJITConfig.h`, and
four CQTest assertions placed their diagnostic argument outside `IsTrue`, so
the single-argument `ASSERT_THAT` macro saw an extra argument. Adding the
authoritative config include and moving each message into the matcher closed
both issues; no design or public Provider ABI change was required.

```text
Implementation build RED: typed-ast-jit-execution-profile-green-1
Expected integration failures: undefined AS_CAN_GENERATE_JIT and four
  ASSERT_THAT macro argument errors
Evidence: Saved/Build/typed-ast-jit-execution-profile-green-1/
          20260814_164325_828_d3540784/Build.log

Build GREEN: typed-ast-jit-execution-profile-green-2
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-execution-profile-green-2/
          20260814_164433_791_57e86dc5/Build.log

Focused UE GREEN: typed-ast-jit-execution-profile-green
Result: execution profile total=5 passed=5 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-execution-profile-green/
          20260814_164504_004_d8f1a10c/Summary.json

Focused UE GREEN: typed-ast-jit-capability-closure-green
Result: direct-call closure total=8 passed=8 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-capability-closure-green/
          20260814_164546_396_4fc6c8f1/Summary.json

Focused UE GREEN: typed-ast-jit-capability-backend-green
Result: backend contract total=9 passed=9 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-capability-backend-green/
          20260814_164645_334_684b19d0/Summary.json

Focused UE GREEN: typed-ast-jit-capability-generation-engine-green
Result: isolated generation Engine total=16 passed=16 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-capability-generation-engine-green/
          20260814_164728_899_a32a725d/Summary.json
```

The generated instrumentation hooks and final per-function Provider execution
hash are still intentionally deferred to tasks 4.13 and 7.3-7.5. This
checkpoint establishes the immutable profile/requirements identity and
fail-closed routing contract those later publication tasks must consume.

### Task 3.14: dedicated HIR dump Commandlet RED

The dedicated developer/test dump surface is being implemented as a separate
request/result type and UObject commandlet, not as an
`UAngelscriptJITCommandlet` mode or registered Static backend. Its planned
production seam reuses one shared complete-project source-graph compiler with
the ordinary artifact builder, while the dump request sets typed HIR capture
directly on the restricted generation Engine and never constructs a StaticJIT
generation profile or invokes Provider packaging.

The initial integration tests require a concrete profile, default `Format` to
`Both`, normalize exact full stable-key filters, preserve complete graph counts
under output filtering, emit deterministic pointer-free text/JSON, keep
engine-local call IDs out of the dump, create no C++ or backend observation,
and prove a subsequent StaticJIT build consumes only same-compilation HIR while
leaving deliberately corrupted dump files untouched.

```text
Build RED: typed-ast-jit-hir-dump-red
Expected failure: C1083 missing
  StaticJIT/AngelscriptHIRDumpCommand.h
Evidence: Saved/Build/typed-ast-jit-hir-dump-red/
          20260814_165654_536_b29f55c9/Build.log
```

### Task 3.14: dedicated HIR dump Commandlet GREEN

`UAngelscriptHIRDumpCommandlet` and its testable
`FAngelscriptHIRDumpCommand` service now form a dedicated developer/test
surface. The request requires one concrete Editor/Game/Shipping profile,
defaults to `Format=Both` and
`Saved/Angelscript/HIRDump/<Profile>/`, accepts only complete 64-hex stable
module/function filters, and exposes no backend, Provider, fallback, entry, or
execution-counter fields. `Mode=DumpHIR` remains invalid for the ordinary JIT
command parser, and the UObject commandlet is not an
`UAngelscriptJITCommandlet` subclass.

StaticJIT artifact generation and HIR dumping now share
`FAngelscriptProjectSourceGraph`, which owns exactly one restricted
`StaticJITGeneration` Engine, full Bind replay, the complete project Script
graph, an explicit bytecode-or-verified-HIR capture profile, synchronous
snapshot consumption, disabled Cache V2 persistence, and deterministic
scratch teardown. Artifact generation remains the only consumer that creates
a generation profile/backend request and packages Provider files; the HIR
consumer serializes the same-compilation verified HIR directly and emits no
C++ or Provider artifact.

Text and JSON output carry the complete graph identity/counts plus a stable
ordered selected-function view. Engine-local script call IDs are normalized to
stable script/environment target identities before serialization; unresolved
identity fails closed. Repeated execution is byte deterministic and
pointer-free. Filtering changes only the output selection, not the complete
graph identity. A deliberately corrupted persisted `.hir.txt` remains
untouched by a later production StaticJIT build, which proves dump files are
diagnostic output rather than compiler input.

The first focused GREEN attempt passed four of five tests. The only failure was
the CQTest harness treating the commandlet's intentional missing-profile error
log as unexpected; registering that exact expected error fixed the test without
changing production behavior.

The new success/failure containment test then exposed a substantive failure
path bug: the shared source-graph service used the default startup-compile
failure handler, so invalid AS source called
`FPlatformMisc::RequestExitWithStatus(..., 3)` and terminated the owning Editor
test process. The contained service now overrides
`HandleStartupCompileFailureExit` with a local no-op and explicitly checks
`DidInitialCompileSucceed()`. Compile failure is therefore returned through the
typed command result instead of becoming a process side effect. The regression
compares the complete primary Engine/package/registry/TLS/UObject/delegate/
coverage snapshot after both success and failure, proves the failed attempt
does not overwrite the last successful text/JSON snapshot, and proves scratch
files are released.

```text
Initial implementation build GREEN: typed-ast-jit-hir-dump-green-1
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-hir-dump-green-1/
          20260814_170429_123_c7d786f7/Build.log

Focused UE intermediate: typed-ast-jit-hir-dump-green-1
Result: HIR dump total=5 passed=4 failed=1 skipped=0
Cause: intentional commandlet error log lacked CQTest expected-error registration
Evidence: Saved/Tests/typed-ast-jit-hir-dump-green-1/
          20260814_170549_781_2d2b2f2a/Summary.json

Focused UE GREEN before deep containment: typed-ast-jit-hir-dump-green-2
Result: HIR dump total=5 passed=5 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-hir-dump-green-2/
          20260814_170720_658_7449b51a/Summary.json

Containment RED: typed-ast-jit-hir-dump-containment-green
Result: process exited with status 3 on contained source compile failure
Evidence: Saved/Tests/typed-ast-jit-hir-dump-containment-green/
          20260814_171226_051_e3e075a8/Automation.log

Final build GREEN: typed-ast-jit-hir-dump-containment-green-2
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-hir-dump-containment-green-2/
          20260814_171415_488_d9e1e748/Build.log

Focused UE GREEN: typed-ast-jit-hir-dump-containment-green-2
Result: generation Engine total=17 passed=17 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-hir-dump-containment-green-2/
          20260814_171435_469_260d6f83/Summary.json

Focused UE GREEN: typed-ast-jit-hir-dump-green-final
Result: HIR dump total=5 passed=5 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-hir-dump-green-final/
          20260814_171626_873_8dfa8e7c/Summary.json

Focused UE GREEN: typed-ast-jit-hir-dump-commandlet-regression
Result: JIT commandlet total=6 passed=6 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-hir-dump-commandlet-regression/
          20260814_171721_438_a89cf9cf/Summary.json

Focused UE GREEN: typed-ast-jit-hir-dump-project-generation-regression
Result: project-generation service total=9 passed=9 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-hir-dump-project-generation-regression/
          20260814_171811_359_d80b52d9/Summary.json
```

This closes only the standalone HIR developer surface. Typed function-level
fallback/execution diagnostics and `as.StaticJIT.DumpDiagnostics` remain tasks
7.1-7.2; source-authority freshness remains task 3.15.

### Task 3.15: authoritative source freeze and contained generation

The Editor refresh path now captures one immutable source-authority snapshot
from the current primary Runtime Engine before it creates a generation Engine.
It verifies the exact EditorDevelopment profile, project Script root, stable
module inventory, and strong source-text identity. A current snapshot owns a
frozen source provider containing the exact text/bytes observed by the primary
compile; the one contained generation Engine consumes that provider directly.
No ForceClean, cache clear, primary recompile, reload, reinstancing, Provider
publication, or route mutation is used to manufacture freshness. A mismatch
returns `AuthoritativeEngineStale` with an explicit Hot Reload/recompile
instruction before generation starts.

The first real-primary integration run exposed that `FFile::RawCode` is
destructively blanked while preprocessing macros and imports. Hashing it after
`ParseIntoChunks` therefore compared transformed whitespace against the actual
source file. `SourceTextHash` is now frozen immediately after source loading
and before preprocessing mutation, and cache restoration reconstructs the same
hash from its authoritative raw source bytes.

The next full-project run exposed a second complete-graph gap: non-`UPROPERTY`
members are synthesized into `FAngelscriptPropertyDesc` during class analysis,
but intentionally have no preprocessor `LiteralType`. Generation snapshot
capture had treated that optional reflection spelling as the canonical VM type
and rejected `FExampleStruct::ExampleHiddenNumber`. A dedicated plain-struct
RED test now covers the shape. Capture resolves the exact generation-Engine
`asCObjectProperty` by its stable index/name and formats its compiled data type
using the same rule as the runtime reference resolver; the resulting
PropertyKey and detached descriptor declaration are therefore complete without
consulting primary-Engine pointers or materialized Unreal reflection.

```text
Authority API build RED: typed-ast-jit-refresh-authority-red
Expected failure: missing source-authority snapshot/dependency API
Evidence: Saved/Build/typed-ast-jit-refresh-authority-red/
          20260814_173748_409_2714785a/Build.log

Initial production build GREEN: typed-ast-jit-refresh-authority-compile-1
Result: Succeeded (140 actions)
Evidence: Saved/Build/typed-ast-jit-refresh-authority-compile-1/
          20260814_174458_716_ab93c1f1/Build.log

State-machine GREEN: typed-ast-jit-refresh-authority-state-green
Result: refresh service total=6 passed=6 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-refresh-authority-state-green/
          20260814_174729_235_df253136/Summary.json

Real-primary intermediate: typed-ast-jit-refresh-authority-integration-green-2
Result: 6 passed, 1 failed
Cause: descriptor `ExampleHiddenNumber` had no canonical type because it was
       a non-UPROPERTY member
Evidence: Saved/Tests/typed-ast-jit-refresh-authority-integration-green-2/
          20260814_175304_017_0f30bcac/Automation.log

Plain-struct RED: typed-ast-jit-plain-struct-identity-red-2
Result: generation Engine total=18 passed=17 failed=1 skipped=0
Expected failure: `PlainHiddenValue_65C28A` incomplete descriptor identity
Evidence: Saved/Tests/typed-ast-jit-plain-struct-identity-red-2/
          20260814_175915_861_b22ee342/Summary.json

Plain-struct build GREEN: typed-ast-jit-plain-struct-identity-green-2
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-plain-struct-identity-green-2/
          20260814_180358_981_4bc7f341/Build.log

Plain-struct focused GREEN: typed-ast-jit-plain-struct-identity-green
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-plain-struct-identity-green/
          20260814_180423_349_a35df91a/Summary.json

Real-primary full-project GREEN: typed-ast-jit-refresh-authority-integration-green-3
Result: refresh service total=7 passed=7 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-refresh-authority-integration-green-3/
          20260814_180522_165_475f786d/Summary.json

Focused cache-restore GREEN: typed-ast-jit-source-hash-cache-restore-green
Result: exact warm restore total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-source-hash-cache-restore-green/
          20260814_180719_659_111ab85e/Summary.json
```

### Task 3.16 preflight: scalar cleanup proof and primary-Engine routing

The first complete StaticJIT selection run completed normally without a
timeout and reported 205/207 passing. Its two failures exposed independent
contract mistakes rather than infrastructure stalls.

`SemanticScalarBranch` was left with an unverified cleanup plan because the
compiler required `scriptData->objVariableInfo` to be empty. That array also
contains ordinary lexical `asBC_Block` markers, so a nested scalar block was
incorrectly treated as managed lifetime state. The proof now relies on the
actual object-variable type table, try/catch table, scalar signature, and
per-allocation scalar checks; object, handle, reference, and non-scalar
allocations remain rejected. A maintained-fork regression asserts that a
nested scalar branch publishes `VerifiedEmpty`.

The Editor Generate/Refresh path also called `FAngelscriptEngine::Get()` while
claiming to consume the process primary Engine. That accessor intentionally
resolves the current scoped Engine, which can be an isolated Runtime test or
tool Engine. Refresh authority capture and route publication now resolve the
subsystem-owned primary Engine directly. Profile mismatch diagnostics report
every actual/expected EditorDevelopment flag without pointer identity.

```text
Initial complete StaticJIT run: typed-ast-jit-selection
Result: total=207 passed=205 failed=2 skipped=0 timedOut=false
Evidence: Saved/Tests/typed-ast-jit-selection/
          20260814_180915_859_1eb336ec/Summary.json

Scalar cleanup RED: typed-ast-jit-cleanup-plan-red-exact
Result: total=1 passed=0 failed=1 skipped=0 (expected RED)
Evidence: Saved/Tests/typed-ast-jit-cleanup-plan-red-exact/
          20260814_182629_552_cbfd2bc6/Summary.json

Scalar cleanup build GREEN: typed-ast-jit-cleanup-plan-green
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-cleanup-plan-green/
          20260814_182730_466_097780fe/Build.log

Scalar cleanup fork GREEN: typed-ast-jit-cleanup-plan-green
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-cleanup-plan-green/
          20260814_182747_472_890f6bbf/Summary.json

Typed AOT generation GREEN: typed-ast-jit-selection-aot-green
Result: total=1 passed=1 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-selection-aot-green/
          20260814_182849_591_270f0139/Summary.json

Primary-authority build GREEN: typed-ast-jit-primary-authority-green
Result: Succeeded
Evidence: Saved/Build/typed-ast-jit-primary-authority-green/
          20260814_183607_277_eabbc93b/Build.log

Primary-authority refresh GREEN: typed-ast-jit-primary-authority-green
Result: total=7 passed=7 failed=0 skipped=0
Evidence: Saved/Tests/typed-ast-jit-primary-authority-green/
          20260814_183629_463_f0276078/Summary.json

Final complete StaticJIT GREEN: typed-ast-jit-selection-green
Result: total=207 passed=207 failed=0 skipped=0 timedOut=false
Runner duration: 570377 ms; test duration: 388.735 s
Evidence: Saved/Tests/typed-ast-jit-selection-green/
          20260814_183802_488_641ffa71/Summary.json
```

This closes task 3.16 and Group 3. The next implementation unit is Group 4's
shared entry plan and scalar TypedASTJIT emitter, beginning with task 4.1's
RED generated-output and bytecode-sentinel coverage.

## 2026-08-14 — Task 4.1 incremental RED/GREEN: typed bool short-circuit

The first Group 4 emitter slice reuses the approved
`semantic-aot-v1/short-circuit` research golden. A new focused generated-output
case requires a verified `bool Left && Right` HIR function to emit a stable
typed C++ signature and short-circuit expression without naming
`FAngelscriptJITExecutionContext`.

The official RED build compiled successfully, then the focused Automation
prefix failed only the new case because the existing analyzer still rejected
all non-`int` shapes:

```text
Build: typed-ast-jit-short-circuit-red PASS
Evidence: Saved/Build/typed-ast-jit-short-circuit-red/
          20260814_185646_952_8359377b/Build.log

Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Result: 2/3 PASS, 1 expected FAIL
Failure: ShortCircuitUsesTypedBoolCppWithoutGenericExecutionContext
Evidence: Saved/Tests/typed-ast-jit-short-circuit-red/
          20260814_185707_870_8b4b9e29/Summary.json
```

The minimal GREEN change adds reviewed `bool` C++ spelling, validates
`bool &&`/`bool ||` operands in the provider-independent analyzer, emits the
HIR short-circuit node directly, and adds
`FAngelscriptJITExecutionContext` to the production generated-text forbidden
token check. It does not add a generic execution object or Runtime arithmetic
dispatch.

```text
Build: typed-ast-jit-short-circuit-green PASS
Evidence: Saved/Build/typed-ast-jit-short-circuit-green/
          20260814_185858_866_653a623a/Build.log

Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Result: 3/3 PASS
Evidence: Saved/Tests/typed-ast-jit-short-circuit-green/
          20260814_185917_380_1dfbdee7/Summary.json
```

Both focused test processes exited immediately after report export; no target
worktree Editor/UBT/test process remained. Task 4.1 stays open: the remaining
scalar type/literal/conversion matrix, one-evaluation assignment/compound/
prefix/postfix plans, unary/binary coverage, compile-out proof, and the complete
eligibility/reference/emission bytecode-access sentinel still require their own
RED/GREEN slices.

## 2026-08-14 — Task 4.1 incremental RED/GREEN: primitive C++ spellings and widening conversion

The next focused emitter slice freezes the C++ spellings for every primitive
scalar identity signature: `int8`, `uint8`, `int16`, `uint16`, `int32`,
`uint32`, `int64`, `uint64`, `float`, `double`, and `bool`. A second golden
requires deterministic typed locals, an `int8(7)` literal, and a direct
`static_cast<int64>` for the reviewed `int32`-to-`int64` widening conversion.
Both generated definitions remain context-free and explicitly reject
`FAngelscriptJITExecutionContext`.

The official RED build compiled successfully. The focused prefix then failed
only the two new cases because the analyzer/emitter still accepted only
`int32`/`bool` and had no Conversion lowering:

```text
Build: typed-ast-jit-primitives-red PASS
Evidence: Saved/Build/typed-ast-jit-primitives-red/
          20260814_190624_982_f16d1676/Build.log

Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Result: 3/5 PASS, 2 expected FAIL
Failures: PrimitiveScalarSignaturesUseFixedWidthCppSpellings
          TypedLocalsEncodeLiteralsAndExplicitConversions
Evidence: Saved/Tests/typed-ast-jit-primitives-red/
          20260814_190645_728_b879c54a/Summary.json
```

The minimal GREEN implementation maps those exact AS primitive tokens to UE
fixed-width C++ spellings, emits integer literals through their verified HIR
type, and admits only same-signedness widening integer conversions. Narrowing,
signedness-changing, integer/float, float/integer, and other boundary-sensitive
conversions still fail closed until the dedicated semantic-equivalence tasks
define and test their exact behavior.

```text
Build: typed-ast-jit-primitives-green PASS
Evidence: Saved/Build/typed-ast-jit-primitives-green/
          20260814_190919_971_d78230ae/Build.log

Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Result: 5/5 PASS
Evidence: Saved/Tests/typed-ast-jit-primitives-green/
          20260814_190936_963_08ac35a8/Summary.json
```

The GREEN Editor process exited 202 ms after test completion. No full StaticJIT
run was repeated for this local emitter slice; the last complete milestone
evidence remains 207/207 PASS. Task 4.1 remains open for the remaining literal,
operator, assignment/update, compile-out, and bytecode-access-sentinel work.

### Task 5.8 clarification: UE Binding targets are real lowering targets

Typed AOT call lowering must cover UE/FBind calls, not only script-to-script
and scalar arithmetic. When the resolved external descriptor proves an exact
scalar ABI plus an exported or header-inline callable, emitted C++ invokes the
actual underlying UE/C++ target. A provider-private implementation may be
exposed only through a deliberately reviewed narrow Runtime thunk. RPC,
Blueprint-event, overridable virtual, complex out/ref, container, and other
UE-semantic calls retain the current UE route/VM bridge unless an equally
strong contract is introduced. Diagnostics must report the resolved target and
one of `DirectExported`, `DirectInline`, `RuntimeThunk`, or `Bridge`, including
the reason for every downgrade; symbol spelling or a private header is never
accepted as DLL/linkage proof.

## 2026-08-14 — Task 4.1/4.3 incremental RED/GREEN: context-free integer wrap and shift lowering

This slice freezes the first integer operator lowering without introducing a
generic execution object. The new header-only `AngelscriptTypedASTJIT` helpers
are `FORCEINLINE` and perform add/subtract/multiply/negate in the matching
unsigned bit domain, mask shift counts by scalar width, use unsigned bits for
logical right shift, and construct arithmetic-right-shift sign fill explicitly.
The analyzer admits only reviewed integer operand/result shapes, and the emitter
adds the helper include only when one of these operations is present.

The first API RED was a compile-time failure because the new helper header did
not yet exist:

```text
Build: typed-ast-jit-scalar-ops-api-red EXPECTED FAIL
Failure: C1083 cannot open AngelscriptTypedASTJITScalarOps.h
Evidence: Saved/Build/typed-ast-jit-scalar-ops-api-red/
          20260814_191723_968_6b9c90f1/Build.log
```

The initial helper candidate exposed a real C++ naming collision: a namespace
named `Angelscript` conflicts with the existing global UE log category of the
same name and caused C2757 plus cascading `UE_LOG` errors. The implementation
was renamed to the unambiguous `AngelscriptTypedASTJIT` namespace; no log
category or unrelated call site was changed.

```text
Build: typed-ast-jit-scalar-ops-helper-candidate EXPECTED DIAGNOSTIC FAIL
Evidence: Saved/Build/typed-ast-jit-scalar-ops-helper-candidate/
          20260814_191838_981_8c276b50/Build.log

Build: typed-ast-jit-scalar-ops-helper-candidate-2 PASS
Evidence: Saved/Build/typed-ast-jit-scalar-ops-helper-candidate-2/
          20260814_191916_313_e9210857/Build.log
```

After the helper semantics were GREEN, the generated-output RED covered unary
negate, bitwise-not, add/subtract/multiply, left shift, logical `>>`, arithmetic
`>>>`, deterministic helper spelling, conditional include insertion, and the
absence of `FAngelscriptJITExecutionContext`. The existing five cases stayed
GREEN and only the new operator case failed, because Unary/Shift remained
unsupported in the analyzer.

```text
Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Label: typed-ast-jit-scalar-ops-emitter-red
Result: 5/6 PASS, 1 expected FAIL
Failure: ScalarOperatorsUseContextFreeWrapAndShiftHelpers
Evidence: Saved/Tests/typed-ast-jit-scalar-ops-emitter-red/
          20260814_192314_259_cc8a6d41/Summary.json
```

The first GREEN candidate made the new case pass but correctly invalidated the
older scalar-branch golden, which still expected raw signed C++ `+`, `-`, and
`*`. That expectation was updated to the already-approved unsigned-bit-domain
contract rather than weakening the implementation. The final focused build and
both relevant prefixes are GREEN:

```text
Build: typed-ast-jit-scalar-ops-golden-update PASS
Evidence: Saved/Build/typed-ast-jit-scalar-ops-golden-update/
          20260814_192711_503_52e14613/Build.log

Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Label: typed-ast-jit-scalar-ops-emitter-green-2
Result: 6/6 PASS
Evidence: Saved/Tests/typed-ast-jit-scalar-ops-emitter-green-2/
          20260814_192731_505_9cb97efa/Summary.json

Tests: Angelscript.TestModule.StaticJIT.ScalarOps.TypedASTJIT
Label: typed-ast-jit-scalar-ops-helper-green-2
Result: 2/2 PASS
Evidence: Saved/Tests/typed-ast-jit-scalar-ops-helper-green-2/
          20260814_192826_537_5a136acd/Summary.json
```

The two final Editor processes exited 270 ms and 223 ms after their reports;
no target-worktree Editor/UBT/test process remained. The build still reports
pre-existing C4191 warnings in unrelated StaticJIT function-pointer tests.
Tasks 4.1 and 4.3 stay open: mutation single-evaluation plans, narrowing and
boolean normalization, failure-capable numeric operations, compile-out values,
and the complete TypedASTJIT bytecode-access sentinel remain separate slices.

## 2026-08-14 — Tasks 2.1/2.2 incremental RED/GREEN: source mutation capture

This slice adds compiler-authoritative HIR for reviewed scalar source
mutations: ordinary assignment, compound assignment, prefix increment, and
postfix increment. Assignment records the maintained compiler's actual
RHS-before-LHS order, prefix returns the updated value, postfix returns the old
value, and an assignment statement owns its mutation through an explicit HIR
`Expression` statement. Capture-on/capture-off bytecode and VM results remain
identical. The normalized dump now prints operator, target/value IDs, explicit
evaluation order, and `returns=old|updated`; verification rejects missing,
forward, or out-of-arena mutation IDs and invalid old-value shapes.

The initial fixture incorrectly used assignment as a return expression. The
maintained grammar accepts assignment as an expression statement, not as the
condition expression consumed by `return`, so that first run failed during
parsing and was not accepted as RED evidence. The corrected fixture uses
`Value = Input; return Value;` and `Value += 3; return Value;`, while prefix and
postfix remain direct return expressions. Its valid RED compiled successfully,
proved VM/bytecode equality, and failed only because mutation HIR and verifier
checks were absent:

```text
Build: typed-semantic-mutation-capture-red-fixture PASS
Evidence: Saved/Build/typed-semantic-mutation-capture-red-fixture/
          20260814_194114_493_431620fd/Build.log

Tests: Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR
Label: typed-semantic-mutation-capture-red-fixture
Result: 6/8 PASS, 2 expected FAIL
Failures: MutationCapturePreservesRhsFirstAndPrefixPostfixResults
          VerifierRejectsDanglingExpressionsAndMultipleStatementOwnership
Evidence: Saved/Tests/typed-semantic-mutation-capture-red-fixture/
          20260814_194137_048_ed64fd38/Summary.json
```

The first production candidate exposed a capture-seam bug. `DoAssignment()` is
also reused for compiler-internal local initialization such as `int Value = 1`.
Capturing at that layer treated the synthetic initialization destination as a
source mutation; it has no source target expression ID, so the provisional HIR
transaction correctly became unsupported and published nothing. One-run
diagnostic logging confirmed an invalid target before every source mutation;
the logging was removed after diagnosis. The final implementation captures
only from `CompileAssignment()` after a real `snAssignment` succeeds, while
prefix/postfix capture remains at their authoritative primitive update sites.
Internal initialization continues to generate the same bytecode and is not
misrepresented as source HIR.

```text
Build: typed-semantic-mutation-source-seam-green PASS
Evidence: Saved/Build/typed-semantic-mutation-source-seam-green/
          20260814_195442_766_b0de20d7/Build.log

Focused test: MutationCapturePreservesRhsFirstAndPrefixPostfixResults
Result: 1/1 PASS
Evidence: Saved/Tests/typed-semantic-mutation-source-seam-green/
          20260814_195458_299_f5074a67/Summary.json

Tests: Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR
Label: typed-semantic-mutation-capture-final-green
Result: 8/8 PASS
Evidence: Saved/Tests/typed-semantic-mutation-capture-final-green/
          20260814_195552_776_5a67a667/Summary.json
```

The final Editor process exited 127 ms after its report, with no process owned
by this test label remaining. Tasks 2.1 and 2.2 stay open because unary,
conversion, short-circuit, wider mutation targets, discard/void propagation,
and the remaining expression matrix are intentionally separate TDD slices.
The next slice is task 4.1's mutation golden RED, followed by explicit
single-target-evaluation/single-store TypedASTJIT lowering and runtime parity.

## 2026-08-14 — Tasks 4.1/4.14 incremental RED/GREEN: scalar mutation C++ lowering

This slice consumes the compiler-owned mutation plan without recovering any
information from bytecode. The analyzer admits only symbol lvalues with one
reviewed scalar type. Plain assignment supports the reviewed scalar set;
compound `+=`, `-=`, `*=`, prefix `++`/`--`, and postfix `++`/`--` are limited
to reviewed integers and use the context-free unsigned-bit-domain wrap helpers.
Expression statements are now part of the first emitted statement slice.

Generated mutation expressions use immediately invoked typed C++ lambdas. A
value assignment materializes the HIR RHS first, then binds exactly one C++
lvalue reference for the HIR target, performs exactly one store, and returns
the updated value. Prefix updates return the updated target; postfix updates
first copy the old scalar value, perform one store, and return that old copy.
Locals and by-value parameters remain `const` unless a verified mutation targets
their symbol. The output contains no `FAngelscriptJITExecutionContext`.

The new golden was a valid RED: the six existing cases remained GREEN and only
the mutation case failed because Assignment and Expression nodes had no
analyzer/emitter support:

```text
Build: typed-ast-jit-mutation-golden-red PASS
Duration: 80.57 s (adaptive Unity shard Module.AngelscriptTest.44.cpp)
Evidence: Saved/Build/typed-ast-jit-mutation-golden-red/
          20260814_200012_912_6744d0bc/Build.log

Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Label: typed-ast-jit-mutation-golden-red
Result: 6/7 PASS, 1 expected FAIL
Failure: ScalarMutationsMaterializeOneTargetAndOneStore
Evidence: Saved/Tests/typed-ast-jit-mutation-golden-red/
          20260814_200247_197_88379e2a/Report/index.json
```

The 80-second build was not a hang or an Engine/cache-capture pause: UBT spent
77.59 seconds compiling the changed adaptive Unity test shard, then linked and
wrote metadata normally. There was no remaining build process. The production
incremental compile touched one Runtime Unity shard and completed in 11.37
seconds. The focused GREEN then passed all seven cases and the Editor exited
265 ms after test completion:

```text
Build: typed-ast-jit-mutation-emitter-green PASS
Evidence: Saved/Build/typed-ast-jit-mutation-emitter-green/
          20260814_200659_999_ab9e5d08/Build.log

Tests: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Label: typed-ast-jit-mutation-emitter-green
Result: 7/7 PASS
Evidence: Saved/Tests/typed-ast-jit-mutation-emitter-green/
          20260814_200720_144_706fad94/Summary.json
```

Tasks 4.1 and 4.14 stay open: this is the scalar symbol-target mutation slice,
not the complete mutation/runtime parity matrix. Wider lvalues, power shapes,
generated-code compilation/execution, and differential VM/AOT edge coverage
remain explicit later slices.

## 2026-08-14 — Tasks 2.1/2.2 incremental investigation: authoritative system-call targets

This slice begins the external-call boundary needed by later UE Binding direct,
export, thunk, bridge, and fallback routing. The maintained compiler already
published a minimal `ResolvedCall` for global script calls, including formal
argument indices and its actual reverse evaluation sequence. It did not retain
whether the final target was a script function or a registered system function,
and it rejected every system call before publishing otherwise valid HIR.

The HIR now carries an explicit pointer-free call-target kind with
`ScriptFunction` and `SystemFunction` values. The compiler assigns that kind
from the final `asCScriptFunction::funcType`; verification rejects an
`Unspecified` resolved call, and the normalized dump includes
`target=<kind>`. The current slice intentionally does not turn a mutable import
slot into the function to which it happens to be bound: import identity and
binding epoch must remain explicit in a later descriptor slice.

The valid API RED failed only because the new target-kind enum/member did not
exist:

```text
Build: typed-semantic-system-call-api-red expected FAIL
Errors: missing asETypedSemanticCallTargetKind and callTargetKind
Evidence: Saved/Build/typed-semantic-system-call-api-red/
          20260814_201555_366_518c8430/Build.log
```

Changing the public maintained-fork HIR header invalidated 21 large Runtime and
Test Unity/link actions. The first official build used a 180-second timeout and
the runner terminated its still-progressing UBT tree at action 9/21. This was
not an Editor hang, cache-capture stall, or compiler error. The retry reused the
completed objects, compiled the remaining 11 actions under heavy committed
memory pressure, and passed after roughly 443 seconds:

```text
Timed-out build: typed-semantic-system-call-candidate
Evidence: Saved/Build/typed-semantic-system-call-candidate/
          20260814_201724_850_54a565dc/Build.log

Retry: typed-semantic-system-call-candidate-retry PASS
UBA duration: 430.83 s
Total duration: about 443 s
Evidence: Saved/Build/typed-semantic-system-call-candidate-retry/
          20260814_202053_729_a5be9f04/Build.log
```

Four fixture constraints were discovered progressively:

1. `CALLSYS` bytecode contains the registered system-function pointer for its
   owning Engine. Raw capture-on/off bytecode cannot be compared across two
   independent Engines even when source and declarations are identical. The
   fixture was changed to compile both modules in one Engine.
2. Executing the first module's duplicate global function only after a second
   same-declaration module was built made the old function handle unsuitable as
   a VM baseline. The fixture now copies bytecode and executes capture-off
   before compiling capture-on.
3. This maintained fork's CDECL fast-call path needs the generated
   `ASAutoCaller::FunctionCaller` in addition to `asFUNCTION`. Registering only
   the raw address allowed compile/HIR capture but left VM execution without
   the required call thunk. The test registration now uses the same contract as
   the native calling-convention coverage.
4. `GetGlobalFunctionByDecl()` was not a reliable way to rediscover this
   registered system function after the script modules were built. The
   registration result is already the compiler-authoritative Engine-local
   FunctionId, so the fixture now retains that ID and compares HIR against it
   directly instead of inferring identity through another query surface.

```text
Invalid two-Engine bytecode fixture:
  Saved/Tests/typed-semantic-system-call-focused-green/
  20260814_202829_952_01de9b92/

Invalid old-function lifetime fixture:
  Saved/Tests/typed-semantic-system-call-focused-green-2/
  20260814_203058_314_fa131110/Summary.json

Missing AutoCaller fixture evidence:
  Saved/Tests/typed-semantic-system-call-focused-green-3/
  20260814_203412_262_3a282170/Report/index.json

Invalid system-function re-query fixture:
  Saved/Tests/typed-semantic-system-call-focused-green-4/
  20260814_203655_782_1f914b46/Report/index.json

Final fixture build after AutoCaller correction: PASS (11.50 s)
  Saved/Build/typed-semantic-system-call-autocaller-fix/
  20260814_203626_634_42ef76b3/Build.log

Final build after authoritative registration-ID and verifier coverage: PASS
  Saved/Build/typed-semantic-system-call-verifier-green/
  20260814_203941_938_c160fe74/Build.log
```

The final focused test passes VM/bytecode parity, target kind, registration ID,
formal/evaluation mappings, normalized dump, and verifier checks. The complete
HIR prefix also passes the new fail-closed test for an unspecified resolved-call
target, and the only closure prefix affected by the public field remains green:

```text
Focused: ResolvedSystemCallPreservesTargetKindAndVmBehavior
Result: 1/1 PASS
Evidence: Saved/Tests/typed-semantic-system-call-focused-green-5/
          20260814_203834_933_134cc5ed/Summary.json

Tests: Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR
Result: 9/9 PASS
Evidence: Saved/Tests/typed-semantic-system-call-final-green/
          20260814_204010_173_21317f24/Summary.json

Tests: Angelscript.TestModule.StaticJIT.Eligibility.TypedASTJIT.CallClosure
Result: 8/8 PASS
Evidence: Saved/Tests/typed-semantic-system-call-callclosure-regression/
          20260814_204103_463_7c5c3f43/Summary.json
```

All three final Editor processes exited within 301 ms of report completion.
Tasks 2.1 and 2.2 remain open because method/interface/import targets,
hidden/default arguments, conversions, compile-out values, and the full
external-call descriptor are separate planned closures. The next TDD slice
will make CallClosure distinguish a system target awaiting an external-call
descriptor from a genuinely missing script callee; it will continue to fail
closed until the UE Binding route is proven direct/export/thunk/bridge-safe.

## 2026-08-14 — Tasks 5.1/5.10 incremental RED/GREEN: system-call closure boundary

CallClosure previously treated every `ResolvedCall` as a script-call graph
edge. It looked up only `resolvedFunctionId`; a system function therefore
degraded to the generic `ResolvedTargetMissing` diagnostic and the pointer-free
plan did not retain the target kind or Engine-local target ID needed for later
external-call descriptor matching.

The valid API RED required each planned call to retain
`TargetKind + EngineLocalTargetFunctionId` and required an unresolved
`SystemFunction` to report `ExternalCallDescriptorMissing` at the exact HIR
span without entering the script closure lookup. It failed only because the two
new plan fields were absent:

```text
Build: typed-ast-jit-system-call-closure-api-red expected FAIL
Errors: FAngelscriptTypedASTJITCallClosureCall has no TargetKind or
        EngineLocalTargetFunctionId
Evidence: Saved/Build/typed-ast-jit-system-call-closure-api-red/
          20260814_204518_127_63dffeb3/Build.log
```

The production planner now copies both compiler-owned coordinates into every
call-plan record. A `SystemFunction` with no explicit descriptor/bridge is
`UnsupportedCall` with stable detail
`ExternalCallDescriptorMissing: SystemFunctionId=<id>...`; a missing script
callee continues to use `ResolvedTargetMissing`. The normalized dump exposes
`target=<kind> targetId=<id>`, and no C++ symbol is guessed.

```text
Build: typed-ast-jit-system-call-closure-green PASS (14.59 s)
Evidence: Saved/Build/typed-ast-jit-system-call-closure-green/
          20260814_204556_990_e6961e24/Build.log

Focused: SystemTargetsAwaitExplicitExternalDescriptorsWithoutScriptGraphLookup
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-system-call-closure-focused-green/
          20260814_204619_294_9fb02933/Summary.json

Tests: Angelscript.TestModule.StaticJIT.Eligibility.TypedASTJIT.CallClosure
Result: 9/9 PASS
Evidence: Saved/Tests/typed-ast-jit-system-call-closure-final-green/
          20260814_204708_302_4c139224/Summary.json
```

The final Editor processes exited within 215 ms of report completion. This is
the fail-closed descriptor boundary, not yet a direct or bridged UE call.

The group-5 audit also found that the task's original
`StaticJIT/StaticJITBinds.h/.cpp` path no longer exists. Current legacy native
forms live under `StaticJIT/BytecodeJIT/StaticJITBinds.*` and own BytecodeJIT
call-code generation plus Engine-local pointer lookup. The new TypedASTJIT
cross-DLL contract will therefore live under a separate Runtime-owned
`StaticJIT/NativeCalls/` surface and attach to the current Engine-owned bind
state; task 5.2 was updated accordingly. This keeps legacy `.NativeFunction()`
and `.NativeMethod()` behavior unchanged and avoids making a TypedASTJIT
linkage contract an implementation detail of BytecodeJIT.

## 2026-08-14 — Tasks 5.1/5.2 RED/GREEN: explicit native-call descriptor and Engine-owned attachment

The legacy NativeForm contract records BytecodeJIT-oriented call spelling,
optional header text, and triviality, but it does not prove that a generated
consumer module may legally name or link the underlying C++ callable. Treating
that spelling as linkage evidence would be unsafe across UE module/DLL
boundaries. A separate Runtime-owned descriptor now makes that proof explicit
without changing the meaning of existing `.NativeFunction()`,
`.NativeMethod()`, or `.NativeFunctionHeader()` calls.

The descriptor lives under `StaticJIT/NativeCalls/` and carries:

- linkage class: `ExportedSymbol`, `HeaderInline`,
  `ExportedRuntimeThunk`, or `ProviderPrivate`;
- exact callable symbol, declaration include, owning UE module, and API macro;
- a normalized scalar ABI string plus a domain-separated artifact hash;
- route flags for direct call, scalar bridge, `ProcessEvent`, and suspension;
- lifetime proofs for by-value scalar-only arguments, no retained references,
  and no Engine-local capture.

Validation is deterministic and fail-closed. It rejects unknown enum/flag
values, contradictory linkage/visibility, missing or code-like symbol text,
missing/unsafe includes, unknown or non-public module dependencies, missing or
incorrect API macros, invalid/mismatched ABI identities, routing that would
bypass `ProcessEvent` or suspension requirements, and incomplete scalar
lifetime proofs. An entirely absent descriptor is valid metadata state but is
neither directly callable nor bridge-callable; this is the compatibility rule
that keeps every old NativeForm non-external by default.

The first API RED proved the descriptor surface did not exist:

```text
Build: typed-ast-jit-native-call-descriptor-api-red expected FAIL
Error: AngelscriptStaticJITNativeCallDescriptor.h was missing
Evidence: Saved/Build/typed-ast-jit-native-call-descriptor-api-red/
          20260814_205144_196_792b55b5/Build.log
```

The pure descriptor implementation then built and its direct/inline/thunk/
provider-private/absent plus invalid-matrix tests passed:

```text
Build: typed-ast-jit-native-call-descriptor-candidate PASS
Evidence: Saved/Build/typed-ast-jit-native-call-descriptor-candidate/
          20260814_205408_347_6d5ea87e/Build.log

Tests: Angelscript.TestModule.StaticJIT.NativeCallLinkage
Result at this point: 2/2 PASS
Evidence: Saved/Tests/typed-ast-jit-native-call-descriptor-green/
          20260814_205429_425_e3a83639/Summary.json
```

The next RED required explicit descriptor attachment through the fluent bind
result and an Engine-owned lookup surface. It failed only because
`FAngelscriptBoundFunction::ExternalNativeCall` and
`FAngelscriptStaticJITNativeCallRegistry` did not exist:

```text
Build: typed-ast-jit-native-call-registry-api-red expected FAIL
Errors: missing ExternalNativeCall and native-call registry APIs
Evidence: Saved/Build/typed-ast-jit-native-call-registry-api-red/
          20260814_205646_465_1efb33e9/Build.log
```

The public descriptor/registry contract remains in `StaticJIT/NativeCalls/`.
Its backing map extends the existing `FAngelscriptNativeFormState`, so the
ownership rules are exact and do not introduce another process-global
container:

1. attachment is accepted only while compatibility binds are being collected;
2. the target `asIScriptFunction` must belong to the supplied
   `FAngelscriptEngine`;
3. the map key is the exact function pointer inside that exact Engine state;
4. replacing metadata for the same function does not increase the live count;
5. destroying one Engine releases only its descriptors; another Engine with
   the same declaration remains intact;
6. registry pointers are transient and must be copied into immutable generation
   state before crossing an Engine/lifetime boundary.

The fluent call is intentionally explicit:

```cpp
BoundFunction
    .NativeMethod("FExample::Read", true)
    .ExternalNativeCall(ReviewedDescriptor);
```

Calling only `.NativeMethod(...)` continues to create no external descriptor.
The implementation does not infer an export from a name, a private header, or
the native function address.

Because `AngelscriptBinds.h` is a high-fan-out public header, adding the fluent
method invalidated 89 Runtime/Test/generated Unity and link actions. The XGE
build progressed normally and was not hung; it completed all 89 actions in
about 155 seconds. This compile fan-out is now recorded as a design-cost item:
future descriptor-only edits should stay in the dedicated header/implementation,
and the fluent declaration dependency should be narrowed further if it can be
done without making the value type incomplete in Engine-owned storage.

```text
Build: typed-ast-jit-native-call-registry-green PASS (89/89)
Duration: about 155 s
Evidence: Saved/Build/typed-ast-jit-native-call-registry-green/
          20260814_210017_611_495e63e8/Build.log

Focused: ExplicitMetadataAttachesToTheExactEngineFunction
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-native-call-registry-focused-green/
          20260814_210301_767_65fcd2c4/Summary.json

Tests: Angelscript.TestModule.StaticJIT.NativeCallLinkage
Result: 3/3 PASS
Evidence: Saved/Tests/typed-ast-jit-native-call-linkage-final-green/
          20260814_210357_742_147de783/Summary.json

Regression: ChainedTraitsMutateOnlyTheStoredFunction
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-native-call-fluent-regression/
          20260814_210454_996_48d774e2/Summary.json
```

All final Editor processes exited within 290 ms after report completion.
Tasks 5.1 and 5.2 are complete. No generated TypedASTJIT call consumes the
descriptor yet: the next slice must copy the exact descriptor into the frozen
generation/call-closure state, derive the expected scalar ABI from
compiler-authoritative HIR, validate it there, and continue to reject every
unproven system call.

## 2026-08-14 — Task 5.8 incremental RED/GREEN: ABI-validated external-call planning

The first descriptor-aware CallClosure slice is now implemented. It does not
emit or publish a native call yet; it establishes the immutable decision that a
later emitter must consume.

One pointer-free `FAngelscriptStaticJITNativeCallTarget` carries the
generation-Engine function ID, canonical declaration, compiler/resolver-owned
expected scalar ABI identity, and copied external-call descriptor. Closure
options also carry the frozen known-module and legal generated-consumer
dependency sets. The closure planner matches the HIR
`SystemFunction + resolvedFunctionId` coordinate exactly, invokes the common
descriptor validator, and copies both the descriptor and typed validation
result into the per-call plan.

Validated direct routes have separate dispositions:

- `ExportedSymbol` -> `DirectExported`;
- `HeaderInline` -> `DirectInline`;
- `ExportedRuntimeThunk` -> `RuntimeThunk`.

`ProviderPrivate` can become `Bridge` only when the descriptor proves a scalar
bridge route and the closure options separately prove that the native scalar
bridge implementation is available. That implementation is not open yet, so
the production default remains false. Missing targets, invalid descriptors,
ABI mismatches, illegal dependencies, and unavailable routes remain
source-located `UnsupportedCall` decisions. The plan dump contains the exact
target ID, disposition, symbol, and validation code; it never reconstructs a
symbol from the AngelScript declaration.

The API RED failed only on the newly required target/options/disposition/plan
fields:

```text
Build: typed-ast-jit-external-call-plan-api-red expected FAIL
Errors: missing FAngelscriptStaticJITNativeCallTarget,
        DirectExported/DirectInline/RuntimeThunk dispositions,
        NativeCallTargets/module context, and copied validation output
Evidence: Saved/Build/typed-ast-jit-external-call-plan-api-red/
          20260814_211227_510_fc8c5e91/Build.log
```

The GREEN matrix covers all three direct dispositions and an intentionally
mismatched `cdecl:i64(i32)` descriptor against the expected
`cdecl:i32(i32)` ABI. The mismatch is rejected at the original HIR call span
(row 92, column 14), not at a later emitter or linker stage.

```text
Build: typed-ast-jit-external-call-plan-green PASS (89/89)
Duration: about 87 s
Evidence: Saved/Build/typed-ast-jit-external-call-plan-green/
          20260814_211359_973_90cd6d1d/Build.log

Focused: ValidatedExternalDescriptorsSelectExactDirectDisposition
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-external-call-plan-focused-green/
          20260814_211533_470_eeeab8cd/Summary.json

Tests: Angelscript.TestModule.StaticJIT.Eligibility.TypedASTJIT.CallClosure
Result: 10/10 PASS
Evidence: Saved/Tests/typed-ast-jit-external-call-plan-final-green/
          20260814_211625_191_1bcd4997/Summary.json
```

Both final Editor processes exited within 238 ms of report completion.

The second consecutive change to the descriptor header again invalidated 89
actions. This confirms a structural compile-fan-out problem rather than a
one-time cold build. `FAngelscriptStaticJITNativeCallTarget` belongs to the
narrow generation/CallClosure input surface, not the fluent Binding descriptor
surface; it should be split into a separate `NativeCalls` header before more
target-plan fields are added. The public descriptor itself must remain stable
and small. This is a build-performance refactor, not a runtime semantic change,
and will be verified with an incremental action-count comparison.

Task 5.8 remains open: the generation snapshot still needs to capture real
Engine-attached targets and authoritative scalar ABI facts, generation settings
must supply the consumer module/dependency context, and the TypedAST emitter
must materialize operands once in HIR evaluation order before invoking the
validated C++ symbol in formal ABI order.

## 2026-08-14 — Registered-function ABI authority and compile-fan-out containment

The scalar ABI identity used by external-call validation is now derived from
the exact registered `asIScriptFunction`, not reconstructed from an AngelScript
declaration string and not inferred from a native address. The maintained-fork
`asSSystemFunctionInterface` supplies the authoritative internal calling
convention and hidden-argument facts. The first deliberately narrow ABI domain
supports primitive scalar CDECL/STDCALL/THISCALL functions, including the
implicit `this` pointer for THISCALL. References, object/handle values, type-info
parameters, hidden metadata, generic conventions, return-in-memory, and other
complex shapes still fail closed.

The focused test proves both a registered global function (`cdecl:i32(i32)`) and
a registered instance method (`thiscall:i32(ptr)`). This was a GREEN authority
and refactor slice following the descriptor-aware CallClosure RED/GREEN above;
there was no separate ABI-helper RED, so none is claimed here.

`FAngelscriptStaticJITNativeCallTarget` was also moved from the high-fan-out
Binding descriptor header into
`NativeCalls/AngelscriptStaticJITNativeCallTarget.h`. The public descriptor
header still required one final broad rebuild for the ABI-authority declaration,
but future snapshot/closure target-field changes no longer invalidate Binding
consumers merely because they include the descriptor contract.

```text
Build: typed-ast-jit-native-abi-authority-green PASS (89/89)
Duration: about 81 s
Evidence: Saved/Build/typed-ast-jit-native-abi-authority-green/
          20260814_211945_842_6b5a8a56/Build.log

Tests: Angelscript.TestModule.StaticJIT.NativeCallLinkage
Result: 4/4 PASS
Evidence: Saved/Tests/typed-ast-jit-native-abi-authority-tests/
          20260814_212114_470_95eb561e/Summary.json
```

The final Editor process exited within 195 ms after report completion. Task 5.8
remains open because the generation snapshot and TypedAST emitter still do not
consume this ABI identity.

## 2026-08-14 — Newly confirmed generation-capture admission gap

Targeted source inspection found that the isolated generation profile currently
sets generation purpose and HIR capture, but does not enable
`bCollectStaticJITCompatibilityBinds`. `FAngelscriptEngine` copies that flag from
its runtime config, while the native-form/compatibility collection hooks reject
registration when it is false. Consequently an Engine-local descriptor can be
correctly attached during Binding yet remain absent from the state needed to
freeze a real system-function target into the generation snapshot.

This is the next TDD boundary. A focused profile/generation test must first prove
the missing flag and the absent reviewed UE target, then the generation profile
will enable collection explicitly and the snapshot will copy only exact,
descriptor-backed, ABI-supported targets. This does not authorize cache loading
or persistence; the generation profile continues to keep runtime cache work
disabled.

The first method-name-level automation command did not discover a test under
the literal C++ `TEST_METHOD` spelling. It failed with `No automation tests
matched` and the Editor exited 195 ms later, so it is not counted as semantic
RED evidence. Validation temporarily uses the narrow registered class prefix
`Angelscript.TestModule.StaticJIT.Backend.Contract`; later focused commands must
use the runner-visible CQTest name rather than assuming the C++ identifier is
the exact automation leaf.

The valid admission RED compiled in four incremental actions and then ran the
narrow Backend contract group. Eight unrelated contract tests passed; the only
failure was the new assertion that the generation profile must collect exact
Engine-local native-call metadata. This isolates the missing configuration bit
from cache behavior and backend selection behavior.

```text
Build: typed-ast-jit-generation-bind-admission-red PASS (4/4 actions)
Evidence: Saved/Build/typed-ast-jit-generation-bind-admission-red/
          20260814_212830_554_ebbfa4f6/Build.log

Expected RED: Angelscript.TestModule.StaticJIT.Backend.Contract
Result: 8/9 PASS, 1 expected failure
Failure: BackendSelectionFreezesOneRequiredCaptureProfile
Detail: generation Engine did not collect exact Engine-local native-call metadata
Evidence: Saved/Tests/typed-ast-jit-generation-bind-admission-red-valid/
          20260814_213009_875_ad73444a/Report/index.json
```

The GREEN change is intentionally one configuration assignment in
`FAngelscriptStaticJITGenerationProfile::ApplyToEngineConfig`: both bytecode and
TypedAST generation Engines collect compatibility/native-call bind facts before
source compilation. It does not enable Cache V2 persistence or cache-record
graph consumption.

```text
Build: typed-ast-jit-generation-bind-admission-green PASS (4/4 actions)
Evidence: Saved/Build/typed-ast-jit-generation-bind-admission-green/
          20260814_213122_028_0a6066b2/Build.log

Focused: BackendSelectionFreezesOneRequiredCaptureProfile
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-generation-bind-admission-focused-green/
          20260814_213140_887_119c7a5c/Report/index.json
```

The exact runner-visible CQTest path includes the generated test class segment:
`...Backend.Contract.FAngelscriptStaticJITBackendTests.<method>`. The Editor
exited 243 ms after the focused result.

The next snapshot API RED compiles a real AngelScript call to the reviewed UE
header-inline function `IsRunningCommandlet()`. After explicitly including the
narrow target type to avoid cascading parser errors, the build failed only
because `FAngelscriptStaticJITGenerationSnapshot` did not yet expose
`NativeCallTargets`. The test also fixes the required frozen facts: exact
generation-Engine function ID, symbol `IsRunningCommandlet`, include
`CoreGlobals.h`, owning module `Core`, and expected ABI `cdecl:bool()`.

```text
Expected API RED: typed-ast-jit-reviewed-ue-native-target-api-red-valid
Failure: FAngelscriptStaticJITGenerationSnapshot has no NativeCallTargets member
Evidence: Saved/Build/typed-ast-jit-reviewed-ue-native-target-api-red-valid/
          20260814_213349_052_468ed05c/Build.log
```

An earlier noisy compile of the same RED omitted the target header and therefore
reported the missing type followed by secondary parse errors; it is retained as
diagnostic history but not used as the canonical RED. A transient UBA shared-CAS
exclusive-access notice did not stall the action or cause the semantic failure.

The GREEN implementation adds an immutable, pointer-free native-target array to
the generation snapshot and synchronous backend graph. Capture scans only
verified HIR `ResolvedCall + SystemFunction` expressions, resolves the exact
function ID in the same generation Engine, and copies a target only when that
exact registered function owns an explicit descriptor and its current registered
calling convention fits the reviewed primitive-scalar ABI domain. Missing or
unsupported targets remain absent and therefore continue to fail closed in
CallClosure; no symbol or linkage is inferred.

`Bind_CoreGlobals` now publishes the first real UE descriptor for
`IsRunningCommandlet()`: `HeaderInline`, `CoreGlobals.h`, owning module `Core`,
direct-call routing, and scalar/no-retention/no-Engine-capture lifetime facts.
The descriptor ABI is derived from the exact registered system function before
attachment. Ordinary runtime Engines that do not request StaticJIT compatibility
collection still skip attachment.

```text
Build: typed-ast-jit-reviewed-ue-native-target-green PASS (17/17 actions)
Duration: about 23 s
Evidence: Saved/Build/typed-ast-jit-reviewed-ue-native-target-green/
          20260814_213630_313_42ba195e/Build.log

Focused: ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-reviewed-ue-native-target-focused-green/
          20260814_213704_707_242d27c0/Report/index.json
```

The focused generation log also exposed one non-blocking fixture warning: the
composite module shape is outside Cache-clean's current single-source/simple-
graph fact-capture domain, so one module's cache function-fact batch was skipped.
The immutable generation snapshot still completed from the same authoritative
source compile and the external-call assertions passed. Measured snapshot-input
work was about 0.708 ms; the much larger isolated-Engine cost remained Binding,
about 1.649 s total, dominated by Blueprint reflection at about 1.327 s. This is
consistent with the earlier generation-Engine performance investigation and is
not a native-target capture regression. The Editor exited 322 ms after the
focused result.

Task 5.8 remains open: a real TypedAST backend request must still supply the
generated consumer's legal module dependencies, validate this frozen target in
CallClosure, and emit the C++ invocation rather than only freezing the route.

The next emitter API RED extends the same real generation fixture to make the
caller a global UFUNCTION root, build its exact CallClosure with `Core` as the
known/legal consumer dependency, require `DirectInline`, and pass that validated
decision to the pure Typed C++ emitter. The compile failed only because the
emitter did not yet define an exact native-call emission plan or accept such
plans in its options.

```text
Expected API RED: typed-ast-jit-real-ue-call-emitter-api-red
Failures: missing FAngelscriptTypedASTJITNativeCallEmissionPlan and
          FAngelscriptTypedASTJITEmitOptions::NativeCalls
Evidence: Saved/Build/typed-ast-jit-real-ue-call-emitter-api-red/
          20260814_214056_722_e937966b/Build.log
```

The GREEN emitter accepts only exact call-expression plans created after
CallClosure validation. Analyzer and emitter both recheck expression ID and
Engine-local target ID; a plain `ResolvedCall` without the plan remains
`UnsupportedCall`. The emitter adds the descriptor's public include and invokes
the copied symbol directly. For calls with operands it emits typed const
temporaries in the compiler's `evaluationSequence`, then invokes the C++ symbol
once in `formalParameterIndices` order, avoiding C++ argument-evaluation-order
ambiguity. The no-argument reviewed UE proof emits the direct expression
`IsRunningCommandlet()`.

```text
Build: typed-ast-jit-real-ue-call-emitter-green PASS (16/16 actions)
Duration: about 21 s
Evidence: Saved/Build/typed-ast-jit-real-ue-call-emitter-green/
          20260814_214252_855_46af3af2/Build.log

Focused: ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot
Result: 1/1 PASS
Proof: real snapshot -> DirectInline CallClosure -> CoreGlobals.h +
       return IsRunningCommandlet();, with no FAngelscriptJITExecutionContext
Evidence: Saved/Tests/typed-ast-jit-real-ue-call-emitter-focused-green/
          20260814_214319_920_db8988bf/Report/index.json

Regression: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Result: 7/7 PASS
Evidence: Saved/Tests/typed-ast-jit-real-ue-call-emitter-regression/
          20260814_214424_653_d020c525/Report/index.json
```

The focused Editor exited 174 ms after completion; the regression Editor exited
223 ms after completion. Task 5.8 is materially advanced but remains unchecked:
the pure emitter path is real, while backend-neutral Provider entry/wrapper
publication is still intentionally disabled until the shared entry plan and
execution-frame/exception contract are consumed.

## 2026-08-14 — direct native-call argument ordering regression

A focused GeneratedOutput regression now covers the nonzero-argument branch of
the direct native-call emitter. The synthetic verified HIR binds three formal
arguments in `A, B, C` order while preserving the compiler-provided evaluation
sequence `C, B, A`. Without an exact native-call emission plan the same
`ResolvedCall` fails as `UnsupportedCall` and returns no declaration,
definition, or includes. With the exact expression/function-ID plan it emits
typed temporaries in `arg2`, `arg1`, `arg0` order and then calls
`ObserveSystemCallTarget(arg0, arg1, arg2)`. This avoids relying on C++ argument
evaluation order and still does not introduce `FAngelscriptJITExecutionContext`.

This was a coverage extension after the production emitter implementation, not
a separate implementation RED. Its fail-closed half nevertheless guards the
missing-plan boundary explicitly.

```text
Build: typed-ast-jit-native-call-order-green PASS (4/4 actions)
Duration: about 12 s
Evidence: Saved/Build/typed-ast-jit-native-call-order-green/
          20260814_214825_843_1b7bf9bf/Build.log

Focused: NativeCallArgumentsPreserveEvaluationAndFormalOrder
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-native-call-order-focused-green/
          20260814_214850_469_4a3b6826/Report/index.json
Editor shutdown: 215 ms after test completion
```

## 2026-08-14 — generated-consumer public dependency truth

The real UE header-inline proof initially supplied `Core` directly to the pure
CallClosure test. Audit of the production path found that the TypedAST backend
had no equivalent generated-consumer module facts: project generation created
ordinary provider settings, the backend built closure options with an empty
known/public module set, and the generated `AngelscriptJIT.Build.cs` declared
its `Core` and `AngelscriptRuntime` dependencies as private. Consequently the
same descriptor proven eligible in the pure test would fail the production
backend's direct-linkage validation.

The TDD slice requires both the project scaffold and the production backend to
consume one explicit dependency truth. Its API RED failed only because
`FAngelscriptJITProviderGenerationSettings` did not yet expose the frozen known
and public native-call module sets.

```text
Expected API RED: typed-ast-jit-consumer-dependencies-api-red
Failure: missing KnownNativeCallModules and
         PublicNativeCallDependencyModules on provider generation settings
Duration: about 13 s
Evidence: Saved/Build/typed-ast-jit-consumer-dependencies-api-red/
          20260814_215228_138_1170e085/Build.log
```

The GREEN implementation adds those two Engine-pointer-free sets to generation
settings. Project generation freezes `Core` and `AngelscriptRuntime`, matching
the generated module's `PublicDependencyModuleNames`; the TypedAST backend
copies both sets into every root CallClosure decision. The real isolated-Engine
test now verifies that the reviewed `IsRunningCommandlet()` target produces
`TypedASTJITCallClosurePassed` through the actual backend, in addition to its
existing direct C++ emitter proof. The scaffold test independently verifies the
generated Build.cs no longer hides these dependencies as private-only.

```text
Build: typed-ast-jit-consumer-dependencies-green PASS (20/20 actions)
Duration: about 29 s
Evidence: Saved/Build/typed-ast-jit-consumer-dependencies-green/
          20260814_215308_427_d688afb1/Build.log

Focused: reviewed UE production-backend closure + project scaffold
Result: 2/2 PASS
Evidence: Saved/Tests/typed-ast-jit-consumer-dependencies-focused-green/
          20260814_215357_590_bfd050b1/Report/index.json
Editor shutdown: 167 ms after test completion
```

The generation fixture again reported the previously recorded Cache-clean
simple-shape warning for one composite module; the source-owned immutable
snapshot, backend closure, and scaffold assertions all completed successfully.
This closes the dependency-fact transport needed by the first UE direct target,
but task 5.6 remains open for the broader audited binding matrix and task 5.8
remains open for provider entry/wrapper publication and execution.

## 2026-08-14 — provider publication boundary after direct-call GREEN

Inspection of the existing generated Provider ABI confirms that the pure Typed
C++ body and the engine-facing entry adapters are separate responsibilities.
The body can and should remain a normal typed function with no
`FAngelscriptJITExecutionContext` and no `FScriptExecution`. Publication still
requires thin ABI adapters: a raw entry accepted by the Provider table, a VM
entry that reads exact `parameterOffsets` from `l_fp` and writes `l_outValue`,
and, where the frozen entry plan requires it, a Parms entry matching Unreal's
aligned parameter/return layout. `FScriptExecution` belongs only at those
engine ABI boundaries.

The current shared generation entry plan freezes only `bHasVMEntry`,
`bHasRawEntry`, `bHasParmsEntry`, and `EntryPlanHash`. The detailed adapter
layout construction still lives inside BytecodeJIT's `GenerateNewFunction`
path. The Typed backend therefore must not publish by guessing offsets, by
reusing a generic execution-context dispatcher, or by silently dropping an
entry kind (which would change `EntryAbiHash`). The next TDD slice will extract
or construct a narrow backend-neutral scalar entry-wrapper plan from the exact
same-compilation `asCScriptFunction`, then have the Typed emitter consume that
plan around its pure body. Until those wrapper and exception/frame contracts are
verified, Provider publication remains intentionally disabled.

Milestone hygiene after the dependency and emitter slices:

```text
Plugin git diff --check: PASS
Parent git diff --check: PASS
openspec validate feature-as-typed-semantic-aot --strict: PASS
```

The only concurrently running `UnrealEditor-Cmd` found during the process audit
belonged to the separate `.worktrees/llvmjit` RuntimeJIT test invocation; no
process from this `V:/` typed-semantic worktree was retained or terminated.

## 2026-08-14 — real Typed Provider emission semantic RED

The reviewed `IsRunningCommandlet()` generation fixture now requires the
production Typed backend to advance beyond a successful closure diagnostic. The
exact root must return `Emitted`, preserve the frozen VM/raw/Parms entry set and
`EntryAbiHash`, carry a pure `{SYMBOL_PREFIX}_TypedBody`, include the real UE
call and `CoreGlobals.h`, and contain the required Provider entry comment
placeholders without naming `FAngelscriptJITExecutionContext`.

The test-only build passed, then the focused runtime test failed exclusively at
the expected boundary: the eligible root still had the current `Unsupported`
disposition. Later emission assertions were therefore not evaluated, and the
known Cache-clean simple-shape warning remained non-causal.

```text
RED build: typed-ast-jit-provider-emission-semantic-red-build
Result: PASS (4/4 actions), about 15 s
Evidence: Saved/Build/typed-ast-jit-provider-emission-semantic-red-build/
          20260814_215946_308_f707f58f/Build.log

Expected semantic RED: ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot
Result: 0/1 PASS; only "eligible typed root must become a real Provider function"
Evidence: Saved/Tests/typed-ast-jit-provider-emission-semantic-red/
          20260814_220008_226_15c3a30d/Report/index.json
Editor shutdown: 220 ms after test completion
```

## 2026-08-14 — progressive OpenSpec attachment policy

Per the implementation instruction, this attachment is the chronological
engineering record for the remainder of the change. Each confirmed problem,
relevant source/document reference, causal explanation, design decision,
RED/GREEN verification result, log/report path, and intentionally deferred
boundary is appended here when it becomes known. `tasks.md` remains a concise
milestone checklist rather than accumulating investigation commentary.

The active checkpoint is the Typed Provider publication slice: the reviewed
UE header-inline target is already present in the immutable generation snapshot
and passes production CallClosure, while the backend still deliberately returns
`Unsupported` because the exact scalar Provider raw/VM/Parms adapter plan has
not yet been emitted. The implementation must preserve the frozen entry set and
`EntryAbiHash`, keep the pure Typed body free of
`FAngelscriptJITExecutionContext`, and fail closed rather than guess stack or
Parms offsets.

## 2026-08-14 — Provider adapter first GREEN build diagnostics

The first official incremental GREEN build completed (it did not hang) and
reported two concrete compile-time integration issues. First, this maintained
AngelScript fork exposes `asCScriptFunction::GetLineNumber` as a non-const API,
while source-metadata resolution intentionally holds a const synchronous view;
the read-only fallback therefore needs a narrow const adaptation. Second,
adding the Provider emitter translation unit changed Unreal Unity grouping and
exposed three StaticJIT public headers that used `AS_CAN_GENERATE_JIT` without
including the header that defines it. Those headers were accidentally dependent
on unrelated include order. The fix is to make the descriptor, target, and
capture-profile headers self-contained, not to alter the macro value or backend
behavior.

```text
Build: typed-ast-jit-provider-emission-green-build
Result: expected integration failure after about 13 s
Primary errors:
  - const asCScriptFunction cannot call non-const GetLineNumber
  - AS_CAN_GENERATE_JIT undefined after Unity repartition
Evidence: Saved/Build/typed-ast-jit-provider-emission-green-build/
          20260814_221049_258_90404767/UBT.log
```

The corrected build then passed all `90/90` XGE actions in about 94 seconds.
The unusually broad rebuild was caused by making widely included public headers
self-contained; the log kept advancing throughout and ended successfully.

```text
Build: typed-ast-jit-provider-emission-green-build-2
Result: PASS (90/90 actions)
Duration: about 94 s
Evidence: Saved/Build/typed-ast-jit-provider-emission-green-build-2/
          20260814_221218_776_541bf5fa/UBT.log
```

The first focused GREEN invocation used the class prefix plus the C++ method
name, but CQTest registers this test with an additional class-name path segment.
The Editor started and shut down normally, then reported zero matching tests;
this is an invocation-filter failure and provides no semantic pass/fail signal.
The prior RED report is the authority for the exact registered path:
`...Engine.FAngelscriptStaticJITGenerationEngineTests.ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot`.

```text
No-match invocation: typed-ast-jit-provider-emission-semantic-green
Result: 0 tests matched; not counted as validation
Evidence: Saved/Tests/typed-ast-jit-provider-emission-semantic-green/
          20260814_221425_589_1584825b/Automation.log
```

Using the exact registered CQTest path then exercised the intended test. The
production Typed backend returned `Emitted`, preserved the captured VM/raw/Parms
entry set and `EntryAbiHash`, emitted a pure `{SYMBOL_PREFIX}_TypedBody` calling
`IsRunningCommandlet()`, produced entry adapters without
`FAngelscriptJITExecutionContext`, and published `CoreGlobals.h` in the module
preamble. The pre-existing Cache-clean simple-shape warning was still present
and remained non-causal.

```text
Focused: ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot
Result: 1/1 PASS
Body duration: about 1.7 s
Evidence: Saved/Tests/typed-ast-jit-provider-emission-semantic-green-exact/
          20260814_221542_231_4c38e3c4/Report/index.json
Editor automation exit: code 0
```

## 2026-08-14 — zero-parameter Typed body syntax RED

Review of the newly publishable Provider text found a neighboring emitter
boundary not exercised by the one-parameter UE proof. The shared pure-body
signature builder appended its closing parenthesis only while iterating
parameters. A valid zero-parameter root therefore returned `bSuccess=true` but
left the definition at `FunctionName(`, which would fail only when the generated
module was later compiled. A focused golden test now requires both `Name();` and
`Name() { ... }` forms.

```text
Build: typed-ast-jit-zero-parameter-red-build PASS (4/4 actions)
Evidence: Saved/Build/typed-ast-jit-zero-parameter-red-build/
          20260814_221830_975_be46f72f/Build.log

Expected RED: ZeroParameterBodyClosesTheTypedCppSignature
Result: 0/1 PASS; emitted declaration stopped at FunctionName(
Evidence: Saved/Tests/typed-ast-jit-zero-parameter-semantic-red/
          20260814_221851_276_93bbb363/Report/index.json
```

After the signature fix, the first GREEN re-run reached a second assertion
difference: the produced definition correctly used the emitter's existing
typed-literal normalization `int32(7)`, while the new test had expected an
untyped `7`. This was a test-oracle mistake, not another production defect; the
golden was corrected to the established deterministic literal form. The
intermediate report is retained at
`Saved/Tests/typed-ast-jit-zero-parameter-semantic-green/20260814_222032_594_20c955a5/Report/index.json`.

The corrected typed-literal golden then passed. Zero-parameter pure bodies now
close both declaration and definition signatures deterministically, with no
change to the existing nonzero-parameter output.

```text
Build: typed-ast-jit-zero-parameter-green-build-2 PASS (4/4 actions)
Evidence: Saved/Build/typed-ast-jit-zero-parameter-green-build-2/
          20260814_222154_413_4301ad35/Build.log

Focused: ZeroParameterBodyClosesTheTypedCppSignature
Result: 1/1 PASS
Evidence: Saved/Tests/typed-ast-jit-zero-parameter-semantic-green-2/
          20260814_222212_095_bf9398fa/Report/index.json
```

The next adjacent verification extends the real UE header-inline fixture from
raw backend output through `FAngelscriptStaticJITGenerator` packaging. It uses
an explicit one-module emit set and requires the final module source to contain
resolved content-addressed raw/VM/Parms symbols, `CoreGlobals.h`, and the direct
UE call, with no unresolved template placeholder or generic execution context.

## 2026-08-14 — final Provider package text GREEN

The real UE header-inline fixture now exercises the complete text-production
path from the Typed backend through `FAngelscriptStaticJITGenerator`, rather
than inspecting backend fragments in isolation. The request selects the exact
captured module, the generator packages the result, and the focused assertion
reads the final generated module source. It confirms that dependency metadata,
the direct UE call, frozen entry ABI, and content-addressed entry symbols all
survive packaging without falling back to the generic execution context.

```text
Build: typed-ast-jit-provider-packaging-build
Result: PASS (4/4 actions)
Evidence: Saved/Build/typed-ast-jit-provider-packaging-build/
          20260814_222406_515_09901ad4/Build.log

Focused: ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot
Result: 1/1 PASS
Body duration: about 1.8 s
Evidence: Saved/Tests/typed-ast-jit-provider-packaging-semantic/
          20260814_222429_561_e9cbe335/Report/index.json
Editor automation exit: code 0
```

The packaged source contains `#include "CoreGlobals.h"`, the pure Typed body
call `return IsRunningCommandlet();`, and the resolved raw and VM symbols plus
the Parms symbol required by the frozen function entry set. It contains neither
`{SYMBOL_PREFIX}` / `{RAW_SYMBOL}` placeholders nor
`FAngelscriptJITExecutionContext`. The existing generation-only Cache capture
warning remains visible in the report but is unrelated to this test's selected
fixture and did not affect the result.

This is intentionally not counted as compile/link/runtime completion. It proves
the final generated C++ text and metadata package; the next verification must
materialize that output in the AngelscriptTestJIT carrier, compile and link it,
then invoke the VM, raw, and Parms entries through their real ABI paths.

## 2026-08-14 — generated Provider carrier verification boundary

The existing `TypedASTJITScalarProbe.generated.cpp` is deliberately a pure-body
probe and cannot establish that the Provider ABI adapters compile or execute.
The next TDD seam therefore keeps that artifact intact and adds a separate
generated Provider-entry probe under the non-Unity `AngelscriptTestJIT` module.
Its test contract calls the same scalar body through raw, VM-frame, and reflected
Parms-buffer entry shapes and requires identical results. Normal Provider-table
publication and UASFunction routing remain later task 6.2 work; this seam proves
the narrower generated translation-unit, DLL link, and entry ABI behavior first.

The first attempt to start the official RED build from the worktree's physical
`D:\Workspace\...\.worktree\feature-as-typed-semantic-aot` path was rejected
before UBT because this worktree's copied `AgentConfig.ini` intentionally names
`V:\AngelscriptProject.uproject`. The shared runner validates that the configured
project belongs to its invocation root and does not canonicalize the substituted
drive mapping. No build or semantic result was produced. Validation for this
worktree must continue from the equivalent `V:\` root; the Engine/project
configuration does not need to be regenerated or changed.

The compile/link contract then produced the intended linker RED: the test module
could import the four new probe functions, while `AngelscriptTestJIT.dll` did
not yet export their implementations. The failure was limited to four named
`LNK2019` symbols and did not involve the existing generated provider.

```text
Expected RED build: typed-ast-jit-provider-entry-link-red
Result: link failure (LNK2019 x4; Has/Raw/VM/Parms probe exports absent)
Evidence: Saved/Build/typed-ast-jit-provider-entry-link-red/
          20260814_222913_004_48a945c0/UBT.log
```

After adding the thin address carrier and teaching the maintained AOT fixture
generator to build its test carrier through
`EmitAngelscriptTypedASTJITProviderFunction`, the generator/bridge build passed.
At this intermediate point the new generated translation unit intentionally did
not exist yet, so the exact focused test reached the semantic RED and reported
that the three entry addresses were not registered. This proves the test cannot
accidentally pass through the pre-existing BytecodeJIT provider or pure-body
probe.

```text
Build: typed-ast-jit-provider-entry-generator-build
Result: PASS (10/10 actions)
Evidence: Saved/Build/typed-ast-jit-provider-entry-generator-build/
          20260814_223220_180_2967c4e4/Build.log

Expected semantic RED: TypedASTGeneratedProviderEntriesCompileLinkAndExecute
Result: 0/1 PASS; generated raw/VM/Parms entries are not registered
Evidence: Saved/Tests/typed-ast-jit-provider-entry-semantic-red/
          20260814_223242_486_901e6360/Report/index.json
```

The test runner wrapper reached its local 60-second tool-call yield while the
fixture was still compiling, but the Editor process continued normally, logged
provider routing, produced the expected report at about 78 seconds, and began
clean shutdown. This is a caller observation timeout, not an Editor hang or a
test timeout.

The commandlet runner's `ExtraArgs` is a PowerShell array. Passing
`-NoHotReloadFromIDE` as a second ordinary token made PowerShell interpret it as
an unknown runner parameter, so that invocation stopped before launching UE.
The corrected official invocation supplied
`@('-Mode=Generate','-NoHotReloadFromIDE')`; the generated Editor command line
then contained both arguments exactly.

The corrected Generate commandlet completed successfully in about 41 seconds.
It added `TypedASTJITProviderProbe.generated.cpp`, refreshed the owned-file
inventory, and kept `Provider.generated.cpp`, `Provider.generated.h`, and the
import-provider module byte-identical to the generator's current expectation.
The primary fixture/manifest and the older scalar probe were refreshed because
their already-evolved Typed scalar helper output is now part of the current
expected artifact. The generated Provider-entry probe includes the declaration,
source, frozen Entry ABI hash, and separate raw/VM/Parms comments, and contains
the exact adapter implementation returned by the Runtime Provider emitter.

```text
Commandlet: AngelscriptTestJIT -Mode=Generate -NoHotReloadFromIDE
Result: PASS
Evidence: Saved/Commandlet/typed-ast-jit-provider-entry-generate/
          20260814_223448_470_581cadc9/Commandlet.log
New owned file: TypedASTJITProviderProbe.generated.cpp
```

## 2026-08-14 — generated translation-unit compile/link diagnostics

The first build after Generate failed exactly where source-text-only tests could
not: both Typed probe files now use the emitter's wrapping integer helpers, but
the older test-carrier template hard-coded only `CoreMinimal.h` (and the new
Provider carrier initially hard-coded only `StaticJITHeader.h`). Consequently
the generated translation units could not resolve the
`AngelscriptTypedASTJIT` namespace. The emitter had already returned the correct
`RequiredIncludes`; the fixture packager was discarding them. The fix renders a
sorted, deduplicated include set from the emission result for both probe files,
while adding the carrier-specific probe/StaticJIT headers explicitly.

```text
Expected generated-source RED: typed-ast-jit-provider-entry-generated-red
Result: compile failure in both Typed probes; scalar helper namespace absent
Evidence: Saved/Build/typed-ast-jit-provider-entry-generated-red/
          20260814_223624_495_d472e6cb/UBT.log
```

After the include correction, both Typed translation units compiled. The link
then advanced to a separate existing primary-fixture call:
`UObject::FindFunctionChecked`/`ProcessEvent`. The refreshed generated module
names the CoreUObject export directly, while the TestJIT consumer declared only
`Core` and `AngelscriptRuntime`; UE module DLL linkage does not treat the latter
as a substitute for the generated consumer's own dependency. The narrow fix is
to add `CoreUObject` to `AngelscriptTestJIT`'s public dependency list. This also
aligns the test carrier with the generated call's real owner rather than relying
on transitive link behavior.

```text
Intermediate build: typed-ast-jit-provider-entry-generated-green-build
Result: Typed probes compile; TestJIT DLL link fails only on
        UObject::FindFunctionChecked
Evidence: Saved/Build/typed-ast-jit-provider-entry-generated-green-build/
          20260814_223749_511_162bb474/UBT.log
```

With the generated consumer's explicit CoreUObject dependency, the final
incremental build compiled both Typed probes, rebuilt the non-Unity TestJIT
module, and linked `UnrealEditor-AngelscriptTestJIT.dll` successfully. The
focused runtime case then executed four scalar rows through each of the raw,
VM-frame, and reflected Parms-buffer entry points. Positive, negative, and
branch-boundary inputs all produced the same expected values. Because the
entry-address carrier remains empty until its generated translation unit's
static registration runs, the prior semantic RED proves this GREEN cannot be
coming from the old BytecodeJIT provider or pure-body function pointer.

```text
Build: typed-ast-jit-provider-entry-final-build
Result: PASS (11/11 actions; TestJIT DLL linked)
Evidence: Saved/Build/typed-ast-jit-provider-entry-final-build/
          20260814_223856_249_810d74a6/Build.log

Focused: TypedASTGeneratedProviderEntriesCompileLinkAndExecute
Result: 1/1 PASS
Rows: 4 through each of raw, VM, and Parms entries
Evidence: Saved/Tests/typed-ast-jit-provider-entry-final-green/
          20260814_223916_192_362c06c4/Report/index.json
Editor automation exit: code 0
```

The test's fixture initialization took about 37.5 seconds and the outer tool
call yielded at 60 seconds before the report was exported. Continued log
monitoring showed normal provider routing, Success, report export, and exit code
0. This repeats the known runner-observation boundary and is not a hang.

The next Generate pass used the newly built include-rendering generator and
reported every one of the eight owned files as `unchanged`, including both
Typed probes, the two module sources, Provider source/header/manifest, and the
inventory. Provider ID and Provider generation also remained identical. This
is the byte-level determinism proof for the generated carrier.

```text
Determinism Generate: AngelscriptTestJIT -Mode=Generate
Result: PASS; 8/8 owned files unchanged
Evidence: Saved/Commandlet/typed-ast-jit-provider-entry-regenerate/
          20260814_224059_250_8b943152/Commandlet.log
```

The immediately following Verify commandlet did not reach its commandlet main
or compare generated output. During the ordinary primary Engine startup it
stopped directly after the project script stage-1/stage-2 timing line and the
runner observed process exit code `-1`. There was no compile diagnostic,
assertion, fatal message, stale-output report, timeout, or crash artifact in the
captured log; Generate and the focused Automation process had both completed
the same startup path successfully just before it. This attempt is recorded as
an abnormal host-process exit and is not counted as either a Verify pass or a
generated-output failure. A clean retry is required after checking concurrent
UE process state.

```text
Abnormal Verify attempt: typed-ast-jit-provider-entry-verify
Result: NOT COUNTED; process -1 before commandlet main
Last log stage: project script compilation stage1/stage2
Evidence: Saved/Commandlet/typed-ast-jit-provider-entry-verify/
          20260814_224151_226_36937f35/Commandlet.log
Metadata: same directory/RunMetadata.json
```

The post-change hygiene checks were clean. Both the parent repository and the
Angelscript submodule returned exit code 0 from `git diff --check`; their only
output was the workspace's existing LF-to-CRLF conversion warning. Strict
OpenSpec validation also accepted the current change record. These checks do
not replace the pending clean Verify retry, but they rule out malformed patch
text and an invalid OpenSpec artifact graph as causes of the abnormal host
exit.

```text
Parent: git diff --check -> exit 0
Plugin: git diff --check -> exit 0
OpenSpec: openspec validate feature-as-typed-semantic-aot --strict -> valid
```

At the retry checkpoint, another worktree still owned an active
`UnrealEditor-Cmd.exe` automation process. It was not started by this worktree
and will not be terminated or reused. The clean Verify retry is deliberately
deferred until UE host contention clears; in the meantime only read-only
inspection and the exact affected-test selection are performed.

The single controlled retry completed cleanly even while that unrelated UE
automation process remained active. It entered the real
`AngelscriptTestJITCommandlet`, completed generated-output verification, and
returned result 0 with zero errors. Therefore the earlier process `-1` is an
unreproduced UE host exit, not evidence of stale output, cache corruption, or a
Typed Provider mismatch. No production workaround is justified by that one
non-reproducing host failure.

```text
Verify retry: AngelscriptTestJIT -Mode=Verify -NoHotReloadFromIDE
Label: typed-ast-jit-provider-entry-verify-retry
Result: PASS; commandlet result 0; 0 errors
Evidence: Saved/Commandlet/typed-ast-jit-provider-entry-verify-retry/
          20260814_224555_349_5433c3e5/Commandlet.log
```

The exact affected ownership prefix was then selected because this slice adds
one generated translation unit, changes the owned-file count, and adds the
generated consumer's direct `CoreUObject` dependency. That Automation host did
not reach test discovery: immediately after primary script startup it exited
with process code `-1`, produced no report index, and logged no assertion,
fatal error, or test event. This attempt is not counted as a test failure.

```text
Affected prefix: Angelscript.TestModule.StaticJIT.TestModuleOwnership
Label: typed-ast-jit-provider-entry-ownership
Result: NOT COUNTED; host process -1 before test discovery
Evidence: Saved/Tests/typed-ast-jit-provider-entry-ownership/
          20260814_224658_204_b8d41dc3/Automation.log
Metadata: same directory/RunMetadata.json
Report: not created
```

Systematic inspection found approximately 54 GiB of memory still available,
no local crash directory/minidump, and no UE `Fatal`/assertion. The Crash Report
monitor recorded this process dying at the same second as an unrelated
worktree's long-running UE Automation host. That other host was blocked behind
its own startup-compile modal and was externally terminated; it subsequently
restarted under a new run label. The shared timing is evidence of host/process
control interference, not of a deterministic failure in the ownership tests.
The exact prefix will be retried only when no unrelated UE host is active, with
`-NoHotReloadFromIDE`; no source workaround or broad test rerun is warranted
without a reproduction in isolation.

Once the machine had no other `UnrealEditor` or `UnrealEditor-Cmd` process, the
same exact ownership prefix was run once with `-NoHotReloadFromIDE`. It passed
all eight tests and shut down normally. This closes the generated-file count,
one-cpp-per-AS-module, stable-reference-slot, committed-path ownership,
consumer-module dependency, and legacy-cache-absence checks for the current
Typed Provider carrier. It also confirms the earlier simultaneous `-1` exits
were shared-host interference rather than a deterministic source failure.

```text
Focused: Angelscript.TestModule.StaticJIT.TestModuleOwnership
Label: typed-ast-jit-provider-entry-ownership-isolated
Extra: -NoHotReloadFromIDE
Result: 8/8 PASS; failed=0; skipped=0; process 0
Evidence: Saved/Tests/typed-ast-jit-provider-entry-ownership-isolated/
          20260814_225020_050_6936b23c/Report/index.json
Log: same directory/Automation.log
```

## Combined Typed scalar capability fixture

To turn the user-facing capability example into executable evidence rather
than documentation-only sample code, the AOT fixture now declares
`TypedASTCapabilityShowcase(int,int,bool,bool)`. One function combines local
scalar arithmetic, simple and compound assignment, prefix/postfix mutation,
unary negation/bitwise-not, left/right shifts, boolean short circuit, nested
`if`/return, and the reviewed `IsRunningCommandlet()` HeaderInline UE target.
The test contract requires generated raw, VM, and Parms entries to execute four
rows that distinguish a skipped short-circuit mutation from an evaluated one.

The first build produced the intended link RED: the Test module referenced the
four new TestJIT carrier exports before their implementations existed. No
unrelated compile error occurred. After adding an address-only atomic carrier,
the build passed, while the focused runtime test produced the intended semantic
RED because no generated translation unit had registered the new entries. The
real isolated fixture Engine compiled the new AS function successfully; only
the existing style warnings about increment/decrement inside complex
expressions were emitted.

```text
Link RED: typed-ast-capability-showcase-red
Result: expected four unresolved TestJIT capability carrier exports
Evidence: Saved/Build/typed-ast-capability-showcase-red/
          20260814_225544_912_3c2bf059/UBT.log

Carrier build: typed-ast-capability-showcase-carrier
Result: PASS (7/7 actions)
Evidence: Saved/Build/typed-ast-capability-showcase-carrier/
          20260814_225643_422_c1398d07/Build.log

Semantic RED: TypedASTCapabilityShowcaseEntriesCompileLinkAndExecute
Result: 0/1 as expected; exact missing generated-entry registration assertion
Evidence: Saved/Tests/typed-ast-capability-showcase-semantic-red/
          20260814_225716_366_b4205b17/Report/index.json
```

### Why integer arithmetic uses force-inlined helpers

`AngelscriptTypedASTJIT::WrapAdd`, `WrapSubtract`, `WrapMultiply`, and
`WrapNegate` are not runtime dispatch helpers and do not receive an execution
context. They are header-only `FORCEINLINE` templates that perform arithmetic
in the matching unsigned bit domain, truncate to the exact AngelScript width,
and bit-cast back for signed results. This makes the source-level C++ semantics
explicitly equal to the maintained VM's fixed-width wrapping semantics.

For non-overflowing values, `WrapAdd<int32>(A,B)` has the same numeric result as
`A + B`, and an optimizing compiler normally lowers the inlined helper to the
same native add instruction. The distinction matters at boundaries:
`MAX_int32 + 1` is signed-overflow undefined behavior in portable C++, while
AngelScript requires the `MIN_int32` bit result. Small integer promotions and
signed right shifts introduce similar portability gaps. Emitting plain signed
operators globally would therefore allow C++ optimization to change script
behavior even if today's MSVC happens to produce the expected instruction.

Plain `A + B` may be used only by a future lowering optimization that proves
the operation cannot overflow or otherwise proves an exact portable C++
equivalence. The baseline emitter keeps the small named helper because it is
testable, context-free, force-inlineable, and avoids repeating a much noisier
unsigned-cast/width-truncation/bit-cast expression in every generated body.

## `Print` as the first non-scalar C++ Bind closure

The user selected global AngelScript `Print` as the key proof that TypedASTJIT
can consume a real C++ binding rather than only lower arithmetic or a header
inline scalar query. Source inspection found the authoritative binding in
`Binds/Bind_Logging.cpp`:

```angelscript
void Print(
    const FString& Text,
    float32 Duration = 5.f,
    FLinearColor Color = FLinearColor::LucBlue)
```

It binds `FAngelscriptLoggingBinds::Print`, applies `CompileOutIfNoLog()`, and
sets the `asTRAIT_USES_WORLDCONTEXT` trait through `.WorldContext()`. The native
implementation calls `UKismetSystemLibrary::PrintString` with
`FAngelscriptEngine::TryGetCurrentWorldContextObject()`.

This is intentionally not treated as if it were equivalent to the already
working `IsRunningCommandlet()` HeaderInline scalar case:

- `FAngelscriptLoggingBinds` and its `Print` member have no exported Runtime
  declaration, so a generated consumer DLL may not name that private bind
  implementation directly;
- `FString` and `FLinearColor` require object/value construction, reference
  binding, default-argument materialization, and exact cleanup lifetime, while
  the current Provider entry/body slice is scalar-only;
- a direct call must retain `CompileOutIfNoLog` target-profile behavior and the
  WorldContext availability contract that the normal VM/native call path
  observes. Merely spelling the C++ member call would bypass reviewed semantic
  policy.

The intended final C++ shape is the actual Runtime-owned callable moved to a
narrow public exported surface and shared by both Bind registration and AOT,
conceptually:

```cpp
AngelscriptStaticJITNativeCallables::Print(Text, Duration, Color);
```

The callable must be declared in a public Runtime header with
`ANGELSCRIPTRUNTIME_API`; the existing Bind should register this same function
and attach an external-call descriptor naming that header, symbol, owner
module, exact ABI, target-profile/compile-out behavior, WorldContext
requirements, and non-retention/cleanup contract. The generated consumer must
include the declaration rather than redeclare it or export the whole private
`FAngelscriptLoggingBinds` struct. A thin exported forwarding callable remains
permitted only when moving the actual implementation would violate ownership or
dependency boundaries.

Executable AOT coverage for `Print` therefore becomes the first non-scalar
binding closure after the current scalar/HeaderInline capability fixture is
green. Its RED must cover at least string literal/parameter materialization,
explicit and default Duration/Color, exactly-once thunk execution, no
`FAngelscriptJITExecutionContext`, correct Development versus Shipping/Test
compile-out behavior, missing WorldContext behavior, and destructor/cleanup on
the success and failure paths. Until those object-lifetime pieces exist,
`Print` must fail closed to BytecodeJIT/VM rather than be mislabeled as a safe
direct call.

### Two native Bind routes: imported DLL symbol or current binding slot

The user clarified that the complete Bind surface needs two distinct lowering
routes rather than forcing every target through one export policy.

1. If the owning module exposes an importable DLL symbol, generated C++ includes
   its public declaration and performs an ordinary direct C++ call. Runtime-
   owned functions preferably register that same exported implementation with
   AngelScript, so VM and AOT share one callable and there is no forwarding or
   generic-dispatch hop.
2. If the callable is provider-private/unexported, generated C++ calls one
   stable exported Runtime bridge. The artifact carries a stable function
   identity/reference slot plus expected ABI, never a process address or an
   Engine-local integer function ID. Engine/provider initialization resolves
   that identity into the current binding database. The bridge loads and
   validates the current slot before invoking the registered pointer/caller;
   module unload, rebind, Engine replacement, and Live Coding invalidate or
   replace the slot rather than leaving a stale address in generated code.

The unexported route is not one universal unchecked function-pointer cast.
Binding registrations cover CDECL functions, methods, generic callers,
implicit receivers, default and hidden arguments, WorldContext traits,
`PassScriptFunctionAsFirstParam`, reflection routes, and value/reference
lifetimes. Bridge eligibility must consume the registered AS system-function
interface/caller metadata or a generated typed stub for a proven ABI shape.
Unsupported shapes remain explicit bridge/typed fallback rows in the complete
inventory.

`Print` is an owned Runtime implementation and therefore exercises the direct
DLL route after its object/default/lifetime lowering is available. A separate
provider-private by-value scalar fixture exercises the current-binding-slot
route first, including exact identity/ABI validation, rebind/unbind behavior,
and no stale call after module or Engine teardown.

The agreed generated bridge spelling is intentionally readable:

```cpp
// AS Bind       : int PrivateAdd(int, int)
// Native Target : FProviderPrivateBinds::PrivateAdd (registered, unexported)
// Route         : CurrentBindingSlot
// Stable Key    : <stable-function-key>; Expected ABI: <abi-hash>; Slot: 7
return AngelscriptTypedASTJIT::InvokeBound<int32, int32, int32>(
    Execution,
    7,
    Left,
    Right);
```

The canonical declaration and registered native display name are emitted as
comments and stored in the manifest/diagnostics, while templates describe the
compile-time return/argument shape. The literal C++ function called by this
generated source is `AngelscriptTypedASTJIT::InvokeBound`; the private target
name is provenance showing which current Bind the slot is expected to select,
not a claim that the generated DLL links that symbol. Runtime does not perform a
name lookup on every call. The generation snapshot/provider entry stores stable
function key + expected ABI; adoption resolves it to a reference slot, and
`InvokeBound` asks the current `FScriptExecution` for that slot's
`asCScriptFunction`. It then executes the same registered caller/function
pointer that the VM would use. This preserves overloads and supports rebinding
without embedding addresses or ephemeral FunctionIds in generated source.

## Native-call inventory: final Engine surface baseline

The first task 5.3 evidence pass deliberately used the existing final-surface
exporter rather than counting `BindGlobalFunction` source lines. The following
command ran from `V:\` so it used only the isolated worktree and the same
`C:\Program Files\Epic Games\UE_5.8` configured by the main checkout:

```powershell
$bundleArgs = @(
    '-BundleKind=Project',
    '-Output=V:\Saved\TypedSemanticAOT\NativeCallInventory\20260814_232214\EngineSurface',
    '-AssetRoots=/Game')
& V:\Tools\RunCommandlet.ps1 `
    -Commandlet AngelscriptOfflineExport `
    -Label typed-aot-native-call-inventory-20260814_232214 `
    -TimeoutMs 600000 `
    -ExtraArgs $bundleArgs
```

The commandlet completed in 10.30 seconds with zero errors and four unrelated
existing warnings. It exported `129847` symbols and `2` assets with bundle
identity
`fc3a8bfb4dd8ea755ad3e965bb7cbc76fd585835a6b2b8892cc34acde3e241c0`.
The ignored raw bundle remains beneath this worktree's `Saved/` directory.

`research/Build-NativeCallEngineSurfaceBaseline.ps1` verifies the exported
`symbols.jsonl` SHA-256 against the manifest, streams the final records, and
writes the checked research attachments:

- `research/native-call-engine-surface-baseline.csv`;
- `research/native-call-engine-surface-summary.json`.

The current final surface contains `77524` callable records:

| Callable kind | Count |
|---|---:|
| behavior | 9 |
| constructor | 12023 |
| destructor | 5844 |
| global-function | 39182 |
| method | 20466 |

The current origin breakdown is `manual=1910`, `reflective=4197`, `script=38`,
and `unknown=71379`. The manual slice is `531` global functions plus `1379`
methods. A repeated script run produced byte-identical CSV and summary hashes:

```text
CSV_SHA256     = 5DDDE6BEC23E0B878E9BF0C28D44BAA6FEE50B6CE1584994F00BED44C081320A
SUMMARY_SHA256 = 3B109EF34AD4E84FCDEB375F5D7C4D0C728D79DD507A57ECE0AD82E9FAA75725
```

This is intentionally labelled a **partial baseline**, not the completed Bind
inventory. Two facts prevent a false completion claim:

1. the commandlet consumes the last built plugin DLL while the current dirty
   source still awaits the official Live-Coding-blocked UBT build, so this
   snapshot is evidence about the currently executable binary, not yet the
   final source revision;
2. `Print` and `IsRunningCommandlet` are present in the final surface but still
   report `origin=unknown`, and constructors/destructors/template-expanded
   behavior dominate the unknown slice. Existing
   `FAngelscriptRegisteredFunctionProvenance` records only origin/provider and
   does not preserve the active owner/source file/source line/native-form
   display required for a complete installed-callable-to-source join.

The task 5.3 closure therefore needs a tested registration provenance extension
plus a native-form/external-descriptor join after the build lock is released.
Only then may the complete inventory assign every installed Bind callable one
of `direct-export|inline|exported-callable|bridge|compile-out|unsupported`.

### Bind source call-site baseline

`research/Build-NativeCallSourceCallsites.ps1` provides the other side of that
future join. It scans the complete `AngelscriptRuntime` source root, masks C++
comments/string bodies without changing offsets, matches the supported binding
registration APIs, balances each call's parentheses, and records source
file/line, nearest provider declaration, declaration expression, literal AS
declaration where available, C++ target expression and fluent traits. Version 8
also parses explicit `.Native*()`
chains and the `METHOD*`/`FUNC*` macros whose preprocessor expansion selects a
native-form overload, retaining the effective native-form method and callable
display spelling. It intentionally reports call sites rather than pretending a
template/loop call site is one installed function.

The current source baseline is:

| Source measure | Count |
|---|---:|
| Runtime `.cpp` files scanned | 395 |
| `Bind_*.cpp` files | 204 |
| `.cpp` files containing registration calls | 128 |
| `FAngelscriptBind` provider declarations | 253 |
| distinct provider BindName + phase identities | 247 |
| call sites lexically/single-file attributed to a provider | 2643 |
| helper/multi-provider call sites awaiting Runtime join | 277 |
| registration call sites | 2920 |
| literal declaration call sites | 2867 |
| dynamic declaration call sites | 53 |
| explicit `.Native*` fluent tails | 147 |
| implicit `METHOD*`/`FUNC*` native-form macro sites | 1509 |
| effective native-form call sites | 1656 |
| compile-out fluent tails | 33 |

The generated attachments are
`research/native-call-source-providers.csv`,
`research/native-call-source-callsites.csv` and
`research/native-call-source-callsites-summary.json`. A repeated run was
byte-identical:

```text
CALLSITE_CSV_SHA256 = 091F3B6AFEDADBECCA3D3117B1966F1FA41AAC1827D5780BC7CA245257C02AE4
PROVIDER_CSV_SHA256 = A5B0363F65778F11A3EF3DBC6484A61E8836236B3F8248C85AB6A9F8346379C1
SUMMARY_SHA256      = 309AF35820E64EB00CF1700C5153A0BE664744C402630EAEB647BDD86C28FEB5
```

The provider table stores inline callbacks as the stable marker
`<inline-lambda>` rather than duplicating whole callback bodies. Named callbacks
retain their function-pointer spelling. This reduced the provider attachment
from roughly 535 KiB to 55 KiB while preserving the source identity required by
the Runtime join. Six duplicate source declarations collapse to 247 distinct
BindName + phase identities because mutually exclusive configuration branches
declare the same provider identity; the final Engine remains the authority for
which variant was installed.

The effective native-form split is 1095 `NativeMethod`, 424
`NativeFunction`, 59 template-instantiated calls, 52 constructors, and 26
other reviewed native-form methods. For example,
`METHOD_TRIVIAL(AActor, IsActorInitialized)` is now recorded as an implicit
`NativeMethod` with display name `IsActorInitialized`; it is no longer hidden
merely because the source has no fluent `.NativeMethod()` text.

The source table already makes the two first end-to-end targets auditable:

- `Bind_Logging.cpp:168` registers
  `void Print(const FString& Text, float32 Duration = 5.f, FLinearColor Color = FLinearColor::LucBlue)`
  against `&FAngelscriptLoggingBinds::Print`, followed by
  `.CompileOutIfNoLog().WorldContext()`;
- `Bind_CoreGlobals.cpp:67` registers `bool IsRunningCommandlet()` against
  `&IsRunningCommandlet`, followed by its native-form declaration. The reviewed
  external descriptor is attached indirectly by the nearby helper and is
  therefore expected to appear through the runtime descriptor join rather than
  a fluent-tail text guess.

The broader root adds 51 real registration call sites and four sealed providers
outside `Binds/Bind_*.cpp`: Core's direct-bind probe/default skip provider, the
Runtime test/test-suite providers, and the reflective Blueprint callable helper
path. Leaving those out would make the source table disagree with the final
Engine even after provenance capture was correct.

The source table now distinguishes provider declaration provenance from the
actual registration callsite. `ActiveBindSourceFile/Line` points at the
`FAngelscriptBind` declaration, not each `.Method()` call. Of 2920 callsites,
2593 have a lexically preceding provider, 50 are safely attributable because
their file has exactly one provider, and 277 live in helper or multi-provider
layouts that require the Runtime provider + canonical-declaration/native-form
join. The unresolved rows stay explicit instead of being assigned to a guessed
nearest provider.

Task `5.3a` now owns the TDD closure for Engine-owned owner/provider/phase/source
provenance plus the native-form/descriptor/traits/ABI inventory view. That is
the missing authority needed to reconcile 2920 source call sites with actual
runtime expansions and eliminate Bind-produced `origin=unknown` rows.

### Production capability carrier compile checkpoint

The AOT test generator now consumes the real per-function backend result for
`TypedASTCapabilityShowcase`, requires `ActualBackendId=TypedAST` and all three
Provider entries, verifies that the packaged module source owns the typed body,
contains the production `IsRunningCommandlet()` direct call, and contains no
`FAngelscriptJITExecutionContext`. It appends only external declarations and a
test address registration to the already-owned
`TypedASTJITProviderProbe.generated.cpp`; the implementation remains in the
normal per-AS-module `.jit.cpp`, so the generated-file count does not grow and
the Provider module content/hash is not mutated after packaging.

The official incremental build was attempted but UBT stopped before compiling
because a different `SigilProject` editor process had the UE 5.8 global Live
Coding mutex active. That process and its `LiveCodingConsole` were not stopped
or modified. This attempt is an external admission block, not a source result:

```text
Label: typed-ast-capability-production-carrier
Result: NOT COUNTED; UBT rejected build before compile because Live Coding is active
Evidence: Saved/Build/typed-ast-capability-production-carrier/
          20260814_230842_572_348cfaa9/UBT.log
```

To obtain an early syntax/type diagnostic without touching the other editor,
the existing UBT response file for the complete `Module.AngelscriptTest.44.cpp`
unity shard was invoked from UBT's recorded Engine/Source working directory,
with only object/dependency/SARIF outputs redirected under this worktree's
`Saved/CompileProbe`. It compiled successfully. This proves the changed
generator translation shard compiles against the current PCH and module
definitions, but deliberately does not claim the still-pending UBT link or
runtime GREEN.

```text
Diagnostic compile: Module.AngelscriptTest.44.cpp
Result: PASS; cl.exe exit 0
Output: Saved/CompileProbe/typed-ast-capability-production-carrier/
Boundary: not a substitute for official UBT build/link
```

### Unexported Bind call and generated-name decision

The native-call design now has an explicit two-route contract:

1. an exported/header-inline callable is named and invoked directly by the
   generated `.jit.cpp` through its real C++ declaration;
2. a provider-private or otherwise unexported callable is invoked through the
   exported typed Runtime bridge, which prepares the current registered
   `asCScriptFunction` and caller/calling-convention metadata the same way the
   AngelScript VM reaches that binding.

For route 2, generated source must not misleadingly look as if it links the
private symbol. It records both names instead: `Emitted C++ Callee` is the
literal `AngelscriptTypedASTJIT::InvokeBound<Return, Args...>` template call,
while `Registered Target` is the human-readable current AS/C++ callable reached
through the Engine binding database. The canonical AS declaration, registered
target display name, stable key, expected ABI and slot are emitted to comments,
the Provider manifest and diagnostics. The template arguments define typed
marshalling; key + ABI resolve once to a deterministic slot during
Provider/Engine initialization. Display strings are therefore available for
source inspection and errors but are never used for hot-path overload lookup or
as a substitute for the current binding identity.

Tasks 5.7, 5.9, 5.12 and 7.1 now require the generated/source/runtime inspection
chain to render:

```text
AS declaration -> emitted C++ callee -> reference slot -> current registered target
```

and to expose bound, unbound, stale and ABI-mismatch states. This gives the
generated C++ a truthful function name while preserving ASLR, reload, unbind,
module unload and multi-Engine safety.

### Native-call installed-inventory RED checkpoint

Task 5.3a now has a production-facing RED test named
`GenerationNativeCallInventoryOwnsCompleteBindProvenance` in
`AngelscriptStaticJITGenerationEngineTests.cpp`. It creates a real
`StaticJITGeneration` Engine and requires its immutable snapshot to contain one
`NativeCallInventory` row for every function registered through the Engine's
Bind provenance map, rather than only native targets referenced by the fixture
HIR. Every row must have a unique Engine-local ID, non-unknown origin,
owner/provider/phase, Engine-owned normalized provider-declaration source
file/line, and canonical declaration. Representative assertions cover:

- `IsRunningCommandlet`: `AngelscriptRuntime/CoreGlobals`, explicit-bind source
  provenance, `NativeFunction` display, reviewed external descriptor, and
  `cdecl:bool()` ABI;
- `Print`: `AngelscriptRuntime/Logging.Functions`, explicit-bind source
  provenance, and no `origin=unknown` gap.

The official UBT runner is still unable to enter compilation while the unrelated
`SigilProject` Live Coding session owns the UE 5.8 global mutex. A redirected
single-unity diagnostic compile was therefore used only to confirm that the new
test fails for the intended missing production contract:

```text
Diagnostic compile: Module.AngelscriptTest.43.cpp
Result: EXPECTED PRE-RED; cl.exe exit 2
Primary error: FAngelscriptStaticJITGenerationSnapshot has no member NativeCallInventory
Output: Saved/CompileProbe/native-call-inventory-red/
Boundary: not accepted as the formal runner RED; Runtime implementation remains unchanged
```

When the Live Coding lock is released, the next TDD action is the official UBT
build. Only after it reproduces this API-level RED will the registration
provenance and generation-inventory production patch begin.

### Generated call-site name is now part of the `.jit.cpp` contract

The unexported-call decision was tightened after the user clarified that the
converted C++ must itself reveal which function is being reached. A bridged
call will no longer rely only on an adjacent comment, an external manifest, or
a Runtime dump. The generated translation unit owns one immutable named
`FAngelscriptTypedASTJITBoundCallSite` row per bridged call site. Conceptually:

```cpp
static const FAngelscriptTypedASTJITBoundCallSite ASJIT_Call_PrivateAdd = {
    "int PrivateAdd(int, int)",
    "FProviderPrivateBinds::PrivateAdd",
    <stable-function-key>, <expected-abi>, 7
};

return AngelscriptTypedASTJIT::InvokeBound<int32, int32, int32>(
    Execution, ASJIT_Call_PrivateAdd, Left, Right);
```

This makes two facts explicit in the generated file:

1. the function that C++ literally calls is the exported typed Runtime bridge
   `AngelscriptTypedASTJIT::InvokeBound<...>`;
2. the current registered AS/C++ target expected behind that bridge is named in
   `ASJIT_Call_PrivateAdd`, alongside its canonical AS declaration.

The strings are deliberately diagnostic-only. They are passed as part of a
static metadata view so the bridge can include the names in an exception or
dump, but the invocation does not copy, parse, hash, search, or overload-resolve
them. Provider/Engine adoption resolves stable key plus expected ABI once, and
the row's numeric reference-slot index selects the current Engine-owned binding
record. The Runtime bridge then prepares a nested AngelScript call using the
current `asCScriptFunction` and registered system caller, matching the VM path
for the supported scalar ABI. This preserves readability without freezing a
private pointer, an Engine-local FunctionId, or a name lookup into the generated
DLL.

OpenSpec design and native-linkage/backend/AOT-test scenarios now require this
same-file row. Tasks 5.7, 5.9 and 5.12 were expanded to cover its golden output,
typed API, executable bridge behavior, cross-DLL fixture, and the negative
requirement that display strings never participate in hot dispatch.

### Source external-descriptor inventory v9

The source scanner now treats native-form metadata and external-call linkage as
separate facts. `Build-NativeCallSourceCallsites.ps1` scans the complete Runtime
source tree for reviewed `AttachReviewed*` helper invocations, ignores the
helper declaration itself, associates the concrete `FAngelscriptBoundFunction`
variable back to its registration call site, and emits a third deterministic
artifact:

```text
research/native-call-source-descriptors.csv
```

The current production-source result is intentionally small:

- 2,920 registration call sites;
- 1,656 call sites with a legacy/native form;
- exactly 1 call site with an explicit external-call descriptor;
- exactly 1 concrete reviewed-helper attachment.

That one descriptor is the `CoreGlobals` registration of
`bool IsRunningCommandlet() no_discard`. Its call site at
`Binds/Bind_CoreGlobals.cpp:67` is associated with the reviewed attachment at
line 72 and records:

```text
Linkage     : HeaderInline
Symbol      : IsRunningCommandlet
Include     : CoreGlobals.h
OwningModule: Core
```

This proves that `.NativeFunction()`/`.NativeMethod()` display spellings are
not external-linkage contracts. The remaining native-form rows must stay
bridge/compile-out/unsupported until a reviewed descriptor is attached; the
inventory must never promote them to direct calls by spelling inference.

The v9 outputs were generated twice in PowerShell 7 and were byte-identical:

```text
native-call-source-callsites.csv
  663AE50D9A4103D3320BB527A004F471A5E882F5FD2FF1CD1F919A3E57ADD182
native-call-source-providers.csv
  A5B0363F65778F11A3EF3DBC6484A61E8836236B3F8248C85AB6A9F8346379C1
native-call-source-descriptors.csv
  124EACEDD90ECD2BF2722096223041BE17C98FB5FC8ABC562B7D5F21E236CF37
native-call-source-callsites-summary.json
  BA9B0A1ECDDE31661AC3F6827BD85ED547BA4A1593FB264B967EDAE7E71D4F8D
```

The JSON summary now records the stable repository-relative source root rather
than the local worktree drive/path, so the research evidence is portable across
the main checkout, this isolated worktree, and another machine. Task 5.3 now
requires retaining and reconciling all three source CSVs with the final fresh
Engine export.

### Bridge integration seam: execution state was not reaching the Typed body

While preparing task 5.7 RED coverage, inspection of
`AngelscriptTypedASTJITProviderEmitter.cpp` found a concrete integration gap.
The generated raw, VM and Parms entry adapters already receive
`FScriptExecution& Execution`, but the current Typed body is emitted as a pure
`Body(args...)`, and each adapter calls it without the execution reference.
Consequently a future `InvokeBound` expression inside that body could not read
the current resolved-reference table, preserve the outer exception state, or
restore the active frame.

The selected correction is conditional execution-state threading:

```text
direct-only closure:
  TypedBody(args...)

closure containing Bridge:
  TypedBody(FScriptExecution& Execution, args...)
```

The call-closure/emission plan owns a transitive `bRequiresExecutionState`
fact. If any reachable call is bridged, the root and required emitted helpers
receive the hidden first parameter, and raw/VM/Parms adapters pass through the
same reference they already own. Direct-only bodies retain their existing
ordinary C++ signature. This does not reintroduce
`FAngelscriptJITExecutionContext`; the typed bridge reads the slot table and
exception state directly from `FScriptExecution` and prepares only the narrow
VM-equivalent nested call needed for the registered target.

Design, backend scenarios and tasks 5.7/5.9 now require both sides of this
contract: bridge output must thread the reference, while the existing pure
direct golden must remain unchanged.

The first task 5.7 test-first slice now lives in
`AngelscriptTypedASTJITGeneratedOutputTests.cpp` pending the later dedicated
runtime bridge fixture. It freezes:

- direct-only emission reports no execution-state requirement;
- a provider-private scalar call carries `Bridge`, canonical declaration,
  registered target, stable key, expected ABI, named call-site symbol and slot;
- generated arguments still materialize in authoritative reverse evaluation
  order and are supplied in formal order;
- the call uses `InvokeBound<Return, Args...>(Execution, CallSiteRow, ...)`;
- an exception check immediately follows the bridge call;
- the Provider raw adapter passes its existing `Execution` reference into the
  Typed body, and VM/Parms continue through that adapter;
- neither body nor adapters name `FAngelscriptJITExecutionContext` or a
  linkable provider-private symbol.

With the unrelated Live Coding mutex still active, the existing UBT unity
response was used only as diagnostic pre-RED evidence. Invoking it from UBT's
required `Engine/Source` working directory failed at the first missing
production contract exactly as intended:

```text
Diagnostic compile: Module.AngelscriptTest.44.cpp
Result: EXPECTED PRE-RED; cl.exe exit 2
Primary error: FAngelscriptTypedASTJITEmission has no member bRequiresExecutionState
Output: Saved/CompileProbe/typed-native-bridge-red/
Boundary: not accepted as the formal runner RED; no bridge production patch started
```

An earlier invocation from the project directory failed on the relative UE
`CQTest.h` include and was rejected as a harness error, not counted as RED.

### VM-equivalent bridge mechanism and generated target naming

The private/unexported Bind route has now been refined against maintained-fork
source rather than left as an abstract “call a function pointer” bridge. The
full evidence and selected algorithm are recorded in
`research/typed-native-call-vm-bridge.md`.

The current implementation seams prove that a Provider reference slot can own
the current `asCScriptFunction` plus its `AddRef` lifetime, while the existing
BytecodeJIT dynamic-call route already performs:

```text
FAngelscriptContext(TargetEngine)
  -> Prepare(CurrentFunction)
  -> SetObject / SetArg*
  -> Execute
  -> scalar return / nested exception adoption
```

For a registered system function, maintained `Execute` enters
`CallSystemFunction`, which selects the registration's real
`CallFunctionCaller` or `CallGeneric`. This preserves its call convention,
parameter offsets, hidden registration metadata, object placement, caller and
return behavior. TypedASTJIT will reuse the existing `FAngelscriptContext`
pool; it will not cast/call a private pointer, declare a guessed `extern`, copy
`ScriptCallNative`, or add another context pool/caller.

Generated source deliberately carries two different names:

```text
Emitted C++ Callee : AngelscriptTypedASTJIT::InvokeBound<Return, Args...>
Registered Target  : FProviderPrivateBinds::PrivateAdd
AS declaration     : int PrivateAdd(int, int)
```

`Return, Args...` is the compile-time scalar marshalling shape. The canonical
declaration and registered-target strings are immutable source/dump/failure
metadata. Stable key plus expected ABI is resolved once at Provider adoption,
and the numeric row slot owns dispatch identity; invocation does not copy,
parse, hash, compare or search either string. This means the converted C++ is
readable without turning a function name into a hot-path lookup.

OpenSpec design, native-linkage/backend/AOT-test scenarios, and tasks 5.7, 5.9
and 5.12 now require the exact maintained context/caller path, both literal and
registered target names, display-string non-identity tests, VM result parity,
and bind/rebind/unbind/Engine-replacement slot behavior. Production bridge code
has not started; formal RED still waits for the unrelated Live Coding mutex to
be released. As of this checkpoint, UnrealEditor PID 44576 and
LiveCodingConsole PID 101880 remain active and were not touched.

### Source native-call review queue v10 and conditional compile-out correction

`Build-NativeCallSourceCallsites.ps1` now assigns every one of the 2,920 source
registration call sites a deterministic, explicitly non-final source-evidence
classification. The new columns are:

```text
SourceEvidenceDisposition
SourceEvidenceReason
RequiredInstalledAuthority
CompileOutMethods
```

Current source-only totals are:

```text
direct-descriptor-candidate        1
bridge-candidate                1655
bridge-or-unsupported-review    1231
compile-out-rule-review           33
installed authority pending     2920
```

The first attempted rule treated every `.CompileOut*()` occurrence as a
compile-out candidate. Inspection of `Bind_Logging.cpp` showed this was too
strong: `Print` uses `CompileOutIfNoLog`, which is target/profile conditional,
and its non-rewritten EditorDevelopment path must still receive the planned
exported direct call. The scanner was corrected before accepting the evidence.
It now records exact methods such as `CompileOutIfNoLog`,
`CompileOutAsEnsure`, and `CompileOutAsCheck` and requires both the target-
profile rewrite decision and the remaining callable disposition. Source
presence alone can no longer hide direct/bridge/unsupported analysis.

The v10 source rows correctly show:

- `IsRunningCommandlet`: `direct-descriptor-candidate`, backed by the one
  explicit reviewed HeaderInline descriptor;
- `Print`: `compile-out-rule-review` with `CompileOutIfNoLog`, awaiting its
  target-profile decision plus task 5.5 exported-callable descriptor;
- private native-form rows without descriptors: `bridge-candidate`, still
  awaiting installed scalar ABI/routing/lifetime/current-caller authority;
- no-native-form rows: `bridge-or-unsupported-review`, never silently direct.

All four generated outputs were run twice with PowerShell 7 and remained
byte-identical:

```text
native-call-source-callsites.csv
  522C4F992E8B8893C3E8E119F7A1133A5935374996B61A2DAE6375CDB80F4C92
native-call-source-providers.csv
  A5B0363F65778F11A3EF3DBC6484A61E8836236B3F8248C85AB6A9F8346379C1
native-call-source-descriptors.csv
  124EACEDD90ECD2BF2722096223041BE17C98FB5FC8ABC562B7D5F21E236CF37
native-call-source-callsites-summary.json
  CAA091972BE9FD31B4F677A8B4A070FC8F407865C76796D0C134EF76A14E5304
```

Task 5.3 and the installed-inventory implementation attachment now carry the
same conditional compile-out rule. This source queue is useful review input but
does not close task 5.3: all 2,920 rows still require the fresh final installed
Engine join before any mandatory final disposition is accepted.

### Source provider attribution v11: unique helper-call ownership

The v10 source queue left 277 registration expressions unattributed because
many Bind files define registration helpers before their `FAngelscriptBind`
Providers. Manual inspection of `Bind_FString.cpp`,
`Bind_FCollisionQueryParams.cpp`, `Bind_WorldCollision.cpp` and
`Bind_Delegates.cpp` confirmed the common shape: the Provider's inline lambda
calls one or more named `void` helpers, and those helpers own the `.Method()` or
`.BindGlobalFunctionForTarget()` expressions.

`Build-NativeCallSourceCallsites.ps1` schema v11 now builds a conservative
same-file call graph over named `void` helpers. It attributes a containing
helper only when exactly one Provider reaches it. It does not guess across
translation units and leaves shared/ambiguous helpers unresolved. Current
results are:

```text
lexical preceding Provider            2593
single-Provider file                     7
unique same-file helper call graph      306
Provider-attributed total              2906
intentionally unattributed               14
registration total                     2920
```

The 14 remaining rows are exactly the dynamic/cross-file boundary:

- eight `Bind_BlueprintCallable.cpp` direct-pointer registrations;
- four `BlueprintCallableReflectiveFallback.cpp` generic fallback
  registrations;
- two `Bind_Primitives_Type.cpp` generated bool-property accessors.

Those functions are invoked from Blueprint-type/property registration owned in
other translation units and may expand per initialized Engine. The source
scanner intentionally does not assign a speculative Provider; the final
generation Engine inventory and task 5.3a provenance capture must resolve them.

The v11 outputs were generated twice with PowerShell 7 and were byte-identical:

```text
native-call-source-callsites.csv
  C4110781A1727107C97B1B4C33A301DBECB99058A15D9206519B9500DCABEEE3
native-call-source-providers.csv
  A5B0363F65778F11A3EF3DBC6484A61E8836236B3F8248C85AB6A9F8346379C1
native-call-source-descriptors.csv
  124EACEDD90ECD2BF2722096223041BE17C98FB5FC8ABC562B7D5F21E236CF37
native-call-source-callsites-summary.json
  4EA3323B6BD0C110041F52AFE06C3B09AF2D3F4DFB3C868E6DD2B68301D83C1B
```

This improves the source side of the direct/bridge/compile-out/unsupported
review, but it still does not close task 5.3. Every final disposition remains
conditioned on the fresh installed Engine's callable kind, normalized ABI,
routing, lifetime, external descriptor and target-profile rewrite decision.

### Task 1.9 verifier slice: exact effective-receiver invariants

The lock-independent Standalone baseline was first rerun before changing the
maintained fork:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-aot-continuation_01_Standalone
Result: 20/20 PASS
Evidence: Saved/StandaloneTests/
          typed-semantic-aot-continuation_01_Standalone/
          20260815_004541_724_d4822646/Summary.json
```

Audit of `VerifyTypedSemanticFunction` then found that every non-`None`
receiver was accepted as long as its symbol index and type were merely valid.
It did not prove parameter zero, object type, exact symbol type, synthetic
native-this ownership, external/mixin trait consistency, or invocation kind.
`AngelscriptTypedSemanticIRTests.cpp` received test-first cases for the four
normalized receiver kinds plus those malformed shapes.

Two fixture failures were rejected before accepting RED:

1. A stack-constructed internal `asCScriptEngine` caused the TypedSemanticIR
   CTest to hang until the 595-second CTest phase timeout. Internal Engine
   construction bypasses the supported `asCreateScriptEngine`/
   `ShutDownAndRelease` lifetime and was replaced with a test-owned Engine.
2. Passing `nullptr` to `asCObjectType(asCScriptEngine*)` access-violated
   because that constructor initializes its namespace from
   `engine->nameSpaces[0]`. The corrected fixture uses the test-owned Engine
   and marks its synthetic types `asOBJ_REF`, matching the maintained
   `IsObject()` contract.

The formal RED was then narrow and deterministic:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-receiver-red-fixed_01_Standalone
Result: 19/20 PASS; only AngelscriptStandalone.TypedSemanticIR failed
Failures: 12 expected malformed receiver/trait/invocation cases
Evidence: Saved/StandaloneTests/
          typed-semantic-receiver-red-fixed_01_Standalone/
          20260815_010237_651_ed7e027e/Summary.json
```

`VerifyTypedSemanticFunction` now requires:

- `None` to have no receiver payload, receiver trait or instance invocation;
- `NativeObjectThis` to use an object-typed synthetic `Receiver` symbol, no
  declared parameter index, no external/mixin trait and an
  instance/constructor/destructor invocation;
- `ExternalImplicitThis` to alias the exact object-typed parameter-zero symbol,
  carry only `asTRAIT_EXTERNAL_IMPLICIT_THIS` and remain a global invocation;
- `MixinFirstParameter` to alias the exact object-typed parameter-zero symbol,
  carry only `asTRAIT_MIXIN` and remain a global invocation;
- every mismatch to return the specification's stable
  `InvalidEffectiveReceiver` code.

The official GREEN is:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-receiver-green_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.07 s
Evidence: Saved/StandaloneTests/
          typed-semantic-receiver-green_01_Standalone/
          20260815_010501_534_bac21a54/Summary.json
```

At this verifier-only checkpoint task 1.9 remained unchecked. The later
compiler-capture checkpoint below constructs real `NativeObjectThis`,
`ExternalImplicitThis`, and mixin receiver records and closes the task. The UE
build for these fork changes remains pending while the unrelated SigilProject
Live Coding mutex is active.

### Unexported-call bridge names made explicit

The unexported Bind decision is now expressed as three separate, inspectable
layers rather than one ambiguous function-name field:

```text
Emitted C++ Callee : AngelscriptTypedASTJIT::InvokeBound<Return, Args...>
Runtime DLL Core   : AngelscriptTypedASTJIT::InvokeBoundViaVM
Registered Target  : FProviderPrivateBinds::PrivateAdd
```

The converted `.jit.cpp` literally calls the header-defined `InvokeBound`
template. Its `Return, Args...` parameters statically own the reviewed
scalar/enum packing shape. The template then calls the fixed non-template
`ANGELSCRIPTRUNTIME_API InvokeBoundViaVM` function in `AngelscriptRuntime`.
That Runtime core resolves no name: it validates the already-adopted numeric
slot, obtains the current retained `asCScriptFunction`, and uses the maintained
`FAngelscriptContext::Prepare/SetArg*/Execute` path. An unexported registered
system function therefore reaches its existing `CallFunctionCaller` or
`CallGeneric` implementation in the same way as an ordinary AS VM call.

Canonical AS declaration and registered C++ target spelling remain immutable
source/dump/failure strings only. Stable key plus expected ABI selects the slot
during Provider/Engine adoption, so duplicate or modified display strings
cannot redirect execution. Design, native-linkage/backend/AOT-test
requirements and tasks 5.7, 5.9 and 7.1 now require the complete inspection
chain:

```text
AS declaration -> InvokeBound<...> -> InvokeBoundViaVM
               -> current reference slot -> registered target
```

This checkpoint changes the OpenSpec implementation contract only. The bridge
production slice remains pending its formal UE RED/GREEN cycle after the
unrelated Live Coding mutex is released.

### Unexported-call source visibility decision confirmed

The user confirmed that a non-exported Bind should execute exactly like an AS
VM call, but the converted C++ must still make the represented function obvious.
The contract now distinguishes readable target naming from dispatch identity:

- the literal converted C++ call is
  `AngelscriptTypedASTJIT::InvokeBound<Return, Args...>`;
- the fixed imported Runtime implementation is
  `ANGELSCRIPTRUNTIME_API AngelscriptTypedASTJIT::InvokeBoundViaVM`;
- a named immutable same-file call-site row records the canonical AS
  declaration and the known registered C++ Bind spelling;
- the expression passes that row by `const&`, not a bare string, and the
  successful path consumes only its already-adopted numeric slot.

Function names are intentionally not template identities. `Return, Args...`
describe only the compile-time marshalling contract; stable key + expected ABI
select the current slot during Provider/Engine adoption. This keeps the
generated source learnable while avoiding overload ambiguity, per-call string
lookup, private-symbol linkage, or stale name-based dispatch after rebind,
module unload, Engine replacement, or Live Coding. Tasks 5.7, 5.9 and 7.1 were
tightened to test this exact source and runtime boundary.

### Task 1.9 complete: compiler-owned effective receiver capture

The earlier verifier slice proved malformed-model rejection but did not prove
that the maintained compiler could construct any non-global receiver. A new
Standalone fixture now compiles one real module containing:

- an ordinary script instance method with no declared parameters;
- a global `external_implicit_this` function whose object-typed parameter zero
  is an explicit `&in` VM parameter;
- a global `mixin` function with the same explicit object parameter shape.

The first attempted fixture used plain `Receiver&`, which this standalone
Engine correctly rejected as unsafe `&inout` for a type without handle support:

```text
Only object types that support object handles can use &inout.
Use &in or &out instead.
```

That run was rejected as a fixture failure rather than accepted as semantic
RED. The source was corrected to `Receiver&in`, matching the standard
maintained frontend contract without enabling a broader unsafe-reference
profile.

A later runner invocation contained the intended three receiver failures plus
an unrelated transient `AngelscriptStandalone.Package` failure whose installed
`--version` process produced no output. The package test immediately passed
alone in 39.85 seconds and the final clean RED passed all other tests, so only
the clean run is accepted as production TDD evidence:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-receiver-capture-red-clean_01_Standalone
Result: 19/20 PASS; only AngelscriptStandalone.TypedSemanticIR failed
Failures:
  native method should publish captured typed HIR
  external implicit-this function should publish captured typed HIR
  mixin function should publish captured typed HIR
Evidence: Saved/StandaloneTests/
          typed-semantic-receiver-capture-red-clean_01_Standalone/
          20260815_012118_057_aa8471c8/Summary.json
```

`asCTypedSemanticIRBuilder` now derives the authoritative header directly from
the compiled `asCScriptFunction`:

- an `objectType` creates one synthetic `Receiver` symbol named `this`, with
  the exact const-qualified object type and `parameterIndex=-1`;
- constructor/destructor traits select their explicit invocation kinds, while
  an ordinary object function selects `InstanceMethod`;
- `external_implicit_this` and `mixin` remain global functions and separately
  alias their real object-typed parameter-zero symbol after parameter binding;
- conflicting traits, missing symbols and non-object parameter zero fail the
  provisional capture transaction without changing normal compilation;
- native `this` does not change `GetParamCount()`, while external/mixin retain
  exactly the original parameter and type in the VM function signature.

The task audit then found that the task text also named a dangling receiver
symbol explicitly. A final negative fixture changes the external receiver to
owned symbol `S41` and proves the same stable `InvalidEffectiveReceiver`
result. The final full Standalone GREEN after that coverage was added is:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-receiver-capture-green-final_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.29 s
Package: PASS in 38.38 s
Evidence: Saved/StandaloneTests/
          typed-semantic-receiver-capture-green-final_01_Standalone/
          20260815_012611_471_67aac8b2/Summary.json
```

Task 1.9 is complete. This does not close task 2.10's explicit-this and
unqualified external-body operand capture, task 2.11's mixin call-site
receiver/evaluation mapping, task 2.7's capture-on/off bytecode equality, or
task 2.9's synthesized constructor/destructor audit. The UE compiler build and
native SDK coverage also remain pending while the unrelated SigilProject Live
Coding mutex is active.

### Task 1.8 fork/Standalone slice GREEN: canonical function-trait summary

The test-first table enumerates every one of the maintained fork's 27 current
`asEFuncTrait` bits and independently states its policy, receiver, invocation,
dispatch, body-availability, lifetime and profile categories. The formal RED
failed in the build phase only because the requested summary type, classifier
and known-mask constant did not exist:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-trait-summary-red_01_Standalone
Result: build RED; 0 tests executed
Cause: missing asSTypedSemanticFunctionTraitSummary,
       ClassifyTypedSemanticFunctionTraits and
       asTYPED_SEMANTIC_KNOWN_FUNC_TRAIT_BITS
Evidence: Saved/StandaloneTests/
          typed-semantic-trait-summary-red_01_Standalone/
          20260815_013035_381_bf0f4bce/Summary.json
```

Production now has one maintained-fork classifier in
`as_typed_semantic_ir.cpp`. The compiler stores its result beside the raw trait
snapshot, the verifier recomputes it and returns
`InvalidFunctionTraitSummary` for disagreement, and the deterministic dump
prints all nine raw/normalized groups. A compile-time assertion and the
independent test-table union both make adding a future `asEFuncTrait` without a
policy row fail visibly. Unknown bits are preserved only in `unknownTraitBits`;
they do not enter a known category and remain structurally valid for the
existing TypedASTJIT eligibility layer to fail closed with
`UnsupportedFunctionTrait`.

The official Standalone GREEN is:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-trait-summary-green_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.24 s
Package: PASS in 39.53 s
Total test time: 45.94 s
Evidence: Saved/StandaloneTests/
          typed-semantic-trait-summary-green_01_Standalone/
          20260815_013711_374_8b9d642a/Summary.json
```

Task 1.8 deliberately remains unchecked at this checkpoint. UE-side synthetic
HIR users were updated to construct matching summaries, and the existing
unknown-trait eligibility case remains the downstream fail-closed assertion,
but both require a fresh UE modular build/test after the unrelated
`UnrealEditor` PID 44576 and `LiveCodingConsole` PID 101880 release the UE 5.8
Live Coding mutex. Neither process was stopped or modified.

### Task 1.5 complete: Engine capture profile freezes before first build

The audit found a concrete implementation/design mismatch. The private
`SetTypedSemanticIRCapture` comment already required selection before source
compilation, but the inline setter returned `void` and continued mutating the
Engine property after modules had been built. One Engine could therefore
compile an early module without HIR and a later module with HIR even though the
generation contract treats capture profile as Engine-wide authority.

The formal RED added three assertions to the real receiver-capture fixture:
new Engines default off, enabling succeeds before the first Build, and a
post-Build attempt to disable capture is rejected without changing the frozen
value. It failed only because the old setter returned `void`:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-capture-freeze-red_01_Standalone
Result: build RED; 0 tests executed
Cause: void SetTypedSemanticIRCapture could not report pre/post-build admission
Evidence: Saved/StandaloneTests/
          typed-semantic-capture-freeze-red_01_Standalone/
          20260815_014158_835_88635e2f/Summary.json
```

`SetTypedSemanticIRCapture(bool)` is still fork-private and now returns a
success flag. `asCScriptEngine::RequestBuild()` freezes the property when the
first source or archive build successfully acquires the Engine build slot.
Every later setter call returns false and leaves the selected value unchanged.
Freezing the shared build/load entry prevents mixed capture profiles across
modules without adding any symbol or method to public `angelscript.h`.

The official GREEN is:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-capture-freeze-green_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.29 s
Package: PASS in 41.81 s
Total test time: 49.06 s
Evidence: Saved/StandaloneTests/
          typed-semantic-capture-freeze-green_01_Standalone/
          20260815_014226_441_86cf8b13/Summary.json
```

Task 1.5 is complete. This does not close task 2.7's cross-profile bytecode,
metadata and archive equality matrix or task 1.12's UE modular build gate.

### Task 2.6 complete: SemanticObserver/HIR overlap characterization GREEN

The existing Standalone observer test proved that observer installation with
HIR capture off preserved bytecode, but it did not compile one function with
both mechanisms enabled or compare their overlapping semantic facts. A fourth
test-owned Engine now enables the private HIR setting before Build, installs an
independent `asISemanticObserver`, and compiles an additional pure
`ObserveTyped()` function whose body resolves `Select(11)`.

The test reads HIR directly from that function's `ScriptFunctionData`; it never
constructs an HIR node from observer events. It then proves:

- the original observed Engine still has capture disabled and continues to
  emit resolved-call, constructor, assignment and constant-string events;
- observer-only, baseline, and observer-plus-HIR Engines save identical
  bytecode;
- the captured function owns verifier-valid HIR with one resolved system call;
- observer and HIR independently report the same selected Engine-local
  `Select(int)` FunctionId, exact `int` argument/result types, section,
  source offset and source length.

The planned RED label passed on its first run. This is accepted as a
characterization GREEN: the compiler already emitted both independent views
correctly and only the missing cross-check was added, so no production change
was manufactured:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  semantic-observer-hir-overlap-red_01_Standalone
Result: 20/20 PASS on first characterization run
SemanticObserver: PASS in 0.28 s
Package: PASS in 40.53 s
Total test time: 43.38 s
Evidence: Saved/StandaloneTests/
          semantic-observer-hir-overlap-red_01_Standalone/
          20260815_014628_750_ef3db3bf/Summary.json
```

Task 2.6 is complete. This proves overlap consistency only; the wider
capture-on/off metadata, VM behavior and archive non-persistence matrix remains
task 2.7.

### Task 1.6 status audit: independent Standalone HIR target complete

Task 1.6 was still unchecked even though its deliverables landed and were
verified during the P1 model/lifetime checkpoint. The audit confirms:

- `Standalone/Tests/AngelscriptTypedSemanticIRTests.cpp` is an independent
  executable, not a UE Automation shim;
- CMake links it to `AngelscriptMaintainedFork`, registers
  `AngelscriptStandalone.TypedSemanticIR`, and selects the compatibility include
  tree only for that consumer rather than leaking it through the fork target;
- the test constructs and destroys the private model, verifies indexed arenas
  and malformed records, compiles real function-owned HIR, and checks an exact
  pointer-free normalized dump;
- `AngelscriptStandalone.Architecture` rejects exposure of the private HIR
  surface through public `Core/angelscript.h` and rejects real Unreal/generated
  build paths in the standalone targets;
- the original P1 RED/GREEN, focused UE `4/4`, Compiler `126/126`, and
  Standalone `20/20` evidence remains recorded above; the fresh task 1.5 and
  2.6 Standalone runs again passed TypedSemanticIR and Architecture.

Task 1.6 is therefore complete. This bookkeeping closure does not claim task
1.1's full failed-build/module-replacement matrix or task 1.4's donor-swap and
destructor-order coverage.

### Provider-private call naming contract refined

The unexported-Bind route is now recorded without requiring every
`FAngelscript*Binds` helper to become a DLL export. Generated Typed AOT C++ will
call the header-defined `AngelscriptTypedASTJIT::InvokeBound<Return, Args...>`
template; its fixed imported Runtime core `InvokeBoundViaVM` prepares the
current registered `asCScriptFunction` and follows the maintained AS VM
`CallSystemFunction -> CallFunctionCaller/CallGeneric` route.

To keep the converted C++ understandable, every bridged site owns one row named
`ASJIT_Call_<sanitized-readable-function-name>_<short-stable-suffix>`. The row
and adjacent comment retain the complete AS declaration, registered C++ Bind
spelling when available, emitted template callee, Runtime DLL core, full stable
key, expected ABI and slot. Strings are inspection/failure metadata and
`Return, Args...` are only the typed marshalling shape. Neither selects the
function: Provider/Engine adoption resolves the full key + ABI once, and the
hot path consumes the validated current numeric slot.

OpenSpec design, native-call linkage scenarios, bridge research and new task
5.9a now require deterministic readable identifiers, overload/collision tests,
the three-layer call mapping, and negative proof that changing display text or
the readable identifier cannot redirect execution. Production bridge code
remains pending the formal UE RED/build gate; the unrelated SigilProject Live
Coding session is still not interrupted.

### Task 2.5 incremental checkpoint: ternary marker GREEN

The first typed unsupported-but-valid compiler marker is implemented for the
ternary expression. A real captured function now compiles
`return Condition ? 1 : 2;` and retains one `Unsupported/Ternary` expression
whose ordered operands are the already-captured condition, true expression and
false expression. The marker owns the compiler-resolved result type and exact
source span; it does not alter bytecode generation.

The verifier requires exactly three earlier arena operands for this category,
and the deterministic pointer-free dump renders
`kind=Unsupported type=int unsupported=Ternary operands=[...]`. The test also
executes both VM branches and proves the results remain `1` and `2`.

The formal RED failed only the two new marker/dump assertions while the script
compiled, both VM executions succeeded, and the other 19 Standalone tests
passed:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-ternary-marker-red_01_Standalone
Result: 19/20 PASS; TypedSemanticIR failed only missing Ternary marker/dump
Evidence: Saved/StandaloneTests/
          typed-semantic-ternary-marker-red_01_Standalone/
          20260815_015929_919_18c784c9/Summary.json
```

The production change then passed the complete official Standalone scope:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-ternary-marker-green_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.25 s
Package: PASS in 38.54 s
Total test time: 44.90 s
Evidence: Saved/StandaloneTests/
          typed-semantic-ternary-marker-green_01_Standalone/
          20260815_020135_034_d353a5f3/Summary.json
```

Task 2.5 remains open: object/property access, reference, handle, container,
construction/lifetime, lambda, managed-cleanup, suspend and compiler exception
region categories still require their own authoritative capture seams and
RED/GREEN coverage. This checkpoint intentionally claims only the ternary
slice.

The verifier coverage was then strengthened with malformed copies that remove
one ternary operand or make an operand point to the marker itself. Both must
return `InvalidNodeShape`; the fresh official run remains fully green:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-ternary-verifier-green_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.26 s
Package: PASS in 38.04 s
Total test time: 40.68 s
Evidence: Saved/StandaloneTests/
          typed-semantic-ternary-verifier-green_01_Standalone/
          20260815_020344_561_860da20a/Summary.json
```

### Task 1.10 incremental checkpoint: compiler snapshot helper Standalone GREEN

The maintained fork now exposes one private, output-only
`BuildTypedSemanticSnapshot` helper. It accepts only a current in-memory
function-owned `asCTypedSemanticFunction`, runs the structural verifier first,
and returns one of `Verified`, `MissingFunction`, or `VerificationFailed` with
stable diagnostics plus deterministic text and compact JSON. Verified output
embeds the normalized pointer-free HIR; invalid or missing input emits
`normalizedHIR:null`/`NormalizedHIR=none` rather than publishing a successful
snapshot. No parser node, Engine, module, context, file path, timestamp or
output path is retained by the result.

The Standalone fixture creates its own `asCScriptEngine`, enables capture before
Build, snapshots the real unsupported-but-valid Ternary function twice, and
proves byte-identical text/JSON, retained source marker, no `0x` pointer
spelling, stable invalid-HIR diagnostics and an explicit missing-function
state. The pre-existing VM execution assertions still prove the snapshot path
does not affect executable bytecode behavior.

The formal RED failed during the TypedSemanticIR target build only because the
snapshot result/state/function API did not yet exist:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-snapshot-helper-red_01_Standalone
Result: expected compile failure for missing snapshot API
Evidence: Saved/StandaloneTests/
          typed-semantic-snapshot-helper-red_01_Standalone/
          20260815_020731_092_1dbbca1d/Summary.json
```

The helper implementation then passed the official complete Standalone scope:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-snapshot-helper-green_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.29 s
Package: PASS in 42.84 s
Total test time: 49.49 s
Evidence: Saved/StandaloneTests/
          typed-semantic-snapshot-helper-green_01_Standalone/
          20260815_020914_352_6c800e36/Summary.json
```

The same helper is now consumed by the native UE compiler fixture: two
independent test-owned Engines compare text/JSON, while a corrupted HIR copy
must preserve `DanglingExpressionId` and produce no normalized success output.
Standalone Architecture also scans the fork-private helper after removing
comment-only lines and rejects StaticJIT, TypedASTJIT, BytecodeJIT, Provider,
UObject, `FAngelscriptEngine`, Engine/module/context construction and file I/O
spellings:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-snapshot-architecture-green_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.03 s
Architecture: PASS in 0.38 s
Package: PASS in 40.15 s
Total test time: 42.75 s
Evidence: Saved/StandaloneTests/
          typed-semantic-snapshot-architecture-green_01_Standalone/
          20260815_021124_842_41f40464/Summary.json
```

Task 1.10 remains unchecked until the new native UE consumer receives a fresh
modular build and focused/full Compiler-prefix verification. That gate is not
repeated while the unrelated SigilProject UnrealEditor PID 44576 and
LiveCodingConsole PID 101880 still hold the shared UE 5.8 Live Coding build
lock. Task 1.11's stale/malicious file non-readback matrix also remains
separate and open.

### Task 2.5 incremental checkpoint: reference and implicit-handle markers GREEN

The compiler-side provisional HIR builder now emits typed unsupported markers
when a declared parameter or local symbol has an exact `asCDataType` carrying
the reference or object-handle bit. Each marker is deliberately non-executable:
it owns no expression operands, retains the exact source-symbol type and span,
and points back to that symbol so eligibility and diagnostics can identify the
specific declaration that requires fallback. A type that is both a reference
and a handle retains both facts as separate stable marker categories.

The verifier rejects a Reference/Handle marker with executable operands, a
missing/dangling source symbol, a type different from that symbol, or a type
whose expected reference/handle bit is absent. The normalized dump includes
the category and source symbol, for example
`unsupported=Reference symbol=S0 operands=[]` and
`unsupported=Handle symbol=S0 operands=[]`.

The first attempted source fixture used upstream explicit-handle spelling
`UnsupportedTarget@ Target`. It failed at the parser with an unrecognized `@`
token and is not counted as the feature RED. This maintained fork
intentionally disables explicit handle tokens and uses implicit-handle syntax;
the corrected valid source is `UnsupportedTarget Target`. This compatibility
finding is retained here so later HIR fixtures do not accidentally test an
unsupported upstream-only syntax form.

With valid fork syntax, the formal RED compiled the real reference and handle
functions and passed the other nineteen Standalone tests. Only the four new
marker/dump assertions failed because the compiler had not emitted those
categories:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-reference-handle-marker-red-valid_01_Standalone
Result: 19/20 PASS; TypedSemanticIR failed only the expected missing
        Reference/Handle marker and dump assertions
Evidence: Saved/StandaloneTests/
          typed-semantic-reference-handle-marker-red-valid_01_Standalone/
          20260815_022257_681_32ddf55f/Summary.json
```

The first implementation run proved compiler capture and verifier behavior but
found one stale golden substring: the Handle expectation omitted the new
`symbol=S0` field. Correcting only that test oracle produced the final official
GREEN:

```text
Runner: Tools/RunTestSuite.ps1 -Suite Standalone
Label:  typed-semantic-reference-handle-marker-green-final_01_Standalone
Result: 20/20 PASS
TypedSemanticIR: PASS in 0.29 s
Package: PASS in 43.21 s
Total test time: 46.17 s
Evidence: Saved/StandaloneTests/
          typed-semantic-reference-handle-marker-green-final_01_Standalone/
          20260815_022703_411_739e411c/Summary.json
```

Task 2.5 remains open because object/property access, containers,
construction/lifetime, lambdas, managed cleanup, suspend points and compiler
exception regions still need their own authoritative capture seams and
RED/GREEN coverage. The UE-side compiler consumer and modular build also remain
pending: after the user reported closing SigilProject, PID 44576 still exposed
the live `SigilProject - Unreal Editor` main window and PID 101880 remained a
responding LiveCodingConsole process, so the unrelated shared UE 5.8 Live
Coding lock had not actually been released at this checkpoint.

### Tasks 5.3a / 5.7 / 5.9 checkpoint: official UE RED admitted

The SigilProject UnrealEditor and LiveCodingConsole later exited, releasing
the shared UE 5.8 Live Coding lock. The first official runner attempt from the
physical isolated-worktree path reached UHT/UBT but failed before compilation
because several generated action paths exceeded the Windows 260-character
limit (one observed path was 265 characters). This is a workspace-path issue,
not a Typed AOT feature failure. The isolated checkout already has the scoped
`V:` SUBST alias, so `AgentConfig.ini` now intentionally selects
`V:\AngelscriptProject.uproject` and every UE runner for this worktree is
invoked from `V:\`; root containment and short-path action generation then
agree.

The short-path official build was admitted with no Engine wait, completed UHT
(`5812` functions analyzed, `11` files generated), and ran the modular compile
through action `190/196`. It failed only on the two deliberately prewritten
feature seams:

```text
Runner: Tools/RunBuild.ps1 -NoXGE -ExtraArgs -NoHotReloadFromIDE
Label:  typed-semantic-reference-handle-ue-green-shortpath
Result: expected RED; UBT exit 6 / runner exit 1; 200.584 s
Evidence: Saved/Build/
          typed-semantic-reference-handle-ue-green-shortpath/
          20260815_023058_644_497a5706/

Typed emission model missing:
  bRequiresExecutionState, Direct/Bridge route, call-site symbol,
  canonical declaration, registered target, stable key, expected ABI,
  reference-slot index

Generation snapshot missing:
  NativeCallInventory broad installed-Bind carrier
```

No Live Coding, long-path, unrelated compile, link or test-source failure was
present in this formal RED. Production work now adds the explicit call route
and transitive execution-state signature, plus a generation-only immutable
inventory joined from current Engine Bind provenance/native-form/descriptor
and scalar-ABI facts. The user's authorization to close a future competing
editor is scoped to a verified `UnrealEditor`/`LiveCodingConsole` process that
actually owns this UE 5.8/project build lock; unrelated processes remain out of
scope.

The first implementation compile exposed one mechanical placement mistake:
the provider-source normalizer had landed inside
`FAngelscriptBoundFunction::ExternalNativeCall`. MSVC rejected the resulting
block-scope function; moving the unchanged helper to the file namespace was
the only production fix. The next official incremental build completed all
compile/link actions:

```text
Runner: Tools/RunBuild.ps1 -NoXGE -ExtraArgs -NoHotReloadFromIDE
Label:  typed-aot-native-carrier-green-02
Result: PASS; 13/13 actions; 12.409 s
Evidence: Saved/Build/typed-aot-native-carrier-green-02/
          20260815_024632_560_b5135f23/
```

The first generated-output execution run then found a test-fixture defect:
the test passed ordinary text to `FBlake3Hash(FWideStringView)`, whose contract
is a 64-character hexadecimal digest. That run asserted before reaching the
emitter and is not a production failure. The fixture now hashes its source
text with `FBlake3::HashBuffer`; a four-action rebuild passed, followed by the
focused GREEN:

```text
Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Label:  typed-aot-emission-green-02
Result: 10/10 PASS
Evidence: Saved/Tests/typed-aot-emission-green-02/
          20260815_024853_018_ccaf9a41/
```

The initial full GenerationEngine run was 19/20. All broad-inventory checks
passed; the lone assertion selected the first declaration containing
`Print(`, which also matched the unrelated method name
`SetParameters_Blueprint(`. Tightening only that fixture predicate to the
canonical global prefix `void Print(` produced the focused GREEN:

```text
Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine.
        FAngelscriptStaticJITGenerationEngineTests.
        GenerationNativeCallInventoryOwnsCompleteBindProvenance
Label:  typed-aot-native-inventory-green-02
Result: 1/1 PASS
Evidence: Saved/Tests/typed-aot-native-inventory-green-02/
          20260815_025250_173_f4127aaf/
```

The immutable snapshot now contains exactly one row per installed Bind
provenance record, deterministic normalized source metadata, explicit absence
for optional native/descriptor/scalar-ABI facts, and no raw function/UObject
pointer. Binding source strings are copied only while a
`StaticJITGeneration` Engine is active; ordinary Engines do not allocate that
per-function payload. The generated bridge contract now has an explicit route,
named call-site row metadata, stable key, expected ABI and reference slot, and
threads `FScriptExecution&` only through bodies whose closure contains a
bridge. Tasks 5.3a, 5.7 and 5.9 remain open until production native-form views,
the exported `InvokeBoundViaVM` implementation, slot adoption, runtime
marshalling/error tests, rebind/unbind and cross-DLL generated execution are
complete.

### Typed native-call VM bridge RED (2026-08-15)

Before adding the Runtime bridge, the focused CQTest product was written for
the current-Engine resolved-slot contract. It covers exact scalar argument and
result marshalling, mixed `double`/`float`/small-integer/boolean ABI kinds,
diagnostic strings that cannot redirect dispatch, missing/out-of-range/
wrong-kind/wrong-Engine slots that fail before calling native code, and a
nested generic-system-function exception that must not publish its return
storage. The official runner admitted the intended compile RED:

```text
Runner: Tools/RunBuild.ps1 -NoXGE -ExtraArgs -NoHotReloadFromIDE
Label:  typed-aot-native-bridge-red
Result: expected RED; UBT exit 6 / runner exit 1; 6.9 s
Evidence: Saved/Build/typed-aot-native-bridge-red/
          20260815_030019_659_1e8d141a/
Failure: StaticJIT/TypedASTJIT/AngelscriptTypedASTJITCallBridge.h
         does not exist
```

No Editor, LiveCodingConsole or UBT process held the UE 5.8 build lock during
this run. Rider's unrelated ReSharper `dotnet` worker was left running. The
production step now adds one exported, non-template `InvokeBoundViaVM` core
plus header-only scalar pack/unpack templates. Only the pre-adopted numeric
reference slot is executable identity; readable declarations, provider target
names, stable key and expected ABI remain metadata, with key/ABI already
enforced when the immutable reference table is built.

The first GREEN compile regrouped Runtime unity shards because the bridge
added a new `.cpp`. That exposed a pre-existing non-self-contained include in
`AngelscriptTypedASTJITEligibility.cpp`: it dereferenced `asCTypeInfo` while
including only `as_scriptfunction.h`, so its old shard happened to supply the
definition from another translation unit. The bridge and new test objects
compiled; only Eligibility failed. The narrow correction is an explicit
`source/as_typeinfo.h` include in the file that uses the type, after which the
same official build is rerun.

That rebuild passed 5/5 incremental actions. The first five-test execution
then produced one genuine GREEN (`missing/wrong-kind/wrong-Engine` fail-closed)
and four fixture failures. Three CDECL registrations omitted this fork's
required `ASAutoCaller::FunctionCaller`, so execution correctly rejected the
unbound native calling convention; the mixed-scalar registration failed for
the same reason. The nested exception reached the required bridge result and
flag, but its expected VM error log had not been suppressed for Automation.
The test fix supplies the maintained-fork caller descriptors and wraps only
the intentional exception invocation in the existing scoped exception-log
suppression. No production bridge behavior changed from this evidence.

After that fix the prefix reached 4/5 GREEN. The remaining registration
diagnostic was exact and expected for this fork's manual binding policy:
`float` is intentionally rejected as ambiguous and must be declared as
`float32` or `float64`. The fixture now uses `float32` for C++ `float` and
`float64` for C++ `double`, which also makes the scalar ABI assertion explicit;
no generic fallback and no production relaxation were introduced.

The corrected focused bridge prefix then passed 5/5. A separate-module test
was added next before its consumer seam: `AngelscriptTest` calls an exported
probe whose `InvokeBound<int32,int32,int32>` template instantiation must live
in `AngelscriptTestJIT.dll` and import the fixed non-template core from
`AngelscriptRuntime.dll`. The official cross-DLL RED failed only because
`ExecuteTypedASTNativeBridge` did not yet exist (`C2039/C3861`), proving the
new assertion was admitted before the TestJIT consumer implementation:

```text
Label:  typed-aot-native-bridge-cross-dll-red
Result: expected RED; UBT exit 6 / runner exit 1; 6.8 s
Evidence: Saved/Build/typed-aot-native-bridge-cross-dll-red/
          20260815_031348_325_c1d77aa8/
```

The TestJIT consumer was then implemented as a narrow exported probe. The
template pack/unpack code is instantiated in `AngelscriptTestJIT.dll`, while
the fixed bridge core remains exported by `AngelscriptRuntime.dll`; no private
system-function address crosses the DLL boundary. The affected build linked
both DLLs and all generated TypedASTJIT probe sources:

```text
Runner: Tools/RunBuild.ps1 -NoXGE -ExtraArgs -NoHotReloadFromIDE
Label:  typed-aot-native-bridge-cross-dll-green
Result: PASS; 11/11 actions
Evidence: Saved/Build/typed-aot-native-bridge-cross-dll-green/
          20260815_031421_830_33c1bc19/
```

The final focused execution added the cross-DLL assertion to the five Runtime
bridge cases and passed all six:

```text
Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.StaticJIT.NativeBridge.TypedASTJIT
Label:  typed-aot-native-bridge-cross-dll-green
Result: 6/6 PASS; 0 failed; 0 skipped
Evidence: Saved/Tests/typed-aot-native-bridge-cross-dll-green/
          20260815_031444_734_5640c720/
```

This closes the scalar bridge core and its independent-DLL import proof, but
does not by itself close task 5.9: actual generated-provider execution,
immutable-table adoption/rebind/unbind coverage, first-exception metadata and
the inspection dump remain to be implemented and verified.

The affected emitter/route regression was rerun immediately after the bridge
landed so the new Runtime header and TestJIT import could not silently change
the generated C++ contract:

```text
Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
Label:  typed-aot-native-bridge-emission-regression
Result: 10/10 PASS; 0 failed; 0 skipped
Evidence: Saved/Tests/typed-aot-native-bridge-emission-regression/
          20260815_031744_021_d3b97129/
```

### Actual generated provider-private bridge RED (2026-08-15)

The next TDD slice adds a real scalar provider-private application function to
the fixed AOT fixture and a reflected script root which calls it. Runtime
Engines register only the callable; the explicit provider-private descriptor
is retained only by the `StaticJITGeneration` Engine, matching production's
generation-only native-form inventory boundary. The new execution assertion
requires a generated Native route, a non-empty adopted reference table, the
expected scalar result and exactly one call to the private target.

The test/fixture build passed before any backend bridge-emission change:

```text
Runner: Tools/RunBuild.ps1 -NoXGE -ExtraArgs -NoHotReloadFromIDE
Label:  typed-aot-generated-private-bridge-red-02
Result: PASS; 4/4 actions
Evidence: Saved/Build/typed-aot-generated-private-bridge-red-02/
          20260815_032512_455_de31c408/
```

The initial runtime attempt exposed and corrected a fixture-only mistake: an
ordinary Runtime Engine intentionally declines generation-only descriptor
attachment. The corrected formal RED then reached Provider routing and failed
for the intended reason: the committed Provider had no exact generated Native
entry for `TypedASTPrivateBridgeShowcase`, so the route remained VM.

```text
Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.StaticJIT.AOT.
        FAngelscriptStaticJITAotTests.
        TypedASTProviderPrivateCallUsesCurrentEngineReferenceSlot
Label:  typed-aot-generated-private-bridge-red-03
Result: expected RED; 0/1 PASS
Failure: expected the bridge root to select generated Native code
Evidence: Saved/Tests/typed-aot-generated-private-bridge-red-03/
          20260815_032708_115_72ff0089/
```

The run also reproduced the already-recorded fixture performance gap: source
compile/class propagation completed at `19:27:50`, while Cache V2 compile
capture began at `19:28:26`. This slice does not disguise that independent
36-second initialization cost as bridge execution time.

The first production compile then found one local implementation typo: the
new readable call-site symbol helper lives in the backend's private namespace,
but its call site was initially unqualified. The failed build reached 12/17
actions and reported only `BuildBridgeCallSiteSymbol` lookup at the new line;
the fix is the explicit private-namespace qualification, with no contract or
runtime behavior change.

```text
Label:  typed-aot-generated-private-bridge-production-01
Result: compile RED; UBT exit 6 / runner exit 1
Evidence: Saved/Build/typed-aot-generated-private-bridge-production-01/
          20260815_033039_870_495039d7/
```

The qualification-only correction then produced a clean affected build, and a
second diagnostic-only build kept the new generation failure detail wired into
the commandlet without changing the provider contract:

```text
Label:  typed-aot-generated-private-bridge-production-02
Result: PASS; 6/6 actions
Evidence: Saved/Build/typed-aot-generated-private-bridge-production-02/
          20260815_033145_358_0434fc00/

Label:  typed-aot-bridge-fallback-diagnostic
Result: PASS; 4/4 actions
Evidence: Saved/Build/typed-aot-bridge-fallback-diagnostic/
          20260815_033400_775_1e2c4d74/
```

### Short-circuit semantic-capture gap and diagnostic (2026-08-15)

Before each validation run, the relevant UE processes were inspected by exact
executable and command line. No `V:\` UE 5.8 editor or Live Coding holder was
present. The only process found belonged to the independent `R:\` AngelScript
SDK TypeSystem test, so it was intentionally left running; it did not hold the
current worktree's build lock.

The first provider regeneration failed closed with `typed-ast:
MissingTypedHIR`. To make this class of failure inspectable instead of guessing
from the final backend reason, compiler-owned script-function data now retains
the deterministic semantic-capture diagnostic. The generation fixture includes
that text in its error. The resulting commandlet evidence identified the exact
source span and verifier rule:

```text
Label: typed-aot-generated-private-bridge-hir-span
Result: expected diagnostic RED
Detail: ASStaticJITAotFixture.as:35:6, statement=9,
        Local initializer is outside the expression arena
Evidence: Saved/Commandlet/typed-aot-generated-private-bridge-hir-span/
          20260815_034558_382_db84fadc/
```

The source at that span was `bool bMutationGate = bEnabled && (++Value > B);`.
The maintained compiler emitted correct bytecode for `&&` and `||`, and the
Typed HIR model/analyzer/emitter already supported `ShortCircuit`, but
`CompileBooleanOperator()` never published its result as a semantic expression.
Consequently the local initializer received an invalid expression ID and the
verifier correctly rejected the incomplete graph.

The compiler fix constructs a `ShortCircuit` expression for `&&`/`||` (and a
normal binary expression for `^^`) after bytecode compilation. A compiler-level
regression compiles capture-enabled `&&` and `||` initializers and requires a
verified function containing exactly two short-circuit nodes. The affected
build and exact automation test are green:

```text
Label:  typed-aot-short-circuit-green
Result: build PASS; 7/7 actions
Evidence: Saved/Build/typed-aot-short-circuit-green/
          20260815_034838_184_825a301c/

Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR.
        FTypedSemanticIRTests.ShortCircuitInitializerPublishesVerifiedHIR
Label:  typed-semantic-short-circuit-green
Result: 1/1 PASS; 0 failed; 0 skipped
Evidence: Saved/Tests/typed-semantic-short-circuit-green/
          20260815_035023_111_e8a23910/
```

The automation process took about 44 seconds end to end, of which about 37
seconds was UE commandlet/editor initialization; the focused test body completed
within one automation frame. Provider regeneration and generated-runtime
execution remain the next proof and are not claimed complete here.

### Scalar mutation/unary/shift capture and eligibility follow-up (2026-08-15)

Rerunning provider generation after the short-circuit fix exposed a second
frontend gap in the same showcase rather than a provider/runtime failure. A
minimal `Enabled && (++Value > Limit)` compiler regression passed, while the
complete ordered mutation sequence failed verification. The exact RED and the
subsequent bounded expression-arena diagnostic were:

```text
Label:  typed-semantic-mutation-sequence-red
Result: expected RED; local initializer outside expression arena
Evidence: Saved/Tests/typed-semantic-mutation-sequence-red/
          20260815_035542_778_ff8b0bc9/

Label:  typed-semantic-unary-tail16-diagnostic
Result: expected diagnostic RED
Detail: deterministic last-16 expression tail identified captured unary -/~
        followed by a missing shift expression
Evidence: Saved/Tests/typed-semantic-unary-tail16-diagnostic/
          20260815_040258_993_38ded559/
```

The maintained compiler now publishes primitive unary expressions and
bitwise/shift binary expressions into Typed HIR. Compound assignments retain
their single authoritative mutation node: the lowered intermediate operator
is deliberately suppressed while mutation lowering is active. The verifier
validates unary arity/token shape, and its failure diagnostic retains a bounded,
pointer-free tail (`expressionArena=<count> tail=[E#:k#:op=...@row:col]`) so a
future incomplete initializer can be localized without dumping the whole IR.
The compiler regression now covers direct/compound/prefix/postfix mutations,
unary minus/bitwise-not, shifts, and short-circuit initializers in one real
source function.

```text
Label:  typed-semantic-unary-shift-green
Result: build PASS; 4/4 actions
Evidence: Saved/Build/typed-semantic-unary-shift-green/
          20260815_040430_405_32544d65/

Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR.
        FTypedSemanticIRTests.ShortCircuitInitializerPublishesVerifiedHIR
Label:  typed-semantic-unary-shift-green
Result: 1/1 PASS; 0 failed; 0 skipped
Evidence: Saved/Tests/typed-semantic-unary-shift-green/
          20260815_040445_194_4a912b85/
```

Provider generation then reached the next independent layer. `HIRCapture=[]`
proved the complete compiler-owned graph was valid, but eligibility rejected
the ordinary `Value = Value - 1` expression at the fixture's line 26:

```text
Label:  typed-aot-generated-private-bridge-generate-green-02
Result: expected pipeline RED after HIR became valid
Detail: UnsupportedExpression: Expression kind is outside the first scalar
        profile, ASStaticJITAotFixture.as:26:8
Evidence: Saved/Commandlet/
          typed-aot-generated-private-bridge-generate-green-02/
          20260815_040534_911_d5bab3a0/
```

Root cause is an obsolete first-profile whitelist in
`AngelscriptTypedASTJITEligibility.cpp`: it predates the already-tested analyzer
and emitter support for conversions, scalar assignments/mutations, unary
operators, short-circuit expressions, call-closure-resolved native calls, and
expression statements. Eligibility is being aligned with those expression
categories while the analyzer remains the typed/operator-level authority and
unknown/unsupported categories continue to fail closed. Generated Provider
success, DLL link, and runtime execution are still pending and are not claimed
by this checkpoint.

### Production eligibility, mixed-backend module guards, and private-provider dependency truth (2026-08-15)

The obsolete eligibility whitelist was aligned with the already-reviewed
scalar HIR surface. It now admits conversions, assignments/mutations, unary
operators, binary operators, short-circuit expressions, expression statements,
and closure-reviewed resolved calls. A resolved call is still rejected as a
standalone root, and unknown/unsupported kinds remain fail-closed. The focused
Runtime/TestJIT build passed:

```text
Label:  typed-aot-eligibility-capabilities-green
Result: build PASS; 4/4 actions
Evidence: Saved/Build/typed-aot-eligibility-capabilities-green/
          20260815_040940_899_af9f5649/
```

The next generation attempt correctly rejected the direct
`IsRunningCommandlet()` descriptor because the fixture had supplied no frozen
native-module dependency truth. The generation fixture was updated to mirror
the actual public dependencies of `AngelscriptTestJIT` (`Core`, `CoreUObject`,
and `AngelscriptRuntime`). The build and next generation were green, and the
capability showcase emitted a Typed AOT body containing a direct
`IsRunningCommandlet()` call without `FAngelscriptJITExecutionContext`:

```text
Label:  typed-aot-generated-private-bridge-generate-green-03
Result: expected RED; UnknownOwningModule: Core
Evidence: Saved/Commandlet/typed-aot-generated-private-bridge-generate-green-03/
          20260815_041019_403_61c8a7df/

Label:  typed-aot-testjit-dependency-truth-green
Result: build PASS; 4/4 actions
Evidence: Saved/Build/typed-aot-testjit-dependency-truth-green/
          20260815_041205_389_26f55247/

Label:  typed-aot-generated-private-bridge-generate-green-04
Result: commandlet PASS
Evidence: Saved/Commandlet/typed-aot-generated-private-bridge-generate-green-04/
          20260815_041228_438_e5e8833d/
```

Auditing the generated source then found that the private-provider showcase
was still emitted by the BytecodeJIT fallback. The old runtime assertion only
proved that some JIT entry executed, so the commandlet now requires the exact
private-bridge root to report the `TypedAST` backend and requires the generated
source to contain its `_TypedBody` plus `AngelscriptTypedASTJIT::InvokeBound<`,
while forbidding `FAngelscriptJITExecutionContext`. This permanent gate turned
the former false green into an actionable failure.

The first build of the freshly generated mixed TypedAST/Bytecode modules also
exposed an independent aggregation bug: both backends supplied the same
`#ifndef AS_SKIP_JITTED_CODE` preamble/footer, the generator retained both
opens because their include blocks differed, but deduplicated the identical
`#endif` footers. `AppendFragment` now merges exact lines contributed by earlier
backends, retaining backend-specific includes but sharing one module-level
guard/footer. A mixed-backend regression proves one shared guard, both includes,
and a balanced target-profile guard:

```text
Label:  typed-aot-private-provider-gate-red-build
Result: expected generated-C++ RED; unmatched #if/#endif in both AS modules
Evidence: Saved/Build/typed-aot-private-provider-gate-red-build/
          20260815_041500_733_61a10655/

Label:  typed-aot-mixed-backend-preamble-green
Result: build PASS; 17/17 actions
Evidence: Saved/Build/typed-aot-mixed-backend-preamble-green/
          20260815_041743_930_4c8d02e0/

Label:  typed-aot-mixed-backend-preamble-focused-green
Result: 1/1 PASS
Evidence: Saved/Tests/typed-aot-mixed-backend-preamble-focused-green/
          20260815_041821_812_c16bebd4/
```

The strict private-provider gate then reported the exact remaining issue:
`AngelscriptTest` was absent from the known native-module set. This module owns
the registered unexported function, but generated code must not link it; the
call goes through a Runtime-owned current binding slot. The fixture therefore
now distinguishes the two truths: `AngelscriptTest` is a known provider module,
while only `Core`, `CoreUObject`, and `AngelscriptRuntime` are public consumer
dependencies. This preserves unknown-module rejection and does not turn the
private provider into a direct DLL dependency.

```text
Label:  typed-aot-private-provider-selection-red
Result: expected strict-gate RED
Detail: UnknownOwningModule: AngelscriptTest is not in the frozen generation
        module set; BytecodeJIT fallback selected
Evidence: Saved/Commandlet/typed-aot-private-provider-selection-red/
          20260815_041910_674_f39de534/
```

Regeneration, generated-source inspection, generated DLL build, and exact
runtime execution remain pending at this checkpoint.

The known-provider/public-dependency split closed that checkpoint. Fresh
generation selected the TypedAST backend for the private bridge and passed the
strict source gate. Both generated AS module translation units contain exactly
one shared `AS_SKIP_JITTED_CODE` guard and have balanced conditional directives.
The private body contains an immutable call-site record with the authoritative
AS declaration, registered C++ target spelling, stable function key, expected
ABI, and reference slot, followed by the typed scalar invocation:

```cpp
const int32 Result = AngelscriptTypedASTJIT::InvokeBound<
    int32, int32, int32>(Execution, CallSite, Left, Right);
```

No `FAngelscriptJITExecutionContext` occurs in the generated fixture module.
The generated TestJIT DLL then compiled and linked, and the exact Runtime test
executed the AS function through the current Engine reference table. It proved
the expected result and exactly one invocation of the unexported C++ provider:

```text
Label:  typed-aot-private-provider-known-module-green
Result: build PASS; 4/4 actions
Evidence: Saved/Build/typed-aot-private-provider-known-module-green/
          20260815_042144_225_102f8690/

Label:  typed-aot-private-provider-selection-green
Result: commandlet PASS; strict TypedAST/source gate satisfied
Evidence: Saved/Commandlet/typed-aot-private-provider-selection-green/
          20260815_042204_302_d4dc85ae/

Label:  typed-aot-private-provider-generated-dll-green
Result: build PASS; 6/6 actions
Evidence: Saved/Build/typed-aot-private-provider-generated-dll-green/
          20260815_042312_786_f2083411/

Runner: Tools/RunTests.ps1
Prefix: Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.
        TypedASTProviderPrivateCallUsesCurrentEngineReferenceSlot
Label:  typed-aot-private-provider-runtime-green
Result: 1/1 PASS
Evidence: Saved/Tests/typed-aot-private-provider-runtime-green/
          20260815_042353_596_4cfc2cb0/
```

This run also reproduces the independent startup-performance symptom already
under investigation: `post full reload` completed at `20:24:36.421`, while the
CacheV2 compile-capture batch was logged at `20:25:11.341`, a gap of about
34.9 seconds. Provider reference resolution after capture took about 673 ms,
and the test body completed immediately. The gap is not attributed to TypedAST
emission or the binding-slot call; its owner must be established from the
CacheV2/test-engine scheduling path before changing behavior.

### CacheV2 post-compile pause root cause and fix (2026-08-15)

The pause was localized inside module-artifact capture, not ClassGenerator,
TypedAST emission, or Provider routing. The exact baseline split was
`authority=0.066ms`, `module_artifacts=34632.832ms`, with
`ASStaticJITAotFixture=34583.591ms`. The resolver rebuilt the complete current
UE/AS environment surface for every stable-key request, so one global scan was
multiplied by the fixture's function/dependency count.

The production resolver now builds a sorted, ambiguity-preserving environment
index lazily on the first query. One instance is shared by all modules and both
function-input resolution and final graph validation in a compile transaction.
The batch log exposes `environment_index=[builds=...,symbols=...]`; the final
two-module run reported exactly one build for 135,223 symbols.

```text
RED build: Saved/Build/cachev2-environment-resolver-index-api-red/
           20260815_043607_263_d000102c/
RED test:  Saved/Tests/cachev2-environment-resolver-lazy-red/
           20260815_044216_714_2a8f6729/
Build:     Saved/Build/cachev2-environment-resolver-transaction-share-green-02/
           20260815_044740_033_ae6745e8/ (PASS)
Test:      Saved/Tests/cachev2-environment-resolver-lazy-green/
           20260815_044800_251_a708f4bf/ (1/1 PASS)
Perf/test: Saved/Tests/cachev2-environment-resolver-transaction-performance-green/
           20260815_044839_587_0a0a1322/ (1/1 PASS)
```

The Typed AOT fixture module-artifact time fell from `34632.832ms` to
`858.399ms` (97.5% reduction). The ordinary editor startup batch fell from
`13889.603ms` to `1320.820ms` (90.5% reduction). StaticJIT generation continues
to use the function-facts-only seam—no Cache records, packs, manifest, or Cache
lifecycle publication—but shares the one-time index because stable UE/native
binding identities remain required. Full analysis and exact logs are recorded
in `performance/cachev2-environment-symbol-resolution.md`.

Focused follow-up verification kept both the complete environment-identity
surface and the unexported C++ binding bridge green:

```text
Saved/Tests/cachev2-environment-identity-regression-green/
  20260815_045018_309_4145327b/                 8/8 PASS
Saved/Tests/typed-aot-private-provider-after-cache-index-green/
  20260815_045111_128_b7fec5b6/                 1/1 PASS
```

The latter repeated the one-index diagnostic
`environment_index=[builds=1,symbols=135223]` and executed the generated
private-provider call through the current Engine reference slot.

### `Print` stable Runtime DLL callable (2026-08-15)

The first non-scalar Bind export now has a narrow public Runtime declaration:

```cpp
ANGELSCRIPTRUNTIME_API void
AngelscriptStaticJITNativeCallables::Print(
    const FString& Text,
    float Duration,
    FLinearColor Color);
```

The implementation itself moved from the private
`FAngelscriptLoggingBinds::Print` member to this exported free function, and
`Bind_Logging.cpp` registers that exact address. This is not a forwarding thunk:
VM/system-function dispatch and a future generated direct call share one
implementation and one DLL symbol. The remainder of
`FAngelscriptLoggingBinds` stays private.

The TDD product is compiled in the separate `AngelscriptTest` consumer module.
It imports the public callable address, creates a normally bound isolated
Engine, locates the installed global `Print`, and compares the registered
`asSSystemFunctionInterface::func` with the imported address. The initial build
failed only because the public header did not yet exist; the implementation
build and exact address test are green:

```text
RED:   Saved/Build/typed-aot-print-runtime-callable-red/
       20260815_045506_638_0fcf05d4/
Build: Saved/Build/typed-aot-print-runtime-callable-green/
       20260815_045538_065_89ab7f0f/             PASS
Test:  Saved/Tests/typed-aot-print-runtime-callable-green/
       20260815_045557_798_c208bdfb/             1/1 PASS
```

This closes the exported callable ownership in task 5.5, not the complete
non-scalar Typed AOT lowering. `Print` remains fail-closed for TypedASTJIT until
`FString`/`FLinearColor` materialization, default arguments,
`CompileOutIfNoLog`, WorldContext, and success/exception cleanup are all
represented and verified. Descriptor attachment and generated cross-DLL
execution remain tasks 5.6/5.12.

### Exact installed-call descriptor and `Print` attachment (2026-08-15)

The native-call contract now separates “this is the exact callable installed
in this Engine” from “the current TypedAST emitter knows how to materialize its
values.” `FAngelscriptStaticJITNativeABIIdentity` fingerprints the registered
call convention, parameter/return layout, traits, defaults, compile-out rules,
hidden arguments and related call metadata. Descriptor attachment rejects a
missing or mismatched identity instead of accepting a symbol or AS declaration
by name. Scalar direct/bridge paths additionally require the existing scalar
ABI. Managed-value descriptors use `ManagedValuesDeferred` and return the
typed validation result `TypedABIUnavailable` while remaining valid inventory
metadata.

`Print` now attaches an `ExportedRuntimeCallable` descriptor to the exact
`FAngelscriptBoundFunction` after `.CompileOutIfNoLog().WorldContext()` has
finished configuring it. The descriptor records:

- public symbol/header/module/API and C++ signature;
- exact current installed-call identity;
- two caller-materialized defaults;
- `IfNoLog` compile-out and `RuntimeCurrentWorld` WorldContext policies;
- no script exception, borrowed `FString` input and by-value object arguments.

It deliberately has no scalar ABI. The generation snapshot therefore retains
`Print` in the complete native-call inventory but excludes it from the scalar
direct-call target set. This is a real, inspectable intermediate state: the DLL
contract is proven, while unsafe `FString`/`FLinearColor` lowering remains
closed.

The first focused test attempt used a normal Runtime Engine and correctly saw
no descriptor inventory because ordinary Engines do not pay the generation-
only metadata cost. The test was corrected to use
`StaticJITGeneration` with `bCollectStaticJITCompatibilityBinds=true`; product
behavior was not broadened. A separate existing CallClosure fixture also used
an `int` as a synthetic implicit receiver; the exact receiver verifier correctly
reported `InvalidEffectiveReceiver`, so only that stale expected diagnostic was
updated.

```text
RED build: Saved/Build/typed-aot-print-descriptor-red/
           20260815_050343_208_00985168/                    expected compile failure
Build:     Saved/Build/typed-aot-print-descriptor-green-03/
           20260815_051326_354_3e8d88c8/                    PASS
Linkage:   Saved/Tests/typed-aot-print-descriptor-green-03/
           20260815_051348_696_e3cfe83b/                    5/5 PASS
Closure:   Saved/Tests/typed-aot-native-abi-call-closure-green-02/
           20260815_051805_780_fd7b50df/                    10/10 PASS
Inventory: Saved/Tests/typed-aot-print-inventory-green/
           20260815_051929_016_a709b6a6/                    1/1 PASS
Bridge:    Saved/Tests/typed-aot-native-abi-private-bridge-green/
           20260815_052009_980_af5db92f/                    1/1 PASS
```

The last private-bridge regression retained the CacheV2 improvement:
`module_artifacts=838.351ms`, one environment-index build and 135,223 symbols.

The source inventory scanner initially remained at one descriptor because it
only recognized the older `AttachReviewed*` helper convention. That RED audit
was accurate evidence of a tooling gap, not a Runtime regression. Schema v12
now recognizes direct `BoundFunction.ExternalNativeCall(Descriptor)`
attachments, associates a simple descriptor variable with the concrete bound
function, and extracts its linkage/symbol/include/module fields while ignoring
generic helper parameters. The refreshed source evidence is:

```text
Runtime .cpp files:                 396
Registration callsites:            2920
External descriptor callsites:     2
External descriptor attachments:   2
Reviewed-helper attachments:       1
Direct attachment:                 PrintFunction -> PrintDescriptor
                                   ExportedRuntimeCallable
```

The two source rows are `IsRunningCommandlet` and `Print`. This does not mark
task 5.6 complete: the source CSV is discovery evidence only, and all 2,920
installed callables still require the authoritative Engine join and a final
direct/exported-callable/inline/bridge/compile-out/unsupported disposition.

### Generated `Print` cross-DLL execution and Provider identity fallback (2026-08-15)

The generated TypedAST fixture now proves the full consumer-DLL path instead
of stopping at generated text or a successful link. A CQTest locates the real
`TypedASTPrintShowcase` function in the ordinary isolated AOT Engine, obtains
its published raw/VM/Parms entries, executes all three, and checks a test-only
atomic observation counter in the exported Runtime `Print` implementation.
The observed counts are `1`, `2`, and `3`, proving every generated adapter
calls the same `AngelscriptRuntime` DLL symbol rather than a local stub, VM
fallback, or generic execution-context dispatcher. Failure diagnostics now
print the stable key, execution/debug identity, selected route, match result,
and Provider candidates before returning safely.

TDD first proved the cross-module contract: the RED `AngelscriptTest.dll` link
failed only because the Runtime observation exports did not yet exist. The
minimal implementation added `ResetPrintCallCountForTesting` and
`GetPrintCallCountForTesting` under `WITH_ANGELSCRIPT_UNITTESTS`; production
builds retain only the real exported `Print` callable.

```text
RED link: Saved/Build/typed-aot-print-execution-red/
          20260815_060744_657_ef03b1e5/
Build:    Saved/Build/typed-aot-print-execution-green/
          20260815_060822_704_d539bda4/                 PASS
```

The first correctly addressed execution run then produced the intended
functional RED: the function remained on VM with `MissingProviderEntry`. A
Verbose run isolated the cause to the gap between Cache eligibility and Static
Provider identity:

```text
Function int TypedASTPrintShowcase(const FString&in, const float,
const FLinearColor&in) parameter 0 is outside the class-graph stable type table
```

The generated Provider manifest already contained the exact key and hashes,
but full Cache V2 capture skipped the fixture module, so the ordinary Engine
published no verified content identity with which the Provider could match.
Allowing external value types into the restorable Cache graph was rejected:
the Cache contract intentionally accepts a narrower set than function-only JIT
analysis.

An initial broad fallback was also rejected by live evidence. Running the
function-facts serializer for every non-cacheable project module reached an
unsupported complex class graph and crashed in
`asCWriter::FindObjectPropIndex`. That experiment was removed immediately; its
log remains as regression evidence:

```text
Crash: Saved/Tests/typed-aot-print-identity-fallback-green/
       20260815_061813_783_a22dbb79/
```

The production fix snapshots the loaded Provider registry once per compile
transaction, collects its module keys, and performs identity-only capture only
for a failed full-capture module whose stable key is actually requested by a
loaded Provider. These identities feed `RebuildFunctionRouteSnapshot` but are
never appended to `PublicationInput`; Cache publication remains unchanged and
unrelated scripts are not scanned. For the fixture this added about `15.163ms`
and captured 48 stable function identities. Provider routing then saw 50
verified functions, published the exact generated `Print` entry, and the real
three-entry execution test passed:

```text
Build: Saved/Build/typed-aot-provider-filtered-identity-green/
       20260815_062046_947_64f8bf89/                    PASS
Test:  Saved/Tests/typed-aot-provider-filtered-identity-green/
       20260815_062108_949_359b9acf/                    1/1 PASS
```

This closes the `Print` portion of task 5.12 only. Header-inline coverage,
private-target rebind/unbind behavior, the complete Bind inventory, and the
general non-empty cleanup/lifetime matrix remain open.

### Per-call fixture module isolation and three-module regressions (2026-08-15)

The exported `Print` proof has been moved out of the scalar/class fixture into
its own authoritative AS module, `ASStaticJITTypedPrintFixture`. Generation now
materializes the import provider, the primary scalar/class fixture and the
Print fixture independently, and emits one module-owned `.jit.cpp` for each.
The generated Print body contains the exact exported Runtime call
`AngelscriptStaticJITNativeCallables::Print(...)`; the other module sources do
not contain that body.

Adding the third source module exposed two unrelated assumptions that had been
hidden by the previous two-module order:

- `GenerateStaticJITProviderArtifacts` received request modules in explicit
  source-graph order, but the resolved source descriptors were appended in
  generation-snapshot order and later paired by array index. The backend now
  resolves each descriptor by the request module's exact Engine-local module
  pointer before appending it. This preserves authoritative source metadata
  regardless of snapshot ordering.
- three TypedAST implementation files dereferenced `asCTypeInfo` while relying
  on a transitive declaration. Direct `source/as_typeinfo.h` includes now make
  their non-unity compilation boundary self-contained.

The first ordinary Runtime execution then proved a Cache/function-facts
asymmetry: class/root facts already accepted stable environment value types,
but the pure-global function-facts authority remained primitive-only. Full
Cache capture is intentionally unchanged. Only the explicitly function-facts-
only path may now build stable environment value/reference identities, which
lets the Provider match `FString`/`FLinearColor` without persisting the Print
module in Cache V2.

```text
Source-order RED: Saved/StaticJIT/TestJIT/Commandlet/
                  typed-aot-print-module-split-generate/
                  20260815_063445_542_6918d47e/
Build:            Saved/Build/typed-aot-module-descriptor-order-green/
                  20260815_063610_852_89375fdb/              PASS
Generate:         Saved/StaticJIT/TestJIT/Commandlet/
                  typed-aot-print-module-split-generate-green/
                  20260815_063633_646_0982d3ca/              PASS
Include RED:      Saved/Build/typed-aot-print-module-split-generated-build-green/
                  20260815_063729_778_510de2f7/
Generated build:  Saved/Build/typed-aot-print-function-facts-generated-build-green/
                  20260815_064501_954_fba08238/              PASS
Print execution:  Saved/Tests/typed-aot-print-function-facts-runtime-green/
                  20260815_064522_201_0666539b/              1/1 PASS
```

The broader AOT class is currently `13/16 PASS`, not complete. The remaining
RED evidence is architectural fixture coupling, not a generated Print failure:

- `DoubleInt64ConversionsMatchInterpreter` compiles the primary source in a
  plain interpreter Engine, but that source still contains
  `TypedASTPrivateBridgeShowcase` and therefore requires the provider-private
  registration that the test intentionally does not install.
- the scalar-parity test fails even when run alone because its
  `StaticJITGeneration` Engine does not enable compatibility-bind collection;
  the helper registers the callable successfully, then incorrectly treats the
  generation-only descriptor `Attach` rejection as an Engine creation failure.
- the Cache V2 proof compiles three modules while only two are intentionally
  cacheable. Its exact-start source set therefore differs and it restores
  `49/50` Provider entries. A StaticJIT-only non-cacheable call fixture must not
  be included in this Cache proof.

```text
Broad RED:  Saved/Tests/typed-aot-aot-class-print-module-split-green/
            20260815_064608_543_9d484e9a/                   13/16 PASS
Narrow RED: Saved/Tests/typed-aot-scalar-private-bridge-red/
            20260815_065003_710_caed1f94/                    0/1 PASS
```

The next implementation step is to give the provider-private showcase its own
AS module and make fixture composition explicit: generation/runtime linkage
proofs load all four modules, while pure interpreter and Cache V2 proofs load
only the import provider plus primary scalar/class module. This preserves the
strict one-AS-module/one-`.jit.cpp` contract and keeps JIT-only native-call
surfaces out of Cache-specific tests.

That isolation is now implemented. `EStaticJITAotFixtureComposition` makes the
choice explicit instead of inferring it from Engine purpose. `Complete`
materializes/registers all four modules for Provider generation and linkage
execution; `Core` materializes only the two cacheable/interpreter modules. The
Cache restore API rejects a non-Core session with a typed diagnostic, and its
expected restored count is derived from Provider entries whose stable module
keys belong to the two current core modules. It no longer assumes every entry
in a Provider is owned by the Cache proof.

The generated ownership is now:

```text
ASStaticJITAotFixture                  46 emitted functions
ASStaticJITAotImportProvider           2 emitted functions
ASStaticJITTypedPrintFixture           1 emitted function
ASStaticJITTypedPrivateBridgeFixture   1 emitted function
```

The complete generation snapshot retains 53 functions: the 50 emitted/source
functions plus three rebuild-only derived `StaticClass` helpers. The Core-only
snapshot retains 51 functions (49 in the primary module, including those three
helpers, plus two import-provider functions). Tests now name this distinction
instead of comparing a snapshot fact count to an emitted Provider count.

```text
Build:     Saved/Build/typed-aot-private-module-isolation-green/
           20260815_065501_151_d56a5937/                   PASS
Generate:  Saved/StaticJIT/TestJIT/Commandlet/
           typed-aot-private-module-regenerate-green/
           20260815_065534_434_e7a25f5d/                   PASS
Gen build: Saved/Build/typed-aot-private-module-generated-build-green/
           20260815_065608_657_5fca9055/                   PASS
AOT run:   Saved/Tests/typed-aot-private-module-aot-green/
           20260815_065627_211_2b5d6584/                   25/26 PASS
           The former three failures all passed; the sole RED was the stale
           generation-fact count described above.
Count build: Saved/Build/typed-aot-generation-facts-count-green/
             20260815_065823_116_5e9bee4d/                 PASS
Count test:  Saved/Tests/typed-aot-generation-facts-count-green/
             20260815_065842_676_efd3195e/                 1/1 PASS
Verify:      Saved/StaticJIT/TestJIT/Commandlet/
             typed-aot-private-module-verify-green/
             20260815_065929_183_d73dd4f5/                 PASS
```

Together, the AOT evidence covers all 26 affected tests (`25` unchanged-pass
results from the broad run plus a fresh pass for its only failed assertion).
No Unreal Editor or Live Coding process owned the current worktree during these
runs, so no process was terminated.

### Private bridge Engine replacement and AOT unbind RED (2026-08-15)

The provider-private bridge already resolves an immutable current-Engine
function slot and executes it through the maintained VM context, but the AOT
fixture covered only the original registration. The next regression requires
the same generated Provider to be adopted by another Engine that registers the
same canonical AngelScript surface/ABI to a different private C++ callable.
After that AOT Binding is cleared, its old binding context/reference table must
retire and execution must fall back to the ordinary VM body instead of using a
stale generated slot.

The maintained fork cannot honestly model native registration removal through
config groups: `BeginConfigGroup`, `EndConfigGroup`, and `RemoveConfigGroup`
are documented by the existing SDK tests as storage-only/no-op stubs. This
checkpoint therefore does not invent a test-only unregister API. It proves the
supported production boundaries—Engine replacement refresh and Provider
Binding retirement—and keeps true in-place native unregister as an explicit
fork limitation. Imported-function bind/rebind/unbind remains a separate HIR
and routing task (2.16/6.5).

The test was added first and produced the expected compile RED because neither
the replacement registration variant nor its observation API existed:

```text
Build:  Saved/Build/typed-aot-private-rebind-red/
        20260815_070510_010_6297f697/
Result: expected RED; missing ETypedASTPrivateBridgeRegistration::Replacement
        and replacement result/counter APIs
Lock:   no V:\\AngelscriptProject.uproject UnrealEditor/LiveCoding process
        was present, so no process was terminated
```

The narrow implementation introduces two Engine-registration variants with
the same canonical AS declaration and scalar ABI but different private C++
callables. Provider generation remains fixed to `Primary`; only the isolated
runtime session may request `Replacement`. This lets the regression distinguish
current-Engine resolution from accidentally persisted generation-Engine state
without changing or regenerating the checked Provider.

The implementation and verification are GREEN. The replacement Engine
registered a different private C++ function behind the same canonical AS
declaration and ABI. The already-built Provider still produced `50/50` exact
routes and the generated private call returned the replacement sentinel (`242`),
with primary call count `0` and replacement count `1`. Clearing the script
function's JIT Binding retired the old `FAngelscriptJITBindingContext` from the
Runtime registry; a second call had no JIT entry and executed the bytecode/VM
body, incrementing only the replacement registration to `2`. No stale slot was
observable or callable.

```text
Build:      Saved/Build/typed-aot-private-rebind-green/
            20260815_070711_592_aebb93cb/                  PASS
Focused:    Saved/Tests/typed-aot-private-rebind-green/
            20260815_070742_544_6b5f9a13/                  1/1 PASS
Regression: Saved/Tests/typed-aot-private-rebind-regression-green/
            20260815_070839_539_1d08e225/                  2/2 PASS
Verify:     Saved/StaticJIT/TestJIT/Commandlet/
            typed-aot-private-rebind-verify-green/
            20260815_070924_381_57844f13/                  PASS
```

`-Mode=Verify` confirms the replacement-only runtime fixture API changes no
generated `.jit.cpp`, Provider manifest, owned-file set, stable identity or
Provider generation. The slot refresh is therefore an Engine-adoption action,
not code regeneration.

### Reference-slot inspection view RED (2026-08-15)

`as.StaticJIT.DumpDiagnostics` currently serializes each Provider reference as
stable key + expected ABI + one `resolved` boolean. That is insufficient for
debugging a bridged call because it cannot distinguish current resolution from
adoption by the active route, cannot explain stale/unbound state, and does not
name the current registered AngelScript function behind an environment slot.

The existing schema-completeness test now requires `currentResolution`,
`adoptionState`, `currentTargetDeclaration`, and `currentTargetKind`. The fresh
test fails only those new expectations:

```text
Build: Saved/Build/typed-aot-reference-diagnostics-red/
       20260815_071132_529_1ad7628c/                       PASS
Test:  Saved/Tests/typed-aot-reference-diagnostics-red/
       20260815_071151_776_2fbc51cd/                       0/1 expected RED
Missing: currentResolution/adoptionState and current registered target view
```

The planned implementation is read-only and snapshot-local. It will reuse the
already-built current-Engine resolver, enumerate the Engine's live registered
system functions once for safe target classification, compare an adopted table
slot against the resolver's current value, and serialize no process address or
Engine-local function ID. Provider ABI and generated artifacts do not change.

### Reference-slot inspection view GREEN (2026-08-15)

The diagnostics snapshot schema is now version `3`. Each Provider reference
retains its stable key, expected ABI and compatibility `resolved` flag, and now
also reports four current-Engine inspection fields:

- `currentResolution`: the exact resolver result (`Exact`, `Missing`, ABI or
  kind mismatch, and the other typed resolver outcomes);
- `adoptionState`: `Unavailable`, `Unbound`, `ResolvedNotAdopted`, `Bound`,
  `Stale`, or `Rejected`;
- `currentTargetDeclaration`: the current registered AngelScript declaration
  when the resolved value is safely classified as a live system function;
- `currentTargetKind`: currently `SystemFunction` for that reviewed live target
  class.

Capture reuses the single current-Engine reference resolver and enumerates the
Engine's registered system functions once into snapshot-temporary lookup state.
It never serializes the temporary pointer key, a process address, or an
Engine-local function ID. A reference is `Bound` only when the active adopted
route's immutable table slot equals the resolver's current value; any divergence
is rendered `Stale`. An exact current target without an active adopted entry is
`ResolvedNotAdopted`, a missing target is `Unbound`, and typed resolver failures
are `Rejected`. This adds no per-call work and changes neither Provider ABI nor
generated source/artifacts.

The original schema-completeness RED is now GREEN, and the entire focused
diagnostics prefix remains GREEN:

```text
Build:      Saved/Build/typed-aot-reference-diagnostics-green/
            20260815_071409_901_2574673f/                  PASS
Focused:    Saved/Tests/typed-aot-reference-diagnostics-green/
            20260815_071429_379_16440e00/                  1/1 PASS
Regression: Saved/Tests/typed-aot-reference-diagnostics-regression-green/
            20260815_071627_893_c01dc2bc/                  5/5 PASS
Build lock: Ready in 3-4 ms; no relevant UnrealEditor or LiveCodingConsole
            process owned V:\\AngelscriptProject.uproject, so none was stopped
Diff check: parent and Plugins/Angelscript both PASS; only existing line-ending
            conversion warnings were reported
```

This closes the inspection/dump slice of task 5.9. The task remains unchecked
because its broader bridge marshalling, exception, imported-function and
module-unload matrix is intentionally still open. Task 5.12 likewise remains
open until the header-inline representative and the complete cross-DLL matrix
are implemented; the exported `Print`, provider-private current-slot execution,
replacement-Engine refresh, binding retirement/VM fallback, generated source
mapping and Runtime diagnostics portions are now proven.

### Generation-only Bind provenance storage RED (2026-08-15)

The already-GREEN broad installed inventory was re-audited against
`research/native-call-installed-inventory-implementation.md`. Its first
implementation populated source strings only for `StaticJITGeneration`, but
the owner/phase/source fields still lived directly in every ordinary
`FAngelscriptRegisteredFunctionProvenance` value. Empty `FString` values avoid
heap copies, but still enlarge every Runtime/Editor per-function row and do not
meet the selected optional-generation-state boundary.

Two tests now require that boundary explicitly:

- a real ordinary Runtime `FAngelscriptTestEngine` must leave
  `GenerationFunctionProvenance` unallocated after the sealed Bind replay;
- a real `StaticJITGeneration` Engine must own that optional table, with exactly
  one broad row for every compact Bind provenance row and every frozen
  `NativeCallInventory` row.

The production member did not exist when the tests were added. The official
short-path UBT build reached both affected test unity files and failed only at
that missing API, establishing the intended compile RED:

```text
Build:  Saved/Build/typed-aot-generation-provenance-red/
        20260815_072505_149_937e907c/
Result: expected RED; UBT exit 6 / runner exit 1
Errors: FAngelscriptBindState has no member GenerationFunctionProvenance
Files:  AngelscriptExplicitBindContextTests.cpp and
        AngelscriptStaticJITGenerationEngineTests.cpp
Lock:   no V:\\AngelscriptProject.uproject UnrealEditor/LiveCoding owner;
        BuildBat lock was ready
```

The GREEN implementation will restore the compact ordinary row to origin plus
provider, allocate owner/phase/normalized source facts only for a generation
Engine, and make snapshot freezing consume that optional Engine-owned table.

### Generation-only Bind provenance storage GREEN (2026-08-15)

`FAngelscriptBindState` now keeps the ordinary installed-function provenance
row compact (`Origin` + `Provider`) and owns a nullable
`GenerationFunctionProvenance` table for the broad generation-only facts. The
table is allocated only while `OnBindForTarget` is replaying against an Engine
whose purpose is `StaticJITGeneration`; it captures owner module, phase,
provider, normalized source path and source line. Snapshot freezing requires
and consumes that table, then copies only owned pointer-free values into the
immutable `NativeCallInventory`.

Fresh official verification:

```text
Build:      Saved/Build/typed-aot-generation-provenance-green/
            20260815_072629_306_b9c7bb11/                 PASS (94/94)
Runtime:    Saved/Tests/typed-aot-generation-provenance-runtime-green/
            20260815_072804_963_af69b639/                 1/1 PASS
Generation: Saved/Tests/typed-aot-generation-provenance-inventory-green-02/
            20260815_073012_779_bf879a1c/                 1/1 PASS
Build lock: ready in 3 ms for both tests; no relevant editor needed stopping
```

An initial generation test launcher was accidentally given a 10-second outer
tool timeout. Its child Editor-Cmd still completed the test successfully and
exited, but that run is not counted as GREEN because the parent runner did not
produce a normal final status. The `-02` run above is the clean rerun with
runner exit `0`, UE test exit `0`, report metadata and normal editor shutdown.

This closes only the optional-storage part of tasks 5.3/5.3a. The tasks remain
open for the production native-form value view, installed callable-kind and
duplicate-conflict coverage, multi-Engine teardown, and final inventory/export
reconciliation.

### Production native-form value view RED/GREEN (2026-08-15)

The generation inventory previously called
`FScriptFunctionNativeForm::GetDebugInfoForTesting()` behind
`WITH_DEV_AUTOMATION_TESTS`. A shipping-capable generation build could therefore
observe `bHasNativeForm=true` while losing the form kind, callable spelling and
header. The test-only value also carried a raw `UFunction*`, which was not safe
to retain beyond the disposable generation Engine.

The existing exhaustive fluent test was changed first to require the production
`FAngelscriptNativeFormDescription` and `Describe()` contract. UFunction cases
require an owned object-path string instead of a pointer. The official RED
reached the affected test unity and failed only because the new type/method did
not yet exist:

```text
Build:  Saved/Build/typed-aot-native-form-description-red/
        20260815_073220_863_d3481f7d/
Result: expected RED; UBT exit 6 / runner exit 1
Errors: FAngelscriptNativeFormDescription undeclared; Describe not a member
Lock:   BuildBat ready; no Live Coding owner
```

`FAngelscriptNativeFormDescription` is now available for every
`AS_CAN_GENERATE_JIT` build. All 17 concrete legacy native-form classes expose
owned kind/name/custom-form/target-type/header/configuration values; the
UFunction form converts its reflected target to `GetPathName()` while the
Engine is alive. The immutable installed inventory copies those facts into its
own fields, including trivial/guaranteed/compare/copy flags, and never retains
the reflected pointer. Existing reflected BlueprintCallable and RPC tests now
match the stable path while continuing to prove their generic VM routing.

Fresh official GREEN evidence:

```text
Build:      Saved/Build/typed-aot-native-form-description-green/
            20260815_073519_296_435a493d/                 PASS (95/95)
Fluent:     Saved/Tests/typed-aot-native-form-description-fluent-green/
            20260815_073706_674_901e9208/                 8/8 PASS
Reflection: Saved/Tests/typed-aot-native-form-description-reflection-green/
            20260815_073817_034_b2167d02/                 4/4 PASS
Inventory:  Saved/Tests/typed-aot-native-form-description-inventory-green/
            20260815_073905_437_c15f9540/                 1/1 PASS
Build lock: ready in 3 ms; no relevant editor needed stopping
```

This closes the production native-form description slice of tasks 5.3/5.3a.
Installed callable-kind/duplicate-conflict coverage, broad multi-Engine teardown
and the final source/export reconciliation remain open.

### Installed callable-kind authority RED/GREEN (2026-08-15)

The first inventory classifier inferred kind from constructor/destructor traits,
generic call convention and `objectType`. Maintained-fork behaviour registration
does not set a destructor trait, and ordinary ADDREF/RELEASE/GC/template
behaviours have no dedicated trait, so valid installed rows were mislabeled as
methods; factory-like behaviours could also look global.

The integration test first required the final installed Bind surface to contain
all six authoritative categories: global, method, constructor, destructor,
behavior and generic. The existing implementation produced the expected RED:

```text
Build: Saved/Build/typed-aot-callable-kind-red-build/
       20260815_074142_105_ca24590e/                       PASS
Test:  Saved/Tests/typed-aot-callable-kind-red/
       20260815_074200_605_a4a2b33e/                       0/1 expected RED
Error: Installed destruct behaviours must not be misclassified as methods
```

The optional generation-only provenance row now also captures the original
`asEBehaviours` value at the three Bind behavior registration entry points.
Snapshot classification maps construct/list-construct/factory/list-factory to
constructor, destruct to destructor and all other explicit behaviours to
behavior before considering generic/method/global inference. Ordinary Runtime
rows remain unchanged.

```text
Build: Saved/Build/typed-aot-callable-kind-green/
       20260815_074316_432_498e8218/                       PASS (94/94)
Test:  Saved/Tests/typed-aot-callable-kind-green/
       20260815_074447_654_751c1366/                       1/1 PASS
Lock:  BuildBat ready in 3 ms; no relevant editor needed stopping
```

### Duplicate generation FunctionId integrity RED/GREEN (2026-08-15)

The first generation-only table used `TMap::FindOrAdd`, which made an accidental
second observation of the same current FunctionId silently reuse the first row.
AngelScript itself already rejects a real duplicate declaration with
`asALREADY_REGISTERED` (covered by the Fluent registration regression), but the
generation capture boundary now also defends its own primary key.

The new test first required a `TryAddFunction` contract and observable conflict
set; the compile RED failed only at the absent API:

```text
Build: Saved/Build/typed-aot-provenance-duplicate-red/
       20260815_074635_405_ac65fbed/                        expected RED
Error: TryAddFunction and DuplicateFunctionIds do not exist
```

`FAngelscriptGenerationFunctionProvenanceState::TryAddFunction` now preserves
the first row, rejects a repeated FunctionId and records it in
`DuplicateFunctionIds`. `OnBindForTarget` converts that conflict into the
existing first-registration-failure path, while snapshot capture independently
rejects any nonempty conflict set with a deterministic lowest-ID diagnostic.

```text
Build:     Saved/Build/typed-aot-provenance-duplicate-green/
           20260815_074716_546_a5975054/                    PASS (94/94)
PrimaryKey: Saved/Tests/typed-aot-provenance-duplicate-green/
           20260815_074851_683_5cbb1ed5/                    1/1 PASS
Inventory: Saved/Tests/typed-aot-provenance-duplicate-inventory-green/
           20260815_074928_715_6a63370b/                    1/1 PASS
Lock:      BuildBat ready in 3 ms; no relevant editor needed stopping
```

### Two-generation-Engine inventory ownership GREEN (2026-08-15)

A focused lifetime regression now creates two simultaneous TypedAST generation
Engines and retains both immutable snapshots. It proves their optional broad
provenance tables have different owners, their installed inventory totals match,
and each contributes an independent native-form table. Destroying Engine A
releases only A's native forms, leaves Engine B's provenance unchanged, and the
pointer-free `NativeCallInventory` retained by A's snapshot remains readable.
Destroying Engine B restores the process native-form count to the pre-test
baseline.

The existing production ownership already satisfied this contract, so no
production change was made solely to force a RED:

```text
Build: Saved/Build/typed-aot-native-inventory-two-engine/
       20260815_075117_127_5899386d/                        PASS (4/4)
Test:  Saved/Tests/typed-aot-native-inventory-two-engine/
       20260815_075135_484_848ad51c/                        1/1 PASS
Lock:  BuildBat ready in 3 ms; no relevant editor needed stopping
```

### Installed routing/ABI surface and deterministic export GREEN (2026-08-15)

The broad inventory now copies the complete current registered-call shape that
task 5.3 needs for classification: namespace and receiver, function traits,
compile-out kind, default/hidden/determines-output parameters, first-parameter
metadata, call convention, parameter/return sizes, return-on-stack,
WorldContext and caller presence. Unknown maintained-fork enum values fail
closed. `Print` is explicitly proven to remain `CompileCalls` for
Win64/EditorDevelopment, carry two defaults and WorldContext, and select the
reviewed `ExportedRuntimeCallable` descriptor rather than a name-inferred
route.

The focused integration test also owns a deterministic one-physical-row-per-
function CSV exporter behind
`-AngelscriptNativeCallInventoryOutput=<path>`. Embedded CR/LF values are
escaped and the final newline is normalized, so the export contains exactly
one header plus every generation row. Two early GREEN attempts exposed and
fixed those physical-row issues before the result was accepted.

```text
Build routing fields: Saved/Build/typed-aot-installed-routing-fields-green-02/
                      20260815_075931_202_7384fe92/          PASS
Routing test:         Saved/Tests/typed-aot-installed-routing-fields-test-02/
                      20260815_080047_088_69ff80ec/          1/1 PASS
CSV export test:      Saved/Tests/typed-aot-installed-inventory-export-test-03/
                      20260815_080600_208_f4deef49/          1/1 PASS
Post-editor build:    Saved/Build/typed-aot-after-editor-close/
                      20260815_075408_907_aa791441/          PASS
```

The post-editor build found no `UnrealEditor.exe` or `LiveCodingConsole.exe`
owning `V:\AngelscriptProject.uproject`; no process needed to be stopped and
the UE 5.8 serialized build lock was immediately available.

### CacheV2 stable installed identity GREEN (2026-08-15)

The first reconciliation prototype tried to hash namespace + receiver +
declaration. A diagnostic test reported `void throw(const FString&inout)` and
`void Throw(const FString&inout)` as a duplicate because Unreal's string-map
key semantics are unsuitable as a case-sensitive AS function identity. This
was a test-identity defect, not a duplicate registration and not evidence of a
CacheV2 collision.

Every installed row now carries the existing pointer-free CacheV2
`EnvironmentSymbol` reference produced by
`FAngelscriptCacheEnvironmentIdentity::TryBuildFunctionReference()`: reference
kind, 256-bit stable key and expected ABI. The integration test requires every
row to have a valid nonzero reference and requires all stable keys to be unique;
`EngineLocalFunctionId` remains only a same-Engine join aid. The same run also
proves all six callable kinds and that at least one manual dynamic Provider
declaration expands into multiple separately identified functions.

```text
Build: Saved/Build/typed-aot-stable-reference-green/
       20260815_082005_692_307b5dec/                         PASS
Test:  Saved/Tests/typed-aot-stable-reference-test/
       20260815_082033_824_eac1e871/                         1/1 PASS
Raw installed inventory:
       Saved/TypedSemanticAOT/NativeCallInventory/20260815_0803/
       installed-native-call-inventory.csv
       rows=78,082 bytes=81,955,275
       sha256=86d7359bc0992d7c4e8358bb22df63b20bd8e840d236df6ee37f73a9d1e565fc
```

### Final task 5.3 source/installed reconciliation (2026-08-15)

`research/Build-NativeCallExportInventory.ps1` joins the fresh installed
authority to the existing source schema-v11 provider/callsite/descriptors
exports. It never treats native display spelling as identity and never guesses
one source callsite for a loop/template/reflective expansion. Exact joins are
retained where unique; otherwise the installed Provider remains authoritative
with a typed expansion status.

The result is complete for the fresh Win64/EditorDevelopment generation
surface:

```text
Installed functions             78,082
Stable unique identities        78,082
Unknown origins                      0
Manual origin                   45,656
Reflective origin               32,426
Distinct installed Providers       146

bridge                             835
exported-callable                    1   (Print)
inline                               1   (IsRunningCommandlet)
unsupported                      77,245
compile-out                           0   (selected profile; rules retained)

Source callsites                  2,920
installed Provider source sites  1,407
inactive/alternate Providers      1,499
inactive Editor profile branch        4
installed dynamic helper sites       10
unresolved source callsites           0
```

The fourteen source sites without a lexical Provider name are resolved
individually rather than accepted by file-name totals. Four old
`BindBlueprintCallable` sites are inactive because this Editor profile has
`AS_USE_BIND_DB=0`; the active prepare/commit sites expand to 1,041 installed
non-generic UFunction rows, the shared reflective fallback sites expand to
4,785 generic UFunction rows, and the bool getter/setter sites expand to
1,186/2,929 exact native-form helper rows across the actual installed
`BlueprintType.ReflectionBindings` and `UStruct.ReflectionBindings`
authorities. The local-only
`Saved/TypedSemanticAOT/NativeCallInventory/<run>/native-call-source-reconciliation.csv`
retains the per-source-row status, authority and reason, while the compact
counts/hash remain in the committed summary. Optional
Editor/GameplayTags/GAS/Test providers
loaded in this Editor surface are likewise retained through their exact
Engine-owned provider paths and receive
`installed-provider-outside-runtime-source-scan`; the source scan remains the
task-specified complete `AngelscriptRuntime` scan rather than silently dropping
those installed rows.

The full one-row-per-function audit is generated as the local-only
`Saved/TypedSemanticAOT/NativeCallInventory/<run>/native-call-export-inventory.csv`;
its self-describing summary is committed as
`research/native-call-export-summary.json`. The CSV deliberately omits the
repeated long native-ABI canonical string while retaining its hash and every
explicit call-convention/receiver/size/default/hidden/trait/routing/lifetime
field. Current artifact facts:

```text
schema=typed-aot-native-call-export-inventory-v4
rows=78,082 (+ header)
bytes=90,577,265
sha256=f4caaae1f384cd096b92379173e37d2f77e6d21a04a306215594b40f88be7b0b
```

This file is research/audit evidence only. Runtime, Provider generation and
packaging do not load it. It is intentionally ignored and never committed:
OpenSpec retains the generator, compact summary/hash, reconciliation evidence
and conclusions, while the raw installed export and complete reconciled CSV
remain under `Saved` for unrestricted local analysis and exact regeneration.

Two independent generation-Engine captures produced different transient raw
exports because Engine-local FunctionIds/order changed, including the earlier
v2 raw SHA-256
`b4c892ea39287def5cdc24a49109fc4e1153ca3edbd43008eaede1f93a2b00ac`.
After removing Engine-local IDs and sorting by the existing CacheV2 stable key,
both v2 runs reproduced the same final SHA-256
`ad78bd70fe43aef6fcbaa81a2b5172048b2c11a35262b104011f87ae56fba3ba`.
The v3 schema added a human-readable authoritative VM dispatch field. The
current v4 schema additionally carries authoritative UFunction routing flags;
its hash is the current value above.

The internal-pointer/generic audit is no longer inferred from native-form
display text. `CallSystemFunction` route capture now reports:

```text
FunctionCaller   72,240
GenericFunction   1,175
GenericMethod     4,667
Native fallback       0
```

This matters because `FunctionCaller` owns a type-erased invocation of the
current Engine's internal pointer, while a generic target owns the incompatible
`void(asIScriptGeneric*)` callback ABI. Neither pointer is serialized or emitted
into `.jit.cpp`. Current `NativeScalarABI` remains direct-call evidence only;
the planned VM bridge receives a separate AS-visible marshalling identity and
re-enters `Prepare/SetArg*/Execute`, which then selects the current
`CallFunctionCaller` or `CallGeneric` implementation. Until the latter has its
dedicated runtime test, all 5,842 generic rows remain explicit TypedASTJIT
fallback instead of being guessed as direct or bridge calls.

TDD evidence for the new inventory route is:

```text
RED build:  Saved/Build/typed-aot-installed-dispatch-red/20260815_084452_977_756d0fe3
            missing DispatchKind and enum, as intended
GREEN build: Saved/Build/typed-aot-installed-dispatch-green/20260815_084749_944_e4a327e2
             PASS
GREEN test:  Saved/Tests/typed-aot-installed-dispatch-test-02/20260815_084912_838_f39d027a
             1/1 PASS
```

### Separate-consumer native-call export contract (2026-08-15)

Tasks 5.4 and 5.6 are now closed against the authoritative generated
inventory rather than a hand-maintained symbol list alone. The new
`AngelscriptStaticJITNativeCallExportTests.cpp` lives in `AngelscriptTest`, so
its includes, function-address expressions and invocations cross the real
`AngelscriptRuntime.dll`/Core consumer boundary. Its generation-only Engine
walks every installed row carrying a direct linkage descriptor and proves:

- one unique AS identity and stable EnvironmentSymbol reference per direct
  row;
- complete public symbol/include/signature/module/API and native-ABI facts;
- exact default count, WorldContext, route, exception and lifetime policy;
- descriptor validation under the owning public consumer dependency;
- no `GenericFunction`/`GenericMethod` dispatch behind a direct descriptor;
- exact registered/imported address equality plus safe invocation for the
  exported Runtime `AngelscriptStaticJITNativeCallables::Print` callable; and
- public-header compile plus safe invocation for the Core header-inline
  `IsRunningCommandlet` target.

`ValidateAngelscriptStaticJITInstalledNativeCallDispatch` is also called while
the generation snapshot is being frozen. It rejects unknown/caller-
inconsistent dispatch facts, descriptor-presence contradictions, linkage/
route contradictions and, specifically, a generic callback advertised as a
direct DLL/inline call. This is a production generation invariant, not only a
test assertion. The complete inventory generator independently applies the
same generic/direct rejection before assigning `direct-export`, `inline` or
`exported-callable`.

```text
RED build:   Saved/Build/typed-aot-native-export-contract-red/20260815_090337_286_32c65b0b
             failed only because the new dispatch-contract validator was absent
GREEN build: Saved/Build/typed-aot-native-export-consumer-green/20260815_090709_062_b44389a0
             PASS
GREEN test:  Saved/Tests/typed-aot-native-export-consumer-test/20260815_090728_133_7a196af2
             2/2 PASS
```

The historical post-contract v3 full export was regenerated locally at
`Saved/TypedSemanticAOT/NativeCallInventory/20260815_0910_export_contract/`.
It remains 78,082 rows / 90,264,909 bytes with SHA-256
`8a5eca08216787cb0286d15b89f785c501818e154fc9c9a086b44177bfb88663`,
proving that the new fail-closed check accepts the two reviewed current rows
without changing that deterministic analysis artifact. Task 5.11 later
superseded it with the v4 route-safety export recorded below. Both complete CSV
runs and their per-row reconciliation remain ignored local evidence; only the
conclusions, generator and compact current hash are Git material.

### Readable collision-safe bridge call sites (2026-08-15)

Task 5.9a is closed with one deterministic allocator instead of the earlier
fixed eight-hex suffix. `AssignAngelscriptTypedASTJITBridgeCallSiteSymbols`
derives a sanitized readable stem from the canonical AS declaration, starts
with eight hex digits of the full stable function key, and extends only the
colliding stem/key group in four-hex increments until every distinct stable
identity is unique. Input order does not affect the key-to-identifier mapping.
Repeated call expressions that adopt the same complete key, ABI, registered
target metadata and reference slot receive the same identifier.

The emitter now also owns a per-function call-site-definition map. Two HIR call
expressions may invoke the same adopted target, but their generated `.jit.cpp`
contains exactly one immutable
`FAngelscriptTypedASTJITBoundCallSite` definition. A reused identifier carrying
different declaration, registered target, stable key, ABI or slot fails closed
instead of producing conflicting C++.

The allocator test uses namespaced overload-like declarations containing
punctuation whose sanitized stems are equal and two synthetic full keys with
the same first eight hex digits. It proves deterministic 12-hex expansion,
duplicate-target reuse, and identical key-to-name results under reversed input
order. The generated private bridge fixture independently compiles the real
form:

```text
ASJIT_Call_TypedASTProviderPrivateAdd_6b00a476
```

Its neighboring immutable row retains the canonical AS declaration, registered
Bind spelling, full stable key, expected ABI and numeric slot. The header
template still contains only the reviewed `Return, Args...` marshalling shape.

The runtime diagnostic-string negative now installs two different retained
current functions in two already-adopted slots, gives both call-site views the
same misleading canonical declaration and registered-target strings, and
proves each invocation still follows its numeric slot. Thus edited or duplicate
display text cannot redirect dispatch. Identifier stem/suffix are C++ source
identifiers and are never runtime lookup inputs; their duplicate/collision
behavior is settled by the deterministic generation allocator.

TDD and focused verification evidence:

```text
RED build:    Saved/Build/typed-aot-callsite-collision-red/
              20260815_091512_213_83fa9f36
              missing AssignAngelscriptTypedASTJITBridgeCallSiteSymbols
GREEN build:  Saved/Build/typed-aot-callsite-collision-green/
              20260815_091646_564_1ef76018
GREEN test:   Saved/Tests/typed-aot-callsite-collision-test/
              20260815_091711_743_4c36f2dd
              11/11 PASS
Dedup build:  Saved/Build/typed-aot-callsite-dedup-green-03/
              20260815_092404_603_b84364c5
              PASS, 4/4 actions
Dedup test:   Saved/Tests/typed-aot-callsite-dedup-test-03/
              20260815_092422_453_31be1c26
              11/11 PASS
Runtime build: Saved/Build/typed-aot-callsite-runtime-negative-green/
               20260815_092650_389_7f938050
               PASS, 4/4 actions
Runtime test: Saved/Tests/typed-aot-callsite-runtime-negative-02/
              20260815_092709_788_0127a00c
              6/6 PASS
```

Two intermediate failures were test-authoring errors, not product regressions.
The first mechanical edit inserted the duplicate plan into the preceding direct
call test. After moving it, the second attempt assigned two plans to the same
HIR expression, which the analyzer correctly rejects. The final test models the
real case as two distinct HIR call expressions sharing one stable target and
therefore validates both two invocations and one metadata definition.

The first runner invocation was also launched from the physical worktree path,
while this worktree's `AgentConfig.ini` intentionally names its `V:\` SUBST
project path. The runner rejected that path mismatch before UBT. All recorded
build/test evidence above was run from `V:\` and uses the same configured UE
5.8 Engine as the main workspace.

## Ordinary no-export scalar Binding bridge — RED to GREEN (2026-08-15)

- The committed analysis policy remains unchanged: every inventory run keeps
  the complete row-level CSV under ignored
  `Saved/TypedSemanticAOT/NativeCallInventory/<run>/`; OpenSpec records the
  generator, count/size/hash and conclusions. Full export is intentionally
  generated and retained whenever it helps analysis; it is never suppressed,
  truncated, replaced or deleted merely to keep Git small, and only the raw
  CSV itself stays outside Git.
- Added the real AngelScript fixture
  `float32 TypedASTOrdinaryBridgeSqrt(float32)` calling `Math::Sqrt(Value)`.
  This is an ordinary `FunctionCaller` global Bind with no explicit external
  descriptor, no receiver/default/hidden/WorldContext/return-on-stack shape,
  and an AS-visible `float32(float32)` scalar signature.
- Fresh RED build passed:
  `Saved/Build/typed-aot-ordinary-bridge-red/20260815_093701_223_b2bdc3e8`
  (`5/5` UBT actions).
- The first attempted Automation prefix omitted CQTest's class component and
  matched no test; it is runner-discovery evidence only, not product RED:
  `Saved/Tests/typed-aot-ordinary-bridge-red/20260815_093742_141_92655ff9`.
- The exact CQTest path then failed `0/1` as intended:
  `Saved/Tests/typed-aot-ordinary-bridge-red-02/20260815_093830_717_951369cf`.
  The generation Engine froze `4` modules / `54` functions, but the probe's
  actual backend was `bytecode` rather than `typed-ast`. This isolates the gap
  to `NativeCallTargets` capturing only explicit descriptor-backed targets;
  the AS source, Bind installation and generation snapshot itself succeeded.
- Production direction: retain native scalar ABI as direct-linkage evidence;
  add a separate AS-visible VM-bridge marshalling identity, and auto-admit only
  the proven first slice (global, non-void by-value primitive scalar,
  `FunctionCaller`, no defaults/receiver/hidden metadata/WorldContext/
  return-on-stack/compile-out rewrite). Generic, method, void and managed
  shapes remain fail-closed until their own TDD slices.
- First production compile attempt
  `Saved/Build/typed-aot-ordinary-bridge-green-01/20260815_094420_107_d1931740`
  failed before linking because the new header prose contained the literal
  token sequence `SetArg*/Execute`, which prematurely terminated its block
  comment; the same compile also exposed a missing complete `asCObjectType`
  include and one extra closing parenthesis. These are mechanical source
  defects, not a change to the bridge admission contract; all three were fixed
  narrowly before rerunning the build.
- The first AOT GREEN attempt
  `Saved/Tests/typed-aot-ordinary-bridge-aot-green-01/20260815_094600_131_5bef1f38`
  exposed a real compatibility regression before reaching the new Sqrt probe:
  the existing provider-private fixture target disappeared. Root cause was
  requiring an installed Bind-provenance inventory row even for a function
  directly registered on the isolated Engine with an explicit descriptor.
  The capture contract was corrected to preserve both authorities: explicit
  descriptors remain independently capturable, while only descriptor-absent
  automatic bridges require the complete installed inventory row.

The GREEN implementation keeps the two ABI concepts separate. Registered
native ABI continues to describe the installed caller/call-convention facts;
`FAngelscriptTypedASTJITVMBridgeABIIdentity` describes only the AS-visible
primitive scalar return/parameter/direction shape plus receiver, hidden,
WorldContext, compile-out and return-on-stack constraints used by VM
marshalling. The automatic route never invents an exported symbol or external
descriptor. It requires the current generation Engine's installed inventory
row, stable environment function reference and expected native ABI, then emits
the already-reviewed numeric-slot bridge route.

The generated fixture is readable without opening a manifest:

```cpp
/* Declaration : float32 TypedASTOrdinaryBridgeSqrt(const float32) */
static const FAngelscriptTypedASTJITBoundCallSite
    ASJIT_Call_Sqrt_000f5a28 = { /* stable key / ABI / slot */ };
// Row fields: "float32 Sqrt(float32)", "FMath::Sqrt", key, ABI, slot.
return AngelscriptTypedASTJIT::InvokeBound<float, float>(
    Execution, ASJIT_Call_Sqrt_000f5a28, Value);
```

The generated source contains no private `FMath::Sqrt` link expression, raw
pointer, Engine-local FunctionId, name-based lookup or
`FAngelscriptJITExecutionContext`. Provider initialization resolves the stable
identity once; the successful invocation consumes the numeric current-Engine
reference slot and enters maintained VM `Prepare` / `SetArgFloat` / `Execute`,
which reaches the installed `FunctionCaller`.

Fresh verification evidence:

```text
Production build:     Saved/Build/typed-aot-ordinary-bridge-green-02/
                      20260815_094453_980_daae06ad              16/16 PASS
Call-closure GREEN:   Saved/Tests/typed-aot-ordinary-bridge-closure-green/
                      20260815_094524_259_9b82122a              11/11 PASS
Generated verify:     Saved/Tests/typed-aot-ordinary-bridge-aot-green-03/
                      20260815_094954_057_1c81c553               1/1 PASS
Generate commandlet:  Saved/Commandlet/typed-aot-ordinary-bridge-generate/
                      20260815_094852_716_06afab12                    PASS
Generated DLL build:  Saved/Build/typed-aot-ordinary-bridge-generated-green/
                      20260815_094930_024_77b33079               5/5 PASS
Runtime Sqrt:         Saved/Tests/typed-aot-ordinary-bridge-runtime-green/
                      20260815_095332_988_1be2bd44               1/1 PASS
Boundary build:       Saved/Build/typed-aot-ordinary-bridge-boundaries-green/
                      20260815_095501_059_be9a52f7               4/4 PASS
Call-closure final:   Saved/Tests/typed-aot-ordinary-bridge-closure-green-02/
                      20260815_095523_621_3709b49e              13/13 PASS
Native bridge:        Saved/Tests/typed-aot-ordinary-bridge-native-green/
                      20260815_095604_598_481fb802               6/6 PASS
Typed output:         Saved/Tests/typed-aot-ordinary-bridge-output-green/
                      20260815_095644_834_9d0a43c6              11/11 PASS
```

The two added planner negatives prove descriptor-absent automatic targets are
invalid without their separate VM-bridge ABI and become `UnsupportedCall` /
`ExternalCallRouteUnavailable` when the Runtime bridge facility is absent.
The actual AOT runtime test executes `Math::Sqrt(144.0f)` and observes
`12.0f`, proving current-slot dispatch rather than source-only text matching.
Task 5.9b is closed; broader task 5.9 remains open for Generic function/method,
receiver/void/managed shapes, exception detail propagation, dump state and the
remaining bind/rebind/unbind/module-unload coverage.

## Native-call fail-closed boundary closure (task 5.10, 2026-08-15)

Task 5.10 is closed across four independent layers instead of relying on one
synthetic emitter assertion:

1. Call-closure planning reports source-located `UnsupportedCall` with
   `ExternalCallDescriptorMissing` / `ExternalCallRouteUnavailable` when an
   unexported system target has neither an explicit direct descriptor nor a
   proven VM bridge.
2. Typed eligibility rejects references, out parameters, return-on-stack,
   objects, structs, containers, delegates, unsupported lifetime and suspend
   state before emission. This run exposed a real omission: `Reference` and
   `Struct` flags were not included in the explicit first-layer masks and could
   rely on later type inspection. The masks now reject them deterministically
   as `UnsupportedSignature` and `UnsupportedType` respectively.
3. Generated private-bridge source is asserted to contain no guessed `extern`,
   `reinterpret_cast`, `uintptr_t`, raw `0x` pointer literal, private-symbol
   call expression, `FAngelscriptJITExecutionContext`, or Engine-local
   `FunctionId`; invalid/unsupported HIR still returns no partial C++.
4. Runtime bridge tests prove missing table/index, null unbound value, wrong
   kind, scalar-signature mismatch and wrong Engine all fail before the retained
   caller executes. Reference-table/Provider adoption separately proves missing,
   ambiguous, wrong-kind and ABI-mismatched references never produce a usable
   required slot. The successful hot path therefore remains numeric-slot-only;
   it does not repeat key/hash/name work per call.

The initial focused eligibility run was useful RED evidence rather than a
flaky rerun:

```text
Eligibility RED:      Saved/Tests/typed-aot-unsupported-eligibility-green/
                      20260815_100442_957_78bba7da               5/7 PASS
```

Five errors came from test HIR that the maintained verifier now correctly
classified first as invalid receiver/call shape. Those fixtures were corrected
to assert verifier precedence or construct a valid resolved call with explicit
target kind, operands, formal positions and evaluation sequence. The other two
errors were the `Reference` / `Struct` production-mask omission fixed above.

Final evidence:

```text
Boundary build:       Saved/Build/typed-aot-unsupported-boundaries-green/
                      20260815_100248_266_fb743889              16/16 PASS
Eligibility fix build:Saved/Build/typed-aot-unsupported-eligibility-fix-green/
                      20260815_100706_407_a743afcb               7/7 PASS
Native bridge:        Saved/Tests/typed-aot-unsupported-native-green/
                      20260815_100331_229_15366c4d               6/6 PASS
Generated output:     Saved/Tests/typed-aot-unsupported-output-green/
                      20260815_100407_466_44684d78              11/11 PASS
Eligibility GREEN:    Saved/Tests/typed-aot-unsupported-eligibility-green-02/
                      20260815_100726_345_4e7f9179               7/7 PASS
Reference slots:      Saved/Tests/typed-aot-unsupported-reference-green/
                      20260815_100801_834_985e7685               5/5 PASS
Provider match:       Saved/Tests/typed-aot-unsupported-provider-green/
                      20260815_100840_235_cb777895               5/5 PASS
Call closure:         Saved/Tests/typed-aot-unsupported-closure-green/
                      20260815_100922_966_efaea559              13/13 PASS
```

## Unreal-routed native-call containment (task 5.11, in progress 2026-08-15)

The first test-first audit found a narrower installed-dispatch gap than the
existing root eligibility matrix. TypedASTJIT already rejects RPC/net,
BlueprintEvent, BlueprintOverride and virtual/non-final roots, and the AOT
virtual fixture already proves current-function dispatch reaches the child
override. However, the pointer-free installed native-call inventory retained
only a UFunction path. It did not retain authoritative `FUNC_Net`,
`FUNC_Event`, or `FUNC_BlueprintEvent` route facts, so a contradictory external
descriptor could theoretically advertise raw-direct DLL linkage without the
installed-dispatch validator detecting that Unreal routing had been bypassed.

RED tests now require route facts for RPC/net, Unreal Event, and BlueprintEvent
UFunctions to reject raw-direct linkage with the stable
`DirectDescriptorBypassesUnrealRoute` diagnostic. A separate positive case
prevents a blanket ban on reviewed ordinary native UFunctions. Focused root
tests name RPC/net, BlueprintEvent, BlueprintOverride and virtual/non-final
rejections explicitly.

```text
Route-safety RED build: Saved/Build/typed-aot-route-safety-red/
                        20260815_102203_635_95b9fbe2            EXPECTED FAIL
Cause:                  EAngelscriptNativeUFunctionRouteFlags and
                        NativeUFunctionRouteFlags do not yet exist.
```

GREEN now snapshots those flags from the live UFunction during generation,
rejects contradictory direct descriptors, preserves the existing VM or
ProcessEvent/current-function routes, and adds the new column to both the
checked export schema and the full ignored row-level CSV. Ordinary reflected
UFunctions with no routed flags remain eligible for a separately reviewed
direct descriptor, so this is not a blanket UFunction ban.

The real final Engine surface contains 593 routed UFunction rows: 138 RPC/net
rows have flag value `3` (`RpcOrNet|Event`) and 455 BlueprintEvent rows have
flag value `6` (`Event|BlueprintEvent`). All 593 remain on current Unreal
routing; the full export found zero routed/raw-direct conflicts. The existing
virtual fixture contains a BlueprintEvent parent and BlueprintOverride child;
its focused runtime test still resolves the child value `217` through the
current-function/RuntimeCallEvent route.

```text
GREEN build:          Saved/Build/typed-aot-route-safety-green/
                      20260815_102419_786_9c555a8d              PASS
Native export:        Saved/Tests/typed-aot-route-native-export-green/
                      20260815_102555_954_c9112863               4/4 PASS
Native forms:         Saved/Tests/typed-aot-route-native-forms-green/
                      20260815_102634_144_9be0da28               4/4 PASS
Eligibility:          Saved/Tests/typed-aot-route-eligibility-green/
                      20260815_102720_184_8e17b1da              26/26 PASS
Virtual route:        Saved/Tests/typed-aot-route-virtual-green/
                      20260815_102756_435_60b7b4bc               1/1 PASS
Installed export:     Saved/Tests/typed-aot-route-full-installed-export/
                      20260815_102938_004_00bcb97e               1/1 PASS
Full v4 CSV:          Saved/TypedSemanticAOT/NativeCallInventory/
                      20260815_1029_route_safety/
                      rows=78,082 bytes=90,577,265
                      sha256=f4caaae1f384cd096b92379173e37d2f77e6d21a04a306215594b40f88be7b0b
```

The full CSV remains an analysis artifact under `Saved/TypedSemanticAOT` and
is intentionally available for unrestricted row-level inspection. Git retains
the deterministic generator, compact count/size/hash/routing summary and these
conclusions, never the 90.6 MB CSV itself. Task 5.11 is closed.

## Cross-DLL fixture and call-site mapping audit (tasks 5.12-5.13, in progress 2026-08-15)

The current generated fixture proves three of the four requested linkage
classes: `IsRunningCommandlet()` is a `HeaderInline` call, `Print(...)` names
the actual `ANGELSCRIPTRUNTIME_API` callable, and
`TypedASTProviderPrivateAdd(...)` uses the immutable current-slot VM bridge.
The v4 full export contains 835 bridge rows, one exported Runtime callable and
one inline callable, but no ordinary scalar `direct-export` row. Therefore
`Print` cannot also stand in as proof of a distinct `ExportedSymbol` route.

The selected real cross-DLL scalar target is
`FDateTime::DaysInMonth(int32, int32)`: UE declares it `CORE_API` in
`Misc/DateTime.h`, defines it out of line in Core, and the existing
`Bind_FDateTime.cpp` registers that exact function. The fixture will call
`FDateTime::DaysInMonth(2024, 2)` from the generated project module and prove
the result is `29`; no test-only forwarding export is needed.

A second gap is observability rather than execution. Generated `.jit.cpp`
currently contains the final C++ expression, the Provider manifest contains
only entry/reference identity, and Runtime diagnostics contains only resolved
reference state. Parsing generated C++ or reconstructing a target from display
names would create three divergent authorities and violates the no-inference
linkage contract. The implementation boundary is therefore one immutable,
pointer-free call-site record carried by the generation model into the Provider
ABI. The `.jit.cpp` comment, JSON manifest and Runtime diagnostic record are
all emitted/copied from that same record; bridge current-target state is joined
through its already-adopted numeric reference slot. Call-site strings remain
diagnostic metadata and are never consulted by dispatch.

This extends the existing Provider ABI instead of inventing an additional dump
side channel. The ABI revision and generation schema must advance, validation
must reject malformed/order-inconsistent rows, the artifact-set digest must
cover their immutable semantic fields, and Provider catalog copies must own all
strings so module unload cannot leave diagnostic views dangling.

The first two RED checkpoints are now concrete:

```text
Exported-symbol RED build:  Saved/Build/typed-aot-exported-symbol-red/
                            20260815_105232_098_76aede3a       PASS
Exported-symbol RED test:   Saved/Tests/typed-aot-exported-symbol-red/
                            20260815_105255_687_21aaabbf       5/6 PASS
Failure:                    descriptor lookup returned null after the exact
                            registered function/DLL address checks passed
Exported-symbol GREEN build:Saved/Build/typed-aot-exported-symbol-green/
                            20260815_105416_613_fe12281c       PASS
Exported-symbol GREEN test: Saved/Tests/typed-aot-exported-symbol-green/
                            20260815_105428_699_1794f939       6/6 PASS
Call-site ABI RED build:    Saved/Build/typed-aot-callsite-metadata-red/
                            20260815_105631_461_8fb4888a       EXPECTED FAIL
Failure:                    provider/generation call-site types, entry fields,
                            revision and validation codes do not yet exist
```

The GREEN descriptor is attached to the existing
`FDateTime::DaysInMonth` registration only for compatibility-collection
generation Engines. It records `CORE_API`, `Misc/DateTime.h`, the exact native
and scalar ABI captured from the installed function, direct-call routing and
scalar-by-value lifetime; the registered pointer remains the original UE Core
function.

The Provider/generation call-site contract is now GREEN. Provider ABI revision
3 owns one validated immutable table per artifact entry; generation schema
revision 4 serializes the same rows into the manifest and generated Provider
translation unit, includes them in the artifact digest, and the Runtime
catalog deep-copies every display string and stable identity. Direct rows must
contain no bridge-only key/ABI/slot fields. Bridge rows must name the fixed
`AngelscriptTypedASTJIT::InvokeBoundViaVM` Runtime core and match an exact
EnvironmentSymbol reference slot by stable key plus expected ABI.

The first focused GREEN run exposed one stale test expectation rather than a
production defect: the full-stable-identity test still required schema revision
3 after the new call-site field intentionally advanced it to 4. The failure was
exactly at that version assertion; all new native-call-site checks had already
passed. The test now formats its expectation from
`FAngelscriptJITGeneration::SchemaRevision`, preserving the deliberate schema
freeze without duplicating a second version constant.

```text
Core GREEN build:       Saved/Build/typed-aot-callsite-core-green-build/
                        20260815_110306_269_fcbe3c75             PASS
Provider ABI:           Saved/Tests/typed-aot-callsite-provider-abi-green/
                        20260815_110347_775_37634e1b              6/6 PASS
Initial generation:     Saved/Tests/typed-aot-callsite-generation-green/
                        20260815_110424_740_fb1cd87c              7/8 PASS
Root cause:             stale hard-coded schemaRevision=3; current contract=4
Version-fix build:      Saved/Build/typed-aot-callsite-generation-version-green/
                        20260815_110828_032_79fc0f99             PASS
Generation rerun:       Saved/Tests/typed-aot-callsite-generation-version-green/
                        20260815_110847_147_2c00e675              8/8 PASS
```

The next checkpoint is Runtime diagnostics: it must expose these owned Provider
rows directly and join a bridge row to its current resolved/adopted slot state;
it must not parse a `.jit.cpp` file or infer route/target from a symbol string.

## Full CSV retention requirement clarified (2026-08-15)

The repository-size constraint applies only to Git storage, not to analysis
depth. Every authoritative native-call inventory run must generate and retain
the complete row-level CSV beneath ignored `Saved/TypedSemanticAOT` (or an
equivalent path outside the repository). The committed summary, hash and
reconciliation evidence are companions to the full local export; they never
replace it. In particular, unsupported, generic, bridge, compile-out and
unresolved rows must remain queryable rather than being reduced to aggregate
counts.

The current accepted v4 artifact remains present and unchanged:

```text
CSV:     Saved/TypedSemanticAOT/NativeCallInventory/
         20260815_1029_route_safety/native-call-export-inventory.csv
rows:    78,082
bytes:   90,577,265 (about 89.6 MiB)
sha256:  f4caaae1f384cd096b92379173e37d2f77e6d21a04a306215594b40f88be7b0b
Git:     untracked; ignored by .gitignore Saved/*
```

Because native-call descriptors and generated call-site metadata are still
being extended in tasks 5.12-5.13, final verification will generate a new full
CSV from the fresh installed Engine surface and retain that complete file
under a new ignored run directory. It will not replace the export with a
Git-friendly reduced CSV.

## Cross-DLL fixture, Runtime call-site dump, and final full export GREEN (tasks 5.12-5.13, 2026-08-15)

Runtime diagnostics now consumes the Provider catalog's owned call-site rows
directly. Direct rows are reported as resolved imported/inline/thunk targets;
bridge rows are joined to the already-adopted numeric reference slot by exact
stable key and expected ABI. Schema version 4 emits a human-readable `mapping`
field without parsing generated source or using any display spelling for
dispatch. The focused diagnostics suite first failed `2/6` only because the
checked-in generated Provider still advertised ABI 2/schema 3; after
regenerating the real Provider at ABI 3/schema 4, all `6/6` passed.

The first regeneration attempt also exposed a real eligibility ordering bug:
aggregate `Reference|Struct` rejection ran before the exact reviewed
`const FString`/`const FLinearColor` input allowlist, so the production Print
fixture failed as `UnsupportedSignature: Reference|Struct`. Eligibility now
permits those flags only when at least one exact reviewed managed input is
present; object/container/delegate/out/return-on-stack and unrelated
reference/struct signatures remain fail-closed. The full eligibility prefix
passed `26/26` after the fix.

The new main fixture function is:

```angelscript
UFUNCTION()
int TypedASTExportedSymbolShowcase(int Year, int Month)
{
    return FDateTime::DaysInMonth(Year, Month);
}
```

Its focused test first failed exactly because the function was absent. After
adding the fixture and regeneration guard, the generated project-module source
contains `#include "Misc/DateTime.h"` and the ordinary C++ expression:

```cpp
return FDateTime::DaysInMonth(as_sem_e2_arg0, as_sem_e2_arg1);
```

The same `.jit.cpp` comment, Provider manifest and Runtime dump all report:

```text
int DaysInMonth(int, int)
  -> FDateTime::DaysInMonth
  -> DirectExported
  -> FDateTime::DaysInMonth

void Print(...)
  -> AngelscriptStaticJITNativeCallables::Print
  -> DirectExported
  -> AngelscriptStaticJITNativeCallables::Print

bool IsRunningCommandlet()
  -> IsRunningCommandlet
  -> DirectInline
  -> IsRunningCommandlet

int TypedASTProviderPrivateAdd(int, int)
  -> AngelscriptTypedASTJIT::InvokeBound<int32, int32, int32>
  -> AngelscriptTypedASTJIT::InvokeBoundViaVM
  -> slot[0]
  -> int TypedASTProviderPrivateAdd(int, int)
```

The direct function has Raw, VM and Parms entries, all returning `29` for
`(2024, 2)`. The separate `AngelscriptTestJIT.dll` compiled and linked the
actual UE Core import. The generated source contains no
`FAngelscriptJITExecutionContext`; direct rows have no bridge key/ABI/slot, and
the private bridge retains its named immutable call-site row and follows
replacement/unbind state without regeneration.

```text
Eligibility build:        Saved/Build/typed-aot-reviewed-managed-signature-green/
                          20260815_112019_467_a5b3c2d3            PASS
Eligibility tests:        Saved/Tests/typed-aot-reviewed-managed-signature-green/
                          20260815_112427_189_5e6f3da6          26/26 PASS
Provider regeneration:    Saved/Commandlet/typed-aot-callsite-provider-regenerate-green/
                          20260815_112507_016_db7337cc            PASS
Provider build:           Saved/Build/typed-aot-callsite-provider-green-build/
                          20260815_112545_074_6d32c5ed            PASS
Diagnostics after ABI 3:  Saved/Tests/typed-aot-diagnostics-callsite-provider-green/
                          20260815_112611_230_0aac42c2             6/6 PASS

Exported-call RED:        Saved/Tests/typed-aot-core-exported-symbol-red/
                          20260815_112726_263_db87f184             0/1 FAIL
Reason:                   exact fixture function was absent
Fixture build:            Saved/Build/typed-aot-core-exported-symbol-fixture-build/
                          20260815_112959_252_bacd3501            PASS
Provider regeneration:    Saved/Commandlet/typed-aot-core-exported-symbol-generate/
                          20260815_113020_053_c5228bf5            PASS
Cross-DLL provider build: Saved/Build/typed-aot-core-exported-symbol-provider-build/
                          20260815_113059_108_abc01cd8            PASS
Exported-call GREEN:      Saved/Tests/typed-aot-core-exported-symbol-green/
                          20260815_113113_681_d9536d75             1/1 PASS

Generated TypedAST AOT:   Saved/Tests/typed-aot-direct-and-bridge-green/
                          20260815_113210_084_dd497ff0             8/8 PASS
Final diagnostics:        Saved/Tests/typed-aot-diagnostics-callsite-final-green/
                          20260815_113257_475_4f75e641             6/6 PASS
Generation determinism:  Saved/Tests/typed-aot-generation-determinism-final-green/
                          20260815_113341_644_60fa2b91             8/8 PASS
Native-call linkage:      Saved/Tests/typed-aot-native-call-linkage-final-green/
                          20260815_113414_685_1cf1184f             6/6 PASS
Required modular build:   Saved/Build/semantic-aot-native-linkage/
                          20260815_113817_584_c346e3da            PASS
Required NativeBridge:    Saved/Tests/semantic-aot-calls/
                          20260815_113824_092_b9af6d67             8/8 PASS
```

The generated-runtime requirement in task 5.13 is covered by the exact
`FAngelscriptStaticJITAotTests.TypedAST` `8/8` run above, so an unrelated full
StaticJIT prefix was not needed in addition to the required NativeBridge
prefix.

The final authoritative installed inventory test passed `1/1` and wrote all
78,082 raw rows. The first join invocation used Windows PowerShell 5.1 and
failed during parsing because the deterministic generator uses PowerShell 7
ternary syntax; no output data had been processed or truncated. Rerunning the
same generator with local `pwsh 7.6.0` produced the complete v4 export:

```text
Installed export test: Saved/Tests/typed-aot-final-installed-inventory-export/
                       20260815_113544_869_ec7881c4                 1/1 PASS
Full CSV:              Saved/TypedSemanticAOT/NativeCallInventory/
                       20260815_1135_final_callsite_mapping/
                       native-call-export-inventory.csv
rows:                  78,082 (+ header)
bytes:                 90,579,196
sha256:                9aba620e0efaf176f4d49de12bedf542a1a1fdb26b5ce66bf1ed56da87048dc0
raw installed sha256:  8ba7420c5bb39657e50aac0cede9f8dbc42dba7f8bf5fd8f1d5a999a94dec9cf
reconciliation sha256: 52002ae60cd414a2b81cd4859ce2b339555fca5a215b5347e3f094f05883113c
Git:                   ignored by Saved/*; TRACKED=False
```

Relative to the retained route-safety export, exactly one callable moved from
`bridge` to `direct-export`: the current distribution is `direct-export=1`,
`exported-callable=1`, `inline=1`, `bridge=834`, `unsupported=77,245`.
Unknown origins and unresolved source callsites remain zero. Both complete CSV
runs remain locally available under ignored `Saved`; neither is staged or
committed. Tasks 5.12 and 5.13 are complete.
## 2026-08-15 — Task 5.8 completion audit: resolved native direct calls

Task 5.8 is now complete on current-state evidence; tasks 5.7 and 5.9 remain
open.  This audit did not infer completion from the later 5.12 fixture.  It
traced the production path and then reran the narrow affected Automation
surfaces.

Production evidence:

- `AngelscriptTypedASTJITCallClosure.cpp` matches each system-call HIR
  `resolvedFunctionId` to one captured native target, validates its explicit
  external-call descriptor against the concrete native/scalar ABI and public
  module dependency set, and selects only `DirectExported`, `DirectInline`, or
  `RuntimeThunk` after that validation succeeds.
- `AngelscriptTypedASTJITBackend.cpp` converts only those validated closure
  decisions into direct emission plans and copies the descriptor-owned symbol
  and include.  It does not obtain either value from the registered function
  pointer or diagnostic display spelling.
- `AngelscriptTypedASTJITEmitter.cpp` consumes the exact expression/function-ID
  plan, includes the declared header, preserves HIR evaluation order in named
  temporaries, restores formal argument order at the C++ call, and emits the
  literal proven symbol.  A direct-only body keeps its ordinary C++ signature
  and does not name `FAngelscriptJITExecutionContext`.
- The committed EditorDevelopment generated fixture includes
  `Misc/DateTime.h` and literally invokes `FDateTime::DaysInMonth(...)`; its
  Provider manifest records `DirectExported`, the exact AS declaration and
  the exact C++ callee without Runtime-core, reference-slot, or bridge fields.

Fresh verification:

- `Saved/Tests/typed-aot-58-callclosure-prefix/20260815_114851_030_911218f2`
  — `13/13 PASS`, including exact descriptor classification plus ABI and
  route rejection.
- `Saved/Tests/typed-aot-58-generated-output/20260815_114925_712_758f996f`
  — `11/11 PASS`, including reverse evaluation/formal-order direct output and
  ordinary direct-only body signatures.
- `Saved/Tests/typed-aot-58-aot-direct-export/20260815_115001_608_5308bacc`
  — `1/1 PASS`, actual generated provider compiles, links across the module
  boundary and returns `29` through `FDateTime::DaysInMonth(2024, 2)`.

Two preceding exact-name attempts intentionally remain retained as diagnostic
evidence under `Saved/Tests/typed-aot-58-classification-audit/` and
`Saved/Tests/typed-aot-58-classification-green/`.  They failed only because a
CQTest Automation path inserts the C++ test-class component between the
declared prefix and `TEST_METHOD`; both runs reported zero matched tests and no
test failure.  The class-prefix run above used the authoritative discovered
paths and passed all 13 cases.

Why 5.7 and 5.9 remain open:

- the production Provider still explicitly rejects a closure containing a
  direct script/internal helper body, so the required direct concrete script
  raw call and ordinary non-UFUNCTION helper cases are not yet generated;
- `InvokeBoundViaVM` currently propagates nested failure only through
  `FScriptExecution::bExceptionThrown`; it does not yet adopt the first nested
  VM exception message, originating function and source position into the
  outer execution chain exactly once;
- reviewed root/helper/bridge frame/depth restoration and first-failure
  exception behavior are therefore still coupled to open tasks 4.11–4.16.

## Nested JIT exception metadata RED (tasks 4.15–4.16, 2026-08-15)

The existing AOT exception fixture already proved that a generated helper
failure reaches the outer caller as `asEXECUTION_EXCEPTION`, but it did not
inspect the public exception payload. The focused test now also requires the
first nested failure's exact message, throwing function, processed source
section, line and column:

```text
message:  StaticJITAotNestedFailure
function: void FailForAOT()
section:  /Angelscript/Game/ASStaticJITAotFixture.as
line:     81
column:   2
```

Fresh RED evidence is retained at
`Saved/Tests/typed-aot-exception-metadata-red/20260815_115704_168_a3a0f9dd`:
`NestedGeneratedExceptionPropagates` failed `0/1` after the preceding focused
build passed. The runtime log already contained the correct inner function and
`Line 81 | Col 2`, proving the throwing context knew the data. The outer
`asIScriptContext`, however, received only `m_status = asEXECUTION_EXCEPTION`.

Root cause: `FScriptExecution` carried only `bExceptionThrown`. Both maintained
fork JIT return sites, generated context-mediated script calls, and the Typed
VM bridge forwarded that bool/status without owning or adopting the first
failure's diagnostic payload. The GREEN implementation therefore needs one
call-scoped first-failure record, direct-call sharing, explicit nested-context
adoption, and publication into the outer public context. Later cleanup failures
must not overwrite the record and exception reporting must remain exactly once.

## Nested JIT exception metadata GREEN checkpoint (tasks 4.15–4.16, 2026-08-15)

The Runtime now owns one `asSJITFailureRecord` for each active
`FScriptExecution` chain. The existing `bExceptionThrown` remains the generated
code fast-path signal, while the record retains the first message, exact live
function id, stable function identity, canonical logical section, row/column,
route origin, backend origin, and reported/adopted state. Directly nested
executions share the same record; context-mediated VM calls explicitly adopt
their public exception once; the maintained-fork return paths publish that
record into the outer `asCContext` before returning `asEXECUTION_EXCEPTION`.

The first generated-provider rebuild exposed a real DLL boundary error:

```text
LNK2019 unresolved external symbol
FScriptExecution::AdoptException(asIScriptContext&)
```

The generated `AngelscriptTestJIT` DLL had called a private maintained-fork
member directly. The fix is the narrow exported Runtime facade
`FStaticJITFunction::AdoptContextException`; generated source and TypedASTJIT
now call that API, while `FScriptExecution::AdoptException` stays internal.
This avoids exporting the entire execution object and keeps generated modules
dependent only on a reviewed Runtime DLL surface. No provider-view, entry
signature, or provider/generated-entry POD layout changed, so the explicit
Provider ABI and Entry ABI revisions remain unchanged. The added failure record
is Runtime-owned state appended after the existing fast signal and is never
persisted in a provider artifact.

The next behavior run reached the public payload but exposed that the recorded
section was the isolated fixture's physical `Saved/Automation/...` path. The
Runtime now maps the exact current section through the authoritative
`FAngelscriptModuleDesc::Code` entry and records its `VirtualPath`. Publication
interns that canonical logical section in the receiving AS Engine, so public
debug/exception APIs never leak the transient fixture path.

Fresh evidence:

- `Saved/Build/typed-aot-exception-runtime-facade/20260815_121349_767_c113929c`
  — Runtime-only facade build PASS.
- `Saved/Commandlet/typed-aot-exception-facade-provider-regenerate/20260815_121412_464_baef65eb`
  — provider regeneration PASS, generated `.jit.cpp` calls only
  `FStaticJITFunction::AdoptContextException`.
- `Saved/Build/typed-aot-exception-generated-provider-green-2/20260815_121449_113_b6ab64ca`
  — full Editor/provider build PASS (`27/27` actions).
- `Saved/Tests/typed-aot-exception-metadata-green-2/20260815_121758_901_d0d50706`
  — exact nested generated exception `1/1 PASS`; the public Context reports
  `StaticJITAotNestedFailure`, `void FailForAOT()`,
  `/Angelscript/Game/ASStaticJITAotFixture.as`, and `81:2`.
- `Saved/Tests/typed-aot-first-failure-green/20260815_122040_315_eec9afd3`
  — exception-helper prefix `4/4 PASS`, including a new nested-execution case
  proving shared record identity, first-message retention, one report, no
  false adoption marker, and TLS execution/context restoration.

This closes the concrete first-failure record and generated DLL adoption
implementation. Task 4.15 remains open until the complete route matrix (VM,
top-level BytecodeJIT, direct nested JIT, TypedASTJIT helper, JIT-to-VM bridge,
and public UASFunction entry) records the same status/payload/report/side-effect
contract. Task 4.16 can be checked once that final matrix confirms the current
implementation across every required entry route.

### Typed VM-bridge system-function exception hardening

Extending the bridge test to inspect its adopted failure record exposed a
maintained-fork crash rather than a mere assertion failure. A Generic system
function has no `scriptData`; `asCContext::SetInternalException` nevertheless
stored `m_exceptionSectionIdx = 0`. On an Engine with no script sections,
`GetExceptionLineNumber(..., &SectionName)` then dereferenced slot zero from an
empty section table during `AdoptContextException`.

RED/crash evidence is retained at
`Saved/Tests/typed-aot-bridge-exception-record-green/20260815_122327_560_4bffe7ea`.
The stack terminates at
`asCContext::GetExceptionLineNumber -> FScriptExecution::AdoptException ->
FStaticJITFunction::AdoptContextException -> InvokeBoundViaVM`.

The fork now records `-1` for exceptions raised by functions without script
source and `GetExceptionLineNumber` validates both the section-table range and
entry pointer before exposing a name. Fresh verification:

- `Saved/Build/typed-aot-system-exception-section-fix/20260815_122446_966_02c1d9c6`
  — Runtime build PASS.
- `Saved/Tests/typed-aot-bridge-exception-record-green-2/20260815_122500_512_fa19e4e6`
  — formerly crashing Generic bridge exception `1/1 PASS`.
- `Saved/Tests/typed-aot-bridge-prefix-green/20260815_122535_066_0fcab325`
  — complete TypedASTJIT NativeBridge prefix `6/6 PASS`.

The bridge assertion now proves the failing callee's return storage is not
exposed, the Generic target executes once, and the adopted record retains the
first message, exact function id, `context-adoption` route, `vm` backend, and
reported/adopted state.

## TypedASTJIT frame/depth RED checkpoint (tasks 4.11–4.12, 2026-08-15)

The first frame/depth slice deliberately keeps the pure Typed body ABI
unchanged. A direct-only body still has its ordinary C++ signature; the
Provider/raw entry wrapper owns the Runtime execution frame and recursion
scope. This preserves task 5.9's narrow execution-state threading while giving
every externally entered root a single reviewed frame instead of duplicating
one in both the adapter and body.

The new generated-output contract requires the Provider entry plan to carry
the canonical AS declaration, logical `/Angelscript/...` source section and
entry line. Its emitted raw wrapper must construct
`FScopeTypedASTJITExecutionFrame` from the existing `FScriptExecution`, current
script function and stable source metadata, stop before invoking the native
body when the recursion scope is inactive, and leave the direct-only body free
of `FScriptExecution`.

Fresh RED evidence:

- `Saved/Build/typed-aot-frame-generated-output-red/20260815_123544_264_9a2c4c99`
  — expected compile RED. `AngelscriptTypedASTJITGeneratedOutputTests.cpp`
  requires `FAngelscriptTypedASTJITProviderEntryPlan::{CanonicalDeclaration,
  SourceSection,SourceLine}`, which do not yet exist. The failure is isolated
  to those three missing frozen metadata fields; no product build or test was
  running concurrently.

The implementation must next add the Runtime RAII/depth state, fill the entry
metadata from the already-authoritative `ResolveSourceMetadata()` result before
Provider emission, and then turn this exact generated-output case GREEN. Direct
helper wrappers, mixed bridge/VM nesting, public-query tables and self/mutual
recursion remain part of tasks 4.11–4.12 and will not be marked complete from
the root-wrapper slice alone.

### Module-only build ABI trap while turning the frame test GREEN

The first test execution after the code compiled crashed in
`BuildRawParameterList()` while reading `EntryPlan.Parameters`. This was not a
container/emitter defect. File timestamps and the build action list proved a
mixed DLL layout:

- `UnrealEditor-AngelscriptTest.dll` was rebuilt at 12:42 against the enlarged
  `FAngelscriptTypedASTJITProviderEntryPlan`;
- `UnrealEditor-AngelscriptRuntime.dll` was still the 12:24 binary using the
  old field offsets;
- `RunBuild.ps1 ... -ExtraArgs '-Module=AngelscriptTest'` rebuilt only the
  Runtime import `.lib`, not the Runtime DLL, even though Runtime sources and a
  cross-module by-reference C++ struct had changed.

Crash evidence is retained at
`Saved/Tests/typed-aot-frame-generated-output-green-2/20260815_124318_836_cc4fee9b`.
The corrective verification action is a build that explicitly emits the
Runtime DLL (or the full Editor target) before loading the Test DLL. Do not use
an AngelscriptTest-only modular build as proof after changing a Runtime-owned
cross-module C++ layout.

### Typed execution-frame capability profile RED

The Runtime frame/depth implementation and its generated wrapper are now green,
but the frozen generation capability profile still advertises the old empty
TypedASTJIT instrumentation set. A focused contract test intentionally requires
the profile to advertise the two abilities already emitted by the Editor
development generator: `FramePosition | RecursionBudget`.

Fresh RED evidence:

- `Saved/Tests/typed-aot-frame-capability-red/20260815_124951_359_adbf0fb9`
  — `1` test discovered, `0` passed, `1` failed. The only assertion is
  `BackendSelectionFreezesOneRequiredCaptureProfile`, which reports that the
  emitted TypedASTJIT root owns position metadata and the shared native
  recursion guard while the selected profile still reports neither capability.

This is a contract-synchronization RED rather than a build, discovery or
runtime crash. The next production change is to make the TypedASTJIT generation
profile advertise the implemented abilities for the current Editor development
target, then rebuild the full Editor target and rerun the exact contract test.
Target-aware Shipping semantics remain part of the explicit instrumentation
profile work in task 4.13 and must not be inferred from this Editor-only GREEN.

The production fix made the profile target-explicit rather than reading the
Editor commandlet host macros. Every caller now supplies a concrete
`EditorDevelopment`, `GameDevelopment`, or `GameShipping` target. TypedASTJIT
advertises `FramePosition | RecursionBudget` for the two non-Shipping targets,
and only `RecursionBudget` for Shipping because `AS_JIT_DEBUG_CALLSTACKS` is
compiled out there. `All` and `Invalid` are rejected as non-concrete generation
profiles. Bytecode continues to advertise no TypedASTJIT capabilities.

Fresh RED/GREEN evidence:

- `Saved/Build/typed-aot-target-capability-red/20260815_125517_762_47258f68`
  — expected compile RED after the target-aware test requested the new explicit
  four-argument `TryCreate` contract; all failures were the missing overload.
- `Saved/Build/typed-aot-target-capability-green-build/20260815_125653_554_e8d0021a`
  — full Editor target PASS, including relinking Runtime, Editor and Test DLLs.
- `Saved/Tests/typed-aot-target-capability-green/20260815_125717_984_fbbe7cc6`
  — exact `BackendSelectionFreezesOneRequiredCaptureProfile` contract `1/1`
  PASS across Bytecode, EditorDevelopment, GameDevelopment, GameShipping and
  invalid composite-target cases.

This closes the frozen-profile synchronization slice. It does not by itself
close tasks 4.11–4.13: checked-in Provider artifacts still need regeneration,
direct helper frames and recursive runtime fixtures remain outstanding, and
the explicit safe-point/instrumentation matrix is separate from position-only
metadata.

### Test Provider physical-path determinism repair

Regenerating the checked-in Provider after the frame/depth slice exposed a
test-orchestrator-only determinism defect. The production-shaped module
sources already used stable logical sections such as
`/Angelscript/Game/ASStaticJITTypedPrintFixture.as`, but
`TypedASTJITProviderProbe.generated.cpp` embedded the current fixture path:

`V:/Saved/Automation/AngelscriptTestJITGeneration/<GUID>/Script/ASStaticJITAotFixture.as`

`GeneratedOutputVerify` creates two fresh generation Engines beneath distinct
GUID roots and compares their owned output byte-for-byte, so the defect was
reliably RED rather than an incidental stale-file failure:

- `Saved/Tests/typed-aot-frame-provider-path-red/20260815_125948_138_94d33d51`
  — exact `GeneratedOutputVerify` `0/1 PASS`; the generated Provider probe was
  reported stale because each execution emitted a different physical path.

Root cause: the production TypedAST backend overwrites the provisional entry
plan's declaration/section/line with its authoritative frozen generation row,
while the test-only scalar Provider probe called the shared plan builder and
kept `GetScriptSectionName()` unchanged. The repair does not sanitize drive
letters, `Saved`, or GUIDs. It finds the matching
`FAngelscriptJITGeneratedFunction` by stable `FunctionKey`, requires a nonempty
canonical declaration, a `/Angelscript/` logical section and a nonzero line,
then uses that same frozen metadata for Provider emission. Missing authority
fails generation closed with a stable diagnostic.

Fresh GREEN evidence:

- `Saved/Build/typed-aot-provider-logical-source-green-generator/20260815_130356_253_77e9a8f7`
  — focused `AngelscriptTest` generator build PASS.
- `Saved/Commandlet/typed-aot-provider-logical-source-regenerate/20260815_130415_030_0ea81798`
  — maintained `AngelscriptTestJIT -Mode=Generate` commandlet PASS; only the
  Provider probe changed. Post-generation inspection found zero
  `Saved/Automation` or drive-qualified source strings, two stable
  `/Angelscript/Game/ASStaticJITAotFixture.as` occurrences, and one
  `FScopeTypedASTJITExecutionFrame`.
- `Saved/Build/typed-aot-provider-logical-source-green-provider/20260815_130500_435_c556d573`
  — regenerated `AngelscriptTestJIT` Provider module build PASS.
- `Saved/Tests/typed-aot-provider-logical-source-green/20260815_130510_828_1aac895a`
  — two-fresh-Engine byte-deterministic `GeneratedOutputVerify` `1/1 PASS`.
- `Saved/Tests/typed-aot-provider-logical-source-runtime-green/20260815_130608_454_564078f3`
  — compiled generated Raw/VM/Parms Provider entry execution `1/1 PASS`.

This closes the generated-artifact regeneration/determinism sub-slice. Tasks
4.11–4.12 remain open for direct helper frames, mixed route nesting, public
queries, and self/mutual recursion budget coverage.

### Direct Typed helper call and internal-frame wrapper slice

The existing call-closure planner already classified eligible direct script
helpers and recursive SCCs, but the Typed emitter/backend still rejected every
such closure. This slice added the two provider-neutral primitives required to
cross that boundary without introducing `FAngelscriptJITExecutionContext`:

- a direct-script call plan that evaluates HIR operands in the maintained
  compiler order, binds them back to formal parameter order, calls a stable
  provider-internal helper symbol with the caller's existing
  `FScriptExecution&`, and checks `Execution.bExceptionThrown` immediately;
- an internal helper wrapper plan that resolves the helper's current
  `asIScriptFunction` from its already-adopted numeric Provider reference slot,
  enters `FScopeTypedASTJITExecutionFrame`, consumes the shared native recursion
  budget, stops before the body when the guard is inactive, and restores the
  outer frame through RAII on every exit.

Fresh RED/GREEN evidence:

- `Saved/Build/typed-aot-direct-helper-emission-red/20260815_131103_854_9a02699e`
  — expected compile RED because the direct-script emission plan/API did not
  exist.
- `Saved/Build/typed-aot-direct-helper-emission-green-build/20260815_131228_531_72add3f2`
  — full Editor target PASS after adding the direct-call plan/analyzer/emitter
  path and relinking Runtime, Editor and Test.
- `Saved/Tests/typed-aot-direct-helper-emission-green/20260815_131301_481_642c6443`
  — exact generated-output test `1/1 PASS`; it proves reverse HIR evaluation,
  formal call ordering, shared `Execution`, immediate exception checking, and
  absence of `FAngelscriptJITExecutionContext`.
- `Saved/Build/typed-aot-helper-frame-wrapper-red/20260815_131426_517_2d43441b`
  — expected compile RED because the internal-helper wrapper plan/emitter API
  did not exist.
- `Saved/Build/typed-aot-helper-frame-wrapper-green-build/20260815_131808_741_53e32841`
  — fresh full Editor target PASS (`8` actions, Runtime and Test relinked).
- `Saved/Tests/typed-aot-helper-frame-wrapper-green/20260815_131832_064_357bb7ef`
  — exact internal-helper frame/depth generated-output test `1/1 PASS`.

This is not task 4.12 completion. The production TypedAST backend still needs
to assign helper ScriptFunction reference slots across the complete root
closure, emit deterministic forward declarations/bodies/wrappers, concatenate
them into the owning module's `.jit.cpp`, and prove real root -> helper plus
self/mutual recursion at runtime. Task 4.11 also remains open for the mixed
JIT/bridge/VM public-query matrix and frame restoration coverage.

### Production direct-helper closure assembly and fallback provenance

The production `FAngelscriptTypedASTJIT` backend now consumes the verified
direct-call closure instead of stopping at the emitter primitives. For every
root it requires the same-compilation verified HIR of every direct closure
member, resolves the authoritative frozen source row and entry plan, derives
the helper's `ScriptFunction` reference and expected ABI from the root's
compiler dependency set, combines and deterministically sorts helper plus
environment references, and assigns slots from that one immutable set. It
then emits root-specific readable helper-body/wrapper symbols, forward
declarations, non-root bodies, frame/depth wrappers and the root adapters into
the owning module translation-unit template. The symbol identity includes the
helper and owning-root stable keys, so a helper reachable from multiple roots
cannot create duplicate definitions in the strict one-AS-module/one-jit.cpp
layout. No Engine-local function ID or function pointer is persisted.

The first fixture attempt placed the new global helper/root pair in the
existing mixed descriptor module. Clean Capture intentionally rejects that
shape because it contains the struct/delegate/class graph, so the apparent RED
was a fixture-boundary failure rather than the missing closure implementation:

- `Saved/Tests/typed-aot-production-helper-red/20260815_132513_059_2dfdc8aa`
  — expected assertion failure caused by the helper dependency being absent;
  the log explicitly reported the Clean Capture module-shape rejection.

The fixture was corrected by appending the source to the already
capture-compatible emit module. This produced the intended production RED:

- `Saved/Build/typed-aot-production-helper-red-fixture/20260815_132624_642_c3acff52`
  — test-only fixture build PASS.
- `Saved/Tests/typed-aot-production-helper-red-2/20260815_132645_626_1730cb21`
  — exact test `0/1 PASS`; the verified closure was `Functions=2 Calls=1`, and
  the production backend rejected it with
  `TypedASTJITProviderClosureUnsupported` because direct helpers had not yet
  been assembled.

After the production implementation, the full Editor build passed and every
body/reference/wrapper assertion passed, but the final test assertion still
required the helper to be absent from the complete Provider output:

- `Saved/Build/typed-aot-production-helper-green-build/20260815_133433_714_9b1f44ae`
  — full Editor target PASS.
- `Saved/Tests/typed-aot-production-helper-green/20260815_133453_333_cbce159f`
  — exact test `0/1 PASS`; the only failure was the overly broad
  `ProviderOutput` helper-absence assertion.

Root-cause review against `design.md` and the backend spec showed that this
assertion conflated two contracts. The helper must not publish an independent
TypedASTJIT/UASFunction entry, but generation deliberately retains
per-function `typed-ast -> bytecode -> VM` fallback, and BytecodeJIT plus
TypedASTJIT entries may coexist in one module TU. The generator's pointer-free
`ActualBackendId` and ordered `BackendAttempts` are the authoritative evidence.
The test now proves that the root is `typed-ast`, the ordinary helper's
independent compatibility entry is `bytecode`, its first Typed attempt is
recorded `Unsupported`, and the root module source still owns the private
Typed helper body/wrapper.

Fresh GREEN evidence:

- `Saved/Build/typed-aot-production-helper-route-green-build/20260815_134006_345_792e1e2a`
  — full Editor target PASS (`4` actions; test module rebuilt and relinked).
- `Saved/Tests/typed-aot-production-helper-route-green/20260815_134026_587_9a48eb05`
  — exact production direct-helper test `1/1 PASS`.

This closes deterministic production assembly for a non-recursive scalar
root-to-helper closure. Tasks 4.11–4.12 remain open: the next slices must prove
root -> helper -> bridge/VM nesting, bridge-row/reference-slot de-duplication,
self/mutual recursion, bounded script exception behavior, runtime execution,
and frame restoration rather than generated-text structure alone.

### Root-to-helper shared native bridge closure

The production closure now proves one additional mixed path rather than only
direct script-helper calls. A TypedASTJIT root and its emitted internal helper
both call the same provider-private scalar binding. The frozen closure assigns
two call-site records to one stable environment reference slot and one stable
metadata-row symbol. Generated implementation code uses the typed
`AngelscriptTypedASTJIT::InvokeBound<int32, int32, int32>` bridge from both
functions and does not introduce `FAngelscriptJITExecutionContext`.

The first run did not reach the intended production assertion:

- `Saved/Build/typed-aot-helper-shared-bridge-red-build/20260815_134455_698_32498afd`
  — full Editor target build PASS for the new test fixture.
- `Saved/Tests/typed-aot-helper-shared-bridge-red/20260815_134515_623_a3c637ae`
  — fixture-authority RED. The isolated generation graph registered a private
  callable owned by `AngelscriptTest` but had not included that module in its
  frozen `KnownNativeCallModules`, so generation correctly failed closed with
  `UnknownOwningModule` before TypedASTJIT emission.

The fixture now declares `AngelscriptTest` as a known native-call module. That
produced the true behavior RED:

- `Saved/Build/typed-aot-helper-shared-bridge-red-fixture/20260815_134613_308_87288e67`
  — corrected fixture build PASS.
- `Saved/Tests/typed-aot-helper-shared-bridge-red-2/20260815_134632_697_8951deff`
  — exact test `0/1 PASS`; both call sites already shared one stable symbol,
  one reference slot and one environment reference, but the generated module
  defined the immutable row once per emitted member body instead of once per
  root closure.

The emitter now exposes closure-scope bridge-row emission. Standalone body
emission retains its previous default, while the production backend disables
per-member row output, emits the de-duplicated rows once from the closure-wide
native-call plan, and places them after all body/wrapper forward declarations
but before any member definition. This ordering lets an earlier helper body use
the shared row without depending on root-body order. Conflicting metadata for
the same stable symbol remains a deterministic failure rather than silently
choosing one row.

Fresh GREEN evidence:

- `Saved/Build/typed-aot-helper-shared-bridge-green-build/20260815_134907_864_9474100d`
  — full Editor target PASS (`16` actions; Runtime, Editor and Test rebuilt and
  relinked).
- `Saved/Tests/typed-aot-helper-shared-bridge-green/20260815_134934_247_29009cd4`
  — exact production closure test `1/1 PASS`; it proves two call-site metadata
  records, one environment reference, one reference slot, one immutable row,
  readable direct-helper use and typed bridge emission.
- `Saved/Tests/typed-aot-helper-shared-bridge-emitter-regression/20260815_135024_834_e59c1fb7`
  — complete TypedASTJIT generated-output class `14/14 PASS`, preserving the
  existing scalar, bridge, helper-frame and Provider golden contracts.

This closes the generated-output and production-packaging portion of
root -> direct helper -> native bridge nesting. It does not yet close tasks
4.11 or 4.12: self/mutual recursion, runtime recursion exhaustion, mixed
JIT/VM public-query behavior and every-exit frame restoration still require
runtime evidence.

### Production self and mutual recursion closure emission

Two production-generation fixtures now compile real source through the
generation-only Engine and assert the complete immutable closure rather than a
synthetic graph:

- one UFUNCTION root calling itself;
- one UFUNCTION root and one ordinary helper forming a mutually recursive SCC.

Both fixtures prove same-compilation verified HIR, exact compiler-owned
`ScriptFunction` dependencies for every back edge, one de-duplicated stable
reference per callee, readable recursive wrapper symbols, the Provider root's
stable `{SYMBOL_PREFIX}_TypedBody` ABI symbol, frame/budget guards, immediate
exception propagation and absence of `FAngelscriptJITExecutionContext`.

The first attempted exact run used the CQTest theme prefix without the CQTest
class-name segment and therefore matched no test. This was a runner selector
mistake, not behavior evidence:

- `Saved/Tests/typed-aot-production-self-recursion-red/20260815_135831_080_56e9f5d3`
  — no tests matched because the target omitted
  `FAngelscriptStaticJITGenerationEngineTests`.

With the authoritative registered names, both fixtures reached the intended
production RED:

- `Saved/Build/typed-aot-production-recursion-red-build/20260815_135806_647_4b732d39`
  — test-only Editor build PASS.
- `Saved/Tests/typed-aot-production-self-recursion-red-2/20260815_135925_839_0c38e8a6`
  — self-recursion `0/1 PASS`; the closure was otherwise eligible with
  `Functions=1 Calls=1 Components=1 Required=RecursionBudget`, but production
  emission reported that the call had no reviewed C++ route.
- `Saved/Tests/typed-aot-production-mutual-recursion-red/20260815_140007_482_b5b6a694`
  — mutual recursion `0/1 PASS`; the complete SCC was otherwise eligible with
  `Functions=2 Calls=2 Components=1 Required=RecursionBudget` and failed at the
  same emission-route boundary.

Root cause was in the pure closure planner, before C++ emission. A selected
root retains `ClosureFunctionDisposition::Root`; when that root appeared as a
callee on a self or mutual back edge, `CallDispositionFor()` mapped only
ordinary `DirectScript` and `InternalSemanticHelper` functions. `Root` fell
through to `Unsupported`, even though SCC classification and recursion
capability validation had already succeeded. The minimal production fix maps a
root used as a callee to `CallDisposition::DirectScript`, allowing the existing
stable-reference, wrapper, frame and recursion-budget path to handle the edge.

An intermediate post-fix run reached generated output but the tests expected a
readable `ASJIT_HelperBody_<root>` symbol for the selected root. That assertion
was too broad: non-root bodies use readable helper-body names, while the root
must retain the Provider ABI placeholder `{SYMBOL_PREFIX}_TypedBody`; recursive
re-entry is made readable by its `ASJIT_Helper_<AS-name>_...` adapter. The tests
now assert this actual two-layer contract rather than changing the Provider ABI.

Fresh GREEN evidence:

- `Saved/Build/typed-aot-production-recursion-green-build/20260815_140124_550_27ad3ccf`
  — Runtime production fix build PASS.
- `Saved/Build/typed-aot-production-recursion-green-test-contract/20260815_140304_314_eed1afbd`
  — corrected test-contract build PASS.
- `Saved/Tests/typed-aot-production-recursion-green-2/20260815_140326_080_99d3d0b7`
  — production self/mutual generation tests `2/2 PASS`.

This closes generation and packaging of bounded recursive wrappers, but task
4.12 remains open until checked-in AOT output is compiled and executed to prove
finite recursion results, maintained script exception before native stack
exhaustion, and every-exit frame restoration. Task 4.11 remains open for its
full mixed JIT/bridge/VM public-query matrix.

### Checked-in TypedAST recursion provider runtime RED

The AOT fixture now materializes a separate
`ASStaticJITTypedRecursionFixture` source module containing:

- a reflected self-recursive scalar root;
- a reflected root and ordinary helper forming a mutually recursive SCC.

The first TDD step deliberately compiles this source in the runtime fixture
Engine without yet adding it to the provider generation graph. The focused
runtime test requires both roots to have current generated VM/raw/Parms entries,
executes their finite cases, then lowers the shared `FScriptExecution` native
frame limit to `8` and requires both deeper calls to publish the maintained
stack-overflow exception while restoring frame depth, active function and
active execution state.

Authoritative RED evidence:

- `Saved/Build/typed-aot-runtime-recursion-red-build/20260815_141033_963_c1458d84`
  — Editor build PASS.
- `Saved/Tests/typed-aot-runtime-recursion-red/20260815_141055_532_1cb89ddc`
  — exact test `0/1 PASS`; source compilation found the new function, but
  `RequireJitEntries` failed on
  `TypedAST self recursion should select generated Native code`.

This is the intended provider-authority RED: it proves the new test is not
using the older BytecodeJIT recursion fixture or a hand-registered probe. The
next GREEN step must add the module to the maintained TestJIT generation graph,
publish checked-in generated C++, compile that source in
`AngelscriptTestJIT.dll`, and pass through the ordinary runtime provider route.

### Checked-in TypedAST recursion generation and runtime propagation RED

The recursion module is now part of the maintained TestJIT generation graph.
Generation also has a permanent test gate requiring both reflected roots to be
emitted by the `TypedAST` backend. This prevents a successful BytecodeJIT
fallback from being mistaken for TypedAST coverage.

The first gated generation run correctly rejected the fixture's `<=` operator:
the completed initial scalar slice currently promises `+`, `-`, `*`, and `>`;
`<=` remains part of the unfinished scalar/control-flow expansion. Rewriting
the fixture as the equivalent `Value > 0` form kept this runtime proof within
the current contract rather than expanding production scope incidentally.

Fresh generation/build evidence:

- `Saved/Build/typed-aot-runtime-recursion-typed-green_01_baseline_build/20260815_141547_748_25250d80`
  — baseline Editor build PASS.
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-runtime-recursion-typed-green_02_generate/20260815_141601_595_13b966bb`
  — maintained commandlet generation PASS with both reflected roots reporting
  `ActualBackendId=typed-ast`.
- `Saved/Build/typed-aot-runtime-recursion-generated-build/20260815_141643_101_8cf7e09e`
  — checked-in generated source compiled and linked into
  `UnrealEditor-AngelscriptTestJIT.dll` PASS.

The generated output contains a TypedAST self-recursive root and a TypedAST
mutually recursive root/helper SCC, including readable helper adapters,
`FScopeTypedASTJITExecutionFrame` guards, immediate exception checks and no
`FAngelscriptJITExecutionContext` dependency. Finite self and mutual calls reach
the generated Native route and produce the expected results.

The deep-recursion runtime case currently exposes a narrower production RED:

- `Saved/Tests/typed-aot-runtime-recursion-green/20260815_141658_141_ee0b752d`
  — exact runtime test `0/1 PASS` at
  `AngelscriptStaticJITAotTests.cpp:953`.

The first interpretation was that the native frame guard had emitted the
maintained stack-overflow log and only the exception result was lost. A
line-by-line check of `Automation.log` disproved that interpretation: no such
log was emitted before the assertion aborted. `asCContext::Execute()` installs
`FScopeSetActiveContext`, which saves the caller's `activeExecution` and then
sets that TLS slot to null. The JIT-owned `FScriptExecution(this)` therefore
does not inherit the caller's test-supplied frame-depth/limit pointers and uses
its default limit; input `32` legitimately finishes instead of reaching the
test limit `8`.

The next RED separates the two boundaries: a direct RawEntry call must prove
that the generated guard records the exception and restores frame state when
given an explicit low-budget `FScriptExecution`; the ordinary Context entry
must then prove how a configured call-scoped budget is handed across
`FScopeSetActiveContext`. No production fix will be made until that comparison
confirms the exact failing boundary. Task 4.12 stays open until the failure
record, `bExceptionThrown`, context result, and every-exit frame restoration are
proven end to end.

The boundary comparison is now authoritative:

- `Saved/Build/typed-aot-recursion-raw-boundary-red-build/20260815_142724_130_60da36d4`
  — diagnostic test build PASS.
- `Saved/Tests/typed-aot-recursion-raw-boundary-red/20260815_142744_278_afb78056`
  — focused runtime test `0/1 PASS` at the unchanged Context expectation.

Before reaching that final assertion, direct RawEntry execution with limit `8`
emitted the maintained recursion failure, set `bExceptionThrown`, populated the
first-failure record with the exact message, restored native frame depth to
zero, and restored the previous active function/execution. The later
`Context->Execute()` with finite input `32` still returned
`asEXECUTION_FINISHED`, exactly confirming that the generated guard is correct
and that the outer test-owned Execution limit is intentionally isolated by the
public Context scope. The production public-entry proof will therefore execute
beyond `FScriptExecution::DefaultNativeJITFrameLimit` while suppressing only the
expected exception log; it will assert the returned public exception payload
directly instead of treating a test-only outer Execution as Context
configuration.

### Task 4.12 final: bounded TypedAST recursion and frame restoration GREEN

The corrected public-entry comparison confirmed both execution boundaries:

- `Saved/Tests/typed-aot-recursion-public-budget/20260815_143013_819_54c911fe`
  — exact generated AOT recursion test `1/1 PASS`. Finite self and mutual
  recursion execute through the checked-in TypedAST Provider. Direct RawEntry
  execution with an explicit limit of `8` records the maintained stack-overflow
  exception and restores native depth, active function and active execution.
  Public `asCContext` execution beyond
  `FScriptExecution::DefaultNativeJITFrameLimit` returns
  `asEXECUTION_EXCEPTION` with the exact maintained message and restores the
  outer TLS state.
- `Saved/Tests/typed-aot-recursion-capability/20260815_143158_641_a7c0bca7`
  — call-closure prefix `13/13 PASS`, including the recursive-SCC case that
  rejects a frame-only profile as
  `UnsupportedExecutionControl/RecursionGuardUnavailable` and accepts the same
  SCC only after `RecursionBudget` is present.

The final requirement-by-requirement audit used current generated output and
fresh focused verification:

- `Saved/Tests/typed-aot-recursion-production-generation-final/20260815_143631_565_fbb0fb7c`
  — Production TypedAST generation prefix `4/4 PASS`: direct helper ownership,
  root/helper bridge-state sharing, complete bounded mutual SCC emission and
  bounded self-recursion emission.
- `Saved/Tests/typed-aot-recursion-frame-restore-final/20260815_143732_486_2672d966`
  — exact Runtime frame/depth case `1/1 PASS`; root, helper and recursion-failure
  exits share the active execution and restore every outer state.
- The checked-in
  `ASStaticJITTypedRecursionFixture.d19c9e37.EditorDevelopment.jit.cpp`
  contains a guarded raw root plus guarded internal self-recursion helper, and
  a guarded mutual root plus guarded odd/even SCC helpers. Every TypedAST edge
  passes the same `FScriptExecution&`, so all scopes consume the same native
  depth/limit rather than creating independent budgets.

The first official checked-in verification run exposed two independent AOT
regressions rather than a recursion failure:

- `Saved/Tests/typed-aot-recursion-final_02_tests/20260815_143840_749_7b8a6f07`
  — `29/31 PASS`. `NestedGeneratedExceptionPropagates` received the generated
  debug-frame module spelling `ASStaticJITAotFixture` instead of the canonical
  processed virtual section, and the large-fixture fact test retained the old
  `46 + 3 = 49` count after `SemanticScalarBranch` raised the current graph to
  `47 + 3 = 50`.

The canonical-section root cause was in Runtime normalization, not generated
recursion. BytecodeJIT debug frames intentionally carry a readable module name;
`TryResolveStableSectionName()` tried only that spelling against absolute,
relative and virtual code-section paths. It now preserves that first lookup and,
when it cannot match, resolves the throwing function's authoritative script
section through the same current `FAngelscriptModuleDesc::Code` table. It does
not guess a path or persist a generated-file string. The fact assertion and its
comment now match the authoritative current graph count.

Fresh RED-to-GREEN and final workflow evidence:

- `Saved/Build/typed-aot-recursion-verify-fixes-build/20260815_144222_627_ac542de5`
  — incremental Editor build PASS, `7/7` actions including Runtime and test DLLs.
- `Saved/Tests/typed-aot-recursion-exception-section-green/20260815_144250_612_5cf516a7`
  — exact nested exception metadata `1/1 PASS`; public section is again
  `/Angelscript/Game/ASStaticJITAotFixture.as`.
- `Saved/Tests/typed-aot-recursion-generation-facts-green/20260815_144332_012_a87a41b3`
  — exact complete-graph/no-cache fact test `1/1 PASS` with `50` primary-module
  functions.
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-recursion-final-green_01_verify/20260815_144412_116_a5ce0806`
  — authoritative checked-in Provider verify `ExitCode=0`; current generation
  matches the checked-in module sources and manifests.
- `Saved/Tests/typed-aot-recursion-final-green_02_tests/20260815_144434_612_10af4b90`
  — complete maintained AOT prefix `31/31 PASS`, zero failures and zero skips.

Task 4.12 is therefore closed. Task 4.11 deliberately remains open: the focused
live frame/depth coverage is now authoritative, but its full public query matrix
across VM, top-level/nested JIT, system calls and mixed JIT-to-VM stacks is a
separate unfinished requirement.

### Task 4.11: unified VM/JIT activation chain and public-query matrix

Task 4.11 began from the already-green frame/depth and generated-wrapper work,
then added a real public-query characterization rather than inferring debugger
behavior from emitted text. The first test fixture used `NewObject<UObject>()`
for synthetic `this` values. UE 5.8 correctly rejected that fixture because
`UObject` is abstract, so this was not accepted as a behavior RED. The fixture
was corrected to use concrete transient `UCurveFloat` instances before any
production change:

- `Saved/Tests/typed-aot-public-queries-red/20260815_145424_100_ffd373d6`
  — invalid fixture observation; abstract `UObject` construction failed before
  the intended public-query assertion.
- `Saved/Build/typed-aot-public-queries-red-fixture-build/20260815_145546_649_d2d4388c`
  — concrete-fixture rebuild PASS, `4/4` actions.
- `Saved/Tests/typed-aot-public-queries-red-valid/20260815_145608_972_bd2228f7`
  — authoritative `0/1 PASS` RED. File, line, formatted position, callstack and
  active function were already correct, while
  `GetAngelscriptExecutionThisObject(0)` returned null for the live JIT root.

The first root cause was that `GetAngelscriptExecutionThisObject()` consulted
only `asGetActiveContext()`. `FScriptExecution` intentionally clears the VM
context while a JIT entry is active, even though
`FScopeJITDebugCallstack` owns the current frame's exact `ThisObject`. The first
minimal fix traversed the current execution's debug frames, then its prior
execution/context, retained the existing VM type validation, and rejected
negative or out-of-range frame indices:

- `Saved/Build/typed-aot-public-queries-green-build/20260815_145749_723_40a11658`
  — incremental Runtime/test build PASS, `4/4` actions.
- `Saved/Tests/typed-aot-public-queries-green/20260815_145813_489_7094fa7c`
  — exact top-level/nested JIT plus system-call query case `1/1 PASS`.

The mixed test then compiled a real reflected AngelScript `UCLASS`, created a
real generated instance, executed its `Probe()` method through `asCContext`,
and captured public queries from a raw line callback. The process-wide line
callback capability flags are guarded with `TGuardValue` and restored after the
test. Without this explicit test-only enablement the callback is deliberately
suppressed, so that initial observation was fixture characterization rather
than a production failure:

- `Saved/Build/typed-aot-vm-mixed-query-red-callback-build/20260815_150700_612_75161b73`
  — callback-guard fixture build PASS, `4/4` actions.
- `Saved/Tests/typed-aot-vm-mixed-query-red-valid/20260815_150721_183_9b1d4826`
  — authoritative mixed `0/1 PASS` RED. Pure VM queries passed, but the VM
  callback's public callstack could not see the outer `MixedRoot` JIT frame;
  the outer JIT `this` would likewise be unreachable.

The second root cause was `FScopeSetActiveContext`: its private stack member
remembered the prior `FScriptExecution*`, but TLS published only the new VM
context and set `activeExecution` to null. A one-level suspended pointer would
fix only JIT-to-VM and fail the next VM-to-JIT-to-VM alternation. The maintained
fork now publishes a transient, stack-owned `FScriptActivation` chain in
`asCThreadLocalData`. Every `FScriptExecution` pushes an execution node and
every `FScopeSetActiveContext` pushes a context node; both assert LIFO teardown
and restore the previous node. The chain carries no persistent Engine/module/
UObject ownership and supports arbitrary transient alternation:

```text
current VM or JIT activation
  -> previous JIT or VM activation
  -> previous ...
```

`GetStackTrace()` and `GetAngelscriptExecutionThisObject()` consume this common
top-to-bottom chain, with the former active-execution/context traversal retained
as a compatibility fallback for scopes that predate activation publication.
This makes pure VM, pure JIT, VM-to-JIT, JIT-to-VM, and deeper alternation share
one ordering contract rather than attempting to merge two unrelated TLS slots.

Fresh implementation evidence:

- `Saved/Build/typed-aot-mixed-activation-green-build/20260815_151107_065_66060310`
  — Runtime header fan-out rebuild PASS, `130/130` actions in approximately
  `126` seconds.
- `Saved/Tests/typed-aot-vm-mixed-query-green/20260815_151320_346_6838428b`
  — real pure-VM plus JIT-to-VM public-query case `1/1 PASS`.
- `Saved/Tests/typed-aot-debugcallstack-activation-green/20260815_151429_554_f77c0012`
  — complete StaticJIT DebugCallstack prefix `5/5 PASS`.
- `Saved/Tests/typed-aot-activation-vm-debug-regression/20260815_151911_847_a7f1afeb`
  — maintained AngelScript `Runtime.Debug` prefix `9/9 PASS`, covering raw VM
  Callstack, ThisPointer, NestedContext, line callback and related lifecycle
  behavior.

The first attempt to launch the VM regression from the physical worktree path
was rejected before UE startup because this isolated checkout intentionally
stores `ProjectFile=V:\\AngelscriptProject.uproject`. The runner correctly
requires project root and project file to share one normalized path domain.
All authoritative build/test commands therefore continue from the existing
`V:\\` SUBST root; no `AgentConfig.ini` or primary-workspace setting was
changed. A separate earlier short caller timeout also left the already-started
UE child alive; it was monitored to its one final report instead of launching a
duplicate editor and contending for the engine build/live-coding locks.

The final requirement audit found that all scenarios existed but the system
and mixed cases asserted only subsets of the public surface. The test now uses
`FPublicQueryMatrixRow` plus one verifier for every row. Each top-level JIT,
direct helper, system call, nested JIT, restored helper/root, pure VM, mixed
JIT-to-VM, and restored mixed-root row checks exact file/line, formatted
position, required callstack members, formatted callstack equality, top-frame
`this`, and `asGetActiveFunction()`. Additional stack-frame queries prove the
nested helper/root and mixed outer-JIT `this` values. The focused live-top-frame
`GetAngelscriptExecutionFileAndLine()` regression remains independent.

Final task-4.11 verification:

- `Saved/Build/typed-aot-public-query-matrix-build/20260815_152248_426_71565423`
  — table-driven test rebuild PASS, `4/4` actions.
- `Saved/Tests/typed-aot-public-query-matrix-green/20260815_152310_248_8f161a8f`
  — complete runtime/public-query DebugCallstack prefix `5/5 PASS`.
- `Saved/Tests/typed-aot-task411-generated-output/20260815_152414_754_58a6e428`
  — TypedAST generated-output prefix `14/14 PASS`; root and internal helper
  wrappers each own an `FScopeTypedASTJITExecutionFrame`, thread the same
  `FScriptExecution&`, stop before the body when inactive, and keep pure body
  signatures free of `FAngelscriptJITExecutionContext`.
- `Saved/Tests/typed-aot-task411-production-closure/20260815_152450_905_543886b3`
  — production root/helper/bridge/recursive closure prefix `4/4 PASS`; direct
  helpers and bridge rows are packaged inside the owning root closure with
  bounded frame wrappers and no generic execution-context dependency.

Task 4.11 is closed from direct runtime, generated-output and maintained-fork
regression evidence. This does not claim task 4.13 instrumentation hooks or
task 4.15 exception-matrix behavior; both retain their independent RED/GREEN
work.

## Safe-point role prerequisite and reference-shape fail-closed repair (2026-08-15)

This slice advances the source/safe-point prerequisite for task 4.13 without
claiming that instrumentation task complete. The maintained-fork HIR now owns
an explicit safe-point role vocabulary (`FunctionEntry`, `Statement`, `Call`,
`LoopEntry`, `LoopBackedge`, `Transfer`, `SwitchInvalidValue`, and `Return`),
and normalized dumps emit `safePoint=<Role>` only when a role is present. The
current real compiler capture assigns `FunctionEntry` to the root block,
`Statement` to the already-supported local/expression/if statements, `Call`
to resolved calls, and `Return` to return statements. `LoopEntry`,
`LoopBackedge`, `Transfer`, and `SwitchInvalidValue` deliberately remain
unclaimed until tasks 2.3-2.4 capture the corresponding structured control
flow.

The focused source/safe-point test first failed because the compiled root had
no entry role and then passed after the compiler-path assignment. The broader
TypedSemanticIR prefix initially exposed a system-call fixture problem. The
captured HIR was null before VM execution and carried no capture diagnostic;
production capture itself had not rejected the call. The test had built a
capture-off module, then attempted to call `SetTypedSemanticIRCapture(true)`
on the same Engine. `RequestBuild()` intentionally freezes the private
engine-wide capture profile at the first build, so the ignored setter failure
left the second module capture-off. The fix preserves the pre-build-only
production invariant and instead uses two test-owned Engines configured before
their respective first builds.

Comparing those two Engines then exposed an expected representation detail:
`asBC_CALLSYS` is a pointer-argument opcode and embeds the owning Engine's
`asCScriptFunction*`. Raw bytecode words across two live Engines therefore
cannot be equal even when compilation is otherwise identical. The regression
now decodes instructions with `asBCInfo`/`asBCTypeSize`, requires exactly one
`CALLSYS` on each side, zeroes only its pointer operand words, and requires
every remaining opcode and operand word to match exactly. It separately
checks VM behavior, HIR target kind and Engine-local function ID, formal/actual
mapping, evaluation order, verifier result, and normalized dump. This is a
test-only comparison normalization; no pointer is added to HIR or generated
provider identity.

Evidence for that system-call closure:

- `Saved/Tests/typed-aot-safepoint-system-call-phase-red/20260815_154051_595_3610f9a9`
  — authoritative pre-execution RED showing null HIR after the invalid
  post-build profile mutation.
- `Saved/Build/typed-aot-safepoint-system-call-normalized-build/20260815_154553_483_6a8f9c46`
  — normalized cross-Engine test rebuild PASS.
- `Saved/Tests/typed-aot-safepoint-system-call-normalized-green/20260815_154611_329_ac7bcf18`
  — exact system-call case `1/1 PASS`.
- `Saved/Tests/typed-aot-safepoint-role-prefix-green-2/20260815_154649_333_dfe20956`
  — complete UE TypedSemanticIR prefix `11/11 PASS` before the reference-marker
  repair below.

The required shared-fork Standalone gate then produced a distinct valid RED:
the `int UnsupportedReference(int&in Value)` dump contained neither operands
nor the expected `Unsupported(Reference)` marker. The builder's
`AllowBorrowedInputReference` path had conflated two independent decisions:
a borrowed `&in` parameter has no callee-owned destruction and may retain a
verified-empty cleanup plan, but Typed AOT v1 still does not support reference
shapes and must preserve an explicit unsupported expression. The production
fix removes that suppression from symbol unsupported-marker construction while
leaving cleanup-free parameter classification unchanged. Reference-shaped HIR
therefore now fails closed for Typed AOT without inventing cleanup work or
changing VM behavior.

Final repair evidence:

- `Saved/StandaloneTests/typed-aot-safepoint-reference-diagnostic_01_Standalone`
  — failure-only normalized dump that localized the missing Reference marker.
- `Saved/StandaloneTests/typed-aot-safepoint-reference-marker-green_01_Standalone/20260815_155105_066_a8e62668`
  — full Standalone Debug build/CTest gate `20/20 PASS`; the branch contains
  the additional TypedSemanticIR CTest, so this is the current local suite
  count rather than the older `19/19` repository baseline.
- `Saved/Build/typed-aot-safepoint-reference-marker-ue-build/20260815_155209_315_c82ae8fc`
  — latest Runtime/test incremental UE build `4/4` actions PASS.
- `Saved/Tests/typed-aot-safepoint-reference-marker-ue-green/20260815_155527_775_face7c25`
  — complete post-repair UE TypedSemanticIR prefix `11/11 PASS`.
- `Saved/Tests/typed-aot-reference-marker-eligibility-green/20260815_155616_888_62fc2dfd`
  — complete TypedASTJIT eligibility prefix `26/26 PASS`, proving reference
  shapes remain rejected while the supported scalar/enum surface stays
  eligible.

Both parent and plugin `git diff --check` report no whitespace errors; their
only output is the existing LF-to-CRLF checkout warning. No task checkbox is
advanced from this prerequisite slice: task 4.13 remains open until real
loop/transfer capture and profile-approved runtime hooks exist, and tasks
2.3-2.4 remain the next implementation dependency.

## First real structured-control-flow slice: `while` (tasks 2.3-2.4 in progress, 2026-08-15)

The first structured-control-flow TDD slice targets one real maintained-fork
`while` compilation rather than attempting to land every loop and transfer in
one patch. The test uses two independently configured Engines, compiles the
same scalar countdown function with capture off/on, compares every bytecode
word, executes inputs `0`, `1`, and `4` through VM, and then inspects only the
compiler-owned HIR. It requires one `While` node with a bool condition and an
owned body Block containing the two source assignments.

The first test attempt was not accepted as RED evidence: it assigned directly
to an AngelScript value parameter, which this fork treats as const, so both
modules failed source compilation before HIR capture. The fixture was corrected
to copy the parameter into a local `Current` value. The next run was the
authoritative RED: source compilation, bytecode equality, and VM behavior all
succeeded, verified HIR was published, but no `While` statement existed because
the existing capture hooks flattened the compiled body statements directly
into the parent Block.

The production change stays inside the existing recursive compiler path:

- `CompileWhileStatement()` retains the already-resolved condition expression,
  marks the parent Block before compiling the body, detaches the compiled body,
  and appends a structured `While(condition, body)` only after the ordinary
  bytecode work is complete.
- Detached loop bodies are normalized to an owned Block even for an unbraced
  single source statement. A source Block is reused rather than double-wrapped.
  This leaves nested `Return`, `Call`, and ordinary statement roles available
  instead of overwriting them with a loop-level role.
- The body Block carries `phase=Body safePoint=LoopEntry`.
- The `While` statement carries
  `phase=Condition safePoint=LoopBackedge`, meaning that its backedge targets
  condition evaluation. The condition expression keeps its own role, so a
  direct call condition does not lose `safePoint=Call`.
- The verifier rejects an out-of-range condition/body, a non-bool condition,
  a non-Block body, or inconsistent condition/body phase and role metadata.
  Ownership already treats `bodyStatement` as a lexical child, so the body can
  no longer remain simultaneously owned by the parent Block.
- The normalized dump now exposes `While condition=... body=...`, loop phase,
  and safe-point role. No emitter hook is implied by this metadata.

RED/GREEN evidence:

- `Saved/Build/typed-aot-structured-while-valid-red-build/20260815_160251_718_40329954`
  — corrected test fixture build `4/4` actions PASS.
- `Saved/Tests/typed-aot-structured-while-valid-red/20260815_160311_592_1b285b97`
  — exact `0/1 PASS` RED at the missing structured `While` assertion; module
  compilation and all earlier bytecode/VM assertions passed.
- `Saved/Build/typed-aot-structured-while-green-build/20260815_160644_769_3726424f`
  — maintained-fork Runtime and test rebuild `8/8` actions PASS.
- `Saved/Tests/typed-aot-structured-while-green/20260815_160704_988_e351fb2f`
  — exact structured-while case `1/1 PASS`.
- `Saved/Tests/typed-aot-structured-while-prefix-green/20260815_160755_559_e1b12154`
  — complete UE TypedSemanticIR prefix `12/12 PASS`.
- `Saved/StandaloneTests/typed-aot-structured-while-green_01_Standalone/20260815_160831_458_457b75ca`
  — independent maintained-fork/Standalone Debug build and CTest `20/20 PASS`.

Both repositories still pass `git diff --check` with only the existing line
ending warnings. Tasks 2.3-2.4 remain open because `for`, `do-while`,
`switch/case/default/fallthrough`, `break`, `continue`, nested nearest-legal
targets, and transfer cleanup have not yet been captured. Task 4.13 likewise
remains open: this slice records safe-point authority but emits no runtime
instrumentation hook.

### Structured `do-while` body-first slice

The next focused case freezes the semantic difference from `while`: a scalar
`do-while` increments `Current` in its body before testing `Current < Limit`.
VM inputs `(0, 1, 4)` return `(1, 1, 4)`, so a body/condition reversal cannot
pass as a result-only coincidence. Capture-off/on bytecode remains exactly
equal. The authoritative RED reached the one missing-`DoWhile` assertion only
after module compilation, bytecode comparison, VM execution, and verified HIR
publication had succeeded.

`CompileDoWhileStatement()` now marks/detaches the real body before compiling
the existing trailing condition, then appends `DoWhile(body, condition)` after
normal bytecode assembly. It reuses the same body-Block normalization and
metadata contract as `while`: the body is `phase=Body safePoint=LoopEntry`,
while the structural `DoWhile` is
`phase=Condition safePoint=LoopBackedge`. The verifier checks body ownership,
Block normalization, bool condition type, and both phase/role pairs; the dump
spells body before condition to preserve the frontend order.

Evidence:

- `Saved/Build/typed-aot-structured-do-while-red-build/20260815_161124_837_254b7b3a`
  — RED test fixture build `4/4` actions PASS.
- `Saved/Tests/typed-aot-structured-do-while-red/20260815_161142_401_2427dfa2`
  — exact `0/1 PASS` at the missing structured `DoWhile` assertion.
- `Saved/Build/typed-aot-structured-do-while-green-build/20260815_161305_756_c55d6fcd`
  — Runtime rebuild `5/5` actions PASS.
- `Saved/Tests/typed-aot-structured-do-while-green/20260815_161320_369_b461693c`
  — exact body-first case `1/1 PASS`.
- `Saved/Tests/typed-aot-structured-do-while-prefix-green/20260815_161357_363_8ead7bc0`
  — complete UE TypedSemanticIR prefix `13/13 PASS`.

The independent Standalone gate is intentionally batched with the immediately
following `for` maintained-fork slice rather than rerunning its approximately
45-second Package test for each adjacent loop form. No broad task checkbox is
advanced yet.

### Structured `for` four-phase and ordered-increment slice

The real parser grammar permits an initializer, an optional condition, and an
ordered comma-separated increment list before the loop body. The first model
audit found that the provisional statement stored only one
`incrementExpression`, which could not faithfully represent source such as
`Index = Index + Step, Step = Step + 1`. The maintained-fork model now owns both
an `incrementStatement` Block, which preserves lexical/source ownership for the
increment phase, and `incrementExpressions[]`, which gives later emitters the
exact ordered expression values without reparsing source or reverse-engineering
bytecode. Statement ownership collection and TypedASTJIT call-closure traversal
were updated for both surfaces.

The focused fixture compiles the same function in independent capture-off/on
Engines, compares every bytecode word, and executes limits `0`, `1`, `4`, and
`7`, producing `0`, `0`, `4`, and `10`. The result depends on executing
`Index = Index + Step` before `Step = Step + 1`, so reversed increment order
cannot pass accidentally. Its authoritative RED reached only the missing
structured `For` assertion after compilation, bytecode equality, all VM cases,
and verified HIR publication had succeeded.

`CompileForStatement()` now marks and detaches the real initializer,
compiler-resolved condition, ordered increment statements, and body while
leaving the existing bytecode/label assembly unchanged. Empty initializer,
condition, and increment phases remain legal; a present increment is normalized
to a Block. `AddFor()` assigns `Initializer`, `Increment`, and `Body` phases,
places `LoopEntry` on the body Block, and places `LoopBackedge` plus
`Condition` on the structural `For`. This deliberately preserves a condition
call's own `safePoint=Call` instead of overwriting it with loop metadata. The
verifier requires the optional condition to retain bool type, checks the
initializer/body phases, requires the increment Block and ordered expression
list to have identical lengths and exact element identity, and rejects a list
without its owner Block. The normalized dump exposes initializer, optional
condition, increment Block, ordered `increments=[...]`, body, phase, and
safe-point role.

The first post-production focused run exposed a test-harness-only issue after
all semantic checks had reached the increment list: CQTest has no `ToString`
conversion for `asTypedSemanticExpressionId`, so `AreEqual(Id, Id)` raises an
ensure even when the values match. The assertion now compares the IDs' stable
numeric `value` fields. No production behavior was changed for that harness
repair.

Evidence:

- `Saved/Build/typed-aot-structured-for-red-build/20260815_161820_294_ca788e12`
  — model/header and RED fixture rebuild `21/21` actions PASS.
- `Saved/Tests/typed-aot-structured-for-red/20260815_161847_120_f6fcd6f1`
  — authoritative `0/1 PASS` at the one missing structured `For` assertion;
  all preceding compile, bytecode, VM, and HIR-publication assertions passed.
- `Saved/Build/typed-aot-structured-for-green-build/20260815_162424_547_e2995089`
  — maintained-fork Runtime production rebuild `5/5` actions PASS.
- `Saved/Tests/typed-aot-structured-for-green/20260815_162438_348_bc0b025f`
  — diagnostic post-production run reached the ordered-ID assertion and exposed
  only CQTest's missing custom-ID formatter.
- `Saved/Build/typed-aot-structured-for-assertion-build/20260815_162544_416_77fbba7f`
  — test-harness assertion repair rebuild `4/4` actions PASS.
- `Saved/Tests/typed-aot-structured-for-green-2/20260815_162603_554_b5517bbb`
  — exact four-phase/ordered-increment case `1/1 PASS`.
- `Saved/Tests/typed-aot-structured-for-prefix-green/20260815_162638_453_2681eb95`
  — complete UE TypedSemanticIR prefix `14/14 PASS`.
- `Saved/StandaloneTests/typed-aot-structured-loops-green_01_Standalone/20260815_162713_400_4122767e`
  — batched independent maintained-fork/Standalone Debug build and CTest
  `20/20 PASS`, closing both the deferred `do-while` gate and this `for` gate.

Both repositories still pass `git diff --check`; their only output is the
pre-existing LF-to-CRLF checkout warning. Tasks 2.3-2.4 remain open because
`break`, `continue`, nearest-legal transfer targets, transfer cleanup, and
`switch/case/default/fallthrough` still require real compiler capture and
verification. Task 4.13 remains open because the safe-point roles recorded here
are authority metadata only and no profile-approved runtime hook has been
emitted yet.

### Nearest loop `break`/`continue` targets and explicit transfer cleanup

The transfer fixture reuses the maintained nested-target semantics in a
focused capture form. One function nests `while` inside `for` and contains an
inner and outer `break` plus an inner and outer `continue`; two additional
functions prove that `for` continue executes increment before condition and
that `do-while` continue reaches the trailing condition. Capture-off/on
bytecode is compared word-for-word, while VM results `26`, `23`, and `3`
freeze the maintained execution behavior before HIR is inspected.

The authoritative RED compiled and executed normally but refused HIR
publication with `semantic capture encountered an unrepresentable compiler
state`. The missing representation was specific: bytecode uses label stacks
whose target labels already exist while compiling a transfer, but the stable
structured loop statement ID is allocated only after its body has been
compiled. Feeding HIR back into the bytecode label machinery would have
violated the capture boundary.

The repair adds a builder-private lexical control-target stack independent of
`breakLabels`/`continueLabels`. `BeginLoopTarget()` opens a pending loop frame;
`AddBreak()` records against the innermost frame, while `AddContinue()` scans
to the innermost continue-capable frame. When `For`, `While`, or `DoWhile` is
appended, the builder patches its pending transfers with that stable statement
ID and closes the frame. This also establishes the exact mechanism needed for
the next switch slice: switch will open a break-capable, non-continue frame, so
continue can skip it and retain the enclosing loop.

Each captured transfer now records `safePoint=Transfer`, the exact number of
compiler variable scopes traversed by the existing destructor walk, and a
compiler-authored cleanup-plan ID. For the current scalar slice,
`MarkVerifiedEmptyCleanupPlan()` attaches the same explicit empty universal
plan to break, continue, and return rather than expecting a future emitter to
infer cleanup absence from C++ braces. Normalized dump output includes target,
cleanup plan, and exited-scope count.

The verifier now constructs the lexical parent relation independently from
the statement arena order, walks ancestors for every transfer, and selects the
nearest legal target: loops for continue, and loops or switch for break. It
uses the new stable `InvalidControlTarget` verification code for an out-of-
range target, an ancestor of the wrong kind, a target that skips a nearer loop,
or a non-ancestor target. Separate mutations of a real verified nested-loop HIR
exercise all four cases. It also requires the transfer safe-point role and an
in-range compiler-authored cleanup plan consistent with the header's universal
coverage claim.

Evidence:

- `Saved/Build/typed-aot-loop-transfers-red-build/20260815_163344_994_0f7fed40`
  — model/test fixture rebuild `21/21` actions PASS.
- `Saved/Tests/typed-aot-loop-transfers-red/20260815_163411_779_f8a4ee5a`
  — authoritative `0/1 PASS` RED; bytecode and VM work completed before only
  HIR publication rejected the missing transfer representation.
- `Saved/Build/typed-aot-loop-transfers-green-build/20260815_163720_721_f976509e`
  — maintained-fork Runtime rebuild `5/5` actions PASS.
- `Saved/Tests/typed-aot-loop-transfers-green/20260815_163734_686_ef5ed054`
  — exact nested target, phase, transfer safe-point, scope count, cleanup-plan,
  and dump case `1/1 PASS`.
- `Saved/Build/typed-aot-loop-transfer-verifier-build/20260815_163848_216_92d44b89`
  — verifier-mutation test rebuild `4/4` actions PASS.
- `Saved/Tests/typed-aot-loop-transfer-verifier-green/20260815_163907_540_127f79a6`
  — focused real-capture plus dangling/wrong-kind/skipped-nearer/non-ancestor
  verifier matrix `1/1 PASS`.
- `Saved/Tests/typed-aot-loop-transfer-prefix-green/20260815_163942_054_e678fbd0`
  — complete UE TypedSemanticIR prefix `15/15 PASS`.

The independent Standalone build/CTest is intentionally batched with the
immediately following switch/control-target slice to avoid repeating its
approximately 40-second Package test. Tasks 2.3-2.4 remain open until switch,
case/default ordering, fallthrough, switch/loop nesting, and the exhaustive
invalid-enum edge are captured. Task 4.13 remains independently open because
transfer roles are still metadata rather than emitted runtime hooks.

### Ordered switch/case capture and mixed loop targets

The final structured-control slice captures `switch`, ordered `case` and
`default` nodes directly in `CompileSwitchStatement()`. The bytecode dispatch
table remains the existing compiler authority; the HIR builder receives a
separate source-order list and never sorts, rewrites, or feeds decisions back
into `asCByteCode`. A switch opens a break-capable but non-continue control
frame. Consequently an inner `break` resolves to that switch while an inner
`continue` skips it and resolves to the nearest enclosing loop. A loop nested
inside a case still owns its own nearer break/continue frame.

Each case owns a normalized body Block, its normalized 32-bit constant,
default disposition, implicit/explicit fallthrough disposition, and source
span. Empty grouped cases receive an explicit empty Block rather than sharing
the next case's statement ownership. The Switch records the compiler-selected
signed/unsigned 32-bit normalization, ordered case IDs, default/exhaustive
state, and the maintained exhaustive-enum invalid-value exception edge. That
edge is also the only Switch form carrying `safePoint=SwitchInvalidValue`.

The first production capture diagnosed
`switch case capture has invalid metadata: value=4294967295 ...`. The
maintained compiler had already validated and converted the case constant but
this compile-time-only comparison path did not always retain an executable HIR
expression ID. The repair does not reparse source: after the existing
`ImplicitConversion` to `int` or `uint`, it synthesizes a canonical Literal
from the compiler-authoritative `GetConstantDW()` result. This keeps enum,
signed and unsigned case identity identical to the actual dispatch table.

The verifier rejects dangling/non-Case children, duplicate constants after
normalization, more than one default, a default that is not last (the current
fork rule), final-case fallthrough, explicit fallthrough without a successor,
selector/normalization disagreement, and a missing or spurious exhaustive
enum invalid-value edge. The dump exposes selector, normalization, ordered
cases, constants, bodies, fallthrough/default/exhaustive state and the stable
safe-point role.

The real compiler fixture covers switch-in-for, loop-in-switch, scoped case
declarations, grouped cases, explicit fallthrough, signed and unsigned
selectors, default, and an exhaustive enum invoked with raw value `99`. It
compares capture-off/on bytecode word-for-word and VM results, including the
exact `Invalid enum value passed to switch` exception.

Evidence:

- `Saved/Build/typed-aot-structured-switch-red-build-2/20260815_164955_821_3bfb0a39`
  — RED fixture build PASS.
- `Saved/Tests/typed-aot-structured-switch-red-2/20260815_165100_752_e6dca8b9`
  — authoritative `0/1 PASS`; compile, bytecode and VM assertions reached the
  first missing Switch-HIR assertion.
- `Saved/Build/typed-aot-structured-switch-verifier-build/20260815_170517_468_3975b05e`
  — final switch builder/verifier/dump rebuild PASS.
- `Saved/Tests/typed-aot-structured-switch-matrix/20260815_170400_625_2646b7e4`
  — signed/unsigned/grouped/exhaustive mixed-target fixture `1/1 PASS`.
- `Saved/Tests/typed-aot-structured-switch-prefix-green/20260815_170536_173_f828cb87`
  — complete pre-return UE TypedSemanticIR prefix `16/16 PASS`.
- `Saved/StandaloneTests/typed-aot-structured-control-green_01_Standalone/`
  — independent maintained-fork/Standalone Debug build and CTest `20/20 PASS`.

### Return exited-scope cleanup and structured-control closure

The closure audit found one real remaining task-2.3 gap: break and continue
recorded the exact number of `asCVariableScope` frames traversed by their
destructor walk, while Return retained its cleanup-plan ID but left
`exitedScopeCount=0`. A focused nested-return RED proved normal compile,
capture-off/on bytecode equality and both VM result paths before failing only
the missing scope count.

`CompileReturnStatement()` now counts its current compiler variable-scope
chain before destruction and passes that authority into `AddReturn()`. Every
Return therefore retains `safePoint=Return` and a non-zero exited-scope count;
a return inside two nested lexical blocks records a larger count than the
outer function return. The normalized dump prints the Return value, cleanup
plan and exited-scope count. For a compiler-verified cleanup state the verifier
requires an in-range plan and enforces the header's universal-plan claim. For
an explicitly `Unverified` lifetime shape, the verifier instead requires no
claimed plan while still requiring the safe-point and scope count. This
distinction lets valid external-implicit-this, mixin and handle HIR remain
available for deterministic eligibility fallback without pretending their
object lifetime is Typed-AOT-safe.

The same audit added a real braced `if/else` ownership check. Both branches are
owned Blocks, both returns retain their source/safe-point roles, and the dump
exposes the stable else statement ID. Combined with the preceding while,
do-while, for, transfer and switch slices, this closes every construct and
metadata item named by tasks 2.3 and 2.4. Task 2.18 deliberately remains open:
it requires adapting the much larger generated matrices in
`AngelscriptNativeNestedTargetTests.cpp`, `AngelscriptNativeSwitchTests.cpp`
and `AngelscriptNativeForClauseTests.cpp` as capture-on/off oracles for every
product, not merely the focused representative matrix used here.

Evidence:

- `Saved/Build/typed-aot-return-cleanup-red-build/20260815_171345_140_7ff70a3f`
  — nested-return RED fixture build PASS.
- `Saved/Tests/typed-aot-return-cleanup-red/20260815_171404_201_5e5468af`
  — authoritative `0/1 PASS` at `MinimumExitedScopes > 0` after bytecode and
  VM equality passed.
- `Saved/Build/typed-aot-return-cleanup-green-build/20260815_171734_169_e0eb6790`
  — compiler, verifier, dump and synthetic fixture rebuild PASS.
- `Saved/Tests/typed-aot-return-cleanup-green/20260815_171752_517_b8b5150b`
  — focused return cleanup/verifier case `1/1 PASS`.
- `Saved/Build/typed-aot-structured-control-final-build/20260815_172007_274_0ca54108`
  — explicit if/else ownership audit rebuild PASS.
- `Saved/Tests/typed-aot-structured-control-prefix-green/20260815_172024_731_8ebf73c9`
  — complete UE TypedSemanticIR prefix `17/17 PASS`.
- `Saved/Tests/typed-aot-return-cleanup-eligibility-green/20260815_172100_280_ad18a324`
  — affected TypedASTJIT eligibility/call-closure prefix `26/26 PASS`.
- `Saved/Tests/typed-aot-return-cleanup-generated-green/20260815_172136_115_ac430ea8`
  — affected TypedASTJIT generated-output prefix `14/14 PASS`.
- `Saved/StandaloneTests/typed-aot-return-cleanup-green_01_Standalone/20260815_172210_912_5e67ef11`
  — expected compatibility RED, `19/20 PASS`; strict plan validation wrongly
  rejected three explicitly Unverified lifetime shapes.
- `Saved/StandaloneTests/typed-aot-return-cleanup-compat-green_01_Standalone/20260815_172412_992_8344918e`
  — final independent maintained-fork/Standalone build and CTest `20/20 PASS`.
- `Saved/Build/typed-aot-structured-control-closure-build/20260815_172642_097_2f9d5474`
  — final UE Runtime rebuild after the Unverified-lifetime compatibility
  distinction, `4/4` actions PASS.
- `Saved/Tests/typed-aot-structured-control-closure-green/20260815_172653_489_e9f9154b`
  — final post-compatibility UE TypedSemanticIR prefix `17/17 PASS`.
- `Saved/Tests/typed-aot-structured-control-eligibility-final/20260815_172728_362_e4ea7bdf`
  — final post-compatibility eligibility/call-closure prefix `26/26 PASS`.

### Native control-flow matrix capture oracles

Task 2.18 now reuses the maintained native SDK matrices as capture-off/on
oracles instead of adding a smaller parallel fixture. `ForClauses` compiles
and executes all 24 initializer/condition/increment/count products in two
otherwise identical Engines, compares diagnostics and bytecode exactly, and
checks the captured For phase IDs against each omitted/present clause.
`NestedTargets` does the same for all 18 nesting/transfer/target products and
checks explicit inner-versus-outer transfer IDs plus Return exited-scope
depth. `Switch` covers its existing 12 selector x 9 case-shape x 4 exit
product, including compile-time rejection cells, fallthrough/default
disposition, runtime results and exceptions. A separate exhaustive-enum
oracle invokes raw value `99` in both Engines and requires the exact maintained
`Invalid enum value passed to switch` exception.

The first two focused runs are GREEN. The first Switch cell produced an
authoritative RED after capture-off/on compile, diagnostics and bytecode had
already matched: `int8 Value = int8(1)` left the LocalDeclaration initializer
invalid, so HIR verification rejected the otherwise valid switch function.
The source compiler's explicit primitive `CompileConversion()` merged
bytecode and final type but did not propagate the expression ID. The repair
adds a real typed `Conversion` node from the already captured operand to the
compiler-selected final type; it does not change bytecode or VM conversion
logic. Conversion verification also now requires exactly one earlier arena
operand.

That repair advanced the matrix from the first `INT8/FIRST/BREAK` cell through
the primitive selectors to `ENUM/FIRST/BREAK`, exposing a second independent
RED: the maintained compiler had already resolved `ESelector::One` to its
typed constant, but HIR capture left the expression ID invalid. The enum
resolution authority now emits a normalized numeric Literal with the resolved
enum type and processed source span. It does not parse the qualified name or
change the compiler's constant value. The complete matrix then passed, and an
explicit observed-cell assertion guards the full `12 * 9 * 4 = 432` product.

Task 2.18 is complete. All three matrices compile each source in capture-off
and capture-on Engines, require exact build result and diagnostic text, compare
valid bytecode word-for-word, execute both VM paths, compare result or exact
exception, and discard both modules. Invalid Switch cells retain the existing
compile-time rejection rather than being silently removed from the product.

Evidence:

- `Saved/Build/typed-aot-native-control-oracles-red-build/20260815_173548_099_acfa26f8`
  — all three upgraded matrix tests compile; UE build PASS in 28.9 seconds.
- `Saved/Tests/typed-aot-native-for-clauses-green/20260815_173743_667_5a3b0310`
  — ForClauses `1/1 PASS`, internally all 24 products.
- `Saved/Tests/typed-aot-native-nested-targets-green/20260815_173817_883_475c3101`
  — NestedTargets `1/1 PASS`, internally all 18 products.
- `Saved/Tests/typed-aot-native-switch-green/20260815_173852_711_f15d5d93`
  — expected RED, `1/2 PASS`; SwitchPlacement passed and the main matrix
  stopped at the first `INT8/FIRST/BREAK` missing Conversion capture.
- `Saved/Build/typed-aot-native-switch-conversion-green-build/20260815_174227_133_9ad8e487`
  — primitive Conversion capture repair build PASS.
- `Saved/Tests/typed-aot-native-switch-conversion-green/20260815_174239_588_00779c40`
  — expected second RED, `1/2 PASS`; the primitive selector cells advanced to
  the first missing enum Literal at `ENUM/FIRST/BREAK`.
- `Saved/Build/typed-aot-native-switch-enum-green-build/20260815_174408_594_aa5bdb62`
  — enum Literal capture repair build PASS.
- `Saved/Tests/typed-aot-native-switch-enum-green/20260815_174421_447_f571cb0c`
  — complete Switch prefix `2/2 PASS`, including all 432 product cells and the
  exhaustive invalid-enum exception oracle.
- `Saved/Build/typed-aot-native-control-oracles-final-build/20260815_174518_756_1ccf7d53`
  — final UE Runtime/Test rebuild PASS after explicit matrix-count coverage.
- `Saved/Tests/typed-aot-native-control-oracles-final/20260815_174544_684_6ccb0ad0`
  — final combined control-flow oracle run `3/3 PASS`, internally 24 ForClause,
  18 NestedTarget, and 432 Switch products.
- `Saved/Tests/typed-aot-native-control-typed-ir-final/20260815_174619_941_9218c8e8`
  — affected UE TypedSemanticIR regression `17/17 PASS`.
- `Saved/StandaloneTests/typed-aot-native-control-oracles-final_01_Standalone/`
  — independent maintained-fork/Standalone Debug build and CTest `20/20 PASS`.

## Explicit instrumentation-profile emission RED (task 4.13, 2026-08-15)

The task 4.13 audit confirmed that the route/profile half already fails closed:
the current production generation profile advertises only `RecursionBudget`
for GameShipping and `FramePosition|RecursionBudget` for non-Shipping targets;
breakpoint/step/locals/coverage/loop-timeout/abort/suspend requirements are not
advertised, their typed route matrix selects VM with stable reasons, and the
direct-call closure rejects a child whose available capabilities do not cover
the root requirements with `DirectCalleeProfileMismatch`. The maintained VM
remains the only implementation of `AngelscriptLineCallback`, coverage hits
and `asBC_SUSPEND` loop/status polling. A source-position write must therefore
not be relabelled as one of those callbacks.

The missing production seam is generated-output ownership. Provider root and
helper wrappers currently instantiate `FScopeTypedASTJITExecutionFrame`
unconditionally, while `EmitTypedASTJITFunction()` receives no explicit
generation capability profile and cannot emit source-position changes from
the HIR safe-point roles. The same emitted text is consequently produced for
the non-Shipping position profile and the Shipping recursion-only profile,
even though the existing profile-content identity helper distinguishes them.

The new RED fixture requires one explicit immutable profile on body emission,
requires position-only output to emit `TypedFrame.SetLineNumber()` at captured
statement/return source points, and forbids direct references to
`AngelscriptLineCallback`, `AngelscriptLoopDetectionCallback`, `HitLine`,
`FAngelscriptCodeCoverage`, or `DebugServer`. It also requires a
recursion-only profile to emit no position hook and a profile that falsely
advertises unimplemented `LineCallback|Coverage` hooks to fail with no partial
C++ output. This is the intended worker-thread guarantee: generated position
metadata mutates only its thread-local JIT frame and never enters the
game-thread observer pipeline.

Clean RED evidence:

- `Saved/Build/typed-aot-instrumentation-red-clean/20260815_175809_892_2cc6b20c`
  — expected compile failure only because
  `FAngelscriptTypedASTJITEmitOptions::InstrumentationProfile`,
  `FAngelscriptTypedASTJITEmission::bRequiresInstrumentationFrame`, and the
  emitted instrumentation-profile identity do not yet exist. The earlier
  `typed-aot-instrumentation-red` attempt also exposed and immediately removed
  one fixture-only assertion-macro spelling error; it is not production RED
  evidence.

### Explicit instrumentation-profile emission GREEN

Task 4.13 now has one exact profile from generation planning through body,
root-entry and internal-helper emission. The body emitter accepts only the
currently implemented `FramePosition|RecursionBudget` capability subset and
rejects a profile that claims line-callback, coverage, timeout, abort or
suspend hooks before emitting partial C++. A FramePosition body receives the
narrow existing `FScopeTypedASTJITExecutionFrame& TypedFrame` parameter and
emits `SetLineNumber()` only at captured non-empty safe-point roles. A
recursion-only body receives no frame parameter and emits no position write.
No generated body receives `FAngelscriptJITExecutionContext`.

Provider root and direct-helper wrappers retain the exact immutable profile,
require its identity to match the body, always enforce the shared native
recursion budget, and link the existing thread-local debug-position frame only
when FramePosition is advertised. `SetLineNumber()` mutates only that linked
frame. It does not call `AngelscriptLineCallback`, coverage, DebugServer, loop
polling, abort or suspend code; those requirements continue to select VM in
the existing route matrix. The generated-output fixture forbids every such
observer symbol, while the runtime frame test proves recursion-only execution
does not publish a debug frame and position-aware execution restores the
outer frame after updating its line.

The first full AOT Verify exposed an older cross-task integration gap rather
than an instrumentation failure: the maintained HIR correctly preserved a
typed `Reference` unsupported marker for each `const FString&` and
`const FLinearColor&` parameter, but TypedASTJIT eligibility/analyzer did not
distinguish the already reviewed borrowed-input slice. The backend now admits
only a marker attached to an exact parameter symbol of those two read-only
types. HIR still retains the marker and every other reference remains
fail-closed. This allowed the real exported `Print(FString,float,FLinearColor)`
fixture to use the production Typed backend again; the maintained generator
then reported only the expected stale owned bytes. The owned files were
regenerated through `AngelscriptTestJIT -Mode=Generate`, rebuilt, verified and
executed rather than edited manually.

GREEN evidence:

- `Saved/Build/typed-aot-instrumentation-green-build-2/20260815_180434_858_81666a81`
  — production profile/body/provider implementation build PASS.
- `Saved/Tests/typed-aot-instrumentation-generated-output/20260815_180452_379_ef1c6835`
  — profile-driven generated-output and fail-closed hook matrix `15/15 PASS`.
- `Saved/Tests/typed-aot-instrumentation-eligibility/20260815_180546_325_bde4eb4f`
  — execution requirements, route fallback and direct-call closure `26/26 PASS`.
- `Saved/Build/typed-aot-instrumentation-frame-test/20260815_180834_923_00bd64c2`
  — direct frame-characterization test build PASS.
- `Saved/Tests/typed-aot-instrumentation-debugcallstack/20260815_180857_325_8023125f`
  — debug position, nested VM/JIT public queries and explicit profile frame
  linkage `6/6 PASS`.
- `Saved/Tests/typed-aot-instrumentation-aot-verify/20260815_180946_690_b795092e`
  — expected integration RED: real `Print` root fell back on its retained
  Reference marker before generated-byte comparison.
- `Saved/Build/typed-aot-reviewed-borrowed-input/20260815_181226_530_22499443`
  — exact reviewed borrowed-input marker repair build PASS.
- `Saved/Tests/typed-aot-instrumentation-aot-verify-2/20260815_181241_971_77a62058`
  — expected freshness RED after the repair: production Typed generation
  succeeded and reported only six stale owned generated files.
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-instrumentation-generate/20260815_181345_013_f4c5aa40`
  — maintained Generate command PASS; six owned files written and five
  unchanged.
- `Saved/Build/typed-aot-instrumentation-generated-build/20260815_181421_505_c5ab9255`
  — all five affected generated C++ translation units compiled and linked,
  `8/8` build actions PASS.
- `Saved/Tests/typed-aot-instrumentation-aot-verify-green/20260815_181432_729_cbc66557`
  — two fresh isolated-Engine generations match the owned fixture and one
  another byte-for-byte, `1/1 PASS`.
- `Saved/Tests/typed-aot-instrumentation-provider-runtime/20260815_181518_826_ada9e682`
  — regenerated Typed provider raw/VM/Parms entries compile, link and execute,
  `1/1 PASS`.
- `Saved/Tests/typed-aot-instrumentation-print-runtime/20260815_181603_781_54de0dd7`
  — regenerated exported Runtime `Print` direct call executes through its
  Typed AOT provider entry, `1/1 PASS`.

### Task 4.14 mutation/power matrix RED: implicit power conversions were missing from HIR

The maintained Assignment and Increment products now enable private typed-HIR
capture before their first raw SDK build and inspect the exact already-reviewed
local mutation cells in their existing matrices. Assignment proves one target,
one RHS and updated-result identity for plain assignment plus integer
`+=|-=|*=`. Increment proves one target, no synthetic RHS, and exact
prefix-updated versus postfix-old identity for integer `++|--`. Their complete
existing compile/runtime/metadata products remain GREEN; field, property and
alias cells are still VM or later Typed fallback rather than being counted as
symbol-target emission support.

The new generated-output RED requires only the three maintained runtime power
shapes (`POWf`, `POWd`, `POWdi`) to emit `FMath::Pow`, with an explicit
`static_cast<double>` for the compiler-normalized signed 32-bit exponent, and
requires integer power to fail closed without partial C++. It is the only
failure in the generated-output class:

- `Saved/Build/typed-aot-mutation-power-red/20260815_182956_909_e2e2248d`
  — test-only RED build `7/7` actions PASS.
- `Saved/Tests/typed-aot-mutation-power-red/20260815_183017_259_54a2c5e5`
  — authoritative emitter RED, `15/16 PASS`; only
  `PowerEmitsOnlyCompilerProvenFloatingShapes` failed because `POWf` remained
  outside the analyzer.
- `Saved/Tests/typed-aot-assignment-capture-red/20260815_183101_415_91997279`
  — complete Assignment product `1/1 PASS` with the reviewed local HIR checks.
- `Saved/Tests/typed-aot-increment-capture-red/20260815_183137_188_f33579cb`
  — complete Increment product `3/3 PASS` with prefix/postfix HIR checks.

The complete maintained Power product is a second, compiler-side RED rather
than an emitter failure. All ordinary compilation/bytecode/VM behavior still
ran, but 598 floating cases showed that the power Binary node retained one or
both pre-conversion operand types (`304 POWf`, `220 POWd`, `74 POWdi` shape
failures). For example, `int64 ** float64` selected the maintained `POWd`
bytecode route while HIR still named the left operand as `int64`. Emission must
not rely on C++ overload resolution to rediscover that decision. The correction
therefore belongs at the existing `CompileMathOperator` implicit-conversion
seam: retain explicit conversion nodes and final operand types before adding
the Binary node, with capture remaining observational and bytecode unchanged.

- `Saved/Tests/typed-aot-power-capture-red/20260815_183211_193_6bc5a972`
  — authoritative maintained-matrix capture RED, all three Power products
  failed only their new final converted-HIR shape assertions.

### Task 4.14 compiled-probe RED: stale TestJIT output exposed BytecodeJIT POWdi drift

The maintained AOT fixture now contains dedicated mutation, `POWf`, `POWd`,
and `POWdi` functions, and the existing separate-DLL scalar probe contract has
test-side registration/execution seams for all four. The first build deliberately
kept the committed generated probe stale so the AOT class could provide the
required runtime RED before the generation commandlet rewrites owned files.

- `Saved/Build/typed-aot-mutation-power-runtime-red/20260815_184548_646_8006dbda`
  — source/test-side RED build succeeded, `11/11` actions, while the committed
  `TypedASTJITScalarProbe.generated.cpp` still registered only the old branch.
- `Saved/Tests/typed-aot-mutation-power-runtime-red-2/20260815_184712_302_27e968c1`
  — the affected AOT class produced two expected stale-output signals and one
  newly exposed production bug. Cache V2 restored `53` current functions while
  the stale committed Provider catalog still described `49`; this is expected
  to close only after maintained regeneration. More importantly, generation
  reached `asBC_POWdi` and asserted because BytecodeJIT required operand 2 to
  have `Double` storage even though the maintained interpreter and compiler
  define it as a signed one-dword integer. `POWd` and `POWdi` also emitted a
  line but returned `false`, contradicting the generator's mandatory
  `Implement()` contract.

The production correction is deliberately at the BytecodeJIT opcode seam:
`POWdi` now requires `DWord`, reads it through the existing signed view, and
both floating-double power opcodes report successful implementation. This does
not broaden integer-power support or change compiler bytecode selection. The
same real fixture keeps the regression in the maintained AOT generation and
Interpreter/BytecodeJIT/TypedASTJIT parity path.

### Task 4.14 compiled-probe GREEN: one owned DLL probe proves mutation and power parity

The real-fixture pass exposed one further pre-existing BytecodeJIT C++ spelling
defect after the operand/storage correction: all three floating power opcodes
emitted `Math::Pow`, but generated UE C++ has no such namespace. They now emit
`FMath::Pow`; `POWdi` also emits the reviewed explicit
`static_cast<double>(signed-int32-exponent)`. The first generated-module build
therefore served as the expected self-hosting RED: it compiled the repaired
Runtime but rejected the still-old generated text. Regenerating through the
rebuilt maintained commandlet produced the corrected bytes, after which the
separate TestJIT DLL compiled and executed successfully. No generated file was
edited by hand.

The one `TypedASTJITScalarProbe.generated.cpp` translation unit now registers
the scalar branch, mutation, `POWf`, `POWd`, and `POWdi` typed function pointers
together. The runtime fixture executes assignment/compound-assignment/
prefix/postfix cases and safe rows for all three power shapes through three
independent paths: Interpreter, maintained BytecodeJIT, and the separately
compiled TypedASTJIT DLL. Every result is exact and the probe reports exactly
the expected 12 new compiled calls. Integer power remains compiler-rejected or
TypedASTJIT-unsupported and never gains an emitter path.

The larger AOT fixture also stopped freezing its generation-function count at
`50`. Four new global functions correctly raised the current graph to `54`.
The isolated generation Engine intentionally does not publish the process-facing
FunctionRoute snapshot, so the test now compares the snapshot with the same
Engine's independent complete `asCModule::scriptFunctions` ownership table.
This keeps the no-Cache-V2 proof (`InputCacheRecordCount == 0`) and will follow
future authored/generated fixture growth without weakening Engine isolation.
The nested exception oracle similarly derives its source row from the fixture
text instead of freezing a line displaced by new functions.

GREEN evidence:

- `Saved/Build/typed-aot-powdi-bytecode-fix/20260815_184931_730_0a36ebe1`
  — repaired POWdi storage and successful-implementation contract build PASS.
- `Saved/Tests/typed-aot-mutation-power-probe-registration-red/20260815_184946_355_731595e1`
  — expected stale-owned-output RED: the new mutation function had no compiled
  TestJIT entry before maintained regeneration.
- `Saved/Commandlet/typed-aot-mutation-power-stale-verify/20260815_185051_509_03db7cb9`
  — Verify named only the expected five stale owned files.
- `Saved/Commandlet/typed-aot-mutation-power-generate/20260815_185128_361_b9d16162`
  — maintained Generate wrote exactly those five files.
- `Saved/Build/typed-aot-mutation-power-generated-build/20260815_185205_924_c7077e95`
  — expected self-host RED exposed generated `Math::Pow` after Runtime had
  already accepted the opcode.
- `Saved/Build/typed-aot-bytecode-power-cpp-name-fix/20260815_185257_594_cbae0de5`
  — rebuilt the maintained generator with `FMath::Pow`; the overall build
  remained RED only because committed generated bytes were still old.
- `Saved/Commandlet/typed-aot-mutation-power-regenerate-bytecode-fix/20260815_185315_998_4efd2383`
  — regeneration replaced the three invalid power spellings with reviewed UE
  C++ and preserved the explicit POWdi conversion.
- `Saved/Build/typed-aot-mutation-power-generated-build-2/20260815_185350_416_3ec1c415`
  — regenerated TestJIT DLL build `4/4 PASS`.
- `Saved/Tests/typed-aot-mutation-power-runtime-green/20260815_185402_826_ae305ec4`
  — exact Interpreter/BytecodeJIT/separate-DLL TypedASTJIT mutation and three
  power-shape parity `1/1 PASS`.
- `Saved/Commandlet/typed-aot-mutation-power-determinism/20260815_185450_292_c0e7395f`
  — second Generate reported all 11 owned files unchanged.
- `Saved/Commandlet/typed-aot-mutation-power-verify-green/20260815_185525_418_1f6bcec1`
  — maintained Verify PASS with zero stale files.
- `Saved/Build/typed-aot-task414-function-count-green/20260815_190631_963_f8d4fa79`
  — final independent VM-function-table assertion build `4/4 PASS`.
- `Saved/Tests/typed-aot-task414-function-count-green-2/20260815_190742_086_d2dc371b`
  — dynamic generation-graph count/no-Cache-V2 proof `1/1 PASS`.
- `Saved/Tests/typed-aot-task414-aot-full-green/20260815_190821_533_1803aa8f`
  — complete AOT class, including exception, generation facts, provider and
  separate-DLL runtime parity, `31/31 PASS`.
- `Saved/Tests/typed-aot-task414-generated-output/20260815_191007_749_faf3fa63`
  — TypedASTJIT generated-output contract `16/16 PASS`.
- `Saved/Tests/typed-aot-task414-assignment/20260815_191007_749_cdf31ecb`
  — complete maintained Assignment prefix `3/3 PASS`.
- `Saved/Tests/typed-aot-task414-increment/20260815_191007_749_360154c6`
  — complete maintained Increment prefix `3/3 PASS`.
- `Saved/Tests/typed-aot-task414-power/20260815_191007_749_602e22a7`
  — complete maintained Power prefix `3/3 PASS`, including the universal,
  negative-exponent, and fractional-exponent products.

## Checked integral exception-helper RED (task 4.15, 2026-08-15)

The first six-route exception-matrix fixture exposed a production safety gap
before any deliberate exceptional native code was executed. TypedASTJIT did not
have a reviewed integer division/remainder emission path: the verified scalar
operator was rejected by the emitter, and the generic binary fallback would
otherwise spell raw C++ `/` or `%`. Raw integral division cannot implement the
AngelScript exception contract because divisor zero and signed-minimum divided
by `-1` must record `TXT_DIVIDE_BY_ZERO` or `TXT_DIVIDE_OVERFLOW` in the shared
`FScriptExecution` first-failure record. On Windows those raw operations may
also raise a native hardware exception before Runtime can adopt the failure.

The maintained interpreter (`as_context.cpp`) and BytecodeJIT
(`AngelscriptBytecodes.cpp`) agree on the required order for both division and
remainder: test zero first, then signed minimum with divisor `-1`, and only then
evaluate the C++ operator. The TypedASTJIT repair must preserve that order,
thread the existing execution record only for exception-capable operators, and
leave ordinary add/subtract/multiply/shift helpers context-free.

RED evidence:

- `Saved/Tests/typed-aot-exception-checked-divide-red/20260815_192642_962_88dcab70`
  — generated-output class `16/17 PASS`; the only failure is
  `IntegerDivisionUsesTheScriptExceptionContract` at the first assertion because
  an otherwise verified scalar `int32 / int32` function does not emit at all.
  The test inspects generated text and metadata only; it intentionally does not
  execute divide-by-zero while unchecked native C++ remains possible.

### Checked integral exception-helper GREEN

TypedASTJIT analysis now admits reviewed same-type integral `/` and `%` shapes.
The emitter pre-scans those expressions before spelling the function signature,
so only exception-capable integral functions gain the hidden shared
`FScriptExecution&`; the generated expression calls `CheckedDivide` or
`CheckedRemainder` and never emits a raw native operator. The helpers preserve
the maintained VM order (zero, signed minimum with `-1`, operation), return a
zero sentinel after failure, and short-circuit immediately when an earlier
failure already exists. Add/subtract/multiply/shift output remains unchanged
and context-free.

The runtime characterization also caught an oracle-display trap rather than a
production defect. `TXT_DIVIDE_OVERFLOW` is the 28-byte string
`Overflow in integer division` with no final period; Automation appends sentence
punctuation when formatting an equality failure, which initially made the two
values look identical. The final test compares the authoritative exact length
and case-sensitive content, and separately proves that a later overflow cannot
replace an earlier divide-by-zero record.

GREEN evidence:

- `Saved/Build/typed-aot-exception-checked-integral-final-build/20260815_193641_279_cc1cd1f1`
  — Runtime, generated TestJIT sources and test module compile/link PASS.
- `Saved/Tests/typed-aot-exception-checked-integral-final-green/20260815_193658_672_18b4a4e8`
  — generated-output and scalar-helper prefixes `21/21 PASS`, covering checked
  output metadata, normal signed/unsigned results, divide-by-zero, signed
  remainder overflow, exact messages, and first-failure preservation.

## Real TypedAST nested-exception fixture RED (task 4.15, 2026-08-15)

The dedicated recursion module now contains a real two-function exception
chain. `TypedASTExceptionEntry(int,int)` directly calls
`TypedASTExceptionHelper(int,int)`; the helper performs the checked integral
division, while the entry deliberately calls the already-inventoried
provider-private native probe afterwards. The test requires both functions to
select current generated Native entries, invokes the public context with a zero
denominator, and will compare the published helper identity/source, one public
exception callback, and zero late native-call observations.

The initial RED was run before regenerating any owned output. Current source
compiled successfully, but the old committed Provider knew only 59 of 61 exact
functions and both new functions stayed on VM. The exact test failed at the
first generated-Native route requirement, so no unchecked or stale native entry
was invoked. This proves the fixture distinguishes fresh authored source from
old Provider bytes instead of passing through an unrelated VM exception.

RED evidence:

- `Saved/Build/typed-aot-exception-real-fixture-red-build/20260815_194112_346_fa03999c`
  — fixture/test compile and link PASS.
- `Saved/Tests/typed-aot-exception-real-fixture-red/20260815_194131_903_501e9c2a`
  — exact test `0/1`, failing only because the checked-exception helper route is
  not generated Native before maintained regeneration (`verified=61`,
  `exact/native=59`, `vm=2`).

### Maintained generation exposed a helper-root oracle error

The first maintained `AngelscriptTestJIT -Mode=Generate` attempt did not reach
file publication because the new generation guard incorrectly required
`TypedASTExceptionHelper` to produce its own `typed-ast` backend function
result. The authoritative backend diagnostic was:

`NotUFunctionRoot: No exact resolved FunctionDesc root exists.`

This is not evidence that the root call closure omitted the helper. The OpenSpec
contract deliberately selects only resolved UFUNCTION roots and emits reachable
ordinary AS helpers as provider-internal symbols; it explicitly forbids
publishing an independent UASFunction entry for such a helper. Production
closure planning already indexes the complete compiled graph, classifies the
ordinary helper with `InternalHelperCallClosure`, and emits its body/wrapper as
part of the calling root artifact. The failing guard and runtime test were
therefore asserting the opposite contract by treating the helper as an
independent generated route.

RED evidence:

- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-exception-real-fixture-generate/20260815_194511_742_8d2e8806`
  — generation failed deterministically at the helper-only backend-result
  requirement; the helper result was BytecodeJIT with the typed attempt carrying
  `NotUFunctionRoot`. The repair must require the public entry root to be
  TypedASTJIT and prove the internal helper through generated closure metadata
  plus nested exception identity, not make the helper independently publishable.

The guard was corrected without changing production root selection. The next
maintained generation completed successfully and the module-owned generated
source contains an `ASJIT_HelperBody_TypedASTExceptionHelper...`, its reviewed
`CheckedDivide<int32>(Execution, ...)`, an internal helper wrapper, and the
subsequent provider-private native call in the public entry artifact.

Generation/build evidence:

- `Saved/Build/typed-aot-exception-helper-oracle-fix-build/20260815_194653_708_66217273`
  — corrected test/generation oracle compiled PASS.
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-exception-real-fixture-generate-2/20260815_194715_378_d7eaa6cf`
  — maintained generation PASS; no generated C++ was hand-edited.
- `Saved/Build/typed-aot-exception-real-fixture-generated-build/20260815_194805_236_be7add87`
  — generated recursion module and Provider compiled/linked PASS.

### Real generated nested-exception identity RED

With the fresh Provider loaded, routing matched all `61/61` fixture functions
and the checked-exception test executed the public TypedASTJIT entry. Execution
returned `asEXECUTION_EXCEPTION` with the exact first message `Divide by zero`,
but the context did not publish `TypedASTExceptionHelper` as the originating
function; the first failing assertion is the exact helper identity comparison.
This is now a production exception-adoption defect rather than stale generation
or fallback behavior. Remaining row/column, callback count and late-side-effect
observations must be characterized after the identity assertion no longer hides
them.

RED evidence:

- `Saved/Tests/typed-aot-exception-real-fixture-generated-red-2/20260815_194913_505_b14512b4`
  — exact test `0/1`; generated routing `verified=61 exact=61 native=61 vm=0`,
  execution status/message passed, exact originating-helper identity failed.

The post-execution oracle was then made non-short-circuiting so one run exposed
the complete public observation rather than hiding later fields behind the
first identity assertion. The authoritative RED tuple was:

`Function=TypedASTExceptionEntry, Line=32, Column=2, Section=<expected>, CallbackCount=0, LateNativeCallCount=0`.

This separated two production defects from already-correct behavior. The
processed helper row/section and late bridge side-effect suppression were
preserved, but exception recording selected the entry-level `jitFunction`
instead of the active direct-helper frame, and immediate host reporting marked
the record reported before the owning public context could invoke its configured
exception callback.

RED evidence:

- `Saved/Build/typed-aot-exception-real-observation-build/20260815_195134_490_534749e7`
  — complete-observation oracle compiled PASS.
- `Saved/Tests/typed-aot-exception-real-observation-red/20260815_195154_207_bb021d54`
  — exact `0/1` with the complete tuple above.

### Real generated nested-exception identity/callback GREEN

`RecordJITException` now selects the current TLD active function before falling
back to the entry-level JIT function, so a direct internal helper remains the
primary origin. Context-owned entries defer their one public report to
`PublishException`; context-free raw/parameter entries still report immediately.
This preserves the existing no-context helper behavior without suppressing a
custom public `asIScriptContext` exception callback.

GREEN evidence:

- `Saved/Build/typed-aot-exception-active-origin-callback-build/20260815_195603_850_cf6e7539`
  — Runtime change compiled/linked PASS.
- `Saved/Tests/typed-aot-exception-real-origin-callback-green/20260815_195623_484_4b13a42e`
  — exact generated nested-exception test `1/1 PASS`; status/message, helper
  identity, row/section, one public callback and zero late bridge invocations all
  match the desired contract with `61/61` current native routes.

## Four-route exception-matrix RED (task 4.15, 2026-08-15)

The first table-driven public-context matrix now executes the same maintained
failure contract through interpreter VM, top-level BytecodeJIT, nested
BytecodeJIT and the real generated TypedASTJIT helper. Every case captures the
public execution status/message/function/section/row/column and callback count;
while the callback runs it also copies the still-live Runtime first-failure
record's reported/adopted flags and route/backend origin. The oracle aggregates
all differences instead of short-circuiting at the first field.

The authoritative first RED has only two mismatching rows. The interpreter-only
fixture returns its isolated physical processed filename
`V:/Saved/Automation/AngelscriptTestJITGeneration/<guid>/Script/ASStaticJITAotFixture.as`
instead of the same CodeSection's stable `/Angelscript/Game/...` virtual path.
This is a representation difference in the generation-purpose VM oracle rather
than a Runtime provider defect; the matrix will preserve the raw section and
canonicalize it through that Engine's authoritative module CodeSection table.

The production defect is the nested BytecodeJIT row. Its public status, message,
originating `void FailForAOT()`, stable section, row `106` and column `2` are all
correct, but the configured outer exception callback runs zero times. The
generated BytecodeJIT caller creates a configured pooled `FAngelscriptContext`;
that inner context runs the default exception callback before
`AdoptContextException`, marks the shared first-failure record reported, and
therefore suppresses the owning outer context's callback. Top-level BytecodeJIT
and direct TypedASTJIT did not exhibit this loss.

RED evidence:

- `Saved/Build/typed-aot-exception-four-route-matrix-red-build/20260815_201001_301_8ba0323c`
  — new matrix and fixture declaration compile/link PASS.
- `Saved/Tests/typed-aot-exception-four-route-matrix-red/20260815_201025_220_e96764a4`
  — exact matrix `0/1`; two reported rows are the intentional raw-section
  normalization gap and the nested BytecodeJIT callback-ownership defect above.

### Nested-context callback ownership and provenance GREEN

The interpreter display-only difference was first removed from the behavioral
oracle by retaining `RawSection` for diagnostics while resolving the canonical
section through the exact fixture Engine's authoritative module CodeSection
table. The resulting observation RED contained exactly one failing route:
nested BytecodeJIT had the correct exception payload and zero later side
effects, but `CallbackCount=0`.

Runtime now uses `FScopeStaticJITNestedExceptionAdoption` around temporary
context execution in both maintained BytecodeJIT output and the TypedASTJIT VM
call bridge. The scope saves the complete pooled callback state, suppresses the
temporary context's public report, and restores the exact state before the
context is returned. `AdoptContextException` then leaves context-owned failures
unreported for the public owner, while a context-free Raw/Parms/bridge call
reports a still-unreported primary failure immediately.

The first implementation correctly changed the nested public callback from
zero to one, but the full matrix remained RED because adoption reduced the
origin to `context-adoption/vm`. Relaxing the oracle would have hidden the real
generated Provider origin, so the maintained context now carries the complete
`asSJITFailureRecord` provenance across a temporary context boundary. Standard
VM exceptions leave this carrier empty; a JIT failure preserves its stable
function identity, route/backend, adopted state and source location. Pooled
Prepare/Unprepare and ordinary VM exception creation explicitly clear the
carrier, preventing stale diagnostics on context reuse.

The next pre-regeneration run was intentionally still RED: the checked-in
`.jit.cpp` had been produced by the old generator and still invoked bare
`CallContext->Execute()`. Its inner callback legitimately marked the carried
record reported before the outer owner saw it. This proved that source-generator
changes alone were insufficient and that the committed output gate was
effective. The files were then regenerated only through the maintained
`AngelscriptTestJIT -Mode=Generate` commandlet; no generated C++ was hand-edited.

Evidence:

- `Saved/Tests/typed-aot-exception-four-route-observation-red/20260815_201231_639_c8168393`
  — canonicalized four-route observation RED; only nested BytecodeJIT had
  `CallbackCount=0`.
- `Saved/Build/typed-aot-nested-exception-ownership-green-build/20260815_201819_614_0e410077`
  — first callback-ownership Runtime/generator patch compiled and linked PASS.
- `Saved/Tests/typed-aot-exception-four-route-ownership-green/20260815_201916_835_deee948a`
  — intermediate `0/1`: callback became exactly one, while the remaining row
  exposed the too-generic `context-adoption/vm` provenance.
- `Saved/Build/typed-aot-nested-exception-provenance-green-build/20260815_202126_406_3980a74e`
  — complete context-carried provenance implementation rebuilt all affected
  Runtime/test consumers (`106/106` build actions) and linked PASS.
- `Saved/Tests/typed-aot-exception-four-route-provenance-green/20260815_202427_536_85d5ad54`
  — expected pre-regeneration `0/1`; old generated source still consumed the
  inner callback, proving the maintained output had to be refreshed.
- `Saved/Commandlet/typed-aot-nested-exception-regenerate/20260815_202531_405_b9495998`
  — official TestJIT Generate PASS with zero errors; emitted nested exception
  scopes into the owned per-module sources.
- `Saved/Build/typed-aot-nested-exception-generated-green-build/20260815_202605_119_59e1a8bf`
  — regenerated TestJIT sources compiled and linked PASS.
- `Saved/Tests/typed-aot-exception-four-route-generated-green/20260815_202615_871_692e7e2e`
  — exact matrix `1/1 PASS`. All four routes publish one callback, the expected
  function/section/row/column, zero later side effects, and JIT routes preserve
  `generated-native-call / AngelscriptTestJIT Fixtures` rather than collapsing
  to VM adoption metadata.

## Provider-private generic VM-bridge exception RED (task 4.15/5.9, 2026-08-15)

The fifth route extends the same public exception oracle through an actual
provider-private `asCALL_GENERIC` system function. The AS root calls
`TypedASTProviderPrivateFail(int)`, which sets a script exception from its
generic callback, followed by a separate provider-private Add call whose
counter must remain zero after the failure. The first build passed, but the
first runtime RED failed before source compilation because the fixture helper
tried to construct `FAngelscriptStaticJITScalarABIIdentity` for the generic
registration.

That failure exposed a real contract defect rather than a fixture spelling
problem: the existing `Scalar` descriptor domain described a directly callable
native `cdecl`/`stdcall`/`thiscall` ABI, while `asCALL_GENERIC` is eligible only
for the separate AS-visible VM marshalling ABI. Treating the generic callback
as native-scalar callable would contradict the maintained bridge boundary and
could lead to an invalid function-pointer cast. A focused test was added first
and produced the expected compile RED for the missing domain.

RED evidence:

- `Saved/Build/typed-aot-exception-vm-bridge-route-red-build/20260815_203520_969_b2a6be2d`
  — fixture and five-route matrix compiled/linked PASS (`5/5` actions).
- `Saved/Tests/typed-aot-exception-vm-bridge-route-red/20260815_203544_308_0fae7b77`
  — exact matrix `0/1`; the generation fixture rejected the provider-private
  generic surface before source compilation.
- `Saved/Build/typed-aot-generic-vm-abi-domain-red-build/20260815_203800_074_9bf8c5b5`
  — focused TDD compile RED: `VMScalarBridge` was not yet a declared ABI domain.

The descriptor now has an explicit `VMScalarBridge` domain. It retains the
exact installed native ABI only for registration identity and readable target
metadata, requires an empty native scalar-call ABI, provider-private linkage,
the reviewed scalar lifetime flags and bridge-only routing. Generation still
constructs and persists the separate `FAngelscriptTypedASTJITVMBridgeABIIdentity`
from the AS-visible parameter/result shape. The generic fixture records its
actual callback type `void(asIScriptGeneric*)`; it is never advertised or cast
as `int32(int32)`.

Focused GREEN and stale-output RED evidence:

- `Saved/Build/typed-aot-generic-vm-abi-domain-green-build/20260815_203930_859_ee71bfdb`
  — public Runtime header/snapshot change rebuilt and linked PASS (`97/97`
  actions).
- `Saved/Tests/typed-aot-generic-vm-abi-domain-green/20260815_204133_433_db892a30`
  — focused descriptor contract `1/1 PASS`.
- `Saved/Tests/typed-aot-exception-vm-bridge-stale-provider-red/20260815_204207_712_f4468577`
  — exact five-route matrix remains intentionally `0/1`: source compilation and
  Provider publication succeed, but the old generated artifact reports
  `verified=62 exact=61 native=61 vm=1`; only the new exception root is not yet
  native. This is the required proof that the checked-in output must be
  regenerated rather than silently accepted or hand-edited.

### Compiler-authoritative Native ABI preparation boundary

Official regeneration alone did not make the fifth root native. A real
Generation Engine integration test was therefore added around the production
TypedAST backend rather than weakening the five-route oracle. It proves that
the resolved generic system call, environment reference, `VMScalarBridge`
descriptor and VM bridge ABI are all present in the frozen snapshot, then asks
the real call-closure builder to emit the root.

The first backend RED failed closed with `NativeABIMismatch`. Printing both
canonical identities reduced the difference to one field:

```text
Descriptor ... paramSize=0;returnSize=0
Expected   ... paramSize=1;returnSize=0
```

The descriptor is attached immediately after `RegisterGlobalFunction`, while
the snapshot is captured after `asCScriptEngine::PrepareEngine()`.
`PrepareSystemFunctionGeneric()` assigns `sysFuncIntf->paramSize` only at that
later boundary from `asCScriptFunction::GetSpaceNeededForArguments()`. The
registration already owns the authoritative parameter types and calculated
stack layout, so persisting the mutable, not-yet-prepared interface cache made
one logical ABI hash differently at the two legitimate observation times.

RED evidence:

- `Saved/Build/typed-aot-generic-vm-bridge-backend-red-build/20260815_205131_788_e59d07fd`
  — real Generation Engine/TypedAST integration test compiled and linked PASS.
- `Saved/Tests/typed-aot-generic-vm-bridge-backend-red-2/20260815_205241_373_4ae70e3f`
  — exact `0/1`; the backend rejected only the descriptor/expected Native ABI
  comparison.
- `Saved/Build/typed-aot-generic-vm-bridge-canonical-red-build-2/20260815_205712_855_4205d075`
  — canonical diagnostic refinement compiled and linked PASS.
- `Saved/Tests/typed-aot-generic-vm-bridge-canonical-red/20260815_205734_482_cd8b0062`
  — exact `0/1`; the canonical output proves `paramSize=0` versus `1` is the
  complete mismatch and ties it to the Generic preparation boundary.

The Native ABI builder now derives canonical `paramSize` directly from every
registered parameter type's stack DWORD size. This is the exact value
`PrepareSystemFunctionGeneric()` later caches, but it is stable immediately
after registration. Attachment and post-prepare snapshot capture therefore
compare the same logical ABI without calling `PrepareEngine()` early or
weakening strict validation.

GREEN evidence:

- `Saved/Build/typed-aot-generic-vm-bridge-native-abi-green-build/20260815_210024_186_f16723af`
  — normalized Native ABI implementation compiled and linked PASS.
- `Saved/Tests/typed-aot-generic-vm-bridge-native-abi-green/20260815_210043_438_64b8bb6f`
  — real Generation Engine/TypedAST backend integration `1/1 PASS`; the generic
  bridge root emits its named `InvokeBound<int32, int32>` call and immediate
  exception check.
- `Saved/Commandlet/typed-aot-generic-vm-bridge-regenerate-green/20260815_210137_057_02443a10`
  — official `AngelscriptTestJIT -Mode=Generate` PASS with zero errors. The
  checked-in module source now contains the generic Fail and later Add rows,
  stable reference slots and a TypedAST body with no legacy execution context
  or Bytecode `SCRIPT_CALL_NATIVE` path for this root.

### Per-root bridge-row symbol collision RED

Compiling the officially regenerated one-file-per-AS-module output exposed the
next real integration defect. `TypedASTPrivateBridgeShowcase` and
`TypedASTPrivateBridgeException` are separate roots in the same AS module and
both call `TypedASTProviderPrivateAdd`. Each root correctly owns and de-duplicates
its immutable bridge row, but the row symbol was derived only from the target
name/key. Concatenating both roots into the module's single `.jit.cpp` therefore
defined `ASJIT_Call_TypedASTProviderPrivateAdd_6b00a476` twice.

This is not a reason to split the generated module file. The fix must preserve
one row per exact target inside each root closure while adding the owning root
function key to the C++ identifier so rows from different closures cannot
collide.

RED evidence:

- `Saved/Build/typed-aot-generic-vm-bridge-generated-green-build/20260815_210258_593_2620298e`
  — expected compile RED in
  `ASStaticJITTypedPrivateBridgeFixture.9d65c50b.EditorDevelopment.jit.cpp`;
  MSVC reports the exact duplicate immutable Add row at lines 43 and 250.

### Per-root bridge-row symbol collision GREEN

Bridge-row symbol assignment now accepts the owning root's stable function key.
The readable target stem and target-key prefix remain intact, while the full
owning root key is appended to the C++ identifier. This preserves one immutable
row per exact target inside one root closure and makes identical targets from
different roots unique when the required one-AS-module/one-`.jit.cpp` output
concatenates their bodies. Reversing target discovery remains deterministic,
and generated files are still produced only through the maintained commandlet.

Changing the exported helper signature initially exposed a bootstrap boundary:
the already-built `AngelscriptTest` DLL imported the previous two-argument
helper while rebuilding that module also compiled the stale colliding TestJIT
source. The original exported overload is therefore retained as a deterministic
compatibility entry for model/test consumers; production generation always
uses the new owner-scoped overload. No generated source was hand-edited.

Final GREEN evidence:

- `Saved/Build/typed-aot-bridge-row-root-scope-runtime-compat-build/20260815_210821_086_f5d9c668`
  — Runtime compatibility overload compiled and linked PASS, allowing the
  maintained generator to load the existing Test DLL during regeneration.
- `Saved/Commandlet/typed-aot-bridge-row-root-scope-regenerate-2/20260815_210846_848_ae2030c1`
  — official TestJIT generation PASS. The module output contains four bridge
  rows with four unique identifiers; the two Add rows retain the same target
  prefix but have distinct owning-root suffixes.
- `Saved/Build/typed-aot-generic-vm-bridge-generated-root-scope-green-build/20260815_210925_365_e4e049f5`
  — complete Editor Development project build PASS (`14/14` actions), including
  compilation/link of the regenerated one-file-per-AS-module TestJIT sources.
- `Saved/Tests/typed-aot-bridge-row-root-scope-green/20260815_211126_940_7c893c8e`
  — exact deterministic/readable/collision model test `1/1 PASS`. The runner
  wrapper was interrupted after launch, so this evidence is read from the
  completed Automation report (`succeeded=1`, `failed=0`).
- `Saved/Tests/typed-aot-exception-five-route-generated-green/20260815_211210_213_129794a8`
  — exact five-route public exception matrix `1/1 PASS`. The provider-private
  Generic route reports `context-adoption / vm`, calls the failing target once,
  adopts the expected message/function exactly once, and suppresses the later
  Add side effect (`LaterSideEffects=0`).
- `Saved/Tests/typed-aot-generic-vm-bridge-root-scope-final-green/20260815_211255_765_fa1f0a8d`
  — real Generation Engine + production TypedAST backend integration `1/1
  PASS` after the final regeneration and module build.

Task-boundary note: this closes the fifth exception route and its concrete
provider-private Generic bridge integration. Tasks 4.15 and 4.16 remain open
because their acceptance matrix also names the public `UASFunction` entry.
Task 5.9 remains open until its remaining inspection/dump and lifecycle clauses
are explicitly reconciled; the passing fifth route is not used to inflate the
checklist.

## 2026-08-15 — public UASFunction exception route, first RED boundary

The sixth exception-matrix row now drives a real reflected public entry:

```text
public AS wrapper
  -> test-only Generic trigger
  -> UASFunction::RuntimeCallEvent
  -> current TypedAST root
  -> provider-private Generic VM bridge failure
```

The fixture/test module compiled, the maintained TestJIT commandlet generated
the new wrapper plus complete VM/raw/parameter entries, and the regenerated
TestJIT DLL built successfully. The first runtime RED failed before exception
adoption at the entry-selection assertion: the `Parms` execution count stayed
unchanged.

RED evidence:

- `Saved/Build/typed-aot-public-uasfunction-red-build/20260815_212132_010_d0d90aa5`
  — fixture and matrix changes compiled and linked PASS (`5/5` actions).
- `Saved/Commandlet/typed-aot-public-uasfunction-red-regenerate/20260815_212202_591_fff33832`
  — maintained TestJIT generation PASS with zero errors; the generated module
  contains `TypedASTPublicUASFunctionExceptionEntry` VM/raw/parameter entries.
- `Saved/Build/typed-aot-public-uasfunction-red-generated-build/20260815_212535_701_5b46c590`
  — regenerated project/TestJIT build PASS.
- `Saved/Tests/typed-aot-exception-six-route-public-uasfunction-red/20260815_212556_521_b3a3f2f2`
  — exact matrix `0/1`, failing only the assertion that the reflected call must
  increment the current Typed root's `Parms` execution count exactly once.

Root cause: static script-library `UFUNCTION`s are Blueprint-thread-safe by
default unless their metadata contains `NotBlueprintThreadSafe`. The fixture's
public target therefore used the intentional thread-safe generic VM wrapper;
that route is not allowed to enter the game-thread JIT `ParmsEntry`. This is a
fixture precondition mismatch, not evidence that the current Binding or
`RuntimeCallEvent` dispatch is stale. The fixture must explicitly opt out of
Blueprint thread safety before the second RED can characterize the intended
public `ParmsEntry` exception-adoption boundary.

Follow-up diagnosis corrected the first hypothesis: after adding
`NotBlueprintThreadSafe`, runtime evidence reports
`WrapperClass=ASFunction_NotThreadSafe`, metadata present, the authoritative
root Binding has a non-null `ParmsEntry`, and the test-only public trigger runs
once. Nevertheless its `Parms` count remains `0`; the outer context finishes
with no exception and executes one later side effect. Exact evidence:

- `Saved/Tests/typed-aot-exception-six-route-public-uasfunction-observation-diagnostic-red/20260815_213405_581_a307f9b0`
  — `Status=0`, empty exception/callback/JIT record, `TriggerCalls=1`,
  `LaterSideEffects=1`, `Before=0`, `After=0`.

Therefore metadata/class selection is now proven correct, but the call made by
the trigger still falls back to a nested VM context instead of acquiring the
same authoritative function's current Binding. The next diagnostic boundary
is exact per-call UASFunction/function identity plus the Binding returned by
`AcquireJITBindingForExecution`; production exception publication must not be
changed until that entry-selection discrepancy is explained.

## 2026-08-15 — exported Bind current-address reuse RED

The generated-address audit distinguished relocatable DLL symbol linkage from
current-Engine rebinding semantics. Existing `DirectExported` output contains
no numeric process address, but it does freeze the descriptor symbol as the
executable target and therefore cannot follow a different callable installed
under the same AS identity in another Engine or after rebind. The accepted
replacement keeps true header-inline behavior direct and routes non-inline
reviewed scalar native calls through a stable key/ABI/reference slot plus
`InvokeBoundNative`; Generic/unreviewed forms stay on `InvokeBoundViaVM`.

RED tests now require generated output to name `CurrentNativeBinding`, thread
the existing `FScriptExecution`, emit `InvokeBoundNative<...>` with a named
call-site row, and avoid calling the descriptor symbol. A runtime test reuses
one call-site row while swapping the Engine-local slot between two registered
native functions and requires the second address to take effect.

RED evidence:

- `Saved/Build/typed-aot-current-native-binding-red/20260815_214604_485_8e9db962`
  — expected compile errors identify the missing
  `EAngelscriptTypedASTJITCallEmissionRoute::CurrentNativeBinding`,
  `EAngelscriptJITNativeCallSiteRoute::CurrentNativeBinding`, and
  `AngelscriptTypedASTJIT::InvokeBoundNative` production contracts.
- The same adaptive non-unity build independently exposed missing
  `AS_NATIVE_*`/generated-source helper includes in unrelated SDK test unity
  shards. Those errors are recorded as a separate build hygiene issue and are
  not accepted as the new feature's RED oracle; the exact new-test diagnostics
  are present later in the complete log.

## 2026-08-15 — provider-private safe-native promotion RED

The follow-up ABI audit corrected the remaining linkage/dispatch conflation.
An unexported provider-private function cannot be named from generated C++, but
its current Engine registration still owns the real `sysFuncIntf->func`.
Therefore an explicitly reviewed global by-value scalar `CDECL`/`STDCALL`
target that cannot set script exceptions can use the already implemented
`CurrentNativeBinding` route. DLL export visibility is not an ABI-safety
criterion. Generic callbacks, receiver/hidden/default/WorldContext/return-on-
stack forms and may-set-exception targets remain VM-only.

New RED coverage requires:

- descriptor validation to distinguish `CurrentNativeCall` from both direct
  symbol linkage and `ScalarBridge`;
- an exception-capable provider-private target to fail that route closed;
- the pure closure planner to emit an explicit `CurrentNativeBinding`
  disposition for a frozen provider-private target carrying a valid current-
  Engine EnvironmentSymbol reference; and
- existing provider-private Generic coverage to remain `ScalarBridge`/VM.

RED evidence:

- `Saved/Build/typed-aot-provider-private-current-native-red/20260815_223818_307_2109f7c5`
  — expected compile failure only at the missing production vocabulary:
  `CurrentNativeCall`, validation/target `bCurrentNativeCallable`, and closure
  disposition `CurrentNativeBinding`. The failure confirms the test boundary
  precedes the implementation rather than merely observing the old Bridge.

GREEN evidence:

- `Saved/Build/typed-aot-provider-private-current-native-implementation-build/20260815_224118_354_5adacff3`
  — fresh implementation build PASS, 97/97 UBT actions.
- `Saved/Tests/typed-aot-provider-private-current-native-linkage-green/20260815_224412_787_e993d01a`
  — native-call descriptor/linkage matrix 8/8 PASS. The reviewed provider-private
  scalar target selects `CurrentNativeCall`; the Generic target and an
  exception-capable target still fail closed to their VM/fallback contracts.
- `Saved/Tests/typed-aot-provider-private-current-native-closure-green/20260815_224624_820_fd7fc772`
  — TypedAST call-closure matrix 14/14 PASS, including exact selection of
  `CurrentNativeBinding` for the reviewed provider-private scalar call.

The remaining proof for this reopened task is the generated-source loop:
regenerate `AngelscriptTestJIT`, inspect the emitted indirect current-Engine
binding call, rebuild the generated module, and execute the AOT replacement /
unbind fallback tests.

## UFunction and AngelScript descriptor introspection boundary

Generation-time code can reconstruct a complete, exact view of an
AngelScript-owned Unreal function, but there is deliberately no claim that a
bare `UFunction*` contains every AngelScript fact. The data is split across:

- `UFunction` / `UASFunction`: UE flags, metadata, `FProperty` parameter layout,
  parameter-struct offsets, WorldContext marshalling, VM argument behavior, and
  installed VM/Raw/Parms JIT entries;
- `FAngelscriptFunctionDesc`: source/script/original names, descriptor metadata,
  return/argument declarations, Blueprint/RPC/access/static/const/thread-safe
  flags, source line, exact `ScriptFunction`, and generated `UFunction` links;
- `asCScriptFunction` plus maintained-fork Typed Semantic HIR: compiler-owned
  declaration/signature, receiver form, hidden/default arguments, resolved
  calls/members, traits, evaluation order, and source spans;
- StaticJIT root/entry/native-call plans: stable module/function/descriptor keys,
  entry-plan hash, VM/Raw/Parms availability, native linkage/ABI route, and the
  current Engine reference slot.

`BuildAngelscriptTypedASTJITRootIndex` already joins the final descriptor graph
to the exact compiled function and stable function identity without name-only
matching. Full descriptor pointers remain task-local and synchronous; generated
providers must remain pointer-free. A future unified debug API should therefore
freeze a read-only `FAngelscriptFunctionIntrospectionSnapshot` keyed by stable
FunctionKey, with separate Unreal, ScriptDescriptor, Compiler, and JIT sections.
It must never serialize `UFunction*`, `FAngelscriptFunctionDesc*`, Engine-local
function IDs, or native function addresses. Native C++ `UFunction`s have no
AngelScript descriptor/HIR section and must report those sections as absent
rather than synthesize misleading data.

### Literal-asset role audit

The literal-asset lowering does not define an `asTRAIT_ASSET` bit. Its exact
identity is distributed across two authoritative facts:

- the generated `__Init_<Name>(Type <Name>)` declaration carries
  `external_implicit_this`, which becomes
  `asTRAIT_EXTERNAL_IMPLICIT_THIS` and makes declared parameter zero the
  effective receiver;
- the generated `Get<Name>()` is stored by exact module lifecycle identity in
  `FAngelscriptModuleDesc::PostInitFunctions` and is invoked by
  `FAngelscriptClassGenerator::CallPostInitFunctions()` after class setup.

`asTRAIT_GENERATED_FUNCTION` is a separate `__generated` token and is not a
reliable literal-asset classifier. Current HIR already retains the external
receiver trait and the scalar eligibility matrix rejects it, so the existing
profile fails closed. Task 2.22 records the missing positive introspection
model: freeze a pointer-free literal-asset role by joining the exact compiled
function with the module's authoritative post-init record, never by generated
name prefixes. This becomes a prerequisite for a later object/receiver profile,
not a reason to weaken the current fallback.

### AS-function markers and first-parameter metadata audit

The follow-up audit separated three similarly named mechanisms that must not
be conflated:

- Unreal-reflected script methods are explicitly identifiable as
  `UASFunction` (or one of its optimized/JIT subclasses), and the wrapper owns
  the current `ScriptFunction` association plus the reflected argument and
  dispatch plan. This is the correct first gate when joining a `UFunction` to
  AngelScript state; the exact descriptor join still uses
  `FAngelscriptFunctionDesc::Function/ScriptFunction`, not a short name.
- the VS Code parser has `ASScopeType::LiteralAsset`, `ASLiteralAsset`, and
  `DBProperty::isLiteralAsset`. Those are editor/source-model records and are
  not Runtime JIT identity or an `asCScriptFunction` trait.
- native Binds have a separate maintained-fork ABI marker,
  `asSSystemFunctionInterface::passFirstParamMetaData`, set by
  `.PassScriptFunctionAsFirstParam()` or
  `.PassScriptObjectTypeAsFirstParam()`. During authoritative VM dispatch,
  `CallSystemFunction` injects the selected `asCScriptFunction*` or its
  `objectType` before the visible arguments.

The last mechanism is relevant to TypedASTJIT native calls. Current code is
already fail-closed in the safe direction: installed inventory and native ABI
identity retain `firstMetadata`; automatic VM-scalar admission requires
`None`; `TryBuildAngelscriptStaticJITScalarABIIdentity`,
`IsReviewedCurrentNativeCandidate`, and the current-native resolver all reject
non-`None` metadata. A VM bridge can preserve the behavior because it prepares
and executes the current registered system function through the maintained AS
context, where the authoritative dispatcher performs the injection.

The remaining gap is explicit regression coverage. Task 5.14 now requires
real registered functions for both metadata modes, proves exact current-Engine
injection through VM dispatch, and proves direct/current-native lowering never
silently drops the hidden pointer. Future direct support is deliberately not
assumed: it needs a versioned host-argument plan and pointer lifetime contract.

## 2026-08-15 — provider-private current-native generated loop

The maintained TestJIT workflow regenerated the provider and proved the
generated module compiles. Evidence:

- baseline build:
  `Saved/Build/typed-aot-provider-private-current-native_01_baseline_build/20260815_224741_407_84c63568`;
- Generate commandlet result 0:
  `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-provider-private-current-native_02_generate/20260815_224756_126_ae56a7ff`;
- generated-source build PASS:
  `Saved/Build/typed-aot-provider-private-current-native_03_generated_build/20260815_224820_345_89a00ba4`;
- Verify commandlet result 0:
  `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-provider-private-current-native_04_verify/20260815_224831_338_9b8bf8a7`.

The generated `ASStaticJITTypedPrivateBridgeFixture...jit.cpp` now records and
executes:

`int TypedASTProviderPrivateAdd(int, int)` ->
`AngelscriptTypedASTJIT::InvokeBoundNative<int32, int32, int32>` ->
`CurrentNativeBinding` -> `ResolveBoundNative` -> reference slot 0.

It contains no target-symbol call, pointer literal, Engine-local FunctionId, or
`FAngelscriptJITExecutionContext`. The Generic
`TypedASTProviderPrivateFail(int)` remains `InvokeBound<int32, int32>` ->
`Bridge` -> `InvokeBoundViaVM`. Focused regenerated-provider runtime proof is
GREEN: `TypedASTProviderPrivateCallUsesCurrentEngineReferenceSlot` and
`TypedASTProviderPrivateCallRefreshesForReplacementEngineAndUnbindsToVM` both
PASS, including replacement-Engine address refresh and unbind-to-VM behavior.

The broad regenerated AOT run did not pass as a whole: its structured report at
`Saved/Tests/typed-aot-provider-private-current-native_05_tests/20260815_224854_882_4526d709`
has two stable exception-path regressions,
`ExceptionRouteMatrixCharacterizesExecutionPaths` and
`NestedGeneratedExceptionPropagates`. The former also fails in isolation at
`Saved/Tests/typed-aot-provider-private-exception-matrix-isolated/20260815_225236_860_d44d18fd`.
This does not invalidate the current-native dispatch proof, but it keeps the
overall change open and moves execution to the already-unchecked exception
contract tasks 4.15-4.16. Do not report the full AOT suite as GREEN.

## 2026-08-15 — first-failure exception publication and owned stack closure

Tasks 4.15-4.16 are now closed. The previous broad AOT failures were not
native-call dispatch failures: they exposed two independent gaps in the
Runtime exception compatibility boundary.

First, a nested generated entry shared its `asSJITFailureRecord` but not the
fast-path `bExceptionThrown` flag with its caller. `FScriptExecution` teardown
now propagates that stop signal to `prevExecution`, while the shared record
continues to preserve the first diagnostic. `HasContextExceptionPublisher()`
walks the execution chain so nested raw/parameter entries defer their one-shot
report to the public owning context instead of logging twice. This restored the
table-driven VM, BytecodeJIT, direct nested JIT, Typed helper, bridge and public
`UASFunction` outcome/message/function/section/row/column/route/report-count
matrix.

Second, the inner generated `FailForAOT` frame was live when the first failure
was recorded but gone when the outer public context finally invoked its
exception callback. The first attempt correctly captured an owned,
pointer-free stack in `asSJITFailureRecord`, but the temporary context adoption
copied only scalar diagnostic fields into the outer record. The final fix
copies `CapturedStackModule` and `CapturedStackFrames` only when the outer
`TryRecordException()` accepts that nested record. A pre-existing outer failure
therefore still wins and its stack is never overwritten. `PublishException()`
copies the complete record to the public `asCContext` before its callback, and
logging consumes that explicit snapshot instead of stale TLS frames.

RED evidence retained:

- `Saved/Tests/typed-aot-nested-generated-exception-after-propagation/20260815_232958_389_de75ce68`
  — exception status/message/function/source were correct, but the final log
  contained zero `FailForAOT` frames and only one surviving outer frame;
- `Saved/Tests/typed-aot-context-owned-stack-snapshot-green/20260815_234059_257_d902f916`
  — proved context-side publication alone was insufficient because nested
  adoption had already discarded the captured array.

GREEN evidence:

- `Saved/Build/typed-aot-adopt-captured-stack-green/20260815_234740_094_af065ca8/Build.log`
  — incremental Runtime build PASS, 4/4 UBT actions;
- `Saved/Tests/typed-aot-adopt-captured-stack-green/20260815_234811_366_09848cc7`
  — exact nested generated exception 1/1 PASS and logs two owned
  `FailForAOT` plus two `ExceptionEntryForAOT` frames;
- `Saved/Tests/typed-aot-exception-stack-aot-regression/20260815_234900_540_4d6c4f90`
  — complete currently discovered AOT class 22/22 PASS, including the route
  matrix, public `UASFunction`, raw/VM/parameter entries, Typed helpers,
  private bridge, recursion and the nested generated exception;
- `Saved/Tests/typed-aot-first-failure-nested-regression/20260815_235011_852_e86a9924`
  — focused first-failure-wins nested execution 1/1 PASS;
- `Saved/Build/typed-aot-exception-stack-final-build/20260815_235102_003_19da755a`
  — fresh final build invocation PASS (`Result: Succeeded`, target up to date).

The stack snapshot contains owned strings only. It retains no
`FScopeJITDebugCallstack*`, `asCScriptFunction*`, `UObject*`, Engine-local
function ID as dispatch identity, or generated-provider pointer. Shipping keeps
the fields empty because debug-callstack capture remains compiled out. This
closes diagnostic preservation without changing the generated Provider ABI or
the existing execution-entry layout.

## 2026-08-16 — authoritative Literal Asset function roles

The Literal Asset marker audit is now implemented rather than inferred. There
is still no `asTRAIT_ASSET`: the Runtime authority is the preprocessor action
that creates the exact Getter/Initializer pair and appends the Getter to
`FAngelscriptModuleDesc::PostInitFunctions`. The preprocessor now retains one
`FAngelscriptLiteralAssetFunctionDesc` per declaration with owned strings for
the asset name, declared type, exact Getter, exact Initializer, and the exact
PostInit array index. This record is created at the generation site; downstream
code never reconstructs it from `Get*`, `__Init_*`, or `__Asset_*` prefixes.

StaticJIT snapshot capture joins each pair only after all functions in the
module have been captured. It first verifies that pair records are in strictly
increasing PostInit order and exact-match the indexed Getter. It then requires
one unique root-namespace zero-parameter Getter and one unique root-namespace,
one-parameter Initializer carrying `asTRAIT_EXTERNAL_IMPLICIT_THIS`. Missing,
ambiguous, reordered, colliding, or structurally inconsistent records fail the
generation task closed. The resulting pointer-free
`EAngelscriptStaticJITLiteralAssetFunctionRole::{None,Getter,Initializer}` is
copied into the immutable generation snapshot and compiled backend view. No
Engine-local function pointer, FunctionId, UObject pointer, or address becomes
the persistent role identity.

This is deliberately separate from both other mechanisms found in the audit:

- `UASFunction` identifies a reflected Unreal wrapper whose implementation is
  AngelScript; it does not identify Literal Asset helper functions;
- `asEFirstParamMetaData::ScriptFunction|ScriptObjectType` is hidden native
  Bind ABI metadata injected by the VM dispatcher; it is not a Literal Asset
  or `UASFunction` marker;
- VS Code's `ASScopeType::LiteralAsset`, `ASLiteralAsset`, and
  `DBProperty::isLiteralAsset` describe the editor/source model only.

The generated Initializer test proves that its HIR receiver is
`ExternalImplicitThis` at declared parameter index zero. Namespace-local
functions with identical short names remain `None`, proving that names alone
cannot confer the role. Both authoritative roles remain ineligible under the
current scalar TypedASTJIT profile, so asset creation, UObject lifetime, and
receiver behavior continue through VM fallback. A future object profile still
requires the additional generated/authored provenance and replacement contract
named in task 2.22; this change does not silently open that surface.

The pair record currently belongs to the source/preprocessor generation view.
Ordinary runtime and precompiled execution continue to use the existing
`PostInitFunctions` contract and do not need this role metadata. If a future
offline generation mode consumes restored module descriptors without running
the authoritative preprocessor, it must version and serialize the complete
pair record; it must not fall back to prefix inference.

TDD and focused verification evidence:

- RED compile:
  `Saved/Build/typed-aot-literal-asset-role-red/20260815_235944_980_a0283a2f`
  failed because the authoritative pair and generation/backend role fields did
  not yet exist;
- implementation build:
  `Saved/Build/typed-aot-literal-asset-role-green-build/20260816_000437_411_3d99a6bf`
  — 29/29 UBT actions PASS;
- final focused build after source-owner assertions:
  `Saved/Build/typed-aot-literal-asset-preprocessor-assertions-build/20260816_001640_922_a74368c2`
  — 4/4 UBT actions PASS;
- exact role/order/decoy/HIR/fallback test:
  `Saved/Tests/typed-aot-literal-asset-role-green-exact-3/20260816_001118_224_4b54c8db`
  — 1/1 PASS;
- preprocessor Literal tests after direct pair assertions:
  `Saved/Tests/typed-aot-literal-asset-preprocessor-authority-green/20260816_001700_397_0cd09fdb`
  — 7/7 PASS;
- runtime asset materialization/coexistence:
  `Saved/Tests/typed-aot-literal-asset-runtime-regression/20260816_001454_107_7d7326de`
  — 3/3 PASS;
- Hot Reload object replacement:
  `Saved/Tests/typed-aot-literal-asset-hotreload-regression/20260816_001532_910_809c4714`
  — 1/1 PASS.

One broader Generation Engine class run also exposed an independent current
branch expectation mismatch:
`Saved/Tests/typed-aot-literal-asset-bridge-regression/20260816_001210_369_12eefad4`.
The former
`ProductionTypedASTClosureSharesOneBridgeRowAcrossRootAndHelper` still assumed
that `TypedASTProviderPrivateAdd` used `Bridge`. That expectation predates the
reviewed provider-private scalar contract completed by task 5.10. The current
descriptor correctly selects `CurrentNativeBinding`, and both the root and its
direct helper share one immutable current-native call-site row and reference
slot. The regression test is now named
`ProductionTypedASTClosureSharesOneCurrentNativeRowAcrossRootAndHelper` and
requires both sites to select `CurrentNativeBinding`, emit
`InvokeBoundNative<int32, int32, int32>`, and contain neither
`InvokeBoundViaVM` nor `FAngelscriptJITExecutionContext`.

An initial diagnostic assertion incorrectly required the complete generated
template to omit `FScriptExecution& Execution` and failed at
`Saved/Tests/typed-aot-current-native-shared-row-green/20260816_002119_626_cf174dae`.
That assertion was wrong: `CurrentNativeBinding` intentionally receives the
entry-owned `FScriptExecution` so the fixed Runtime resolver can load the
selected Engine's already-adopted numeric slot and honor rebind/unbind/Engine
replacement. It does not create an AngelScript VM context. Removing that false
assertion preserves the stronger route-specific checks and the user-requested
absence of `FAngelscriptJITExecutionContext`.

Reconciliation evidence:

- `Saved/Build/typed-aot-current-native-shared-row-test-fix-build/20260816_002217_882_703c8229`
  — 4/4 UBT actions PASS;
- `Saved/Tests/typed-aot-current-native-shared-row-green-2/20260816_002240_010_84335804`
  — exact corrected route/row test 1/1 PASS;
- `Saved/Tests/typed-aot-generation-engine-literal-current-native-green/20260816_002320_089_20bf1465`
  — complete Generation Engine class 28/28 PASS, covering both the new Literal
  Asset role and the corrected current-native closure contract.

## 2026-08-16 — hidden first-parameter Bind metadata contract

Task 5.14 is now closed with real Fluent-Bind, installed-inventory, runtime
dispatch, current-Engine replacement and generated-output coverage. The two
maintained-fork modes are not AngelScript-visible parameters:

- `.PassScriptFunctionAsFirstParam()` stores
  `asEFirstParamMetaData::ScriptFunction` on the registered
  `asSSystemFunctionInterface` and the authoritative VM dispatcher injects the
  exact selected `asCScriptFunction*`;
- `.PassScriptObjectTypeAsFirstParam()` stores
  `asEFirstParamMetaData::ScriptObjectType` and the dispatcher injects that
  selected function's exact `objectType`.

The registered Native ABI and the separate VM-bridge ABI both freeze the exact
`firstMetadata=<enum>` token. The scalar ABI builder rejects either mode with
`NativeScalarABIUnsupportedHiddenState`; reviewed `CurrentNativeBinding` and
automatic scalar-bridge admission also require `None`. This prevents a typed
indirect call from silently dropping the host-only pointer. The supported path
is `InvokeBound -> InvokeBoundViaVM -> asIScriptContext::Execute ->
CallSystemFunction`, where the maintained dispatcher owns injection. Two
separate Engines prove the same generated/runtime call-site view resolves the
current slot and receives the current Engine's function rather than retaining
the first Engine's pointer. `InvokeBoundNative` rejects the row before invoking
the callback.

Generation coverage deliberately consumes the production
`UObject::StaticClass()` Bind instead of adding a test-only providerless
registration. The final installed inventory row has `ScriptFunction`, a valid
Native ABI containing `firstMetadata=1`, and no scalar ABI. Its Engine-local
function ID is absent from the immutable `NativeCallTargets` set, proving that
neither automatic scalar nor current-native lowering admitted it. TypedASTJIT
returns `Unsupported` with no emitted function body; its module preamble names
neither `StaticClass` nor `asCScriptFunction`. Consequently no generated C++
can contain a baked function pointer or fabricate the hidden pointer as an AS
formal parameter.

The production fixture currently also reports `InvalidCleanupPlan` for the
discarded `UClass` expression before call-closure diagnostics. The regression
therefore does not assert one particular root fallback-detail string. The
metadata-specific rejection is instead proved at the exact ABI and frozen
target-admission boundaries, while the backend assertion proves that no C++
body escaped through another route. Direct support remains deferred until a
separately versioned typed host-argument plan can specify pointer lifetime and
current-Engine ownership.

Debugging notes retained:

- the first two runner attempts used the class prefix without CQTest's concrete
  class-name segment and correctly reported no matching test at
  `Saved/Tests/typed-aot-hidden-first-param-generation-green/20260816_003726_423_66c411e0`
  and
  `Saved/Tests/typed-aot-hidden-first-param-discovery/20260816_003815_470_874d8e20`;
- a test-only Fluent Bind registered outside normal provider replay made the
  broad provenance inventory incomplete and failed closed at
  `Saved/Tests/typed-aot-hidden-first-param-generation-green-2/20260816_003918_782_b754624f`.
  Replacing it with the existing production `UObject::StaticClass()` row fixed
  the test design instead of weakening inventory completeness;
- the first production-row run reached the intended frozen snapshot but showed
  the independent `InvalidCleanupPlan` ordering at
  `Saved/Tests/typed-aot-hidden-first-param-production-bind-green/20260816_004212_511_7385c6aa`.

Focused GREEN evidence:

- `Saved/Build/typed-aot-first-param-metadata-test-build/20260816_003156_803_1b13c501`
  — initial metadata test implementation build, 5/5 UBT actions PASS;
- `Saved/Tests/typed-aot-first-param-metadata-runtime/20260816_003219_471_30b8f4e8`
  — exact two-mode VM injection/current-Engine/direct-native rejection test
  1/1 PASS;
- `Saved/Tests/typed-aot-first-param-metadata-inventory/20260816_003302_207_aadc274a`
  — complete installed Bind inventory metadata/ABI/rejection audit 1/1 PASS;
- `Saved/Build/typed-aot-hidden-first-param-fallback-assertion-build/20260816_004315_241_5019a851`
  — final production-Bind generation test build, 4/4 UBT actions PASS;
- `Saved/Tests/typed-aot-hidden-first-param-production-bind-green-2/20260816_004336_185_f7a42852`
  — exact production Bind admission/fallback/no-generated-pointer test 1/1
  PASS.
- `Saved/Tests/typed-aot-first-param-final-focused/20260816_004518_551_78985f58`
  — final combined real Fluent-Bind runtime injection plus complete installed
  inventory audit 2/2 PASS after all test-design corrections.

## 2026-08-16 — parser lifetime and complete function-trait normalization

Tasks 1.7 and 1.8 are now reconciled against executable Standalone evidence.
The parser ownership contract remains unchanged: `asCParser` owns its own
`FMemStackBase`, and `CreateNode` placement-constructs every raw
`asCScriptNode` in that arena. A new test installs a scoped Standalone
`FMemory` observer around a real `asCParser`, captures the exact raw syntax-root
address, proves it has not been freed while the parser is alive, and then
proves that exact address is freed by parser destruction. The test never
dereferences the pointer after destruction.

In the same fixture an independently owned, verified
`asCTypedSemanticFunction` is dumped before parser destruction and verified and
dumped again afterwards. Its normalized output remains byte-identical. A
separate architecture assertion freezes the source boundary: `asCParser` must
continue to own `FMemStackBase MemStack`, `CreateNode` must allocate
`asCScriptNode` from it, and neither the `ScriptFunctionData` definition nor
`as_typed_semantic_ir.h` may contain `asCScriptNode`. This catches a future raw
parser-node retention even if a dormant pointer is not traversed by verifier or
dumper code.

The existing table-driven trait test was already complete but its OpenSpec item
had not been reconciled. It enumerates every bit in the current `asEFuncTrait`
surface and requires their union to equal
`asTYPED_SEMANTIC_KNOWN_FUNC_TRAIT_BITS`. Each row checks the explicit header
categories for source policy, receiver, invocation, dispatch, body
availability, lifetime, and profile metadata. An unknown high bit remains
visible only in `unknownTraitBits`, enters no known category, and leaves the
HIR structurally valid so TypedASTJIT eligibility can reject it fail-closed.
The verifier separately rejects a trait summary that does not match the raw
declared bits.

Focused verification from `V:\Plugins\Angelscript\Standalone`:

- `cmake --build --preset win64-msvc-debug --target
  AngelscriptStandaloneArchitectureTests AngelscriptTypedSemanticIRTests -- /m`
  — both focused targets built successfully; MSBuild emitted only the existing
  shared-intermediate-directory `MSB8028` warning;
- `ctest --preset win64-msvc-debug -R
  "^AngelscriptStandalone\\.(Architecture|TypedSemanticIR)$"
  --output-on-failure`
  — 2/2 PASS in 0.43 seconds.

No Runtime/public ABI, parser ownership behavior, HIR layout, or generated JIT
code changed in this closure; it adds durable characterization and architecture
guards only.

## 2026-08-16 — native compiler snapshot helper final reconciliation

Task 1.10's former external blocker is cleared. The task had intentionally
remained unchecked after its Standalone implementation because the native UE
consumer could not receive a fresh focused run while another Editor and Live
Coding Console held the UE build lock. The current worktree now executes the
complete native TypedSemanticIR class without that lock.

The ownership split is deliberate and matches the design: native and
Standalone fixtures create their own test-owned `asCScriptEngine`, enable the
fork-private capture flag before Build, and compile current source. The
fork-private `BuildTypedSemanticSnapshot` helper does not create an Engine or
perform compilation itself; it accepts only that current compilation's
function-owned in-memory HIR, verifies it, and returns the distinct
`TestHIRSnapshot` text/JSON result. Architecture coverage forbids Engine/module
construction, StaticJIT/TypedASTJIT/BytecodeJIT, Provider, UObject, context
execution and file I/O in the helper. This keeps snapshot formatting incapable
of becoming a hidden Static artifact or runtime path.

The final native run covers capture-off absence, capture-on bytecode equality,
two independent Engines with byte-identical pointer-free snapshots,
unsupported-but-valid markers, verifier-invalid snapshots retaining the exact
diagnostic without normalized success output, and unchanged VM behavior.

Final evidence:

- `Saved/Tests/typed-semantic-snapshot-native-reconcile/20260816_005436_533_836d430b`
  — exact
  `Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR` prefix,
  17/17 PASS, zero failures/skips, summary sourced from `Report/index.json`.

The first shell invocation returned control to the orchestrator after five
seconds while its child runner correctly continued in the background. A second
invocation observed the worktree runner lock and did not start another Editor.
The original run was monitored to completion and produced the evidence above;
no process was killed and no duplicate test result is counted.

## 2026-08-16 — persisted HIR non-readback matrix

Task 1.11 is closed with two complementary executable boundaries. The native
compiler fixture now compiles the scalar function once with capture enabled,
then creates four persisted-input conditions before a fresh independent Engine
compiles the same source: a stale but superficially verified `.hir.txt`, an
edited `.hir.json`, a malicious text snapshot claiming `StaticJITArtifact` and
a forged Provider ID/C++ pointer write, and an explicitly missing JSON path.
The later compilation produces byte-identical normalized HIR and bytecode,
preserves every seeded file byte-for-byte, does not create the missing file,
and returns the same VM results for all four scalar oracle inputs.

The project-generation fixture provides the artifact half of the proof. It
first builds a clean TypedASTJIT Provider baseline. It then places stale,
edited, malicious and missing HIR conditions directly beside the fixture's
`.as` source, corrupts both prior developer dump outputs, and performs a new
isolated generation. The second task still reports
`bLastTaskUsedOnlySameCompilationHIR`; Provider ID, Provider generation,
artifact-set digest, ordered file paths/kinds, every generated `.jit.cpp`, and
all Provider metadata are byte-identical to the clean baseline. Generation
neither reads, rewrites, deletes, nor packages any `.hir.txt/.hir.json` input.

These runtime tests complement the architecture guard on the fork-private
snapshot helper, which forbids file I/O and Engine/backend/provider behavior,
and the Typed backend's exact pointer-identity check between each backend view
and the owning current `asCScriptFunction::GetTypedSemanticFunction()`. A
serialized, reconstructed, stale or cross-Engine HIR therefore has no
admission route even if its text resembles a valid snapshot.

Focused evidence:

- `Saved/Build/typed-aot-hir-non-readback-build/20260816_005753_299_1e9f582c`
  — 4/4 UBT actions PASS for the artifact matrix;
- `Saved/Tests/typed-aot-hir-non-readback-green/20260816_005815_678_a9544e57`
  — exact project-generation non-readback matrix 1/1 PASS;
- `Saved/Build/typed-aot-hir-non-readback-native-build/20260816_010004_743_23e5368a`
  — 4/4 UBT actions PASS for the native bytecode/VM matrix;
- `Saved/Tests/typed-aot-hir-non-readback-native-green/20260816_010024_674_88ced47a`
  — exact compiler capture/bytecode/VM non-readback case 1/1 PASS.

No persisted HIR reader, parser, cache or interchange format was added. The
only valid TypedASTJIT input remains verified HIR owned by the exact function
from the current generation Engine's one source compilation.

## 2026-08-16 — HIR foundation group final gate

Task 1.12 now has a fresh post-change build and full native Compiler-prefix
gate. The prefix includes the 17 TypedSemanticIR cases plus all other current
compiler/builder/parser regression classes, so the new persisted-file and
parser-lifetime assertions are validated alongside the maintained frontend
rather than only in isolation.

Evidence:

- `Saved/Tests/semantic-ir-foundation-final/20260816_010153_260_8f6aafea`
  — `Angelscript.TestModule.AngelScriptSDK.Compiler`, 139/139 PASS, zero
  failures/skips, process exit 0;
- `Saved/Build/semantic-ir-foundation-final/20260816_010241_529_c5bd3555`
  — final `RunBuild.ps1 -NoXGE` invocation PASS; target was already up to date
  after the two immediately preceding 4/4-action modular builds.

No failure was observed. This closes the explicit group-1 verification gate;
it does not by itself imply that every earlier 1.1-1.4 wording has been
reconciled, which remains a separate evidence audit.

## 2026-08-16 — `IsAngelscriptGenerated` versus literal-asset identity audit

The follow-up audit separated three names that can otherwise sound like one
"AS/asset function marker":

- `IsAngelscriptGenerated(const UFunction*)` identifies reflected functions
  implemented by AngelScript by testing whether the UObject is in the existing
  `UASFunction` class family. Its `FProperty` overload recognizes properties
  owned by a `UASClass` or the exact argument/return records of a
  `UASFunction`. This classification is consumed today by debugger/reflection
  code and intentionally remains true for a stale `UASFunction` UObject after
  its backing `ScriptFunction` is cleared during module discard;
- `FAngelscriptLiteralAssetFunctionDesc` plus
  `EAngelscriptStaticJITLiteralAssetFunctionRole::{Getter,Initializer}` is the
  separate source/generation identity for generated literal-asset helpers. It
  is authoritative through the ordered `PostInitFunctions` pair and does not
  imply that either helper has an independent reflected `UASFunction` entry;
- UE `FAssetIdentifier` / AssetRegistry tags do not participate in either
  classification, and the plugin contains no special AssetRegistry identifier
  path for `UASFunction`.

No production field is needed for TypedASTJIT. The isolated generation Engine
deliberately creates no UObjects, so it must continue selecting UFUNCTION roots
from the exact `FAngelscriptModuleDesc -> FAngelscriptClassDesc::Methods ->
FAngelscriptFunctionDesc::ScriptFunction` graph and stable function identity.
At publication time TypedASTJIT attaches entries to the current
`asCScriptFunction`; normal class generation still creates one of the existing
`UASFunction` wrapper classes. Task 6.2 now explicitly requires executable
coverage that the wrapper and its owned parameter/return properties remain
`IsAngelscriptGenerated == true`, native functions remain false, stale wrapper
classification survives module replacement, and no TypedASTJIT-specific
subclass, AssetRegistry tag, UObject pointer, or duplicate origin bit is added.

## 2026-08-16 — HIR foundation 1.1–1.4 final lifecycle reconciliation

The final evidence audit found that the model, owner and deterministic tests
were already substantially implemented, but task 1.1 still lacked executable
failed-build/module-replacement/destruction boundaries and task 1.4 lacked an
explicit fail-closed Cache donor rule. The closure added those missing cases
instead of treating the earlier scalar checkpoint or broad Compiler gate as
indirect proof.

The native lifecycle RED additions are
`FailedModuleBuildPublishesNoProvisionalTypedHIR` and
`ModuleReplacementKeepsHIRBoundToExactFunctionLifetime` in
`AngelscriptNativeTypedSemanticIRTests.cpp`. The failed-build case proves a
function body compiled before a later source error does not publish any HIR in
the failed module or Engine function table. It passed on the first focused
run. The replacement case proves the replacement function and HIR are new,
while an externally retained retired function preserves its exact old HIR and
deterministic dump.

The first replacement assertion incorrectly expected the old FunctionId to
disappear immediately after the last external `Release()`. The focused RED
run was `18/19 PASS`; only that assertion failed. Maintained-fork inspection
showed this was a test-lifecycle error, not cross-function HIR retention:
`asCModule::Discard()` keeps the discarded module in `scriptModules` and its
`scriptFunctions` array retains an internal reference. The documented cleanup
boundary is `asCScriptEngine::GarbageCollect() -> DeleteDiscardedModules() ->
asCModule::~asCModule() -> InternalReset() ->
asCScriptFunction::DestroyInternal()`. The corrected test now proves the old
function/HIR remain valid after the external release while the discarded
module owns them, then requests `asGC_FULL_CYCLE` and proves the old Engine
table identity is removed without affecting the replacement function. It
never dereferences the retired pointer after that cleanup boundary.

The Cache donor RED came from the Standalone architecture guard: the restore
commit swapped all `ScriptFunctionData`, so the target's previous HIR happened
to move into the temporary donor and be destroyed, but there was no explicit
rule preventing a future donor from carrying stale/injected HIR into the
target. The guard failed only because both owners were not explicitly cleared.
`as_restore.cpp` now calls
`artifact->DiscardTypedSemanticFunction()` and
`target->DiscardTypedSemanticFunction()` immediately before the no-fail
private-data swap. A Runtime restore-hook test installs a provisional target
HIR sentinel before a valid restore and proves it is absent immediately after
the donor commit. Together these cover present target cleanup and the future
donor fail-closed invariant.

Destructor ordering remains explicit in `asCScriptFunction::DestroyInternal`:
HIR is discarded before `ReleaseReferences()`, template subtype release,
parameter/return type teardown, object-type release, and `ScriptFunctionData`
deallocation. The architecture test freezes that source order. HIR contains
owned strings/arenas and typed IDs; resolved calls are Engine-local integer IDs
rather than retained function pointers, source syntax is copied into owned
spans rather than retaining parser nodes, and the whole owner is gone before
the authoritative type/function graph is released.

The task 1.2 audit maps every requirement to direct coverage:

- invalid-by-default contiguous typed IDs and exact `asCDataType` are covered
  by the native arena/model tests and receiver/unsupported Standalone cases;
- source spans and all current safe-point roles are covered by the compiler
  source/safe-point test and exact normalized dump checks;
- global/system resolved-call targets and formal/evaluation order are covered
  without retained pointers;
- explicit nearest legal break/continue targets, while/do/for loop phases and
  switch targets are covered by structured compiler fixtures and negative
  verifier mutations;
- assignment/compound/prefix/postfix single-evaluation plans are covered by
  bytecode/VM equality and HIR-plan assertions;
- unsupported categories, normalized headers, raw trait summaries, all four
  receiver kinds, verifier failure codes and pointer-free deterministic dumps
  are covered by the native and Standalone model suites.

Fresh GREEN evidence from `V:\`:

- `Saved/Build/typed-hir-lifetime-green/20260816_012034_224_b0fafeb6`
  — modular `AngelscriptProjectEditor` build PASS, 5/5 actions; only the known
  fixture C5038/C4191 warnings;
- `Saved/Tests/typed-hir-lifetime-green/20260816_012059_998_c110d5d9`
  — exact `Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR`
  prefix 19/19 PASS, zero failures/skips;
- `Saved/Tests/typed-hir-cache-restore-green/20260816_012136_662_e018d3a3`
  — exact `Angelscript.TestModule.Cache.BuildArtifactRestoreHook` prefix 3/3
  PASS, including the new provisional-target-HIR discard assertion;
- `ctest --test-dir out/build/win64-msvc -C Debug -R
  "^AngelscriptStandalone\\.(Architecture|TypedSemanticIR)$"` — 2/2 PASS in
  0.34 seconds on the current binaries.

One attempted Standalone verification used the nonexistent guessed directory
`Build/Debug` and failed before running CTest. Discovery found the configured
tree at `out/build/win64-msvc`; the corrected command above passed. An earlier
attempt to join two CQTest method names with `+` also omitted the CQTest class
segment and matched zero tests; only the exact class-prefix runs are counted as
evidence. These were runner-invocation mistakes, not product failures.

Tasks 1.1–1.4 are now checked only after this requirement-by-requirement audit;
the already recorded full Compiler 139/139 gate remains the broader regression
evidence, while the fresh focused runs prove the newly closed lifecycle paths.

## 2026-08-16 — structured control-flow emitter, first 4.4–4.5 checkpoint

The task 6.1 fixture audit found a real dependency that the earlier scalar AOT
matrix could not bypass: the production analyzer, eligibility filter and
emitter accepted only `Block`, `LocalDeclaration`, `Expression`, `If` and
`Return`, while 6.1 explicitly requires loops, switch transfers and the
exhaustive-enum invalid-value edge. Tasks 4.4–4.5 therefore precede the next
6.1 fixture expansion. They remain unchecked until real compiler HIR is built
into the generated AOT translation unit and executed against the VM and
BytecodeJIT oracles.

The first new golden fixture constructs structurally verified HIR containing
an initializer-scoped `for`, ordered increment, `continue`, loop `break`,
`while`, body-first `do-while`, single-evaluation signed switch selector,
explicit switch `break`, source-ordered fallthrough and a final default case.
The HIR verifier accepted it before the backend was queried. The exact RED run
was:

- `Saved/Tests/typed-aot-control-flow-red/20260816_013930_930_372b33bb`
  — 19/20 PASS; the new case alone failed with `Binary operator is outside the
  scalar slice`, first on the loop `<` comparison. This is direct evidence that
  the test HIR was valid and the TypedASTJIT surface was incomplete.

The production checkpoint now admits all six scalar comparison operators and
the verified `For|While|DoWhile|Switch|Case|Break|Continue` statement set.
Emission preserves the HIR ownership tree rather than creating bytecode-offset
labels: C++ `break`/`continue` remain correct because the verifier already
requires the exact nearest legal target. A `for` initializer is emitted in an
owned C++ scope; ordered increment expressions remain in the increment phase,
so `continue` still executes them. Loop conditions and increment blocks use
small lambdas only when execution-state or position instrumentation requires
them; they stop on the first script exception and the outer function returns
before later side effects. The pure path remains ordinary typed C++.

Switch emission evaluates and normalizes the selector once, preserves ordered
case bodies, omits an implicit `break` only for a verified fallthrough, and
emits the maintained `SetSwitchValueInvalidException(Execution)` default edge
for an exhaustive enum without a source default. By-value enum ABI spelling is
the fixed signed carrier selected from its verified storage width; the common
AngelScript enum case is `int32`, so no local C++ enum declaration or live AS
type pointer enters generated text.

A second fixture uses a real `asCEnumType` and proves the verifier-mandated
`switchHasInvalidEnumValueEdge` produces an `FScriptExecution` entry, signed
`int32` cases, synthetic default, exact exception helper and default return.
Fresh GREEN evidence from `V:\`:

- `Saved/Build/typed-aot-control-flow-green-build/20260816_014516_236_f1062c89`
  — Runtime emitter build PASS;
- `Saved/Tests/typed-aot-control-flow-green/20260816_014538_758_e853b945`
  — GeneratedOutput 20/20 PASS;
- `Saved/Build/typed-aot-enum-switch-green-build/20260816_014710_562_734331b9`
  — enum-test binary build PASS;
- `Saved/Tests/typed-aot-enum-switch-green/20260816_014729_504_bf66c727`
  — final GeneratedOutput 21/21 PASS.

The first RED build also exposed two compile-order defects in the already
dirty feature tree before the behavioral test could run. The new native ABI
descriptor dereferenced `asCObjectType` without its direct `as_objecttype.h`
include, and three Disabled 2.38 conformance files depended on another unity
source file to provide `AS_NATIVE_NON_PRODUCT`. The minimal closure added the
direct production include and each test's direct
`AngelscriptNativeCaseTestSupport.h` include. The first build/test invocations
used a one-second tool observation timeout; their child processes continued,
so no duplicate command was started and the existing logs/processes were
followed to completion. Those invocation timeouts and compile blockers are not
counted as the semantic RED above.

## 2026-08-16 — real control-flow probe, Cache V2 local enum, and signed narrowing

The first real `AngelscriptTestJIT -Mode=Generate` run after the manual
structured-control-flow GREEN exposed three independent integration gaps. They
were fixed in dependency order rather than weakening the fixture or bypassing
Cache V2.

First, a global function whose body referred to a module-local enum did not
carry that enum into the Cache V2 resolver set. The new
`GlobalFunctionDependingOnLocalEnumRoundTrips` test creates one isolated enum
and one global function containing an enum cast/switch, captures the full
clean artifact, proves the stable `ScriptType` key plus expected ABI are
present, validates cold generation preparation, restores into a fresh Engine,
and executes the restored function. The full clean-capture and lightweight
diagnostic paths now share exact module/type-schema matching through
`TryAddSingleGlobalEnumDependencyAuthority`; neither path guesses from a
display name or stores an Engine-local type pointer.

That test then exposed an independent compact-wire decoder defect. A legal
short enum schema containing no optional metadata uses a 16-byte minimum
enumerator record, but the reader required 48 bytes before attempting the
record. The TypeSchema decoder minimum is now 16 bytes; later field reads
remain individually bounded, so the change accepts the existing compact form
without weakening malformed-input rejection. Focused Cache GREEN evidence is:

- `Saved/Build/typed-aot-local-enum-diagnostic-green-build/20260816_023156_817_628b5911`
  — Runtime/Test build PASS;
- `Saved/Tests/typed-aot-local-enum-diagnostic-green/20260816_023214_636_2ff8f5a8`
  — the exact full-capture, diagnostic-facts and fresh-Engine restore test
  PASS.

Second, the real generator snapshot contained six compiled modules while the
test commandlet's hand-maintained expected set still listed five. The missing
module was `ASStaticJITTypedControlFlowFixture`; it is now part of the exact
fixture set. The mismatch diagnostic was also changed from a generic graph
error to include `SnapshotModules` and `CompiledModules`, so future set drift
is directly actionable. The original RED log is
`Saved/StaticJIT/TestJIT/Commandlet/typed-aot-control-flow-local-enum-cache-green-generate/20260816_023626_835_62454ed5/Commandlet.log`.
The fix build is
`Saved/Build/typed-aot-control-flow-module-set-green-build/20260816_023751_428_b975c607`.

Third, the real compiler HIR proved the earlier manual enum test encoded the
wrong storage assumption. The source fixture performs
`ETypedASTControlMode(RawMode)` from signed `int32`; because the declared enum
values are `0..2`, the maintained compiler selects a signed one-byte enum
carrier. A permanent eligibility diagnostic captured the exact facts:
`SourceEnum=0 SourceToken=69 SourceBytes=4 SourceUnsigned=0 TargetEnum=1
TargetToken=5 TargetBytes=1 TargetUnsigned=0`. The evidence log is
`Saved/StaticJIT/TestJIT/Commandlet/typed-aot-enum-conversion-diagnostic-generate/20260816_024612_204_54ee8a8f/Commandlet.log`.

The first attempted production rule admitted only same-width signed
primitive/enum conversion. It made the strengthened manual test pass but the
real fixture still fell back, so that assumption was discarded. The final
rule admits only signed primitive integer/enum conversion across the reviewed
1/2/4/8-byte carriers; unsigned and floating sources remain fail-closed.
Widening uses ordinary typed `static_cast`. True narrowing emits the
context-free `AngelscriptTypedASTJIT::WrapNarrow<Target>` helper, which truncates
in the unsigned bit domain and reconstructs the signed target bits, avoiding
implementation-defined C++ signed narrowing and introducing no
`FAngelscriptJITExecutionContext`.

The manual enum HIR was strengthened to match the compiler shape exactly:
an `int32 RawMode` parameter, an `int8` enum local initialized by an explicit
conversion, an exhaustive switch and its invalid-value edge. One intermediate
RED incorrectly attached the initializer through `valueExpression` instead of
`initializerExpression`; the verifier correctly rejected it as `Local
initializer is outside the expression arena`. That malformed-HIR run is not
counted as a product RED. The corrected RED is
`Saved/Tests/typed-aot-enum-conversion-unit-red2/20260816_024152_081_bb5c1361`,
which failed only with the unsupported conversion reason.

Fresh end-to-end GREEN evidence from `V:\` is:

- `Saved/Build/typed-aot-enum-narrow-green-build/20260816_025006_886_2c6d69e2`
  — 17-action modular Editor build PASS;
- `Saved/Tests/typed-aot-enum-narrow-green/20260816_025054_341_ad1ef48b`
  — exact GeneratedOutput TypedASTJIT prefix 22/22 PASS;
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-control-flow-enum-narrow-green-generate/20260816_025132_652_9c391c5c/Commandlet.log`
  — real six-module generation PASS and writes the generated control-flow
  artifacts;
- `Saved/Build/typed-aot-control-flow-generated-build/20260816_025314_601_309a29be`
  — the generated `TypedASTJITScalarProbe.generated.cpp`, module `.jit.cpp`,
  Provider source and TestJIT DLL compile/link PASS;
- `Saved/Tests/typed-aot-control-flow-differential-green/20260816_025345_683_4f6a80eb`
  — exact VM/BytecodeJIT/Typed C++ structured-control-flow differential 1/1
  PASS, including the exhaustive invalid-enum exception and the execution
  counter proving the native probe ran;
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-control-flow-enum-narrow-green-verify/20260816_025434_525_f7bf26e9/Commandlet.log`
  — maintained `-Mode=Verify` generation comparison PASS.

The generated Typed body is intentionally still the group-4 test-only probe,
not the production Provider entry. It contains native C++ `for`, `while`,
`do-while`, `switch`, `WrapNarrow<int8>` and the maintained invalid-enum
exception edge. The same module's current production `.jit.cpp` remains the
BytecodeJIT entry until tasks 6.1–6.5 wire these functions through the shared
Provider/UASFunction publication seam. This is the design boundary documented
in `design.md`, not a claim that production control-flow takeover is complete.
Tasks 4.4–4.5 therefore remain unchecked until their remaining loop-phase
exception and cleanup-plan rows are audited or added; this checkpoint closes
the real compiled/differential scalar-empty-cleanup slice only.

The first broader AOT regression was `33/34 PASS` at
`Saved/Tests/typed-aot-control-flow-aot-regression/20260816_025643_351_bd27569b`.
Only `FreshCacheV2EnginePublishesAndExecutesCommittedProviderRoute` failed.
The failure was not a Cache reuse defect: its diagnostic reported the exact
persisted generation was consumed with `Modules=3` and
`RestoredFunctions=55/53`. The Core fixture had grown from two modules to
three, and Cache V2 correctly restored the two new control-flow functions,
while the proof harness still hard-coded two candidate modules and computed
the expected Provider function count from only the old two module keys.

`RestoreFreshEngineFromCacheV2` now derives its expected count from the full
Core cache module array, which includes `ASStaticJITTypedControlFlowFixture`,
and compares `CandidateModuleCount` with that array length. The public test
freezes the current three-module Core composition. The exact-start whole-module
vertical still intentionally rejects the production-shaped mixed graph and
uses function-level hybrid reuse; the assertion continues to require a current
publication rather than falsely claiming `bRestoredFromStore` exact-module
activation.

Follow-up GREEN evidence is:

- `Saved/Build/typed-aot-cache-core-module-count-green-build/20260816_025934_852_067eec1a`
  — 5-action Test module build PASS;
- `Saved/Tests/typed-aot-cache-core-module-count-green/20260816_025956_619_6782854c`
  — exact formerly failing Cache/Provider route test 1/1 PASS, reporting three
  candidates and 55 restored functions;
- `Saved/Tests/typed-aot-control-flow-aot-regression-green/20260816_030047_477_bb4ff4fe`
  — complete `Angelscript.TestModule.StaticJIT.AOT` prefix 34/34 PASS.

## 2026-08-16 — production Typed control-flow UFUNCTION roots and Cache-publication authority

The control-flow fixture's two scalar roots are now real production
`UFUNCTION` roots rather than only test-probe helpers:
`SemanticStructuredControlFlow(int,int)` and
`SemanticExhaustiveEnum(int)`. A test-only production-backend assertion was
added first. The correct TestJIT generation RED is
`Saved/StaticJIT/TestJIT/Commandlet/typed-aot-production-control-flow-red2_02_generate/20260816_031019_895_b5a8825f/Commandlet.log`; it rejected the first root with
`typed-ast:1:NotUFunctionRoot` and then exhausted bytecode fallback. An earlier
attempt through `Tools/RunAngelscriptJIT.ps1` targeted the unrelated generic
project scaffold and is retained only as a wrong-runner diagnostic, not as
product RED evidence.

Adding the existing `UFUNCTION()` source annotation to the two fixture roots
closed that RED without adding a Typed-specific reflection type. Generation
at
`Saved/StaticJIT/TestJIT/Commandlet/typed-aot-production-control-flow-green_02_generate/20260816_031114_602_a02da1f4/Commandlet.log`
passed. The resulting production module
`ASStaticJITTypedControlFlowFixture.e3b08a3c.EditorDevelopment.jit.cpp`
contains native structured `for`, `while`, `do-while`, and `switch` bodies,
the signed enum `WrapNarrow<int8>` conversion, the invalid-enum exception
edge, and VM/raw/Parms entries. It contains neither a bytecode register/goto
state machine nor `FAngelscriptJITExecutionContext`. The generated-source
build is
`Saved/Build/typed-aot-production-control-flow-generated-build/20260816_031443_149_45c88897`
and passed five actions.

That reflection change exposed a second, valid RED in the broader AOT prefix:
`Saved/Tests/typed-aot-production-control-flow-existing-regression/20260816_031500_667_effea069`
was 33/34 PASS. The only failure was
`FreshCacheV2EnginePublishesAndExecutesCommittedProviderRoute`. Once the
control-flow module materialized its statics class, current Cache V2 correctly
kept that module outside the clean module candidate and compiled its two roots
plus the three derived `StaticClass()` helpers in the fresh Engine. The old
test incorrectly equated the three modules visible in the generated Provider
with three modules that must have been frozen into Cache, so it demanded
`Modules=3` and `RestoredFunctions=55` while the authoritative publication was
`Modules=2`, `RestoredFunctions=53`.

The proof no longer substitutes another hard-coded `2/53`. It now reads the
producer Cache service's immutable `Current` publication used by the
successful flush, derives the expected module keys and validated function
keys from its `FAngelscriptCacheCleanModuleArtifacts`, requires the import and
primary fixture modules as the stable minimum, and verifies every committed
function key is present in the TestJIT Provider. The fresh consumer must then
report exactly those publication-derived module/function counts and the same
generation ID. This remains forward-compatible: when Cache later supports the
statics-class module shape, the same proof will naturally expect that third
module instead of encoding another test constant.

GREEN evidence is:

- `Saved/Build/typed-aot-cache-publication-authority-green/20260816_032243_305_a03360fb`
  — six-action Editor build PASS;
- `Saved/Tests/typed-aot-cache-publication-authority-focused-green2/20260816_032359_911_0a5298ef`
  — the exact formerly failing Cache/Provider test 1/1 PASS.

The current two-module Cache result is therefore a supported hybrid boundary,
not a loss of the production Typed Provider route. Task 6.2 continues with
executable `UASFunction` origin/classifier and Parms-entry coverage; the
reflection marker audit remains recorded above and deliberately introduces no
AssetRegistry tag or duplicate persistent origin bit.

## 2026-08-16 — UASFunction origin marker GREEN, reflected Parms layout RED

The task-6.2 publication test now resolves the two production Typed
control-flow roots through their ordinary generated `UASFunction_NotThreadSafe`
wrappers. It proves that each wrapper still owns the exact current
`asCScriptFunction`, `IsAngelscriptGenerated(const UFunction*)` remains true,
the declared argument/return `FProperty` values remain
`IsAngelscriptGenerated(...) == true`, and an ordinary native `UFunction` plus
its properties remain false. A separately retained stale `UASFunction` is also
classified by its durable UObject type after its backing isolated Engine module
is retired. This closes the origin-marker design question: `UASFunction` is the
existing authoritative marker; Literal Asset Getter/Initializer roles are a
separate generation concern, and no AssetRegistry identifier, generated
Provider bit, or Typed-specific reflection subclass is required.

The same executable test produced a genuine RED at
`Saved/Tests/typed-aot-uasfunction-origin-parms-focused/20260816_032832_151_e0a77945`.
All wrapper, Provider-entry and origin assertions passed, and
`RuntimeCallEvent` entered the Typed `ParmsEntry`, but
`SemanticStructuredControlFlow(4,2)` left the reflected return value at `0`
instead of `84`. The root cause is an ABI-layout mismatch, not a missing origin
marker. ClassGenerator appends a synthetic `_World_Context` UObject parameter
after declared parameters for a static script UFUNCTION without explicit
WorldContext metadata, then places the return property after that pointer.
TypedASTJIT's Parms adapter had reconstructed only the AS signature, so it used
the synthetic pointer's offset as `ReturnParmOffset` and wrote the scalar result
into the hidden world-context slot.

The in-progress fix makes this reflected suffix an explicit pointer-free
`EAngelscriptTypedASTJITReflectedParmsLayout` plan. Production root planning
derives `AppendGeneratedWorldContext` from the exact task-local
`FAngelscriptFunctionDesc`/statics-class authority using the same explicit-
WorldContext decision as ClassGenerator; helpers and non-reflected probes retain
`ScriptSignature`. Emission then aligns and reserves one pointer between the
declared arguments and return value. `FAngelscriptJITGeneration::SchemaRevision`
is advanced to 5 because generated C++ semantics changed. The runtime test now
sets the actual `_World_Context` property and reports declared/world/return
offsets on failure; a source-level emitter test freezes the required ordering.
Build, regeneration and executable GREEN evidence remain pending.

The first broader AOT regression after the production fix intentionally found
one stale test harness at
`Saved/Tests/typed-aot-reflected-parms-aot-regression/20260816_034149_695_5a84b2c2`.
The direct TestJIT probe helpers still allocated compact C++ structs containing
only declared AS parameters plus return storage. The generated production
Parms entries now correctly expected the reflected hidden-pointer slot, so the
capability probe missed its return and then wrote beyond the compact struct;
the following test crashed while constructing `FScriptExecution` after that
stack corruption. This was not accepted as a production rollback. Both test
probe structs now include an aligned `void* GeneratedWorldContext` between
declared parameters and return storage, matching the real ClassGenerator
layout they claim to simulate. A clean rebuild and full AOT rerun are pending.

The capability probe then passed in isolation. A second exact rerun proved the
following exported-symbol test had its own compact local Parms struct rather
than merely failing from prior corruption:
`Saved/Tests/typed-aot-reflected-parms-post-corruption-green/20260816_034446_612_e5767de9`.
The exported `FDateTime::DaysInMonth` and typed Print Parms fixtures are also
static reflected UFUNCTION roots, so their local test layouts now include the
same hidden pointer before `ReturnValue`. Instance-method and explicit
WorldContext fixture layouts are unchanged.

The second full AOT run was `34/35 PASS` at
`Saved/Tests/typed-aot-reflected-parms-aot-green/20260816_034738_805_5212342a`.
Its only failure exposed an important test distinction: the scalar Provider
probe is deliberately a test-only generated entry for non-UFUNCTION
`SemanticScalarBranch`, while the capability registration aliases a production
UFUNCTION root. The former therefore retains compact `ScriptSignature` Parms;
only the latter owns `AppendGeneratedWorldContext`. The scalar probe's temporary
hidden-pointer addition was reverted, making the test fixtures reflect the two
different entry plans instead of assuming every global function is reflected.

The complete follow-up is now GREEN. Exact evidence is:

- `Saved/Build/typed-aot-reflected-parms-build/20260816_033645_098_44558ce6`
  — initial production build PASS (22 actions);
- `Saved/Tests/typed-aot-reflected-parms-emitter-green/20260816_033726_334_fa17c12f`
  — Typed Provider emitter source contract 23/23 PASS;
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-reflected-parms-generate/20260816_033821_308_66e70a99/Commandlet.log`
  — TestJIT `Generate` PASS with schema revision 5;
- `Saved/Build/typed-aot-reflected-parms-generated-build/20260816_033856_129_df7650a1`
  — regenerated Provider C++ build PASS (10 actions);
- `Saved/Tests/typed-aot-uasfunction-origin-parms-green/20260816_033917_115_dd08fb8e`
  — exact ordinary-UASFunction identity, classifier, hidden WorldContext and
  runtime Parms-entry execution proof 1/1 PASS;
- `Saved/Tests/typed-aot-uasfunction-dispatch-regression/20260816_034030_405_753b35ed`
  — existing UASFunction dispatch prefix 4/4 PASS;
- `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-reflected-parms-verify/20260816_034117_385_204dcf69/Commandlet.log`
  — maintained TestJIT `Verify` PASS;
- `Saved/Build/typed-aot-reflected-parms-probe-split-build/20260816_034944_709_760f7684`
  and `Saved/Tests/typed-aot-reflected-parms-scalar-probe-green/20260816_034955_803_0541c647`
  — the corrected reflected/non-reflected probe split builds and the compact
  scalar probe executes 1/1 PASS;
- `Saved/Tests/typed-aot-reflected-parms-final-aot-green/20260816_035035_549_828aff85`
  — complete `Angelscript.TestModule.StaticJIT.AOT` prefix 35/35 PASS.

Task 6.2's origin/classifier and production Typed Parms-entry slice is therefore
closed, but the whole task remains unchecked until an actual optimized final
scalar UASFunction wrapper reaches the Raw entry. Current Typed eligibility is
global/static-root oriented while the existing optimized wrappers are primarily
instance-method shapes, so a test-only provider probe is not accepted as that
proof.

One adjacent hybrid boundary is now explicitly retained for task 6.3 instead
of being hidden by the Typed GREEN. The legacy BytecodeJIT Parms emitter still
reconstructs `parameters -> return` directly from `asCScriptFunction` and does
not consume ClassGenerator's synthetic `_World_Context` suffix. The current
production roots in this slice select Typed, so this is not a failure in the
35/35 result; however, a future Typed-ineligible static script UFUNCTION with no
explicit WorldContext could fall back to a Bytecode Parms entry with the same
wrong return offset. The required closure is an executable fallback case that
either teaches Bytecode planning the reflected suffix or deliberately withholds
its Parms entry and preserves the authoritative VM route. No duplicate
AssetRegistry tag, persistent origin bit, generated UObject pointer, or
Typed-specific `UASFunction` subclass is an acceptable solution.

## 2026-08-16 — task 6.2 optimized Raw-wrapper audit

The remaining task-6.2 Raw proof cannot be closed by another publication
assertion. `UASFunction::AllocateFunctionFor` selects an existing specialized
`UASFunction_*_JIT` wrapper only when the current function has a complete
VM/Raw/Parms Binding, its binding context is immutable cooked direct dispatch,
and the script method is final. Those wrappers call Raw with the maintained
instance ABI `Return(FScriptExecution&, void* Object, Args...)`.

The maintained compiler HIR already represents an ordinary instance method as
`InstanceMethod + NativeObjectThis`, with a synthetic owned receiver symbol and
declared parameter symbols following it. TypedASTJIT currently rejects this
twice: eligibility accepts only `Global + None`, and the Provider entry planner
rejects every non-null `objectType`. Consequently no real Typed-generated
function can currently cause ClassGenerator to select a final optimized
`UASFunction_*_JIT` wrapper.

The first reviewed extension will admit only final, non-virtual ordinary
instance UFUNCTION roots whose HIR does not read the native receiver. This is
not permission to guess a dynamic script-object C++ layout: any expression that
references the receiver, any member access, virtual/event/RPC route, external
implicit-this or mixin remains typed fallback. The Provider Raw entry may accept
and forward the authoritative `void* Object` ABI for wrapper/frame identity,
while the pure scalar body receives only declared parameters. Parameter-symbol
mapping must use the compiler-owned symbol IDs rather than assuming parameter
zero is symbol zero, because NativeObjectThis owns the first symbol. TDD will
freeze both the positive final-unused-receiver case and receiver-use rejection
before the production admission changes.

The authoritative contract REDs are now captured. The first exact CQTest path
was initially invoked without the CQTest class segment and matched zero tests at
`Saved/Tests/typed-aot-final-instance-raw-red/20260816_035952_661_360f2424`;
that runner mistake is diagnostic only. A first synthetic-HIR run then failed
the maintained trait-summary verifier because the fixture declared `final`
without recomputing its trait summary; that fixture defect was corrected before
accepting a product RED.

The real eligibility RED is
`Saved/Tests/typed-aot-final-instance-raw-contract-red/20260816_040146_532_8a5dec78`:
the final, non-virtual `InstanceMethod + NativeObjectThis` case is rejected by
the current production `ordinary global script functions only` gate. The
independent Provider-source RED is
`Saved/Tests/typed-aot-final-instance-provider-contract-red/20260816_040506_431_1eacae08`:
an entry plan carrying the native object slot still emits the old global Raw
signature, so its first assertion cannot find
`(FScriptExecution& Execution, void* Object, asDWORD p_0)`. These two failures
freeze the admission boundary and the maintained wrapper ABI separately before
production changes.

The production admission and Provider ABI patch now compile, and its two exact
contracts are GREEN. `Saved/Build/typed-aot-final-instance-provider-green-build/
20260816_041129_649_30638339` is a successful nine-action modular Editor build.
The first Provider GREEN attempt had already emitted the correct `Object` into
the Typed frame, but the test incorrectly expected the unrelated frame-position
capability bit to be true under a recursion-budget-only profile. Correcting that
test expectation produced
`Saved/Tests/typed-aot-final-instance-provider-green/
20260816_041217_218_088c0074`, 1/1 PASS. The eligibility contract remains 1/1
PASS at `Saved/Tests/typed-aot-final-instance-eligibility-green/
20260816_040839_370_9fb403fb`.

The wrapper audit also corrected a terminology error before adding the real
AOT fixture. In the current reloadable EditorDevelopment profile,
`UASFunction_DWordReturn` is already the existing optimized scalar wrapper: its
`RuntimeCallEvent` resolves the current function and invokes
`FAngelscriptCurrentRawJITCall`. The `_JIT` suffix identifies the narrower
immutable-cooked direct-dispatch allocation family; it is not required for a
Raw call and must not be forced into an editor test. The end-to-end fixture will
therefore require an ordinary final instance UFUNCTION to remain the existing
`UASFunction_DWordReturn`, remain `IsAngelscriptGenerated`, return through its
production Typed-generated Raw entry exactly once, and leave VM/Parms counters
unchanged. The separate immutable-artifact test continues to own the
`UASFunction_DWordReturn_JIT` allocation invariant.

The first real runtime GREEN attempt exposed a module-shape boundary rather
than an entry ABI defect. The stale-provider RED is
`Saved/Tests/typed-aot-final-instance-real-fixture-red/
20260816_041824_208_24e53d8c`: before regeneration the new method had no native
entry, exactly as expected. Official generation then succeeded at
`Saved/Commandlet/typed-aot-final-instance-real-fixture-generate/
20260816_041908_614_47116aca`, and the generated C++ visibly contained
`Raw(FScriptExecution&, void* Object)`, VM receiver forwarding from `l_fp`, and
Parms forwarding of `Object`; the generated TestJIT DLL compiled at
`Saved/Build/typed-aot-final-instance-generated-build/
20260816_041947_023_a25c07e8`.

Runtime publication still failed. The added route diagnostic at
`Saved/Tests/typed-aot-final-instance-route-diagnostic/
20260816_042225_760_e1b1693c` reported the exact method key but
`Selected=VM`, `Match=MissingProviderEntry`, `Verified=false` and a null
Binding, while the whole snapshot contained `Native=63, VM=9`. The preceding
compile log explained why: adding a reflected class to the existing
one-enum/global-function control-flow fixture created a mixed
enum+globals+class graph that `CleanCapture` intentionally does not accept, so
the entire module lost current verified route identity. The fix is fixture
composition, not weaker Cache validation: the final scalar class is moving to
its own `ASStaticJITTypedFinalScalarFixture.as` module, preserving both modules'
independently supported graph shapes and the required one-AS-module/one-jit-cpp
layout.

The split-module implementation is now fully GREEN. The authoritative fixture
is `ASStaticJITTypedFinalScalarFixture.as`, containing final non-virtual
`UTypedASTFinalScalarReceiver::TypedFinalRawValue()`. Official generation at
`Saved/Commandlet/typed-aot-final-instance-module-split-generate/
20260816_042443_218_7615022f` produced the independent
`ASStaticJITTypedFinalScalarFixture.d5fc286c.EditorDevelopment.jit.cpp`; its
Typed body returns the native scalar directly, its Raw signature retains
`void* Object`, and its VM and Parms entries forward that same object slot. The
generated TestJIT DLL compiled at
`Saved/Build/typed-aot-final-instance-module-split-generated-build/
20260816_042511_948_9103a2b0`. The executable wrapper proof at
`Saved/Tests/typed-aot-final-instance-module-split-green/
20260816_042535_295_457dc9d8` is 1/1 PASS: the production function remains the
existing `UASFunction_DWordReturn`, remains script-origin classified, returns
84, increments Raw exactly once, and does not increment VM or Parms. Official
Verify also passes with zero errors at
`Saved/Commandlet/typed-aot-final-instance-module-split-verify/
20260816_042619_338_6d313f66` (the 15 reported warnings are the existing known
fixture warnings).

The affected regression prefixes are all GREEN:

- `Angelscript.TestModule.StaticJIT.AOT.UASFunctionDispatch`: 5/5 PASS at
  `Saved/Tests/typed-aot-final-instance-uasfunction-regression/
  20260816_042832_507_ec8725b2`;
- `Angelscript.TestModule.StaticJIT.Eligibility.TypedASTJIT`: 28/28 PASS at
  `Saved/Tests/typed-aot-final-instance-eligibility-regression/
  20260816_042928_029_1906a4b7`;
- `Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT`: 24/24 PASS at
  `Saved/Tests/typed-aot-final-instance-generated-output-regression/
  20260816_043002_199_55b94f81`;
- the complete `Angelscript.TestModule.StaticJIT.AOT` prefix: 36/36 PASS at
  `Saved/Tests/typed-aot-final-instance-full-aot-regression/
  20260816_043048_035_4f279c2c`.

The full AOT run also preserves the known performance evidence rather than
hiding it: one representative clean compile reported about 906 ms in Cache V2
module-artifact capture (about 803 ms in `ASStaticJITAotFixture`) and about
729 ms in Provider reference resolution. These timings are not correctness
failures and remain part of the separate Cache/performance investigation.

The Asset-identity audit is closed without adding metadata. The authoritative
script-origin classifier is the runtime type/ownership contract (`UASFunction`
and `IsAngelscriptGenerated` for its owned function and properties); optimized
wrapper families, including the immutable `_JIT` subclasses, remain derived
from `UASFunction`. `AssetRegistrySearchable` is property metadata, while
literal-asset Getter/Initializer roles are generation descriptors, not a
per-function origin identity. Typed Provider rows therefore must not persist a
second `FAssetIdentifier`, Asset Registry tag, generated UObject pointer, or
duplicate origin bit. The 5/5 UASFunction regression freezes this existing
single-source classification across the new Raw route.

## 2026-08-16 — task 6.3 Bytecode fallback generated-WorldContext RED

The adjacent task-6.3 risk is now reproduced through a real generated Provider,
not inferred from source alone. ClassGenerator appends a reflected
`_World_Context : UObject*` property to every static script UFUNCTION whose AS
declaration does not name an explicit WorldContext argument. TypedASTJIT already
models that suffix through `AppendGeneratedWorldContext`; BytecodeJIT's Parms
emitter currently derives offsets only from `asCScriptFunction::parameterTypes`
and the return type, so it cannot see the ClassGenerator-only property.

The new fixture
`int BytecodeFallbackGeneratedWorldContext(int Value)` keeps a scalar reflected
signature but uses an `FString` local so Typed eligibility fails and the normal
Bytecode backend owns the generated entry. A stale-Provider diagnostic RED is
preserved at `Saved/Tests/typed-aot-bytecode-worldcontext-stale-provider-red/
20260816_043654_766_62dc3c42`: before regeneration the new function correctly
remained VM-only. Official old-code generation then succeeded at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-bytecode-worldcontext-old-generate/
20260816_043748_409_b4ff0909`, and its generated DLL compiled at
`Saved/Build/typed-aot-bytecode-worldcontext-old-generated-build/
20260816_043825_233_5d9366d0`.

That old generated source is the authoritative product RED: its manifest says
`vm=true, raw=true, parms=true`, while the Parms function lays out the declared
`Value` at offset 0 and the `int` return immediately after it. It contains no
slot for the reflected pointer-aligned `_World_Context` suffix. The exact
runtime test fails because this incompatible Parms entry is published at
`Saved/Tests/typed-aot-bytecode-worldcontext-parms-red/
20260816_043840_566_31a600fe` (0/1 PASS). The selected repair is fail-closed:
for a statics-class UFUNCTION descriptor that requires ClassGenerator to append
WorldContext, Bytecode generation will retain VM/Raw but emit and publish no
Parms entry. Explicit WorldContext parameters and non-reflected functions keep
their existing ABI. The generic UASFunction path must then execute VM exactly
once and preserve the reflected return value. No Asset Registry tag, generated
UObject identity, or second origin bit participates in this decision; the
synchronous authoritative function descriptor is sufficient.

The production repair is now GREEN. Bytecode generation receives an exact
per-function `bSuppressParmsEntry` decision from the synchronous resolved
module descriptors; only statics-class script UFUNCTIONs that require the
ClassGenerator-only suffix omit Parms. Generation fails closed if a requested
suppression cannot be consumed by the same module. The generated schema is now
revision 7. Official generation at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-bytecode-worldcontext-green-generate/
20260816_044311_088_c59191bb` produced VM+Raw and `parms=false` for
`BytecodeFallbackGeneratedWorldContext`; the generated DLL compiled at
`Saved/Build/typed-aot-bytecode-worldcontext-green-generated-build/
20260816_044348_933_9570e7d9`.

Provider adoption also needed an explicit optional-optimization rule. The
preferred match remains the complete VM+Raw+Parms Entry ABI. If it is not an
exact match, the router and diagnostics may accept an explicitly constructed
exact VM+Raw/no-Parms ABI; duplicate or ambiguous preferred Providers remain
fail-closed. This is not a loose signature match: both shapes retain exact
module/function/content/profile/environment/EntryAbi identity. The direct
matcher regression is 6/6 PASS at
`Saved/Tests/typed-aot-provider-fallback-green-2/
20260816_045714_790_1dd59b7b`.

The executable UASFunction proof is 6/6 PASS at
`Saved/Tests/typed-aot-bytecode-worldcontext-uasfunction-green/
20260816_045324_114_70a427c7`. The wrapper retains VM and Raw, publishes no
Parms entry, identifies `_World_Context` at the actual reflected property
offset, and returns 33 from input 31. `RuntimeCallEvent` first marshals the
reflected layout through the ordinary AS Context; maintained
`asCContext::Execute` then acquires the current Binding and calls `VMEntry`
directly. This internal Context hand-off does not pass through the public
`FAngelscriptJITExecutionContext::InvokeVM` wrapper, so the diagnostic wrapper
counter remains unchanged; it must not be interpreted as evidence of bytecode
interpretation. Raw/Parms wrapper counters also remain unchanged. Official
Verify passes at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-bytecode-worldcontext-green-verify/
20260816_045750_115_68c6fb23` with zero errors.

One test-only compile failed while moving the counter comment because the
mechanical edit changed an earlier fixture's variable names; it was repaired
without production impact. One matcher RED also correctly exposed that two
entry shapes for the same function inside one Provider are a duplicate rather
than a valid preference scenario; the final test uses separate Provider
fixtures and preserves the duplicate fail-closed contract.

## 2026-08-16 — task 6.3 real RPC/ProcessEvent route RED

Task 6.3 still lacked a real generated RPC even though synthetic eligibility
and bridge tests covered RPC flags. The AOT fixture now declares
`UFUNCTION(Client) void ClientStoreRpcValue(int Value)`. The preprocessor keeps
the public `ClientStoreRpcValue` wrapper for Unreal routing and compiles the
current script implementation as
`ClientStoreRpcValue_Implementation(const int)`.

The new executable test requires the public wrapper to remain the ordinary
generic `UASFunction_NotThreadSafe`, retain `FUNC_Net | FUNC_NetClient`, and
point at the current implementation. It calls the public wrapper through
`UObject::ProcessEvent`, verifies the receiver mutation, requires exactly one
VM entry, and forbids Raw-direct or reflected-Parms bypass. This freezes UE's
authoritative RPC/ProcessEvent boundary while still allowing the implementation
body to be AOT-generated.

The test-only build passed at
`Saved/Build/typed-aot-rpc-process-event-test-build/
20260816_050524_775_bafda26e`. Running the seven-case UASFunctionDispatch group
against the deliberately stale Provider produced the intended 5/7 RED at
`Saved/Tests/typed-aot-rpc-process-event-red/
20260816_050549_254_e24fd12f`: all five unrelated cases passed, while
`ExposesJitEntries` reported the resolved/verified RPC implementation with
`Native=false`, match code 2 and null VM/Raw/Parms binding, and the new runtime
case failed specifically because `VMEntry` was null. No crash, flag mismatch,
or ProcessEvent behavior failure was observed before the missing generated
binding stopped the test. The next step is official Generate, generated-module
build, then the exact route GREEN.

The RPC route is now GREEN without changing production dispatch. Official
Generate passed at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-rpc-process-event-generate/
20260816_050705_306_3455314e`. The one-module generated source contains both
the public wrapper's existing Bytecode entries and the exact
`ClientStoreRpcValue_Implementation(const int)` entry set with readable AS
declaration/source metadata. The generated TestJIT module compiled at
`Saved/Build/typed-aot-rpc-process-event-generated-build/
20260816_050739_942_a81f522f`.

The focused UASFunctionDispatch group is 7/7 PASS at
`Saved/Tests/typed-aot-rpc-process-event-green/
20260816_050755_609_9b91f0cf`. The public Client RPC remains
`UASFunction_NotThreadSafe`, keeps its Net/Client flags and current
implementation pointer, and `ProcessEvent` changes `StoredValue` to 91 while
the implementation binding records VM +1, Raw +0 and Parms +0. This proves the
generated body did not replace UE's public network/event route.

Official Verify passed with zero errors at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-rpc-process-event-verify/
20260816_050842_679_97c0d074`. The complete AOT prefix is 38/38 PASS at
`Saved/Tests/typed-aot-rpc-process-event-full-aot/
20260816_050909_686_8bbe0549`. That same run includes the existing generated
virtual child/BlueprintEvent override route, thread-safe and complex
reference/object/multi-argument UASFunction wrappers, explicit WorldContext,
the generated-WorldContext Bytecode fail-closed case, and the new RPC route.
Task 6.3 is therefore complete. The literal-asset role and AS-origin audit
remain unchanged: no Asset Registry identity or duplicate generated-object
marker was introduced.

## 2026-08-16 — Task 6.4 isolated-backend differential RED

- Added one final instance scalar UFUNCTION, `int DifferentialScalarValue(int A, int B) final`, to the existing final-scalar AOT fixture. Its body (`A * 3 + B - 7`) is intentionally supported by both BytecodeJIT and the first TypedASTJIT scalar slice.
- Added test-only `AngelscriptTestJITProbes` accessors for two independent VM/Raw/Parms entry sets, their readable generated symbol prefixes, raw-entry identity, and route-specific execution. These APIs do not publish a Provider or alter production routing.
- Added CQTest `Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.IsolatedBackendsUseDistinctEntriesAndOneProductionRegistration`. It requires distinct BytecodeJIT/TypedASTJIT symbol sets and entry addresses, executes all three entry shapes for both backends, and finally requires exactly one ordinary production Provider catalog row for the target FunctionKey.
- Test-only incremental build passed at `Saved/Build/typed-aot-isolated-differential-red-build/20260816_052147_218_e324bd26`.
- The first runner invocation omitted the CQTest class segment and therefore matched no tests; it is not RED evidence. The corrected exact run is `Saved/Tests/typed-aot-isolated-differential-red-real/20260816_052325_545_e186fa08`: `1` discovered, `0` passed, `1` failed, solely because the independent BytecodeJIT VM/Raw/Parms set was not registered. This is the intended pre-generator RED.

## 2026-08-16 — Task 6.4 independent Bytecode/Typed artifacts GREEN

The AOT generator now runs two additional, independent disposable generation
Engine tasks for the differential function: one selects `BytecodeJIT`, and one
selects `TypedASTJIT`. Each task builds the complete immutable generation view,
then emits only the final-scalar target module. The target is joined through
the authoritative current Engine-local function pointer in the generation
snapshot rather than through declaration-text matching. This matters because
the snapshot's canonical declaration is
`int DifferentialScalarValue(const int, const int)`, while the initial
text-based selector expected the source spelling without `const`. The intended
diagnostic failures are retained at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-isolated-differential-generate/
20260816_052902_585_b4e6260a` and
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-isolated-differential-diagnostic-generate/
20260816_053013_706_6dba54a1`; no partial output was published. The
authoritative-pointer repair compiled at
`Saved/Build/typed-aot-isolated-differential-authority-build/
20260816_053120_382_951ef188`.

Official Generate passed at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-isolated-differential-generate-green/
20260816_053140_150_9f0f9966`. It produces two owned test-only translation
units:

- `DifferentialBytecodeJIT.generated.cpp` contains the real BytecodeJIT
  opcode-lowered implementation and independent VM/Raw/Parms symbols;
- `DifferentialTypedASTJIT.generated.cpp` contains the real TypedAST scalar
  expression lowering and its own independent VM/Raw/Parms symbols.

Both files identify stable function key
`bcc16a42d6581e28f5fd897a3719e70c37469f91213349e84390b2ae478ef35b`
and execution hash
`24397a70f048c17cf8cc8051d54e6394dc379c349573bc515f4253b4d6d503ae`,
but use distinct readable symbol prefixes and compiled function addresses.
They register only test probe accessors and contain no Provider registration.
The ordinary production Typed provider contains exactly one catalog entry for
the stable function key. The generated module build passed at
`Saved/Build/typed-aot-isolated-differential-generated-build/
20260816_053411_259_4ee9685b`, and the exact six-route execution test passed
1/1 at
`Saved/Tests/typed-aot-isolated-differential-green/
20260816_053448_686_d8f3c586`. Official Verify passed at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-isolated-differential-verify/
20260816_053529_676_ccf8e9d4`, and the two-run generated-output determinism
test passed 1/1 at
`Saved/Tests/typed-aot-isolated-differential-generated-output-verify/
20260816_053606_194_345dec75`.

The first complete AOT run exposed a legitimate test-order RED rather than a
JIT failure: 38/39 passed at
`Saved/Tests/typed-aot-isolated-differential-full/
20260816_053702_091_a210978c`. `GeneratedOutputVerify` had correctly discarded
its temporary Engine before the new test ran. The retained stale `UASFunction`
wrapper remained AS-origin classified, but its backing `ScriptFunction` was
null by design, so the test could not recompute the target key through a live
Engine pointer. The repair makes each test-only generated artifact register
the already-authoritative 64-character stable function key alongside its
entry set. The test requires Bytecode and Typed artifacts to carry the same
key, then counts the production Provider row by that pointer-free key. This is
also the required Asset/origin boundary: no UObject pointer, Asset Registry
tag, or duplicate origin bit is persisted.

The ordering fix compiled at
`Saved/Build/typed-aot-isolated-key-build/
20260816_054111_938_92128a20`; official regeneration passed at
`Saved/StaticJIT/TestJIT/Commandlet/typed-aot-isolated-key-generate/
20260816_054137_815_379f06e0`. The exact class prefix, which executes
`GeneratedOutputVerify` before the differential test, is 24/24 PASS at
`Saved/Tests/typed-aot-isolated-key-order-green/
20260816_054215_693_2d4a8547`. The final complete AOT prefix is 39/39 PASS at
`Saved/Tests/typed-aot-isolated-differential-full-green/
20260816_054337_012_b21e79b9`, and final official Verify has zero errors at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-isolated-differential-final-verify/
20260816_054530_259_c4a3b97f`. Task 6.4 is complete without any production
dual-backend execution or competing registration.

## 2026-08-16 — task 6.5.1 generic isolated carrier and enum capability GREEN

Task 6.5.1 now extends the task-6.4 pair of hard-coded scalar entry sets into a
thread-safe test-only registry keyed by exact backend plus canonical
declaration. Every generated row owns copied symbol-prefix, stable-function-key
and declaration strings together with its compiled VM/Raw/optional-Parms
addresses. The old final-scalar accessors remain compatibility views populated
from the generic registration, so existing task-6.4 tests continue to execute
the same independently generated bodies rather than a second manual fixture.

The enum TDD started with an exact RED at
`Saved/Tests/typed-aot-isolated-enum-red/20260816_055135_076_84598ccd`:
the new test was discovered, and failed only because no independently generated
BytecodeJIT enum row had registered. The first generator implementation then
produced a useful design failure at
`Saved/StaticJIT/TestJIT/Commandlet/typed-aot-isolated-enum-generate/
20260816_055907_551_4869fa45`: the Bytecode artifact emitted VM+Raw but no
Parms, while the initial carrier incorrectly required all three entries.

That is not a missing Bytecode feature. `SemanticExhaustiveEnum` is a static
script UFUNCTION whose ClassGenerator reflected parameter memory appends a
pointer-aligned generated `_World_Context` slot that does not exist in the AS
signature. Task 6.3 intentionally made BytecodeJIT fail closed for this exact
layout because its legacy Parms emitter cannot represent the suffix; publishing
its old compact Parms adapter would write the return value to the wrong offset.
TypedASTJIT has an explicit `AppendGeneratedWorldContext` plan and may safely
publish the reflected Parms adapter. The generic carrier therefore requires VM
and Raw but treats Parms as an exact generated capability. Generation now also
accepts an expected-Parms bit per isolated target and reports actual VM/Raw/
Parms values on any plan mismatch. This preserves, rather than weakens, the
existing fallback contract.

Two more disposable generation Engines now emit the same authoritative enum
FunctionKey into separate test-only files:

- `DifferentialControlFlowBytecodeJIT.generated.cpp` contains a readable
  Bytecode symbol set, VM+Raw bodies and a null Parms registration;
- `DifferentialControlFlowTypedASTJIT.generated.cpp` contains a distinct Typed
  symbol set and a Parms body that reserves the hidden WorldContext pointer
  before the return slot.

Both carry FunctionKey
`0145fa4429b9ae62be79d15799167aacc5b06d72777cceecf717a910ebec9dd4`,
register only with the test carrier, and are included in the generated owned-
file inventory. No second production Provider row or shadow runtime backend is
introduced. The focused enum test compares key/address identity, executes
values `0/1/2 -> 10/20/30` through Bytecode Raw+VM and Typed Raw+VM+reflected
Parms, requires the Bytecode Parms pointer to remain null, and freezes reflected
offsets `RawMode=0`, generated WorldContext `=8`, return `=16`.

Final evidence for this slice is:

- `Saved/Build/typed-aot-isolated-enum-capability-build/
  20260816_060302_022_e3a2ca47` — generator/carrier/test build PASS;
- `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-isolated-enum-capability-generate/
  20260816_060330_190_b06d9979` — official Generate PASS;
- `Saved/Build/typed-aot-isolated-enum-generated-build/
  20260816_060422_652_85a89f96` — both new translation units build PASS;
- `Saved/Tests/typed-aot-isolated-enum-green/
  20260816_060450_222_225a3b1e` — exact enum differential test 1/1 PASS;
- `Saved/Tests/typed-aot-isolated-scalar-regression/
  20260816_060534_668_ac14ce3f` — task-6.4 scalar compatibility 1/1 PASS;
- `Saved/Tests/typed-aot-isolated-enum-generated-output-verify/
  20260816_060620_831_98f3f215` — repeated output and three-Typed-task
  lifecycle verification 1/1 PASS;
- `Saved/Tests/typed-aot-isolated-enum-full-green/
  20260816_060728_074_e30def2c` — complete AOT prefix 40/40 PASS;
- `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-isolated-enum-final-verify/
  20260816_060943_461_71b9eb5d` — official Verify PASS with zero errors.

Task 6.5.1 is complete. Parent task 6.5 remains open for typed failure payloads,
cleanup traces, eager-order/mutation/control-flow state, numeric/global
boundaries, imported/direct/bridge calls, and non-cloneable-effect rejection.

## 2026-08-16 — task 6.5.2 isolated failure payload and cleanup contract GREEN

The independent differential carrier now records route status/value, the exact
first script failure (message, function, section, row and column), runtime
route/backend origin, test-selected backend/entry route, compile-time cleanup
plan state/action count, and the runtime cleanup trace. It covers exhaustive
enum invalid value `99` and checked integer division `12 / 0` through a fresh
interpreter execution plus independently generated BytecodeJIT and TypedASTJIT
VM/Raw/available Parms entries. The generated artifacts preserve the same
stable key per AS target without publishing a second production Provider row.

TypedASTJIT generation refuses the supported scalar fixture unless its verified
HIR cleanup plan is universal, covers every transfer, has zero reverse live
slots and therefore records `VerifiedEmpty` with zero actions. BytecodeJIT
records `NotCaptured`, and every executed route produces an empty cleanup trace.
The test carrier does not forge production origin metadata: direct generated
entries legitimately report `generated-native-call/static-jit`, while the
interpreter reports `vm/vm`.

The first runtime execution was RED at
`Saved/Tests/typed-aot-isolated-exception-first-runtime/
20260816_064348_209_f79dd197`. Its `103:2` interpreter, `104:4` Bytecode and
`104:2` Typed positions identified two root causes rather than an oracle issue.
The interpreter's `asBC_ThrowException` path had not synchronized local VM
registers into `m_regs` before `SetInternalException`; BytecodeJIT had treated
`GetLineNumber`'s section-index output as a column instead of decoding the
packed return value. Together with the compiler-owned `LineInstr` immediately
before the synthesized exhaustive-switch throw and the opcode position hook,
the final generated enum positions are `104:2` for both backends and the
checked-division positions are `118:2`.

The Runtime build passed at
`Saved/Build/typed-aot-isolated-exception-position-fix-build/
20260816_064746_989_debe595f`; official Generate passed at
`Saved/Commandlet/typed-aot-isolated-exception-position-fix-generate/
20260816_064820_869_7bed84a3`; regenerated sources built at
`Saved/Build/typed-aot-isolated-exception-position-fix-generated-build/
20260816_064913_612_ed898ba8`. The exact differential test is 1/1 PASS at
`Saved/Tests/typed-aot-isolated-exception-position-fix-exact/
20260816_064927_250_efbad254`; exact Typed and Bytecode position-hook tests are
each 1/1 PASS at `Saved/Tests/typed-aot-position-hooks-typed-exact/
20260816_065024_309_f4ecf303` and
`Saved/Tests/typed-aot-position-hooks-bytecode-exact/
20260816_065057_722_f4c2d731`.

Official Verify passed at
`Saved/Commandlet/typed-aot-isolated-exception-position-fix-verify/
20260816_065142_181_f5aae906`; exact generated-output verification is 1/1 PASS
at `Saved/Tests/typed-aot-isolated-exception-generated-output-verify-exact/
20260816_065229_799_1af7a029`; and the final AOT prefix is 41/41 PASS with zero
failed/skipped/not-run tests at
`Saved/Tests/typed-aot-isolated-exception-position-fix-aot/
20260816_065345_508_6c7901af`. Task 6.5.2 is complete; 6.5.3 remains next.

## 2026-08-16 — task 6.5.3 cloneable state and evaluation order GREEN

Added `SemanticCloneableState` plus a test-only value-semantic state carrier.
Every interpreter, Bytecode Raw/VM, and Typed Raw/VM/Parms execution receives a
fresh copy. The cases cover nested eager prefix increments, `&&` short-circuit
side effects, compound/prefix/postfix exactly-once mutation, and nested
`while`/`for`/`switch` transfer targets. The original state retains its sentinel
after every route, proving the oracle does not share mutable fixture state.

The initial no-artifact RED was
`Saved/Tests/typed-aot-cloneable-state-red/
20260816_070258_035_cdb80cfa`. Official generation then produced independent
Bytecode and Typed artifacts with the same stable key; Bytecode has Raw+VM and
Typed has Raw+VM+Parms with the frozen reflected layout. Their first execution
found a real lowering bug at
`Saved/Tests/typed-aot-cloneable-state-green/
20260816_070821_253_40006d0b`: interpreter and Bytecode returned `3123`, but
Typed Raw returned `3321` because mutation lambdas were emitted directly as
C++ helper-call arguments and host argument order was not the AngelScript HIR
order.

Typed ordinary binary emission now evaluates a typed left temporary followed
by a typed right temporary before the native operation. Short-circuit nodes
remain lazy. The change preserves direct native scalar computation and adds no
`FAngelscriptJITExecutionContext`. Fresh evidence is:

- Runtime emitter build PASS:
  `Saved/Build/typed-aot-binary-evaluation-order-fix-build/
  20260816_071133_203_51539dcc`;
- Generate PASS:
  `Saved/Commandlet/typed-aot-cloneable-state-order-fix-generate/
  20260816_071148_194_b9722662`;
- generated artifacts build PASS:
  `Saved/Build/typed-aot-cloneable-state-order-fix-generated-build/
  20260816_071243_604_57415abb`;
- exact cloned-state differential 1/1 PASS:
  `Saved/Tests/typed-aot-cloneable-state-order-fix-green/
  20260816_071257_135_df430e47`;
- official Verify PASS:
  `Saved/Commandlet/typed-aot-cloneable-state-order-fix-verify/
  20260816_071408_806_9b2ed881`;
- exact generated-output verification 1/1 PASS:
  `Saved/Tests/typed-aot-cloneable-state-generated-output-verify-exact/
  20260816_071457_191_ce036af7`;
- complete AOT prefix 42/42 PASS with zero failed/skipped/not-run:
  `Saved/Tests/typed-aot-cloneable-state-order-fix-aot/
  20260816_071623_636_dc262f63`.

Task 6.5.3 is complete. Task 6.5 remains open for 6.5.4 and 6.5.5.

## 2026-08-16 — task 2.15 global origin and folded HardValue authority GREEN

The maintained compiler now distinguishes three global-related HIR facts. A
compiler-folded pure constant is `FoldedGlobalConstant` with its exact
engine-local global-property coordinate and canonical value bits; a live read
or write remains `GlobalStorage`; and the anonymous body produced by
`CompileGlobalVariable()` is explicitly `GlobalInitializer`. The verifier
checks the new node shapes, and normalized dumps retain the global coordinate
and bit payload. The compiler oracle proves a folded `42` is not degraded to an
origin-free literal, a mutable storage read remains distinct, and the
initializer has the dedicated invocation kind.

The Cache-to-StaticJIT handoff now preserves semantic reasons rather than only
flattening them into stable references. `FAngelscriptFunctionArtifactReferenceSet`
owns a storage-neutral, pointer-free semantic dependency array; clean capture,
exact startup and graph promotion copy it from the persisted Cache vocabulary
through an explicit enum mapping. Generation snapshots then reconcile a
`ScriptGlobal` stable key with the same Engine's exact global-property id and
freeze `Kind`, stable reference, expected ABI and optional content/value
fingerprint into the compiled backend graph. The reconciliation deliberately
leaves missing or ambiguous coordinates invalid so the per-function backend
can fail closed.

TypedASTJIT initially accepts only folded pure constants. Eligibility and the
emitter independently require exactly one valid `HardValue` plan for the HIR
global coordinate, with `ScriptGlobal` identity, nonzero expected ABI and a
nonzero expected value fingerprint. Missing, wrong-kind, mismatched or
duplicate authority reports `SemanticDependencyMismatch`; live storage and
initializer bodies report `UnsupportedGlobalStorage` and
`UnsupportedGlobalInitializer`. Eligible constants are reconstructed through
`FromCanonicalBits<T>(UINT64_C(...))`, preserving integer, bool, float and
double bit patterns without using `FAngelscriptJITExecutionContext`. The bits
are formatted as a decimal `UINT64_C` payload because the generated-output
safety scan intentionally rejects long `0x...` tokens as possible baked
addresses. The authoritative ScriptGlobal reference is also retained in the
Provider reference slots, so current-Engine matching and later hard-value
invalidation have a stable dependency to resolve.

The real Engine test uses the exact Cache-supported shape: one reflected script
class, one pure primitive global and a final scalar UFUNCTION reader. It proves
the compiler HIR property id equals the generation global coordinate; the
snapshot HardValue stable key equals the global key; expected ABI and value
fingerprint are present; Typed C++ contains
`FromCanonicalBits<int32>(UINT64_C(7))`; and the emitted Provider function owns
the ScriptGlobal reference. Earlier attempts with the existing mixed
reflection/delegate module, a global-only module containing a user global, and
an enum-plus-class module correctly had no validated Cache reference set and
therefore remained ineligible. A non-UFUNCTION reader and a non-final method
likewise reached `NotUFunctionRoot` and `UnsupportedFunctionTrait`. Those REDs
were retained as evidence of the existing fail-closed boundaries rather than
bypassing Cache or weakening root eligibility.

Implementation/debug evidence:

- `Saved/Build/typed-aot-global-dependency-red/20260816_075316_471_58f9bbbf`
  — initial test-first compile RED before the semantic dependency handoff
  types existed;
- `Saved/Build/typed-aot-global-dependency-compile-1/20260816_080011_205_71070b80`
  — first production compile found that UE 5.8 has no
  `Templates/IsSame.h`; the helper now uses standard `<type_traits>`;
- `Saved/Tests/typed-aot-global-dependency-emitter-green-exact/
  20260816_080431_616_60d68292` — the first emitter run found the intended
  generated-output pointer-like-hex guard, leading to decimal canonical-bit
  formatting;
- `Saved/Tests/typed-aot-folded-global-snapshot-exact-fixture/
  20260816_081840_875_82363957` — the first exact Cache-supported snapshot
  fixture reached `NotUFunctionRoot`, proving all dependency assertions had
  passed before formal root eligibility;
- `Saved/Tests/typed-aot-folded-global-snapshot-method/
  20260816_082109_139_cb46c1c7` — the UFUNCTION method then reached the
  existing virtual/non-final trait gate before being made final;
- `Saved/Build/typed-aot-global-origin-final-build/
  20260816_082340_418_792b0642` — final Editor build PASS, 34/34 actions;
- `Saved/Tests/typed-aot-global-origin-compiler-final/
  20260816_082459_545_6d397a38` — compiler origin/initializer oracle 1/1 PASS;
- `Saved/Tests/typed-aot-global-origin-eligibility-final/
  20260816_082535_308_59247392` — constant-only eligibility and typed fallback
  matrix 1/1 PASS;
- `Saved/Tests/typed-aot-global-origin-emitter-final/
  20260816_082609_875_a2020b70` — dependency-required exact-bits emission 1/1
  PASS;
- `Saved/Tests/typed-aot-global-origin-snapshot-final/
  20260816_082645_389_db949a20` — complete Engine snapshot/backend/Provider
  reference chain 1/1 PASS.

One test invocation initially omitted the CQTest class segment and matched no
tests, and one short-timeout build wrapper left its child UBT briefly
overlapping the next link. Neither was a product failure; the final commands
use the exact discovered test paths and one serialized build invocation. Task
2.15 is complete. Task 6.5.4 is next for executable numeric boundaries and
folded-global invalidation across independently generated VM, BytecodeJIT and
TypedASTJIT routes.
## 2026-08-16 — task 6.5.4 numeric-boundary generation REDs

Task 6.5.4 extends the isolated differential carrier with one integer boundary
function and one double-power function per backend. The integer fixture covers
wrapping add/subtract/multiply, checked division and remainder, masked logical
and arithmetic shifts, integer widening, boolean normalization and a folded
pure global. The power fixture will cover signed zero, subnormal, NaN, infinity
and overflow/exception parity.

The initial exact automation RED compiled successfully but could not find the
new independent Bytecode artifact:
`Saved/Tests/typed-aot-numeric-boundary-red-exact/
20260816_083652_925_855e9d86`. The first maintained generation attempt at
`Saved/Commandlet/typed-aot-numeric-boundary-first-generate/
20260816_083911_476_0ff44063` exposed a real fixture/capture boundary: placing
the folded constant in `ASStaticJITTypedControlFlowFixture` changed that module
from the admitted enum-plus-functions clean-capture shape to a module with a
global, so Cache V2 skipped the complete module and the isolated Bytecode target
had no entry. The test source was not weakened; the constant and boundary
function were moved together into the already-proven final-scalar class module,
where task 2.15's class-plus-hard-value dependency path is authoritative.

The corrected fixture/generator build passed 4/4 actions at
`Saved/Build/typed-aot-numeric-boundary-final-scalar_01_baseline_build/
20260816_084407_694_400d0f1a`. Maintained Generate then captured all seven
requested function-fact candidates and froze seven modules, 79 functions, five
types and five globals, but intentionally stopped before publication at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-numeric-boundary-final-scalar_02_generate/
20260816_084420_906_c6a67e46`: the new power artifact specification incorrectly
expected no Parms entry while the authoritative Bytecode plan reported
`vm=true raw=true parms=true`. Existing generated output confirms the pure
scalar global power function has all three entries. Both independent power
specifications now require Parms; this was a test-oracle correction, not a
production behavior change.

The next maintained attempt compiled its generator at
`Saved/Build/typed-aot-numeric-boundary-final-scalar-green_01_baseline_build/
20260816_084613_901_3066a544` and again captured all requested facts, but the
Typed-only artifact correctly selected `actual='bytecode'` at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-numeric-boundary-final-scalar-green_02_generate/
20260816_084627_651_9af46009`. This was the intended production-root guard:
the pre-existing `SemanticPowerDouble` is an ordinary global AS helper, so the
old expression probe can demonstrate Typed emission but it is not a publishable
Typed UFUNCTION root. The differential target now uses a final, receiver-free
`UTypedASTFinalScalarReceiver::SemanticPowerBoundary` UFUNCTION in the same
class fixture as the numeric boundary. Both independent backends therefore
exercise the real Provider eligibility/publication path rather than treating a
manual probe as production AOT.
## 2026-08-16 — task 6.5.4 numeric/power execution differential RED

The isolated numeric/power artifacts now compile through the official Generate
workflow and the generated translation units build successfully. The final
numeric differential is 1/1 PASS at
`Saved/Tests/typed-aot-numeric-boundary-execution-green-final/20260816_090339_747_f9afa9ec`.
It compares the interpreter with independent BytecodeJIT and TypedASTJIT
Raw/VM/Parms entries for signed wrapping add/subtract/multiply, truncating
divide/remainder, `MIN_int32 / -1` and `% -1`, masked negative/32/large shifts,
logical and arithmetic right shift, integer widening, boolean normalization,
and the folded immutable global value `7001`.

The power differential is intentionally RED at
`Saved/Tests/typed-aot-power-boundary-execution-red/20260816_090427_422_dd9bbf9c`.
Interpreter and both generated artifacts already agree for negative zero,
subnormal, NaN, positive-infinity reciprocal, negative-base fractional power,
and negative infinity. The interpreter reports `asEXECUTION_EXCEPTION` with
`Overflow in exponent operation` for `2.0 ** 1024.0`, while the first generated
route reports normal completion. Inspection of the generated sources confirms
that both BytecodeJIT and TypedASTJIT currently emit a bare `FMath::Pow` without
the maintained interpreter's positive-infinity overflow check. Production
changes must preserve NaN and negative infinity as values and raise only for
the VM-equivalent positive overflow case.
## 2026-08-16 — task 6.5.4 power-overflow compatibility GREEN

The numeric/power execution differential RED identified one maintained-fork
semantic mismatch: the interpreter treats an exact positive `HUGE_VAL` power
result as the script exception `Overflow in exponent operation`, while the
generated BytecodeJIT and TypedASTJIT bodies previously returned positive
infinity normally. Production generation now preserves that behavior through
the existing `FScriptExecution` first-failure channel:

- `POWf`, `POWd`, and `POWdi` BytecodeJIT lowering checks the computed result
  against the maintained VM boundary, records the power-overflow exception at
  the current source position, and uses the ordinary exception return path;
- TypedASTJIT emits `AngelscriptTypedASTJIT::CheckedPower<T>(Execution, ...)`
  for the three admitted floating power shapes, so Raw, VM, Parms, direct
  helper, and public-entry routes share one exception state;
- NaN, negative zero, denormal, negative infinity, and non-overflow positive
  infinity-input rows remain values exactly when the interpreter does; the
  check deliberately rejects only an exact positive overflow result;
- the legacy direct TypedAST power probe typedefs now carry
  `FScriptExecution&`; the first regenerated build provided the expected RED
  by rejecting the old two-argument function-pointer ABI rather than hiding
  the drift with a cast.

Evidence:

- production build before regeneration:
  `Saved/Build/typed-aot-power-overflow-production-build/20260816_091011_212_92777bab`
  — 51/51 UBT actions PASS;
- official Generate:
  `Saved/StaticJIT/TestJIT/Commandlet/typed-aot-power-overflow-generate/20260816_091109_999_995ae21d`
  — commandlet PASS;
- intentional regenerated-probe ABI compile RED:
  `Saved/Build/typed-aot-power-overflow-generated-build/20260816_091417_644_fd33d93d`
  — `FTypedASTPower*Probe` rejected the new `FScriptExecution&` signatures;
- generated-output build after aligning the test carrier:
  `Saved/Build/typed-aot-power-overflow-generated-build-green/20260816_091506_258_b78415d3`
  — 23/23 UBT actions PASS;
- exact power differential:
  `Saved/Tests/typed-aot-power-boundary-execution-green/20260816_091530_409_076c4da3`
  — 1/1 PASS;
- exact numeric boundary regression:
  `Saved/Tests/typed-aot-numeric-boundary-after-power-green/20260816_091613_713_2e3e2d7b`
  — 1/1 PASS;
- direct TypedAST mutation/power probe ABI regression:
  `Saved/Tests/typed-aot-power-probe-abi-green/20260816_091725_409_28e32dd3`
  — 1/1 PASS.

Task 6.5.4 remains open until the folded pure-global content-invalidation row
is GREEN; the arithmetic, division/remainder, shift, reviewed conversion, and
power execution rows are now complete.

## 2026-08-16 — task 6.5.4 folded-global invalidation GREEN

The final task-6.5.4 row now compiles the same final scalar UFUNCTION against a
test-only current source in which only the pure immutable global changes from
`7001` to `9001`. The stable FunctionKey remains equal to the checked-in
Provider entry, while the current function execution hash changes. The old
Provider VM/Raw/Parms entries are not attached, the final Engine route remains
VM, and executing mode 10 with input 41 observes the current source result
`9042` rather than the stale generated literal `7042`.

The first exact test was a useful RED at
`Saved/Tests/typed-aot-folded-global-invalidation-red/
20260816_092446_384_3255a2e1`: all publication and execution assertions passed,
but the test incorrectly expected `FAngelscriptFunctionRoute::MatchResult` to
carry the candidate Provider rejection. That stable route snapshot describes
the final execution route and therefore reports VM/no selected Provider. The
authoritative per-candidate rejection is
`FAngelscriptJITProviderRouteRefreshResult::Routes`, whose existing summary
already reported exactly one `ContentMismatch`. The test now performs an
idempotent diagnostic refresh, resolves its exact FunctionKey record, and
asserts `ContentMismatch` plus `bBindingPublished == false`; no production
route semantics or persistent diagnostic state was duplicated.

Verification evidence:

- `Saved/Build/typed-aot-folded-global-invalidation-test-build-2/
  20260816_092428_107_6de38b81` — source-override fixture build PASS, 4/4;
- `Saved/Build/typed-aot-folded-global-invalidation-green-build/
  20260816_092921_535_67afeac2` — authoritative diagnostic-observation test
  build PASS, 4/4;
- `Saved/Tests/typed-aot-folded-global-invalidation-green-2/
  20260816_093024_763_d1ac256e` — exact folded-global invalidation test 1/1
  PASS;
- the attempted shorter CQTest name at
  `Saved/Tests/typed-aot-folded-global-invalidation-green/
  20260816_092940_431_bfce41c9` discovered zero tests because it omitted the
  CQTest class segment; it is runner-name evidence, not a product failure.

Together with the previously recorded exact numeric, power, and direct-probe
GREEN runs, this closes task 6.5.4. Task 6.5.5 is the next isolated differential
slice: imported bind/rebind/unbind, exported/inline/thunk direct calls,
provider-private bridges, and explicit rejection of non-cloneable effects.

## 2026-08-16 — task 6.5.5 imported-slot HIR RED

The first 6.5.5 slice added
`ImportedCallCapturesMutableSlotWithoutFreezingBinding` to the maintained-fork
compiler HIR tests. One Engine compiles two compatible provider modules and an
unbound consumer import before selecting either provider. The desired contract
requires one `ResolvedCall` that owns the import signature's `FUNC_IMPORTED`
slot coordinate, never either mutable provider FunctionId; binding provider A,
rebinding provider B and unbinding must change VM behavior without mutating the
compiler-owned HIR coordinate.

The test-only change built successfully at
`Saved/Build/typed-aot-imported-hir-red-build/20260816_094046_432_a3f20a4f`.
The first short filter omitted the CQTest class segment and matched no tests;
it is discovery evidence only. The corrected exact run is the authoritative
RED at
`Saved/Tests/typed-aot-imported-hir-red-2/20260816_094149_272_0b064586`:
1 test ran and failed only because the consumer function published no HIR,
with diagnostic `semantic capture encountered an unrepresentable compiler
state`. Source inspection confirms `AddResolvedGlobalCall` currently accepts
only `asFUNC_SCRIPT` and `asFUNC_SYSTEM`, so `asFUNC_IMPORTED` discards the
whole sidecar before TypedASTJIT can produce the required typed
`UnsupportedImportedRoute` fallback. The fix must add an explicit imported
call-target kind whose engine-local coordinate is the immutable slot ID; it
must not read or persist `boundFunctionId`.

## 2026-08-16 — task 6.5.5 imported-slot HIR GREEN and executable differential RED

The maintained fork now publishes `ImportedFunction` as a distinct resolved
call-target kind. Its `resolvedFunctionId` retains the `FUNC_IMPORTED` slot
coordinate before binding and remains unchanged across provider A bind,
provider B rebind and unbind. The Typed call-closure planner records that same
slot and fails closed with `UnsupportedImportedRoute` plus
`ImportedBindingRouteUnavailable`; it never resolves or persists the current
`boundFunctionId` as a concrete callee.

Focused evidence:

- `Saved/Build/typed-aot-imported-route-focused-verify/
  20260816_094908_953_2da6e28e` — focused build PASS (the immediately preceding
  orphaned wrapper invocation also completed UBT successfully, but this run is
  the authoritative runner result);
- `Saved/Tests/typed-aot-imported-hir-kind-green/
  20260816_094940_508_f05b6257` — real compiler/import lifecycle 1/1 PASS;
- `Saved/Tests/typed-aot-imported-closure-green/
  20260816_094940_508_d8cd7086` — exact Typed closure fallback 1/1 PASS.

The next RED extends the committed final-scalar fixture with one reflected
`SemanticImportedBinding(int)` root. It requires an independently generated
Bytecode VM/raw/Parms entry, asserts that no Typed entry is published, and is
prepared to execute bind A -> rebind B -> unbind -> rebind A against separate
interpreter and generated routes. The test source builds at
`Saved/Build/typed-aot-imported-differential-red-build/
20260816_095506_003_70f69087`; its authoritative RED is
`Saved/Tests/typed-aot-imported-differential-red/
20260816_095526_518_8202d477`, 1 test run / 1 failure, solely because the new
Bytecode artifact is not generated yet. This is the intended artifact-level
RED, not a fixture compile or import-binding failure.

## 2026-08-16 — task 6.5.5 target-profile import-mode diagnosis

The first generated-artifact attempt exposed an important fixture/profile
distinction rather than a compiler regression. The commandlet log at
`Saved/StaticJIT/TestJIT/Commandlet/
typed-aot-imported-differential-generate/20260816_095848_769_63dd9e3c`
reported that the supposed imported-slot root was emitted successfully by
TypedASTJIT as a two-function direct script closure instead of rejecting with
`UnsupportedImportedRoute`.

Source tracing established the exact reason:

- `UAngelscriptSettings::bAutomaticImports` defaults to `true`;
- `FAngelscriptEngine` applies that target setting as
  `asEP_AUTOMATIC_IMPORTS` before source compilation;
- in that mode `asCBuilder::RegisterImportedFunction` intentionally ignores
  explicit `import ... from ...` declarations and global lookup resolves the
  current provider function directly. There is therefore no mutable
  `FUNC_IMPORTED` slot in this profile, and a direct script closure is the
  correct captured semantic shape;
- mutable `BindImportedFunction` / `UnbindImportedFunction` behavior exists
  only when automatic imports are disabled. The earlier maintained-fork HIR
  test was already running that manual-import contract and remains valid.

The correction is test-scoped and profile-honest: ordinary isolated
EditorDevelopment generation continues to inherit the real project/target
automatic-import setting. Only the 6.5.5 imported-slot Bytecode/Typed
differential tasks and their matching interpreter Engine now opt into a fresh
manual-import fixture before `InitialCompile`, setting both the owning
`FAngelscriptEngine` policy and `asEP_AUTOMATIC_IMPORTS=0`. This produces real
`CALLBND`/slot semantics without changing normal project generation or
pretending an automatic-import direct edge is dynamically rebound.

The next verification gate is a focused build followed by the same generation
commandlet. It must generate the Bytecode artifact, record a deterministic
Typed `UnsupportedImportedRoute` attempt followed by Bytecode fallback, and
then pass the bind A -> rebind B -> unbind -> rebind A execution differential.

## 2026-08-16 — task 6.5.5 mutable import-slot lowering GREEN

An audit prompted by the existing Asset/function classifier confirmed that no
new Asset marker is needed for this slice. `IsAngelscriptGenerated(UFunction*)`
already classifies script-generated reflection through `UASFunction`, and
Literal Asset getter/initializer ordering is carried separately by the
pointer-free `EAngelscriptStaticJITLiteralAssetFunctionRole`. Neither concept
identifies a mutable AngelScript import slot. Reusing either one for `CALLBND`
would conflate reflection ownership or asset initialization role with dynamic
module binding, so the implementation leaves both classifiers unchanged.

The new Provider-only import descriptor has two deliberately different
identities:

- `StableKey` is built from the consumer `ModuleKey`, canonical namespace,
  canonical import declaration and declared source module. It names one slot
  owned by the consumer and contains no Engine-local ID, pointer,
  `boundFunctionId` or selected provider identity;
- `ExpectedAbi` is built only from the canonical namespace and callable
  declaration. Compatible rebinds therefore retain the slot ABI even when the
  provider lives in a different module.

`CaptureAngelscriptCurrentModuleFunctionFacts` now admits and resolves imports
only under `bFunctionFactsOnly`. The ordinary reusable Cache V2 capture and
pre-compile authority paths still reject modules containing import declarations;
their persistence contract was not broadened. The function-fact resolver maps
the compiler's imported signature pointer to the stable `ScriptImport`
descriptor and accepts signature dependencies only. The maintained-fork
characterization test also confirms the imported signature contributes one
signature dependency and zero function-content dependencies; its exact 1/1
PASS is
`Saved/Tests/typed-aot-import-dependency-red-2/
20260816_101619_958_10dfeb26` (the preceding shorter name discovered zero CQ
tests and is not a product failure).

BytecodeJIT now recognizes `asFUNC_IMPORTED` before ordinary script-function
reference lookup. Generated `CALLBND` code obtains the consumer-owned signature
from its resolved reference slot, then reads the current Engine's
`importedFunctions[slot]->boundFunctionId` for every call. Missing reference
tables and unbound slots fail through the ordinary observable unbound-function
exception instead of dereferencing null. The current-Engine resolver indexes
`ScriptImport` against each active module's current `sBindInfo` table and
retains the imported signature for the immutable reference-table lifetime.
StaticJIT-generation Engines may use their complete, verified same-compilation
generation snapshot as transient reference authority; ordinary Engines still
require a current Cache publication or validated route snapshot.

The independently generated differential probe now carries the exact
`FAngelscriptJITReferenceSlot` array alongside VM/raw/Parms function pointers.
This is test-module plumbing, not a product Provider ABI change. It found and
closed two useful REDs:

- `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-imported-differential-generate-manual/
  20260816_100627_347_bae7eb3a` rejected the complete root/class graph solely
  because the old Cache-shaped function-facts path rejected imports;
- `Saved/Tests/typed-aot-import-slot-differential-green/
  20260816_102935_190_b5630864` reached the generated `CALLBND` entry but
  crashed because the isolated probe had exported entry pointers without its
  reference slots. After the null guard and slot export, the next run at
  `Saved/Tests/typed-aot-import-slot-differential-green-2/
  20260816_103655_154_f6b95bd8` failed normally and diagnostically because the
  generation-purpose interpreter Engine had no reusable Cache publication;
  this led to the narrowly scoped generation-snapshot authority above.

Focused GREEN evidence:

- descriptor TDD RED:
  `Saved/Build/typed-aot-import-slot-descriptor-red/
  20260816_102023_396_6042e8c3` (missing `ForImportSlot` only);
- descriptor build and exact test:
  `Saved/Build/typed-aot-import-slot-descriptor-green-build/
  20260816_102103_358_4d49e921` and
  `Saved/Tests/typed-aot-import-slot-descriptor-green-2/
  20260816_102223_949_7e67a7e7` — 1/1 PASS;
- production import-slot build:
  `Saved/Build/typed-aot-import-slot-runtime-build-2/
  20260816_102652_815_e457ae66` — PASS. The immediately preceding compile
  exposed only that `FAngelscriptHash256` is not a `TSet` hash key; the bounded
  uniqueness check now uses an array;
- generation commandlets:
  `Saved/Commandlet/typed-aot-import-slot-generate-green/
  20260816_102727_863_110c648b` and
  `Saved/Commandlet/typed-aot-import-slot-probe-regenerate/
  20260816_103513_555_358fb603` — exit 0, zero errors;
- generated `.jit.cpp` builds:
  `Saved/Build/typed-aot-import-slot-generated-build/
  20260816_102903_931_608f4f94` and
  `Saved/Build/typed-aot-import-slot-probe-generated-build/
  20260816_103634_186_755e3e13` — PASS;
- generation reference-authority build:
  `Saved/Build/typed-aot-generation-reference-authority-build/
  20260816_103900_341_57b227a4` — PASS;
- final executable differential:
  `Saved/Tests/typed-aot-import-slot-differential-green-3/
  20260816_103916_992_68ecca6e` — exact test 1/1 PASS.

The final differential binds the primary provider (`Value + 77`), rebinds the
same consumer slot to a compatible function in a different module
(`Value + 177`), unbinds it, and binds the primary provider again. Interpreter,
Bytecode VM, raw and Parms routes agree at every step; the unbound state reports
the same `Unbound function called` failure. TypedASTJIT publishes no competing
entry for the manual-import target and retains its typed
`UnsupportedImportedRoute` / Bytecode-fallback diagnostic. This closes the
manual import bind/rebind/unbind sub-row of task 6.5.5; exported/inline/thunk,
private bridge and non-cloneable rejection rows remain separate work.

## 2026-08-16 — task 6.5.5 native/private differential RED

The asset-origin audit remains a no-code-change conclusion: `UASFunction`
classification and the existing Literal Asset Getter/Initializer role are
already the authoritative markers. Native, import and bridge routing must stay
on stable function/reference identities and must not add an AssetRegistry tag
or a second persistent script-origin bit.

The next 6.5.5 slice now has an executable RED fixture. The fixture adds one
real `ExportedRuntimeThunk` target whose interpreter/Bytecode registration is
the current Engine's ordinary function while TypedASTJIT will call a fixed
Runtime DLL wrapper. The test matrix names four independent artifact rows:

- `TypedASTCapabilityShowcase` for `DirectInline`;
- `TypedASTPrintShowcase` for `DirectExported`;
- `TypedASTRuntimeThunkShowcase` for `RuntimeThunk`;
- `TypedASTPrivateBridgeShowcase` for the current-Engine private route;
- `ObjectLifetimeEntryForAOT` remains an explicit pre-execution rejection.

Evidence:

- `Saved/Build/typed-aot-6-5-5-native-fixture-red-build/
  20260816_104858_232_cef0bb3a` — fixture/test build PASS;
- `Saved/Tests/typed-aot-6-5-5-native-rows-red/
  20260816_104921_395_133e8c4b` — exact test 0/1 as intended. Its sole failure
  is the missing BytecodeJIT differential entry for
  `int TypedASTCapabilityShowcase(const int, const int, const bool, const bool)`.

The RED excludes Engine startup, compilation and UASFunction classification as
causes. GREEN must extend the independently generated artifact inventory and
then compare real execution/counters; it must not satisfy the test by sharing
the production Provider entry.

## 2026-08-16 — task 6.5.5 native/private execution and deterministic rejection GREEN

The remaining 6.5.5 routes now execute through independently generated
BytecodeJIT and TypedASTJIT artifacts. The fixture covers four current native
linkage forms:

- `TypedASTCapabilityShowcase` lowers the reviewed capability call as
  `DirectInline`;
- `TypedASTPrintShowcase` calls the exported Runtime DLL symbol through
  `DirectExported`;
- `TypedASTRuntimeThunkShowcase` distinguishes the ordinary Engine-registered
  native target from the exported Runtime thunk by independent counters;
- `TypedASTPrivateBridgeShowcase` resolves the current Engine's stable private
  binding slot and proves that the replacement provider is not accidentally
  used.

Every route starts from freshly reset state and compares the interpreter with
Bytecode Raw/VM and Typed Raw/VM/Parms entry points. The first execution RED
was not an object-reference ABI error: the exact exception was
`Calling a function that requires WorldContext, but the current object is not
in a world.` `Print` deliberately retains its `.WorldContext()` policy, so the
test now installs the live editor world in the isolated Engine scope instead
of bypassing that production semantic. The interpreter/native differential
then passes in full.

The explicit non-cloneable row requests Typed generation for
`ObjectLifetimeEntryForAOT`, verifies that no Typed artifact is published, and
records the compiler-owned `MissingTypedHIR` capture diagnostic as
`NonCloneableEffectRejected`. The generated-output verifier exposed one final
RED: repeated fresh fixture roots leaked their random physical directory into
the imported-route rejection detail. The isolated artifact collector now maps
its physical `FixtureRoot/Script` prefix to `/Angelscript/Game` and rejects any
remaining fixture-root leak before retaining the diagnostic. This preserves
the useful source row/column while making repeated results deterministic.

Evidence:

- `Saved/Tests/typed-aot-6-5-5-interpreter-exception-diagnostic-test/
  20260816_112343_953_86e6ff6e` — 0/1 RED with the exact missing-WorldContext
  exception;
- `Saved/Build/typed-aot-6-5-5-world-context-oracle-build/
  20260816_112603_523_40ee2b7a` — focused editor build PASS;
- `Saved/Tests/typed-aot-6-5-5-world-context-oracle-test/
  20260816_112621_741_e9733380` — native/private execution differential 1/1
  PASS;
- `Saved/Tests/typed-aot-6-5-5-native-shape-final/
  20260816_112715_039_dabd2ddf` — generated native rows and explicit
  non-cloneable rejection 1/1 PASS;
- `Saved/Tests/typed-aot-6-5-5-generated-output-final/
  20260816_112754_610_a0565d83` — determinism RED, differing only in random
  physical fixture roots embedded in the imported-route diagnostic;
- `Saved/Build/typed-aot-6-5-5-fallback-path-normalization-build/
  20260816_113157_536_0925565d` — diagnostic normalization build PASS;
- `Saved/Tests/typed-aot-6-5-5-generated-output-normalized/
  20260816_113215_856_3d8f6e48` — repeated generation, checked-in output,
  imported rejection and non-cloneable rejection verification 1/1 PASS.

Tasks 6.5.1 through 6.5.5 are now closed, so parent task 6.5 is complete.

## 2026-08-16 — task 6.6 runtime-route audit

The existing execution-profile model is sound but is currently consumed only
while planning and closing a generation task. It normalizes `FramePosition`,
`LineCallback`, `DebuggerStep`, `DebuggerLocals`, `Coverage`, `LoopTimeout`,
`AbortSuspend`, and `RecursionBudget`; closure analysis also rejects a direct
callee profile mismatch. The first TypedASTJIT development profile currently
offers only `FramePosition | RecursionBudget`, while Shipping offers only
`RecursionBudget`.

The audit found a real integration gap after a Provider is installed. Neither
`FAngelscriptJITProviderRouter` nor `FAngelscriptJITBindingContext` retains and
re-evaluates the entry's available execution capabilities when current Engine
requirements change. The two AngelScript context JIT selection sites and the
UASFunction VM/raw/Parms call helpers currently select a non-null entry pointer
without checking debugger, coverage, or timeout requirements. Therefore a
position-only Typed entry installed before a breakpoint or coverage session can
continue to run even though it cannot provide the newly required hooks.

This is not proven by the existing synthetic execution-profile tests: those
tests validate the pure policy matrix, not the installed Provider and actual
UASFunction/AngelScript call routes. Group 6.6 now requires a real AOT fixture
whose result and independent entry counters prove the selected body.

The implementation seam is deliberately provider-neutral:

- carry an immutable capability/profile identity in the provider entry ABI and
  its artifact digest rather than inferring behavior from a backend name;
- capture current Engine execution requirements at invocation selection;
- gate both `as_context.cpp` JIT sites plus BPVM, Parms and raw UASFunction
  routes before invoking an installed entry;
- use each call site's existing VM path when the entry cannot satisfy the
  complete current root/helper closure;
- distinguish functions that actually contain loop backedges from the global
  Editor timeout setting, so non-loop scalar entries are not needlessly routed
  to VM;
- retain generation-time closure rejection for a heterogeneous instrumented
  root/uninstrumented direct child.

The next TDD proof will activate the real fixture Engine's debugger state after
the position-only Typed Provider is already installed. The script result must
remain correct through VM fallback and the Typed VM/raw/Parms counters must not
increase. No production route change will be accepted from a synthetic policy
test alone.

The real installed-Provider RED is now captured. The focused Editor build
completed at
`Saved/Build/typed-aot-6-6-debugger-route-red-build-complete/
20260816_115412_336_7c352a4d` (the preceding label's UBT also succeeded in
14.02 seconds, but its runner was interrupted before writing the final
summary). The exact CQTest path includes its class component, so the first
shorter method-only prefix discovered zero tests and is not product evidence.
The maintained `Angelscript.TestModule.StaticJIT.AOT.UASFunctionDispatch`
prefix at
`Saved/Tests/typed-aot-6-6-debugger-route-red-discover/
20260816_115502_931_7bb2ca20` ran 8 tests: 7 passed and the new debugger route
test was the sole expected failure. Its script result remained `84`; VM and raw
counters remained unchanged; only the Typed Parms counter changed from `0` to
`1`. This isolates the missing dynamic entry gate without implicating fixture
compilation, Provider adoption, reflected parameter layout, WorldContext, or
the VM oracle.

The first provider-neutral runtime-gate production slice now compiles and
links. It bumps the Provider ABI, carries available execution capabilities and
their profile identity through generation/catalog/adoption, lets the installed
binding compare current Engine requirements with that immutable profile, and
gates both AngelScript context selections plus UASFunction BPVM, Parms, and raw
entry selection. Coverage requirements now observe active recording rather
than merely the presence of a coverage extension. The compatibility header
keeps the maintained fork's Standalone build independent of Unreal-only state.

Evidence:

- `Saved/Build/typed-aot-6-6-runtime-gate-build-1/
  20260816_120324_636_090ef32d` — `174/174` compile/link actions completed,
  `Result: Succeeded`, process exit `0`, no timeout or shared-Engine conflict,
  with `146.669 s` recorded duration.

This build is a compile checkpoint, not a 6.6 GREEN claim. The checked
TypedASTJIT provider artifacts still need regeneration with the new profile
ABI, followed by the exact installed-AOT debugger test and route-prefix
regression. Coverage, loop-backedge-aware timeout routing, nested frames,
recursion, heterogeneous root/helper profiles, and deterministic profile
identity remain open.

## 2026-08-16 — task 6.6 generated profile, test partition, and coverage GREEN

The Provider artifacts were regenerated after the capability-profile ABI
change. Typed entries now carry `HasExecutionCapabilityProfile`, advertise the
current `FramePosition | RecursionBudget` capability set, and retain a nonzero
profile hash; BytecodeJIT entries continue to carry no Typed capability claim.
The generated-output module rebuilt successfully, the exact debugger route
fixture passed, the UASFunction dispatch regression passed, and Provider ABI
tests now cover profile identity plus malformed flag/capability/hash and
unknown-bit rejection.

Evidence before the coverage slice:

- `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-6-6-profile-abi_02_generate/
  20260816_120948_200_9f835621` — AOT generation PASS;
- `Saved/Build/typed-aot-6-6-profile-abi-generated-build/
  20260816_121129_655_e2c60068` — generated output build `33/33` PASS;
- `Saved/Tests/typed-aot-6-6-debugger-route-green/
  20260816_121153_500_a1e43157` — original exact debugger fixture `1/1`
  PASS;
- `Saved/Tests/typed-aot-6-6-uas-dispatch-regression/
  20260816_121237_153_524f5ef0` — UASFunction dispatch `8/8` PASS;
- `Saved/Build/typed-aot-6-6-provider-profile-tests-build/
  20260816_121434_659_070be2b2` — Provider profile test build PASS;
- `Saved/Tests/typed-aot-6-6-provider-profile-tests/
  20260816_121455_601_501a5d13` — Provider ABI/profile `8/8` PASS;
- `Saved/Build/typed-aot-6-6-all-entry-gates-build/
  20260816_121717_377_7ae3a0b9` and
  `Saved/Tests/typed-aot-6-6-all-entry-gates/
  20260816_121736_449_746294ad` — build PASS and real context VM,
  UASFunction raw, and UASFunction Parms debugger gate `1/1` PASS.

The runtime-route tests were then moved out of the already large general AOT
test file and partitioned under
`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/RuntimeRoutes/`:

- `AngelscriptStaticJITAotDebuggerRouteTests.cpp` owns debugger/step/local
  routing;
- `AngelscriptStaticJITAotCoverageTimeoutRouteTests.cpp` owns coverage and the
  pending loop-timeout matrix;
- `AngelscriptStaticJITAotRuntimeRouteTestSupport.{h,cpp}` owns only shared
  isolated-Engine/function lookup and exact VM/raw/Parms counter assertions;
- nested frame and recursion work will use a separate frame/recursion C++ file
  rather than growing either of the current scenario files.

The first build after adding the directory invalidated the UBT makefile because
the source directory was new, discovered all translation units, and completed
all `15/15` actions:

- `Saved/Build/typed-aot-6-6-runtime-routes-split-coverage/
  20260816_123017_793_967f76ad` — PASS in about 25 seconds.

The first partitioned runtime-route run deliberately retained the outstanding
coverage RED:

- `Saved/Tests/typed-aot-6-6-runtime-routes-green/
  20260816_123053_968_611044e3` — debugger PASS, coverage FAIL, total `1/2`.

That RED proved two independent runtime lifecycle bugs rather than an AOT
emitter error. First, `FAngelscriptCodeCoverage::StartRecording()` and stop
changed only a recorder boolean, so an already attached Engine did not refresh
the AngelScript line-callback state. Second, `AngelscriptLineCallback` and its
stack-pop sibling used the process-primary `FAngelscriptEngine::Get()` even
when the executing `asCContext` belonged to an isolated Engine. The result was
correct VM fallback with zero Typed counters, but coverage events were either
disabled or attributed to the wrong Engine.

The fix keeps ownership explicit:

- each extension-created coverage recorder retains its non-owning owner Engine;
- `StartRecording()` and the new report-free `StopRecording()` refresh that
  Engine's line-callback state;
- report writing delegates to `StopRecording()`;
- RuntimeJIT reports `CoverageActive` only while the recorder is active;
- line and stack-pop callbacks resolve their exact owner through
  `FAngelscriptEngine::TryGetByScriptEngine(Context->GetEngine())`;
- the AOT integration fixtures use the Engine-configured context so the proof
  exercises the same callbacks as production execution.

Final focused evidence:

- `Saved/Build/typed-aot-6-6-engine-owned-callback-build/
  20260816_123252_637_6c3aa33f` — incremental build `7/7` PASS;
- `Saved/Tests/typed-aot-6-6-coverage-owner-green/
  20260816_123315_553_764865d7` — exact coverage route `1/1` PASS with result
  `84`, real line hits, and unchanged Typed VM/raw/Parms counters;
- `Saved/Tests/typed-aot-6-6-code-coverage-regression/
  20260816_123409_633_aa0aba10` — existing CodeCoverage theme `34/34` PASS;
- `Saved/Tests/typed-aot-6-6-runtime-routes-final-green/
  20260816_123450_743_f94a64f3` — partitioned RuntimeRoutes parent prefix
  `2/2` PASS.

This closes the current debugger gate and coverage-recording slice, but parent
task 6.6 remains open. Loop-backedge-aware timeout routing, explicit
breakpoint/break-next/data-local variants, live nested frame restoration,
self/mutual recursion budget behavior, heterogeneous root/helper profile
rejection, and final deterministic profile verification are still pending.

## 2026-08-16 — task 6.6 loop-backedge-aware timeout routing GREEN

The partitioned timeout fixture first exposed a diagnostic-instrumentation
gap. Both maintained-fork `asCContext` JIT call sites invoked `VMEntry`
directly instead of using the common runtime invocation helper, so a real
Typed body could execute while its provider-neutral VM execution counter
remained zero. The two sites now use `FAngelscriptJITExecutionContext::InvokeVM`.
This centralizes execution-scope publication and counter updates without
putting the generic execution helper back into generated `.jit.cpp` bodies.

After that correction, the strengthened test produced the intended product
RED: with timeout disabled the loop-bearing function entered Typed VM once;
after enabling `EditorMaximumScriptExecutionTime` on the already installed
Provider it incorrectly entered Typed a second time. This proved that
install-time selection alone could not preserve the VM loop-timeout behavior.

The provider-neutral entry ABI is now revision 6 and carries
`RuntimeExecutionRequirementTriggers` in addition to the immutable available
capability set/profile hash. The field participates in manifest validation,
artifact-set identity, catalog copying/equality, binding adoption, generated
provider rows, and readable generated function metadata. TypedASTJIT scans
every same-compilation direct closure member's verified HIR for
`LoopBackedge`; if the root or any directly emitted helper contains one, the
root entry receives a `LoopTimeout` trigger. At invocation, that capability is
required only while the Editor timeout is nonzero. Consequently a loop entry
without `LoopTimeout` support falls back to VM, while unrelated no-loop
entries remain eligible for Typed execution.

Generated evidence is directly inspectable:

- `SemanticStructuredControlFlow` advertises `ExecutionCaps: 129` and
  `RuntimeTriggers: 32`;
- `TypedFinalRawValue` advertises the same available profile but
  `RuntimeTriggers: 0`;
- the generated provider aggregate retains the exact trigger value in the
  ABI row rather than inferring it from a declaration, backend name, or
  process-local pointer.

Focused evidence:

- diagnostic-counter RED after centralizing VM invocation:
  `Saved/Tests/typed-aot-6-6-loop-timeout-counter-green-next-red/
  20260816_124632_684_c77102b4` — baseline Typed VM count became correct and
  the sole failure moved to the timeout-enabled call entering Typed again;
- ABI/runtime build:
  `Saved/Build/typed-aot-6-6-loop-trigger-abi-build/
  20260816_125051_538_a66241ba` — 60/60 actions PASS;
- Provider ABI/manifest tests:
  `Saved/Tests/typed-aot-6-6-loop-trigger-provider-abi/
  20260816_125213_593_3a72d566` — 8/8 PASS, including trigger identity and
  malformed/unknown trigger rejection;
- maintained generation:
  `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-6-6-loop-trigger_02_generate/
  20260816_125252_777_d90113b6` — exit 0, zero errors;
- generated carrier build:
  `Saved/Build/typed-aot-6-6-loop-trigger-generated-build/
  20260816_125429_622_fa9a985a` — 33/33 PASS;
- exact timeout route:
  `Saved/Tests/typed-aot-6-6-loop-timeout-green/
  20260816_125509_363_04874b24` — 1/1 PASS;
- complete partitioned route prefix:
  `Saved/Tests/typed-aot-6-6-runtime-routes-loop-green/
  20260816_125553_012_a4970783` — debugger, coverage, and timeout 3/3 PASS.

Task 6.6.3 is complete. Parent 6.6 remains open for explicit debugger-state
variants, abort/suspend requirement handling, live frame restoration,
self/mutual recursion, heterogeneous closure profiles, and final deterministic
profile verification. Frame/recursion tests will be added in their own
`StaticJIT/AOT/RuntimeRoutes` translation unit as frozen by the AOT test spec.

## 2026-08-16 — runtime-route test partition and recursive-frame proof

The installed-AOT self/mutual-recursion integration test no longer lives in
the general `AngelscriptStaticJITAotTests.cpp` test class. It was moved to the
bounded scenario file:

- `StaticJIT/AOT/RuntimeRoutes/
  AngelscriptStaticJITAotFrameRecursionRouteTests.cpp`
- automation prefix:
  `Angelscript.TestModule.StaticJIT.AOT.RuntimeRoutes.FrameRecursion`

The file uses only the small shared runtime-route support layer for isolated
Engine validation, module/function lookup, binding-context access, and
provider-neutral entry counters. Recursive execution, frame-budget handling,
and exception assertions remain local to the frame/recursion scenario instead
of growing that support layer or the general AOT file.

The migrated proof was strengthened while preserving its existing behavior:

- ordinary self-recursive and mutually recursive calls preserve the expected
  script result and increment the installed Typed `VMEntry` count exactly
  once per root invocation;
- direct Raw invocation increments the installed Typed `RawEntry` count
  exactly once and stops at an explicit native recursion budget;
- both the direct Raw budget failure and the context-driven default-budget
  failure preserve the maintained stack-overflow exception text;
- every failure restores native JIT frame depth, thread-local active function,
  and active execution state.

Focused evidence:

- `Saved/Build/typed-aot-6-6-frame-recursion-split-build/
  20260816_130158_976_9523fa98` — incremental editor build PASS (`7/7`
  actions after UBT discovered the new source file);
- `Saved/Tests/typed-aot-6-6-frame-recursion-split-green/
  20260816_130223_383_fda19411` — exact new prefix `1/1` PASS.

This closes the physical test migration and the installed self/mutual
recursion counter/budget slice of task 6.6.4. Task 6.6.4 remains open for the
live nested root/helper position probe, heterogeneous root/child capability
rejection, and final deterministic profile-identity/output proof.

## 2026-08-16 — live root/helper source-frame proof GREEN

The frame/recursion scenario now contains a live execution probe rather than
only generated-text assertions. The typed-recursion fixture registers the
provider-private native binding `TypedASTObserveFrame(int)` and attaches the
same Scalar/CurrentNativeBinding descriptor path used by production typed
native calls. `TypedASTFrameEntry` invokes the observer before and after a
direct emitted helper call; `TypedASTFrameHelper` invokes it while nested.
The observer records both the public execution file/line API and the active
native JIT debug-callstack chain.

The first test-only build intentionally omitted the observer registration and
produced the expected compiler RED at all three AS call sites:

- `Saved/Build/typed-aot-6-6-live-frame-red-build/
  20260816_130733_894_3b50c4b1` — build PASS;
- `Saved/Tests/typed-aot-6-6-live-frame-red/
  20260816_130755_805_55057612` — startup compile RED because
  `TypedASTObserveFrame` was not registered.

After registering the observer, the existing generated Provider was
deliberately stale. The exact runtime test then produced the second intended
RED instead of silently accepting old code: provider routing reported
`verified=80 exact=77 native=77 vm=3`, and the new root had no Typed binding
context. This proves the stable content identity rejected the pre-change
Provider:

- `Saved/Build/typed-aot-6-6-live-frame-probe-build/
  20260816_130904_398_48cd6c5d` — incremental build PASS;
- `Saved/Tests/typed-aot-6-6-live-frame-provider-red/
  20260816_130922_588_cb206457` — expected stale-provider RED.

One diagnostic run used the project-level `RunAngelscriptJIT.ps1` entry and
failed before product generation because this isolated host does not contain
the project scaffold expected by that runner. That result is retained as a
wrong-runner diagnostic at
`Saved/AngelscriptJITRuns/typed-aot-6-6-live-frame-generate/
20260816_131012_061_a99e2028`; TestJIT generation must use
`RunStaticJITTests.ps1` or the `AngelscriptTestJIT` commandlet. All build and
test scripts for this worktree must also be launched through the configured
`V:\` root. Launching from the physical `.worktree` path is rejected by the
project-root guard because `AgentConfig.ini` intentionally names the mapped
project path.

The maintained TestJIT generation then produced one module-owned recursion
file containing both root and helper. Inspection confirmed:

- `TypedASTFrameEntry` and `TypedASTFrameHelper` each establish an
  `FScopeTypedASTJITExecutionFrame` with canonical declaration and source
  location metadata;
- the helper frame nests beneath the root frame and restores the root after
  return;
- all three observer calls use the CurrentNativeBinding call-site metadata;
- generated function bodies do not use `FAngelscriptJITExecutionContext`.

Final focused evidence:

- `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-6-6-live-frame_02_generate/
  20260816_131115_107_ea119b52` — generation PASS, zero errors;
- `Saved/Build/typed-aot-6-6-live-frame-generated-build/
  20260816_131415_641_de0a8ea9` — generated carrier build `5/5` PASS;
- `Saved/Tests/typed-aot-6-6-live-frame-green/
  20260816_131446_429_3e9b7c65` — exact live root/helper test `1/1` PASS;
- `Saved/Tests/typed-aot-6-6-frame-recursion-green/
  20260816_131529_600_3ccca71a` — partitioned frame/recursion prefix `2/2`
  PASS, including the existing self/mutual recursion proof;
- `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-6-6-live-frame-verify/
  20260816_131616_798_5996c99a` — maintained generated-output Verify PASS
  with zero errors.

The live root/helper and recursion portions of task 6.6.4 are now closed.
The task remains unchecked until heterogeneous root/child capability-profile
rejection and its deterministic profile identity/output proof are complete.

## 2026-08-16 — distinct debugger runtime-requirement matrix GREEN

The runtime-route Debugger scenario previously exercised only
`DebugServer->bIsDebugging = true`. That state conservatively requests line
callbacks, stepping, and inspectable locals together, so it did not prove
that the two narrower live DebugServer states were independently captured and
routed. The existing real VM/Raw/Parms execution proof is now parameterized
across three distinct states while keeping all scenario bodies in
`StaticJIT/AOT/RuntimeRoutes/AngelscriptStaticJITAotDebuggerRouteTests.cpp`:

- a connected debugger publishes
  `FramePosition|LineCallback|DebuggerStep|DebuggerLocals`;
- `bBreakNextScriptLine` without a connected-debugger blanket publishes
  `FramePosition|LineCallback|DebuggerStep`;
- a live data-breakpoint/local-inspection requirement publishes
  `FramePosition|LineCallback|DebuggerLocals`.

Each case invokes the actual installed Provider through context VM, reflected
Raw, and reflected Parms routes. Results remain `84`, while the Typed VM/Raw/
Parms counters remain unchanged for the complete invocation. The test restores
the prior DebugServer flags, data-breakpoint array, and line-callback state
after every case, so the shared isolated fixture session does not carry state
between test methods.

Focused evidence:

- `Saved/Build/typed-aot-6-6-debugger-state-matrix-build/
  20260816_132136_596_0a6a78c2` — incremental test build `4/4` PASS;
- `Saved/Tests/typed-aot-6-6-debugger-state-matrix/
  20260816_132157_604_140ea00e` — connected debugger, break-next, and
  data-breakpoint/local-inspection routes `3/3` PASS.

No production routing change was required: the new matrix confirms that
`CaptureCurrentJITExecutionRequirements()` already distinguishes the three
authoritative DebugServer states and that the entry gates consume those bits
for all current entry ABI shapes. The explicit debugger-state portion of task
6.6 is closed; abort/suspend and heterogeneous closure-profile work remains.
## 2026-08-16 — task 6.6 abort/suspend capability boundary audit

The runtime-requirements audit found that abort/suspend is not a currently
requestable maintained-fork execution state. The authoritative local source is
`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/
as_context.cpp`:

- `asCContext::Abort()` at lines 1038-1041 returns `asERROR`;
- `asCContext::Suspend()` at lines 1044-1047 returns `asERROR`;
- `m_doSuspend`, `m_doAbort`, and `m_externalSuspendRequest` are initialized or
  reset, but the current fork has no writer which establishes a cooperative
  request and no `m_regs.doProcessSuspend` polling chain.

The read-only upstream comparison used the pinned local AngelScript 2.38.0
reference at
`D:/Workspace/AngelscriptProject/Reference/angelscript-v2.38.0`, commit
`0601da029d846a658bf23f2888e953a45a94450a`. Its `as_context.cpp` does not merely
change the two public methods: it sets request/status flags and
`m_regs.doProcessSuspend`, then polls that state at `asBC_SUSPEND`, recursive
entry, native/system-call boundaries, exception handling, and line-callback
configuration. The current fork does not have the corresponding register field
or polling sites.

Decision: `EAngelscriptJITExecutionCapability::AbortSuspend` remains a reserved,
provider-neutral fail-closed contract bit, and the synthetic execution-profile
test continues to prove that a position-only profile rejects it with
`AbortSuspendSafepointUnavailable`. The Engine does not invent a live request
that its maintained VM cannot currently issue. Restoring cooperative
abort/suspend is a separately scoped maintained-fork semantic backport: it must
cover the complete request/poll/status/thread-safety path before Runtime JIT or
TypedASTJIT may advertise safe-point parity. A test-only global flag and a
partial copy of the two 2.38 methods were explicitly rejected because either
would create false safety evidence.

## 2026-08-16 — task 6.6 complete capability and runtime-route verification

The final 6.6 audit checked all maintained script-JIT selection surfaces rather
than relying on the runtime fixture alone. Both `asCContext` VM-entry call sites
and the UASFunction VM/raw/Parms entry paths call
`FAngelscriptEngine::AllowsJITBindingExecution()`. That common gate captures
the current debugger/coverage state on every invocation and adds the per-entry
`LoopTimeout` requirement only when the generated artifact marks a loop
trigger and the Editor timeout is nonzero. Recursion is an immutable generated
closure/profile capability, not a mutable global runtime switch.

The provider-neutral contract carries
`HasExecutionCapabilityProfile`, `AvailableExecutionCapabilities`,
`RuntimeExecutionRequirementTriggers`, and
`ExecutionCapabilityProfileHash`. Manifest validation rejects unknown,
missing, or internally inconsistent profile fields; the profile hash
participates in the artifact-set digest. Typed body emission stores the same
profile identity, while the provider emitter rejects a body/wrapper profile or
frame-position mismatch for both roots and internal helpers.

Focused verification from `V:/` with the isolated worktree and UE 5.8:

- `Saved/Tests/typed-aot-6-6-profile-contract/
  20260816_132954_344_ce8a21cc` — execution capability/requirements contract
  `5/5` PASS, including reserved `AbortSuspend` fail-closed behavior, stable
  identity, complete matrix, and unknown-bit rejection;
- `Saved/Tests/typed-aot-6-6-closure-profile/
  20260816_133032_783_13fefb6e` — complete Typed direct-call closure prefix
  `15/15` PASS, including heterogeneous direct-child profile rejection and
  recursive SCC requirements;
- `Saved/Tests/typed-aot-6-6-runtime-routes-complete/
  20260816_133109_747_f2f020dd` — partitioned installed-AOT RuntimeRoutes parent
  prefix `7/7` PASS: debugger connected/break-next/data-local VM routing,
  coverage, loop/no-loop timeout, nested root/helper frames, and self/mutual
  recursion all report exact VM/Typed counters;
- `Saved/Tests/typed-aot-6-6-provider-profile-abi/
  20260816_133248_095_4c550511` — provider ABI `8/8` PASS, including profile
  identity/digest participation and malformed-profile rejection;
- `Saved/Tests/typed-aot-6-6-profile-output/
  20260816_133322_682_ecab3891` — exact instrumentation generated-output case
  `1/1` PASS: position hooks appear only for the position profile, unsupported
  hooks fail with no partial C++, and a recursion-only profile has a distinct
  identity and output body.

The first profile-contract launcher invocation outlived the orchestration
tool's accidental five-second wait budget, but its child Editor remained valid
and completed with an exported `5/5` PASS report and exit code zero. No second
Editor was launched while it was active; later focused invocations used the
test runner's normal completion wait.

Task 6.6 is therefore closed from three independent layers: normalized
capability contract, static direct-closure validation, and installed generated
AOT execution. Task 6.7 remains separate because it must prove whole-generation
byte determinism and verification failure for stale or missing expected Typed
artifacts, not merely deterministic single-body emission.

## 2026-08-16 — task 6.7 generated-output verification and test partition

The former `GeneratedOutputVerify` scenario was removed from the general
`AngelscriptStaticJITAotTests.cpp` translation unit and replaced by the focused
`StaticJIT/AOT/Generation/AngelscriptStaticJITAotGenerationVerificationTests.cpp`
surface. Its dedicated
`Angelscript.TestModule.StaticJIT.AOT.GenerationVerification` prefix owns three
whole-generation scenarios:

- two fresh generation Engines must produce byte-identical Provider output,
  normalized HIR, generated C++, Provider generation identity, and artifact-set
  digest, and the result must verify against the checked-in output;
- a recursion-only instrumentation profile must produce a different Provider
  generation and artifact-set digest, then fail verification against the
  position/default checked-in output with the owned-bytes-stale diagnostic;
- an expected Typed UFUNCTION root forced to require unavailable Coverage
  capability must fall back, and whole-generation verification must reject the
  missing expected Typed result.

The test-owned generation fixture now exposes only verification-safe fault
variants. `RecursionOnlyProfile` changes the frozen generation profile, while
`RequireCoverageWithoutCapability` changes the expected root requirements so
the normal eligibility path produces a deterministic fallback. Both variants
reject `Generate` mode before any file write. The production/default generation
path remains unchanged. `ArtifactSetDigest` is returned for assertions from the
same Provider result used by normal generation rather than recomputed by the
test.

TDD and focused verification evidence from `V:/` with the isolated worktree and
UE 5.8:

- `Saved/Build/typed-aot-6-7-verification-red/
  20260816_133925_313_f19aeb37` — expected RED: the new test did not compile
  before the test-only variants and artifact-set digest were exposed;
- `Saved/Build/typed-aot-6-7-verification-green-build/
  20260816_134035_811_ccaf4b3e` — implementation build `6/6` PASS;
- `Saved/Tests/typed-aot-6-7-generation-verification/
  20260816_134058_391_0909dced` — initial focused prefix: repeated-generation
  and expected-fallback scenarios passed; the cross-profile scenario reached
  every identity/stale assertion but its test incorrectly expected the enum
  spelling `ContentMismatch` in a human-readable diagnostic;
- `Saved/Build/typed-aot-6-7-cross-profile-fix-build/
  20260816_134737_719_c09aec20` — assertion-only incremental build PASS in
  13.22 seconds;
- `Saved/Tests/typed-aot-6-7-cross-profile-green/
  20260816_134809_390_dca6332f` — exact cross-profile method `1/1` PASS after
  asserting the stable file-store detail `Owned generated bytes are stale.`.

The expensive cross-profile case takes about 157 seconds because it performs
two complete isolated Engine generations. Keeping it in a dedicated file and
prefix is intentional: ordinary AST lowering, scalar operation, ABI, native
call, and runtime-route edits should run only their focused tests, while this
whole-generation proof is reserved for generation/profile/file-store changes.
The broader OpenSpec test-organization rule now requires future AST JIT/AOT
coverage to be partitioned by capability and scenario instead of growing the
general AOT test file or a replacement monolithic helper.

Task 6.7 is closed: deterministic regeneration, cross-profile identity/output,
stale verification, and expected-eligible fallback rejection all have active
integration evidence.

## 2026-08-16 — task 6.8 regeneration, reference resolution, and focused AOT triage

The maintained paired-artifact workflow was run from the isolated `V:/`
worktree through `Tools/RunStaticJITTests.ps1 -Mode Generate -AotOnly`. It
completed with the expected fixture warnings, zero errors, and an exact owned
inventory (`34` declared, `34` present, no missing or unexpected files). The
current generated Provider identity is
`7dc70fd55a76cc55d726e32d5c2434713bd93755a32e4dd524a4b7c39c8b5d44`
and its generation identity is
`32a70919d49a46d98f7cc2a976e4e5f836b6b664c3182b65786fe3d4295d7aee`.
The OpenSpec-prescribed `semantic-aot-generated` build and a subsequent
read-only Verify both passed; regeneration retained identical owned bytes and
timestamps.

The first complete `Angelscript.TestModule.StaticJIT.AOT` run discovered `56`
tests and produced `53` PASS / `3` FAIL. This was useful integration evidence,
not a timeout: it exposed one production reference-identity defect and two
stale dispatch-counter expectations.

### Script-global reference identity fix

The committed Provider contains a stable ScriptGlobal reference for
`const int TypedASTDifferentialFoldedGlobal = 7001`, but the current Engine
resolver originally enumerated only Engine-owned globals and therefore missed
module-owned script globals. Adding `asCModule::scriptGlobalsList` enumeration
found the property, but the key still differed because generation used the
Engine's canonical type declaration (`int`) while the current resolver and two
other current-reference paths used `asCDataType::Format` (`const int`). The
production fix now uses
`GetTypeDeclaration(GetTypeIdFromDataType(Property->type), true)` consistently
in HIR/provider capture, Cache semantic reference validation, and current
Engine reference resolution. This keeps stable identity independent of the
fork's formatted storage qualifiers.

Focused evidence:

- `Saved/Build/typed-aot-6-8-script-global-canonical-diagnostic-build/
  20260816_141056_866_b7db64f0` — expected diagnostic compile failure showing
  this maintained fork does not expose `asCDataType::GetTypeId()`; the
  authoritative API is `asCScriptEngine::GetTypeIdFromDataType`;
- `Saved/Build/typed-aot-6-8-script-global-canonical-green-build/
  20260816_141310_495_2a4bf12d` — production fix build PASS (`6` actions);
- `Saved/Tests/typed-aot-6-8-script-global-canonical-green/
  20260816_141330_895_d6eb01c2` — exact committed-reference-resolution test
  `1/1` PASS, `54/54` references resolved and all `80/80` generated Provider
  entries routed native.

### UASFunction route-counter correction and test partition

The two remaining failures reproduced independently under the
`UASFunctionDispatch` prefix (`5/7` before the correction), so they were not
parent-prefix order pollution. The structured-control-flow function contains a
loop. With the Editor loop-timeout requirement enabled, its Typed profile
correctly lacks `LoopTimeout` and must fall back to VM; it was therefore the
wrong fixture for a test whose purpose is to prove direct Parms dispatch. The
test now retains origin/wrapper checks for both roots but executes the
loop-free exhaustive-enum root for the Parms assertion. Separately, the
bytecode generated-WorldContext fallback comment predated the shared execution
context: AS Context now enters its current VM binding through
`FAngelscriptJITExecutionContext::InvokeVM`, so the exact VM count increases
once while Raw and Parms remain unchanged.

The production fail-closed capability matrix was not weakened. The assertion
correction build and focused prefix passed:

- `Saved/Build/typed-aot-6-8-uas-route-assertions-build/
  20260816_142025_384_79340e36` — incremental build PASS;
- `Saved/Tests/typed-aot-6-8-uas-route-green/
  20260816_142052_008_e4bfbaff` — `UASFunctionDispatch` `7/7` PASS.

Following the test-partition rule, the seven reflected-dispatch automation
methods now live in
`StaticJIT/AOT/UASFunctionDispatch/AngelscriptStaticJITAotUASFunctionDispatchTests.cpp`.
A narrow bridge reuses the existing fixture and scenario implementations, so
the split does not add another Engine initialization or change automation
names. Build and discovery evidence after the physical split:

- `Saved/Build/typed-aot-test-organization-uas-build/
  20260816_142333_283_365cc93e` — PASS after adding the translation unit;
- `Saved/Tests/typed-aot-test-organization-uas-green/
  20260816_142354_726_296dadb2` — the unchanged dedicated prefix still
  discovers and passes `7/7` tests.

The final complete parent-prefix rerun is
`Saved/Tests/semantic-aot-aot-green/20260816_142527_385_ab753cb1`:
`56/56` PASS, zero failures, zero skips, exit code zero, and no timeout in
401.6 seconds. This closes the original three integration failures while
retaining the generated Provider bytes verified earlier in the task. Both the
plugin submodule and parent OpenSpec working trees also pass `git diff
--check`; the reported messages are line-ending notices only, not whitespace
errors.

Task 6.8 is complete. Future reference-only additions should be accumulated
under a bounded `AOT/References/` surface rather than extending the general
AOT file.

### AST JIT / AOT test partition rule tightened before task 7

The maintained general AOT test translation unit remains close to seven
thousand physical lines even after the landed `RuntimeRoutes`, `Generation`
and `UASFunctionDispatch` extraction. Per the implementation review request,
new AST JIT/AOT coverage is now required to land beneath bounded capability
directories instead of extending that file.

The AOT test spec and task 7.1 now explicitly reserve
`StaticJIT/AOT/Diagnostics/` for three independently evolving contracts:
generation/artifact diagnostics, installed Provider/route diagnostics, and
deterministic serialization/console output. The remaining incremental
extraction map, including `References`, `Parity`, `ProviderLifecycle`, and
`ExceptionsAndLifetime`, is recorded in
`research/ast-jit-aot-test-partition.md`. Existing tests will move by complete
scenario family while preserving discovery names and reusing one narrow shared
fixture/session interface; no mass rename or duplicate per-file Engine
initialization is planned.

### Task 7.1 generation diagnostics slice 1: request and backend attempts

The first task-7 test now lives in the new bounded diagnostics surface:

`StaticJIT/AOT/Diagnostics/AngelscriptStaticJITAotGenerationDiagnosticsTests.cpp`.

Its RED build failed only because `FStaticJITDiagnostics::FSnapshot` had no
artifact-request record and no conversion from the existing pointer-free
`FAngelscriptStaticJITGeneratorOutput`:

- `Saved/Build/typed-aot-diagnostics-generation-red/
  20260816_144410_958_6124725c` — expected compile RED.

Schema 5 now adds an optional `artifactRequest` object. The pure conversion
preserves fixed request kind `StaticJITArtifact`, requested backend, capture
state/HIR-capture flag, ordered fallback chain, compiled-source-graph summary,
task error, and per-function actual backend, entry kinds and ordered backend
attempts. Functions are ordered by stable FunctionKey; the record contains no
Engine pointer, numeric Engine function ID, or process address. A live
`CaptureSnapshot` emits the explicit artifact request kind but leaves unknown
generation selection fields empty instead of fabricating them.

Verification:

- `Saved/Build/typed-aot-diagnostics-generation-green-build/
  20260816_144639_442_3bd33b61` — incremental build PASS;
- `Saved/Tests/typed-aot-diagnostics-generation-green/
  20260816_144702_002_84b0fae3` — new Generation diagnostics `1/1` PASS;
- `Saved/Tests/typed-aot-diagnostics-schema5-regression/
  20260816_144736_690_5a3b2bb2` — complete diagnostics parent prefix `7/7`
  PASS.

This is only the first task-7 slice. Typed fallback reasons are still collapsed
into backend-attempt detail text and must next cross the generator boundary as
structured enum plus source provenance; task 7.1/7.2 therefore remain open.

### Task 7.1 generation diagnostics slice 2: structured typed fallback

The second Generation diagnostics test enumerates every current
`EAngelscriptTypedASTJITFallbackReason`, gives the free-form backend-attempt
detail an opaque value, and requires the JSON reason plus processed source
section/row/column to come from a separate structured record. Its first build
failed only because backend attempts did not yet own `TypedDiagnostic`:

- `Saved/Build/typed-aot-diagnostics-structured-fallback-red/
  20260816_144954_728_27b77154` — expected compile RED.

`FAngelscriptStaticJITFunctionResult` and
`FAngelscriptStaticJITBackendAttemptDiagnostic` now optionally retain one
pointer-free `FAngelscriptStaticJITTypedFunctionDiagnostic`. The generator
copies it into the ordered attempt history before a later Bytecode backend
replaces the selected function result. The TypedAST backend fills the record
directly from eligibility/closure facts and uses explicit `EmitterFailure` for
post-eligibility emission failures. Diagnostics serialization copies the enum
through the exhaustive `LexToString` vocabulary and never parses `Detail`.

Verification:

- `Saved/Build/typed-aot-diagnostics-structured-fallback-green-build/
  20260816_145156_739_dbb172fb` — build PASS;
- `Saved/Tests/typed-aot-diagnostics-structured-fallback-green/
  20260816_145223_314_6d084553` — Generation diagnostics `2/2` PASS.

Root/helper shape, raw/unknown traits, capability closure, exception/cleanup
state and per-call disposition remain subsequent task-7 slices, so 7.1/7.2
remain open.

### Task 7.1 generation diagnostics slice 3: semantic and closure facts

The third bounded Generation diagnostics method requires one owned semantic
record for the selected function plus the complete Typed root/helper closure.
Its RED build failed exclusively on the intentionally missing record/enum
contract:

- `Saved/Build/typed-aot-diagnostics-semantic-facts-red/
  20260816_150109_046_725cf881` — expected compile RED.

The backend-neutral output now copies the following facts while the generation
HIR is still alive:

- stable FunctionKey and exact `NonRoot|UFunctionRoot|DirectScript|
  InternalSemanticHelper|Bridge|Unsupported` closure role;
- raw and classified unknown function-trait bits;
- normalized invocation/receiver kind and receiver parameter index;
- explicit `Missing|Verified|Invalid` HIR state;
- cleanup-plan state, suspend/exception-cleanup flags, all-transfer coverage,
  SCC component and recursion state;
- per-member structured eligibility reason/detail/processed source;
- required/available capability sets and their identity hashes;
- `Unavailable|PositionOnly|Instrumented` profile classification and exact
  recursion-guard availability;
- successful emitted-root exception control through the shared execution
  state and payload through the owned first-failure record.

No Engine/HIR/function pointer crosses this record. The `Invalid` HIR value is
part of the fail-closed diagnostic vocabulary; a normal accepted backend task
reports only `Missing` or `Verified`, because an invalid HIR cannot be handed
to emission as a verified input. Schema revision advanced from 5 to 6 for the
new nested `semanticFunction` and `callClosure` objects. Closure functions are
serialized in stable FunctionKey order.

The synthetic diagnostics test proves the generator/JSON boundary. The
existing whole-generation test was extended with test-only aggregate
observations after real Typed backend output, so production provenance is
proved without creating another fixture Engine in the new diagnostics
translation unit.

Verification:

- `Saved/Build/typed-aot-diagnostics-semantic-facts-green-build/
  20260816_150647_612_ca8e328a` — schema/serialization build PASS;
- `Saved/Tests/typed-aot-diagnostics-semantic-facts-green/
  20260816_150716_366_ffc9c3f5` — bounded Generation diagnostics `3/3` PASS;
- `Saved/Build/typed-aot-diagnostics-production-feed-build/
  20260816_150859_547_df9de31e` — production-observation build PASS;
- `Saved/Tests/typed-aot-diagnostics-production-feed/
  20260816_150922_400_3e6bb562` — real GenerationVerification `3/3` PASS,
  process exit zero, no runner timeout, duration 283190 ms;
- `Saved/Tests/typed-aot-diagnostics-schema6-regression-corrected/
  20260816_151516_604_01895504` — parent AOT Diagnostics `9/9` PASS.

Two validation-command issues were diagnosed without changing production
behavior. The first GenerationVerification launch used a 120-second shell
wait around a valid runner timeout of 600 seconds; the shell detached while
the single responsive Editor process continued and wrote the successful
report. The next invocation should give the shell at least the runner timeout
or monitor the existing process by report path. The first schema regression
used the nonexistent prefix `Angelscript.TestModule.StaticJIT.Diagnostics` and
correctly failed discovery; the source-authoritative prefix is
`Angelscript.TestModule.StaticJIT.AOT.Diagnostics`, used by the successful
corrected run above.

Both plugin and parent `git diff --check` return exit code zero; emitted
messages are line-ending notices only. Per-call lowering/linkage/source rows,
authored/generated provenance and installed Provider/catalog publication
remain open, so tasks 7.1 and 7.2 are not checked yet.

### Task 7.1 generation diagnostics slice 4: per-call lowering and test partition

Per the bounded-test-file rule, the call-level contract was not added to the
existing Generation diagnostics translation unit. It now lives in
`StaticJIT/AOT/Diagnostics/AngelscriptStaticJITAotCallDiagnosticsTests.cpp`
under the dedicated
`Angelscript.TestModule.StaticJIT.AOT.Diagnostics.Calls` prefix. The file is a
synthetic pointer-free serialization test and starts no additional generation
Engine. Real production-feed assertions remain in the existing
`AOT/Generation/AngelscriptStaticJITAotGenerationVerificationTests.cpp`
session.

The RED build failed only on the intentionally absent typed call record and
`CallClosure.Calls` collection:

- `Saved/Build/typed-aot-call-diagnostics-red/
  20260816_152121_276_b9227a06` — expected compile RED.

The backend-neutral Typed diagnostic output and schema 7 now retain one owned
call record per closure edge:

- stable caller/callee keys and HIR expression index, never an Engine-local
  function ID or executable pointer;
- mandatory processed source plus explicitly optional authored/generated
  coordinates; current production capture populates processed source and does
  not relabel it as authored/generated source;
- typed target kind and the complete
  `DirectScript|InternalSemanticHelper|DirectExported|DirectInline|
  RuntimeThunk|CurrentNativeBinding|Bridge|Unsupported` disposition vocabulary;
- callee eligibility reason/detail/source and native linkage validation
  code/detail as separate typed facts;
- canonical AS declaration, actual emitted route and literal C++ callee,
  direct C++ symbol, fixed Runtime DLL core, generated metadata-row symbol,
  registered target display, stable target key, expected ABI and reference
  slot;
- deterministic ordering by caller FunctionKey, expression index and callee
  FunctionKey.

The closure planner supplies stable/source/validation facts while the HIR and
generation Engine are alive. Only after successful body and Provider emission
does the backend enrich the same exact caller+expression record from
`FAngelscriptTypedASTJITNativeCallSiteMetadata`. Thus a bridge dump separately
answers the generated `InvokeBound<...>` callee, Runtime DLL
`InvokeBoundViaVM` core, immutable metadata row, numeric slot and readable
registered target. The strings remain diagnostic-only: generated execution
continues to dispatch by stable key + expected ABI + adopted reference slot.

Verification:

- `Saved/Build/typed-aot-call-diagnostics-green-build/
  20260816_152603_430_ada522eb` — production/schema build PASS (`19` actions);
- `Saved/Tests/typed-aot-call-diagnostics-green/
  20260816_152631_998_baa4b47e` — initial bounded Calls test `1/1` PASS;
- `Saved/Tests/typed-aot-call-diagnostics-production-feed/
  20260816_152709_424_550cf76d` — real generation verification `3/3` PASS with
  the fixture's existing compiler warnings, zero failures and process exit 0;
- `Saved/Tests/typed-aot-call-diagnostics-schema7-regression/
  20260816_153200_310_92ab16b3` — AOT Diagnostics parent prefix `10/10` PASS;
- `Saved/Build/typed-aot-call-diagnostics-vocabulary-build/
  20260816_153319_892_a4e9cc03` — exhaustive disposition/order test build PASS
  (`4` actions);
- `Saved/Tests/typed-aot-call-diagnostics-vocabulary-green/
  20260816_153340_102_a3285222` — final bounded Calls test `1/1` PASS.

The full authored/generated provenance capture remains task 2.17 work; this
slice only exposes honest optional fields and proves absent generated origin is
omitted rather than fabricated. Installed Provider/catalog publication,
current bound/unbound/stale/ABI-mismatch joins, command output and Shipping
exclusion remain open, so tasks 7.1 and 7.2 stay unchecked.
## 2026-08-16 — task 7 installed-Provider diagnostics ABI and bounded test

The installed diagnostic contract was added as a separate bounded translation
unit:

`StaticJIT/AOT/Diagnostics/AngelscriptStaticJITAotInstalledDiagnosticsTests.cpp`

It does not create another isolated Engine. A synthetic one-entry Provider
drives the cross-DLL ABI validator and Registry copy path. Provider ABI revision
7 appends an optional flat diagnostic catalog containing function, ordered
backend-attempt, semantic-function, and per-call rows. Runtime validates all
element sizes, table/range ownership, stable keys, capability masks, boolean
fields, required token strings, and a separate diagnostic digest, then deep
copies every pointer-backed string/table into the Registry snapshot.

Diagnostic metadata is deliberately excluded from `ArtifactSetDigest` and
`ProviderGeneration`. Re-registering the same execution catalog with a changed
diagnostic digest returns `Replaced` and publishes a new snapshot; an execution
catalog mismatch under the same Provider generation remains
`AmbiguousGeneration`. This permits diagnostic wording or requested-backend
metadata to change without lying about executable identity.

The adaptive non-unity RED build additionally exposed one partition-specific
implicit include in
`AOT/RuntimeRoutes/AngelscriptStaticJITAotFrameRecursionRouteTests.cpp`; the
translation unit now directly includes `Testing/AngelscriptScriptTestRunner.h`.

Evidence:

- RED build: `Saved/Build/typed-aot-installed-diagnostics-red/20260816_154112_858_7da62188`;
- first production build: `Saved/Build/typed-aot-installed-diagnostics-green-build/20260816_155026_325_f55469f8` — expected implementation compile failure because stable function keys use `Hash.IsZero()` rather than an `IsValid()` method;
- GREEN build: `Saved/Build/typed-aot-installed-diagnostics-green-build-02/20260816_155113_995_7fbab423` — PASS;
- focused test: `Saved/Tests/typed-aot-installed-diagnostics-green/20260816_155137_131_b09d5369` — `1/1 PASS`.

Task 7.1 and 7.2 remain open: generated Providers still need to render the
catalog, installed diagnostics must feed `as.StaticJIT.DumpDiagnostics`, and
GameShipping must prove that the optional pointer is omitted.

## 2026-08-16 — generated Provider diagnostic catalog and formal generation

The optional ABI-7 diagnostic catalog is now packaged into non-Shipping
Providers. `FAngelscriptJITGeneration` normalizes diagnostic functions into
the exact emitted FunctionKey order, rejects missing, duplicate and
non-emitted rows, flattens contiguous backend-attempt, semantic-function and
call ranges, validates the transient view, computes a diagnostic-only digest,
and renders provider-owned immutable tables. `ArtifactSetDigest` and
`ProviderGeneration` remain unchanged when only diagnostics are present.
GameShipping omits the include, tables, digest and Provider-view pointer.

The bounded generated-Provider test was deliberately added as its own source:

`StaticJIT/AOT/Diagnostics/AngelscriptStaticJITAotGeneratedProviderDiagnosticsTests.cpp`

Its RED run proved the Editor package initially discarded the catalog, then
its two GREEN cases proved Editor emission and Shipping omission:

- `Saved/Tests/typed-aot-generated-provider-diagnostics-red/
  20260816_160119_488_218bff65` — expected `1/2` RED;
- `Saved/Build/typed-aot-generated-provider-diagnostics-green-build/
  20260816_160632_531_877e1bb2` — build PASS;
- `Saved/Tests/typed-aot-generated-provider-diagnostics-green/
  20260816_160646_074_a0258dc7` — `2/2 PASS`.

### Formal-path issue: managed scaffold markers and CRLF

The first formal project Generate stopped because the managed scaffold was
stale. Scaffold then refused to refresh its own `AngelscriptJIT.Build.cs`:
`HasExpectedScaffoldMarker` compared an LF-terminated marker substring against
the checked-out CRLF first line. The fix compares the exact first marker line
after stripping only an optional trailing carriage return; revision and kind
remain strict. The regression lives in the bounded
`StaticJIT/Scaffold/AngelscriptJITScaffoldLineEndingTests.cpp` file.

- `Saved/Tests/typed-aot-scaffold-crlf-red/
  20260816_160937_721_1f6f3e4c` — expected `0/1` RED;
- `Saved/Build/typed-aot-scaffold-crlf-green-build/
  20260816_161024_434_78afcacf` — build PASS;
- `Saved/Tests/typed-aot-scaffold-crlf-green/
  20260816_161045_183_b56a7043` — `1/1 PASS`;
- `Saved/AngelscriptJITRuns/scaffold/
  20260816_161120_404_ed4e3deb` — formal scaffold PASS and refreshed four
  managed shell files;
- `Saved/Build/typed-aot-scaffold-refresh-build/
  20260816_161148_706_f841e0a7` — required full build PASS.

### Formal-path issue: function-artifact property lookup crash

The next formal Generate reached the maintained-fork artifact writer and
crashed after `FindObjectPropIndex` failed to resolve a bytecode property
offset. The upstream-only assertion is compiled out in this configuration, so
the old code dereferenced a null `objProp`. Both missing object type and missing
property now set the writer error and return. Capture therefore reports the
module unsupported and continues instead of terminating the commandlet. The
isolated regression corrupts a compiled property operand and proves
`WriteFunctionArtifact` returns an error without crashing; it lives under
`Cache/` because this is a serializer contract, not an AOT scenario family.

- `Saved/Build/typed-aot-function-artifact-property-failclosed-build/
  20260816_161418_693_721260c2` — implementation build PASS;
- `Saved/Tests/typed-aot-function-artifact-property-failclosed/
  20260816_161438_996_9695c7ae` — first test setup RED; it found only one of
  the maintained fork's two property opcode pairs and did not crash;
- `Saved/Build/typed-aot-function-artifact-property-test-fix-build/
  20260816_161533_524_7541c310` — corrected test build PASS;
- `Saved/Tests/typed-aot-function-artifact-property-failclosed-green/
  20260816_161552_760_d57a3db3` — final `1/1 PASS`.

### Real project output and worktree ownership

The checked-in project `Generated/EditorDevelopment` inventory belongs to the
main checkout's project-path-derived ProviderId. The isolated `V:/` worktree
correctly received a different ProviderId, and the generated-file store
refused to overwrite the foreign owner. No protection was bypassed: the clean
old output was moved recoverably beneath `Saved`, the worktree-specific output
was generated and compiled, and the original output was restored afterwards.
The validated worktree output remains at
`Saved/AngelscriptJITTransient/validated-provider-d68adf88/EditorDevelopment`
for inspection only and is not a commit candidate.

- `Saved/AngelscriptJITRuns/generate-editordevelopment/
  20260816_161730_506_2be80036` — expected owner-mismatch refusal after all
  source capture completed;
- `Saved/AngelscriptJITRuns/typed-aot-generated-provider-formal-generate/
  20260816_162014_772_878ec9f3` — formal Generate PASS, zero errors, ten
  independent AS-module `.jit.cpp` files plus ABI-7 diagnostic tables;
- `Saved/Build/typed-aot-generated-provider-formal-build/
  20260816_162059_322_bdacb638` — all generated project sources compiled and
  linked (`14` UBT actions) PASS.

### Real TestJIT call identity refinement

The first fixed-identity `AngelscriptTestJIT` regeneration then exposed a
typed ABI bug at diagnostic call row zero. The validator required a non-zero
AS `CalleeFunctionKey` for every call. That is correct for `ScriptFunction`,
but `Print` and other UE/C++ `SystemFunction` calls use
`StableTargetKey + ExpectedAbi` and do not own a script-module function key.
The validator now makes the function-key requirement conditional on the
script target kind. The installed diagnostics source owns the focused test:
system-call zero CalleeFunctionKey validates, while changing the same row to
`ScriptFunction` deterministically fails at diagnostic call index zero.

- `Saved/Tests/typed-aot-provider-diagnostic-system-call-red/
  20260816_162546_657_cfee115f` — expected `0/1` RED;
- `Saved/Build/typed-aot-provider-diagnostic-system-call-green-build/
  20260816_162634_198_a1c442d6` — build PASS;
- `Saved/Tests/typed-aot-provider-diagnostic-system-call-green/
  20260816_162647_839_7bad2030` — `1/1 PASS`;
- `Saved/StaticJIT/TestJIT/Commandlet/
  typed-aot-provider-diagnostics-testjit-green_02_generate/
  20260816_162729_485_7ac505c5` — real TestJIT Generate PASS;
- `Saved/Build/typed-aot-provider-diagnostics-testjit-generated-build/
  20260816_162910_208_d987169a` — regenerated TestJIT Provider and all owned
  fixture/differential translation units compiled and linked (`33` actions)
  PASS;
- `Saved/Tests/typed-aot-generated-provider-formal-tests-green/
  20260816_162927_945_44f46a0a` — combined Provider ABI plus partitioned AOT
  Diagnostics `22/22 PASS`.

The current general `AngelscriptStaticJITAotTests.cpp` is still `7057` lines
and `33` methods. New AST JIT tests are prohibited there. Complete existing
families will move only when next touched so the partition does not multiply
expensive isolated Engine startup. Tasks 7.1 and 7.2 remain open until the
installed catalog is represented by the unified dump/command surface and the
formal GameShipping output is verified, rather than treating the synthetic
Shipping omission case as the whole milestone.

## 2026-08-16 — installed Provider diagnostics in the unified dump

`FStaticJITDiagnostics::FSnapshot` schema revision 8 now copies each
Registry-owned optional Provider diagnostic catalog into its owning Provider
record. `as.StaticJIT.DumpDiagnostics` serializes that catalog as
`generationDiagnostics` beside the same Provider's current entries,
references, native call sites, route adoption and execution counters. The
JSON shape is nested for inspection (`function -> backend attempt -> typed
diagnostic -> semantic/call closure`) even though the cross-DLL Provider ABI
remains flat and range-based. Capability bits use a fixed Provider-neutral
name order; structured installed trait fields are numeric, while the existing
artifact-request schema retains its established hexadecimal strings. A
function query removes unrelated diagnostic function rows and leaves the
immutable dependent arrays internal to the snapshot.

The command/serialization regression is deliberately isolated in
`StaticJIT/AOT/Diagnostics/AngelscriptStaticJITAotCommandDiagnosticsTests.cpp`.
It does not create another Engine: it inspects the real installed
`AngelscriptTestJIT` Provider, proves repeat serialization is identical, then
executes `as.StaticJIT.DumpDiagnostics -Output=...` and validates the written
catalog. The legacy no-pointer check was narrowed from the invalid rule "no
`0x` anywhere" to rejecting Win64 pointer-shaped 12-16 digit hexadecimal
values; legitimate trait, route and lifetime bit-mask prose remains visible.

During the RED build, the project module's generated inventory described
nested `.jit.cpp` files that were absent after the previous ownership restore,
so the Provider linked against two missing symbols. The complete previously
validated worktree-specific output was moved back into the project module and
the module-rule timestamp was refreshed so UBT re-enumerated all nested source
files. This was a generated-directory consistency/UBT makefile issue, not a
diagnostics failure; the main workspace was not touched.

Evidence:

- `Saved/Build/typed-aot-command-diagnostics-red-build-03/
  20260816_163654_071_a3626d19` — RED test source build PASS after restoring
  the complete generated inventory;
- `Saved/Tests/typed-aot-command-diagnostics-red/
  20260816_163706_653_faa163a2` — expected `0/1` RED at missing schema/catalog;
- `Saved/Build/typed-aot-command-diagnostics-green-build-02/
  20260816_164052_488_cc9889aa` — implementation build PASS;
- `Saved/Tests/typed-aot-command-diagnostics-green/
  20260816_164109_741_f946c311` — command surface `1/1 PASS`;
- `Saved/Build/typed-aot-diagnostics-schema8-final-build/
  20260816_164916_801_888f1dbc` — final incremental build PASS;
- `Saved/Tests/typed-aot-diagnostics-schema8-final/
  20260816_164936_440_c1e9fe14` — complete partitioned Diagnostics prefix
  `15/15 PASS`.

Tasks 7.1 and 7.2 remain unchecked until Editor-side pre-publication
authority/containment failures and formal GameShipping omission are proven.
## 2026-08-16 — AST JIT/AOT test ownership split continues

The AST JIT/AOT suite now treats one capability family as the normal C++
translation-unit boundary. Large families may split again by observable
scenario, while unrelated tests must not accumulate in a generic catch-all
file. The maintained partition map is
`research/ast-jit-aot-test-partition.md`.

The independent `GenerationFacts` automation class was moved unchanged from
`StaticJIT/AngelscriptStaticJITAotTests.cpp` to
`StaticJIT/AOT/Generation/AngelscriptStaticJITAotGenerationSnapshotTests.cpp`.
Its automation prefix and method name remain stable, and it still creates only
its original single interpreter fixture Engine. The root translation unit fell
from 7057 to 6987 physical lines. `MultiEngine` was deliberately left in place
because it currently reaches the shared fixture through a friend bridge;
extracting it safely requires moving that ownership seam rather than cloning
another Engine setup.

Focused verification:

- source discovery and compile/link: `Saved/Build/typed-aot-test-partition-generation-snapshot/20260816_165529_715_29dfad06/UBT.log`
  (`Module.AngelscriptTest.45.cpp` compiled, `UnrealEditor-AngelscriptTest.dll`
  linked, UBT `Result: Succeeded`);
- refreshed Editor target build:
  `Saved/Build/typed-aot-test-partition-generation-snapshot-03/20260816_165601_377_e45cafae/`
  PASS;
- focused automation:
  `Saved/Tests/typed-aot-test-partition-generation-snapshot/20260816_165753_510_b94fa07c/`
  — `1/1 PASS` for
  `Angelscript.TestModule.StaticJIT.AOT.GenerationFacts`.

### Typed AST JIT root cleanup

Following the explicit request to avoid accumulating AST JIT tests in one
directory or translation unit, the six Typed AST JIT capability files were
moved from `StaticJIT/` into `StaticJIT/TypedASTJIT/`: eligibility,
execution-profile, call-closure, generated-output, native-bridge, and scalar
operation coverage. Their CQTest prefix strings and method names are
unchanged, so focused filters remain stable. The generated-output file is
still large but cohesive; the partition map records the required support seam
and three scenario boundaries for its next extraction instead of duplicating
its HIR/golden helpers now.

Focused compile evidence:

- `Saved/Build/typed-ast-jit-test-folder-partition/` — UBT rediscovered the
  moved sources beneath `StaticJIT/TypedASTJIT/`, compiled the affected
  `AngelscriptTest` unity shards, and linked
  `UnrealEditor-AngelscriptTest.dll`; `Result: Succeeded` in 15.07 seconds.
- The only emitted warning is the pre-existing raw-entry function-pointer
  `reinterpret_cast` in the AOT frame/recursion route test. No test name,
  prefix, fixture lifetime, source content, or generated artifact changed, so
  this ownership-only move uses the focused module compile as its verification
  gate instead of starting four independent Editor test processes.

## 2026-08-16 — task 7.4 provider identity and stable diagnostic source paths

The existing bounded generation-verification session now captures the actual
BytecodeJIT and TypedASTJIT result identity before the isolated Engines are
released. It compares the stable FunctionKey, execution/content hash, debug
hash, ArtifactProfile and EntryAbi hash across the two backends. It also runs
the TypedAST provider generation twice and requires the complete emitted
output to be byte-identical. BackendId remains an ordered diagnostic attempt
field and is not part of any of those execution identities.

The initial post-regeneration test still reported the checked
`Provider.generated.cpp` as stale. A fixed-point experiment proved that the
Provider manifest and owned-file inventory were already byte-identical across
two independent official Generate runs, while only the Provider C++ changed.
Every difference was a random test root beneath
`Saved/Automation/AngelscriptTestJITGeneration/<GUID>/Script`. The unstable
text had entered structured `EligibilitySource`/`ProcessedSource` fields and
the free-form backend-attempt `Detail`; the generated entries and their
runtime identities were not changing.

TypedAST generation diagnostics now resolve a captured source span through
the frozen graph's authoritative module descriptors and code sections. They
prefer the stable virtual path (for these fixtures,
`/Angelscript/Game/<file>.as`), then the relative filename, and use the raw
section only when no authoritative mapping exists. The same normalization is
applied to the source prefix inside the human-readable eligibility detail.
No persistent path, hash or dispatch decision depends on the process-local
test directory.

One validation trap was recorded: a module-filtered test build rebuilt the
Runtime object/library but did not relink
`UnrealEditor-AngelscriptRuntime.dll`, so the following commandlet still loaded
the old implementation. The final verification uses full incremental Editor
builds whenever a Runtime implementation change must be consumed by a fresh
commandlet process.

Evidence:

- first official regeneration:
  `Saved/Commandlet/typed-aot-provider-identity-regenerate/20260816_172907_144_8cdcf3f2/`
  — PASS;
- first regenerated-source build:
  `Saved/Build/typed-aot-provider-identity-generated-build/20260816_173108_054_885788a3/`
  — PASS;
- expected stale-output RED:
  `Saved/Tests/typed-aot-provider-identity-green-02/20260816_173138_073_0da19eca/`
  — `0/1`, before the identity assertions;
- fixed-point second Generate:
  `Saved/Commandlet/typed-aot-provider-identity-fixedpoint-cycle2/20260816_173523_153_343f1624/`
  — manifest and owned inventory identical; Provider C++ differed only by
  random diagnostic source roots. The cycle-one comparison copy is beneath
  `Saved/Diagnostics/typed-aot-provider-fixedpoint-cycle1/`;
- final Runtime relink:
  `Saved/Build/typed-aot-stable-diagnostic-detail-full-relink/20260816_174424_363_4cdc8019/`
  — PASS, including `UnrealEditor-AngelscriptRuntime.dll`;
- final official regeneration:
  `Saved/Commandlet/typed-aot-stable-diagnostic-detail-regenerate/20260816_174538_713_59e12d1d/`
  — PASS, and `Provider.generated.cpp` contains zero random test-root or
  drive-letter source paths;
- generated Provider build:
  `Saved/Build/typed-aot-provider-identity-final-generated-build/20260816_174720_312_a9b7d213/`
  — PASS (`4` actions, generated Provider compiled and linked);
- exact two-run identity/determinism automation:
  `Saved/Tests/typed-aot-provider-identity-green-03/20260816_174750_272_ac8d5a1c/`
  — `1/1 PASS`.

Task 7.4 is complete. Tasks 7.1 and 7.2 remain open for the explicitly scoped
Editor-side pre-publication authority/containment failures and formal
GameShipping omission proof; this identity result does not mark those broader
diagnostic tasks complete.

## 2026-08-16 — tasks 7.1/7.2 complete: pre-publication failures and formal Shipping exclusion

The final diagnostics audit found that production code had already advanced
beyond the earlier attachment checkpoint. `FStaticJITDiagnostics::FSnapshot`
is schema revision 9. The Editor refresh service reports a real
`AuthoritativeEngineStale` failure before preparation/generation when its
captured primary source authority is no longer current. Its containment seam
also propagates a typed `GenerationContainmentFailure` without invoking
generation, backend work, Provider registration, or route publication. These
records belong to the generation result only and are not fabricated as loaded
Provider state.

Focused evidence:

- `Saved/Tests/typed-aot-task7-diagnostics-refresh-audit/
  20260816_180019_246_0b5971a6/` — combined bounded AOT Diagnostics and real
  RefreshService prefixes `26/26 PASS`.

Formal GameShipping verification used the official commandlet and a real
Shipping target. The initial direct invocation accidentally placed both values
inside the `-Mode` argument; the next correctly formed attempt was expectedly
refused because the existing GameShipping directory carried a different
checkout's Provider owner identity. That foreign output was moved recoverably
from `Source/AngelscriptJIT/Generated/GameShipping` to
`Saved/AngelscriptJITTransient/task7-gameshipping-foreign-owner-20260816_180337`
and was not deleted or committed.

Final evidence:

- `Saved/Commandlet/typed-aot-task7-gameshipping-generate-04/
  20260816_180344_909_9f542042/` — official GameShipping Generate PASS, exit
  code zero, eight module `.jit.cpp` units plus Provider/inventory/manifest;
- recursive generated-source scan — no Provider diagnostic table symbols,
  diagnostic JSON field names, fallback/source-provenance vocabulary, or typed
  diagnostic tokens in the GameShipping profile;
- `Saved/Build/typed-aot-task7-gameshipping-build/
  20260816_180500_724_6d8639ac/` — `AngelscriptProject Win64 Shipping` PASS,
  104 actions, including `Provider.generated.cpp`, every GameShipping JIT unit,
  final executable link and target metadata; exit code zero in 249.18 seconds.

The XGE build paused visibly after action 101 while the local final executable
link completed, then emitted actions 102-104 and metadata normally. The fresh
executable timestamp and final UBT `Result: Succeeded` show this was link
latency rather than a deadlock. Tasks 7.1 and 7.2 are now checked; task 7.4 was
already complete. Provider ABI/mixed-backend publication remains the next
independent task-7 audit.

## 2026-08-16 — tasks 7.3/7.5 complete: landed Provider ABI and mixed per-function publication

The provider integration audit confirmed that the complete multi-provider
contract is already available from plugin commit `3d6f231`. Typed semantic AOT
uses Provider ABI revision 7, the existing stable ModuleKey/FunctionKey and
content/profile/Entry-ABI identities, and the existing backend-neutral
VM/Raw/Parms entry tuple. No TypedAST-only Provider type, Registry, refresh
service, route snapshot, Live Coding hook, or temporary compatibility API was
added.

Following the AST JIT test-partition rule, the new proof is a bounded file at
`StaticJIT/AOT/Generation/AngelscriptStaticJITAotMixedBackendPublicationTests.cpp`
rather than another method in the roughly seven-thousand-line AOT translation
unit. It reads the already installed TestJIT catalog and creates no Engine. It
proves that diagnostic FunctionKeys map one-to-one to the backend-neutral
entries, then finds a single AS ModuleKey containing both a TypedASTJIT
function with VM/Raw/Parms entries and a BytecodeJIT function with its own VM
entry. The existing shared-fixture UASFunctionDispatch family remains the
runtime proof, including the generated-WorldContext function that safely
falls back to Bytecode and omits Parms.

Evidence:

- `Saved/Build/typed-aot-mixed-provider-publication/
  20260816_181918_358_f8f3a8cc/` — incremental Editor build PASS in 15.27s;
  the added file compiled in adaptive non-unity;
- `Saved/Tests/typed-aot-mixed-provider-publication/
  20260816_181942_055_1b02f904/` — mixed Provider publication `1/1 PASS`;
- `Saved/Tests/typed-aot-mixed-provider-vm-fallback/
  20260816_182017_685_ad09d0ae/` — UASFunctionDispatch `7/7 PASS`.

Tasks 7.3 and 7.5 are complete. Task 7.6 is resolved as not needed because the
real ABI is present; no temporary long-lived Provider API was created.

## 2026-08-16 — AST JIT test ownership rule expanded to compiler HIR

The capability-owned test partition now applies to both StaticJIT/AOT and the
maintained-compiler HIR surface. Existing TypedASTJIT tests are already grouped
beneath `StaticJIT/TypedASTJIT/`, while new task-2 expression capture and
`asCExprContext` propagation coverage will start beneath
`AngelScriptSDK/Compiler/TypedSemanticIR/` instead of extending the existing
large `AngelscriptNativeTypedSemanticIRTests.cpp`.

The rule is semantic rather than a raw line-count split: one `.cpp` owns one
observable capability family. Expensive native Engine/module/snapshot setup is
extracted only when genuinely shared, and must not be duplicated merely to
make translation units smaller. Existing large files are migrated family by
family when touched; automation names remain stable, mutable state is reset per
method, and adaptive non-unity compilation must continue to expose every
translation unit's direct dependencies.

## 2026-08-16 — tasks 2.1/2.2 complete: bounded expression capture and final-type propagation

The task-2 expression matrix now lives in capability-owned translation units
beneath `AngelScriptSDK/Compiler/TypedSemanticIR/`. The existing
`ExpressionContextCopyMergeAndClearPropagateTypedIdentity` method moved out of
the large legacy compiler HIR file without changing its automation path, while
new expression-propagation and operator files cover exact leaves, operators,
explicit/implicit conversion, void/value call discard, call initialization,
and final compiler-selected types. Each method owns only one native Engine and
Module for its capability family; no cross-file global Engine fixture was
introduced.

The first expanded run was a useful RED: `24/25 PASS`, with a local
`float32` initializer retaining the pre-conversion parameter symbol. A central
`ImplicitConversion` completion seam now emits scalar conversion HIR after the
maintained compiler has selected its final type, and the old math-only special
case was removed so return, comparison, bitwise, call-argument, local, and
power conversions share one rule. `CompileInitialization` retains the original
member-level initializer identity, then accepts an optional post-conversion
identity from `DoAssignment` only when it belongs to the current function
arena. This timing is after final typing but before bytecode merge consumes the
rvalue context. Local-declaration capture now emits a precise ownership
diagnostic containing local name, expression ID, arena size, and processed
source position.

During the first adaptive non-unity build, three existing Conformance files
were found to depend on a sibling unity unit for
`AngelscriptNativeCaseTestSupport.h`. Direct includes were added so every
translation unit is independently compilable. No production behavior changed
for this build-hermeticity correction.

RED/GREEN evidence:

- `Saved/Tests/typed-semantic-expression-red-02/20260816_184027_205_8f819e4f/`
  — initial bounded matrix `24/25`, proving the stale implicit-return identity;
- `Saved/Tests/typed-semantic-expression-green/20260816_184538_932_e79af466/`
  — expanded RED isolated the remaining converted-local initializer;
- `Saved/Build/typed-semantic-member-capture-green/20260816_190041_388_41618bdf/`
  — final incremental Editor build PASS;
- `Saved/Tests/typed-semantic-member-capture-exact/20260816_190058_216_f949aeeb/`
  — the three timing-sensitive cases `3/3 PASS`;
- `Saved/Tests/typed-semantic-member-capture-group/20260816_190136_498_3c67afc6/`
  — bounded TypedSemanticIR prefix `25/25 PASS`;
- `Saved/Tests/typed-semantic-power-regression/20260816_190223_465_77bdf504/`
  — maintained Power matrix `3/3 PASS`.

Tasks 2.1 and 2.2 are now checked. The next compiler work remains the typed
unsupported/synthesized/provisional-publication group (2.5, 2.8, 2.9), not a
broader test-file merge.

## 2026-08-16 — task 2.5 slice 1: object-property fallback identity GREEN

The first unsupported-expression slice was added in its own capability-owned
translation unit:
`AngelScriptSDK/Compiler/TypedSemanticIR/AngelscriptNativeTypedSemanticIRUnsupportedTests.cpp`.
The executable fixture builds once with capture off and once with capture on,
proves both functions contain bytecode, executes both VM routes to the same
result, then inspects only the capture-on HIR.

The final RED was intentional and source-local: valid `Carrier.Value` access
degraded to the receiver symbol instead of publishing a `PropertyAccess`
marker. Production now appends one unsupported property node after the
maintained compiler has resolved the property and final result type. The node
owns the previously captured receiver expression ID, pointer-free target text
such as `FTypedPropertyCarrier::Value`, exact `asCDataType`, and processed
source span. The verifier requires one earlier receiver and non-empty resolved
target detail; the normalized dump includes that target. No bytecode decision,
property offset, object address, Engine pointer, or executable field route is
stored in HIR.

Adaptive non-unity repartition also exposed six existing SDK test sources that
used case/language-case helpers through sibling unity includes. Each now
includes its direct support header. These are build-hermeticity corrections
caused by the requested test partition, not runtime behavior changes.

RED/GREEN evidence:

- `Saved/Tests/typed-semantic-unsupported-property-red-final/
  20260816_191905_783_d5b87a9d/` — exact case `0/1`, failing only because the
  direct property marker was absent after bytecode and VM checks passed;
- `Saved/Build/typed-semantic-unsupported-property-green/
  20260816_192110_417_e6027242/` — Editor build PASS;
- `Saved/Tests/typed-semantic-unsupported-property-green-exact/
  20260816_192147_253_90798301/` — exact property case `1/1 PASS`;
- `Saved/Tests/typed-semantic-unsupported-property-green-group/
  20260816_192232_011_4702f37b/` — complete bounded HIR prefix `26/26 PASS`.

Task 2.5 remains open: object/implicit-member, container,
construction/lifetime, lambda, cleanup, suspend, and source-level
try/catch/rethrow rejection coverage still need their own RED/GREEN rows in
this same unsupported-capability file.

## 2026-08-16 — task 2.5 slices 2/3 and compiler-HIR partition refinement

The unsupported matrix now follows the same capability-owned translation-unit
rule as the larger AST JIT/AOT suite. The former generic unsupported file was
split into dedicated Container and Property owners. Managed construction and
cleanup have a Lifetime owner, and rejected future syntax has a Language
Boundary owner. The bounded owners at this checkpoint were:

- `AngelscriptNativeTypedSemanticIRExpressionPropagationTests.cpp`;
- `AngelscriptNativeTypedSemanticIROperatorTests.cpp`;
- `AngelscriptNativeTypedSemanticIRUnsupportedContainerTests.cpp`;
- `AngelscriptNativeTypedSemanticIRUnsupportedPropertyTests.cpp`;
- `AngelscriptNativeTypedSemanticIRUnsupportedLifetimeTests.cpp`;
- `AngelscriptNativeTypedSemanticIRUnsupportedLanguageBoundaryTests.cpp`.

No shared process/global Engine was introduced. Container, Property and
Lifetime each retain only the Engine/module pair required for capture-off/on
comparison. The language-boundary method creates one Engine per capture policy
and reuses it across five rejected syntax cases, so file partitioning does not
multiply startup once per case. The expression-propagation owner was
subsequently split when it crossed the recorded review trigger; see the later
AST JIT test ownership checkpoint.

Container RED/GREEN:

- the first ref/no-count fake `TArray` fixture was invalid because the type
  could not be instantiated; it is not feature RED evidence;
- the valid POD value-type fixture failed exactly because only the generic
  `Reference` marker existed at
  `Saved/Tests/typed-semantic-unsupported-container-red-valid-fixture/
  20260816_193213_605_f476704f/`;
- production now recognizes maintained array types and the stable
  `TArray`/`TSet`/`TMap` names, emits an independent typed `Container` marker,
  and verifies its exact symbol/type shape;
- exact GREEN is
  `Saved/Tests/typed-semantic-unsupported-container-green-exact/
  20260816_193340_268_e387c385/` (`1/1 PASS`).

Lifetime RED/GREEN:

- valid managed-class construction initially left the local initializer
  expression invalid at
  `Saved/Tests/typed-semantic-unsupported-lifetime-red-exact/
  20260816_193641_077_1561f94d/`;
- both direct construction nodes and the function-call-shaped type-constructor
  route now emit `ConstructionOrLifetime` after type resolution;
- final compiler variable ownership inspection emits `ExceptionCleanup`, sets
  `hasExceptionCleanup`, and deliberately leaves the cleanup plan unverified;
- build and exact GREEN are
  `Saved/Build/typed-semantic-unsupported-lifetime-green-02/
  20260816_194010_893_ce6f35c2/` and
  `Saved/Tests/typed-semantic-unsupported-lifetime-green-02-exact/
  20260816_194025_651_3ae903ba/` (`1/1 PASS`).

Lambda/future-language characterization:

- several early failures were invalid fixtures rather than feature RED:
  script-level `funcdef`, explicit `@`, funcdef local/value parameter, and a
  system const-reference target are all outside the current reachable
  conversion surface;
- the maintained tokenizer explicitly disables `@`, while the existing
  Lambda 2.38 tests remain Disabled future coverage;
- no production parser/language rule was expanded to satisfy HIR tests;
- the final bounded test proves capture on/off both reject future Lambda,
  try/catch, incomplete handler placement and bare rethrow, retain diagnostics,
  publish no `Entry`, and discard cleanly at
  `Saved/Tests/typed-semantic-language-boundary-green-exact/
  20260816_195643_640_631dc928/` (`1/1 PASS`).

Partition verification:

- `Saved/Build/typed-semantic-test-partition-container-property/
  20260816_195958_614_9b8e9a0f/` — build PASS after UBT source discovery;
- `Saved/Tests/typed-semantic-test-partition-group/
  20260816_200019_388_815906bb/` — complete `TypedSemanticIR` prefix
  `29/29 PASS`.

Task 2.5 remains unchecked. Implicit object/member access, suspend state,
dormant compiler exception regions and a reachable/deterministic Lambda or
synthesized-function disposition still need closure.

### Task 2.5 implicit member receiver slice — RED/GREEN

The implicit-member scenario is kept in its own capability-owned translation
unit,
`AngelscriptNativeTypedSemanticIRUnsupportedImplicitMemberTests.cpp`, rather
than enlarging either the direct-property or generic compiler HIR file. Its
production mutation is specific: removing the `CompileVariableAccess()`
receiver capture makes valid bytecode and VM execution continue to work but
prevents the capture-on method from publishing HIR.

Root cause: direct `Receiver.Property` already arrived at the postfix-property
hook with a captured symbol. Explicit `this` and unqualified members instead
resolve through `CompileVariableAccess()`; that branch set VM stack/type state
but no typed expression. Consequently `this.Value` passed an invalid receiver
ID to the existing property-marker hook and invalidated the provisional HIR,
while bare `Value` had no receiver/property identity at all.

Production now constructs a fresh function-owned receiver-symbol expression
for each source access, wraps it in `Unsupported/ObjectAccess` with
`<ResolvedType>::this`, and makes the final `Unsupported/PropertyAccess`
consume that object-access expression. Both spellings therefore retain the
same normalized header receiver while keeping independent source spans and
evaluation nodes. The sidecar remains write-only relative to bytecode.

Evidence:

- first build attempt correctly failed only because maintained `asCArray`
  has no C++ range-for adapter; the test was corrected to indexed traversal
  before accepting any RED;
- the first attempted exact prefix matched zero tests because CQTest includes
  the class component in its full path; zero tests were rejected as evidence;
- valid RED:
  `Saved/Tests/typed-semantic-implicit-member-red-valid/
  20260816_201100_933_57a92da2/` (`0/1`, missing HIR only);
- build GREEN:
  `Saved/Build/typed-semantic-implicit-member-green/
  20260816_201413_727_d4816e3e/`;
- exact GREEN:
  `Saved/Tests/typed-semantic-implicit-member-green-exact/
  20260816_201434_191_cee391f1/` (`1/1 PASS`);
- bounded regression:
  `Saved/Tests/typed-semantic-implicit-member-green-group/
  20260816_201513_804_07887686/` (`30/30 PASS`).

Task 2.5 remains open only for suspend state, dormant compiler exception-region
metadata, and a reachable deterministic lambda/compiler-synthesized
disposition.
## AST JIT test ownership rule clarified

- AST JIT and compiler-HIR tests remain organized by observable capability,
  with one narrowly named `.cpp` owner rather than a growing catch-all file.
- A translation unit crossing roughly 500 physical lines or five test methods
  now triggers a partition review. This is a review heuristic, not a reason to
  duplicate expensive Engine setup or split cohesive helper code blindly.
- The former 581-line expression-propagation owner has been split into
  `ExpressionContext`, `ExpressionConversion`, and `ResolvedCall` files while
  preserving the maintained Automation prefix and method names. The largest
  current compiler-HIR capability file is 380 physical lines, and every file
  owns at most two test methods.
- New unsupported categories continue to receive independent files; the
  implicit-member and generated-lifecycle regressions already follow this
  rule.
- The detailed directory/fixture boundary is recorded in
  `research/ast-jit-aot-test-partition.md`.

### Expression propagation capability split — verified

The former `AngelscriptNativeTypedSemanticIRExpressionPropagationTests.cpp`
was migrated as three complete capability families without changing the
maintained Automation prefix or method names:

- `AngelscriptNativeTypedSemanticIRExpressionContextTests.cpp` owns
  expression-context copy/merge/clear identity;
- `AngelscriptNativeTypedSemanticIRExpressionConversionTests.cpp` owns
  compiler-selected conversions and final compiler types;
- `AngelscriptNativeTypedSemanticIRResolvedCallTests.cpp` owns discarded and
  local-initializer resolved calls.

The split keeps each raw SDK scenario's case-owned Engine/module lifetime and
keeps narrow HIR lookup helpers class-private. It introduces no global fixture
or cross-file mutable state. Current compiler-HIR capability owners contain at
most two `TEST_METHOD` cases; the largest is 380 physical lines.

Verification:

- `Saved/Build/typed-semantic-test-capability-partition/
  20260816_204235_037_0a9f87ff/` — Editor build PASS; UBT invalidated source
  discovery for the added translation units and linked `AngelscriptTest`;
- `Saved/Tests/typed-semantic-test-capability-partition/
  20260816_204253_331_0374e30f/` — complete
  `Angelscript.TestModule.AngelScriptSDK.Compiler.TypedSemanticIR` prefix
  `32/32 PASS`, zero failed and skipped.

## Task 2.5/2.9 generated-function disposition — RED/GREEN

The maintained parser accepts `__generated` as a trailing function attribute,
and the builder freezes it as `asTRAIT_GENERATED_FUNCTION`. Before this slice,
capture published an otherwise complete scalar HIR but gave the emitter no
typed reason to reject a compiler/preprocessor-generated function.

The dedicated
`AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedFunctionTests.cpp`
owner compiles the same valid generated-trait function with capture off/on,
compares bytecode bytes, executes both through the VM, and inspects the HIR.
The accepted RED was `0/1` solely because the fallback marker was absent.
Production now adds exactly one pointer-free
`Unsupported/CompilerSynthesizedFunction` marker during the provisional
transaction and verifies that it is backed by the generated trait with a
stable `__generated` disposition and no executable payload.

Evidence:

- RED: `Saved/Tests/typed-semantic-synthesized-red/
  20260816_202142_156_d1697d3d/` (`0/1`, missing marker only);
- build GREEN: `Saved/Build/typed-semantic-synthesized-green/
  20260816_202237_297_55b8db73/`;
- exact GREEN: `Saved/Tests/typed-semantic-synthesized-green-exact/
  20260816_202251_976_659817a6/` (`1/1 PASS`);
- bounded regression: `Saved/Tests/typed-semantic-synthesized-green-group/
  20260816_202329_972_471d56fc/` (`31/31 PASS`).

Tasks 2.5 and 2.9 remain open for the separately reachable suspend/exception
region/lambda boundary and the complete constructor/destructor/factory/list
factory/accessor disposition table.

## Task 2.9 synthesized lifecycle paths and immediate test split

Automatic default constructors, default destructors and factories are emitted
by separate compiler entry points that never create the normal source-body HIR
builder. Capture previously exposed neither HIR nor a reason. Production now
records stable capture-only no-HIR dispositions from those three entry points;
capture-off stays empty and generated bytecode is untouched.

The lifecycle fixture uses a nested script-class member so the builder must
generate all three functions. It verifies their non-empty bytecode and stable
diagnostics, then executes capture-off/on construction and destruction with
the same result. Constructor/factory and default-destructor each had their own
accepted RED before the corresponding production hook.

Applying the test-ownership rule immediately, the 356-line synthesized file
was split before adding the destructor matrix:

- `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedFunctionTests.cpp`
  owns the explicit `__generated` marker contract;
- `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLifecycleTests.cpp`
  owns default constructor/destructor/factory disposition and shares one
  Engine pair across those lifecycle rows.

Evidence:

- constructor/factory RED: `Saved/Tests/
  typed-semantic-synthesized-lifecycle-red/20260816_202654_360_d187e1ea/`;
- constructor/factory GREEN: `Saved/Build/
  typed-semantic-synthesized-lifecycle-green/20260816_202752_680_8d7c0815/`
  and `Saved/Tests/typed-semantic-synthesized-lifecycle-green-exact/
  20260816_202807_074_da262368/` (`1/1 PASS`);
- destructor RED: `Saved/Tests/typed-semantic-synthesized-destructor-red/
  20260816_203111_451_4d67f1e6/`;
- destructor GREEN: `Saved/Build/typed-semantic-synthesized-destructor-green/
  20260816_203155_616_2d3be778/` and
  `Saved/Tests/typed-semantic-synthesized-destructor-green-exact/
  20260816_203209_945_ea8012a1/` (`1/1 PASS`);
- bounded regression: `Saved/Tests/
  typed-semantic-synthesized-lifecycle-green-group/
  20260816_203247_178_c5d5b63b/` (`32/32 PASS`).

Task 2.9 remains open for list factory/accessor/lambda and the final exhaustive
artifact-invocation disposition table.

## Tasks 2.17 and 2.21 processed/authored/generated source provenance

Source provenance is now transported from the UE preprocessor through the
fork-private script-section handoff into compiler-owned Typed Semantic HIR and
Typed AOT diagnostics. Processed UTF-8 coordinates remain mandatory;
authored/generated origins are independent optional tuples and diagnostics do
not relabel processed positions.

The real Asset + Subsystem HIR dump exposed two integration bugs rather than a
test-only gap. HIR normalization assumed the old adjacency around
`functionId`, so it now normalizes an exact token for ResolvedCall and
CallRewrite and the dump schema is revision 2. LiteralAsset preprocessing was
correct, but the generated initializer parameter used the whole function span
and crossed into the authored body. The compiler now records each parameter's
own identifier token; strict provenance containment remains unchanged.

Focused results are SourceProvenance `5/5`, Preprocessor `1/1`, AOT diagnostic
`1/1`, HIR Dump Commandlet `5/5`, all PASS. The required broad gates are
Compiler `184/184 PASS` at `Saved/Tests/semantic-ir-capture/
20260817_025953_549_4bcd2ccd/` and Standalone `20/20 PASS` at
`Saved/StandaloneTests/semantic-ir-standalone_01_Standalone/
20260817_030036_496_b5f2e697/`. The current Standalone count includes the new
TypedSemanticIR CTest and therefore supersedes the older 19-test baseline for
this worktree. Full root-cause and RED/GREEN evidence is in
`research/task-2-17-source-provenance.md`. Tasks 2.17 and 2.21 are complete.

## 2026-08-17 — Task 2.16 stable call targets and body ownership

Compiler-owned HIR now distinguishes concrete script functions, registered
system functions, imported signature slots and shared/external body ownership.
Imported capture records the maintained `FUNC_IMPORTED` slot, source module and
canonical signature but never reads mutable `sBindInfo::boundFunctionId`.
Bind/rebind/unbind therefore alter VM execution while the verified HIR and dump
remain byte-stable.

The compiler tests are partitioned beneath
`AngelScriptSDK/Compiler/TypedSemanticIR/CallTargets/`: imported lifecycle and
body-ownership scenarios have separate `.cpp` owners and share one narrow
support header. The maintained parser's shared/external tokens remain disabled,
so the body-ownership test uses `CompileFunction(..., asCOMP_ADD_TO_MODULE)` and
the exact module arrays consumed by production rather than advertising unsupported
public syntax.

Standalone found two real include-boundary issues and one incremental-link
hazard. `as_typed_semantic_ir.cpp` now directly includes `as_typeinfo.h`; a
Standalone compat header preserves the old VM-entry behavior without importing
UE Runtime; the SemanticObserver test retains failure-only verifier/HIR dump
diagnostics. The first relink and a no-source-change repeat both passed `20/20`.

Final evidence: focused `2/2`, complete HIR `57/57`, consumer `30/30 + 25/25`,
Standalone `20/20` twice, and final UE build 4/4 actions. Full paths, RED stages,
fixture constraints and the MSBuild `MSB8028` observation are recorded in
`research/task-2-16-call-target-and-body-ownership.md`. Task 2.16 is complete.

## Task 2.13 authoritative evaluation order — RED/GREEN

The maintained eager-expression runtime suite is now the direct oracle for
Typed Semantic HIR evaluation. Calls, constructors, indexes and call/member
chains retain reverse final-formal eager order for 2/3/8 operands; binary
expressions, assignment/compound RHS graphs and nested casts retain their
left-to-right operand order. Assignment nodes separately state value before
the one-evaluation target/store.

`asSTypedSemanticExpression::evaluationSteps` is the complete authority and
records role, expression, formal parameter and source argument ordinal. The
older `evaluationSequence` remains only a per-binding compatibility projection.
Independent instance/index receivers are explicit final steps; a mixin
receiver aliases formal zero exactly once. Selected constructor calls remain
inspectable beneath the existing fail-closed construction/lifetime marker.
Verifier, deterministic dump, call-closure traversal and the emitter consume
or validate the same steps.

Tests are capability-owned beneath `TypedSemanticIR/EvaluationOrder/`: ordinary
calls, constructor/index calls, chains and non-call expressions have separate
single-method `.cpp` owners plus one narrow graph-query support header. The RED
build failed on the absent model fields and also exposed an old adaptive-unity
namespace leak in `AngelscriptNativeExceptionRecoveryTests.cpp`; that file now
imports its used helper in the private builder scope.

Evidence:

- RED: `Saved/Build/typed-semantic-task213-evaluation-red/
  20260817_003850_876_40f78841/Build.log`;
- build: `Saved/Build/typed-semantic-task213-evaluation-green-build1/
  20260817_005137_850_5ce8a20f/` — PASS;
- focused: `Saved/Tests/typed-semantic-task213-evaluation-focused1/
  20260817_005218_200_e8238afb/` — `4/4 PASS`;
- complete HIR: `Saved/Tests/typed-semantic-task213-full-hir1/
  20260817_005255_252_231d452a/` — `53/53 PASS`;
- eligibility/call closure: `Saved/Tests/
  typed-semantic-task213-eligibility-closure1/
  20260817_005343_275_d96c8eb5/` — `30/30 PASS`;
- generated output: `Saved/Tests/typed-semantic-task213-generated-output1/
  20260817_005419_007_62c8e372/` — `25/25 PASS`.

The detailed oracle matrix, receiver rules, verifier invariants and follow-on
boundary are recorded in `research/task-2-13-evaluation-order.md`.

## 2026-08-17 — task 2.12 final call rewrites and native ABI GREEN

The maintained compiler now publishes executable `ResolvedCall` nodes only for
the final `CompileCalls` disposition. `CompileOutEntirely`,
`ReplaceWithFirstParam`, and `CompileOutAsMethodChain` publish non-executable
`CallRewrite` nodes containing only their final void/value/receiver semantics
and diagnostic target provenance. TypedASTJIT consumes those nodes without
reintroducing a target call.

Final call operands now carry parallel formal binding, origin, and evaluation
arrays. Host-hidden arguments and receiver aliases remain distinct from AS
visible/default operands. System targets additionally carry a pointer-free
native ABI requirements record; script calls must keep it empty. The verifier,
normalized dump, eligibility/analyzer and emitter were updated together.

Tests are capability-owned beneath `TypedSemanticIR/CallRewrites/` and
`TypedSemanticIR/CallMetadata/`. The affected regression pass also exposed old
synthetic fixtures that violated already-strict unsupported/exception-region
shapes and stale generated-output goldens for the previously landed binary
evaluation-order and checked-power fixes. Fixtures and goldens were aligned to
the authoritative contracts; production validation was not weakened.

Fresh evidence:

- build `Saved/Build/typed-semantic-task212-call-green-build/
  20260817_000551_801_742bd84d/` — PASS;
- focused compiler call partition `Saved/Tests/
  typed-semantic-task212-call-green/20260817_000630_588_5f596b29/` —
  `3/3 PASS`;
- complete compiler HIR `Saved/Tests/typed-semantic-task212-full-green/
  20260817_000711_876_48b83539/` — `49/49 PASS`;
- affected eligibility/call closure `Saved/Tests/
  typed-semantic-task212-staticjit-eligibility-green2/
  20260817_001720_443_e192105d/` — `30/30 PASS`;
- affected generated output `Saved/Tests/
  typed-semantic-task212-staticjit-generated-output-green/
  20260817_002141_574_d899db91/` — `25/25 PASS`;
- final affected build `Saved/Build/
  typed-semantic-task212-generated-golden-build/
  20260817_002121_636_34122258/` — PASS.

Detailed roots, RED evidence and remaining task boundaries are recorded in
`research/task-2-12-call-rewrites-and-native-abi.md`. Task 2.12 is complete;
task 2.13 is the next compiler-HIR capture task.

## Task 2.14 argument provenance — RED/GREEN

Resolved-call HIR now separates caller source origin, final formal binding and
evaluation order. `SourcePositional`, `SourceNamed`, `Default`, `HostHidden`
and receiver-alias records carry a processed span; default/hidden records also
retain exact callee/function/formal/canonical-expression provenance. The old
origin/ordinal arrays remain checked compatibility projections, while the new
provenance array is authoritative and fail-closed.

Default-expression invalidation continues through the compiler's existing
`Signature` artifact dependency. The focused HIR test observes exactly one
such dependency and the existing Hot Reload classification still suggests a
full reload after the default expression changes. No parallel HIR cache edge
was introduced.

Evidence: clean build PASS at `Saved/Build/
typed-semantic-task214-argument-origin-green-build2/
20260817_011658_948_e5d93963/`; focused `2/2 PASS`, hidden `1/1 PASS`, complete
TypedSemanticIR `55/55 PASS`, Hot Reload `1/1 PASS`, Eligibility/CallClosure
`30/30 PASS`, and GeneratedOutput `25/25 PASS`. The initial complete HIR run
was `54/55` only because a fail-closed mixin negative expected the older broad
diagnostic; it now expects the new exact `InvalidArgumentProvenance` category.
Full design and paths are in `research/task-2-14-argument-provenance.md`.

## Task 2.11 mixin receiver/formal mapping — RED/GREEN

Real method-syntax mixin capture now reuses the maintained compiler's final
`args[0]` expression as both the dedicated source receiver and effective
formal-zero operand. It is not cloned or re-evaluated. The resolved-call
verifier rejects any receiver/operand alias that is duplicated or maps to a
formal other than zero. Ordinary instance receivers remain independent of
formal operands, and `external_implicit_this` remains a separate header kind.

Tests are partitioned beneath `TypedSemanticIR/Mixin/`: one owner proves the
real call, VM evaluation oracle, named/default/formal mapping and verifier
corruption; one owner proves free-call remains rejected with capture off/on.
The first build also exposed an old Adaptive Unity dependency in the unrelated
DirectionDefaults test; adding its missing direct language-case support include
restored independent compilation.

Evidence:

- invalid infrastructure RED: `Saved/Build/
  typed-semantic-task211-mixin-red-build/20260816_232206_390_1fafc9e9/`;
- valid feature RED: `Saved/Tests/typed-semantic-task211-mixin-red/
  20260816_232827_409_7c5cbfeb/` — `1/2 PASS`, exact missing-receiver failure;
- GREEN build: `Saved/Build/typed-semantic-task211-mixin-green-build/
  20260816_233005_894_65dd7140/` — PASS;
- focused GREEN: `Saved/Tests/typed-semantic-task211-mixin-green/
  20260816_233019_313_eb823903/` — `2/2 PASS`;
- bounded regression: `Saved/Tests/typed-semantic-task211-regression/
  20260816_233103_970_a4b191c8/` — `46/46 PASS`, zero failed/skipped.

Task 2.11 is checked complete. Full call-rewrite/source-role/default-origin
coverage remains intentionally owned by tasks 2.12–2.14.

## 2026-08-16 — Task 2.10 `external_implicit_this` receiver/call capture

Task 2.10 is complete. The compiler-owned HIR now retains a dedicated resolved
call receiver expression without moving receiver parameter zero into, or out
of, the ordinary formal operand list. Effective receiver capture is propagated
through explicit `this`, unqualified fields, the maintained property-accessor
path and implicit method calls. Missing or primitive receiver parameter zero
keeps existing bytecode/frontend policy but discards the HIR transaction with
stable `InvalidEffectiveReceiver` diagnostics.

Tests were added as three capability-owned `.cpp` files plus one narrow support
header under `TypedSemanticIR/ExternalImplicitThis/`. Investigation corrected
two fixture mistakes rather than changing production language behavior: the
removed script `property` decorator was replaced by the explicit mode-2 `GetX`
accessor path, and a reference script-class receiver was changed from a
reference-to-handle to the real handle-by-value ABI. Cross-Engine bytecode
comparison now normalizes only documented Engine-local pointer words.

Verification: build PASS; focused `3/3 PASS`; complete TypedSemanticIR
`44/44 PASS`. Exact paths and root-cause evidence are recorded in
`research/task-2-10-external-implicit-this.md`.

## 2026-08-16 — task 2.7 capture/archive parity checkpoint

Task 2.7 now owns two focused translation units rather than extending the
large historical TypedSemanticIR test: `CaptureParity` covers capture-on/off
bytecode, metadata, traits/signature and VM behavior across external-this,
mixin, hidden/default and compile-out fixtures; `ArchiveIsolation` covers exact
`SaveByteCode`, current Cache V2 `WriteFunctionArtifact`, bytecode-only restore,
absent restored HIR and restored VM behavior.

The first parity RED exposed a real compiler-sidecar gap. The authoritative
no-node default-construction path emitted ordinary VM construction for
`FParityCounter Counter;` but transferred no initializer expression, so the
strict HIR verifier rejected the local declaration. The repair attaches the
existing `ConstructionOrLifetime` fallback only for the actual non-handle,
non-funcdef object default-construction path; it changes no VM bytecode and
does not weaken verification. The complex call-rewrite entry is not required
to publish complete HIR before tasks 2.10-2.14; an independent representable
probe proves capture is genuinely enabled while the complex entry proves
non-interference and safe fallback.

The first archive RED used different module/source-section names and therefore
compared legitimately different debug archives. Giving the already isolated
Engines the same stable module identity made both `SaveByteCode` and Cache V2
function-artifact streams byte-for-byte equal without changing serialization.
Loading the capture-on bytes into a fresh capture-enabled Engine produces no
HIR and executes with the expected result.

The original `PrecompiledScript.Cache` wording was stale. Current production
uses Cache V2 function artifacts and explicitly never opens legacy
`PrecompiledScript*.Cache`; the task/spec/design now preserve that legacy path
as a negative no-reader/no-writer/no-migration/no-dual-write boundary rather
than reconstructing it. Full RED/GREEN evidence and source anchors are in
`research/task-2-7-capture-archive-parity.md`. Focused builds, both exact tests,
and the complete `TypedSemanticIR` prefix are GREEN; the latter is `41/41 PASS`
at `Saved/Tests/typed-semantic-task27-full-green/
20260816_222836_812_8b7864c0`. Task 2.7 is checked complete, with strict
OpenSpec validation retained as the record-integrity gate.

## Task 2.5 suspend and compiler-exception-region closure

The final task-2.5 gap is closed without changing the maintained language
surface. `Reference/angelscript-v2.38.0` shows that upstream cooperative
`Suspend()` sets context request/register flags which are consumed at
`asBC_SUSPEND`; the maintained fork deliberately has no such live state
machine and returns `asERROR`. A new capability-owned
`AngelscriptNativeTypedSemanticIRSuspendBoundaryTests.cpp` therefore proves
that a real loop retains both bytecode `asBC_SUSPEND` and HIR `LoopBackedge`
safe-point identity while `hasSuspendState` remains false and no unsupported
`SuspendPoint` is fabricated.

The independent
`AngelscriptNativeTypedSemanticIRUnsupportedExceptionRegionTests.cpp` owner
uses a unit-test-only post-finalization metadata seam to emulate the dormant
future-backport input that production must consume. The RED test found that
the injected function was still published as `VerifiedEmpty`. Production now
examines finalized `tryCatchInfo`, publishes
`CompilerExceptionRegion`/`hasExceptionCleanup`, installs a non-universal
empty scalar plan for existing transfers, and emits a stable pointer-free
`ExceptionCleanup` marker with `compiler-exception-region` target. The verifier
requires the header/marker pair. No source `try`/`catch` syntax, handler
bytecode, or runtime routing was enabled.

Evidence:

- RED: `Saved/Tests/typed-semantic-exception-region-red-exact/
  20260816_215636_300_670d1a8b/` — `0/1` at the precise cleanup-state check;
- GREEN build: `Saved/Build/typed-semantic-exception-region-green/
  20260816_215854_802_0b3e48ac/` — PASS;
- exception exact: `Saved/Tests/typed-semantic-exception-region-green-exact/
  20260816_215914_883_bc49e4d8/` — `1/1 PASS`;
- suspend build: `Saved/Build/typed-semantic-suspend-boundary/
  20260816_220100_331_b08e46f3/` — PASS;
- suspend exact: `Saved/Tests/typed-semantic-suspend-boundary-exact/
  20260816_220120_546_74616436/` — `1/1 PASS`;
- bounded regression: `Saved/Tests/typed-semantic-task25-green-group/
  20260816_220157_931_7fbf7256/` — `39/39 PASS`, zero failed/skipped.

## 2026-08-16 — Task 2.8 provisional HIR publication transaction

The compiler-HIR test surface follows the capability-owned partition rule.
The new failure/commit boundary is isolated in
`AngelScriptSDK/Compiler/TypedSemanticIR/
AngelscriptNativeTypedSemanticIRPublicationTransactionTests.cpp` rather than
adding another method to the large foundation file. The folder now contains
sixteen `.cpp` owners; fifteen have one `TEST_METHOD`, the operator owner has
two, and the largest remains the one-method list-factory boundary at 415 lines.

The first source-discovery build was not a valid behavioral RED. Adaptive Unity
repartition exposed six existing TypeSystem sources that used
`AppendGeneratedAsLine` / `PrintGeneratedAsSource` without directly including
their owner, `AngelscriptNativeLanguageCaseTestSupport.h`. Direct includes were
added only to the compiler-reported files. The subsequent exact test produced
the intended RED: the script compiled, but verifier-invalid provisional HIR
was still published.

Production now starts the optional HIR transaction inside
`asCCompiler::Reset()` for ordinary functions and global initializers. The
builder remains compiler-local, bytecode finalizes normally, and only the
result of the real verifier can transfer to `ScriptFunctionData`. A test-only,
private Engine user-data sentinel clears the provisional root immediately
before verification. It adds no public AngelScript ABI and does not alter
bytecode. The exact GREEN proves no HIR publication, stable verifier detail,
byte-for-byte capture-off/on bytecode equality and equal VM result `42`.

Evidence:

- invalid Unity-leak build: `Saved/Build/
  typed-semantic-publication-transaction-red-build/
  20260816_213443_181_0f91d8b6/`;
- valid RED: `Saved/Tests/typed-semantic-publication-transaction-red-exact/
  20260816_213808_821_eca5a698/` — `0/1`, only the expected publication
  assertion failed;
- GREEN build: `Saved/Build/typed-semantic-publication-transaction-green/
  20260816_214029_939_ecf873ff/` — PASS;
- exact GREEN: `Saved/Tests/
  typed-semantic-publication-transaction-green-exact/
  20260816_214050_382_8b6c3ab9/` — `1/1 PASS`;
- bounded regression: `Saved/Tests/
  typed-semantic-publication-transaction-green-group/
  20260816_214127_680_9d2e33e3/` — `37/37 PASS`, zero failed/skipped.

Task 2.8 is now checked complete. Future AST JIT tests continue to split by
observable capability/scenario when a file begins mixing responsibilities or
crosses the review trigger; tightly coupled cases may continue sharing one
fixture owner rather than mechanically creating one file per method.

## Task 2.9 list-factory boundary, fork ownership fix and final test partition

The final synthesized-function audit row has its own capability-owned test at
`AngelScriptSDK/Compiler/TypedSemanticIR/
AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedListFactoryTests.cpp`.
It intentionally does not share the generated constructor/destructor/factory
file: a list factory is a registered native/system behavior, not a script
compiler-generated function. The test owns one raw-SDK scenario and checks
registration/type-slot identity, `asFUNC_SYSTEM`, absent `scriptData`, absent
build-artifact invocation/HIR, normalized capture-off/on bytecode, real generic
callback arguments and identical runtime result.

Systematic debugging found three useful RED stages:

1. The first proposed `is null` script was rejected because that syntax is not
   part of the maintained fork, so it was discarded as an invalid fixture.
2. A syntactically accepted implicit-handle list-factory registration crashed
   `CompileInitListElement`; a guarded RED then proved the registered
   function's `listPattern` was null.
3. Source tracing showed `asCScriptFunction::listPattern` was static and every
   new function constructor reset the shared pointer. The locally pulled fixed
   AngelScript 2.38 reference (`Reference/angelscript-v2.38.0`, commit
   `0601da029d846a658bf23f2888e953a45a94450a`) keeps it per function.

Production now makes only `listPattern` instance-owned. The neighboring
delegate fields were not broadened into this fix because current delegate tests
already record a separate deferred limitation. The test also avoids comparing
raw addresses across independent Engines: it normalizes only pointer words for
the Engine-local opcodes documented by the maintained bytecode serializer, and
continues to compare opcodes and every non-pointer operand exactly.

The partition now has fifteen capability-owned `.cpp` files, one or two
methods each. The largest is this single-method list-factory owner at 415
physical lines, still below the 500-line review trigger. Evidence:

- build: `Saved/Build/
  typed-semantic-list-factory-engine-local-normalization/
  20260816_212532_082_2172bed4/` — PASS;
- exact: `Saved/Tests/
  typed-semantic-list-factory-engine-local-normalization-exact/
  20260816_212549_262_5825c26c/` — `1/1 PASS`;
- complete compiler-HIR prefix: `Saved/Tests/
  typed-semantic-list-factory-engine-local-normalization-group/
  20260816_212625_822_f4f1b01b/` — `36/36 PASS`, zero failed/skipped.

The exhaustive disposition table now has no open compiler/build artifact
family, so task 2.9 is checked complete. Future AST JIT tests continue to use
the capability-owned folder/translation-unit rule; a file crossing roughly
500 lines or five methods triggers another ownership review rather than a
mechanical copy split.

## Task 2.9 accessor/lambda boundary partition and source-backed inventory

The compiler-HIR tests now follow the requested capability ownership at the
point where a scenario is introduced. Future lambda syntax was removed from
`AngelscriptNativeTypedSemanticIRUnsupportedLanguageBoundaryTests.cpp` and
moved to
`AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLambdaTests.cpp`.
Removed virtual-property accessor syntax has its own
`AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedAccessorTests.cpp`.
Both files contain one scenario-specific CQTest method and one case-owned raw
SDK Engine pair; neither creates a generic unsupported catch-all.

The observable contract is intentionally fail-honest. The maintained parser
rejects virtual properties with the exact removal diagnostic before a type or
accessor function can be published. The internal lambda artifact kind still
exists, but current public source syntax cannot reach it; capture off/on both
reject the future syntax without publishing a function or HIR. This does not
claim lambda lowering support that the maintained language surface lacks.

All fourteen files currently under
`AngelScriptSDK/Compiler/TypedSemanticIR/` own one capability family, have one
or two test methods, and remain at or below 377 physical lines. Evidence:

- build: `Saved/Build/typed-semantic-synthesized-boundary-partition/
  20260816_205540_756_aec01d17/` — PASS;
- accessor exact: `Saved/Tests/typed-semantic-synthesized-accessor-exact/
  20260816_205552_057_b2f5c5fa/` — `1/1 PASS`;
- lambda exact: `Saved/Tests/typed-semantic-synthesized-lambda-exact/
  20260816_205629_730_fc055492/` — `1/1 PASS`;
- complete compiler-HIR prefix:
  `Saved/Tests/typed-semantic-synthesized-boundary-partition-group/
  20260816_205706_789_ef45e33a/` — `35/35 PASS`, zero failed/skipped.

The source-backed exhaustive inventory is now recorded at
`research/compiler-synthesized-function-dispositions.md`. Task 2.9 remains
open only for a dedicated behavioral proof that list-factory construction is a
registered native/system behavior and does not enter a script compiler HIR
transaction.

## Task 2.9 generated `__InitDefaults` disposition — RED/GREEN

Class-body `default` statements create a real generated `__InitDefaults`
method. This path enters ordinary `CompileFunction` with the class declaration
node, but it compiles each re-parsed default statement directly instead of
entering a normal function statement block. The provisional HIR builder
therefore had no root block and reduced every valid default sequence to the
generic `semantic capture encountered an unrepresentable compiler state`
diagnostic.

The dedicated
`AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedDefaultsTests.cpp`
owner proves the complete observable contract with real code: capture-off/on
modules contain non-empty byte-for-byte equal `__InitDefaults` bytecode; a
fresh object begins with `Value == 5`; manually executing the generated method
changes it to 37 in both Engines. Capture-on now records the stable no-HIR
`unsupported compiler-synthesized function: init-defaults` disposition and
does not create the builder that cannot own this generated statement stream.
Parser, default-statement compilation and bytecode remain unchanged.

Evidence:

- RED build: `Saved/Build/typed-semantic-init-defaults-red-build/
  20260816_204716_740_4925430b/` — test fixture compiled successfully;
- valid RED: `Saved/Tests/typed-semantic-init-defaults-red/
  20260816_204737_654_c8632be5/` — `0/1`; only the generic diagnostic differed;
- GREEN build: `Saved/Build/typed-semantic-init-defaults-green/
  20260816_204831_895_daa46706/` — PASS;
- exact GREEN: `Saved/Tests/typed-semantic-init-defaults-green-exact/
  20260816_204844_789_6e0a323f/` — `1/1 PASS`;
- bounded regression: `Saved/Tests/typed-semantic-init-defaults-green-group/
  20260816_204922_192_dede22ec/` — `33/33 PASS`, zero failed/skipped.

Task 2.9 remains open for list factory/accessor/lambda and the final exhaustive
artifact-invocation disposition table.
## Task 4.1 TypedASTJIT scalar golden and bytecode isolation closure

Task 4.1 is now checked complete. The existing generated-output owner proves
typed locals, literals, conversions, scalar operators, checked division,
single-evaluation mutations, short circuiting, deterministic symbols and the
absence of `FAngelscriptJITExecutionContext`; its current complete prefix is
`25/25 PASS` at `Saved/Tests/semantic-aot-task41-generated-output-green/
20260817_043616_901_febe6916/`.

Two capability-owned partitions close the previously indirect clauses.
`TypedASTJIT/CompileOut/AngelscriptTypedASTJITCompileOutTests.cpp` proves all
three compiler-final rewrite dispositions emit only the retained value/void
marker, never call the diagnostic target and publish no native call metadata.
A temporary method-chain mutation produced the intended isolated `1/2` RED;
after restoration the official build passed and the prefix returned `2/2
PASS`. `TypedASTJIT/BytecodeIsolation/
AngelscriptTypedASTJITBytecodeIsolationTests.cpp` drives a real isolated AOT
Generation Engine through both backends: BytecodeJIT self-proves all four
sentinels, while the accepted TypedASTJIT production scope records zero
analysis, reference-scan, `GetByteCode` and bytecode-dispatch access (`1/1
PASS`). Full reasoning and evidence paths are recorded in
`research/task-4-1-bytecode-isolation-sentinel.md`.

## Task 4.3 scalar emitter closure

Task 4.3 is checked complete. Exact compiler constant bits now own bool,
float32, float64 and enum literal emission while source spelling remains
diagnostic-only. The scalar helper layer already provided unsigned-bit-domain
wrapping arithmetic, count-masked shifts, explicit arithmetic-right-shift sign
fill, checked division/remainder/power, and context-free return/body emission.

The final gap was portable integer conversion. A new force-inlineable,
context-free `ConvertInteger<Target>` implements AngelScript's sign/zero
extension plus low-target-bit rule without implementation-defined
unsigned-to-signed C++ conversion. Generated bodies retain readable forms:
true narrowing uses `WrapNarrow`, remaining signedness changes use
`ConvertInteger`, and same-signed widening stays a direct `static_cast`.
Neither helper nor generated pure scalar bodies take
`FAngelscriptJITExecutionContext`.

Capability-owned tests remain split under `TypedASTJIT/LiteralEncoding/` and
`TypedASTJIT/ScalarConversions/`. Fresh verification is: build PASS; scalar
conversions `2/2 PASS`; literal encoding `1/1 PASS`; scalar helpers `4/4 PASS`;
generated output `25/25 PASS`; executed numeric boundary differential `1/1
PASS`. The complete RED/GREEN evidence and maintained-compiler semantic audit
are recorded in `research/task-4-3-scalar-emitter-audit.md`.

## Task 4.4/4.5 structured control flow — second capability matrix

Control-flow generation coverage is now capability-owned under
`TypedASTJIT/ControlFlow/{Branches,Loops,Returns,Switch,Cleanup}` rather than
added to the existing monolithic StaticJIT test files. The six current methods
cover nested branches, void returns, checked loop operands, all three loop
forms, multiple for-increment expressions, nested loop/switch targets,
fallthrough/default/scoped cases, exhaustive-enum failure emission, and the
explicit verified-empty cleanup gate. Corrupting a continue target or transfer
cleanup plan proves zero partial C++ output.

The first expanded prefix was `5/6`: a local explicit enum construction
correctly retained `Unsupported(ConstructionOrLifetime)` and failed closed.
The switch-focused fixture now takes an enum parameter; enum construction
remains assigned to task 4.6 rather than being silently admitted here. The
fresh official build passes and the complete control-flow prefix is `6/6 PASS`
at `Saved/Tests/semantic-aot-task44-control-flow-matrix-green/
20260817_060352_181_16f6cde4/`. Tasks 4.4/4.5 remain open for the expanded AOT
runtime exception/side-effect matrix and final structured-control-flow audit.

## 2026-08-17 — tasks 4.4/4.5 structured control flow complete

The final audit did not treat generated C++ text as runtime proof. Two new RED
runs first required missing do-while/continue/condition/body failures and
normal nested return/fallthrough behavior from the existing cloneable
differential carrier. `SemanticCloneableState` now owns explicit modes for all
three loop forms' relevant condition/body/continue/increment phases, nested
early/multiple returns, and switch fallthrough/default/scoped locals.

The regenerated independent Bytecode and Typed artifacts compile and execute
against a fresh Interpreter through Bytecode Raw/VM and Typed Raw/VM/Parms.
Nine exception phases preserve the first divide-by-zero failure and
deterministic failure value; the normal value matrix remains equal on all six
routes. Current generated artifacts also pass formal Verify, capability-owned
control-flow is `6/6`, generated output is `25/25`, and exhaustive enum
Raw/VM/Parms differential is GREEN.

The emitter consumes verified HIR relationships, phases, target IDs, case
disposition and cleanup plans only; it neither derives control flow from
bytecode offsets nor emits goto labels. Scalar exited-scope cleanup remains an
explicit `VerifiedEmpty` proof. Non-empty managed cleanup remains task 4.17.
Full RED/GREEN paths and the requirement matrix are recorded in
`research/task-4-4-control-flow-audit.md`. Tasks 4.4 and 4.5 are checked
complete.

## 2026-08-17 — task 4.6 numeric semantics complete

Task 4.6 is checked complete after a width-complete numeric audit. Capability-
owned tests now exercise wrapping add/subtract/multiply, masked shifts at
`-1|0|width-1|width|width+1|100000`, divide/remainder by zero across all eight
integer types, and signed `MIN/-1` across all four signed widths. The native
bitwise and operator-failure matrices execute 1680 and 102 cells respectively;
Typed scalar failures enter the existing `FScriptExecution` contract.

Float/integer conversions with no reviewed portable shared primitive remain
ineligible and now report the exact `NonPortableNumericConversion` reason.
Signed zero, subnormal, finite range edges, Infinity, NaN, underlying-`int8`
enum boundaries and bool normalization all have fresh focused evidence. The
real AOT numeric fixture also remains equal across Interpreter, Bytecode
Raw/VM/Parms and Typed Raw/VM/Parms. Full RED/GREEN paths and matrix dimensions
are recorded in `research/task-4-6-numeric-conversion-progress.md`.

## 2026-08-17 — task 4.7 per-task backend routing complete

Task 4.7 is checked complete after auditing the already-landed production
factory path. `typed-ast` has one Runtime-registry factory and no other
production construction site; each generator call creates, invokes and destroys
its own one-shot `FAngelscriptTypedASTJIT`. Exact capture profile, current
Engine and same-compilation HIR checks fail before unsafe consumption.

Fresh backend contract is `9/9 PASS`, the self-proving Bytecode-isolation probe
is `1/1 PASS`, and a real project Generate plus read-only Verify is `1/1 PASS`
with exactly one created/invoked/destroyed backend per operation. That real
project test also exposed a stale single-line source-text oracle after helper
formatting became multiline; it now validates the generated ScriptFunction
reference kind, ABI and slot before checking the readable C++ spelling. Full
source boundaries, historical TDD and current evidence are recorded in
`research/task-4-7-backend-routing-audit.md`.

## 2026-08-17 — task 4.8 emitter failure atomic fallback complete

Task 4.8 is checked complete with an end-to-end Verify-only fault variant. A
valid EditorDevelopment capability profile advertises Coverage in addition to
FramePosition and RecursionBudget, so the real Typed call closure passes
eligibility and the production emitter rejects the unsupported hook with
`EmitterFailure`. The existing generator then records the Typed attempt and
emits the same stable function through BytecodeJIT.

The focused observation is pointer-free and remains in AngelscriptTest. It
proves exact FunctionKey identity, eligible Typed closure, final backend
`bytecode`, emitted Bytecode attempt, exactly one final Provider function, and
no same-prefix `_TypedBody` in the packaged module source. The ordinary AOT
differential verifier still rejects that unexpected fallback; no Runtime test
hook, provider ABI change or production `dual` backend was added.

Fresh evidence is build PASS, exact emitter-fallback `1/1 PASS`, existing
eligibility fallback `1/1 PASS`, backend contract `9/9 PASS`, and Typed emitter
generated output `25/25 PASS`. The RED history, two narrowly diagnosed harness
issues and exact report paths are recorded in
`research/task-4-8-emitter-failure-fallback.md`.

## 2026-08-17 — tasks 4.9/4.10 semantic dependency Provider gap recorded

The first production semantic-use analyzer integration exposed a real contract
gap rather than a local eligibility bug. Its current blanket requirement that
every direct script call have a `FunctionContent` compiler dependency correctly
rejects missing dependencies, but incorrectly rejects valid self-recursion:
the maintained compiler gives ordinary calls a `Signature` edge and adds
`FunctionContent` only in hard-value compilation contexts. The production
valid-generation regression remains intentionally RED with
`SemanticDependencyMismatch` at
`Saved/Tests/semantic-aot-task49-valid-generation/
20260817_082524_596_85ea63f7/`.

Dropping the content requirement globally is unsafe because TypedASTJIT embeds
reachable non-root helper/SCC bodies in the root `.jit.cpp`; a helper-only body
change could otherwise leave the old root Provider eligible. Folded hard-value
content has the same transport problem. Provider ABI revision 7 does not carry
the authoritative per-entry semantic kind/target/expected-content rows needed
to validate those embedded facts at publication time.

The full compiler evidence, stale-publication sequence, rejected alternatives,
recommended versioned Provider semantic-dependency table, tentative file map,
and required RED matrix are recorded in
`research/task-4-9-4-10-semantic-dependency-analyzer.md`. This is an unresolved
design checkpoint: no Provider ABI or production behavior was changed in this
record-only step, and tasks 4.9/4.10 remained unchecked pending explicit
approval of the recommended contract.

### `UFUNCTION` is not the semantic-dependency discriminator

The issue was clarified against the production closure path. Exact UFUNCTION
status selects roots and distinguishes an eligible callee as `DirectScript`
rather than `InternalSemanticHelper`, but both dispositions are direct closure
members. The backend binds both to a fixed generated wrapper symbol and
currently marks both as requiring function content. Making every AS function a
UFUNCTION would therefore not prevent an installed caller from reaching an old
embedded callee body; invalidating the callee's own Provider entry does not
invalidate a caller that bypasses that entry with a direct symbol call.

The actual discriminator is lowering: direct embedded/fixed-symbol calls need
callee `FunctionContent` validation; calls through a current Engine/Provider/VM
slot need Signature + ABI + route validation and let the callee validate its
own body; root self-recursion is already covered by the root `ExecutionHash`.
The expanded Chinese explanation, four-case matrix and reflection-cost note are
recorded in `research/task-4-9-4-10-semantic-dependency-analyzer.md`. No code or
task state changed in this clarification step.

## 2026-08-17 — per-entry semantic dependency design approved and formalized

The user approved the explicit per-Provider-entry Semantic Dependency Table.
The decision is now normative in `design.md` and
`specs/as-typed-ast-jit-backend/spec.md`, while the complete rationale,
forward-table versus reverse-index model, stale-entry sequence and rejected
alternatives remain in
`research/task-4-9-4-10-semantic-dependency-analyzer.md`.

The approved contract is lowering-based rather than reflection-based. Root
self-recursion relies on its own `ExecutionHash`; fixed direct non-root
helper/SCC closure adds transitive `FunctionContent`; current
Engine/Provider/VM calls retain Signature + ABI + route only; folded constants
retain `HardValue`. Generated/provider truth is one canonical flat dependency
table with per-entry slices. Each selected Engine builds an ephemeral reverse
index and withdraws only affected stale entries before new calls can acquire
them, while existing entry leases protect calls already running. Later source
generation, DLL build/load and matching Provider adoption restore Typed
execution independently from immediate fallback.

Tasks 4.9 through 4.10c now split RED coverage, analyzer classification,
Provider ABI revision/serialization, current-Engine matching, hot-reload
reverse invalidation, fixture regeneration and official focused verification.
Tests are divided by capability under
`StaticJIT/TypedASTJIT/Dependencies/` instead of accumulating in one file.
This checkpoint changes OpenSpec only: no production code, ABI, generated
fixture, task checkbox, build result or test result is claimed here.
