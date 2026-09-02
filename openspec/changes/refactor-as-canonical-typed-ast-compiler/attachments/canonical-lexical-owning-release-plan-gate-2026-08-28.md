# Canonical lexical owning-reference release-plan gate (CTA-S45, 2026-08-28)

## Result

CTA-S45 closes the direct initialized lexical `ReferenceObject` / `FuncDef`
release slice for the opt-in CANONICAL compiler. Sema now seals explicit
`scope-release` cleanup statements for normal block exit and for each
return/break/continue/fallthrough that exits the owning block. Canonical
Bytecode consumes the sealed plan as `asBC_FREE` plus `asOBJ_UNINIT`, and the
normal-path plan retires the compile-time object directory entry so the common
function epilogue cannot release it a second time.

This milestone does not remove AngelScript's native AST. `asCScriptNode`,
Parser, Builder, `asCCompiler` and the explicit LEGACY pipeline remain the
syntax/recovery/reference/differential/rollback implementation. The old HIR
remains physically retired. No dump or HIR replay was added between the
sealed Canonical AST and Bytecode.

Current reportable progress after this gate is:

- OpenSpec tasks: **87/125 = 69.6%**; no broad lifetime umbrella row closes;
- weighted implementation: **about 77%**;
- action-only Sema authority: **about 98%**;
- Canonical Bytecode/Runtime closure: **about 73%**;
- direct Canonical-AST AOT: **about 55%**;
- safe default-CANONICAL readiness: **about 50%**;
- compiler default: still intentionally **LEGACY**.

## Sealed contract

The lifetime pipeline for this slice is:

```text
Parser local declaration action
    -> Canonical VarDecl with exact QualType and initializer identity
    -> block Sema classifies lexical cleanup route
       - ValueObject + exact destructor -> scope-exit
       - ReferenceObject/FuncDef + not REFERENCE -> scope-release
       - non-owning REFERENCE/uninitialized/other -> no plan
    -> reverse ordered normal and transfer cleanup StmtIds
    -> AST verifier proves target/type/decl invariants
    -> Canonical Bytecode finds the exact tracked local slot
    -> asBC_FREE(slot, runtime behaviour/type authority)
    -> ObjInfo(slot, asOBJ_UNINIT)
    -> normal-path compile-time retirement only
```

The two cleanup literals intentionally have different binding contracts:

| Literal | Target | `resolvedDecl` | Backend action |
| --- | --- | --- | --- |
| `scope-exit` | exact local value-object `DeclRef` | exact destructor | destructor call + `UNINIT` |
| `scope-release` | exact owning reference/funcdef local `DeclRef` | must be invalid | `FREE` + `UNINIT` |

A release is a Runtime ownership operation, not a source-level destructor
call. Encoding a destructor declaration on `scope-release` would conflate the
reference-count protocol with value-object destruction and is rejected by the
verifier.

## Implementation

### Sema route

`as_sema_stmt.cpp` now uses an explicit `asELexicalCleanupRoute` instead of a
value-object-only boolean. `GetLexicalCleanupRoute` requires an initialized
local variable and rejects a true `REFERENCE` qualifier. It selects:

- `asLEXICAL_CLEANUP_VALUE_DESTRUCTOR` for a direct value object with an exact
  Canonical destructor;
- `asLEXICAL_CLEANUP_OWNED_REFERENCE_RELEASE` for a direct
  `asAST_TYPE_REFERENCE_OBJECT` or `asAST_TYPE_FUNCDEF`;
- no route for borrowed references, primitive/enum/void forms, unsupported
  template/container forms, or locals without an initializer.

`CreateLexicalCleanup` keeps the existing exact destructor plan for value
objects and creates a destructor-free `scope-release` expression for owning
reference forms. The existing reverse-order block walk is shared by both
routes, so mixed lexical objects preserve one declaration-order lifetime
stack. Transfer plans are copied to each exiting transfer; the normal block
plan remains a distinct AST identity.

Relevant implementation anchors:

- `as_sema_stmt.cpp:1734` — route enum;
- `as_sema_stmt.cpp:1741` — ownership classification;
- `as_sema_stmt.cpp:1789` — cleanup creation;
- `as_sema_stmt.cpp:1880` — transfer-plan append;
- `as_sema_stmt.cpp:1979` — block-local collection;
- `as_sema_stmt.cpp:1994` — reverse normal-exit plan.

### Verifier route

The AST verifier now rejects a forged `scope-release` plan unless all of the
following are true:

1. `resolvedDecl` is invalid;
2. there is exactly one child and it is a `DeclRef`;
3. the child resolves to a local variable declaration;
4. the target is not a non-owning `REFERENCE` qualifier;
5. the target Canonical type kind is `ReferenceObject` or `FuncDef`.

The stable failure details are:

- `scope-release-cleanup-decl`;
- `scope-release-cleanup-target`;
- `scope-release-cleanup-type`.

This validation is intentionally based on the sealed Canonical type kind and
qualifier contract, not on an Engine numeric TypeId.

### Canonical Bytecode route

`as_bytecode_codegen.cpp` now has one shared Runtime ownership predicate and
one shared release emitter:

- `IsOwnedReferenceObject` accepts an explicit object handle, a funcdef, or an
  implicit-handle Runtime object whose flags are `asOBJ_REF` without
  `asOBJ_VALUE`;
- `EmitOwnedReferenceRelease` emits `asBC_FREE` and immediately records
  `asOBJ_UNINIT`;
- the normal function epilogue uses the same helper, preventing a separate
  implicit-handle cleanup implementation from drifting;
- `EmitScopeReleaseCleanup` validates the target declaration and exact tracked
  slot, resolves the current Runtime data type through the generation-local
  type bridge, and requires the same Runtime type authority as the tracked
  object;
- `EmitLexicalCleanup` dispatches the two sealed literals;
- transfer-plan copies emit cleanup but do not globally mutate compile-time
  liveness, while the normal-path statement retires the object after emitting
  its release. This preserves both CFG paths and prevents common-epilogue
  double release.

Funcdefs use the Engine's function-behaviour table as the `FREE` behaviour
operand. Reference objects use their resolved current type info. These are
late Runtime projections; neither is stored as durable AST identity.

Relevant implementation anchors:

- `as_bytecode_codegen.cpp:3382` — Runtime reference-object predicate;
- `as_bytecode_codegen.cpp:3406` — shared `FREE`/`UNINIT` emission;
- `as_bytecode_codegen.cpp:7212` — sealed `scope-release` consumption;
- `as_bytecode_codegen.cpp:7259` — lexical cleanup dispatch;
- `as_bytecode_codegen.cpp:7311` — normal-path object retirement.

## TDD evidence

### Expected RED

The first Sema run exposed an invalid test assumption rather than the missing
contract: an implicit-handle local was expected to carry a handle qualifier.
That run is retained as issue evidence but is not counted as the clean
missing-contract RED:

- `Saved/Tests/cta-s45-scope-release-sema-red/20260828_083225_837_76f3e4e8/RunMetadata.json`.

After correcting the fixture to assert `ReferenceObject && !IsReference()`,
the expected contract failures were:

- Sema missing all `scope-release` plans, **0/1**:
  `Saved/Tests/cta-s45-scope-release-sema-red-2/20260828_083425_738_c1a96274/RunMetadata.json`;
- verifier class **27/29**, with only the two new forged-plan tests failing:
  `Saved/Tests/cta-s45-scope-release-verifier-red/20260828_083701_054_06b661c2/RunMetadata.json`;
- production execution test missing the expected three release plans, **0/1**:
  `Saved/Tests/cta-s45-scope-release-production-red/20260828_083937_403_e4469b6b/RunMetadata.json`.

Both RED test builds succeeded:

- `Saved/Build/cta-s45-scope-release-red-build/20260828_083202_550_2b1f9cb3/RunMetadata.json`;
- `Saved/Build/cta-s45-scope-release-red-build-2/20260828_083319_253_29ffc618/RunMetadata.json`.

### GREEN

The production implementation build is green:

- `Saved/Build/cta-s45-scope-release-green-build/20260828_084725_209_f160d14c/RunMetadata.json`.

Focused and expanded gates are all green:

| Gate | Result | Evidence |
| --- | ---: | --- |
| new Sema reverse release-plan test | **1/1 PASS** | `Saved/Tests/cta-s45-scope-release-sema-green/20260828_084750_247_bc7d1a40/RunMetadata.json` |
| native execution, early + normal return | **1/1 PASS** | `Saved/Tests/cta-s45-scope-release-production-green/20260828_084826_242_ca9c121b/RunMetadata.json` |
| Canonical AST verifier class | **29/29 PASS** | `Saved/Tests/cta-s45-scope-release-verifier-green/20260828_084900_049_3a43464b/RunMetadata.json` |
| complete SemaAuthority class | **388/388 PASS** | `Saved/Tests/cta-s45-sema-authority-full/20260828_085300_967_b14bd9e3/RunMetadata.json` |
| complete ProductionCodeGen class | **111/111 PASS** | `Saved/Tests/cta-s45-production-codegen-full/20260828_085503_741_480a1248/RunMetadata.json` |
| Production + Semantics + retained native ScriptNode | **160/160 PASS** | `Saved/Tests/cta-s45-secondary-gates/20260828_085819_369_68b43581/RunMetadata.json` |

The execution fixture proves, for both early and normal return:

- result value is `42`;
- exactly one native reference object is created and destroyed;
- release calls equal transient AddRef calls plus the factory-owned reference;
- no live object remains;
- publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`;
- LEGACY compiler invocation count is zero.

The joint downstream gate includes the retained native ScriptNode tests. Its
green result is direct evidence that this lifetime closure did not delete or
disable the native AngelScript AST boundary.

## Issues and decisions

### CTA-S45-I1 — implicit handles do not necessarily carry `HANDLE`

**Resolved in the ownership classifier and recorded as a type-model rule.**
The observed Canonical local declaration for an implicit-handle ref object is
`ReferenceObject` with qualifier mask zero. The factory return may carry
`AUTO_HANDLE`, but that qualifier is not the durable ownership fact of the
destination local. `IsHandle()` therefore cannot classify every owning local.

The stable rule is:

```text
owning lexical release =
    initialized local
    && !QualType.IsReference()
    && TypeKind in { ReferenceObject, FuncDef }
```

Runtime lowering then verifies the resolved data type is an object handle,
funcdef, or `REF && !VALUE` object. This split is compatible with the dynamic
TypeId architecture: Canonical semantic identity chooses the route; the
current generation binding supplies the Runtime operand.

### CTA-S45-I2 — release plans must not reuse destructor binding

**Resolved.** `ActOnCleanup` normally searches for a destructor, which is
correct for value-object cleanup but wrong for reference release. Sema creates
`scope-release` directly and leaves `resolvedDecl` invalid. The verifier has a
specific rejection for any forged destructor binding.

### CTA-S45-I3 — compile-time liveness is not branch-local state

**Resolved for sealed lexical normal/transfer plans.** A transfer-plan copy is
emitted into a branch but cannot mark the tracked object globally dead during
linear code generation, because another CFG route still reaches the normal
cleanup. Only the normal-path cleanup retires the directory entry. The common
epilogue therefore emits no duplicate cleanup, while every early transfer has
its own sealed copy.

### CTA-S45-I4 — implicit-handle epilogue and explicit scope release could drift

**Resolved.** The old epilogue release predicate named only object handles and
funcdefs. The shared helper now also recognizes the fork's implicit-handle
`asOBJ_REF && !asOBJ_VALUE` representation. Explicit AST cleanup and fallback
epilogue destruction use the same `FREE`/`UNINIT` sequence.

### CTA-S45-I5 — exact class-prefix totals differ from older aggregate totals

**Not a product failure.** Fresh exact class-prefix runs report
SemaAuthority **388** and ProductionCodeGen **111** tests. Earlier records
reported **394** and **115** under the then-observed discovery/build state.
This attachment cites each runner's own `RunMetadata.json` and does not add or
normalize totals across different selections. Final completion still requires
the named broad matrices rather than relying on either focused count.

## Remaining lifetime boundary

CTA-S45 is deliberately bounded. The following remain open:

- deferred/out/inout storage and partial initialization;
- template/container lifetime routes not represented by direct
  `ReferenceObject`/`FuncDef` kinds;
- globals, imports and mutable global lifecycle;
- exception/unwind and source-level exceptional cleanup policy;
- suspend/resume/coroutine frames;
- delegate/lambda capture ownership beyond the covered funcdef local;
- exceptional cleanup/debug/source/coverage/safe-point metadata parity;
- full TypedASTJIT/AOT cleanup emission from the same sealed plan;
- complete production-entry, StaticJIT, Standalone and configured `All`
  matrices;
- default-CANONICAL switch.

The next lifetime milestone should model initialized/live state explicitly for
deferred/out locals and exception/suspend edges. It must extend this sealed
plan vocabulary; it must not reintroduce HIR, a semantic dump, or native AST
replay as a backend input.
