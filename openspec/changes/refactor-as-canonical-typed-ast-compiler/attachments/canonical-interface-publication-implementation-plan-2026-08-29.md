# Canonical Interface Publication Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:executing-plans` to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking. The main thread owns implementation,
> builds, tests and commits. Subagents may perform read-only bounded audits but
> may not edit files, run builds/tests, commit or publish.

**Goal:** Make lexical AngelScript interfaces and class/interface dispatch a
sealed Sema-owned Canonical fact that Canonical CodeGen publishes atomically as
correct Runtime interface shells, slots, offsets and dispatch tables.

**Architecture:** Canonical Sema records exact record-owned method relations as
`implementation -> requirement` declaration edges. The final verifier,
traversal, deterministic dump and pointer-free Sidecar authenticate and preserve
those edges. CodeGen binds exact declaration IDs to candidate Runtime objects,
mechanically prepares the generation-local dispatch projection, and publishes
it only through the existing candidate `Commit()`/`Abandon()` transaction.

**Tech Stack:** AngelScript maintained-fork C++, Canonical AST/Sema/verifier,
AngelScript VM bytecode, Unreal Automation/CQTest Native Core tests, OpenSpec.

**Spec:**
`openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/canonical-interface-publication-transaction-design-2026-08-29.md`

## Global Constraints

- Work only in `D:/as-cta`; use
  `D:/as-cta/AngelscriptProject.uproject` through the checked-in tool entry
  points.
- Do not edit or run Standalone in this slice.
- The product default remains LEGACY; do not change
  `ep.canonicalCompilerPipeline` defaults.
- Keep native `asCScriptNode`, Parser, `asCBuilder`, `asCCompiler`, and explicit
  LEGACY selection for syntax/recovery/reference/differential/rollback use.
- HIR is physically absent and must not be recreated.
- CANONICAL never silently invokes LEGACY and has no production `dual` mode.
- Public AST V1 remains unchanged; exact method relations are internal sealed
  facts in this slice.
- Numeric TypeId, Runtime pointers, function IDs, `vfTableIdx`, and interface
  offsets remain generation-local installation state.
- Use strict RED -> GREEN -> REFACTOR. No production change for a task precedes
  its focused failing test.
- New Native Core test files start with `AngelscriptNative`; registrations stay
  inside `#if WITH_ANGELSCRIPT_UNITTESTS`.
- Validate only through `Tools/RunTests.ps1`, `Tools/RunBuild.ps1`, and
  `Tools/RunTestSuite.ps1`; no direct UBT command.
- Commit plugin source/tests first, then update the parent gitlink and OpenSpec
  evidence.

## File Map

### Canonical semantic model

- Modify
  `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_decl.h`:
  define the pointer-free record-owned method-relation value and store its
  ordered array on `asCDecl`.
- Modify
  `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_context.h/.cpp`:
  add the construction-only `AddMethodRelation` API with normal lifecycle and
  snapshot-owner checks.
- Modify
  `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.h` and
  `as_sema_decl.cpp`: finalize exact base-override and interface-requirement
  relationships at `ActOnRecordFinishAction`.

The semantic value has this fixed shape:

```cpp
enum asEASTMethodRelationKind : asBYTE
{
	asAST_METHOD_RELATION_BASE_OVERRIDE = 0,
	asAST_METHOD_RELATION_INTERFACE_IMPLEMENTATION,
};

struct asSASTMethodRelation
{
	asEASTMethodRelationKind kind;
	asASTDeclId implementation;
	asASTDeclId requirement;
};
```

Relations live on the class/interface record declaration, not on the method
itself. That placement is required because an inherited base-class method may
satisfy an interface introduced only by a derived class.

### Verification and internal inspection

- Modify `as_ast_kind.h`, `as_ast_traversal.cpp`, and `as_ast_dump.cpp`:
  expose named relation implementation/requirement edges and deterministic
  `method-relations=` text/diff output.
- Modify `as_ast_verifier.cpp`: authenticate owner, relation kind, ancestry,
  method kinds, exact canonical callable signature, uniqueness and complete
  interface coverage.
- Modify `as_ast_sidecar.h/.cpp`: after the round-trip RED proves V7 erases the
  new irreducible semantic fact, append method-relation triples and bump the
  pointer-free schema to V8. Older versions remain safe misses.

### Runtime projection and transaction

- Modify `as_bytecode_codegen.h/.cpp`:
  register interface Runtime shells, create declaration-only
  `asFUNC_INTERFACE` functions, bind exact declarations to candidate functions
  and object types, prepare interface closure/slots/offsets/chunks without
  name/signature selection, validate prepared Stage 1/2 shells, and inject one
  test-only failure before publication.

### Tests

- Create
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaInterfaceDispatchTests.cpp`:
  AST-first semantic and Sidecar fidelity gate.
- Create
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionInterfaceDispatchTests.cpp`:
  Runtime shell, dispatch, exact-overload and transaction gate.
- Extend the nearest existing prepared-module case in
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` only for the
  `GeneratePreparedModule` shell-validation scenario; do not duplicate its
  substantial Stage 1/2 setup in another file.

### Records

- Add an issue attachment after the first Sidecar RED with the observed V7
  loss, exact test, root cause and V8 boundary.
- Add the final RED/GREEN/verification attachment and focused review under the
  same OpenSpec change.
- Update `tasks.md` progress under Tasks 0.2, 4.3, 4.5, 9.1, 9.5, 13.2 and
  13.6 without checking any umbrella task whose full sentence remains open.

---

### Task 1: Seal exact method relations in Canonical Sema

**Files:**

- Create:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaInterfaceDispatchTests.cpp`
- Modify: `.../source/as_decl.h`
- Modify: `.../source/as_ast_context.h`
- Modify: `.../source/as_ast_context.cpp`
- Modify: `.../source/as_sema.h`
- Modify: `.../source/as_sema_decl.cpp`

**Interfaces:**

- Consumes: sealed record declarations, `asCDecl::bases`, method/parameter
  declarations, canonical `asCQualType`, method traits.
- Produces:
  `int asCASTContext::AddMethodRelation(asASTDeclId owner,
  const asSASTMethodRelation& relation)` and ordered
  `asCDecl::methodRelations`.

- [x] **Step 1: Add the focused AST-first test registration and fixture**

Use prefix:

```cpp
TEST_CLASS_WITH_FLAGS(FCanonicalASTSemaInterfaceDispatchTests,
	"Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.InterfaceDispatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
```

The first fixture is:

```angelscript
interface IBaseProbe
{
    int Probe(int Value);
}

interface IDerivedProbe : IBaseProbe
{
    int Probe(bool Value);
}

class BaseProbe
{
    int Probe(int Value)
    {
        return Value + 1;
    }
}

class DerivedProbe : BaseProbe, IDerivedProbe
{
    int Probe(bool Value)
    {
        return Value ? 42 : 0;
    }
}
```

Add separate test methods named:

```text
ParserSealsExactOverrideAndInterfaceImplementationEdges
InheritedClassMethodSatisfiesDerivedInterfaceRequirement
OverloadedInterfaceRequirementsBindByCanonicalSignature
MissingInterfaceImplementationProducesSemaDiagnostic
ExplicitOverrideWithoutBaseTargetProducesSemaDiagnostic
```

The positive assertions inspect record-owned relations directly and require:

```text
DerivedProbe: interface BaseProbe::Probe(int) -> IBaseProbe::Probe(int)
DerivedProbe: interface DerivedProbe::Probe(bool) -> IDerivedProbe::Probe(bool)
IDerivedProbe: inherited requirement IBaseProbe::Probe(int) remains in closure
```

The overload assertion derives its expectations from literal declaration names,
parameter type refs and owners; it must not compare dump strings only.

- [x] **Step 2: Run the test and capture the expected RED**

Run:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.InterfaceDispatch" `
  -Label cta-interface-sema-red -TimeoutMs 600000
```

Expected: the new file either fails to compile because
`asSASTMethodRelation`/`methodRelations` are absent, or the structural
assertions fail because only `bases` exist. Record the exact failure and report
path before editing production files.

- [x] **Step 3: Add the smallest pointer-free relation model and writer API**

Add the enum/struct shown in the File Map, add:

```cpp
asCArray<asSASTMethodRelation> methodRelations;
```

to `asCDecl`, and declare:

```cpp
int AddMethodRelation(
	asASTDeclId owner,
	const asSASTMethodRelation& relation);
```

The context method rejects post-freeze mutation, foreign IDs, invalid relation
kind and an implementation equal to its requirement. It preserves insertion
order and rejects exact duplicate triples.

- [x] **Step 4: Resolve relations in Sema at record completion**

Add private Sema helpers with these responsibilities:

```cpp
bool MethodSignaturesMatch(
	const asCDecl& implementation,
	const asCDecl& requirement) const;
bool CollectRecordAncestry(
	asASTDeclId record,
	asCArray<asASTDeclId>& classChain,
	asCArray<asASTDeclId>& interfaceClosure);
bool FinalizeRecordMethodRelations(asASTDeclId record);
```

`MethodSignaturesMatch` requires equal name, return `asCQualType`, const-method
trait, ordered parameter count and every parameter `asCQualType`. It ignores
parameter spelling/default text. `FinalizeRecordMethodRelations` selects the
nearest exact class-chain method, records base overrides, then records exactly
one implementation for every own-method requirement in the transitive
interface closure. A missing/ambiguous requirement and an authored `override`
without a base target add stable source-located Sema diagnostics.

Invoke it from `ActOnRecordFinishAction` after all authored members exist and
before generated class lifecycle/accessor declarations alter the member set.

- [x] **Step 5: Run the focused gate and refactor while green**

Run the Task 1 command. Expected: all five methods pass with zero skips. Then
extract only repeated ancestry/signature logic; do not add Runtime fields or
CodeGen lookup.

- [x] **Step 6: Commit the semantic slice**

```powershell
git -C Plugins/Angelscript add -- `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_decl.h `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_context.h `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_context.cpp `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.h `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp `
  Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaInterfaceDispatchTests.cpp
git -C Plugins/Angelscript commit -m "[CanonicalAST] Refactor: seal exact interface method relations"
```

---

### Task 2: Authenticate, inspect and round-trip method relations

**Files:**

- Modify: `.../source/as_ast_kind.h`
- Modify: `.../source/as_ast_traversal.cpp`
- Modify: `.../source/as_ast_dump.cpp`
- Modify: `.../source/as_ast_verifier.cpp`
- Modify: `.../source/as_ast_sidecar.h`
- Modify: `.../source/as_ast_sidecar.cpp`
- Modify: the Task 1 test file
- Modify:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp`

**Interfaces:**

- Consumes: `asCDecl::methodRelations` from Task 1.
- Produces: publication-verifier admission, named traversal edges,
  deterministic dump/diff material, lossless Sidecar V8 triples.

- [x] **Step 1: Add verifier, traversal and Sidecar failing tests**

Add test methods:

```text
VerifierRejectsForeignWrongOwnerWrongSignatureAndDuplicateMethodRelations
TraversalNamesMethodRelationImplementationAndRequirementEdges
SidecarRoundTripPreservesExactMethodRelations
```

The verifier matrix creates hand-built contexts and calls `AddMethodRelation`
with a VarDecl, unrelated interface, wrong-signature method and duplicate
requirement assignment. Each `Seal()` must fail with a stable detail beginning
with `method-relation-`.

The traversal test requires two named reference edges per relation:

```text
decl-method-relation-implementation[index]
decl-method-relation-requirement[index]
```

The Sidecar test encodes a sealed positive fixture, decodes it into a fresh
context, and compares literal relation kind/source/target IDs after remap plus
the deterministic structural dump. It must not accept a matching textual name
as evidence.

- [x] **Step 2: Run RED for verifier/traversal and V7 round trip**

Run:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" `
  -Label cta-interface-verifier-red -TimeoutMs 600000
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.InterfaceDispatch" `
  -Label cta-interface-sidecar-red -TimeoutMs 600000
```

Expected: verifier/traversal lack relation rules, and the decoded V7 snapshot
has zero method relations. Record this exact loss in
`attachments/canonical-interface-sidecar-v8-issue-2026-08-29.md` before changing
the schema.

- [x] **Step 3: Add verifier and traversal/dump support**

Verification requires:

```text
owner kind is Class or Interface
implementation and requirement are Method declarations
implementation belongs to owner or its class ancestry
requirement belongs to legal class/interface ancestry
relation role agrees with requirement owner kind
canonical return/parameter/const signature is exact
one owner has at most one implementation for each requirement
every concrete-class interface requirement has one relation
```

Traversal emits both named indexed references. Tree text, structured text,
semantic diff and AST digest include relation kind plus source/target
declaration identity in insertion order.

- [x] **Step 4: Make the smallest lossless Sidecar V8 increment**

Bump:

```cpp
static const asUINT asAST_SIDECAR_SCHEMA_VERSION = 8;
```

Append a u32 relation count followed by `kind`, `implementation.value`, and
`requirement.value` for every declaration. Decode only after count/budget/kind/
ID validation, reconstruct through `AddMethodRelation`, and let final Seal
authenticate semantics. V1–V7 remain unsupported safe misses.

- [x] **Step 5: Run focused GREEN and deterministic repeat**

Run both Step 2 commands twice with new labels
`cta-interface-verifier-green` and `cta-interface-sidecar-v8-green`. Expected:
identical counts, zero failures/skips, and byte-identical normalized relation
dump on the repeated fixture.

- [x] **Step 6: Commit the verification/transport slice**

```powershell
git -C Plugins/Angelscript add -- `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_kind.h `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_traversal.cpp `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.cpp `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_sidecar.h `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_sidecar.cpp `
  Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaInterfaceDispatchTests.cpp `
  Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp
git -C Plugins/Angelscript commit -m "[CanonicalAST] Refactor: verify and preserve interface method relations"
```

---

### Task 3: Publish detached Runtime interface dispatch from exact edges

**Files:**

- Create:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionInterfaceDispatchTests.cpp`
- Modify: `.../source/as_bytecode_codegen.h`
- Modify: `.../source/as_bytecode_codegen.cpp`

**Interfaces:**

- Consumes: verified record-owned relations and exact `asSCodeGenFuncBind`
  declaration/function bindings.
- Produces: detached interface object shells, declaration-only interface
  functions and a validated generation-local class/interface dispatch
  projection.

- [x] **Step 1: Add Runtime/VM and rollback RED tests**

Use prefix:

```cpp
TEST_CLASS_WITH_FLAGS(FCanonicalASTProductionInterfaceDispatchTests,
	"Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.InterfaceDispatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
```

Add methods:

```text
CanonicalBuildPublishesDeclarationOnlyInterfaceMethods
InterfaceInheritanceExecutesThroughExactDispatchChunks
InheritedClassImplementationSatisfiesDerivedInterfaceAtRuntime
OverloadedInterfaceCallUsesSealedRequirementEdge
DispatchPreparationFailurePublishesNoEngineOrModuleEntries
FailedInterfaceReplacementKeepsLastGoodGenerationExecutable
```

The execution fixture returns literal values `42`, `101`, and `202` from
different overloads so a wrong slot is observable. Internal assertions require:

```cpp
InterfaceMethod->funcType == asFUNC_INTERFACE
InterfaceMethod->scriptData == nullptr
InterfaceMethod->vfTableIdx == authoredDeclarationOrdinal
ClassType->interfaces.GetLength() == ClassType->interfaceVFTOffsets.GetLength()
```

Bytecode assertions require the call through an interface-typed value to
contain `asBC_CALLINTF`. Publisher must be
`asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, with zero legacy compiler invocations.

The explicit CodeGen transaction test snapshots Engine function/type/free-list
and module inventory counts, injects failure after dispatch preparation but
before `Commit()`, runs `Generate`, and requires every count plus current
publisher/digest to remain unchanged.

- [x] **Step 2: Run Runtime RED**

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.InterfaceDispatch" `
  -Label cta-interface-production-red -TimeoutMs 600000
```

Expected: current registration omits interface types, bodyless methods are
skipped or misclassified, or Build fails before Runtime inspection. Capture
the exact first failure in the final gate attachment.

- [x] **Step 3: Register exact detached interface shells and functions**

Extend `RegisterCanonicalScriptTypes` to accept both Class and Interface
declarations. For Interface:

```cpp
st->flags = asOBJ_REF | asOBJ_SCRIPT_OBJECT;
st->isInterfaceDeclaration = true;
st->size = 0;
st->alignment = 1;
st->beh.construct = 0;
st->beh.copy = 0;
```

Do not require class byte size/alignment on an Interface. Record exact local
`recordDecl -> asCObjectType*` bindings for later projection.

Create every bodyless interface Method as:

```cpp
asNEW(asCScriptFunction)(engine, module, asFUNC_INTERFACE)
```

Reserve its function ID and fill callable identity/signature, but skip source
body metadata that requires `scriptData`. It enters binds/artifact publication
but never `emitDecls`.

- [x] **Step 4: Replace Runtime name/signature rematching with a prepared plan**

Introduce an internal helper with this conceptual interface:

```cpp
int PrepareCanonicalObjectDispatch(
	const asCASTContext& context,
	asCScriptEngine* engine,
	const asCArray<asSCanonicalObjectTypeBind>& typeBinds,
	const asCArray<asSCodeGenFuncBind>& functionBinds,
	asSBytecodeCodeGenArtifact* detachedArtifact,
	asCString& detail);
```

It uses relation declaration IDs only. It assigns interface-own method slots in
declaration order, copies base class slots, applies explicit base-override
relations, allocates new class slots, derives transitive interface closure, and
appends one chunk per interface using exact implementation relations. It
validates every pointer, owner, slot and table length before returning success.

Delete the name/signature selection loop from
`FinalizeOneCanonicalObjectInheritance`. A signature comparison may remain only
as a stale Runtime-shell assertion after the exact declaration binding has
already selected both functions.

- [x] **Step 5: Add and prove the pre-commit failure seam**

Under `WITH_ANGELSCRIPT_UNITTESTS`, add:

```cpp
void SetTestFailureAfterDispatchPreparation(int failureCode);
```

The check runs after the complete detached dispatch projection validates and
before relocation resolution/`artifact.Commit`. On failure it returns the
negative code and calls `artifact.Abandon(engine)` through the ordinary caller
path.

- [x] **Step 6: Run Production GREEN and its full parent prefix**

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.InterfaceDispatch" `
  -Label cta-interface-production-green -TimeoutMs 600000
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" `
  -Label cta-interface-production-regression -TimeoutMs 600000
```

Expected: all discovered methods pass, zero failures/skips, and existing class
virtual dispatch remains green.

- [x] **Step 7: Commit detached Runtime publication**

```powershell
git -C Plugins/Angelscript add -- `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.h `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp `
  Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionInterfaceDispatchTests.cpp
git -C Plugins/Angelscript commit -m "[CanonicalAST] Refactor: publish exact interface dispatch candidates"
```

---

### Task 4: Authenticate the prepared Stage 1/2 interface shell path

**Files:**

- Modify: `.../source/as_bytecode_codegen.cpp`
- Modify:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`

**Interfaces:**

- Consumes: Task 3's exact projection helper and Stage 2 Runtime shells.
- Produces: `GeneratePreparedModule` acceptance of interface declarations only
  when their shells exactly match the sealed relation plan.

- [x] **Step 1: Add a prepared-module RED**

Extend the existing prepared-module harness with
`PreparedInterfaceShellsAreAuthenticatedBySealedRelations`. The fixture has one
base interface, one derived interface, one implementing class and one
interface-typed call. It must show that the interface method has
`asFUNC_INTERFACE`/null `scriptData`, binds to the exact stable declaration,
and produces the same closure/offset/chunk sequence as the sealed plan.

- [x] **Step 2: Run the exact prepared/primary RED prefix**

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" `
  -Label cta-interface-prepared-red -TimeoutMs 600000
```

Expected: `GeneratePreparedModule` rejects the interface shell because it
currently requires `scriptData`, or accepts Builder tables without exact
Canonical relation validation.

- [x] **Step 3: Accept declaration-only interface shells and validate exact projection**

In the prepared function inventory:

- allow null `scriptData` only when `funcType == asFUNC_INTERFACE`, the sealed
  declaration is Method, and its owner is Interface;
- skip `FillFunctionSourceMetadata` and body emission for that declaration;
- require producer stable declaration binding exactly once;
- compute the dispatch plan from sealed relation IDs and candidate bindings;
- validate or replace candidate-only Builder tables before module promotion;
- fail before active-generation promotion on any mismatch.

The prepared path may reuse Builder-owned Runtime shell allocation, but it must
not read a native syntax node, call `DoesMethodExist`, or choose an
implementation by name/signature.

- [x] **Step 4: Run prepared/primary GREEN**

Repeat Step 2 with `green` labels. Expected: all existing cases plus the new
interface case pass with zero legacy compiler invocations.

- [x] **Step 5: Commit prepared-path authentication**

```powershell
git -C Plugins/Angelscript add -- `
  Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp `
  Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp
git -C Plugins/Angelscript commit -m "[CanonicalAST] Refactor: authenticate prepared interface dispatch"
```

---

### Task 5: Regression, evidence and dual-repository publication

**Files:**

- Add:
  `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/canonical-interface-publication-gate-2026-08-29.md`
- Add:
  `openspec/changes/refactor-as-canonical-typed-ast-compiler/reviews/canonical-interface-publication-implementation-review-2026-08-29.md`
- Modify: `openspec/changes/refactor-as-canonical-typed-ast-compiler/tasks.md`
- Modify parent gitlink: `Plugins/Angelscript`

**Interfaces:**

- Consumes: all prior task commits and test reports.
- Produces: fresh evidence, issue ledger, review, plugin commit chain and parent
  gitlink/OpenSpec commit.

- [x] **Step 1: Run the focused semantic/backend/transport matrix**

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.InterfaceDispatch" `
  -Label cta-interface-final-sema -TimeoutMs 600000
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.InterfaceDispatch" `
  -Label cta-interface-final-production -TimeoutMs 600000
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" `
  -Label cta-interface-final-frontend -TimeoutMs 600000
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Cache.ASTBodySidecar" `
  -Label cta-interface-final-sidecar-v8 -TimeoutMs 600000
```

Require zero failures/skips/timeouts and record exact discovered/pass counts and
report directories.

- [x] **Step 2: Run regression and build gates**

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" `
  -Label cta-interface-final-canonical-compiler -TimeoutMs 900000
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.PrimaryCanonicalASTGenerate" `
  -Label cta-interface-final-primary -TimeoutMs 600000
Tools\RunBuild.ps1 `
  -Label cta-interface-final-build -TimeoutMs 1800000
```

Do not run Standalone. Any unexpected failure triggers
`superpowers:systematic-debugging` and gets recorded before a fix.

- [x] **Step 3: Run source/invariant and OpenSpec checks**

```powershell
rg -n "IsSignatureExceptNameAndReturnTypeEqual|DoesMethodExist" `
  Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
rg -n "asFUNC_INTERFACE|methodRelations|interfaceVFTOffsets" `
  Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source
openspec validate refactor-as-canonical-typed-ast-compiler --strict
git diff --check
git -C Plugins/Angelscript diff --check
```

The first scan may find a Runtime stale-assertion helper, but it must find no
CodeGen target-selection loop. Record the reviewed line and why it is not Sema.

- [x] **Step 4: Write evidence, review and task progress**

The gate attachment records:

- every RED and why it was the expected missing behavior;
- every GREEN command/count/report path;
- Sidecar V7 loss and V8 repair;
- semantic edge and Runtime projection invariants;
- prepared/detached transaction behavior;
- any remaining gaps and their exact owning tasks;
- confirmation that default LEGACY, native AST retention, HIR absence, Public
  AST V1 and Standalone scope did not change.

The review reopens any claim not supported by the actual broadest relevant
gate. Task updates are progress paragraphs, not umbrella completion claims.

- [x] **Step 5: Commit plugin final evidence state, then parent gitlink/docs**

If Task 5 found a required plugin correction, commit it first with a focused
message and re-run the affected gate. Then:

```powershell
git -C Plugins/Angelscript status --short
git add -- `
  Plugins/Angelscript `
  openspec/changes/refactor-as-canonical-typed-ast-compiler/tasks.md `
  openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/canonical-interface-sidecar-v8-issue-2026-08-29.md `
  openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/canonical-interface-publication-gate-2026-08-29.md `
  openspec/changes/refactor-as-canonical-typed-ast-compiler/reviews/canonical-interface-publication-implementation-review-2026-08-29.md
git commit -m "[CanonicalAST] Docs: record atomic interface publication gate"
```

Do not stage `.claude/skills/openspec-design.md` or `list/`.

## Plan self-review

- Spec coverage: semantic selection, verification, deterministic inspection,
  Sidecar fidelity, detached publication, prepared shell path, Runtime
  execution and rollback each have a task and focused gate.
- Scope containment: no default flip, native-AST deletion, HIR, Public AST V1,
  Standalone, full Cache V2 redesign or global TypeId redesign is included.
- Type consistency: the same `asSASTMethodRelation`, `methodRelations`,
  `AddMethodRelation`, and `PrepareCanonicalObjectDispatch` names are used by
  every dependent task.
- Publication consistency: semantic relations contain only snapshot-local IDs;
  Runtime slots/pointers remain candidate-owned.
- Execution mode: inline `superpowers:executing-plans` on the main thread;
  subagent assistance is limited to read-only audits that do not block or
  mutate the mainline.
