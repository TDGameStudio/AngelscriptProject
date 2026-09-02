# Wave C 2.6 — named Engine type keys (TDD inventory)

> **This package is attachment-only until C-28 (tasks 2.8 / 13.5) releases exclusive UBT.** Do not edit fork/production sources in this dispatch. Do not run `RunBuild` / `RunTests` / UBT now. Do not check `tasks.md` 2.6.

> **For the later implementer:** Use superpowers:test-driven-development. Write the failing tests first. `RunBuild` then the Type prefix **before** editing `as_runtime_type_bridge.cpp`. Exclusive UBT. If `UE4Editor` / `MSBuild` / `UnrealBuildTool` / `link` are running, **wait or stop**. Do not start a second build.

**Worktree:** `D:\as-cta`. Dual-repo later: plugin submodule first. Commands always from `D:\as-cta`.

**Goal:** `asCRuntimeTypeBridge::FromDataType` maps Engine `asCDataType` / `asCTypeInfo` named types to interned `asCQualType` whose `asCType::kind` is `ENUM` / `FUNCDEF` / `TEMPLATE` / `VALUE_OBJECT` / `REFERENCE_OBJECT`, and whose public identity is intern-id + qualifier mask + `stableKey` string. No `asCTypeInfo*`. No numeric `typeId` on `asCQualType` or `asCType`.

**Spec (already written):** `specs/as-canonical-typed-ast/spec.md` — “Canonical types have stable identity and a Runtime bridge”. Runtime type objects and IDs resolve through the current-Engine bridge and MUST NOT be durable public/cache identity.

---

## Honest current state (do not redo quals)

| Fact | Where |
| --- | --- |
| `asAST_TYPE_ENUM` / `FUNCDEF` / `TEMPLATE` / `VALUE_OBJECT` / `REFERENCE_OBJECT` already exist | `as_ast_kind.h` L79–90 |
| Intern table already accepts those kinds as string keys | `asCASTContext::InternNamedType` / `InternType` (`as_ast_context.cpp` L216–291). Identity is `(kind, primitiveToken, stableKey)` |
| `asCQualType` is already two POD words: `asASTTypeRef type` + `asDWORD quals`. No engine pointer field | `as_ast_type.h` L27–50 |
| Qualifier intern already rejects unknown bits, dir-without-ref, auto-handle-without-handle, illegal void quals. `void`+handle remains legal (nullptr) | `asASTQualifiersAreValid` + Type tests below |
| `RuntimeBridgeDoesNotEmbedEnginePointersInQualType` only covers **const int** via `Bridge(nullptr)` | Type tests L90–99 |

`tasks.md` 2.6 “why open” qualifier sentences are **stale**. Do **not** reopen or rewrite:

- `PrimitiveEnumObjectAndQualifierCanonicalization` (direct `InternNamedType` / `InternPrimitive`, including `void`+handle nullptr)
- `RejectsDirectionWithoutReference`
- `RejectsAutoHandleWithoutHandle`
- `RejectsIllegalVoidQualifiers`
- `RejectsUnknownQualifierBits`
- `RuntimeBridgeDoesNotEmbedEnginePointersInQualType` (keep the const-int case; add **sibling** methods)

Those tests already lock intern + qualifier predicates. 2.6 is the **Engine bridge**, not a second qualifier pass.

Sema `ActOnQualTypeFromNode` still invents `VALUE_OBJECT` vs `REFERENCE_OBJECT` from the handle bit (`as_sema_decl.cpp` ~L333–338). That is **task 4.3**, not 2.6. Do not edit `as_sema*`. Sidecar decode still force-`VALUE_OBJECT` — **task 6.3**, not 2.6.

---

## Current `FromDataType` hole (`as_runtime_type_bridge.cpp` L95–124)

```cpp
if( dataType.GetTokenType() == ttVoid || dataType.IsPrimitive() )
{
    return context.InternPrimitive(dataType.GetTokenType(), quals);
}
asCTypeInfo* info = dataType.GetTypeInfo();
if( info && info->GetName() )
{
    const asEASTTypeKind kind = dataType.IsObjectHandle() || (info->GetFlags() & asOBJ_REF)
        ? asAST_TYPE_REFERENCE_OBJECT
        : asAST_TYPE_VALUE_OBJECT;
    return context.InternNamedType(kind, info->GetName(), quals);
}
```

Three independent bugs:

1. **`asCDataType::IsPrimitive()` is true for enums** (`as_datatype.cpp` L585–589). Enums never reach the named branch. `GetTokenType()` is `ttIdentifier`, so `InternPrimitive(ttIdentifier, …)` hits the default arm and returns **invalid** `asCQualType`.
2. Named non-enums collapse to `REFERENCE_OBJECT` if `IsObjectHandle()` **or** `asOBJ_REF`, else `VALUE_OBJECT`. Host **funcdefs** are `asOBJ_REF | asOBJ_GC | asOBJ_FUNCDEF` (`as_typeinfo.cpp` L461–462) → interned as `REFERENCE_OBJECT`. Host **`array<T>`** is `asOBJ_REF | asOBJ_TEMPLATE` → interned as `REFERENCE_OBJECT`. `asAST_TYPE_ENUM` / `FUNCDEF` / `TEMPLATE` are unused by the bridge.
3. Key is `info->GetName()` only: template instance `array<int>` becomes `"array"`; `Game::ETeam` collides with global `ETeam`. Handle is used as a **kind**, not a qualifier.

`CreateNullHandle()` is not primitive (`ttUnrecognizedToken`, no `typeInfo`) → empty QualType. **nullptr as `void`+handle is intentional** on the intern path; the bridge must map null handles onto that same encoding (without `CONST` — `const void` is illegal).

---

## Global constraints (implementer)

- TDD. No Unreal types in fork files (`as_ast_*`, `as_runtime_type_bridge`, `as_sema*`, `as_bytecode_codegen`, `as_source_manager`).
- No Clang/LLVM headers, `llvm::`, `clang::`, or linkage. Do not invent a Clang QualType.
- Default pipeline stays LEGACY. `Ready()` stays false. Do not route `Build()` through `Generate()`.
- Do not add `asCTypeInfo*`, `asITypeInfo*`, `void* engineType`, or `int typeId` to `asCQualType` or `asCType`.
- Do not change `asASTQualifiersAreValid` or the six existing Type TEST_METHODs listed above.
- Do not edit `as_ast_verifier.*`, `as_sema*`, `as_ast_sidecar.cpp`, or CodeGen.
- Host registration only: `RegisterEnum` / `RegisterFuncdef` / `RegisterObjectType`. **No production `Build()`**, no `asCBytecodeCodeGen::Generate()`, no module script compile required for these Type tests.
- Classification helper lives in the **bridge `.cpp`** (static). Do not pull `as_typeinfo.h` into `as_ast_type.h`.
- `Standalone/CMakeLists.txt` already lists `as_runtime_type_bridge.cpp`. No CMake change unless a new `.cpp` is added (do not add one).

---

## File map

| Path | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTTypeTests.cpp` | Six new TEST_METHODs (keep the existing six untouched). Add `#include "Misc/ScopeExit.h"` plus fork headers `as_scriptengine.h`, `as_ast_type.h`, `as_typeinfo.h` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_bridge.cpp` | `FromDataType` classification + qualifier-stripped `stableKey`; `FindRuntimeTypeInfo` tries `GetTypeInfoByDecl` **before** `GetTypeInfoByName`; null-handle → `void`+handle |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_bridge.h` | No new public fields. Optional: no API change (keep helpers `static` in the `.cpp`) |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_type.h/.cpp` | **No new members.** Intern APIs already exist. Do not store engine pointers or `typeId` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_kind.h` | **No change.** Kinds already exist |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-c-results.md` | After implement: record Type prefix counts |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/tasks.md` | Check 2.6 **only** after close criteria |

Do **not** touch: `as_sema_decl.cpp`, `as_ast_sidecar.cpp`, `as_ast_verifier.cpp`, `as_bytecode_codegen.cpp`, `Core/angelscript.h`.

---

## How to classify Engine types (no pointer / no typeId on QualType)

`asCQualType` stays `{ asASTTypeRef type; asDWORD quals; }`. `asCType` stays `{ asASTTypeRef id; asEASTTypeKind kind; eTokenType primitiveToken; asCString stableKey; }`. The bridge **reads** `asCDataType` / `asCTypeInfo` for the duration of `FromDataType` / `Resolve`, copies a string key, and forgets the Engine object.

### Qualifier bits (already mapped; do not invent new ones)

Copy from `asCDataType` into `quals` as today:

| Engine | Qual bit |
| --- | --- |
| `IsReadOnly()` | `asAST_QUAL_CONST` — **except** null handle (below) |
| `IsObjectHandle()` | `asAST_QUAL_HANDLE` |
| `IsReference()` | `asAST_QUAL_REFERENCE` |

Do **not** map auto-handle in 2.6 (Engine `asCDataType` has no 1:1 auto-handle bit on the datatype). Do not reopen auto-handle intern tests.

### Kind (ordered; first match wins)

Handle / ref / const are **not** kinds.

```text
if dataType.IsNullHandle():
    InternPrimitive(ttVoid, asAST_QUAL_HANDLE)
    // drop CONST even if CreateNullHandle is const — const void is illegal
else if typeInfo = dataType.GetTypeInfo() is non-null:
    flags = typeInfo->GetFlags()
    if flags & asOBJ_ENUM:     kind = asAST_TYPE_ENUM
    else if flags & asOBJ_FUNCDEF: kind = asAST_TYPE_FUNCDEF
    else if flags & asOBJ_TEMPLATE: kind = asAST_TYPE_TEMPLATE
    else if flags & asOBJ_REF: kind = asAST_TYPE_REFERENCE_OBJECT
    else                       kind = asAST_TYPE_VALUE_OBJECT
    InternNamedType(kind, StableKey(dataType), quals)
else if token == ttVoid || IsPrimitive():
    InternPrimitive(token, quals)   // built-in only; enums never reach here
else:
    invalid QualType
```

Equivalent Engine predicates: `IsEnumType()` / `IsFuncdef()` / `IsTemplate()` match those flags. Prefer flags (or those predicates) over `IsObjectHandle()` / `asOBJ_REF` for kind.

Why this order:

| Engine registration | Flags (today) | Wrong kind today | Required kind |
| --- | --- | --- | --- |
| `RegisterEnum("ETeam")` | `asOBJ_ENUM \| asOBJ_SHARED` | invalid (`IsPrimitive` → `InternPrimitive(ttIdentifier)`) | `ENUM` |
| `RegisterFuncdef("void FCallback()")` | `asOBJ_REF \| asOBJ_GC \| asOBJ_FUNCDEF` | `REFERENCE_OBJECT` (`asOBJ_REF`) | `FUNCDEF` |
| `RegisterObjectType("array<class T>", 0, asOBJ_REF \| asOBJ_TEMPLATE \| asOBJ_NOCOUNT)` and instance `array<int>` | `asOBJ_REF \| asOBJ_TEMPLATE` | `REFERENCE_OBJECT` + key `"array"` | `TEMPLATE` + key `"array<int>"` |
| `RegisterObjectType("CObj", 0, asOBJ_REF \| asOBJ_NOCOUNT)` | `asOBJ_REF` | `REFERENCE_OBJECT` (accidentally right) | `REFERENCE_OBJECT`; handle is a qualifier |
| `RegisterObjectType("FValue", 4, asOBJ_VALUE \| asOBJ_POD \| asOBJ_APP_PRIMITIVE)` | `asOBJ_VALUE \| …` | `VALUE_OBJECT` (accidentally right) | `VALUE_OBJECT` |

`asOBJ_TEMPLATE` instances keep `asOBJ_TEMPLATE` on the instance (`GetTemplateInstanceType` copies `templateType->flags`). Check TEMPLATE **before** REF.

### `stableKey` (pointer-free, not `typeId`)

Do **not** stringify `GetTypeId()`, `typeInfo` address, or `0x…`.

Build from the Engine type **without** const/handle/ref (those live on `asCQualType.quals`):

1. Copy `asCDataType keyDt = dataType`.
2. `keyDt.MakeReadOnly(false); keyDt.MakeHandle(false); keyDt.MakeReference(false);`
3. `asCString key = keyDt.Format(engine->nameSpaces[0], /*includeNamespace*/ true);`

That yields `ETeam`, `Game::ETeam`, `FCallback`, `array<int>`, `CObj`, `FValue`. `Format` already appends `<subtype,…>` for object types with `templateSubTypes` (`as_datatype.cpp` L240–254). Default-array `T[]` sugar is off (`expandDefaultArrayToTemplate` defaults false only for `int[]` display; registered `array<T>` uses the template branch).

If `Format` is inconvenient, equivalent: `namespace::` + `GetName()` + `<` + recursive subtype keys + `>` when `GetSubTypeCount() > 0`. Same strings. Do not use bare `GetName()` for templates or namespaced types.

Intern identity remains `(kind, primitiveToken=ttUnrecognizedToken, stableKey)`. Same name with different kinds intern **separately** (already true).

### `Resolve` lookup (same engine, pointers allowed **only** here)

`FindRuntimeTypeInfo` today: `GetTypeInfoByName(key)` then `GetTypeInfoByDecl(key)` then scan object types / `funcDefs` by **bare name**. For `array<int>` and `Game::ETeam`, **Decl must win**.

Change the scan to:

1. `engine->GetTypeInfoByDecl(key)`
2. `engine->GetTypeInfoByName(key)` (global short names)
3. existing object-type / funcdef fallbacks only if both miss

Do not persist the resolved `asCTypeInfo*` into the QualType. Round-trip tests may compare `Resolve(...).GetTypeInfo()` to the host `asITypeInfo*` **on the live Engine only**.

### Nullptr

`dataType.IsNullHandle()` → `context.InternPrimitive(ttVoid, asAST_QUAL_HANDLE)` only. Do not apply `CONST` / `REFERENCE`. This is the same encoding `RejectsIllegalVoidQualifiers` already locks on the intern API. Do not change that test; add a **bridge** test.

---

## Task 1 — failing tests (RED)

Append these methods inside `FCanonicalASTTypeTests`. Do **not** edit the six existing methods. Add includes:

```cpp
#include "Misc/ScopeExit.h"
#include "source/as_ast_type.h"
#include "source/as_scriptengine.h"
#include "source/as_typeinfo.h"
```

Anonymous helper (test file only):

```cpp
namespace
{
	asCDataType MakeHostDataType(asIScriptEngine* Engine, const char* Decl, bool bConst = false)
	{
		asITypeInfo* Info = Engine->GetTypeInfoByDecl(Decl);
		if (Info == nullptr)
		{
			Info = Engine->GetTypeInfoByName(Decl);
		}
		asCDataType DataType = asCDataType::CreateType(static_cast<asCTypeInfo*>(Info), bConst);
		return DataType;
	}
}
```

Prefer `GetTypeInfoByDecl` so `array<int>` and `Game::ETeam` resolve. **No `Build()`.** `FNativeTestEngine` is already available through `AngelscriptNativeCanonicalASTTestSupport.h`.

### TEST_METHOD names (exact)

1. `RuntimeBridgeInternsHostEnumAsEnumKind`
2. `RuntimeBridgeInternsHostFuncdefAsFuncdefKind`
3. `RuntimeBridgeInternsArrayIntAsTemplateKind`
4. `RuntimeBridgeNamedTypeIdentityHasNoEnginePointerOrTypeId`
5. `RuntimeBridgeNullHandleIsVoidWithHandle`
6. `RuntimeBridgeHandleIsQualifierNotKindForRefAndValue`

### 1. `RuntimeBridgeInternsHostEnumAsEnumKind`

```cpp
	TEST_METHOD(RuntimeBridgeInternsHostEnumAsEnumKind)
	{
		using namespace AngelscriptNativeTestSupport;
		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };
		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->RegisterEnum("ETeam") >= 0, TEXT("host RegisterEnum(ETeam)")));
		ASSERT_THAT(AreEqual(asSUCCESS, ScriptEngine->SetDefaultNamespace("Game"), TEXT("select Game namespace")));
		ASSERT_THAT(IsTrue(ScriptEngine->RegisterEnum("ETeam") >= 0, TEXT("namespace-local ETeam is a different Engine type")));
		ASSERT_THAT(AreEqual(asSUCCESS, ScriptEngine->SetDefaultNamespace(""), TEXT("restore global namespace")));

		asCASTContext Context;
		asCRuntimeTypeBridge Bridge(ScriptEngine);
		const asCDataType GlobalDt = MakeHostDataType(Engine.Get(), "ETeam");
		const asCQualType GlobalQual = Bridge.FromDataType(Context, GlobalDt);
		const asCType* GlobalTy = Context.GetType(GlobalQual.type);
		ASSERT_THAT(IsTrue(GlobalQual.IsValid() && GlobalTy != nullptr, TEXT("enum FromDataType must intern")));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_ENUM, (int)GlobalTy->kind, TEXT("host enum kind is ENUM, not primitive/VALUE_OBJECT")));
		ASSERT_THAT(IsTrue(GlobalTy->stableKey.Equals("ETeam"), TEXT("global enum key is the name, not typeId")));

		const asCQualType Again = Bridge.FromDataType(Context, GlobalDt);
		ASSERT_THAT(IsTrue(GlobalQual == Again, TEXT("equivalent enum datatypes intern to one QualType")));

		const asCDataType ConstDt = asCDataType::CreateType(GlobalDt.GetTypeInfo(), true);
		const asCQualType ConstQual = Bridge.FromDataType(Context, ConstDt);
		ASSERT_THAT(IsTrue(ConstQual.IsValid() && ConstQual.IsConst(), TEXT("const is a qualifier")));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_ENUM, (int)Context.GetType(ConstQual.type)->kind, TEXT("const does not change enum kind")));
		ASSERT_THAT(IsTrue(ConstQual.type == GlobalQual.type, TEXT("const enum shares the interned asCType")));

		const asCDataType NsDt = MakeHostDataType(Engine.Get(), "Game::ETeam");
		const asCQualType NsQual = Bridge.FromDataType(Context, NsDt);
		const asCType* NsTy = Context.GetType(NsQual.type);
		ASSERT_THAT(IsTrue(NsQual.IsValid() && NsTy != nullptr, TEXT("namespaced enum FromDataType must intern")));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_ENUM, (int)NsTy->kind, TEXT("namespaced enum is still ENUM")));
		ASSERT_THAT(IsTrue(NsTy->stableKey.Equals("Game::ETeam"), TEXT("namespace is part of the stable key")));
		ASSERT_THAT(IsTrue(NsQual != GlobalQual, TEXT("Game::ETeam must not collide with global ETeam")));

		const asCDataType Resolved = Bridge.Resolve(Context, NsQual);
		ASSERT_THAT(IsTrue(Resolved.GetTypeInfo() == NsDt.GetTypeInfo(),
			TEXT("Resolve uses stable key, not a stored typeId, and binds the current Engine type")));
	}
```

Expected RED today: `GlobalQual.IsValid()` is false (`IsPrimitive` + `ttIdentifier`).

### 2. `RuntimeBridgeInternsHostFuncdefAsFuncdefKind`

```cpp
	TEST_METHOD(RuntimeBridgeInternsHostFuncdefAsFuncdefKind)
	{
		using namespace AngelscriptNativeTestSupport;
		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };
		asIScriptEngine* const ScriptEngine = Engine.Get();
		ASSERT_THAT(IsTrue(ScriptEngine->RegisterFuncdef("void FCallback()") >= 0, TEXT("host RegisterFuncdef")));

		asCASTContext Context;
		asCRuntimeTypeBridge Bridge(static_cast<asCScriptEngine*>(ScriptEngine));
		const asCDataType DataType = MakeHostDataType(ScriptEngine, "FCallback");
		ASSERT_THAT(IsTrue(DataType.GetTypeInfo() != nullptr, TEXT("funcdef type info exists without Build")));
		ASSERT_THAT(IsTrue((DataType.GetTypeInfo()->GetFlags() & asOBJ_FUNCDEF) != 0, TEXT("host funcdef carries asOBJ_FUNCDEF")));

		const asCQualType Qual = Bridge.FromDataType(Context, DataType);
		const asCType* Ty = Context.GetType(Qual.type);
		ASSERT_THAT(IsTrue(Qual.IsValid() && Ty != nullptr, TEXT("funcdef FromDataType must intern")));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_FUNCDEF, (int)Ty->kind,
			TEXT("asOBJ_REF|FUNCDEF must intern FUNCDEF, not REFERENCE_OBJECT")));
		ASSERT_THAT(IsTrue(Ty->stableKey.Equals("FCallback"), TEXT("funcdef key is the name, not typeId or pointer")));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_FUNCDEF, (int)Context.GetType(Bridge.FromDataType(Context, DataType).type)->kind,
			TEXT("second FromDataType intern-hits the same FUNCDEF type")));
	}
```

Expected RED today: `kind == asAST_TYPE_REFERENCE_OBJECT`.

### 3. `RuntimeBridgeInternsArrayIntAsTemplateKind`

Feasible **without** production `Build()`. `GetTemplateInstanceType` does not require factories when `beh.templateCallback == 0`. `GetTypeInfoByDecl("array<int>")` uses silent `ParseDataType` and instantiates.

```cpp
	TEST_METHOD(RuntimeBridgeInternsArrayIntAsTemplateKind)
	{
		using namespace AngelscriptNativeTestSupport;
		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };
		asIScriptEngine* const ScriptEngine = Engine.Get();
		ASSERT_THAT(IsTrue(
			ScriptEngine->RegisterObjectType("array<class T>", 0, asOBJ_REF | asOBJ_TEMPLATE | asOBJ_NOCOUNT) >= 0,
			TEXT("host array<T> template must register without Build")));

		asITypeInfo* const Inst = ScriptEngine->GetTypeInfoByDecl("array<int>");
		ASSERT_THAT(IsNotNull(Inst, TEXT("GetTypeInfoByDecl(array<int>) must instantiate without module Build")));
		ASSERT_THAT(IsTrue((Inst->GetFlags() & asOBJ_TEMPLATE) != 0, TEXT("instance keeps asOBJ_TEMPLATE")));

		asCASTContext Context;
		asCRuntimeTypeBridge Bridge(static_cast<asCScriptEngine*>(ScriptEngine));
		const asCDataType DataType = asCDataType::CreateType(static_cast<asCTypeInfo*>(Inst), false);
		const asCQualType Qual = Bridge.FromDataType(Context, DataType);
		const asCType* Ty = Context.GetType(Qual.type);
		ASSERT_THAT(IsTrue(Qual.IsValid() && Ty != nullptr, TEXT("array<int> FromDataType must intern")));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_TEMPLATE, (int)Ty->kind,
			TEXT("asOBJ_REF|TEMPLATE must intern TEMPLATE, not REFERENCE_OBJECT")));
		ASSERT_THAT(IsTrue(Ty->stableKey.Equals("array<int>"),
			TEXT("template instance key is array<int>, not bare array and not typeId")));
		ASSERT_THAT(IsTrue(!Ty->stableKey.Equals("array"), TEXT("bare template name is not the instance key")));

		const asCDataType Resolved = Bridge.Resolve(Context, Qual);
		ASSERT_THAT(IsTrue(Resolved.GetTypeInfo() == Inst,
			TEXT("Resolve(array<int>) must use GetTypeInfoByDecl, not GetTypeInfoByName(array)")));
	}
```

If `GetTypeInfoByDecl("array<int>")` were ever null, **fail the test** — do not weaken the key to `"array"`. Do not compile a module to create the instance.

Expected RED today: `kind == REFERENCE_OBJECT` and `stableKey == "array"`.

### 4. `RuntimeBridgeNamedTypeIdentityHasNoEnginePointerOrTypeId`

```cpp
	TEST_METHOD(RuntimeBridgeNamedTypeIdentityHasNoEnginePointerOrTypeId)
	{
		using namespace AngelscriptNativeTestSupport;
		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		asIScriptEngine* const ScriptEngine = Engine.Get();
		ASSERT_THAT(IsTrue(ScriptEngine->RegisterEnum("ETeam") >= 0, TEXT("host enum")));
		asITypeInfo* const Info = ScriptEngine->GetTypeInfoByName("ETeam");
		ASSERT_THAT(IsNotNull(Info, TEXT("ETeam type info")));
		const int EngineTypeId = Info->GetTypeId();
		const uintptr_t InfoAddr = reinterpret_cast<uintptr_t>(Info);

		asCASTContext Context;
		asCRuntimeTypeBridge Bridge(static_cast<asCScriptEngine*>(ScriptEngine));
		const asCQualType Qual = Bridge.FromDataType(Context, asCDataType::CreateType(static_cast<asCTypeInfo*>(Info), false));
		const asCType* Ty = Context.GetType(Qual.type);
		ASSERT_THAT(IsTrue(Qual.IsValid() && Ty != nullptr, TEXT("named FromDataType must intern")));
		ASSERT_THAT(AreEqual(sizeof(asUINT) + sizeof(asDWORD), sizeof(asCQualType),
			TEXT("QualType layout is intern id + quals; no engine pointer word")));
		ASSERT_THAT(IsTrue(Qual.type.value != static_cast<asUINT>(EngineTypeId),
			TEXT("snapshot-local TypeRef must not be the Engine typeId")));
		ASSERT_THAT(IsTrue(reinterpret_cast<uintptr_t>(Ty) != InfoAddr, TEXT("interned asCType is not asCTypeInfo")));
		ASSERT_THAT(IsTrue(Ty->stableKey.Equals("ETeam"), TEXT("identity is the stable key string")));
		ASSERT_THAT(IsTrue(FCStringAnsi::Strstr(Ty->stableKey.AddressOf(), "0x") == nullptr,
			TEXT("stableKey must not spell an address")));

		asCString KeyCopy = Ty->stableKey;
		const asEASTTypeKind KindCopy = Ty->kind;
		const asASTTypeRef IdCopy = Qual.type;
		Engine.Destroy();

		const asCType* After = Context.GetType(IdCopy);
		ASSERT_THAT(IsTrue(After != nullptr && After->kind == KindCopy && After->stableKey.Equals(KeyCopy),
			TEXT("QualType/asCType must remain valid after Engine.Destroy — no dangling typeInfo*")));
	}
```

Do **not** call `Resolve` after `Destroy()`. Keep `RuntimeBridgeDoesNotEmbedEnginePointersInQualType` as the const-int case.

### 5. `RuntimeBridgeNullHandleIsVoidWithHandle`

```cpp
	TEST_METHOD(RuntimeBridgeNullHandleIsVoidWithHandle)
	{
		asCASTContext Context;
		asCRuntimeTypeBridge Bridge(nullptr);
		const asCQualType Qual = Bridge.FromDataType(Context, asCDataType::CreateNullHandle());
		const asCType* Ty = Context.GetType(Qual.type);
		ASSERT_THAT(IsTrue(Qual.IsValid() && Qual.IsHandle() && !Qual.IsConst() && !Qual.IsReference(),
			TEXT("null handle intern is void+handle, not const void")));
		ASSERT_THAT(IsTrue(Ty != nullptr && Ty->kind == asAST_TYPE_VOID && Ty->primitiveToken == ttVoid,
			TEXT("nullptr encoding is the void primitive, not a named type")));
		const asCQualType Direct = Context.InternPrimitive(ttVoid, asAST_QUAL_HANDLE);
		ASSERT_THAT(IsTrue(Qual == Direct, TEXT("bridge null handle matches the interned nullptr encoding")));
	}
```

Do not change `RejectsIllegalVoidQualifiers`. Expected RED today: `FromDataType` returns invalid.

### 6. `RuntimeBridgeHandleIsQualifierNotKindForRefAndValue`

```cpp
	TEST_METHOD(RuntimeBridgeHandleIsQualifierNotKindForRefAndValue)
	{
		using namespace AngelscriptNativeTestSupport;
		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };
		asIScriptEngine* const ScriptEngine = Engine.Get();
		ASSERT_THAT(IsTrue(
			ScriptEngine->RegisterObjectType("CObj", 0, asOBJ_REF | asOBJ_NOCOUNT) >= 0, TEXT("host ref type")));
		ASSERT_THAT(IsTrue(
			ScriptEngine->RegisterObjectType("FValue", 4, asOBJ_VALUE | asOBJ_POD | asOBJ_APP_PRIMITIVE) >= 0,
			TEXT("host value type")));

		asCASTContext Context;
		asCRuntimeTypeBridge Bridge(static_cast<asCScriptEngine*>(ScriptEngine));
		asCDataType RefDt = MakeHostDataType(ScriptEngine, "CObj");
		const asCQualType RefQual = Bridge.FromDataType(Context, RefDt);
		RefDt.MakeHandle(true);
		const asCQualType HandleQual = Bridge.FromDataType(Context, RefDt);
		ASSERT_THAT(AreEqual((int)asAST_TYPE_REFERENCE_OBJECT, (int)Context.GetType(RefQual.type)->kind,
			TEXT("asOBJ_REF interned as REFERENCE_OBJECT")));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_REFERENCE_OBJECT, (int)Context.GetType(HandleQual.type)->kind,
			TEXT("handle does not change kind")));
		ASSERT_THAT(IsTrue(RefQual.type == HandleQual.type, TEXT("handle vs non-handle share asCType")));
		ASSERT_THAT(IsTrue(!RefQual.IsHandle() && HandleQual.IsHandle(), TEXT("handle is a QualType bit")));
		ASSERT_THAT(IsTrue(RefQual != HandleQual, TEXT("handle distinguishes QualType identity")));

		const asCQualType ValueQual = Bridge.FromDataType(Context, MakeHostDataType(ScriptEngine, "FValue"));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_VALUE_OBJECT, (int)Context.GetType(ValueQual.type)->kind,
			TEXT("asOBJ_VALUE interned as VALUE_OBJECT, not from missing handle")));
		ASSERT_THAT(IsTrue(!ValueQual.IsHandle(), TEXT("value object is not a handle by default")));
	}
```

Do not force `MakeHandle` on `FValue` (value types reject handles unless `asOBJ_ASHANDLE`).

---

## Task 2 — prove RED

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-26-red -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type" -Label wave-c-26-red -TimeoutMs 600000
```

Expected: the six **existing** methods stay PASS. The six **new** methods RED (enum invalid; funcdef/array wrong kind and/or key; null handle invalid; identity fails because enum does not intern).

If UBT is busy, write the tests, stop, record the lock in `wave-c-results.md`. Do not start a second build.

This inventory dispatch does **not** run those commands.

---

## Task 3 — minimal bridge (GREEN)

`as_runtime_type_bridge.cpp` only (plus test file already in Task 1).

`FromDataType`:

1. Build `quals` from const/handle/ref as today.
2. If `IsNullHandle()`: `return context.InternPrimitive(ttVoid, asAST_QUAL_HANDLE);` (ignore const/ref).
3. If `GetTypeInfo()` non-null: classify by flag order ENUM → FUNCDEF → TEMPLATE → REF → VALUE; intern `InternNamedType(kind, StableKey, quals)`.
4. Else if `ttVoid` or `IsPrimitive()`: existing `InternPrimitive`.
5. Else invalid.

`StableKey`: Format a copy with const/handle/ref cleared and `includeNamespace == true`. Empty key → invalid QualType.

`FindRuntimeTypeInfo`: `GetTypeInfoByDecl(key)` before `GetTypeInfoByName(key)`.

Do **not**:

- add fields to `asCQualType` / `asCType`
- change `asASTQualifiersAreValid`
- teach Sema named kinds (4.3)
- encode sidecar kinds (6.3)
- require CALL-without-callee or touch the verifier
- use Unreal `UObject` / `FVector` as fork types (tests register script names `CObj` / `FValue` / `ETeam` only)

`Resolve` may still `MakeHandle(true)` for `asOBJ_REF` / `asOBJ_FUNCDEF` (pre-existing). Do not assert handle-bit equality on REF/FUNCDEF round-trips. Do assert `GetTypeInfo()` identity on the live Engine and `kind`/`stableKey` on the QualType.

---

## Task 4 — prove GREEN

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-26-green -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type" -Label wave-c-26-green -TimeoutMs 600000
```

Expected: Type prefix all PASS (6 old qualifier/intern methods + 6 new bridge methods). Production default still LEGACY; `Ready()` false.

Optional extra (same exclusive UBT slot, after Type is green): Frontend CanonicalAST is **not** required to close 2.6 and must not be used to fight C-28 verifier work.

Record counts in `attachments/wave-c-results.md`.

---

## Close criteria (task 2.6)

**Implementer must not check `tasks.md` 2.6 until named types intern with the right kind AND QualType identity has no engine pointer.** Both clauses. Kind-only with a stored `typeId`, or pointer-free `VALUE_OBJECT` for enums/funcdefs/templates, is still `[ ]`.

May check 2.6 **only if all** of:

- [ ] Host `RegisterEnum("ETeam")` → `asAST_TYPE_ENUM`, key `"ETeam"`; `Game::ETeam` → key `"Game::ETeam"`; they do not intern as one type
- [ ] Host `RegisterFuncdef("void FCallback()")` → `asAST_TYPE_FUNCDEF`, **not** `REFERENCE_OBJECT`
- [ ] Host `array<class T>` + `GetTypeInfoByDecl("array<int>")` without `Build()` → `asAST_TYPE_TEMPLATE`, key `"array<int>"` not `"array"`; `Resolve` returns that instance
- [ ] Handle is a QualType bit; `asOBJ_REF` / `asOBJ_VALUE` choose `REFERENCE_OBJECT` / `VALUE_OBJECT`; handle does not change kind
- [ ] `CreateNullHandle()` intern-equals `InternPrimitive(ttVoid, asAST_QUAL_HANDLE)`; existing illegal-void tests still PASS
- [ ] `sizeof(asCQualType) == sizeof(asUINT)+sizeof(asDWORD)`; interned `asCType` survives `Engine.Destroy()`; `stableKey` has no `0x` and is not `GetTypeId()`
- [ ] The six pre-existing Type TEST_METHODs are unchanged and still PASS
- [ ] No `asCTypeInfo*` / `typeId` member on `asCQualType` or `asCType`; no Unreal types in fork files; no Clang/LLVM
- [ ] Type prefix green after `RunBuild` from `D:\as-cta` with `-NoXGE`
- [ ] Production default still LEGACY; `Ready()` false; `Build()` still `asCCompiler`

Still **do not** check 4.3 / 5.9 / 6.3 / 2.8 / 13.5 / 13.2 / 9.5 / 13.6 / section 10 from these greens.

---

## Out of scope / hard no

| Do not | Why |
| --- | --- |
| Reopen qualifier intern tests or rewrite `asASTQualifiersAreValid` | Already landed; 2.6 why-open qualifier bullets are stale |
| Store `asCTypeInfo*` or numeric typeId on QualType/`asCType` | Spec + R02/R08: public/cache identity is intern id + key |
| `as_sema_decl.cpp` named-kind from handle bit | Task 4.3 |
| Sidecar `InternNamedType(VALUE_OBJECT, …)` | Task 6.3 |
| Production `Build()` / `Generate()` / Ready / CANONICAL default | Wave D / section 10 |
| CALL-without-callee, verifier publication, cleanup-plan POD fields | C-28 / 5.8 |
| Clang QualType, LLVM types, Unreal `UObject` in fork files | Global constraints |
| Second UBT while C-28 or Editor/MSBuild owns the machine | One UBT user |

**Exclusive UBT for implementation starts only after C-28 reports Verifier + Frontend CanonicalAST green without CALL-without-callee.** Until then this file is the ready-to-execute plan, not a license to compile.
