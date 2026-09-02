# CompileFunction canonical cutover gate (2026-08-24)

## Scope

This gate advances Tasks 0.2, 10.1, 10.3, 10.4, 13.1, 13.6, and the
CompileFunction-completeness part of 13.8. It covers the public
`asIScriptModule::CompileFunction` entry point in a CANONICAL-selected Engine;
builder-level LEGACY comparison tests remain a separate opt-out path.

## AST-first test source and methods

- Source:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`
- Methods:
  - `SourceBuildPurposesSelectCanonicalAndExecute`
  - `CompileFunctionAddToModuleRetiresIncompleteSnapshot`
  - `CanonicalCompileFunctionDetachedKeepsCompleteSnapshotCurrent`
  - `CanonicalCompileFunctionFailureLeavesPublishedGenerationUntouched`
  - `CanonicalCompileFunctionOwnsNestedLambdaClosureWithoutExposingIt`
  - `CanonicalCompileFunctionBindsCurrentModuleFunctionsAndGlobals`

Fixtures:

```angelscript
int Extra()
{
    return 11;
}
```

and the retained complete-module baseline:

```angelscript
int F()
{
    return 1;
}
```

## Required sealed/public facts

Before execution evidence counts, the single-function source must:

1. enter Parser + Sema and produce exactly one direct, non-lambda function
   declaration under the translation unit;
2. seal and pass publication verification;
3. be consumed by `asCBytecodeCodeGen`, which records a non-zero digest of that
   exact sealed ephemeral AST;
4. publish `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` with zero
   `asCCompiler` invocations;
5. execute the emitted function successfully;
6. for `asCOMP_ADD_TO_MODULE`, add the function only after complete emission,
   then retire the previous retained module snapshot because the ephemeral
   graph is not a complete replacement module graph;
7. keep the retired lease immutable/readable and make a fresh snapshot acquire
   return null until a later complete `Build()` republishes a full generation;
8. for detached compilation, register executable function IDs without adding
   any function to the module inventory and release all temporary ownership
   correctly when the caller releases the function;
9. project already-published symbols from the current module into only this
   ephemeral Sema graph as declaration-only views, then bind them back to their
   exact Runtime function/property without requiring automatic imports or
   republishing module inventory.

Failure before commit must leave the function inventory, current retained
snapshot, Engine function allocator, and prior executable functions unchanged.

## Red baseline

Build after adding the assertions:

- PASS:
  `Saved/Build/cta-compilefunction-canonical-red-build-v2/20260824_182104_577_f63084b3`

Focused gate:

- `CanonicalAST.Cutover`: **5/7 PASS, 2/7 FAIL, 0 skipped**
- Evidence:
  `Saved/Tests/cta-compilefunction-canonical-red/20260824_182123_250_44282b69`
- Exact failures:
  - `SourceBuildPurposesSelectCanonicalAndExecute`: single-function compile
    published `asBYTECODE_PUBLISHER_COMPILER` instead of Canonical CodeGen.
  - `CompileFunctionAddToModuleRetiresIncompleteSnapshot`: public
    `CompileFunction` did not publish from `asCBytecodeCodeGen`.

The function compiled and executed before both assertions failed, proving the
red condition is backend provenance rather than syntax/runtime breakage.
Current source confirms the cause: `asCBuilder::CompileFunction` attaches
canonical Sema, then discards that graph and instantiates `asCCompiler` for
every non-restored function.

The detached lifecycle assertion was then added separately and failed only on
the same publisher fact:

- Build PASS:
  `Saved/Build/cta-compilefunction-detached-red-build/20260824_182402_454_4d0fe09e`
- Test **0/1 PASS, 1/1 FAIL**:
  `Saved/Tests/cta-compilefunction-detached-red/20260824_182421_113_fec90405`
- The detached function already returned `13`, left module inventory unchanged,
  and kept the complete retained snapshot current. Only the legacy publisher
  assertion failed.

After the initial single-function transaction was green, the detached lambda
fixture was strengthened to call the already-attached `AttachedLambda()`.
That produced a second, narrower red gate:

- Build PASS:
  `Saved/Build/cta-compilefunction-cross-module-call-build/20260824_184316_877_77c8a86a`
- Exact test **0/1 PASS, 1/1 FAIL**:
  `Saved/Tests/cta-compilefunction-cross-module-call/20260824_184334_273_1b37b8ea`
- Sema rejected `AttachedLambda()` as `unresolved-callee`; no publication was
  attempted.

The cause was not Cache V2. A complete module source graph naturally contains
all of its declarations, while public `CompileFunction` intentionally parses
only one function. Canonical Sema therefore needed an explicit, read-only view
of the current module scope. Reusing cross-module automatic-import lookup would
have been incorrect because it requires `automaticImports`, excludes the owner
module, and could bind a same-named producer.

## Green implementation boundary

The intended implementation reuses the standard Parser/Sema source session,
seals a short-lived function AST, and invokes a single-function mode of
`asCBytecodeCodeGen`:

```text
CompileFunction source
    -> current-module read-only symbol views (CompileFunction only)
    -> Parser + Sema
    -> sealed ephemeral AST
    -> detached CodeGen artifact
         |- flags=0: Engine-visible function, no module inventory mutation
         `- ADD_TO_MODULE: validate-all -> commit-all to the owner module
    -> JITCompile
```

No new public ABI is required. The ephemeral graph is deleted after CodeGen and
never replaces a retained complete-module snapshot. A successful attached
compile invalidates that snapshot exactly once; detached compilation leaves it
current.

The gate is green only after the two named methods, the Module CompileFunction
API contract, Canonical ProductionCodeGen, and a full Editor/plugin build pass.

## Green result

The public module entry point now selects one of two explicit implementations:

```text
CANONICAL
  source -> Builder source session -> Parser/Sema -> Seal
         -> asCBytecodeCodeGen::GenerateFunction
         -> attached Commit or detached Engine-only Commit

LEGACY opt-out
  source -> asCBuilder::CompileFunction -> asCCompiler
```

`GenerateFunction` accepts exactly one direct source function and any nested
lambda declarations. Its primary function retains the established
`PUBLIC_SINGLE_FUNCTION` build-artifact identity. Attached publication transfers
the emitted closure into module ownership and gives the public API a temporary
internal reference; detached publication installs Engine function IDs without
touching the module and leaves that same temporary reference on the primary.
Nested functions keep only real signature/bytecode references. Lambdas remain
internal script functions and are not inserted into the module's global
function lookup.

The ephemeral Sema session now projects exact default-namespace functions and
globals already owned by the module. Each projected declaration carries a
dedicated origin. CodeGen accepts that origin only by exact namespace,
signature/type, and owner-module match, then binds the existing Runtime object
as an emitter lookup entry. The view is never appended to the detached artifact
and therefore cannot allocate, commit, roll back, or duplicate a module symbol.
The hook is invoked only by public `CompileFunction`; full module replacement
builds cannot observe the previous generation through it.

Fresh evidence:

- Runtime/Editor production build PASS:
  `Saved/Build/cta-compilefunction-current-module-scope/20260824_184958_636_426b36fe`
- Added current-module global gate build PASS:
  `Saved/Build/cta-compilefunction-current-module-global-test/20260824_185322_611_78510d1e`
- CompileFunction failure + nested lambda lifecycle: **2/2 PASS**:
  `Saved/Tests/cta-compilefunction-atomic-lambda/20260824_183715_179_cfd6a8db`
- Strengthened detached lambda + current-module function call: **1/1 PASS**:
  `Saved/Tests/cta-compilefunction-current-module-call-green-v2/20260824_185211_029_d3f74fec`
- Exact current-module function + global binding: **1/1 PASS**:
  `Saved/Tests/cta-compilefunction-current-module-global/20260824_185341_124_0ce8aaea`
- Complete Canonical Cutover: **11/11 PASS**:
  `Saved/Tests/cta-compilefunction-current-module-cutover/20260824_185425_186_e3ed8f87`
- Complete Canonical ProductionCodeGen: **73/73 PASS**:
  `Saved/Tests/cta-compilefunction-current-module-production-codegen/20260824_185501_893_4a55a886`
- Exact public CompileFunction + snapshot API: **2/2 PASS**:
  `Saved/Tests/cta-compilefunction-current-module-public-api-snapshot/20260824_185603_065_657bf0f0`

The failure test compares the complete Engine function-slot array and free-ID
stack, module inventory, prior executable function identity, canonical digest,
and current/fresh snapshot generation before and after a rejected compile. The
lambda test executes both attached and detached capturing closures and proves
only the primary enters public module lookup. The module-scope test builds an
authoritative module containing `CurrentValue` and `CurrentFunction`, compiles
a detached reader, executes `40 + 2 == 42`, and proves both public inventory
counts remain unchanged.

Cache V2 is not part of this gate. It remains default-disabled and is deferred
to a later dedicated redesign. Preserving the public single-function invocation
kind is a compatibility invariant, not new Cache V2 implementation work.
