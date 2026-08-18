# Task 2.16 — call-target and body-ownership provenance

## Decision

Compiler-owned HIR records a stable semantic coordinate for each resolved call,
not the target selected by mutable runtime state. The representation distinguishes:

- a concrete script function and its declaration/body-owning module;
- a registered system function with a Runtime-owned native body;
- an imported-function signature slot plus import source module and canonical
  signature;
- a locally owned, other-module, shared-owned, shared-borrowed or
  external-borrowed script body.

An imported target deliberately retains its `FUNC_IMPORTED` function ID only as
the maintained fork's stable import-slot coordinate. Capture never reads or
serializes `sBindInfo::boundFunctionId`. Bind, rebind and unbind therefore change
runtime dispatch without changing the HIR or its deterministic dump.

## Runtime and compiler authority

The maintained fork supplied the authoritative paths:

- ordinary script/system/import target selection is already final when
  `asCCompiler` builds the resolved call;
- `asFUNC_IMPORTED` identifies the imported signature object, while
  `engine->importedFunctions[id & ~FUNC_IMPORTED]` owns the source-module and
  canonical-signature record;
- `sBindInfo::boundFunctionId` is mutable runtime state used by execution and is
  not a compiler semantic identity;
- `asCModule::globalFunctionList`, `externalFunctions`, the target's original
  module and `asTRAIT_SHARED` are the current fork's body-ownership authority.

The new `asSTypedSemanticFunctionTargetProvenance` is pointer-free. Function
headers separately record the compiler transaction module, body availability,
body ownership and body owner. Verifier rules reject partial or contradictory
tuples, including an imported slot carrying a concrete bound target.

## TDD coverage and test ownership

The source-backed tests live under the capability-owned directory
`AngelScriptSDK/Compiler/TypedSemanticIR/CallTargets/`:

- `AngelscriptNativeTypedSemanticIRImportedCallTargetTests.cpp` compiles provider
  A, provider B and one importing consumer. Provider A returns 11, provider B
  returns 29. It proves bind, rebind and unbind alter VM behavior while HIR and
  dump retain the same import slot/source/signature and never retain either
  mutable bound ID. Malformed source and a fabricated frozen bound ID fail
  verification.
- `AngelscriptNativeTypedSemanticIRBodyOwnershipTests.cpp` covers local script,
  registered system, shared owner/borrower and external borrower tuples plus
  malformed verifier cases.
- `AngelscriptNativeTypedSemanticIRCallTargetTestSupport.h` shares only the
  narrow raw-SDK Engine/module/HIR helpers used by those scenarios.

Consumer fixtures in TypedASTJIT Eligibility, CallClosure and GeneratedOutput
were extended only for the fields they synthesize; compiler-capture ownership
remains in the compiler test directory.

## Maintained-fork fixture limitation

The parser still contains disabled/commented shared/external source-token paths,
so a public source fixture cannot honestly claim those declarations are enabled.
The ownership test uses the maintained builder seam instead: it preinstalls the
relevant module function relationship and compiles the caller with
`CompileFunction(..., asCOMP_ADD_TO_MODULE)`. Calling `asCModule::Build()` was
initially incorrect because `Build()` performs `InternalReset()` and erased the
preinstalled relationship. The final fixture tests the real module arrays used
by production capture without re-enabling unsupported public syntax.

This limitation is explicit: the task proves the compiler/runtime ownership
model, not public shared/external language admission.

## Problems found while closing the task

1. The first registration assertion expected `asSUCCESS`, but
   `RegisterGlobalFunction` returns a non-negative function ID. The test now
   validates the documented return shape.
2. The maintained canonical script declaration includes the parameter's
   effective `const` spelling, while a registered native declaration retains
   its registered spelling. Exact oracles now distinguish the two.
3. Target provenance was accidentally rendered from the assignment dump branch
   instead of the resolved-call branch. The dump now emits the tuple adjacent to
   the actual call.
4. Standalone non-unity compilation exposed that `as_typed_semantic_ir.cpp`
   consumed `asCTypeInfo` without directly including `as_typeinfo.h`; the direct
   include now makes the fork source self-contained.
5. An earlier Runtime change made `as_context.cpp` include the UE-owned
   `StaticJIT/AngelscriptJITExecutionContext.h`. Standalone must not import UE
   Runtime. `Standalone/Compat/StaticJIT/AngelscriptJITExecutionContext.h`
   supplies only the existing VM-entry compatibility behavior and the
   Architecture test confirms that no UObject/provider/ref-resolver/DLL model is
   introduced.
6. The first fully linked Standalone run reported SemanticObserver 19/20. Adding
   failure-only verifier detail forced that test executable to relink; it then
   passed 20/20, and a no-source-change repeat also passed 20/20. MSBuild emitted
   `MSB8028` shared-intermediate warnings on both runs. The evidence supports an
   old incremental link product rather than a production verifier failure, but
   this remains recorded as an observed toolchain hazard rather than asserted as
   a proven CMake root cause. The retained diagnostic will print null HIR,
   verifier error/detail and the full HIR dump if it recurs.

## Evidence

- expected API/contract RED build:
  `Saved/Build/typed-semantic-task216-call-target-red/
  20260817_013314_895_29e2705d/`;
- implementation build:
  `Saved/Build/typed-semantic-task216-call-target-green-build5/
  20260817_014918_616_7aaa8479/` — PASS;
- focused call-target/body-ownership tests:
  `Saved/Tests/typed-semantic-task216-call-target-focused5/
  20260817_014937_201_7db0344c/` — `2/2 PASS`;
- complete TypedSemanticIR regression:
  `Saved/Tests/typed-semantic-task216-hir-regression1/
  20260817_015024_267_8fecc4b2/` — `57/57 PASS`;
- TypedASTJIT eligibility/call-closure regression:
  `Saved/Tests/typed-semantic-task216-eligibility-regression1/
  20260817_015112_743_1a5bf4ab/` — `30/30 PASS`;
- TypedASTJIT generated-output regression:
  `Saved/Tests/typed-semantic-task216-generated-output-regression1/
  20260817_015148_925_09cc7bc7/` — `25/25 PASS`;
- Standalone after diagnostic relink:
  `Saved/StandaloneTests/
  typed-semantic-task216-standalone-diagnostic_01_Standalone/
  20260817_015857_651_40634119/` — `20/20 PASS`;
- no-source-change Standalone confirmation:
  `Saved/StandaloneTests/
  typed-semantic-task216-standalone-confirm_01_Standalone/
  20260817_020000_204_29bca196/` — `20/20 PASS`;
- final UE build after the fork include and Standalone compatibility changes:
  `Saved/Build/typed-semantic-task216-final-green/
  20260817_020057_017_69296247/` — PASS, 4/4 actions.

Task 2.16 is complete. Downstream TypedASTJIT must consume the stable provenance
and current provider/reference-slot authorities; it must not reinterpret the
diagnostic canonical declaration as dispatch identity.
