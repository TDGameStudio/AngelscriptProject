# Plan-Only Verification — 2026-08-12

> **Layout supersession note (2026-08-12):** Earlier M5 evidence proves the implementation that existed at the time, including per-function slices and fixed 32 buckets. That layout is no longer acceptance evidence after the approved strict one-AS-module-per-profile-`<Module>.jit.cpp` decision. Reopened tasks in `tasks.md` require new RED/GREEN evidence; the historical results below are retained for traceability only.

## Delivered Scope

This round changed only `openspec/changes/refactor-as-static-jit-multi-provider/` and its current OpenSpec cross-references. It did not modify:

- `Plugins/Angelscript` or any vendored AngelScript source;
- host `Source/` or `AngelscriptProject.uproject`;
- `.uplugin`, Build.cs, generated JIT C++, Cache V2 data, commandlets, tools, or tests;
- build products, Saved cache data, or Editor state.

The OpenSpec was refactored from the earlier external-provider plan into a ready-to-execute plan covering:

- one breaking, non-versioned, lifecycle-aware AS JIT Binding interface;
- adoption of the useful AS 2.38 delayed-publication/cleanup semantics without retaining v1/v2 APIs;
- neutral Cache V2/StaticJIT artifact routes and stable references;
- current-revision provider ABI and engine-local reference slots;
- process-wide multi-provider Registry supporting several UE Provider modules, multi-AS-module Providers, owner-scoped unload, per-Provider generations, and deterministic cross-Provider ambiguity fallback;
- Editor/PIE current-function routing and reflected `UASFunction` VM/Raw/Parms dispatch;
- Editor-only `AngelscriptTestJIT` generated-code carrier isolated from all project inputs, naming, Scaffold, descriptors, settings, outputs, and lifecycle;
- fixed project module `AngelscriptJIT` at `Source/AngelscriptJIT`;
- `AngelscriptEditor`-owned project `-run=AngelscriptJIT -Mode=Scaffold|Generate|Verify`;
- `AngelscriptTest`-owned plugin-fixture `-run=AngelscriptTestJIT -Mode=Generate|Verify`;
- content-addressed function slices and exactly 32 fixed bucket translation units;
- explicit Editor Live Coding refresh after one normal full build;
- source-engine plus Cache V2 fresh-engine AOT tests;
- Development/Shipping behavior, diagnostics, Python dump inspection, performance, packaging, and full-suite gates.

## Artifact Inventory

Normative/working artifacts now include:

- `proposal.md`
- `design.md`
- `tasks.md` with 63 unchecked future implementation tasks
- `implementation-plan.md`
- `verification.md`
- historical progressive `research.md`, retained and marked with a 2026-08-12 supersession section
- historical `history/pre-multi-provider-shared-identity-contract.md`, preserved from the removed Cache worktree without treating its old task numbering as current requirements
- new focused `jit-interface-238-test-module-research.md`
- seven capability delta specs:
  - `as-jit-lifecycle-interface`
  - `as-static-jit-artifact-provider`
  - `as-static-jit-editor-routing`
  - `as-static-jit-module-scaffolding`
  - `as-static-jit-aot-test`
  - `static-jit-diagnostics`
  - `uasfunction-dispatch-matrix-and-jit-paths`

All task boxes remain unchecked because this was an OpenSpec-only refactor. The previous 31-item checklist was replaced rather than marked complete.

## Consistency Checks

- Modified capability requirement names match their existing base-spec requirements exactly.
- All delta scenarios use OpenSpec `#### Scenario` structure.
- Normative module naming is consistently `AngelscriptTestJIT` for plugin tests and fixed `AngelscriptJIT` for projects; ProviderId remains project/source-domain-specific.
- Old names/API terms occur in normative artifacts only where the plan explicitly describes current source evidence, rejected alternatives, or required removal.
- `AngelscriptTestJIT` is consistently Editor-only and contains generated code/probes only; it is not a project scaffold or project source target.
- `AngelscriptTest` owns only plugin-fixture tests and the isolated `AngelscriptTestJIT` Generate/Verify entry; `AngelscriptEditor` owns project `AngelscriptJIT` Scaffold/Generate/Verify.
- Several UE Provider modules may coexist in one Registry, one Provider may contain several AS modules, and each AS Engine owns independent resolved state.
- Same-Provider generations replace safely; different-Provider exact conflicts produce `AmbiguousExactProvider` and VM rather than load-order override.
- Runtime depends on neither TestJIT nor project JIT provider modules.
- Cache V2 and StaticJIT share neutral identity/route/reference values but retain separate cache-store and JIT-provider responsibilities.
- The implementation order starts with AS lifecycle ownership, then neutral artifacts/provider/routing, and only then creates modules and Live Coding integration.

## Multi-Module Follow-Up Evidence

The 2026-08-12 follow-up inspected current source before changing the record:

- `FStaticJITFunction` construction appends VM/Raw/Parms entries to `FJITDatabase::Get().Functions` by numeric FunctionId;
- generated reference constructors append to global reference arrays in the same database;
- static constructors from multiple translation units or loaded modules can therefore reach one accumulator;
- `FStaticJITCompiledInfo` still enforces one active precompiled-data identity;
- FunctionId overwrite, all-database clear, absent Provider ownership, and absent owner-scoped unload mean this is not true multi-provider support.

The revised OpenSpec consequently requires a new owner-aware Registry rather than describing the current database as already multi-module. It separately covers multiple UE Provider modules, multiple AS modules per Provider, and multiple Engine-local consumers.

## Validation Evidence

The following commands were run after the 2026-08-12 proposal, design, specs, tasks, implementation plan, and research attachment were present:

```powershell
openspec status --change refactor-as-static-jit-multi-provider --json
openspec validate refactor-as-static-jit-multi-provider --strict
```

Observed result:

- both commands returned exit code `0`;
- status reported `schemaName: spec-driven` and `isComplete: true`;
- proposal, design, specs, and tasks all reported `done`;
- strict validation reported `Change 'refactor-as-static-jit-multi-provider' is valid`.

The final verification pass after this file was written reran strict validation and `git diff --check`; both returned exit code `0`. `git status --short` showed only the renamed StaticJIT change, its current OpenSpec cross-references, and the shared artifact-identity spec. No plugin or host-project source path was modified. The line-ending notices are Git's existing LF-to-CRLF checkout warning and are not `diff --check` failures.

## Change Rename Verification

On 2026-08-12 the active change directory was renamed from
`refactor-as-static-jit-external-module` to
`refactor-as-static-jit-multi-provider`. The rename intentionally describes
the architectural outcome—stable multi-Provider registration, routing,
generation replacement, and module-backed artifacts—rather than only one
external UE module.

The rename pass verified:

- `openspec list --json` discovers only the new active change name;
- `openspec status --change refactor-as-static-jit-multi-provider --json`
  reports all required artifacts present and 63 implementation tasks;
- strict validation passes for `refactor-as-static-jit-multi-provider`,
  `refactor-as-incremental-function-cache`, and
  `feature-as-typed-semantic-aot`;
- the only active occurrences of the old name are the explicit rename
  mappings in `research.md` and this verification record;
- archived snapshots retain the old name and were not rewritten;
- `git diff --check` returns exit code `0`.

`openspec validate --all --strict` reported 142 passing items and two existing
unrelated empty-delta failures:
`docs-as-mutable-global-feasibility` and
`refactor-as-runtime-assets-and-singletons`. Neither path is part of this
rename diff. Targeted strict validation of every change touched by the rename
passes, so these repository-wide baseline failures are recorded but not
modified as part of this OpenSpec-only rename.

No C++ build, Unreal Automation run, Editor launch, PIE session, Live Coding patch, or package run is claimed because the user explicitly restricted this round to OpenSpec changes.

## Historical Verification Retained

The 2026-08-08 plan-only packet had six capability deltas and 31 unchecked tasks and correctly recorded that no source implementation had occurred. Its research history remains in `research.md` and Git history. This 2026-08-12 packet supersedes its module suffix, JIT-interface boundary, route ownership, TestJIT topology, commandlet ownership, single-global-database assumptions, test-cache strategy, and implementation order; it does not retroactively describe those earlier choices as implemented.

## Implementation Handoff

Implementation should begin at `tasks.md` group 1 with native AngelScript JIT lifecycle tests. It should not begin by scaffolding the provider modules. Before group 2, re-confirm the current Cache V2 artifact identity/route types and focused regression baseline; then neutralize reusable types without moving cache persistence policy into StaticJIT.

The first source-level completion claim is valid only after the unified Binding publish/release tests pass. The feature-level completion claim is valid only after `AngelscriptTestJIT`, host project JIT module, Editor/PIE, Live Coding, Development/Shipping package, multi-start, diagnostics, and the complete impact-focused prefix matrix are recorded. As superseded by the 2026-08-13 final-gate scope decision below, configured `All` is diagnostic evidence rather than a completion prerequisite.

## Milestone 1 Implementation Evidence — 2026-08-12

Tasks 1.1–1.7 are implemented. This is a milestone claim only; the overall multi-provider change remains in progress.

### Lifecycle API and ownership

- Replaced the fork's synchronous `CompileFunction` / `ReleaseJITFunction` callback pair and separate public VM/Raw/Parms fields with one non-versioned `asIJITCompiler` lifecycle and `asSJITFunctionBinding` value.
- Removed `asEP_JIT_INTERFACE_VERSION`; later explicit engine-property numeric values remain stable.
- Added delayed `SetJITBinding()` / `GetJITBinding()` publication on `asIScriptFunction`.
- Made `asCScriptFunction` clear before release and retain the exact publishing compiler as owner of each non-empty Binding.
- Converged replacement, explicit clear, module discard, function destruction, compiler replacement/removal, and engine shutdown on exact-once release. Failed half-created functions never receive readiness notification and therefore cannot own a published Binding.
- Restricted readiness to successfully compiled/restored script functions containing JIT entry instructions; detached `CompileFunction()` success now follows the same notification path.

### Generator and consumer migration

- Changed StaticJIT generation to enumerate completed module functions through an explicit generator input instead of temporarily replacing the engine compiler.
- Migrated VM, Raw, Parms, ClassGenerator, cache restore, dump, diagnostics, AOT, and compatibility precompiled-data consumers to the unified Binding.
- Retained compatibility precompiled-data installation only in the diagnostics-owned path; normal Runtime startup does not create a compatibility compiler.

### TDD and verification runs

The principal RED evidence was:

- clean target API build failure before lifecycle implementation: `Saved/Build/build/20260812_120755_399_81df601f`;
- lifecycle release suite: 1 pass / 3 fail at `Saved/Tests/static-jit-binding-lifecycle-release-red/20260812_121529_715_1e8ff3bc/Report`;
- lifecycle completeness suite: 5 pass / 1 fail at `Saved/Tests/static-jit-binding-lifecycle-completeness-red/20260812_122645_904_68adcce5/Report`;
- generator observer test: 1 fail because the old generator collected no functions without replacing the compiler, at `Saved/Tests/static-jit-generator-observer-red-2/20260812_124614_818_c999d607/Report`.

The corresponding GREEN evidence was:

- full plugin build, 123 actions successful: `Saved/Build/build/20260812_123649_306_1210d45b`;
- native lifecycle plus compiler tests, 7/7 pass: `Saved/Tests/static-jit-sdk-binding-and-compiler/20260812_124010_753_ff27a445/Report`;
- migrated Upgrade, Cache StaticJIT isolation, and StaticJIT AOT consumers, 22/22 pass: `Saved/Tests/static-jit-unified-binding-consumers/20260812_124047_676_1fa449b1/Report`;
- generator output tests, 2/2 pass: `Saved/Tests/static-jit-generator-observer-green/20260812_124823_915_75626a87/Report`;
- AOT diagnostics tests, 3/3 pass: `Saved/Tests/static-jit-generator-aot-diagnostics/20260812_124907_520_f95109b3/Report`.

The lifecycle test set covers delayed complete publication, replacement, explicit clear, re-entrant inspection and VM execution, detached-function destruction, bytecode restore eligibility, module discard, engine shutdown, compiler replacement, and compiler removal. Active-reader retention during concurrent Native execution remains explicitly deferred to task 4.5.

The milestone-closing rerun after the documentation/API-comment consistency pass also succeeded:

- 123-action Development Editor build: `Saved/Build/static-jit-m1-final/20260812_125831_024_357224c0`;
- lifecycle and compiler prefix, 7/7 pass: `Saved/Tests/static-jit-m1-lifecycle-final/20260812_130103_490_780a041b/Report`;
- generator observer prefix, 2/2 pass: `Saved/Tests/static-jit-m1-generator-final/20260812_130143_226_d897591e/Report`;
- targeted strict OpenSpec validation and parent/submodule `git diff --check`: exit code `0`.

### Documentation

Chinese documentation was updated first in `RT_ThirdPartyKernel.md`, `AS_ForkDifferences.md`, and `RT_StaticJIT.md`; the English fork-difference guide and public vendored header comments then received the same maintained-fork lifecycle boundary. Deprecated `Documents/Plans/Plan_AS238JITv2Port.md` remains an intentionally historical plan rather than being rewritten as current truth.

## Milestone 2 Implementation Evidence — 2026-08-12

Tasks 2.1–2.5 are implemented. The overall multi-provider change remains in
progress; Provider ABI and Registry work starts at task group 3.

### Neutral identity, reference, and route ownership

- Reconfirmed that stable module/type/function identity and execution/debug/profile/environment/compatibility hashes already live under neutral `Core/Artifacts` contracts and remain the single source of truth.
- Moved the reusable stable-reference vocabulary into `FAngelscriptArtifactReference` while preserving the existing serialized kind values.
- Replaced Cache-named route values with `FAngelscriptFunctionRoute`, `FAngelscriptFunctionRouteSnapshot`, `FAngelscriptFunctionRouteGeneration`, and typed `EAngelscriptArtifactMatchResult` values.
- Moved the sole mutable route publication state into one Engine-owned `FAngelscriptFunctionRouteState`; consumers receive shared const snapshots and resolve through `FAngelscriptEngine::ResolveFunctionRoute`.
- Kept Cache V2 storage, restore policy, mutation guards, and diagnostic DTOs Cache-specific. The existing Cache diagnostic `PublicationOrdinal` remains stable and is populated from the neutral route generation.
- Removed the old private `AngelscriptCacheRuntimeState.h` and verified no legacy Cache route/reference/runtime-state symbol remains in Runtime or tests.

### TDD and focused verification

The principal RED evidence was:

- neutral artifact tests failed to compile until the new neutral headers and values existed: `Saved/Build/static-jit-m2-neutral-types-red/20260812_130730_846_78faf88d`;
- the first broad migration build exposed one Cache diagnostic DTO assertion that had been over-renamed mechanically: `Saved/Build/static-jit-m2-neutral-types-green/20260812_131130_378_5ab456e2`. Restoring the compatibility field name fixed the issue without changing the neutral Runtime route contract.

The corresponding GREEN evidence was:

- incremental Development Editor build after the neutral-type migration: `Saved/Build/static-jit-m2-neutral-types-green-2/20260812_131352_148_bcd0fd65`;
- neutral artifact tests plus the pre-existing identity, route, and fresh-engine restoration baseline, 22/22 pass: `Saved/Tests/static-jit-m2-neutral-and-baseline-green/20260812_131410_541_e1e76813/Report`;
- two-Engine/reordered-FunctionId test build: `Saved/Build/static-jit-m2-two-engine-green/20260812_131705_074_90d8a346`;
- route snapshot prefix including the new two-Engine stable-reference resolution case, 5/5 pass: `Saved/Tests/static-jit-m2-two-engine-routes/20260812_131723_697_878b109a/Report`;
- Cache candidate lookup, dependency propagation, exact/production warm startup, and StaticJIT isolation, 24/24 pass: `Saved/Tests/static-jit-m2-cache-behavior-green/20260812_131938_264_864f86ff/Report`.

The two-Engine test intentionally consumes a script FunctionId in the second
Engine before compiling identical source. It asserts equal stable function,
execution-content, and profile identity; unequal numeric FunctionIds; distinct
Engine-local live function pointers; and resolution of one identical stable
reference descriptor to the correct local function in each Engine.

The focused Cache run produced only the environment's existing
`generate_204` HTTP timeout warning; all 24 selected tests passed with zero
failures and zero skips. Parent and plugin `git diff --check` returned exit
code `0`, and a source scan found no old Cache route/reference/runtime-state
symbols.

## Milestone 3 Provider ABI And Reference Evidence — 2026-08-12

Tasks 3.1–3.5 and 3.7 were implemented at this checkpoint. Tasks 3.6 and 3.8
remained open here because production module-unload retirement and the real
`AngelscriptTestJIT` plus project Provider modules were not yet closed; their
later closure is recorded below.

### Provider ABI, Registry, and matching

- Added one current provider ABI revision with explicit layout fields,
  `StructSize`, exact 32-bucket validation, deterministic artifact-set and
  content-derived Provider-generation digests, sorted entries/reference slots,
  and no compatibility adapter.
- Added Runtime-owned copied immutable catalogs, deterministic snapshots,
  owner-scoped register/unregister, Modular Features discovery, same-Provider
  generation replacement, ProviderId conflict rejection, and old-snapshot
  retention.
- Added typed matching across stable module/function identity, execution/debug
  content, profile, native environment, entry ABI, required VM/Raw/Parms
  entrypoints, complete immutable sets, reference slots, duplicate entries, and
  cross-Provider exact ambiguity. Ambiguity fails closed rather than selecting
  by registration order.

### Engine-local references and Binding transport

- Added stable descriptors for script function/type/global/import/string and
  Runtime-helper references and immutable per-Engine resolved reference tables.
- Script-function slots retain the current Engine object across module discard;
  two Engines resolve an identical stable descriptor to independent local
  addresses.
- Added complete `FScriptExecution` Binding fields and explicit VM/Raw/Parms
  invocation helpers, plus Runtime-owned immutable Binding contexts retaining
  Provider catalogs and resolved tables.
- Hardened Binding-context recognition: legacy compiler `UserData` is never
  dereferenced or recognized by a spoofable magic value; only addresses
  registered by live Runtime-created contexts are accepted.

### TDD and focused verification

The provider-generation digest change deliberately exposed a stale test
fixture; after rebuilding the test module, the complete Provider prefix passed
16/16 at
`Saved/Tests/static-jit-m3-provider-regression-built/20260812_143411_358_c298e3b3/Report`.

The legacy-`UserData` spoof test first failed as intended at
`Saved/Tests/static-jit-m3-userdata-red/20260812_143850_124_472add87/Report`.
After switching to live-context registration, the Development Editor build
passed at
`Saved/Build/static-jit-m3-userdata-green/20260812_143948_156_49f28e4d`,
ExecutionContext passed 5/5 at
`Saved/Tests/static-jit-m3-userdata-green/20260812_144010_540_48b60aad/Report`,
and BindingPublication passed 2/2 at
`Saved/Tests/static-jit-m3-userdata-binding-green/20260812_144059_023_219a2bae/Report`.

Additional focused evidence already produced in this milestone includes
ReferenceSlots 5/5, MultiProvider 4/4, actual core VM context execution 4/4
before the spoof case was added, provider Binding publication 2/2, and the M1
lifecycle regression 6/6 after active-reader retirement was introduced. Those
primitives are necessary evidence for open tasks 3.6 and 3.8 but do not by
themselves prove safe real-module unload or the real Provider module topology.

### Task 3.7 complete Binding execution closure

- The core VM acquires one complete `asSJITFunctionBinding` reader snapshot
  and publishes the exact Engine, function, Binding/UserData, and resolved
  reference table in `FScriptExecution` for the duration of the entry.
- Runtime external VM, Raw, and Parms dispatch uses the same scoped execution
  context; Raw callers hold `FAngelscriptJITBindingExecutionLease` so a
  concurrent replacement cannot retire the old Provider catalog/reference
  table before the call returns.
- UASFunction generic VM/Parms and specialized Raw paths now acquire the
  current function Binding at invocation time. They do not read provider-owned
  view memory and do not resolve an ambient/process-global Engine.
- Reloadable generated script calls now carry a full stable function key and
  use `FScriptExecution.jitEngine` to recover the exact Runtime Engine. The
  Runtime bridge resolves the current Engine-local route, then the current
  virtual override when applicable, and retains the callee until the nested
  call finishes. Direct content-specific symbols remain disabled unless an
  immutable cooked set is explicitly validated later.

Final focused evidence for task 3.7:

- Development Editor build: `Saved/Build/static-jit-m4-generated-route-green2/20260812_152632_949_b333d874` (117/117 actions);
- generated call contract plus current-route/runtime Native→VM→refreshed-Native
  execution: 5/5 at
  `Saved/Tests/static-jit-m4-native-miss-refresh/20260812_153807_480_d1e6fa6f/Report`;
- complete VM/Raw/Parms execution context: 5/5 at
  `Saved/Tests/static-jit-m3-execution-context-final/20260812_153853_405_a8d0be65/Report`;
- concurrent/external Binding publication leases: 3/3 at
  `Saved/Tests/static-jit-m3-binding-publication-final/20260812_153929_328_a0f00d6a/Report`.

The deliberately invalid-pointer diagnostic attempt at
`Saved/Tests/static-jit-m4-current-route-runtime/20260812_153350_419_a8275b3b`
is not GREEN evidence: the test supplied address `0x1` as an
`asIScriptEngine*` and correctly crashed on dereference. It was replaced with
the valid missing-Engine (`nullptr`) fail-closed case before the 4/4 and 5/5
GREEN runs. Production `FScriptExecution.jitEngine` is always either null or a
real Engine pointer; arbitrary non-null addresses are outside the C++ API
contract.

## Milestone 4 Current-call Routing Evidence — 2026-08-12

Task 4.2 is implemented. Reloadable-profile generated call sites now resolve a
full `FAngelscriptStableFunctionKey` against the exact `FScriptExecution` Engine
through `FStaticJITCurrentFunctionCall`; they do not embed or dereference a
content-specific callee `RawEntry`. Direct script-to-script C++ calls remain
disabled by default behind `bUseImmutableDirectScriptCalls`, so incomplete or
reloadable sets take current VM/current Binding dispatch.

The first real AOT regeneration exposed a pre-existing dynamic-return
materialization defect: `CpyRtoV4` copied one byte from `l_dwordRegister` after
the dynamic call had populated `l_valueRegister`, causing `Entry()` to return
zero. The same branch also used four bytes for `double`. The generator now copies
four and eight bytes respectively from the materialized value register.

Evidence:

- RED routed AOT run, generated sources compiled but runtime parity failed 11/12
  (`Entry()` returned `0` instead of `42`):
  `Saved/Tests/staticjit-m4-routed-aot_04_tests/20260812_154319_996_09bedd3b/Report`;
- GREEN baseline generator build:
  `Saved/Build/staticjit-m4-routed-aot-green_01_baseline_build/20260812_154459_011_2d2f80d5`;
- GREEN regenerated-source build: recorded by the successful
  `Tools/RunStaticJITTests.ps1 -LabelPrefix staticjit-m4-routed-aot-green -AotOnly`
  pipeline;
- GREEN AOT automation, 12/12 pass:
  `Saved/Tests/staticjit-m4-routed-aot-green_04_tests/20260812_154555_666_b840ef19/Report`.

The checked-in generated AOT fixture now contains the routed
`Entry -> AddForAOT` call and was the source compiled by the GREEN pipeline.

Task 4.1 is now complete. The actual generated-code matrix additionally covers:

- nested exception propagation from a generated callee into the outer VM
  status and diagnostics;
- in/out references, value-object return/lifetime behavior, and recursive
  generated calls;
- a consumer module imported from a separately compiled provider module and
  rebound to the current Engine-local provider function after Cache restore;
- a generated parent method invoking a `BlueprintEvent` on a child instance,
  proving the current child `BlueprintOverride` is selected and both generated
  entries execute once.

The exception RED run completed 11/12 because the nested call context entered
the exception state without marking the outer `FScriptExecution`; after the
route propagated `Execution.bExceptionThrown`, the regenerated pipeline passed
13/13:

- RED: `Saved/Tests/staticjit-m4-exception-red_04_tests/20260812_155132_736_c7c3ec15/Report`;
- GREEN: `Saved/Tests/staticjit-m4-exception-green_04_tests/20260812_155349_951_381911e6/Report`;
- GREEN generated-source build:
  `Saved/Build/staticjit-m4-exception-green_01_baseline_build/20260812_155249_139_54375fb9`.

Reference, object-lifetime, recursion, and import evidence:

- reference/lifetime/recursion generated parity, 14/14:
  `Saved/Tests/staticjit-m4-parity-reference-lifetime-recursion_04_tests/20260812_155706_887_7bccfc25/Report`;
- import setup plus generated consumer/provider route, 14/14:
  `Saved/Tests/staticjit-m4-import-setup-green/20260812_160159_715_812b8bfc/Report`;
- corresponding build:
  `Saved/Build/staticjit-m4-import-setup-green/20260812_160145_615_b08c995b`.

The current-virtual-override regeneration exposed another latent generator
defect: non-materialized `GETOBJ` emitted `*v` after declaring `v` as the
integer-width `asPWORD`, so the generated C++ could not compile. It now emits
`*(asPWORD*)v`, matching the already-correct store/clear representation. The
first complete virtual pipeline also exposed that shared test-engine module
reset did not clear the per-Engine StaticName indices serialized by the
precompiled fixture. `ResetModules` now clears that module-owned table after
discard and GC, allowing the next precompiled module set to rebuild it from its
own serialized names.

Final virtual and aggregate evidence:

- generated `GETOBJ` compile RED:
  `Saved/Build/staticjit-m4-current-virtual-green_03_generated_build/20260812_160713_433_8c4e6ee5`;
- the regenerated virtual route itself, 1/1:
  `Saved/Tests/staticjit-m4-current-virtual-single/20260812_161048_759_a0a3f24d/Report`;
- StaticName cross-test RED assertion:
  `Saved/Tests/staticjit-m4-current-virtual-getobj-green2_04_tests/20260812_160925_070_cb0bddf7`;
- final cleanup build:
  `Saved/Build/staticjit-m4-static-name-cleanup-build/20260812_161237_939_f90aee8f`;
- final complete AOT prefix, 15/15:
  `Saved/Tests/staticjit-m4-aot-15-green/20260812_161302_458_b77a310b/Report`.

### Task 4.3 UASFunction dispatch matrix

Task 4.3 is complete. The ordinary source-compiled dispatch matrix and the
actual generated AOT fixture now cover specialized and generic wrappers,
no-parameter calls, primitive arguments and returns, in/out references,
reference-plus-return generic dispatch, object returns, multi-argument generic
dispatch, Blueprint-thread-safe dispatch, static world-context dispatch, and
current virtual override dispatch through reflected Parms memory.

The first expanded AOT run was deliberately RED at 13/15:

- the test initially expected immutable `_JIT` wrapper subclasses even though
  the fixture is a reloadable Editor profile and must retain current-Binding
  lookup; and
- a direct reflected call through the parent BlueprintEvent returned the
  correct child result but did not execute the child's current generated
  implementation entry, exposing that the specialized wrapper bypassed
  virtual Binding resolution.

The first attempted allocation rule treated every non-final AngelScript method
as virtual. The ordinary dispatch prefix rejected that blanket assumption: AS
methods are not necessarily marked `asTRAIT_FINAL`, so no-param/primitive/
reference specializations were incorrectly downgraded. The final rule uses
the reflected descriptor boundary (`bBlueprintEvent || bBlueprintOverride`):
ordinary methods keep their specialized wrappers, while Blueprint events use
the generic wrapper that resolves the current override and then reads its
complete current Binding.

Evidence:

- expanded AOT RED, 13/15:
  `Saved/Tests/staticjit-m4-uasfunction-matrix-red_04_tests/20260812_162041_560_57461637/Report`;
- blanket non-final-rule RED ordinary prefix, 1/3:
  `Saved/Tests/staticjit-m4-asfunction-dispatch-green/20260812_162348_675_275c884d/Report`;
- corrected Development Editor build:
  `Saved/Build/staticjit-m4-uasfunction-blueprint-event-build/20260812_162952_778_b7f1c67f`;
- ordinary source-compiled allocation/current-Binding matrix, 3/3:
  `Saved/Tests/staticjit-m4-asfunction-dispatch-blueprint-event-green/20260812_163007_791_3ab09a26/Report`;
- actual regenerate/rebuild AOT matrix, 15/15 successful, zero failures:
  `Saved/Tests/staticjit-m4-uasfunction-matrix-green_04_tests/20260812_163141_368_13abc4f4/Report`.

### Task 4.4 current Binding across UASFunction soft reload

Task 4.4 is complete. A new focused Editor soft-reload test installs complete
initial Bindings for two final reflected methods on one class, changes only one
method body, publishes no exact Binding for that changed replacement, and
publishes a newer complete Binding for the unchanged method. Soft reload keeps
the same `UClass` and `UFunction` objects but replaces both `ScriptFunction`
associations.

The test deliberately failed before reload because full ClassGenerator reload
still copied a final function's VM/Raw/Parms addresses into the long-lived
`UASFunction` fields. Full reload now retains only the current ScriptFunction
association; all reloadable ordinary, specialized, generic, and `_JIT` wrapper
implementations acquire that function's current complete Binding when invoked.
Content-specific pointer caching is reserved for the separately validated
immutable cooked boundary in task 4.6.

The GREEN test proves that the changed function's replacement Binding has no
VM, Raw, or Parms entry and reflected dispatch executes the new VM body, while
the unchanged function retains a new-generation exact Native Binding and
executes its current Native entry. Generic shapes use Parms dispatch; after
task 4.6 reserves `_JIT` subclasses for validated immutable cooked sets, the
specialized primitive-return fixture uses its current Raw entry. No retired
initial entry counter changes after reload.

Evidence:

- RED focused soft reload, failed on the copied VM entry before reload:
  `Saved/Tests/staticjit-m4-uasfunction-softreload-red/20260812_163750_512_2c875dcf/Report`;
- GREEN build:
  `Saved/Build/staticjit-m4-uasfunction-softreload-green-build/20260812_163844_136_c7097157`;
- GREEN focused soft reload, 1/1:
  `Saved/Tests/staticjit-m4-uasfunction-softreload-green/20260812_163903_335_5dd17a5f/Report`;
- complete ASFunction neighboring regression, 15/15:
  `Saved/Tests/staticjit-m4-uasfunction-current-binding-regression/20260812_163950_303_896d5918/Report`;
- generated AOT regression after removing long-lived pointer copies, 15/15:
  `Saved/Tests/staticjit-m4-uasfunction-current-binding-aot-regression/20260812_164034_751_584ccd8f/Report`.

### Task 4.5 in-flight Binding publication

Task 4.5 is complete. A focused `UASFunction` integration fixture now covers
the complete Engine-facing call chain instead of only the lower-level Binding
lease. Both generated methods are marked `BlueprintThreadSafe` and receive a
complete VM/Raw/Parms/UserData Binding before ClassGenerator allocation. The
final task 4.6 allocation rule intentionally keeps these reloadable,
non-validated Bindings on the generic route-aware `UASFunction` wrapper; their
publication behavior is otherwise unchanged.

The overlapping-reader case blocks the old VM entry on a worker thread,
publishes a complete replacement Binding from the test thread, and invokes the
same reflected function again before the old call is allowed to return. The
new call observes the new generation immediately, while the old provider
Binding remains unreleased and continues to return its original value. Only
after the final old reader exits is that Binding released, exactly once; the
new generation then retires independently.

The re-entrant case replaces its own Binding from inside the active old VM
entry and executes the same reflected method through a nested AngelScript
context. The nested call observes the new generation, the outer call retains
the old immutable snapshot until it exits, and neither generation is released
early or more than once. These integration cases exercise the reader/retired
Binding lifecycle implemented in the maintained AngelScript fork during M1,
including the `UASFunction` pooled-context path.

Evidence:

- initial assertion RED under the interim allocation rule, which selected the
  thread-safe `UASFunction_JIT` subclass for any complete Binding; task 4.6
  subsequently tightened that rule to require an accepted immutable-set token:
  `Saved/Tests/staticjit-m4-uasfunction-publication-tests/20260812_164832_408_b874afde/Report`;
- GREEN build:
  `Saved/Build/staticjit-m4-uasfunction-publication-build2/20260812_164952_602_67ce3a1a`;
- focused thread-safe and re-entrant publication matrix, 2/2:
  `Saved/Tests/staticjit-m4-uasfunction-publication-tests2/20260812_165013_767_f246e351/Report`;
- complete `StaticJIT.UASFunction` neighboring prefix, 3/3:
  `Saved/Tests/staticjit-m4-uasfunction-publication-regression/20260812_165057_441_87b0ade7/Report`;
- lower-level Binding publication/lease regression, 3/3:
  `Saved/Tests/staticjit-m4-binding-publication-regression/20260812_165139_199_37089ce5/Report`;
- generated AOT regression, 15/15:
  `Saved/Tests/staticjit-m4-uasfunction-publication-aot-regression/20260812_165216_364_bb7b109c/Report`.

### Task 4.6 immutable cooked artifact-set boundary

Task 4.6 is complete. Runtime now validates immutable direct-call eligibility
as an all-or-nothing artifact-set property rather than inferring it from an
individual complete Binding. The typed validator requires the immutable-cooked
runtime profile, exact provider artifact-set/profile/environment identities,
one exact deterministic match for every provider entry, complete VM/Raw/Parms
entry points, and complete resolved reference tables. Any missing, duplicate,
stale, mismatched, or partial entry rejects the whole direct-call set.

An accepted validation result is an opaque Runtime-owned token. Provider
publication refuses entries marked `ImmutableDirectCallSet` without that token
or when the token does not cover the exact selected catalog entry. The created
Binding context records direct-dispatch eligibility, and ClassGenerator only
allocates `_JIT` subclasses when the current Binding carries that recognized
validated context. Complete reloadable, legacy, and custom Bindings stay on
ordinary current-route wrappers and therefore fail closed to current
VM/Raw/Parms dispatch.

TDD and regression evidence:

- RED compile before the immutable-set contract existed (missing production
  header):
  `Saved/Build/staticjit-m4-immutable-set-red-build/20260812_165901_007_d1bb2119`;
- GREEN Development Editor build:
  `Saved/Build/staticjit-m4-immutable-set-green-build/20260812_170156_009_0676df52`;
- focused immutable-set acceptance, mismatch, partial-set, guarded-publication,
  and actual ClassGenerator allocation matrix, 5/5:
  `Saved/Tests/staticjit-m4-immutable-set-tests/20260812_170224_554_e04f1ed3/Report`;
- first full StaticJIT regression, 79/80, exposed that the existing reload test
  still expected Parms dispatch after its primitive-return wrapper correctly
  moved from `_JIT` to the ordinary specialized Raw path:
  `Saved/Tests/staticjit-m4-immutable-set-full-staticjit-regression/20260812_170312_847_715df95f/Report`;
- corrected regression-test build:
  `Saved/Build/staticjit-m4-immutable-set-regression-fix-build/20260812_170518_358_27b03db3`;
- focused current-Binding soft-reload case, 1/1:
  `Saved/Tests/staticjit-m4-immutable-set-current-binding-fix/20260812_170536_036_9c75353b/Report`;
- final complete StaticJIT prefix, 80/80:
  `Saved/Tests/staticjit-m4-immutable-set-full-staticjit-green/20260812_170616_263_b89d60d4/Report`;
- ClassGenerator dispatch/allocation regression, 3/3:
  `Saved/Tests/staticjit-m4-immutable-set-asfunction-regression/20260812_170846_817_260871f9/Report`.

Milestone 4 is complete. Milestone 3 tasks 3.6 and 3.8 deliberately remain
open until real provider-module unload/refresh and the real concurrent test,
project, and plugin Provider topology are proven.

## Provider Code-Image Lifetime Hardening — 2026-08-12

The implementation portion of task 3.6 now has a Runtime-owned per-generation
lease that resolves every published VM/Raw/Parms address to the actual loaded
base or Live Coding patch image and retains one platform handle per distinct
DLL. All Registry registration paths reject `CodeLifetimeUnavailable` when the
claimed owner module is absent or any entry image cannot be proven retainable.
Replacement and unregistration move retired Catalog/snapshot references out of
the Registry critical section before a final handle release can occur.

Focused evidence:

- Runtime directed build:
  `Saved/Build/staticjit-provider-address-lifetime-runtime/20260812_205333_576_51335b40`;
- Test-module directed build:
  `Saved/Build/staticjit-provider-address-lifetime-test/20260812_205351_828_b6d573ce`;
- Registry + MultiProvider + BindingPublication + ExecutionContext +
  ProjectScaffold, 28/28 PASS:
  `Saved/Tests/staticjit-provider-address-lifetime-regression/20260812_205417_089_c21ee304/Report`.

This proves actual `AngelscriptTest` DLL address retention, unavailable-owner
rejection, active-call retirement, conflict/recovery order independence,
unrelated-provider continuity, and two-Engine isolation. At this checkpoint
tasks 3.6 and 3.8 remained unchecked until the dedicated `AngelscriptTestJIT`
carrier existed and a physical carrier unload/reload test proved the final
ModuleManager boundary.

### Tasks 3.6 and 3.8 dedicated carrier closure — 2026-08-13

The real `AngelscriptTestJIT` module is now explicitly unloaded through
`FModuleManager::UnloadModule(..., bAllowUnloadCode=true)` while its retired
catalog is retained. Current Registry selection removes only TestJIT; project
and plugin-shaped providers remain visible. The old committed generated entry
continues to execute and returns `87`, proving that the Runtime-owned image
lease protects callable code rather than only copied metadata. Reload then
republishes the unchanged ProviderId/generation. The Registry discovery test
was also corrected to treat already discovered providers as a baseline instead
of assuming a single-provider process.

Evidence:

- Editor build after the real carrier test:
  `Saved/Build/staticjit-real-provider-retirement-test-compile-fix/20260813_035359_571_11d1b858`;
- real carrier/multi-provider/module-order matrix, 6/6 PASS:
  `Saved/Tests/staticjit-real-provider-retirement-runtime-prefix/20260813_035515_264_d606657d/Report`;
- active-reader and two-Engine Binding retirement, 5/5 PASS:
  `Saved/Tests/staticjit-provider-retirement-binding-publication/20260813_035629_875_d1b826f8/Report`;
- initial stale Registry baseline, 6/7 PASS, followed by the baseline-aware
  build and 7/7 PASS:
  `Saved/Tests/staticjit-provider-retirement-registry/20260813_035720_264_380316a4/Report`,
  `Saved/Build/staticjit-provider-registry-baseline-fix/20260813_035903_276_c2c3df72`, and
  `Saved/Tests/staticjit-provider-retirement-registry-green/20260813_035925_752_08a6331d/Report`;
- VM/Raw/Parms and re-entrant execution context, 5/5 PASS:
  `Saved/Tests/staticjit-provider-retirement-execution-context/20260813_040019_673_2ddfe7c8/Report`.

Tasks 3.6 and 3.8 are closed. Detailed lifetime ownership, failure behavior,
and RED/GREEN history are in
`attachments/provider-dll-lifetime-and-retirement.md`.

## Milestone 6.1 TestJIT Ownership Evidence — 2026-08-12

The Editor-only `AngelscriptTestJIT` shell and fixed ProviderId are now present
with dependency direction `Runtime <- TestJIT <- Test`. Ownership/identity
tests pass 3/3 at
`Saved/Tests/staticjit-testjit-providerid-green-tests/20260812_210500_603_925ef90d/Report`,
after the expected RED evidence and required full Editor target receipt rebuild
recorded in `attachments/testjit-module-and-package-boundary.md`.

The Development Game package compiled/cooked/staged/archived successfully and
its receipt/archive exclude both TestJIT and Test. The overall smoke then
correctly failed on the pre-existing ignored `Script/PrecompiledScript.Cache`;
that progressive issue is reserved for the explicit task 6.4/10.4 legacy-cache
migration rather than being silently removed during module ownership work.

## Milestone 5 Deterministic Generation Evidence — 2026-08-12

### Task 5.1 deterministic generation goldens

Task 5.1 is complete. Runtime now exposes a host-neutral deterministic
generation contract that accepts complete stable function/provider metadata
and produces content-addressed per-function slices, all 32 fixed bucket files,
provider header/source and JSON metadata, plus a sorted owned-file inventory.
Bucket assignment is exactly `ReadLE64(StableFunctionKey[0..7]) mod 32`;
symbols and paths retain the full 256-bit function key and full 256-bit
Execution hash. Stable references sort by complete descriptor before their
contiguous slot indices are assigned.

The golden matrix covers a frozen key/symbol/path/bucket/include shape,
provider/reference metadata, byte-identical output from reversed function and
reference input order, and removed-function cleanup that removes only the old
content-addressed slice from the current owned inventory while retaining all
32 bucket translation units.

Evidence:

- RED build, failed first on the intentionally missing
  `StaticJIT/AngelscriptJITGeneration.h` contract:
  `Saved/Build/staticjit-m5-generation-red/20260812_171557_699_42846de3`;
- first implementation build also exposed an existing adaptive non-unity test
  include dependency and one test-only `ByteArray` container assumption:
  `Saved/Build/staticjit-m5-generation-green1/20260812_171955_322_ed26b57c`;
- GREEN Development Editor build after the local test fixes:
  `Saved/Build/staticjit-m5-generation-green2/20260812_172034_530_90b809b0`;
- deterministic generation golden matrix, 3/3:
  `Saved/Tests/staticjit-m5-generation-determinism/20260812_172100_116_079ca192/Report`.

### Task 5.2 real bytecode emission and stable reference handoff

Task 5.2 is complete. The real `FAngelscriptStaticJIT` bytecode emitter now
supports a Provider generation mode that assigns content-addressed symbols,
emits one independently owned slice per current verified function, suppresses
numeric `FStaticJITFunction(FunctionId, ...)` registration in those slices,
and feeds exactly 32 deterministic bucket translation-unit contents plus the
provider header/source, manifest, and owned-file inventory through the shared
Runtime generator.

Generation requires the current Engine's complete verified function routes and
current successful artifact publication. Clean capture and exact-startup
publication now expose a storage-neutral
`FAngelscriptFunctionArtifactReferenceSet` beside each verified function
identity. It contains only sorted, deduplicated stable kind/key/ABI values; no
Cache record coordinate, numeric FunctionId, or live pointer crosses into the
generator. A real `Alpha -> Helper` fixture proves that the caller's provider
entry and generated provider source contain a required `ScriptFunction` slot,
while leaf functions retain valid empty reference tables.

The production primitive is now named
`GenerateStaticJITProviderArtifacts`; project/test filesystem orchestration
remains outside Runtime for tasks 5.4-5.7 and 6.3. Compiling the emitted files
inside the fixed Editor-only `AngelscriptTestJIT` carrier remains task 6.2.
The old generator's `FJitRef_*` compile dependencies remain available during
the staged parity period and are removed with `FJITDatabase` in task 10.3;
Provider identity/reference metadata no longer derives from those legacy
numeric registrations.

Evidence:

- RED build of the new real-caller assertion:
  `Saved/Build/staticjit-m5-provider-references-red-build/20260812_174113_173_7099df22`;
- RED actual emission prefix, 5/6, failing only because Alpha's stable Provider
  reference table was empty:
  `Saved/Tests/staticjit-m5-provider-references-red2/20260812_174213_710_043f700d/Report`;
- GREEN Development Editor build after adding the neutral verified-reference
  handoff and production generator consumption:
  `Saved/Build/staticjit-m5-provider-references-green1/20260812_174501_696_4e4c819a`;
- real GeneratedOutput emission matrix, 6/6:
  `Saved/Tests/staticjit-m5-provider-references-green1/20260812_174653_827_1326adf5/Report`;
- deterministic generator plus Cache global-function capture/restore
  regression, 4/4:
  `Saved/Tests/staticjit-m5-provider-references-regression/20260812_174806_401_99c56c1e/Report`.

### Task 5.3 explicit target profiles and mismatch boundaries

Task 5.3 is complete. Runtime generation now requires one concrete
`EditorDevelopment`, `GameDevelopment`, or `GameShipping` target profile.
Each profile exposes explicit `EDITOR`, `EDITORONLY_DATA`, `RELEASE`, `TEST`,
cooked-binding, development-script, and editor-script traits for later
isolated-Engine orchestration; generation does not infer those values from the
Editor tool host. `All` remains a command-orchestration selection only and is
rejected by the single-profile emission primitive.

The native environment fingerprint is target-bound and deterministically
includes the current generation schema, Provider ABI revision, all explicit
profile traits, and a sorted/deduplicated list of orchestration-supplied
platform/toolchain/binding inputs. Generated output and the provider manifest
retain the selected target profile. The three profiles produce pairwise
different artifact profiles, native environment fingerprints, and
ProviderGenerations for the same stable function content.

The focused matcher matrix starts from an exact Editor provider selection,
then independently crosses the profile, environment, and entry-ABI boundaries
and proves the typed `ProfileMismatch`, `EnvironmentMismatch`, and
`EntryAbiMismatch` results. No boundary is resolved by provider registration
or load order.

TDD and regression evidence:

- RED Development Editor build, failing on the intentionally absent target
  profile contract:
  `Saved/Build/staticjit-m5-profiles-red/20260812_175512_533_88a8b282`;
- first GREEN Development Editor build:
  `Saved/Build/staticjit-m5-profiles-green1/20260812_175659_259_137d0dcf`;
- initial focused target-profile matrix, 3/3:
  `Saved/Tests/staticjit-m5-profiles-green1/20260812_175722_193_407f1694/Report`;
- complete StaticJIT regression after the production contract change, 87/87:
  `Saved/Tests/staticjit-m5-profiles-full-regression/20260812_175810_459_34c6d162/Report`;
- final build after pairwise and input-order assertions:
  `Saved/Build/staticjit-m5-profiles-final-build/20260812_180026_692_f8a4e515`;
- final focused target-profile matrix, 3/3:
  `Saved/Tests/staticjit-m5-profiles-final/20260812_180046_624_48b26d99/Report`.

### Task 5.4 owned-file publication and read-only project verification

Task 5.4 is complete. Runtime now owns a filesystem-neutral generated-file
store over `FAngelscriptJITGenerationOutput`; Editor owns only project
Generate/Verify orchestration. Every generated C++/JSON file carries the
current ownership revision, while `OwnedFiles.generated.json` additionally
records the concrete target profile, ProviderId, ProviderGeneration, and the
complete sorted file set.

Publication validates all expected paths and existing ownership before it
writes anything. Changed owned files are staged beside their destinations and
individually replaced through `IFileManager::Move`, the inventory is published
last, stale files are removed only when both the previous inventory and a
current ownership marker agree, and byte-identical files are left untouched so
their timestamps remain stable. Empty/broad roots, malformed inventories,
marker/revision conflicts, cross-profile reuse, and cross-Provider reuse fail
closed without partial writes.

Editor Verify materializes the expected bytes beneath a unique isolated child
of the caller-provided temporary root, checks that staged output through the
same Runtime comparison primitive, compares the real output root read-only,
and deletes only that exact temporary child. Missing, stale, unexpected-owned,
ownership, profile, Provider, inventory, and read failures are typed; byte
mismatches retain expected and actual BLAKE3 hashes.

During final static checking, the legacy AOT emitter's exception-cleanup
comment was also corrected to join variable positions without a trailing
comma/space. The checked-in generated fixture was updated to the same bytes,
and its focused generation Verify proves the source and fixture remain in
sync.

TDD and regression evidence:

- RED build, failing first on the intentionally absent generated-file-store
  contract:
  `Saved/Build/staticjit-m5-file-store-red/20260812_180523_404_97cd14b1`;
- first implementation build, reaching only a test-parenthesis compile error:
  `Saved/Build/staticjit-m5-file-store-green1/20260812_181027_099_7a892bb5`;
- GREEN Development Editor build:
  `Saved/Build/staticjit-m5-file-store-green2/20260812_181102_247_062241f9`;
- initial project publication/Verify matrix, 3/3:
  `Saved/Tests/staticjit-m5-file-store-tests1/20260812_181125_407_a4d249c1/Report`;
- final build after broad-root and preflight hardening:
  `Saved/Build/staticjit-m5-file-store-final-build/20260812_181308_445_3f5dc9bb`;
- final focused project publication/Verify matrix, 3/3:
  `Saved/Tests/staticjit-m5-file-store-final/20260812_181331_281_bdb3a9b5/Report`;
- deterministic generation/profile regression, 6/6:
  `Saved/Tests/staticjit-m5-file-store-generation-regression/20260812_181416_625_3c1d78b8/Report`;
- complete StaticJIT regression, 90/90:
  `Saved/Tests/staticjit-m5-file-store-full-regression/20260812_181554_125_32f0c073/Report`;
- Development Editor build after the AOT emitter formatting correction:
  `Saved/Build/staticjit-m5-file-store-post-generator-fix/20260812_181854_148_7a8e16b3`;
- focused checked-in AOT generated-output Verify, 1/1:
  `Saved/Tests/staticjit-m5-file-store-aot-generated-verify/20260812_182006_886_6c118080/Report`.

`git diff --check` reports no whitespace errors after the generator/fixture
correction; line-ending conversion notices remain informational only.

### Task 5.5 fixed project module scaffold contract

Task 5.5 is complete. `AngelscriptEditor` now owns a project-scaffold service
for exactly `Source/AngelscriptJIT`. It structurally reads and writes the
`.uproject` JSON, preserves unrelated descriptor fields/modules, and accepts
only one `AngelscriptJIT` descriptor with `Type=Runtime` and
`LoadingPhase=PostDefault`; conflicting or duplicate reserved descriptors
abort before any source or descriptor write.

The scaffold creates a revision-marked Build.cs with a private
`AngelscriptRuntime` dependency, a compilable module shell that registers and
unregisters `IAngelscriptJITArtifactProvider` through Core modular features,
and exactly 32 fixed bucket translation units. The module shell returns no
Provider view before generated output exists and automatically consumes the
generated Provider header after a later Generate/full build. It has no Editor,
`AngelscriptTest`, or `AngelscriptTestJIT` dependency.

ProviderId is derived by the Runtime canonical writer from the normalized
project descriptor path, normalized project `Script/` root, and the fixed UE
module name. Equivalent paths collapse to one identity, while separate
projects with the same project/module names remain different ownership
domains.

Scaffold preflights every reserved path before staging any bytes. An absent,
old-revision, wrong-kind, or user-owned path is never overwritten. Current
scaffold-owned files are atomically replaced only when their bytes change;
unchanged descriptors/files preserve timestamps. Generated bucket files with
the current JIT ownership marker are explicitly accepted and preserved, so a
later Scaffold cannot erase real Generate output. Unrelated user extension
files beneath the module remain untouched. Inspection verifies descriptor,
target eligibility, Runtime dependency, module source, and the exact fixed
bucket count.

TDD and regression evidence:

- RED Development Editor build, failing only on the intentionally missing
  `StaticJIT/AngelscriptJITProjectScaffold.h` contract:
  `Saved/Build/staticjit-m5-scaffold-red/20260812_182436_317_942c3a87`;
- first implementation build reached a single missing DLL export on the
  inspection result's `Summary()` method:
  `Saved/Build/staticjit-m5-scaffold-green1/20260812_182854_403_049db535`;
- first GREEN Development Editor build after exporting the public result
  structures:
  `Saved/Build/staticjit-m5-scaffold-green2/20260812_182925_709_3d570f89`;
- initial fixed-module/path/profile/conflict/idempotency matrix, 4/4:
  `Saved/Tests/staticjit-m5-scaffold-tests1/20260812_182951_921_470cf1d6/Report`;
- final Development Editor build after marker-kind hardening and generated
  bucket preservation coverage:
  `Saved/Build/staticjit-m5-scaffold-final-build/20260812_183118_526_ad982f2c`;
- combined project Generate/Verify/Scaffold regression, 7/7:
  `Saved/Tests/staticjit-m5-project-tooling-regression/20260812_183142_392_02f29db7/Report`;
- complete StaticJIT regression, 94/94:
  `Saved/Tests/staticjit-m5-scaffold-full-regression/20260812_183225_060_06509cb5/Report`.

Focused `git diff --check` reports no whitespace errors in the scaffold
service or its tests.

### Task 5.6 project commandlet and real isolated generation

Task 5.6 is complete. `AngelscriptEditor` now owns the
`UAngelscriptJITCommandlet` and a separately testable command service with
stable `Scaffold`, `Generate`, and `Verify` modes, concrete
`EditorDevelopment` / `GameDevelopment` / `GameShipping` profiles, `All`
expansion, explicit project/temporary-root selection, and stable success,
execution-failure, invalid-argument, and scaffold-required exit codes. Runtime
continues to own only target-profile, deterministic emission, provider ABI,
and generated-file primitives; project descriptor/source discovery and
publication remain Editor-owned and neither path depends on `AngelscriptTest`
or the future `AngelscriptTestJIT` module.

Project generation creates a fresh isolated `FAngelscriptEngine` for each
profile, discovers only the selected project's `Script/` root, applies
explicit target preprocessor flags instead of inheriting the commandlet host,
collects every successful AS module, and emits them as one sorted Provider.
The fixed scaffold now has root profile selectors and exactly 32 compilable
bucket translation units; profile provider/bucket bodies are inert generated
includes selected by UE target macros.

The first real Generate/Verify run exposed an old archive-local
`FJitRef_Function` declaration containing the current process address. The
Provider generation path now maps each verified ScriptFunction reference to
its sorted stable slot before emission. Generated callers use
`FAngelscriptJITGeneratedReferenceAccess` with `FScriptExecution` and the slot
index, so the current Engine-local Binding table supplies the callee at
runtime. Two independent full compilations of the same temporary project now
produce the same Provider generation and byte-identical source, and Verify
leaves the published manifest unchanged.

TDD and regression evidence:

- initial commandlet implementation build reached only two local compile
  errors after UHT generated the new commandlet:
  `Saved/Build/staticjit-m5-commandlet-green1/20260812_184715_630_267fed40`;
- first GREEN commandlet build:
  `Saved/Build/staticjit-m5-commandlet-green2/20260812_185019_500_0b4bb183`;
- command service/UObject seam before real generation, 4/4:
  `Saved/Tests/staticjit-m5-commandlet-final-tests/20260812_185201_063_a8543ded/Report`;
- RED real project generation/Verify, 4/5, proving the repeated compile
  produced stale `Provider.generated.inl` bytes:
  `Saved/Tests/staticjit-m5-production-builder-test/20260812_185601_972_512c1a92/Report`;
- diagnostic RED isolated the first mismatch to the process-specific
  `FREF_ProjectHelper(0x...)` constructor:
  `Saved/Tests/staticjit-m5-production-determinism-diag-test/20260812_185806_173_936f97da/Report`;
- GREEN build after stable ScriptFunction-slot emission:
  `Saved/Build/staticjit-m5-stable-function-slot-build/20260812_190335_604_ca8d98fc`;
- focused real Generate followed by read-only Verify, 1/1:
  `Saved/Tests/staticjit-m5-stable-function-slot-test/20260812_190407_085_5d428f29/Report`;
- final commandlet matrix including production generation, 5/5:
  `Saved/Tests/staticjit-m5-commandlet-stable-slot-final-tests/20260812_190600_830_ebdccfe0/Report`;
- combined project publication/scaffold regression, 7/7:
  `Saved/Tests/staticjit-m5-project-command-regression/20260812_190647_940_142d48d6/Report`;
- real generator/runtime-route regression, 6/6:
  `Saved/Tests/staticjit-m5-generated-output-stable-slot-regression/20260812_190725_300_d4a33ecf/Report`;
- complete StaticJIT regression, 99/99:
  `Saved/Tests/staticjit-m5-commandlet-full-regression/20260812_190824_812_6ca6b63e/Report`.

`git diff --check` reports no whitespace errors; line-ending conversion
notices remain informational only.

## Strict Per-AS-Module Layout Implementation

### Task 1 Provider ABI topology removal

The current Provider ABI is now revision 2. `FAngelscriptJITProviderView`,
provider validation/generation hashing, and copied Registry catalogs no longer
contain a bucket count or any other generated translation-unit topology. The
generator's revision-1 32-bucket layout remains only as a private, temporary
implementation detail until Tasks 2–4 replace and remove that emitter; it is
not observable through the Runtime Provider contract. No revision-1 adapter
was added.

TDD and regression evidence:

- RED build succeeded and the new focused test failed only because revision 1
  did not equal revision 2:
  `Saved/Build/staticjit-per-module-abi-red/20260812_194018_232_880c88ff` and
  `Saved/Tests/staticjit-per-module-abi-red/20260812_194036_927_0184258b/Report`;
- the first GREEN build attempt exposed one namespace qualification error in
  the private migration constant:
  `Saved/Build/staticjit-per-module-abi-green/20260812_194252_434_f0eb4a70`;
- corrected Development Editor build:
  `Saved/Build/staticjit-per-module-abi-green-r2/20260812_194325_457_640dbfd1`;
- Provider ABI matrix, 6/6:
  `Saved/Tests/staticjit-per-module-abi-green-tests/20260812_194343_463_879e043a/Report`;
- Provider Registry matrix, 6/6:
  `Saved/Tests/staticjit-per-module-registry-abi/20260812_194420_414_9984fa0b/Report`;
- Provider matching matrix, 5/5:
  `Saved/Tests/staticjit-per-module-match-abi/20260812_194457_248_faae3c64/Report`.

The focused source audit finds no `BucketCount`, `GeneratedBucketCount`, or
`InvalidBucketCount` in `AngelscriptRuntime/StaticJIT`.

### Tasks 5.1-5.3 strict per-AS-module generation

The shared generator now declares explicit input/output module records, sorts
modules by full StableModuleKey and functions by `(ModuleKey, FunctionKey)`,
and emits exactly one `Modules/<full-key>.jit.cpp` for each non-empty AS
module. Function body changes retain the module path; the module content hash
and Provider metadata change while unrelated module source bytes stay
identical. Generator schema and generated-file ownership are revision 2. The
current output contains no function-slice or fixed-bucket files.

The real provider builder resolves canonical module names from the current
Cache V2 publication and emits all functions in the same compiled AS module
into the same guarded translation unit. EditorDevelopment, GameDevelopment,
and GameShipping retain independent target identity and use their respective
exact `WITH_EDITOR && UE_BUILD_DEVELOPMENT`,
`!WITH_EDITOR && UE_BUILD_DEVELOPMENT`, and
`!WITH_EDITOR && UE_BUILD_SHIPPING` guards.

TDD and regression evidence:

- strict-layout RED, 0 passing module-source expectations under the old
  emitter:
  `Saved/Tests/staticjit-per-module-generator-red-tests/20260812_194717_391_1943a187/Report`;
- Development Editor build:
  `Saved/Build/staticjit-per-module-generator-green1/20260812_195453_273_bce89b78`;
- deterministic generation matrix, 8/8:
  `Saved/Tests/staticjit-per-module-generator-green-tests/20260812_195516_087_8f2a66ed/Report`;
- real compiled-project generated output, 6/6:
  `Saved/Tests/staticjit-per-module-generated-output/20260812_195552_597_92d6639f/Report`.

### Task 5.4 revision-2 publication and safe legacy migration

Project output now keeps module sources as real `.jit.cpp` files and renames
only the Provider implementation to `Provider.generated.inl`. Publication
reports exact added/removed module source paths, atomically replaces changed
owned bytes, preserves unchanged module bytes/timestamps, and preflights user
or cross-profile conflicts before publication. Verify materializes expected
bytes only under an isolated temporary root and never mutates project output.

Revision-1 inventories are removal-only migration input. The additional
hardening described in
`attachments/migration-revision-1-generated-layout.md` requires both an old
layout path and its exact old kind marker; arbitrary paths carrying a forged
old marker are ownership conflicts and are not deleted.

Evidence:

- initial revision-1 migration RED:
  `Saved/Tests/staticjit-per-module-store-red/20260812_195850_077_ccd17805/Report`;
- first GREEN build:
  `Saved/Build/staticjit-per-module-store-green/20260812_200121_770_30564d4a`;
- project publication/migration matrix, 4/4:
  `Saved/Tests/staticjit-per-module-store-green-tests/20260812_200142_200_29ae9e15/Report`;
- profile isolation/guards, 3/3:
  `Saved/Tests/staticjit-per-module-profile-green-tests/20260812_200221_693_290144c5/Report`;
- forged legacy-path RED, 3/4:
  `Saved/Tests/staticjit-legacy-path-hardening-red/20260812_201458_154_6fb4076d/Report`;
- hardened build and GREEN matrix, 4/4:
  `Saved/Build/staticjit-legacy-path-hardening-green/20260812_201602_309_4fecde57` and
  `Saved/Tests/staticjit-legacy-path-hardening-green-tests/20260812_201619_462_6d416349/Report`.

### Tasks 5.5-5.7 bucket-free project tooling

The `Source/AngelscriptJIT` scaffold now owns only Build.cs, the Runtime module
entry, and the Provider selector header/source. It emits no fixed bucket
translation units. Recognized revision-1 scaffold buckets are removed;
unowned lookalikes stop the upgrade without writes or deletion. A second
current Scaffold is byte/timestamp preserving.

Generate and Verify consume real per-profile module `.jit.cpp` output.
Project/command results expose exact added/removed module sources and
`bRequiresFullBuild`; content-only replacement keeps it false, while module
source-set changes set it true. Verify reports Provider/profile/ABI identity,
full StableModuleKey, CanonicalModuleName, ModuleSource, stable function key,
symbol, hashes, and every owned-file difference. Stale Verify is read-only and
returns non-zero.

`Tools/RunAngelscriptJIT.ps1` validates mode/profile, reads project and engine
paths from `AgentConfig.ini`, writes isolated logs/metadata beneath
`Saved/AngelscriptJITRuns/<label>/`, applies an explicit timeout, omits Profile
for Scaffold, and preserves the commandlet exit code.

Evidence:

- Development Editor build:
  `Saved/Build/staticjit-per-module-command-green1/20260812_200906_983_3d5cdb48`;
- bucket-free scaffold matrix, 6/6:
  `Saved/Tests/staticjit-per-module-scaffold-green-tests/20260812_200934_302_2ae76879/Report`;
- commandlet/service/real generation matrix, 6/6:
  `Saved/Tests/staticjit-per-module-command-green-tests/20260812_201009_811_58bfc3c8/Report`;
- project generation matrix, 4/4:
  `Saved/Tests/staticjit-per-module-project-green-tests/20260812_201213_169_1da25ea4/Report`;
- wrapper PowerShell parser passed, and an actual read-only Verify against the
  currently unscaffolded host propagated `ScaffoldRequired` exit code 3:
  `Saved/AngelscriptJITRuns/staticjit-wrapper-scaffold-required/20260812_201253_811_2003468f`.

The rewritten Task 4 scaffold tests were introduced alongside the bucket-free
implementation, so no retroactive new-layout scaffold RED run is claimed.
Historical revision-1 scaffold RED/GREEN evidence above remains superseded by
this current 6/6 contract.

## Milestone 6.2-6.6 TestJIT and Cache V2 closure — 2026-08-13

The fixed Editor-only `AngelscriptTestJIT` carrier now contains the committed
provider and plugin-owned probes, while `AngelscriptTest` owns the independent
`-run=AngelscriptTestJIT -Mode=Generate|Verify` orchestration and all test
fixtures. Strict output contains exactly two module translation units for the
two non-empty AS modules: 2 plus 44 functions, with 46 total provider entries.

The legacy paired `StaticJITAotFixture.Cache`, generated `.jit.hpp`, aggregate
JIT info/code sources, availability APIs, and runner fallback are removed.
Normal source-driven tests publish an engine-local in-memory Cache V2 current
snapshot without Store persistence. The dedicated fresh-Engine proof flushes
Engine A, destroys it, creates Engine B, consumes the persisted two-module
candidate, restores 46/46 functions, rebuilds B-local reference slots, and
executes the exact Native route.

A real test-wrapper configuration bug found during this migration is fixed:
an explicit `bDisableCacheV2Persistence=true` is no longer overwritten merely
because the test supplies an isolated cache-root override. Disabled persistence
still retains in-memory compile capture because provider selection requires
the current artifact snapshot; an attempted broader suppression produced the
expected fail-closed VM routes and was reverted. The final regression proves
valid in-memory `Current`, no Store reuse publication, and no shutdown files.

The reproducible external workflow passed:

```text
Generate commandlet:
Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit-workflow_02_generate/
  20260813_044928_793_96ca6dea/Commandlet.log

Generated-source build:
Saved/Build/staticjit-testjit-workflow_03_generated_rebuild/
  20260813_045114_515_7a0e0cc6

Verify commandlet:
Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit-workflow_01_verify/
  20260813_045122_966_eb92a943/Commandlet.log

Post-Verify AOT:
Saved/Tests/staticjit-testjit-workflow_02_tests/
  20260813_045247_211_6786e74d/Report
Totals: total=18 passed=18 failed=0 skipped=0
Provider routing: verified=46 exact=46 native=46 vm=0 references=37/37
```

Adjacent final prefixes pass: TestModuleOwnership 7/7, UASFunction 3/3, and
Cache.StaticJITIsolation 3/3. The focused disabled-persistence regression is
1/1. Detailed TDD history, cache semantics, performance/lifetime reasoning,
exact report paths, and the non-counted runner-lock observation are recorded
in `attachments/testjit-cache-v2-and-stable-reference-emission.md`.

Tasks 6.2-6.6 are closed. The overall change remains in progress at group 7;
no Editor/PIE, Live Coding, project-provider, packaged Shipping, or final-suite
completion is claimed by this milestone.

## Milestone 7 host `AngelscriptJIT` Provider closure — 2026-08-13

The real host project now contains the fixed Runtime/PostDefault
`Source/AngelscriptJIT` carrier and generates three independent target
profiles. EditorDevelopment contains 9 AS-module translation units and 19
entries; GameDevelopment and GameShipping each contain 8 module translation
units and 18 entries. Each physical source basename is
`<StableModuleKey>.<TargetProfile>.jit.cpp`, so the strict one-file-per-AS-
module/per-profile boundary is preserved while avoiding UE 5.8 UBT's
directory-flattened non-unity object-name collisions.

Four real integration defects were found and closed while moving beyond
isolated fixtures:

1. identical `<StableModuleKey>.jit.cpp` basenames in three profile folders
   collide in UBT even when their directories differ;
2. Provider-only generated sources inherited the Editor commandlet's
   `UE_BUILD_DEVELOPMENT` guard, which made Shipping compile an empty body and
   then fail with 54 unresolved entry symbols;
3. a negative `__has_include` result in the stable selector was not a tracked
   UBT dependency, so first Generate could leave a previously compiled null
   selector object until the selector timestamp changed;
4. Windows retention used a borrowed `GetModuleHandle()` result as though it
   were an owned loader reference, causing an access violation during module
   shutdown. The Runtime lifetime now uses balanced
   `GetModuleHandleExW(...FROM_ADDRESS...)` acquisition.

The selector uses exact target guards and Generate touches it only after all
requested profiles succeed and only when the generated module-source set
changes. Repeated Generate is byte- and timestamp-stable. The carrier tracks
its own modular-feature registration with `bRegistered`, so shutdown removes
exactly its own feature rather than querying whether any Provider exists.

Evidence:

- isolated scaffold/command service preflight, 10/10:
  `Saved/Tests/staticjit-host-project-isolated-preflight/20260813_050718_006_b1892a99/Report`;
- first null-provider Editor and Game builds:
  `Saved/Build/staticjit-host-project-first-editor-build/20260813_050910_319_beded275` and
  `Saved/Build/staticjit-host-project-first-game-build/20260813_051100_766_f30e8d6e`;
- initial real three-profile Generate:
  `Saved/AngelscriptJITRuns/staticjit-host-generate-all/20260813_051447_056_ffc3c557`;
- UBT duplicate-basename RED:
  `Saved/Build/staticjit-host-generated-editor-build/20260813_051654_424_c2d8bed2`;
- unique-basename profile tests, 3/3, and migrated Editor/Game builds:
  `Saved/Tests/staticjit-profile-basename-green/20260813_052213_410_e0d9b2b4/Report`,
  `Saved/Build/staticjit-host-generated-editor-build-green/20260813_052451_845_ca6cefd3`, and
  `Saved/Build/staticjit-host-generated-game-build/20260813_052507_949_e1773bf9`;
- Shipping 54-symbol RED:
  `Saved/Build/staticjit-host-generated-shipping-build/20260813_052538_303_a4684639`;
- exact profile guard, scaffold selector, and selector-invalidation matrices,
  each 6/6:
  `Saved/Tests/staticjit-profile-guards-green/20260813_053542_906_e2b6eadb/Report`,
  `Saved/Tests/staticjit-scaffold-guards-green/20260813_053637_921_132fce08/Report`, and
  `Saved/Tests/staticjit-selector-touch-green/20260813_053722_573_90e216e1/Report`;
- final real Editor, Development Game, and Shipping Provider builds:
  `Saved/Build/staticjit-host-profile-guards-editor-build/20260813_054054_057_0a0470a7`,
  `Saved/Build/staticjit-host-profile-guards-game-build/20260813_054111_876_c7c41419`, and
  `Saved/Build/staticjit-host-profile-guards-shipping-build/20260813_054143_662_b0ce91d9`;
- shutdown access-violation RED and balanced-reference GREEN Verify All:
  `Saved/AngelscriptJITRuns/staticjit-host-verify-all-final/20260813_054224_251_fc61f6d2` and
  `Saved/AngelscriptJITRuns/staticjit-host-dll-lifetime-green/20260813_054956_174_87828f5d`;
- precise scaffold/Registry/real carrier multi-provider lifecycle, 19/19:
  `Saved/Tests/staticjit-dll-lifecycle-regression/20260813_055350_403_b7963ae4/Report`;
- repeated real Generate, all profiles current, `RequiresFullBuild=false`,
  with 39/39 generated files preserving path, hash, length, and timestamp:
  `Saved/AngelscriptJITRuns/staticjit-host-repeat-generate-idempotency/20260813_055605_192_c4dbf3c8`.

The TestJIT committed output was migrated through its normal product workflow
to the same profile-qualified physical basename rule. Baseline build,
Generate, generated-source rebuild, and read-only Verify all exited zero.
The subsequent complete StaticJIT prefix passed 119/121 and exposed two stale
test-only guard expectations; after updating them to the already implemented
exact Development guards, both affected generation prefixes pass 8/8 at
`Saved/Tests/staticjit-generation-exact-guard-green/20260813_061203_788_73750144/Report`.
The other 119 tests were green in
`Saved/Tests/staticjit-testjit-profile-qualified-final_05_tests/20260813_060152_788_afaa2c5e/Report`.

Detailed host migration and build evidence is recorded in
`attachments/host-project-provider-generation.md`; the Windows loader root
cause is retained in `attachments/provider-dll-lifetime-and-retirement.md`.
Tasks 7.1-7.4 are closed. The overall change remains in progress at group 8;
Editor/PIE edit classification, Live Coding refresh, packaging/multi-start,
legacy global removal, diagnostics, benchmarks, docs, and final All-suite
verification are not yet complete.

## Milestone 8 partial Editor hot-reload route refresh — 2026-08-13

The first group-8 implementation slice found a real consumer-order gap rather
than an invalid Cache identity. Initial compile/restore already matched current
routes to Providers, but successful `PerformHotReload()` transactions stopped
after publishing the new Cache V2/current-function snapshot. Replacement
functions therefore could not reuse stale code, but even an unchanged exact
replacement remained VM because Provider matching was not run again.

The production hot-reload boundary now refreshes copied Provider catalogs only
after `CompileModules()` returns success: Cache mutation has ended, accepted
modules/ClassGenerator work/current routes are authoritative, and post-compile
consumers have not yet run. Failure exits before refresh and preserves the
last-good publication.

Behavioral RED and GREEN evidence:

- missing unchanged-function rebind RED, 0/1:
  `Saved/Tests/staticjit-editor-routing-red/20260813_062258_168_4bebc14b/Report`;
- fixed Editor route proof, 1/1:
  `Saved/Tests/staticjit-editor-routing-green-tests/20260813_062441_130_853b182d/Report`;
- expanded body/debug/failure/signature/delete matrix, 4/4:
  `Saved/Tests/staticjit-editor-routing-matrix-tests/20260813_062748_110_d95a1f73/Report`;
- current-binding UASFunction regression, 1/1:
  `Saved/Tests/staticjit-editor-uas-current-binding-green/20260813_062908_354_96c9094f/Report`;
- Cache function-route regression, 5/5:
  `Saved/Tests/staticjit-editor-cache-route-green/20260813_063003_016_25ffca3b/Report`.

The focused implementation build is
`Saved/Build/staticjit-editor-routing-green-build/20260813_062418_361_750ac90d`.
Detailed diagnosis, safe-point reasoning, typed route counts, global-function
diagram semantics, and remaining group-8 boundaries are recorded in
`attachments/editor-hot-reload-provider-routing.md`.

No group-8 checkbox is closed yet: explicit PIE and structural
metadata/layout/inheritance/import Provider observations plus broader focused
prefixes remain required before tasks 8.1-8.5 can be claimed complete.

## Milestone 8 automatic-import Cache repair and expanded Editor matrix — 2026-08-13

The expanded group-8 matrix now includes real PIE reflected dispatch,
structural class/layout/inheritance/metadata reload observed before
post-compile consumers, cross-Provider ambiguity, and the maintained
automatic-import cross-module path. The automatic-import case exposed and
fixed an incremental Cache V2 defect rather than changing the test to avoid
Cache.

During a provider-body-only reload, an unchanged consumer can temporarily have
compiler dependencies pointing to the predecessor provider function while its
reference-updated bytecode points to the successor. The accepted VM module also
uses a temporary hot-reload name. Cache authority now resolves the semantic
`baseModuleName`, matches the predecessor FunctionKey against the current
declaration, aliases both transient function pointers to the same stable
authority for the capture transaction, and excludes modules with a non-null
`ReloadNewModule` from detached-reader current-module selection. Persisted
records remain pointer-free and FunctionId-free; signature/owner mismatches and
unrelated same-name ambiguity still fail closed.

Focused evidence:

- repair build:
  `Saved/Build/cache-cross-module-dual-alias-build/20260813_071548_216_1f4ba2ac`;
- Cache-layer provider-only reload regression, 1/1:
  `Saved/Tests/cache-cross-module-dual-alias-green/20260813_071609_320_06e0f7b2/Report`;
- Editor automatic-import Provider routing, 1/1:
  `Saved/Tests/staticjit-auto-import-after-cache-fix/20260813_071712_263_c2989951/Report`;
- complete EditorRouting matrix, 8/8:
  `Saved/Tests/staticjit-editor-routing-cache-fix-matrix/20260813_071811_095_2ec29d57/Report`;
- complete Cache MultiModuleGeneration matrix, 5/5:
  `Saved/Tests/cache-multi-module-successor-regression/20260813_071941_141_23e816c5/Report`.

The forced legacy declared-import/CALLBND diagnostic is explicitly not treated
as a current automatic-import regression. Cache V2 still rejects manual import
tables during clean capture/restore; implementing that obsolete compatibility
shape would be a separate expansion. The full diagnosis, progressive REDs,
stable-identity constraints, and diagram treatment for global functions are in
`attachments/editor-hot-reload-provider-routing.md`.

## Milestone 8 complete Editor/PIE hot-reload routing — 2026-08-13

The remaining focused regressions and source audit close tasks 8.1-8.5. The
expanded Editor matrix proves the accepted current AS/ClassGenerator generation
is authoritative, exact unrelated functions remain Native, changed or
ambiguous functions fall back to VM, real PIE reflected dispatch consumes the
current binding, and structural changes remain owned by the hot-reload/class
reinstancing path. The automatic-import Cache repair also remains green under
the broader HotReload prefix.

Final focused evidence:

- current-binding UASFunction matrix, 3/3:
  `Saved/Tests/staticjit-editor-uasfunction-after-cache-fix/20260813_072157_635_7fee05e8/Report`;
- complete HotReload prefix, 122/122:
  `Saved/Tests/staticjit-editor-hotreload-after-cache-fix/20260813_072302_759_c6c883e7/Report`.

The development-mode audit intentionally keeps the existing early return in
`FAngelscriptStaticJIT::OnFunctionReady()`: all code below that return reads the
legacy process-global `FJITDatabase` by numeric `FunctionId`. The Engine-local
Provider lifecycle adapter is installed independently for every Engine and its
`FAngelscriptJITProviderRouter::Refresh()` calls execute in Editor startup and
successful hot reload without consulting that guard. Removing the condition
before task 10.3 would re-enable the superseded FunctionId attachment path; it
would not enable the Provider path, which is already active and covered.

Group 8 is complete. Live Coding generation/patch refresh remains group 9;
packaged immutable-set behavior and legacy global removal remain later groups.

## Milestone 9 explicit Live Coding refresh implementation — 2026-08-13

Tasks 9.1-9.3 and 9.5 are implemented. `AngelscriptEditor` now owns an explicit
`Generate/Refresh AngelScript JIT` action and a testable refresh state machine.
It recompiles authoritative AS source first, publishes only owned
`EditorDevelopment` generated files, rejects added/removed per-module source
sets with an exact full-build requirement, and invokes the Editor-only Live
Coding backend only for an already active source graph.

Patch completion observes and validates the live Provider view before Registry
replacement. Only the exact expected generation/artifact/profile/environment
is registered and routed; stale, unexpected, invalid, or unpinnable code never
replaces the copied catalog through this service. Save-time directory-watcher
handling remains AS recompile/invalidation only.

Evidence:

- intentional undefined-service/link RED:
  `Saved/Build/staticjit-livecoding-service-red/20260813_073326_163_a61fc767`;
- final focused build:
  `Saved/Build/staticjit-livecoding-prevalidate-build/20260813_074513_665_9e04cc36`;
- fake-backend state matrix, 5/5:
  `Saved/Tests/staticjit-livecoding-prevalidate-tests/20260813_074535_933_40166ea4/Report`;
- Editor menu, module lifecycle, and save-time silence prefix, 14/14:
  `Saved/Tests/staticjit-livecoding-editor-action-tests/20260813_074147_108_550b3465/Report`.

Detailed lifecycle, source-set reasoning, typed outcomes, and the UE 5.8
backend constraint are recorded in
`attachments/live-coding-refresh-service.md`. Task 9.4 remains open for the
opt-in real Editor smoke with Live Coding actually started; headless automation
does not claim that external session.

## Milestone 10 packaged Provider parity — 2026-08-13

Tasks 10.1 and 10.2 are complete. The C++ matrices cover both
`GameDevelopment` and `GameShipping`, complete immutable-set acceptance,
stale/partial rejection, ProviderId conflict and recovery, VM fallback,
multi-Provider/multi-AS-module coexistence, actual `AngelscriptTestJIT` module
departure/reload, and delayed code-lifetime retirement. Stable selection is
also proved independent of transient FunctionIds, pointers, and engine/cache
creation order.

The pre-cutover broad prefix run reached its configured total timeout rather
than a test failure:
`Saved/Tests/staticjit-pre-legacy-cutover/20260813_101000_091_68270a60`.
At termination it had started 114 tests and completed 113 successfully, with
no failed test. The complete task-10 groups within that run were:

- `ImmutableArtifactSet` 5/5;
- `MultiProvider` 6/6;
- `PackagedProvider` 3/3;
- `BindingPublication` 5/5.

The wide prefix must therefore be split or run with a larger final gate; the
timeout itself is not recorded as a passing full-prefix result.

Fresh process/archive evidence is independent of C++ automation:

- Development:
  `Saved/StaticJITPackage/staticjit-provider-development-predefault-final-Development/20260813_100413_445_817f3901`;
- Shipping:
  `Saved/StaticJITPackage/staticjit-provider-shipping-sideeffect-fixed-Shipping/20260813_100132_684_a63da84f`.

Both configurations passed BuildCookRun, configuration-specific game-link
response inspection, source/build-rule and archive dependency exclusion, and
two clean process starts. Each process selected one packaged Provider with
8 AS modules, 18/18 exact Native functions, 0 verified VM fallbacks, and 12/12
resolved stable references. The two starts in each configuration had identical
ProviderId, ProviderGeneration, module/function route set, and route counts.
Shipping used the schema-v5 structured process report because optimized builds
do not emit the Development startup route log.

## Milestone 10 legacy global activation removed — 2026-08-13

After Development/Shipping package parity and the focused source/Cache/Editor
matrices passed, the superseded process-global activation path was deleted.
There is no remaining `FJITDatabase`, `FStaticJITCompiledInfo::ActiveInfo`,
persisted FunctionId registration, whole-cache `DataGuid` activation,
`FJitRef_*`/`FJitVerify*` helper, legacy cutover reader, compatibility flag, or
dual-write branch in Runtime source. The old committed `.Cache`, `.jit.hpp`,
aggregate code/info outputs, and their archive/cutover tests are also removed.

Evidence:

- Runtime and generated-artifact scans:
  `NO_LEGACY_RUNTIME_MATCHES`, `NO_LEGACY_GENERATED_FILES`;
- post-deletion Editor build:
  `Saved/Build/static-jit-legacy-cutover-r2/20260813_110315_768_ae698f6b`;
- real Provider generation plus diagnostics/dump regression, 13/13:
  `Saved/Tests/static-jit-diagnostics-generated-r8/20260813_112319_274_8fd18d01/Report`.

No migration/compatibility path was introduced. Detailed deletion scope is in
`attachments/packaged-provider-and-legacy-cutover.md`. Tasks 10.3 and 10.4 are
closed; the broader task-11.6 final gates remain open.

## Milestone 11.1-11.3 diagnostics and offline inspector — 2026-08-13

StaticJIT diagnostics now serialize deterministic schema-v2 Provider/Route
records. They include ABI/publication/route generations, Provider and AS-module
ownership, strict generated module-source paths and module artifact digests,
complete function identities, VM/Raw/Parms availability, current stable
reference resolution, selected and candidate Provider generations, typed
miss/conflict results, transient FunctionId context, immutable-dispatch state,
and execution counters. Serialization sorts all stable records and emits no
process address.

`as.StaticJIT.DumpDiagnostics` handles no Engine/no Provider safely, logs a
compact summary plus JSON, writes an explicit output path, and filters by
canonical declaration or full stable FunctionKey through `-Function`. Capture
reads production Registry/Route/Binding/reference surfaces without adding
Engine test APIs or publishing state.

TDD evidence:

- schema-v2 RED, 2/4 passing with the new schema/query tests failing:
  `Saved/Tests/static-jit-diagnostics-schema-red-r2/20260813_113148_963_3226920e/Report`;
- implementation build:
  `Saved/Build/static-jit-diagnostics-schema-green-build-r2/20260813_113927_788_ffa0ed4b`;
- schema/query GREEN, 4/4:
  `Saved/Tests/static-jit-diagnostics-schema-green-r3/20260813_113948_806_0b693fe2/Report`;
- deterministic two-Provider exact-conflict GREEN, 1/1:
  `Saved/Tests/static-jit-diagnostics-conflict-green-r2/20260813_115158_282_48d52a67/Report`.

The first conflict fixture run asserted inside UE's hex parser because the test
misused `FBlake3Hash(FWideStringView)` with a non-hex seed. It was corrected to
the project canonical writer; production behavior did not change.

The standard-library-only
`Tools/Diagnostics/InspectStaticJITDump.py` validates schema/ABI, stable hash
shape, ordering, Provider/module/function membership, module function counts,
reference slots, Route totals, candidate generations, and Native/VM/result
consistency. Checked-in valid, mismatch, and malformed fixtures produce exit
codes `0`; `0` or `2` with `--fail-on-mismatch`; and `1`, respectively.

Full diagnostics capture rebuilds a current Engine reference resolver to report
real reference outcomes. The 4/4 schema run took 223.8 seconds because it
intentionally captured repeatedly; diagnostics are an explicit troubleshooting
operation, not per-frame telemetry. Detailed schema, commands, timing, and the
diagnostic-only memory-artifact seam are in
`attachments/diagnostics-provider-route-cutover.md`. Tasks 11.1-11.3 are
closed; benchmarks, documentation, real Live Coding smoke, and final broad
verification remain open.

## Milestone 11.4 benchmark and reference-resolution optimization — 2026-08-13

Task 11.4 is complete. Runtime routing now reports separate Provider-catalog,
reference-discovery, stable-reference-resolution, route-match/publication, and
total durations. The initial 46-route/37-reference sample proved that Registry
and matching were not the bottleneck:

```text
before current source:
  catalog=0.001 discovery=0.032 references=12116.510 routes=0.092 total=12116.643 ms
before fresh source session:
  catalog=0.001 discovery=0.033 references=12518.721 routes=0.090 total=12518.853 ms
```

The current reference builder had invoked three full application-surface scans
for each `EnvironmentSymbol`. It now creates the requested EnvironmentSymbol
index with one pass across current registered types, functions, properties,
code roots, and their current ABIs. The resolver remains Engine-local and tied
to the immutable current Cache V2 publication; no process pointer is cached
across compile generations. The same samples are:

```text
after current source:
  catalog=0.001 discovery=0.018 references=696.227 routes=0.093 total=696.346 ms
after fresh source session:
  catalog=0.001 discovery=0.018 references=763.188 routes=0.130 total=763.346 ms
```

This is an approximately 94.3% reduction in the current-source stable-reference
phase. The complete isolated fresh Cache V2 + JIT execution fixture decreased
from 102.15 s to 86.54 s while still restoring 46 functions and reporting the
same three compiled misses, three not-cacheable functions, and six frontend
events.

Behavior and build evidence:

- GREEN Runtime build:
  `Saved/Build/static-jit-reference-batch-index-build-r2/20260813_121216_832_60e3c612`;
- current-source plus fresh-Cache Native execution, 2/2:
  `Saved/Tests/Tests/static-jit-reference-batch-index-benchmark/20260813_121237_229_646d65ab/Report`;
- stable slot and Cache environment identity/resolver regression, 10/10:
  `Saved/Tests/Tests/static-jit-reference-batch-index-regression/20260813_121644_214_1ba79cf7/Report`;
- Editor changed-function VM / unchanged-consumer Native fallback, 1/1, with
  a 0.358 ms diagnostic refresh:
  `Saved/Tests/Tests/static-jit-editor-vm-fallback-benchmark/20260813_120444_034_2dbc8dd0/Report`.

Strict module rebuild measurements used `-NoXGE`, touched one validated
workspace-local generated source, restored its original timestamp, and built
successfully. Both the representative 11,948-byte/4-function project module
and the 136,259-byte/44-function TestJIT module compiled exactly one `.jit.cpp`
and linked only their owning carrier. Warm end-to-end UBT samples were 6.49 s
and 6.29 s respectively. Repeated generation independently preserved path,
hash, length, and timestamp for 39/39 files.

The current output scale is 9/19 project Editor files/functions, 8/18 project
GameDevelopment, 8/18 project GameShipping, and 2/46 TestJIT Editor. Production
direct script-to-script emission remains disabled: all 18 GameShipping entry
flags are zero. Both packaged Shipping launches nevertheless publish 18/18
validated Native Bindings, 0 VM, and 12/12 references. This change therefore
records the supported Native route baseline and defers immutable direct-call
emission to a separate optimization with explicit cross-translation-unit
coverage.

Raw data and methodology are under
`openspec/changes/refactor-as-static-jit-multi-provider/benchmarks/`.
Documentation, real Editor Live Coding smoke, and final broad verification
remain open.

## Milestone 11.5 Provider lifecycle documentation cutover — 2026-08-13

Task 11.5 is complete. The Chinese StaticJIT guide is now based on ABI Revision
2 Providers, copied immutable Registry catalogs, Engine-local stable routing,
Cache V2 authority, strict one-AS-module/one-profile-`.jit.cpp` ownership,
Editor/PIE invalidation, explicit Live Coding refresh, DLL/code-image leases,
schema-v2 diagnostics, package profiles, and the measured rebuild/reference
baseline. It explicitly explains that global functions belong to an AS module
instead of a UML class, and that production content-specific direct script-call
emission remains disabled.

Build, test, package, fork, HotReload, coverage, global-state, ThirdParty,
state-dump, root README, plugin README, and Chinese/English AGENTS facts were
synchronized. Historical HashMetadata and Angelsea research sections are
clearly marked as superseded where they retain the removed FunctionId/DataGuid
architecture. `FAngelscriptEngine::bStaticJITTranspiledCodeLoaded`, an unused
zero-initialized remnant with no remaining consumer, was removed so the public
engine surface no longer suggests a single process-global JIT activation bit.

Evidence:

- targeted parent/plugin `git diff --check`: clean;
- affected Editor compile: 135/135, `Result: Succeeded`, UBT 163.53 s,
  `Saved/Build/static-jit-doc-lifecycle-cleanup/20260813_123416_916_747bd084`;
- standard runner warm confirmation: exit 0/up to date,
  `Saved/Build/static-jit-doc-lifecycle-cleanup-r2/20260813_123754_491_69bd05b1`.

The detailed stale-claim list and file scope are recorded in
`attachments/documentation-provider-lifecycle-cutover.md`. The real same-Editor
Live Coding smoke and final task-11.6 broad gates remain open.

## Real Editor Live Coding smoke progress — 2026-08-13

Task 9.4 remains open, but the real-process smoke has now proved the first half
of the required state transition and isolated the remaining failure after the
actual Live Coding compile.

The prerequisite Cache/reference crash was fixed by replacing iteration of the
Engine FunctionId/history table with one shared current-registration collector.
It includes current registered globals, registered-type functions, and the
engine-owned `$obj`/`$func` behaviour surfaces while excluding externally
retained functions that have left the current registry. Evidence is the final
build at
`Saved/Build/static-jit-current-function-registry-green-r4/20260813_133145_712_e426cb14`,
focused 3/3 run at
`Saved/Tests/static-jit-current-function-registry-green-r4/20260813_133208_146_e75a405f`,
and full Cache Environment plus EditorRouting 15/15 run at
`Saved/Tests/static-jit-current-function-registry-full-green/20260813_133354_318_9a41c17d`.

The valid `Start-Process -PassThru`/`WaitForExit()` smoke at
`Saved/Tests/static-jit-real-livecoding-smoke-r4` exited 0 and produced a valid
pre-patch `Vm` route for `void ExecuteExampleMath()`: the edited current
execution hash was `dbdcba...`, while the old generation `cd412...` candidate
contained `94a2e4...` and reported `ContentMismatch`. This proves changed-
function Native-to-VM invalidation in the real Editor and confirms the cache
crash no longer occurs.

UBT compiled both the changed per-module `.jit.cpp` and
`Provider.generated.cpp`, then UE logged `Live coding succeeded`. The generated
source on disk contains generation `e3113f...`; nevertheless the running
Provider and `after.json` still expose `cd412...`, so the refresh retained VM
and reported a stale Provider generation. The leading hypothesis is an already-
initialized function-local static Provider view surviving the Live Coding
patch. No VM-to-Native or completed task-9.4 claim is made yet.

The complete reproducible procedure, exact stable keys, JSON oracle, source
restoration rules, command-separator/exit-command details, GUI-process
detachment pitfall, and completion criteria are in
`attachments/real-editor-livecoding-smoke.md`.

## Task 9.4 real Editor Live Coding acceptance complete — 2026-08-13

Task 9.4 is now complete. The intermediate real-process failures each crossed
one additional production boundary rather than being treated as equivalent
Live Coding failures:

- `r4` proved changed-source Native-to-VM fail-closed behavior but exposed a
  retained function-local static Provider view;
- `r5` refreshed scalar view data but exposed retained entry/reference arrays;
- `r6` refreshed the complete manifest and reached Registry code-image
  lifetime acquisition;
- the lifetime fix changed Windows acquisition to retain the authoritative
  loaded PE image directly from each entry address, including Live++ patch
  images, and added explicit registration-code diagnostics;
- invalid orchestration `r7` proved that `Start-Process -ArgumentList` had
  lost the `-ExecCmds` argument boundary, so the repeatable procedure now uses
  `ProcessStartInfo.ArgumentList` plus `WaitForExit()`;
- `r8` reached the stable-identity check and exposed `ProviderIdConflict`
  because Live Coding replaced the generated C++ provider object's address;
- Registry now permits an owner handoff only for an identical ProviderId,
  ProviderName, and OwnerModuleName while preserving conflict rejection for a
  genuinely different provider.

Focused RED/GREEN evidence:

- refresh diagnostic RED, 4/5:
  `Saved/Tests/static-jit-livecoding-lifetime-diagnostic-red/20260813_141427_738_4aa10469`;
- address-pin build:
  `Saved/Build/static-jit-livecoding-lifetime-address-pin-green-build/20260813_141622_231_8c20c3c3`;
- RefreshService + ProviderRegistry GREEN, 12/12:
  `Saved/Tests/static-jit-livecoding-lifetime-address-pin-green/20260813_141644_856_68130e7f`;
- owner-handoff RED, 7/8:
  `Saved/Tests/static-jit-livecoding-owner-handoff-red/20260813_142739_199_49012203`;
- owner-handoff build:
  `Saved/Build/static-jit-livecoding-owner-handoff-green-build/20260813_142915_071_8ed65536`;
- ProviderRegistry + MultiProvider + RefreshService GREEN, 19/19:
  `Saved/Tests/static-jit-livecoding-owner-handoff-green/20260813_142945_509_a24aa8c1`.

The decisive real Editor evidence is
`Saved/Tests/static-jit-real-livecoding-smoke-r9`. One
`UnrealEditor.exe` process exited 0 after approximately 101.6 seconds and
recorded the complete transition for stable function key
`283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112`:

```text
before.json:
  publication=2 routeGeneration=2
  route=Vm candidate=ContentMismatch
  currentExecution=dbdcba6970... oldGeneration=cd4129dd66...

Live Coding:
  succeeded
  published generation=e3113fde3f... Native=19 VM=0

after.json:
  publication=3 routeGeneration=5
  route=Native match=Exact entry=16 references=7/7
  generation=e3113fde3f...
  InspectStaticJITDump.py --fail-on-mismatch => exit 0
```

The temporary AS edit was restored immediately. Source, generated C++, DLL,
and manifest were returned to the normal `* 2.0` / `cd4129...` baseline and
verified independently:

- Generate:
  `Saved/AngelscriptJITRuns/static-jit-livecoding-r9-restore-generate/20260813_143312_610_b237fa9b`;
- Build:
  `Saved/Build/static-jit-livecoding-r9-restore-build/20260813_143419_339_2001351b`;
- Verify:
  `Saved/AngelscriptJITRuns/static-jit-livecoding-r9-restore-verify/20260813_143436_405_cbdd2676`.

The learning-oriented rationale, exact launch code, machine-readable oracle,
failure taxonomy, and cleanup rules are synchronized in the Chinese
`Documents/Knowledges/ZH/RT_StaticJIT.md` guide and
`attachments/real-editor-livecoding-smoke.md`. Task 11.6 broad final gates
remained open at that checkpoint.

## Task 11.6 impact-focused final acceptance — 2026-08-13

Task 11.6 is complete against the user-approved impact-focused matrix. The
configured `All` suite was retained as an optional diagnostic and stopped once
the directly affected surfaces had their own authoritative reports; unrelated
GAS, Widget, and other product prefixes were not repeated as completion gates.

### Focused automated and workflow evidence

| Gate | Result | Authoritative evidence |
| --- | ---: | --- |
| Native SDK JIT lifecycle | 6/6 PASS | `Saved/Tests/staticjit-final-native-jit-lifecycle/20260813_151842_138_39ed1230` |
| Runtime Engine | 130/130 PASS | `Saved/Tests/staticjit-final-runtime_01_Engine/20260813_155406_789_0c62fa9f` |
| Runtime CppTestsLegacy | 22/22 PASS | `Saved/Tests/staticjit-final-runtime_02_CppTestsLegacy/20260813_160156_911_61ad2e57` |
| Cache V2 | 546/546 PASS | `Saved/Tests/staticjit-final-cache-r2/20260813_153515_139_8fbf71aa` |
| StaticJIT, including multi-provider/multi-AS-module routes | 139/139 PASS | `Saved/Tests/staticjit-multiprovider-final-r3_02_tests/20260813_150849_863_d5fbae11` |
| HotReload | 122/122 PASS | `Saved/Tests/staticjit-final-hotreload_01_HotReload/20260813_160437_397_250caec8` |
| UASFunction current-binding matrix | 3/3 PASS | `Saved/Tests/staticjit-editor-uasfunction-after-cache-fix/20260813_072157_635_7fee05e8` |
| UASFunction publication regression | 3/3 PASS | `Saved/Tests/staticjit-m4-uasfunction-publication-regression/20260812_165057_441_87b0ade7` |
| Functional inheritance exact stack location after diagnostic fix | 5/5 PASS | `Saved/Tests/staticjit-final-functional-inheritance-green/20260813_172923_402_7302d904` |

The isolated TestJIT production-like sequence completed in order:

1. the generated-carrier rebuild passed at
   `Saved/Build/static-jit-testjit-livecoding-view-green-build-r2/20260813_144731_737_e8bff7cc`;
2. fixed carrier ownership/Live Coding view coverage passed 8/8 at
   `Saved/Tests/static-jit-testjit-livecoding-view-green/20260813_144802_389_5add2283`;
3. Generate wrote the committed fixtures at
   `Saved/StaticJIT/TestJIT/Commandlet/staticjit-multiprovider-final-r2_02_generate/20260813_144920_901_41b6518d`;
4. Verify was read-only and clean at
   `Saved/StaticJIT/TestJIT/Commandlet/staticjit-multiprovider-final-r3_01_verify/20260813_150708_375_e50e2b71`;
5. the generated-source reader fix rebuilt at
   `Saved/Build/static-jit-template-constructor-reader-green-build/20260813_150527_081_5c9e194c`, and its former crash case passed 1/1 at
   `Saved/Tests/static-jit-template-constructor-reader-green/20260813_150540_460_c6e40f8a`.

The real host-project workflow also completed with the current source:

- Scaffold reported `RequiresFullBuild=false`:
  `Saved/AngelscriptJITRuns/staticjit-final-project-scaffold-r2/20260813_161015_070_07d46f3f`;
- Generate All emitted all three profiles:
  `Saved/AngelscriptJITRuns/staticjit-final-project-generate-all/20260813_161107_596_4e7adeb8`;
- Verify All was read-only with `DifferenceCount=0`:
  `Saved/AngelscriptJITRuns/staticjit-final-project-verify-all/20260813_161305_092_132d8fcc`.

Strict source-layout inspection found exactly one physical `.jit.cpp` for every
non-empty AS module in every generated profile and no current bucket source:

| Profile | AS modules | Functions | Unique sources | Physical sources | Bad suffixes |
| --- | ---: | ---: | ---: | ---: | ---: |
| EditorDevelopment | 9 | 19 | 9 | 9 | 0 |
| GameDevelopment | 8 | 18 | 8 | 8 | 0 |
| GameShipping | 8 | 18 | 8 | 8 | 0 |

Remaining `JITBucket_` source hits are confined to intentional stale-output
cleanup/migration tests; current generated output contains none. Remaining
`FJITDatabase` text is confined to a negative diagnostic test and a comment
that asserts the legacy database is never opened.

### Real Editor, PIE, Live Coding, and packaged behavior

The decisive same-process Editor transition remains
`Saved/Tests/static-jit-real-livecoding-smoke-r9`: the changed function was VM
with `ContentMismatch` before the patch and became Native/Exact at publication
3, route generation 5, with 7/7 references after the Live Coding patch. Real
PIE reflected dispatch and current-route publication are covered separately by
the milestone-8 UASFunction 3/3 and HotReload 122/122 reports cited above. The
complete Live Coding lifecycle and restoration evidence is recorded in the
preceding task-9.4 section and `attachments/real-editor-livecoding-smoke.md`.

Both required cooked/package configurations passed two-launch, cross-process
stable-provider matching with 18 Native, 0 VM functions and 12/12 references:

- Development: `Saved/StaticJITPackage/staticjit-final-package-Development/20260813_161515_077_1107ea74` (`Passed`, 8 modules, 18 functions);
- Shipping: `Saved/StaticJITPackage/staticjit-final-package-Shipping/20260813_161919_017_de25588a` (`Passed`, 8 modules, 18 functions).

### Optional configured-All diagnostic and closure

The stopped diagnostic left 23 authoritative prefix reports from
`Saved/Tests/staticjit-final-all_01_Editor` through
`Saved/Tests/staticjit-final-all_23_GC`: 2643 passed results, including 273
`SuccessWithWarnings`, one failure, zero not-run, 2644 total. Its sole failure
was `FAngelscriptInheritanceTests.Basic`, whose stack expectation still named
column 227 although the first expected null dereference now occurs at column
205. Independent 1/1 reproduction confirmed the same location at
`Saved/Tests/staticjit-final-functional-inheritance-basic-repro/20260813_172721_583_990be5f1`.
The expectation was corrected without weakening the exception/module/frame
match, the four-action incremental build passed at
`Saved/Build/staticjit-functional-inheritance-column-green-build/20260813_172855_868_fb36c9c5`,
and the complete inheritance prefix then passed 5/5 as cited above.

The diagnostic's wall-clock data was affected by a separate user-owned
`.worktree/as-assets-singletons` All/Cache run. Each suite itself dispatched
Automation serially, but the two worktrees competed for machine resources;
therefore the timing attachment is observational, not a CI threshold. Exact
focused and partial-All timing is preserved in
`attachments/final-test-timing.md`.

### Repository-quality gates

- `openspec status --change refactor-as-static-jit-multi-provider --json`
  reported every required artifact complete;
- `openspec validate refactor-as-static-jit-multi-provider --strict` passed;
- full plugin `git diff --check` passed after removing one trailing EOF blank
  line in `StaticJITDiagnostics.cpp`;
- targeted parent `git diff --check` for this change's OpenSpec, documentation,
  project JIT scaffold, and descriptor changes passed.

Standalone and unrelated whole-product suites were not rerun after the user
approved the narrower final scope; no claim is made for a new Standalone or
complete 37-prefix `All` result. The evidence above closes every surface in the
accepted StaticJIT impact matrix.

## Task 13 no-Private carrier closure — 2026-08-13

The project carrier and fixed TestJIT carrier now share one physical rule:
manual implementation files live at the UE module root and generated files live
under root `Generated`. Project `Private`, TestJIT `Private`, and TestJIT
`Public` are all absent. `AngelscriptTestJITProbes.h` remains DLL-annotated and
is visible to `AngelscriptTest` only through its private sibling-module include
path.

### TDD and migration-service evidence

- Project no-Private RED scaffold coverage: 8 tests, 4 expected failures,
  `Saved/Tests/staticjit-no-private-scaffold-red/20260813_192441_349_74ebb2d5`.
- Project no-Private RED generation coverage: 8 tests, 1 expected failure,
  `Saved/Tests/staticjit-no-private-generation-red/20260813_192542_933_2c07bf7f`.
- Project scaffold/generation GREEN: 16/16 PASS,
  `Saved/Tests/staticjit-no-private-project-green/20260813_192939_014_ad7bb541`.
- TestJIT flat-root RED ownership coverage: 8 tests, 6 expected failures,
  `Saved/Tests/staticjit-testjit-flat-root-red/20260813_193145_494_b427ad41`.
- After correcting two source-text assumptions that confused whitespace and
  intentional legacy migration constants with current ownership, TestJIT
  ownership passed 8/8 at
  `Saved/Tests/staticjit-testjit-flat-root-ownership-fixed/20260813_194529_098_79758ccb`.

The real project migration completed through the public runners:

1. Scaffold moved the fixed module/selector files and reported
   `RequiresFullBuild=true` at
   `Saved/AngelscriptJITRuns/staticjit-flat-root-scaffold/20260813_194805_950_bde792ab`.
2. Generate All safely retired the validated old profile inventories, emitted
   current `Generated/EditorDevelopment`, `Generated/GameDevelopment`, and
   `Generated/GameShipping`, and reported a source-set change at
   `Saved/AngelscriptJITRuns/staticjit-flat-root-generate-all/20260813_194857_218_f9d06db7`.
3. The required normal Editor build invalidated the old makefile, compiled the
   root module/selector and all 25 current project `.jit.cpp` sources, and
   passed at
   `Saved/Build/staticjit-flat-root-generated-normal-build/20260813_195046_121_7265579e`.
4. Project Verify All returned exit 0 and `DifferenceCount=0` for every profile
   at
   `Saved/AngelscriptJITRuns/staticjit-flat-root-verify-all/20260813_195105_885_f947f5b2`.

TestJIT Generate and its source-set rebuild passed at
`Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit-flat-root_02_generate/20260813_193607_810_b4889337`
and
`Saved/Build/staticjit-testjit-flat-root-generated-build/20260813_193746_661_aa851681`.
Fresh read-only TestJIT Verify plus its impact-focused AOT prefix then completed
through `Tools/RunStaticJITTests.ps1 -Mode Verify -AotOnly`: Verify exited 0 and
the AOT report passed 20/20 at
`Saved/Tests/staticjit-testjit-flat-root_02_tests/20260813_195420_831_31c307b7`.
The AOT run took 379.859 seconds; live log inspection showed repeated full
Engine construction, Cache V2 restore, a 45.159-second UE DDC maintenance pass,
and a 14.032-second class-layout step rather than a deadlock.

The final combined directly affected Automation prefixes — ProjectScaffold,
ProjectGeneration, Commandlet, and TestModuleOwnership — passed 30/30 at
`Saved/Tests/staticjit-flat-root-focused-final/20260813_200105_899_ff730c6d`.
The updated package-smoke manifest path was then exercised without rebuilding
the unrelated archive by reusing the exact prior Development package root with
`-SkipPackage`: the current root manifest validated, both packaged launches
published 18/18 Native routes with 12/12 references, and the runner returned
exit 0 at
`Saved/StaticJITPackage/staticjit-final-package-Development/20260813_161515_077_1107ea74`.
This is a path/tooling recheck against the prior archive, not a claim of a new
package build.
No configured `All` or unrelated product prefix was rerun for this layout-only
closure.
