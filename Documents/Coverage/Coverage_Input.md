# AngelScript 输入系统全覆盖矩阵

> 本文覆盖 AngelScript 中 **输入系统**的所有用法。
> 包括 Input Binding、Actions、Axis、Touch、增强输入系统等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 传统输入系统 | `AngelscriptTest/Coverage/AngelscriptCoverageInputTests.cpp` | ✅ 已完成 |
| 增强输入系统（UE5） | `AngelscriptTest/Coverage/AngelscriptCoverageEnhancedInputTests.cpp` | ⬜ 计划 |
| Touch 和手势 | `AngelscriptTest/Coverage/AngelscriptCoverageTouchInputTests.cpp` | ⬜ 计划 |

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：传统输入系统 - SetupInputComponent

### 1.1 输入组件绑定

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 获取输入组件 | `InputComponent = FindComponentByClass(UInputComponent)` | ✅ | |
| SetupPlayerInputComponent | `SetupPlayerInputComponent(UInputComponent)` | ✅ | Pawn/PlayerController 重写 |

### 1.2 Action 绑定

| 绑定类型 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| Pressed | `InputComponent.BindAction("Jump", IE_Pressed, this, n"OnJumpPressed")` | ✅ | 按下时触发 |
| Released | `InputComponent.BindAction("Jump", IE_Released, this, n"OnJumpReleased")` | ✅ | 释放时触发 |
| Repeat | `InputComponent.BindAction("Fire", IE_Repeat, this, n"OnFire")` | ✅ | 持续按住 |
| DoubleClick | `InputComponent.BindAction("Select", IE_DoubleClick, this, n"OnDoubleClick")` | ✅ | 双击 |

### 1.3 Axis 绑定

| 绑定类型 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| Axis 1D | `InputComponent.BindAxis("MoveForward", this, n"OnMoveForward")` | ✅ | 前后移动 |
| Axis 值 | `void OnMoveForward(float Value)` | ✅ | 值域 [-1, 1] |
| 多个 Axis | 左右、前后、上下 | ✅ | |

### 1.4 Key 直接绑定

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 按键绑定 | `InputComponent.BindKey(EKeys::Space, IE_Pressed, this, n"OnSpace")` | ✅ | 绕过 InputAction |
| 鼠标按钮 | `BindKey(EKeys::LeftMouseButton, ...)` | ✅ | |
| 键盘按键 | `BindKey(EKeys::W, ...)` / `EKeys::A/S/D` | ✅ | |

---

## 子矩阵 2：输入事件类型

### 2.1 EInputEvent 枚举

| 事件类型 | 枚举值 | 状态 | 触发时机 |
|---------|-------|------|---------|
| Pressed | `IE_Pressed` | ✅ | 按下瞬间 |
| Released | `IE_Released` | ✅ | 释放瞬间 |
| Repeat | `IE_Repeat` | ✅ | 持续按住（按键重复） |
| DoubleClick | `IE_DoubleClick` | ✅ | 双击 |
| Axis | `IE_Axis` | ✅ | Axis 值变化 |

### 2.2 按键状态查询

| 查询方法 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| IsInputKeyDown | `PlayerController.IsInputKeyDown(EKeys::W)` | ✅ | 键是否按下 |
| WasInputKeyJustPressed | `WasInputKeyJustPressed(EKeys::Space)` | ✅ | 本帧刚按下 |
| WasInputKeyJustReleased | `WasInputKeyJustReleased(EKeys::Space)` | ✅ | 本帧刚释放 |
| GetInputKeyTimeDown | `GetInputKeyTimeDown(EKeys::W)` | ✅ | 按下时长 |
| GetInputAxisValue | `GetInputAxisValue("MoveForward")` | ✅ | 获取 Axis 值 |

---

## 子矩阵 3：常见按键和输入

### 3.1 键盘按键

| 按键 | EKeys | 状态 | 用途 |
|------|-------|------|------|
| WASD | `EKeys::W/A/S/D` | ✅ | 移动 |
| 空格 | `EKeys::SpaceBar` | ✅ | 跳跃 |
| Shift | `EKeys::LeftShift` / `RightShift` | ✅ | 冲刺 |
| Ctrl | `EKeys::LeftControl` / `RightControl` | ✅ | 蹲下 |
| Alt | `EKeys::LeftAlt` / `RightAlt` | ✅ | |
| Tab | `EKeys::Tab` | ✅ | 切换 |
| Esc | `EKeys::Escape` | ✅ | 菜单 |
| 数字键 | `EKeys::One` ~ `EKeys::Nine` | ✅ | 快捷栏 |
| F 键 | `EKeys::F1` ~ `EKeys::F12` | ✅ | 功能键 |
| Enter | `EKeys::Enter` | ✅ | 确认 |

### 3.2 鼠标输入

| 输入 | EKeys | 状态 | 用途 |
|------|-------|------|------|
| 左键 | `EKeys::LeftMouseButton` | ✅ | 射击/选择 |
| 右键 | `EKeys::RightMouseButton` | ✅ | 瞄准/次要动作 |
| 中键 | `EKeys::MiddleMouseButton` | ✅ | |
| 滚轮上 | `EKeys::MouseScrollUp` | ✅ | 缩放 |
| 滚轮下 | `EKeys::MouseScrollDown` | ✅ | |
| 侧键 | `EKeys::ThumbMouseButton` / `ThumbMouseButton2` | ✅ | |
| 鼠标移动 | Axis: MouseX / MouseY | ✅ | 相机旋转 |

### 3.3 手柄输入

| 输入 | EKeys | 状态 | 用途 |
|------|-------|------|------|
| 面键 | `EKeys::Gamepad_FaceButton_Bottom` (A) | ✅ | 跳跃 |
| 面键 | `EKeys::Gamepad_FaceButton_Right` (B) | ✅ | 取消 |
| 面键 | `EKeys::Gamepad_FaceButton_Left` (X) | ✅ | 交互 |
| 面键 | `EKeys::Gamepad_FaceButton_Top` (Y) | ✅ | |
| 左摇杆 | Axis: Gamepad_LeftX / Gamepad_LeftY | ✅ | 移动 |
| 右摇杆 | Axis: Gamepad_RightX / Gamepad_RightY | ✅ | 相机 |
| LB/RB | `EKeys::Gamepad_LeftShoulder` / `RightShoulder` | ✅ | |
| LT/RT | `EKeys::Gamepad_LeftTrigger` / `RightTrigger` | ✅ | 射击/瞄准 |
| 方向键 | `EKeys::Gamepad_DPad_Up/Down/Left/Right` | ✅ | |
| Start/Select | `EKeys::Gamepad_Special_Left` / `Special_Right` | ✅ | 菜单 |

---

## 子矩阵 4：增强输入系统（Enhanced Input - UE5）

### 4.1 输入映射上下文（IMC）

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 添加映射上下文 | `EnhancedInputComponent.AddMappingContext(IMC, Priority)` | ⬜ | |
| 移除映射上下文 | `RemoveMappingContext(IMC)` | ⬜ | |
| 清空映射上下文 | `ClearAllMappings()` | ⬜ | |

### 4.2 输入动作（Input Action）

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 绑定动作 | `EnhancedInputComponent.BindAction(IA, ETriggerEvent::Triggered, this, n"OnAction")` | ⬜ | |
| Started | `ETriggerEvent::Started` | ⬜ | 开始触发 |
| Ongoing | `ETriggerEvent::Ongoing` | ⬜ | 持续触发 |
| Triggered | `ETriggerEvent::Triggered` | ⬜ | 触发完成 |
| Completed | `ETriggerEvent::Completed` | ⬜ | 动作完成 |
| Canceled | `ETriggerEvent::Canceled` | ⬜ | 被取消 |

### 4.3 输入动作值

| 值类型 | 类型 | 状态 | 说明 |
|-------|------|------|------|
| 数字 | float | ⬜ | 单一数值 |
| 2D 向量 | FVector2D | ⬜ | 移动输入 |
| 3D 向量 | FVector | ⬜ | 3D 输入 |
| bool | bool | ⬜ | 开关 |

### 4.4 输入修饰器（Modifiers）

| 修饰器 | 状态 | 说明 |
|-------|------|------|
| Dead Zone | ⬜ | 死区 |
| Negate | ⬜ | 取反 |
| Scale | ⬜ | 缩放 |
| Smooth | ⬜ | 平滑 |
| Response Curve | ⬜ | 响应曲线 |

### 4.5 输入触发器（Triggers）

| 触发器 | 状态 | 说明 |
|-------|------|------|
| Down | ⬜ | 按下 |
| Pressed | ⬜ | 按下瞬间 |
| Released | ⬜ | 释放瞬间 |
| Hold | ⬜ | 持续按住 N 秒 |
| Tap | ⬜ | 快速点击 |
| Pulse | ⬜ | 脉冲触发 |
| Combo | ⬜ | 组合键 |

---

## 子矩阵 5：触摸输入

### 5.1 触摸事件

| 事件 | 状态 | 说明 |
|------|------|------|
| TouchPressed | ⬜ | 手指按下 |
| TouchMoved | ⬜ | 手指移动 |
| TouchReleased | ⬜ | 手指抬起 |
| TouchRepeat | ⬜ | 持续触摸 |

### 5.2 触摸信息

| 信息 | 类型 | 状态 | 说明 |
|------|------|------|------|
| 位置 | FVector2D | ⬜ | 屏幕坐标 |
| 手指索引 | int | ⬜ | 多点触控 |
| 压力 | float | ⬜ | 触摸压力 |

### 5.3 手势

| 手势 | 状态 | 说明 |
|------|------|------|
| Pinch（捏合） | ⬜ | 缩放 |
| Swipe（滑动） | ⬜ | 方向滑动 |
| Rotate（旋转） | ⬜ | 两指旋转 |

---

## 子矩阵 6：输入模式

### 6.1 输入模式切换

| 模式 | 状态 | 说明 |
|------|------|------|
| Game Only | ⬜ | 仅游戏输入 |
| UI Only | ⬜ | 仅 UI 输入 |
| Game and UI | ⬜ | 游戏和 UI |

### 6.2 鼠标显示

| 操作 | 写法 | 状态 |
|------|------|------|
| 显示鼠标 | `SetShowMouseCursor(true)` | ✅ |
| 隐藏鼠标 | `SetShowMouseCursor(false)` | ✅ |
| 锁定鼠标 | `SetInputMode(...)` | ⬜ |

---

## 子矩阵 7：输入配置

### 7.1 InputSettings

| 配置 | 状态 | 说明 |
|------|------|------|
| Action Mappings | ⬜ | 项目设置中配置 |
| Axis Mappings | ⬜ | 项目设置中配置 |
| Axis Scale | ⬜ | 轴缩放值 |

### 7.2 运行时修改

| 操作 | 状态 | 说明 |
|------|------|------|
| 添加 Action Mapping | ⬜ | 运行时添加 |
| 移除 Mapping | ⬜ | |
| 保存按键设置 | ⬜ | 用户自定义按键 |

---

## 子矩阵 8：输入使用场景

### 8.1 角色控制

| 场景 | 状态 | 输入 |
|------|------|------|
| 移动 | ⬜ | WASD / 左摇杆 |
| 跳跃 | ⬜ | Space / A 键 |
| 冲刺 | ⬜ | Shift |
| 蹲下 | ⬜ | Ctrl |
| 相机旋转 | ⬜ | 鼠标 / 右摇杆 |

### 8.2 射击游戏

| 场景 | 状态 | 输入 |
|------|------|------|
| 射击 | ⬜ | 左键 / RT |
| 瞄准 | ⬜ | 右键 / LT |
| 换弹 | ⬜ | R 键 |
| 切换武器 | ⬜ | 滚轮 / 数字键 |

### 8.3 UI 交互

| 场景 | 状态 | 输入 |
|------|------|------|
| 选择按钮 | ⬜ | 鼠标点击 |
| 键盘导航 | ⬜ | Tab / 方向键 |
| 确认 | ⬜ | Enter / A 键 |
| 取消 | ⬜ | Esc / B 键 |

---

## 计划测试方法清单

### AngelscriptCoverageInputTests.cpp（传统输入）

| 方法 | 覆盖内容 | 状态 |
|------|---------|------|
| `SetupPlayerInputComponent` | SetupPlayerInputComponent 重写 | ✅ |
| `ActionBinding` | BindAction Pressed/Released/Repeat/DoubleClick | ✅ |
| `AxisBinding` | BindAxis 1D 多轴绑定 | ✅ |
| `KeyDirectBinding` | BindKey 直接按键绑定 | ✅ |
| `InputStateQuery` | IsInputKeyDown / WasJustPressed / GetInputAxisValue | ✅ |
| `KeyboardKeys` | WASD / 功能键 / 数字键 | ✅ |
| `MouseInput` | 鼠标按钮和移动轴 | ✅ |
| `GamepadInput` | 手柄按钮和摇杆轴 | ✅ |
| `InputComponentFinding` | FindComponentByClass(UInputComponent) | ✅ |
| `InputModeControl` | SetShowMouseCursor | ✅ |

### AngelscriptCoverageEnhancedInputTests.cpp（UE5）

| 方法 | 覆盖内容 |
|------|---------|
| `MappingContext` | Add/Remove MappingContext |
| `InputActionBinding` | BindAction + ETriggerEvent |
| `InputActionValue` | float / FVector2D / FVector |
| `InputModifiers` | DeadZone / Negate / Scale |
| `InputTriggers` | Pressed / Hold / Tap |

### AngelscriptCoverageTouchInputTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `TouchEvents` | TouchPressed/Moved/Released |
| `TouchInfo` | 位置/索引/压力 |
| `Gestures` | Pinch/Swipe/Rotate |

---

## 待补充清单

### 🔴 高优先级

1. **Action 和 Axis 绑定**（传统输入核心）
2. **常见按键映射**（WASD / 鼠标 / 手柄）
3. **输入状态查询**

### 🟡 中优先级

4. **增强输入系统**（UE5 推荐）
5. **输入模式切换**
6. **触摸输入**（移动平台）

### 🟢 低优先级

7. **手势识别**
8. **运行时按键重映射**

---

## 总结

输入系统是 **玩家交互的唯一入口**：
- 角色控制
- UI 交互
- 游戏操作

**估计工作量**：3 个测试文件，约 20-25 个测试方法
**优先级**：🔴🔴🔴 极高（玩家交互核心）






