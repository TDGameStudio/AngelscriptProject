---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-sdk-compile-lifecycle
closure_kind: completed
input_sha256: 63c098ed9b01b726287ea60adc581518ae87fc7510ff01ff328fd4bd303ec0ab
captured_at: 2026-09-12T11:14:00+08:00
---

# Terminal workflow evaluation

## Lifecycle

- Created from the approved compile-lifecycle draft. Applied replan added 6.1–6.2 after the user flipped Image deletion into this Change.
- Implemented takeable `asCModuleDefinitionSet`, two Builder products, Function-hung stable bytecode, and `asCEngineCompileRegistration` Install+Link.
- Task 6.2 deleted `asCMetadataImage` / `RegisterMetadataImage` / Engine `metadataImages`. BindInfo Draft/Apply owner-swaps onto DefinitionSet.

## Verification

- 1.1–6.1 GREEN as recorded on their Task Cards.
- 6.2 GREEN: `as_metadata_image.h` absent; `ue.build` `1e427ddd6a04427e89f23ca9bcc569ce` Succeeded; prefix `Angelscript.UnitTest.NativeEngine.CompileLifecycle` run `24ae38f90b374262ba8919403d51874a` 25/25 Succeeded.
- `openspec doctor --json` Succeeded. Strict change validation of `angelscript/refactor-sdk-compile-lifecycle` Succeeded.
- Synced specs: `angelscript/language/types/definitions`, `angelscript/runtime/type-registry`, `angelscript/runtime/bytecode`, `angelscript/runtime/vm` strict-passed. `angelscript/language/frontend/builder` still fails two four-space indent findings on unspecified scenario `Analyze supported source through the replacement`; that card was not in the delta and was not reformatted.

## Material friction and corrective action

- Mechanical `RegisterMetadataImage` → `InstallDefinitionSet` also renamed TEST_METHOD `RegistrationInstallsWithoutRegisterMetadataImage`. Restored the public identity before the 25/25 run.
- Failed Register must not leave a Taken set's functions Prepare-able. BindInfo Apply keeps published TypeId/FunctionId maps on the last set in a batch.

## Spec and knowledge disposition

Durable deltas merged into the five named current specs. Change-local knowledge candidates `script-typeinfo-without-engine.md` and `sdk-compile-parallelism.md` stay change-local; they are not promoted.

## Scope boundary and provenance

Binding GREEN, full NativeEngine, Quick, Integration, host CompileModules, and ClassGen were omitted: Binding GREEN is a later Binding Change; host compile/UClass stay out. Raw Unreal runs remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`. This Change ID is not a reusable Harness gate default fixture.
