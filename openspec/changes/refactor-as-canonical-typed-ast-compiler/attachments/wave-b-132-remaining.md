# Wave B — 13.2 remaining honesty (2026-08-22, after construct-init)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
**Write-only this file in the research package** except the parent 梳理 may refresh it.
Implementer of **B-packed-exec** must not treat this file as permission to check 13.2.

Live 梳理: `attachments/async-work.md`. Exclusive UBT **now**: `attachments/wave-b-packed-exec-next.md` (packed execute 1934). **Not 13.2.**

13.2 text (unchanged): replace the `asCScriptNode` syntax walk with a **Sema environment** (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets). Sealed dumps/views must show those facts so **backends do not rerun Sema**.

Parser still producing `asCScriptNode` is **allowed recovery**. It is **not** the 13.2 close criterion.

---

## 0. Verdict

13.2 is **false**.

Construct-init (`HasConstructAssignTo` VAR `inits`, sealed-offset `PropertyFromFieldDecl`), switch consume 21/7, DeclContext children lookup, unique-signature host globals, ABI intern, compile-seal dumps, MemberRef 42, InitPlan 42, 0-arg intern, dummy CONSTRUCT delete, Get-miss fail-closed, FindExistingExpr kind+begin+end, ObjectTypeFromExpr Resolve-only are real slices. They are **not** a Sema environment.

Honest cutover ~**50%–52%**. **Do not jump to Wave E–G.** Mechanical checklist is 虚标. Eleventh-pass Request changes stands (cutoff before this live state). Tenth-pass system blockers stand.

Do **not** list as remaining: `GetFirstProperty` in CodeGen (gone), MemberRef got=0 (GREEN 42), `FindExistingExpr` kind+begin-only (end matched when nonzero), `FindConstructorId(0)` call sites (gone), dummy invent CONSTRUCT (deleted), script field offset unsealed on dump path, `EmitSwitch` missing, last-loop break fallback, `LookupInScope` `symbols[]`-only, host global name+arity, `HasConstructAssignTo` full-stmt scan, `PropertyFromFieldDecl` ordinal sibling-VAR.

---

## 1. What IS true now (do not redo)

- Dedicated `ActOn*` intern through F5 + 1070 + OpaqueValue.
- CANONICAL `Build()` → `SealCanonicalAST` (fail-closed on Sema diags, **`LayoutScriptClassFields()`**, `Seal()`) → `asCBytecodeCodeGen::Generate()`.
- Dumps of `callee=` / `offset=` / `init=` / `target=` / `captures=` / `receiver=` / `safepoint=` on fixtures.
- Native + script `DECL_VAR` `byteOffset` interned.
- `MemoryBytes` + RDR/WRTV 1/2/4/8. Packed opcode lock GREEN. Packed execute 1934 **OPEN**.
- F2 n-arg exact CALLSYS. 0-arg Construct `FindFunc(resolvedDecl)` only.
- `GetFirstProperty` gone from CodeGen.
- `EmitSwitch` + no innermost-loop fallback. Execute 21 / 7.
- `LookupInScope` grovels sealed `scope->children`.
- Host globals unique-signature intern+bind. `HostPick(41)` execute 42.
- `HasConstructAssignTo` walks `var->inits` unwrap Materialize/Cleanup then CONSTRUCT.
- `PropertyFromFieldDecl` matches `prop->byteOffset == target->byteOffset` (fail-closed if `byteOffset < 0`).
- `EmitMember` / `EmitMemberStore` sealed `field->byteOffset >= 0` only; miss FailAt.

Prefix greens that must **never** be 13.2 evidence: SemaAuthority **250/250**, CanonicalAST **321/321**, Compiler **511/511**, Isolated **4/4**, Semantics **12/12**, Identity **8/8**, Cutover **5/5**.

---

## 2. What is NOT 13.2 (live leftover)

| Site | Live | Why it is still not a Sema environment |
| --- | --- | --- |
| LEGACY `asCCompiler` | default pipeline | Walks `asCScriptNode` (`CompileStatement`, `MatchFunctions`) |
| Packed execute 1934 | opcode WRTV1 GREEN; execute `got=0` | **This exclusive UBT.** Not 13.2 even if GREEN |
| `EmitGeneratedAccessor` | **closed** — consumes sealed `(accessorKind, accessorField)` | No Generate-local name walk |
| `fieldOffsets[]` | **closed** — sealed `byteOffset` miss fails closed | No table fallback |
| `EmitListFactoryInto` | **closed** — consumes sealed `resolvedDecl` and validates list-factory identity | No type-behaviour callee selection |
| `StoreGlobal` | **closed** — uses exact-width `EmitWriteValue` | Mutable-global semantic scope remains separate |
| sealed publication target gate | **closed for CALL / CONSTRUCT / DECL_REF and consumed by canonical `Generate()`** — `wave-b-codegen-publication-gate.md` | Expression ownership/cycles and full call-plan validation remain open |
| `CopyVar` / `LoadReturn` | 4-or-8 dwords | Register leftover |
| `FindExistingStmt` | kind+begin | Control stub fill — do not globally full-span |
| FromNode recovery | `ActOnParsedExpr` `default`, `ActOnQualTypeFromNode` | Allowed recovery, not action-only |
| Intern-time `FindBestCallee` / `controlStack` | die with Sema | Not sealed plans |

`DumpSealedCanonicalAst`: `Module->Build();` then dump even if Generate fail-closes. **GREEN dump ≠ Generate consumed the fact.**

9.3 `[x]` remains **虚标**: switch is a slice, not the full structured-control sentence.
9.2 `[x]` remains **虚标**: packed execute open.

---

## 3. Remaining work to make 13.2 TRUE

Ordered **after** current exclusive **B-packed-exec**. Do **not** start Wave E–G. Do **not** flip default. Do **not** check 13.2 after packed execute GREEN.

**Now (exclusive UBT):** packed int8 execute 1934 (`wave-b-packed-exec-next.md`). **Necessary and not sufficient.**

Then, still 13.2:

1. **These Generate-local re-lookups are now closed:** accessor Get/Set name-strip, `fieldOffsets[]` when sealed offset `< 0`, listFactory behaviour selection, and `StoreGlobal` WRTV4. Do **not** restore dummy CONSTRUCT / `GetFirstProperty` / ordinal / 0-arg arity fallback.
2. **Pending→complete identity.** Not global full-span. `FindExistingStmt` stays kind+begin until a dedicated bite.
3. **FromNode stays recovery** unless a dump intern-creates inside `ActOnParsedExpr` `default`.
4. **LEGACY `asCCompiler` remains default.** 13.2 cannot be true for **production** backends until Wave G **after** CANONICAL already consumes the sealed graph. Honesty, not a now-task.

Do **not**: invent stmt-level cleanup-plan POD; require CALL-without-callee on unsealed `asCASTVerify`; restore script same-arity fallback; globally full-span `FindExisting*`; intern script `funcdef` / `@` / `is` / try-catch.

**Do not check 13.2.**
