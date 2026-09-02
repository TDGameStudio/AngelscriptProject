# Wave B remaining 5.4 hole — Generate / VM traces (dump already GREEN)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Attachment-only research. **No `Plugins/` edits. No UBT. Do not rewrite `wave-b-54-single-eval-next.md`.**
**Do not check `tasks.md` 5.4 / 13.2.** Leave those boxes `[ ]`.

Dump plan **landed**: OpaqueValue + Sequence `literal=opaque` + Logical `lhs=`/`rhs=` + Conditional `cond=`/`then=`/`else=`. SemaAuthority dump GREEN is **not** task 5.4. Original 5.4 still requires isolated legacy/canonical **VM side-effect traces of AST-driven CodeGen**. Dump is not that.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM.

Companions (do not redo):

- `wave-b-54-single-eval-next.md` — dump TDD map; **landed**
- `async-work.md` §3 “Where 5.4 actually is” / §4 Hole 3
- `wave-b-54-1070-next.md` — **next exclusive UBT after F4 native (and after F5 if F5 holds `as_sema.cpp`)**: class-member / for-init DeclRef lookup only
- Exclusive UBT **now** (do not mix into it): `wave-b-eighth-f4-native-next.md` (`array<int>::insertLast`)
- B-56-body-owner is **already GREEN**. Do not re-gate this file on it.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Package | **B-54-generate-remaining** (`async-work.md` §7 parallel no-UBT) |
| Mode | Attachment only. Next Generate exclusive is **1070 lookup**, not OpaqueValue memo |
| Evidence now | F4 intern GREEN (SemaAuthority **227/227** `wave-b-eighth-f4-sema2`). Parser-range DeclRef recovery unblocked value-object Seal. ProductionCodeGen **32/33** `wave-b-eighth-f4-prod3` (only `insertLast`). Live `EmitDeclRef` FailAt is **`as_bytecode_codegen.cpp:1107`** (`asAST_VERIFY_DANGLING_ID`). Historical logs said **1070** — same FailAt, file grew. VmMatrix `RunSingleEval` still default LEGACY `asCCompiler` |
| Gate | **F4 native GREEN** first (do not mix 1070 into insertLast). Then **one** exclusive: `wave-b-54-1070-next.md`. OpaqueValue memo / mutation traces are a **later** UBT after 1107 is gone |
| Do not mark | **5.4 / 13.2** (also 4.2 / 5.6 / 5.9 / 9.5 / 13.3) |

---

## 1. Live `ActOnDeclRefExpr` after F4 — why 1107 is not OpaqueValue

### 1.1 F4 split (do not flatten)

Live `as_sema.cpp:680-737`:

```680:737:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp
asASTExprId asCSema::ActOnDeclRefExpr(asASTDeclId owner, const char* name, const asCSourceRange& range)
{
	asCArray<asASTDeclId> hits;
	LookupCandidatesFrom(owner, name, hits);
	// … prefer VAR, else hits[0] …
	if( !target.IsValid() )
	{
		if( range.begin.fileID == 0 )
		{
			// construction-API miss: diagnostic + ERROR "<unresolved>"
			AddDiagnostic("unresolved-identifier:" + name);
			return ActOnDeclRef(asASTDeclId(), InternNamedType(ERROR, "<unresolved>"), range);
		}
		// parser-range miss: silent intern int, invalid resolvedDecl, no diagnostic
		return ActOnDeclRef(asASTDeclId(), InternPrimitive(ttInt), range);
	}
	// hit: type from decl, ActOnDeclRef(target, …)
}
```

| Path | Range | On lookup miss | Seal | Generate |
| --- | --- | --- | --- | --- |
| **Construction-API** | `fileID == 0` (empty `asCSourceRange()`) | `unresolved-identifier:` + `asAST_TYPE_ERROR` `"<unresolved>"` | fail-closed (diagnostics) | not the 1107 family |
| **Parser-range** | `fileID != 0` | **silent `int` DeclRef**, `resolvedDecl` invalid, **no** diagnostic | **not** blocked (F4 recovery) | `EmitDeclRef` `GetDecl==0` → FailAt **`:1107`** |

`UnresolvedDeclRefMissingIsErrorTypeNotInt` is the construction-API contract (`ActOnDeclRefExpr(Tu, "Missing", empty Range)`). Keep it. Parser-range silent `int` is **recovery so `FValue() { Value = 41; }` Seal is not blocked by `unresolved-identifier:Value`**. It is **not** a bound VAR/PROPERTY. Do **not** “fix” 1107 by diagnosing parser-range class-member / for-init names as ERROR — that is prod2 (`unresolved-identifier:Value` + Seal fail-closed, ProductionCodeGen value-object RED).

Verifier still only flags `resolvedDecl.IsValid() && GetDecl==0` (`as_ast_verifier.cpp:509`). Invalid-id DeclRef is legal unsealed. Generate is the first fail-closed consumer of the read path.

### 1.2 Live FailAt is `EmitDeclRef` `:1107`, not unknown-kind, not OpaqueValue

```1102:1108:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		int EmitDeclRef(const asCExpr* expr, const asCDataType& dataType, int dwords)
		{
			const asCDecl* target = context.GetDecl(expr->resolvedDecl);
			if( target == 0 )
			{
				FailAt(__LINE__, asAST_VERIFY_DANGLING_ID);
				return 0;
```

`code=1` is `asAST_VERIFY_DANGLING_ID`. Not `default:` `asINVALID_ARG` (`:979-981`). Not OpaqueValue (passthrough already exists at `:896-897`). A bound VAR/PARAM whose **slot** is missing is later `asNOT_SUPPORTED` (`FindSlot == 0x7fffffff` at `:1148-1150`), not this line.

Pre-F4 dump log (`wave-b-54-sema3`) printed `line=1070`. `wave-b-eighth-f4-red` printed `line=1107` on ForLoop / IndexCompoundAssign. Same `FailAt(__LINE__)`. Re-read the printed line after F4 native GREEN; do not hard-code 1070 into the next UBT.

### 1.3 F4 recovery unblocked **assign** Generate; **read** still 1107

`EmitAssign` of `DECL_REF` (`:1183-1232`) has a **literal-name** fallback that `EmitDeclRef` does **not**:

```1214:1232:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
				if( func && func->objectType && lhs->literal.GetLength() )
				{
					if( asCObjectProperty* member = func->objectType->GetFirstProperty(lhs->literal.AddressOf()) )
					{
						// ADDSi + WRTV4 — does not need a live resolvedDecl
```

That is why ProductionCodeGen `FValue() { Value = 41; }` recovered in `wave-b-eighth-f4-prod3` (**32/33**, only `insertLast`) **without** binding `resolvedDecl`. `ActOnDeclRefExpr` still `SetLiteral(ref, name)` on the silent-int miss (`:717-721`). Assign writes the engine property by name. `return Value` / `i < 1` go through `EmitDeclRef` and FailAt.

Do **not** treat prod3 value-object GREEN as “class-member DeclRef is bound.” Do **not** add the same literal fallback to `EmitDeclRef` as the 1070 UBT — bind real VAR/PROPERTY decls.

### 1.4 Two intern-order families (lookup walk is not missing)

`LookupCandidatesFrom` (`as_sema.cpp:98-133`) already: walk `start → parent`; on CLASS/INTERFACE also scan children VAR/PROPERTY. **Do not** search every class from the TU.

The miss is **intern order**, then `FindExistingExpr` (kind + begin.fileID + begin.offset, skip 0 — `as_sema_expr.cpp:35-48`) **freezes** the silent-int DeclRef.

**Family A — class member identifier in a method/ctor body**

`ParseClass` (`as_parser.cpp:3968-4025`): `NotifySema` after the class identifier (no VAR children yet). Member loop `ParseDeclaration(true)` does **not** `NotifySema`. `ParseFunction(true)` parses the body via `ParseStatementBlock` → `ParseVariableAccess` `ActOnParsedExpr` (`:1871-1886`) while the field is **not** a CLASS child.

Later `ParseScript` `NotifySema(complete class)` intern `int Value` and `AttachParsedFunctionBody` **reuses** the BLOCK (`owner==fn`, B-56). The DeclRef inside stays invalid.

Fixtures (dump-only today; `DumpSealedCanonicalAst` discards `Build()`):

- `PropertyReadWriteRewritesToAccessors` — user `GetValue() { return Value; }` / `SetValue` `{ Value = Next; }` (the **return** is 1107; assign may literal-fallback)
- `IndexCompoundAssign*` / `PropertyCompoundAssign*` — `int &opIndex` / `GetValue` `{ return Value; }` / `{ return Stored; }`
- Contrast that **does** Generate: `IndexOnCompileSealPathRecordsIndexNode` — `opIndex` `{ return Index; }` (**param**, not a class field)

**Family B — for-init local in cond/incr**

`ParseFor` (`:5046-5144`): `ParseDeclaration` of `int i = 0` does **not** `NotifySema`. Then `ParseExpressionStatementCondition` → `ParseVariableAccess` intern `i` (miss). Then incr `i += 1` intern `i` (FindExisting reuses miss). Then `ActOnParsedStmt(for)` intern the VAR — too late.

- `ForLoopRecordsInitCondIncrBodyPhasesOnCompileSeal` — `for (int i = 0; i < 1; i += 1)`
- `ForStmtRecordsNamedPhasesOnCompileSealPath` — `for (int I = 0; I < 3; ++I)`

Function-body locals already Generate (`T Values` in IndexOnCompileSeal; `int I = 0; while` in LoopReturnCall): `InternParsedCompoundStmt` InsertSymbol before later DeclRefs in the **same** walk, and those identifiers are not interned by `ParseVariableAccess` before the local exists.

`wave-b-eighth-f4-sema2` printed `unresolved-identifier:i` / `:Value` (F4 intern still diagnosed **all** misses). After parser-range recovery those diagnostics disappear; Seal succeeds; Generate of the **read** path is what 1107 is. CanonicalAST / SemaAuthority were **not** re-run after recovery — first 1070 UBT step is re-measure `Canonical CodeGen failed code=1 line=` on the fixtures above.

### 1.5 Verdict (post-F4)

| Hypothesis | Live evidence | Result |
| --- | --- | --- |
| OpaqueValue unknown kind | `case asAST_EXPR_OPAQUE_VALUE` passthrough `:896-897`. Fail is `code=1` `EmitDeclRef` | **False** for 1107 |
| Index base of `Make()` as the unique 1107 | `IndexOnCompileSealPath` (`return Values[3]`, `opIndex` returns **param** `Index`) has no CodeGen fail | **False** as unique cause |
| Mutation Sequence / OpaqueValue as the 1107 expr | Generate walks **every** function-like decl. Same 1107 on PropertyReadWrite / for-init (no `+=` OpaqueValue) | **False** as unique cause |
| F4 silent int **is** a bound member | prod3 FValue ctor is `EmitAssign` literal fallback; `EmitDeclRef` still needs `GetDecl` | **False** |
| Parser-range DECL_REF interned with empty `resolvedDecl` | `ActOnDeclRef(asASTDeclId(), int, range)` when hits empty and `fileID != 0` | **True** — class-member + for-init intern-order |

`Make()[0] += 1` still dies first while emitting **`int &opIndex(int Index) { return Value; }`**, same family as PropertyReadWrite `return Value`. Not because Index's base is OpaqueValue.

Term-era history (`wave-b-term-fix-next.md`): before Index intern, `code=1 line=1068` with no Index in the dump. After Term peel the FailAt line moved with the file; the **cause class stayed DeclRef dangling**. F4 only changed the **miss type** (ERROR vs silent int) and **Seal**. It did not bind members/for-init.

---

## 2. OpaqueValue CodeGen is passthrough (re-evals). Single-eval lowering, children IDs only

**After 1070 GREEN.** Not the next exclusive UBT. Do not mix into `wave-b-54-1070-next.md`.

Landed fire-break (dump brief §2, **not** 9.5, **not** eval-once):

```896:897:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			case asAST_EXPR_OPAQUE_VALUE:
				return expr->children.GetLength() ? EmitExpr(expr->children[0]) : 0;
```

`ActOnOpaqueValueExpr` stores **one child** (the source) and copies that source's type/value category (`as_sema.cpp:848-867`). Dump `source=` is that child id (`as_ast_dump.cpp`).

Why passthrough still double-evaluates `Make()`:

```1631:1632:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			const int base = EmitExpr(expr->children[0]);
			const int index = EmitExpr(expr->children[1]);
```

`EmitIndex` **always** `EmitExpr`s the base. If the base id is OpaqueValue, passthrough re-runs `Make()`. `EmitBinary` / `EmitAssign` / `EmitCall` do the same for each operand id. Sharing a Call id without OpaqueValue is still re-inference (`wave-b-54-single-eval-next.md` §2). Sharing the **OpaqueValue id** is the fact CodeGen can memoize.

Sequence is left-to-right last-value (`as_bytecode_codegen.cpp:953-976`). It skips CALL-without-callee and DECL_REF of function-like/**CLASS** only when `GetDecl` succeeds. A dangling DECL_REF in a Sequence is **not** skipped — it is the 1107 path.

### Lowering (no stmt-level cleanup POD, no new `asCExpr` fields)

`asCExpr` stays the compact tagged POD (`id/kind/range/type/valueCategory/resolvedDecl/literal/literalBits/children`). `asAST_EXPR_OPAQUE_VALUE` is already the kind.

CodeGen-**local** memo, keyed by OpaqueValue **expr id** (not a node field):

```text
EmitExpr(OpaqueValue id):
  if memo[id] bound: return that slot
  slot = EmitExpr(children[0])          // source, once
  memo[id] = slot
  return slot
```

Mutation Sequence `literal=opaque` (intended children, dump `parts=`):

```text
parts=<OV>,<Index-or-Get>,<Add>,<Set-or-Assign>
  OpaqueValue source=<Make Call or Materialize>     // children[0] only
  Index(OV, 0)  callee=T::opIndex(int)              // base child is OV id
  Binary/Call +
  Assign/Set through the same OV id
```

Every later Index/Get/Set/Binary operand that must not re-run `Make()` stores the **OpaqueValue expr id**, not a second Call.

Also unwrap OpaqueValue like Materialize/Cleanup (child 0, not Sequence last) in `ObjectTypeFromExpr` (`as_bytecode_codegen.cpp:491-505`) so `opIndex` object type follows the bound source. That is a children-ID walk, not a new POD member. Live unwrap is Materialize/Cleanup/Sequence only — OpaqueValue is **not** in that list yet.

**Do not invent stmt-level cleanup-plan fields.** Temporaries stay `MaterializeTemporary` / `Cleanup` expr kinds (`ValueTemporaryRecordsMaterializeAndCleanup` already dumps them; `Build()==0`).

### Mutation write-through is a second CodeGen hole (even after memo)

`EmitAssign` for non-DECL_REF / non-MEMBER_REF lhs (`as_bytecode_codegen.cpp:1325-1335`):

```text
rhs = EmitExpr(rhs)
dest = EmitExpr(lhs)     // Index: RDR4 *through* opIndex ref into a temp
CopyVar(dest, rhs)       // writes the temp, not the object
```

`EmitIndex` for `int &opIndex` already `RDR4`s the reference into a dest (`:1645-1648`). A VM trace of `Make()[0] += 1` needs the **address** kept (PSF / WRTV through the returned ref), not only a load. Memo of OpaqueValue is necessary and not sufficient.

### Dump GREEN does not prove the stmt expr *is* the mutation Sequence

`FindExistingExpr` matches **kind + `range.begin.fileID` + `range.begin.offset` only** (`as_sema_expr.cpp:35-48`). Do **not** globally change it to full-span.

`ActOnAssignExpr` `+=` (`as_sema_expr.cpp:752-835`):

1. Reuse SEQUENCE at the **assignment** range only if `literal=opaque`.
2. Intern OV + wrapped Index + add + write.
3. `ActOnSequenceExpr(parts, range)` (`713-736`) **returns any existing SEQUENCE at that begin.offset**.

`Make()[0] += 1`: Term intern already made a postfix SEQUENCE (`literal=seq`) whose begin is `Make`. Assignment range begins at the same offset. `ActOnSequenceExpr` can **steal** that postfix bag; `SetLiteral(..., "opaque")` retags it. Dump tests only require *some* `kind=OpaqueValue` line and *some* `kind=Sequence literal=opaque` — they do **not** require `parts=` to be OV,Index,Add,Write. Orphaned mutation nodes still make SemaAuthority GREEN.

If Entry's stmt expr is the stolen postfix bag, Generate of Entry never hits the OpaqueValue case. 1107 still comes from `opIndex`/`GetValue` member DeclRefs. Fixing steal is `as_sema_expr.cpp` **after** 1070, not in the 1070 bite.

---

## 3. SemaAuthority methods that dump instead of `Build()==0` because Generate fail-closes

Helper (`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:213-227`):

```text
Module->Build();          // result discarded
asCASTDump(*GetCanonicalASTContext(), OutDump);
return true;
```

Dump-plan methods 3.1 / 3.2 **wanted** `Build()==0` (`wave-b-54-single-eval-next.md` §3). They landed on this helper, same as the weak Index count lock. **227/227 is not Generate GREEN.**

### 5.4-related (must not be treated as Generate GREEN)

| TEST_METHOD | Why dump | Last measured Generate |
| --- | --- | --- |
| `IndexCompoundAssignEvaluatesBaseOnce` | Weak `callee=Make()` count; no OpaqueValue tokens | `f4-red`: `code=1 line=1107`; `f4-sema2`: `unresolved-identifier:Value` (Seal); **not re-run after silent-int recovery** |
| `IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath` | Dump tokens for `Make()[0] += 1` | same |
| `PropertyCompoundAssignEvaluatesReceiverOnceOnCompileSealPath` | Dump tokens for `Make().Value += 1` (`return Stored`) | `f4-sema2`: `unresolved-identifier:Stored` |

### Same 1107 family, same helper, not the mutation plan (1070 UBT locks — not OpaqueValue)

| TEST_METHOD | Fixture | Why 1107 |
| --- | --- | --- |
| `PropertyReadWriteRewritesToAccessors` | user `GetValue() { return Value; }` | class-member **read** |
| `ForLoopRecordsInitCondIncrBodyPhasesOnCompileSeal` | `for (int i = 0; …; i += 1)` | for-init cond/incr intern before VAR |
| `ForStmtRecordsNamedPhasesOnCompileSealPath` | `for (int I = 0; …; ++I)` | same |

### 5.4 dump methods that **do** `Build()==0` (Generate already runs)

| TEST_METHOD | Assert |
| --- | --- |
| `LogicalAndRecordsNamedOperandsOnCompileSealPath` | `Build()==0` then dump `lhs=`/`rhs=` |
| `ConditionalMismatchedArmsRecordConversionOnCompileSealPath` | `Build()==0` then dump `cond=`/`then=`/`else=` + Conversion |
| `LogicalShortCircuitRecordsOnCompileSealPath` | `Build()==0` (kind+callee lock; named operands are the sibling) |
| `ValueTemporaryRecordsMaterializeAndCleanup` | `Build()==0` (`struct FValue().Value`) |

Use **these** as the first isolated VM-trace carriers **after** 1070, or even during 1070 as must-stay-green. Do not require mutation `Build()==0` until 1107 is gone on PropertyReadWrite / ForLoop. Do not require `IndexCompoundAssign` `Build()==0` in the 1070 bite — Entry mutation can still fail later (OpaqueValue steal / write-through) after `opIndex`’s `return Value` binds.

Other `DumpSealedCanonicalAst` compile→seal methods fail Generate for **non-5.4** reasons (do not fold into 1070 or OpaqueValue): Break/Fallthrough `code=-3` (`EmitStmt` `default:` switch/break kinds); `EnumParamOnCompileSealPathInternsEnumKind` `asNO_MODULE`. Parser incomplete methods dump because parse never finished.

---

## 4. Isolated VM traces 5.4 still needs

Task 5.4 text: *“Prove side-effect trace parity in separate legacy/canonical Engines.”*

Today `AngelscriptNativeCanonicalASTVmMatrixTests.cpp` `FScopedNativeModule` → `BuildNativeModule` on the engine **default**. Default is LEGACY (`as_scriptengine.cpp` `canonicalCompilerPipeline = false`). `PropertyRewriteAndMutationSingleEvaluation` / `RunSingleEval` (`MakeBox().Stored += 3`) is **`asCCompiler` Bytecode**. That is not AST-driven CodeGen. Do not check 5.4 from that method.

Need **two isolated Engines**, same inline source, `Trace(...)` (existing `RegisterCanonicalExecutionTrace`; **no** mutable script global — `ConstGlobalTraitAndMutableReject`):

| Trace | Source shape | LEGACY engine | CANONICAL engine |
| --- | --- | --- | --- |
| Short-circuit | `Mark(1) == 0 && Mark(9)` → trace `"1"` | `asCCompiler` (VmMatrix already) | `SetCompilerPipeline(CANONICAL)` + `Generate`. Parent intern already `Build()==0` |
| Conditional | `Flag ? Mark(1) : Mark(2)` + mismatched-arm Conversion | `asCCompiler` | CANONICAL `Generate`. SemaAuthority Conditional already `Build()==0` |
| Temporaries | `struct FValue().Value` ctor/dtor / Trace in ctor | `asCCompiler` | CANONICAL `Generate`. `ValueTemporaryRecordsMaterializeAndCleanup` already `Build()==0` |
| Property mutation | `Make().Value += 1` with Trace in Make/Get/Set | `asCCompiler` | CANONICAL `Generate` **after** 1107 gone + OpaqueValue memo + Get/Set through OV |
| Index mutation | `Make()[0] += 1` with Trace in Make/opIndex | `asCCompiler` | CANONICAL `Generate` **after** 1107 + memo + **write-through** Index ref |
| Receiver-once | `MakeBox().Stored += 3` (VmMatrix `RunSingleEval` shape) | keep LEGACY row | new CANONICAL row; do not retcon the old method |

File: add methods (or a sibling test file) under `AngelScriptSDK/Compiler/CanonicalAST/Semantics/`. Do not weaken VmMatrix LEGACY asserts. CANONICAL rows must `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` on **that** Engine only.

ProductionCodeGen named 9.5/F1–F5 slices are **not** these traces. Do not grow 9.5 to fake 5.4. Do not mix 1070 into the live F4 `insertLast` UBT.

---

## 5. Gate and shared files

**Gate: F4 native GREEN**, then **B-54-1070-declref** (`wave-b-54-1070-next.md`). F5 Param/Enumerator also edits `as_sema.cpp` — sequential exclusive, never a second UBT agent. If F5 already holds the mutex, 1070 waits. This file’s recommended Generate bite is **1070 lookup**, not F5, not OpaqueValue.

B-56-body-owner is already GREEN. Shared files with body-owner: none for 1070.

| File | 1070 lookup | Later OpaqueValue / mutation |
| --- | --- | --- |
| `as_parser.cpp` ParseClass VAR `NotifySema`; ParseFor init `NotifySema` | **yes** (intern order) | no |
| `as_sema.cpp` `ActOnDeclRefExpr` | **keep** fileID split; bind hits to real decls | no |
| `as_sema_expr.cpp` `InternParsedDeclRef` FindExisting | **only** skip reuse of DECL_REF with invalid `resolvedDecl` — **not** full-span | later: opaque Sequence steal |
| `as_sema_decl.cpp` `AttachParsedFunctionBody` | **no** unless proven BLOCK reuse blocks rebind (prefer intern-order) | no |
| `as_bytecode_codegen.cpp` | **no** | **yes** — OpaqueValue memo, ObjectTypeFromExpr unwrap, Index assign write-through |
| SemaAuthority tests | yes — `Build()==0` on PropertyReadWrite / ForLoop | later — mutation `Build()==0` + isolated traces |

Do **not** globally change `FindExistingExpr` to full-span (Term lesson). Do **not** require CALL `resolvedDecl` on unsealed `asCASTVerify`. Do **not** edit `as_sema.cpp` miss handling so parser-range true misses become ERROR.

---

## 6. Hard nos

- Check **5.4** from dump GREEN / SemaAuthority **227/227** / prefix green / prod3 value-object GREEN.
- Check **13.2**. This is still not a Sema environment.
- Mix 1070 into live exclusive UBT **F4 native insertLast**.
- Mix OpaqueValue memo / mutation write-through / isolated VM traces into the 1070 bite.
- Default `canonicalCompilerPipeline = true`.
- CANONICAL `CompileFunction` (F2 stays mixed COMPILER).
- Script `funcdef` / `@` / `is`. Invent `dictionary`. Mutable script globals as trace counters. C labeled break.
- Invent stmt-level cleanup-plan POD.
- Second UBT in `D:\as-cta`.
- CALL-without-callee as a seal/verifier firewall.
- Wave E–G. Archive. Commit unless asked.
- Clang/LLVM link. Unreal types in fork frontend files.
- Search every class from the TU to bind `Value`.
- Diagnose parser-range class-member / for-init as `unresolved-identifier:` (prod2 regression).

---

## 7. Exclusive UBT order (not now)

After F4 native GREEN (ProductionCodeGen **33/33**), **one** next Generate exclusive:

0. **`wave-b-54-1070-next.md` — class-member / for-init lookup.** Bind `return Value` / for-init `i` to live VAR/PROPERTY. SemaAuthority `Build()==0` on PropertyReadWrite + ForLoop. No OpaqueValue. No insertLast. No F5 Param/Enumerator in the same bite.
1. Re-read `Canonical CodeGen failed code=1 line=` on those fixtures after that GREEN (line may move).
2. Isolated LEGACY vs CANONICAL traces for **already `Build()==0`** fixtures: Logical, Conditional, `struct FValue` temporaries.
3. OpaqueValue eval-once memo + ObjectTypeFromExpr unwrap in `as_bytecode_codegen.cpp` (children IDs only).
4. If mutation dump still steals postfix Sequence: `as_sema_expr.cpp` intern of `literal=opaque` without FindExisting `seq` bag. Keep dump methods; add `Build()==0` only when Generate no longer prints 1107 **and** Entry’s stmt is the mutation Sequence.
5. Index/property write-through; then isolated mutation traces.

Leftover `ActOnParsedExpr` `default` recovery does not unblock 1107 or OpaqueValue memo.

TDD. One UBT user. `RunBuild.ps1 -NoXGE` then SemaAuthority + CanonicalAST Semantics / ProductionCodeGen as regression. Never All. Never flip the default. **5.4 / 13.2 stay `[ ]` until isolated canonical Generate traces exist for the rows in §4**, not when dump tokens print, not when 1107 is gone on PropertyReadWrite alone.

---

## Done means (this attachment)

§1 matches live F4 `ActOnDeclRefExpr` (`:680-737`) and live `EmitDeclRef` (`:1102-1108`). Dump plan stays landed. `tasks.md` 5.4 / 13.2 stay `[ ]`. Next exclusive Generate UBT is `wave-b-54-1070-next.md`.
