# Task 4.9 time and identity provider verification

## Outcome

The time, GUID, range, frame-time, deterministic-random, math and hash providers record into a detached Store and install into two independently owned Engines. The fixed member surface is 506 contributions: `FDateTime.Functions` 38, `FTimespan.Functions` 46, `FGuid` 14, `FFrameTime` 9, `FRange` 122, `FRandomStream.Functions` 18, `FMath.Manual` 251 and `Hash` 8. `EGuidFormats` and `FRandomStream.Type` are additionally accounted by the declaration pass. ToString contributions remain deferred to task 7.10 during recording.

Recording-aware namespace scopes replaced direct target-Engine access in DateTime, Timespan, GUID, Range, Math and Hash. DateTime's Static JIT descriptor and the DateTime/random ToString contributions now run only against a real target Engine. The new typed `ExistingClassForTarget<T>` path enriches an existing declaration with native lifecycle/equality/hash recipes without redefining its established layout or flags; Range uses it so its array-returning signatures can materialize `TArray<FFloatRange>` and `TArray<FInt32Range>` safely.

## Grouped RED

Build `42c7774a29e74ee8a0e00112f12b0e47` discovered the new eight-case group. Run `299e45e0d31d44fcbdc5325ecef0a6ae` executed 8 cases: the six native representation controls passed and the two owner-construction cases failed at detached DateTime ToString access. Follow-up evidence exposed, in order, DateTime JIT target-Engine access (`a0195413a2a84696a7ac0c951cad166a`), duplicate selection of declaration-pass providers (`aba2bf32ccee4d799840176f9fb57f55`), direct Range namespace access (`fd22a1130afa4bad80bf96d81559df2e`), and absent `FFloatRange` template-element construction recipes (`a8e545a032ab4dd486de212de6f4bf3e`). These were in-scope implementation failures; no requirement or task boundary changed.

## GREEN

- Final editor build: Harness run `3e072d3e9660403fadcda45af4ae8c6c`, exit 0, 4/4 actions. Runtime DLL SHA-256 `767a93202078257f8a67435f79356cfc9348062c6522a8f349fbd0e5839fba1e`; test DLL SHA-256 `38947d064c1964976d16718ad8c9014f9ebef531bdef73772d97047b40ba50d4`.
- Exact proving selection: Harness run `231bd58638844f348ca9944ff19eaad4`, `Angelscript.UnitTest.RuntimeBindings.Values.TimeIdentity.`, 8/8 succeeded, 0 warnings, 0 errors, complete report at `Saved/Harness/Unreal/Runs/231bd58638844f348ca9944ff19eaad4/AutomationReport/index.json`.
- Shared values regression: Harness run `8d33cd49e9e34297adbc90c8abda11ff`, `Angelscript.UnitTest.RuntimeBindings.Values.`, 54/54 succeeded, 0 warnings, 0 errors, complete report at `Saved/Harness/Unreal/Runs/8d33cd49e9e34297adbc90c8abda11ff/AutomationReport/index.json`.

The exact cases prove one-second tick representation, leap-day component round-trip, zero/fixed GUID validity and parse round-trip, inclusive-lower/exclusive-upper range behavior, exact frame/subframe representation, repeatable same-seed sequences across two owners and after reset, integer Clamp, equal-value hash stability, and complete provider accounting.
