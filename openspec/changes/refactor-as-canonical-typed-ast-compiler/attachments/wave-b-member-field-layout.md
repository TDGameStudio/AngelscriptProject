# Wave B research — MemberRef field layout (Clang FieldDecl vs CodeGen index)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-member-field-layout**. **Research only.** No UBT. No `Plugins/` / `tasks.md` / `async-work.md` / `async-dispatch.md` edits.

LLVM/Clang is **shape only**. Quote `Reference/llvm-project` as layout analogues, not ports. Do not link.

This file is **not** a 13.2 / 5.4 / 9.5 close. Exclusive UBT is `wave-b-member-exec.md` (Sequence lhs / execute 42). Do not implement that here. Do **not** restore `GetFirstProperty` as the MemberRef path.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Research-only map for the **next** mutex after MemberRef execute, and a file:line aid if exclusive proves index/offset wrong. |
| LLVM | `D:\as-cta\Reference\llvm-project` (present). Shape analogue only. |
| Live | Dump `callee=FProdFields::Stored` GREEN. Execute **got=0**. `PropertyFromFieldDecl` maps DECL_VAR child index → `objType->properties[index]`. |
| Sema `GetFirstProperty` | **none** under `as_sema*.cpp`. |

---

## 1. Clang shape (do not link)

Clang does **not** store a byte offset on `MemberExpr`. Sema binds a **decl pointer**. Layout lives on record-layout tables keyed by that `FieldDecl*`. This fork stores `asCExpr::resolvedDecl` plus `literal` (the member name) and has **no** offset integer on `asCDecl` / `asCExpr`.

### 1.1 Sema: name lookup → `MemberExpr` holds `FieldDecl*`

`ActOnMemberAccessExpr` is the parser action. It decomposes the unqualified id and calls `BuildMemberReferenceExpr`. It does not compute layout.

```1686:1726:D:\as-cta\Reference\llvm-project\clang\lib\Sema\SemaExprMember.cpp
ExprResult Sema::ActOnMemberAccessExpr(Scope *S, Expr *Base,
                                       SourceLocation OpLoc,
                                       tok::TokenKind OpKind, CXXScopeSpec &SS,
                                       SourceLocation TemplateKWLoc,
                                       UnqualifiedId &Id, Decl *ObjCImpDecl) {
  // ...
  ExprResult Res = BuildMemberReferenceExpr(
      Base, Base->getType(), OpLoc, IsArrow, SS, TemplateKWLoc,
      FirstQualifierInScope, NameInfo, TemplateArgs, S, &ExtraArgs);
  // ...
  return Res;
}
```

After lookup, a non-static data member is a `FieldDecl`. Sema materializes the field reference from **that pointer**, not from “Nth child of the record”:

```1049:1053:D:\as-cta\Reference\llvm-project\clang\lib\Sema\SemaExprMember.cpp
  if (FieldDecl *FD = dyn_cast<FieldDecl>(MemberDecl)) {
    if (ConvertBaseExprToGLValue())
      return ExprError();
    return BuildFieldReferenceExpr(BaseExpr, IsArrow, OpLoc, SS, FD, FoundDecl,
                                   MemberNameInfo);
```

`BuildFieldReferenceExpr` (`SemaExprMember.cpp:1760–1847`) derives the **type** of the member (CVR from base, mutable, bit-field object kind) and then:

```1844:1847:D:\as-cta\Reference\llvm-project\clang\lib\Sema\SemaExprMember.cpp
  return BuildMemberExpr(
      Base.get(), IsArrow, OpLoc, SS.getWithLocInContext(Context),
      /*TemplateKWLoc=*/SourceLocation(), Field, FoundDecl,
      /*HadMultipleCandidates=*/false, MemberNameInfo, MemberType, VK, OK);
```

The AST node is identity, not offset:

```3370:3376:D:\as-cta\Reference\llvm-project\clang\include\clang\AST\Expr.h
  /// Base - the expression for the base pointer or structure references.  In
  /// X.F, this is "X".
  Stmt *Base;

  /// MemberDecl - This is the decl being referenced by the field/member name.
  /// In X.F, this is the decl referenced by F.
  ValueDecl *MemberDecl;
```

```3443:3447:D:\as-cta\Reference\llvm-project\clang\include\clang\AST\Expr.h
  /// Retrieve the member declaration to which this expression refers.
  ///
  /// The returned declaration will be a FieldDecl or (in C++) a VarDecl (for
  /// static data members), a CXXMethodDecl, or an EnumConstantDecl.
  ValueDecl *getMemberDecl() const { return MemberDecl; }
```

`FieldDecl` caches a **field index** for `ASTRecordLayout::getFieldOffset`. That index is the record’s field ordinal, computed from the canonical decl, not a name walk at emit time:

```3243:3252:D:\as-cta\Reference\llvm-project\clang\include\clang\AST\Decl.h
  /// Returns the index of this field within its record,
  /// as appropriate for passing to ASTRecordLayout::getFieldOffset.
  unsigned getFieldIndex() const {
    const FieldDecl *Canonical = getCanonicalDecl();
    if (Canonical->CachedFieldIndex == 0) {
      Canonical->setCachedFieldIndex();
      assert(Canonical->CachedFieldIndex != 0);
    }
    return Canonical->CachedFieldIndex - 1;
  }
```

```199:203:D:\as-cta\Reference\llvm-project\clang\include\clang\AST\RecordLayout.h
  /// getFieldOffset - Get the offset of the given field index, in
  /// bits.
  uint64_t getFieldOffset(unsigned FieldNo) const {
    return FieldOffsets[FieldNo];
  }
```

Shape analogue: Clang’s Sema fact is **which FieldDecl**. Offset is a later lookup through a layout object that already knows that decl. The index on `FieldDecl` is a sealed ordinal into **that** layout table, not “count sibling named nodes at CodeGen”.

### 1.2 CodeGen: `EmitLValueForField` uses layout keyed by `FieldDecl*`

```5517:5544:D:\as-cta\Reference\llvm-project\clang\lib\CodeGen\CGExpr.cpp
LValue CodeGenFunction::EmitLValueForField(LValue base, const FieldDecl *field,
                                           bool IsInBounds) {
  LValueBaseInfo BaseInfo = base.getBaseInfo();

  if (field->isBitField()) {
    const CGRecordLayout &RL =
        CGM.getTypes().getCGRecordLayout(field->getParent());
    const CGBitFieldInfo &Info = RL.getBitFieldInfo(field);
    // ...
        unsigned Idx = RL.getLLVMFieldNo(field);
        // ...
            Addr = Builder.CreateStructGEP(Addr, Idx, field->getName());
```

Non-bit-field structs GEP via the **LLVM field number** for that `FieldDecl*`:

```5469:5482:D:\as-cta\Reference\llvm-project\clang\lib\CodeGen\CGExpr.cpp
static Address emitAddrOfFieldStorage(CodeGenFunction &CGF, Address base,
                                      const FieldDecl *field, bool IsInBounds) {
  if (isEmptyFieldForLayout(CGF.getContext(), field))
    return emitAddrOfZeroSizeField(CGF, base, field, IsInBounds);

  const RecordDecl *rec = field->getParent();

  unsigned idx =
    CGF.CGM.getTypes().getCGRecordLayout(rec).getLLVMFieldNo(field);

  if (!IsInBounds)
    return CGF.Builder.CreateConstGEP2_32(base, 0, idx, field->getName());

  return CGF.Builder.CreateStructGEP(base, idx, field->getName());
}
```

Called from `EmitLValueForField` at `CGExpr.cpp:5654`. TBAA bit-offset uses `ASTRecordLayout::getFieldOffset(field->getFieldIndex())` at `CGExpr.cpp:5598–5603`. The LLVM element index is a `DenseMap<FieldDecl*, unsigned>`:

```200:206:D:\as-cta\Reference\llvm-project\clang\lib\CodeGen\CGRecordLayout.h
  /// Return llvm::StructType element number that corresponds to the
  /// field FD.
  unsigned getLLVMFieldNo(const FieldDecl *FD) const {
    FD = FD->getCanonicalDecl();
    assert(FieldInfo.count(FD) && "Invalid field for record!");
    return FieldInfo.lookup(FD);
  }
```

Clang CodeGen never does “walk record children named `Stored` and take the second VAR”. It never does `GetFirstProperty(name)`.

### 1.3 This fork’s analogue today

| Clang | This fork (live) |
| --- | --- |
| `ActOnMemberAccessExpr` → `BuildFieldReferenceExpr(FieldDecl*)` | `asCSema::ActOnMemberExpr` (`as_sema_expr.cpp:1245`) intern native properties, `ActOnMemberRef` + `SetResolvedDecl` |
| `MemberExpr::MemberDecl` (`ValueDecl*`) | `asCExpr::resolvedDecl` (`as_expr.h:20`) |
| Member spelling is separate from the decl | `asCExpr::literal` is the name (`ActOnMemberRef` `as_sema.cpp:913–917` passes `name` as literal) |
| `FieldDecl` + `ASTRecordLayout` / `CGRecordLayout` | **No** offset/index on `asCDecl` (`as_decl.h:13–38` has name, type, children, traits — no integer layout field) |
| CodeGen `EmitLValueForField(FieldDecl*)` | `EmitMember` / `EmitMemberStore` call `PropertyFromFieldDecl` then `prop->byteOffset` for `ADDSi` |

Fork intern of the field:

```1245:1276:D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_sema_expr.cpp
asASTExprId asCSema::ActOnMemberExpr(asASTExprId base, const char* name, const asCSourceRange& range)
{
	// TryRewritePropertyGet first (generated Get). Else:
	InternNativeProperties(*this, engine, context, baseExpr->type);
	member = FindTypeMemberVar(context, FindNamedTypeDecl(context, baseExpr->type), name);
	const asASTExprId id = ActOnMemberRef(base, name ? name : "", fieldType, range);
	if( member.IsValid() )
	{
		context.SetResolvedDecl(id, member);
	}
	return id;
}
```

`FindTypeMemberVar` (`as_sema_expr.cpp:392–408`) matches **name** among `DECL_VAR` children. That is still a name walk at intern time. The sealed fact after intern is `resolvedDecl` → that `DECL_VAR`. Dump `callee=FProdFields::Stored` is that fact. CodeGen must consume it as identity, then a **layout integer**, not reconstruct layout by recounting siblings.

Do not link Clang/LLVM. Do not port `CGRecordLayout`.

---

## 2. Live `GetFirstProperty` remainder

Search of fork `ThirdParty/angelscript/source`: Sema (`as_sema.cpp`, `as_sema_expr.cpp`, `as_sema_decl.cpp`, `as_sema_stmt.cpp`) has **zero** `GetFirstProperty` calls.

`as_bytecode_codegen.cpp` has **two**. `EmitMember` / `EmitMemberStore` / `FindThisProperty` do **not** call it (they use `PropertyFromFieldDecl`). Do not restore `GetFirstProperty` there.

| File:line | Function | Classification | This mutex |
| --- | --- | --- | --- |
| `as_bytecode_codegen.cpp:1051` | `EmitGeneratedAccessor` | **Generated accessor body** (allowed). `Generate` of a `DECL_METHOD` with `asAST_TRAIT_GENERATED` and no body (`:740–743`) strips `Get`/`Set` prefix and looks up `func->objectType->GetFirstProperty(propName)`. Uses `prop->byteOffset` for `ADDSi`. | **Keep** until a later sealed-field mutex. Do not expand. |
| `as_bytecode_codegen.cpp:2427` | `EmitCall` | **FindFunc-miss inline** of generated Get. When `FindFunc(expr->resolvedDecl)` is null and the callee decl is `TRAIT_GENERATED` `DECL_METHOD` named `Get*`, emit inlines `objType->GetFirstProperty(propName)` instead of CALLSYS. | **Forbidden to expand.** Next mutex after MemberRef execute (async-work §6 item 1). Not user MemberRef. |
| `as_bytecode_codegen.cpp:2061` / `:2097` | `EmitMember` / `EmitMemberStore` | User MemberRef emit. `PropertyFromFieldDecl(GetDecl(resolvedDecl))`. **No** `GetFirstProperty`. | Keep. Do **not** restore name lookup. |
| Sema | — | None. | — |

`GetFirstProperty` definition (`as_objecttype.h:274–289`) is a **name** hash lookup on `propertyTable` (plus `shadowType` walk). That is the opposite of a sealed field record. Restoring it on MemberRef would make `Poison`/`Stored` dumps a lie if they ever shared a name, and would hide a wrong `resolvedDecl`.

Other repo hits (`as_compiler.cpp`, `as_builder.cpp`, Runtime binds, StaticJIT) are LEGACY / engine, not CANONICAL CodeGen/Sema.

Generated-Get fail-closed (delete `:2427` inline) is the **next** exclusive after MemberRef execute. This research must not start it.

---

## 3. Why `PropertyFromFieldDecl` index is not a sealed field record

```2901:2931:D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_bytecode_codegen.cpp
		asCObjectProperty* PropertyFromFieldDecl(const asCDecl* target, asCObjectType* objType) const
		{
			if( target == 0 || target->kind != asAST_DECL_VAR || objType == 0 )
			{
				return 0;
			}
			const asCDecl* parent = context.GetDecl(target->parent);
			// parent must be CLASS / INTERFACE
			int varIndex = 0;
			for( asUINT i = 0; i < parent->children.GetLength(); ++i )
			{
				const asCDecl* child = context.GetDecl(parent->children[i]);
				if( child == 0 || child->kind != asAST_DECL_VAR )
				{
					continue;
				}
				if( child->id == target->id )
				{
					if( varIndex >= 0 && (asUINT)varIndex < objType->properties.GetLength() )
					{
						return objType->properties[varIndex];
					}
					return 0;
				}
				++varIndex;
			}
			return 0;
		}
```

This is **ordinal coincidence**: interned `DECL_VAR` sibling index must equal `asCObjectType::properties[]` index. It is not `FieldDecl*` → layout table. It does not read `byteOffset` from the decl. Extra interned VARs shift Stored onto Poison (or OOB → null → `asNOT_SUPPORTED`).

Engine `properties[]` is registration / inheritance order:

- Native: `RegisterObjectProperty` `as_scriptengine.cpp:1728` `PushLast` (Poison then Stored on the fixture).
- Script: `asCObjectType::AddPropertyToClass` `as_objecttype.cpp:664`.
- Derived copies base properties first (`as_builder.cpp:4202`).

`InternNativeProperties` (`as_sema_expr.cpp:410–448`) walks `objectType->properties[p]` and `ActOnVarDecl`s each named property if `FindTypeMemberVar` misses. Empty names are **skipped** (`:436–438`) and do **not** intern a VAR, but they **remain** in `properties[]`. A nameless slot would desynchronize interned VAR count vs `properties[index]`.

### 3.1 Failing fixture dump (H4 weak for got=0)

`CanonicalNativeMemberRefUsesSealedFieldNotFirstProperty` registers Poison first, Stored second (`AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp:3061–3070`). Live dump (`async-work.md` §4 / `wave-b-member-exec.md` §2):

```text
DECL id=5 kind=Var name=Poison parent=4 key=FProdFields::Poison
DECL id=6 kind=Var name=Stored parent=4 key=FProdFields::Stored
DECL id=7 kind=Constructor name=$beh0 parent=4 key=FProdFields::$beh0()
```

`asCASTDump` prints decls by id (`as_ast_dump.cpp:166`), which is intern order. Class children that are VAR are only Poison then Stored. `$beh0` is `DECL_CONSTRUCTOR`, skipped by `PropertyFromFieldDecl`. For this fixture, `Stored` → `varIndex == 1` → `properties[1]` is Stored. **Index mapping is not the lead for got=0.** H1 Sequence lhs is.

### 3.2 Do other fixtures intern methods as VAR?

**No. Methods intern as METHOD (or MIXIN / CONSTRUCTOR), not VAR.**

| Intern path | Kind | Evidence |
| --- | --- | --- |
| `InternNativeMethods` | `ActOnMethodDecl` `as_sema_expr.cpp:534` | Native methods |
| `InternNativeBehaviourList` | `ActOnConstructorDecl` `:719` | `$beh0` / factories as Constructor |
| `EnsureGeneratedAccessors` | `ActOnMethodDecl` Get/Set `as_sema_decl.cpp:788–794` | Script `class T { int Value; }` dump `kind=Method name=GetValue` / `SetValue` (`SemaAuthority` ~1220), traits generated |
| Parser `snFunction` under class | `ActOnFunctionLike` → Method | Frontend `class FBase { int Method(int Arg) }` dump `kind=Method name=Method` (`AngelscriptNativeCanonicalASTSemaTests.cpp:110`) |
| Mixin | `asAST_DECL_MIXIN` | Dump `kind=Mixin`; `ActOnMixinDecl` `as_sema.cpp:489` |
| Enumerators | `ActOnVarDecl` **under enum** | `kind=Var name=Red` parent enum, not class (`ActOnStartEnumeratorDecl` `as_sema.cpp:470`) |
| `ActOnPropertyDecl` | `DECL_PROPERTY` | Separate kind. `PropertyFromFieldDecl` ignores it. `FindTypeMemberVar` only `DECL_VAR` (`as_sema_expr.cpp:402`). |

So a Method / Constructor / Mixin / Property sibling **does not** shift `varIndex`. The shift hazard is **extra `DECL_VAR` on the same class**:

- Script class fields via WalkOne `snDeclaration` → `ActOnStartVarDecl` (`as_sema_decl.cpp:1449–1469`) — intended VARs, must stay aligned with `properties[]`.
- Dummy / generated VAR: `ActOnListPatternDecl` intern `name=list-pattern` `DECL_VAR` (`as_sema_decl.cpp:1713`) if parent were a class (today used as structured-init helper; parent is typically the construct/function, not the native type).
- Lazy intern: `InternNativeProperties` runs on **first MemberRef**, after `ActOnConstruct` may already have interned `$beh0` (Constructor — harmless) or after some other path interned a VAR.
- Skip of empty-name `properties[p]` vs full `properties[]` index.
- Inherited copies in `properties[]` vs intern that skipped already-named children (`:440–443`): skip keeps interned order if the existing VAR was interned in engine order; intern of a **different** dummy VAR first would still shift.

H4 remains a **real future bug**, not the current execute-0 diagnosis.

---

## 4. Later sealed field fact (do not implement)

`asCDecl` has no layout integer. `asCObjectProperty::byteOffset` already exists at intern time (`InternNativeProperties` holds `prop`). CodeGen already emits `ADDSi` from `prop->byteOffset`.

**Recommendation (one):** intern **`byteOffset`** onto the `DECL_VAR` at `InternNativeProperties` (`as_sema_expr.cpp:433–447`), dump it, CodeGen `EmitMember` / `EmitMemberStore` / `FindThisProperty` consume that integer (fail-closed if missing / `-1`). Optionally dump the **engine** `properties[]` index as a second identity token; do **not** keep sibling-count as the consumer.

Why byteOffset over “keep index and intern properties before any other DECL_VAR”:

- Clang analogue is layout keyed by the field identity, not a process invariant on intern order.
- Intern order is already lazy (first MemberRef), not “class intern then properties then everything else”. Exclusive UBT must not wait for a global intern-order freeze.
- Empty-name skip, inherited copies, list-pattern, and future dummy VARs break sibling index even if methods stay METHOD.
- `GetFirstProperty` by name is **not** the MemberRef path (forbidden restore).

What this mutex must **not** do: add the field, change `PropertyFromFieldDecl`, or block Sequence-lhs unwrap on a layout redesign.

Exclusive UBT (`wave-b-member-exec.md`) uses current `PropertyFromFieldDecl` after unwrapping Assign lhs to `MEMBER_REF`. Index is correct on FProdFields. Layout sealing is the mutex **after** generated-Get fail-closed, or the same later mutex if execute 42 still shows a wrong `ADDSi` (H4).

---

## 5. Sequence lhs (exclusive UBT H1 — quote only)

Plain `=` does **not** unwrap Sequence. After property-Set rewrite miss, it `ActOnAssign`s the original lhs:

```1232:1242:D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_sema_expr.cpp
	asCQualType fallback = context.InternPrimitive(ttInt, 0);
	const asASTExprId rewritten = TryRewritePropertySet(*this, context, lhs, rhs, fallback, range);
	if( rewritten.IsValid() )
	{
		return rewritten;
	}
	if( !lhs.IsValid() )
	{
		return asASTExprId();
	}
	return ActOnAssign(lhs, rhs, fallback, range);
```

`+=` **does** unwrap Sequence / Materialize / Cleanup before Index / Get rewrite:

```1130:1151:D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_sema_expr.cpp
	if( addAssign )
	{
		asASTExprId target = lhs;
		for( ;; )
		{
			const asCExpr* wrap = context.GetExpr(target);
			if( wrap == 0 )
			{
				break;
			}
			if( wrap->kind == asAST_EXPR_SEQUENCE && wrap->children.GetLength() > 0 )
			{
				target = wrap->children[wrap->children.GetLength() - 1];
				continue;
			}
			if( (wrap->kind == asAST_EXPR_MATERIALIZE_TEMPORARY || wrap->kind == asAST_EXPR_CLEANUP)
				&& wrap->children.GetLength() > 0 )
			{
				target = wrap->children[0];
				continue;
			}
			break;
		}
```

`TryRewritePropertySet` already unwraps Sequence (`as_sema_expr.cpp:214–218`). `EmitAssign` does not. MemberRef store is only when `lhs->kind == MEMBER_REF` (`as_bytecode_codegen.cpp:1810–1813`). Else fallthrough:

```1836:1838:D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_bytecode_codegen.cpp
			const int dest = EmitExpr(expr->children[0]);
			CopyVar(dest, rhs, dwords > 0 ? dwords : 1);
			return dest;
```

`EmitExpr` SEQUENCE (`:1445–1471`) emits the last child (MemberRef **load**). CopyVar then writes 41 into the load temp, not `Object.Stored`. That is exclusive UBT H1. Do not edit CodeGen in this package.

Dump already shows Sequence wrapping MemberRef `callee=Stored` beside Assign. Sema intern is not the execute-0 fix.

---

## Out of scope

- 13.2 / 5.4 / 9.5 checkboxes.
- Linking Clang/LLVM.
- Restoring `GetFirstProperty` on `EmitMember` / `EmitMemberStore` / `FindThisProperty`.
- Generated-Get fail-closed (`EmitCall:2427`) — queued after this exclusive UBT.
- Implementing `byteOffset` on `asCDecl`.
