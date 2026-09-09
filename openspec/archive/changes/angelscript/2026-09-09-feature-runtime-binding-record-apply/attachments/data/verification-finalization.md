# Task 7.10 Finalization Verification

## Outcome

Task 7.10 records non-declaration Runtime contributions as ordered typed effects and applies them to each fresh binding Engine before native connection and publication. The compiled provider set contributes exactly 45 ToString formatters, five skipped function identities, four skipped class identities, 12 reflected deprecation actions, and one direct-finalization probe.

Each Engine owns an independent ToString list and bind-state skip sets. Configuration enum values come from the captured editor policy. A finalization effect that rejects installation names its provider and returns no published owner. The path does not replay a legacy `Register*` callback and does not mutate a shared global effect list.

## RED and implementation evidence

- Initial grouped RED run `b8ac84321d8f4ef2a42068d767b9d50c` failed all five prepared cases before the complete typed-effect path existed.
- Run `eb8b09bcc14145948b8cf1092e8f4e0f` reached fresh Engine creation and crashed at the first ToString effect because the binding-only constructor had not allocated its owner-local list. `CreateForBindings` now allocates that list before Store installation.
- Run `d9f078c823a94392808d9eac5f71296d` passed three cases and exposed missing configuration enum values plus incomplete ToString provider selection. The declaration catalog now carries only task-owned `ConfigEnums` values and type-declaration effects into the installable Store; all 45 compiled ToString contributions are selected and asserted exactly.
- Run `96efd0e8237d470ca914f3bf9f39b410` exposed the engine-only `FVector2f` type-finder call while recording its infrastructure provider. That call is skipped during detached recording while its ToString effect remains captured.
- Applied replans `replan-20260909-111200-finalization-engine-effects` and `replan-20260909-114051-finalization-provider-boundary` correct the demonstrated Engine and provider file boundaries. Strict OpenSpec validation run `4287bdad59e34343be5673d07730f6d0` passed after the latter update.
- The first shared run `a6540c847ebc45eb9c6589664f7b1114` passed 304/306 and showed that copying every type-declaration enum value changed the exact platform and serialization family contribution totals. The repair restricts member carryover to `ConfigEnums`; focused runs `b6b165de85e640a79834918ddc60e750` and `4bd4697c81094ee09285625dc76ea929` restored both completed-family accounting contracts.

## Exact GREEN

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Finalization.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `faaa9e36758644eab53f569632184290` passed 5/5 with zero warnings, errors, skips, or incomplete tests:

- `AllEligibleFinalizersHaveTypedEffects`
- `ConfigEnumsAndDeprecationsFollowCapturedEditorPolicy`
- `EveryToStringContributionIsRecordedAndOwnerLocal`
- `FinalizationFailureNamesProviderAndPublishesNoOwner`
- `SkipRulesInstallWithManualGeneratedReflectionPrecedence`

Final source build `334a260d73924060b9674fe60db5b5b5` succeeded after the adjacent accounting repair. Relevant SHA-256 identities are:

- `AngelscriptTypeBindInfo.h`: `c109451c21ebdbc6d2d52af1d487805cae9d52f1ec62c661ad02dcf50636b8c0`
- `AngelscriptTypeBindInfoStore.cpp`: `767dd0237935daa0a3bcff4c60c090cc11c3a2771a207fcfe7c9af5affc8a5d7`
- `AngelscriptTypeBindInfoCatalog.cpp`: `5133047b7f7d2e24d4d3a96ca34ec9dd9911da94441a89be2b2f92587a59303b`
- `AngelscriptBinds.cpp`: `008584278bf2325536ff8ba830c8c8dad4b6af229390bbfbeb9f8ef9d8330c15`
- `AngelscriptEngine.cpp`: `e72d7423d71b595c8bb2be7399d74e8a7372def4712dafccdf5e093004a6242e`
- `Bind_FString.cpp`: `9157d0c9d2dcfd3144d8b70957216f6bc8f59f3a231b5e0949debbe31557b7bc`
- `Bind_Deprecations.cpp`: `8dd425404bdacc8d481dbe1fc5dc2be38dab024134285f0759c03d1e5d721c53`
- `AngelscriptSkipBinds.cpp`: `c54ab06146f4d5e709575e9e25f1c538738395137e34f8f99efcc86eaa755fcf`
- `RuntimeBindingFinalizationTests.cpp`: `446e3cf352fda1cfb0a460ff99d8266fa57a7ea56c1563177daaf570ce674f59`
- `UnrealEditor-AngelscriptRuntime.dll`: `5033ae28bd4781e4fdc7d67e43216a2294bf94cb80c48f618cc8c5c3cacc1383`
- `UnrealEditor-AngelscriptTest.dll`: `2172315dd11aa3df0062882fac3e77ef761f12cadbaa78259c7e68305f69d3df`

## Shared regression proof

Harness run `456bada88dbb48e0b3b2c65b820ccafa` selected `Angelscript.UnitTest.RuntimeBindings.` and passed 306/306 with zero warnings, errors, skips, or incomplete tests against the source and binary identities above. This covers the affected Store, declaration catalog, effect recording, fresh Engine installation, owner isolation, provider accounting, native connection, and every completed Runtime family contract.

The full NativeEngine selector and dormant-startup baseline remain the explicit terminal gates in tasks 8.4 and 8.3. Harness Quick, Performance, Integration, packaging, legacy suites, and unrelated UE suites were omitted because task 7.10 changes the Runtime binding recording/publication path; the complete RuntimeBindings selection is the matching shared contract.
