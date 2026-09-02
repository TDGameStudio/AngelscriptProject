# Problem 梳理 and next async work (2026-08-22, after construct-init)

> **Superseded status note — 2026-09-01:** this file is a historical execution
> package. Tasks 4.2, 5.3 and 5.4 were closed by later dedicated gates; the
> current authoritative status is `tasks.md` plus
> `reviews/current-overall-progress-2026-09-01-2005.md`. In particular, CTA-S177
> closes 5.4 and records the scalar-reference `+=` alias RED/GREEN in
> `canonical-sequencing-single-evaluation-closure-gate-2026-09-01.md`. Retain
> the old “do not check” instructions below only as evidence of what was not yet
> proven on 2026-08-22.

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
Do not archive. Do not commit unless the user asks. Dual-repo: plugin submodule first.
Do **not** rewrite remaining `tasks.md` boxes down to match incomplete code.
Do **not** check 13.2 / 13.1 / 13.6 / 4.2 / 5.4 / 5.5 / 5.6 / 5.7 / 5.8 / 5.9 / 9.1 / 9.5 / 10.2 / 10.4 from prefix greens. Task 13.3 is now separately closed by producer-carried stable identity plus exact Runtime/StaticJIT/Cache binding; see `canonical-function-decl-identity-gate-2026-08-23.md`.

Companions:

- `async-dispatch.md` — live package table (this dispatch)
- `wave-b-packed-exec-next.md` — **exclusive UBT now**: packed int8 execute 1934 (`got=0` while opcode WRTV1 GREEN)
- `wave-b-132-remaining.md` — 13.2 honesty (refreshed this dispatch)
- `wave-b-codegen-remaining.md` — remaining Generate-local leftovers after construct-init
- `public-ast-v1-view-size-contract.md` — V1 view-buffer capacity hardening
  only; it explicitly does **not** close public ABI or snapshot-protocol work
- `public-ast-v1-trailing-vtable.md` — restores the original `asIScriptModule`
  ABI prefix; foreign-ID and atomic snapshot protocol blockers remain
- `public-ast-v1-atomic-publication-plan.md` — focused Acquire/publish lifetime
  sub-plan; it does not close the broader Wave E protocol tasks
- `public-ast-v1-atomic-publication.md` — implemented guarded acquire/publish
  repair, with deterministic architecture RED, 64-generation stress coverage,
  and explicit remaining raw-context/foreign-ID protocol gaps
- `hirdump-snapshot-lease-consumer.md` — matching-profile dump now consumes its
  held `asCASTSnapshot` lease
- `staticjit-generation-snapshot-lease.md` — StaticJIT immutable-generation
  snapshots now own V1 AST leases for every retained module AST; typed capture
  requires that lease, while retained Bytecode identity remains supported
- `compilefunction-retained-snapshot-invalidation.md` — successful legacy
  `CompileFunction(asCOMP_ADD_TO_MODULE)` now retires rather than lies about a
  retained snapshot that cannot include the added declaration
- `canonical-codegen-transaction-rollback-2026-08-23.md` — current CodeGen
  failure rollback now journals provisional class types and imported bind
  slots; it records both source-level RED cases and the bounded non-claims
- `public-ast-v1-opaque-id-ownership-2026-08-23.md` — public AST V1 IDs now
  reject foreign snapshot ownership rather than treating another snapshot's
  local array index as valid; this is a bounded ABI repair, not R05/R06 close
- `reviews/implementation-rereview-2026-08-22-eleventh-pass.md` — still **Request changes** (cutoff before switch/DeclContext/global-bind/construct-init)
- `reviews/implementation-rereview-2026-08-22-tenth-pass.md` — still **Request changes** for system blockers (atomic install / Cache / SourceManager / default)

Honest production-cutover readiness is ~**44%**. Mechanical checklist is still 虚标. Do not jump past this: LEGACY default is still `asCCompiler`, CANONICAL CodeGen remains a bounded subset, packed execute 1934/902 is now landed, and Wave E–G have not started.

### 2026-08-23 — bounded V1 consumer-lifetime repair

The StaticJIT generation snapshot no longer takes an unowned
`GetCanonicalASTContext()` pointer. It owns `asIASTSnapshot` V1 leases through
the immutable snapshot. This is a **lifetime repair**, not an AST/Sema or
default-pipeline milestone. During validation, the retained-Bytecode identity
fixtures caught the important compatibility condition that a Bytecode profile
may retain and use AST identity metadata even though only `VerifiedTypedHIR`
must reject a missing AST. Evidence and non-claims are in
`staticjit-generation-snapshot-lease.md`.

### 2026-08-23 — `CompileFunction` current-snapshot safety repair

`CompileFunction(asCOMP_ADD_TO_MODULE)` still uses the LEGACY compiler and
does **not** synthesize a canonical AST merge. The safe V1 contract is now
explicit: after a successful append the module retires its current retained
snapshot. Existing leases remain traversable, but a fresh module acquire
returns null until a full `Build()` publishes a complete replacement. This
prevents a public “current” AST that is missing executable module content;
it does not make `CompileFunction` canonical or complete Task 10.3. See
`compilefunction-retained-snapshot-invalidation.md`.

### 2026-08-23 — bounded Canonical CodeGen rollback repair

Canonical CodeGen now rolls back the two observed declarations that had to be
made visible before later function-body emission: provisional script-object
types and imported-function bind slots. The tests exercise a real later
`fallthrough` emitter rejection, compare module and engine tables, and retry
the same names in the same module. Function-to-class method/constructor/
destructor association is also deferred until Commit, so rollback never tears
down a provisional type through already-removed function IDs. This is a
compensating journal, not a detached-artifact completion; it does not close
CodeGen atomic installation or alter the LEGACY-default/cutover judgement. See
`canonical-codegen-transaction-rollback-2026-08-23.md`.

### 2026-08-23 — public V1 foreign-ID ownership repair

The initial public AST V1 IDs were raw context-local indexes, so snapshot B
accepted snapshot A's translation-unit ID when both happened to use index 1.
The public snapshot boundary now tags every returned Decl/Stmt/Expr/Type ID
with a non-zero owner token and rejects a raw or foreign owner before reading
the context or overwriting the caller's view. The internal AST remains raw,
which keeps this boundary out of Parser/Sema/CodeGen. TDD evidence is a real
two-snapshot API RED (**6/7**, B returned success) then GREEN (**7/7**), plus
Standalone **21/21**. V1 ID/view struct sizes changed in the worktree and the
existing `structSize` protocol fails older smaller views closed; final release
ABI policy remains R05. See
`public-ast-v1-opaque-id-ownership-2026-08-23.md`.

---

## 1. What this change actually is

Specs / `design.md` still require a **complete production cutover**:

```text
SourceManager → Parser dedicated Sema actions → sealed interned typed AST
  → asCBytecodeCodeGen / TypedASTJIT / Cache DTO / public snapshot
```

LLVM/Clang is a **shape reference only**. This project does not link Clang/LLVM.

The tree today is a **migration platform + opt-in CANONICAL subset CodeGen**:

```text
legacy Parser → asCScriptNode (recovery tree)
  → incremental Parser ActOnParsed* / NotifySema
  → dedicated Sema API tests intern landed kinds with no script node
  → asCBuilder SealCanonicalAST
        LayoutScriptClassFields() before Seal()     LANDED
        fail-closed if Sema diagnostics non-empty
  → LEGACY Build() → asCCompiler                     (default pipeline)
  → CANONICAL Build() → asCBytecodeCodeGen::Generate()
        asCASTVerifyPublication() before registration LANDED
        9.5 named rows + F1–F5 + exact CALLSYS       LANDED (slice)
        InitPlan dump + execute 42                   LANDED
        native 0-arg intern; dummy CONSTRUCT deleted LANDED
        MemberRef Sema + execute 42                  LANDED
        sealed native + script field byteOffset      LANDED
        exact-byte RDR/WRTV helpers                  LANDED (opcode)
        packed int8 WRTV1 opcode                     LANDED
        packed int8 execute 1934                     LANDED (1934/902)
        EmitSwitch + no innermost-loop fallback      LANDED (21/7)
        LookupInScope sealed children                LANDED
        host global unique-signature intern+bind     LANDED (HostPick 42)
        HasConstructAssignTo VAR inits CONSTRUCT     LANDED
        PropertyFromFieldDecl sealed offset match    LANDED
        list-pattern sealed list-factory callee      LANDED
        LEGACY still asCCompiler
  → Runtime carries sealed stable Decl key
  → StaticJIT/Cache exact structural bind (identity 11/11; LEGACY still reruns Sema)
```

All-suite greens while the Engine default is `LEGACY` and publisher is `COMPILER` are **compatibility of the old path**. They are not cutover evidence.

---

## 2. Why implementation drifted (虚标)

Intended: baselines → scaffold beside `asCCompiler` → move lookup/overload/conversion/lifetime **out of** `asCCompiler` into Sema → backends consume only the sealed graph → flip the production default → delete the old path.

What happened: **scaffold-as-cutover**, then a real but **subset** production routing.

虚标 = **`[x]` against a task whose spec meaning is not met**.

Rule: **do not rewrite a remaining `[ ]` down.** Prefix counts are regression evidence, not authority. Do **not** silently uncheck already-checked 虚标 boxes (9.2 / 9.3 / 9.4 / 13.5) in this dispatch — record honesty; checkbox surgery waits for an explicit rereview pass.

| Green evidence | What it is | What it is not |
| --- | --- | --- |
| Dump with `callee=` / `typeKind=` / `target=` / `captures=` / `init=` / `safepoint=` / `receiver=` / `offset=` | Sema recorded a fact on a fixture | Sema environment (13.2). `DumpSealedCanonicalAst` **ignores `Build()` return** |
| SemaAuthority **250/250** `wave-b-construct-init-sema` | Parser/Sema fixtures including VAR `init=` Construct | 4.2–5.9 / 13.2 close |
| Identity **8/8** | Snapshot FunctionKey↔AST unique keys | 13.3 close (default still LEGACY `asCCompiler`) |
| ProductionCodeGen **53/53** `cta-codegen-publication-gate-production` | Named subset reaches `Generate()` only after sealed publication target validation | Full-language CodeGen (9.5) / default cutover |
| Dedicated `ActOn*` | That kind's intern is Clang-shaped | Remaining FromNode extract + backends not re-deciding |
| CanonicalAST **321/321** `wave-b-construct-init-canonicalast` | Graph + opt-in Generate at construct-init cutoff | 13.2 |
| Compiler **518/518** `cta-codegen-publication-gate-compiler` (ReportJson) | Compiler prefix after canonical CodeGen publication gate | Wave E–G / default CANONICAL |
| 9.3 `[x]` “switch/case/default/break/continue” | `EmitSwitch` + execute 21/7 exist as a **slice** | Full structured-control sentence. **Still 虚标** until rereview |
| 9.2 `[x]` exact-width | Helpers `{1,2,4,8}` + packed opcode WRTV1 | Packed **execute 1934 open**. **Still 虚标** |

---

## 3. Honest current state

### Closed honestly (do not redo)

| Item | Evidence | Still not |
| --- | --- | --- |
| Wave A honesty | LEGACY default, publisher observable | 13.1 — CompileFunction provenance; Ready() still unconditionally true |
| R11 CodeGen teardown | extra-ref drop + Transaction 7/7 | 9.5 language coverage |
| Wave C R07/R08/2.6 | **2.4 / 2.8 / 2.6 / 13.4 / 13.5 `[x]`** (13.5 虚标) | CALL-without-callee is a **hard no** for unsealed `asCASTVerify` |
| Dedicated intern through F5 + 1070 | SemaAuthority **250/250** | **13.2 / 5.9 / 4.2** |
| **B-54-opaque** + Isolated traces | Isolated **4/4**. Semantics **12/12** | 5.4 |
| **B-55 + sealed publication target gate** | Verifier **20/20**; canonical CodeGen transaction **8/8** consumes it before mutation | 5.5 / 5.6 / 13.5 remain incomplete |
| **F2 Phase A+B** | Exact METHOD/ctor/factory/opIndex CALLSYS | 9.4 虚标; 13.2 |
| **InitPlan dump + execute** | `init=` interned `40+1`. Execute **42**. atoi helper deleted | 5.7 / 5.8 / 13.2 |
| **Native 0-arg intern** | Default factory/ctor only. Factory STOREOBJ | 13.2 |
| **Dummy VALUE invent CONSTRUCT** | Fail-close `asNO_FUNCTION` if no VAR inits CONSTRUCT | 13.2 |
| **MemberRef Sema + execute 42** | Sealed field `resolvedDecl` + `UnwrapAssignLhs` | 13.2 |
| **Sealed native `byteOffset`** | `InternNativeProperties` writes engine `prop->byteOffset` | 13.2 |
| **Script field `byteOffset` on seal** | `LayoutScriptClassFields()` before `Seal()`. Dumps `Stored offset=4` | Generate-local `fieldOffsets[]` **fallback** when `byteOffset < 0` still exists |
| **Exact-byte RDR/WRTV** | `MemoryBytes` + `EmitReadValue`/`EmitWriteValue` 1/2/4/8; REF/`size<=0` pointer width | Packed **execute 1934 OPEN** (`got=0`). 9.2 虚标. 12-byte `asBC_COPY` not this |
| **Get miss fail-closed** | `GetFirstProperty` **gone** from CodeGen | 9.4 虚标 |
| **FindExistingExpr kind+begin+end** | End matched when request end nonzero | Not owner+role. `FindExistingStmt` still kind+begin |
| **ObjectTypeFromExpr Resolve-only** | Unwrap then `bridge->Resolve` only | Resolve is engine mapping (allowed) |
| **B-seal-facts compile-seal dumps** | Assign conversion, lambda `captures=` on retain, inner shadowed var, `opPostInc` on `Build()` | Construction-API tests remain Parser identity. 13.2 |
| **B-sealed-env** | `EmitSwitch` + `PushLoop(switch, end, continueLabel=-1)`. Break/continue miss **fail-closed** (no last-loop). Execute **21** and **7** | 9.3 still 虚标 (slice). 13.2 |
| **B-declcontext** | `LookupInScope` grovels sealed `scope->children`. Construction-API FUNCTION without `InsertSymbol` resolves | `symbols[]` still filled as intern-time cache. 13.2 |
| **B-global-bind** | Host globals intern+bind unique signature (name + param/return + in-out). `HostPick(41)` execute **42**, CALLSYS int not first same-arity bool | Did not store `asCScriptFunction*` on decls. 13.2 |
| **B-construct-init + publication consumer** | Construct-init facts remain; `Generate()` now consumes `asCASTVerifyPublication()` before registration. ProductionCodeGen **53/53**; Compiler **518/518** | Publication target presence is not full call planning or 13.2 |
| Wave D isolated Tasks 1–5 | Transaction **8/8** including pre-mutation missing-target rejection | Fully detached install (9.1 / 13.6) |

### Live counts (regression only)

| Prefix | Last green / live | Note |
| --- | --- | --- |
| `Compiler.CanonicalAST.SemaAuthority` | **250/250** `wave-b-construct-init-sema` | Includes VAR `init=` Construct. Not 4.2 / 13.2 |
| `Frontend.CanonicalAST.Verifier` | **20/20** `cta-publication-target-gate-verifier-green` | Includes sealed CALL / CONSTRUCT / DECL_REF target gate |
| `Frontend.CanonicalAST` | **86/86** `wave-b-zeroarg-frontend` | Not re-run after construct-init. Not 5.6 |
| `Compiler.CanonicalAST` | **321/321** `wave-b-construct-init-canonicalast` | Includes ProductionCodeGen packed **opcode** lock |
| `Compiler.CanonicalAST.ProductionCodeGen` | **53/53** `cta-codegen-publication-gate-production` | Includes `Generate()` sealed-publication gate |
| `Compiler` | **518/518** `cta-codegen-publication-gate-compiler` | ReportJson 518/518 |
| `Compiler.CanonicalAST.Cutover` | **5/5** | Mixed CompileFunction accepted |
| Identity | **11/11** `cta-canonical-function-identity-regression` | 13.3 closed; not full Sema/CodeGen cutover |
| Transaction | **8/8** `cta-codegen-publication-gate-transaction-green-v2` | Not 9.1 |
| Semantics | **12/12** | Not 5.4 |
| Isolated traces | **4/4** | Not 5.4. Isolated packed execute **not** added |

Must-stay-green oracles: Isolated 4/4, Semantics 12/12, InitPlan 42, MemberRef 42, HostPick 42, switch 21/7, `FValue Object` 42.

Compiler JSON may have `succeededWithWarnings`. Do not write pure `N/N PASS` if a warning exists.

### LocalDecl CodeGen trap (do not regress)

`asAST_STMT_DECL` only allocates a slot. Init assign must be a **sibling** `STMT_EXPR`. Flattened block locals must intern ASSIGN/DECL_REF at the **declaration** range, not the enclosing block range. For-init LocalDecl: prefer wrapping BLOCK over inner DECL (`stmt-multi-owner`).

`BindParameters` also `AllocTyped`s function `DECL_VAR` children, so `STMT_DECL` may skip (`FindSlot` already set).

Dummy VALUE invent CONSTRUCT is **deleted**. VALUE object without `HasConstructAssignTo` fail-closes `asNO_FUNCTION`. `HasConstructAssignTo` now reads **VAR `inits`**, not a stmt scan. Do **not** restore dummy CONSTRUCT. Do **not** restore 0-arg `FindConstructorId(0)` / `FindFactoryId(0)`. Do **not** restore `GetFirstProperty` in CodeGen. Do **not** restore ordinal sibling-VAR match in `PropertyFromFieldDecl`.

### Where 13.2 actually is

13.2 text: replace the `asCScriptNode` syntax walk with a **Sema environment** (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets). Sealed dumps/views must show those facts so **backends do not rerun Sema**.

What is true: dedicated intern through F5 + 1070; dumps of selected facts; CANONICAL `Build()` fail-closes on Sema diagnostics then Generate; native METHOD/ctor/factory/opIndex `resolvedDecl` binds CALLSYS; script+native field `byteOffset` interned before Seal; exact-byte memory helpers; FindExistingExpr kind+begin+end; ObjectTypeFromExpr Resolve-only; switch consume; DeclContext children lookup; unique-signature host globals; VAR inits CONSTRUCT; sealed-offset property match.

What is **not** 13.2:

- Dump locks are facts on fixtures. `DumpSealedCanonicalAst` calls `Build()` and dumps `pendingCanonicalAST` **even when Generate fail-closes**.
- Intern-time `asCSema::symbols` / `controlStack` / `FindBestCallee` still exist as caches / die with Sema.
- Generate-local leftovers: broad `CopyVar` / `LoadReturn` ABI coverage and
  lifecycle teardown. The accessor field identity, field-offset fallback,
  list-factory callee, and exact-width `StoreGlobal` re-lookups are closed.
- Packed int8 **opcode** WRTV1 GREEN; **execute 1934 OPEN** (`got=0`, report `wave-b-packed-exec-red-prod`).
- `FindExistingStmt` still kind+begin. ActOnParsedExpr `default` / QualType FromNode still recovery.
- LEGACY Bytecode still `asCCompiler` (default pipeline still reruns Sema).

**Do not check 13.2** after construct-init, HostPick 42, switch 21/7, or this dispatch's packed-execute work unless backends truly do not redo Sema (they will not: LEGACY still `asCCompiler`; Parser still `asCScriptNode`).

### Where 4.2 / 5.4 / 5.5 / 5.6 / 9.5 actually is

- **4.2:** Parser dedicated Sema actions exist for named kinds, initially shadowing Builder. Parser is not action-only. **Do not check 4.2.**
- **5.4:** OpaqueValue memo, Isolated traces, InitPlan, MemberRef landed. Full mutation/temporary/lifetime contract not closed. Packed execute 1934 open. **Do not check 5.4.**
- **5.5 / 5.6:** Four compile-seal dump/verifier oracles GREEN. HIR control tests not fully migrated. **Do not check.**
- **9.5:** Named production rows through capturing IIFE, selected-overload script CALL, F1–F5, array insertLast, accessors, import CALLBND, InitPlan 42, MemberRef 42, switch 21/7, HostPick 42. Packed execute open. **Do not check 9.5.** Checked **9.3 is still 虚标** (switch is a slice). **9.2 is still 虚标** (packed execute open).

### Eleventh-pass F1–F10 vs live

| Id | Eleventh-pass (cutoff 20:22) | Live now |
| --- | --- | --- |
| F1 typed InitPlan | Dump GREEN, execute **got=0** | **Dump + execute 42 GREEN**. VAR `inits` CONSTRUCT GREEN |
| F2 exact bind | 0-arg fallback listed | **0-arg intern GREEN**. Host global unique-signature GREEN |
| F3 ABI width | Open | Helpers + int64/double/handle RDR8 + packed **opcode** GREEN. Packed **execute 1934 OPEN** |
| F4 string inits | `strtoll` protocol | Unchanged |
| F5 FindExistingExpr | Open | kind+begin+end when nonzero. Not owner+role |
| F6 Verifier firewall | Open | Queued. Never CALL-without-callee on unsealed verify |
| F7–F10 | Wave E–G | **Forbidden now** |

---

## 4. The live problem — remaining Generate-local + packed execute

The latest Wave B order is still: **Sema-owned facts on the sealed AST so CodeGen does not redo Sema**. Dump-only ABI tweaks are **not** this.

Observable redo / leftover sites **now** (exclusive UBT takes packed execute):

| # | Site | Why it is still a hole | Test that would fail if ignored |
| --- | --- | --- | --- |
| 1 | Packed int8 execute 1934 | Opcode WRTV1 locked. `RunPacked` historically `got=0`. Asserts **reverted** so ProductionCodeGen stays 48/48. `got=0` is **all zeros**, not neighbor smash (`1900` would be B-smash) | Re-assert `RunPacked()==1934` and `RunPair16()==902`. RED already: `Saved/Tests/wave-b-packed-exec-red-prod/20260822_234717_191_3cdf7074` |
| 2 | Generated accessor identity | **closed** — sealed `accessorKind` / `accessorField`; no name-strip or sibling scan | Do not restore `GetFirstProperty` |
| 3 | Field layout fallback | **closed** — sealed `byteOffset` only; miss fails closed | No `fieldOffsets[]` resurrection |
| 4 | `EmitListFactoryInto` | **closed** — consumes `FindFunc(expr->resolvedDecl)` and validates registered list-factory identity | `wave-b-list-factory-sealed-callee.md` |
| 5 | `StoreGlobal` exact width | **closed** — uses `EmitWriteValue` | Mutable-global semantic scope remains separate |
| 6 | `CopyVar` / `LoadReturn` 4-or-8 | Register copies, not field memory | Not packed-execute. 12-byte COPY later |

Dump trap: `DumpSealedCanonicalAst` ignores `Build()` return. A GREEN dump does **not** prove Generate consumed the fact.

Packed int8 execute is **this mutex**. Do not pad int8 members to 4. Do not restore WRTV4.

---

## 5. Five remaining 13.2 blockers (honesty)

1. **LEGACY default `asCCompiler` still walks `asCScriptNode` and reruns lookup.** Do not flip default now. CompileFunction stays mixed COMPILER.
2. **CANONICAL CodeGen still has broader lowering/lifecycle gaps**, but its accessor name-strip, `fieldOffsets[]` miss, list-factory behaviour selection, and `StoreGlobal` WRTV4 re-lookups are closed. Switch consume, DeclContext lookup, unique-signature globals, VAR inits, sealed-offset property match: **do not redo**.
3. **`FindExistingExpr` is kind+begin+end, not pending→complete owner+role.** `FindExistingStmt` still kind+begin. Do **not** globally full-span.
4. **`ActOnParsedExpr` `default` / QualType FromNode / child FromNode extract** still walk syntax for meaning. Recovery is allowed.
5. **Sealed dumps/views are still fixture tokens** plus intern-time tables that die with Sema. Migrating dumps onto `Build()` is **necessary and not sufficient**.

---

## 6. Hard constraints (every package)

- Worktree **`D:\as-cta` only**. Do not dirty `D:\Workspace\AngelscriptProject` main checkout.
- One UBT mutex. `-NoXGE`. `ProjectFile=D:\as-cta\AngelscriptProject.uproject`.
- Commands only `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`. Always `RunBuild.ps1` after impl (`RunTests.ps1` does not UBT).
- TDD. Watch RED of the packed execute assert before changing emit.
- Systematic-debugging for `got=0`: root cause **before** any “fix”. Compare generated int8 SetB/GetA vs working FValue int SetValue/GetValue 42. Do not guess WRTV4.
- LLVM/Clang is **shape only**. No link. No Unreal types in frontend fork files.
- Fork dialect: no script `funcdef` / `@` / `is`; mutable globals intern then reject; `nullptr` = `ttNull`. Host `RegisterFuncdef` remains legal.
- CALL-without-callee as unsealed `asCASTVerify` firewall is **forbidden**.
- Do **not** globally change `FindExistingExpr` / `FindExistingStmt` to full-span.
- Do **not** diagnose parser-range class-member / for-init as `unresolved-identifier:`.
- Do **not** invent stmt-level cleanup-plan POD.
- Do **not** restore `GetFirstProperty` in CodeGen, dummy invent CONSTRUCT, 0-arg `FindConstructorId(0)` / `FindFactoryId(0)`, ordinal sibling-VAR match, last-loop break fallback, name+arity global bind, `LookupInScope` `symbols[]`-only.
- LEGACY `ep.propertyAccessorMode == 0`. `.Value` Get/Set rewrite is CANONICAL-only.
- `as_bytecode_codegen.cpp` is often git `??`. Adaptive UBT may skip it. If “Target is up to date”, delete Runtime DLL + `Module.AngelscriptRuntime.44.cpp.obj` (codegen `.44`; dump `.43`; context `.42`; sema `.48`; sema_expr/sema_stmt `.49`) then rebuild.
- CAEngine `UE4Editor` / `MSBuild` / `link` on this machine is **not** this worktree’s lock. Dispatch-time: `UE4Editor` at `W:\CA0917\CAEngine`; Rider temp `.proj` MSBuild; `link` at `D:\Project\CAMain\CAEngine`. **No** `UnrealBuildTool` with `D:\as-cta`.
- Wave E–G **forbidden**. CompileFunction stays mixed COMPILER. Do not archive / commit unless asked.
- Leave 13.2 / 10.2 / 9.5 / 4.2 / 5.4 / 5.6 `[ ]` unless the **full spec meaning** holds. Task 13.3 is the bounded exception closed by `canonical-function-decl-identity-gate-2026-08-23.md`.

---

## 7. Async packages this dispatch

See `async-dispatch.md`. Exclusive UBT is **B-packed-exec**. Research packages write attachments only and must not touch `Plugins/`.
