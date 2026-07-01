# Widget / UMG UI Coverage Matrix

> **This matrix is the design specification header for Widget/UMG tests**: each row is a concrete verifiable scenario guiding `AngelscriptCoverageWidgetTests.cpp` implementation. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork unsupported.
>
> - Test file: `AngelscriptCoverageWidgetTests.cpp`, 24 methods
> - Automation prefixes: `Angelscript.TestModule.Coverage.Widget` and `...Widget.RuntimeApi`, two prefixes in one file, which is why the global theme count is 90
> - See `../coverage-matrix.md` for the legend.

## 1. Declarations And Reflection

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| WidgetClass and BindWidget reflection | ✅ | `WidgetClassAndBindWidgetReflection` |
| Lifecycle and animation override reflection | ✅ | `WidgetLifecycleAndAnimationOverrideReflection` |
| Input event override reflection | ✅ | `WidgetInputEventOverrideReflection` |

## 2. Creation And Tree Operations

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| CreateWidget and viewport surface | ✅ | `CreateWidgetAndViewportSurface` |
| WidgetTree runtime operations | ✅ | `WidgetTreeRuntimeOperations` |
| Visibility / enabled / focus queries | ✅ | `WidgetVisibilityEnabledAndFocusQueries` |
| Unsupported get-widget-by-name boundary | 🚫 | `GetWidgetFromNameUnsupportedBoundary` |

## 3. Control Properties And Style

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| TextBlock text/color round trip / font SlateFontInfo | ✅ | `TextBlockTextAndColorRoundTrip` `TextBlockSetFontAppliesSlateFontInfoFields` |
| Common control property methods | ✅ | `CommonControlPropertyMethods` |
| Image resource brush round trip / Button style round trip | ✅ | `ImageResourceBrushRoundTrip` `ButtonStyleRoundTrip` |
| Slate style value types | ✅ | `SlateStyleValueTypes` |
| Border/Margin state round trips | ✅ | `BorderAndMarginStateRoundTrips` |

## 4. Layout

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Container layout operations / Overlay layer-order operations | ✅ | `ContainerLayoutOperations` `OverlayLayerOrderOperations` |
| Combo/SizeBox/Brush state round trips | ✅ | `ComboPanelSizeBoxAndBrushStateRoundTrips` |
| Advanced ListView surfaces | ✅ | `AdvancedListViewSurfaces` |

## 5. Dynamic Events And Reflection

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Dynamic events invoke script handlers, including added coverage | ✅ | `WidgetDynamicEventsInvokeScriptHandlers` `AdditionalWidgetDynamicEventsInvokeScriptHandlers` |
| Button event delegate reflection, including added coverage | ✅ | `ButtonEventDelegateReflectionSurfaces` `WidgetAdditionalEventDelegateReflectionSurfaces` |
| Animation playback reflection | 🟡 | `WidgetAnimationPlaybackReflectionSurfaces`, reflection surface only; see G7 |
| Focus and input mode reflection | 🟡 | `WidgetFocusAndInputModeReflectionSurfaces`, reflection surface only; see G7 |

---

**Corresponding test methods**: 24 methods.
**Enhancement pending (🟡)**: G7 — `WidgetAnimationPlaybackReflectionSurfaces` / `WidgetFocusAndInputModeReflectionSurfaces` currently assert only reflection surfaces, not runtime behavior such as animation advancement or actual focus transfer. Test whether headless can add runtime assertions; if not, keep the reflection ceiling, analogous to the networking ceiling.
**Boundary (🚫)**: runtime widget lookup through `GetWidgetFromName` is a fork boundary; see `../coverage-gaps.md §2.4`.
