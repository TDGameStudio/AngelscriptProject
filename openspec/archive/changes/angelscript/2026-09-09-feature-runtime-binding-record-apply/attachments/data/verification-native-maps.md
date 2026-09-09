# Task 6.4 — native function maps and alternate transport

## Outcome

Detached binding snapshots now own immutable native function-map records, including module, symbol, signature, ABI, version, source provenance, caller, and address. Store coalescing preserves an equivalent manual binding over a generated contribution and permits a real address to complete a compatible placeholder. Each installation copies the configured maps into owner-local state.

The installation API validates and atomically installs an explicit alternate table. It rejects missing symbols and mismatched module, version, signature, ABI, or thunk identity before changing the active table. Invocation constructs the recorded native call frame and dispatches through the selected thunk. Destroying one installation cannot invalidate another installation's map.

`Bind_NativeModuleFunctionBinding` records the configured modular-feature views when that backend is compiled and the provider is recording. The selected Editor Development target has `WITH_ANGELSCRIPT_NATIVE_MODULE_FUNCTION_ADDRESS=0`, so the always-compiled Store view supplies the configured-transport fixture without altering generated host files or the installed engine.

## Behavioral RED

Run `5b0bdc3723ca45089df5a6b9f0fc14f4` executed the exact seven-case selector after the public operation skeleton compiled. All 7 cases failed because native-map coalescing, installation, validation, invocation, and owner isolation were not implemented.

The earlier build attempt `a555...` was a setup failure caused by a non-const alternate-installation method and is not behavioral RED.

## GREEN

- Build `eddff851634b4a8f8029df7f4fc905b9`: `AngelscriptProjectEditor` succeeded, 98 of 98 build actions completed.
- Exact run `236904ac6b3b42e0b091d9322195a90e`: all 7 `Angelscript.UnitTest.RuntimeBindings.Reflection.NativeMaps.` cases succeeded, with zero warnings, errors, skipped, not-run, or incomplete cases.
- Expanded run `89536374f8544c6bbc4dd272eb820122`: all 228 discovered `Angelscript.UnitTest.RuntimeBindings.` cases succeeded, with zero warnings, errors, skipped, not-run, or incomplete cases.

Exact cases:

- `ConfiguredTransportInvokesAddTwoAndThree`
- `DestroyingOneOwnerLeavesOtherNativeMapUsable`
- `EquivalentExplicitAlternateTableInvokesAdd`
- `ManualBindingWinsEquivalentGeneratedContribution`
- `MissingSymbolFailsWithSourceProvenance`
- `PlaceholderIsCompletedByRealNativeAddress`
- `WrongModuleVersionAndSignatureAreRejectedWithProvenance`

An intermediate exact run `fed705...` passed 6 of 7 cases. Its configured-provider fixture assumed the conditional modular-feature provider was compiled; the target configuration disproved that assumption. The final fixture records the same bridge view through the unconditional Store API, while the provider integration remains guarded by the real build macro.

## Identities

Final SHA-256 identities:

- `AngelscriptTypeBindInfo.h`: `111A9CF54BCE279EFD5664E85AC6747364E862817CCCE615D4B5E187183DAE39`
- `AngelscriptTypeBindInfoStore.h`: `280C5666E5B74E824876FE337B72B9FF579509C95081D9DD4C40FDF8B6E1B8D0`
- `AngelscriptTypeBindInfoStore.cpp`: `C849B2034F83E1DF3682EA2F1A61A69171BBB20D858B4316329316592E5E63F7`
- `AngelscriptTypeBindInfoApply.h`: `8C527F867603326C3E4BE4D3136A7AB3D6DBFAFEFE093F5065C9072B03ABA0E9`
- `AngelscriptTypeBindInfoApply.cpp`: `F4135C7BB18ADC032151F9C933F534900FC8F3CF4B2B982DCF11CF30A5B407D6`
- `Bind_NativeModuleFunctionBinding.cpp`: `9194620567E54DABF9F1F9458045B8D7BE5E4D8BD4CF4B7EBAF23C6748A60209`
- `RuntimeBindingNativeMapsTests.cpp`: `64E91CE350CD1E5C84B9058D9D6188B1CAE799A564051D37CBE88FAAC20E3CE5`
- `UnrealEditor-AngelscriptRuntime.dll`: `E944E8B7251670D13AAD329FAF750423EE20C1DA948687A49BEF3C47CC8D3054`
- `UnrealEditor-AngelscriptTest.dll`: `C1E5E481135B66FF6B69101AE893B123DA6BF8F852374F2E1FE6CC35C83DD919`

No broader NativeEngine, baseline, packaging, performance, JIT, or legacy suite was run. The complete 228-case RuntimeBindings selection covers the changed Store, installation, invocation, isolation, and adjacent family contracts; final NativeEngine and baseline gates remain owned by tasks 8.4 and 8.3.
