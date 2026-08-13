## Context

`feature-as-stateful-tool-execution` plans stable memory-source compilation, retained sessions and Tool History without a product UI or tool catalogue. `feature-as-editor-tool-host-extensions` plans commands, explicit Editor context and dockable tabs whose v1 content is a reflected Details surface. `feature-as-editor-tool-workspace` plans one native scratch-source workspace. None of them promises arbitrary code-first widget construction, and this change must not merge those responsibilities.

The repository and local UE 5.8 installation contain three useful immediate-UI references:

- Epic's disabled-by-default Experimental `SlateIM` plugin, including a runtime `SlateIMBlueprint` function library with reflected roots, containers, controls, menus, tabs, graphs and canvas calls;
- Hazelight script examples that use fluent `FHazeImmediate*Handle` values to draw Editor viewport overlays; and
- the MIT-licensed `Reference/myas/EmmsUI` plugin, which reconciles a retained UMG widget tree from an immediate AngelScript draw function and supplies popup, viewport-overlay and Editor-tab hosts.

The user may instead choose an ImGui implementation later. The durable design problem is therefore the tool/UI lifecycle boundary, not choosing a widget library in this record-only revision.

### Decision status

| Topic | Status in this record |
|---|---|
| Keep execution, Editor host and workspace responsibilities separate | Fixed |
| User owns tool source, model state and reusable tool set | Fixed |
| Native host must contain draw-scope and script-failure cleanup | Fixed |
| Backend dependencies are optional and isolated from non-users | Fixed |
| SlateIM, ImGui, UMG/EmmsUI or plugin-owned facade | Open |
| Direct raw binding versus curated hosted API | Open |
| Editor-only first versus Editor + Runtime/InGame | Open |
| Backend-specific APIs versus a common widget facade | Open |
| Optional sibling plugin versus an existing-module adapter | Open |

## Goals / Non-Goals

**Goals:**

- Preserve enough verified evidence to make the later backend decision without repeating the initial repository and engine-source audit.
- Establish safety and ownership invariants that apply to any selected immediate-mode backend.
- Keep UI rendering replaceable without making the stateful runner or tool registry own a UI implementation.
- Define characterization work that can falsify a candidate before production code or dependency changes are authorized.
- Leave a future path for both Editor tools and separately opted-in Runtime/InGame tools.

**Non-Goals:**

- Select, enable, vendor or implement SlateIM, ImGui, EmmsUI or another backend now.
- Create a lowest-common-denominator widget DSL before backend semantics are understood.
- Expose `SWidget`, `TSharedPtr`, backend renderer objects or persistent native widget handles to AngelScript.
- Change the Details-based v1 contract in `feature-as-editor-tool-host-extensions`.
- Add a built-in tool collection, discover user files by convention or manage the user's accumulated tools.
- Put Editor UI, source history or scratch-workspace behavior in `AngelscriptRuntime`.
- Promise that Editor-only and Runtime/InGame UI use the same adapter or ship in the same milestone.

## Decisions

### 1. This remains a decision record until a backend is explicitly selected

The present proposal, research, requirements and tasks may be refined, but they authorize no production code, plugin descriptor or dependency change. Before implementation, the maintainer must select a primary backend, target scope, exposure model and dependency boundary, then rewrite candidate language into an implementation design.

Creating a generic facade immediately was rejected because SlateIM, ImGui and UMG differ in identity, input, docking, style, retained-object access and failure semantics. Selecting SlateIM merely because it is already in UE was also rejected: it is Experimental and its raw root API is not exception-safe for arbitrary script use.

### 2. Tool lifecycle is backend-neutral; widget APIs need not be

The shared host boundary is responsible for opening/closing a tool surface, retaining one user tool instance, scheduling draw callbacks, providing context, handling compatible hot reload and tearing down on close or shutdown. A selected adapter owns only the rendering backend and the translation from an AS-facing draw API to that backend.

No common `Button/Text/Table` facade is committed. A future `UScriptSlateIMTool` and `UScriptImGuiTool`, for example, may share host lifecycle while exposing different draw namespaces. A common facade remains an option only after real tools demonstrate a useful stable intersection.

### 3. The native host owns every unsafe draw boundary

The adapter opens a valid backend root/frame, invokes the latest compatible AngelScript draw callback, and closes or aborts the backend scope from native code on every return path. The script callback does not own a required root `Begin`/`End` pair.

For SlateIM this is essential: the local implementation maintains one global current root and uses `checkf` for nested roots, missing roots and roots left active at post-tick. `EndRoot()` resets container/menu stacks, so a native finally/RAII path can contain a script exception. Characterization must prove the actual AngelScript dispatch path returns control to that guard.

Container Begin/End APIs may still be visible inside a draw callback, but the adapter must recover at the root boundary when they are unbalanced. Any backend that cannot recover from an interrupted draw is ineligible for untrusted user-authored tool callbacks without an additional isolation mechanism.

### 4. Persistent state belongs to the user tool object; UI references are frame-scoped

Search text, filters, selected data, operation configuration and other durable model state live in reflected fields on the user-owned tool/session object or another explicit user-owned object. Backend state such as focus, scroll offset, popup openness and retained widget caches belongs to the adapter.

Script-visible builder values or handles are non-owning frame capabilities. They must not be serializable, reflected as persistent properties, retained across Tick, used from async callbacks or trusted after hot reload. The host may validate a frame/generation token when a backend uses handle values.

This separation permits the tool object to be reinstanced while the backend either preserves compatible visual state or deliberately recreates it without retaining stale script/native references.

### 5. Backend dependencies remain optional integration boundaries

The stateful runner and users of the existing Details host must not acquire a required SlateIM, ImGui or EmmsUI dependency. If SlateIM is selected, the leading candidate is a disabled-by-default sibling integration plugin analogous to the repository's optional GameplayTags/GAS plugins. It could depend on `Angelscript` and Epic's `SlateIM` plugin and declare separate Runtime and Editor modules only for scopes that are actually approved.

Adding SlateIM directly to `Angelscript.uplugin` or `AngelscriptRuntime.Build.cs` was rejected as the default because it would make an Experimental UI backend part of every consumer's build and load surface. A narrow existing-Editor-module adapter remains an open alternative only if UE version availability and optional plugin loading can be preserved without a core dependency.

An ImGui candidate must name and pin the actual integration source, license, renderer/input bridge and supported UE versions before it becomes comparable to the in-engine SlateIM candidate. `Reference/myas/EmmsUI` is research source, not an implicit production dependency.

### 6. Raw reflected SlateIM exposure is a spike question, not an assumed API

`USlateIMBlueprintFunctionLibrary` is `BlueprintType` and its functions are `BlueprintCallable`. SlateIM modules load at `Default`, while Angelscript modules load at `PostDefault`; the current reflective binding scan is therefore expected to see the class when the plugin is enabled. The exact AS namespace, supported parameter types and call route are not yet runtime-verified.

Enabling the plugin may expose raw `BeginWindowRoot`/`EndRoot` along with safe control calls, bypassing a hosted adapter. A SlateIM implementation decision must choose and prove one of these policies:

1. deliberately expose the official raw API as an advanced unsafe surface while providing a safe host;
2. exclude the raw function library and manually expose a curated AS namespace; or
3. change the binding/filter boundary so root functions are unavailable to ordinary script while supported controls remain visible.

The record does not assume that depending only on the `SlateIM` module prevents `SlateIMBlueprint` from loading, because the engine plugin descriptor declares all four runtime modules.

### 7. Editor and Runtime/InGame delivery are independent decisions

The first use case is Editor tooling, but SlateIM and ImGui can also support Runtime/InGame debugging. An adapter must declare its target scope. Editor-only registration, context and dock tabs remain excluded from non-Editor targets. A Runtime adapter must separately define owning player/viewport, networking/authority behavior, Shipping policy, input capture and platform packaging.

No Runtime dependency is justified merely by a possible future use. Conversely, selecting an Editor-only first milestone must not encode an API shape that makes a later optional Runtime adapter impossible.

## Candidate Architecture

```text
User-owned AS tool model and operations
        |
        v
Shared tool host lifecycle
  open / close / instance / context / reload / error boundary
        |
        +---------------------+----------------------+------------------+
        v                     v                      v                  v
 Details adapter       SlateIM adapter         ImGui adapter      UMG adapter
 (existing v1)         (candidate)             (candidate)        (candidate)
```

The runner may compile or execute a temporary/full-source class, but it does not draw its UI. The Editor host may discover or open a compatible tool surface, but it does not own user source or build a catalogue. The adapter invokes a draw callback on the current tool instance and never persists source/history itself.

## Hot Reload and Lifecycle Model

1. A physical tab/window/overlay owns one native adapter session and one reflected user tool instance.
2. The adapter derives a stable UI identity from the host surface identity, not a timestamp, pointer or compile generation.
3. Each eligible frame opens the backend scope and invokes the currently resolved draw callback on the Game Thread.
4. Compatible AngelScript class reinstancing updates the reflected owner reference; the next frame invokes the replacement object/function.
5. Frame-scoped handles from the prior call are invalid regardless of whether the backend cache survives.
6. A removed or incompatible class stops drawing, performs best-effort deinitialization, closes or marks the surface unavailable and emits one bounded diagnostic.
7. A missed frame must have defined backend behavior. SlateIM characterization must determine whether its root is removed/closed and whether the host must explicitly recreate or reopen it after reload.

## Error Handling

- Backend unavailable, headless/commandlet execution or missing renderer/input initialization returns a structured unavailable result; it must not construct a partial tool instance.
- A script exception is reported through the existing AngelScript exception path, after which the native host closes/aborts the draw scope and suppresses recursive drawing until the next defined recovery point.
- Duplicate stable root/surface IDs are rejected deterministically rather than relying on registration or tick order.
- Unbalanced child containers are cleaned at the native root boundary when the backend supports recovery; otherwise the adapter disables the surface and reports the unsupported failure mode.
- Long-running draw callbacks remain Game-Thread work and require a documented per-frame budget. The UI adapter is not an asynchronous execution or cancellation system.

## Risks / Trade-offs

- **[Risk: SlateIM is Experimental and can change across UE releases.]** → Keep it optional, version-gate the adapter and use compile/runtime characterization against every supported UE baseline.
- **[Risk: automatically reflected SlateIM roots bypass native cleanup.]** → Make raw-exposure policy a blocking decision and add an exception-after-Begin regression before production adoption.
- **[Risk: immediate widget identity changes when script order changes.]** → Characterize insertion/removal, focus, text editing, selection and scroll behavior; document stable IDs where the selected backend supports them.
- **[Risk: a universal facade loses backend capabilities or becomes another UI framework.]** → Do not create it until concrete tools prove the shared subset and migration value.
- **[Risk: backend-native handles survive in script state.]** → Use frame/generation validation and make handle types non-reflected/non-serializable.
- **[Risk: hot reload skips a draw frame and closes backend roots.]** → Characterize reload timing and let the native session recreate the backend surface from stable identity.
- **[Risk: Runtime UI expands Editor tooling into Shipping/debug policy.]** → Treat Runtime/InGame as a separate opt-in scope with explicit platform, input, authority and Shipping requirements.
- **[Risk: third-party integration provenance is unclear.]** → Require pinned source, license review and notices before selecting an ImGui or copied EmmsUI implementation.

## Migration Plan

There is no migration in this record-only revision. After a backend is selected:

1. revise this design/spec to replace candidate language with the selected delivery shape;
2. run the backend-specific characterization spike without modifying the existing tool OpenSpecs;
3. decide whether the adapter is a sibling plugin or an existing-module extension;
4. add tests and implementation behind an opt-in dependency;
5. only then add a delta to `feature-as-editor-tool-host-extensions` if its public tab-content contract must accept the new adapter;
6. retain the Details host as the compatibility path and disable/remove the optional adapter to roll back.

## Open Questions

1. Which primary backend is selected: SlateIM, ImGui, UMG/EmmsUI or a plugin-owned facade?
2. Is the first milestone Editor-only, or must it also support Runtime/InGame debugging?
3. If SlateIM is selected, can raw reflected roots be excluded cleanly without changing unrelated binding behavior?
4. Should scripts derive from a backend-specific tool base or receive a backend-specific frame/context value from a more general host base?
5. Does the selected backend provide stable explicit widget IDs, or is positional identity acceptable for v1?
6. Which visual state must survive compatible hot reload: window/tab, focus, scroll, open tree rows, popup state and text edit composition?
7. What per-frame draw budget and throttling policy is required for inactive or background tabs?
8. What source/provenance and renderer/input integration would be used for an ImGui candidate?
