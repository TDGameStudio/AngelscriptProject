## Context

The completed `refactor-classgenerator-decomposition` change split `FAngelscriptClassGenerator` member definitions by pipeline phase while keeping `AngelscriptClassGenerator.h` as the single declaration source. It also clarified that `ClassGenerator` is a historical directory name: the real architectural boundary is the AS-to-Unreal Generator.

The remaining monolithic artifact file is `ASClass.cpp/.h`. It currently groups several responsibilities that evolve at different rates:

```text
AS declarations / descriptors
  ↓
Generator pipeline
  ↓
UE reflected artifacts
  - UASClass      // generated class runtime, CDO/defaults, construction, tick, replication, GC hooks
  - UASFunction   // generated function reflection, argument layout, runtime dispatch bridge
  - UASFunction_* // dispatch variants selected by argument/return/JIT/thread-safety shape
  - UASStruct     // generated struct artifact, already comparatively cohesive
```

## Goals / Non-Goals

**Goals:**
- Separate generated class runtime behavior from generated function call behavior.
- Keep UHT-facing `UCLASS()` declarations explicit and reviewable.
- Reduce copy-paste risk in dispatch implementation bodies without hiding reflected class declarations from UHT.
- Add only narrow public-behavior characterization tests where current `ASClass`/Generator coverage has known gaps.
- Normalize existing `ClassGenerator` CQTest files that are used as the regression net so they follow `Documents/UnitTest/UnitTest.md`: class-level engine lifecycle, `ASTEST_AS` inline AS fixtures, public CQTest hooks/methods, and no method-level engine reset pattern.
- Keep the first implementation pass behavior-preserving and mechanically reviewable.

**Non-Goals:**
- No semantic changes to construction, defaults, GC, replication, tick, hot reload, or dispatch selection.
- No private/internal header that becomes a second declaration source for an existing reflected type.
- No broad rename of `ClassGenerator` directories or test prefixes in this change.
- No macro-only/table-only source of UHT-visible `UCLASS()` declarations.
- No de-globalization or haze-marker cleanup.

## Decisions

### Decision: Split by reflected artifact ownership

`ASClass.cpp` should retain `UASClass` behavior only. `UASFunction` base behavior should move to an `ASFunction` unit. Dispatch variants should move to a dedicated dispatch-variant unit while preserving explicit UHT declarations.

Rationale: artifact ownership is the stable module boundary. `UASClass` owns class runtime lifecycle; `UASFunction` owns function reflection/call layout; dispatch variants are generated-call strategy classes. Mixing them creates review noise and accidental coupling.

Alternative considered: rename the whole directory to `Generator` first. Rejected for this change because it creates high-churn path/test-prefix changes before the artifact responsibilities are stable.

### Decision: Tests assert public generated artifacts, not private generator state

Coverage should compile real AngelScript snippets and observe generated Unreal artifacts, diagnostics, and runtime behavior. It should not assert helper placement, translation-unit split, private counters, or internal state machines.

Rationale: this refactor changes ownership and file layout, not behavior. Public artifact assertions survive implementation movement; private-state assertions would freeze the wrong boundary.

### Decision: Dispatch variant declarations remain explicit

Any table/macro generation may target non-UHT implementation bodies or checked-in generated source only. UHT-facing `UCLASS()` declarations must remain explicit committed C++ declarations.

Rationale: UHT parsing is a hard build boundary. Readability and deduplication cannot come at the cost of reflected declaration ambiguity.

## Risks / Trade-offs

- UHT declaration drift → keep explicit declarations and compare generated class set through existing dispatch tests.
- Unity build masking missing includes → validate with the project build runner and narrow affected tests before broad regression.
- Behavior drift during movement → move bodies mechanically first; extract helpers only after equivalent tests are green.
- Test churn from naming cleanup → defer directory/test-prefix rename until artifact split has landed.

## Migration Plan

1. Record current `ASClass` / `UASFunction` / dispatch ownership map.
2. Close ClassGenerator movement-guard test structure debt: class-local helper ownership, fixture proximity, and documented isolation exceptions.
3. Add narrow characterization tests for remaining public gaps only.
4. Move `UASFunction` base implementation into its own unit.
5. Move dispatch variants into a dedicated unit with explicit UHT declarations preserved.
6. Leave `ASClass.cpp` as the `UASClass` runtime artifact owner.
7. Validate build, `ClassGenerator.ASClass`, `ClassGenerator.ASFunction`, and affected `ClassGenerator`/`HotReload` suites.

## Characterization Notes

- `AngelscriptScriptClassStructureTests.cpp` now pins namespaced `UCLASS` generation through public artifact behavior: the script namespace compiles, `UNamespacedScriptClass` is published as a `UASClass`, its reflected property default is observable on the CDO, and its generated `UFUNCTION` executes through the shared runtime event helper.
- This coverage intentionally asserts generated Unreal artifacts rather than preprocessor internals; compiler namespace tests already cover helper emission and namespace parsing.

## Open Questions

- Whether debugger prototype behavior has a stable public seam worth testing in this change.
- Whether final naming should stay `ClassGenerator` for compatibility or migrate to `Generator` in a separate rename-only change.