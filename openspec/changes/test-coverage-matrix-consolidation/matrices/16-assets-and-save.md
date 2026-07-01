# 资源加载 / 材质 / 存档 覆盖矩阵

> **本矩阵是资源/材质/存档测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 4 个测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`。
>
> - 测试文件：`AssetLoading`(6) / `LiteralAsset`(7) / `Material`(3) / `SaveGame`(4) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<AssetLoading|LiteralAsset|Material|SaveGame>`
> - 图例见 `../coverage-matrix.md`。

## 1. 资源加载（AssetLoadingTests 6）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 同步软对象路径加载 / 同步软类路径加载 | ✅ | `SynchronousSoftObjectPathLoad` `SynchronousSoftClassPathLoad` |
| 全局 LoadObject | ✅ | `GlobalLoadObject` |
| 软引用路径构造与 pending | ✅ | `SoftReferencePathConstructionAndPending` |
| 软路径字符串身份与缺类边界 / 软引用异步边界 | ✅ | `SoftPathStringIdentityAndMissingClassBoundaries` `SoftReferenceAsyncBoundaries` |

## 2. 字面量资源（LiteralAssetTests 7）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 资源声明基础 / 单例行为 | ✅ | `AssetDeclarationBasics` `AssetSingletonBehavior` |
| 编译期材质化 / 空声明 | ✅ | `AssetCompileTimeMaterialization` `AssetEmptyDeclaration` |
| 复杂初始化 / 增量初始化 | ✅ | `AssetComplexInitialization` `AssetIncrementalInitialization` |
| null 安全 | ✅ | `AssetNullSafety` |

## 3. 材质（MaterialTests 3）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 组件材质槽往返 | ✅ | `ComponentMaterialSlotRoundTrip` |
| 动态材质参数赋值 / 回读 | ✅ | `DynamicMaterialParametersAndAssignment` `DynamicMaterialParameterReadback` |

## 4. 存档（SaveGameTests 4）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| SaveGame 子类与属性 | ✅ | `SaveGameSubclassAndProperties` |
| 同步槽位往返 | ✅ | `SynchronousSlotRoundTrip` |
| 缺槽返回 null | ✅ | `MissingSlotReturnsNull` |
| **嵌套 struct / 数组字段 save→load 往返** | ✅ | `ComplexStructAndArraySlotRoundTrip` |

---

## 汇总

| 文件 | 方法 |
|------|------|
| AssetLoading | 6 |
| LiteralAsset | 7 |
| Material | 3 |
| SaveGame | 4 |
| **合计** | **20** |

**已补充关闭（2026-07-01）**：G2 — `AngelscriptCoverageSaveGameTests.cpp::ComplexStructAndArraySlotRoundTrip` 覆盖嵌套 USTRUCT、`TArray<int>`、`TArray<USTRUCT>` 的 save→load 往返断言。
