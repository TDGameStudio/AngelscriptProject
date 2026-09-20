# Compile without Engine, then one Registration

User: compile everything first, register into the Engine once at the end.

That matches delayed registration. Engine is not the compile-time type library.

## Where types are created today

```text
asCBuilder(Snapshot, Diagnostics, Options)     // 这个构造函数没有 Engine
 └─ DefinitionConsumer.Consume(Session)
      └─ Image.CreateObjectType / CreateFunction   // engine == nullptr，TypeId == -1
         └─ Freeze
              └─ 别人可以当 Dependencies（仍无 Engine）

asCBuilder(Engine, Module)                     // 旧模块路径；宿主 Stage1 已关掉
```

Sema looks up names in the session (`asCType`, `ExternalTypes`), not `Engine.GetTypeInfo`. Emit uses StableKey. Layout uses Image/TypeContext options. `asCDataType` still has a leftover `typeInfo->engine` fallback for array formatting; the metadata path prefers Image options.

Engine construction is a different story: `InitializeMetadataBuiltins` builds `$obj`/`$func` on an Image and **immediately** `RegisterMetadataImage`. That is Engine bringing up its own builtins, not user script compile.

## User model (recommended)

```text
无 Engine
  按 DAG 波次编完所有脚本单元
    ├─ 每个 Builder 造出 TypeInfo/Function + 稳定字节码
    └─ 后波次引用前面的 TypeInfo*（不拥有）

有 Engine（一次）
  asCEngineCompileRegistration
    ├─ Install 整片闭包
    └─ Link 全部脚本 body          // 声明齐了才降 runtime 码
```

Do **not** require “compile A → Register A → compile B”. That makes Engine the type library again.

Two limits:

1. Cross-unit DAG stays acyclic (today `AddDependency` rejects cycles). Mutual `A::T` / `B::U` must sit in **one** snapshot/session, or fail.
2. Native/bind types (UClass, `FString`) are still produced by BindInfo and today land on an Engine at bind Install. Out of this SDK slice. Script-to-script does not wait on that.

## Who holds the forest until that one Registration

Not `asCCompileOutput` (descriptions only). The pending TypeInfo/Function objects must stay alive (Builders kept, or Registration given the list of pending sets). After Install, Engine owns them.

## Incremental later (not the full-build path)

If an Engine already has types, a later Builder may take those Engine TypeInfo* as externals (Q19). That is hot-add one unit, not “register after every module in a full compile.”
