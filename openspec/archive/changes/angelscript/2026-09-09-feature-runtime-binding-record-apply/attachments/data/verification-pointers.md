# Task 6.7 — UObject pointer, subclass, weak and soft reference templates

## Outcome

The recorded runtime catalog now admits the complete UObject pointer-template family: `TObjectPtr`, `TSubclassOf`, `TWeakObjectPtr`, `TSoftObjectPtr` and `TSoftClassPtr`. Their declaration providers record explicit template-container kinds, and the soft-reference infrastructure returns after recording so it does not consult the live type database while producing a detached Store.

Each concrete specialization receives engine-local operations with its reflected `UClass` constraint. Strong, weak and subclass assignment validates that constraint before mutating the destination. Strong assignments retain live objects in the owning installation until explicit release; weak assignments retain no strong reference. Soft assignment preserves an unloaded `FSoftObjectPath` without attempting a load. Construction, copy, destruction and strong-reference enumeration use the native wrapper representation for every pointer kind.

## Behavioral RED

Build `c9612e393b8b4afb8be5107af9a18ee7` succeeded with the final seven-case test shape and provider names. Exact run `e471c4a695ab4ad48c2247882387bc8c` selected all 7 cases: 5 failed and 2 structural controls succeeded.

The five failures were the deliberately unavailable pointer operations:

- `CorrectSubclassAssignmentSucceedsAndUnrelatedClassIsRejected`
- `NullPointerOperationsFollowExistingContract`
- `SoftPathRoundTripsWithoutLoadingAsset`
- `StrongReferenceRetainsFixtureObject`
- `WeakPointerBecomesInvalidAfterCollection`

The controls `TwoOwnersShareNoMutableTemplateOperations` and `FullPointerFamilyDeclarationsAreAccounted` passed, proving declaration capture, specialization materialization and owner isolation before the behavior implementation.

Earlier runs that failed during fixture setup because pointer templates were excluded from the installable-template catalog or because the test requested the nonexistent provider name `SoftObjectPath` are excluded from behavioral RED. The corrected provider is `SoftObjectPath.Functions`.

## GREEN

- Build `0d2e1befbc6446a9aa8dd908cff1b96e`: `AngelscriptProjectEditor` succeeded, 9/9 actions.
- Exact run `577f41d9242849fe870111fe739bfcd2`: all 7 `Angelscript.UnitTest.RuntimeBindings.Reflection.Pointers.` cases succeeded, with zero warnings, errors, skipped, not-run or incomplete cases.

The final run proves successful and rejected subclass assignment, preservation of the previous value on rejection, strong retention through collection and release, weak invalidation and stale state after collection, unloaded soft-path round-trip, null assignment for all four operational kinds, distinct per-owner operation tables, and declarations/members for the full five-template family plus both soft path value types.

## Identities

Final SHA-256 identities:

- `AngelscriptTypeBindInfo.h`: `C8BD58565562671C4318A96BDA90C20C885970C7FCD1544EE91DE39566509BE9`
- `AngelscriptTypeBindInfoCatalog.cpp`: `95BF6EBF7F88288F246444C7B9DDEA419E1463B66A65BABD27AAD2CFED7D9DBA`
- `AngelscriptTypeBindInfoApply.h`: `39FE9BCE08FB44F317E5289A84AFA5CB6AC88F92A4B73697D04CD45C754BAF70`
- `AngelscriptTypeBindInfoApply.cpp`: `3BE4E298F221DCB4F0E2E95350AE7679C893408C7DFE660930BE2208D167987C`
- `Bind_BlueprintType.cpp`: `D8D22EC0AA7D1D5BB086328474EE33D6650A5870AE328D306A24B987388D3E31`
- `Bind_TSoftObjectPtr.cpp`: `2D573939E806CC9A3B2285BEEA503AA6838024BDAE7D6F28F8D0FC1939BAF0D2`
- `RuntimeBindingPointersTests.cpp`: `CB2536B0E38F7CE9F58DA1F8A6923D1FC254063A63A8C49B98170AD87E82695D`
- `UnrealEditor-AngelscriptRuntime.dll`: `02F47D0FB2E3A80F2A608CD92921AE3B6FDA80D4D05896B5F8628CE65FF8A9A0`
- `UnrealEditor-AngelscriptTest.dll`: `F669DAD5A657262D631F19966F1EBE58FE0F82773EC11B8737CEFDBC091C27B8`

No expanded RuntimeBindings, baseline, packaging, performance, JIT or legacy suite was run. The exact selector covers the new provider capture, metadata materialization, native pointer operations, GC behavior and owner isolation. Heavier suites do not add a matching contract for this bounded pointer-family migration.
