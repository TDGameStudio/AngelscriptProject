# Initial-only skip and public names

## Context

C is locked. The remaining choices were which compile types skip Stage1–4, the proving test identity, and the Change id.

## Evidence

AskQuestion Q2 = I, N1 = `ClassGenMaterialization`, N2 = `classgen-register-join`. Neighbors: withdrawn `ClassGenMaterialization` under `Angelscript.UnitTest.NativeEngine.Compile`; prior Change `feature-classgen-type-materialization`. Draft log R3.

## Options

- I: only `CompileModules(Initial)` skips. R: Initial plus Full/SoftReload skip; CacheV2 reuse still out.
- Test class `ClassGenMaterialization` versus `CompileModulesBuilderJoin`.
- Change `feature-classgen-register-join` versus `feature-compile-modules-builder-join`.

## Settled Decision

Only Initial skips the dead block. Test class is `ClassGenMaterialization` on `Angelscript.UnitTest.NativeEngine.Compile`. Change id is `angelscript/feature-classgen-register-join`. Host entry stays `CompileModules`; do not restore `BindRegisteredTypesForClassGeneration`.

## Consequences

First editor compile can emit UCLASS. File-edit reload stays on the dead Stage path until a follow-up Change. Implementers add `ClassGenMaterializationTests.cpp` beside existing Compile tests.

## Flip Condition

Take Q2=R if hot reload must materialize in this Change. Open `NativeEngine.ClassGen` later if reload/reinstance needs a dedicated suite.

## Sources

[glossary](../drafts/glossary.md), [handoff](../drafts/handoff.md). Provenance: draft log R3.
