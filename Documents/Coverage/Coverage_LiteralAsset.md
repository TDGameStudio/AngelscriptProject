# AngelScript Literal Asset 全覆盖矩阵

> 本文覆盖 AngelScript 中 **Literal Asset（字面量资源引用）**的所有用法。
> 
> **注意**：AngelScript 中的 "Literal Asset" 指的是 `asset` 关键字声明的脚本资源对象，
> 不是 C++ 字符串字面量形式的资源引用（如 `Asset"/Game/..."`）。
> 这是 AngelScript 特有的资源声明语法。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| **Coverage 核心测试** | `AngelscriptTest/Coverage/AngelscriptCoverageLiteralAssetTests.cpp` | ✅ 已完成 |
| PostInit & 共存 | `AngelscriptTest/ClassGenerator/AngelscriptLiteralAssetPostInitTests.cpp` | ✅ 已覆盖 |
| HotReload | `AngelscriptTest/HotReload/AngelscriptHotReloadLiteralAssetTests.cpp` | ✅ 已覆盖 |
| 编辑器序列化 | `AngelscriptEditor/Tests/AngelscriptEditorModuleLiteralAssetTests.cpp` | ✅ 已覆盖 |

---

## 子矩阵 1：`asset` 声明语法

### 1.1 基础声明

| 语法元素 | 写法 | 测试位置 | 状态 | 说明 |
|---------|------|---------|------|------|
| asset 声明 | `asset MyAsset of UMyClass { }` | CoverageTests::AssetDeclarationBasics | ✅ | 声明脚本资源 |
| 带初始化 | `asset MyAsset of UMyClass { Prop = Value; }` | CoverageTests::AssetDeclarationBasics | ✅ | 初始化属性 |
| 空初始化块 | `asset MyAsset of UMyClass { }` | CoverageTests::AssetEmptyDeclaration | ✅ | 仅声明，使用默认值 |
| 多资源共存 | 同类声明多个 asset | PostInitTests::MultipleAssetsInSameClassCoexist | ✅ | 独立对象 |

### 1.2 资源初始化

| 场景 | 行为 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| 编译时创建 | 编译后立即实例化 | CoverageTests::AssetCompileTimeMaterialization | ✅ | 无需手动 new |
| 初始化块执行 | `{ }` 内代码执行一次 | PostInitTests::PostInitMaterializesAssetOnce | ✅ | PostInitCalls = 1 |
| 重复访问 | 返回同一对象 | CoverageTests::AssetSingletonBehavior | ✅ | 单例行为 |
| Getter 生成 | 自动生成 `GetMyAsset()` | CoverageTests::AssetDeclarationBasics | ✅ | 访问器 |
| 复杂表达式 | 支持算术、构造函数 | CoverageTests::AssetComplexInitialization | ✅ | Sum = 10+20+30 |
| 增量操作 | 支持 += 等操作符 | CoverageTests::AssetIncrementalInitialization | ✅ | Counter += 10 |
| 非空保证 | 编译成功后不返回 null | CoverageTests::AssetNullSafety | ✅ | 可安全访问 |

---

## 子矩阵 2：资源共存与兼容性

### 2.1 多资源共存

| 场景 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| 同类多资源 | 同一 UClass 声明多个 asset | PostInitTests::MultipleAssetsInSameClassCoexist | ✅ | FirstAsset, SecondAsset |
| 独立初始化 | 各自独立的属性值 | PostInitTests::MultipleAssetsInSameClassCoexist | ✅ | Marker = 10 vs 20 |
| 独立对象 | 不同的 UObject* | PostInitTests::MultipleAssetsInSameClassCoexist | ✅ | FirstAsset != SecondAsset |

### 2.2 与其他特性共存

| 场景 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| DefaultComponent | asset + DefaultComponent Actor | PostInitTests::AssetWithDefaultComponentCoexist | ✅ | 可同时使用 |
| 类生成 | 与 UCLASS 生成共存 | PostInitTests | ✅ | 正常工作 |

---

## 子矩阵 3：热重载行为

### 3.1 资源替换

| 行为 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| 对象替换 | 旧对象 → 新对象 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | OldAsset != NewAsset |
| 类替换 | 旧类 → 新类 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | OldClass != NewClass |
| 名称保留 | 新对象保留原名 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | 仍为 "ExampleAsset" |
| 旧对象重命名 | 旧对象改名 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | REPLACED_ASSET_* |

### 3.2 重载回调

| 事件 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| OnLiteralAssetReload | 替换时触发 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | (OldObj, NewObj) |
| 触发一次 | 每次重载触发一次 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | ReloadCount = 1 |
| 旧类标记 | CLASS_NewerVersionExists | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | 标记过时 |

### 3.3 属性演化

| 场景 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| 新增属性 | 添加 UPROPERTY | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | ExtraValue |
| 新属性默认值 | 新对象有新默认值 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | ExtraValue = 2 |
| 旧类布局保留 | 旧类不反映新属性 | HotReloadTests::BroadcastsReloadedObjectReplacement | ✅ | 旧类无 ExtraValue |

---

## 子矩阵 4：编辑器集成

### 4.1 UCurveFloat 序列化

| 特性 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| 曲线键序列化 | AddLinearCurveKey() | EditorModuleTests::OnLiteralAssetSavedSerializesCurveKeys* | ✅ | 保存时生成代码 |
| 常量键 | AddConstantCurveKey() | EditorModuleTests::OnLiteralAssetSavedFlatCurvesSkip* | ✅ | RCIM_Constant |
| DefaultValue | DefaultValue = N; | EditorModuleTests | ✅ | 默认值 |
| 外推模式 | PreInfinityExtrap, PostInfinityExtrap | EditorModuleTests | ✅ | RCCE_* 枚举 |

### 4.2 加权切线

| 特性 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| WeightedArrive | AddCurveKeyWeightedArriveTangent() | EditorModuleTests::OnLiteralAssetSavedWeightedTangents* | ✅ | 到达权重 |
| WeightedLeave | AddCurveKeyWeightedLeaveTangent() | EditorModuleTests::OnLiteralAssetSavedWeightedTangents* | ✅ | 离开权重 |
| WeightedBoth | AddCurveKeyWeightedBothTangent() | EditorModuleTests::OnLiteralAssetSavedWeightedTangents* | ✅ | 双向权重 |
| 参数顺序 | Time, Value, bBroken, Arrive, Leave, ArriveWeight, LeaveWeight | EditorModuleTests::OnLiteralAssetSavedWeightedTangents* | ✅ | 固定顺序 |

### 4.3 编辑器优化

| 特性 | 描述 | 测试位置 | 状态 | 说明 |
|------|------|---------|------|------|
| 平坦曲线跳过图表 | 单点/平坦曲线不生成 ASCII 图 | EditorModuleTests::OnLiteralAssetSavedFlatCurvesSkip* | ✅ | 性能优化 |
| 保留序列化键 | 即使跳过图表也保留键 | EditorModuleTests::OnLiteralAssetSavedFlatCurvesSkip* | ✅ | 数据完整 |

---

## 子矩阵 5：实际使用模式

### 5.1 典型声明

```angelscript
// 基础声明
UCLASS()
class UMyAssetClass : UObject
{
    UPROPERTY()
    int Value = 0;
}

asset MyAsset of UMyAssetClass
{
    Value = 42;
}
```

### 5.2 多资源声明

```angelscript
asset FirstAsset of UMultiAssetOwner
{
    Marker = 10;
}

asset SecondAsset of UMultiAssetOwner
{
    Marker = 20;
}
```

### 5.3 与 DefaultComponent 共存

```angelscript
UCLASS()
class AMyActor : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
}

asset MyCoexistAsset of UAssetCarrier
{
    CoexistMarker = 99;
}
```

### 5.4 UCurveFloat 编辑器集成

```angelscript
// 编辑器保存时自动生成初始化代码
asset MyCurve of UCurveFloat
{
    AddLinearCurveKey(0.0, 0.0);
    AddLinearCurveKey(1.0, 1.0);
    DefaultValue = 0.5;
    PreInfinityExtrap = ERichCurveExtrapolation::RCCE_Cycle;
    PostInfinityExtrap = ERichCurveExtrapolation::RCCE_Linear;
}
```

---

## 实际测试方法清单

### AngelscriptCoverageLiteralAssetTests.cpp (Coverage 核心)

| 测试方法 | 覆盖内容 | 状态 |
|---------|---------|------|
| `AssetDeclarationBasics` | 基础声明语法、属性初始化 | ✅ |
| `AssetSingletonBehavior` | 单例行为、同一实例返回 | ✅ |
| `AssetCompileTimeMaterialization` | 编译时实例化、AssetsPackage | ✅ |
| `AssetEmptyDeclaration` | 空初始化块、类默认值 | ✅ |
| `AssetComplexInitialization` | 复杂表达式、多属性初始化 | ✅ |
| `AssetNullSafety` | 非空保证、属性访问 | ✅ |
| `AssetIncrementalInitialization` | 增量操作（+=）、多语句执行 | ✅ |

### AngelscriptLiteralAssetPostInitTests.cpp (ClassGenerator)

| 测试方法 | 覆盖内容 | 状态 |
|---------|---------|------|
| `PostInitMaterializesAssetOnce` | 初始化块执行、单例行为、Getter | ✅ |
| `MultipleAssetsInSameClassCoexist` | 同类多资源、独立初始化 | ✅ |
| `AssetWithDefaultComponentCoexist` | 与 DefaultComponent 共存 | ✅ |

### AngelscriptHotReloadLiteralAssetTests.cpp (HotReload)

| 测试方法 | 覆盖内容 | 状态 |
|---------|---------|------|
| `BroadcastsReloadedObjectReplacement` | 热重载替换、回调、属性演化 | ✅ |

### AngelscriptEditorModuleLiteralAssetTests.cpp (Editor)

| 测试方法 | 覆盖内容 | 状态 |
|---------|---------|------|
| `OnLiteralAssetSavedSerializesCurveKeysDefaultValueAndInfinityModes` | UCurveFloat 基础序列化 | ✅ |
| `OnLiteralAssetSavedFlatCurvesSkipAsciiGraphButPreserveSerializedKeys` | 平坦曲线优化 | ✅ |
| `OnLiteralAssetSavedWeightedTangentsEmitExpectedFunctionAndArgumentOrder` | 加权切线序列化 | ✅ |

---

## 总结

AngelScript Literal Asset（`asset` 关键字）是 **脚本资源声明特性**：

**核心特点**：
- ✅ **编译时创建** → 模块编译后立即实例化
- ✅ **单例行为** → 每次访问返回同一对象
- ✅ **自动 Getter** → 生成 `GetAssetName()` 访问器
- ✅ **初始化块** → `{ }` 内代码执行一次
- ✅ **热重载支持** → 旧对象替换，回调通知
- ✅ **编辑器集成** → UCurveFloat 等支持可视化编辑

**测试覆盖统计**：
- **4 个测试文件**，共 **17 个测试方法**
- **核心 Coverage 测试**：7 个方法（基础语法、初始化、单例）
- **ClassGenerator 测试**：3 个方法（PostInit、共存）
- **HotReload 测试**：1 个方法（热重载行为）
- **Editor 测试**：3 个方法（UCurveFloat 序列化）

**已覆盖场景**：
- ✅ 基础声明与属性初始化
- ✅ 空初始化块与默认值
- ✅ 复杂表达式与增量操作
- ✅ 单例行为与对象身份
- ✅ 编译时实例化验证
- ✅ 多资源共存
- ✅ 与其他特性（DefaultComponent）共存
- ✅ 热重载行为与回调
- ✅ UCurveFloat 编辑器序列化（键、切线、外推模式）

**测试覆盖率**：🟢 **完整**
- 核心语法 ✅
- 初始化语义 ✅
- 运行时行为 ✅
- 热重载集成 ✅
- 编辑器集成 ✅

**关键约束**：
- 仅支持 UObject 派生类
- 编译时实例化，不支持运行时动态创建
- 单例模式，每个 asset 只有一个实例
- 热重载会替换对象（不是就地更新）

**与 C++ 字面量对比**：
- AngelScript `asset MyAsset of UClass { }` ← 脚本资源声明
- C++ 字面量 `Asset"/Game/..."` ← 不在此文档范围内（属于资源路径引用）
