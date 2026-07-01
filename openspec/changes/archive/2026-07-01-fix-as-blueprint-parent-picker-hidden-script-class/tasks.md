## 1. Reproduce and capture

- [x] 1.1 Add or extend a diagnostic test that checks `AExampleActorType` against standard blueprint parent-picker eligibility.
- [x] 1.2 Capture the relevant class flags, metadata, and picker filter conditions so the search failure is observable without relying on manual editor clicks.
- [x] 1.3 Confirm the failure is class-viewer cache invalidation, not `UASClass` blueprint-base metadata.

## 2. Fix picker discovery

- [x] 2.1 Broadcast Angelscript class reload/create events for soft reload materialized classes.
- [x] 2.2 Request Unreal's standard class-viewer hierarchy refresh when Angelscript class sets change.
- [x] 2.3 Keep existing exclusions for `Abstract`, `Deprecated`, `HideDropdown`, and `NotBlueprintable` classes intact.
- [x] 2.4 Preserve full reload's existing `BroadcastBlueprintCompiled` refresh path without adding a duplicate class-package refresh.

## 3. Verify behavior

- [x] 3.1 Confirm the Angelscript direct create-blueprint popup path remains covered by `Angelscript.Editor.Module` popup tests; no source change altered that flow.
- [x] 3.2 Confirm the standard Blueprint parent-class picker dependency path through ClassViewer refresh is covered by project/editor automation tests; no manual Slate click-through result is claimed.
- [x] 3.3 Add a project-side regression test for the ClassViewer refresh signal.
- [x] 3.4 Extend existing editor reload helper tests for soft/full refresh-event semantics.
- [x] 3.5 Run targeted build and automation tests after the editor/build workers release locked DLLs; `Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.Module" -Label parent-picker-closeout-editor-module -TimeoutMs 600000` passed `13/13` on 2026-07-02, and the earlier blocker is recorded in `build-session-notes-2026-06-26.md`.
