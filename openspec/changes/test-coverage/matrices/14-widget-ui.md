# Widget / UMG UI 覆盖矩阵

> **本矩阵是 Widget/UMG 测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 `AngelscriptCoverageWidgetTests.cpp` 的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持。
>
> - 测试文件：`AngelscriptCoverageWidgetTests.cpp`（24 方法）
> - Automation 前缀：`Angelscript.TestModule.Coverage.Widget` 与 `...Widget.RuntimeApi`（同文件两前缀，故全局主题计数为 90）
> - 图例见 `../coverage-matrix.md`。

## 1. 声明与反射

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| WidgetClass 与 BindWidget 反射 | ✅ | `WidgetClassAndBindWidgetReflection` |
| 生命周期与动画重写反射 | ✅ | `WidgetLifecycleAndAnimationOverrideReflection` |
| 输入事件重写反射 | ✅ | `WidgetInputEventOverrideReflection` |

## 2. 创建与树操作

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| CreateWidget 与视口 | ✅ | `CreateWidgetAndViewportSurface` |
| WidgetTree 运行期操作 | ✅ | `WidgetTreeRuntimeOperations` |
| 可见性/启用/焦点查询 | ✅ | `WidgetVisibilityEnabledAndFocusQueries` |
| 按名取控件不支持边界 | 🚫 | `GetWidgetFromNameUnsupportedBoundary` |

## 3. 控件属性与样式

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| TextBlock 文本/颜色往返 / 字体 SlateFontInfo | ✅ | `TextBlockTextAndColorRoundTrip` `TextBlockSetFontAppliesSlateFontInfoFields` |
| 通用控件属性方法 | ✅ | `CommonControlPropertyMethods` |
| Image 资源 Brush 往返 / Button 样式往返 | ✅ | `ImageResourceBrushRoundTrip` `ButtonStyleRoundTrip` |
| Slate 样式值类型 | ✅ | `SlateStyleValueTypes` |
| Border/Margin 状态往返 | ✅ | `BorderAndMarginStateRoundTrips` |

## 4. 布局

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 容器布局操作 / Overlay 层序操作 | ✅ | `ContainerLayoutOperations` `OverlayLayerOrderOperations` |
| Combo/SizeBox/Brush 状态往返 | ✅ | `ComboPanelSizeBoxAndBrushStateRoundTrips` |
| 高级 ListView 表面 | ✅ | `AdvancedListViewSurfaces` |

## 5. 动态事件与反射

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 动态事件触发脚本处理器（含追加） | ✅ | `WidgetDynamicEventsInvokeScriptHandlers` `AdditionalWidgetDynamicEventsInvokeScriptHandlers` |
| Button 事件委托反射（含追加） | ✅ | `ButtonEventDelegateReflectionSurfaces` `WidgetAdditionalEventDelegateReflectionSurfaces` |
| 动画播放反射 | 🟡 | `WidgetAnimationPlaybackReflectionSurfaces`（仅反射表面，见 G7） |
| 焦点与输入模式反射 | 🟡 | `WidgetFocusAndInputModeReflectionSurfaces`（仅反射表面，见 G7） |

---

**对应测试方法**：24 方法。
**待增强（🟡）**：G7 — `WidgetAnimationPlaybackReflectionSurfaces` / `WidgetFocusAndInputModeReflectionSurfaces` 目前仅断言反射表面，未断言运行期行为（动画推进 / 焦点实际转移）。需实测确认 headless 下能否补运行期断言；若不可行则维持反射上限（同 networking 的天花板逻辑）。
**边界（🚫）**：`GetWidgetFromName` 运行时取控件为 fork 边界（`../coverage-gaps.md §2.4`）。
