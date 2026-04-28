# Hazelight 脚本特性对齐盘点与验证闭环计划

## 背景与目标

### 背景

当前仓库在讨论与 Hazelight 的差距时，往往集中在工程硬化、对外交付入口或 Bind API 差量上，但对**脚本层面用户直接感知的核心特性**（`default` 语句、`asset` 声明、`DefaultComponent`、UFUNCTION/UPROPERTY specifier、`foreach`、网络 RPC 等）缺少一份独立的对齐盘点。这些特性是脚本开发者日常编写 `.as` 文件时最高频使用的语法和预处理器能力；它们的实现现状、测试覆盖深度和与 Hazelight 的真实 delta 需要一份专题文档来记录。

通过代码探索确认：当前插件的预处理器（`AngelscriptPreprocessor.cpp`）**已经具备大部分 Hazelight 可见脚本特性的核心实现**，包括 `default` 语句解析、`asset X of Type` 字面量资产声明、`DefaultComponent` / `OverrideComponent` / `RootComponent` / `Attach` / `ShowOnActor` 组件 specifier、完整的 UFUNCTION/UPROPERTY/UCLASS specifier 链路、以及 `PostProcessRangeBasedFor`（foreach）预处理改写。但测试覆盖在多个特性上仍偏薄，部分特性的验证闭环不完整。

### 目标

1. **盘点**当前插件脚本层核心特性的实现状态和代码位置，让后续执行者可直接定位。
2. **记录**每个特性与 Hazelight 基线的真实 delta（功能差、测试差、示例差）。
3. **识别**测试覆盖薄弱环节，为后续验证闭环提供可执行的分阶段任务。
4. **不**在本计划中展开具体代码改造或新 Bind 实现；功能扩展仍由各 sibling plan 承接。

## 范围与边界

- **范围内**
  - 预处理器实现的脚本语法特性：`default`、`asset`、`DefaultComponent` 等
  - UFUNCTION / UPROPERTY / UCLASS specifier 支持面
  - `foreach` (range-based for) 预处理改写
  - 网络 RPC specifier（Server/Client/NetMulticast/WithValidation/Unreliable）
  - GAS / EnhancedInput helper surface 与 FunctionLibrary 覆盖面
  - 上述特性的测试覆盖深度与缺口
- **范围外**
  - 引擎侧补丁能力差距（UHT / CoreUObject / Blueprint 编译链）
  - Bind API 逐文件对齐（由 `Plan_HazelightBindModuleMigration.md` / `BindGapAuditMatrix.md` 承接）
  - AS 2.38 语言本体移植（由 `Plan_AS238*.md` 系列承接）
  - 工程硬化与对外交付（由 `Plan_PluginEngineeringHardening.md` 承接）

## 当前事实状态快照

### 一、`default` 语句

**实现状态：已支持**

- **解析入口**：`AngelscriptPreprocessor.cpp:3638-3648`，在类 chunk 内探测 `default` + 空白开头的行，记入 `FDefaultsCode::StartPos`，先存 `PendingDefaults`，chunk 提交时并入 `Chunk.Defaults`。
- **处理逻辑**：`ProcessDefaults()`（`AngelscriptPreprocessor.cpp:1230-1255`），逐行从 `StartPos + 8` 读到行尾，`TrimStartAndEnd` + `StripCommentsFromLine` 后拼入 `ClassDesc->DefaultsCode`。
- **消费方**：`AngelscriptClassGenerator.cpp` 对 `DefaultsCode` 做比对与继承，应用到 CDO。
- **支持语法**：`default PropertyName = Value;`、`default Tags.Add(n"Tag");`、子对象属性赋值等。

**测试覆盖（专用 10 + 顺带 22，合计约 32 个 Automation）**：

专用测试（主目标围绕 `default` 块 / CDO / DefaultsCode / 构造上下文）：

| # | Automation 路径 | 验证内容 |
|---|----------------|----------|
| 1 | `Compiler.EndToEnd.StringDefaultPreservesCommentMarkersInsideLiteral` | 字符串 default 含 `//` / `/*` 不破坏预处理；`DefaultsCode` 文本与 CDO/实例字符串一致 |
| 2 | `Compiler.EndToEnd.PropertyDefaultsCompile` | `default Score = 21` + `default Tags.Add(n"Alpha")`；CDO 整数断言通过（**注意**：`Tags.Add` 仅编译未在断言中验证） |
| 3 | `ClassGenerator.ASClass.StaticObjectConstructorAppliesScriptConstructorAndDefaultsOnce` | UObject 构造 + `default DefaultValue = 7` / `DefaultLabel = "ObjectDefaults"` 只执行一次 |
| 4 | `ClassGenerator.ASClass.StaticActorConstructorAppliesScriptConstructorAndDefaultsOnce` | AActor 同上，`default DefaultValue = 11` |
| 5 | `ClassGenerator.ASClass.StaticComponentConstructorAppliesScriptConstructorAndDefaultsOnce` | UActorComponent 同上，`default DefaultValue = 9` |
| 6 | `ClassGenerator.ASClass.GetConstructingASObjectReportsCurrentScriptInstance` | `default CapturedDuringDefaults = FConstructionContextProbe(...)` — 验证 default 块内执行脚本时的构造上下文 |
| 7 | `Learning.Runtime.ClassGeneration` | `GetDefaultObject()` 上读 `Health=7` / `bStartsEnabled=true` |
| 8 | `Actor.DefaultValues` | 子对象字段 `default PrimaryActorTick.TickInterval = 0.5f` |
| 9 | `ScriptActor.Inheritance.ChildOverridesBlueprintEvent` | 子类 `default PickupValue = 25` 传播基线与局限验证 |
| 10 | `ScriptExamples.BehaviorTreeNodes` | BT Decorator/Service/Task 各自 `default NodeName = "Example ..."` |

顺带使用（`default` 为场景搭建而非主断言目标，约 22 个 Automation）：
- 网络 RPC 测试 6 个（`default bReplicates = true` 搭建复制上下文）
- 复制列表 `ASClassReplicationTests` 1 个
- HotReload Property 3 个（`default Version = 1/2`、`default Mana = 5`、`default State = Alpha/Gamma`）
- HotReload Delegate 1 个、HotReload Analysis 2 个、HotReload Function 3 个
- Execute Discard 1 个（`default Value = 7/9`）
- Learning HotReload Decision 1 个
- Actor RadialDamage 1 个（`default DamageSphere.SetSphereRadius(64.0f)`）
- Actor Interface SpawnAndQuery 1 个（`default Tags.Add(n"...")`）
- Examples Actor 1 个、Examples MovingObject 1 个

**与 Hazelight 的 delta**：
- **功能 delta**：无明确差距。
- **测试 delta**：无 FName/枚举/结构体嵌套/软引用类型的专用 default 矩阵；无非法 `default` 诊断负例（不存在的属性名、类型不匹配、在非类作用域使用）；`Tags.Add` 仅编译未断言实际结果；无 `default` 与行内 `UPROPERTY()` 初始化优先级交互测试。
- **示例 delta**：`Script/Examples/` 中 `default` 使用充分（Actor/MovingObject/BehaviorTreeNodes 等），无差距。

### 二、`asset` 字面量资产声明

**实现状态：已支持**

- **入口**：`PostProcessLiteralAssets()`（`AngelscriptPreprocessor.cpp:4187-4326`），在 `CondenseFromChunks` 后执行。
- **正则**：`asset\s+([A-Za-z0-9_]+)\s+of\s+([A-Za-z0-9]+)\s*($|\r|\n)`。
- **生成代码**：隐藏字段 `__Asset_{Name}`、getter property `Get{Name}()`（懒加载 `Cast<{Type}>(__CreateLiteralAsset(...))`）、`__Init_{Name}` 回调、`__PostLiteralAssetSetup` 调用、`PostInitFunctions` 注册。
- **注释/字符串安全**：维护词法状态，在注释或字符串内匹配到的不展开。

**测试覆盖（专用 5 + 关联 1，合计 6 个 Automation）**：

| # | Automation 路径 | 文件 | 验证内容 |
|---|----------------|------|----------|
| 1 | `ClassGenerator.LiteralAsset.PostInitMaterializesAssetOnce` | `AngelscriptLiteralAssetPostInitTests.cpp` | 资源在显式 getter 调用前已物化；`__Init_*` 只执行一次（`PostInitCalls==1`、`bWasPostInit`、`InitMarker==1337`）；重复 getter 不重初始化、返回同一 UObject |
| 2 | `ClassGenerator.LiteralAsset.PostInitResolvesGeneratedGetterInsteadOfNameCollision` | 同上 | 手工短名 getter 碰撞时，post-init 只走生成 getter 路径（`RightCalls==1`、`WrongCalls==0`） |
| 3 | `Preprocessor.LiteralAssets.GenerateGetterAndPostInitRegistration` | `AngelscriptPreprocessorLiteralAssetTests.cpp` | 预处理器输出：去掉原文 `asset ...`；生成 `__Asset_PreviewAsset` + `GetPreviewAsset() property` + `__CreateLiteralAsset` + `__PostLiteralAssetSetup`；`PostInitFunctions` 恰一条 |
| 4 | `Preprocessor.LiteralAssets.SkipStringAndCommentDecoys` | 同上 | 字符串内 `"asset FakeAsset of UObject"` 与注释内 `// asset CommentAsset ...` 不展开；只处理真实声明 |
| 5 | `HotReload.LiteralAsset.BroadcastsReloadedObjectReplacement` | `AngelscriptHotReloadLiteralAssetTests.cpp` | Full reload（类新增字段）后旧类 `CLASS_NewerVersionExists`；旧对象改名 `REPLACED_ASSET_*`；`OnLiteralAssetReload` 回调一次且 old/new 指针正确；新资源上可读 `ExtraValue` |
| 6 | `Editor.ClassReloadHelper.ReloadStateTracksLiteralAssetsAndEnumChanges` | `AngelscriptClassReloadHelperTests.cpp` | （关联）手造 old/new UObject 广播验证 `ClassReloadHelper::ReloadState` 登记，不涉及 `asset` 源码声明 |

**与 Hazelight 的 delta**：
- **功能 delta**：无明确差距。
- **测试 delta**：无同模块多 `asset` 共存测试；无跨模块 asset 引用；无自定义 UObject 子类 asset；无非法语法失败路径（如 `asset X of` 缺类型、`asset` 在函数体内使用）；无 `asset` + `DefaultComponent` 同类共存测试；无 `Soft`/`EditorOnly` 资源类型边界。
- **示例 delta**：`Script/Examples/` 中无 `asset` 声明示例（现有示例均未使用此语法）。

### 三、`DefaultComponent` / `OverrideComponent` / `RootComponent` / `Attach`

**实现状态：已支持**

- **入口**：`ProcessPropertyMacro()`（`AngelscriptPreprocessor.cpp:2237-2652`）。
- **支持的 specifier**：`DefaultComponent`、`OverrideComponent`、`RootComponent`、`Attach`、`AttachSocket`、`ShowOnActor`。
- **组合校验**：Attach/RootComponent 仅允许与 DefaultComponent 同用；DefaultComponent + OverrideComponent 互斥；ShowOnActor 仅限 `bInstancedReference` 或 `Instanced` 属性。
- **AutoCollapseCategories**：`PP_NAME` 已声明（line 2237）但 `ProcessClassMacro` **未接线**，写进 UCLASS 会触发"Unknown class specifier"——与名称声明不同步。

**测试覆盖（专用 8 + 顺带 6，合计 14 个 Automation）**：

专用测试：

| # | Automation 路径 | 正/负 | 验证内容 |
|---|----------------|-------|----------|
| 1 | `DefaultComponent.Basic` | 正 | `DefaultComponent + RootComponent` 的 `USceneComponent` 作根；断言 `GetRootComponent()` 类与实例 |
| 2 | `DefaultComponent.Multiple` | 正 | Root + `Attach = RootScene` 子组件层级；断言 `GetAttachParent()==Root` |
| 3 | `DefaultComponent.NativeTypes` | 正 | 原生 `UStaticMeshComponent` 根 + `UBillboardComponent` 子 Attach；验证非脚本类型组件 |
| 4 | `ClassGenerator.ASClass.DefaultComponentMetadataCapturesRootAndAttachLayout` | 正 | `UASClass::DefaultComponents`/`OverrideComponents` 元数据：基类 RootScene（`bIsRoot`）、Billboard（`Attach==RootScene`）；派生 `OverrideComponent` 与类名/变量名一致 |
| 5 | `ClassGenerator.ASClass.SoftReloadPreservesDefaultComponentMetadataWithoutDuplication` | 正 | Soft reload 前后 metadata 快照相等、无重复；spawn 后 runtime root/billboard 与 metadata 一致 |
| 6 | `ClassGenerator.Component.InvalidAttachParentFailsClosed` | **负** | `Attach = MissingParent`（父默认组件不存在）→ `ECompileResult::Error`、诊断含预期片段 |
| 7 | `ClassGenerator.Component.MissingOverrideTargetFailsClosed` | **负** | `OverrideComponent = MissingScene`（基类无该槽位）→ fail-closed |
| 8 | `Preprocessor.Properties.ShowOnActorRequiresDefaultComponent` | **复合** | 负段：普通 `int` + 仅 `ShowOnActor` → 预处理失败；正段：`DefaultComponent + ShowOnActor + RootComponent` → 成功，`Meta` 含 `DefaultComponent=True`、`RootComponent`、`EditInline` |

顺带使用（约 6 个 Automation）：
- `ScriptExamples.Coverage.PropertySpecifiers` — Coverage 脚本中 Root + Attached Billboard 层级
- `Actor.Interface.BoundMethods` — `DefaultComponent, RootComponent` 作场景骨架
- `Actor.Interface.ComponentAndInput` — Root + `Attach = RootScene` 的 ExtraScene
- `Actor.RadialDamage` — `DefaultComponent, RootComponent` 的 Sphere + `default DamageSphere.SetSphereRadius`
- `Learning.Runtime.ComponentHierarchy` — 两个 `DefaultComponent` Angelscript component 的 Trace 占位
- `Template.ReflectionAccess.PathAccessExtendedTypes` — 单 `UPROPERTY(DefaultComponent)` 反射路径与 GetObject

**与 Hazelight 的 delta**：
- **功能 delta**：无明确差距。
- **测试 delta**：无 OverrideComponent 多层继承形状（A→B→C 逐层 override）专项；无 ShowOnActor + EditorOnly 组件组合；无深层 Attach 链（3+ 层 parent → child → grandchild）；无与 native Actor 基类已有默认组件交互的专项测试；`OverrideComponent` 仅在元数据测试中出现一次正例。
- **示例 delta**：`Script/Examples/` 中 `DefaultComponent` 使用充分（MovingObject/PropertySpecifiers/ConstructionScript 等），无差距。

### 四、UFUNCTION Specifier

**实现状态：已支持**

- **入口**：`ProcessFunctionMacro()`（`AngelscriptPreprocessor.cpp:1275-1603`）。
- **当前支持**（非 Haze 分支 `#else`）：
  - `BlueprintCallable` / `NotBlueprintCallable` / `BlueprintPure`
  - `BlueprintEvent` / `BlueprintOverride`
  - `Server` / `Client` / `NetMulticast` / `WithValidation` / `Unreliable`
  - `CallInEditor` / `Exec` / `BlueprintAuthorityOnly`
  - `Category` / `Keywords` / `ToolTip` / `DisplayName` / `BlueprintProtected`
  - `Meta(...)` / `ForcedAssets(...)`
- **Haze 分支**（`#if WITH_ANGELSCRIPT_HAZE`）使用 `NetFunction` / `CrumbFunction` / `DevFunction` 替代 UE 风格 Server/Client/NetMulticast。

**测试覆盖（约 8 个 Automation）**：

| # | Automation 路径 / 文件 | 验证内容 |
|---|------------------------|----------|
| 1 | `Compiler.EndToEnd.FunctionBlueprintCallableDefaultsAndOverrides` | `BlueprintCallable`/`BlueprintPure`/`Not`/Default 组合；`FUNC_BlueprintCallable` 与 `FUNC_BlueprintPure` 标志验证 |
| 2 | `Compiler.EndToEnd.BlueprintEventWrapper` (×2 assertions) | Blueprint 包装 + `FUNC_BlueprintEvent`；Push 到 `SuperFunction` 验证 |
| 3-4 | `Compiler.EndToEnd.GlobalUFunctionTests` (×2) | 文件作用域 `UFUNCTION(BlueprintCallable)` + 命名净化（`::` → `_`） |
| 5 | `Compiler.EndToEnd.MetadataSpecifier` | `meta=(...)` 括号内含难解析字符串（`,`、`=`）；GetMetaData 往返 |
| 6 | `Compiler.EndToEnd.SpecifierMetadata` | `UCLASS`/`UFUNCTION`/`UENUM` 的 `DisplayName`/`ToolTip` 往返（跨 specifier 类型复合测试） |
| 7 | `ScriptExamples.FunctionSpecifiers` | 示例级编译通过（含 BlueprintCallable/Pure/Event/Server/Exec 等，无逐项反射断言） |
| 8 | `Compiler.EndToEnd.NetworkRPC.*`（6 个中的 specifier 部分） | Server/Client/NetMulticast specifier → `FUNC_Net*` 标志（与 RPC 专用测试重叠） |

**与 Hazelight 的 delta**：
- 网络 specifier 命名不同：当前使用 UE 标准名（Server/Client/NetMulticast），Hazelight 使用自定义名（NetFunction/CrumbFunction）——这是**有意的编译期分叉**，通过 `WITH_ANGELSCRIPT_HAZE` 宏控制，不是遗漏。
- `DevFunction`：Hazelight 专有，当前非 Haze 分支不支持。
- `AS_ENFORCE_SERVER_RPC_VALIDATION`：当前已实现，可配置强制 Server RPC 必须带 WithValidation。
- **测试缺口**：无 `CallInEditor` 编辑器内调用验证；无 `BlueprintAuthorityOnly` 权限过滤专项；`ForcedAssets(...)` 无专项测试。

### 五、UPROPERTY Specifier

**实现状态：已支持**

- **入口**：`ProcessPropertyMacro()`（`AngelscriptPreprocessor.cpp:2237-2650`）。
- **当前支持**：`EditConst`、`BlueprintReadOnly`、`BlueprintReadWrite`、`NotEditable`、`NotVisible`、`Interp`、`Config`、`Transient`、`AssetRegistrySearchable`、`NoClear`、`DefaultComponent`、`OverrideComponent`、`ShowOnActor`、`RootComponent`、`Attach`、`AttachSocket`、`BlueprintSetter`、`BlueprintGetter`、`AdvancedDisplay`、`SaveGame`、`Meta(...)`。
- **网络相关**（`#if !WITH_ANGELSCRIPT_HAZE`）：`Replicated`、`ReplicatedUsing`、`ReplicationCondition`、`NotReplicated`——Hazelight 编译把这些去掉（由引擎侧接管）。

**测试覆盖（约 8 个 Automation）**：

| # | Automation 路径 / 文件 | 验证内容 |
|---|------------------------|----------|
| 1-2 | `Compiler.EndToEnd.PropertyMetadataTests` (×2) | `ReplicatedUsing` + `BlueprintGetter`/`BlueprintSetter` 互斥规则；`BlueprintPure` 约束 |
| 3 | `Compiler.EndToEnd.PropertyReplicationConditionTests` | `Replicated + ReplicationCondition=OwnerOnly/SkipReplay` → `ELifetimeCondition` 映射 |
| 4 | `Compiler.EndToEnd.PropertyDefaultTests` | 属性默认值（与 `default` 语句间接相关但焦点在 `UPROPERTY()` 声明层） |
| 5 | `Preprocessor.Properties.PreprocessorPropertyDefaultSpecifierTests` | 默认 `BlueprintReadOnly` 行为验证；裸 `UPROPERTY()` 无 specifier 时的默认标志 |
| 6-7 | `Preprocessor.Properties.PreprocessorPropertyMacroErrorTests` (×2 负例) | `ReplicatedUsing` 缺回调 → 编译失败；非法 `ReplicationCondition` 值 → 编译失败 |
| 8 | `ScriptExamples.PropertySpecifiers` | `EditConst`/`NotEditable`/`BlueprintReadOnly`/`EditCondition` 示例编译通过（无逐项反射断言） |

**与 Hazelight 的 delta**：
- 网络属性 specifier 在 Haze 编译下被去掉，当前插件完整保留。
- Hazelight 可能有额外的 property specifier（如特定的 GAS/编辑器扩展 meta），需进一步符号级 diff 确认。
- **测试缺口**：`EditConst`/`NotEditable` 无逐项反射断言的专用测试（仅通过示例编译验证）；`AdvancedDisplay`/`SaveGame`/`NoClear` 无专项测试；`Interp`/`Config`/`Transient` 无专项测试。

### 六、UCLASS Specifier

**实现状态：已支持**

- **入口**：`ProcessClassMacro()`（`AngelscriptPreprocessor.cpp:2128-2235`）。
- **当前支持**：`NotPlaceable`、`NotBlueprintable`、`Blueprintable`、`Abstract`、`Transient`、`HideDropdown`、`DefaultToInstanced`、`EditInlineNew`、`Deprecated`、`Config`、`ClassGroup`、`HideCategories`、`DefaultConfig`、`ComponentWrapperClass`、`BlueprintType`（`[UE++]` 扩展）、`Meta(...)`。
- **已声明但未接线**：`AutoCollapseCategories`（`PP_NAME` 在 line 2237 定义，但未在 `ProcessClassMacro` 的 if/else 链中处理）。

**测试覆盖（约 2 个 Automation）**：

| # | Automation 路径 / 文件 | 验证内容 |
|---|------------------------|----------|
| 1 | `Compiler.EndToEnd.SpecifierMetadataTests` | `UCLASS(meta=(DisplayName="...", ToolTip="..."))` 往返验证；`GetMetaData` 对 key-value 精确匹配 |
| 2 | `Compiler.EndToEnd.MetadataSpecifierTests` | `meta=(...)` 含 `,`/`=` 等难解析字符的 UCLASS 场景（与 UFUNCTION 共用测试但含 UCLASS 分支） |

**与 Hazelight 的 delta**：
- `AutoCollapseCategories` 声明了但未实际生效——可能是遗漏。
- `BlueprintType` 作为 UCLASS specifier 是 `[UE++]` 本地扩展，Hazelight 可能走不同路径。
- **测试缺口**：`BlueprintType` UCLASS specifier 无专项测试；`Abstract`/`DefaultToInstanced`/`EditInlineNew`/`Deprecated` 无专项反射断言测试；`HideCategories`/`ClassGroup` 仅依赖编辑器运行时行为、无自动化验证。

### 七、`foreach` (Range-based For)

**实现状态：已支持**

- **入口**：`PostProcessRangeBasedFor()`（`AngelscriptPreprocessor.cpp:4019-4185`），在 `CondenseFromChunks` 后、`PostProcessLiteralAssets` 前执行。
- **正则**：`for(\s*)\(([^:;{]*):([^:;{\n][^;{\n]*)\)(\s*)(\{|.*;)`。
- **改写产物**：`for ... (auto _Iterator = <expr>.Iterator(); _Iterator.CanProceed; ) { <var> = _Iterator.Proceed(); ... }`。依赖集合类型提供 `.Iterator()` / `CanProceed` / `Proceed()` 协议。

**测试覆盖（9 个 Automation，5 个文件）**：

| # | Automation 路径 | 容器类型 | 迭代模式 |
|---|----------------|----------|----------|
| 1 | `ControlFlow.ForeachBreakContinueNested` | `TArray<int>` | 仅值；`continue`（跳过 2）+ `break`（在 4 处退出） |
| 2 | `Bindings.ArrayForeach` | `TArray<int>` | **值 + index** 双变量：`foreach (int Value, int Index : Values)` |
| 3 | `Bindings.SetForeach` | `TSet<int>` | 仅值 |
| 4 | `Bindings.SetForeachExactVisit` | `TSet<int>`（含空集合） | 仅值；验证空集合不遍历、非空时每元素恰好一次 |
| 5 | `Bindings.MapForeach` | `TMap<FName, int>` | **值 + key** 双变量：`foreach (int Value, FName Key : Values)` |
| 6 | `Bindings.MapForeachKeyValuePairing` | `TMap<FName, int>`（含空 Map） | 值 + key；校验 key/value 配对与每桶 key 唯一 |
| 7 | `Bindings.ForeachCompat` | `int[]` 别名 + `TArray<FName>` + `TArray<FVector>` | **C++ 风格** `for (int Value : ...)` + `for (const FVector& VectorValue : ...)`；变更数组后再迭代 |
| 8 | `Compiler.EndToEnd.RangeBasedForRewriteSupportsBlockAndSingleLine` | `TArray<int>` | **预处理器改写**：块形式 + 单行形式各一次；`__auto_constref_type` 注入 |
| 9 | `Compiler.EndToEnd.RangeBasedForRewriteSkipsStringAndCommentLiterals` | — | 预处理器不在字符串/注释内误改写 `for (...)` |

**与 Hazelight 的 delta**：
- **功能 delta**：已对齐（基于相同的 `.Iterator()` / `CanProceed` / `Proceed()` 协议）。
- **测试 delta**：无 UObject 数组 foreach；无嵌套 foreach（外层 Array 内层 Map）专项；无 `const` 迭代变量 vs 可变变量的对比验证；无 `foreach` 与反射容器/自定义迭代器混用；`Script/Examples/` 中**无** foreach 示例。
- **示例 delta**：`Script/Examples/` 与 `AngelscriptTest/Examples/` 中均未出现 `foreach` 字面使用。

### 八、网络 RPC

**实现状态：已支持**

- 预处理器支持 `Server` / `Client` / `NetMulticast` / `WithValidation` / `Unreliable` specifier。
- `AngelscriptClassGenerator.cpp` 在类最终化时设置 `FUNC_Net*` / `FUNC_NetReliable` / `FUNC_NetValidate` 等 UE 标准标志。

**测试覆盖（专用 6 + 分散复制约 8，合计约 14 个 Automation）**：

专用 RPC 测试（`Networking/AngelscriptNetworkRPCTests.cpp`，纯编译/反射级）：

| # | Automation 路径 | 验证内容 |
|---|----------------|----------|
| 1 | `RPC.ServerDeclarationCompiles` | `UFUNCTION(Server)` → `FUNC_Net` + `FUNC_NetServer` + 默认可靠（`FUNC_NetReliable`）；类上 `default bReplicates = true` |
| 2 | `RPC.ClientDeclarationCompiles` | `UFUNCTION(Client)` → `FUNC_Net` + `FUNC_NetClient` + 默认可靠 |
| 3 | `RPC.NetMulticastDeclarationCompiles` | `UFUNCTION(NetMulticast)` → `FUNC_Net` + `FUNC_NetMulticast` + 默认可靠 |
| 4 | `RPC.WithValidationDeclarationCompiles` | `UFUNCTION(Server, WithValidation)` + `_Validate` 函数 → `FUNC_NetValidate` |
| 5 | `RPC.UnreliableDeclarationCompiles` | `UFUNCTION(Client, Unreliable)` → 无 `FUNC_NetReliable` |
| 6 | `RPC.MixedDeclarationsCompile` | 同一类 Server/Client/NetMulticast+Unreliable/Server+WithValidation + `UPROPERTY(Replicated)`/`ReplicatedUsing` → `CPF_Net`/`CPF_RepNotify` |

分散复制/网络测试（跨多个文件）：
- `Compiler.EndToEnd.PropertyReplicationCondition`（1 个）— `Replicated + ReplicationCondition=OwnerOnly/SkipReplay` → `ELifetimeCondition`
- `Compiler.EndToEnd.PropertyMetadata`（2 个）— `ReplicatedUsing` + `BlueprintGetter/Setter` 规则
- `Preprocessor.PropertyMacroError`（2 个负例）— `ReplicatedUsing` 缺回调、非法 `ReplicationCondition`
- `ClassGenerator.ASClass.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties`（1 个）— 生命周期复制列表含继承属性
- `ClassGenerator.ASFunction.NetValidateCache`（1 个）— `FUNC_NetValidate` 缓存
- GAS 多个测试中涉及 `GetIsReplicated()` 等（与 RPC 间接相关）

**与 Hazelight 的 delta**：
- **功能 delta**：网络 specifier 命名不同（UE 标准 vs Hazelight 自定义，由 `WITH_ANGELSCRIPT_HAZE` 宏控制）；`DevFunction` Hazelight 专有，当前非 Haze 分支不支持。
- **测试 delta**：全部为编译/反射级验证（检查 `FUNC_Net*` 标志），无实际 RPC 派发、多进程 PIE、或 FakeNetDriver 运行时测试；无 `Unreliable` 丢包行为验证。
- **示例 delta**：`Script/Examples/` 中无 RPC 示例；尚未有独立的 Network 示例 `.as` 文件。

### 九、GAS / EnhancedInput / FunctionLibrary

**GAS 实现面**：
- `Core/GAS/`：18 个文件（Actor/Character/Pawn 基类、AbilitySystemComponent、AttributeSet、Ability、AbilityTask、库与工具）。
- `Binds/`：6 个 GAS 相关文件。

**GAS 测试覆盖（42 个 Automation，24 个 .cpp 文件）**：

| 分组 | Automation 数 | 代表路径 | 主要验证内容 |
|------|:---:|----------|-------------|
| AbilitySystem 核心 | 9 | `GAS.AbilitySystem.*` | ASC Tests (3) + Lifecycle (1) + Callback (1) + Query (3) + Tag (1)；ASC 注册/卸载/查询/标签阻塞/事件回调 |
| Ability | 5 | `GAS.Ability.*` | Tests (2) + Task (1) + AsyncLibrary (2)；能力激活/结束/异步等待/取消 |
| AttributeSet | 3 | `GAS.AttributeSet.*` | Tests (1) + Runtime (1) + ChangedDataMixin (1)；属性初始化/运行时修改/Mixin 变更通知 |
| Actor 基类 | 2 | `GAS.GASActorBase.*` | GASActorBase (2)；继承 Actor/Pawn + ASC/AttributeSet 注入验证 |
| GAS Bindings | 2 | `GAS.ValueBindings.*` | FGameplayAttributeData 与 FScalableFloat 等值类型绑定兼容 |
| Gameplay 辅助 | 13 | `GAS.Gameplay.*` | TagBindings (8) + TagContainer (1) + EmptyContract (1) + FunctionLibrary (2) + EffectUtils (1) + CueUtils (1)；Tag 增删查/容器操作/Effect 辅助/Cue 辅助 |
| AbilityTaskLibrary | 8 | `GAS.AbilityTaskLibrary.*` | Tests (3) + ActorLifecycle (1) + Observer (1) + StateOverlap (1) + Attribute (1)；Task 生命周期/观察者/状态重叠/属性变化监听 |

**EnhancedInput 实现面**：
- `Binds/`：3 个文件（`Bind_FInputActionValue.cpp` / `Bind_FInputBindingHandle.cpp` / `Bind_UEnhancedInputComponent.cpp`）。
- 示例：3 个 `.as` 示例（`Example_EnhancedInput_Component.as` / `Example_EnhancedInput_PlayerController.as` / `Example_EnhancedInput_InterfaceCall.as`）。

**EnhancedInput 测试覆盖（3 个 Automation，1 个文件 `AngelscriptEnhancedInputBindingsTests.cpp`）**：

| # | Automation 路径 | 验证内容 |
|---|----------------|----------|
| 1 | `Bindings.EnhancedInput.InputActionValueMulAssignCompat` | `FInputActionValue` 链式 `*=` 运算；float/FVector2D/FVector 子类型保持 |
| 2 | `Bindings.EnhancedInput.EnhancedInputComponentConstCompat` | `const UEnhancedInputComponent` 上调用只读 API 编译约束 |
| 3 | `Bindings.EnhancedInput.InputDebugKeyBindingExecuteCompat` | `FInputBindingHandle` Execute 签名 + 绑定句柄生命周期 |

**FunctionLibrary 实现面**：
- Runtime：21 个文件（含 8 个 `*MixinLibrary` 命名的 ScriptMixin 扩展）。
- Editor：6 个文件。
- Mixin 概念：通过语言 `mixin` + C++ `ScriptMixin` + `*MixinLibrary` + 反射注入 `bInjectMixinObject` 共同承担。

**FunctionLibrary 测试覆盖（23 个 Automation，16 个文件）**：

| 分组 | Automation 数 | 代表路径 | 覆盖领域 |
|------|:---:|----------|----------|
| FrameTime | 2 | `Bindings.FunctionLibrary.FrameTime.*` | DeltaSeconds/WorldDeltaSeconds |
| Math | 3 | `Bindings.FunctionLibrary.Math.*` | FMath 常用静态函数 |
| HitResult | 2 | `Bindings.FunctionLibrary.HitResult.*` | FHitResult 读取/赋值 |
| GameplayTag | 2 | `Bindings.FunctionLibrary.GameplayTag.*` | Tag 匹配/Contains/MakeTag |
| WorldCollision | 2 | `Bindings.FunctionLibrary.WorldCollision.*` | Trace/Sweep 辅助 |
| SoftReference | 2 | `Bindings.FunctionLibrary.SoftReference.*` | TSoftObjectPtr 加载/有效性 |
| AssetManager | 2 | `Bindings.FunctionLibrary.AssetManager.*` | 异步加载/同步加载 |
| Script | 2 | `Bindings.FunctionLibrary.Script.*` | Script 模块辅助函数 |
| World | 2 | `Bindings.FunctionLibrary.World.*` | GetWorld/SpawnActor 辅助 |
| Widget | 1 | `Bindings.FunctionLibrary.Widget.*` | UMG Widget 辅助 |
| Curve | 1 | `Bindings.FunctionLibrary.Curve.*` | UCurveFloat/UCurveVector 读值 |

**与 Hazelight 的 delta（GAS/EnhancedInput/FunctionLibrary 综合）**：
- **功能 delta**：GAS 核心已高度对齐；EnhancedInput 绑定基本覆盖；FunctionLibrary 21+ 运行时库 + 8 个 Mixin 提供较广表面。
- **测试 delta**：
  - GAS 42 个 Automation 覆盖深度高，但无 `.as` 脚本示例（仅 C++ 验证）。
  - EnhancedInput 仅 3 个绑定兼容性测试（无事件绑定/解绑/ActionValue 子类型完整覆盖）；`Script/Examples/EnhancedInput/` 的 3 个 `.as` 示例无对应自动化测试。
  - FunctionLibrary 23 个 Automation 覆盖面广，但每个 Library 仅 1-3 个用例，深度浅。
- **示例 delta**：GAS 无 `.as` 脚本示例（README 排除项）；EnhancedInput 有 3 个示例但无回归覆盖；FunctionLibrary 无独立示例。

## 分阶段执行计划

### Phase 1：固化当前特性对齐基线与证据索引

> 目标：把当前已确认的实现状态和代码位置冻结为可引用的基线，避免后续重复探索。

- [ ] **P1.1** 同步本计划的事实状态到相关文档
  - 当前 `Plan_StatusPriorityRoadmap.md` 的"不应再误判为差距"章节还未包含 `default` 语句、`asset` 声明、`DefaultComponent`、`foreach` 等预处理器特性的对齐确认。把本计划的结论同步到 `Plan_StatusPriorityRoadmap.md` 与 `Plan_HazelightCapabilityGap.md` 的对应段落，避免后续任务继续把已对齐特性列为缺口。
  - 同时在 `Plan_OpportunityIndex.md` 中增加本计划的索引条目。
- [ ] **P1.1** 📦 Git 提交：`[Docs/Roadmap] Docs: sync script feature parity baseline to sibling plans`

- [ ] **P1.2** 修复 `AutoCollapseCategories` 声明与实现不同步
  - `PP_NAME_AutoCollapseCategories` 在 `AngelscriptPreprocessor.cpp:2237` 已声明，但 `ProcessClassMacro()` 的 if/else 链（line 2150-2235）中没有对应分支。写入 UCLASS 时会触发"Unknown class specifier"报错。需要确认是有意排除还是遗漏，若为遗漏则补上处理分支并加正负例测试。
  - 参考 Hazelight 基线确认该 specifier 的预期行为（写入 `ClassDesc->Meta` 或设置 flag）。
- [ ] **P1.2** 📦 Git 提交：`[AngelscriptRuntime] Fix: wire AutoCollapseCategories into ProcessClassMacro`

### Phase 2：补齐 `default` 语句测试矩阵

> 目标：把 `default` 语句从"有实现、顺带验证"推进到"系统性测试覆盖"。

- [ ] **P2.1** 建立 `default` 语句专项测试文件
  - 当前仅有 2 个端到端编译测试覆盖 `default` 语法，其余 15+ 个文件为场景内顺带使用。需要新建 `Plugins/Angelscript/Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelinePropertyDefaultMatrixTests.cpp`（或扩展现有文件），按类型系统性覆盖。
  - 测试矩阵应包含：整数/浮点/bool/FName/枚举/FVector/FColor/FString 等基础类型、TArray/TMap/TSet 容器类型的 `default` 赋值、`default` 调用方法（如 `Tags.Add`）、子对象属性路径（如 `default SomeComp.SomeProperty = ...`）、多行 `default` 拼接行为、与 `UPROPERTY()` 内联初始化的优先级交互。
  - 负例矩阵：非法 `default`（不存在的属性名、类型不匹配、在非类作用域使用）应产生清晰的编译错误。
- [ ] **P2.1** 📦 Git 提交：`[AngelscriptTest] Test: establish default statement systematic test matrix`

### Phase 3：补齐 `asset` 声明与 `DefaultComponent` 测试深度

> 目标：把字面量资产和组件声明的验证从"核心路径覆盖"推进到"边界与负例覆盖"。

- [ ] **P3.1** 扩展 `asset` 字面量资产测试边界
  - 当前 5 个测试覆盖了核心 post-init、getter 重写、字符串/注释跳过和热重载场景。需要补充：同一模块多个 `asset` 声明互不冲突、`asset` 声明引用自定义 UObject 子类、预处理器失败路径（非法语法如 `asset X of` 缺少类型、`asset` 在函数体内使用）、`asset` 与 `DefaultComponent` 在同一类中共存。
  - 测试应落入 `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/` 或 `Preprocessor/` 已有文件的扩展。
- [ ] **P3.1** 📦 Git 提交：`[AngelscriptTest] Test: expand literal asset boundary and negative tests`

- [ ] **P3.2** 扩展 `DefaultComponent` / `OverrideComponent` 测试深度
  - 当前 8 个测试覆盖了基本层级、元数据和两条负例。需要补充：OverrideComponent 的多层继承形状（A → B → C，B override A 的组件，C 再次 override）、ShowOnActor + EditorOnly 组件组合、深层 Attach 链（3+ 层 parent → child → grandchild）、DefaultComponent 与 native Actor 基类已有默认组件的交互。
  - 测试应落入 `Plugins/Angelscript/Source/AngelscriptTest/Component/` 与 `ClassGenerator/`。
- [ ] **P3.2** 📦 Git 提交：`[AngelscriptTest] Test: deepen DefaultComponent and OverrideComponent coverage`

### Phase 4：补齐 `foreach` 与网络 RPC 测试闭环

> 目标：在已有"功能可用"的基础上补齐验证深度。

- [ ] **P4.1** 扩展 `foreach` 测试矩阵
  - 当前 8 个测试覆盖了 Array/Set/Map/嵌套 break+continue/编译器改写。需要补充：`foreach` 与 UObject 数组/反射容器的混用、const 迭代变量、值类型 vs 引用类型迭代、嵌套 `foreach`（外层 Array 内层 Map）、空容器不进入循环体。
  - 测试应落入 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/` 或 `Compiler/` 已有文件的扩展。
- [ ] **P4.1** 📦 Git 提交：`[AngelscriptTest] Test: expand foreach iteration matrix`

- [ ] **P4.2** 规划网络 RPC 运行时派发测试路径
  - 当前 6 个 RPC 测试均为编译/反射级验证（检查 `FUNC_Net*` 标志）。真正的 RPC 派发测试需要多进程 PIE 或 FakeNetDriver 环境，超出本计划的直接实施范围。
  - 本步骤只做路径规划：确认 `FakeNetDriver` 的当前可用状态、评估在 headless automation 中跑 client/server 的可行性、输出结论写入 `Plan_NetworkReplicationTests.md`。
- [ ] **P4.2** 📦 Git 提交：`[Docs/Roadmap] Docs: route RPC runtime dispatch testing path`

### Phase 5：补齐 GAS 示例与 EnhancedInput 测试

> 目标：把 GAS/EnhancedInput 的验证面从"C++ 测试强"推到"示例+测试双覆盖"。

- [ ] **P5.1** 建立 GAS 脚本示例最小集
  - 当前 `Script/Examples/` 无 GAS `.as` 示例，README 明确标注为排除项。参考 Hazelight `GASExamples/` 分组，先建立 3-5 个最小示例：AbilitySystem 基础用法、GameplayEffect 应用、AttributeSet 自定义、AbilityTask 使用。
  - 示例建立后同步更新 `Script/Examples/README.md`，并在 `Examples/` 测试目录下新增对应的编译冒烟测试。
  - 关联 `Plan_ScriptExamplesExpansion.md` 推进。
- [ ] **P5.1** 📦 Git 提交：`[Script/Examples] Feat: establish GAS script examples minimum set`

- [ ] **P5.2** 补齐 EnhancedInput 测试覆盖
  - 当前仅 1 个绑定测试文件（`AngelscriptEnhancedInputBindingsTests.cpp`），对比 3 个 Bind 文件和 3 个示例，测试面明显偏薄。需要补充：`FInputActionValue` 各子类型读取、`UEnhancedInputComponent` 事件绑定/解绑、`FInputBindingHandle` 生命周期。
  - 测试应落入 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/`。
- [ ] **P5.2** 📦 Git 提交：`[AngelscriptTest] Test: expand EnhancedInput binding coverage`

## 验收标准

1. 本计划中"当前事实状态快照"章节的每个特性都附有代码位置（文件 + 行号范围）和测试文件列表，后续执行者可直接定位。
2. 每个特性的"与 Hazelight 的 delta"被区分为三类：功能 delta、测试 delta、示例 delta。
3. `AutoCollapseCategories` 的声明与实现不同步问题被明确记录并排入 P1.2。
4. Phase 2-5 的测试扩展任务都有明确的测试矩阵描述（覆盖什么类型/场景/负例），而不是模糊的"补更多测试"。
5. 本计划不与已有 sibling plan 重叠：网络 RPC 运行时测试路由到 `Plan_NetworkReplicationTests.md`，GAS 示例路由到 `Plan_ScriptExamplesExpansion.md`，Bind API 差量路由到 `BindGapAuditMatrix.md`。
6. 完成后 `Plan_StatusPriorityRoadmap.md` 与 `Plan_HazelightCapabilityGap.md` 的"不应再误判为差距"列表已包含 `default`/`asset`/`DefaultComponent`/`foreach` 等预处理器特性。

## 风险与注意事项

### 风险

1. **测试矩阵可能过度扩展**：`default` 语句的类型组合矩阵很容易做到几十个用例，但大部分底层路径相同。
   - **缓解**：每种类型选一个代表性用例，不追求完全笛卡尔积；重点放在边界和负例。

2. **`AutoCollapseCategories` 修复可能影响已有脚本**：如果现有 `.as` 文件中使用了该 specifier 但一直被当作未知 specifier 报错忽略，修复后行为会变化。
   - **缓解**：修复前先搜索仓库内是否有使用该 specifier 的脚本，若无则风险极低。

3. **GAS 示例依赖运行时环境**：GAS 示例需要 AbilitySystem 组件和 Effect 等运行时对象，纯编译冒烟测试可能不足。
   - **缓解**：先做编译级冒烟，运行时验证由 `Plan_GASIntegrationTests` 承接。

### 已知行为变化

1. **`AutoCollapseCategories` 接线后**：若修复为写入 `ClassDesc->Meta`，使用该 specifier 的脚本类在编辑器中的 Details 面板折叠行为会生效。
   - 影响文件：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`（`ProcessClassMacro` 函数）

## 代码位置快速索引

| 特性 | 文件 | 行号范围 |
|------|------|----------|
| `default` 探测 | `Preprocessor/AngelscriptPreprocessor.cpp` | 3638-3648 |
| `ProcessDefaults` | 同上 | 1230-1255 |
| `PostProcessLiteralAssets` | 同上 | 4187-4326 |
| `PostProcessRangeBasedFor` | 同上 | 4019-4185 |
| `ProcessFunctionMacro` | 同上 | 1275-1603 |
| `ProcessPropertyMacro` | 同上 | 2237-2652 |
| `ProcessClassMacro` | 同上 | 2128-2235 |
| `FDefaultsCode` / `FChunk::Defaults` | `Preprocessor/AngelscriptPreprocessor.h` | 71-75, 90 |
| GAS Core | `Core/GAS/` | 18 个文件 |
| GAS Binds | `Binds/Bind_FGameplay*.cpp` 等 | 6 个文件 |
| EnhancedInput Binds | `Binds/Bind_FInput*.cpp` 等 | 3 个文件 |
| FunctionLibraries (Runtime) | `FunctionLibraries/` | 21 个文件 |
| FunctionLibraries (Editor) | `AngelscriptEditor/FunctionLibraries/` | 6 个文件 |
