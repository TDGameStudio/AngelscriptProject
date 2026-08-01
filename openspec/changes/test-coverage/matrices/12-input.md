# Input System Coverage Matrix, Legacy Input + Enhanced Input

> **This matrix is the design specification header for input tests**: each row is a concrete verifiable scenario guiding `AngelscriptCoverageInputTests.cpp` implementation. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, 🟡 means partial coverage such as reflection ceiling or subset coverage, and 🚫 means fork/headless unsupported.
>
> - Test file: `AngelscriptCoverageInputTests.cpp`, 25 methods
> - Automation prefix: `Angelscript.TestModule.Coverage.Input`
> - See `../coverage-matrix.md` for the legend.

## 1. Legacy Input Bindings

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| SetupPlayerInputComponent initialization | ✅ | `SetupPlayerInputComponent` |
| Action / Axis / direct key binding | ✅ | `ActionBinding` `AxisBinding` `KeyDirectBinding` |
| Binding collections visible after setup / advanced binding collections | ✅ | `InputBindingCollectionsVisibleAfterSetup` `AdvancedInputComponentBindingCollections` |
| Input component finding | ✅ | `InputComponentFinding` |
| Binding priority and consume semantics, Block / Override / DontBlock / bConsumeInput / bExecuteWhenPaused | ✅ | `LegacyInputPriorityAndConsumeSurface` observes InputComponent priority/block state, both bConsumeInput variants, and bExecuteWhenPaused |

## 2. Input State And Devices

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Input state query, including key hold time | ✅ | `InputStateQuery` |
| Keyboard / mouse / gamepad | ✅ | `KeyboardKeys` `MouseInput` `GamepadInput` |
| PlayerController device APIs, GetMousePosition / GetInputMotionState / GetInputAnalogKeyState | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records the current unbound device API surface; `GetInputKeyTimeDown` is already compiled in `InputStateQuery` |
| Multiple players, second gamepad / split-screen PlayerController | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records CreatePlayer / GetPlayerControllerFromID as the current unsupported routing boundary |

## 3. Input Mode / Cursor / Feedback

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Input mode control, SetShowMouseCursor boundary | ✅ | `InputModeControl` |
| Input mode switching unsupported boundary | 🚫 | `InputModeSwitchingUnsupportedBoundary` |
| Cursor type / click / hover events, SetMouseCursor / bEnableClickEvents / bEnableMouseOverEvents | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records the current cursor/click/hover boundary; `InputModeControl` still covers SetShowMouseCursor |
| Force Feedback / Haptic, ClientPlayForceFeedback / SetHapticsByValue and related APIs | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records the current APlayerController feedback boundary |

## 4. Enhanced Input, UE5

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| MappingContext and ActionValue, Bool / Axis1D / Axis2D / Axis3D / ConvertToType | ✅ | `EnhancedInputMappingContextAndActionValues` `EnhancedInputRuntimeMappingContextMatrix` |
| Component binding events and removal / binding handles and removal | ✅ | `EnhancedInputComponentBindingEventsAndRemoval` `EnhancedInputBindingHandlesAndRemoval` `EnhancedInputTriggerEventReflectionPreservation`, covering all five ETriggerEvents and native GetTriggerEvent preservation |
| Modifier and Trigger, Add+Count | 🟡 | `EnhancedInputModifiersAndTriggers` covers Add+Count; `EnhancedInputAndDeviceBoundaryInventory` records ModifyRaw/UpdateState as unbound. Modifier subset covers DeadZone/Negate/Scalar/Smooth/ResponseCurveExponential plus Swizzle; Trigger subset covers Down/Pressed/Released/Hold/Tap/Pulse/Combo |
| Full Modifier set, FOVScaling and related modifiers | 🟡 | `EnhancedInputRuntimeMappingContextMatrix` constructs and verifies Swizzle; `EnhancedInputAndDeviceBoundaryInventory` proves `UInputModifierFOVScaling` is compile-exposed |
| Full Trigger set, ChordedAction distinct from Combo | ✅ | `EnhancedInputAndDeviceBoundaryInventory` creates `UInputTriggerChordAction` and round-trips `ChordAction`; `UInputTriggerCombo` remains covered |
| Action and Mapping metadata | ✅ | `EnhancedInputActionAndMappingMetadata` |
| Input settings and runtime mapping API | ✅ | `InputSettingsAndRuntimeMappingApi` |
| EnhancedInputUserSettings / PlayerMappableKeyProfile | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records the current UserSettings/Profile boundary |

## 5. Touch / Gesture

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Touch state query surface | ✅ | `TouchStateQuerySurface` |
| Touch/gesture API boundary | 🚫 | `TouchAndGestureApiBoundaries` |

---

**Corresponding test methods**: 25 methods.

**Implementation status**: G20, G23, and G25 have runtime/reflection assertions. G22 proves FOVScaling type exposure. G21/G24 and G26-G29 retain explicit unsupported-boundary inventory. The full Input prefix passed 25/25 on 2026-08-01.

**True saturation level**: the current 25 methods cover MappingContext/ActionValue across all four ValueTypes, input key hold time, all five ETriggerEvents, Add+Count subsets for Modifier/Trigger, FOVScaling type exposure, ChordAction property semantics, native GetTriggerEvent preservation, legacy input policy fields, and explicit boundaries for the currently unbound Enhanced Input/device/cursor/feedback surfaces. In headless mode, actual input triggering and handler count round trips remain outside scope because they depend on SlateApplication and EnhancedInputSubsystem real-time ticks; those continue under the existing 🚫 boundaries. The complete prefix passed 25/25 on 2026-08-01.
