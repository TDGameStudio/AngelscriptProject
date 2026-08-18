# Who implements each DSL call

Companion to `authoring-examples.md` (what bind files look like) and `angelscript-type-adapter.md` (`Adapter` / `DefaultArrayType`). This file walks **every** call in `RegisterTArray` / `RegisterFVector` and names the owner.

`Bind_TArray.cpp` / `Bind_FVector.cpp` **author**. They do not implement the DSL, do not call `asIScriptEngine`, and do not `MakeShared` adapters.

## Four layers

```text
1. Authoring     Bind_TArray.cpp          writes RegisterTArray(Store)
2. Recorder      FAngelscriptTypeBindInfoStore / FAngelscriptTypeBindInfo
                 Expand: append rows + members. No asIScriptEngine.
3. Apply         FAngelscriptTypeBindInfoApply (new)
                 each engine: RegisterObjectType / RegisterObjectMethod /
                 MakeShared adapter / RegisterDefaultArrayType / JIT native form
4. Existing impl already in the tree, not rewritten by this change:
                 FAngelscriptArrayType, FArrayOperations, ValidateArrayTemplate,
                 asCScriptEngine, FScriptFunctionNativeForm, FAngelscriptDocs,
                 FAngelscriptType::Register
```

Today `FAngelscriptBinds::Method` **is** layer 3 (it immediately `RegisterObjectMethod`). After this change, `TArray_.Method` is layer 2; layer 3 runs later.

Today `FAngelscriptBoundFunction` holds a live `FunctionId` / `asIScriptFunction*` so `.PassScriptObjectTypeAsFirstParam()` can poke `sysFuncIntf`. After this change the same chained calls mutate the **member record**. Apply copies those flags onto the new `asIScriptFunction` of **this** engine.

## `RegisterTArray` call by call

### Type row

| Call | Expand records | Apply (each engine) | Existing work that stays |
|---|---|---|---|
| `Store.Value<FScriptArray>("TArray<class T>")` | New row: name=`TArray`, kind=Template, native layout=`FScriptArray`, size=`sizeof(FScriptArray)`, alignment=`alignof(FScriptArray)`, plus `asGetTypeTraits<FScriptArray>()` | `asIScriptEngine::RegisterObjectType("TArray<class T>", size, asOBJ_VALUE\|asOBJ_APP_CLASS\|asOBJ_TEMPLATE\|traits)` | Today's `ValueClassForTarget<FScriptArray>` |
| `.Template("<T>")` | Template arg string; sets `asOBJ_TEMPLATE`; display name becomes `TArray<T>` after the engine parses `TArray<class T>` | Same post-register name fix as `ValueClassForTarget` when `Flags.bTemplate` | AngelScript template object type |
| `.ExtraObjectFlags(asOBJ_TEMPLATE_SUBTYPE_COVARIANT)` | Extra flags on the TypeDecl member | OR'd into `RegisterObjectType` flags | AngelScript object flags |
| `.DefaultArrayType()` | `bDefaultArrayType=true` | `RegisterDefaultArrayType("TArray<T>")` + `TypeDB.ArrayTemplateTypeInfo = GetTypeInfoByName("TArray")` | `as_scriptengine.cpp` + `FAngelscriptTypeDatabase` — see `angelscript-type-adapter.md` |
| `.Adapter<FAngelscriptArrayType>()` | Factory `MakeShared<FAngelscriptArrayType>` | `FAngelscriptType::Register(ThisEngine.TypeDB, MakeShared<…>())` | **`FAngelscriptArrayType`** in `Bind_TArray_Type.cpp` |
| `.TypeFinder(&FindTArrayProperty)` | Function pointer (process C++ identity) | `FAngelscriptType::RegisterTypeFinder(ThisEngine.TypeDB, Fn)` | `FindTArrayProperty` body stays in `Bind_TArray.cpp`; it runs at **property walk / Apply time**, not Expand. It must use **this** engine's TypeDB (`Usage.GetApplyTypeDatabase()`), never a recording TypeDB. |

`Store.Value<T>(Name)` is the **type declaration**. It is the only call that becomes `RegisterObjectType`. Adapter is TypeDB. DefaultArrayType is the language default-array hook.

### Members (template row → `EApplySlot::Infrastructure`)

| Call | Expand records | Apply | Existing work that stays |
|---|---|---|---|
| `.Constructor("void f()", FUNC_TRIVIAL(FArrayOperations::Construct))` | Member Kind=Constructor, decl string, `asSFuncPtr` + caller | `RegisterObjectBehaviour(…, asBEHAVE_CONSTRUCT, …)` | `FArrayOperations::Construct` in `Bind_TArray.h` |
| `.Destructor("void f()", &FArrayOperations::Destruct)` | Kind=Destructor, callable | `RegisterObjectBehaviour(…, asBEHAVE_DESTRUCT, …)` | `FArrayOperations::Destruct` |
| `.TemplateCallback("bool f(int&in Type, int&out ErrorMessage)", &ValidateArrayTemplate)` | Kind=TemplateCallback, callable | `RegisterObjectBehaviour(…, asBEHAVE_TEMPLATE_CALLBACK, …)` | `ValidateArrayTemplate` / `ValidateArrayOperations` in `Bind_TArray.cpp` — still runs when **this** engine instantiates `TArray<FVector>` |
| `.Method("void Add(…)", &FArrayOperations::Add)` | Kind=Method, decl still contains placeholder `T`, callable | `RegisterObjectMethod("TArray", decl, ptr, …)` | `FArrayOperations::Add` (VM thunk; reads `FArrayOperations*` userdata on the **specialization**) |
| `.Property("bool CanProceed", &FArrayIterator::bCanProceed)` | Kind=Property, offset | `RegisterObjectProperty` | `FArrayIterator` layout |
| `.Documentation(TEXT("…"))` | Doc string on the member | `FAngelscriptDocs::AddUnrealDocumentation(ThisEngine, newFunctionId, …)` | `FAngelscriptDocs` |

`FUNC_TRIVIAL` / `FUNC` / `METHOD_TRIVIAL` stay today's macros. They produce an `asSFuncPtr` + caller. TypeBindInfo stores that identity. No new metaprogramming, no auto-generated declaration strings.

### Chained flags on a member (today poke a live `asIScriptFunction`)

| Call | Expand records on the member | Apply copies onto **this** engine's `asIScriptFunction` | Existing work |
|---|---|---|---|
| `.PassScriptObjectTypeAsFirstParam()` | `FirstParamMeta = ScriptObjectType` | `sysFuncIntf->passFirstParamMetaData = ScriptObjectType` | AngelScript calling convention: inject `asCObjectType*` so `Add` can `GetArrayOperations(Meta)` |
| `.NativeTemplateInstantiatedCall("FArrayOperations::Add", trivial, needsCompare, needsCopy)` | Native recipe: kind=TemplateInstantiatedCall, name, three bools | `FScriptFunctionNativeForm::BindTemplateInstantiatedCall(ThisEngine, NewFn, …)` | StaticJIT native form. **Does not run** `Add_Template<T>` at Expand. JIT later instantiates when the specialization is known. |
| `.NativeTArrayIndex()` | Native recipe: kind=TArrayIndex | `FScriptFunctionNativeForm::BindTArrayIndex` | StaticJIT `opIndex` |
| `.NativeTArrayIteratorCreate()` / `.NativeTArrayIteratorProceed()` | Native recipe: iterator create/proceed | matching `BindTArrayIterator*` | StaticJIT iterators |
| `.NativeConstructor` / `.NativeFunction` / `.NoDiscard` (FVector) | Same: flags + names on the member | today's `FAngelscriptBoundFunction` setters, but after `RegisterObjectMethod` | JIT / compiler traits |

`#if AS_CAN_GENERATE_JIT` stays an Apply-time compile switch, not an Expand branch that drops the recipe. Record the recipe always; Apply no-ops the native-form bind when JIT is off (same as today's `#else (void)Name`).

### Iterator rows

`Store.Value<FArrayIterator>("TArrayIterator<class T>").Template("<T>")` is a **second type row**, still written by `RegisterTArray`. Same for `TArrayConstIterator`. Each gets its own `Adapter<FAngelscriptArrayIteratorType>()` / `Adapter<FAngelscriptArrayConstIteratorType>()`. `#if AS_ITERATOR_DEBUGGING` destructor is a recorded member only in that configuration (compile-time, like today).

## What is stored vs what is created later

```text
Expand (once, no engine)
  TArray row: template decl + methods with placeholder T
  TypeFinder fn pointer
  Adapter factory
  Native recipes as strings/flags
  Callable: &FArrayOperations::Add  (C++ identity)

Apply (each asIScriptEngine)
  asITypeInfo* for template TArray
  asIScriptFunction* for Add / opIndex / …
  TSharedRef<FAngelscriptArrayType> in this TypeDB
  ArrayTemplateTypeInfo pointer

Script uses TArray<FVector> (this engine, later)
  AngelScript clones the template
  asBEHAVE_TEMPLATE_CALLBACK → ValidateArrayTemplate
  FArrayOperations userdata (element size, construct/copy flags)
  NOT a new TypeBindInfo row
```

## FVector vs TArray (same DSL, different inferred slot)

| DSL | FVector ApplySlot | TArray ApplySlot |
|---|---|---|
| `Store.Value` | Type | Type |
| `Adapter` / `TypeFinder` / `ToString` / `DefaultArrayType` | Infrastructure | Infrastructure |
| `Constructor` / `Method` / `Property` / `Constant` | **Members** | **Infrastructure** (template method surface must exist before other types' methods) |
| `TemplateCallback` | n/a | Infrastructure |

Inference is in the recorder (`Store.Value` that saw `.Template()` marks the row Kind=Template). Authoring does not stamp `.Infrastructure()` on every method.

## `FAngelscriptBind` ticket (not a DSL on the row)

```cpp
AS_FORCE_LINK const FAngelscriptBind Bind_TArray(
	TEXT("TArray"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterTArray);
```

CRT discovery only: name + kind + function pointer. No members. Expand looks up this ticket and calls `RegisterTArray(Store)`. Extra engines do not call it.

## Apply walk (why slots exist)

```text
for each row in DeclarationOrder:
  apply members with ApplySlot=Type          // RegisterObjectType
for each row:
  apply members with ApplySlot=Infrastructure  // adapter, default array, TArray.Add
for each row:
  apply members with ApplySlot=Members         // FVector.Size, UObject methods
```

AngelScript still forbids `RegisterObjectMethod` before `RegisterObjectType`. Template methods in Infrastructure still land before `FVector` methods, same as today's TypeInfrastructure phase — without a second `FAngelscriptBind`.
