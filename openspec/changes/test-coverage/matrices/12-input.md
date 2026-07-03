# Input System Coverage Matrix, Legacy Input + Enhanced Input

> **This matrix is the design specification header for input tests**: each row is a concrete verifiable scenario guiding `AngelscriptCoverageInputTests.cpp` implementation. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, 🟡 means partial coverage such as reflection ceiling or subset coverage, and 🚫 means fork/headless unsupported.
>
> - Test file: `AngelscriptCoverageInputTests.cpp`, 22 methods
> - Automation prefix: `Angelscript.TestModule.Coverage.Input`
> - See `../coverage-matrix.md` for the legend.

## 1. Legacy Input Bindings

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| SetupPlayerInputComponent initialization | ✅ | `SetupPlayerInputComponent` |
| Action / Axis / direct key binding | ✅ | `ActionBinding` `AxisBinding` `KeyDirectBinding` |
| Binding collections visible after setup / advanced binding collections | ✅ | `InputBindingCollectionsVisibleAfterSetup` `AdvancedInputComponentBindingCollections` |
| Input component finding | ✅ | `InputComponentFinding` |
| Binding priority and consume semantics, Block / Override / DontBlock / bConsumeInput / bExecuteWhenPaused | ⬜ | Pending G25: `bConsumeInput` default parameter is exposed on `BindKey` mixin and `bExecuteWhenPaused` is exposed on `BindDebugKey`, but runtime behavior, consume/pass-through and paused execution, plus `InputComponent.Priority` / Block / Override / DontBlock reflected or behavioral input-component chain effects are not asserted |

## 2. Input State And Devices

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Input state query | ✅ | `InputStateQuery` |
| Keyboard / mouse / gamepad | ✅ | `KeyboardKeys` `MouseInput` `GamepadInput` |
| PlayerController device APIs, GetMousePosition / GetInputMotionState / GetInputAnalogKeyState / GetInputKeyTimeDown | ⬜ | Pending G26: `InputStateQuery` only reaches compile failure with `GetInputAxisValue`; `GetMousePosition`, `GetInputMotionState`, and `GetInputAnalogKeyState` have zero fork bindings by grep, so add independent compile-failure boundaries to lock the AS reflection ceiling |
| Multiple players, second gamepad / split-screen PlayerController | ⬜ | Pending G27: all methods construct only one PlayerController; multi-player input routing, CreatePlayer / GetPlayerControllerFromID / second gamepad InputComponent isolation, is not asserted through reflection or behavior |

## 3. Input Mode / Cursor / Feedback

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Input mode control, SetShowMouseCursor boundary | ✅ | `InputModeControl` |
| Input mode switching unsupported boundary | 🚫 | `InputModeSwitchingUnsupportedBoundary` |
| Cursor type / click / hover events, SetMouseCursor / bEnableClickEvents / bEnableMouseOverEvents | ⬜ | Pending G28: zero grep bindings; `InputModeControl` covers only `SetShowMouseCursor`, so other cursor APIs need independent compile-failure boundaries |
| Force Feedback / Haptic, ClientPlayForceFeedback / SetHapticsByValue and related APIs | ⬜ | Pending G29: APlayerController feedback APIs have zero fork bindings by grep and need compile-failure boundaries |

## 4. Enhanced Input, UE5

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| MappingContext and ActionValue, Bool / Axis1D / Axis2D / Axis3D / ConvertToType | ✅ | `EnhancedInputMappingContextAndActionValues` `EnhancedInputRuntimeMappingContextMatrix` |
| Component binding events and removal / binding handles and removal | 🟡 | `EnhancedInputComponentBindingEventsAndRemoval` `EnhancedInputBindingHandlesAndRemoval`, G20: all five ETriggerEvents, Started/Ongoing/Triggered/Completed/Canceled, are compile-reachable through BindAction, but `GetTriggerEvent()` reflection assertions cover only Started+Triggered; Ongoing/Completed/Canceled need independent reflection-preservation assertions |
| Modifier and Trigger, Add+Count | 🟡 | `EnhancedInputModifiersAndTriggers`, G21: only asserts `AddModifier`/`AddTrigger` plus `GetModifierCount`/`GetTriggerCount`; missing `ModifyRaw` / `UpdateState` behavior or reflection assertions. Modifier subset covers only DeadZone/Negate/Scalar/Smooth/ResponseCurveExponential, not Swizzle/FOVScaling. Trigger subset covers Down/Pressed/Released/Hold/Tap/Pulse/Combo, not ChordedAction, which is distinct from Combo |
| Full Modifier set, Swizzle / FOVScaling and related modifiers | 🟡 | `EnhancedInputRuntimeMappingContextMatrix`, G22: Swizzle is now covered through runtime mapping-context construction; `UInputModifierFOVScaling` still has zero fork grep references, so it needs a compile-failure boundary before this row can close |
| Full Trigger set, ChordedAction distinct from Combo | ⬜ | Pending G23: `UInputTriggerChordAction` has zero fork grep references; use compile-failure boundary or reflection assertion to lock exposure state. `UInputTriggerCombo` is covered, but ChordAction and Combo are distinct classes |
| Action and Mapping metadata | ✅ | `EnhancedInputActionAndMappingMetadata` |
| Input settings and runtime mapping API | ✅ | `InputSettingsAndRuntimeMappingApi` |
| EnhancedInputUserSettings / PlayerMappableKeyProfile | ⬜ | Pending G24: zero grep references; AS exposure state for the UE5 PlayerMappable Key Settings subsystem is unknown, so add compile-failure boundaries to lock the reflection ceiling |

## 5. Touch / Gesture

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Touch state query surface | ✅ | `TouchStateQuerySurface` |
| Touch/gesture API boundary | 🚫 | `TouchAndGestureApiBoundaries` |

---

**Corresponding test methods**: 22 methods.

**Pending (⬜)**:
- G20 full EnhancedInput ETriggerEvent coverage, missing `GetTriggerEvent()` reflection-preservation assertions for Ongoing/Completed/Canceled
- G21 Modifier/Trigger application behavior, `ModifyRaw`/`UpdateState` reflection or behavior; currently Add+Count only
- G22 FOVScaling Modifier reflection ceiling; Swizzle is covered by `EnhancedInputRuntimeMappingContextMatrix`
- G23 ChordedAction Trigger, distinct from Combo, reflection or boundary
- G24 EnhancedInputUserSettings / PlayerMappableKeyProfile compile-failure boundary
- G25 legacy InputComponent priority, Block/Override/DontBlock, plus bConsumeInput / bExecuteWhenPaused runtime behavior or reflection
- G26 PlayerController device APIs, GetMousePosition / GetInputMotionState / GetInputAnalogKeyState / GetInputKeyTimeDown, independent compile-failure boundaries
- G27 multi-player, second gamepad / split-screen PlayerController input routing
- G28 cursor type / click event / hover event, SetMouseCursor / bEnableClickEvents / bEnableMouseOverEvents compile-failure boundaries
- G29 Force Feedback / Haptic, ClientPlayForceFeedback / SetHapticsByValue and related APIs, compile-failure boundaries

**True saturation level**: the current 21 methods cover MappingContext/ActionValue across all four ValueTypes, compile reachability for five ETriggerEvents, Add+Count subsets for Modifier/Trigger, and `GetTriggerEvent` only for Started+Triggered. In headless mode, actual input triggering and handler count round trips are not reachable because they depend on SlateApplication and EnhancedInputSubsystem real-time ticks; those are recorded as 🚫 boundaries through `InputModeSwitchingUnsupportedBoundary` / `TouchAndGestureApiBoundaries`. This downgrade is concentrated on capability surfaces that are reachable at the reflection ceiling but not yet asserted, G20/G21, plus PlayerController/feedback/cursor/UserSettings APIs with zero grep bindings but missing independent compile-failure boundaries, G24/G26/G28/G29. The Touch Pressed/Moved/Released state machine continues under the 🚫 record in `TouchAndGestureApiBoundaries` and does not need a separate row.
