# Wave D sixth-pass F1 remainder — later exclusive-UBT TDD slice

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research brief for a **later** exclusive UBT package. **Do not implement in the research package that wrote this file.**

Flags slice is **landed**. Do **not** redo it. Do **not** check `tasks.md` 9.5 / 13.2 / 13.3 / 10.2 / 9.1 / 13.6. Do **not** archive. Do **not** flip default CANONICAL.

Exclusive UBT at the time this brief was written is **F4 execute** (`wave-d-f4-exec-next.md`). Do **not** start this remainder while that agent owns ProductionCodeGen / `as_bytecode_codegen.cpp`.

Default pipeline stays LEGACY. Tests **SetCompilerPipeline(CANONICAL)** only. No Clang/LLVM. No Unreal types in fork frontend files. No script `funcdef` / `@` / `is`. `nullptr` = `ttNull`.

Stale companions (do **not** implement from them):

- `attachments/wave-d-95-f1-next.md` — still talks about 8 methods / empty-list-before-globals.
- `attachments/wave-d-95-f1-refresh.md` — still talks about 16 methods / atoi globals.
- Sixth-pass review F1 class-as-VALUE — **closed by flags**. Remainder below is what is still open.

Live ProductionCodeGen file currently has **33** `TEST_METHOD`s, including landed `CanonicalScriptClassRegistersRefImplicitHandleNotValue`. Keep that method. Do not weaken execute-42 rows.

---

## Why flags GREEN does not close F1

Landed (do not touch as a flags redo):

- Sema `as_sema_decl.cpp:1074-1077`: `snClass` with `tokenType == ttStruct` gets `asAST_TRAIT_VALUE`.
- CodeGen `RegisterCanonicalScriptTypes` (`as_bytecode_codegen.cpp:2453-2463`): `class` → `asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`, `size = -1`; `struct` → `asOBJ_VALUE | asOBJ_SCRIPT_OBJECT | asOBJ_NOINHERIT`, `size = 0`. Copied `scriptTypeBehaviours` + AddRef on factory/copy/construct like legacy Builder.

Existing VALUE fixtures use **`struct FValue`**, not `class`. That is why 25/25 (now 33 methods) and F1-class-as-VALUE could coexist. The flags test already locks class vs struct. This remainder is **layout, fail-closed property, nested namespace, host collision**.

Sixth-pass remainder (still open):

1. Final **alignment assigned 4**; size rounding is not a first-class max-property-alignment layout (legacy floor is 8).
2. Property type parse / `AddPropertyToClass` failure is silent **`continue`** (Build may still succeed with dropped fields).
3. Nested-namespace class is **not** registered by the direct-TU scan.
4. Bare-name host/other-module type: skip create + `GetTypeInfoByName` fallback can bind methods onto an existing host type (`FindCanonicalObjectType` / `FillFunctionSignature`).

Not this slice: F2 atoi (landed), F3 RDR4 (landed), F4 capture execute, F5 LEGACY lambda, F6 atomic install, verifier/Cache/snapshot, default CANONICAL, 9.5 / 13.2 check.

---

## Live vs legacy map (quote today)

### Legacy oracle — `as_builder.cpp`

**Register + flags** (`RegisterClass`, 2692-2943; flags 2853-2883):

- Recursed from `RegisterTypesFromScript` (1362-1394). `snNamespace` computes `nsName`, `engine->AddNameSpace`, then **`RegisterTypesFromScript(node->lastChild, script, nsChild)`**. Nested class is registered with that namespace.
- `CheckNameConflict(name, n, file, ns)` (2236-2260) **WriteError** if `allRegisteredTypesByName` already has the same name in the **same namespace** (`TXT_NAME_CONFLICT_s_EXTENDED_TYPE`). Host twin is a compile error, not reuse.
- New type: `st->flags = asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_NOCOUNT`; struct then `&= ~(asOBJ_REF | asOBJ_NOCOUNT)`, `|= asOBJ_VALUE | asOBJ_NOINHERIT`; class then `|= asOBJ_IMPLICIT_HANDLE`.
- `st->size = -1` as **not-yet-laid-out sentinel** for both. `st->nameSpace = ns`. `asCObjectType` ctor sets **`alignment = 8`** (`as_objecttype.cpp:51,60`), overriding `asITypeInfo::alignment = 4` (`Core/angelscript.h:1359`).
- `st->beh = engine->scriptTypeBehaviours.beh`; struct clears factory; class AddRefs factory; both AddRef copy/construct.
- `engine->allScriptDeclaredTypes.Add(st)` — **not** `allRegisteredTypesByName`.

**Properties** (`CompileClass` 4010-4038, `asCBuilder::AddPropertyToClass` 4689-4725):

- `CreateDataTypeFromNode` reports errors; `!dt.CanBeInstantiated()` **WriteError** and returns 0. Build fails. No silent drop.

**Layout** (`LayoutClass` 4105-4209):

- Resets size from derived/shadow/`basePropertyOffset`, else **`ot->size = 0`** (the `-1` sentinel is not used as a starting offset).
- Per property: pad `ot->size` to `prop->type.GetAlignment()`, store `byteOffset`, add `propSize`.
- Alignment is raised in `asCObjectType::AddPropertyToClass` (660-662): `if (propAlignment > alignment) alignment = propAlignment`. Combined with ctor floor **8**, int-only objects stay align-8; double does not reduce alignment.
- Tail: `if (ot->alignment != 1) ot->size = (ot->size + ot->alignment - 1) & ~(ot->alignment - 1)`.
- Oracle for `struct { double High; int Low; }`: High@0, Low@8, **size 16**, **alignment 8**.

### Canonical live — `as_bytecode_codegen.cpp`

**`FindCanonicalObjectType`** (200-219):

```text
module->classTypes[n]->name == name          // bare name, no namespace
then engine->GetTypeInfoByName(name)         // first allRegisteredTypesByName hit
```

No `module` ownership check. No namespace. Host and other-module types are legal hits.

**`RegisterCanonicalScriptTypes`** (2419-2533):

1. Only **`tu->children`**. `kind != asAST_DECL_CLASS` → `continue`. Sema puts `namespace Game { class NestedActor {} }` under `asAST_DECL_NAMESPACE` (`as_sema_decl.cpp:1061-1067, 1073-1079`), so NestedActor is **not** a TU child.
2. If `GetTypeInfoByDecl(name) || GetTypeInfoByName(name)` → **`continue`** (no create, no error). Host same bare name is skipped.
3. `st->alignment = 4` **after** the object-type ctor’s 8.
4. `st->nameSpace = module->defaultNamespace` always (nested ns identity discarded even if a later walk is added without a fix).
5. Property loop (2493-2518): `member->kind != asAST_DECL_VAR` skip; `bridge.Resolve` invalid → **`continue`**; `AddPropertyToClass == 0` → **`continue`**. Function still **`return true`**. `Generate` treats only `false` as `asOUT_OF_MEMORY` (2728-2733).
6. Layout uses current `st->size` as the running offset. REF classes still start at **`size = -1`**; `(asUINT)(-1)` padding is not LayoutClass’s reset-to-0.
7. CodeGen layout loop does **not** itself `st->alignment = max(st->alignment, propAlignment)`. Rounding uses `st->alignment` after the `AddPropertyToClass` side-effect.
8. Then `engine->allRegisteredTypesByName.Add(st)` + `module->classTypes` + `allLocalTypes` + `artifact.types`. Types are live **before** emission. `Abandon` only `types.SetLength(0)` (2652-2653) — F6, out of this slice except **fail before registry insert**.

**`FillFunctionSignature`** (2579-2614):

- METHOD/CTOR/DTOR whose parent is `DECL_CLASS` → `FindCanonicalObjectType(engine, module, parent->name)`.
- On hit: `func->objectType = objType`, AddRefInternal, **`beh.construct = func->id`**, `constructors[]`, **`beh.destruct`**, **`methods.PushLast`**, **`methodTable.Add`**.
- If Register skipped the script class, this binds generated ctor/dtor/GetValue onto the **host**.

Sema still `EnsureGeneratedLifecycle` / `EnsureGeneratedAccessors` for every class (`as_sema_decl.cpp:1080-1081`). A colliding `class HostTwin { int Value; }` always produces generated methods that `FillFunctionSignature` will attach to whoever `FindCanonicalObjectType("HostTwin")` returns.

`CanonicalDeclIsSupportedForCodeGen` (38-56) **includes** `asAST_DECL_NAMESPACE` and `CLASS`. Nested-namespace modules do **not** fail the preflight; they succeed with a missing class.

`asCSema::ActOnQualType` (`as_sema_decl.cpp:328-369`): unknown name is interned as `VALUE_OBJECT` named type, not a Sema error. `asCRuntimeTypeBridge::Resolve` (`as_runtime_type_bridge.cpp:91-96`) then returns an invalid `asCDataType` if the engine has no such type — which is the CodeGen `continue`.

---

## TDD order (four methods, this order)

Same class: `FCanonicalASTProductionCodeGenTests`.
File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`.

Keep the live **33**. Append these **four**. Expected discovered count after the add: **37**.

Every method:

- Assert default engine pipeline is still `asCOMPILER_PIPELINE_LEGACY`.
- Then `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)`.
- `ON_SCOPE_EXIT { Engine.Destroy(); }` — host-collision must not crash teardown.
- Successful CANONICAL install → publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`.
- Fail-closed → `BuildResult < 0`; if `Module != nullptr`, publisher ≠ `COMPILER`.
- Do **not** assert `BuildResult == 0` unconditionally on rows that allow fail-closed.

Do not add `as_objecttype.h` to the fork. Existing `as_module.h` / `as_scriptengine.h` already expose `asCObjectType`. `asITypeInfo::alignment` is a public field (`Core/angelscript.h:1359`). `GetSize()` / `GetProperty()` are enough for layout.

### 1. First RED — `CanonicalUnknownPropertyBuildFailsClosed`

**Recommended first TDD method.** Forces the property-loop `continue`, not the generated-accessor `FillFunctionSignature` fail.

Trap: Sema still emits `GetField`/`SetField` with type `MissingType`. Those methods hit `FillFunctionSignature` `asINVALID_DECLARATION` today (`2546-2559`), so a naïve `struct { MissingType Field; }` may already **fail-closed via accessors** and hide the `continue`. Provide **user** `GetField`/`SetField` so `EnsureGeneratedAccessors` skips (`ClassHasNamedMethod`).

Exact script:

```as
struct FBroken
{
	MissingType Field;
	int Value;
	int GetField() { return 0; }
	void SetField(int value) {}
}

int F()
{
	FBroken Object;
	Object.Value = 41;
	return Object.Value + 1;
}
```

Exact asserts:

- Default LEGACY, then CANONICAL.
- `BuildResult == 0` **implies**:
  - publisher `CANONICAL_CODEGEN`;
  - `FBroken` in `classTypes`;
  - `GetPropertyCount() >= 2` and one property name is `"Field"` (not dropped);
  - `int F()` execute **42** (do not weaken if Build succeeded).
- `BuildResult < 0` is allowed (honest fail-closed). Publisher ≠ `COMPILER`.
- Forbidden: `BuildResult == 0` with only `Value` installed.

**Honest prediction on today’s codegen: RED.** `Resolve("MissingType")` is invalid → `continue` → `Value` still lands → Commit OK → execute 42 with Field dropped.

Fix: any property Resolve / `AddPropertyToClass` failure → whole `RegisterCanonicalScriptTypes` fails **before** `allRegisteredTypesByName` / `classTypes` insert; `Generate` maps that to a real error (not `asOUT_OF_MEMORY`); `asDELETE` the half-built `st` and ReleaseInternal the copied behaviours. Do not `continue`.

### 2. `CanonicalValueObjectDoubleIntLayoutMatchesLegacy`

Lock `double` + `int` layout. Do **not** use execute-only: a size-12 object can still read `Low` on a single local.

Exact script:

```as
struct FPacked
{
	double High;
	int Low;
}

int F()
{
	FPacked Object;
	Object.Low = 41;
	return Object.Low + 1;
}
```

Exact asserts (Build must succeed for this VALUE struct — same family as live `FValue`):

- publisher `CANONICAL_CODEGEN`.
- `FPacked` in `classTypes`; flags still `asOBJ_VALUE` (do not redo class-as-REF).
- `GetPropertyCount() == 2`.
- Property `"High"` offset **0**; `"Low"` offset **8** (`GetProperty(..., &offset)`).
- `GetSize() == 16`.
- `alignment == 8` (legacy floor 8 + `alignof(double)`).
- Execute `F()==42` **in addition to** the layout asserts (do not replace layout with execute).

**Honest prediction: possibly GREEN.** `AddPropertyToClass` already bumps `alignment` when `propAlignment > 4`, so double may raise 4→8 and tail-round 12→16 even though CodeGen still **assigns** 4 and the layout loop never `max`es alignment itself. Keep the test either way. If GREEN, still fix the hardcoded `st->alignment = 4` and start size from LayoutClass’s 0, not REF `-1`, so int-only objects keep legacy align-8/size-8 and REF layout does not pad from `0xFFFFFFFF`.

Do **not** expand this method into inheritance/shadow/mixin. That stays later F1.

### 3. `CanonicalNestedNamespaceClassInstallsOrFailsClosed`

Exact script:

```as
namespace Game
{
	class NestedActor
	{
		int Value;
	}
}

int F()
{
	return 1;
}
```

Exact asserts:

- Default LEGACY, then CANONICAL.
- `BuildResult == 0` **implies**:
  - publisher `CANONICAL_CODEGEN`;
  - a module class type named `"NestedActor"` whose `GetNamespace()` is `"Game"` (lookup via `SetDefaultNamespace("Game")` + `GetTypeInfoByName("NestedActor")`, or `GetTypeIdByDecl("Game::NestedActor") >= 0`);
  - flags `asOBJ_REF | asOBJ_IMPLICIT_HANDLE`, not `asOBJ_VALUE`;
  - `GetFunctionByDecl("int F()")` is the unique global;
  - no NestedActor method/ctor pointer on `globalFunctionList`.
- `BuildResult < 0` allowed. Publisher ≠ `COMPILER`.
- Forbidden: `BuildResult == 0` with NestedActor missing, or NestedActor registered in `""` while methods leak as globals.

**Honest prediction: RED.** TU-direct scan never sees the class. Generated ctor/GetValue/SetValue then either become globals (`objectType == 0`) or bind a bare-name host via `FindCanonicalObjectType`.

Fix: walk every `asAST_DECL_CLASS` (or recurse namespace children). Set `nameSpace` from the parent `asAST_DECL_NAMESPACE` chain through `engine->AddNameSpace`. Do not invent script `@`.

### 4. `CanonicalSameNameHostTypeIsNotMutated`

Must **not** mutate host behaviour tables.

Register a host REF type **before** Build (reuse `ProdCanonicalHandleAddRef` / `ProdCanonicalHandleRelease`):

```cpp
ScriptEngine->RegisterObjectType("HostTwin", 0, asOBJ_REF);
ScriptEngine->RegisterObjectBehaviour("HostTwin", asBEHAVE_ADDREF, "void f()", asFUNCTION(ProdCanonicalHandleAddRef), asCALL_GENERIC);
ScriptEngine->RegisterObjectBehaviour("HostTwin", asBEHAVE_RELEASE, "void f()", asFUNCTION(ProdCanonicalHandleRelease), asCALL_GENERIC);
ScriptEngine->RegisterObjectMethod("HostTwin", "int HostMarker()", asFUNCTION(ProdCanonicalHostMarker), asCALL_GENERIC);
```

`ProdCanonicalHostMarker` is a new file-local generic that `SetReturnDWord(7)`. Snapshot **before** Build:

- `asITypeInfo* const Host = ScriptEngine->GetTypeInfoByName("HostTwin")`;
- `HostMethodCount = Host->GetMethodCount()`;
- `HostMarker = Host->GetMethodByDecl("int HostMarker()")`;
- `HostConstruct` / `HostDestruct` via `GetBehaviourByIndex` or `asCObjectType::beh.construct` / `beh.destruct`;
- `HostMethodsLength` from `asCObjectType::methods`.

Exact script:

```as
class HostTwin
{
	int Value;
}

int F()
{
	return 1;
}
```

Exact asserts **after** Build, regardless of success or fail-closed:

- `Host` pointer identity unchanged; `GetModule() == nullptr`.
- `GetMethodCount()` == snapshot; `GetMethodByDecl("int HostMarker()")` == snapshot pointer.
- `GetMethodByName("GetValue")` is **not** a new script function (still null / still the pre-Build pointer).
- `beh.construct` / `beh.destruct` / `methods.GetLength()` unchanged on the host object type.
- `Engine.Destroy()` must return (no `ReleaseAllFunctions` crash).

Plus the install contract:

- `BuildResult == 0` **implies** a **distinct** `module->classTypes` entry named `"HostTwin"` with `GetModule() == Module` and pointer **≠** `Host`; publisher `CANONICAL_CODEGEN`.
- `BuildResult < 0` allowed (legacy `CheckNameConflict` is fail-closed). Publisher ≠ `COMPILER`.
- Forbidden: skip-create + bind generated ctor/GetValue onto `Host`.

**Honest prediction: RED.** Skip-create at 2442-2447, then `FindCanonicalObjectType` returns the host, then `FillFunctionSignature` writes `beh.construct` / `methods` / `methodTable`. Teardown may crash; that is still RED.

Fix:

- Treat existing engine type in the same namespace as **conflict** (legacy `CheckNameConflict`), not reuse.
- `FindCanonicalObjectType` only searches **this module’s** `classTypes` with matching namespace. **Delete** the `engine->GetTypeInfoByName` fallback for owner bind.
- `FillFunctionSignature` must refuse `objType->module != module` (and refuse `objType->engine` registered types with `module == 0`).

Do not use script `funcdef` / `@`. Do not name the host `CObj` (handle fixture).

---

## Files to touch (later implementer)

| File | Why |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` | Append the four methods. Keep flags / FValue owner / global-only / enum-only. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` | `RegisterCanonicalScriptTypes`, `FindCanonicalObjectType`, `FillFunctionSignature`. Property fail-closed; layout floor/max/tail; namespace walk + `nameSpace`; no host fallback. |
| `as_sema_decl.cpp` | **Only if** class decls do not already parent under the namespace (they do today). Prefer CodeGen-only. |

Do **not** edit `as_builder.cpp` (it is the oracle). Do **not** edit `tasks.md` checkboxes. Do **not** add Unreal types to the fork. Do **not** start F6 atomic-install, F4 capture, or F5 LEGACY lambda here.

Suggested CodeGen shape (after RED exists; not a license to implement in research):

1. Collect all `asAST_DECL_CLASS` (namespace-aware), not only `tu->children`.
2. For each: same-namespace engine type → fail (not `continue`).
3. Create type with **already-landed** class/struct flags. Leave ctor `alignment = 8`. `size = 0` for layout start (LayoutClass), including REF.
4. Resolve **every** `DECL_VAR` member; any invalid type / `AddPropertyToClass == 0` → destroy `st`, return fail. No `continue`.
5. Pad offsets by property alignment; `st->alignment = max(st->alignment, propAlignment)`; tail-round size to `st->alignment`.
6. Only then insert engine/module registries.
7. Owner lookup: module + namespace only.

---

## Verification (later exclusive UBT only)

From `D:\as-cta` only. Always `-NoXGE` after touching tests. Timeout ≤ `600000`. Do **not** run these in the research package. Do **not** run against `D:\Workspace\AngelscriptProject`.

TDD: add method 1 first, build/test RED, then fix property `continue`. Then method 2, 3, 4 in that order. Do not batch-green by weakening asserts.

If the new methods fail, label **`d-f1-rem-red`**. After production fix, label **`d-f1-rem`**.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d-f1-rem-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d-f1-rem-red -TimeoutMs 600000
```

GREEN twin (same prefix, after the four are expected PASS):

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d-f1-rem
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d-f1-rem -TimeoutMs 600000
```

Expect **37** discovered methods (33 current + 4). Predicted: existing 33 PASS (F4 sibling-lambda execute may still be RED if that UBT has not finished — do **not** start this remainder until ProductionCodeGen is free and that row is decided). These 4: method 1 RED, method 2 maybe GREEN, method 3 RED, method 4 RED.

Either GREEN still leaves **9.5 / 13.2 `[ ]`**. F1 is not closed until property fail-closed, layout oracle, nested ns, and host non-mutation all hold. Shared/final/abstract/UE shadow/base layout/interface/enum-in-CodeGen remain later F1, not this slice.

---

## Hard constraints

- Leave `tasks.md` **9.5 / 13.2** (and 9.1 / 13.6 / 13.3 / 10.2) unchecked.
- Default `ep.canonicalCompilerPipeline` stays LEGACY.
- Do not redo `CanonicalScriptClassRegistersRefImplicitHandleNotValue` or Sema `asAST_TRAIT_VALUE`.
- Do not invent script `funcdef` / `@` / `is`.
- Do not run UBT / `RunBuild.ps1` / `RunTests.ps1` while writing or refreshing this attachment.
- This attachment is not an implementation license to edit `Plugins/` from the research package.
- F6 live-type mutation / `Abandon` remains open; property fail must not insert then leak. That is not a 13.6 close.
