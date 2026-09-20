# The missing cross-module TypeInfo holder

User: Image was not only a public SDK bag; it was the **intermediate owner of TypeInfo between compile units**, before Engine. After deleting `asCMetadataImage`, that ring was only hand-waved as “pending arrays on Builder.”

## What Image actually did for this job

```text
Builder A
 └─ TakeDefinitions() → asCMetadataImage A     // unique owner, Frozen
      engine == nullptr, TypeId == -1
      别人不拥有它

Builder B
 └─ Options.Dependencies = { Image A* }      // 非拥有
    └─ AddExternalDefinitions 闭包
         └─ 用 A 的 TypeInfo 当 ExternalTypes

统一 Registration 之前
  所有 Image UniquePtr 必须还活着
```

That is **not** `asCCompileOutput` (UE/诊断). It is **not** Engine. It is a takeable, frozen, engine-free unique owner per compile unit, with an acyclic DAG.

## What the shrink currently says (the hole)

```text
asCBuilder
 ├─ pending TypeInfo* 数组          // 没有独立产品，不能 Take 给下一模块
 └─ asCCompileOutput                // 明确不背 TypeInfo
```

If Builder A is destroyed, B’s `TypeInfo*` dangle. Registration has no typed list of units to Install. The DAG has no node type.

## Replacement job (narrow)

One object per compile unit that:

- uniquely owns that unit’s TypeInfo / Function / Global until Registration
- can be Frozen so later Builders may depend on it
- does **not** grow BoundTypeIds / Attached / Engine.metadataImages
- is consumed (objects move to Engine) at the one batch Install

Settled name: `asCModuleDefinitionSet`. One compile unit’s unique owner of TypeInfo / Function / Global (stable bytecode on the functions). `asCBuilder` holds `TUniquePtr` until Take. Later Builders depend with a non-owning pointer. Batch Registration consumes the UniquePtrs. Not `asCModule`, not `asCCompileOutput`.
