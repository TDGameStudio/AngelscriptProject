# Wave B research — InitPlan `this` ABI (PSF 0 + RDSPtr vs VM fp[0])

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-initplan-this-abi**. **Research only.** No UBT. No `Plugins/` edits.

This file is **not** a 13.2 / 5.4 / 9.5 close. Do not check those boxes because this map exists.

Companion exclusive UBT (CALL-id / execute 42): `wave-b-initplan-exec.md`. Dump bite (landed): `wave-b-initplan-next.md`. Do not edit those files from this research.

LLVM/Clang is **shape only**. Do not link. Quotes under `Reference/llvm-project` are layout analogues, not ports.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Research-only ABI map. If exclusive UBT proves H1 (Entry CALL id ≠ user ctor id), stop here. If H1 ids **match**, this file supplies H2 file:line instead of guessing `thisOffset`. |
| Live symptom | Dump GREEN: user ctor `init=` typed Assign of interned `40+1`. Execute RED: `CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody` **got=0**. |
| Do not mark | **any remaining OpenSpec box** (not 13.2 / 5.4 / 9.5) |
| Hard nos | Do not propose `thisOffset = -AS_PTR_SIZE` without showing PSF 0 is wrong. Do not propose Get-always-inline. Do not propose `atoi`. Do not intern native 0-arg / `array<T>` factories. |

---

## ABI conclusion (read this first)

**PSF 0 + RDSPtr matches VM this-at-fp[0].** It is the same convention asCCompiler uses for implicit-`this` member access on VALUE objects, and the same convention Canonical CodeGen uses for generated accessors and the GREEN generated default ctor.

Callee layout:

- After `asBC_CALL`, `PrepareScriptFunction` sets `stackFramePointer = stackPointer` (then `stackPointer -= variableSpace`). The object pointer the caller pushed last sits **at fp[0]**.
- `asBC_PSF 0` pushes **the address of that slot** (`l_fp - 0`), not the object.
- `asBC_RDSPtr` loads the pointer stored there. Null → `TXT_NULL_POINTER_ACCESS` exception. **RDSPtr-null cannot explain got=0.**
- `ADDSi` / `PopRPtr` / `WRTV4` then write the member through that object pointer.

`thisOffset = 0` is therefore the documented AngelScript method/`this` slot. `BindParameters` already places **parameters** at `-AS_PTR_SIZE` (and return-on-stack another `-AS_PTR_SIZE`). Moving `this` to `-AS_PTR_SIZE` would alias the first parameter, not fix a missed VALUE local.

If exclusive UBT already proved H1 ids match, H2 is **not** “flip `thisOffset`”. Diff generated-default-ctor vs user-ctor bytecode (and Entry `PSF dest` vs later `Object.Value` slot). See §6.

---

## 1. VM layout (`as_context.cpp`)

Paths: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp`.

### 1.1 `PrepareScriptFunction`: frame pointer then locals

```1709:1745:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp
void asCContext::PrepareScriptFunction()
{
	asASSERT( m_currentFunction->scriptData );
	asDWORD *oldStackPointer = m_regs.stackPointer;
	asUINT needSize = m_currentFunction->scriptData->stackNeeded;
	// ...
	m_regs.stackPointer = (asDWORD*)(((asPWORD)m_regs.stackPointer) & ~(16 - 1));
	if( m_regs.stackPointer != oldStackPointer )
	{
		int numDwords = m_currentFunction->totalSpaceBeforeFunction;
		memmove(m_regs.stackPointer, oldStackPointer, sizeof(asDWORD)*numDwords);
	}

	// Update framepointer
	m_regs.stackFramePointer = m_regs.stackPointer;

	// Set all object variables to 0 to guarantee that they are null before they are used
	// Only variables on the heap should be cleared. The rest will be cleared by calling the constructor
	asUINT n = m_currentFunction->scriptData->objVariablesOnHeap;
	while( n-- > 0 )
	{
		int pos = m_currentFunction->scriptData->objVariablePos[n];
		*(asPWORD*)&m_regs.stackFramePointer[-pos] = 0;
	}

	// Initialize the stack pointer with the space needed for local variables
	m_regs.stackPointer -= m_currentFunction->scriptData->variableSpace;
}
```

`asBC_CALL` (`:2000-2024`) snapshots `l_sp` then `CallScriptFunction` → `PrepareScriptFunction`. Arguments (including `this`) are already on the stack. Alignment may `memmove` `totalSpaceBeforeFunction` dwords; after that, **`this` is still at the new fp[0]**.

`asCScriptFunction::CalculateParameterOffsets` (`as_scriptfunction.cpp:696-722`): `spaceNeededForArguments` is **parameters only**; `totalSpaceBeforeFunction` adds `AS_PTR_SIZE` when `objectType != nullptr`. CodeGen `RET` does the same (`as_bytecode_codegen.cpp:755-760`: `GetSpaceNeededForArguments()` then `+ AS_PTR_SIZE` if `objectType`).

VALUE locals are **not** in `objVariablesOnHeap`. Canonical extract currently forces `objVariablesOnHeap = 0` (`as_bytecode_codegen.cpp:777`). Unconstructed VALUE memory is not VM-zeroed. got=0 can be “ctor never ran on this slot” (H1) or “writes hit a different address” (H2). It is not RDSPtr-null.

### 1.2 `asBC_PSF`: address of `l_fp - offset`

```1942:1947:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp
	// Push the address of a variable on the stack
	case asBC_PSF:
		l_sp -= AS_PTR_SIZE;
		*(asPWORD*)l_sp = asPWORD(l_fp - asBC_SWORDARG0(l_bc));
		l_bc++;
		break;
```

`PSF 0` ⇒ push `(asPWORD)l_fp`. That is a pointer **to the this-slot**, not the object.

Caller constructing an in-place VALUE local (`CallDefaultConstructor` / Canonical `EmitConstructInto`) also uses `PSF dest` **without** RDSPtr: dest **is** the object memory, so the pushed address **is** `this`.

### 1.3 `asBC_RDSPtr`: load pointer at that address (null = exception)

```2448:2465:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp
	case asBC_RDSPtr:
		{
			// The pointer must not be null
			asPWORD a = *(asPWORD*)l_sp;
			if( a == 0 )
			{
				m_regs.programPointer    = l_bc;
				m_regs.stackPointer      = l_sp;
				m_regs.stackFramePointer = l_fp;

				SetInternalException(TXT_NULL_POINTER_ACCESS);
				return;
			}
			// Pop an address from the stack, read a pointer from that address and push it on the stack
			*(asPWORD*)l_sp = *(asPWORD*)a;
		}
		l_bc++;
		break;
```

Callee member-through-this: `PSF 0` then `RDSPtr` replaces the slot-address with the object pointer stored at fp[0].

`asBC_PshVPtr` (`:2442-2446`) is the one-instruction form of “load pointer value at `l_fp - offset`”. After `PshVPtr 0` the stack already holds the object pointer; RDSPtr is **not** applied. asCCompiler uses `PshVPtr` only for the `this` **token** on REF types (§2). Implicit-this **members** still go PSF + Dereference (= RDSPtr).

### 1.4 `asBC_ADDSi` / `asBC_PopRPtr` / `asBC_WRTV4`

```3033:3050:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp
	case asBC_ADDSi:
		{
			asPWORD a = *(asPWORD*)l_sp;
			if( a == 0 )
			{
				// ... SetInternalException(TXT_NULL_POINTER_ACCESS); return;
			}
			*(asPWORD*)l_sp = a + asBC_SWORDARG0(l_bc);
		}
		l_bc += 2;
		break;
```

```2558:2562:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp
	case asBC_PopRPtr:
		*(asPWORD*)&m_regs.valueRegister = *(asPWORD*)l_sp;
		l_sp += AS_PTR_SIZE;
		l_bc++;
		break;
```

```3104:3107:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp
	case asBC_WRTV4:
		**(asDWORD**)&m_regs.valueRegister = *(l_fp - asBC_SWORDARG0(l_bc));
		l_bc++;
		break;
```

`ADDSi` null is also an exception, not got=0. `WRTV4` writes the dword at local `offset` **through** `valueRegister`. If `valueRegister` is a member address inside Object, Object.Value changes. If it is some other address, Entry still reads 0.

Win64: `AS_PTR_SIZE == 2`. The this pointer occupies `l_fp[0]` and `l_fp[1]` (higher addresses). Locals are `l_fp - positive` (lower). Parameters are `l_fp - (negative)` = higher, starting at `-AS_PTR_SIZE` = `l_fp+2`. Offset 0 does not collide with `nextLocal = 1`.

---

## 2. asCCompiler `this` for VALUE vs REF (`as_compiler.cpp` ~14662–14816)

`ThisObjectStackOffset = 0` whenever `outFunc->objectType != nullptr`. External implicit this is the only non-zero case.

```14661:14703:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp
	asCObjectType* ThisObjectType = nullptr;
	int ThisObjectStackOffset = 0;

	if (outFunc)
	{
		if (outFunc->objectType != nullptr)
		{
			ThisObjectType = outFunc->objectType;
			ThisObjectStackOffset = 0;
		}
		else if (ExternalThisType != nullptr)
		{
			ThisObjectType = ExternalThisType;
			ThisObjectStackOffset = ExternalThisOffset;
		}
	}
	// ...
			if ((ThisObjectType->flags & asOBJ_VALUE) != 0)
			{
				// The object pointer is located at stack position 0
				ctx->bc.InstrSHORT(asBC_PSF, ThisObjectStackOffset);
				ctx->type.SetVariable(dt, ThisObjectStackOffset, false);
				ctx->type.dataType.MakeReference(true);
				ctx->type.isLValue = true;
			}
			else
			{
				// The object pointer is located at stack position 0
				ctx->bc.InstrSHORT(asBC_PshVPtr, ThisObjectStackOffset);
				ctx->type.SetVariable(dt, ThisObjectStackOffset, false);
				ctx->type.isLValue = true;
			}
```

| Kind | `this` token | Comment |
| --- | --- | --- |
| VALUE | `PSF 0` + `MakeReference(true)` | Push **address of the this-slot**. Type becomes reference-to-value. |
| REF | `PshVPtr 0` | Push **pointer value** stored at fp[0] (handle). |

Implicit member through `this` (not an explicit `this` token) **always** PSF + Dereference, VALUE and REF:

```14804:14826:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp
				if( !objType )
				{
					// The object pointer is located at stack position 0
					// This is only done when accessing through the implicit this pointer
					ctx->bc.InstrSHORT(asBC_PSF, ThisObjectStackOffset);
					ctx->type.SetVariable(dt, ThisObjectStackOffset, false);
					ctx->type.dataType.MakeReference(true);
					Dereference(ctx, true);
				}

				ctx->bc.InstrSHORT_DW(asBC_ADDSi, (short)prop->byteOffset, engine->GetTypeIdFromDataType(dt));

				if( prop->type.IsReference() )
					ctx->bc.Instr(asBC_RDSPtr);

				if( prop->type.IsPrimitive() )
				{
					ctx->bc.Instr(asBC_PopRPtr);
				}
```

`Dereference` (`:10213-10221`): if the type is an object/funcdef **reference**, emit `asBC_RDSPtr` and drop the reference flag.

Same shape in default-ctor / member-init / in-class VALUE construct:

- Nested ctor / base ctor: `PSF 0; RDSPtr; CALL` (`:2974-2976`, `:4017-4019`).
- In-place VALUE local: `PSF offset;` RDSPtr **only if** `derefDest` (`CallDefaultConstructor` `:4559-4562`).
- Member init counted-handle clear: `PSF 0; RDSPtr; ADDSi; PopRPtr; WRTV*` (`:3796-3808`).

`SetupParametersAndReturnVariable` (`:3302-3306`): `stackPos = 0`, then `if (objectType) stackPos = -AS_PTR_SIZE` **for the first named parameter**. `this` is never a named parameter; it is implicit at 0.

---

## 3. CodeGen live file:line (`as_bytecode_codegen.cpp`)

Path: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`.

### 3.1 `thisOffset = 0` — `Emit` ~692

```687:693:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		bool Emit(asCScriptFunction* outFunc, const asCDecl* decl)
		{
			func = outFunc;
			nextLocal = 1;
			nextLabel = 1;
			// Method `this` lives at frame offset 0 as a pointer (asCCompiler ThisObjectStackOffset).
			thisOffset = (func && func->objectType) ? 0 : 0x7fffffff;
```

Locals start at `nextLocal = 1`. Offset 0 is reserved for the this pointer. Matches asCCompiler.

### 3.2 `PushThisObject` PSF + RDSPtr — ~1010

```1010:1014:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		void PushThisObject()
		{
			bc.InstrSHORT(asBC_PSF, (short)thisOffset);
			bc.Instr(asBC_RDSPtr);
		}
```

This is asCCompiler implicit-this member access, not the REF `this` token (`PshVPtr`). Generated accessors (`:1061`, `:1091`) and ctor member Assign (`:1709`, `:1729`) share it. Generated accessors are GREEN on this path.

`PushMemberBase` for a **local VALUE** (`:1016-1027`) is `PSF base` **without** RDSPtr: the object memory **is** at `base`. Do not confuse callee-this (pointer in a slot) with caller-local VALUE (object in the slot).

### 3.3 `BindParameters` `stackPos = -AS_PTR_SIZE` then PARAMs; AllocTyped DECL_VAR — ~1244

```1244:1267:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		void BindParameters(const asCDecl* decl)
		{
			int stackPos = 0;
			if( func->objectType )
				stackPos = -AS_PTR_SIZE;
			if( func->DoesReturnOnStack() )
				stackPos -= AS_PTR_SIZE;

			for( asUINT i = 0; i < decl->children.GetLength(); ++i )
			{
				const asCDecl* child = context.GetDecl(decl->children[i]);
				if( child == 0 )
					continue;
				if( child->kind == asAST_DECL_PARAM )
				{
					BindSlot(child->id, stackPos);
					stackPos -= LocalDwords(TypeOf(child->type));
				}
				else if( child->kind == asAST_DECL_VAR )
				{
					const asCDataType dataType = TypeOf(child->type);
					BindSlot(child->id, AllocTyped(dataType));
				}
			}
```

Call order in `Emit`: `BindParameters` **then** `returnSlot = AllocDwords` (`:705-720`). Function `DECL_VAR` children (if any) take slots before the return temp. `STMT_DECL` later skips if `FindSlot` already bound (`:2627`).

0-arg ctor: no PARAMs. `this` stays 0. Temps from inits/body allocate at ≥1.

### 3.4 `EmitConstructInto` VALUE: PSF dest + CALL — ~2026–2055

```2026:2055:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			int pop = 0;
			if( !isValue )
			{
				bc.InstrSHORT(asBC_PSF, (short)dest);
				pop += AS_PTR_SIZE;
			}
			for( asUINT i = args.GetLength(); i > 0; --i )
			{
				// ... PushValue args reverse ...
			}
			if( isValue )
			{
				bc.InstrSHORT(asBC_PSF, (short)dest);
				pop += AS_PTR_SIZE;
				if( ctor && ctor->funcType == asFUNC_SYSTEM )
					bc.Call(asBC_CALLSYS, ctorId, pop);
				else
					bc.Call(asBC_CALL, ctorId, pop);
			}
			else
			{
				bc.Alloc(asBC_ALLOC, objType, ctorId, pop, true);
			}
```

VALUE: `this` is pushed **last** (top of stack = fp[0] in the callee). `PSF dest` with no RDSPtr = asCCompiler in-place VALUE (`derefDest == false`). REF: `ALLOC` / factory + `STOREOBJ`, not this file’s H2 question.

0-arg fallback when `FindFunc(resolvedDecl)` misses (`:1975-1988`): `FindConstructorId(objType, 0)` then `FindFactoryId`. That is H1, not thisOffset.

### 3.5 `FindConstructorId(0)` first SCRIPT — ~561–603

```561:602:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
	int FindConstructorId(asCObjectType* objType, asUINT argCount)
	{
		int systemId = 0;
		for( asUINT i = 0; i < objType->beh.constructors.GetLength(); ++i )
		{
			// ... arity filter ...
			if( ctor->funcType == asFUNC_SCRIPT )
			{
				return id;   // first SCRIPT 0-arg wins
			}
			if( systemId == 0 )
				systemId = id;
		}
		if( argCount == 0 && objType->beh.construct )
		{
			// SCRIPT construct preferred; else keep systemId
		}
		return systemId;
	}
```

Inherited `scriptTypeBehaviours` construct is SYSTEM (`ScriptObject_Construct`, `as_scriptobject.cpp:253`). First SCRIPT in `constructors[]` wins. If the user ctor is not that first SCRIPT (or never installed), Entry CALL is the wrong id — H1.

### 3.6 `HasConstructAssignTo` does not require `resolvedDecl` — ~2751

```2751:2784:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		bool HasConstructAssignTo(asASTDeclId varId) const
		{
			// ... any STMT_EXPR Assign whose lhs DECL_REF is varId ...
				const asCExpr* rhs = context.GetExpr(assign->children[1]);
				while( rhs
					&& (rhs->kind == asAST_EXPR_MATERIALIZE_TEMPORARY || rhs->kind == asAST_EXPR_CLEANUP)
					&& rhs->children.GetLength() )
				{
					rhs = context.GetExpr(rhs->children[0]);
				}
				if( rhs && rhs->kind == asAST_EXPR_CONSTRUCT )
				{
					return true;
				}
```

True for **any** sibling Construct, even if `resolvedDecl` is invalid. Dummy (the only `FindInternedZeroArgConstructor` caller) is then skipped.

### 3.7 `FindInternedZeroArgConstructor` dummy only — ~410, ~2643

Definition `:410-453`. Three-way class match: `stableKey==stableKey` OR `name==stableKey` OR `stableKey==name`. First 0-arg `DECL_CONSTRUCTOR` child.

Call site — dummy VALUE `STMT_DECL` only:

```2640:2648:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
					if( dataType.IsObject() && !dataType.IsObjectHandle()
						&& dataType.GetTypeInfo()
						&& (dataType.GetTypeInfo()->GetFlags() & asOBJ_VALUE)
						&& !HasConstructAssignTo(var->id) )
					{
						asCExpr dummyConstruct;
						dummyConstruct.kind = asAST_EXPR_CONSTRUCT;
						dummyConstruct.type = var->type;
						dummyConstruct.resolvedDecl = FindInternedZeroArgConstructor(context, var->type);
```

`FValue Object;` always has Sema sibling Construct (`AppendDefaultValueConstruct`, `as_sema_stmt.cpp:90-105`). Dummy is skipped. Intern lookup never runs for this fixture.

### 3.8 `FillFunctionSignature` `constructors[0]` overwrite — ~3160

```3160:3170:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
					if( decl->kind == asAST_DECL_CONSTRUCTOR )
					{
						objType->beh.construct = func->id;
						if( func->parameterTypes.GetLength() == 0 && objType->beh.constructors.GetLength() )
						{
							objType->beh.constructors[0] = func->id;
						}
						else
						{
							objType->beh.constructors.PushLast(func->id);
						}
					}
```

Overwrite happens only on the **asNEW** path. If the list is non-empty (inherited behaviours), slot `[0]` is replaced; else PushLast.

### 3.9 `RegisterCanonicalScriptTypes` copies `scriptTypeBehaviours.beh` — ~3036

```3036:3058:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			st->beh = engine->scriptTypeBehaviours.beh;
			if( isValue )
			{
				st->beh.factory = 0;
				st->beh.factories.SetLength(0);
			}
			// ... AddRefInternal on inherited factory/copy/construct ...
```

Same copy as asCBuilder (`as_builder.cpp:2918`). VALUE clears factories; **constructors list is kept**. That list starts as the `$obj` SYSTEM construct.

### 3.10 `FindExactRegisteredConstructor` returns 0 if `body.IsValid()` — ~245

```245:251:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		if( engine == 0 || decl == 0 || decl->kind != asAST_DECL_CONSTRUCTOR || decl->body.IsValid() )
		{
			return 0;
		}
		if( (decl->traits & asAST_TRAIT_GENERATED) != 0 )
		{
			return 0;
		}
```

User ctor **has a body** → never reused as a host bind → `asNEW` + `FillFunctionSignature`. Generated ctor is also 0 (`GENERATED`) → also `asNEW`. Host-ctor reuse is not why generated is GREEN and user is RED.

---

## 4. Clang shape only (do not port)

Local tree: `Reference/llvm-project` (commit recorded in `attachments/clang-ast-reference.md`).

- `CXXMethodDecl::getThisType()` (`clang/include/clang/AST/DeclCXX.h` ~2267–2272): `this` is a **pointer** to the class, including on constructors (`CXXConstructorDecl` is a `CXXMethodDecl`).
- `CXXThisExpr` (`clang/include/clang/AST/ExprCXX.h` ~1154–1178): a typed expression of that pointer type, implicit or explicit.
- `CXXConstructExpr` holds `CXXConstructorDecl*`, not name+arity (`attachments/wave-b-llvm-construct-intern.md` §1).

Adopted analogue: callee `this` is a pointer stored at fp[0]; PSF 0 addresses that slot; RDSPtr loads it. **Do not** import Clang `CodeGenFunction` / LLVM IR `this` lowering.

---

## 5. Why generated `FValue Object; return Object.Value+1` can GREEN while user ctor local `Object.Value` is 0

Fixtures (both CANONICAL CodeGen publisher):

```angelscript
// GREEN CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes
struct FValue { int Value = 41; }
int F() { FValue Object; return Object.Value + 1; }

// RED CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody
struct FValue {
    int Value = 40 + 1;
    FValue() { Value = Value + 1; }
}
int Entry() { FValue Object; return Object.Value; }
```

Dump already proves the **user-ctor function** has `init=` Assign of interned `40+1`. It does not prove Entry CALL hits that function, or that callee `this` is Entry’s `Object`.

Every live delta:

| # | Topic | Generated default ctor (GREEN 42) | User ctor (RED got=0) |
| --- | --- | --- | --- |
| 1 | Lifecycle decl | `EnsureGeneratedLifecycle` synthesizes `DECL_CONSTRUCTOR` + `asAST_TRAIT_GENERATED`. No user body. | User `FValue()` is `DECL_CONSTRUCTOR` with `body.IsValid()`. No generated ctor (`hasCtor` true). |
| 2 | Member plan | `AttachConstructorMemberInits` copies `Value = 41` onto ctor `inits`. | Same helper copies interned `40+1` onto ctor `inits`. Dump GREEN. |
| 3 | Inherited `beh.constructors` | `st->beh = scriptTypeBehaviours.beh` then VALUE factory clear. `[0]` is SYSTEM `$obj` construct until overwrite. | Identical. |
| 4 | Host reuse | `FindExactRegisteredConstructor` returns 0 (`GENERATED`). `asNEW`. | Returns 0 (`body.IsValid()`). `asNEW`. **Not a delta.** |
| 5 | `constructors[0]` overwrite | First 0-arg asNEW ctor writes `beh.construct` and `constructors[0]`. | Same, if `FillFunctionSignature` runs for that decl. |
| 6 | `SelectConstructor` class match | `as_sema.cpp:947`: `DECL_CLASS` with `decl->name.Equals(named->stableKey)` **only**. | Same function. If `stableKey` is not the spelling `FValue`, **both** miss. |
| 7 | Intern native 0-arg | `ActOnConstruct` intern-native only if `args.GetLength() > 0` (`as_sema.cpp:1025-1028`). 0-arg still `SelectConstructor`. | Same. **Do not** intern native 0-arg / array factories to “fix” this. |
| 8 | Sibling Construct | `AppendDefaultValueConstruct` → Assign `Object = Construct()`. `HasConstructAssignTo` true **without** `resolvedDecl`. | Same. Dummy skipped. |
| 9 | Dummy `FindInternedZeroArgConstructor` | Not called (sibling exists). Dummy is the **only** caller (`:2648`). | Not called. If `SelectConstructor` missed, sibling Construct has **invalid** `resolvedDecl` and dummy cannot save it. |
| 10 | `EmitConstructInto` callee | `FindFunc(resolvedDecl)` if Select hit; else `FindConstructorId(0)` = first SCRIPT in `constructors[]`. | Same. If overwrite installed the user SCRIPT at `[0]`, H1 ids match. If `[0]` stayed a different SCRIPT, or CALL id is SYSTEM `ScriptObject_Construct`, Entry writes nothing into `Value` → got=0 (**H1**). |
| 11 | Ctor body | Empty / no `Value = Value + 1`. Inits only: `SetV4 41; PSF 0; RDSPtr; ADDSi; PopRPtr; WRTV4`. | Inits same shape for `40+1`, **then** body load `CpyRtoV8` / `PshVPtr` / `RDR4`, `SetV4`, `ADDi`, `WRTV4`. Body `Value+1` on a 0-read yields **1**, not 0. |
| 12 | Entry return | `Object.Value + 1`. `+1` is in **Entry**. If `Value` were 0, F() would be **1**, not 42. GREEN 42 ⇒ generated ctor **did** write 41 into the object F() reads. | `Object.Value` with **no** `+1`. got=0 ⇒ the object Entry reads was never written, or is not the object the ctor wrote. |
| 13 | Get vs member | Both fixtures spell `Object.Value`. `EmitMember` (`:2064-2101`): `PushMemberBase` = `PSF ObjectSlot` (no RDSPtr) + `ADDSi` + `RDR4`. `EmitCall` generated-Get (`:2424-2458`) is the same `PSF base` + `ADDSi` + `RDR` **on the receiver**, not callee `PushThisObject`. Isolated `FValue().Value+1` is a **temporary**, not this local. | Same `Object.Value` member path unless Entry dump shows `CALL`/`CALLSYS` GetValue. Always-inline Get was tried, still got=0, **reverted** (broke accessors). |
| 14 | `this` convention | Generated ctor uses `PushThisObject` PSF 0 + RDSPtr. GREEN ⇒ **that callee ABI writes a VALUE object the caller later reads.** | User ctor dump already shows PSF + RDSPtr + WRTV4. If H1 ids match, the ABI opcode shape is not the missing write; the **pointer value at fp[0]** or Entry dest slot is. |

`atoi` is dead (`EmitConstructorMemberDefaults` deleted). got=0 is not `atoi("40+1")=40` (that predicts 41). Isolated GREEN is not InitPlan evidence.

---

## 6. Recommended H2 probe (only if exclusive already proved H1 ids match)

Not a patch. Smallest bytecode diff:

1. **Entry CALL vs generated F() CALL**  
   Same shape expected: `PSF <ObjectSlot>; CALL <ctorId>`.  
   Record `ObjectSlot` from `PSF` and from `scriptData->objVariablePos[]`.  
   Record `returnSlot` (first `AllocDwords` after `BindParameters` when there are no function `DECL_VAR` children).  
   If user Entry `PSF` dest ≠ the slot later `EmitMember` uses for `Object.Value`, that is H2/H3 slot alias — still not `thisOffset`.

2. **Ctor first store vs generated default ctor first store**  
   Expected common prefix: `SetV4 <tmp>; PSF 0; RDSPtr; ADDSi <Value.byteOffset=0>; PopRPtr; WRTV4 <tmp>`.  
   Diff only the `SetV4` immediate (41 vs 40+1 result) and whether `ADDSi` typeId/offset match `FValue::Value`.  
   If user init **omits** RDSPtr after PSF 0, WRTV4 would hit the **this-slot** (overwrite the pointer bits) and Entry’s Object stays 0. Last RED dump already listed RDSPtr — confirm the new dump still has it on **both** init store and body store.

3. **User body extra** (generated has none)  
   `EmitDeclRef` this-property (`:1620-1642`): `PushThisObject; ADDSi; PopRPtr; CpyRtoV8 ptr; PshVPtr ptr; PopRPtr; RDR4`. Then `ADDi` + `WRTV4`.  
   A 0-read + 1 = **1**. If body store is present and Entry is still 0, body also missed Object (same bad `this` pointer), or Entry never called this function (H1 contradiction).

4. **Do not** treat `PshVPtr 0` vs `PSF 0; RDSPtr` as a fix candidate without a dump that shows PSF-without-RDSPtr. They are equivalent **loads** of fp[0]; only PSF-without-RDSPtr then ADDSi is wrong.

Stop after naming the first differing instruction (opcode, offset, CALL id). Hand that back to `wave-b-initplan-exec.md`. One evidence-based fix lives there, not here.

---

## 7. Hard nos

- **Do not** propose `thisOffset = -AS_PTR_SIZE` without showing PSF 0 is wrong. VM, asCCompiler (`ThisObjectStackOffset = 0`), `BindParameters` (params at `-AS_PTR_SIZE`), `nextLocal = 1`, and GREEN generated ctor/accessors all put **this at fp[0]**. Negative offset is the first parameter.
- **Do not** propose Get-always-inline. Tried; still got=0; broke accessors; reverted.
- **Do not** propose `atoi` / `strtoll` / expanding `IntegerInitText` for `40+1`. Dump already has a typed init plan.
- **Do not** intern native 0-arg constructors or `array<T>` factories. `FindFactoryId(0)` / ArrayInt stub stay until a dedicated 0-arg intern bite.
- **Do not** delete `FindConstructorId(0)` for native SYSTEM 0-arg yet.
- **Do not** UBT from this file. **Do not** check 13.2 / 5.4 / 9.5.

---

## 8. File map (read-only)

| File | Why |
| --- | --- |
| `as_context.cpp` | `PrepareScriptFunction`, `asBC_PSF`, `asBC_RDSPtr`, `asBC_ADDSi`, `asBC_PopRPtr`, `asBC_WRTV4`, `asBC_CALL` |
| `as_compiler.cpp` | `ThisObjectStackOffset`, VALUE `PSF` vs REF `PshVPtr`, implicit-this `Dereference` + `ADDSi`, `CallDefaultConstructor` PSF dest |
| `as_bytecode_codegen.cpp` | All Canonical `this`/ctor emit sites in §3 |
| `as_sema.cpp` / `as_sema_stmt.cpp` / `as_sema_decl.cpp` | `SelectConstructor` name vs `stableKey`; `AppendDefaultValueConstruct`; `AttachConstructorMemberInits` |
| `as_scriptfunction.cpp` | `totalSpaceBeforeFunction` includes this; `GetSpaceNeededForArguments` does not |
| `as_scriptobject.cpp` | Inherited SYSTEM `$obj` construct |
| `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` | GREEN generated `:849`; RED user execute `:2594` |
| `Reference/llvm-project/clang/include/clang/AST/DeclCXX.h`, `ExprCXX.h` | Shape only: `this` is a pointer |
