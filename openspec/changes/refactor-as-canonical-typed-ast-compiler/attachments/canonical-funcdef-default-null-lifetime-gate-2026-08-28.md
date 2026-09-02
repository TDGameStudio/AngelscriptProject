# Canonical funcdef default-null lifetime gate (CTA-S46, 2026-08-28)

## Result

CTA-S46 closes one previously implicit lifetime fact for the opt-in CANONICAL
compiler: a valid local funcdef declaration without an explicit initializer is
an initialized owning null handle, not an uninitialized slot. Sema now seals a
direct `NullLiteral` in the local `Decl.inits`, emits the corresponding local
assignment, and lets the existing lexical lifetime classifier produce normal
and transfer `scope-release` plans. The verifier rejects a forged release plan
whose target declaration has no initializer. Canonical Bytecode consumes the
already-sealed contract through its existing null-store and `FREE` + `UNINIT`
routes.

This is deliberately a bounded closure. It does not add explicit `@` source
syntax, broaden funcdef comparison semantics, complete deferred/out or
container ownership, or switch the compiler default. The retained native
AngelScript AST remains available for syntax, recovery, LEGACY execution,
differential comparison and implementation reference. HIR remains physically
deleted, and no AST dump, HIR replay or serialized transport was introduced
between the sealed Canonical AST and Bytecode/AOT consumers.

Current reportable progress remains conservative:

- OpenSpec tasks: **87/125 = 69.6%**; no broad lifetime umbrella row closes;
- weighted implementation: **about 77%**;
- action-only Parser-to-Sema authority: **about 98%**;
- Canonical Bytecode/Runtime closure: **about 73%**;
- direct Canonical-AST AOT: **about 55%**;
- safe default-CANONICAL readiness: **about 50%**;
- compiler default: intentionally still **LEGACY**.

## Sealed contract

The complete contract for this slice is:

```text
valid host-registered funcdef with asOBJ_IMPLICIT_HANDLE
    -> source local declaration has no explicit initializer
    -> Parser invokes the typed local-declaration action
    -> Sema creates the exact local FuncDef VarDecl
    -> Sema creates a direct NullLiteral
    -> VarDecl.inits contains that NullLiteral
    -> local assignment makes the initialized-null state executable
    -> lexical classifier sees initialized, owning FuncDef
    -> normal block exit and each block-leaving transfer get scope-release
    -> verifier proves the release target has a sealed initializer
    -> Canonical Bytecode clears the pointer slot
    -> scope-release emits FREE followed by ObjInfo(UNINIT)
```

The important distinction is:

```text
null value != uninitialized lifetime state
```

The VM frame happens to be cleared during allocation, but that implementation
detail is not a portable semantic fact for Canonical AST, detached Bytecode,
TypedASTJIT or future direct AOT visitors. The direct `NullLiteral` is the
backend-independent initialization proof. A release of null is then a valid,
idempotent ownership operation, while a release plan targeting a declaration
with no sealed initializer is malformed and now fails verification.

## Implementation

### Sema default-null publication

`AppendImplicitLocalInitialization` in `as_sema_stmt.cpp:164` now distinguishes
a non-reference Canonical `FuncDef` from ordinary default-constructed values.
For that form it:

1. creates `ActOnNullLiteral(range)`;
2. creates the exact local `DeclRef`;
3. appends the null expression to `Decl.inits`;
4. emits the typed assignment statement into the function body.

The local-declaration action calls this helper at `as_sema_stmt.cpp:286` when
the Parser reports a default-initialized local. The existing lifetime route at
`as_sema_stmt.cpp:1758` and cleanup creation at `as_sema_stmt.cpp:1806` then
classify the now-initialized owning funcdef and seal `scope-release` plans.
No native-node expression/statement replay is used to reconstruct the value.

### Verifier live-state invariant

The `scope-release` verifier in `as_ast_verifier.cpp:1623` now requires the
target `VarDecl` to contain at least one initializer. A forged release for an
uninitialized owning handle fails with:

- result: `asAST_VERIFY_INVALID_CHILD`;
- detail: `scope-release-cleanup-uninitialized`;
- edge: `asAST_EDGE_DECL_INIT`;
- related node: the target declaration.

This check extends the earlier target-kind, ownership-kind, qualifier and
destructor-free constraints. It prevents a backend from interpreting a
release plan as permission to free an arbitrary uncleared stack slot.

### Existing Canonical Bytecode consumption

No new Bytecode opcode path was required. The sealed null assignment already
uses the existing pointer-clear lowering, while the established owning-release
route remains:

- `as_bytecode_codegen.cpp:3382` — Runtime owning-reference predicate;
- `as_bytecode_codegen.cpp:3406` — shared `FREE` + `UNINIT` emitter;
- `as_bytecode_codegen.cpp:7212` — exact `scope-release` target consumption;
- `as_bytecode_codegen.cpp:7259` — lexical cleanup dispatch.

The change is intentionally AST-first: the runtime behavior was already safe,
but the AST had not sealed why the local was live and releasable. CTA-S46 makes
that fact explicit so every backend consumes the same lifetime model.

### Test anchors

- Sema contract: `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:5348`,
  `DefaultNullFuncdefLocalSealsNullInitAndReleasePlans`;
- verifier rejection:
  `AngelscriptNativeCanonicalASTVerifierTests.cpp:558`,
  `RejectsScopeReleaseCleanupForUninitializedOwningHandle`;
- LEGACY/CANONICAL execution and publisher proof:
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp:5544`,
  `CanonicalDefaultNullFuncdefMatchesLegacyAndExecutesSealedRelease`.

The fixtures register the funcdef with the host and set
`asOBJ_IMPLICIT_HANDLE`, matching the maintained fork's valid by-value funcdef
surface. The production test proves that LEGACY and CANONICAL both build and
execute the same bounded function, CANONICAL returns `42`, the sealed AST owns
the direct null initializer and release plans, bytecode contains `FREE`, the
publisher is Canonical CodeGen, and the LEGACY compiler invocation count on
the CANONICAL engine is zero.

## TDD evidence

### Invalid discovery attempts retained as issue evidence

The first source fixture used explicit handle spelling (`Type@ Local`). This
maintained fork rejects that syntax, so its failures were Parser/language-
surface evidence rather than a clean CANONICAL lifetime RED:

- build PASS:
  `Saved/Build/cta-s46-default-null-red-build/20260828_094802_948_53a21353/RunMetadata.json`;
- production fixture fails during LEGACY source compilation:
  `Saved/Tests/cta-s46-default-null-production-red/20260828_094913_373_10c12141/RunMetadata.json`;
- Sema fixture fails with the disabled-`@` parse/unresolved surface:
  `Saved/Tests/cta-s46-default-null-sema-red/20260828_095045_917_b8d6b740/RunMetadata.json`.

The replacement fixture used a host-registered funcdef, but its first version
did not set `asOBJ_IMPLICIT_HANDLE`. The Sema/verifier probes still exposed the
missing Canonical contract, but LEGACY correctly rejected the by-value local,
so that production run is not the clean parity RED:

- build PASS:
  `Saved/Build/cta-s46-funcdef-default-null-red-build/20260828_095331_461_69264f66/RunMetadata.json`;
- Sema missing init/release:
  `Saved/Tests/cta-s46-funcdef-default-null-sema-red/20260828_095354_767_d757cb2e/RunMetadata.json`;
- verifier missing the rejection:
  `Saved/Tests/cta-s46-funcdef-default-null-verifier-red/20260828_100012_947_f9f42882/RunMetadata.json`;
- production LEGACY build rejection:
  `Saved/Tests/cta-s46-funcdef-default-null-production-red/20260828_100049_886_5f8efa69/RunMetadata.json`.

Removing an unsupported funcdef/null comparison did not make the unflagged
type valid. These are also retained but excluded from the clean RED:

- build PASS:
  `Saved/Build/cta-s46-funcdef-default-null-red-fixture-build/20260828_100523_847_c8819fc4/RunMetadata.json`;
- LEGACY still rejects the missing implicit-handle registration:
  `Saved/Tests/cta-s46-funcdef-default-null-production-clean-red/20260828_100631_330_c792cb8b/RunMetadata.json`.

### Clean expected RED

After setting `asOBJ_IMPLICIT_HANDLE`, both frontends accepted the source and
the tests isolated only the missing sealed lifetime contract:

| Gate | Expected result | Evidence |
| --- | ---: | --- |
| RED test build | **PASS** | `Saved/Build/cta-s46-funcdef-default-null-clean-red-build/20260828_100943_634_15e33e0b/RunMetadata.json` |
| Sema default-null contract | **0/1 RED** — no direct null init or three release plans | `Saved/Tests/cta-s46-funcdef-default-null-sema-clean-red/20260828_101041_038_ff93c44e/RunMetadata.json` |
| production LEGACY/CANONICAL parity | **0/1 RED** — LEGACY succeeds; Canonical direct-null AST assertion fails | `Saved/Tests/cta-s46-funcdef-default-null-production-clean-red-v2/20260828_101115_418_ed0d9fab/RunMetadata.json` |
| verifier forged uninitialized release | **RED** — missing stable rejection | `Saved/Tests/cta-s46-funcdef-default-null-verifier-red/20260828_100012_947_f9f42882/RunMetadata.json` |

### GREEN

The implementation build and all focused/class/secondary gates are green:

| Gate | Result | Evidence |
| --- | ---: | --- |
| implementation build | **PASS** | `Saved/Build/cta-s46-funcdef-default-null-green-build/20260828_101444_072_f0a8cb76/RunMetadata.json` |
| new verifier rejection | **1/1 PASS** | `Saved/Tests/cta-s46-funcdef-default-null-verifier-green/20260828_101655_386_684fc2d8/RunMetadata.json` |
| new Sema contract | **1/1 PASS** | `Saved/Tests/cta-s46-funcdef-default-null-sema-green/20260828_101728_737_76908f19/RunMetadata.json` |
| new production execution/parity | **1/1 PASS** | `Saved/Tests/cta-s46-funcdef-default-null-production-green/20260828_101823_703_dfc98fa4/RunMetadata.json` |
| complete verifier class | **30/30 PASS** | `Saved/Tests/cta-s46-funcdef-default-null-verifier-class-green/20260828_101905_122_384ebde6/RunMetadata.json` |
| complete SemaAuthority class | **389/389 PASS** | `Saved/Tests/cta-s46-funcdef-default-null-sema-class-green/20260828_101938_481_69b9ad0c/RunMetadata.json` |
| complete ProductionCodeGen class | **112/112 PASS** | `Saved/Tests/cta-s46-funcdef-default-null-production-class-green/20260828_102019_261_91b5a2cd/RunMetadata.json` |
| ProductionCodeGen + Canonical Semantics + retained native ScriptNode | **161/161 PASS** | `Saved/Tests/cta-s46-funcdef-default-null-secondary-gates/20260828_102111_301_cea9d64a/RunMetadata.json` |

The non-empty secondary gate is also evidence that the retained native
`asCScriptNode` surface remains enabled after this Canonical lifetime change.

## Issues and decisions

### CTA-S46-I1 — explicit `@` handle syntax is disabled in this fork

**Observed, recorded, and excluded from the migration target.** The initial
fixture was invalid on both paths. CTA-S46 does not expand the language or use
a CANONICAL-only spelling. The valid test surface is the maintained fork's
implicit-handle funcdef registration.

### CTA-S46-I2 — by-value funcdef locals require implicit-handle registration

**Resolved in the fixture and recorded as a host/type contract.** Registering
the funcdef declaration alone does not make `FCallback Local;` valid. Its
`asCTypeInfo` must carry `asOBJ_IMPLICIT_HANDLE`, after which both LEGACY and
CANONICAL accept the same source. The flag is a current-generation Runtime
projection; durable AST identity remains the Canonical funcdef type identity,
not a numeric Engine TypeId.

### CTA-S46-I3 — funcdef/null comparison is not a valid parity oracle here

**Observed and excluded.** The maintained LEGACY language surface did not
accept the attempted `Callback != nullptr` expression. The parity fixture was
narrowed to build/execute plus direct AST and bytecode proofs. No new comparison
operator semantics were added as a side effect of this lifetime gate.

### CTA-S46-I4 — zeroed VM storage is not a sealed AST initialization fact

**Resolved AST-first.** Frame allocation already clears pointer slots, so a
VM-only execution test could appear safe even while `Decl.inits` was empty and
no lexical release existed. The direct `NullLiteral` now publishes initialized
live state independently of backend allocation behavior. This is necessary for
detached Bytecode and direct AST AOT correctness.

### CTA-S46-I5 — verifier allowed release without initialization proof

**Resolved for sealed `scope-release`.** The verifier now rejects a release
whose target declaration has no initializer using the stable
`scope-release-cleanup-uninitialized` detail. This makes malformed or manually
constructed AST fail closed before CodeGen.

### CTA-S46-I6 — lifetime and backend breadth remain incomplete

**Open cutover blocker.** CTA-S46 covers default-null initialization of valid
implicit-handle funcdef locals and their existing lexical release route only.
Explicit/reference parameter ownership, deferred/out values,
template/container and delegate/lambda capture ownership, global
initialization/shutdown, exception edges, suspend/resume frames, complete
detached Bytecode metadata, and direct TypedASTJIT/AOT cleanup consumption
remain outside this slice. Unsupported families must stay fail-closed and must
not reintroduce native-tree semantic replay, HIR, or dump transport.

## Completion boundary

CTA-S46 is complete and green, but the OpenSpec change is not complete. Tasks
5.7/5.8 and the broad backend/AOT/publication/default-cutover tasks remain
unchecked. The next safe sequence is to seal deferred/out and aggregate
ownership state, then globals, exceptional and suspended control-flow cleanup,
and finally prove those contracts in detached Bytecode and direct
Canonical-AST AOT before considering a default switch.
