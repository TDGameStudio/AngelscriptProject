# Verification — Direct Manual Binding Callback Architecture

Verified on 2026-08-08 with the project-configured installed Unreal Engine 5.8.0 (CL 55116800).

## Outcome

The legacy nested bind records, integer ordering, per-engine callback-array copy/sort, PreviousBind mutation, runtime bind disabling, and templated native metadata macros have been replaced by one sealed process callback collection, seven fixed phases, explicit-engine direct replay, and exact fluent function/property results. The retained NativeModuleFunctionAddress POD/`IModularFeatures` bridge is source-engine-only and is unchanged in layout and transport behavior.

## Build and focused regression evidence

| Scope | Result | Evidence |
| --- | ---: | --- |
| Final build after shared-engine isolation fix | 94/94 actions, success | `Saved/Build/direct-bind-shared-engine-poison-fix/20260808_181805_988_6ffd1e8f/Build.log` |
| Final build after Extension pairing fix | 94/94 actions, success | `Saved/Build/direct-bind-extension-pairing-green/20260808_182650_738_ffdac410/Build.log` |
| Binding architecture focused selection | 90/90 | `Saved/Tests/direct-bind-final-focused-green/20260808_171945_585_f7bb71dd/Report/index.json` |
| Manual Bindings prefix | 275/275 | `Saved/Tests/direct-bind-final-bindings-green/20260808_172430_367_ee78f08d/Report/index.json` |
| StaticJIT native-form regressions | 4/4 | `Saved/Tests/direct-bind-final-staticjit-nativeforms-green/20260808_172611_971_352d5208/Report/index.json` |
| StaticJIT AOT generation/compile | 12/12 | `Saved/Tests/direct-bind-final-staticjit-aot-green/20260808_172657_286_6d6625f6/Report/index.json` |
| UHT resolver + generated binding selection | 10/10 | `Saved/Tests/direct-bind-final-uht-generated/20260808_172915_571_9d255409/Report/index.json` |
| Native AngelScript SDK suite | 691/691 | `Saved/Tests/direct-bind-final-native-core_01_AngelScriptSDK/20260808_172949_798_f814e57e/Report/index.json` |
| Reflection family selection | 75/75 | `Saved/Tests/direct-bind-reflection-final-verification-r2/20260808_135228_675_1e834c7b/Report/index.json` |
| RPC declarations | 6/6 | `Saved/Tests/direct-bind-reflection-rpc/20260808_130603_949_3eba3804/Report/index.json` |
| Dump observation/schema | 4/4 | `Saved/Tests/direct-bind-dump-observation/20260808_164228_402_d7aa1153/Report/index.json` |
| Performance observation | 6/6 | `Saved/Tests/direct-bind-performance-observation/20260808_164311_631_e0cf2ede/Report/index.json` |
| Extension attach/reentrant-registration regression | 6/6 | `Saved/Tests/direct-bind-extension-pairing-green/20260808_183219_591_278a92c0/Report/index.json` |
| Failed-initialization detach regression | 6/6 | `Saved/Tests/direct-bind-extension-detach-green/20260808_183309_205_33d38aef/Report/index.json` |
| Shared-engine failure isolation selection | 4/4 | `Saved/Tests/direct-bind-engine-binds-shared-isolation-green/20260808_183351_454_da4678c8/Report/index.json` |
| Complete Engine prefix after lifecycle fixes | 163/163 | `Saved/Tests/direct-bind-engine-prefix-green/20260808_183429_360_63a5bc9a/Report/index.json` |
| Final configured All suite | 2521/2521 across 35/35 groups; 0 failed, 0 skipped | `Saved/Tests/direct-bind-final-all-green-rerun_01_Editor` through `Saved/Tests/direct-bind-final-all-green-rerun_35_WorldSubsystem` |

## Red-to-green lifecycle findings

The first final `All` attempt passed groups 1–16 (`1735/1735`) and found one order-dependent Engine test failure. A negative direct-registration test intentionally leaves failure sticky, but it used the shared `ASTEST_CREATE_ENGINE()` fixture and poisoned the next test. The negative case now uses `ASTEST_CREATE_ENGINE_FULL()`; the isolated selection and complete Engine prefix above are green.

Independent final review then identified two Extension lifecycle gaps introduced by fail-closed publication. Tests first proved both failures:

1. an Extension registered by another Extension's `OnAttached` callback was not attached to the same engine because readiness was published too late;
2. an engine whose direct binding failed before registry attach still broadcast a registry detach during shutdown.

The engine now becomes publication-ready before synchronous registry attach, records whether registry attach actually completed, detaches only paired registry attachments, and precisely cleans the earlier CodeCoverage attachment on failed initialization. Both dedicated regressions are green.

## Script-visible and generated parity

- `Script/Binds.Cache` remains byte-identical to baseline: 3,853,902 bytes, SHA-256 `DD482308E3EDE1DB990FD5230A55DE9A3A221886003EDD4670F6F49554C2E094`; `Script/Binds.Cache.Headers` remains 2,241,487 bytes.
- Baseline `DumpAll_5676F055465C9CF82D8FA991D32E7871` and post-migration `DumpAll_60B60391491302105F76E0AF8971128E` both contain 34 CSV tables. Of 34 tables, 31 retain identical headers and row counts. Every script-visible engine/type/function/property/module table retains its exact row count. The three intentional architecture-only count changes are:
  - `BindRegistrations.csv`: `230 -> 260`, because split providers now expose owner/name/seven-phase/source/execution/publication observations instead of legacy bind-name/skip fields;
  - `EngineSettings.csv`: one `DisabledBindNames` row removed;
  - `RuntimeConfig.csv`: one `DisabledBindNames` row removed.
  Total dump rows therefore change only from `601457` to `601485` (`+30` provider records minus two removed runtime-disable rows).
- The callable and order migration matrices record declaration, trait, documentation, callable-owner, phase, native/trivial classification, and focused behavior evidence for all migrated providers.
- Container template native-form arguments are unchanged from baseline: TArray `24/24`, TMap `13/13`, TOptional `13/13`, and TSet `10/10`, including name/trivial/compare/copy classification. The former `SCRIPT_NATIVE_TEMPLATED_CALL*` attachment is now an exact operation on the returned `FAngelscriptBoundFunction`.
- StaticJIT AOT C++ generation and compilation is green (`12/12`). Ordinary former lambdas remain ordinary non-native callables; migration did not blanket-promote them to native/trivial forms.
- RuntimeLinked UHT shards now emit file-static `GeneratedBindings` callbacks. RPC/Net UFunctions still route through `BlueprintCallableReflectiveFallback`; direct raw thunks were not introduced.
- NativeModuleFunctionAddress retains layout token `0xA5C0DE02` and the existing `48/32/32` layout expectations. Its runtime transport is compiled out by the installed UE target (`WITH_ANGELSCRIPT_NATIVE_MODULE_FUNCTION_ADDRESS=0`), so this environment verifies emitter/source guards and build compatibility, not live source-engine feature arrival/unload.
- `FAngelscriptType`, generic-call marshalling, RPC routing, and NativeModuleFunctionAddress POD semantics were not redesigned. Focused type-usage, generic-call, reflection/RPC, and multi-engine tests exercise their unchanged contracts.
- Performance observations confirm one-time collection finalization, direct per-engine callback execution, and the absence of per-engine callback-array copy/sort or expanded binding-operation storage. Timing values vary by host load and are diagnostic rather than a byte-for-byte performance promise.

The pre-edit inventory did not retain separately labelled FVector, generic-call, startup timing/allocation, or cache-create/load runs. This is recorded in `inventory.md`. Their parity is supported by the checked-in baseline contracts, exact source/native-form inventories, the byte-identical cache, focused post-edit regressions, generated AOT compile, performance observations, and the final configured suite; no missing baseline artifact is represented as if it existed.

## Architecture and source-layout guards

The active source-layout tests enforce:

- exactly one process callback collection and no public registry/manifest/dependency/priority surface;
- fixed seven-phase ordering and deterministic same-phase ordering;
- explicit target-engine mutation for callback-owned binding state;
- no production direct callable lambdas outside the narrow DSL/test exemptions;
- named `FAngelscript<Name>Binds` companions only where a hand-written callable owner is needed;
- exact chained-call formatting: one trait remains inline when the raw combined line is at most 120 columns, a long single trait splits, and every item in a multi-trait chain uses its own continuation line;
- optional GameplayTags/GAS sources follow the same chain and callable-owner rules.

Final zero-reference scans, strict OpenSpec validation, and repository `git diff --check` are recorded after the complete All suite below.

## Final repository checks

- Removed production APIs/concepts are all zero-reference across Runtime, Editor, UHTTool, GameplayTags, and GAS production roots: nested `FAngelscriptBinds::FBind`, `GetSortedBindArray(...)`, PreviousBind function/property state, `SCRIPT_NATIVE_TEMPLATED_CALL*`, `WITH_ANGELSCRIPT_LEGACY_BINDS`, `DisabledBindNames`, qualified legacy `RegisterBinds(...)` / `CallBinds(...)`, and `EOrder::Early/Normal/Late`.
- `TLambdaFuncPtr` remains present at 10 source references, and focused lambda compatibility fixtures remain compiled and exercised. The source-layout guard distinguishes supported DSL/test lambdas from forbidden production hand-written direct callable lambdas.
- `openspec validate refactor-as-manual-binding-architecture --strict`: PASS.
- `git diff --check`: PASS in the parent repository plus `Plugins/Angelscript`, `Plugins/AngelscriptGameplayTags`, and `Plugins/AngelscriptGAS`.
- The change remains active and unarchived. Plugin source was committed submodule-first after verification:
  - `Plugins/Angelscript`: `a2b7531d1864ce9855afa7b9a00ac77281ce68ca`;
  - `Plugins/AngelscriptGameplayTags`: `e1da2c3d2e73b4f02deaf7b9d94a473e9bfa72fe`;
  - `Plugins/AngelscriptGAS`: `a9e61b4e028bf5a6e9ea4f1ad13ba479eee93fc5`.
  The parent documentation/OpenSpec/gitlink update is not committed, no repository was pushed, and archiving remains intentionally deferred to the parent integration decision.
