## Why

The C++ learning trace tooling under `Plugins/Angelscript/Source/AngelscriptTest/Learning/` produced unsatisfactory teaching artifacts. The owner (project lead) decided the C++ examples are not good enough to keep ("not good; very awkward") and will replace them with a future web-based learning content pipeline (separate effort, not part of this change). Removing the C++ tooling now prevents drift, frees the Test module of dead-weight teaching code, and clears the slate for the new direction.

## What Changes

- Delete the entire `AngelscriptTest/Learning/` directory (Native, Runtime, Export — 28 files including exporter, commandlet, and 23 `*LearningTraceTests.cpp` files).
- Delete the orphaned learning-trace utility in `AngelscriptTest/Shared/`: `AngelscriptLearningTrace.h`, `AngelscriptLearningTrace.cpp`, `AngelscriptLearningTraceTests.cpp`.
- Delete the runtime teaching-trace instrumentation: `AngelscriptRuntime/Core/AngelscriptTeachingTrace.h` and `AngelscriptRuntime/Core/AngelscriptTeachingTrace.cpp`.
- Revert workbench-introduced probe call sites and the `EmitClassTeachingTraceEvent` / `EmitTeachingTraceEvent` namespace in `AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` (back to its committed HEAD state).
- Remove the matching entries from `AngelscriptTest/Shared/README.md` so the header inventory no longer references the removed `AngelscriptLearningTrace.h`.
- **BREAKING:** Removes the `AngelscriptLearningTraceExport` commandlet and its JSON export contract; consumers of `Saved/Automation/AngelscriptLearningTraceExport/*.json` lose the regenerator. The static frozen `Experiment/ASRuntimeVisualizer/raw-trace-data.js` snapshot remains usable as an archival demo.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `as-learning-trace-export`: REMOVED. The C++ exporter, commandlet, schema, scenarios, and visualizer-hint contract no longer exist.
- `as-runtime-visualizer-raw-trace`: REMOVED. The contract between the C++ exporter and the visualizer page is dropped. The static visualizer page may persist as an unmaintained demo, but it is no longer a recorded capability.
- `as-teaching-snapshot-workbench`: REMOVED. The scoped runtime teaching-trace recorder, class/member generation probes, and `RuntimeClassMemberGeneration` exporter scenario are all deleted.

## Impact

- **Submodule (`Plugins/Angelscript`):** 33 file deletions plus one file revert. No new files. Test count baseline drops by ~30 automation cases (Learning theme — these have not been counted in `TestCatalog.md`'s 275/275 baseline, so that document does not need updating).
- **Build/test commands:** `Tools\RunBuild.ps1`, `Tools\RunTests.ps1` should remain green for all non-Learning themes. No Build.cs edits required (the module structure is unchanged; only files are removed).
- **Web visualizer:** `Experiment/ASRuntimeVisualizer/` keeps its frozen `raw-trace-data.js` snapshot. Decision pending on whether to keep it as archival or also remove (tracked as a follow-up question, not part of this change).
- **OpenSpec specs:** three capability records become REMOVED. Three archived changes (`feature-as-runtime-visualizer-raw-trace`, `feature-as-teaching-snapshot-workbench`, and any earlier learning-trace records) remain in `openspec/archive/` as historical records.
- **Documentation:** `Documents/Guides/LearningTrace.md` becomes obsolete (deleted in a follow-up doc-sweep change, not this one — keeps the diff focused on code).
