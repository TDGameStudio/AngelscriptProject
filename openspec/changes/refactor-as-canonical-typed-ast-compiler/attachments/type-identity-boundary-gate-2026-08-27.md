# Canonical AST type-identity boundary gate — 2026-08-27

Worktree: `D:\as-cta`

OpenSpec change: `refactor-as-canonical-typed-ast-compiler`

This attachment records the final evidence for Task 14.6. It closes the
pre-cutover type-identity boundary gate only. It does not flip the compiler
default, enable Cache V2 by default, replace section 12's final focused/All
verification, or claim that the remaining Canonical Sema/CodeGen surface is
complete.

## 1. Result

Task 14.6 is **GREEN**.

The implemented boundary is:

```text
asASTTypeRef
  snapshot-local traversal identity
        |
        v
StableTypeKey
  durable semantic equality
        |
        v
TypeABIKey
  target/profile/layout compatibility
        |
        v
immutable generation-local RuntimeTypeBinding
        |
        v
resolved pointer / offset / slot / current public numeric TypeId
```

Consequences:

- public AngelScript `int typeId` remains compatible and Engine-local;
- no AST, diagnostic, DTO, Provider identity or detached relocation uses the
  numeric TypeId as durable equality;
- binding resolution happens before aggregate generation publication;
- the active VM path consumes resolved generation-local values under a
  generation lease and does not perform a stable-key lookup per instruction;
- two Engines may assign different numeric IDs to the same stable semantic
  type without corrupting identity or sharing Runtime type objects;
- the product compiler default remains `LEGACY` until Task 10.2;
- Cache V2 remains disabled by default.

## 2. Defects exposed and repaired by this gate

### 2.1 Provider dependency tests did not select their required capture route

The first complete TypedASTJIT run crashed in
`ChangedFunctionContentIsSemanticDependencyMismatch` because its helper could
not find the requested provider entry and used a fatal `check`.

Root cause: the dependency fixture relied on a prematurely changed global
compiler/Cache default instead of explicitly selecting Canonical capture and
explicit Cache V2 enablement for its private Engine.

Repair:

- `CreateEngine` now explicitly selects
  `asCOMPILER_PIPELINE_CANONICAL` and explicitly enables Cache V2 through the
  per-Engine override;
- `SetEntryDependencies` returns `bool` instead of terminating the process;
- each owning test asserts the requested provider entry exists and returns on
  failure;
- provider matching semantics were not weakened and no synthetic entry is
  created.

Evidence:

- build:
  `Saved/Build/cta-type-provider-explicit-capture-build/20260827_055929_550_b9fc3d75/RunMetadata.json`;
- focused method: **1/1 PASS** at
  `Saved/Tests/cta-type-provider-match-explicit-capture-green/20260827_055948_604_19b66944/Report/index.json`;
- ProviderMatch group: **8/8 PASS** at
  `Saved/Tests/cta-type-provider-match-group-green/20260827_060025_962_d1571945/Report/index.json`;
- complete TypedASTJIT: **70/70 PASS** at
  `Saved/Tests/Angelscript.TestModule.StaticJIT.TypedASTJIT/20260827_061944_194_7f4e9a9c/Report/index.json`.

### 2.2 Cache maintenance used mutable global settings instead of Engine policy

The Cache ForceClean boundary ignored an explicit per-Engine Cache V2 override
because `AngelscriptCacheDiagnostics.cpp` read
`GetDefault<UAngelscriptCacheSettings>()->bEnableCacheV2` directly.

Repair: the maintenance path now asks the target Engine through
`Engine->IsCacheV2Enabled()`. This preserves the default-disabled product
policy while honoring an explicitly configured test or contained Engine.

Evidence:

- RED: **0/1 PASS** at
  `Saved/Tests/cta-cache-engine-override-red/20260827_060553_375_b8327cc6/Report/index.json`;
- build:
  `Saved/Build/cta-cache-boundary-fix-build/20260827_060703_182_8d970ff5/RunMetadata.json`;
- GREEN: **1/1 PASS** at
  `Saved/Tests/cta-cache-engine-override-green/20260827_060724_195_cf2b03be/Report/index.json`.

### 2.3 Default-array spelling did not resolve through the target Engine

The source-facing nominal type `TArray<int>` and AngelScript's registered
default-array shorthand `int[]` denote the same target Runtime type, but the
binding resolver compared only the Runtime shorthand. A stable
`TArray<int>` key therefore failed to bind.

Repair: candidate matching reconstructs the registered template's nominal
spelling (`TArray<int>`) locally from the target Engine's `asCDataType`. This
is a late-binding candidate-selection rule only:

- durable semantic identity remains `TArray<int>`;
- the target Engine still owns its own `asCTypeInfo*` and numeric TypeId;
- no array alias or Engine object is persisted in AST/DTO/Provider identity;
- Engines A and B resolve the same stable key independently.

The permanent test perturbs Engine B's registration order with `FDummy`, proves
the two public TypeIds differ, and proves that the one stable key resolves to
each Engine's own TypeInfo without sharing.

Evidence:

- RED: **0/1 PASS** at
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type.FCanonicalASTTypeTests.RuntimeBridgeResolvesDefaultArrayAliasPerEngineGeneration/20260827_061556_452_de54bb4b/Report/index.json`;
- build:
  `Saved/Build/cta-type-alias-green-build/20260827_061714_236_12b90f9f/RunMetadata.json`;
- GREEN: **1/1 PASS** at
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type.FCanonicalASTTypeTests.RuntimeBridgeResolvesDefaultArrayAliasPerEngineGeneration/20260827_061727_857_03a4cb74/Report/index.json`.

### 2.4 Open boundary retained: local `TArray<int>` default construction

An attempted script-corpus fixture containing:

```angelscript
TArray<int> LocalIntArray;
```

exposed `DANGLING_ID construct-decl` in Canonical CodeGen. This is a real
container/default-construction Sema/CodeGen gap, not a type-identity binding
failure. It remains open under the active Sema/lifetime/container/lowering
work (`5.2`, `5.5`, `5.7`, `5.8`, `9.5` and related umbrella tasks).

The TypedASTJIT corpus test was narrowed to a valid array-signature fixture:

```angelscript
int ExampleArrayFixtureValue(const TArray<int>& Values)
```

and accepts the existing safe `UnsupportedSignature` typed-backend fallback.
This records the supported boundary without claiming that local array
construction is fixed. Evidence of the discovered gap:
`Saved/Tests/cta-typedastjit-script-fallback-green/20260827_060804_555_6dbf659d/Report/index.json`.

The refocused corpus method is **1/1 PASS** at
`Saved/Tests/Angelscript.TestModule.StaticJIT.TypedASTJIT.ScriptCorpus.FAngelscriptTypedASTJITScriptFunctionCorpusTests.AdaptedScriptClassAndArrayFixturesFallbackFromTypedBackend/20260827_061810_989_783c7ace/Report/index.json`.

## 3. Task 14.6 verification matrix

Runner console totals are authoritative for aggregate UE groups whose nested
JSON summary does not expose the same top-level total.

| Gate | Result | Evidence |
| --- | ---: | --- |
| Frontend CanonicalAST Type | **20/20 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type/20260827_062158_158_0b19ea9b/Report/index.json` |
| Compiler CanonicalAST SemaAuthority | **301/301 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_062230_746_a93eeb31/Report/index.json` |
| Compiler CanonicalAST ProductionCodeGen | **111/111 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen/20260827_062311_469_3c4c2c63/Report/index.json` |
| CanonicalAST CodeGen Transaction | **20/20 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction/20260827_062526_291_3a8698e1/Report/index.json` |
| Module CanonicalAST Snapshot | **9/9 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot/20260827_062559_955_a40a2f21/Report/index.json` |
| HotReload CanonicalAST | **12/12 PASS** | `Saved/Tests/Angelscript.TestModule.HotReload.CanonicalAST/20260827_062631_955_10b6f2ea/Report/index.json` |
| StaticJIT CanonicalASTIdentity | **12/12 PASS** | `Saved/Tests/Angelscript.TestModule.StaticJIT.CanonicalASTIdentity/20260827_062711_884_ae1d29ae/Report/index.json` |
| StaticJIT ProjectGeneration.Engine | **32/32 PASS** | `Saved/Tests/Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine/20260827_062813_303_5b816239/Report/index.json` |
| StaticJIT TypedASTJIT | **70/70 PASS** | `Saved/Tests/Angelscript.TestModule.StaticJIT.TypedASTJIT/20260827_061944_194_7f4e9a9c/Report/index.json` |
| StaticJIT ProviderReload | **5/5 PASS** | `Saved/Tests/Angelscript.TestModule.StaticJIT.TypedASTJIT.Dependencies.ProviderReload/20260827_061848_934_9c1fbad5/Report/index.json` |
| Cache SettingsAndShutdown/default-disabled boundary | **7/7 PASS** | `Saved/Tests/Angelscript.TestModule.Cache.SettingsAndShutdown/20260827_063122_516_91817d34/Report/index.json` |
| Standalone Debug | **21/21 PASS** | `Saved/StandaloneTests/cta-type-boundary-standalone_01_Standalone/20260827_063208_912_9101ff80/RunMetadata.json` |
| Runtime/Game build | **PASS**, 110/110 actions | `Saved/Build/cta-type-boundary-runtime-build/20260827_063324_387_a4624807/RunMetadata.json` |
| Editor build | **PASS**, up to date | `Saved/Build/cta-type-boundary-editor-build/20260827_063731_253_fc24cb9b/RunMetadata.json` |
| TypedASTJIT generated-output determinism | **25/25 PASS** | `Saved/Tests/Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT/20260827_063947_102_ebebd30f/Report/index.json` |
| Canonical address-free dump | **7/7 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump/20260827_064155_544_0d3f15af/Report/index.json` |
| Structured dump determinism/address-free | **3/3 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.StructuredDump/20260827_064228_411_76b93b58/Report/index.json` |
| AST diagnostics | **3/3 PASS** | `Saved/Tests/Angelscript.TestModule.Dump.ASTDiagnostics/20260827_064300_135_98f77129/Report/index.json` |
| Cache ASTBodySidecar | **17/17 PASS** | `Saved/Tests/Angelscript.TestModule.Cache.ASTBodySidecar/20260827_064332_756_dbfaa226/Report/index.json` |
| OpenSpec strict validation | **PASS** | `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict` |
| Parent and plugin diff checks | **PASS** | both `git diff --check` invocations exited 0; only existing line-ending conversion warnings were reported |

One initial Runtime build invocation accidentally passed unsupported
`-LabelPrefix`; PowerShell forwarded the label as an extra UBT target and UBT
reported that no target rules existed for the label. It is a runner invocation
error, not implementation evidence. It is excluded from the gate and retained
at `Saved/Build/build/20260827_063311_308_e8110002/RunMetadata.json`. The
supported `-Label` invocation produced the successful build above.

## 4. Durable-identity source scan

The final scan reported zero forbidden durable-identity matches in all four
surfaces:

| Surface | Forbidden durable forms | Result |
| --- | --- | ---: |
| AST type storage (`as_ast_type.h`, `as_ast_context.h`) | Engine/TypeInfo pointers, numeric `typeId` | **0** |
| diagnostic JSON/text (`as_ast_dump.cpp`, `as_ast_diagnostics.cpp`) | emitted TypeId/address/pointer identity | **0** |
| optional AST DTO/sidecar (`as_ast_sidecar.cpp`, Cache AST body sidecar) | Engine/TypeInfo/numeric TypeId/snapshot owner as persisted identity | **0** |
| Provider and detached relocation identity | Engine-local TypeId, `asASTTypeRef`, Runtime Engine/type objects | **0** |

The scan used `rg` against the maintained-fork AST type/context, dump and
diagnostic emitters, sidecar codec plus UE Cache AST sidecar, Provider/artifact
identity headers, and the `asSTypeRelocation` field block. It distinguishes a
forbidden persisted/compared identity field from a generation-local active
binding or a decoder-local type-table index; the latter two are reviewed below
rather than hidden by a broad textual exclusion.

Reviewed non-violations:

- `as_ast_sidecar.cpp` reconstructs `asASTTypeRef(i)` at local decoder points.
  These integers are indices into the DTO's serialized type table and are
  immediately interned into the newly created snapshot. The encoder persists
  type kind plus complete stable key; the semantic hash expands kind, token and
  stable key. The indices are not cross-snapshot identity.
- public `asSASTTypeView` intentionally exposes a snapshot-local
  `asASTTypeRef` for traversal together with its stable key. The view contract
  does not permit the ref to be retained or compared across snapshots.
- `asCASTSnapshot` privately retains its `asCRuntimeTypeGeneration` as a
  lifetime lease. That is ownership of the generation backing the view, not a
  durable semantic key.
- generation snapshots intentionally contain resolved pointers/current IDs
  beside stable keys. They are immutable, generation-local active state and
  are never Provider/DTO/detached identity.
- `asCBytecodeCodeGenArtifact` may hold candidate pointers and pending TypeId
  allocation state while the build lock and transaction are active. The
  detached `asSTypeRelocation` remains pointer-free and contains only stable
  identity, expected ABI, use, owning artifact/offset and target ordinal.

## 5. Scope decision

This gate proves the Canonical compiler's durable type identity and late
Runtime installation boundary. It deliberately does not rewrite the entire
legacy VM/SaveByteCode/`FAngelscriptPrecompiledData` operand model. Existing
legacy numeric references are classified in
`reviews/type-identity-runtime-boundary-reconciliation-2026-08-27.md`; a full
legacy relocation cleanup belongs to the recorded future
`refactor-as-runtime-type-identity-relocation` scope and must not be created or
implemented without explicit user authorization.

The next compiler work remains Sema authority, complete Canonical lowering,
TypedASTJIT HIR retirement, entry-point cutover and section 12 delivery gates.
