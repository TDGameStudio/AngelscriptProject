# UCLASS 与类系统覆盖矩阵

> **本矩阵是 UCLASS/类系统测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 5 个测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持/拒绝边界。
>
> - 测试文件：`UClass`(36) / `UClassProperty`(18) / `UClassDefaultComponent`(6) / `ClassLifecycle`(9) / `ClassFeatures`(14) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.UClass`、`UClass.Property`、`UClass.DefaultComponent`、`ClassLifecycle`、`ClassFeatures`
> - 图例见 `../coverage-matrix.md`。

## 1. 类声明（UClassTests）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础类型声明（AActor 等基类） | ✅ | `UClassBaseTypeDeclarations` |
| 常见引擎基类声明 | ✅ | `UClassCommonEngineBaseDeclarations` |
| Gameplay 框架引用表面 | ✅ | `UClassGameFrameworkReferenceSurface` |

## 2. 说明符与元数据（UClassTests + ClassFeatures）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| Blueprintable/Abstract 说明符 | ✅ | `UClassBlueprintAndAbstractSpecifiers` |
| Config/Inline 创建说明符 | ✅ | `UClassConfigAndInlineCreationSpecifiers` |
| 行为标志 / 继承标志与 Config | ✅ | `UClassBehaviorFlags` `UClassInheritedFlagsAndConfig` |
| 显示/分类/特殊/脚本专属 元数据 | ✅ | `UClassDisplayAndCategoryMetadata` `UClassSpecialAndInheritedMetadata` `UClassScriptOnlyAndDisplayNameMetadata` |
| 子类忽略分类关键字 | ✅ | `UClassIgnoreCategoryKeywordsInSubclasses` |
| 说明符叉积/顺序/重复排序矩阵 | ✅ | `UClassSpecifierCrossProductMatrix` `UClassSpecifierOrderAndBoundaryCombinations` `UClassSpecifierDuplicateOrderingMatrix` |
| 说明符与元数据（ClassFeatures） | ✅ | `ClassFeatures::UClassSpecifiersAndMetadata` `UClassSpecifierCombinations` |
| 说明符列表语法/无效组合/不支持 边界 | 🚫 | `UClassSpecifierListSyntaxBoundaryMatrix` `UClassNonActorComponentSpecifierMetadataBoundary` `UClassUnsupportedSpecifierBoundaries` |

## 3. 访问控制与继承（UClassTests + ClassFeatures）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 默认继承属性表面 | ✅ | `UClassDefaultInheritancePropertySurface` |
| private/AllowPrivateAccess 可见性 | ✅ | `UClassPrivateAllowPrivateAccessPropertyVisibility` |
| 访问控制编译失败（边界） | 🚫 | `UClassAccessControlCompileFailures` |
| 访问修饰符 / 抽象类 / 继承链 / 类型转换 / 组合引用 | ✅ | `ClassFeatures::AccessModifiers` `AbstractClass` `InheritanceChain` `ClassCasting` `CompositionReferences` |
| 脚本类实现 native UINTERFACE 运行期分发 / 脚本级 interface 拒绝边界 | ✅ | `ClassFeatures::InterfaceImplementation` |

## 4. 运行期分发与生命周期（UClassTests + ClassLifecycle）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 抽象继承与运行期转型 | ✅ | `UClassAbstractInheritanceAndCastingRuntime` |
| CDO 默认对象与方法分发 | ✅ | `UClassUObjectDefaultObjectAndMethodDispatch` |
| CDO ↔ 实例独立性（CDO 突变后新实例继承新值；实例突变不污染 CDO） | ✅ | `UClassDefaultObjectAndInstanceStateIndependence` |
| 常见生命周期/子系统/Gameplay 事件函数表面 | ✅ | `UClassCommonLifecycleFunctionSurface` `UClassSubsystemFunctionSurface` `UClassGameFrameworkEventFunctionSurface` |
| Actor/Pawn/Component/Widget 生命周期 | ✅ | `ClassLifecycle::ActorLifecycle` `PawnLifecycle` `ComponentLifecycle` `WidgetLifecycle` |
| Actor 自身 Tick/EndPlay/Destroyed 运行期分发断言 | 🟡 | （G9）：`ActorLifecycle` 与 `MultiLevelInheritanceLifecycle` 脚本侧声明了 Tick/EndPlay/Destroyed 覆盖但仅断言 BeginPlay；测试注释承认需更复杂世界/生命周期 setup。Component 侧 Tick/EndPlay 已在 `ComponentLifecycle` 通过 `DispatchComponentTick` + `DestroyComponent` 真实驱动，Actor 同侧未补 |
| Actor 构造脚本 / 组件初始化 / 多级继承生命周期 | ✅ | `ClassLifecycle::ActorConstructionScript` `ActorComponentInitialization` `MultiLevelInheritanceLifecycle` |
| 抽象 Actor Spawn 被拒（边界） | 🚫 | `UClassAbstractActorSpawnIsRejected` |
| HUD DrawHUD 反射分发边界 | 🚫 | `UClassHUDDrawHUDReflectionDispatchBoundary` |
| 子系统生命周期反射边界 | 🚫 | `ClassLifecycle::SubsystemLifecycleReflectionBoundaries` |
| PostInitializeComponents 不可作 BlueprintOverride（边界，已隐含覆盖） | 🚫 | `ClassLifecycle::ActorComponentInitialization` 内含 |
| PostLoad / PreSave / PostInitProperties / BeginDestroy / FinishDestroy / Reset 等 native-only 虚方法的 BlueprintOverride 边界 | 🚫 | `ClassLifecycle::NativeOnlyVirtualOverrideBoundaries` |

## 5. 默认子对象组件（UClassTests + UClassDefaultComponent + ClassFeatures）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 默认组件树与引用表面 / 运行期操作 | ✅ | `UClassDefaultComponentTreeAndReferenceSurface` `UClassComponentRuntimeOperationSurface` |
| 组件派生类型矩阵 | ✅ | `UClassComponentDerivedTypeMatrix` |
| 默认组件说明符排列 / 隐式根排列 | ✅ | `UClassDefaultComponentSpecifierPermutationMatrix` `UClassDefaultComponentImplicitRootPermutation` |
| Override/原生父类 Override 组件矩阵 | ✅ | `UClassOverrideComponentSpecifierMatrix` `UClassNativeParentOverrideComponentMatrix` |
| 根/附加/socket/继承/隐式根/无效说明符（DefaultComponent 文件） | ✅ | `DefaultComponentRootAttachSocketRuntimeMatrix` `DefaultComponentShowOnActorSpecifierSurface` `DefaultComponentNativeComponentTypeMatrix` `DefaultComponentInheritanceAndForwardAttachMatrix` `DefaultComponentImplicitRootAndDelayedAttachMatrix` `DefaultComponentInvalidSpecifierBoundaryMatrix` |
| 组件声明/说明符/类型（ClassFeatures + default 关键字） | ✅ | `ClassFeatures::ComponentDeclaration` `ComponentSpecifierMetadata` `ComponentTypes` `DefaultKeywordOverride` `DefaultKeywordMethods` `DefaultKeywordContainersAndComponents` |
| 组件说明符无效组合（边界） | 🚫 | `UClassComponentSpecifierInvalidCombinationBoundaries` |

## 6. UObject 属性引用语义（UClassPropertyTests 18）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 标量/文本/struct 成员矩阵 | ✅ | `UClassScalarTextStructMemberMatrix` |
| 引用成员 / 引用容器成员矩阵 | ✅ | `UClassReferenceMemberMatrix` `UClassReferenceContainerMemberMatrix` |
| 接口成员矩阵 | ✅ | `UClassInterfaceMemberMatrix` |
| 容器/枚举容器/脚本结构容器成员矩阵 | ✅ | `UClassContainerMemberMatrix` `UClassEnumContainerMemberMatrix` `UClassScriptStructMemberContainerMatrix` |
| 可选成员矩阵 | ✅ | `UClassOptionalMemberMatrix` |
| 委托成员系列（返回/参数/类型化负载/struct 负载/容器负载） | ✅ | `UClassDelegateMemberMatrix` `UClassDelegateReturnMemberMatrix` `UClassDelegateParameterMemberMatrix` `UClassDelegateTypedPayloadMemberMatrix` `UClassDelegateStructPayloadMemberMatrix` `UClassDelegateContainerPayloadMemberMatrix` |
| 默认值与 CDO 矩阵（含继承 `default` 覆盖与自定义容器默认调用边界） | ✅ | `UClassDefaultValueAndCDOMatrix` |
| 访问与 BP 可见性矩阵 | ✅ | `UClassAccessAndBlueprintVisibilityMatrix` |
| 非 UPROPERTY 成员矩阵 | ✅ | `UClassNonUPropertyMemberMatrix` |
| 属性说明符与元数据矩阵 | ✅ | `UClassPropertySpecifierAndMetadataMatrix` |

---

## 汇总

| 文件 | 方法 |
|------|------|
| UClass | 36 |
| UClass.Property | 18 |
| UClass.DefaultComponent | 6 |
| ClassLifecycle | 9 |
| ClassFeatures | 14 |
| **合计** | **83** |

**待实现（⬜/🟡）**（2026-06-30 深审新增软候选，**非阻塞**；编号为 `coverage-gaps.md §1` 全局 G 编号）：

- `G9` 🟡 Actor 自身 Tick/EndPlay/Destroyed 运行期分发未断言（`ActorLifecycle`/`MultiLevelInheritanceLifecycle` 脚本声明覆盖但仅断言 BeginPlay；Component 侧已用 `DispatchComponentTick` + `DestroyComponent` 真实驱动，Actor 同侧未补）。

**已关闭**：

- G8 — `UClassDefaultObjectAndInstanceStateIndependence` 断言 CDO 突变只影响后续 `NewObject`，既有实例不被 retroactive 修改，实例突变也不会反写 CDO 或污染后续实例。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.UClass"` → `60/60`。
- G10 — `NativeOnlyVirtualOverrideBoundaries` 断言 `PostLoad` / `PreSave` / `PostInitProperties` / `BeginDestroy` / `FinishDestroy` / 直接 `Reset` 等 native-only 虚方法作为 `BlueprintOverride` 会编译失败；`OnReset` 合法路径仍由 UFunction/Actor lifecycle 测试覆盖。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.ClassLifecycle"` → `9/9`。

> 历史结论："类系统覆盖非常成熟，不支持说明符/组合均以 🚫 边界固化"。本轮深审进一步核到断言层：除剩余 1 条软候选外，未发现"伪 ✅ 降级"项；已抽查的 `Surface` 类方法（`UClassDefaultComponentTreeAndReferenceSurface` / `UClassComponentRuntimeOperationSurface` / `UClassUObjectDefaultObjectAndMethodDispatch` / `UClassDefaultObjectAndInstanceStateIndependence` / `UClassAbstractInheritanceAndCastingRuntime` / `UClassDefaultInheritancePropertySurface` 等）均带运行期行为断言（spawn / NewObject → `VerifyByPath` 回读），符合 mixed 标准；`...FunctionSurface` 系列按矩阵设计为反射上限（行标"函数表面"），不计为缺口。
