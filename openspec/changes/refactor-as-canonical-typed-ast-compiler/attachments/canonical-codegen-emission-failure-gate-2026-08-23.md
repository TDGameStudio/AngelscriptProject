# Canonical CodeGen emission-failure gate — 2026-08-23

Worktree: `D:\as-cta`
OpenSpec tasks: `0.2`, `9.1`, `13.6`
Scope: deterministic diagnostic/failure injection for the existing Canonical
Bytecode CodeGen artifact rollback matrix.

## Problem and root cause

Three transaction tests used the source statement `fallthrough` as their
post-first-function CodeGen failure injector. That was never a durable
transaction contract: it depended on a temporary gap in lowering support.
Once Canonical CodeGen correctly began emitting fallthrough as a no-op between
contiguous case bodies, all three tests falsely failed by requiring the valid
source to be rejected.

The observed baseline is authoritative:

```text
Target: Frontend.CanonicalAST.CodeGen.Transaction
Result: 9 passed, 3 failed, 0 skipped

Failed tests:
  - CodeGenEmitterFailureAfterPriorFunctionLeavesNoTables
  - CodeGenEmitterFailureAfterImportLeavesNoImportSlots
  - CodeGenEmitterFailureAfterClassMethodsLeavesNoDanglingTypeFunctionIds
```

All three reported their assertion that fallthrough “must fail”, not a leak in
an engine/module table. The baseline report is
`Saved/Tests/cta-codegen-transaction-baseline-20260823/20260823_164530_604_2441e1ff/RunMetadata.json`.

## Gate card: deterministic post-first-body rollback

- **OpenSpec task(s):** `9.1`, `13.6`.
- **Source fixtures:**
  1. `LeakedType`, `First()`, and `Second()`;
  2. `import int ImportedValue() ...`, `First()`, and `Second()`; and
  3. `LeakedMethodType::FirstMethod()` and `SecondMethod()`.
- **Canonical fact:** after `Parser → Sema → Seal`, each fixture retains the
  exact source owner/declarations that surround the requested CodeGen boundary:
  class plus global functions, import plus global functions, or class plus
  member functions.
- **AST test:**
  `AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp`, the three
  `CodeGenEmitterFailureAfter*` methods. Before calling CodeGen, each method
  seals and dumps the source-built canonical AST and asserts the relevant class,
  import, and stable function keys. This is the source-path AST-first gate; it
  does not infer the input shape from the later VM result.
- **AST-red:** this repair has no semantic-AST defect to manufacture. The
  historical source-path AST behavior was already green; the relevant red
  state was the stale failure injector. The first new behavior was therefore
  tested at the CodeGen interface boundary: the test called the missing
  `SetTestFailureBeforeFunctionEmission` API and the supported build failed
  exactly with C2039 (member absent). Evidence:
  `Saved/Build/cta-codegen-test-hook-red/20260823_164841_779_575ae960/RunMetadata.json`.
- **AST/provenance green:** all three source-built graphs seal and satisfy the
  pre-CodeGen dump assertions in the final transaction run. The failure detail
  is `injected-function-emission ordinal=1 function=<stable-key> error=<code>`;
  it identifies a CodeGen boundary rather than an unsupported language form.
- **CodeGen/lifecycle green:** a test-only method, compiled only with
  `WITH_ANGELSCRIPT_UNITTESTS`, injects a specified error before the requested
  function body emission. `Generate()` runs `artifact.Abandon()` and the
  existing global cleanup path, then returns the requested error. The methods
  compare module/engine function, import, global/property, type, allocator,
  address-map, behavior-reference, and publisher snapshots. Normal builds
  have neither the method nor the injection branch.
- **Focused regression:**
  `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction`
  — **17/17 PASS**, zero failures/skips:
  `Saved/Tests/cta-codegen-transaction-commit-method-final-green/20260823_171244_217_d42df912/RunMetadata.json`.
- **Build:** `Tools\RunBuild.ps1 -Label cta-codegen-commit-stages-final-build
  -TimeoutMs 1800000 -NoXGE` exited zero:
  `Saved/Build/cta-codegen-commit-stages-final-build/20260823_170957_212_9a49ee12/RunMetadata.json`.
- **Remaining boundary:** this is a direct `Generate()` artifact test. It now
  injects immediately after each *currently supported* `Commit()` phase, but
  does not cover per-item allocation/exceptions inside a phase, funcdefs or
  other unsupported declaration shapes, candidate-to-active module promotion,
  or full-language Sema/CodeGen authority. It must not close `9.1`, `9.5`,
  `13.6`, or any section-10 cutover task.

## Design

`asCBytecodeCodeGen::SetTestFailureBeforeFunctionEmission(asUINT ordinal,
int error)` exists only under `WITH_ANGELSCRIPT_UNITTESTS` in the maintained
fork internal CodeGen header. The default ordinal is disabled. During the
normal emission loop, ordinal `1` means:

```text
sealed AST has been validated
  → candidate types/globals/imports/signatures prepared
  → body 0 emitted into the detached candidate function
  → inject before body 1
  → artifact.Abandon + global cleanup
  → no Commit and no publisher/digest claim
```

It deliberately uses a real, fully supported source fixture. This makes the
transaction oracle independent from which language features are currently
supported, and it makes the failure detail searchable when a future regression
is diagnosed. It is not a public scripting, cache, or provider interface.

## Commit publication-stage extension

The first emission-boundary gate only proved rollback before `Commit()`. The
artifact's four currently implemented publication phases are independent
mutation boundaries:

```text
candidate artifact
  ├─ publish script types
  ├─ publish global properties + address-map/importable-global index
  ├─ publish imports + engine import slots
  └─ publish script functions + module/global-function/importable-function indexes
```

`asEBytecodeCodeGenTestCommitStage` and
`SetTestFailureAfterCommitStage(stage, error)` exist only under
`WITH_ANGELSCRIPT_UNITTESTS`. They inject after one completed phase and return
through the ordinary `Generate() → artifact.Abandon()` failure path. Neither
the enum, setter, hook arguments, nor injection branches exist in a normal
runtime build.

Each of these source-path tests first parses, semantically builds, seals, and
dumps its own AST fixture before it requests a failure:

| Stage | Source AST fact asserted before CodeGen | Rollback oracle |
| --- | --- | --- |
| types | `CommitTypeStage`, `StageFunction()` | module/engine type indexes |
| globals | `__StaticType_CommitGlobal`, `StageFunction()` | module globals, property allocator, `varAddressMap`, importable-global index |
| imports | `CommitImportedValue`, `StageFunction()` | module bind information and engine import allocator/slots |
| functions | `CommitType`, `First()`, `Second()`; and `CommitMethodType::FirstMethod/SecondMethod` | module function lists, class-method ownership, engine function allocator/slots, importable-function index |

The shared snapshot also checks `allScriptGlobalFunctions`,
`allScriptGlobalVariables`, and `allScriptDeclaredTypes`; these are non-owning
automatic-import/type-lookup indexes that an ordinary table-count test would
miss.

### Observed red and repair

The API-contract red build was
`Saved/Build/cta-codegen-commit-hook-red/20260823_170008_595_64736c73/RunMetadata.json`:
the source test named a missing `SetTestFailureAfterCommitStage` method and
missing `asBYTECODE_CODEGEN_TEST_COMMIT_AFTER_FUNCTIONS` stage.

After the test-only hook existed, the function-stage runtime red was
`Saved/Tests/cta-codegen-commit-after-functions-runtime-red/20260823_170119_780_0f8b43a4/RunMetadata.json`.
It proved a real partial-publication bug rather than a test assumption:

```text
engine script-function slots: restored
module GetFunctionCount / scriptFunctions / globalFunctionList: leaked
engine allScriptGlobalFunctions: leaked
```

`asSBytecodeCodeGenArtifact::Abandon()` now first removes a partially
published function from its module function/global-function maps and from
`allScriptGlobalFunctions`, then removes its engine slot and destroys the
candidate. It also removes a partially published property from
`allScriptGlobalVariables` before `RemoveGlobalVar()` can release it. These
operations are idempotent for pre-Commit abandonment.

The four-stage phase group passed **4/4** after the repair:
`Saved/Tests/cta-codegen-all-commit-stages-green/20260823_170544_301_9f423858/RunMetadata.json`.
The additional class-method function-stage fixture passed, and the full
transaction result is the **17/17** record above.

## Verification sequence

1. **Red:** add the desired contract to one source-path transaction test;
   `Tools\RunBuild.ps1 -Label cta-codegen-test-hook-red -TimeoutMs 1800000
   -NoXGE` failed with the expected missing-member C2039 error.
2. **Green API/build:** add only the test-gated hook and no default behavior;
   `Tools\RunBuild.ps1 -Label cta-codegen-test-hook-green-one -TimeoutMs
   1800000 -NoXGE` exited zero.
3. **Green single behavior:** exact test path
   `...CodeGenEmitterFailureAfterPriorFunctionLeavesNoTables` passed **1/1**:
   `Saved/Tests/cta-codegen-injected-rollback-one-green/20260823_164943_342_a7a30162/RunMetadata.json`.
4. **Emission-boundary matrix:** after applying the same stable boundary to
   import and class-method fixtures, the historical emission-only group passed
   **12/12**:
   `Saved/Tests/cta-codegen-transaction-injection-green/20260823_165112_972_4ba97967/RunMetadata.json`.
5. **Commit-boundary red/green:** the missing API was the contract red; the
   first function-publication execution exposed leaked module/global indexes;
   the corrected type/global/import/function stage group passed **4/4**.
6. **Combined matrix:** the current full transaction group passed **17/17**
   at the path recorded above.

The intentionally failing build is TDD evidence, not a healthy-build result.
The two later build/test reports are the current verification evidence.
