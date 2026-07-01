# 组件覆盖矩阵

> **本矩阵是组件测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 4 个测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`。
>
> - 测试文件：`Component`(25) / `SceneComponent`(8) / `PrimitiveComponent`(11) / `SpecialComponent`(11) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<Component|SceneComponent|PrimitiveComponent|SpecialComponent>`
> - 图例见 `../coverage-matrix.md`；物理/碰撞系统级见 `13-physics-collision.md`。

## 1. UActorComponent 基础（ComponentTests 25）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础声明 / 特殊类型声明 | ✅ | `ComponentBasicDeclaration` `ComponentSpecialTypeDeclarations` |
| AudioComponent 声明与控制 / 淡入淡出与滤波 / 路由与反射 | ✅ | `AudioComponentDeclarationAndControls` `AudioComponentFadeAndFilterControls` `AudioComponentRoutingAndReflectionSurface` |
| 属性说明符 | ✅ | `ComponentPropertySpecifiers` |
| 生命周期 / 顺序 / 多组件与动态顺序 / 自定义 Super 调用 | ✅ | `ComponentLifecycle` `ComponentLifecycleOrdering` `ComponentActorMultiAndDynamicLifecycleOrdering` `CustomComponentLifecycleSuperCalls` |
| Tick 控制 / 配置与前置 / 运行期间隔控制 | ✅ | `ComponentTickControl` `ComponentTickConfigurationAndPrerequisites` `ComponentRuntimeTickIntervalControl` |
| 激活 / 注册与激活 | ✅ | `ComponentActivation` `ComponentRegistrationAndActivation` |
| 查找（通用/按类与标签） / 标签 | ✅ | `ComponentFinding` `ComponentFindingByClassAndTag` `ComponentTags` |
| 自定义脚本组件 / 复用继承与实例化 | ✅ | `CustomScriptComponent` `CustomComponentReuseInheritanceAndInstantiation` |
| 手动 NewObject 注册 | ✅ | `ComponentManualNewObjectRegistration` |
| 销毁 / 销毁回调与状态 / 销毁提升子级与 K2 元数据 | ✅ | `ComponentDestruction` `ComponentDestructionCallbacksAndState` `ComponentDestroyComponentPromoteChildrenAndK2Metadata` |
| 场景附加规则变换 | ✅ | `ComponentSceneAttachmentRuleTransforms` |

## 2. USceneComponent（SceneComponentTests 8）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 世界/相对变换 / 完整变换 | ✅ | `SceneComponentWorldTransform` `SceneComponentRelativeTransform` `SceneComponentCompleteTransform` |
| 附加 / 附加规则 / socket 附加 | ✅ | `SceneComponentAttachment` `SceneComponentAttachmentRules` `SceneComponentSocketAttachment` |
| 层级 | ✅ | `SceneComponentHierarchy` |
| 标签 | ✅ | `SceneComponentTags` |

## 3. UPrimitiveComponent（PrimitiveComponentTests 11）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 渲染 / 隐藏 | ✅ | `PrimitiveRendering` `PrimitiveHiddenInGame` |
| 碰撞设置 / 配置回读 / 响应 / 通道矩阵回读 | ✅ | `PrimitiveCollisionSetup` `PrimitiveCollisionConfigurationReadback` `PrimitiveCollisionResponse` `PrimitiveCollisionChannelMatrixReadback` |
| 碰撞事件 / Hit 事件 | ✅ | `PrimitiveCollisionEvents` `PrimitiveHitEvents` |
| 物理 / 物理状态回读 | ✅ | `PrimitivePhysics` `PrimitivePhysicsStateReadback` |
| Trace 对象查询回读 | ✅ | `PrimitiveTraceObjectQueryReadback` |

## 4. 特化组件（SpecialComponentTests 11）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| StaticMesh / CharacterMovement / Camera / SpringArm | ✅ | `StaticMeshComponent` `CharacterMovementComponent` `CameraComponent` `SpringArmComponent` |
| 形状组件：Box / Sphere / Capsule / 多形状 | ✅ | `BoxComponent` `SphereComponent` `CapsuleComponent` `MultipleShapeComponents` |
| 自定义脚本 SceneComponent | ✅ | `CustomScriptSceneComponent` |
| 追加默认组件类型 / 特化组件操作 | ✅ | `AdditionalDefaultComponentTypes` `SpecialComponentOperations` |

---

## 汇总

| 文件 | 方法 |
|------|------|
| Component | 25 |
| SceneComponent | 8 |
| PrimitiveComponent | 11 |
| SpecialComponent | 11 |
| **合计** | **55** |

**待实现（⬜）**：当前无硬缺口；组件 API 表面覆盖成熟。
