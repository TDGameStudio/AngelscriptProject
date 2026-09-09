# Task 2.5 — recorded native callable connection

## Outcome and scope

A sealed Store installs a complete metadata image through Install, then ConnectNative validates and publishes its callable/storage batch in the exact owning Engine. Installed function/global identity is checked by pointer and stable key. Candidate interfaces retain their declarations; no candidate function or address is published when another entry fails. Caller parameter counts captured by the typed facade detect the tested signature arity mismatch, while calling convention checks reject incompatible owners and missing targets.

Generic calls receive auxiliary data from the exact acquired binding generation. Plain member user data is kept separate from the VM receiver; native first-parameter function/type metadata and object-first/object-last argument order are preserved. Engine type and global name indexes now follow the same case-sensitive contract as draft/image indexes.

This task proves Context Prepare/Execute against native metadata. It does not activate default startup, compile full scripts, complete Runtime providers, or provide the explicit FAngelscriptEngine owner (task 3.2). It does not infer arbitrary C++ type equivalence from erased pointers: the negative signature fixture proves arity rejection, alongside convention/owner checks.

## Commands and terminal runs

All commands import Harness and construct the selected-workspace context in the current PowerShell process. The exact task selector is:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Calls.Native.'; Fast = $true; TimeoutMs = 600000 }
```

Actual asynchronous launches add NoWait=true and retain the resulting managed RunId. Build command: ue.build with NoWait=true and TimeoutMs=900000. Concurrency remains the default Auto selection.

| Purpose | Managed RunId | Terminal evidence |
|---|---|---|
| Initial test setup build | 5f84b4f2dae746438a94e4832468837b | Succeeded, exit 0 |
| Initial native RED | 6a31a39a884140f9958f39f7d3b83bea | Failed, exit 255; 12 failures and 3 rejection controls passed |
| Initial implementation build | c97f43ac1b224eb6b60da4e0ca598b67 | Succeeded, exit 0, 360.20 s after external build ended |
| Interrupted shared proof | 8ae4a58ca4774c4db1456afd19601600 | Failed, exit 3; generic auxiliary null read; no complete Automation report |
| Auxiliary transport build | eadc13b236de45d288c94dd29f083d83 | Succeeded, exit 0 |
| Expanded test build | acbdb685e9584b8bb67c5d4e0710a7c8 | Succeeded, exit 0, 15.65 s |
| Intermediate shared GREEN | 6cd1fc97a2a644d881f59c271e5c2508 | Succeeded, exit 0; 70 cases including 19 native cases |
| Member auxiliary RED setup | 36b519a2aabd445b80ed110f0a9bb5e6 | Succeeded, exit 0 |
| Member auxiliary RED | 311df54a47984ad5a38518a43443a3ca | Failed, exit 255; new member auxiliary case failed, 19 controls passed |
| Final implementation build | 36eb0ef8dd4246ca9d53432ef35f4e79 | Succeeded, exit 0, 11.80 s |
| Final shared RuntimeBindings GREEN | 946164fe25de449e8eeca2c7ce9b7eae | Succeeded, exit 0; all 71 cases successful |
| Adjacent VM native contracts | 3b1fae1c16054584b680de4b520bafdc | Succeeded, exit 0; all 28 cases successful |
| Adjacent metadata registration | 57dd66955b4c4727ab846a985b3f299e | Succeeded, exit 0; all 23 cases successful |
| Adjacent global definitions | d2839d2eb88a4774a2401be7b72b8a93 | Succeeded, exit 0; all 7 cases successful |

Final actual selectors, each with Fast=true, TimeoutMs=600000 and NoWait=true:

- Angelscript.UnitTest.RuntimeBindings.
- Angelscript.UnitTest.NativeEngine.VMNative
- Angelscript.UnitTest.NativeEngine.MetadataImage.
- Angelscript.UnitTest.NativeEngine.GlobalDefinitions.

Every final case reports Success with zero errors/warnings, and each report has zero failed, in-process and not-run cases. The shared RuntimeBindings run maps to the exact task selections below; it is not an inferred aggregate success.

## RED interpretation and local repairs

The initial ConnectNative skeleton returned false. Twelve initial cases failed, mostly on successful connection expectations. The case-sensitive owner fixture failed earlier at image installation because the Engine name index conflated Pair/pair. MissingTarget, IncompatibleCallableOwner and WrongSignature passed under the rejecting skeleton; these are recorded as baseline controls, not independent observed failures.

The first native implementation passed four cases before the generic callback dereferenced a null auxiliary pointer. Inspection proved asCGeneric delegated GetAuxiliary to asCScriptFunction::GetAuxiliary, which returns zero, and the callable interface did not retain auxiliary data. The applied auxiliary-transport replan expanded task ownership, then the sidecar/consumer path was repaired. The callback was also changed to observe and assert the pointer before dereferencing so a regression produces a complete report.

Four added controls cover missing global storage after valid candidates, pure constants without external storage, case-sensitive global addresses and reentrant generic binding replacement. They first ran with the 70-case intermediate GREEN; no separate missing-behavior RED is claimed for those added controls. The case-sensitive fixture lookup was tightened to exact-case comparison and asserts distinct functions/owners before both dispatches.

The later member auxiliary fixture observed a separate RED: the facade's user data was passed to DetectCallingConvention as though it supplied a member receiver. The batch now detects ordinary thiscall with no auxiliary receiver and retains the recorded address in the callable sidecar.

The setup-only build errors 1f03b833561e4d81a7160eb2e3fdc14e (fixture API arguments/name) and 6b9036f87abf4d9daec1e96ee0cf0434 (fixture field spelling) were corrected before valid proving runs. They are not behavior RED.

The rules-DLL sharing failure 619df032b389447490a0db70ee26ccf2 is a separate, still-open Harness issue. It is not native RED or GREEN. See [external IDE build admission](../implementation/issue-20260908-180555-external-ide-build-admission.md).

## Exact task 2.5 case mapping

| Case | Initial RED state | Member auxiliary RED state | Final state |
|---|---|---|---|
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.CaseSensitiveGlobalNamesKeepDistinctAddresses | Not in initial group | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.CaseSensitiveOwnersDispatchDistinctFunctions | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.FirstParameterMetadataUsesInstalledFunctionAndOwner | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ForeignEngineRejectsInstalledIdentity | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.FreeFunctionAddsThroughContext | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GenericAuxiliaryKeepsExecutingGenerationDuringRebind | Not in initial group | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GenericCallbackObservesAuxiliary | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GlobalPropertyConnectsOriginalStorage | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.IncompatibleCallableOwnerRejectsWholeConnection | Success | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MemberAuxiliaryDoesNotReplaceTheReceiver | Not in initial group | Fail | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MemberFunctionUsesReceiver | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MissingGlobalStorageRejectsFunctionsAndEarlierAddresses | Not in initial group | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MissingTargetRejectsWholeConnection | Success | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ObjectFirstAndObjectLastKeepExplicitArgumentOrder | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.OutAndInOutWriteCallerStorage | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.PureConstantConnectsWithoutExternalStorage | Not in initial group | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ReferenceReturnAliasesReceiver | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ValueConstructionCopyAndDestructionBalance | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ValueReturnPreservesBothFields | Fail | Success | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.WrongSignatureRejectsWholeConnection | Success | Success | Success; errors 0, warnings 0 |

## Shared task mapping

| RuntimeBindings prefix suffix | Task | Final executed cases |
|---|---|---|
| Recording.Store. | 1.2 | 7 |
| Recording.Facade. | 1.3 | 8 |
| Recording.Providers. | 1.4 | 8 |
| Types.Declarations. | 2.2 | 8 |
| Types.Layouts. | 2.3 | 9 |
| Types.Members. | 2.4 | 11 |
| Calls.Native. | 2.5 | 20 |

The 51 prior-task cases refresh adjacent Store/facade/provider/parser/layout/member proof on this final binary. Their original RED evidence remains in their existing verification attachments.

## Report and crash identities

Paths are under Saved/Harness/Unreal/Runs/<RunId>/. Automation report hashes bind AutomationReport/index.json.

| RunId | Report SHA-256 |
|---|---|
| 6a31a39a884140f9958f39f7d3b83bea | 47C7503C2ED9843A8377B4D96563F063634FC8AEE320E49E9FDEC583865809A5 |
| 6cd1fc97a2a644d881f59c271e5c2508 | 02FA83DE05C7010EB00B1D191393B81454020F68F4D897DA1F9701012B298AB5 |
| 311df54a47984ad5a38518a43443a3ca | 09A10545127E1F3F15E2518124EE02850C4A288FFA66980CE7F78739C421DC08 |
| 946164fe25de449e8eeca2c7ce9b7eae | 2912D97BE760323DE46245D6798A08558C665DE64F55DC88902EF9804B976DC0 |
| 3b1fae1c16054584b680de4b520bafdc | DAE9BD33A57B3A8F813389FEDEFD72DD2B24F4F6A603C7FFAF1CC5EFF57DF396 |
| 57dd66955b4c4727ab846a985b3f299e | 252CAAD082212B79C8C1D1442AAF80B00EECADB65BDB546A80E7C2834D0EB818 |
| d2839d2eb88a4774a2401be7b72b8a93 | 6E6998A73493C60B19C34CB748FD4A720DA47A3AB59B6183B9DD281E852810AD |

Interrupted run 8ae4a58ca4774c4db1456afd19601600 has no index.json. Its Command.log SHA-256 is 68D9710ED70A649010F078D5712DA358E72CE809814B42A1CE7212F54F82B345, and missing-report Summary.json SHA-256 is 539D6F1BE9468A9CB92AFEE8D2945C48CC056692D1FC72832CAF9BA6B07BA2A4.

## Source and binary identity

All paths below are relative to the selected workspace. Hashes were captured for the initial RED, the complete member-auxiliary RED snapshot and final GREEN. A dash means the file was outside the initial captured ownership, not absent or proven by that initial identity. The added native batch source did not exist at the initial RED. Final identities were checked again after all four final test runs and matched; source was frozen throughout those builds/tests.

| Path | Initial RED SHA-256 | Member auxiliary RED SHA-256 | Final GREEN SHA-256 |
|---|---|---|---|
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h | D106FD1E0F0F5CBBDF5B860B4142BFF2A9CE1AA8465C5D90AAE1A17A1B6FE735 | D106FD1E0F0F5CBBDF5B860B4142BFF2A9CE1AA8465C5D90AAE1A17A1B6FE735 | D106FD1E0F0F5CBBDF5B860B4142BFF2A9CE1AA8465C5D90AAE1A17A1B6FE735 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp | F7C89431EE03074081EDDDE2BEF6DC6251FA1ED61FADAD71BFE2BC407F9C694A | 4B58C0076A37C5EA7911F416FC8634B6B9B77D6C0C8E72D09BE05A692D3908E1 | 4B58C0076A37C5EA7911F416FC8634B6B9B77D6C0C8E72D09BE05A692D3908E1 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h | 97ABF9CFDB6D1A298A335B2022AA14F5A7A35AB3041ED92C4792C3F70229C4E1 | 404D05FA1697A3C35A118F400490E4D22316A3AAF1C5BB09EC13C8AFDF2CCCD4 | 404D05FA1697A3C35A118F400490E4D22316A3AAF1C5BB09EC13C8AFDF2CCCD4 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h | EB4590D79F3ED6306AA8B7EED7102E00DC0C3CAD7D1DD51922F1B72FB8AC14FE | D7DF598D4F1A0D488DD901F9127D86781B1191C78BB23F50AA68C7A84DF49A14 | D7DF598D4F1A0D488DD901F9127D86781B1191C78BB23F50AA68C7A84DF49A14 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_native_bindings.cpp | — | D14455967B1ED53411EB4F5FC7474700C1EF53AA217CB29B799F132C9139DED1 | 4A28ED6406B1732480CE33764FCF7DE8CDF04FEE4E038B0105D7757D5F96B4D0 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callfunc.h | — | CA3C2894729E638B530995843FBB81039F88BFE19324E4DD07188DE58824B208 | CA3C2894729E638B530995843FBB81039F88BFE19324E4DD07188DE58824B208 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callfunc.cpp | — | DB945F7486EA5F1AE2468B2182D471030AFBDECC2C092708009BDF03940E31B8 | DB945F7486EA5F1AE2468B2182D471030AFBDECC2C092708009BDF03940E31B8 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_generic.h | — | 16BF8E4C8D390425B24C1C0F967BA7153D8989703658EB977EA7BE9C7AFC86CB | 16BF8E4C8D390425B24C1C0F967BA7153D8989703658EB977EA7BE9C7AFC86CB |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_generic.cpp | — | 7B98F98E659713FA8424462A3DDECAEBE7A26C79745EEAD36CF53216653A9C3E | 7B98F98E659713FA8424462A3DDECAEBE7A26C79745EEAD36CF53216653A9C3E |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp | — | FBECA0646102D1D7642B08FEB862202BCD18268D60C9C36D359ECEEB364CF110 | FBECA0646102D1D7642B08FEB862202BCD18268D60C9C36D359ECEEB364CF110 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingNativeTests.cpp | 2F2276AC7E0EB7705FD5C997611D6C97DCE53308BBD77F1F7F422D3FE4CF9213 | EB790306097D7C822A93F0260B158C13F14D8BDCA2ABE411CAEB3AC2B8D19E97 | EB790306097D7C822A93F0260B158C13F14D8BDCA2ABE411CAEB3AC2B8D19E97 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | 9C4DB1ED2729C09E846DDAA024A47F867AC77CC4CFB365BB1202747C2D265789 | 87FB15D9FE8B36CFA6E7B081A32092DF240FD1A76F9B7D21061723E92B3DDA09 | 078255698ACD858F44E06C8777C59B2254CD80D63424C6795599882D0FEF9F93 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | 9A40BDC442D7001877E803070D35AEA5F4F511A467EB6E25EDBA0D64DF03BED5 | 5639A43D9E5ABC4BDBF263F47B60414DD596F45C41CD18F65BA57ADC010D381A | 5639A43D9E5ABC4BDBF263F47B60414DD596F45C41CD18F65BA57ADC010D381A |

## Complete final case inventory

### Shared RuntimeBindings

| Exact case | Result |
|---|---|
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.CaseSensitiveGlobalNamesKeepDistinctAddresses | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.CaseSensitiveOwnersDispatchDistinctFunctions | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.FirstParameterMetadataUsesInstalledFunctionAndOwner | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ForeignEngineRejectsInstalledIdentity | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.FreeFunctionAddsThroughContext | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GenericAuxiliaryKeepsExecutingGenerationDuringRebind | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GenericCallbackObservesAuxiliary | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GlobalPropertyConnectsOriginalStorage | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.IncompatibleCallableOwnerRejectsWholeConnection | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MemberAuxiliaryDoesNotReplaceTheReceiver | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MemberFunctionUsesReceiver | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MissingGlobalStorageRejectsFunctionsAndEarlierAddresses | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MissingTargetRejectsWholeConnection | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ObjectFirstAndObjectLastKeepExplicitArgumentOrder | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.OutAndInOutWriteCallerStorage | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.PureConstantConnectsWithoutExternalStorage | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ReferenceReturnAliasesReceiver | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ValueConstructionCopyAndDestructionBalance | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ValueReturnPreservesBothFields | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.WrongSignatureRejectsWholeConnection | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.CallerVariantsAndPropertyExposureSurviveRecording | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.FunctionTraitsAndCompilePoliciesAreDetached | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.HandlesSurviveGrowthAndRejectSealedEdits | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespaceAndCaseSensitiveTypesDoNotCollide | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespacesEnumsAndConstantsAreRecorded | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NativeRecipesOwnTheirInputsAndPreserveOrder | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ReferenceAndTemplateDeclarationsRetainUEFacts | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ValueLifecycleAndMembersNeedNoEngine | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.DuplicateIdentityNamesBothSourcesBeforeExecution | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.EmptySealedCollectionProducesAnEmptySealedStore | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.LateProviderInvalidatesCaptureWithProvenance | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.OutOfOrderProvidersPreservePhaseOrderAndContributions | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.RecordingFailureReportsSourceAndPublishesNothing | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.ReusingSnapshotNeverReexecutesProviders | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.TargetConditionsAndEffectivePolicyAreCaptured | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.UnsealedCollectionCannotPublishASnapshot | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.CompatibleDeclarationsCoalesce | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.ConflictingNativeDefinitionReportsBothSources | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.EmptyStoreSeals | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.RecordHandlesSurviveGrowthAndRejectForeignStores | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.RepeatedSealPreservesIdentity | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.SealedMutationRejected | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.StoreOwnsInputLifetime | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ConstReferenceMethodAndDefaultAreDetached | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.DefaultExpressionsKeepNestedCommasAndOriginalText | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.EquivalentSpellingSharesIdentityAndRefChangesOverload | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ExplicitVoidAndReferenceDirections | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.InvalidDeclarationsReportOwnedSourceRanges | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.NestedTemplatesAndObjectHandlesResolve | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.PropertyAndStandaloneTypeUseCanonicalTypes | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ReturnTypeConflictCannotPublishCallable | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.BaseCycleReportsItsDeclarationsAndPublishesNothing | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.ByValueCycleIsRejectedEvenWithExplicitNativeSizes | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.CaseSensitiveNominalsKeepIndependentNativeLayouts | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.DerivedBeforeBaseAndForwardValuePropertyKeepNativeLayout | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.EnumAliasAndInterfaceFactsRoundTrip | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.InvalidAlignmentAndOutOfBoundsOffsetFailWithSource | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MissingNominalReportsTheMemberProviderAndDeclaration | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MutualObjectHandleReferencesDoNotFormALayoutCycle | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.UnsealedStoreCannotStartADraft | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.CompilePoliciesUseCapturedBuildFacts | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.ConstAndMutableGlobalDeclarationsHaveMetadataWithoutStorage | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.ConstructorsAndDestructorKeepDistinctBehaviourIdentities | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.DefaultsDirectionsAndNativeFunctionTraitsSurviveFreeze | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.FrozenInstallationRejectsLaterMemberMutation | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.IncompatibleDuplicateSignatureFailsBeforeRegistration | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.MethodAndGlobalOverloadsAreVisibleAfterWholeImageInstall | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.MissingParameterTypePublishesNoImageAndReportsMemberSource | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.PropertyAccessAndOffsetsAreCompleteBeforePublication | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.PureConstantRejectsMutableAndObjectStorageBeforePublication | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.SecondEngineOwnsDistinctImageWithEqualStableIdentities | Success; errors 0, warnings 0 |

### Adjacent NativeEngine contracts

| Exact case | Result |
|---|---|
| Angelscript.UnitTest.NativeEngine.VMNativeABI.InOutInoutAndForwardedReference | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.MultipleInheritanceAppliesBaseOffset | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.ObjectFirstAndLastReachReceiver | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.PaddedReceiverSevenPlusFiveReturnsTwelve | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.PrimitiveWidthsGenericAndTyped | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.RejectsMissingCallerUnsupportedNullReceiverAndThrowsOnce | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.ValueObjectArgumentAndHandleReturn | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.ConcurrentReadersSeeCompleteRetainedGenerations | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.DescriptorLeaseKeepsDeclarationReadableAfterEngineAndProducerRelease | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.InvalidReplacementPreservesInstalledCallback | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.OldGenerationInvokesOriginalAfterReplacementAndExpiresOnRelease | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.ReentrantReplacementCleansTransferredValueExactlyOnce | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.ReentrantReplacementRetainsActiveDescriptorThroughReturn | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.RetiredEngineRejectsReplacementBeforeBindingMutation | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.BindNativeFunctionRequiresRegisteredDeclaration | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.BytecodeWritesNativeRecordValueAndPreservesPadding | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.GenericAddTwentyAndTwentyTwoReturnsFortyTwo | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.GenericInt64BoolAndOutParameter | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.MethodReceiverValueSevenPlusFiveReturnsTwelveWithSentinels | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.NativeSetExceptionReportsVmException | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.NullIndirectCompositeThrowsBeforeWrite | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.TypedCallerAddTwentyAndTwentyTwoReturnsFortyTwo | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.UnboundSystemCallRejectsAtLink | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.UnsupportedThiscallOnFreeFunctionFailsBeforeCallback | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.CompositeInlineAndIndirectHaveDistinctLayoutWitnesses | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.NativeAdmissionRejectsOverflowOverlapPackedAndFrozenMutation | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.NativeRecordPreservesHostOffsetsAndPadding | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.SameKeyDifferentOffsetChangesLayoutHash | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.ActualTypesAndMethodsNeedNoEngineOrNumericIds | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.AdmittedFloatAliasesAndTargetReferencesMatchLayoutQueries | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.AliasCycleIsRejectedWithoutRecursingForever | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.ByValueRecursionFailsWithoutPartialLayouts | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.ConcurrentExternalReferencesKeepTheFrozenGraphAlive | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.ConcurrentFactoriesSerializeOwnershipWithoutAnEngine | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.DefaultArrayAndChildFuncdefRetainSemanticEdges | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.DuplicateIdentityAndNameFailuresDoNotPublishObjects | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.EnumAliasAndFuncdefAreActualOwnedTypes | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.FactoryAndBehaviourQueriesUseObjectsBeforeRegistration | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.FreezeRequiresCompleteSignaturesAndFinalizedLayouts | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.FrozenDependencyLifetimeAndForeignEdgesAreExplicit | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.FrozenImageRejectsNewObjectsAndSemanticEdges | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.ImmutableOptionsDoNotFollowCallerOrOtherImageChanges | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.ImportedLayoutAndTargetCompatibilityAreExplicit | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.InheritanceAndInterfacesRemainLocalDefinitionRelations | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.InheritanceCycleIsRejectedBeforeDraftQueries | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.InvalidNativeLayoutDoesNotBecomeAValidFrozenType | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.LayoutUsesTargetPointerSizeAndAlignment | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.MethodLeaseRetainsOwnerSignatureAndNamespace | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.RejectedSignatureDoesNotPublishOwnerOrParameters | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.SignatureQueriesRetainTypesNamesFlagsAndDefaults | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.MetadataImage.TypeLeaseRetainsRecursiveMembersUntilFinalRelease | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.GlobalDefinitions.DetachedGlobalMetadataDoesNotAllocateExecutableStorage | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.GlobalDefinitions.DuplicateGlobalRegistrationDoesNotPublishNewImage | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.GlobalDefinitions.FrozenGlobalMutationIsRejectedByRegistration | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.GlobalDefinitions.GlobalExternalReferencesAreConcurrentWithoutGraphCycles | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.GlobalDefinitions.GlobalOnlyLeaseRetainsImageAfterProducerAndEngineDestruction | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.GlobalDefinitions.MutableGlobalAndVoidTypeAreRejectedWithoutPublication | Success; errors 0, warnings 0 |
| Angelscript.UnitTest.NativeEngine.GlobalDefinitions.WrongKeyRoleNameNamespaceAndTypeAreRejected | Success; errors 0, warnings 0 |

## Deliberately omitted verification

Quick/Performance/Integration Harness profiles are unrelated to this native binding change. A whole NativeEngine run remains the explicit final shared-contract gate in task 8.4; the bounded adjacent selectors here exercise callable generations, ABI/layout, image registration and native global behavior directly. Full source-compiler declaration suites are not repeated because no shared grammar changed in 2.5. Default runtime startup/provider integration remains in tasks 8.2/8.3. No Review, Git commit, integration or push was performed.
