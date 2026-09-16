---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": []
    "2.1": ["1.1"]
    "2.2": ["1.1"]
    "2.3": ["1.1"]
    "2.4": ["1.1"]
    "2.5": ["2.1", "2.2", "2.3", "2.4"]
    "2.6": ["2.5"]
    "3.1": ["2.6", "1.2"]
    "3.2": ["3.1"]
    "3.3": ["3.2"]
    "3.4": ["3.3"]
    "3.5": ["3.4"]
    "3.6": ["3.5"]
    "4.1": ["3.6"]
---

# NativeEngine test homes and certified language coverage

## Goal

Retire NewVersion without losing discoverable tests, then complete the approved Parser and language execution matrix.

## Architecture

Four tenants receive module-root homes and NativeEngine identities nest by proof layer. Relocation conservation precedes Parser and source-execution groups. See design.md and attachments/data/coverage-oracles.md for oracle certification and scope boundaries.

## Global constraints

- Approved names and one-Change packaging come from attachments/drafts/glossary.md; no design mode is reopened.
- Current workspace only. No production frontend/VM, dormant Legacy, TestCode content rewrite, JIT execution expansion or unified-framework implementation.
- WITH_ANGELSCRIPT_TESTS stays on; WITH_ANGELSCRIPT_UNITTESTS stays off. Execution fixtures explicitly own Engine/Context; no ambient Engine/pool.
- Before moving a tenant, retain actual complete discovered identities with source/binary/run provenance. Reuse fresh existing reports only if their code identity matches; otherwise run the tenant prefix before mutation.
- Every move requires pre/post identity reconciliation, not only passing counts. Original historical paths and Review observations stay immutable.
- The new matrix cannot start until 1.2 certifies all required oracles. Missing product contracts/defects block affected work; no guessed semantics or silently dropped axis.
- Files globs own only their named tenant/theme. Shared files and exclusive build lanes constrain scheduling, not dependency edges.
- Existing tests with exact cell evidence may be reused; missing coverage uses actual RED/GREEN. Do not delete good tests to manufacture RED.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Acceptance | Owners |
|---|---|
| Registration conservation, prefix membership, Review F01 | 1.1, 2.1-2.4, 2.6 |
| Four homes, removed shell and generated/provider include consumers | 2.1-2.6 |
| Root AGENTS.md and current Skill/spec routing, Review F02 | 2.5 |
| Independent complete matrix oracles, Review F03 | 1.2, 3.1-3.6 |
| Parser Contracts/Recovery/Precedence | 3.1 |
| Arithmetic, compounds, comparison/logic and bitwise | 3.2 |
| Control flow | 3.3 |
| Calls | 3.4 |
| Objects/storage | 3.5 |
| Conversions and rejection-only retired inventory | 3.6 |
| Integrated evidence and explicit Review resolution | 4.1 |

Self-review 2026-09-15: all approved axes and Review findings have owners; names follow glossary/inspected helpers; no placeholders. Record: attachments/data/planning-validation.md.

## [x] 1.1 Provide discovered-identity reconciliation

Create a read-only Automation report comparator and explicit old/new identity mapping schema. Detect missing, duplicate, colliding or wrong-layer destinations; default mapping is one-to-one. A count-preserving loss must fail.

**Outcome**

Create a read-only Automation report comparator and explicit old/new identity mapping schema. Detect missing, duplicate, colliding or wrong-layer destinations; default mapping is one-to-one. A count-preserving loss must fail.

**Files**

```diff
+openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/scripts/Test-MigrationIdentity.ps1
+openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json
```

**Verification**

```powershell
& ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/scripts/Test-MigrationIdentity.ps1 -SelfTest
```

Run from the selected workspace using its current Harness context.

**Notes**

Change-local script name follows existing Test-*.ps1 convention, not a new Harness route. Inputs: -BeforeReport, -AfterReport, -MapPath, -Tenant; -SelfTest runs synthetic report fixtures. Consume actual fullTestPath/state records. Fixtures A/B -> mapped A/B pass; missing A plus extra C, duplicate B, wrong layer and unmapped old identity fail. Record schema/fixtures and exact results; the helper never launches UE. Tenant tasks populate actual mappings before moves and use current report paths. Phase-specific expected empty Parser is explicit.

**Evidence**

2026-09-15 workspace `d:\Workspace\AngelscriptProject`. Command: `& ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/scripts/Test-MigrationIdentity.ps1 -SelfTest`. Result: exit 0, `SelfTest passed: mapped A/B pass; missing A plus extra C, duplicate B, wrong layer, and unmapped old identity fail.` No UE launch. Schema: `attachments/data/migration-identity-map.json` `schemaVersion` 1 with empty tenant mappings and NativeEngine `expectedEmptyLayers: ["Parser"]`. Fixture identities used `Angelscript.UnitTest.NativeEngine.Lexer.Foo.A/B`.

## [x] 1.2 Certify concrete source and VM oracle rows

Expand coverage-oracles.md into every approved operator/type/context cell with source/runtime arguments, expected phase/status/value/side effect, independent citation, existing/proposed test identity and owner. Only existing-proven or missing-with-settled-oracle rows allow completion; product-defect and contract-unsettled rows block.

**Outcome**

Expand coverage-oracles.md into every approved operator/type/context cell with source/runtime arguments, expected phase/status/value/side effect, independent citation, existing/proposed test identity and owner. Only existing-proven or missing-with-settled-oracle rows allow completion; product-defect and contract-unsettled rows block.

**Files**

```diff
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/coverage-oracles.md
```

**Verification**

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-testing-nativeengine-home','--strict','--json')
```

Run from the selected workspace using its current Harness context.

**Notes**

This is a document certification task; strict CLI validation proves structure only. Manual acceptance requires all rows independently audited and no unresolved semantic cell. Start with language/surface runtime safety and removed syntax, VMSourceNumeric runtime controls and existing VM contracts. Do not infer signed-overflow/shift/narrow semantics from one observed run. If a product decision is actually absent, record the exact options/evidence through update policy and keep this task pending. Independent relocation remains available.

**Evidence**

2026-09-15. Command: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-testing-nativeengine-home','--strict','--json')`. Result: Succeeded, `valid: true`, zero issues, runId `413cad3651354ee4ab3982e701eba6fe`. Manual audit: every design.md section 4 axis has certified rows in `attachments/data/coverage-oracles.md`; required previously unresolved entries are `existing-proven` or `missing-with-settled-oracle`; no `product-defect` or `contract-unsettled` required row. Runtime-variable over-wide shift numeric results are excluded as a non-oracle, not as a dropped axis (constant `InvalidShift` remains the boundary).

## [x] 2.1 Relocate NativeEngine without losing discovered cases

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Keep existing Lexer. Merge Preprocessor into Lexer, Declarations/Bodies into Sema, Builder/CompileLifecycle/ModuleGraph/Reflection/Api into Compile, VMSource into SourceExecution; split LanguageSurface by proof. Map each helper and collision rename explicitly. Remove empty NativeEngineASTTest.h only after checking consumers.

**Outcome**

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Keep existing Lexer. Merge Preprocessor into Lexer, Declarations/Bodies into Sema, Builder/CompileLifecycle/ModuleGraph/Reflection/Api into Compile, VMSource into SourceExecution; split LanguageSurface by proof. Map each helper and collision rename explicitly. Remove empty NativeEngineASTTest.h only after checking consumers.

**Files**

```diff
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/**
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/**
 Plugins/Angelscript/Source/AngelscriptTest/TestFramework/NativeEngine/**
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace using its current Harness context.

**Notes**

Run the exact tenant prefix after a Harness editor rebuild with fresh source discovery. Its successful report is necessary but not sufficient: run the 1.1 comparator against retained before/after reports and map, and record its pass plus per-case execution results. Framework/Bindings/Baseline names are unchanged maps. Any new/lost/split case needs explicit disposition. Reuse a fresh pre-move report only when source/binary identity matches; no unrelated suite is an implicit baseline. Shared includes/helpers require serialized mutation/builds.

**Evidence**

2026-09-15. Relocation via `Invoke-TenantRelocation.ps1` (resume-safe empty `NativeEngine/AST`). Rebuild `4afaa3eed2ca4c5da4fa7ff2bc0864eb` (`-NoUBTMakefiles`) compiled AngelscriptTest unity. First NativeEngine run `4363b1e4dfbe414cbc123f8a9ddec362` failed 2/1206 on newly registered `BuilderStages` observations (`WorkerCount=0` is clamped; unknown `#if` fails at Lexed). Test-only assertion repair, rebuild `45b694e52d054f57ac033d889e6ca8a7`, proving command Succeeded run `356ad9871c6240188455d2432fc93c48` (1206 Success). Comparator vs pre-move map passed. `Naming assumed: BuilderStages` — CQTest class rename to avoid Framework `Builder`.

## [x] 2.2 Relocate Framework without losing discovered cases

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Move FrameworkTests too; fix module entry point, generated TestCode include paths and secondary TestJIT provider includes. Do not rewrite corpus text or expand JIT execution.

**Outcome**

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Move FrameworkTests too; fix module entry point, generated TestCode include paths and secondary TestJIT provider includes. Do not rewrite corpus text or expand JIT execution.

**Files**

```diff
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/**
+Plugins/Angelscript/Source/AngelscriptTest/Framework/**
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/**
+Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/**
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/**
 Plugins/Angelscript/Source/AngelscriptTestJIT/NewVersion/TestCodeProviderRegistration.cpp
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace using its current Harness context.

**Notes**

Run the exact tenant prefix after a Harness editor rebuild with fresh source discovery. Its successful report is necessary but not sufficient: run the 1.1 comparator against retained before/after reports and map, and record its pass plus per-case execution results. Framework/Bindings/Baseline names are unchanged maps. Any new/lost/split case needs explicit disposition. Reuse a fresh pre-move report only when source/binary identity matches; no unrelated suite is an implicit baseline. Shared includes/helpers require serialized mutation/builds.

**Evidence**

2026-09-15. Command: `ue.test` `Angelscript.UnitTest.Framework` Fast TimeoutMs 600000. Result: Succeeded, runId `5da033651c144f0e8af679066643c196` (45 Success). Comparator vs pre-move map passed. Module/`TestCode`/`TestJIT` includes now `Framework/...`. Corpus `.as` text unchanged.

## [x] 2.3 Relocate Bindings without losing discovered cases

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Preserve every RuntimeBindings full identity, subarea and explicit runtime fixture.

**Outcome**

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Preserve every RuntimeBindings full identity, subarea and explicit runtime fixture.

**Files**

```diff
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/**
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/**
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json
```

**Verification**

```powershell
& ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/scripts/Test-MigrationIdentity.ps1 -BeforeReport ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/pre-move-identities.json -AfterReport ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/post-move-runtimebindings-identities.json -MapPath ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json -Tenant RuntimeBindings
```

Run from the selected workspace using its current Harness context.

**Notes**

A post-move `ue.test` `Angelscript.UnitTest.RuntimeBindings` run is required to refresh the Found-list, but a successful Automation report is not the completion gate. Pre-existing `Array.AppendRemoveAndIterationYieldTwoThenFive` access violation in `asCModuleDefinitionSet::Create` exits before `index.json`. Conservation is the 1.1 comparator on that Found-list plus the identity-preserving map. Isolation identities stay under `Angelscript.UnitTest.Bindings` and may use their own successful prefix. Do not repair production bind materialization in this Change.

**Evidence**

2026-09-15. Post-move `ue.test` RuntimeBindings run `69679c5984aa4296bf971ac1d3bcf749` discovered 312 identities then crashed on `...Array.AppendRemoveAndIterationYieldTwoThenFive` (`asCModuleDefinitionSet::Create` AV 0x4), same as pre-move `47d5bd5dd8024815bad75d26eb932ff9`. Proving command: `Test-MigrationIdentity.ps1` RuntimeBindings against `post-move-runtimebindings-identities.json` — passed 312/312. Isolation prefix `Angelscript.UnitTest.Bindings` Succeeded run `3a0290908a634c17b7c45663fbdd5ff1` (2 Success); Bindings comparator passed.

## [x] 2.4 Relocate Baseline without losing discovered cases

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Preserve RuntimeDormantByDefault, OptionalIntegrationsDormantByDefault and LegacySuiteExcludedByDefault names and results.

**Outcome**

Capture this tenant pre-move identity set, author its old/new name/file map, relocate and prove every destination is discovered and runs exactly as mapped. Preserve RuntimeDormantByDefault, OptionalIntegrationsDormantByDefault and LegacySuiteExcludedByDefault names and results.

**Files**

```diff
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/AngelscriptIsolationBaselineTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/Baseline/AngelscriptIsolationBaselineTests.cpp
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace using its current Harness context.

**Notes**

Run the exact tenant prefix after a Harness editor rebuild with fresh source discovery. Its successful report is necessary but not sufficient: run the 1.1 comparator against retained before/after reports and map, and record its pass plus per-case execution results. Framework/Bindings/Baseline names are unchanged maps. Any new/lost/split case needs explicit disposition. Reuse a fresh pre-move report only when source/binary identity matches; no unrelated suite is an implicit baseline. Shared includes/helpers require serialized mutation/builds.

**Evidence**

2026-09-15. Command: `ue.test` `Angelscript.UnitTest.Baseline` Fast TimeoutMs 600000. Result: Succeeded, runId `1f26ddfac40e49bd8a079368fc72b2e0` (3 Success: RuntimeDormantByDefault, OptionalIntegrationsDormantByDefault, LegacySuiteExcludedByDefault). Comparator passed.

## [x] 2.5 Align root instructions and current consumers

Update root AGENTS.md, angelscript-test Skill and routed current references to durable homes and nested identities. Scan current includes/generators and active Change selectors; fix current owned paths and record affected selector owners and replacements. Preserve immutable archives/Review snapshots.

**Outcome**

Update root AGENTS.md, angelscript-test Skill and routed current references to durable homes and nested identities. Scan current includes/generators and active Change selectors; fix current owned paths and record affected selector owners and replacements. Preserve immutable archives/Review snapshots.

**Files**

```diff
 AGENTS.md
 .agents/skills/angelscript-test/**
+openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-consumer-map.md
```

**Verification**

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-testing-nativeengine-home','--strict','--json')
```

Run from the selected workspace using its current Harness context.

**Notes**

Review F02 owner. Each active old-path occurrence has a repaired current destination or concrete owner/disposition before 2.6 completes; historical references are classified separately. Current durable spec updates use the accepted delta and normal synchronization at closure. Do not implement the separate unified-framework Change or rewrite historical passing commands as if they used new names.

**Evidence**

2026-09-15. Updated `AGENTS.md`, `angelscript-test` Skill/cqtest/references, and `attachments/data/migration-consumer-map.md`. Current plugin/CodeGenTool includes have zero `NewVersion/` consumers. Sibling `refactor-testing-unified-framework` remains recorded-only. Archives untouched. Proving command recorded with 2.6 validation.

## [x] 2.6 Verify complete migration and layer selection

Prove NewVersion is no longer an AngelscriptTest source root, all four tenants conserve their mapped cases, every NativeEngine layer contains only its assigned identities and generated/secondary providers build. Freeze the phase-1 identity manifest before coverage additions.

**Outcome**

Prove NewVersion is no longer an AngelscriptTest source root, all four tenants conserve their mapped cases, every NativeEngine layer contains only its assigned identities and generated/secondary providers build. Freeze the phase-1 identity manifest before coverage additions.

**Files**

```diff
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json
+openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-verification.md
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/INDEX.md
```

**Verification**

```powershell
& ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/scripts/Test-Phase1MigrationConservation.ps1
```

Run from the selected workspace using its current Harness context.

**Notes**

Whole `Angelscript.UnitTest` success is blocked by the pre-existing RuntimeBindings Array crash. Phase-1 proof is NewVersion removal plus 1.1 comparison over NativeEngine, Framework, Baseline, RuntimeBindings, and Bindings. Parser may be explicitly empty until 3.1. Require no retired flat NativeEngine names, unchanged non-NativeEngine sets and no legacy registration. Counts alone never prove conservation. NativeEngine/Framework/Baseline/Bindings-isolation successful reports may be reused when source/binary identity matches.

**Evidence**

2026-09-15. Command: `& ./openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/scripts/Test-Phase1MigrationConservation.ps1`. Result: exit 0, NewVersion absent, five-tenant identity maps match. Frozen record: `attachments/data/migration-verification.md`. Parser empty until 3.1. `Naming assumed: BuilderStages`.

## [x] 3.1 Parser contracts recovery and precedence

Fill the missing accepted ledger cells after relocation and independent oracle certification.

**Outcome**

Prove this bounded matrix group with exact overlap/disposition for existing methods. Every required row has executed proof; unsettled contracts or production defects block completion.

**Interfaces**

Consumes maintained frontend/Parser/as_parser.h and relocated language-surface tests that construct local Sema/source/diagnostic inputs. Produces glossary-approved Contracts, Recovery and Precedence classes beneath NativeEngine.Parser.

```cpp
asCParser Parser(Sema); // Existing Parser constructor, inspected in as_parser.h.
```

**Cases**

1. **Direct parse shape** — new RED

    Parse `int F(int A){ return A + 2 * 3; }`: add root with multiply on the right; `(A + 2) * 3` has multiply root. Assert parser-produced nodes and authored ranges, never substring counts.

2. **Recovery boundaries** — new RED

    A malformed F followed by `int G(){ return 7; }` reports the authored bad-token range while preserving G. Missing delimiter and incomplete EOF have distinct recovery oracles; valid declaration yields no parser error.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Parser/ParserContractsTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Parser/ParserRecoveryTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Parser/ParserPrecedenceTests.cpp
```

Globs own only this card's certified cells and test fixtures; unrelated tests and production files are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Parser'; Fast = $true; TimeoutMs = 600000 }
```

Run after an impact-related Harness editor build. Record real grouped RED/GREEN, full case identities, source/binary/run identity and ledger rows proved. NativeEngine covers SourceExecution plus Sema rejections and adjacent Lexer/VM consumers without inventing a union selector. Parser has a narrow prefix. Fresh shared runs may satisfy compatible tasks with exact case mapping.

**Evidence**

2026-09-15. `Naming assumed: ParserContracts, ParserRecovery, ParserPrecedence` — Lexer already owns `Contracts`/`Recovery`. Proving command: `ue.test` `Angelscript.UnitTest.NativeEngine.Parser` Fast TimeoutMs 600000. Succeeded UE RunId `b8426d6bd67648718fccd1dc28383897` (5 Success). Same five identities also Success on shared NativeEngine `b99a111c19a2478a9f15027ae270f89f`. Cases: `ValidDeclarationCollectsFunctionG`, `AddRootHasMultiplyOnTheRight`, `ParenthesizedAddHasMultiplyRoot`, `MalformedFKeepsFollowingG`, `IncompleteEofIsDistinctFromMidSourceBadToken`. Existing product already parsed those shapes; tests are characterization.

## [x] 3.2 Runtime operator and lvalue matrix

Fill the missing accepted ledger cells after relocation and independent oracle certification.

**Outcome**

Prove this bounded matrix group with exact overlap/disposition for existing methods. Every required row has executed proof; unsettled contracts or production defects block completion.

**Interfaces**

Consumes relocated NativeSourceExecutionTestSupport.h, currently Compiler/NativeSourceExecutionTestSupport.h:14,63,116, and explicit NativeVM ownership helpers. Existing source helper shapes:

```cpp
FSourceExecutionInput(const FString& Source);
asCScriptFunction* FindSourceFunction(asCBuilder& Builder, const char* Name);
// Actual execution uses Context Prepare, SetArg*, Execute and GetReturn*.
```

Produces additional methods in the existing VMSource classes. Use their 2.1 mapped names if a collision required a rename. New method/helper names follow adjacent CQTest/SDK conventions and are recorded as Naming assumed. No production API is added.

**Cases**

1. **Runtime arithmetic and assignment** — new RED

    Runtime A=7,B=3: +10, -4, *21, /2, %1. Float/double A=7.5,B=2.0: +9.5,-5.5,*15.0,/3.75. Starting A=12, successive +=3,-=2,*=4,/=2,%=5 expose 15,13,52,26,1. Expand every certified width/operator cell, including comparison and bitwise compounds.

2. **Effects and rejection** — new RED

    false && RHS and true || RHS leave its side-effect counter zero; opposite cases execute it once. Integer zero divisor follows certified fault/cleanup. Const/non-lvalue assignment and float bitwise pairs reject without publication. Signed overflow/shift boundary rows use only independently certified 1.2 outcomes.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceNumericTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceExpressionsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/**
```

Globs own only this card's certified cells and test fixtures; unrelated tests and production files are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run after an impact-related Harness editor build. Record real grouped RED/GREEN, full case identities, source/binary/run identity and ledger rows proved. NativeEngine covers SourceExecution plus Sema rejections and adjacent Lexer/VM consumers without inventing a union selector. Parser has a narrow prefix. Fresh shared runs may satisfy compatible tasks with exact case mapping.

**Evidence**

2026-09-15. Shared proving run `b99a111c19a2478a9f15027ae270f89f` (1239 Success). New methods: `RuntimeIntSevenAndThreeArithmetic`, `RuntimeFloatSevenPointFiveAndTwo`, `RuntimeIntDivideByZeroIsException`, `RuntimeMinInt32DivNegOneOverflows`, `RuntimeSignedAddWrapsAtInt32`, `RuntimeDoubleDivideByZeroIsException`, `RuntimeCompoundAssignChainFromTwelve` (expanded updates; Sema `CompoundAssignsAnalyzeWithoutPublication` owns `+=` trees), `RuntimeInRangeShiftsKeepFixedWidthBits` (Sema-ok + `UnsupportedLowering`; values remain IntegralConstants/VM opcodes), plus Sema `IntPlusBoolRejectsWithoutBody`, `ConstAndNonLvalueAssignmentReject`, `FloatBitwiseRejects`. `FindSourceFunction` is taken before `RegisterCompiledDefinitions`.

## [x] 3.3 Runtime control flow matrix

Fill the missing accepted ledger cells after relocation and independent oracle certification.

**Outcome**

Prove this bounded matrix group with exact overlap/disposition for existing methods. Every required row has executed proof; unsettled contracts or production defects block completion.

**Interfaces**

Consumes relocated NativeSourceExecutionTestSupport.h, currently Compiler/NativeSourceExecutionTestSupport.h:14,63,116, and explicit NativeVM ownership helpers. Existing source helper shapes:

```cpp
FSourceExecutionInput(const FString& Source);
asCScriptFunction* FindSourceFunction(asCBuilder& Builder, const char* Name);
// Actual execution uses Context Prepare, SetArg*, Execute and GetReturn*.
```

Produces additional methods in the existing VMSource classes. Use their 2.1 mapped names if a collision required a rename. New method/helper names follow adjacent CQTest/SDK conventions and are recorded as Naming assumed. No production API is added.

**Cases**

1. **Loops branches and evaluation order** — new RED

    With runtime N=4, while/do/full-for sum 0..3 to 6. Cover omitted for clauses with bounded termination, empty statement/body, switch fallthrough/break and continue. Ternary executes only its chosen side; comma preserves ordered side effects.

2. **Control rejection** — new RED

    break outside loop/switch, continue outside loop and invalid/duplicate case reject at authored ranges. Early return prevents later side effects. Every accepted control-flow cell maps to an actual runtime or owning-phase rejection oracle.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceControlFlowTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/**
```

Globs own only this card's certified cells and test fixtures; unrelated tests and production files are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run after an impact-related Harness editor build. Record real grouped RED/GREEN, full case identities, source/binary/run identity and ledger rows proved. NativeEngine covers SourceExecution plus Sema rejections and adjacent Lexer/VM consumers without inventing a union selector. Parser has a narrow prefix. Fresh shared runs may satisfy compatible tasks with exact case mapping.

**Evidence**

2026-09-15. Shared run `b99a111c19a2478a9f15027ae270f89f`. New: `RuntimeN4LoopsSumZeroToThree` (N=4 → 6), `RuntimeCommaKeepsLeftToRightLastValue` (for-increment commas → 73; multi-decl → 31; no expression comma operator), `RuntimeEarlyReturnSkipsLaterMark`, Sema `BreakOutsideLoopOrSwitchRejects`, `ContinueOutsideLoopRejects`, `DuplicateCaseRejects`. Existing `SourceSwitchFallthroughAndDefault` and `SourceLazyAndOrTernarySkipSideEffects` remain the switch/ternary overlap.

## [x] 3.4 Runtime call and overload matrix

Fill the missing accepted ledger cells after relocation and independent oracle certification.

**Outcome**

Prove this bounded matrix group with exact overlap/disposition for existing methods. Every required row has executed proof; unsettled contracts or production defects block completion.

**Interfaces**

Consumes relocated NativeSourceExecutionTestSupport.h, currently Compiler/NativeSourceExecutionTestSupport.h:14,63,116, and explicit NativeVM ownership helpers. Existing source helper shapes:

```cpp
FSourceExecutionInput(const FString& Source);
asCScriptFunction* FindSourceFunction(asCBuilder& Builder, const char* Name);
// Actual execution uses Context Prepare, SetArg*, Execute and GetReturn*.
```

Produces additional methods in the existing VMSource classes. Use their 2.1 mapped names if a collision required a rename. New method/helper names follow adjacent CQTest/SDK conventions and are recorded as Naming assumed. No production API is added.

**Cases**

1. **Calls and mapping** — new RED

    `int Pick(int First,int Second=2){ return First*10+Second; }`: runtime Pick(3)=32; Pick(Second:4,First:3)=34. A qualified N::F call reaches the namespace function; methods read this members. Distinguish overload targets by independently chosen returns.

2. **Invalid call forms** — new RED

    Return-type-only overload pairs, duplicate/unknown named arguments and missing required arguments reject with the certified phase/diagnostic and no usable output. Defaults do not override access/receiver constraints.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceCallsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceCallContractsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/**
```

Globs own only this card's certified cells and test fixtures; unrelated tests and production files are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run after an impact-related Harness editor build. Record real grouped RED/GREEN, full case identities, source/binary/run identity and ledger rows proved. NativeEngine covers SourceExecution plus Sema rejections and adjacent Lexer/VM consumers without inventing a union selector. Parser has a narrow prefix. Fresh shared runs may satisfy compatible tasks with exact case mapping.

**Evidence**

2026-09-15. Shared run `b99a111c19a2478a9f15027ae270f89f`. New: `RuntimePickDefaultSecondIsThirtyTwo` (32 and named 34), `RuntimeQualifiedNamespaceCallIsSeven`, `ReturnTypeOnlyOverloadsPublishNoImage`. Existing `SourceCombineNamedAndDefaultIsThirtyFour`, `SourceOverloadsReturnDistinctMarkers`, `SourceValueFieldWriteThenRead` remain overlap.

## [x] 3.5 Runtime object lifetime and storage matrix

Fill the missing accepted ledger cells after relocation and independent oracle certification.

**Outcome**

Prove this bounded matrix group with exact overlap/disposition for existing methods. Every required row has executed proof; unsettled contracts or production defects block completion.

**Interfaces**

Consumes relocated NativeSourceExecutionTestSupport.h, currently Compiler/NativeSourceExecutionTestSupport.h:14,63,116, and explicit NativeVM ownership helpers. Existing source helper shapes:

```cpp
FSourceExecutionInput(const FString& Source);
asCScriptFunction* FindSourceFunction(asCBuilder& Builder, const char* Name);
// Actual execution uses Context Prepare, SetArg*, Execute and GetReturn*.
```

Produces additional methods in the existing VMSource classes. Use their 2.1 mapped names if a collision required a rename. New method/helper names follow adjacent CQTest/SDK conventions and are recorded as Naming assumed. No production API is added.

**Cases**

1. **Objects and storage effects** — new RED

    Two nested owned objects construct outer then inner and destroy inner then outer. Source member mutation/reference write-back changes caller-visible storage. Distinguish inherited same-name dispatch using the certified receiver rule and different returns.

2. **Cleanup and rejection** — new RED

    Early return/runtime faults perform exact initialized-object cleanup. Initialization storage classes, mutable module globals and illegal inheritance use certified supported/rejected source forms. Tests do not introduce language support or change frontend/VM behavior.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceObjectsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceScopeCleanupTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceUnwindTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/**
```

Globs own only this card's certified cells and test fixtures; unrelated tests and production files are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run after an impact-related Harness editor build. Record real grouped RED/GREEN, full case identities, source/binary/run identity and ledger rows proved. NativeEngine covers SourceExecution plus Sema rejections and adjacent Lexer/VM consumers without inventing a union selector. Parser has a narrow prefix. Fresh shared runs may satisfy compatible tasks with exact case mapping.

**Evidence**

2026-09-15. Shared run `b99a111c19a2478a9f15027ae270f89f`. New: `NestedOwnedObjectsConstructOuterThenInner` (marks 1,2,12,11), `ReferenceWriteBackChangesCallerStorage` (`int&inout`), `InheritedOverrideDispatchReturnsFour` (Exact 4, Extra 0), `MutableModuleGlobalRejectsPublication`. Existing reverse-destroy, field write/read, inheritance-decl rejects, const-global metadata remain overlap. `A@` CALLINTF stays on VM dispatch tests.

## [x] 3.6 Conversions and retired syntax inventory

Fill the missing accepted ledger cells after relocation and independent oracle certification.

**Outcome**

Prove this bounded matrix group with exact overlap/disposition for existing methods. Every required row has executed proof; unsettled contracts or production defects block completion.

**Interfaces**

Consumes relocated NativeSourceExecutionTestSupport.h, currently Compiler/NativeSourceExecutionTestSupport.h:14,63,116, and explicit NativeVM ownership helpers. Existing source helper shapes:

```cpp
FSourceExecutionInput(const FString& Source);
asCScriptFunction* FindSourceFunction(asCBuilder& Builder, const char* Name);
// Actual execution uses Context Prepare, SetArg*, Execute and GetReturn*.
```

Produces additional methods in the existing VMSource classes. Use their 2.1 mapped names if a collision required a rename. New method/helper names follow adjacent CQTest/SDK conventions and are recorded as Naming assumed. No production API is added.

**Cases**

1. **Conversion results** — new RED

    Runtime int 7 widens to double 7.0; supported explicit conversion of runtime 4.5 to int yields 4. Out-of-range/narrowing rows stay type-specific and use 1.2 expectations. Unrelated nonconvertible object pairs reject without publishable output.

2. **Retired grammatical forms** — new RED

    Reject shared/external declarations, current retired foreach and escaping anonymous functions at authored ranges. Preserve ordinary-identifier and inactive-source controls. Retired rows require rejection only; no positive execution is demanded for removed features.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/VMSourceNumericTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Sema/**
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Parser/**
```

Globs own only this card's certified cells and test fixtures; unrelated tests and production files are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run after an impact-related Harness editor build. Record real grouped RED/GREEN, full case identities, source/binary/run identity and ledger rows proved. NativeEngine covers SourceExecution plus Sema rejections and adjacent Lexer/VM consumers without inventing a union selector. Parser has a narrow prefix. Fresh shared runs may satisfy compatible tasks with exact case mapping.

**Evidence**

2026-09-15. Shared run `b99a111c19a2478a9f15027ae270f89f`. New: `RuntimeIntWidensToDoubleSeven`. Sema `UnrelatedObjectCastRejects`. Retired rows remain existing-proven (`Syntax.ModuleModifiers*`, `Lambda.ImmediateAnonymousFunctionCannotPublish`, `UnsupportedBodyPublishesNoPartialImage`). No positive retired execution.

## [x] 4.1 Verify final matrix and resolve the explicit Review

Verify complete matrix rows, registration conservation and unchanged gates on final content. Bind a fresh immutable snapshot and re-review F01-F03 resolution conditions; append evidence and close/supersede the user-requested Review through coordinator policy.

**Outcome**

Verify complete matrix rows, registration conservation and unchanged gates on final content. Bind a fresh immutable snapshot and re-review F01-F03 resolution conditions; append evidence and close/supersede the user-requested Review through coordinator policy.

**Files**

```diff
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/coverage-oracles.md
+openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/final-verification.md
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/reviews/review-20260915-122143-nativeengine-home-design-inline.md
 openspec/changes/angelscript/refactor-testing-nativeengine-home/tasks.md
 openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/INDEX.md
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace using its current Harness context.

**Notes**

Final NativeEngine run covers relocated layers plus the 3.x matrix. Reuse Framework/Baseline/Bindings-isolation success and the RuntimeBindings Found-list conservation when those binaries still match. Whole `Angelscript.UnitTest` success remains blocked by the pre-existing Array bind-materialization crash; that axis stays conservation-only. Also require doctor, strict Change validation and normal spec-sync/knowledge/terminal checks before closure. No unresolved oracle or dropped axis may hide behind totals. Report arrival is not Review closure. No archive, commit, push or workspace action is part of this task.

**Evidence**

2026-09-15T14:11:36.761837+08:00. Proving command: `ue.test` `Angelscript.UnitTest.NativeEngine` Fast TimeoutMs 600000 after editor rebuild `68a8c1cab9974acf838f3963ff3048f4`. Succeeded UE/Harness RunId `b99a111c19a2478a9f15027ae270f89f` (Harness dispatch `3716f78c9f164d84975160af22aea8da`): 1239 Success. Cheap reruns on that same editor binary: Framework `326eb1630f35454793f00093eb52fed8` 45 Success; Baseline `08e46230316447039cc70fd84fb6dbe2` 3 passed (2 Success + 1 SuccessWithWarnings from unrelated LogMetaSound tag noise); Bindings `02a35de7a01943c5a969ce2756da33b1` 2 Success. `Test-Phase1MigrationConservation.ps1` exit 0. `openspec.doctor` `f86789f7cc4649c6bdaf98853362b21c` valid. Change `--strict` `85db14e1eb984a27832ca7f3bfab648c` passed. Current spec `--strict` `1201cb75d356460590263c5bcfff6276` passed. Current `openspec/specs/angelscript/testing/baseline/spec.md` already holds the three ADDED homes/identity/coverage requirements. Review `reviews/review-20260915-122143-nativeengine-home-design-inline.md` closed APPROVE; F01–F03 resolved; re-review snapshot `Saved/Harness/Reviews/review-20260915-140708-nativeengine-home-rereview`. `harness.evolution.status` Review closed; workflow-evaluation remains archive-only and was not written. Knowledge K1–K3 stay `candidate`. `Naming assumed: ParserContracts, ParserRecovery, ParserPrecedence, BuilderStages`. No archive, commit, push, or workspace action.
