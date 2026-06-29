# 输入系统覆盖矩阵（传统输入 + Enhanced Input）

> 域：传统 InputComponent 绑定、按键/轴、输入模式、Enhanced Input（MappingContext/Action/Modifier/Trigger）。
> 测试文件：`AngelscriptCoverageInputTests.cpp`（Automation 前缀 `Angelscript.TestModule.Coverage.Input`）。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例见 `../coverage-matrix.md`。

| 状态 | 方法数 |
|------|-------|
| 🟡 | 21 |

## 测试方法清单

| # | TEST_METHOD | 覆盖点 |
|---|-------------|--------|
| 1 | SetupPlayerInputComponent | 输入组件初始化 |
| 2 | ActionBinding | Action 绑定 |
| 3 | AxisBinding | Axis 绑定 |
| 4 | KeyDirectBinding | 按键直绑 |
| 5 | InputBindingCollectionsVisibleAfterSetup | 绑定集合初始化后可见 |
| 6 | InputStateQuery | 输入状态查询 |
| 7 | KeyboardKeys | 键盘键 |
| 8 | MouseInput | 鼠标输入 |
| 9 | GamepadInput | 手柄输入 |
| 10 | InputComponentFinding | 输入组件查找 |
| 11 | InputModeControl | 输入模式控制 |
| 12 | InputModeSwitchingUnsupportedBoundary | 输入模式切换不支持边界 |
| 13 | EnhancedInputMappingContextAndActionValues | EI MappingContext/ActionValue |
| 14 | EnhancedInputComponentBindingEventsAndRemoval | EI 绑定事件与移除 |
| 15 | EnhancedInputModifiersAndTriggers | EI Modifier/Trigger |
| 16 | EnhancedInputActionAndMappingMetadata | EI Action/Mapping 元数据 |
| 17 | InputSettingsAndRuntimeMappingApi | 输入设置/运行期映射 API |
| 18 | TouchAndGestureApiBoundaries | 触摸/手势 API 边界 |
| 19 | AdvancedInputComponentBindingCollections | 高级绑定集合 |
| 20 | EnhancedInputBindingHandlesAndRemoval | EI 绑定句柄与移除 |
| 21 | TouchStateQuerySurface | 触摸状态查询表面 |

## 已知边界

- 输入模式切换、部分触摸/手势 API 在 fork/headless 下不支持，已以 `*UnsupportedBoundary` / `*ApiBoundaries` 方法记录。
