# AngelScript 参考案例测试扩展（第二轮）

> **范围**：基于 `Reference/myas/` 中 *It Takes Two Script*（5,356 .as）与 *Split Fiction Script*（15,741 .as）的二次深挖，针对第一轮 `Plan_ReferenceBasedTestExpansion.md`（28 个主题）**未覆盖**或**仅浅层覆盖**的高价值模式。

---

## 阅读前提

### 两个参考项目的 C++ 框架特征（对我们项目的影响）

| 维度 | Hazelight 项目（ITT / SF） | 我们的项目 | 处理策略 |
|------|---------------------------|-----------|---------|
| **基础 Actor** | `AHazeActor`（自有抽象） | `AActor`（原生） | 测试时把 `AHazeActor` → `AActor` |
| **能力系统** | `UHazeCapability` + 4 阶段 Tick 分组（`Setup/ShouldActivate/OnActivated/TickActive`），通过 `UHazeCapabilityComponent` 调度 | 无 Capability 框架 | **不直接借鉴 Capability 类**，但其底层依赖的 AS 语言特性（`BlueprintOverride` 多重 + `default Tags.Add()` + `OnLogState` 等）值得测试 |
| **网络层** | `EHazeCapabilityNetworkMode::Crumb`、`HasControl()`、`CrumbSyncedFloatComponent`、`PredictedGlobalCrumbTrailTime` | 标准 UE Replication | 提取**通用网络模式**（按 instigator 限权、双端同步语义）—— 用 `bReplicates`/`COND_OwnerOnly` 表达 |
| **UI 框架** | `UHazeEditorSubsystem` + 自有 ImGui-like Canvas API（`BeginCanvasPanel().Button()...`） | 标准 UMG / Slate | **跳过** Hazelight UI 链式 API；保留 UMG 测试 |
| **音频** | `UFoghornBarkDataAsset` + `PlayFoghornBark()` | 标准 USoundBase | 跳过 Foghorn；测 `UAudioComponent`/`USoundCue` |
| **动画** | `FeatureAnimInstance*` 命名、`UAnimNotifyState` 大量子类 | 原生 `UAnimInstance` | 保留 `UAnimNotify(State)` 脚本继承测试，剥离 Feature 命名 |
| **GAS** | `UHazeAbilityXxx` 包装层 | 我们已有 GAS 集成 | 测**原生 GameplayAbility/Effect/Cue 在 AS 中的定义**，不引入 Haze 包装 |

### 对照状态

| 项目 | 状态 |
|------|-----|
| `Plan_ReferenceBasedTestExpansion.md`（第一轮） | 已覆盖 28 主题 / 49 用例 |
| `Plan_HazelightCapabilityGap.md` | 评估 Capability 系统差距 |
| `Plan_HazelightScriptFeatureParity.md` | 评估 default/asset/DefaultComponent 等语法 parity |
| 本文档（第二轮） | **15 个新主题 / 约 35 个测试**，专注第一轮未触达的**深度语义**与**通用可借鉴模式** |

---

## 1. `access` 命名访问控制（深度场景）

第一轮第 26 节只覆盖了 `access private` 基础形式，**Hazelight 真实代码中大量使用命名 access + 修饰符组合**，是当前测试缺口。

### 真实场景（Split Fiction `Example_AccessSpecifiers.as`）

```angelscript
class UAccessSpecifierExample
{
    access Internal = private;
    access:Internal float PrivateFloatValue = 0.0;

    access InternalWithCapability = private, UAccessSpecifierCapability, AHazePlayerCharacter;
    access:InternalWithCapability float AccessibleFloatValue = 1.0;

    // 修饰符 readonly / editdefaults
    access SpecifierCapabilityCanOnlyRead = private, UAccessSpecifierCapability (readonly);
    access:SpecifierCapabilityCanOnlyRead float CapabilityReadOnlyValue = 0.0;

    // inherited 包含派生类
    access ReadableInAnyCapability = private, UHazeCapability (inherited, readonly);

    // * 通配 + 修饰符
    access EditAndReadOnly = private, * (editdefaults, readonly);
}
```

### 测试用例

#### 1.1 命名 access 声明 + 多类授权
- **Test**：`Angelscript.TestModule.Syntax.AccessSpecifier.NamedAccessMultipleClasses`
- **断言**：
  - 编译成功；列在 access 列表里的类可读写；其他类访问 → 编译错误
  - 同一 access 名可被多个成员复用（声明只一次）

#### 1.2 access 修饰符组合
- **Test**：`Angelscript.TestModule.Syntax.AccessSpecifier.Modifiers_ReadOnly_EditDefaults`
- **断言**：
  - `(readonly)` → 授权类只能读，不能写（写入产生编译错误）
  - `(editdefaults)` → 仅在 `default` 块或 `ConstructionScript` 内可写
  - `(readonly, editdefaults)` 组合可叠加

#### 1.3 access `inherited` 语义
- **Test**：`Angelscript.TestModule.Syntax.AccessSpecifier.InheritedFlag`
- **断言**：
  - 不带 `inherited`：仅指定类本身能访问，子类不能
  - 带 `inherited`：子类也能访问，证明继承链传递

#### 1.4 access `*` 通配
- **Test**：`Angelscript.TestModule.Syntax.AccessSpecifier.WildcardWithModifier`
- **断言**：`access X = private, * (editdefaults, readonly)` 允许任意类只读 + 仅 default 块可写

#### 1.5 access 全局函数授权
- **Test**：`Angelscript.TestModule.Syntax.AccessSpecifier.GlobalFunctionGrant`
- **断言**：把全局函数名（非类名）列入 access 列表后，该全局函数能调用 private 方法

> **如果当前预处理器/编译器不支持上述任一形式**：测试应作为**负例**记录"未实现：编译失败"，并落 `#ue57-unimplemented` 标签，配合 `Plan_HazelightScriptFeatureParity.md` 推动实装。

---

## 2. `asset` 字面量资产声明（运行时使用进阶）

第一轮未覆盖，`Plan_HazelightScriptFeatureParity.md` 仅覆盖**预处理与生成**，缺少**真实使用模式**测试。

### 真实场景（Split Fiction `Example_ComposableSettings.as`）

```angelscript
asset ExampleDefaultSettings of UExampleComposableSettings
{
    SomeFloatValue = 10.0;
    SomeNameValue = n"AName";
}

class AExampleDefaultSettingsActor : AHazeActor
{
    UPROPERTY()
    UExampleComposableSettings DefaultSettings = ExampleDefaultSettings;
}
```

### 测试用例

#### 2.1 asset 作为 UPROPERTY 默认值
- **Test**：`Angelscript.TestModule.Functional.Asset.UsedAsPropertyDefault`
- **断言**：`UPROPERTY() UFoo Foo = MyAsset;` → CDO 上 Foo 字段指向 `__Asset_MyAsset` 同一实例；多个 actor spawn 后字段共享

#### 2.2 asset 嵌套字段初始化
- **Test**：`Angelscript.TestModule.Functional.Asset.NestedFieldInitialization`
- **脚本**：
  ```angelscript
  asset MyAsset of UMyData
  {
      InnerStruct.A = 1;
      InnerStruct.B = "hello";
      Tags.Add(n"AssetTag");
  }
  ```
- **断言**：嵌套结构体字段、`Tags.Add` 调用都被生成的 `__Init_*` 正确执行

#### 2.3 asset 跨 import 引用
- **Test**：`Angelscript.TestModule.Functional.Asset.CrossModuleReference`
- **断言**：模块 A 声明 `asset X of UMyData`；模块 B `import A;` 后能直接 `auto Y = X;` 拿到同一个 UObject

#### 2.4 asset 作为函数返回值/参数
- **Test**：`Angelscript.TestModule.Functional.Asset.PassAsParameter`
- **断言**：`void DoSth(UMyData Data)` 可以接受 `MyAsset` 字面量；多个调用使用同一实例（指针相等）

---

## 3. `property` 关键字（getter/setter 完整语义）

第一轮第 5 节仅有"property 关键字编译验证"。但 Hazelight 真实代码中 property 用于自定义 component 包装：

### 真实场景（Split Fiction `Example_SyncedValues.as`）

```angelscript
class UExample_CrumbSyncedCameraValues : UHazeCrumbSyncedStructComponent
{
    private FExample_SyncedCameraValue CachedValue;
    const FExample_SyncedCameraValue& GetValue() property
    {
        GetCrumbValueStruct(CachedValue);
        return CachedValue;
    }

    void SetValue(FExample_SyncedCameraValue NewValue) property
    {
        SetCrumbValueStruct(NewValue);
    }
}
```

### 测试用例

#### 3.1 property 返回 const 引用
- **Test**：`Angelscript.TestModule.Syntax.PropertyAccessor.ConstReferenceReturn`
- **断言**：`const T& GetX() property` 可以正确通过 `obj.X` 访问，且不复制（取地址相同）

#### 3.2 setter 仅写
- **Test**：`Angelscript.TestModule.Syntax.PropertyAccessor.SetterOnly`
- **断言**：仅声明 `void SetX(T Val) property` 时，`obj.X = v;` 调用 setter；`auto v = obj.X;` 编译失败

#### 3.3 getter/setter 混合可见性
- **Test**：`Angelscript.TestModule.Syntax.PropertyAccessor.AsymmetricVisibility`
- **断言**：`private void SetX() property` + `public T GetX() property` → 外部能读不能写

#### 3.4 property 在 UPROPERTY 反射中的可见性
- **Test**：`Angelscript.TestModule.Syntax.PropertyAccessor.NotExposedAsUProperty`
- **断言**：`property` 不创建 UProperty 字段，`UClass::FindPropertyByName("X")` 返回 nullptr；同时 BP 节点也不会出现该 getter（除非额外打 UFUNCTION）

---

## 4. `TInstigated<T>` 优先级容器（高价值通用模式）

第一轮未覆盖，但是 Hazelight 用得**极其广泛**——任何"多源覆盖某值"场景都用它（碰撞配置、显示控制、可见性等）。可作为可选 FunctionLibrary 验证。

### 真实场景

```angelscript
TInstigated<FName> CollisionProfile;
CollisionProfile.SetDefaultValue(n"PlayerCharacter");
CollisionProfile.Apply(n"PriorityNormal", Game::Mio);
CollisionProfile.Apply(n"PriorityLow", Game::Zoe, EInstigatePriority::Low);
CollisionProfile.Clear(Instigator = Game::Mio);
```

### 测试用例（如已有等价实现，验证；否则作为缺失功能登记）

#### 4.1 优先级取最高值
- **Test**：`Angelscript.TestModule.Functional.Container.TInstigated.PriorityResolution`
- **断言**：多 instigator 同时 Apply，Get() 返回最高优先级；优先级相同按插入顺序；Clear 后回退到次高

#### 4.2 默认值回退
- **Test**：`Angelscript.TestModule.Functional.Container.TInstigated.DefaultFallback`
- **断言**：所有 instigator Clear 后，Get() 返回 `SetDefaultValue` 设的值

#### 4.3 struct/UObject/FName 三种 instigator
- **Test**：`Angelscript.TestModule.Functional.Container.TInstigated.InstigatorTypes`
- **断言**：UObject、FName 都能作为 instigator 唯一识别

> **若我们项目无 `TInstigated` 类型**：本组测试可作为 `Plan_OpportunityIndex.md` 候选，先以**"等价 PriorityValueStack 模式 helper"** 形式落地。

---

## 5. `FHazeStructQueue` / `UHazeActionQueueComponent` —— 结构化任务队列（通用 BT 替代）

第一轮第 14 节只覆盖了 BehaviorTree 节点声明；Hazelight 的 ActionQueue/StructQueue 是**比 BT 更轻量**的脚本侧调度模式，值得借鉴。

### 真实场景（Split Fiction `Example_ActionQueue.as`）

```angelscript
ActionQueue.Idle(2.0);
ActionQueue.Capability(UJumpAttackCapability);
ActionQueue.Event(this, n"OnPhaseChange");
ActionQueue.Duration(2.0, this, n"UpdateProgress");
ActionQueue.IdleUntil(this, n"ShouldProceed");
ActionQueue.Parallel(SubQueues);
ActionQueue.SetLooping(true);
ActionQueue.ScrubTo(Time::PredictedGlobalCrumbTrailTime);
```

### 测试用例（聚焦**通用排队抽象**，不涉及 Haze 网络）

#### 5.1 顺序 Event/Duration 调度
- **Test**：`Angelscript.TestModule.Functional.Queue.OrderedEventAndDuration`
- **脚本骨架**：纯 AS 实现一个简易 `FActionQueue`（Idle/Event/Duration），Tick 推进；或验证我们项目已有的 `FHazeActionQueue` 等价物
- **断言**：Event 调度顺序 = 加入顺序；Duration 的 Alpha 从 0→1 在 N 帧内线性变化

#### 5.2 IdleUntil 条件等待
- **Test**：`Angelscript.TestModule.Functional.Queue.IdleUntilDelegate`
- **断言**：调度暂停在 IdleUntil；委托返回 true 后立即推进

#### 5.3 Parallel 子队列
- **Test**：`Angelscript.TestModule.Functional.Queue.ParallelSubQueues`
- **断言**：两个并行子队列同时 tick；主队列等到所有子队列完成才推进

> 如果我们项目无 ActionQueue：本组验证可作为新增 helper 库（`Plugins/.../FunctionLibraries/AngelscriptActionQueueLib.cpp`）的 PoC 用例。

---

## 6. `FHazeTimeLike` / `Timeline` 网络同步（深度场景）

第一轮第 9 节覆盖 Timer，但 ITT `Example_Timeline.as` 中 `FHazeTimeLike` 有 **bSyncOverNetwork + SyncTag** 模式值得测：

### 测试用例

#### 6.1 Timeline 翻转/循环联合
- **Test**：`Angelscript.TestModule.Functional.Timeline.LoopAndFlipFlop`
- **断言**：`bLoop=true, bFlipFlop=true` → 0→1→0→1 循环；`OnTimelineUpdated` 每帧调用，`OnTimelineFinished` 在每次到达端点时触发

#### 6.2 Reverse / PlayFromStart / IsReversed 状态
- **Test**：`Angelscript.TestModule.Functional.Timeline.PlaybackStateMachine`
- **断言**：`Play()`、`Reverse()`、`PlayFromStart()`、`ReverseFromEnd()` 正确切换；`IsPlaying()`/`IsReversed()` 状态对齐

#### 6.3 Timeline + Curve 资产
- **Test**：`Angelscript.TestModule.Functional.Timeline.CurveAssetEvaluation`
- **断言**：`UCurveFloat` 作为 Curve，Timeline.GetValue() 返回 curve 求值结果

> 网络同步 `bSyncOverNetwork`：依赖 Hazelight 私有同步层，**仅做编译/默认值断言**，不做实际同步行为测试。

---

## 7. `EffectEventHandler`（事件解耦模式）

第一轮第 10 节覆盖 delegate/event；但 Hazelight 的 `UHazeEffectEventHandler` 是**类型化事件桥**——actor 触发，handler 类响应，是 BP 之外的解耦事件总线方案。

### 真实场景

```angelscript
class UExampleEffectEventHandler : UHazeEffectEventHandler
{
    UFUNCTION(BlueprintEvent)
    void StartWorking() { ... }
    UFUNCTION(BlueprintEvent)
    void EventWithParams(FExampleEventHandlerParams P) { ... }
}

// Actor:
default EffectEventHandlers.Add(UExampleEffectEventHandler);
UExampleEffectEventHandler::Trigger_StartWorking(this);
UExampleEffectEventHandler::Trigger_EventWithParams(this, Params);
```

### 测试用例（如我们有等价桥；否则记录差距）

#### 7.1 Handler 自动注册
- **Test**：`Angelscript.TestModule.Functional.EventBridge.HandlerAutoRegister`
- **断言**：`default EffectEventHandlers.Add(...)` 能让 Trigger 调用到 handler；多 handler 都被调用

#### 7.2 参数 struct 传递
- **Test**：`Angelscript.TestModule.Functional.EventBridge.ParametrizedTrigger`
- **断言**：`Trigger_X(actor, struct)` 调用时 handler 收到完整 struct 内容

#### 7.3 同名事件不同 handler 类不串扰
- **Test**：`Angelscript.TestModule.Functional.EventBridge.IsolatedHandlerClasses`
- **断言**：A、B handler 都有 `BlueprintEvent void DoX()`；只触发 A 不会调用 B

> **若我们没有 EffectEventHandler 系统**：测试转化为"**等价模式**：基于 `UInterface` 多重派发"实现的验证。

---

## 8. `TListedActors<T>`（按类型快速查询全局 actor）

第一轮第 11 节覆盖 SpawnActor；但 Hazelight 的 `TListedActors<T>` 是替代 `GetAllActorsOfClass` 的高效方案，用 `UHazeListedActorComponent` 自动登记。

### 真实场景

```angelscript
class AExampleListedActor : AActor
{
    UPROPERTY(DefaultComponent)
    UHazeListedActorComponent ListedComponent;
}

// 查询：
TListedActors<AExampleListedActor> All;
for (auto Actor : All) { ... }

AExampleListedActor Single = TListedActors<AExampleListedActor>().GetSingle();
```

### 测试用例

#### 8.1 Spawn 后自动列入
- **Test**：`Angelscript.TestModule.Functional.ListedActor.SpawnRegistersAutomatically`
- **断言**：spawn 3 个带 ListedComponent 的 actor → `TListedActors<>().Num() == 3`

#### 8.2 Destroy 自动移除
- **Test**：`Angelscript.TestModule.Functional.ListedActor.DestroyRemovesEntry`
- **断言**：destroy 后 Num 减少；遍历不出现已 destroy 的 actor

#### 8.3 GetSingle 多实例诊断
- **Test**：`Angelscript.TestModule.Functional.ListedActor.GetSingleErrorOnMultiple`
- **断言**：超过 1 个实例时 GetSingle 返回 nullptr 或抛诊断（视实装）

> 我们项目可能没有等价类。可借此机会评估是否在 `Plugins/.../FunctionLibraries/` 提供 `UAngelscriptListedActorLib`。

---

## 9. `Soft Pointer` 异步加载完整链

第一轮第 11 节有 Spawn，未涵盖 `TSoftClassPtr.LoadAsync(callback)` 异步链。

### 真实场景

```angelscript
UPROPERTY(EditAnywhere) TSoftClassPtr<UActorComponent> ComponentClass;

// BeginPlay:
ComponentClass.LoadAsync(FOnSoftClassLoaded(this, n"OnComponentClassLoaded"));

UFUNCTION()
void OnComponentClassLoaded(UClass LoadedClass) { ... }
```

### 测试用例

#### 9.1 LoadAsync 回调触发
- **Test**：`Angelscript.TestModule.Functional.SoftPointer.LoadAsyncCallback`
- **断言**：`LoadAsync` 后 N 帧内回调一次；回调收到的 UClass 与目标类相等

#### 9.2 同 SoftPtr 重复 LoadAsync 不重复回调
- **Test**：`Angelscript.TestModule.Functional.SoftPointer.LoadAsyncIdempotency`
- **断言**：连续两次 LoadAsync，回调总次数为 2（每次都触发），但底层加载只执行一次

#### 9.3 跨 sublevel TSoftObjectPtr 在 BeginPlay 时可能为 null
- **Test**：`Angelscript.TestModule.Functional.SoftPointer.NullDuringBeginPlay`
- **断言**：明确文档化 `OtherActor.Get()` 在 sublevel 未加载时返回 null；用 OnLevelLoaded 后再次 Get 拿到非空

---

## 10. `UScriptComponentVisualizer`（编辑器可视化）

第一轮第 25 节覆盖 CallInEditor 按钮；缺少**编辑器视口可视化**模式。

### 真实场景（Split Fiction `Example_SelectableVisualizer.as`）

```angelscript
class UExampleVisualizerSelectable : UHazeScriptComponentVisualizer
{
    default VisualizedClass = UExampleSelectableVisualizerComponent;

    UFUNCTION(BlueprintOverride)
    void VisualizeComponent(const UActorComponent InComponent)
    {
        SetRenderForeground(true);
        SetHitProxy(n"EditableOffset", EVisualizerCursor::GrabHand);
        DrawPoint(...);
    }

    UFUNCTION(BlueprintOverride)
    bool VisProxyHandleClick(...) { ... }

    UFUNCTION(BlueprintOverride)
    bool GetWidgetLocation(FVector& OutLocation) const { ... }

    UFUNCTION(BlueprintOverride)
    bool HandleInputDelta(FVector& DeltaTranslate, FRotator& DeltaRotate, FVector& DeltaScale) { ... }
}
```

### 测试用例（**仅编辑器**，标 `EAutomationTestFlags::EditorContext`）

#### 10.1 Visualizer 类自动绑定到 component
- **Test**：`Angelscript.Editor.Visualizer.AutoBindByDefault`
- **断言**：通过 `default VisualizedClass = ...` 在 ComponentVisualizerManager 中能查到对应 visualizer

#### 10.2 HitProxy 命名+点击事件
- **Test**：`Angelscript.Editor.Visualizer.HitProxyClickRoutes`
- **断言**：调 `SetHitProxy(n"X")` 后注入模拟点击事件，`VisProxyHandleClick` 收到 HitProxy="X"

#### 10.3 GetWidgetLocation 控制 gizmo 位置
- **Test**：`Angelscript.Editor.Visualizer.GizmoLocationOverride`
- **断言**：`GetWidgetLocation` 返回 true + 自定义 location → 编辑器 gizmo 位置即为该 location

> 现状：第一轮未覆盖；我们 `Plugins/Angelscript/Source/AngelscriptEditor/` 是否已有 ComponentVisualizer 桥？需先 grep 确认。

---

## 11. `UScriptActorMenuExtension` / `UScriptAssetMenuExtension` / `UScriptEditorMenuExtension`

第一轮 #25 仅 CallInEditor 按钮；缺少**菜单扩展**完整测试。

### 真实场景

```angelscript
class UExampleActorMenuExtension : UScriptActorMenuExtension
{
    default SupportedClasses.Add(AActor);

    UFUNCTION(CallInEditor) void Foo() { ... }
    UFUNCTION(CallInEditor, Category = "Sub") void Bar() { ... }
    UFUNCTION(CallInEditor, Meta = (EditorIcon = "Icons.Link")) void WithIcon() { ... }
    UFUNCTION(CallInEditor) void PerActor(AActor SelectedActor) { ... }
    UFUNCTION(CallInEditor) void PromptUser(AActor A, bool bX = true, FVector V = FVector::ZeroVector) { ... }
}
```

### 测试用例

#### 11.1 SupportedClasses 过滤
- **Test**：`Angelscript.Editor.MenuExtension.SupportedClassesFilter`
- **断言**：选中 `default SupportedClasses = AActor` → 菜单显示；选中非 AActor 子类 → 菜单不显示

#### 11.2 Category 生成子菜单
- **Test**：`Angelscript.Editor.MenuExtension.CategoryGroupedAsSubmenu`
- **断言**：相同 Category 的 CallInEditor 函数被分组到同名子菜单

#### 11.3 单参 actor 函数对每个选中 actor 调用一次
- **Test**：`Angelscript.Editor.MenuExtension.PerActorInvocationCount`
- **断言**：选中 N 个 actor、点击菜单后函数被调 N 次，每次参数不同

#### 11.4 多参函数弹出参数对话框
- **Test**：`Angelscript.Editor.MenuExtension.MultiParamShowsPrompt`
- **断言**：含 bool/Vector 参数时编辑器显示输入对话框；接受默认值后函数被调用

---

## 12. `UScriptEditorSubsystem` 编辑器订阅 + 输入劫持

第一轮未覆盖；ITT/SF 用 `UHazeEditorSubsystem` 拦截视口键盘/点击。

### 真实场景

```angelscript
class UExampleEditorSubsystemInput : UHazeEditorSubsystem
{
    UFUNCTION(BlueprintOverride) void OnEditorLevelsChanged() { ... }
    UFUNCTION(BlueprintOverride) bool OnLevelEditorKeyInput(FKey, EInputEvent) { ... }
    UFUNCTION(BlueprintOverride) bool OnLevelEditorClick(FKey, EInputEvent, UObject) { ... }
    UFUNCTION(BlueprintOverride) void Tick(float DeltaTime) { ... }
}
```

### 测试用例

#### 12.1 OnEditorLevelsChanged 回调
- **Test**：`Angelscript.Editor.Subsystem.LevelChangeHook`
- **断言**：编辑器 load/unload 子关卡时回调触发

#### 12.2 KeyInput 拦截
- **Test**：`Angelscript.Editor.Subsystem.KeyInputInterception`
- **断言**：返回 true 后 UE 不再传递该按键；返回 false 时传递

#### 12.3 Click 路由到 ClickedObject
- **Test**：`Angelscript.Editor.Subsystem.ClickRoutesObject`
- **断言**：模拟视口点击 primitive component → `ClickedObject` 即该 component

> 依赖编辑器子系统脚本基类是否已暴露；否则记入 `Plan_HazelightScriptFeatureParity.md`。

---

## 13. `UCustomContextMenuAction`（资产/路径上下文菜单）

第一轮无；ITT/SF 用于扩展 Content Browser 右键菜单。

### 测试用例

#### 13.1 ShouldAddMenuEntryForAssets 过滤
- **Test**：`Angelscript.Editor.AssetContextMenu.AssetClassFilter`
- **断言**：仅当选中含 `CurveFloat` 资产时菜单出现

#### 13.2 PerformActionForAssets 接收完整 FAssetData
- **Test**：`Angelscript.Editor.AssetContextMenu.AssetDataPayload`
- **断言**：函数接收 SelectedAssets 数组，每条含 `ObjectPath`/`AssetClass`/`AssetName`/`PackageName`/`PackagePath`

#### 13.3 ShouldAddMenuEntryForPaths 双调用兜底
- **Test**：`Angelscript.Editor.AssetContextMenu.PathFallback`
- **断言**：当用户右键文件夹（无具体资产）时走 `ShouldAddMenuEntryForPaths`；返回 true 后再触发 `PerformActionForPaths`

---

## 14. `Script::` 内省/反射 API

第一轮无；Hazelight 大量使用 `Script::GetNamespaceOfGlobalVariableBeingInitialized()` 等做"声明位置感知"。

### 真实场景（SF `TogglesDevBool.as`）

```angelscript
FHazeDevToggleBool()
{
    InitFromGlobalVariable("");  // 内部用：
    // FString Namespace = Script::GetNamespaceOfGlobalVariableBeingInitialized();
    // FString Variable = Script::GetNameOfGlobalVariableBeingInitialized();
}
```

### 测试用例

#### 14.1 全局变量构造时反射自身名
- **Test**：`Angelscript.TestModule.Functional.Reflection.GlobalVarSelfName`
- **断言**：在结构体构造函数内调 `Script::GetNameOfGlobalVariableBeingInitialized()` 返回当前正在初始化的变量名

#### 14.2 命名空间路径反射
- **Test**：`Angelscript.TestModule.Functional.Reflection.GlobalVarNamespacePath`
- **断言**：嵌套 namespace 中声明的全局变量构造时返回完整 `Outer::Inner` 路径

#### 14.3 非全局变量上调用返回空/错误
- **Test**：`Angelscript.TestModule.Functional.Reflection.NotInGlobalContextEmpty`
- **断言**：在普通函数/类方法中调用返回空字符串（不抛异常）

> 若我们项目无该绑定，是高价值新增点（DevToggle/Setting/Asset 命名约定都依赖它）。

---

## 15. f-string 完整规范测试

第一轮第 6 节有"基础格式化"，但 Split Fiction `Example_FormatString.as` 揭示了**完整 Python-like 规范**，多数仍未测：

### 缺失的格式说明符测试

| 形式 | 含义 | 当前测试 |
|------|------|---------|
| `{x =}` | 打印 `x = value` | ❌ 无 |
| `{x =:.0}` | 等号 + 格式说明符组合 | ❌ 无 |
| `{x :010d}` | 整数前导零至 10 位 | ❌ 无 |
| `{x :#x}` / `{x :#b}` | 带前缀十六/二进制 | ❌ 无 |
| `{x :#032b}` | 二进制 32 位前导零 | ❌ 无 |
| `{name :>40}` | 右对齐到 40 列 | ❌ 无 |
| `{name :_<40}` | 自定义填充字符（_）+ 左对齐 | ❌ 无 |
| `{enum :n}` | 枚举仅打印 name | ❌ 无 |
| `{vec :.3}` | 复合类型字段统一精度 | ❌ 无 |

### 测试用例

#### 15.1 等号自描述
- **Test**：`Angelscript.TestModule.Syntax.FString.EqualSignSelfDescribe`
- **断言**：`f"{x =}"` → `"x = 42"`；`f"{obj.Field =}"` → `"obj.Field = ..."`

#### 15.2 整数格式
- **Test**：`Angelscript.TestModule.Syntax.FString.IntegerFormatSpecifiers`
- **断言**：`d`/`x`/`b`/`o`、`#` 前缀、`0`-padding、宽度全验证

#### 15.3 对齐与填充
- **Test**：`Angelscript.TestModule.Syntax.FString.AlignmentAndPadding`
- **断言**：`<`/`>`/`^` + 自定义填充字符 + 宽度

#### 15.4 枚举 `:n` 仅 name
- **Test**：`Angelscript.TestModule.Syntax.FString.EnumNameOnlySpecifier`
- **断言**：默认 `f"{e}"` 出 `"EFoo::Bar (1)"`；`f"{e :n}"` 出 `"Bar"`

#### 15.5 等号 + 格式组合
- **Test**：`Angelscript.TestModule.Syntax.FString.EqualPlusSpecifier`
- **断言**：`f"{x =:.2}"` → `"x = 3.14"`

---

## 输出与执行约定

### 文件路径建议

| 主题 | 建议文件 |
|------|---------|
| 1（access） | `Plugins/.../AngelscriptTest/Syntax/AngelscriptSyntaxAccessSpecifierAdvancedTests.cpp`（扩展现有 cpp） |
| 2（asset） | `Plugins/.../AngelscriptTest/Functional/Asset/AngelscriptAssetUsageTests.cpp` (新建) |
| 3（property） | 扩展 `AngelscriptSyntaxPropertyAccessorTests.cpp` |
| 4（TInstigated） | `Functional/Container/AngelscriptInstigatedContainerTests.cpp` (新建，需先确认 binding) |
| 5（ActionQueue） | `Functional/Queue/AngelscriptActionQueueTests.cpp` (新建) |
| 6（Timeline 进阶） | 扩展 `Functional/Misc/`（如已有 Timeline 测试）或新建 |
| 7（EffectEvent） | `Functional/EventBridge/AngelscriptEffectEventHandlerTests.cpp` (新建) |
| 8（ListedActor） | `Functional/Actor/AngelscriptListedActorTests.cpp` (新建) |
| 9（SoftPtr 异步） | 扩展 `Bindings/AngelscriptSoftReferenceFunctionLibraryTests.cpp` |
| 10–13（编辑器） | `Editor/` 目录新建对应 `.cpp`，标 `EditorContext` flag |
| 14（Script:: 反射） | `Functional/Reflection/AngelscriptScriptReflectionTests.cpp` (新建) |
| 15（f-string 进阶） | 扩展 `AngelscriptSyntaxFStringTests.cpp` |

### Automation 命名

- Syntax 类：`Angelscript.TestModule.Syntax.<Theme>.<Case>`
- Functional 类：`Angelscript.TestModule.Functional.<Theme>.<Case>`
- Editor 类：`Angelscript.Editor.<Theme>.<Case>`

### 优先级矩阵

| P | 主题 | 用例 | 理由 |
|---|------|-----|------|
| **P0** | 1 access 进阶 | 5 | Hazelight 真实代码强依赖；当前完全缺失命名 + 修饰符形式 |
| **P0** | 3 property 完整 | 4 | 已部分支持但语义边界（const&/setter-only/可见性）未验证 |
| **P0** | 15 f-string 完整规范 | 5 | Format string 是 AS 卖点，规范完整性影响开发者信任 |
| **P1** | 2 asset 真实使用 | 4 | 与 Plan_HazelightScriptFeatureParity 的 asset delta 直接对齐 |
| **P1** | 9 Soft Pointer 异步 | 3 | 跨 sublevel 加载是 UE 关键实践，回调链未测 |
| **P1** | 14 Script:: 反射 | 3 | 解锁 DevToggle/Setting 命名约定模式 |
| **P2** | 6 Timeline 进阶 | 3 | 已有基础测试，补完播放状态机 |
| **P2** | 11 ActorMenuExtension | 4 | 编辑器扩展能力链路 |
| **P2** | 13 ContentBrowser 上下文菜单 | 3 | 资产工作流扩展 |
| **P3** | 4 TInstigated | 3 | 需先评估是否在我们项目实装等价类型 |
| **P3** | 5 ActionQueue | 3 | 同上，可作为 helper lib PoC |
| **P3** | 7 EffectEventHandler | 3 | 同上 |
| **P3** | 8 ListedActor | 3 | 同上 |
| **P3** | 10 Visualizer | 3 | 编辑器可视化基类是否已绑定需先确认 |
| **P3** | 12 EditorSubsystem 输入 | 3 | 同上 |

**总计**：15 主题 / **52 个测试用例**（其中 P0 14 个 / P1 10 个 / P2 10 个 / P3 18 个）。

### 与已有 Plan 的关系

- 与 `Plan_ReferenceBasedTestExpansion.md`（28 主题）**互补无重复**
- 与 `Plan_HazelightScriptFeatureParity.md` 协作：本 Plan 偏**测试侧**；Parity 偏**实装/语义校验**
- 与 `Plan_HazelightCapabilityGap.md` 解耦：本 Plan **不直接测试 Capability 类**，仅测试其底层依赖的 AS 语言/反射特性

### 排除项（明确不引入）

| 排除项 | 原因 |
|--------|-----|
| `UHazeCapability` 直接子类测试 | 我们项目无 Capability 框架；属于 `Plan_HazelightCapabilityGap` 范围 |
| `EHazeCapabilityNetworkMode::Crumb` / `HasControl` | 需要 Hazelight 网络层；用标准 UE replication 替代 |
| `UHazeCrumbSyncedXxxComponent` | 同上 |
| `UFoghornBarkDataAsset` / VO 系统 | Hazelight 私有音频包装 |
| `Game::Mio` / `Game::Zoe` 全局玩家引用 | 项目特定 |
| `UHazeEditorSubsystem` 中的 Canvas 链式 UI API | 是 Hazelight 自有 ImGui-like 包装；标准 Slate / UMG 已覆盖 |
| `FeatureAnimInstance*` 命名规范 | 项目特定，保留 `UAnimNotify(State)` 通用模式即可 |

---

## 验证方式

每个新测试遵循项目模式：

1. CQTest 风格（参考 `Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE_ZH.md`）
2. 使用 `ASTEST_CREATE_ENGINE()` + 共享引擎复用
3. 编译路径：`SyntaxTestHelpers::AssertCompiles` / `AssertCompileError`
4. 运行路径：`Functional/<Theme>` 目录下用 `FAngelscriptEngineScope` 隔离 + spawn UWorld
5. 运行命令：
   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
     -TestPrefix "Angelscript.TestModule.Functional.Asset." `
     -Label asset-usage-round2
   ```

---

# 附录 B：测试变体扩展矩阵（举一反三）

> **目的**：对前述 15 主题的 52 个"主干"用例，按 **6 大变体轴**横向铺开，把同一主题的"正路径单点验证"扩展为"覆盖语义/边界/错误/交互/演化/规模"的完整网格。
>
> **6 大变体轴**：
> 1. **正例（Positive）** —— 主干能力正确执行
> 2. **负例（Negative）** —— 编译期/运行期诊断完整性
> 3. **边界（Boundary）** —— 空/0/最大/嵌套/递归/极端值
> 4. **交互（Interaction）** —— 与其他特性组合（继承/HotReload/网络/GC/序列化/BP）
> 5. **诊断（Diagnostics）** —— 错误消息可读性、行列号、修复建议
> 6. **规模/性能（Scale）** —— 大量实例、深度嵌套、热路径、回归 baseline
>
> **不要求** 每个主题在每个轴上都有用例；下表标注 `★` 为必补，`☆` 为可选。

## 变体覆盖矩阵总览

| # | 主题 | 主干 | 正例追加 | 负例 | 边界 | 交互 | 诊断 | 规模 | 主题用例小计 |
|---|------|-----|---------|------|------|------|------|------|------------|
| 1 | access 命名访问控制 | 5 | ★3 | ★4 | ★3 | ★3 | ★2 | ☆1 | **21** |
| 2 | asset 字面量进阶 | 4 | ★2 | ★3 | ★3 | ★4 | ★2 | ★1 | **19** |
| 3 | property 完整语义 | 4 | ★3 | ★3 | ★3 | ★3 | ☆1 | ☆1 | **18** |
| 4 | TInstigated | 3 | ★2 | ★2 | ★3 | ★2 | ☆1 | ★1 | **14** |
| 5 | ActionQueue / StructQueue | 3 | ★3 | ★2 | ★3 | ★3 | ☆1 | ★1 | **16** |
| 6 | Timeline 进阶 | 3 | ★2 | ★1 | ★3 | ★3 | — | ☆1 | **13** |
| 7 | EffectEventHandler | 3 | ★2 | ★2 | ★2 | ★3 | ☆1 | — | **13** |
| 8 | ListedActor | 3 | ★2 | ★1 | ★2 | ★3 | — | ★1 | **12** |
| 9 | Soft Pointer 异步 | 3 | ★2 | ★2 | ★2 | ★3 | ☆1 | ★1 | **14** |
| 10 | Visualizer | 3 | ★2 | ★1 | ★1 | ★2 | ☆1 | — | **10** |
| 11 | ActorMenuExtension | 4 | ★2 | ★2 | ★2 | ★3 | ☆1 | — | **14** |
| 12 | EditorSubsystem 输入 | 3 | ★1 | ★1 | ★2 | ★2 | — | — | **9** |
| 13 | ContentBrowser 上下文菜单 | 3 | ★2 | ★1 | ★2 | ★2 | — | — | **10** |
| 14 | Script:: 反射 | 3 | ★2 | ★2 | ★3 | ★2 | ☆1 | ★1 | **14** |
| 15 | f-string 完整规范 | 5 | ★4 | ★3 | ★4 | ★3 | ★2 | ☆1 | **22** |
| **总计** | — | **52** | **34** | **30** | **38** | **41** | **15** | **9** | **219** |

> **52 → 219**（×4.2 倍覆盖密度）。下面按主题展开变体清单。

---

## B.1 主题 1：access 命名访问控制（21 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 1.6  | `AccessSpec.NamedAlias_ReusedAcrossMembers` | 同一 access 名声明 1 次后被 5+ 字段/方法复用，全部按授权列表生效 |
| 1.7  | `AccessSpec.ProtectedBaseline_PlusFriendList` | `access X = protected, Friend1, Friend2` —— 子类 + Friend 都可访问 |
| 1.8  | `AccessSpec.PerMemberDifferentAccessNames` | 同一类 5 个字段各自挂不同 access 名，互不干扰 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 1.N1 | `AccessSpec.UndeclaredNameUsage_FailsClosed` | `access:Undeclared` 引用未声明的名字 → 明确编译错误 |
| 1.N2 | `AccessSpec.WriteThroughReadOnly_Compiles_NoSilentBreak` | 授权类对 `(readonly)` 字段写入 → 编译错误（不能静默通过） |
| 1.N3 | `AccessSpec.NonDefaultBlockEditOnEditDefaults` | `(editdefaults)` 字段在普通方法体内赋值 → 编译错误 |
| 1.N4 | `AccessSpec.UnauthorizedClassReadFails` | 非授权类读 private/access 字段 → 编译错误 + 错误位置可定位 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 1.B1 | `AccessSpec.EmptyAccessList_PrivateOnly` | `access X = private;` 后 `access:X` 等价 private 无 friend |
| 1.B2 | `AccessSpec.VeryLongFriendList_30Classes` | 授权列表含 30+ 个类，全部生效，无截断 |
| 1.B3 | `AccessSpec.ModifierStackingAllFlags` | `(readonly, editdefaults, inherited)` 三标志同时叠加，语义按位组合 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 1.I1 | `AccessSpec.WithBlueprintInheritance` | BP 继承 AS 类后，`(inherited)` 是否将 BP 视为子类（推断：BP 派生应被承认） |
| 1.I2 | `AccessSpec.WithHotReload_FieldRemainsAccessible` | HotReload 改变 access 列表（增/减 friend），重编译后访问状态正确 |
| 1.I3 | `AccessSpec.WithMixin_AccessHonored` | `mixin` 函数是否绕过 access？必须不能；mixin 注入的访问遵循同样规则 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 1.D1 | `AccessSpec.ErrorMessage_PointsToCallerLine` | 非法访问错误消息含调用行号 + 字段路径 + 当前类 + 授权类列表 |
| 1.D2 | `AccessSpec.SuggestionWhenTypoOfAccessName` | `access:Intrenal`（拼错）→ 错误消息建议 `Internal` |

### 规模（可选）
| ID | Test | 内容 |
|----|------|------|
| 1.S1 ☆ | `AccessSpec.ManyMembersManyAccessNames` | 100 字段 × 10 access 名，编译时间在 baseline 1.5x 内 |

---

## B.2 主题 2：asset 字面量（19 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 2.5 | `Asset.MultipleAssetsSameType_SeparateInstances` | 同模块 3 个 `asset X/Y/Z of UFoo` → 3 个独立 UObject，PtrEq 互不相同 |
| 2.6 | `Asset.AssetWithDefaultBlock_RuntimeReadback` | asset 体内 `Tags.Add(n"X")` + `default Field = 5` → spawn 后通过反射读到一致值 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 2.N1 | `Asset.MissingTypeName_FailsClosed` | `asset Foo of` 后无类型 → 预处理报错且行号正确 |
| 2.N2 | `Asset.AssetInsideFunctionBody_Rejected` | 在函数体内写 `asset X of UFoo {}` → 拒绝（仅顶层声明） |
| 2.N3 | `Asset.NameCollisionWithExistingGetter` | 短名 getter 已存在时再声明同名 asset → 显式诊断（参照 `LiteralAsset.PostInitResolvesGeneratedGetterInsteadOfNameCollision` 的反向） |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 2.B1 | `Asset.EmptyBody_StillValid` | `asset Foo of UBar {}` 空体合法，PostInit 仅构造不赋值 |
| 2.B2 | `Asset.NestedFieldDeepChain` | `asset X { A.B.C.D = 1; }` 4 层嵌套字段链全部初始化 |
| 2.B3 | `Asset.LargeAssetWith50Fields` | 50 个字段 + Tags + 嵌套 struct → PostInit 一次完成 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 2.I1 | `Asset.UsedInDefaultStatementOfAnotherClass` | A 类 default 字段引用 asset；B 类继承 A → B 的 CDO 仍指向同一 asset |
| 2.I2 | `Asset.HotReload_BodyChange_ReplacesUObject` | reload 修改 asset body 字段 → `OnLiteralAssetReload` 一次，新值生效，老引用通过 reinstance 链接到新对象 |
| 2.I3 | `Asset.AsParameterDefaultValue` | 全局函数参数 `void Do(UFoo F = MyAsset)` —— 调用时缺省值即 asset |
| 2.I4 | `Asset.AcrossModuleImport_PtrEquality` | M1 声明 asset，M2 import M1 后引用 → ptr 相等；reload M1 → M2 自动更新 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 2.D1 | `Asset.PostInitFailureLogsAssetName` | asset body 内调用了不存在方法 → 错误消息带 asset 名而非 `__Init_*` |
| 2.D2 | `Asset.CycleDetection_AssetReferencesItself` | asset A body 引用自身 → 检出/诊断（不应栈溢出） |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 2.S1 | `Asset.HundredAssetsInOneModule_BootTime` | 100 个 asset 在同模块声明，启动时初始化耗时不超过 baseline 2x |

---

## B.3 主题 3：property（getter/setter）（18 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 3.5 | `PropertyAccessor.GetterSetterPair_RoundTrip` | `T GetX() property` + `void SetX(T) property` —— `obj.X = v; auto u = obj.X;` 等价 round-trip |
| 3.6 | `PropertyAccessor.OperatorCompoundOnProperty` | `obj.X += 1` 触发 get → +1 → set；中间值正确 |
| 3.7 | `PropertyAccessor.PropertyOfStructType_Modify` | `FVector GetV() property` 返回值修改后 `obj.V.X = 1` 是否影响原值（语义须明确） |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 3.N1 | `PropertyAccessor.GetterTakingArgs_Rejected` | `T GetX(int) property` 多参 getter → 拒绝 |
| 3.N2 | `PropertyAccessor.SetterMultipleParams_Rejected` | `void SetX(T, T) property` → 拒绝 |
| 3.N3 | `PropertyAccessor.GetterReturnsVoid_Rejected` | `void GetX() property` → 编译错误 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 3.B1 | `PropertyAccessor.StaticPropertyOnNamespace` | `namespace N { T GetX() property {...} }` 是否可调 `N::X`？语义记录 |
| 3.B2 | `PropertyAccessor.PropertyOnInterface` | interface 内声明 property —— 实现类必须提供两侧 |
| 3.B3 | `PropertyAccessor.OverrideInDerivedClass` | 派生类 override property getter/setter —— 多态分发正确 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 3.I1 | `PropertyAccessor.NotExposedToBP_NoUFunction` | property 不挂 UFUNCTION 时 BP 不可见；挂 UFUNCTION 后变 BP-callable |
| 3.I2 | `PropertyAccessor.WithAccessSpecifier` | `private void SetX() property` + `public T GetX() property` —— 外部只读 |
| 3.I3 | `PropertyAccessor.HotReload_AddSetter` | reload 给原本只读 property 增加 setter → 旧实例后续可写 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 3.D1 ☆ | `PropertyAccessor.SetterOnlyReadAttempt` | 仅 setter 时读 → 错误消息建议添加 getter |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 3.S1 ☆ | `PropertyAccessor.HotPathProperty_NoOverhead` | tick 中频繁 `v += obj.X` —— JIT/解释执行下与裸字段访问差距 < 20% |

---

## B.4 主题 4：TInstigated（14 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.4 | `TInstigated.UpdateExistingInstigator_OverwritesValue` | 同 instigator 二次 Apply → 新值覆盖旧值，不增加内部条数 |
| 4.5 | `TInstigated.PriorityTieBreaker_FIFO` | 同优先级先后 Apply → Get 返回先 Apply 的值 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 4.N1 | `TInstigated.ClearNonexistentInstigator_NoEffect` | Clear 未 Apply 过的 instigator → 不抛异常，状态不变 |
| 4.N2 | `TInstigated.NullInstigator_Diagnosis` | Apply 时 instigator=nullptr → 明确诊断或回退到 FName instigator |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 4.B1 | `TInstigated.AllPriorityLevels` | Low/Normal/High 三档全 Apply → Get 返回 High |
| 4.B2 | `TInstigated.NoApply_OnlyDefault` | 从未 Apply → Get 永远返回 SetDefaultValue 的值 |
| 4.B3 | `TInstigated.LargeNumInstigators_500` | 500 个不同 instigator 同时 Apply → Get 仍 O(1) 或可接受复杂度 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 4.I1 | `TInstigated.InstigatorUObjectGCed_AutoCleared` | UObject instigator 被 GC → 对应 entry 自动消失，Get 回退 |
| 4.I2 | `TInstigated.WithReplication` | TInstigated 字段标 Replicated → server Apply → client 可见（如绑定支持） |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 4.D1 ☆ | `TInstigated.DebugDumpListsAllEntries` | 调用 `ToString()` 列出所有 instigator + value + priority |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 4.S1 | `TInstigated.HotApplyClear_PerfBaseline` | tick 中 Apply/Clear 100 次/帧 —— 不出现 GC / 分配热点 |

---

## B.5 主题 5：ActionQueue / StructQueue（16 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 5.4 | `ActionQueue.Capability_StructParameter_Sync` | Capability action 携带 struct 参数 —— 在 OnActivated 内拿到完整 struct |
| 5.5 | `ActionQueue.ReverseDuration_FlipFlopAlpha` | ReverseDuration alpha 从 1→0；与正向 Duration 拼接构造 FlipFlop |
| 5.6 | `ActionQueue.ScrubTo_NetworkAlignment` | 调 ScrubTo(t) → 当前 alpha 立即跳变；scrubbed 不触发已 fire 过的 Event |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 5.N1 | `ActionQueue.ScrubOnQueueWithCapability_Rejected` | 队列含 Capability action 时调 ScrubTo → 明确诊断（文档明示不支持） |
| 5.N2 | `ActionQueue.EmptyQueueIsActive_AlwaysFalse` | `IsEmpty() && IsActive()` 不可能同真 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 5.B1 | `ActionQueue.IdleZeroDuration_AdvancesNextTick` | `Idle(0)` → 下一帧自动跳过 |
| 5.B2 | `ActionQueue.LongChain_100Actions` | 队列 100 个 Idle/Event 混合 → 顺序执行无丢失 |
| 5.B3 | `ActionQueue.ParallelEmptySubQueue` | Parallel 含一个空子队列 → 主队立即推进 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 5.I1 | `ActionQueue.PauseDuringDuration_AlphaFreezes` | SetPaused(true) 期间 alpha 不变；resume 后继续 |
| 5.I2 | `ActionQueue.LoopingQueue_RestartsCleanly` | SetLooping(true)；一轮完成后 Event 再次触发 |
| 5.I3 | `ActionQueue.NestedParallelInsideParallel` | Parallel 子队列里再 Parallel —— 拓扑正确 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 5.D1 ☆ | `ActionQueue.TemporalLogIntegration` | `TemporalLog.Value("Q", queue)` 输出含每个待办项类型 + 进度 |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 5.S1 | `ActionQueue.TickOverhead_EmptyQueue` | 空队列 tick 应近 0 开销（不分配） |

---

## B.6 主题 6：Timeline 进阶（13 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 6.4 | `Timeline.PlayFromStartResetsAlpha` | 中途状态调 PlayFromStart → 内部时间归零，事件重新触发 |
| 6.5 | `Timeline.CustomCurve_FloatLookup` | UCurveFloat 注入；GetValue() = curve.Eval(time) |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 6.N1 | `Timeline.NegativeDuration_Rejected` | `default Timeline.Duration = -1.f` → 编译期/构造期诊断 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 6.B1 | `Timeline.ZeroDuration_FinishImmediately` | Duration=0 → Play 后下一帧 OnFinished 触发 |
| 6.B2 | `Timeline.LoopAndFlipFlopBoth_DefinedSemantic` | 两标志同真时优先级文档化（FlipFlop 优先 / Loop 优先） |
| 6.B3 | `Timeline.ReverseAtBoundary_NoDoubleEvent` | reverse 时刚好处于 0/1 端点 → OnFinished 不重复触发 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 6.I1 | `Timeline.WithTimerHandle_PauseUnpause` | World Pause → 时间 dilation = 0 时 Timeline 是否暂停？需明确 |
| 6.I2 | `Timeline.MultipleBindUpdates_AllCalled` | 多次 BindUpdate 后所有回调都触发 |
| 6.I3 | `Timeline.HotReload_TimelinePropertyPreserved` | reload 不影响进行中的 Timeline 进度 |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 6.S1 ☆ | `Timeline.ManyTimelinesPerActor` | 一个 actor 持 20 个独立 Timeline 同时 tick —— 性能可接受 |

---

## B.7 主题 7：EffectEventHandler（13 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 7.4 | `EffectEvent.MultipleHandlersInvokedInRegistrationOrder` | 同 actor 注册 3 handler → Trigger 按 add 顺序回调 |
| 7.5 | `EffectEvent.HandlerWithReturnValueIgnored` | BlueprintEvent return type 非 void —— 行为定义化 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 7.N1 | `EffectEvent.TriggerNotMatchingSignature_Rejected` | Trigger 提供错误参数 → 编译错误 |
| 7.N2 | `EffectEvent.HandlerNotInheriting_BaseRejected` | 非 `UHazeEffectEventHandler` 子类做 EffectEventHandlers.Add → 拒绝 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 7.B1 | `EffectEvent.EmptyHandlerList_TriggerNoOp` | 0 handler → Trigger 调用安全无副作用 |
| 7.B2 | `EffectEvent.ParamStructWithDefault_InitializedFromCDO` | 不传 params → struct 默认值生效 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 7.I1 | `EffectEvent.DynamicAddRemoveHandler` | runtime add/remove handler → 后续 Trigger 反映变化 |
| 7.I2 | `EffectEvent.HandlerOwnedByDifferentActor` | handler 实例 outer 不是 actor —— 是否合法？需文档化 |
| 7.I3 | `EffectEvent.WithReplication_HandlerLocalOnly` | NetMulticast Trigger 是否在 client 也激活 handler？语义验证 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 7.D1 ☆ | `EffectEvent.MissingTriggerFunction_HelpfulError` | 漏写 BlueprintEvent 直接调 Trigger_X → 错误消息提示要 BlueprintEvent |

---

## B.8 主题 8：ListedActor（12 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 8.4 | `ListedActor.RangeBasedFor_OrderStability` | 同一帧多次遍历 `TListedActors<>()` 顺序稳定 |
| 8.5 | `ListedActor.SubclassFiltering` | 派生类带 ListedComponent —— `TListedActors<Base>()` 含派生实例 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 8.N1 | `ListedActor.GetSingleWithMultiple_Diagnostics` | >1 实例时 GetSingle —— 返回 nullptr 或 ensure 一次（行为对齐文档） |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 8.B1 | `ListedActor.EmptyWorld_NumZero` | 无任何带 ListedComponent 的 actor —— `Num()==0` |
| 8.B2 | `ListedActor.ManyActors_1000Spawned` | 1000 个 spawn → Num==1000；Destroy 一半 → Num==500 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 8.I1 | `ListedActor.PIE_StartStopCleansList` | EndPIE 后下次 BeginPIE list 不残留旧 actor |
| 8.I2 | `ListedActor.LevelStreamingLoadUnload` | sublevel 加载/卸载时 list 自动同步 |
| 8.I3 | `ListedActor.WithAsyncSpawn_VisibleAfterFinishSpawning` | DeferredSpawn → FinishSpawning 后才出现在 list 中 |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 8.S1 | `ListedActor.ScanCost_LinearWithCount` | 遍历开销与 actor 数线性，无 O(n²) |

---

## B.9 主题 9：Soft Pointer 异步（14 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 9.4 | `SoftPointer.AsyncLoadCallback_OnNonGameThreadFinishedOnGameThread` | LoadAsync callback 必须在 GameThread 触发 |
| 9.5 | `SoftPointer.SoftClassPtr_LoadThenSpawn` | LoadAsync UClass → 回调中 SpawnActor 成功 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 9.N1 | `SoftPointer.LoadAsyncOnInvalidPath_CallbackWithNull` | path 不存在 → 回调入参为 nullptr，不崩溃 |
| 9.N2 | `SoftPointer.GetWithoutLoad_ReturnsNullSafely` | 未 Load 时 `.Get()` 返回 nullptr 而非崩溃 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 9.B1 | `SoftPointer.AlreadyLoadedAsset_LoadAsyncImmediateCallback` | 资源已在内存 → 下一帧立即回调（不卡 N 帧） |
| 9.B2 | `SoftPointer.NullSoftPtr_LoadAsyncDoesNothing` | 未指向任何资源的 SoftPtr → LoadAsync 无回调或回调 nullptr |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 9.I1 | `SoftPointer.ConcurrentLoadAsync_SamePathDeduped` | 100 个 actor 同时 LoadAsync 同 path → 底层只发 1 个加载请求，全部回调 |
| 9.I2 | `SoftPointer.ActorDestroyedBeforeCallback_NoCallback` | LoadAsync 后 actor 被 Destroy → 回调不触发（防止野指针） |
| 9.I3 | `SoftPointer.LevelStreaming_SubLevelActorPtrResolves` | sublevel load 后 `OtherActor.Get()` 返回非空 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 9.D1 ☆ | `SoftPointer.LoadAsyncTimeoutLogs` | 超时未完成 → log warning 含 path |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 9.S1 | `SoftPointer.HundredsOfPathsBatched` | 同帧 200 个不同 path LoadAsync —— 不超预算 N 帧完成 |

---

## B.10 主题 10：Visualizer（10 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 10.4 | `Visualizer.DrawLineSphereBox_AllShapesRendered` | DrawLine/DrawSphere/DrawBox 都生成 PDI 元素 |
| 10.5 | `Visualizer.MultipleHitProxiesIndependentClicks` | 注入两 hit proxy，分别点击 → VisProxyHandleClick 各收到自己的 name |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 10.N1 | `Visualizer.NoVisualizedClass_NoBinding` | 不写 `default VisualizedClass = X` → 不绑定到任何 component |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 10.B1 | `Visualizer.ComponentDestroyedDuringDraw_NoCrash` | tick 期间 component 被销毁 → 下一次 VisualizeComponent 安全跳过 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 10.I1 | `Visualizer.HotReloadVisualizerClass_RebindsToComponents` | reload visualizer 类 → 自动重新绑定 |
| 10.I2 | `Visualizer.HandleInputDelta_AppliesToActorTransform` | 模拟 gizmo drag → component 字段被修改且 dirty 标记 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 10.D1 ☆ | `Visualizer.MissingBlueprintOverrideMethod_RuntimeWarn` | 漏 BlueprintOverride 关键方法 → editor warn 而非 silent |

---

## B.11 主题 11：ActorMenuExtension（14 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 11.5 | `ActorMenu.IconRenderingFromMetaTag` | `Meta = (EditorIcon = "...")` → 菜单项实际显示对应图标 |
| 11.6 | `ActorMenu.DisplayNameOverride` | `DisplayName = "X"` → 菜单文本即 "X" |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 11.N1 | `ActorMenu.NoCallInEditorAttribute_NoMenuItem` | 无 CallInEditor 的方法不会出现 |
| 11.N2 | `ActorMenu.SelectedClassNotInSupportedClasses_NoMenu` | 选中无关 actor → 菜单不显示该扩展项 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 11.B1 | `ActorMenu.ZeroSelectedActor_FunctionNotInvoked` | 选中 0 个 actor 后调用 → 不触发 actor-param 函数 |
| 11.B2 | `ActorMenu.DeepCategoryNesting` | `Category="A | B | C | D"` → 菜单 4 层嵌套显示 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 11.I1 | `ActorMenu.UndoRedoSupport` | 在 PerformAction 内 `Modify()` 修改 actor → undo/redo 可逆 |
| 11.I2 | `ActorMenu.ParameterPromptBindings_AcceptsDefaults` | 多参对话框 → 接受默认 → 函数正确接收默认值 |
| 11.I3 | `ActorMenu.HotReloadAddNewExtension_AppearsImmediately` | reload 新增 UScriptActorMenuExtension 子类 → 无需重启 editor 即可见 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 11.D1 ☆ | `ActorMenu.InvalidParameterType_RejectedAtCompile` | 函数参数为不可序列化类型（如 lambda）→ 编译错误 |

---

## B.12 主题 12：EditorSubsystem 输入（9 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 12.4 | `EditorSubsystem.TickOnlyWhenActive` | bIsRelevant=false 时 Tick 内任何 UI 调用应被守卫 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 12.N1 | `EditorSubsystem.OnLevelEditorClick_NullObject_HandledGracefully` | ClickedObject==nullptr → 函数不崩溃 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 12.B1 | `EditorSubsystem.MultipleEditorSubsystems_KeyDispatchOrder` | 多个 EditorSubsystem 都返回 false → UE 收到原 key；任一返回 true → 后续不再传递 |
| 12.B2 | `EditorSubsystem.LevelChangeOnPIEStart_NotTriggered` | 仅 editor world 切换才触发 OnEditorLevelsChanged，PIE start 不触发 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 12.I1 | `EditorSubsystem.HotReloadSubsystemClass_StateRetained` | reload 后子系统单例保留还是重建？语义记录 |
| 12.I2 | `EditorSubsystem.WithLevelEditorViewportOverlay_DrawOnTop` | overlay canvas 元素位于视口最上层，不被 actor 遮挡 |

---

## B.13 主题 13：ContentBrowser 上下文菜单（10 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 13.4 | `ContentBrowserMenu.PartialSelectionFiltering` | 选中混合类型资产 —— ShouldAddMenuEntryForAssets 仅对匹配子集返回 true |
| 13.5 | `ContentBrowserMenu.SubFolderRecursionInPathSelection` | 选中文件夹 —— GetAssetsInPaths 含子目录资产 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 13.N1 | `ContentBrowserMenu.PerformActionWithEmptyAssets_NoOp` | 选中 0 资产场景下点击 → 函数被调但参数为空数组，安全退出 |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 13.B1 | `ContentBrowserMenu.HugeSelection_500Assets` | 选 500 资产 —— ShouldAdd 在合理时间返回（< 500ms） |
| 13.B2 | `ContentBrowserMenu.ZeroPathSelected_NoMenu` | 0 路径 → ShouldAddMenuEntryForPaths 不触发 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 13.I1 | `ContentBrowserMenu.OpenEditorForAsset_FocusesEditor` | PerformAction 中 `Editor::OpenEditorForAsset` → 编辑器获焦 |
| 13.I2 | `ContentBrowserMenu.ModifyMultipleAssetsBatch_OneTransaction` | 修改多资产 —— 单 undo 事务包裹 |

---

## B.14 主题 14：Script:: 反射（14 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 14.4 | `ScriptReflection.ConstructorOfStruct_FieldName` | struct 构造函数内 GetNameOfGlobalVariableBeingInitialized 准确 |
| 14.5 | `ScriptReflection.GetCallingScriptModuleName` | 跨模块函数调用，被调方能获取 caller 模块名 |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 14.N1 | `ScriptReflection.OutsideInitContext_ReturnsEmpty` | 普通方法体内调用 → 返回 ""，不抛 |
| 14.N2 | `ScriptReflection.NestedCallChain_ReturnsOuterMost` | 全局变量 init 中调函数 X，X 内部又问反射 → 行为定义化（最外层 vs 最近层） |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 14.B1 | `ScriptReflection.AnonymousNamespaceVariable` | 匿名 / 默认命名空间变量 → namespace 路径返回 "" |
| 14.B2 | `ScriptReflection.MultipleVarsInOneInitChain` | 同一行声明 `T A, B, C;` —— 各自构造时反射到自己的名字 |
| 14.B3 | `ScriptReflection.VariableInsideClass_NotGlobal` | 类成员字段不属于 global var；反射应返回空 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 14.I1 | `ScriptReflection.HotReloadDoesNotResetCachedNames` | reload 模块后 cached name → 用户层期望 |
| 14.I2 | `ScriptReflection.WithLiteralAssetGenerated__Init` | asset 生成的 `__Init_*` 内调反射 → 返回 asset 名 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 14.D1 ☆ | `ScriptReflection.WrongCallContextLogsHint` | 在不允许的上下文调用 → log 提示"only valid during global init" |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 14.S1 | `ScriptReflection.ManyGlobalsInit_OnePassPerformance` | 1000 个全局变量 init 都用反射 → 整体 boot time 不退化超 baseline 1.5x |

---

## B.15 主题 15：f-string 完整规范（22 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 15.6 | `FString.NestedExpressionInBraces` | `f"{a + b * c}"` 复合表达式求值 |
| 15.7 | `FString.MethodCallInsideBraces` | `f"{obj.GetName()}"` |
| 15.8 | `FString.MultiplePlaceholdersSameLine` | `f"{a}+{b}={c}"` 三个占位符 |
| 15.9 | `FString.EscapedBraces` | `f"{{literal}}"` → `"{literal}"` |

### 负例
| ID | Test | 内容 |
|----|------|------|
| 15.N1 | `FString.UnclosedBrace_CompileError` | `f"{x"` → 明确编译错误 + 行列号 |
| 15.N2 | `FString.InvalidFormatSpecifier_CompileError` | `f"{x :zz}"` 未知格式说明符 → 报错 |
| 15.N3 | `FString.WrongTypeForSpecifier` | `f"{vector :d}"`（向量按整数格式） → 错误或文档化的 fallback |

### 边界
| ID | Test | 内容 |
|----|------|------|
| 15.B1 | `FString.EmptyFString` | `f""` → `""` |
| 15.B2 | `FString.OnlyLiteralNoPlaceholder` | `f"hello"` → 等价于普通字符串 |
| 15.B3 | `FString.VeryLongString_4KB` | 4KB 长 f-string + 50 占位符 → 正确生成 |
| 15.B4 | `FString.UnicodeContent` | 占位符内含中文/emoji → 按 UTF-8 输出 |

### 交互
| ID | Test | 内容 |
|----|------|------|
| 15.I1 | `FString.InsidePrintLogF` | `Print(f"{x}")` 与 `Log(f"{x}")` 输出一致 |
| 15.I2 | `FString.UsedInUFunctionParameter` | f-string 作为 UFUNCTION FString 参数 → 调用前完成插值 |
| 15.I3 | `FString.OperatorPlusWithFString` | `f"a" + f"b"` 拼接结果 |

### 诊断
| ID | Test | 内容 |
|----|------|------|
| 15.D1 | `FString.SpecifierErrorPointsToColumn` | 错误说明符的列号定位精确（不是整行） |
| 15.D2 | `FString.UnknownVariableInBraces_NotSilent` | `f"{undeclared}"` → 编译错误而非空字符串 |

### 规模
| ID | Test | 内容 |
|----|------|------|
| 15.S1 ☆ | `FString.HotPathFormat_NoAllocPerCall` | tick 中频繁 f-string —— alloc 次数与裸字符串拼接持平 |

---

## 附录 C：执行交付优先级（按变体维度）

将 219 个用例的实施分为 **4 个交付波次**，每波 ≈ 1 sprint（2 周）：

| 波次 | 包含变体 | 主题主干优先级 | 用例数 |
|------|---------|--------------|------|
| **W1（基线 + 正例补全）** | 主干 + 正例追加 | P0 + P1 全部主题 | 52 + 34 = **86** |
| **W2（错误诊断闭环）** | 负例 + 诊断 | P0 + P1 + P2 主题 | 30 + 15 = **45** |
| **W3（边界 + 交互）** | 边界 + 交互 | 全部主题 | 38 + 41 = **79** |
| **W4（性能基线）** | 规模 | 高频访问/热路径主题 | **9** |

---

## 附录 D：变体设计参考清单（适用于其他主题扩展）

> 通用变体清单，下次新增任何主题时可作为 checklist 复用：

```
正例变体：
  □ 单一接口最简使用
  □ 多接口组合（A+B+C 链式调用）
  □ 跨实例/跨类型复用
  □ 默认值 vs 显式参数

负例变体：
  □ 必填参数缺失
  □ 类型不匹配
  □ 参数取值越界
  □ 重复声明 / 命名冲突
  □ 在错误上下文调用（如类内调用全局函数）

边界变体：
  □ 空值 / null / 0 / 默认构造
  □ 极大值 / 数量上限
  □ 嵌套深度 1 / 3 / 10 层
  □ 递归 / 自引用
  □ 并发同时操作

交互变体：
  □ 与 HotReload 的兼容
  □ 与 BP 继承的协作
  □ 与 GC 的安全
  □ 与序列化（save / replication）的兼容
  □ 与编辑器（Undo/PIE/Cooking）的协作
  □ 与其他特性（mixin/access/property/template）的组合

诊断变体：
  □ 错误消息含行列号
  □ 错误消息含上下文（哪个类/哪个字段）
  □ 错误消息含修复建议
  □ 错误不导致后续编译误报雪崩

规模变体：
  □ tick 热路径开销基线
  □ 启动 / 编译 boot time 基线
  □ 大量实例（500+ / 1000+）行为
  □ 大量声明（100+）的链路稳定性
```
