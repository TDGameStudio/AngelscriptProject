# Examples 测试融合计划

> **For agentic workers:** Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `AngelscriptTest/Examples/` 的 22 个文件融合进功能测试体系。不只是简单搬文件，而是以每个 Example 为种子，举一反三地设计完整的功能测试矩阵（正例 / 负例 / 边界），补齐现有测试覆盖缺口。

**Architecture:** 分四阶段推进——删除已有充分覆盖的 7 个 → 迁移 10 个并扩展为完整测试矩阵 → 新建 4 个关键缺失领域的测试 → 清理 Examples/ 目录。

**Tech Stack:** UE5 CQTest、`FCoverageModuleScope`、`AngelscriptTestSupport::BuildModule`、`AngelscriptTestMacros.h`

---

## 从 Example 提炼功能测试矩阵

每个 Example 只是一个"种子"——它演示了某个 AS 特性的 happy path。真正有价值的功能测试应该从这个种子出发，覆盖正例 / 负例 / 边界：

### 1. Timer API（来源：`TimersTest.cpp`）— 现有覆盖率 0%

**Example 种子**：`System::SetTimer` + `FTimerHandle` 暂停/恢复/清除

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `SetTimer_SingleShot` | 正例 | 一次性定时器正确触发回调 |
| `SetTimer_Looping` | 正例 | 循环定时器多次触发 |
| `SetTimer_ZeroInterval` | 边界 | 间隔为 0 时的行为（立即触发 or 报错） |
| `SetTimer_NegativeInterval` | 负例 | 负数间隔应安全处理 |
| `PauseAndResume` | 正例 | 暂停后不触发，恢复后继续 |
| `ClearAndInvalidate` | 正例 | 清除后句柄无效，不再触发 |
| `IsTimerPaused_NotSet` | 边界 | 查询未设置的定时器的暂停状态 |
| `ClearAlreadyCleared` | 边界 | 重复清除不崩溃 |
| `CallbackTargetDestroyed` | 负例 | 回调对象被销毁后定时器的安全性 |

**目标文件**：新建 `Functional/System/AngelscriptTimerTests.cpp`

---

### 2. BehaviorTree 节点（来源：`BehaviorTreeNodesTest.cpp`）— 现有覆盖率 0%

**Example 种子**：`UBTDecorator/Service/Task_BlueprintBase` 派生 + 生命周期方法

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `Decorator_CompileAndCheck` | 正例 | Decorator 派生编译通过，`PerformConditionCheckAI` 可覆写 |
| `Decorator_ConditionReturnValue` | 正例 | 条件检查返回 true/false 影响行为树执行 |
| `Service_ActivationAndTick` | 正例 | Service 的 `ActivationAI` + `TickAI` 生命周期 |
| `Task_ExecuteAndAbort` | 正例 | Task 的 `ExecuteAI` 执行和 `AbortAI` 中止 |
| `Task_ReturnFinished` | 正例 | Task 返回 `EBTNodeResult::Succeeded` 完成 |
| `DefaultNodeName` | 边界 | `default NodeName = "..."` 正确设置 |
| `MissingOverride_Compile` | 负例 | 不覆写必需方法时的编译行为 |
| `InvalidParentClass` | 负例 | 从错误基类派生应报错 |

**目标文件**：新建 `Functional/AI/AngelscriptBehaviorTreeNodeTests.cpp`

---

### 3. Character 输入（来源：`CharacterInputTest.cpp`）— 现有覆盖率 20%

**Example 种子**：`ACharacter` + `UInputComponent` + 按键/轴回调

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `CharacterDerive_Compile` | 正例 | 从 ACharacter 派生编译通过 |
| `InputComponent_Property` | 正例 | `UPROPERTY() UInputComponent` 声明与访问 |
| `ActionCallback_Pressed` | 正例 | 按键按下回调触发 |
| `ActionCallback_Released` | 正例 | 按键释放回调触发 |
| `AxisCallback_Float` | 正例 | 轴输入回调接收 float 值 |
| `MultipleBindings` | 正例 | 同一输入多个回调绑定 |
| `CallbackSignatureMismatch` | 负例 | 回调签名不匹配时的编译错误 |

**目标文件**：新建 `Functional/Input/AngelscriptCharacterInputTests.cpp`

---

### 4. Component 重叠事件（来源：`OverlapsTest.cpp`）— 现有覆盖率 60%

**Example 种子**：`OnComponentBeginOverlap/EndOverlap` + `AddUFunction`

现有 `AngelscriptActorInteractionTests.cpp` 已覆盖 Actor 级别重叠，需补充 Component 级别：

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `ComponentOverlap_BeginBind` | 正例 | `OnComponentBeginOverlap.AddUFunction()` 编译通过 |
| `ComponentOverlap_EndBind` | 正例 | `OnComponentEndOverlap.AddUFunction()` 编译通过 |
| `ComponentOverlap_ComplexSignature` | 正例 | 复杂回调签名（6 个参数含 `FHitResult&in`）编译通过 |
| `ComponentOverlap_WrongSignature` | 负例 | 回调参数不匹配时的编译错误 |
| `ComponentOverlap_Runtime` | 正例 | 运行时重叠实际触发回调 |

**目标文件**：扩展 `Functional/Actor/AngelscriptActorInteractionTests.cpp`

---

### 5. ConstructionScript（来源：`ConstructionScriptTest.cpp`）— 现有覆盖率 40%

**Example 种子**：`UFUNCTION() ConstructionScript()` + 动态组件创建

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `ConstructionScript_Compile` | 正例 | 构造脚本函数声明编译通过 |
| `ConstructionScript_ComponentCreate` | 正例 | 脚本内 `UBillboardComponent::Create()` 编译通过 |
| `ConstructionScript_DerivedProperty` | 正例 | 派生属性计算（`Product = A * B`）运行时验证 |
| `ConstructionScript_CalledOnSpawn` | 正例 | Spawn Actor 后构造脚本被调用 |
| `ConstructionScript_NotCalledOnLoad` | 边界 | 从存档加载时的调用行为 |

**目标文件**：扩展 `Functional/Actor/AngelscriptActorLifecycleTests.cpp`

---

### 6. UPROPERTY 元数据（来源：`PropertySpecifiersTest.cpp`）— 现有覆盖率 70%

**Example 种子**：`ShowOnlyInnerProperties`、`MakeEditWidget`、`EditCondition`、`ClampMin/Max`

现有 `Syntax/AngelscriptSyntaxUPropertyTests.cpp` 已覆盖基础修饰符，需补充元数据：

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `Meta_ClampMinMax_Compile` | 正例 | `ClampMin=0, ClampMax=100` 编译通过 |
| `Meta_ClampMinMax_Runtime` | 正例 | 运行时赋值被 Clamp 到范围内 |
| `Meta_ClampMinMax_Reversed` | 负例 | `ClampMin > ClampMax` 时的行为 |
| `Meta_EditCondition_Compile` | 正例 | `EditCondition="bEnabled"` 编译通过 |
| `Meta_MakeEditWidget_Compile` | 正例 | `MakeEditWidget` 编译通过 |
| `Meta_ShowOnlyInnerProperties` | 正例 | 嵌套结构体只展示内部属性 |
| `Meta_InlineEditConditionToggle` | 正例 | 内联条件切换编译通过 |

**目标文件**：扩展 `Syntax/AngelscriptSyntaxUPropertyTests.cpp`

---

### 7. UFUNCTION 修饰符（来源：`FunctionSpecifiersTest.cpp`）— 现有覆盖率 50%

**Example 种子**：`BlueprintEvent`、`NotBlueprintCallable`、`NetMulticast`、`Server`、`CallInEditor`

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `BlueprintEvent_Compile` | 正例 | `UFUNCTION(BlueprintEvent)` 编译通过 |
| `BlueprintEvent_Override` | 正例 | Blueprint 中可覆写该事件 |
| `NotBlueprintCallable_Compile` | 正例 | 标记后不暴露给蓝图 |
| `NotBlueprintCallable_ScriptStillCallable` | 正例 | 脚本内仍可调用 |
| `NetMulticast_Compile` | 正例 | 网络多播函数编译通过 |
| `Server_Compile` | 正例 | 服务器函数编译通过 |
| `CallInEditor_Compile` | 正例 | 编辑器调用函数编译通过 |
| `ConflictingSpecifiers` | 负例 | `BlueprintPure + BlueprintEvent` 冲突时的编译错误 |

**目标文件**：扩展 `Syntax/AngelscriptSyntaxUFunctionTests.cpp`

---

### 8. Widget UMG 生命周期（来源：`WidgetUmgTest.cpp`）— 现有覆盖率 60%

**Example 种子**：`BindWidget`、`Construct()`、`CreateWidget`、`AddToViewport`

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `BindWidget_Compile` | 正例 | `UPROPERTY(BindWidget) UTextBlock` 编译通过 |
| `BindWidget_AutoAssociation` | 正例 | 运行时自动关联到 Widget 树中的同名控件 |
| `Construct_Override` | 正例 | `void Construct()` 覆写编译通过 |
| `Tick_GeometryParam` | 正例 | `Tick(FGeometry, float)` 签名编译通过 |
| `CreateWidget_TSubclassOf` | 正例 | `TSubclassOf<UMyWidget>` 参数类型检查 |
| `BindWidget_MissingControl` | 负例 | Widget 树中不存在同名控件时的行为 |
| `BindWidget_WrongType` | 负例 | 控件类型不匹配时的编译错误 |

**目标文件**：扩展 `Bindings/AngelscriptUserWidgetBindingsTests.cpp`

---

### 9. TArray 容器（来源：`ArrayTest.cpp`）— 现有覆盖率 85%

现有测试已覆盖基础 API，需补充：

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `TArray_ObjectPointer` | 正例 | `TArray<AActor*>` 对象指针容器编译+运行时 |
| `TArray_NestedContainer` | 边界 | `TArray<TArray<int>>` 嵌套容器 |
| `TArray_AsUProperty` | 正例 | 作为 UPROPERTY 时的序列化完整性 |
| `TArray_EmptyIteration` | 边界 | 空数组遍历不崩溃 |

**目标文件**：扩展 `Bindings/AngelscriptTArrayBindingsTests.cpp`

---

### 10. TMap 容器（来源：`MapTest.cpp`）— 现有覆盖率 80%

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `TMap_RefReturn_Modify` | 正例 | `Find()` 返回引用后修改值生效 |
| `TMap_ComplexKeyValue` | 正例 | `TMap<FName, TArray<int>>` 复杂值类型 |
| `TMap_IterateAndRemove` | 边界 | 迭代时删除元素的安全性 |
| `TMap_FindMissing` | 边界 | `Find()` 查找不存在的键返回空 |

**目标文件**：扩展 `Bindings/AngelscriptMapBindingsTests.cpp`

---

### 11. Actor 基础（来源：`ActorTest.cpp`）— 现有覆盖率 85%

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `Default_bReplicates` | 正例 | `default bReplicates = true` 标志正确设置 |
| `Default_Tags` | 正例 | `default Tags.Add("Tag")` 运行时验证 |
| `BlueprintEvent_Declare` | 正例 | `BlueprintEvent void Func()` 编译通过 |
| `BlueprintEvent_CallFromScript` | 正例 | 脚本内调用 BlueprintEvent 的行为 |
| `ScriptOnlyMethod` | 正例 | 非 UFUNCTION 方法只在脚本层可见 |

**目标文件**：扩展 `Functional/Actor/AngelscriptActorLifecycleTests.cpp`

---

### 12. Math 命名参数（来源：`MathTest.cpp`）— 现有覆盖率 80%

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `RandRange_InBounds` | 正例 | 返回值在 [Min, Max] 范围内 |
| `RandRange_MinEqualsMax` | 边界 | Min == Max 时返回固定值 |
| `NamedParams_Clamp` | 正例 | `Math::Clamp(X=2.0, Min=0.0, Max=0.5)` 命名参数语法 |
| `NamedParams_OutOfOrder` | 正例 | 命名参数乱序传递仍正确 |

**目标文件**：扩展 `Bindings/AngelscriptMathFunctionLibraryTests.cpp`

---

### 13. Actor 运动（来源：`MovingObjectTest.cpp`）— 现有覆盖率 80%

| 测试用例 | 类型 | 验证内容 |
|---|---|---|
| `FVector_PlusEquals` | 正例 | `FVector += FVector` 就地修改运行时验证 |
| `FVector_MinusEquals` | 正例 | `FVector -= FVector` 就地修改运行时验证 |
| `Tick_StateToggle` | 正例 | Tick 中 bool 状态切换逻辑正确 |
| `SceneComponent_SetLocation` | 正例 | 组件位置更新反映到 Actor |

**目标文件**：扩展 `Functional/Actor/AngelscriptActorLifecycleTests.cpp`

---

### 14. CoverageTests 拆分（来源：`CoverageTests.cpp`）— 唯一运行时验证

这是最复杂的文件，包含 4 个测试类和 7 个 helper 函数。拆分矩阵：

| 原测试类 | 目标目录 | 需迁移的 helper |
|---|---|---|
| `CoverageActorTest` | `Functional/Actor/` | `CompileCoverageExample`、`RequireProperty`、`ExpectPropertyFlag` |
| `CoverageComponentTest` | `Component/` | `CreateCoverageRuntimeComponent` |
| `CoverageUObjectTest` | `Core/` | `CompileCoverageExample` |
| `CoveragePropertySpecifiersTest` | `ClassGenerator/` | `ExpectPropertyMetadata`、`ExpectPropertyMetadataExists` |

通用 helper（`GetCoverageExampleAbsolutePath`、`ExpectCoverageExampleExists`）提取到 `Shared/AngelscriptCoverageTestHelpers.h`

---

## 执行阶段

### Phase 1: 删除已有充分覆盖的文件（7 个）

- [ ] AccessSpecifiersTest、DelegatesTest、EnumTest、FormatStringTest、MixinMethodsTest、FunctionsTest、StructTest
- [ ] 处理 EnumTest 依赖（PropertySpecifiersTest 引用 `GetScriptExampleEnumSource()`）
- [ ] 编译 + 全量测试

### Phase 2: 迁移 + 扩展测试矩阵（10 个）

按上述矩阵 #5-#13 逐个实现，每个 Example：
1. 在目标 CQTest 文件中新增 TEST_METHOD（按矩阵中列出的用例）
2. 删除原 Example 文件
3. 编译验证

### Phase 3: 新建关键缺失领域测试（4 个）

按上述矩阵 #1-#4 逐个实现：
- [ ] Timer API → `Functional/System/AngelscriptTimerTests.cpp`（9 个测试用例）
- [ ] BehaviorTree → `Functional/AI/AngelscriptBehaviorTreeNodeTests.cpp`（8 个测试用例）
- [ ] Character Input → `Functional/Input/AngelscriptCharacterInputTests.cpp`（7 个测试用例）
- [ ] CoverageTests 拆分到 4 个目标目录

### Phase 4: 清理

- [ ] 删除 `TestSupport.cpp` 和 `Examples/` 目录
- [ ] 确认 `Angelscript.TestModule.ScriptExamples.*` 无注册测试
- [ ] 更新 `TESTING_GUIDE.md`

---

## 覆盖缺口优先级总结

| 优先级 | 功能领域 | 现有覆盖率 | 矩阵编号 | 新增测试用例数 |
|---|---|---|---|---|
| **HIGH** | Timer API | **0%** | #1 | 9 |
| **HIGH** | BehaviorTree 节点 | **0%** | #2 | 8 |
| **HIGH** | Character 输入 | **20%** | #3 | 7 |
| **HIGH** | Component 重叠 | **60%** | #4 | 5 |
| **MEDIUM** | ConstructionScript | **40%** | #5 | 5 |
| **MEDIUM** | UPROPERTY 元数据 | **70%** | #6 | 7 |
| **MEDIUM** | UFUNCTION 修饰符 | **50%** | #7 | 8 |
| **MEDIUM** | Widget 生命周期 | **60%** | #8 | 7 |
| **LOW** | TArray 复杂类型 | **85%** | #9 | 4 |
| **LOW** | TMap 引用返回 | **80%** | #10 | 4 |
| **LOW** | Actor 基础 | **85%** | #11 | 5 |
| **LOW** | Math 命名参数 | **80%** | #12 | 4 |
| **LOW** | Actor 运动 | **80%** | #13 | 4 |
| **—** | Coverage 拆分 | **—** | #14 | 迁移 |

**总计：新增约 77 个测试用例，覆盖 13 个功能领域**

---

## 关联文档

- `Plan_ScriptExamplesExpansion.md` — 原 Examples 扩展计划（本计划是其方向调整：从扩展转为融合）
- `Plan_CQTestFullMigration.md` — CQTest 全面迁移计划
- `TESTING_GUIDE.md` — 测试指南

## 验证清单

1. `RunBuild.ps1` 编译通过
2. `RunTests.ps1 -TestPrefix "Angelscript.TestModule"` 全量通过，无新增失败
3. `Angelscript.TestModule.ScriptExamples.*` 路径下测试数 = 0
4. `Examples/` 目录不存在
5. 新增 ~77 个 TEST_METHOD 全部通过
