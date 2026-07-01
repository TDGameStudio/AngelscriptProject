# 对象引用与 GC 覆盖矩阵

> **本矩阵是对象引用/GC 测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 5 个测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持。
>
> - 测试文件：`Handle`(14) / `Handles`(10) / `WeakReference`(10) / `SoftReference`(11) / `GC`(12) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<Handle|Handles|WeakReference|SoftReference|GC>`
> - 图例见 `../coverage-matrix.md`；接口引用边界见 `../coverage-gaps.md §2.3`。

## 1. UObject handle 基础与操作（HandleTests）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| handle 声明/赋值基础 | ✅ | `HandleBasics` |
| handle 比较（==/!=/null） | ✅ | `HandleComparison` |
| Cast 与类型转换 | ✅ | `HandleCast` |
| handle 操作（GetClass/GetName 等） | ✅ | `HandleOperations` |
| handle 作属性 | ✅ | `HandleAsProperty` |
| handle 作参数 | ✅ | `HandleAsParameter` |
| handle 在容器中（数组/Set） | ✅ | `HandleInContainers` `HandleSetContainer` |
| 成员对象/Actor/组件引用 | ✅ | `MemberObjectActorComponentReferences` |
| NewObject 与 handle | ✅ | `UObjectHandleAndNewObject` `UObjectHandleAssignmentAndActorOuter` |
| 销毁 Actor 使引用失效 | ✅ | `HandleDestroyActorInvalidatesReference` |

## 2. TObjectPtr 路由与显式属性

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| TObjectPtr 路由（脚本侧透明处理） | ✅ | `HandleTests::TObjectPtrRouting` |
| NewObject + TObjectPtr + Subclass 引用 | ✅ | `HandlesTests::UObjectNewObjectTObjectPtrAndSubclassReferences` |

## 3. 弱引用 TWeakObjectPtr（WeakReferenceTests + HandlesTests）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 弱引用基础 | ✅ | `WeakObjectPtrBasics` |
| 失效检测 | ✅ | `WeakObjectPtrInvalidation` |
| 作属性 | ✅ | `WeakObjectPtrAsProperty` |
| null 比较与重新赋值 | ✅ | `WeakObjectPtrNullComparisonAndReassignment` |
| 打破反向引用环 | ✅ | `WeakObjectPtrBreaksBackReferenceCycle` |
| 弱引用数组容器（含重新赋值） | ✅ | `WeakObjectPtrArrayContainer` `HandlesTests::WeakObjectPtrArrayContainerAndReassignment` |

## 4. TSubclassOf（WeakReference + Handle + Handles）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础与作属性 | ✅ | `TSubclassOfBasics` `TSubclassOfAsProperty` |
| Spawn / NewObject | ✅ | `TSubclassOfSpawn` `HandleTests::TSubclassOfParameterAndNewObject` |
| 类型检查 | ✅ | `TSubclassOfTypeCheck` |
| 综合用法 | ✅ | `HandlesTests::TSubclassOfUsage` |

## 5. 软引用 TSoftObjectPtr / TSoftClassPtr（SoftReferenceTests + Handles）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| SoftObjectPtr 基础 / null 检查 / 路径 | ✅ | `SoftObjectPtrBasics` `SoftObjectPtrNullChecks` `SoftObjectPtrPath` |
| SoftObjectPtr 作属性 / 容器中 | ✅ | `SoftObjectPtrAsProperty` `SoftObjectPtrInContainers` |
| SoftObjectPtr 路径构造与 pending / 异步加载 | ✅ | `SoftObjectPtrPathConstructionAndPending` `SoftObjectPtrAsyncLoad` |
| SoftClassPtr 基础 / 路径 / 作属性 / 配置路径 | ✅ | `SoftClassPtrBasics` `SoftClassPtrPath` `SoftClassPtrAsProperty` `SoftClassPtrConfiguredPath` |
| 综合软引用用法（Handles） | ✅ | `HandlesTests::SoftReferenceUsage` `SoftReferencePathConstructionAndPendingBoundary` |

## 6. 垃圾回收 GC（GCTests）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础回收 | ✅ | `GCBasicReclaim` |
| UPROPERTY 保护不被回收 | ✅ | `GCUPropertyProtection` |
| 弱指针失效 | ✅ | `GCWeakPtrInvalidation` |
| 容器保护 | ✅ | `GCContainerProtection` |
| 跨帧持有 | ✅ | `GCCrossFrameHold` |
| 局部变量不保护 | ✅ | `GCLocalVariableNoProtection` |
| 收集方法 / IsValid 检查 | ✅ | `GCCollectionMethods` `GCIsValidCheck` |
| NewObject Outer 与收集 | ✅ | `GCNewObjectOuterAndCollection` |
| 根可达性 / UPROPERTY 可达链 | ✅ | `GCRootReachability` `GCUPropertyReachabilityChain` |
| 强循环引用回收 | ✅ | `GCStrongCycleReclaim` |

## 7. 引用有效性与原生接口句柄

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 引用有效性检查 | ✅ | `HandlesTests::ReferenceValidityChecks` |
| 原生接口引用句柄 | ✅ | `HandlesTests::NativeInterfaceReferenceHandles` |
| GC 可达性与弱失效边界（Handles） | ✅ | `HandlesTests::GCReachabilityAndWeakInvalidationBoundary` |

## 8. 边界（fork 不支持）

| 场景 | 状态 | 说明 |
|------|------|------|
| 脚本级 `TScriptInterface<I>` 引用 | 🚫 | 见 `07-macros-enum-function-interface.md` 与 `../coverage-gaps.md §2.3` |

---

## 汇总

| 文件 | 方法 | 说明 |
|------|------|------|
| Handle | 14 | handle 基础/操作/容器/TObjectPtr 路由 |
| Handles | 10 | 引用作属性/参数 + TObjectPtr/弱数组/软引用综合 |
| WeakReference | 10 | TWeakObjectPtr + TSubclassOf |
| SoftReference | 11 | TSoftObjectPtr / TSoftClassPtr |
| GC | 12 | 回收/保护/可达性/循环引用 |
| **合计** | **57** | |

**待实现（⬜）**：经审计，`TObjectPtr` 路由/属性（§2）与弱引用数组（§3）均已覆盖；原 `coverage-gaps.md` G3/G4 由"待补"修正为"已覆盖（可按需加深断言）"。当前无硬缺口。
