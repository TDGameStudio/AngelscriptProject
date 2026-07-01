# 物理与碰撞覆盖矩阵

> **本矩阵是物理/碰撞测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 `AngelscriptCoveragePhysicsTests.cpp` 的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`。
>
> - 测试文件：`AngelscriptCoveragePhysicsTests.cpp`（25 方法）
> - Automation 前缀：`Angelscript.TestModule.Coverage.Physics`
> - 图例见 `../coverage-matrix.md`。

## 1. 物理模拟与受力

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 物理模拟开关与状态 | ✅ | `PhysicsSimulation` | SetSimulatePhysics / 状态回读 |
| 施加力 / 冲量 / 扭矩 | ✅ | `PhysicsForces` | AddForce/AddImpulse/AddTorque |
| 线速度 / 角速度 | ✅ | `PhysicsVelocity` | Set/GetPhysicsLinearVelocity 等 |

## 2. 碰撞事件分发

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 组件级碰撞事件 | ✅ | `CollisionEvents` | OnComponentHit/BeginOverlap |
| Actor 级碰撞事件 | ✅ | `ActorCollisionEvents` | ActorHit 委托 |
| 移动触发的重叠 | ✅ | `ActorOverlapGeneratedByMovement` | 移动产生 Overlap |
| 组件碰撞事件分发链 | ✅ | `ComponentCollisionEventDispatch` | 事件路由 |

## 3. Trace / Overlap 查询

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 射线 / 扫描 trace | ✅ | `TraceOperations` | LineTrace/SweepTrace |
| 重叠检测 | ✅ | `OverlapDetection` | OverlapMulti/Components |
| Object/Profile/Sweep trace 变体 | ✅ | `TraceObjectProfileAndSweepVariants` | ByObjectType/ByProfile |
| 碰撞查询参数容器 | ✅ | `CollisionQueryParameterContainers` | FCollisionQueryParams |
| 碰撞对象查询初始化类型 | ✅ | `CollisionObjectQueryInitTypes` | FCollisionObjectQueryParams |

## 4. 碰撞通道 / 响应 / Profile

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 碰撞通道与响应设置 | ✅ | `CollisionChannelsAndResponses` | SetCollisionResponseToChannel |
| 碰撞 Profile 与启用模式 | ✅ | `CollisionProfilesAndEnabledModes` | SetCollisionProfileName / ECollisionEnabled |
| 碰撞通道矩阵回读 | ✅ | `CollisionChannelMatrix` | 全通道响应矩阵 |
| 碰撞响应容器操作 | ✅ | `CollisionResponseContainerOperations` | FCollisionResponseContainer |

## 5. HitResult

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| HitResult 基础字段 | ✅ | `HitResultFields` | Location/Normal/Distance |
| HitResult 扩展访问器 | ✅ | `HitResultExtendedAccessors` | 扩展字段 |
| 物理材质 HitResult 引用 | ✅ | `PhysicsMaterialHitResultReference` | PhysMaterial 引用 |

## 6. 角色移动（CharacterMovementComponent）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 角色移动物理设置 | ✅ | `CharacterMovementPhysicsSettings` | 重力/摩擦/最大速度 |
| 移动模式查询 | ✅ | `CharacterMovementModeQueryStates` | Walking/Falling 等 |
| 移动速度查询 | ✅ | `CharacterMovementVelocityQuery` | Velocity 读取 |

## 7. 约束与抛射物

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 物理约束组件设置 | ✅ | `PhysicsConstraintComponentSettings` | PhysicsConstraint 参数 |
| 物理约束预设配方 | ✅ | `PhysicsConstraintPresetRecipes` | 常用约束预设 |
| 抛射物移动设置 | ✅ | `ProjectileMovementSettings` | ProjectileMovementComponent |

---

## 汇总

| 维度 | 场景 | 状态 |
|------|------|------|
| 1 物理模拟与受力 | 3 | ✅ |
| 2 碰撞事件分发 | 4 | ✅ |
| 3 Trace/Overlap 查询 | 5 | ✅ |
| 4 通道/响应/Profile | 4 | ✅ |
| 5 HitResult | 3 | ✅ |
| 6 角色移动 | 3 | ✅ |
| 7 约束与抛射物 | 3 | ✅ |

**对应测试方法**：25 方法（全 ✅）。
**待实现（⬜）**：当前无硬缺口。若后续接入更多物理子系统（如布料、破坏 Chaos 字段），在对应维度补 ⬜ 行并排期。
