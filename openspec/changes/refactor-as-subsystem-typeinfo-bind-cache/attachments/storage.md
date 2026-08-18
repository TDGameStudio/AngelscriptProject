# How TypeBindInfo is stored after the refactor

Process-lifetime native data on `UAngelscriptSubsystem`. Not `UPROPERTY`, not disk, not GameInstance, not `asITypeInfo*`.

## Owner

```text
UAngelscriptSubsystem                          // UEngineSubsystem
  FAngelscriptTypeBindInfoStore Store
    TArray<FAngelscriptTypeBindInfo> TypeBindInfos
    TMap<FName, int32>               TypeBindInfoIndexByName
    EState { Empty, Expanding, Sealed, Failed }
    TSet<EAngelscriptBindSurface>    ExpandedSurfaces
```

Lookup: `IndexByName.Find("FVector")` → `TypeBindInfos[i]`.

## One row = one script type

```text
FAngelscriptTypeBindInfo
  FName                         AngelscriptTypeName     // "FVector"
  EAngelscriptTypeBindKind      Kind                    // Value / ObjectHandle / Enum / Interface / Template / Namespace
  FAngelscriptBindCondition     Condition               // type-level visibility
  FAngelscriptAdapterRecipe     Adapter                 // how to rebuild FAngelscriptType on apply (not the live adapter object)
  FAngelscriptCppFormRecipe     CppForm                 // copied at record time
  TOptional<FSoftObjectPath>    UnrealType              // UClass / UScriptStruct / UEnum; never asITypeInfo*
  int32                         DeclarationOrder        // global apply order among types
  TArray<FAngelscriptTypeBindInfoMember> Members
```

`Hash::` functions live on `Kind=Namespace` row `"Hash"`. No second global array.

## One member = one recorded bind action

```text
FAngelscriptTypeBindInfoMember
  EMemberKind     Kind            // TypeDecl | Adapter | TypeFinder | ToString
                                  // Constructor | Destructor | Method | Property
                                  // Behaviour | StaticFunction | Constant | TemplateCallback
  EApplySlot      ApplySlot       // Type | Infrastructure | Members
  FString         Declaration     // AS signature string
  FAngelscriptCallableIdentity  Callable   // asSFuncPtr / FUNC / property offset
  FAngelscriptNativeRecipe      Native     // .NativeFunction / header / trivial
  FAngelscriptBindCondition     Condition
  EAngelscriptBindSurface       VisibleOn  // EditorDevelopment | GameShipping | ...
  int32                         MemberOrder
```

`EApplySlot` is **only for Apply** into a live `asIScriptEngine`:

| Slot | Register* equivalent |
|---|---|
| `Type` | `RegisterObjectType` / `ValueClass` / `Enum` |
| `Infrastructure` | adapter, ToString, **template method surface** (`TArray.Add`) |
| `Members` | constructors, methods, properties, namespace functions, reflected UFunctions, Actor `Spawn` |

Recording does not call `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod`. A Register function may write Type + Infrastructure + Members in **one function**. Apply later walks all rows' `Type` members, then all `Infrastructure`, then all `Members`.

## What a filled `FVector` row looks like

```text
TypeBindInfos[i]  name=FVector  kind=Value  flags=POD|BASICMATHTYPE
  Members:
    { Kind=TypeDecl,     ApplySlot=Type,           Decl="FVector" }
    { Kind=Adapter,      ApplySlot=Infrastructure, Recipe=FVectorType }
    { Kind=ToString,     ApplySlot=Infrastructure, Fn=AppendToString }
    { Kind=TypeFinder,   ApplySlot=Infrastructure, NetQuantize* → FVector }
    { Kind=Constructor,  ApplySlot=Members,        Decl="void f(float64 X, float64 Y, float64 Z)", Callable=ConstructXYZ }
    { Kind=Property,     ApplySlot=Members,        Decl="float64 X", Offset=&FVector::X }
    { Kind=Method,       ApplySlot=Members,        Decl="float64 Size() const", Callable=METHOD_TRIVIAL(FVector, Size) }
    { Kind=Constant,     ApplySlot=Members,        Decl="const FVector ZeroVector", Addr=&FVector::ZeroVector }
```

## What is not stored

- `asITypeInfo*`, `asIScriptFunction*`, engine-owned objects
- A second array for "types" vs "methods"
- Finished rows as C++ `static` objects (CRT only stores `&RegisterFVector`)
- Per-engine copies of this array (each engine **reads** the sealed store and **writes** its own `asIScriptEngine` / TypeDB)

## Expand vs Apply vs extra Engine

```text
Expand  → write Store (once per bind surface this process needs)
Apply   → read Store, Register* into one asIScriptEngine
Engine2 → read Store again, Register* into another asIScriptEngine
```

## Why `TArray` if expand can be multithreaded

The store array is the **sealed catalog**, not the worker write buffer.

Multithread in this OpenSpec is expand-only:

```text
worker 0: private shard TArray + TMap     (RegisterFVector, …)
worker 1: private shard TArray + TMap     (RegisterFColor, …)
join
Game Thread: MergeShardsInto(Store.TypeBindInfos)
Store → Sealed
later engines: read-only walk TypeBindInfos by DeclarationOrder / ApplySlot
```

Workers never `TypeBindInfos.Add`. After `Sealed` the array is immutable; extra engines read it without a lock.

`TArray` + `TMap<FName,int32>` stays because Apply, dumps, and tests need a stable order and `give me FVector`. A concurrent hash map would not give `DeclarationOrder`, would not be the Apply walk, and UE has no `TConcurrentHashMap` we should copy for this. Details: `multithreaded-write.md`.