# USTRUCT 覆盖矩阵

> **本矩阵是 USTRUCT 测试的设计规格("头")**：每行是一个**具体可验证场景**，用来指导 `AngelscriptCoverageUStructTests.cpp` / `AngelscriptCoverageUStructMemberTests.cpp` 的实现。
> 状态为 ⬜ 的行即"待实现测试"；✅ 行注明已覆盖它的 `TEST_METHOD`。
>
> - 测试文件：`AngelscriptCoverageUStructTests.cpp`（43 方法）、`AngelscriptCoverageUStructMemberTests.cpp`（4 方法）
> - Automation 前缀：`Angelscript.TestModule.Coverage.UStruct`、`...UStructMember`
> - 图例：✅ 已覆盖 ／ 🟡 部分覆盖 ／ ⬜ 待实现 ／ 🚫 fork 不支持（边界记录）。完整图例见 `../coverage-matrix.md`。

## 1. 声明与反射（Declaration & Reflection）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 基础 USTRUCT 声明 + 反射注册 | ✅ | `UStructBasicDeclaration` | 类型注册、字段可见 |
| 声明 / 构造的边界组合 | ✅ | `UStructDeclarationAndConstructionEdgeMatrix` | 默认构造、聚合初始化边界 |
| 命名空间内声明与反射 | ✅ | `UStructNamespacedDeclarationAndReflection` | `namespace` 下 struct 反射名 |
| 跨多个反射点的类型标识一致 | ✅ | `UStructTypeIdentityAcrossReflectionSites` | 参数/返回/成员处类型同一 |
| BlueprintGeneratedClass 关联边界 | ✅ | `UStructBlueprintGeneratedClassBoundary` | 与 BP 生成类交互边界 |

## 2. 说明符与元数据（Specifiers & Metadata）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| USTRUCT 受支持说明符 | ✅ | `UStructSpecifiers` | BlueprintType / Atomic 等 |
| 不支持的 USTRUCT 说明符（边界） | 🚫 | `UStructUnsupportedSpecifiers` | 记录被拒绝说明符 |
| 属性说明符标志矩阵 | ✅ | `UStructPropertySpecifierFlagMatrix` | EditAnywhere/BlueprintReadWrite/SaveGame 等标志位 |
| 可选 + 说明符组合 | ✅ | `UStructOptionalAndSpecifierCombinations` | 组合规则 |
| 元数据别名与弃用 | ✅ | `UStructMetadataAliasAndDeprecationMatrix` | meta alias / deprecated |
| 高级元数据 | ✅ | `UStructAdvancedMetadata` | 自定义 meta 键往返 |

## 3. 成员与默认值（Members & Defaults）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 成员声明与访问 | ✅ | `UStructMembers` / `UStructMember*`(member 文件) | 基础成员读写 |
| 扩展成员类型矩阵 | ✅ | `UStructExtendedMemberTypeMatrix` | 各 UE 类型作成员 |
| 枚举 / FText / 属性标志成员 | ✅ | `UStructEnumTextAndPropertyFlags` | enum/FText 成员 |
| 默认值类型矩阵 | ✅ | `UStructDefaultValueTypeMatrix` | 各类型默认值反射 |
| 嵌套 struct 默认值反射 | ✅ | `UStructNestedDefaultsReflection` | 嵌套默认值 |

## 4. 值语义、运算符、成员方法（Value Semantics / Operators / Methods）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 值语义（拷贝/赋值独立） | ✅ | `UStructValueSemantics` | 值类型拷贝隔离 |
| 运算符重载（==、!= 等） | ✅ | `UStructOperators` | 比较/赋值运算符 |
| 成员方法调用矩阵 | ✅ | `UStructMemberMethodInvocationMatrix` | struct 方法调用 |

## 5. 作参数 / 返回值（Parameter / Return）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| struct 作脚本函数参数 | ✅ | `UStructAsParameter` | 值/in/out/inout |
| struct 作脚本函数返回值 | ✅ | `UStructAsReturn` | 返回值往返 |
| struct 作 UFUNCTION 参数调用 | ✅ | `UStructUFunctionParameterInvocation` | 反射调用入参 |
| struct 作 UFUNCTION 返回调用 | ✅ | `UStructUFunctionReturnInvocation` | 反射调用返回 |
| 函数形态矩阵（参数×返回组合） | ✅ | `UStructFunctionShapeMatrix` | 形态排列 |
| 可选（optional）返回矩阵 | ✅ | `UStructOptionalReturnMatrix` | optional 返回 |

## 6. 委托交互（Delegate）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| struct 作委托参数往返 | ✅ | `UStructDelegateParameterRoundTrip` | 委托广播 struct |
| struct 容器作委托参数往返 | ✅ | `UStructDelegateContainerRoundTrip` | TArray<struct> 委托 |
| 扩展 Map 委托排列矩阵 | ✅ | `UStructExtendedMapDelegatePermutationMatrix` | TMap 值含 struct 的委托 |
| Map 键值委托排列矩阵 | ✅ | `UStructMapKeyValueDelegatePermutationMatrix` | 键/值 struct 委托排列 |

## 7. 容器交互（Containers）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| struct 在容器中（TArray/TMap/TSet 元素） | ✅ | `UStructInContainers` | 作元素 |
| struct 作可哈希 Map 键 / Set 元素 | ✅ | `UStructHashableMapKeyAndSetElement` | GetTypeHash 路径 |
| 空容器形态矩阵 | ✅ | `UStructEmptyContainerShapeMatrix` | 空容器边界 |
| 容器作参数形态矩阵 | ✅ | `UStructContainerParameterShapeMatrix` | 容器入参排列 |
| 容器作成员形态矩阵 | ✅ | `UStructContainerMemberShapeMatrix` | 容器成员排列 |
| 扩展 Map 成员排列矩阵 | ✅ | `UStructExtendedMapMemberPermutationMatrix` | TMap 成员排列 |
| 反射容器参数调用 | ✅ | `UStructReflectedContainerParameterInvocation` | 反射调用容器入参 |
| 键容器参数与返回矩阵 | ✅ | `UStructKeyContainerParameterAndReturnMatrix` | 键容器形态 |
| struct→struct Map 参数与返回 | ✅ | `UStructStructToStructMapParameterAndReturnMatrix` | TMap<struct,struct> |
| Map 键值形态矩阵 | ✅ | `UStructMapKeyValueShapeMatrix` | 键值类型排列 |
| Map 键值参数与返回矩阵 | ✅ | `UStructMapKeyValueParameterAndReturnMatrix` | 键值参数/返回 |
| Map 基础键值参数与返回 | ✅ | `UStructMapPrimitiveKeyValueParameterAndReturnMatrix` | 基础类型键值 |

## 8. 嵌套（Nested）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 嵌套 struct（struct 含 struct 成员） | ✅ | `UStructNested` | 多层嵌套读写 |
| struct 内含数组、再作为外层数组元素 | ✅ | `UStructInContainers` / `UStructNested` | 见 `../coverage-gaps.md §2.2`（允许形态） |

## 9. 边界（Boundaries — fork 不支持/不适用）

| 场景 | 状态 | 覆盖测试方法 | 要点 |
|------|------|------------|------|
| 不支持的组合（容器嵌套等） | 🚫 | `UStructUnsupportedCombinationBoundaries` | 编译诊断作边界断言，详见 `../coverage-gaps.md §2.2` |

---

## 汇总

| 维度 | 已覆盖场景 | 状态 |
|------|----------|------|
| 1 声明与反射 | 5 | ✅ |
| 2 说明符与元数据 | 6（含 1 边界） | ✅ |
| 3 成员与默认值 | 5 | ✅ |
| 4 值语义/运算符/方法 | 3 | ✅ |
| 5 参数/返回值 | 6 | ✅ |
| 6 委托交互 | 4 | ✅ |
| 7 容器交互 | 12 | ✅ |
| 8 嵌套 | 2 | ✅ |
| 9 边界 | 2（🚫 记录） | — |

**对应测试方法**：`UStructTests.cpp` 43 + `UStructMemberTests.cpp` 4 = 47 方法。
**待实现（⬜）**：当前无硬缺口；USTRUCT 是覆盖最成熟的领域之一。若后续新增能力（如 struct 自定义序列化器、InstancedStruct），在对应维度补 ⬜ 行并排期。
