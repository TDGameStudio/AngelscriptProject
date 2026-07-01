# 输入系统覆盖矩阵（传统输入 + Enhanced Input）

> **本矩阵是输入测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 `AngelscriptCoverageInputTests.cpp` 的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🟡＝部分覆盖（反射上限或子集），🚫＝fork/headless 不支持。
>
> - 测试文件：`AngelscriptCoverageInputTests.cpp`（21 方法）
> - Automation 前缀：`Angelscript.TestModule.Coverage.Input`
> - 图例见 `../coverage-matrix.md`。

## 1. 传统输入绑定

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| SetupPlayerInputComponent 初始化 | ✅ | `SetupPlayerInputComponent` |
| Action / Axis / 按键直绑 | ✅ | `ActionBinding` `AxisBinding` `KeyDirectBinding` |
| 绑定集合初始化后可见 / 高级绑定集合 | ✅ | `InputBindingCollectionsVisibleAfterSetup` `AdvancedInputComponentBindingCollections` |
| 输入组件查找 | ✅ | `InputComponentFinding` |
| 绑定优先级与消费语义（Block / Override / DontBlock / bConsumeInput / bExecuteWhenPaused） | ⬜ | 待实现（G25）：`bConsumeInput` 默认参数已在 `BindKey` mixin 暴露、`bExecuteWhenPaused` 已在 `BindDebugKey` 暴露，但运行期行为（消费/穿透、暂停时执行）与 `InputComponent.Priority` / Block / Override / DontBlock 设置后 InputComponent 链路反射或行为均未断言；待补 setter 反射或绑定列表覆写行为 |

## 2. 输入状态与设备

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 输入状态查询 | ✅ | `InputStateQuery` |
| 键盘 / 鼠标 / 手柄 | ✅ | `KeyboardKeys` `MouseInput` `GamepadInput` |
| PlayerController 设备 API（GetMousePosition / GetInputMotionState / GetInputAnalogKeyState / GetInputKeyTimeDown） | ⬜ | 待实现（G26）：`InputStateQuery` 仅以 `GetInputAxisValue` 触发 compile-failure 终止；`GetMousePosition` / `GetInputMotionState` / `GetInputAnalogKeyState` 在 fork 中 grep 零绑定，需补独立 compile-failure 边界以锁定"AS 不暴露"的反射上限 |
| 多 Player（双手柄 / 分屏 PlayerController） | ⬜ | 待实现（G27）：所有方法都仅构造单 PlayerController；多 Player 输入路由（CreatePlayer / GetPlayerControllerFromID / 第二手柄 InputComponent 隔离）反射或行为未断言 |

## 3. 输入模式 / 光标 / 反馈

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 输入模式控制（SetShowMouseCursor 边界） | ✅ | `InputModeControl` |
| 输入模式切换不支持边界 | 🚫 | `InputModeSwitchingUnsupportedBoundary` |
| 光标类型 / 点击 / 悬停事件（SetMouseCursor / bEnableClickEvents / bEnableMouseOverEvents） | ⬜ | 待实现（G28）：grep 零绑定；`InputModeControl` 仅覆盖 `SetShowMouseCursor` 一项边界，其余 cursor 类 API 缺独立 compile-failure 边界 |
| Force Feedback / Haptic（ClientPlayForceFeedback / SetHapticsByValue 等） | ⬜ | 待实现（G29）：APlayerController 反馈 API 在 fork 中 grep 零绑定，需补 compile-failure 边界 |

## 4. Enhanced Input（UE5）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| MappingContext 与 ActionValue（Bool / Axis1D / Axis2D / Axis3D / ConvertToType） | ✅ | `EnhancedInputMappingContextAndActionValues` |
| 组件绑定事件与移除 / 绑定句柄与移除 | 🟡 | `EnhancedInputComponentBindingEventsAndRemoval` `EnhancedInputBindingHandlesAndRemoval`（G20）：5 个 ETriggerEvent（Started/Ongoing/Triggered/Completed/Canceled）已 BindAction 编译可达，但 `GetTriggerEvent()` 反射断言仅覆盖 Started+Triggered 两项，Ongoing/Completed/Canceled 三个事件缺独立反射保留断言 |
| Modifier 与 Trigger（Add+计数） | 🟡 | `EnhancedInputModifiersAndTriggers`（G21）：仅断言 `AddModifier`/`AddTrigger` + `GetModifierCount`/`GetTriggerCount`；缺 `ModifyRaw` / `UpdateState` 行为或反射断言；Modifier 子集只覆盖 DeadZone/Negate/Scalar/Smooth/ResponseCurveExponential，未覆盖 Swizzle/FOVScaling 等；Trigger 子集只覆盖 Down/Pressed/Released/Hold/Tap/Pulse/Combo，未覆盖 ChordedAction（区别于 Combo） |
| Modifier 全集（Swizzle / FOVScaling 等） | ⬜ | 待实现（G22）：`UInputModifierSwizzleAxis` 已在 `Bindings/AngelscriptEnhancedInputBindingsTests.cpp` 暴露但 Coverage 缺反射上限断言；`UInputModifierFOVScaling` 在 fork 中 grep 零引用，需先 compile-failure 边界确认是否暴露 |
| Trigger 全集（ChordedAction 区别于 Combo） | ⬜ | 待实现（G23）：`UInputTriggerChordAction` 在 fork 中 grep 零引用，需以 compile-failure 边界或反射断言锁定其暴露状态（已覆盖 `UInputTriggerCombo` 一项，但 ChordAction 与 Combo 是不同类） |
| Action 与 Mapping 元数据 | ✅ | `EnhancedInputActionAndMappingMetadata` |
| 输入设置与运行期映射 API | ✅ | `InputSettingsAndRuntimeMappingApi` |
| EnhancedInputUserSettings / PlayerMappableKeyProfile | ⬜ | 待实现（G24）：grep 零引用；UE5 PlayerMappable Key Settings 子系统在 AS 暴露状态未知，需补 compile-failure 边界以锁定反射上限 |

## 5. 触摸 / 手势

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 触摸状态查询表面 | ✅ | `TouchStateQuerySurface` |
| 触摸/手势 API 边界 | 🚫 | `TouchAndGestureApiBoundaries` |

---

**对应测试方法**：21 方法。

**待实现（⬜）**：
- G20 EnhancedInput ETriggerEvent 全集（Ongoing/Completed/Canceled 三个事件的 `GetTriggerEvent()` 反射保留断言缺失）
- G21 Modifier/Trigger 应用行为（`ModifyRaw`/`UpdateState` 反射或行为；当前仅 Add+Count）
- G22 Swizzle / FOVScaling Modifier 反射上限
- G23 ChordedAction Trigger（区别于 Combo）反射或边界
- G24 EnhancedInputUserSettings / PlayerMappableKeyProfile compile-failure 边界
- G25 传统 InputComponent 优先级（Block/Override/DontBlock）+ bConsumeInput / bExecuteWhenPaused 运行期行为或反射
- G26 PlayerController 设备 API（GetMousePosition / GetInputMotionState / GetInputAnalogKeyState / GetInputKeyTimeDown）独立 compile-failure 边界
- G27 多 Player（双手柄 / 分屏 PlayerController）输入路由
- G28 光标类型 / 点击事件 / 悬停事件（SetMouseCursor / bEnableClickEvents / bEnableMouseOverEvents）compile-failure 边界
- G29 Force Feedback / Haptic（ClientPlayForceFeedback / SetHapticsByValue 等）compile-failure 边界

**真实饱和度**：当前 21 方法在反射上限内覆盖了 MappingContext/ActionValue 全部 4 种 ValueType、5 个 ETriggerEvent 编译可达性、Modifier/Trigger 的 Add+Count 子集、`GetTriggerEvent` 仅 Started+Triggered；headless 下"输入实际触发→handler 计数往返"非可达（依赖 SlateApplication 与 EnhancedInputSubsystem 实时 Tick），已通过 `InputModeSwitchingUnsupportedBoundary` / `TouchAndGestureApiBoundaries` 记 🚫 边界。本次降级集中在反射上限本可达但未做的能力面（G20/G21）以及 grep 零绑定但缺独立 compile-failure 边界的 PlayerController/反馈/光标/UserSettings 类 API（G24/G26/G28/G29）。Touch Pressed/Moved/Released 状态机走向延续 `TouchAndGestureApiBoundaries` 的 🚫 记录，不另开行。
