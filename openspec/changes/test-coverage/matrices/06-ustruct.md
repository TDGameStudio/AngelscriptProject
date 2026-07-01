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
| `HasNativeMake` / `HasNativeBreak` 说明符 | ⬜? | — | 待实现（G15）：UE UHT 用这两个说明符指示 native 端绑定自定义 Make/Break 节点；fork 内 grep 无 `HasNativeMake/HasNativeBreak` 解析；当前 `UStructUnsupportedSpecifiers` 仅覆盖 `Atomic`/`Immutable`/`NoExport`。需补一行 compile-failure 实测（预期 `Unknown class specifier`），归 🚫 边界 |

## 3. 成员与默认值（Members & Defaults）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 成员声明与访问 | ✅ | `UStructMembers` / `UStructMember*`(member 文件) | 基础成员读写 |
| 扩展成员类型矩阵 | ✅ | `UStructExtendedMemberTypeMatrix` | 各 UE 类型作成员（含 TWeakObjectPtr / TSoftObjectPtr / TSoftClassPtr / TSubclassOf / FText / 数学结构 / UObject 引用） |
| 枚举 / FText / 属性标志成员 | ✅ | `UStructEnumTextAndPropertyFlags` | enum/FText 成员 |
| 默认值类型矩阵 | ✅ | `UStructDefaultValueTypeMatrix` | 各类型默认值反射 |
| 嵌套 struct 默认值反射 | ✅ | `UStructNestedDefaultsReflection` | 嵌套默认值（3 层 Outer→Branch→Leaf） |
| `FInstancedStruct` 作 USTRUCT 成员 / UPROPERTY | ⬜ | — | 待实现（G11）：fork 已绑定 `FInstancedStruct`（见 `Bind_FInstancedStruct.cpp`、`AngelscriptInstancedStructBindingsTests.cpp` 的 `DefaultConstruction`/`ResetClears`），但 Coverage 域未覆盖。需补：作 UPROPERTY 反射、`InitializeAs<FFoo>` / `Get<FFoo>()` 往返、作函数参数/返回、作 TArray 元素 |

## 4. 值语义、运算符、成员方法（Value Semantics / Operators / Methods）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 值语义（拷贝/赋值独立） | 🟡 | `UStructValueSemantics` | 值类型拷贝隔离（G12）：当前仅 int + FString 成员的拷贝/赋值独立性；含 TArray/TMap/TSet 成员的深拷贝独立性（修改副本容器不影响源容器）尚未断言 |
| 运算符重载（==、!= 等） | 🟡 | `UStructOperators` | 当前覆盖 `opEquals` / `opAdd` / `opAssign` / `opCmp` / `opIndex`（G13）：缺 `opSub` / `opMul` / `opDiv` / `opNeg` 及复合赋值 `opAddAssign` / `opSubAssign` / `opMulAssign` / `opDivAssign` 的运行期断言 |
| 成员方法调用矩阵 | ✅ | `UStructMemberMethodInvocationMatrix` | const / 非 const / 返回 struct / `CopyFrom(const&in)` 等形态运行期断言 |

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
| 不支持 USTRUCT 说明符（`Atomic` / `Immutable` / `NoExport`） | 🚫 | `UStructUnsupportedSpecifiers` | 编译诊断作边界断言（`Unknown class specifier ...`） |
| `TMap<FStruct,V>` / `TSet<FStruct>` 缺少 `Hash`+`opEquals` | 🚫 | `UStructUnsupportedCombinationBoundaries` | 编译诊断 `Key type does not have a hash function defined` |
| `FInstancedPropertyBag` / `FPropertyBag` | ⬜? | — | （G14）：fork 未发现 PropertyBag 绑定（无 `Bind_FPropertyBag*`），疑似 🚫 边界但未做 compile-failure 实证；需先实测一行 `FInstancedPropertyBag Foo;` 的编译诊断再定状态 |
| USTRUCT 自定义 `Serialize(FArchive&)` 入口 | ⬜? | — | 待实现/边界（G16）：UE C++ 端可通过 `Serialize(FArchive&)` 重载或 `WithSerializer` Cpp struct trait 自定义 USTRUCT 二进制序列化；fork 内 grep 未发现 AS struct 暴露 `FArchive` 类型/`Serialize` 钩子绑定。预期 🚫 边界（AS struct 走默认反射序列化即可），需 1 行 `void Serialize(FArchive& Ar)` compile-failure 实测固化 |
| USTRUCT `NetSerialize` / 复制序列化入口 | ⬜? | — | 待实现/边界（G17）：UE 通过 `NetSerialize(FArchive&,UPackageMap*,bool&)` + `WithNetSerializer` 实现 struct 网络压缩；fork 内 grep 无 `NetSerialize` 绑定。AS struct 仅能依赖默认逐字段复制（已通过 UPROPERTY 反射），但脚本端无法覆盖 `NetSerialize`。预期 🚫 边界，需对应 compile-failure 实测固化 |
| AS USTRUCT 静态成员（`static int Foo`） | ⬜? | — | 待实现/边界（G18）：AS 语言层不支持类/结构静态字段（已在委托域以 `BindStatic` 边界形式记录于 `coverage-gaps.md §2.4`）。USTRUCT 域未做对应 compile-failure 行；需 1 行 `static int Foo` USTRUCT 成员 compile-failure 实测，固化为 🚫 边界 |

---

## 汇总

| 维度 | 已覆盖场景 | 状态 |
|------|----------|------|
| 1 声明与反射 | 5 | ✅ |
| 2 说明符与元数据 | 6 ✅（含 1 边界）+ 1 待实证（G15） | 🟡 |
| 3 成员与默认值 | 5 + 1 ⬜（G11） | 🟡 |
| 4 值语义/运算符/方法 | 1 ✅ + 2 🟡（G12/G13） | 🟡 |
| 5 参数/返回值 | 6 | ✅ |
| 6 委托交互 | 4 | ✅ |
| 7 容器交互 | 12 | ✅ |
| 8 嵌套 | 2 | ✅ |
| 9 边界 | 3 🚫 + 4 待实证（G14/G16/G17/G18） | — |

**对应测试方法**：`UStructTests.cpp` 43 + `UStructMemberTests.cpp` 4 = 47 方法。

**待实现（⬜ / 🟡）**：
- `G11` ⬜ `FInstancedStruct` 作 USTRUCT 成员 / UPROPERTY 反射 + `InitializeAs<FFoo>` / `Get<FFoo>()` 往返 + 容器/参数形态。fork 已绑定（`Bind_FInstancedStruct.cpp`），Coverage 域未覆盖。
- `G12` 🟡 值语义深拷贝独立性补强：现 `UStructValueSemantics` 仅 int+FString 成员；扩展为含 `TArray`/`TMap`/`TSet` 成员的深拷贝独立性（修改副本容器不影响源）。
- `G13` 🟡 运算符重载补全：现 `UStructOperators` 覆盖 `opEquals`/`opAdd`/`opAssign`/`opCmp`/`opIndex`；补 `opSub`/`opMul`/`opDiv`/`opNeg` + 复合赋值 `opAddAssign`/`opSubAssign`/`opMulAssign`/`opDivAssign` 的运行期断言。
- `G14` 🚫? 实证候选：`FInstancedPropertyBag` / `FPropertyBag` 在 fork 是否绑定？建议先做 1 行 compile-failure 实测，再决定归 🚫 边界还是 ⬜ 候选。
- `G15` 🚫? 实证候选：USTRUCT 说明符 `HasNativeMake` / `HasNativeBreak`；fork 无解析路径。1 行 compile-failure 实测固化 🚫 边界。
- `G16` 🚫? 实证候选：USTRUCT 自定义 `Serialize(FArchive&)` 入口；fork 无 `FArchive` AS 绑定。1 行 compile-failure 实测固化 🚫 边界。
- `G17` 🚫? 实证候选：USTRUCT `NetSerialize` 复制序列化重载；fork 无 `NetSerialize` 绑定。1 行 compile-failure 实测固化 🚫 边界。
- `G18` 🚫? 实证候选：USTRUCT 静态成员 `static int Foo;`；AS 语言不支持。1 行 compile-failure 实测固化 🚫 边界。

> 历史结论"USTRUCT 是覆盖最成熟的领域之一"仍成立：47 方法在断言层均为真行为/反射断言，无大面积"伪 ✅"。本次新增 8 项 NEW 中 G11~G13 为**能力面增强**（非阻塞），G14~G18 为**边界实证候选**（每项仅需 1 行 compile-failure 测试即可固化为 🚫 边界）。
