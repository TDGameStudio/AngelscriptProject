# AngelScript Coverage 待覆盖 / 边界矩阵（统一记录）

> 配合 `coverage-matrix.md`（主索引）及 `matrices/` 下各领域矩阵使用。本文记录两类内容：
>
> 1. **待覆盖 / 待增强**（⬜ / 🟡）：尚未覆盖或可继续加强的真实子项。
> 2. **fork 不支持 / 不适用**（🚫）：当前 AngelScript fork 明确不支持的能力，已作为边界测试或不纳入计划，**避免后续重复尝试**。
>
> 重要原则：历史文档（`Documents/Coverage/`）长期高估缺口（把已实现项标为 ⬜）。本文已剔除"伪缺口"，凡标注 `需审计` 者表示需对照实际测试文件确认后再动手。

## 图例

| 标记 | 含义 |
|------|------|
| ⬜ | 待覆盖（建议新增测试） |
| 🟡 | 部分覆盖（建议增强既有测试） |
| 🚫 | fork 不支持 / 不适用（仅记录，不计划补测） |

---

## 1. 待覆盖 / 待增强（候选工作项）

> 注：经对照实际测试代码审计后，已剔除"伪缺口"。例如 GC 循环引用（`GCStrongCycleReclaim`/`GCRootReachability`/`GCUPropertyReachabilityChain`）与动态材质参数（`DynamicMaterialParametersAndAssignment`/`...Readback`）实际已覆盖，不再列为缺口。

| # | 优先级 | 子项 | 关联测试文件 | 状态 | 说明 |
|---|-------|------|------------|------|------|
| G1 | 🟡 中 | AnimInstance 行为覆盖 | AngelscriptCoverageAnimInstanceTests.cpp | ✅ | `AnimInstanceQueryFunctionsExecute` 已把 owner / montage / curve 查询从 compile-only 升级为 asset-free 运行期断言；状态机/动画通知等真实动画资产路径不纳入本轮 headless Coverage |
| G2 | 🟢 低 | SaveGame 复杂结构序列化 | AngelscriptCoverageSaveGameTests.cpp | ✅ | `ComplexStructAndArraySlotRoundTrip` 已覆盖嵌套 USTRUCT、`TArray<int>`、`TArray<USTRUCT>` save→load 往返 |
| G5 | 🟢 低 | TArray 越界 `[]` 访问语义 | AngelscriptCoverageTArrayAdvancedTests.cpp | ✅ | `TArrayOutOfBoundsIndexAccess` 已覆盖读/写越界 `[]` 均抛出稳定脚本异常 `Array index out of bounds.` |
| G6 | 🟢 低 | TMap 值为用户 USTRUCT | AngelscriptCoverageTMapAdvancedTests.cpp | ✅ | `TMapUserStructValues` 已覆盖 `TMap<int, 用户USTRUCT>` 的 Add/Find/index/overwrite 运行期往返 |
| G7 | 🟢 低 | Widget 动画/焦点运行期断言 | AngelscriptCoverageWidgetTests.cpp | 🟡/需实测 | `WidgetAnimationPlaybackReflectionSurfaces` / `WidgetFocusAndInputModeReflectionSurfaces` 仅反射表面；需实测 headless 能否断言动画推进/焦点转移，否则维持反射上限 |
| G8 | 🟢 低 | UClass CDO ↔ 实例独立性 | AngelscriptCoverageUClassTests.cpp | ✅ | `UClassDefaultObjectAndInstanceStateIndependence` 已覆盖 CDO 突变 → 后续 `NewObject` 继承、既有实例不 retroactive 修改、实例突变不污染 CDO 或后续实例 |
| G9 | 🟡 中 | Actor 自身 Tick/EndPlay/Destroyed 运行期分发 | AngelscriptCoverageClassLifecycleTests.cpp | 🟡 | `ActorLifecycle`/`MultiLevelInheritanceLifecycle` 脚本声明覆盖但仅断言 BeginPlay；Component 侧已用 `DispatchComponentTick` + `DestroyComponent` 真实驱动，Actor 同侧未补 |
| G10 | 🟢 低 | UObject/Actor native-only 虚方法 BlueprintOverride 拒绝边界补全 | AngelscriptCoverageClassLifecycleTests.cpp | ✅ | `NativeOnlyVirtualOverrideBoundaries` 已固化 `PostLoad / PreSave / PostInitProperties / BeginDestroy / FinishDestroy / Reset` 等 native-only 虚方法作为 `BlueprintOverride` 的编译失败边界；`OnReset` 合法路径仍由 UFunction/Actor lifecycle 测试覆盖 |
| G11 | 🟢 中 | FInstancedStruct 作 USTRUCT 成员 | AngelscriptCoverageUStructTests.cpp | ⬜ | fork 已绑定（`Bind_FInstancedStruct.cpp`），Coverage 域未覆盖；补 UPROPERTY 反射 + `InitializeAs<FFoo>` / `Get<FFoo>()` 往返 + 容器/参数形态 |
| G12 | 🟢 低 | USTRUCT 值语义深拷贝独立性补强 | AngelscriptCoverageUStructTests.cpp | 🟡 | `UStructValueSemantics` 仅 int+FString 成员的拷贝独立性；缺含 TArray/TMap/TSet 成员的深拷贝独立性断言 |
| G13 | 🟢 低 | USTRUCT 运算符重载子集补全 | AngelscriptCoverageUStructTests.cpp | 🟡 | `UStructOperators` 已覆盖 opEquals/opAdd/opAssign/opCmp/opIndex；缺 opSub/opMul/opDiv/opNeg 与复合赋值 opAddAssign/opSubAssign/opMulAssign/opDivAssign |
| G14 | 🟢 低 | FInstancedPropertyBag / FPropertyBag 边界实证 | AngelscriptCoverageUStructTests.cpp | ⬜/需实测 | fork 内 grep 无 `Bind_FPropertyBag*`，疑似 🚫 边界；先 1 行 compile-failure 实测再定状态 |
| G15 | 🟢 低 | HasNativeMake / HasNativeBreak 说明符边界实证 | AngelscriptCoverageUStructTests.cpp | ⬜/需实测 | fork 内 grep 无解析路径；现 `UStructUnsupportedSpecifiers` 仅覆盖 Atomic/Immutable/NoExport；1 行 compile-failure 实测固化 🚫 |
| G16 | 🟢 低 | USTRUCT 自定义 Serialize(FArchive&) 边界实证 | AngelscriptCoverageUStructTests.cpp | ⬜/需实测 | fork 无 `FArchive` AS 绑定；1 行 compile-failure 实测固化 🚫 |
| G17 | 🟢 低 | USTRUCT NetSerialize 复制序列化边界实证 | AngelscriptCoverageUStructTests.cpp | ⬜/需实测 | fork 内 grep 无 `NetSerialize` 绑定；1 行 compile-failure 实测固化 🚫 |
| G18 | 🟢 低 | AS USTRUCT 静态成员边界实证 | AngelscriptCoverageUStructTests.cpp | ⬜/需实测 | AS 语言不支持类/结构静态字段（已在委托域以 `BindStatic` 边界形式记录于 §2.4）；USTRUCT 域未做对应 compile-failure 行 |
| G19 | 🟢 低 | for-each 迭代中修改容器（迭代器失效语义） | AngelscriptCoverageLoopTests.cpp | ⬜ | `ForEach` 仅断言 `int& Val` 元素就地修改；缺 Add/Remove 容器在迭代中修改时的运行期语义断言 |
| G20 | 🟢 低 | EnhancedInput ETriggerEvent 全集反射保留 | AngelscriptCoverageInputTests.cpp | 🟡 | 5 个 ETriggerEvent 已 BindAction 编译可达；`GetTriggerEvent()` 反射断言仅覆盖 Started+Triggered，Ongoing/Completed/Canceled 三事件缺独立反射保留断言 |
| G21 | 🟢 低 | EnhancedInput Modifier/Trigger ModifyRaw/UpdateState | AngelscriptCoverageInputTests.cpp | 🟡 | 仅断言 Add+Count；缺 `ModifyRaw` / `UpdateState` 行为或反射断言 |
| G22 | 🟢 低 | Swizzle / FOVScaling Modifier 反射上限 | AngelscriptCoverageInputTests.cpp | ⬜/需实测 | `UInputModifierSwizzleAxis` 已在 `Bindings/AngelscriptEnhancedInputBindingsTests.cpp` 暴露但 Coverage 缺；`UInputModifierFOVScaling` grep 零引用 |
| G23 | 🟢 低 | ChordedAction Trigger（区别于 Combo） | AngelscriptCoverageInputTests.cpp | ⬜/需实测 | `UInputTriggerChordAction` grep 零引用；以 compile-failure 边界或反射断言锁定其暴露状态 |
| G24 | 🟢 低 | EnhancedInputUserSettings / PlayerMappableKeyProfile 边界实证 | AngelscriptCoverageInputTests.cpp | ⬜/需实测 | grep 零引用；UE5 PlayerMappable Key Settings 在 AS 暴露状态未知 |
| G25 | 🟢 中 | 传统 InputComponent 优先级 + Consume/Pause 行为 | AngelscriptCoverageInputTests.cpp | ⬜ | `bConsumeInput`/`bExecuteWhenPaused` 默认参数已暴露但运行期消费/穿透与 `InputComponent.Priority` / Block / Override / DontBlock 行为未断言 |
| G26 | 🟢 中 | PlayerController 设备 API 边界实证 | AngelscriptCoverageInputTests.cpp | ⬜ | `GetMousePosition` / `GetInputMotionState` / `GetInputAnalogKeyState` / `GetInputKeyTimeDown` 在 fork 中 grep 零绑定；需独立 compile-failure 边界 |
| G27 | 🟢 低 | 多 Player（双手柄 / 分屏 PlayerController）输入路由 | AngelscriptCoverageInputTests.cpp | ⬜ | 所有方法仅构造单 PlayerController；CreatePlayer / GetPlayerControllerFromID / 第二手柄 InputComponent 隔离反射或行为未断言 |
| G28 | 🟢 低 | 光标类型 / 点击 / 悬停事件边界 | AngelscriptCoverageInputTests.cpp | ⬜ | grep 零绑定；`InputModeControl` 仅覆盖 `SetShowMouseCursor` 一项；`SetMouseCursor` / `bEnableClickEvents` / `bEnableMouseOverEvents` 缺独立 compile-failure 边界 |
| G29 | 🟢 低 | Force Feedback / Haptic API 边界 | AngelscriptCoverageInputTests.cpp | ⬜ | APlayerController 反馈 API 在 fork 中 grep 零绑定；需 compile-failure 边界 |

> 当前剩余 21 项 ⬜/🟡 候选项，均为**可选增强**、非阻塞：前轮仅剩 G7 = 1 项（G1/G2/G5/G6 已于 2026-07-01 补测关闭）；2026-06-30 第二轮深审（05-uclass / 06-ustruct / 07-macros / 09-control-flow / 12-input 五个未深审域）新增 22 项 G8–G29，其中 G8/G10 已于 2026-07-01 补测关闭（剩余按域分布：05-uclass 1、06-ustruct 8、07-macros 0、09-control-flow 1、12-input 10）。当前 Coverage 覆盖整体成熟（89 文件 / **1010** 方法 — 2026-07-01 AnimInstance +1、SaveGame +1、TArrayAdvanced +1、TMapAdvanced +1、UClass +1、ClassLifecycle +1，并回填主索引漏计 Comment +1），无"极高优先级"硬缺口。新增测试须遵循 `AGENTS.md` 测试分层与 `_angelscript-test-guide` 约定。

### 2026-06-30 断言层深审记录（mixed 标准）

> 起因：此前矩阵的 ✅ 多由"存在同名 `TEST_METHOD`"推断，未核到断言层，用户质疑"是否全标完成"。本次按**mixed 标准**逐文件读断言：能力类须有运行期行为断言才记 ✅；纯声明/反射/语法类允许反射/编译级 ✅。

- **已逐文件核实为"真行为断言"（✅ 站得住）**：`Material`（spawn→BeginPlay→断言 MID 创建/参数回读/native override 值）、`AssetLoading`（执行 AS 函数断言加载/异步回调次数）、`LiteralAsset`（断言 asset 材质化值）、`Const`、`OperatorOverload`（执行函数断言返回值）、`Preprocessor`（断言模块序/代码包含/诊断/汇总计数）。
- **`Comment` 维持 ✅**：`CommentFormsCompile` 仅 `AssertCompiles`，但注释为纯语法特性、运行期无行为可断言，编译级即其天花板（mixed 标准下不算缺口）。
- **新发现的真缺口**：容器域 G5/G6 均已补测关闭；G1/G2 在矩阵中本已为 🟡/⬜，现均已补测关闭。
- **结论**：在 mixed 标准下，"伪 ✅"规模很小，主要为 `AnimInstance`（G1，已补运行期断言）。后续若扩大范围逐个核实其余 ~80 文件，仍可能发现零散 compile-only 项，届时按本标准降级并补 ⬜。

### 2026-06-30 能力面缺失行审查（按 UE/AS 能力面找"该测却没测"的行）

> 方法：逐域对照该类型/系统的 UE/AS 能力面与现有矩阵行，凡候选缺口先 grep 对应测试文件确认"真没测"再补，避免凭空捏造。

| 域 | 审查方式 | 结论 |
|----|---------|------|
| 01 基础类型（int/float/bool/FString） | 能力面对照 + grep `StartsWith/EndsWith/Left/Right/Chop` | **饱和**（151 方法，常见方法全覆盖），无真缺口 |
| 02 数学结构（6 struct + Math + 几何） | 能力面对照（三轴 + Math 命名空间 + 几何结构） | **饱和**（142 方法），不支持项已 🚫 固化 |
| 03 容器 | 能力面对照 + grep struct 元素/越界/struct 作值 | 新增 **G5/G6** 两条真缺口 |
| 08 委托/事件 | 执行标记密度对照（Delegate 60:11、Event 70:14） | **真覆盖**为主，无新缺口 |
| 10 组件 | 能力面对照（4 文件 55 方法，生命周期/Tick/附加/销毁/特化组件） | **饱和**，无真缺口 |
| 11 定时器 | 能力面对照（句柄/延迟/周期/参数/回调/用例） | **饱和**，Latent/Lambda 已 🚫 |
| 13 物理/碰撞 | grep `AddRadialForce/GetMass/SetCenterOfMass/阻尼` | 候选项**均已覆盖** → 饱和；Chaos 布料/破坏为未来子系统 |
| 14 Widget/UMG | 能力面对照 → 发现 **G7**（动画/焦点仅反射表面） | 可运行期测的部分已测；动画/焦点为软候选 |
| 15 网络/RPC | 能力面对照 | 反射/静态表面为 **headless 合法天花板**（真实多机往返非 headless 范畴），**非缺口** |

**总体结论**：本套件（89 文件 / 1010 方法）经多域 grounded 抽查，整体**极其成熟**；真正可补的硬缺口稀疏（G1/G2/G5/G6/G8/G10 已于 2026-07-01 补测关闭；G7 为软候选）。

### 2026-06-30 能力面缺失行审查 · 第二轮：05/06/07/09/12 五个未深审域（subagent 并行）

> 起因：上轮抽查未覆盖五个大文件域；用户要求把这 5 域用 subagent 并行深审到能力面行级，把发现的缺失/降级正式登记到矩阵与 `coverage-gaps.md`。
> 方法：每域一个 subagent，按 mixed 标准核 `TEST_METHOD` 断言层 + 用 grep 对 UE/AS 该域能力面对照"该测却没测"的行；候选缺口先 grep 验证"真没测"再补；只允许修改对应 `matrices/0X-*.md`，缺口编号与 task 由主代理统一汇总。

| 域 | 测试方法数 | 抽查/全审 | 新增 G 编号 | 主要发现 |
|----|----------|---------|-----------|---------|
| 05-uclass | 79 → **83**（DefaultComponent 由 4 修正为 6，G8 +1，G10 +1） | 5 文件 ~16 个 `Surface/Reflection/Lifecycle` 方法核到断言层 | **G8 / G9 / G10**（3 项；G8/G10 已关闭） | 已实现但矩阵漏列：`ClassFeatures::InterfaceImplementation`（脚本类实现 native UINTERFACE 运行期分发 + 脚本级 interface 拒绝边界），已直接补 ✅ 行；G8 已补 CDO/实例独立性；G10 已固化 native-only 虚方法拒绝边界；G9 是 Actor 侧 Tick/EndPlay/Destroyed 仅声明未真断言（Component 同侧已真驱动） |
| 06-ustruct | 47（16k 行） | 16 个能力类方法逐个 Read 断言层 | **G11–G18**（8 项） | 47 方法全部为真行为/反射断言，无大面积伪 ✅；G11=FInstancedStruct（fork 已绑定但 Coverage 域 0 覆盖）；G12/G13=值语义/运算符颗粒度补强；G14–G18=PropertyBag/HasNativeMake/Serialize/NetSerialize/static 成员 5 项**边界实证候选**（每项 1 行 compile-failure 即可固化为 🚫） |
| 07-macros-enum-function-interface | 101 | 5 文件 grep + 抽查 | **0 项** | 域整体饱和；扁平表格重写为 5 章节（UEnum/UFunction/UInterface/Macros/MetaSpecifier）的场景级矩阵，无新缺口 |
| 09-control-flow-language | 63 | 11 文件全 grep + 抽查 | **G19**（1 项） | 仅发现 `ForEach` 缺迭代中容器修改的运行期语义断言；其余 11 文件控制流/命名空间/预处理/类型转换/mixin/const/运算符饱和 |
| 12-input | 21 全审 | 21 方法逐方法核断言层 + 全 Enhanced Input 能力面对照 | **G20–G29**（10 项） | 21 方法**未达反射上限饱和**：G20/G21=ETriggerEvent 全集反射保留 + Modifier/Trigger ModifyRaw 缺；G22/G23/G24=Swizzle/FOVScaling/ChordedAction/UserSettings 反射边界缺；G25=传统 InputComponent 优先级行为缺；G26–G29=PlayerController 设备 API/多 Player/光标/反馈 5 簇 grep 零绑定但缺 compile-failure 边界 |

**总体结论（两轮合并）**：本套件（89 文件 / **1010** 方法）经全 18 域 grounded 抽查，整体**极其成熟**；**G1–G29 中剩余 21 条 ⬜/🟡 候选项均为可选增强、非阻塞**。真正的硬缺口为零。两轮深审合计降级 6 项（G1/G3 等历史 + G9/G12/G13/G20/G21）、新增 ⬜/🟡 21 项、关闭历史伪缺口 4 项（G3/G4 + 2 项 fork-绑定确认），2026-07-01 追加关闭 G1/G2/G5/G6/G8/G10。`07-macros` 域为 zero-finding 域（域饱和的样本之一）；`12-input` 域为 highest-finding 域（10 条），主要因为反射上限本可达但未做的 Enhanced Input 能力面 + grep 零绑定但缺 compile-failure 边界。

### 已审计关闭的历史候选（原 G3/G4）

- **G3（弱引用/指针容器元素）已覆盖**：`WeakReferenceTests::WeakObjectPtrArrayContainer` 与 `HandlesTests::WeakObjectPtrArrayContainerAndReassignment` 已断言 `TArray<TWeakObjectPtr<T>>` 元素往返/重新赋值。如需可继续加深失效断言，但不再列为缺口。
- **G4（TObjectPtr 显式属性往返）已覆盖**：`HandleTests::TObjectPtrRouting` 与 `HandlesTests::UObjectNewObjectTObjectPtrAndSubclassReferences` 已覆盖 `TObjectPtr<T>` 路由与作为引用属性的声明/读写。不再列为缺口。

## 2. fork 不支持 / 不适用边界（仅记录，不计划补测）

### 2.1 容器 API 未绑定

| 容器 | 未绑定 API | 现状 |
|------|-----------|------|
| TArray | `RemoveAll(Pred)` / `Find` / `FindLast` / `StableSort` / `Reverse` / `FilterByPredicate` / `FindByKey` / `FindByPredicate` / `Heapify`/`HeapPop`/`HeapPush` / `LowerBound`/`UpperBound` | 🚫 当前绑定未暴露；用 `FindIndex`/`Contains`/`Sort` 替代 |
| TMap | 指针式 `Find(Key)` / `GenerateKeyArray` / `GenerateValueArray` / `FindRef` / `FindChecked` / `Reserve`/`Shrink` / `Append` / `FilterByPredicate` / `for (auto& Pair)` 语法 | 🚫 用 `Find(Key,Out)` / `GetKeys` / `GetValues` / 显式迭代器替代 |
| TSet | `Find(Value)` / `Array()` / `Union` / `Intersect` / `Difference` / `Includes` / `FilterByPredicate` | 🚫 用 `Contains` / `Append`(并集) / 手动 for-each 替代 |

### 2.2 容器嵌套

| 组合 | 现状 |
|------|------|
| `TArray<TArray<T>>` / `TArray<TMap<>>` / `TMap<K,TArray<>>` / `TArray<TSet<>>` / `TMap<K,TMap<>>` | 🚫 编译器诊断 `Containers cannot be nested in other containers`（已作边界测试） |
| struct 内含数组再作为数组元素 | ✅ 允许（已覆盖，列此对照） |

### 2.3 接口引用

| 能力 | 现状 |
|------|------|
| 脚本级 `interface` / `TScriptInterface<I>` 声明、赋值、多态调用、作容器元素 | 🚫 当前 fork 不支持脚本级 interface；`UInterfaceTests` 覆盖的是 C++ UINTERFACE 实现路径 |

### 2.4 其他边界

| 能力 | 现状 |
|------|------|
| 委托 `BindStatic`（绑定全局/静态函数） | 🚫 AS 无静态函数概念，用 `BindUFunction`/`BindLambda` |
| 多播委托返回值 | 🚫 语义上不支持（多监听器返回值无意义） |
| 输入模式切换 `SetInputMode` 完整路径 | 🚫 headless 下作为 `InputModeSwitchingUnsupportedBoundary` 边界记录 |
| `GetWidgetFromName` 运行时取控件 | 🚫 作为 `GetWidgetFromNameUnsupportedBoundary` 边界记录 |

---

## 3. 已被历史文档误标为"未覆盖"的项（已实现，纠偏对照）

> `Documents/Coverage/` 多处把下列**已实现**主题标为 ⬜/计划，本表纠偏，删除旧文档时无需迁移其"待办"。

| 历史文档声称 | 实际状态 | 实际测试位置 |
|------------|---------|------------|
| 物理/碰撞/Trace/约束 = 0% 计划 | ✅ 已覆盖 | PhysicsTests.cpp（25 方法，含 Trace/Constraint/CharacterMovement） |
| 增强输入(UE5)/触摸 = ⬜ 计划 | ✅ 已覆盖 | InputTests.cpp（IMC/修饰器/触发器/触摸边界） |
| UI/UMG 控件/动画/绑定 = ⬜ 计划 | ✅ 已覆盖 | WidgetTests.cpp（控件/布局/动画/焦点/事件） |
| 委托/事件/动态委托 = ⬜ | ✅ 已覆盖 | Delegate/Multicast/Dynamic/Event Tests |
| 句柄/弱引用/软引用/GC = 部分 ⬜ | ✅ 已覆盖 | Handle/Handles/Weak/Soft/GC Tests |
| MasterIndex 整体完成度 ≈ 12% | ❌ 严重低估 | 实际 89 文件 / 980 方法，绝大多数主题成熟 |

---

## 4. 文档退役 / 迁移（cutover · 已完成）

`Documents/Coverage/` 已退役，由本 OpenSpec 记录接管。cutover 执行情况：

- ✅ **38 个** Coverage 测试 `.cpp` 的头注释里 `Documents/Coverage/Coverage_*.md` 引用，已统一改指 `OpenSpec: test-coverage-matrix-consolidation/coverage-matrix.md`。
- ✅ `.agents/skills/_angelscript-test-guide/SKILL.md` 与 `SKILL_ZH.md` 已同步改指本记录。
- ✅ 改指完成后删除 `Documents/Coverage/` 整目录（80 个文件）；`git grep "Documents/Coverage"` 无残留。

> 严格遵循"先改指、后删除"，无悬空引用窗口。改动仅限注释字符串。
