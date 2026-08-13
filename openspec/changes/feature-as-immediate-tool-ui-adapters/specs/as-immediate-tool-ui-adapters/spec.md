## ADDED Requirements

### Requirement: Production backend selection is explicit
The change SHALL remain record-only and SHALL NOT enable, vendor, expose or implement a production immediate-mode UI backend until the maintainer explicitly selects the backend, target scope, exposure model and dependency boundary from recorded evidence.

#### Scenario: Backend decision remains pending
- **WHEN** the research lists SlateIM, ImGui, UMG/EmmsUI and a plugin-owned facade without a maintainer selection
- **THEN** no production plugin descriptor, module dependency, binding surface or tool-host behavior SHALL change

#### Scenario: Maintainer selects a backend
- **WHEN** the maintainer explicitly selects a primary backend and delivery scope
- **THEN** the proposal, design, specification and tasks SHALL be revised to replace candidate language with the selected version, provenance, APIs and verification gates before implementation begins

### Requirement: UI adapters remain isolated from tool execution
A selected UI backend SHALL be contained behind an optional adapter boundary and SHALL NOT make backend rendering, widget state or UI dependencies part of stateful source compilation, Tool History or non-UI tool execution.

#### Scenario: Tool executes without an immediate UI adapter
- **WHEN** a consumer compiles or runs a stateful AngelScript tool without enabling the selected UI adapter
- **THEN** execution and history behavior SHALL remain available without loading or depending on that UI backend

#### Scenario: Adapter is disabled or unavailable
- **WHEN** a project does not enable the optional adapter or its backend is unavailable
- **THEN** existing Details-based and non-UI tool paths SHALL remain usable and SHALL NOT silently load another immediate-mode backend

### Requirement: User owns tool source and persistent model state
The adapter SHALL host user-owned AngelScript tool code and model state without creating, curating, discovering by convention or managing a plugin-owned collection of tools.

#### Scenario: User creates a fixed tool
- **WHEN** a project defines a reusable AngelScript tool class using a selected adapter
- **THEN** the project SHALL own the source, lifecycle callbacks and persistent model fields while the plugin supplies only hosting and rendering primitives

#### Scenario: User creates a temporary tool
- **WHEN** a temporary full-source class is compiled through the planned workspace/runner path and opened in a compatible UI adapter
- **THEN** the adapter SHALL host that explicit class/session without promoting it into a managed catalogue or changing Tool History ownership

### Requirement: Native host owns unsafe draw lifecycle
The native adapter host SHALL own backend root/frame setup and teardown around each AngelScript draw callback and SHALL restore or disable the backend deterministically after callback failure.

#### Scenario: Draw callback succeeds
- **WHEN** the host enters a valid backend draw scope and the AngelScript callback returns normally
- **THEN** the host SHALL close the scope exactly once and leave the backend ready for the next eligible frame

#### Scenario: Draw callback throws
- **WHEN** the AngelScript callback raises an exception after the native host has opened the draw scope
- **THEN** the existing AngelScript exception path SHALL report the failure and the host SHALL still close, abort or disable the scope without leaving global backend state active

#### Scenario: Child container is unbalanced
- **WHEN** a script exits a draw callback without matching a backend child-container Begin operation
- **THEN** the native root boundary SHALL either recover the backend to a valid next-frame state or disable the affected surface with one bounded diagnostic rather than triggering an uncontrolled assertion later

### Requirement: Script UI references are frame-scoped
Backend builder values, widget handles and native UI references exposed to AngelScript SHALL be non-owning capabilities valid only for the active draw frame and SHALL NOT expose persistent native ownership.

#### Scenario: Script retains a handle across frames
- **WHEN** script code attempts to reuse a handle from an earlier draw frame or compile generation
- **THEN** the adapter SHALL reject it deterministically or expose a type that cannot be persistently stored, rather than dereferencing stale backend state

#### Scenario: Script hot reload replaces the class
- **WHEN** compatible hot reload replaces the AngelScript tool class while a surface remains open
- **THEN** all prior frame handles SHALL be invalid and the next draw SHALL resolve the replacement instance/callback through the reflected host owner

### Requirement: Model state and visual state have separate owners
User-visible operation state SHALL live in the user tool/session model, while backend-local focus, scroll, popup and retained-widget cache state SHALL remain owned by the native adapter.

#### Scenario: Compatible hot reload preserves model fields
- **WHEN** the existing AngelScript reinstancing rules preserve compatible reflected fields
- **THEN** the adapter SHALL draw from the replacement tool model without retaining pointers into the old script object

#### Scenario: Visual state cannot be preserved
- **WHEN** backend or hierarchy changes make focus, scroll or retained widget state incompatible
- **THEN** the adapter SHALL recreate only the incompatible visual state from the stable surface identity and current tool model without corrupting persistent tool data

### Requirement: Backend identity and semantics are explicit
Each immediate-mode tool surface SHALL declare the selected adapter/backend and a stable logical surface identity; the system SHALL NOT silently reinterpret backend-specific calls through a different widget system.

#### Scenario: Duplicate logical surface identity
- **WHEN** two incompatible surfaces request the same stable identity in one backend scope
- **THEN** registration or opening SHALL fail deterministically with a bounded diagnostic rather than relying on tick or registration order

#### Scenario: Selected backend is removed
- **WHEN** a project's selected adapter is disabled or removed
- **THEN** its backend-specific tool surfaces SHALL become unavailable explicitly while source, runner history and unrelated tool-host paths remain intact

### Requirement: Editor and Runtime scopes are independently gated
An adapter SHALL explicitly declare whether it supports Editor, Runtime/InGame or both, and SHALL keep Editor-only dependencies and behavior out of non-Editor targets.

#### Scenario: Editor-only adapter in a commandlet or packaged target
- **WHEN** an Editor-only adapter is encountered without an initialized Editor/Slate host
- **THEN** registration and drawing SHALL remain inert without constructing a partial tool instance or adding Runtime behavior

#### Scenario: Runtime support is selected later
- **WHEN** a Runtime/InGame adapter is explicitly approved
- **THEN** it SHALL separately define viewport/player ownership, input routing, authority/network behavior, Shipping policy and platform packaging rather than inheriting Editor assumptions

### Requirement: Candidate adoption requires characterization evidence
Before a candidate backend becomes a production adapter, the change SHALL record focused evidence for AS binding, exception recovery, hot reload, widget identity/input state, dependency/provenance and supported target behavior.

#### Scenario: SlateIM is selected
- **WHEN** SlateIM is the proposed production backend
- **THEN** the evidence SHALL include raw reflected API visibility, in/out parameter behavior, root cleanup after an AS exception, control reorder/focus behavior, reload root recreation and supported UE-version builds

#### Scenario: ImGui is selected
- **WHEN** an ImGui implementation is the proposed production backend
- **THEN** the evidence SHALL identify the concrete integration and revision, license, renderer/input bridge, docking/multi-viewport policy, packaging scope, AS frame cleanup and supported UE versions

#### Scenario: UMG or EmmsUI-derived implementation is selected
- **WHEN** a UMG/EmmsUI-style implementation is the proposed production backend
- **THEN** the evidence SHALL cover source/provenance, module/API adaptation, widget reconciliation and property reset, focus and GC behavior, Editor styling and exception-safe hierarchy cleanup
