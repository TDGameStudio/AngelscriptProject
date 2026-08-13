> Record-only decision checklist. Tasks 2.x are mutually exclusive candidate spikes, not authorization to run every spike. After task 1 selects a direction, delete the irrelevant candidate tasks and replace section 3 with a backend-specific implementation plan before changing production code.

## 0. Preserve the Research Baseline

- [x] 0.1 <!-- Non-TDD --> Audit the current tool execution, Editor host and workspace OpenSpecs and record why immediate UI remains a separate capability.
- [x] 0.2 <!-- Non-TDD --> Inspect local UE 5.8 SlateIM source, the reflected Blueprint surface, root/manager lifecycle, EmmsUI reconciliation and Hazelight immediate-handle examples; separate confirmed facts from unverified binding inferences in `research.md`.
- [x] 0.3 <!-- Non-TDD --> Record candidate comparison, backend-independent ownership/safety requirements and the explicit record-only decision state without modifying production code or plugin descriptors.

## 1. Make the Maintainer Decision

- [ ] 1.1 <!-- Non-TDD --> Select the primary backend: SlateIM, one named ImGui integration, UMG/EmmsUI-derived implementation or a plugin-owned facade; record the rationale and rejected alternatives in `design.md`.
- [ ] 1.2 <!-- Non-TDD --> Select the first delivery scope: Editor-only or Editor plus separately defined Runtime/InGame support, including Shipping and input/viewport policy when Runtime is selected.
- [ ] 1.3 <!-- Non-TDD --> Select the AS exposure model: raw backend API plus safe host, curated backend-specific API, or an explicitly justified common facade.
- [ ] 1.4 <!-- Non-TDD --> Select the dependency boundary: disabled-by-default sibling plugin or a proven optional existing-module integration; identify supported UE versions and dependency/provenance obligations.
- [ ] 1.5 <!-- Non-TDD --> Rewrite the proposal, specs, design and this checklist for the selected direction, remove irrelevant candidate work and obtain explicit implementation authorization.

## 2. Characterize the Selected Candidate

- [ ] 2.1 <!-- Non-TDD --> If SlateIM is selected, use an explicitly authorized disposable configuration to enable it, capture the generated AS declarations/call routes and verify representative control, in/out parameter, table and exposed-root calls.
- [ ] 2.2 <!-- TDD --> If SlateIM is selected, add a test-first characterization for exception-after-root, unbalanced child scope, next-frame recovery, control reorder/input focus and compatible hot reload before accepting its production API.
- [ ] 2.3 <!-- Non-TDD --> If ImGui is selected, pin one concrete Unreal integration/revision and document license, renderer/input bridge, UE compatibility, docking/multi-viewport, packaging and Shipping policy.
- [ ] 2.4 <!-- TDD --> If ImGui is selected, add a test-first/native harness characterization for AS frame cleanup, input coexistence, hot reload and Editor/Runtime startup-shutdown in the approved scopes.
- [ ] 2.5 <!-- Non-TDD --> If UMG/EmmsUI is selected, decide concept-only adaptation versus source reuse, complete provenance/module migration review and characterize widget reconciliation, property reset, focus, GC, Editor styling and hierarchy cleanup.
- [ ] 2.6 <!-- Non-TDD --> If a common facade remains a candidate, prototype the same two representative tools against at least two backends and retain the facade only if the shared API preserves required control coverage without backend leakage.

## 3. Produce the Selected Implementation Plan

- [ ] 3.1 <!-- Non-TDD --> Convert successful characterization evidence into a file-by-file implementation plan with public types, module/plugin dependencies, hot-reload lifecycle, failure cleanup and exact `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` verification commands.
- [ ] 3.2 <!-- Non-TDD --> Add a delta to `feature-as-editor-tool-host-extensions` only if the selected adapter changes its public tab-content contract; keep stateful execution and Tool Workspace responsibilities unchanged.
- [ ] 3.3 <!-- Non-TDD --> Confirm the final plan still provides no built-in tool catalogue, user-source management or mandatory backend dependency before beginning implementation.
