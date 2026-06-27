# AngelScript UActorComponent 全覆盖矩阵

> 本文覆盖 AngelScript 中 **UActorComponent 及其派生类**的所有用法场景。
> 包括组件生命周期、组件说明符、组件类型、组件操作等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 组件基础和生命周期 | `AngelscriptTest/Coverage/AngelscriptCoverageComponentTests.cpp` | ✅ 已完成 |
| 组件说明符和属性 | `AngelscriptTest/Coverage/AngelscriptCoverageComponentPropertiesTests.cpp` | ⬜ 计划 |
| 场景组件（Transform） | `AngelscriptTest/Coverage/AngelscriptCoverageSceneComponentTests.cpp` | ✅ 已完成 |
| 图元组件（渲染/碰撞） | `AngelscriptTest/Coverage/AngelscriptCoveragePrimitiveComponentTests.cpp` | ✅ 已完成 |
| 特殊组件类型 | `AngelscriptTest/Coverage/AngelscriptCoverageSpecialComponentTests.cpp` | ✅ 已完成 |

✅ 组件系统核心功能已全面覆盖

- Automation 前缀：`Angelscript.TestModule.Coverage.Component*`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：组件继承层次

### 1.1 组件类型树

```
UActorComponent（基类组件）
├── USceneComponent（带变换的组件）
│   ├── UPrimitiveComponent（可渲染/碰撞的组件）
│   │   ├── UMeshComponent
│   │   │   ├── UStaticMeshComponent
│   │   │   ├── USkeletalMeshComponent
│   │   │   └── UProceduralMeshComponent
│   │   ├── UShapeComponent
│   │   │   ├── UBoxComponent
│   │   │   ├── USphereComponent
│   │   │   └── UCapsuleComponent
│   │   └── UBillboardComponent
│   ├── ULightComponentBase
│   │   ├── ULightComponent
│   │   │   ├── UPointLightComponent
│   │   │   ├── USpotLightComponent
│   │   │   └── UDirectionalLightComponent
│   ├── UCameraComponent
│   ├── USpringArmComponent
│   ├── UArrowComponent
│   └── UAudioComponent
├── UMovementComponent
│   ├── UCharacterMovementComponent
│   ├── UProjectileMovementComponent
│   ├── URotatingMovementComponent
│   └── UFloatingPawnMovement
├── UInputComponent
└── UChildActorComponent
```

### 1.2 基础组件类型覆盖

| 组件类型 | 基类 | 状态 | 典型用途 |
|---------|------|------|---------|
| `UActorComponent` | - | ✅ | 纯逻辑组件 |
| `USceneComponent` | UActorComponent | ✅ | 带变换的组件 |
| `UPrimitiveComponent` | USceneComponent | ✅ | 可渲染/碰撞 |
| `UStaticMeshComponent` | UMeshComponent | ✅ | 静态网格 |
| `USkeletalMeshComponent` | UMeshComponent | ✅ | 骨骼网格 |
| `UBoxComponent` | UShapeComponent | ✅ | 盒体碰撞 |
| `USphereComponent` | UShapeComponent | ✅ | 球体碰撞 |
| `UCapsuleComponent` | UShapeComponent | ✅ | 胶囊碰撞 |
| `UCameraComponent` | USceneComponent | ✅ | 相机 |
| `USpringArmComponent` | USceneComponent | ✅ | 弹簧臂 |
| `UPointLightComponent` | ULightComponent | ✅ | 点光源 |
| `UCharacterMovementComponent` | UMovementComponent | ✅ | 角色移动 |
| `UArrowComponent` | USceneComponent | ⬜ | 编辑器箭头 |
| `UAudioComponent` | USceneComponent | ⬜ | 音频 |
| `UInputComponent` | UActorComponent | ⬜ | 输入处理 |

---

## 子矩阵 2：组件声明方式

### 2.1 在 Actor 中声明组件

| 声明方式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| DefaultComponent | `UPROPERTY(DefaultComponent) USceneComponent Root;` | ✅ | 自动创建 |
| DefaultComponent + RootComponent | `UPROPERTY(DefaultComponent, RootComponent) USceneComponent Root;` | ✅ | 根组件 |
| DefaultComponent + Attach | `UPROPERTY(DefaultComponent, Attach=Root) UStaticMeshComponent Mesh;` | ✅ | 附加到其他组件 |
| DefaultComponent + AttachSocket | `UPROPERTY(DefaultComponent, AttachSocket="WeaponSocket") UStaticMeshComponent Weapon;` | ✅ | 附加到 Socket |
| DefaultComponent + ShowOnActor | `UPROPERTY(DefaultComponent, ShowOnActor) UCapsuleComponent Capsule;` | ✅ | 编辑器显示 |
| 普通 UPROPERTY 引用 | `UPROPERTY() USceneComponent SomeComponent;` | ✅ | 引用外部组件 |
| 动态创建组件 | `Comp = NewObject<UMyComponent>(this);` | ✅ | 运行时创建 |

### 2.2 组件 UPROPERTY 说明符

| 说明符 | 作用 | 写法示例 | 状态 |
|-------|------|---------|------|
| `DefaultComponent` | 自动创建组件 | `UPROPERTY(DefaultComponent)` | ⬜ |
| `RootComponent` | 标记为根组件 | `UPROPERTY(RootComponent)` | ⬜ |
| `Attach = Name` | 附加到指定组件 | `UPROPERTY(Attach=Root)` | ⬜ |
| `AttachSocket = "..."` | 附加到 Socket | `UPROPERTY(AttachSocket="Hand")` | ⬜ |
| `ShowOnActor` | 编辑器显示 | `UPROPERTY(ShowOnActor)` | ⬜ |
| `EditAnywhere` | 可编辑 | `UPROPERTY(DefaultComponent, EditAnywhere)` | ⬜ |
| `BlueprintReadOnly` | BP 只读 | `UPROPERTY(DefaultComponent, BlueprintReadOnly)` | ⬜ |
| `Instanced` | 实例化组件 | `UPROPERTY(Instanced)` | ⬜ |

---

## 子矩阵 3：组件生命周期

### 3.1 UActorComponent 生命周期

| 方法 | 调用时机 | 状态 | 验证点 |
|------|---------|------|--------|
| `OnComponentCreated()` | 组件创建时 | ✅ | 早于 BeginPlay |
| `InitializeComponent()` | 组件初始化 | ✅ | RegisterComponent 后 |
| `BeginPlay()` | 游戏开始 | ✅ | PIE 启动 |
| `TickComponent(float, ELevelTick, FActorComponentTickFunction*)` | 每帧调用 | ✅ | 需启用 Tick |
| `EndPlay(EEndPlayReason::Type)` | 游戏结束 | ✅ | PIE 停止 |
| `OnComponentDestroyed(bool)` | 组件销毁 | ✅ | DestroyComponent |
| `UninitializeComponent()` | 反初始化 | ✅ | UnregisterComponent 前 |

### 3.2 生命周期顺序验证

| 场景 | 状态 | 验证点 |
|------|------|--------|
| 创建顺序 | ⬜ | OnComponentCreated -> Initialize -> BeginPlay |
| 销毁顺序 | ⬜ | EndPlay -> Uninitialize -> OnComponentDestroyed |
| Actor 与 Component 顺序 | ⬜ | Actor.BeginPlay 后组件 BeginPlay |
| 多组件顺序 | ⬜ | 根组件先，子组件后 |
| 动态创建的组件 | ⬜ | 运行时 RegisterComponent |

---

## 子矩阵 4：组件 Tick 控制

### 4.1 Tick 配置

| 配置项 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| 启用 Tick | `PrimaryComponentTick.bCanEverTick = true;` | ⬜ | 构造函数设置 |
| 禁用 Tick | `PrimaryComponentTick.bCanEverTick = false;` | ⬜ | 默认禁用 |
| Tick 间隔 | `PrimaryComponentTick.TickInterval = 0.5f;` | ⬜ | 每 0.5 秒 |
| Tick 组 | `PrimaryComponentTick.TickGroup = TG_PrePhysics;` | ⬜ | Tick 顺序 |
| 开始时启用 Tick | `PrimaryComponentTick.bStartWithTickEnabled = true;` | ⬜ | |
| 运行时切换 | `SetComponentTickEnabled(bool)` | ⬜ | 动态控制 |

### 4.2 Tick 依赖

| 场景 | 写法 | 状态 |
|------|------|------|
| 依赖其他组件 Tick | `AddTickPrerequisiteComponent(OtherComp)` | ⬜ |
| 依赖 Actor Tick | `AddTickPrerequisiteActor(MyActor)` | ⬜ |
| 移除依赖 | `RemoveTickPrerequisiteComponent(...)` | ⬜ |

---

## 子矩阵 5：USceneComponent 特性（带变换）

### 5.1 变换操作

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 获取位置 | `GetComponentLocation()` | ✅ | 世界坐标 |
| 设置位置 | `SetWorldLocation(FVector)` | ✅ | |
| 获取旋转 | `GetComponentRotation()` | ✅ | |
| 设置旋转 | `SetWorldRotation(FRotator)` | ✅ | |
| 获取缩放 | `GetComponentScale()` | ✅ | |
| 设置缩放 | `SetWorldScale3D(FVector)` | ✅ | |
| 获取 Transform | `GetComponentTransform()` | ✅ | |
| 设置 Transform | `SetWorldTransform(FTransform)` | ✅ | |
| 相对位置 | `SetRelativeLocation(FVector)` | ✅ | 相对父组件 |
| 相对旋转 | `SetRelativeRotation(FRotator)` | ✅ | |

### 5.2 附加层次

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 附加到组件 | `AttachToComponent(USceneComponent, FName, EAttachmentRule, ...)` | ✅ | |
| 附加到 Actor | `AttachToActor(AActor, FName, ...)` | ✅ | |
| 分离 | `DetachFromComponent(FDetachmentTransformRules)` | ✅ | |
| 获取父组件 | `GetAttachParent()` | ✅ | |
| 获取子组件 | `GetAttachChildren()` | ✅ | |
| 获取 Socket 位置 | `GetSocketLocation(FName)` | ✅ | |
| 是否附加 | `IsAttachedTo(USceneComponent)` | ✅ | |

### 5.3 附加规则

| 规则 | 枚举值 | 状态 | 行为 |
|------|-------|------|------|
| 保持世界变换 | `EAttachmentRule::KeepWorld` | ⬜ | 位置不变 |
| 保持相对变换 | `EAttachmentRule::KeepRelative` | ⬜ | 相对父组件 |
| 对齐到目标 | `EAttachmentRule::SnapToTarget` | ⬜ | 贴合父组件 |

---

## 子矩阵 6：UPrimitiveComponent 特性（渲染和碰撞）

### 6.1 渲染属性

| 属性/方法 | 状态 | 说明 |
|----------|------|------|
| `SetVisibility(bool)` | ✅ | 显示/隐藏 |
| `SetHiddenInGame(bool)` | ✅ | 游戏中隐藏 |
| `SetCastShadow(bool)` | ✅ | 投射阴影 |
| `SetRenderCustomDepth(bool)` | ✅ | 自定义深度 |
| `SetCustomDepthStencilValue(int)` | ✅ | 模板值 |
| `SetMaterial(int, UMaterialInterface)` | ✅ | 设置材质 |
| `GetMaterial(int)` | ✅ | 获取材质 |
| `CreateDynamicMaterialInstance(int)` | ✅ | 动态材质 |

### 6.2 碰撞属性

| 属性/方法 | 状态 | 说明 |
|----------|------|------|
| `SetCollisionEnabled(ECollisionEnabled::Type)` | ✅ | 启用碰撞 |
| `SetCollisionProfileName(FName)` | ✅ | 碰撞配置 |
| `SetCollisionResponseToChannel(ECollisionChannel, ECollisionResponse)` | ✅ | 通道响应 |
| `SetCollisionResponseToAllChannels(ECollisionResponse)` | ✅ | 所有通道 |
| `SetCollisionObjectType(ECollisionChannel)` | ✅ | 对象类型 |
| `SetNotifyRigidBodyCollision(bool)` | ✅ | Hit 事件通知 |
| `SetGenerateOverlapEvents(bool)` | ✅ | Overlap 事件 |

### 6.3 碰撞事件

| 事件 | 签名 | 状态 | 触发时机 |
|------|------|------|---------|
| `OnComponentHit` | `(UPrimitiveComponent, AActor, UPrimitiveComponent, FVector, FHitResult)` | ✅ | 物理碰撞 |
| `OnComponentBeginOverlap` | `(UPrimitiveComponent, AActor, UPrimitiveComponent, int32, bool, FHitResult)` | ✅ | 开始重叠 |
| `OnComponentEndOverlap` | `(UPrimitiveComponent, AActor, UPrimitiveComponent, int32)` | ✅ | 结束重叠 |

### 6.4 物理属性

| 属性/方法 | 状态 | 说明 |
|----------|------|------|
| `SetSimulatePhysics(bool)` | ⬜ | 启用物理模拟 |
| `SetEnableGravity(bool)` | ⬜ | 启用重力 |
| `SetMassOverrideInKg(FName, float, bool)` | ⬜ | 设置质量 |
| `AddImpulse(FVector, FName, bool)` | ⬜ | 添加冲量 |
| `AddForce(FVector, FName, bool)` | ⬜ | 添加力 |
| `SetPhysicsLinearVelocity(FVector, bool, FName)` | ⬜ | 设置速度 |
| `SetPhysicsAngularVelocityInDegrees(FVector, bool, FName)` | ⬜ | 设置角速度 |

---

## 子矩阵 7：特殊组件类型

### 7.1 UStaticMeshComponent

| 特性/方法 | 状态 | 说明 |
|----------|------|------|
| `SetStaticMesh(UStaticMesh)` | ✅ | 设置网格 |
| `GetStaticMesh()` | ✅ | 获取网格 |
| `SetMaterial(int, UMaterialInterface)` | ✅ | 设置材质 |
| `GetNumMaterials()` | ✅ | 材质数量 |

### 7.2 USkeletalMeshComponent

| 特性/方法 | 状态 | 说明 |
|----------|------|------|
| `SetSkeletalMesh(USkeletalMesh)` | ✅ | 设置骨骼网格 |
| `SetAnimInstanceClass(TSubclassOf<UAnimInstance>)` | ✅ | 设置动画蓝图 |
| `PlayAnimation(UAnimSequence, bool)` | ✅ | 播放动画 |
| `GetBoneLocation(FName)` | ✅ | 骨骼位置 |
| `GetSocketLocation(FName)` | ✅ | Socket 位置 |

### 7.3 UCharacterMovementComponent

| 特性/方法 | 状态 | 说明 |
|----------|------|------|
| `MaxWalkSpeed` | ✅ | 最大行走速度 |
| `JumpZVelocity` | ✅ | 跳跃速度 |
| `GravityScale` | ✅ | 重力缩放 |
| `GetMovementMode()` | ✅ | 移动模式 |
| `SetMovementMode(EMovementMode)` | ✅ | 设置移动模式 |
| `IsWalking()` / `IsFalling()` / `IsFlying()` | ✅ | 状态查询 |

### 7.4 UCameraComponent

| 特性/方法 | 状态 | 说明 |
|----------|------|------|
| `FieldOfView` | ✅ | 视野角度 |
| `AspectRatio` | ✅ | 宽高比 |
| `bConstrainAspectRatio` | ✅ | 约束宽高比 |
| `SetProjectionMode(ECameraProjectionMode)` | ✅ | 投影模式 |

### 7.5 USpringArmComponent

| 特性/方法 | 状态 | 说明 |
|----------|------|------|
| `TargetArmLength` | ✅ | 弹簧臂长度 |
| `bDoCollisionTest` | ✅ | 碰撞检测 |
| `bEnableCameraLag` | ✅ | 相机延迟 |
| `CameraLagSpeed` | ✅ | 延迟速度 |

### 7.6 UBoxComponent / USphereComponent / UCapsuleComponent

| 特性/方法 | 状态 | 说明 |
|----------|------|------|
| `SetBoxExtent(FVector)` | ✅ | 盒体大小 |
| `SetSphereRadius(float)` | ✅ | 球体半径 |
| `SetCapsuleSize(float, float)` | ✅ | 胶囊尺寸 |
| `InitBoxExtent(FVector)` | ✅ | 初始化盒体 |

---

## 子矩阵 8：组件操作和查询

### 8.1 组件查找

| 方法 | 状态 | 说明 |
|------|------|------|
| `GetComponentByClass(TSubclassOf<UActorComponent>)` | ⬜ | 按类型查找 |
| `GetComponentsByClass(TSubclassOf<UActorComponent>)` | ⬜ | 查找所有 |
| `GetComponentsByTag(TSubclassOf<UActorComponent>, FName)` | ⬜ | 按标签查找 |
| `FindComponentByClass(TSubclassOf<UActorComponent>)` | ⬜ | 查找（含子类） |

### 8.2 组件注册和激活

| 方法 | 状态 | 说明 |
|------|------|------|
| `RegisterComponent()` | ⬜ | 注册组件 |
| `UnregisterComponent()` | ⬜ | 注销组件 |
| `Activate(bool)` | ⬜ | 激活组件 |
| `Deactivate()` | ⬜ | 停用组件 |
| `IsActive()` | ⬜ | 是否激活 |
| `IsRegistered()` | ⬜ | 是否注册 |

### 8.3 组件销毁

| 方法 | 状态 | 说明 |
|------|------|------|
| `DestroyComponent(bool)` | ⬜ | 销毁组件 |
| `K2_DestroyComponent()` | ⬜ | BP 版本 |
| `IsBeingDestroyed()` | ⬜ | 是否正在销毁 |

---

## 子矩阵 9：组件标签和元数据

| 特性/方法 | 状态 | 说明 |
|----------|------|------|
| `ComponentTags` | ⬜ | 标签数组 |
| `ComponentHasTag(FName)` | ⬜ | 是否有标签 |
| `SetComponentTickEnabled(bool)` | ⬜ | Tick 开关 |
| `SetComponentTickInterval(float)` | ⬜ | Tick 间隔 |
| `GetOwner()` | ⬜ | 获取所属 Actor |
| `GetWorld()` | ⬜ | 获取世界 |

---

## 子矩阵 10：自定义组件

### 10.1 脚本派生组件

| 场景 | 写法 | 状态 | 验证点 |
|------|------|------|--------|
| 派生 UActorComponent | `UCLASS() class UMyComponent : UActorComponent` | ⬜ | 纯逻辑组件 |
| 派生 USceneComponent | `UCLASS() class UMySceneComp : USceneComponent` | ⬜ | 带变换 |
| 派生 UPrimitiveComponent | `UCLASS() class UMyPrimitive : UPrimitiveComponent` | ⬜ | 可渲染 |
| 重写生命周期 | `BeginPlay() / TickComponent()` | ⬜ | 调用 super |
| 添加自定义属性 | `UPROPERTY() int MyValue;` | ⬜ | |
| 添加自定义方法 | `UFUNCTION() void MyMethod()` | ⬜ | |

### 10.2 组件复用

| 场景 | 状态 | 验证点 |
|------|------|--------|
| 在多个 Actor 中使用 | ⬜ | 组件类可复用 |
| 组件继承链 | ⬜ | Base -> Derived 组件 |
| 组件实例化 | ⬜ | NewObject 创建 |

---

## 计划测试方法清单

### AngelscriptCoverageComponentTests.cpp（基础和生命周期）

| 方法 | 覆盖内容 |
|------|---------|
| `ComponentBasicDeclaration` | DefaultComponent / RootComponent / Attach |
| `ComponentLifecycle` | OnComponentCreated -> BeginPlay -> Tick -> EndPlay |
| `ComponentTickControl` | bCanEverTick / TickInterval / SetComponentTickEnabled |
| `ComponentActivation` | Activate / Deactivate / IsActive |
| `ComponentRegistration` | RegisterComponent / UnregisterComponent |
| `ComponentDestruction` | DestroyComponent / IsBeingDestroyed |
| `ComponentFinding` | GetComponentByClass / GetComponentsByClass |
| `ComponentTags` | ComponentTags / ComponentHasTag |

### AngelscriptCoverageSceneComponentTests.cpp（变换和附加）

| 方法 | 覆盖内容 |
|------|---------|
| `SceneComponentTransform` | Get/SetWorldLocation/Rotation/Scale |
| `SceneComponentRelativeTransform` | Relative 位置/旋转 |
| `SceneComponentAttachment` | AttachToComponent / DetachFromComponent |
| `SceneComponentAttachmentRules` | KeepWorld / KeepRelative / SnapToTarget |
| `SceneComponentHierarchy` | GetAttachParent / GetAttachChildren |
| `SceneComponentSockets` | GetSocketLocation / AttachToComponent(Socket) |

### AngelscriptCoveragePrimitiveComponentTests.cpp（渲染和碰撞）

| 方法 | 覆盖内容 |
|------|---------|
| `PrimitiveRendering` | Visibility / CastShadow / CustomDepth |
| `PrimitiveMaterials` | SetMaterial / GetMaterial / CreateDynamicMaterialInstance |
| `PrimitiveCollisionSetup` | CollisionEnabled / CollisionProfile / ResponseToChannel |
| `PrimitiveCollisionEvents` | OnComponentHit / BeginOverlap / EndOverlap |
| `PrimitivePhysics` | SimulatePhysics / EnableGravity / AddImpulse / AddForce |

### AngelscriptCoverageSpecialComponentTests.cpp（特殊组件）

| 方法 | 覆盖内容 |
|------|---------|
| `StaticMeshComponent` | SetStaticMesh / SetMaterial |
| `SkeletalMeshComponent` | SetSkeletalMesh / PlayAnimation / GetBoneLocation |
| `CharacterMovementComponent` | MaxWalkSpeed / JumpZVelocity / MovementMode |
| `CameraComponent` | FieldOfView / ProjectionMode |
| `SpringArmComponent` | TargetArmLength / CameraLag |
| `ShapeComponents` | BoxExtent / SphereRadius / CapsuleSize |
| `CustomScriptComponent` | 脚本派生组件 |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. **组件声明和生命周期**（DefaultComponent / BeginPlay / Tick）
2. **场景组件变换**（Transform / Attach / Detach）
3. **碰撞和物理**（Collision / Physics / Events）

### 🟡 中优先级

4. **特殊组件类型**（StaticMesh / SkeletalMesh / Movement）
5. **组件查找和操作**（GetComponent / Activate / Destroy）
6. **自定义组件**（脚本派生组件类）

### 🟢 低优先级

7. **高级渲染**（CustomDepth / Material 动态实例）
8. **物理高级特性**（约束 / 力场）
9. **音频组件**（Sound / Attenuation）

---

## 如何复用本矩阵

本矩阵结构可用于其他组件主题的测试：

1. **UI 组件**（UMG Widget 组件）
2. **网络组件**（Replicated 组件）
3. **动画组件**（AnimInstance / Montage）
4. **AI 组件**（Perception / Navigation）

调整时注意：
- UI 组件无物理
- 网络组件需 PIE 多人测试
- 动画组件依赖骨骼网格





