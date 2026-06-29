# 物理与碰撞覆盖矩阵

> 域：碰撞事件、物理模拟/力/速度、Trace/Overlap、碰撞通道与响应、约束、角色移动、抛射物。
> 测试文件：`AngelscriptCoveragePhysicsTests.cpp`（Automation 前缀 `Angelscript.TestModule.Coverage.Physics`）。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例见 `../coverage-matrix.md`。

| 状态 | 方法数 |
|------|-------|
| ✅ | 25 |

## 测试方法清单

| # | TEST_METHOD | 覆盖点 |
|---|-------------|--------|
| 1 | CollisionEvents | 碰撞事件 |
| 2 | PhysicsSimulation | 物理模拟 |
| 3 | PhysicsForces | 施力 |
| 4 | PhysicsVelocity | 速度 |
| 5 | TraceOperations | 射线/扫描 trace |
| 6 | OverlapDetection | 重叠检测 |
| 7 | CollisionChannelsAndResponses | 碰撞通道与响应 |
| 8 | CollisionProfilesAndEnabledModes | 碰撞 Profile 与启用模式 |
| 9 | HitResultFields | HitResult 字段 |
| 10 | ActorCollisionEvents | Actor 碰撞事件 |
| 11 | ActorOverlapGeneratedByMovement | 移动触发的重叠 |
| 12 | ComponentCollisionEventDispatch | 组件碰撞事件分发 |
| 13 | CollisionChannelMatrix | 碰撞通道矩阵 |
| 14 | TraceObjectProfileAndSweepVariants | 对象/Profile/Sweep trace 变体 |
| 15 | CollisionQueryParameterContainers | 碰撞查询参数容器 |
| 16 | CharacterMovementPhysicsSettings | 角色移动物理设置 |
| 17 | CharacterMovementModeQueryStates | 角色移动模式查询 |
| 18 | CharacterMovementVelocityQuery | 角色移动速度查询 |
| 19 | PhysicsMaterialHitResultReference | 物理材质 HitResult 引用 |
| 20 | PhysicsConstraintComponentSettings | 物理约束组件设置 |
| 21 | PhysicsConstraintPresetRecipes | 物理约束预设 |
| 22 | ProjectileMovementSettings | 抛射物移动设置 |
| 23 | CollisionResponseContainerOperations | 碰撞响应容器操作 |
| 24 | CollisionObjectQueryInitTypes | 碰撞对象查询初始化类型 |
| 25 | HitResultExtendedAccessors | HitResult 扩展访问器 |
