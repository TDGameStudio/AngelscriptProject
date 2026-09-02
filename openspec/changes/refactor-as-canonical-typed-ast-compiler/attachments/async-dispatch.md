# Async dispatch — 2026-08-22 (after construct-init; exclusive = packed int8 execute)

> **Superseded status note — 2026-09-01:** this dispatch is a dated historical
> package. Tasks 4.2 and 5.4 were closed by later complete gates. Use `tasks.md`
> and `reviews/current-overall-progress-2026-09-01-2005.md` for current status;
> the old leave-open instructions below describe only the 2026-08-22 evidence
> boundary.

Worktree: `D:\as-cta`. Only one UBT user at a time.
Plan: `attachments/async-work.md`. Exclusive **B-packed-exec** **LANDED** (1934/902). Mutex free. Next exclusive: Generate-local leftover.
Do not mark 13.2 / 13.3 / 13.1 / 13.6 / 9.1 / 9.5 / 10.2 / 10.4 / 4.2 / 5.4 / 5.5 / 5.6 / 5.7 / 5.8 / 5.9.

**Construct-init LANDED.** `HasConstructAssignTo` walks VAR `inits` CONSTRUCT (no stmt scan). `PropertyFromFieldDecl` matches sealed `byteOffset` (not ordinal). Packed **opcode** WRTV1 GREEN; packed **execute 1934 OPEN** (`got=0`). Switch 21/7, DeclContext children lookup, unique-signature host globals: do not redo.

SemaAuthority **250/250** `wave-b-construct-init-sema`. CanonicalAST **321/321** `wave-b-construct-init-canonicalast`. Compiler **518/518** `cta-codegen-publication-gate-compiler`. ProductionCodeGen **53/53** `cta-codegen-publication-gate-production`. CodeGen transaction **8/8** `cta-codegen-publication-gate-transaction-green-v2`. Isolated **4/4**. Semantics **12/12**.

**Leave 5.6 / 5.5 / 5.4 / 4.2 / 9.5 / 13.2 `[ ]`.** 9.3 remains 虚标 (switch is a slice). 9.2 remains 虚标 (packed execute open). Do not uncheck them this dispatch.

CompileFunction stays mixed COMPILER. Do not skip to Wave E–G.

Eleventh-pass still **Request changes** (cutoff before this live state). Tenth-pass system blockers stand. Do not archive.

## Honest already-closed (do not redo)

| Item | Evidence |
| --- | --- |
| R11 | CodeGen teardown closed |
| Wave A | LEGACY default, publisher observable; 13.1 still `[ ]` |
| Wave C R07/R08/2.6 | 2.4 / 2.8 / 2.6 / 13.4 `[x]`; never CALL-without-callee |
| Dedicated intern through F5 + 1070 | SemaAuthority **250/250**. **Not** 4.2 / 13.2 |
| **B-54-opaque** / Isolated | Isolated **4/4**. Semantics **12/12**. **Not** 5.4 |
| **B-55 publication verifier + consumer** | Verifier **20/20**; canonical `Generate()` consumes it before mutation. **Not** 5.5 / 5.6 |
| **F2 Phase A+B exact CALLSYS** | n-arg METHOD/ctor/factory/opIndex |
| **InitPlan dump + execute** | Execute **42** |
| **Native 0-arg intern** | Default factory/ctor only |
| **Dummy invent CONSTRUCT** | Deleted. Do not restore |
| **MemberRef Sema + execute 42** | Sealed field |
| **Sealed native + script `byteOffset`** | `LayoutScriptClassFields` before Seal |
| **Exact-byte RDR/WRTV + packed opcode** | int64/double/handle RDR8; packed WRTV1. Execute 1934 **not** closed |
| **Get miss fail-closed** | No `GetFirstProperty` in CodeGen |
| **FindExistingExpr kind+begin+end** | Not owner+role |
| **ObjectTypeFromExpr Resolve-only** | Allowed engine mapping |
| **B-seal-facts compile-seal dumps** | Four remaining construction-API facts on `Build()`+retain |
| **B-sealed-env** | ProductionCodeGen execute 21 and 7. `EmitSwitch` + no last-loop fallback |
| **B-declcontext** | `LookupInScope` grovels `scope->children`. SemaAuthority 249 then 250 |
| **B-global-bind** | `HostPick(41)` execute 42, CALLSYS int. Unique signature intern+bind |
| **B-construct-init** | VAR `inits` CONSTRUCT. Sealed-offset `PropertyFromFieldDecl`. **250/250 48/48 321/321 511/511** |
| Wave D Tasks 1–10 named rows | Cutover **5/5**; Ready true; default LEGACY — **not** 9.5 |
| Identity **8/8** | **not** 13.3 |
| Transaction **8/8** | **not** 9.1 |
| Dump **6/6** | Observer only |

## This dispatch

| Package | Mode | Output | Constraint |
| --- | --- | --- | --- |
| **B-packed-exec** | exclusive UBT — **LANDED** | ProductionCodeGen **48/48**. `RunPacked` 1934, `RunPair16` 902. Shunting-yard intern of flat `snExpression`. Map: `wave-b-packed-exec-next.md` | **13.2 stays `[ ]`**. Mutex released |
| **B-codegen-leftover-next** | implementation | Accessor sealed field id, sealed field-offset fail-close, list-factory `FindFunc(resolvedDecl)`, and `StoreGlobal` exact-byte are now closed. See their Wave B attachments. | Do not claim 13.2 from these local closures |
| **B-132-remaining** | research — attachments only | Refresh `wave-b-132-remaining.md` for live post-construct-init | **Do not check 13.2**. No `Plugins/` |

Do **not** re-research LLVM construct intern / Verifier 13.5 / F2 exact bind / InitPlan / MemberRef / ABI helpers / B-seal-facts dumps / switch emit / DeclContext / global bind / HasConstructAssignTo scan / ordinal field — those maps already on disk and intern landed.

## Already on disk (queued exclusive UBT later)

| Package | Output | Gate |
| --- | --- | --- |
| Packed int8 execute 1934 | `wave-b-packed-exec-next.md` | **This mutex** |
| Accessor name-strip / `fieldOffsets[]` / listFactory / `StoreGlobal` | **closed** — see Wave B closure attachments | Local lowering closure only |
| Verifier 13.5 remainder | `wave-b-verifier-135-next.md` | Not unsealed CALL-without-callee |
| Leftover expr `default` FromNode | `wave-b-leftover-after-opaque.md` | **None today.** Recovery stays recovery |
| 12-byte POD `asBC_COPY` | after packed execute | Fail-closed `>8` stays until then |
| **Wave E snapshot ABI** | 3.2 / 3.4 / 13.7 / 13.8 | After rereview of the 9.5 subset |
| **Wave F Cache/SourceManager** | 6.3 / 2.2 / 13.9 / 13.10 | After E |
| **Wave G default CANONICAL** | 10.2 | After 9.5/9.7 and rereview. **Forbidden now** |

## Parallelism

Do **not** spawn a second UBT agent in `D:\as-cta`. Mutex is **B-packed-exec**.

Packed-execute TDD and leftover/13.2 research do **not** share write files. Research must not touch `as_sema*.cpp` / `as_bytecode_codegen.cpp` / test `.cpp`.

Do not re-edit Isolated / 5.5 dump / F2 / InitPlan / 0-arg / MemberRef / Get-miss / identity / switch / HostPick / construct-init tests except to keep them compiling. Packed opcode lock stays; **add** execute oracles (do not delete WRTV1 asserts).

## UBT mutex

One UBT user in `D:\as-cta`. `-NoXGE`. `ProjectFile=D:\as-cta\AngelscriptProject.uproject`.

`UE4Editor` / `MSBuild` / `link` on this machine may belong to CAEngine (`W:\CA0917\CAEngine`) or Rider (`ClrStack` / temp `.proj`). They are **not** this worktree’s lock. Dispatch-time: `UE4Editor` pid on CAEngine; Rider `Lohobiv.proj` / `Zudicex.proj`; `link` at `D:\Project\CAMain\CAEngine`. **no** `UnrealBuildTool` with `D:\as-cta`.

`as_bytecode_codegen.cpp` is often git `??` untracked — adaptive UBT may skip it. If “Target is up to date”, delete `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` and `Intermediate/.../AngelscriptRuntime/Module.AngelscriptRuntime.44.cpp.obj` (codegen is in `.44`) then rebuild. Sema expr/stmt is `.49`. Dump `.43`. Context `.42`. Sema `.48`.

Do not start Wave E/F/G. Do not archive. Do not commit unless asked.
