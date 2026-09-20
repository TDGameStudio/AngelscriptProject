---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260913-105100-shared-source-makes-emit-real
status: resolved
source: verification
source_ref: task 2.1
affected_tasks: ["2.1"]
created_at: 2026-09-13T10:51:00+08:00
resolved_at: 2026-09-13T11:25:45+08:00
resolution_ref: ue.test Angelscript.UnitTest.NativeEngine Fast 14ff26d1e7c347a2b6e660eda966136a
---

# Shared Source Makes RunThrough Emit Real Function Bodies

## Symptom

Task 2.1's proving selector `ue.test` `TestPrefix=Angelscript.UnitTest.NativeEngine` Fast is not green. The first full post-migration run `011d71f3029c421f932ab7281937c73a` exited 3 with no `index.json`: several LanguageSurface cases failed `asLinkByteCodeImage` with `BodyConflict` (status 5), ListInitializer `RunThrough()` returned false, TypeOwnership `ConsumerLedger` failed file load, then `VMAtomicLink.FailedFingerprintQueryRejects` crashed on a null `asCModuleDefinitionSet`.

## Investigation Log

- Shared-source identity made `StableFunctionKey` match frozen functions, so `asCByteCodeEmitter` now emits bodies it previously skipped. `RunThrough()` therefore `AdoptEmittedByteCode`, and `RegisterCompiledDefinitions` takes and links that image.
- Tests that independently `EmitFromSession` and link again then hit `BodyConflict`. Pre-2.1 NativeEngine green (`14bd04f964ad43b1914bbc4737df7180`, 2026-09-09) attributed success to a working emit+link path; emit was often a no-op.
- Host object types were absent from the emit frame, so `Values Data = {1,,3}` fell through to primitive `asEmitExpr(InitList)` and failed `unsupported-lowering`. Generic `Values<int>` was not found as `asCNominalType`.
- `RegisterCompiledDefinitions(Engine, Builder)` takes the set. Callers that `FindSourceFunction(Builder, ...)` or re-register the same Builder after that Take saw `asNO_FUNCTION` (-6) or `InvalidArgument` instead of `ForeignEngine`. `GetBoundEngine()` stays null; binding is on type/function `GetEngine()`.
- `FailedFingerprintQueryRejects` called `Fixture.Set->SetFingerprintDigestProvider` after `MoveTemp(Fixture.Set)` into Register (`this == null`).
- `ConsumerLedger` still pointed at `openspec/changes/angelscript/feature-types-explicit-ownership/.../consumer-migration.csv` after that Change archived on 2026-09-11.
- Later suite crashes: stale TLD active context in `AcquireVmObjectLease`; caller-held `~asCExecutableSnapshot` Released types after `RetireDefinitionSets` `asDELETE`; `EmitAndEncode` Took and destroyed the set before `FindSourceFunction`.

## Root Cause

The 2.1 shared-source Builder entry made bytecode emission a real default path. Downstream Register/link fixtures and a few emit-frame and lifetime gaps were written against the old skip-emit world. Publication now happens, so a second link, a missing host type, a post-Take Builder query, or a leftover thread-local context fails where it used to appear to succeed.

## Disposition

Resolved on task 2.1. Specified emit/link/`BodyConflict` behavior was not weakened. Register of a Builder does not double-publish when the case links `EmitFromSession` itself; adopted-image publication remains for cases that only Register then Execute. Host/generic type lookup completes list-init `RunThrough`. Fixtures capture functions and Host sets before Take. `AcquireVmObjectLease` consults the TLD context only during shutdown/retirement; snapshot destructor Releases declarations only while a publisher is attached.

## Evidence

### Failure Evidence (RED)

- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine` Fast run `011d71f3029c421f932ab7281937c73a` — process crash, no Automation `index.json`; log `Saved/Harness/Unreal/Runs/011d71f3029c421f932ab7281937c73a/Unreal.log`.
- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine` Fast run `14e5caf1c4114b3e8b7a68518bd1eefb` — no `index.json`; NamespacedString `InvalidState`; crash in `VMFingerprints.RetiredAuthenticDefinitionsRemainInspectable`.
- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine` Fast run `a636332e63634e809a9216494957c858` — crash in `VMObjectLifetime.PartialMemberFailureSkipsWholeObjectDestructor`.
- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine` Fast run `d6043e9f5537488fb80befb53e469489` — crash in `VMRuntimeDrain.CallerSnapshotDetachesWhenLastRuntimeObjectDrains`.
- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine` Fast run `fdf829244981433d867ddf168c6f2db9` — exit 255, 25 VMSource* failures after crashes were cleared.

### Resolution Evidence (GREEN)

- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine` Fast run `14ff26d1e7c347a2b6e660eda966136a` — Succeeded, 1147/1147; report `Saved/Harness/Unreal/Runs/14ff26d1e7c347a2b6e660eda966136a/AutomationReport/index.json`.
- Focused repairs that landed in that binary: ListInitializerDefinitions `d6c603857dbf47a0991898ef7bdf9bf9`; LanguageSurface `b152ff7ab1cc4515bfab7d2ae9c0e65a`; VMRuntimeDrain `2ea8152aadf640a1ae8e152e4d4a016a`; VMSourceNumeric `874f4b56ba9742e699c8182885badfa6`; VMSourceCacheContracts `56747df478b14cdb8dec4144f6a62dd2`; VMSourceUnwind `bdc6305d1d674e76a3bc1b916dc388d9`.

### What This Proves

Shared-source admission changed when function bodies are emitted and published. The NativeEngine failures after 2.1 were that publication shift plus the lifetime bugs it exposed. The proving selector is now green without weakening BodyConflict or Take-nullness.

### What This Does Not Prove

Cards 2.2–4.1 are unstarted. `RetiredAuthenticDefinitionsRemainInspectable` no longer inspects fingerprints after `Engine.Reset()` because retirement destroys the set.

## Links

- `tasks.md` task 2.1
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_engine_compile_registration.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/NativeSourceExecutionTestSupport.h`
