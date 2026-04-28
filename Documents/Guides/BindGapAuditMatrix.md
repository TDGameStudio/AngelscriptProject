# Bind 差距审计矩阵

> 快照提交：`cc5f25e`
>
> 目的：为 `Documents/Plans/Plan_TechnicalDebt.md` 的 `P0.4` 提供可复查的候选矩阵，明确每个 Bind 文件与 Hazelight/UEAS2 参考源之间的差距类型、测试落点、风险级别与去向决策。

## 矩阵字段说明

- **本地文件**：当前仓库中的候选 Bind 文件。
- **参考差距**：对照 Hazelight/UEAS2 参考源后，仍然存在的明确符号或行为差距。
- **可选模块依赖**：差距是否依赖额外插件模块、编辑器模块或高耦合上下文。
- **首批测试落点**：若保留在本计划内，优先补到哪个现有测试文件或目录。
- **风险级别**：`Low` / `Medium` / `High`。
- **决策**：保留在 `Plan_TechnicalDebt`、拆到 sibling plan，或判定为风格差异不纳入。

## 审计矩阵

| 本地文件 | 参考差距 | 可选模块依赖 | 首批测试落点 | 风险级别 | 决策 |
| --- | --- | --- | --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp` | Hazelight/UEAS2 仍有本地未吸收的 `intrusive optional state` API、`CalculateOptionalSize()` 回调、hot-reload 比较接口、`FUNC_NOJIT` 构造绑定，以及 `IsSet()/GetValue()/Get()` 的 `no_discard` 标注。 | 无；均为核心类型系统差距。 | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptDataTypeTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptTypeTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadPropertyTests.cpp` | `Medium` | 超出主计划 low-risk 范围；进一步收口转交 `Documents/Plans/Plan_AS238NonLambdaPort.md`。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp` | 参考侧仍有本地缺失的 struct intrusive optional state API、`TStructType` 模板绑定、`FIntPoint` base-structure 排除、`HasGetter/HasSetter(..., false)` 生成 getter/setter 检测，以及 `ScriptName` 多别名分号处理。 | 无；均为核心类型系统差距。 | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptStructCppOpsTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptContainerBindingsTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMathAndPlatformBindingsTests.cpp` | `Medium-Low` | 超出主计划 low-risk 范围；进一步收口转交 `Documents/Plans/Plan_AS238NonLambdaPort.md`。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` | 参考侧仍启用本地已注释的 `CPF_TObjectPtr` 过滤（本地 `Bind_BlueprintType.cpp:156-157`），并且有本地未吸收的 property getter/setter binding、property accessor 标记与更直接的函数映射路径。 | 无；均为核心绑定逻辑差距。 | `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptObjectBindingsTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptClassBindingsTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptUpgradeCompatibilityTests.cpp` | `Medium` | `CPF_TObjectPtr` 之外的后续工作转交 `Documents/Plans/Plan_AS238NonLambdaPort.md`。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp` | 参考侧仍有本地未接入的 `DeprecateOldActorGenericMethods` 配置控制、`GetComponentsByClassWithTag()`、`VerifySpawnActor` delegate hook；本地同时保留了参考没有的额外 helper/简易方法，迁移时需保留本地增强。 | 无额外模块；但需要扩展现有 `AngelscriptSettings` 与运行时 delegate 模式。 | `Plugins/Angelscript/Source/AngelscriptTest/Actor/AngelscriptActorInteractionTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptEngineBindingsTests.cpp` | `Low-Medium` | 剩余模块迁移转交 `Documents/Plans/Plan_HazelightBindModuleMigration.md`。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent.cpp` | 参考侧仍有本地未接入的 `FScopedMovementUpdate` RAII 包装、`SetComponentVelocity()`、`DeprecateOldActorGenericMethods` 配置控制；本地已有增强版 `GetComponentTransform()` / `SetRelativeLocation()` 等，需要保留而不是回退。 | 无；`FScopedMovementUpdate` 属于核心 Engine 能力。 | `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptEngineBindingsTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Actor/AngelscriptActorInteractionTests.cpp` | `Low` | `SetComponentVelocity` / `FScopedMovementUpdate` 已在 `Plan_TechnicalDebt` 落地；剩余模块迁移转交 `Documents/Plans/Plan_HazelightBindModuleMigration.md`。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp` | 参考侧仍有本地未接入的 `SetPreviousBindNoDiscard(true)`、`SetPreviousBindUnsafeDuringConstruction(true)`、稀疏 delegate `FUNC_NOJIT` 标记，以及 `DelegateTypeInfo` / `MulticastTypeInfo` 赋值；本地的 enum 属性兼容路径更现代，应保留。 | 无；均为绑定注解与元数据差距。 | `Plugins/Angelscript/Source/AngelscriptTest/Delegate/AngelscriptDelegateTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFileAndDelegateBindingsTests.cpp` | `Low-Medium` | 保留在本计划；以安全注解和元数据补齐为主。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult.cpp` | 与 Hazelight/UEAS2 的主要差距是 `SCRIPT_PROPERTY_DOCUMENTATION` 注解未同步；本地行为面未发现高风险缺口。 | 无；仅涉及文档宏。 | `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMathAndPlatformBindingsTests.cpp`，若不足则新建 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptHitResultTests.cpp` | `Low` | 保留在本计划；属于纯文档/元数据 parity closure。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp` | 参考侧仍有本地未吸收的 `int64` `Abs/Sign/Min/Max/Square` 重载、`LinePlaneIntersection(FPlane)`、`LineExtentBoxIntersection`、标量 `CubicInterpDerivative` 重载；JIT 绑定模式存在实现差异，但更像风格/历史分叉。 | 无；均为核心数值或 Kismet 数学 API。 | `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMathAndPlatformBindingsTests.cpp` | `Low-Medium` | 保留在本计划；优先做局部数值重载与数学函数补齐，JIT 模式差异单独验证。 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp` | 参考侧仍有本地缺失的 `ToDirectionAndLength` 绑定；`AngelscriptManager.h` vs `AngelscriptEngine.h` 头文件差异属于架构分叉，不构成阻塞。 | 无；仅涉及核心数学类型方法。 | `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMathAndPlatformBindingsTests.cpp`，若不足则新建 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFVector2fTests.cpp` | `Low` | 保留在本计划；单方法补齐，适合作为 `P4.2` 的最小入口。 |

## 审计结论

- 本轮 `P0.4` 审计覆盖的 9 个 Bind 候选文件，均未发现必须立即拆到 sibling plan 的高耦合依赖。
- 当前差距大多可归类为三类：
  - **低风险 API / overload 补齐**：如 `Bind_FMath.cpp`、`Bind_FVector2f.cpp`
  - **安全注解 / 元数据 / 文档 parity**：如 `Bind_Delegates.cpp`、`Bind_FHitResult.cpp`
  - **中风险但局部可控的类型系统增强**：如 `Bind_TOptional.cpp`、`Bind_UStruct.cpp`、`Bind_BlueprintType.cpp`
- 本地文件中已存在的增强能力应视为当前插件语义的一部分，后续 `P4.2` 只做差量吸收，不能为了贴近 Hazelight/UEAS2 而回退这些本地增强。
- 现阶段仍保留 sibling plan 的必要性：接口绑定、AS238 语言/ThirdParty 迁移、Hazelight 大批量模块迁移等主题不在这 9 个文件的低风险审计范围内，后续若发现新差距跨出当前矩阵边界，再按 `P4.3` 分流。

## Phase 4 执行过滤器

### 先进入 `P4.2` 的低风险项

- `Bind_FVector2f.cpp`
  - 目标：补齐 `ToDirectionAndLength` 绑定。
  - 原因：单方法缺口，测试落点集中在 `Bindings/AngelscriptMathAndPlatformBindingsTests.cpp`。
- `Bind_FMath.cpp`
  - 目标：优先补齐 `int64` 数值重载与局部数学函数缺口，不碰 JIT 模式差异。
  - 原因：行为闭环可由 `Bindings/AngelscriptMathAndPlatformBindingsTests.cpp` 直接锁住。
- `Bind_FHitResult.cpp`
  - 目标：同步 `SCRIPT_PROPERTY_DOCUMENTATION` 注解。
  - 原因：纯元数据 parity，不扩散到运行时行为。
- `Bind_Delegates.cpp`
  - 目标：补齐 `SetPreviousBindNoDiscard(true)`、`SetPreviousBindUnsafeDuringConstruction(true)`、delegate type info 元数据等本地低风险差距。
  - 原因：不改变现有委托执行语义，优先补安全注解与元数据。
- `Bind_USceneComponent.cpp`
  - 目标：补齐 `FScopedMovementUpdate` / `SetComponentVelocity` 这类局部引擎 API 差量。
  - 原因：矩阵已确认无额外模块依赖，且测试可落在现有 Actor / Engine bindings 目录。

### 先留在矩阵、如超出局部收口即转 `P4.3` 的项

- `Bind_TOptional.cpp`
  - 触发拆分条件：一旦需要扩展 intrusive optional 语义到广泛类型系统或 hot-reload 结构比较协议，转 sibling plan。
- `Bind_UStruct.cpp`
  - 触发拆分条件：一旦收口涉及大范围 property accessor / script name 别名策略重写，转 sibling plan。
- `Bind_BlueprintType.cpp`
  - 触发拆分条件：若 `CPF_TObjectPtr` 恢复之外还需要大规模 property getter/setter 系统迁移，转 sibling plan。
- `Bind_AActor.cpp`
  - 触发拆分条件：若差距扩大到配置体系、spawn 校验框架或 broader actor generic method deprecation 策略，转 sibling plan。

### sibling plan 去向约束

- 接口相关绑定差距：并入 `Documents/Plans/Plan_InterfaceBinding.md`
- AS238 语言 / ThirdParty 迁移：并入 `Documents/Plans/Plan_AS238NonLambdaPort.md`（若文件尚未建，`P4.3` 先补计划文档）
- Hazelight 大批量模块迁移：并入 `Documents/Plans/Plan_HazelightBindModuleMigration.md`（若文件尚未建，`P4.3` 先补计划文档）
