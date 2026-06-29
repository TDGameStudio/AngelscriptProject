# Widget / UMG UI 覆盖矩阵

> 域：UserWidget 生命周期、BindWidget、控件属性、Slate 样式、布局、动态事件、运行期 API。
> 测试文件：`AngelscriptCoverageWidgetTests.cpp`
> Automation 前缀：`Angelscript.TestModule.Coverage.Widget` 与 `Angelscript.TestModule.Coverage.Widget.RuntimeApi`（同一文件下两个前缀，故全局主题计数为 90）。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例见 `../coverage-matrix.md`。

| 状态 | 方法数 |
|------|-------|
| ✅ | 24 |

## 测试方法清单

| # | TEST_METHOD | 覆盖点 |
|---|-------------|--------|
| 1 | WidgetClassAndBindWidgetReflection | WidgetClass/BindWidget 反射 |
| 2 | WidgetLifecycleAndAnimationOverrideReflection | 生命周期/动画重写反射 |
| 3 | WidgetInputEventOverrideReflection | 输入事件重写反射 |
| 4 | CreateWidgetAndViewportSurface | CreateWidget/视口 |
| 5 | GetWidgetFromNameUnsupportedBoundary | 按名取控件不支持边界 |
| 6 | WidgetTreeRuntimeOperations | WidgetTree 运行期操作 |
| 7 | WidgetVisibilityEnabledAndFocusQueries | 可见性/启用/焦点查询 |
| 8 | TextBlockTextAndColorRoundTrip | TextBlock 文本/颜色往返 |
| 9 | CommonControlPropertyMethods | 通用控件属性方法 |
| 10 | ImageResourceBrushRoundTrip | Image 资源 Brush 往返 |
| 11 | ButtonStyleRoundTrip | Button 样式往返 |
| 12 | TextBlockSetFontAppliesSlateFontInfoFields | 字体 SlateFontInfo 字段 |
| 13 | ContainerLayoutOperations | 容器布局操作 |
| 14 | OverlayLayerOrderOperations | Overlay 层序操作 |
| 15 | SlateStyleValueTypes | Slate 样式值类型 |
| 16 | ComboPanelSizeBoxAndBrushStateRoundTrips | Combo/SizeBox/Brush 状态往返 |
| 17 | AdvancedListViewSurfaces | 高级 ListView 表面 |
| 18 | WidgetDynamicEventsInvokeScriptHandlers | 动态事件触发脚本处理器 |
| 19 | AdditionalWidgetDynamicEventsInvokeScriptHandlers | 追加动态事件触发 |
| 20 | ButtonEventDelegateReflectionSurfaces | Button 事件委托反射 |
| 21 | WidgetAdditionalEventDelegateReflectionSurfaces | 追加事件委托反射 |
| 22 | WidgetAnimationPlaybackReflectionSurfaces | 动画播放反射 |
| 23 | WidgetFocusAndInputModeReflectionSurfaces | 焦点/输入模式反射 |
| 24 | BorderAndMarginStateRoundTrips | Border/Margin 状态往返 |
