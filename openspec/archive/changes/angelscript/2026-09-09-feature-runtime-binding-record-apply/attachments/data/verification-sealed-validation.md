# Task 1.8 verification: sealed-record validation

## Outcome

`FAngelscriptTypeBindInfoValidation::ValidateSealed` now validates an immutable Store without creating or registering a native Engine. It rejects recording failures and incomplete provenance, then reuses the existing declaration parser, nominal dependency resolver, layout checks, member completion, image freeze, and canonical definition checks through `FAngelscriptTypeBindInfoApply::Prepare`. A final read-only pass checks required native callable recipes/targets and global storage. `CreateForBindings` runs this gate before allocating its native Engine and preserves the validation stage and diagnostic on failure.

## RED and corrections

Build `7ca1d5393ae24e2db0780d84d08e7eb0` succeeded with the seven-case fixture and a deliberately unimplemented validator. Harness run `04292f90e9ec414089a6fa5fe9f50fc5` completed all seven cases with seven expected behavioral failures, zero warnings, and seven errors. This proved that the existing factory allocated before semantic validation and that there was no reusable sealed-record validation surface.

After implementation, build `0de97850b7a042ff98d9016cee6cf75e` succeeded. Run `d6ec655bdaf94395a48b437b7abf006f` passed five cases and exposed two fixture assertion mismatches: the established base-cycle diagnostic names both involved declarations instead of containing the literal word `cycle`, and `ReportFailure` returns false because recording a failure is itself an unsuccessful transition. Those assertions were corrected without changing product behavior. Build `227232139e7a4a7989761b2cdd50358d` then succeeded.

## GREEN

- Exact selector run `63c5d566a970483490eab2dfc2f77ee8`, `Angelscript.UnitTest.RuntimeBindings.Recording.Validation.`, completed with 7/7 successful, zero warnings/errors/skipped/not-run/in-process, process exit 0.
- Shared affected-contract run `a7bd48d72b544a86bd57072fcd0c8956`, `Angelscript.UnitTest.RuntimeBindings.`, completed with 115/115 successful, zero warnings/errors/skipped/not-run/in-process, process exit 0. This refreshes the affected Creation, Recording, declaration/layout/member, native connection, and ownership paths after splitting Prepare from Engine registration.

The exact cases were:

1. `BaseAndByValueCyclesFailWhileForwardBaseAndHandleCyclePass`
2. `InvalidProvenanceAndRecordingFailureAreRejected`
3. `LayoutAndPropertyBoundsFailAtTypesStage`
4. `MissingNativeTargetFailsBeforeEngineAllocation`
5. `MissingNominalAndMalformedMemberNameTheirSource`
6. `RepeatedValidationAndRejectedMutationPreserveTheStore`
7. `ValidPairAndGlobalsValidateWithoutEngineOrProviderExecution`

## Verified identities

- `Core/AngelscriptTypeBindInfoValidation.cpp`: `F68E89C75C1F6B6C696A5CDAD7865C3A109B18D730091665BC235DD5CF374182`
- `Core/AngelscriptTypeBindInfoValidation.h`: `ABFF0956CF918156A241ABD7D384671EF727AC02B161BEEA89AC8F25B5C187D2`
- `Core/AngelscriptTypeBindInfoApply.cpp`: `1D8A442A024BF06A2979DB37E870DE43DD9D6EDC2537869DA60737A1DA05BA1A`
- `Core/AngelscriptTypeBindInfoApply.h`: `6CD536E6D7DD3832FA6E0BE3F48C9A0F66483FD6D006082EA337AD6F7EBF797C`
- `Core/AngelscriptEngine.cpp`: `3F6ACBAC54A35535F7A5F8A7C1EB256E4B3A50547A59263DF64605A54A53EC77`
- `RuntimeBindingValidationTests.cpp`: `ADEEFC7B35CC2A5A82684487C127230C02FA497008F15592FBB0E6B16FBC9B2F`
- `UnrealEditor-AngelscriptRuntime.dll`: `CFC02E20CE68B555A8C787586F26C31E4BE097D6432206ED22371403CFB55F03`
- `UnrealEditor-AngelscriptTest.dll`: `3BE8CF5D437DE71AF48C691BD40F2A59D3116109A6B09C1B3E6DFF269A2ABF64`
- Exact Automation report: `E10C432D5B875798A8DC1FEDA0BB1229E51EB7921C878CED9A046200823FC505`
- Shared Automation report: `A1E4C30428ED568CC6DD867F233FCA02660DEFB44529480378BD68195B669478`

No broader baseline or full Unreal build was selected. The complete affected RuntimeBindings contract passed, and this task does not change dormant startup or non-binding runtime behavior.
