# Task 6.2 verification: loaded UE reflection definitions

## Outcome

Task 6.2 captures real loaded or selected UE nominal declarations on the GameThread without a script Engine. The immutable snapshot retains class/interface/struct/enum/delegate identity, parent and interface relationships, nested property type uses, signed 64-bit enum values, native layout, struct initialization/copy/destruction and GC facts. The owning BlueprintType, UStruct and UEnum declaration providers reuse the same detached snapshot. A Store rejects a reflection snapshot whose effective recording policy differs before attaching it or recording a type.

## RED

The feature group first ran with eleven intended scenarios failing against the compilable reflection API skeleton while existing recording controls remained separate. After implementation and provider extraction, the final focused RED was Harness run `3b68d6b9cf984a0c84e34568de37ed67` on 2026-09-08. Its complete Automation report contained 13 cases: 12 succeeded and `RecordingRejectsSnapshotWithDifferentEffectivePolicy` failed at the assertion that recording must reject the snapshot. Process exit was 255 with one test error and no warning. This demonstrated that `SetReflectedSnapshot` accepted the first snapshot without comparing its policy to the Store policy.

## Implementation boundary

`FAngelscriptTypeBindInfoReflection` performs serial GameThread capture and copies deterministic reflection facts into `FAngelscriptReflectedTypeSnapshot`, which strongly retains referenced UObject identities. Owning binding providers describe eligibility and native lifetime adaptation. `FAngelscriptTypeBindInfoStore::SetReflectedSnapshot` compares every effective policy field before mutating its snapshot reference. The policy comparison is shared by the recording Store and does not query or publish an Engine.

## GREEN

- Build: Harness run `0549f3d8887f49468ef749a886765b45`, `AngelscriptProjectEditor Win64 Development`, succeeded with exit 0 in 226626 ms.
- Exact proving selection: Harness run `25d4761604a44a10be123a5466a11163`, `Angelscript.UnitTest.RuntimeBindings.Reflection.Definitions.`, succeeded with process exit 0.
- Report: complete and valid, 13 total, 13 succeeded, zero failed/skipped/not-run/in-process, zero warnings and zero errors.

The successful cases were:

1. `ContainerPropertyRetainsNestedNominalDependencyShape`
2. `DelegateSignatureKeepsReturnAndReferenceFlagsWithoutInvocation`
3. `DerivedBeforeBaseRecordsRealNominalParentWithoutEngine`
4. `EditorOnlyTypeHasExplicitCookedPolicyExclusion`
5. `EnumNamesAndInt64ValuesAreDetachedFromLaterReflectionMutation`
6. `LoadedCaptureCanBeReadRepeatedlyWithNoCurrentEngine`
7. `NativeInterfaceIdentityAndImplementationRelationshipAreCaptured`
8. `OriginalDeclarationProvidersReuseTheDetachedSnapshot`
9. `RecordingRejectsSnapshotWithDifferentEffectivePolicy`
10. `SnapshotAndRecordedStoreRetainTemporaryReflectionUntilRelease`
11. `StructLayoutAndPropertyUsesMatchNativeReflection`
12. `StructLifetimeRecipeInitializesCopiesAndDestroysNativeStringStorage`
13. `WorkerThreadCaptureFailsBeforeTouchingReflection`

## Verified identities

After the successful run, relevant source SHA-256 values were:

- `Core/AngelscriptTypeBindInfo.h`: `E98FFADDA0A7066433D10A6A190DB8792EF2482962B50369F88A0B65D8BBAD8C`
- `Core/AngelscriptTypeBindInfoStore.cpp`: `442AD7BC3751BF152E63113FED990A0257603498880778F3971285B383F5F895`
- `Core/AngelscriptTypeBindInfoReflection.h`: `08764FB7A417D254625E3987EF30B784741FDE38A246CE8D911FD5AAF89B7D41`
- `Core/AngelscriptTypeBindInfoReflection.cpp`: `289A17D0050811CE0580352B8700D4BE53CEFB7043BA0821AD5C7CC731F4506E`
- `RuntimeBindingDefinitionsTests.cpp`: `FFA3ACEE64BD5F25965921F0380D219CE1860A87C640C64054F713A962A187A6`
- `UnrealEditor-AngelscriptRuntime.dll`: `6626864D34EE98B94F22A90F6232A26DFF4E94E466BE5B93236365D669E77111`
- `UnrealEditor-AngelscriptTest.dll`: `CE3CF2B336E69A2DB38295DCE61DB176608A8F01E34B52156A651AED73A2804A`

The exact task selector is sufficient for the reflection-declaration outcome. Full Runtime installation, member surfaces, dump validation and native invocation remain owned by their downstream tasks, so no broader suite was treated as task 6.2 proof.
