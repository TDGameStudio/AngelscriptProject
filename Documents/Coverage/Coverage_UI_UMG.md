# AngelScript UI/UMG 系统全覆盖矩阵

> 本文覆盖 AngelScript 中 **UI 和 UMG（Unreal Motion Graphics）**的所有用法。
> 包括 Widget、Button、Text、Binding、动画等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| Widget 基础 | `AngelscriptTest/Coverage/AngelscriptCoverageWidgetTests.cpp` | ⬜ 计划 |
| UI 控件 | `AngelscriptTest/Coverage/AngelscriptCoverageUIControlTests.cpp` | ⬜ 计划 |
| 数据绑定 | `AngelscriptTest/Coverage/AngelscriptCoverageUIBindingTests.cpp` | ⬜ 计划 |
| UI 动画 | `AngelscriptTest/Coverage/AngelscriptCoverageUIAnimationTests.cpp` | ⬜ 计划 |

---

## 子矩阵 1：UUserWidget 基础

### 1.1 Widget 生命周期

| 方法 | 调用时机 | 状态 |
|------|---------|------|
| `NativeConstruct()` / `Construct()` | Widget 构造 | ⬜ |
| `NativeDestruct()` / `Destruct()` | Widget 销毁 | ⬜ |
| `NativeTick(FGeometry, float)` / `Tick()` | 每帧 | ⬜ |
| `OnInitialized()` | 初始化 | ⬜ |
| `OnAnimationStarted(UWidgetAnimation)` | 动画开始 | ⬜ |
| `OnAnimationFinished(UWidgetAnimation)` | 动画结束 | ⬜ |

### 1.2 Widget 创建和管理

| 操作 | 方法 | 状态 |
|------|------|------|
| 创建 Widget | `CreateWidget<UUserWidget>(...)` | ⬜ |
| 添加到视口 | `AddToViewport(ZOrder)` | ⬜ |
| 从视口移除 | `RemoveFromViewport()` | ��� |
| 添加到父 Widget | `AddChild(UWidget)` | ⬜ |
| 获取父 Widget | `GetParent()` | ⬜ |

### 1.3 Widget 可见性

| 操作 | 枚举/方法 | 状态 |
|------|----------|------|
| Visible | `ESlateVisibility::Visible` | ⬜ |
| Collapsed | `ESlateVisibility::Collapsed` | ⬜ |
| Hidden | `ESlateVisibility::Hidden` | ⬜ |
| HitTestInvisible | `ESlateVisibility::HitTestInvisible` | ⬜ |
| SelfHitTestInvisible | `ESlateVisibility::SelfHitTestInvisible` | ⬜ |
| 设置可见性 | `SetVisibility(ESlateVisibility)` | ⬜ |

---

## 子矩阵 2：常用 UI 控件

### 2.1 UButton（按钮）

| 特性/事件 | 状态 | 说明 |
|----------|------|------|
| OnClicked | ⬜ | 点击事件 |
| OnPressed | ⬜ | 按下事件 |
| OnReleased | ⬜ | 释放事件 |
| OnHovered | ⬜ | 鼠标悬停 |
| OnUnhovered | ⬜ | 鼠标离开 |
| SetIsEnabled | ⬜ | 启用/禁用 |
| WidgetStyle | ⬜ | 按钮样式 |

### 2.2 UTextBlock（文本）

| 操作 | 方法 | 状态 |
|------|------|------|
| 设置文本 | `SetText(FText)` | ⬜ |
| 获取文本 | `GetText()` | ⬜ |
| 设置颜色 | `SetColorAndOpacity(FSlateColor)` | ⬜ |
| 设置字体 | `SetFont(FSlateFontInfo)` | ⬜ |
| 设置对齐 | `SetJustification(...)` | ⬜ |

### 2.3 UEditableText（可编辑文本）

| 特性/事件 | 状态 | 说明 |
|----------|------|------|
| OnTextChanged | ⬜ | 文本改变事件 |
| OnTextCommitted | ⬜ | 提交事件（Enter） |
| SetText | ⬜ | 设置文本 |
| GetText | ⬜ | 获取文本 |
| SetIsReadOnly | ⬜ | 只读模式 |
| SetHintText | ⬜ | 提示文本 |

### 2.4 UImage（图片）

| 操作 | 方法 | 状态 |
|------|------|------|
| 设置纹理 | `SetBrushFromTexture(UTexture2D)` | ⬜ |
| 设置材质 | `SetBrushFromMaterial(UMaterialInterface)` | ⬜ |
| 设置颜色 | `SetColorAndOpacity(FLinearColor)` | ⬜ |
| 设置尺寸 | `SetBrushSize(FVector2D)` | ⬜ |

### 2.5 UProgressBar（进度条）

| 操作 | 方法 | 状态 |
|------|------|------|
| 设置百分比 | `SetPercent(float)` | ⬜ |
| 设置颜色 | `SetFillColorAndOpacity(FLinearColor)` | ⬜ |

### 2.6 USlider（滑块）

| 特性/事件 | 状态 | 说明 |
|----------|------|------|
| OnValueChanged | ⬜ | 值改变事件 |
| SetValue | ⬜ | 设置值 |
| GetValue | ⬜ | 获取值 |
| SetMinValue / SetMaxValue | ⬜ | 范围 |
| SetStepSize | ⬜ | 步长 |

### 2.7 UCheckBox（复选框）

| 特性/事件 | 状态 | 说明 |
|----------|------|------|
| OnCheckStateChanged | ⬜ | 状态改变 |
| SetIsChecked | ⬜ | 设置选中 |
| IsChecked | ⬜ | 获取状态 |

### 2.8 UComboBox（下拉框）

| 操作 | 状态 | 说明 |
|------|------|------|
| AddOption | ⬜ | 添加选项 |
| RemoveOption | ⬜ | 移除选项 |
| SetSelectedOption | ⬜ | 设置选中项 |
| OnSelectionChanged | ⬜ | 选择改变事件 |

---

## 子矩阵 3：容器和布局

### 3.1 UCanvasPanel（画布）

| 操作 | 状态 | 说明 |
|------|------|------|
| AddChild | ⬜ | 添加子控件 |
| SetPosition | ⬜ | 设置位置（绝对） |
| SetSize | ⬜ | 设置尺寸 |
| SetAnchors | ⬜ | 设置锚点 |

### 3.2 UVerticalBox / UHorizontalBox（垂直/水平盒）

| 操作 | 状态 | 说明 |
|------|------|------|
| AddChild | ⬜ | 添加子控件 |
| AddChildToVerticalBox | ⬜ | 添加到垂直盒 |
| RemoveChild | ⬜ | 移除子控件 |
| ClearChildren | ⬜ | 清空所有 |

### 3.3 UScrollBox（滚动盒）

| 操作 | 状态 | 说明 |
|------|------|------|
| ScrollToStart | ⬜ | 滚动到开始 |
| ScrollToEnd | ⬜ | 滚动到结束 |
| SetScrollOffset | ⬜ | 设置滚动偏移 |

### 3.4 USizeBox（尺寸盒）

| 操作 | 状态 | 说明 |
|------|------|------|
| SetWidthOverride | ⬜ | 覆盖宽度 |
| SetHeightOverride | ⬜ | 覆盖高度 |
| SetMinDesiredWidth | ⬜ | 最小宽度 |

### 3.5 UOverlay（叠加层）

| 操作 | 状态 | 说明 |
|------|------|------|
| AddChild | ⬜ | 添加层 |
| 层级顺序 | ⬜ | Z-Order |

---

## 子矩阵 4：数据绑定

### 4.1 属性绑定

| 绑定类型 | 状态 | 说明 |
|---------|------|------|
| 文本绑定 | ⬜ | 绑定 FText 函数 |
| 可见性绑定 | ⬜ | 绑定 ESlateVisibility 函数 |
| 颜色绑定 | ⬜ | 绑定 FLinearColor 函数 |
| 进度绑定 | ⬜ | 绑定 float 函数 |
| 启用状态绑定 | ⬜ | 绑定 bool 函数 |

### 4.2 绑定方法

| 方法 | 状态 | 说明 |
|------|------|------|
| UPROPERTY(meta=(BindWidget)) | ⬜ | 自动绑定控件 |
| GetWidgetFromName | ⬜ | 按名称获取控件 |

---

## 子矩阵 5：UI 动画

### 5.1 UWidgetAnimation

| 操作 | 方法 | 状态 |
|------|------|------|
| 播放动画 | `PlayAnimation(Animation)` | ⬜ |
| 停止动画 | `StopAnimation(Animation)` | ⬜ |
| 暂停动画 | `PauseAnimation(Animation)` | ⬜ |
| 恢复动画 | `ResumeAnimation(Animation)` | ⬜ |
| 反向播放 | `ReverseAnimation(Animation)` | ⬜ |
| 播放参数 | `PlayAnimation(..., float StartTime, int NumLoops, ...)` | ⬜ |
| 是否播放中 | `IsAnimationPlaying(Animation)` | ⬜ |

### 5.2 动画事件

| 事件 | 状态 | 说明 |
|------|------|------|
| OnAnimationStarted | ⬜ | 动画开始 |
| OnAnimationFinished | ⬜ | 动画结束 |
| BindToAnimationStarted | ⬜ | 绑定开始事件 |
| BindToAnimationFinished | ⬜ | 绑定结束事件 |

---

## 子矩阵 6：焦点和输入

### 6.1 焦点管理

| 操作 | 方法 | 状态 |
|------|------|------|
| 设置焦点 | `SetKeyboardFocus()` | ⬜ |
| 检查焦点 | `HasKeyboardFocus()` | ⬜ |
| 设置用户焦点 | `SetUserFocus(PlayerController)` | ⬜ |

### 6.2 输入模式

| 操作 | 方法 | 状态 |
|------|------|------|
| 仅 UI | `SetInputMode(FInputModeUIOnly)` | ⬜ |
| UI 和游戏 | `SetInputMode(FInputModeGameAndUI)` | ⬜ |
| 仅游戏 | `SetInputMode(FInputModeGameOnly)` | ⬜ |

---

## 子矩阵 7：样式和主题

### 7.1 样式刷（Slate Brush）

| 操作 | 状态 | 说明 |
|------|------|------|
| 设置纹理 | ⬜ | FSlateBrush |
| 设置颜色 | ⬜ | TintColor |
| 设置绘制模式 | ⬜ | Box/Border/Image |

### 7.2 字体

| 操作 | 状态 | 说明 |
|------|------|------|
| FSlateFontInfo | ⬜ | 字体信息 |
| 字体大小 | ⬜ | Size |
| 字体样式 | ⬜ | TypefaceFontName |

---

## 子矩阵 8：高级 UI 功能

### 8.1 UListView（列表视图）

| 操作 | 状态 | 说明 |
|------|------|------|
| SetListItems | ⬜ | 设置数据源 |
| RegenerateAllEntries | ⬜ | 重新生成 |
| OnItemClicked | ⬜ | 点击事件 |

### 8.2 UTileView（平铺视图）

| 操作 | 状态 | 说明 |
|------|------|------|
| SetListItems | ⬜ | 设置数据源 |
| EntryWidgetClass | ⬜ | 条目 Widget 类 |

### 8.3 UTreeView（树视图）

| 操作 | 状态 | 说明 |
|------|------|------|
| SetListItems | ⬜ | 设置根项 |
| OnGetChildren | ⬜ | 获取子项回调 |

---

## 子矩阵 9：UI 事件系统

### 9.1 鼠标事件

| 事件 | 签名 | 状态 |
|------|------|------|
| OnMouseButtonDown | `(FGeometry, FPointerEvent)` | ⬜ |
| OnMouseButtonUp | `(FGeometry, FPointerEvent)` | ⬜ |
| OnMouseMove | `(FGeometry, FPointerEvent)` | ⬜ |
| OnMouseEnter | `(FGeometry, FPointerEvent)` | ⬜ |
| OnMouseLeave | `(FPointerEvent)` | ⬜ |

### 9.2 键盘事件

| 事件 | 签名 | 状态 |
|------|------|------|
| OnKeyDown | `(FGeometry, FKeyEvent)` | ⬜ |
| OnKeyUp | `(FGeometry, FKeyEvent)` | ⬜ |

---

## 子矩阵 10：UI 使用场景

### 10.1 HUD

| 场景 | 状态 | 说明 |
|------|------|------|
| 生命值条 | ⬜ | ProgressBar |
| 准星 | ⬜ | Image |
| 弹药显示 | ⬜ | TextBlock |
| 小地图 | ⬜ | Image + 更新 |

### 10.2 菜单

| 场景 | 状态 | 说明 |
|------|------|------|
| 主菜单 | ⬜ | Button + 导航 |
| 暂停菜单 | ⬜ | Overlay |
| 设置菜单 | ⬜ | Slider / CheckBox |

### 10.3 对话框

| 场景 | 状态 | 说明 |
|------|------|------|
| 确认对话框 | ⬜ | Modal Widget |
| 提示消息 | ⬜ | 自动关闭 |
| 输入对话框 | ⬜ | EditableText |

---

## 计划测试方法清单

### AngelscriptCoverageWidgetTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `WidgetLifecycle` | Construct/Destruct/Tick |
| `WidgetCreation` | CreateWidget/AddToViewport |
| `WidgetVisibility` | Visible/Collapsed/Hidden |
| `WidgetHierarchy` | Parent/Child 关系 |

### AngelscriptCoverageUIControlTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `ButtonControl` | OnClicked/Pressed/Released |
| `TextControl` | SetText/GetText |
| `EditableTextControl` | OnTextChanged/Committed |
| `ImageControl` | SetBrush/Texture |
| `ProgressBarControl` | SetPercent |
| `SliderControl` | OnValueChanged |
| `CheckBoxControl` | OnCheckStateChanged |
| `ContainerLayouts` | Canvas/VerticalBox/HorizontalBox |

### AngelscriptCoverageUIBindingTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `PropertyBinding` | 文本/可见性/颜色绑定 |
| `WidgetBinding` | meta=(BindWidget) |
| `GetWidgetFromName` | 按名称获取 |

### AngelscriptCoverageUIAnimationTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `AnimationPlayback` | Play/Stop/Pause/Resume |
| `AnimationEvents` | OnAnimationStarted/Finished |
| `AnimationReverse` | 反向播放 |
| `AnimationLoop` | 循环播放 |

---

## 待补充清单

### 🔴 高优先级

1. **Widget 生命周期和创建**
2. **常用控件**（Button/Text/Image）
3. **事件绑定**（OnClicked 等）

### 🟡 中优先级

4. **容器和布局**（Canvas/Box）
5. **UI 动画**
6. **数据绑定**

### 🟢 低优先级

7. **高级控件**（ListView/TreeView）
8. **样式和主题**
9. **自定义绘制**

---

## 总结

UI/UMG 是 **玩家与游戏交互的界面**：
- HUD - 游戏内信息显示
- 菜单 - 游戏设置和导航
- 对话框 - 用户交互

**估计工作量**：4 个测试文件，约 25-30 个测试方法
**优先级**：🔴🔴🔴 极高（用户界面核心）
