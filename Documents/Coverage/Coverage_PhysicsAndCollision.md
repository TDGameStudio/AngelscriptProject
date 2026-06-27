# AngelScript 物理和碰撞全覆盖矩阵

> 本文覆盖 AngelScript 中 **物理系统和碰撞检测**的所有用法。
> 包括物理模拟、碰撞响应、射线检测、物理约束等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 碰撞基础 | `AngelscriptTest/Coverage/AngelscriptCoverageCollisionTests.cpp` | ⬜ 计划 |
| 物理模拟 | `AngelscriptTest/Coverage/AngelscriptCoveragePhysicsTests.cpp` | ⬜ 计划 |
| 射线检测 | `AngelscriptTest/Coverage/AngelscriptCoverageTraceTests.cpp` | ⬜ 计划 |
| 物理约束 | `AngelscriptTest/Coverage/AngelscriptCoverageConstraintTests.cpp` | ⬜ 计划 |

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：碰撞配置

### 1.1 碰撞通道（Collision Channels）

| 通道 | 枚举值 | 状态 | 用途 |
|------|-------|------|------|
| WorldStatic | `ECC_WorldStatic` | ⬜ | 静态环境 |
| WorldDynamic | `ECC_WorldDynamic` | ⬜ | 动态物体 |
| Pawn | `ECC_Pawn` | ⬜ | 角色 |
| Visibility | `ECC_Visibility` | ⬜ | 视线检测 |
| Camera | `ECC_Camera` | ⬜ | 相机碰撞 |
| PhysicsBody | `ECC_PhysicsBody` | ⬜ | 物理对象 |
| Vehicle | `ECC_Vehicle` | ⬜ | 载具 |
| Destructible | `ECC_Destructible` | ⬜ | 可破坏物 |
| 自定义通道 | `ECC_GameTraceChannel1` ~ `18` | ⬜ | 项目自定义 |

### 1.2 碰撞响应（Collision Response）

| 响应类型 | 枚举值 | 状态 | 说明 |
|---------|-------|------|------|
| Ignore | `ECR_Ignore` | ⬜ | 忽略碰撞 |
| Overlap | `ECR_Overlap` | ⬜ | 重叠（触发事件） |
| Block | `ECR_Block` | ⬜ | 阻挡（物理碰撞） |

### 1.3 碰撞启用模式

| 模式 | 枚举值 | 状态 | 说明 |
|------|-------|------|------|
| NoCollision | `ECollisionEnabled::NoCollision` | ⬜ | 完全关闭 |
| QueryOnly | `ECollisionEnabled::QueryOnly` | ⬜ | 仅查询（射线） |
| PhysicsOnly | `ECollisionEnabled::PhysicsOnly` | ⬜ | 仅物理模拟 |
| QueryAndPhysics | `ECollisionEnabled::QueryAndPhysics` | ⬜ | 查询和物理 |

### 1.4 碰撞预设（Collision Profiles）

| 预设名 | 状态 | 典型用途 |
|-------|------|---------|
| NoCollision | ⬜ | 装饰物 |
| BlockAll | ⬜ | 墙壁 |
| OverlapAll | ⬜ | 触发器 |
| BlockAllDynamic | ⬜ | 动态阻挡 |
| OverlapAllDynamic | ⬜ | 动态触发 |
| IgnoreOnlyPawn | ⬜ | 忽略角色 |
| OverlapOnlyPawn | ⬜ | 仅与角色重叠 |
| Pawn | ⬜ | 角色碰撞 |
| PhysicsActor | ⬜ | 物理对象 |
| Projectile | ⬜ | 投射物 |

---

## 子矩阵 2：碰撞设置 API

### 2.1 组件级设置

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 启用碰撞 | `SetCollisionEnabled(Mode)` | ⬜ | |
| 设置预设 | `SetCollisionProfileName(FName)` | ⬜ | |
| 设置对象类型 | `SetCollisionObjectType(Channel)` | ⬜ | |
| 设置响应 | `SetCollisionResponseToChannel(Channel, Response)` | ⬜ | |
| 设置所有响应 | `SetCollisionResponseToAllChannels(Response)` | ⬜ | |
| 生成碰撞事件 | `SetNotifyRigidBodyCollision(bool)` | ⬜ | OnHit 事件 |
| 生成重叠事件 | `SetGenerateOverlapEvents(bool)` | ⬜ | BeginOverlap 事件 |

### 2.2 查询碰撞设置

| 查询 | 方法 | 状态 |
|------|------|------|
| 获取碰撞启用 | `GetCollisionEnabled()` | ⬜ |
| 获取预设名 | `GetCollisionProfileName()` | ⬜ |
| 获取对象类型 | `GetCollisionObjectType()` | ⬜ |
| 获取响应 | `GetCollisionResponseToChannel(Channel)` | ⬜ |

---

## 子矩阵 3：碰撞事件

### 3.1 Hit 事件（物理碰撞）

| 事件 | 签名 | 状态 | 触发条件 |
|------|------|------|---------|
| OnComponentHit | `(UPrimitiveComponent, AActor, UPrimitiveComponent, FVector, FHitResult)` | ⬜ | Block 响应 + 物理碰撞 |
| OnActorHit | `(AActor, AActor, FVector, FHitResult)` | ⬜ | Actor 级别 |
| 绑定 Hit 事件 | `OnComponentHit.AddDynamic(this, &ClassName::OnHit)` | ⬜ | |

### 3.2 Overlap 事件（重叠）

| 事件 | 签名 | 状态 | 触发条件 |
|------|------|------|---------|
| OnComponentBeginOverlap | `(UPrimitiveComponent, AActor, UPrimitiveComponent, int32, bool, FHitResult)` | ⬜ | 开始重叠 |
| OnComponentEndOverlap | `(UPrimitiveComponent, AActor, UPrimitiveComponent, int32)` | ⬜ | 结束重叠 |
| OnActorBeginOverlap | `(AActor, AActor)` | ⬜ | Actor 级别 |
| OnActorEndOverlap | `(AActor, AActor)` | ⬜ | Actor 级别 |
| 绑定 Overlap 事件 | `OnComponentBeginOverlap.AddDynamic(...)` | ⬜ | |

### 3.3 FHitResult 结构

| 字段 | 类型 | 状态 | 说明 |
|------|------|------|------|
| bBlockingHit | bool | ⬜ | 是否阻挡 |
| Actor | AActor | ⬜ | 碰撞对象 |
| Component | UPrimitiveComponent | ⬜ | 碰撞组件 |
| Location | FVector | ⬜ | 碰撞点 |
| Normal | FVector | ⬜ | 碰撞法线 |
| ImpactPoint | FVector | ⬜ | 撞击点 |
| ImpactNormal | FVector | ⬜ | 撞击法线 |
| Distance | float | ⬜ | 距离 |
| Time | float | ⬜ | 归一化时间 [0,1] |
| BoneName | FName | ⬜ | 骨骼名 |
| PhysMaterial | UPhysicalMaterial | ⬜ | 物理材质 |

---

## 子矩阵 4：射线检测（Ray/Line Trace）

### 4.1 LineTrace 方法

| 方法 | 状态 | 说明 |
|------|------|------|
| `LineTraceSingle` | ⬜ | 单次射线（第一个碰撞） |
| `LineTraceMulti` | ⬜ | 多次射线（所有碰撞） |
| `LineTraceSingleByChannel` | ⬜ | 按通道单次 |
| `LineTraceMultiByChannel` | ⬜ | 按通道多次 |
| `LineTraceSingleByObjectType` | ⬜ | 按对象类型单次 |
| `LineTraceMultiByObjectType` | ⬜ | 按对象类型多次 |

### 4.2 形状检测（Sweep）

| 方法 | 状态 | 说明 |
|------|------|------|
| `SweepSingle` | ⬜ | 形状扫描单次 |
| `SweepMulti` | ⬜ | 形状扫描多次 |
| `SphereTraceSingle` | ⬜ | 球形扫描 |
| `BoxTraceSingle` | ⬜ | 盒体扫描 |
| `CapsuleTraceSingle` | ⬜ | 胶囊扫描 |

### 4.3 重叠检测（Overlap）

| 方法 | 状态 | 说明 |
|------|------|------|
| `OverlapSingle` | ⬜ | 单次重叠检测 |
| `OverlapMulti` | ⬜ | 多次重叠检测 |
| `SphereOverlapActors` | ⬜ | 球形范围检测 Actor |
| `BoxOverlapActors` | ⬜ | 盒体范围检测 |
| `CapsuleOverlapActors` | ⬜ | 胶囊范围检测 |

### 4.4 Trace 参数

| 参数 | 类型 | 状态 | 说明 |
|------|------|------|------|
| Start | FVector | ⬜ | 起点 |
| End | FVector | ⬜ | 终点 |
| TraceChannel | ECollisionChannel | ⬜ | 碰撞通道 |
| Params | FCollisionQueryParams | ⬜ | 查询参数 |
| ResponseParams | FCollisionResponseParams | ⬜ | 响应参数 |
| OutHit | FHitResult | ⬜ | 输出结果 |

### 4.5 FCollisionQueryParams

| 字段 | 状态 | 说明 |
|------|------|------|
| TraceTag | ⬜ | 调试标签 |
| bTraceComplex | ⬜ | 精确碰撞 vs 简单碰撞 |
| bReturnPhysicalMaterial | ⬜ | 返回物理材质 |
| bReturnFaceIndex | ⬜ | 返回面索引 |
| AddIgnoredActor | ⬜ | 忽略 Actor |
| AddIgnoredActors | ⬜ | 忽略多个 Actor |

---

## 子矩阵 5：物理模拟

### 5.1 物理模拟设置

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 启用物理 | `SetSimulatePhysics(bool)` | ⬜ | |
| 启用重力 | `SetEnableGravity(bool)` | ⬜ | |
| 设置质量 | `SetMassOverrideInKg(FName, float, bool)` | ⬜ | |
| 设置质心 | `SetCenterOfMass(FVector)` | ⬜ | |
| 设置密度 | （由材质控制） | ⬜ | |
| 设置线性阻尼 | `SetLinearDamping(float)` | ⬜ | 空气阻力 |
| 设置角阻尼 | `SetAngularDamping(float)` | ⬜ | 旋转阻尼 |

### 5.2 物理约束

| 约束类型 | 状态 | 说明 |
|---------|------|------|
| Lock Position | ⬜ | 锁定位置轴 |
| Lock Rotation | ⬜ | 锁定旋转轴 |
| 限制运动 | ⬜ | 限制范围 |

### 5.3 施加力和冲量

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 添加力 | `AddForce(FVector, FName, bool)` | ⬜ | 持续力 |
| 添加冲量 | `AddImpulse(FVector, FName, bool)` | ⬜ | 瞬时冲量 |
| 添加径向力 | `AddRadialForce(FVector, float, ...)` | ⬜ | 爆炸力 |
| 添加径向冲量 | `AddRadialImpulse(...)` | ⬜ | 爆炸冲量 |
| 添加扭矩 | `AddTorque(FVector, FName, bool)` | ⬜ | 旋转力 |
| 添加角冲量 | `AddAngularImpulse(FVector, FName, bool)` | ⬜ | 旋转冲量 |

### 5.4 设置速度

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 设置线性速度 | `SetPhysicsLinearVelocity(FVector, bool, FName)` | ⬜ | |
| 设置角速度 | `SetPhysicsAngularVelocityInDegrees(FVector, bool, FName)` | ⬜ | |
| 获取线性速度 | `GetPhysicsLinearVelocity(FName)` | ⬜ | |
| 获取角速度 | `GetPhysicsAngularVelocityInDegrees(FName)` | ⬜ | |

### 5.5 物理材质

| 属性 | 状态 | 说明 |
|------|------|------|
| Friction | ⬜ | 摩擦力 |
| Restitution | ⬜ | 弹性（反弹） |
| Density | ⬜ | 密度 |

---

## 子矩阵 6：物理约束组件

### 6.1 UPhysicsConstraintComponent

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 设置约束组件 | `SetConstrainedComponents(A, B)` | ⬜ | |
| 锁定位置轴 | `SetLinearXLimit(...)` / Y / Z | ⬜ | |
| 锁定旋转轴 | `SetAngularSwing1Limit(...)` / Swing2 / Twist | ⬜ | |
| 启用马达 | `SetLinearPositionDrive(...)` | ⬜ | |
| 设置目标位置 | `SetLinearPositionTarget(FVector)` | ⬜ | |
| 断裂约束 | `BreakConstraint()` | ⬜ | |

### 6.2 约束类型

| 类型 | 状态 | 用途 |
|------|------|------|
| 铰链（Hinge） | ⬜ | 门、轮子 |
| 棱柱（Prismatic） | ⬜ | 活塞 |
| 球关节（Ball and Socket） | ⬜ | 链条 |
| 固定（Fixed） | ⬜ | 焊接 |

---

## 子矩阵 7：角色移动组件（CharacterMovementComponent）

### 7.1 移动模式

| 模式 | 枚举值 | 状态 | 说明 |
|------|-------|------|------|
| Walking | `MOVE_Walking` | ⬜ | 行走 |
| NavWalking | `MOVE_NavWalking` | ⬜ | 导航网格行走 |
| Falling | `MOVE_Falling` | ⬜ | 下落 |
| Swimming | `MOVE_Swimming` | ⬜ | 游泳 |
| Flying | `MOVE_Flying` | ⬜ | 飞行 |
| Custom | `MOVE_Custom` | ⬜ | 自定义 |

### 7.2 移动参数

| 参数 | 状态 | 说明 |
|------|------|------|
| MaxWalkSpeed | ⬜ | 最大行走速度 |
| MaxAcceleration | ⬜ | 最大加速度 |
| BrakingDeceleration | ⬜ | 制动减速度 |
| GroundFriction | ⬜ | 地面摩擦力 |
| JumpZVelocity | ⬜ | 跳跃速度 |
| AirControl | ⬜ | 空中控制 |
| GravityScale | ⬜ | 重力缩放 |

### 7.3 移动查询

| 查询 | 方法 | 状态 |
|------|------|------|
| 是否行走 | `IsWalking()` | ⬜ |
| 是否下落 | `IsFalling()` | ⬜ |
| 是否游泳 | `IsSwimming()` | ⬜ |
| 是否飞行 | `IsFlying()` | ⬜ |
| 获取速度 | `GetVelocity()` | ⬜ |
| 获取加速度 | `GetCurrentAcceleration()` | ⬜ |

---

## 子矩阵 8：投射物移动组件

### 8.1 UProjectileMovementComponent

| 参数 | 状态 | 说明 |
|------|------|------|
| InitialSpeed | ⬜ | 初始速度 |
| MaxSpeed | ⬜ | 最大速度 |
| bRotationFollowsVelocity | ⬜ | 旋转跟随速度 |
| bShouldBounce | ⬜ | 是否反弹 |
| Bounciness | ⬜ | 反弹系数 |
| ProjectileGravityScale | ⬜ | 重力缩放 |
| bIsHomingProjectile | ⬜ | 追踪投射物 |
| HomingTargetComponent | ⬜ | 追踪目标 |

---

## 子矩阵 9：碰撞使用场景

### 9.1 触发器（Trigger）

| 场景 | 状态 | 说明 |
|------|------|------|
| 区域触发 | ⬜ | 进入区域触发事件 |
| 拾取物品 | ⬜ | 角色碰到物品 |
| 检查点 | ⬜ | 通过检查点 |

### 9.2 射击检测

| 场景 | 状态 | 说明 |
|------|------|------|
| 子弹射线 | ⬜ | LineTrace 检测命中 |
| 爆炸范围 | ⬜ | SphereOverlap 检测范围伤害 |
| 近战攻击 | ⬜ | Sweep 检测攻击范围 |

### 9.3 环境交互

| 场景 | 状态 | 说明 |
|------|------|------|
| 开门 | ⬜ | Overlap 触发开门 |
| 按钮 | ⬜ | 碰撞触发按钮 |
| 可破坏物 | ⬜ | 物理碰撞破坏 |

---

## 计划测试方法清单

### AngelscriptCoverageCollisionTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `CollisionChannels` | 碰撞通道枚举 |
| `CollisionResponses` | Ignore/Overlap/Block |
| `CollisionProfiles` | 预设配置 |
| `CollisionSetup` | SetCollision* API |
| `HitEvent` | OnComponentHit |
| `OverlapEvents` | Begin/EndOverlap |
| `FHitResultFields` | HitResult 结构字段 |

### AngelscriptCoveragePhysicsTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `PhysicsSimulation` | SetSimulatePhysics/Gravity |
| `PhysicsForces` | AddForce/AddImpulse |
| `PhysicsVelocity` | Set/GetLinearVelocity |
| `PhysicsMaterial` | Friction/Restitution |
| `CharacterMovement` | MovementMode/Speed |
| `ProjectileMovement` | 投射物参数 |

### AngelscriptCoverageTraceTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `LineTraceSingle` | 单次射线 |
| `LineTraceMulti` | 多次射线 |
| `SphereTrace` | 球形扫描 |
| `BoxTrace` | 盒体扫描 |
| `OverlapActors` | 范围检测 |
| `TraceParams` | FCollisionQueryParams |

### AngelscriptCoverageConstraintTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `PhysicsConstraint` | 约束组件 |
| `ConstraintLimits` | 位置/旋转限制 |
| `ConstraintMotor` | 马达驱动 |
| `ConstraintBreak` | 断裂约束 |

---

## 待补充清单

### 🔴 高优先级

1. **碰撞事件**（Hit / Overlap）
2. **射线检测**（LineTrace / Sweep）
3. **碰撞配置**（Profile / Channel / Response）

### 🟡 中优先级

4. **物理模拟**（Force / Impulse / Velocity）
5. **角色移动**（MovementComponent）
6. **范围检测**（OverlapActors）

### 🟢 低优先级

7. **物理约束**（Constraint Component）
8. **投射物移动**（Projectile）
9. **物理材质**（Friction / Restitution）

---

## 总结

物理和碰撞是 **游戏交互的基础**：
- 碰撞检测 → 触发器、拾取
- 射线检测 → 射击、视线
- 物理模拟 → 真实物理交互
- 角色移动 → 玩家控制

**估计工作量**：4 个测试文件，约 25-30 个测试方法
**优先级**：🔴🔴🔴 极高（物理交互核心）





