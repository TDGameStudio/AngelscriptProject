# Wave B research — remaining CANONICAL CodeGen re-lookups (after construct-init)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-codegen-remaining**. Live inventory. Ready-to-execute TDD for leftover bites: `wave-b-codegen-leftover-next.md` (research this dispatch).

Exclusive UBT **now**: packed execute (`wave-b-packed-exec-next.md`). Do **not** compete.

LLVM/Clang is **shape only**. Script `class` = REF implicit handle. Script `struct` = VALUE.

**Do not check 13.2.** **Do not restore** `GetFirstProperty`, dummy VALUE `CONSTRUCT`, `FindConstructorId(0)` / `FindFactoryId(0)`, ordinal sibling-VAR, last-loop break, name+arity global bind, `LookupInScope` `symbols[]`-only.

> **Status update — 2026-08-23.** Bites 2, 3, 5, and 7 below are now closed,
> 6's **local POD assignment, direct POD return/call-result, and direct
> CANONICAL script-to-script POD by-value parameter** portions are now closed.
> Generated
> accessors consume a sealed `(accessorKind, accessorField)` relation, and the
> `fieldOffsets[]` fallback has been removed entirely: type registration and emitters
> consume only sealed `byteOffset`. `StoreGlobal` now uses the same exact-width
> `EmitWriteValue` ABI selection as member stores, rather than unconditionally
> emitting `WRTV4`. The production-equivalent Sema-layout stage was also restored to
> the isolated test helper. See `wave-b-accessor-sealed-field-identity.md`,
> `wave-b-field-offset-fail-closed.md`, and `wave-b-global-write-width.md` for TDD.
> `wave-b-pod-copy-width.md` records the `COPY` protocol, hidden-return route, and
> the maintained generic object-pointer ABI for direct script and external Context
> POD parameters. Constructor/factory, native/system (including generic),
> imported/indirect arguments, indirect returns, and non-POD copying remain
> intentionally outside this slice. Wide POD calls to those external targets now
> fail closed because their ABI may take heap-object ownership; final evidence is
> `53/53` ProductionCodeGen and `518/518` Compiler. List-pattern `Construct`
> nodes now carry the selected native list-factory declaration as `resolvedDecl`;
> CodeGen binds and emits only that declaration, then verifies the target remains
> the type's registered `listFactory`. Integer constant globals
> now consume the sealed `constantValue` fact rather than reparsing `defaultArg`;
> see `wave-b-const-global-sealed-value.md`.
> The older inventory rows are
> retained below as historical dispatch context; do not treat their "remaining"
> wording as current.

---

## 0. Confirmed live (file:line, after construct-init)

| Claim | Live |
| --- | --- |
| `HasConstructAssignTo` | `as_bytecode_codegen.cpp:2821-2847`. Walks `var->inits`, unwrap Materialize/Cleanup, CONSTRUCT. **No `GetStmtCount` scan.** |
| `PropertyFromFieldDecl` | `:3068-3083`. Fail-closed if `byteOffset < 0`. Match `prop->byteOffset == target->byteOffset`. |
| `EmitMember` / `EmitMemberStore` | `:2155+`. Sealed `field->byteOffset >= 0` only; miss FailAt. Does **not** call ordinal fallback. |
| `FindBreakLabel` / `FindContinueLabel` | `:2808-2819` / `:2849-2860`. Match `loops[i].stmt == target` else **-1**. No last-loop. |
| `EmitSwitch` | `:2959+`. `PushLoop(switch, end, continueLabel=-1)`. |
| `LookupInScope` | `as_sema.cpp:81-105`. Grovels sealed `scope->children` by name. |
| `FindRegisteredGlobalFunction` | `as_bytecode_codegen.cpp:61+`. Unique signature (name + param/return + in-out), not first name+arity. |
| Packed opcode | ProductionCodeGen `:2345`. WRTV1/WRTV2 not WRTV4. Offsets B@1 Hi@2. **Execute 1934 not asserted.** |
| `GetFirstProperty` in CodeGen | **ZERO** |
| ProductionCodeGen `TEST_METHOD` count | **53** |
| SemaAuthority / CanonicalAST / Compiler | **250 / 321 / 511** `wave-b-construct-init-*` |

---

## 1. Remaining Generate-local leftover (not packed-execute mutex)

Classify **engine mapping** (allowed) vs **second Sema** vs **Generate-local leftover**.

| Site | File:line | Class | Consume sealed instead? |
| --- | --- | --- | --- |
| `EmitGeneratedAccessor` | **closed** | **sealed accessor-field identity** | Generated METHOD consumes its sealed `(accessorKind, accessorField)` relation. It does not strip `Get`/`Set` or scan sibling fields. |
| `FindFieldOffset` table miss | **closed** | **sealed field layout** | Only the selected field declaration's `byteOffset >= 0` is accepted; there is no `fieldOffsets[]` fallback. |
| `fieldOffsets[]` fill | `RegisterCanonicalScriptTypes` `:3144+` | same | Primary layout is Sema `LayoutScriptClassFields`. |
| `EmitListFactoryInto` | **closed** | **sealed native list-factory callee** | `Construct.resolvedDecl` identifies a constructor declaration carrying `asAST_TRAIT_LIST_FACTORY`; `FindFunc` must bind it and its function id must still equal the type's registered `listFactory`. Missing/mismatched facts fail closed. |
| `DestroyObject` | dtor from `beh.destruct` | **Engine mapping** | Cleanup expr already has sealed callee in dumps. |
| `StoreGlobal` | **closed** | **exact-width global write** | Uses `EmitWriteValue` with the sealed data type, as member stores do. |
| `CopyVar` / `LoadReturn` / `PushValue` | 4-or-8 | **ABI register leftover** | Local POD assignment, direct POD return/call result, and direct CANONICAL script-to-script POD arguments are closed through `COPY` plus the maintained object-pointer ABI. Constructor/factory, native/system, imported/indirect arguments, indirect returns, and non-POD semantics remain. Native/system wide arguments are explicitly rejected until an owned heap-transfer lowering exists. |
| Const global `strtoll` | **closed** | **Generate-local const eval** | Integer globals consume sealed `hasConstantValue` / `constantValue`; CodeGen no longer reparses `defaultArg`. Floats, strings, objects, and runtime global initialization remain outside this slice. |
| `EmitCall` receiver | **closed** | **Explicit sealed receiver edge** | `asCExpr::receiver` is a snapshot-local expression ID; Sema, lambda capture scanning, dumps, and CodeGen consume it directly. `literalBits` is now literal payload only. See `wave-b-call-receiver-explicit-edge.md`. |

**Already consuming sealed facts (do not “fix” by restoring walks):**

- Script/native `byteOffset` on Seal.
- `EmitCall` / `EmitIndex` / ordinary construction / list-pattern construction consume `FindFunc(resolvedDecl)` and miss `asNO_FUNCTION`.
- `EmitMember` sealed offset only.
- `HasConstructAssignTo` VAR `inits`.
- `PropertyFromFieldDecl` sealed offset match.
- `LookupInScope` children.
- Unique-signature host globals.
- `EmitSwitch` + fail-closed break/continue.
- Packed **opcode** WRTV1. Packed **execute 1934 OPEN**.

---

## 2. Remaining bites after this exclusive UBT

| # | Bite | Owner |
| --- | --- | --- |
| 1 | Packed execute 1934 (`got=0`) | **B-packed-exec NOW** |
| 2 | Accessor sealed field id (no Get/Set name-strip) | **closed** — `wave-b-accessor-sealed-field-identity.md` |
| 3 | `fieldOffsets[]` miss fail-closed | **closed** — `wave-b-field-offset-fail-closed.md` |
| 4 | listFactory `FindFunc(resolvedDecl)` | **closed** — `wave-b-list-factory-sealed-callee.md` |
| 5 | `StoreGlobal` exact-byte | **closed** — `wave-b-global-write-width.md` |
| 6 | 12-byte `asBC_COPY` / hidden return object / direct generic-pointer argument | **local POD assignment, direct return/call result, direct CANONICAL script-to-script POD by-value parameters, and external Context invocation closed**; constructor/factory, native/system, imported/indirect arguments, indirect returns, and non-POD remain. System/generic calls explicitly reject until owned heap transfer exists. |

**13.2 stays `[ ]`.** LEGACY default `asCCompiler`, `FindExistingStmt` kind+begin, Parser `asCScriptNode` recovery, and fixture dump tokens ≠ sealed plans are all still true.
