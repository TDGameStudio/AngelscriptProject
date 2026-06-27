# AngelScript UCLASS 全覆盖矩阵

> 本文覆盖 AngelScript 中 **UCLASS 宏和类声明**的所有用法场景。
> 对应 `Documents/AS_FullCoverageMatrix.md` §8（类）和 §12（UCLASS 说明符）。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| UCLASS 说明符 | `AngelscriptTest/Coverage/AngelscriptCoverageUClassTests.cpp` | ✅ 已完成 |
| 类继承和生命周期 | `AngelscriptTest/Coverage/AngelscriptCoverageClassLifecycleTests.cpp` | ✅ 已完成 |
| 类特性（abstract/接口/default） | `AngelscriptTest/Coverage/AngelscriptCoverageClassFeaturesTests.cpp` | ✅ 已完成 |

✅ UCLASS 核心特性已全面覆盖

- Automation 前缀：`Angelscript.TestModule.Coverage.UClass*`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：UCLASS 基础声明

### 1.1 基本语法

| 声明形式 | 写法示例 | 状态 | 备注 |
|---------|---------|------|------|
| 裸 UCLASS | `UCLASS() class AMyActor : AActor` | ✅ | 最小声明 |
| 无 UCLASS 标记 | `class MyClass { }` | ✅ | 纯脚本类（不暴露给 UE） |
| 继承 UE 基类 | `class AMyActor : AActor` | ✅ | |
| 继承脚本基类 | `class ADerived : AMyBase` | ✅ | |
| 多级继承链 | `Base -> Derived1 -> Derived2` | ✅ | |
| 实现接口 | `class AMyActor : AActor, IMyInterface` | ✅ | |
| 多接口实现 | `class X : AActor, IFoo, IBar` | ✅ | |

### 1.2 常见继承基类覆盖

| 基类 | 典型用途 | 状态 | 关键生命周期方法 |
|------|---------|------|-----------------|
| `AActor` | 场景中的对象 | ⬜ | BeginPlay / Tick / EndPlay / Destroyed |
| `APawn` | 可被控制的 Actor | ⬜ | SetupPlayerInputComponent |
| `ACharacter` | 带角色移动的 Pawn | ⬜ | OnMovementModeChanged |
| `APlayerController` | 玩家控制器 | ⬜ | BeginPlay / SetupInputComponent |
| `AGameModeBase` | 游戏模式 | ⬜ | InitGame / PostLogin |
| `AGameStateBase` | 游戏状态 | ⬜ | OnRep_* |
| `APlayerState` | 玩家状态 | ⬜ | CopyProperties |
| `AHUD` | HUD 显示 | ⬜ | DrawHUD |
| `UObject` | 纯数据/逻辑对象 | ⬜ | 无生命周期 |
| `UActorComponent` | Actor 组件 | ⬜ | BeginPlay / TickComponent |
| `USceneComponent` | 带变换的组件 | ⬜ | OnComponentCreated |
| `UStaticMeshComponent` | 静态网格组件 | ⬜ | |
| `UUserWidget` | UMG 控件 | ⬜ | Construct / Tick / Destruct |
| `UWorldSubsystem` | 世界子系统 | ⬜ | Initialize / Deinitialize |
| `UGameInstanceSubsystem` | 游戏实例子系统 | ⬜ | Initialize / Deinitialize |
| `ULocalPlayerSubsystem` | 本地玩家子系统 | ⬜ | Initialize / Deinitialize |

---

## 子矩阵 2：UCLASS 说明符（完整清单）

### 2.1 Blueprint 相关

| 说明符 | 作用 | 写法示例 | 状态 | 验证点 |
|-------|------|---------|------|--------|
| `Blueprintable` | 可被 BP 继承 | `UCLASS(Blueprintable)` | ✅ | 创建 BP 子类 |
| `NotBlueprintable` | 禁止 BP 继承 | `UCLASS(NotBlueprintable)` | ✅ | 编辑器中不可选 |
| `BlueprintType` | 可作为 BP 变量类型 | `UCLASS(BlueprintType)` | ✅ | BP 中声明此类型变量 |
| `NotBlueprintType` | 禁止作为 BP 变量 | `UCLASS(NotBlueprintType)` | ✅ | |

### 2.2 类行为控制

| 说明符 | 作用 | 写法示例 | 状态 | 验证点 |
|-------|------|---------|------|--------|
| `Abstract` | 抽象类，不可实例化 | `UCLASS(Abstract)` | ✅ | 无法 SpawnActor |
| `Transient` | 不保存到磁盘 | `UCLASS(Transient)` | ✅ | 不在关卡保存 |
| `NonTransient` | 强制保存（覆盖父类 Transient） | `UCLASS(NonTransient)` | ✅ | |
| `Deprecated` | 已弃用 | `UCLASS(Deprecated)` | ✅ | 编辑器警告 |
| `NotPlaceable` | 不可放置到关卡 | `UCLASS(NotPlaceable)` | ✅ | 编辑器中不可拖拽 |
| `Placeable` | 可放置（默认） | `UCLASS(Placeable)` | ✅ | |
| `DefaultToInstanced` | 属性默认实例化 | `UCLASS(DefaultToInstanced)` | ⬜ | |
| `EditInlineNew` | 可在属性面板内联创建 | `UCLASS(EditInlineNew)` | ⬜ | |
| `HideDropdown` | 隐藏类选择器 | `UCLASS(HideDropdown)` | ⬜ | |

### 2.3 配置和持久化

| 说明符 | 作用 | 写法示例 | 状态 | 验证点 |
|-------|------|---------|------|--------|
| `Config = Game` | 属性保存到配置文件 | `UCLASS(Config=Game)` | ⬜ | 读取 .ini 文件 |
| `Config = Editor` | 编辑器配置 | `UCLASS(Config=Editor)` | ⬜ | |
| `DefaultConfig` | 使用默认配置 | `UCLASS(DefaultConfig)` | ⬜ | |
| `GlobalUserConfig` | 全局用户配置 | `UCLASS(GlobalUserConfig)` | ⬜ | |
| `ProjectUserConfig` | 项目用户配置 | `UCLASS(ProjectUserConfig)` | ⬜ | |

### 2.4 显示和分组

| 说明符 | 作用 | 写法示例 | 状态 | 验证点 |
|-------|------|---------|------|--------|
| `ClassGroup = "MyGroup"` | 类分组 | `UCLASS(ClassGroup=(Custom))` | ⬜ | 编辑器分组显示 |
| `HideCategories = (...)` | 隐藏属性分类 | `UCLASS(HideCategories=(Rendering))` | ⬜ | 属性面板隐藏 |
| `ShowCategories = (...)` | 显示分类（覆盖父类隐藏） | `UCLASS(ShowCategories=(Rendering))` | ⬜ | |
| `CollapseCategories` | 折叠所有分类 | `UCLASS(CollapseCategories)` | ⬜ | |
| `DontCollapseCategories` | 不折叠（覆盖父类） | `UCLASS(DontCollapseCategories)` | ⬜ | |
| `AutoExpandCategories = (...)` | 自动展开分类 | `UCLASS(AutoExpandCategories=(MyCategory))` | ⬜ | |
| `AutoCollapseCategories = (...)` | 自动折叠分类 | `UCLASS(AutoCollapseCategories=(MyCategory))` | ⬜ | |

### 2.5 元数据（meta）

| meta 键 | 作用 | 写法示例 | 状态 | 验证点 |
|---------|------|---------|------|--------|
| `DisplayName` | 显示名称 | `UCLASS(meta=(DisplayName="My Actor"))` | ⬜ | 编辑器中显示 |
| `ShortTooltip` | 短提示 | `UCLASS(meta=(ShortTooltip="..."))` | ⬜ | |
| `ToolTip` | 完整提示 | `UCLASS(meta=(ToolTip="..."))` | ⬜ | |
| `IsBlueprintBase` | 是否为 BP 基类 | `UCLASS(meta=(IsBlueprintBase="true"))` | ⬜ | |
| `ChildCanTick` | 子类可以 Tick | `UCLASS(meta=(ChildCanTick))` | ⬜ | |
| `IgnoreCategoryKeywordsInSubclasses` | 忽略子类分类关键字 | `UCLASS(meta=(IgnoreCategoryKeywordsInSubclasses))` | ⬜ | |

### 2.6 特殊用途（Actor 相关）

| 说明符 | 作用 | 写法示例 | 状态 | 备注 |
|-------|------|---------|------|------|
| `ConversionRoot` | 转换根类 | `UCLASS(ConversionRoot)` | ⬜ | Actor 转换 |
| `ComponentWrapperClass` | 组件包装类 | `UCLASS(ComponentWrapperClass)` | ⬜ | |
| `HideFunctions = (...)` | 隐藏函数 | `UCLASS(HideFunctions=(Func1,Func2))` | ⬜ | |
| `SparseClassDataTypes = (...)` | 稀疏类数据 | `UCLASS(SparseClassDataTypes=(...))` | ⬜ | 优化内存 |

### 2.7 说明符组合验证

| 组合场景 | 写法 | 状态 | 目的 |
|---------|------|------|------|
| Blueprintable + Abstract | `UCLASS(Blueprintable, Abstract)` | ⬜ | BP 可继承但本身不可实例化 |
| Config + DefaultConfig | `UCLASS(Config=Game, DefaultConfig)` | ⬜ | 配置文件类 |
| NotBlueprintable + BlueprintType | `UCLASS(NotBlueprintable, BlueprintType)` | ⬜ | 可作变量但不可继承 |
| HideCategories + ShowCategories | 父类 Hide，子类 Show 某分类 | ⬜ | 分类覆盖 |

---

## 子矩阵 3：类生命周期方法

### 3.1 AActor 生命周期

| 方法 | 调用时机 | 状态 | 验证点 |
|------|---------|------|--------|
| `BeginPlay()` | Actor 开始游戏 | ✅ | PIE 启动时调用 |
| `Tick(float DeltaSeconds)` | 每帧调用 | ✅ | DeltaTime 验证 |
| `EndPlay(EEndPlayReason::Type)` | Actor 结束 | ✅ | 关闭 PIE 时调用 |
| `Destroyed()` | Actor 被销毁 | ✅ | DestroyActor 后调用 |
| `OnConstruction(FTransform&in Transform)` | 构造脚本 | ✅ | 编辑器移动 Actor 时 |
| `PostInitializeComponents()` | 组件初始化后 | ✅ | |
| `PreInitializeComponents()` | 组件初始化前 | ✅ | |

### 3.2 APawn 生命周期

| 方法 | 调用时机 | 状态 |
|------|---------|------|
| `SetupPlayerInputComponent(UInputComponent)` | 输入绑定 | ⬜ |
| `PossessedBy(AController)` | 被控制器占有 | ⬜ |
| `UnPossessed()` | 失去控制 | ⬜ |

### 3.3 UActorComponent 生命周期

| 方法 | 调用时机 | 状态 |
|------|---------|------|
| `OnComponentCreated()` | 组件创建 | ⬜ |
| `InitializeComponent()` | 组件初始化 | ⬜ |
| `BeginPlay()` | 开始游戏 | ⬜ |
| `TickComponent(float, ELevelTick, FActorComponentTickFunction*)` | 每帧 | ⬜ |
| `EndPlay(EEndPlayReason::Type)` | 结束 | ⬜ |
| `OnComponentDestroyed(bool)` | 销毁 | ⬜ |

### 3.4 UUserWidget 生命周期

| 方法 | 调用时机 | 状态 |
|------|---------|------|
| `Construct()` | 控件构造 | ⬜ |
| `Destruct()` | 控件销毁 | ⬜ |
| `Tick(FGeometry, float)` | 每帧 | ⬜ |
| `OnInitialized()` | 初始化 | ⬜ |

### 3.5 Subsystem 生命周期

| 方法 | 调用时机 | 状态 |
|------|---------|------|
| `Initialize(FSubsystemCollectionBase&)` | 子系统初始化 | ⬜ |
| `Deinitialize()` | 子系统清理 | ⬜ |
| `OnWorldBeginPlay()` | 世界开始（仅 WorldSubsystem） | ⬜ |

---

## 子矩阵 4：default 关键字

### 4.1 default 用法场景

| 用法 | 写法示例 | 状态 | 验证点 |
|------|---------|------|--------|
| 覆盖父类属性默认值 | `default Health = 200;` | ⬜ | CDO 中的值 |
| 调用父类方法 | `default SetReplicates(true);` | ⬜ | |
| 修改容器默认值 | `default Tags.Add(n"Tag");` | ⬜ | |
| 设置组件属性 | `default Mesh.SetCastShadow(false);` | ⬜ | |
| 多层继承链 | Base -> Derived1 -> Derived2 各层 default | ⬜ | |

### 4.2 default 与构造函数对比

| 场景 | default 关键字 | 构造函数 | 推荐 |
|------|---------------|----------|------|
| 静态默认值 | ✅ 支持 | ✅ 支持 | default |
| 复杂初始化逻辑 | 🚫 不支持 | ✅ 支持 | 构造函数 |
| 运行时条件初始化 | 🚫 不支持 | ✅ 支持 | 构造函数 |
| CDO 修改 | ✅ 支持 | 🚫 不执行 | default |

---

## 子矩阵 5：类特性

### 5.1 访问修饰符

| 修饰符 | 作用域 | 状态 | 验证点 |
|-------|--------|------|--------|
| `private` | 仅本类 | ⬜ | 外部访问应失败 |
| `protected` | 本类和子类 | ⬜ | 子类可访问，外部不可 |
| `public` | 所有 | ⬜ | |
| `private` 成员 + `AllowPrivateAccess` | BP 可访问私有成员 | ⬜ | meta 覆盖 |

### 5.2 抽象类和纯虚方法

| 特性 | 写法 | 状态 | 验证点 |
|------|------|------|--------|
| 抽象类 | `UCLASS(Abstract)` | ⬜ | 不可实例化 |
| 虚方法（可覆盖） | 子类重写父类方法 | ⬜ | 多态调用 |
| 纯虚方法 | （AS 无显式语法） | 🚫 | |
| 调用父类方法 | `Super::MethodName()` 或 `ParentClass::Method()` | ⬜ | |

### 5.3 接口实现

| 特性 | 写法 | 状态 | 验证点 |
|------|------|------|--------|
| 实现单个接口 | `class X : AActor, IMyInterface` | ⬜ | |
| 实现多个接口 | `class X : AActor, IFoo, IBar` | ⬜ | |
| 接口方法实现 | 实现接口声明的方法 | ⬜ | |
| 接口 Cast | `Cast<IMyInterface>(Obj)` | ⬜ | |
| TScriptInterface | `TScriptInterface<IMyInterface>` | ⬜ | |

---

## 子矩阵 6：组件（DefaultComponent）

### 6.1 组件声明

| 写法 | 说明 | 状态 | 验证点 |
|------|------|------|--------|
| `UPROPERTY(DefaultComponent)` | 声明默认组件 | ⬜ | 自动创建 |
| `UPROPERTY(DefaultComponent, RootComponent)` | 根组件 | ⬜ | Transform 基准 |
| `UPROPERTY(DefaultComponent, Attach=Root)` | 附加到其他组件 | ⬜ | 父子关系 |
| `UPROPERTY(DefaultComponent, AttachSocket="Name")` | 附加到 Socket | ⬜ | Socket 绑定 |
| `UPROPERTY(DefaultComponent, ShowOnActor)` | 在 Actor 上显示 | ⬜ | 编辑器可见性 |

### 6.2 组件类型覆盖

| 组件类型 | 状态 | 典型用途 |
|---------|------|---------|
| `USceneComponent` | ⬜ | 变换组件 |
| `UStaticMeshComponent` | ⬜ | 静态网格 |
| `USkeletalMeshComponent` | ⬜ | 骨骼网格 |
| `UCapsuleComponent` | ⬜ | 碰撞胶囊 |
| `UBoxComponent` | ⬜ | 盒体碰撞 |
| `USphereComponent` | ⬜ | 球体碰撞 |
| `USpringArmComponent` | ⬜ | 弹簧臂 |
| `UCameraComponent` | ⬜ | 相机 |
| `UPointLightComponent` | ⬜ | 点光源 |
| `UCharacterMovementComponent` | ⬜ | 角色移动 |
| `UArrowComponent` | ⬜ | 箭头指示器 |
| 自定义脚本组件 | ⬜ | 脚本派生的组件类 |

### 6.3 组件操作

| 操作 | 写法 | 状态 |
|------|------|------|
| 获取组件 | `GetComponentByClass(...)` | ⬜ |
| 附加组件 | `Component.AttachToComponent(...)` | ⬜ |
| 分离组件 | `Component.DetachFromComponent(...)` | ⬜ |
| 销毁组件 | `Component.DestroyComponent()` | ⬜ |
| 创建动态组件 | `NewObject<UMyComponent>(this)` | ⬜ |

---

## 子矩阵 7：类间关系

### 7.1 继承层次

| 场景 | 写法 | 状态 | 验证点 |
|------|------|------|--------|
| 单层继承 | `ADerived : ABase` | ⬜ | |
| 多层继承 | `A -> B -> C -> D` | ⬜ | 4 层以上 |
| 覆盖父类方法 | 子类重新实现父类方法 | ⬜ | |
| 调用父类方法 | `Super::Method()` | ⬜ | |
| 访问父类属性 | 子类访问 protected 成员 | ⬜ | |
| 类型转换向上 | `ABase Base = Derived;` | ⬜ | 隐式转换 |
| 类型转换向下 | `Cast<ADerived>(Base)` | ⬜ | 显式 Cast |

### 7.2 组合关系

| 场景 | 写法 | 状态 |
|------|------|------|
| 成员对象 | `UPROPERTY() UMyObject MyObj;` | ⬜ |
| 成员 Actor 引用 | `UPROPERTY() AActor OtherActor;` | ⬜ |
| 成员组件引用 | `UPROPERTY() UMyComponent Comp;` | ⬜ |
| TSubclassOf 成员 | `UPROPERTY() TSubclassOf<AActor> ActorClass;` | ⬜ |

---

## 子矩阵 8：类的序列化和复制

### 8.1 序列化

| 场景 | 状态 | 验证点 |
|------|------|--------|
| 保存到关卡 | ⬜ | 关卡保存/加载后属性保持 |
| Transient 类不保存 | ⬜ | 关卡保存后实例消失 |
| Config 属性保存 | ⬜ | 读取 .ini 文件 |
| SaveGame 属性 | ⬜ | 存档系统 |

### 8.2 网络复制

| 场景 | 状态 | 归属 |
|------|------|------|
| Replicated 属性 | ⬜ | Networking 套件 |
| ReplicatedUsing | ⬜ | Networking 套件 |
| Server RPC | ⬜ | Networking 套件 |
| Client RPC | ⬜ | Networking 套件 |
| NetMulticast RPC | ⬜ | Networking 套件 |

---

## 计划测试方法清单

### AngelscriptCoverageUClassTests.cpp（UCLASS 说明符）

| 方法 | 覆盖内容 |
|------|---------|
| `UClassBasicDeclaration` | 裸 UCLASS、无 UCLASS、继承基类 |
| `UClassBlueprintSpecifiers` | Blueprintable / NotBlueprintable / BlueprintType |
| `UClassBehaviorSpecifiers` | Abstract / Transient / NotPlaceable / Deprecated |
| `UClassConfigSpecifiers` | Config=Game / DefaultConfig / GlobalUserConfig |
| `UClassDisplaySpecifiers` | ClassGroup / HideCategories / ShowCategories |
| `UClassMetaData` | DisplayName / ToolTip / ShortTooltip |
| `UClassSpecifierCombinations` | 说明符组合验证 |

### AngelscriptCoverageClassLifecycleTests.cpp（生命周期）

| 方法 | 覆盖内容 |
|------|---------|
| `ActorLifecycle` | BeginPlay / Tick / EndPlay / Destroyed |
| `ActorConstructionScript` | OnConstruction |
| `PawnLifecycle` | SetupPlayerInputComponent / PossessedBy |
| `ComponentLifecycle` | BeginPlay / TickComponent / EndPlay |
| `WidgetLifecycle` | Construct / Destruct / Tick |
| `SubsystemLifecycle` | Initialize / Deinitialize |
| `MultiLevelInheritanceLifecycle` | 3 层继承链生命周期调用顺序 |

### AngelscriptCoverageClassFeaturesTests.cpp（类特性）

| 方法 | 覆盖内容 |
|------|---------|
| `DefaultKeywordOverride` | default 覆盖父类默认值 |
| `DefaultKeywordMethods` | default 调用父类方法 |
| `AccessModifiers` | private / protected / public |
| `AbstractClass` | Abstract 类不可实例化 |
| `InterfaceImplementation` | 实现接口、Cast<IInterface> |
| `ComponentDeclaration` | DefaultComponent / RootComponent / Attach |
| `ComponentTypes` | 各种组件类型声明 |
| `InheritanceChain` | 多层继承、super 调用 |
| `ClassCasting` | Cast 向上/向下转换 |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. **UCLASS 核心说明符**（Blueprintable / Abstract / Config）
2. **Actor 生命周期**（BeginPlay / Tick / EndPlay）
3. **组件声明和使用**（DefaultComponent / RootComponent）

### 🟡 中优先级

4. **default 关键字**（覆盖默认值、调用父类方法）
5. **访问修饰符**（private / protected / public）
6. **接口实现**（单接口、多接口、Cast）
7. **多层继承**（3+ 层继承链、super 调用）

### 🟢 低优先级

8. **显示和分组说明符**（HideCategories / ShowCategories）
9. **特殊用途说明符**（ConversionRoot / SparseClassDataTypes）
10. **序列化和复制**（属于独立 Networking 套件）

---

## 如何复用本矩阵

本矩阵结构可用于其他 UE 宏的覆盖测试：

1. **USTRUCT** - 复制本文件，替换为 USTRUCT 说明符
2. **UENUM** - 枚举说明符和用法
3. **UINTERFACE** - 接口说明符
4. **UFUNCTION** - 函数说明符（已在 int 测试中部分覆盖）
5. **UPROPERTY** - 属性说明符（已在 int 测试中完整覆盖）

调整时注意：
- USTRUCT 无生命周期方法
- UENUM 无组件概念
- UINTERFACE 无实例化
