# Immediate Tool UI Backend Research

> Status: record-only / decision pending
> Date: 2026-08-13
> Production changes made by this research: none

## 1. Research Question

Can user-owned AngelScript editor tools draw code-first windows, dock tabs, viewport overlays and controls without coupling the tool runner or core plugin to one UI implementation? In particular, can Epic SlateIM be exposed safely to AS, while preserving the option to use ImGui, UMG or another backend later?

This record separates **observed facts**, **inferences requiring a smoke test**, **candidate directions** and **unresolved decisions**.

## 2. Existing OpenSpec Boundaries

| Change | Existing responsibility | UI consequence |
|---|---|---|
| `feature-as-stateful-tool-execution` | stable memory source, compile/run, retained session and Tool History | deliberately owns no UI, catalogue or discovery scan |
| `feature-as-editor-tool-host-extensions` | Editor context, dynamic commands and one transient object per dock tab | v1 uses Details + explicit zero-parameter `CallInEditor` actions and rejects arbitrary Slate |
| `feature-as-editor-tool-workspace` | one official scratch source editor, draft recovery, compile/run/history/export | native UI is a consumer of the runner, not the general host for project tools |

The UI backend decision belongs in a separate change. A future selected adapter may require a narrow delta to the host-extension spec, but no current requirement must be rewritten during research.

## 3. Confirmed SlateIM Evidence

### 3.1 Availability and module shape

The configured local engine is `C:/Program Files/Epic Games/UE_5.8`. It contains:

```text
Engine/Plugins/Experimental/SlateIM/SlateIM.uplugin
```

The descriptor states:

- `FriendlyName`: `SlateIM`
- `Description`: immediate-mode wrapper for Slate intended for debugging tools
- `IsExperimentalVersion`: `true`
- `EnabledByDefault`: `false`
- Runtime modules: `SlateIM`, `SlateIMEngine`, `SlateIMInGame`, `SlateIMBlueprint`

Epic's public UE 5.7 and 5.8 API pages also list the plugin. This is engine-distributed source governed by the Unreal Engine distribution/license boundary; it is not a separate repository dependency to copy into this project.

### 3.2 Reflected Blueprint surface

`Source/SlateIMBlueprint/Public/SlateIMBlueprintFunctionLibrary.h` defines `USlateIMBlueprintFunctionLibrary` as `UCLASS(BlueprintType)` and exposes reflected functions for:

- window and viewport roots;
- horizontal/vertical stacks and wraps;
- tables, borders, scroll boxes and popups;
- slot alignment, padding and sizing;
- text, editable text and images;
- buttons, checkboxes, spin boxes, sliders, progress bars, combo boxes and selection lists;
- menus, internal tabs, modal dialogs, hover/focus queries and input state;
- graphs and engine canvas drawing.

`Source/SlateIM/Public/SlateIMParameters.h` supplies `BlueprintType` wrapper structs for the public parameter sets, including in/out primitive state supported by buttons and editable controls.

### 3.3 Root and retained-tree behavior

Local `FSlateIMManager` source confirms:

- a single `CurrentRoot` is active globally while one hierarchy is built;
- `BeginRoot` resets container/menu stacks and current widget index;
- beginning a second root while one is active uses `checkf`;
- `EndRoot` without an active root uses `checkf`;
- post-tick uses `checkf` if a root remains active;
- `EndRoot` clears the container/menu stacks, removes unused widget hashes and clears `CurrentRoot`;
- roots not activated on subsequent ticks are removed;
- retained Slate children and data/alignment hashes are updated by positional traversal.

`FSlateIMWidgetBase` uses `FSlateApplication::OnPreTick` to call a draw function. `FSlateIMNomadTabBase` and `FSlateIMExposedBase` use `BeginExposedRoot` to put the resulting widget into an existing Slate hierarchy. This is the most relevant native pattern for an AngelScript tool-host tab.

### 3.4 AngelScript binding inference — not yet runtime verified

The current AngelScript reflective binding path captures native `BlueprintType` classes and binds `BlueprintCallable` functions when all parameter types are supported. SlateIM loads at `Default`; Angelscript modules load at `PostDefault`. Therefore, when SlateIM is enabled, the reflected function library is expected to be present before AS type binding.

Unverified details:

- exact generated AS namespace (`SlateIMBlueprintFunctionLibrary` or another name);
- whether every parameter wrapper and Canvas type is accepted;
- direct/generated binding versus `BlueprintCallableReflectiveFallback`;
- correct writeback for every `UPARAM(Ref)` value;
- whether the current bind database/cook path retains the optional surface;
- whether raw root calls become visible automatically and can be selectively excluded.

No `.uproject` change or Editor smoke test was performed in this record-only session.

### 3.5 SlateIM safety implication

Direct script ownership of `BeginWindowRoot`/`EndRoot` is unsafe when a script callback throws or exits before its matching call. A native host should own the root and invoke AS only inside it. The characterization spike must deliberately throw after the root begins and prove that the next Slate tick does not assert and that the surface can draw again.

## 4. Confirmed EmmsUI Evidence

The local research tree is:

```text
Reference/myas/EmmsUI/
```

Its `LICENSE` is MIT, copyright Hazelight 2025. Its README describes an immediate AngelScript API over a retained UMG widget tree. Important implementation details observed locally:

- `UMMWidget` owns maps of available/pending widgets and reuses widgets by type, parent and an optional hash identifier;
- each draw swaps pending/active trees and removes widgets not used during the frame;
- reflected widget/slot attributes track current and pending values and reset removed properties;
- editable helper calls write values back into script variables;
- `UMMPopupWindow` wraps an `SWindow` and strongly retains its UObject until close;
- `UMMEditorUtilityTab` wraps an `SDockTab`, owns a transient `UMMWidget`, and calls script `DrawTab` every tick;
- the Editor module rescans script-derived tab/customization classes after full reload and re-registers changed tab spawners;
- its Runtime module depends on the older upstream `AngelscriptCode` module name, so it is a reference rather than a drop-in dependency for this repository.

Strengths to borrow:

- retained widget reconciliation avoids destroying text focus and control state every frame;
- user model state remains ordinary script fields;
- hybrid UMG and immediate content is possible;
- popup, overlay, tab and Details customization hosts are demonstrated.

Risks to avoid or characterize:

- global implicit hierarchy and matched Begin/End requirements;
- broad reflection-driven wrapper generation/maintenance;
- UMG overhead and Editor style mismatch for dense native tools;
- old AngelScript module/API assumptions;
- importing a full dependency when only a small host contract is needed.

## 5. Confirmed Hazelight Immediate-Handle Evidence

Local Split Fiction script examples use fluent, temporary handles:

```angelscript
auto Overlay = GetEditorViewportOverlay();
auto Canvas = Overlay.BeginCanvasPanel();
auto ButtonBar = Canvas
    .SlotAnchors(0.5, 0.0)
    .SlotAlignment(0.5, 0.0)
    .SlotAutoSize(true)
    .HorizontalBox();

auto TestButton = ButtonBar.Button("Test Button").Padding(6);
if (TestButton.WasClicked())
    Print("Button clicked");
```

Evidence paths include:

- `Reference/myas/Split Fiction Script/Examples/Editor/Example_EditorSubsystemInput.as`
- `Reference/myas/Split Fiction Script/Core/Prefab/PrefabEditorSubsystem.as`
- `Reference/myas/Split Fiction Script/GUI/Debug/CapabilityDevMenu/CapabilityDevMenu.as`

The native implementation is not present in the reference tree, so this is API-shape evidence only. The fluent style is expressive, but any similar handle must be frame-scoped and generation-validated to prevent storage across Tick/hot reload.

## 6. Candidate Comparison

| Candidate | Advantages | Main risks/costs | Best-fit use |
|---|---|---|---|
| Epic SlateIM | already in supported UE 5.7/5.8; native Slate appearance/input; reflected Blueprint wrappers; tables/tabs/graphs/canvas; Editor and Runtime roots | Experimental; disabled by default; global root/checkf failure behavior; positional identity; UE-version drift; raw roots may auto-bind | native-feeling debug/editor tools when optional dependency is acceptable |
| ImGui integration | established immediate-mode authoring model; dense debug tooling; mature IDs/docking/tables in Dear ImGui itself; renderer-independent core | must select a concrete Unreal integration; renderer/input/multi-viewport/packaging work; non-native Editor styling; provenance/version/license review; no current project dependency | dense debug/profiling/runtime tools where native UE appearance is secondary |
| UMG/EmmsUI-style reconciliation | all reflected UMG properties; hybrid Widget Blueprint/code UI; UObject/GC-friendly state; local MIT reference | large adapter/reflection surface; UMG cost and native Editor density/style; older AS integration assumptions; Begin/End recovery | hybrid Editor/runtime UI and project-facing visual tools |
| Plugin-owned generic facade | backend replacement and curated safe calls; can hide unsafe roots | becomes a new UI framework; lowest-common-denominator API; duplicates backend features; long-term maintenance | only after real tools prove a stable shared subset |
| Existing Details + actions | already planned; native metadata/property editing; minimal API and failure surface | insufficient for dynamic tables, previews, custom layout or viewport overlays | configuration-heavy fixed tools; remains the baseline/fallback |

No candidate is selected by this table.

## 7. Recommended Architecture Invariants

These recommendations are independent of backend selection:

1. Share tool/session lifecycle, not necessarily widget calls.
2. Keep the backend dependency optional and outside the stateful runner.
3. Let the native adapter own root/frame Begin/End and exception cleanup.
4. Keep model state in the user tool UObject; keep focus/scroll/cache state in the adapter.
5. Treat builder handles as frame-scoped capabilities, never persistent UObject properties.
6. Use stable logical surface IDs, not pointer, timestamp or compile-generation IDs.
7. Re-resolve the script draw callback after compatible hot reload.
8. Keep Editor-only registration inert in commandlets/headless processes.
9. Decide Runtime/InGame policy separately rather than leaking Editor dependencies into Runtime.
10. Do not add, discover or manage a user tool collection; the plugin supplies hosting/execution only.

## 8. Exposure Models to Decide

### A. Raw backend API plus a safe host

Expose the backend's reflected API and document direct roots as advanced/unsafe. This is the smallest integration but cannot prevent user code from bypassing lifecycle cleanup.

### B. Curated backend-specific adapter

Expose `SlateIM::Text/Button/...` or `ImGui::...` through an integration module while the host supplies the root. This provides the cleanest safety and naming surface, but SlateIM must first prove that the official Blueprint library can be excluded or coexist without ambiguity.

### C. Common plugin-owned facade

Expose `ImmediateUI::...` and map it to a selected backend. This is only justified if portability between backends is an actual product requirement and the common subset is large enough. It is not the default recommendation at the research stage.

## 9. Candidate Module Shapes

### Optional sibling plugin (leading isolation candidate)

```text
Plugins/AngelscriptImmediateUI/ or Plugins/AngelscriptSlateIM/
  Runtime module only if Runtime/InGame is selected
  Editor module for tabs/viewport/editor context
  Test module
  plugin dependencies: Angelscript + selected backend
  EnabledByDefault: false
```

This follows the optional GameplayTags/GAS pattern and leaves the core plugin reusable without the backend.

### Existing AngelscriptEditor module

This has fewer plugins to distribute but is acceptable only if the backend remains dynamically/optionally available across supported UE installations. A hard `SlateIM` Build.cs/uplugin dependency would make every Angelscript consumer inherit an Experimental plugin and is therefore not the default.

### Core Runtime integration

Rejected as a default. It can be reconsidered only if Runtime/InGame becomes a selected first-class requirement and the dependency remains optional for non-users.

## 10. Required Characterization Before Selection

### Candidate-neutral checks

- define two representative tools: a small property/action tab and a dynamic table/filter/preview tool;
- define expected Editor hot-reload behavior for model fields, focus, scroll, selection and open tab/window;
- measure inactive/active draw scheduling and Game-Thread cost;
- prove headless/commandlet paths are inert;
- prove script exceptions and unbalanced child scopes do not poison later frames;
- define plugin disable/removal behavior and dependency diagnostics.

### SlateIM spike

1. Enable SlateIM only in a disposable/explicitly authorized configuration.
2. Dump or inspect generated AS declarations for the Blueprint library and parameter structs.
3. Compile calls covering `Text`, `Button`, `EditableText`, `CheckBox`, `SpinBox`, `ComboBox`, table and `BeginExposedRoot` hosting.
4. Verify every in/out value and determine the direct/reflection-fallback route.
5. Throw from AS after native root begin and after child-container begin; verify cleanup and next-frame recovery.
6. Insert/remove/reorder controls while editing text; observe focus, scroll and activation identity.
7. Full/soft reload an open dock tab and a floating window; observe missed-frame/root recreation behavior.
8. Determine whether raw root functions auto-bind and how a curated adapter could exclude them.
9. Build against every supported UE baseline where SlateIM is expected.

### ImGui spike

1. Select one concrete Unreal integration and record repository, exact revision, license and UE compatibility.
2. Prove renderer/input startup and shutdown in Editor, PIE and the selected Runtime targets.
3. Define namespace/type bindings without exposing renderer pointers.
4. Verify docking/multi-viewport policy, DPI, keyboard focus and coexistence with Slate input.
5. Prove hot reload and exception cleanup at the native frame boundary.
6. Measure packaging size and Shipping/debug enablement policy.

### UMG/EmmsUI spike

1. Decide whether to adapt concepts or source; if source, complete provenance and module/API migration review.
2. Characterize widget reuse, focus, property reset, dynamic list cost and GC.
3. Prove Editor tab styling and hybrid Widget Blueprint embedding.
4. Replace the global implicit hierarchy or prove exception-safe cleanup.

## 11. Decision Criteria

The maintainer should record a backend decision only after scoring the actual spikes against:

- Editor-native UX and styling;
- Runtime/InGame need;
- hot-reload continuity;
- exception/failure containment;
- AS API ergonomics;
- control coverage, especially tables/tree/preview/canvas;
- stable widget identity and input focus;
- dependency/license/provenance cost;
- UE version maintenance burden;
- build/package/runtime overhead;
- ability to remain optional;
- testability in automation/headless environments.

## 12. Decision Log

| Date | Decision | Status |
|---|---|---|
| 2026-08-13 | Record SlateIM, ImGui, UMG/EmmsUI and plugin-owned facade as candidates | Recorded |
| 2026-08-13 | Do not select or enable a backend in this session | Recorded |
| 2026-08-13 | Keep execution, host and workspace OpenSpecs unchanged | Recorded |
| 2026-08-13 | Require native ownership of unsafe draw/root lifetime | Recorded |
| — | Select primary backend | Pending maintainer decision |
| — | Select Editor-only versus Editor + Runtime/InGame scope | Pending maintainer decision |
| — | Select raw, curated backend-specific or common facade exposure | Pending maintainer decision |
| — | Select sibling-plugin versus existing-module delivery | Pending maintainer decision |

## 13. Evidence Index

Official engine documentation:

- UE 5.8 SlateIM plugin index: <https://dev.epicgames.com/documentation/unreal-engine/API/PluginIndex/SlateIM?lang=en-US>
- UE 5.7 SlateIM API index: <https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/SlateIM>

Local UE 5.8 source inspected:

- `C:/Program Files/Epic Games/UE_5.8/Engine/Plugins/Experimental/SlateIM/SlateIM.uplugin`
- `Source/SlateIM/Public/SlateIM.h`
- `Source/SlateIM/Public/SlateIMParameters.h`
- `Source/SlateIM/Public/SlateIMWidgetBase.h`
- `Source/SlateIM/Private/Misc/SlateIMManager.cpp`
- `Source/SlateIM/Private/Implementation/SlateIM_Roots.cpp`
- `Source/SlateIMBlueprint/Public/SlateIMBlueprintFunctionLibrary.h`
- `Source/SlateIMInGame/Public/SlateIMInGameWidgetBase.h`

Repository references inspected:

- `Reference/myas/EmmsUI/README.md`
- `Reference/myas/EmmsUI/LICENSE`
- `Reference/myas/EmmsUI/Source/EmmsUI/Private/MMWidget.cpp`
- `Reference/myas/EmmsUI/Source/EmmsUI/Private/EmmsStatics.cpp`
- `Reference/myas/EmmsUI/Source/EmmsUIEditor/Private/MMEditorUtilityTab.cpp`
- `Reference/myas/EmmsUI/Source/EmmsUIEditor/Private/EmmsUIEditorModule.cpp`
- `Reference/myas/Split Fiction Script/Examples/Editor/Example_EditorSubsystemInput.as`
- `Reference/myas/Split Fiction Script/Core/Prefab/PrefabEditorSubsystem.as`
- `Reference/myas/Split Fiction Script/GUI/Debug/CapabilityDevMenu/CapabilityDevMenu.as`

Current AngelScript binding/host evidence inspected:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`
- `Plugins/Angelscript/Angelscript.uplugin`
- `Plugins/AngelscriptGameplayTags/AngelscriptGameplayTags.uplugin`
