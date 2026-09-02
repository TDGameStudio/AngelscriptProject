# Wave B exclusive UBT — B-eighth-f4-native (`insertLast` RankArgument)

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:test-driven-development` then `superpowers:systematic-debugging` if ProductionCodeGen stays RED, then `superpowers:verification-before-completion` before claiming GREEN. One exclusive UBT. Do **not** check `tasks.md` 13.2 / 4.2 / 5.4 / 5.6 / 9.5.

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
Companions: `attachments/async-work.md` §4 Hole 1; `attachments/async-dispatch.md`; `attachments/wave-b-eighth-f3-f4-next.md` (F3 landed, F4 intern tests landed); `attachments/eighth-pass-verified.md`.

---

## Goal

CANONICAL `array<int> Values; Values.insertLast(41); return Values[0] + 1;` **Builds and executes 42** from CodeGen after F4 fail-closed intern, **without** restoring script same-arity fallback.

Script F4 intern already GREEN (SemaAuthority **227/227** `wave-b-eighth-f4-sema2`). Do not redo F3. Do not rewrite F4 tests weaker.

## Architecture

```text
Values.insertLast(41)          receiver type = array<int> (TEMPLATE)
InternNativeMethods            FromDataType(const T&in) intern named "T"
FindBestCallee / RankArgument  QualTypesMatch is type-id equality
                               T vs int → -1 → miss → unresolved-callee:insertLast
                               SealCanonicalAST fail-closed → Build != 0

F4 script contract (keep):
  member FindBestCallee miss
    → native-intern fileID==0 same-arity only (written, unverified)
    → fall through mixin MixHelper(T,int) with full args (receiver included)
    → NEVER bind script Get(bool) or free Get(int) from v.Get(3)

Preferred bind for insertLast:
  1. Verify already-written native fileID==0 same-arity (ActOnMethodDecl empty range).
  2. If still RED: RankArgument instantiate host template parameter T against
     the receiver's template instance (array<int> → int), not a second same-arity
     walk over script methods.
```

Clang/LLVM is a **shape** reference only (template specialization matches instantiated args). No link. No Unreal types in fork frontend files.

## Global constraints

- Default pipeline stays **LEGACY**. CANONICAL is per-Engine in these tests only.
- `CompileFunction` stays mixed **COMPILER**.
- Script `class` is REF + implicit handle; `struct` is VALUE. Do not reverse sixth-pass runtime flags.
- Do not invent script `funcdef` / `@` / `is`. Host `RegisterFuncdef` remains legal.
- Unsealed `asCASTVerify` must still succeed on legal construction graphs. Do **not** require CALL `resolvedDecl` on unsealed verify.
- No ABI matrix. No F6. No 1070 / OpaqueValue as the primary change of this UBT.
- Commands only from `D:\as-cta`. Always `-NoXGE` on `RunBuild.ps1`. `RunTests.ps1` does not UBT. Always `RunBuild.ps1` first after impl.
- Do not check **13.2 / 4.2 / 5.4 / 5.6 / 9.5**. Do not archive. Do not commit unless asked.

## Live evidence (do not guess)

ProductionCodeGen `wave-b-eighth-f4-prod3` **32/33**
`D:\as-cta\Saved\Tests\wave-b-eighth-f4-prod3\20260822_160637_363_c405d9a0`

```text
Canonical Sema diagnostic: unresolved-callee:insertLast
EXPR id=3 kind=Call type=<unresolved> literal=insertLast callee=
     receiver=1 nargs=2 args=41,Values typeKind=Error
```

Index `Values[0]` already interned (`kind=Index type=int`). Factory Construct of `array<int>` interned. Only `insertLast` is unresolved.

SemaAuthority `wave-b-eighth-f4-sema2` **227/227** (Mixin recovered by full-args fall-through).

CanonicalAST `wave-b-eighth-f4-canonical2` **270/276** (value-object `unresolved-identifier:Value` + array). Parser-range DeclRef recovery then made ProductionCodeGen value-object tests GREEN (`prod3` only array remained). CanonicalAST was **not** re-run after that recovery.

Native-intern same-arity in `ResolveCallee` (`fileID == 0`) is **in the source, written after prod3, never built**.

```493:498:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp
						if( child && child->kind == asAST_DECL_METHOD && child->name.Equals(name)
							&& child->range.begin.fileID == 0
							&& CountParams(context, child) == withoutReceiver.GetLength() )
						{
							return child->id;
						}
```

`RankArgument` (`:1212-1240`) returns `-1` unless QualTypesMatch or int↔float.

## File map

| Path | This UBT |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | `ResolveCallee` native fileID==0 (already written) and/or `RankArgument` template instantiate |
| `as_sema.cpp` / `as_parser.cpp` / `as_bytecode_codegen.cpp` / verifier | **do not edit** unless a proven one-line interaction; prefer Sema expr only |
| Tests | Existing `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` + F4 SemaAuthority methods. Add a SemaAuthority lock only if RankArgument instantiate needs a dump oracle beyond ProductionCodeGen |

## Must stay green (do not weaken)

| Test | Contract |
| --- | --- |
| `MemberSameArityTypeMismatchDoesNotBindFirstMethod` | `v.Get(3)` no `callee=T::Get(bool)`, no `callee=Get(int)`, `unresolved-callee:` |
| `MemberAmbiguousOverloadDoesNotBindFirstSameArity` | no first `T::Get(int,float)` |
| `MixinCallBindsReceiverNotFreeGlobal` | `v.MixHelper(3)` binds mixin, not a free global |
| `UnresolvedCallMissingIsErrorTypeNotInt` | ERROR `<unresolved>`, unsealed verify OK |
| `UnresolvedDeclRefMissingIsErrorTypeNotInt` | construction-API empty range ERROR |
| `UnresolvedCallDoesNotPublishFakeIntSuccess` | CANONICAL Build `!= 0` for `Missing()` |
| `ClassTemporaryConstructInternsReferenceObjectNotValueObject` | F3 |
| `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` | F1 dump |
| ProductionCodeGen class/struct flags | sixth-pass runtime flags |

---

### Task 1: Build current tree (fallback already written)

- [ ] **Step 1: Build**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-eighth-f4-native -NoXGE -TimeoutMs 1800000
```

Expected: build OK. CAEngine `UE4Editor`/`MSBuild`/`link` on this machine is **not** this lock.

- [ ] **Step 2: ProductionCodeGen**

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-eighth-f4-prod4 -TimeoutMs 600000
```

Expected GREEN: **33/33**. If RED only on `CanonicalArrayIntBuildPublishesCodeGenAndExecutes`, go to Task 2. If other tests fail, systematic-debug those first (do not restore script same-arity).

- [ ] **Step 3: If prod4 is 33/33, lock prefixes**

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-eighth-f4-sema3 -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-eighth-f4-canonical3 -TimeoutMs 600000
```

Expected: SemaAuthority **227/227** (or live total). CanonicalAST full prefix 0 failed (total will be 275 or 276). Frontend optional if time; not required to close this UBT.

Do **not** run All.

### Task 2: If insertLast still unresolved — diagnose, then instantiate T

- [ ] **Step 4: Read the failed dump** in `Saved\Tests\wave-b-eighth-f4-prod4\*\Automation.log`. Confirm whether:

  1. `InternNativeMethods` interned `insertLast` as a METHOD child of the `array<int>` classDecl (`kind=Method` in dump).
  2. That METHOD `range.begin.fileID` is 0.
  3. `CountParams` equals 1 (`withoutReceiver` length).
  4. `FindNamedTypeDecl` found the class (otherwise the native same-arity walk never runs).

Likely remaining causes if fallback misses:

- `objectType == 0` in `InternNativeMethods` (`Resolve` of `array<int>` QualType fails) → no METHOD interned.
- `FindNamedTypeDecl` misses TEMPLATE `array<int>` → walk never runs.
- RankArgument still required because fileID is not 0 (parser later attached a range).

- [ ] **Step 5: Minimal fix (pick one, smallest)**

**Preferred if METHOD is interned but RankArgument rejects T vs int:** extend `RankArgument` so a host template parameter (`stableKey` `T` / template subtype of the callee's object type) matches the **instantiated** argument type of the receiver. `array<int>` + `const T&in` + arg `int` → rank 2 (or 1 if reference/const differ only in quals — QualTypesMatch currently ignores quals and compares `type.value` only).

Do **not** make `RankArgument` treat any same-name type as int. Do **not** rank `bool` vs `int` as a match (keeps `Get(bool)` fail-closed).

**Acceptable if METHOD is interned, fileID==0, CountParams matches, and FindNamedTypeDecl missed:** fix `FindNamedTypeDecl` for TEMPLATE `array<int>` so the existing native walk runs. Do not restore script same-arity.

**Forbidden:** walk script methods (`fileID != 0`) by name+count. Weaken ProductionCodeGen to not require insertLast. Bind free `insertLast`.

- [ ] **Step 6: Rebuild and re-run Task 1 steps 2–3**

Same labels with a suffix (`prod5` / `sema4` / `canonical4`) if prod4 already exists.

### Task 3: Record, do not commit

- [ ] **Step 7: Record**

Append `## B-eighth-f3-construct-type` (if missing) and `## B-eighth-f4-fail-closed` / `## B-eighth-f4-native` to `attachments/wave-b-results.md` with RED/GREEN report paths.

Patch `eighth-pass-verified.md` F3 row landed; F4 row: script intern + array bind (or native-only same-arity remainder if RankArgument still does not instantiate T).

Leave `tasks.md` boxes `[ ]`. A one-paragraph progress note on 13.2 is allowed; do not check it.

Patch `async-dispatch.md` exclusive row to **landed** only if ProductionCodeGen **33/33** and SemaAuthority **227/227** and CanonicalAST 0 failed.

Do not commit. Do not archive. Do not start F5 / 1070 / Wave E.
