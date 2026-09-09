# Task 6.3 — reflected object and struct installation

## Outcome

The detached reflection snapshot now installs class inheritance and interface edges into each binding owner and exposes owner-checked adapters for reflected property access, native struct lifetime, and UObject retention. Property operations resolve against the exact reflected owner record, preserve read/write policy, and use the captured `FProperty` recipe. Struct operations use the captured initialize/copy/destroy recipe. Retained UObjects live in engine-owned strong references and are released with the installation.

The fixture uses unique reflected type names per case. This matters because dynamic `UClass`, `UScriptStruct`, and `UEnum` objects remain visible in Unreal's loaded-object registry until collection; reusing short names made a later full catalog snapshot observe mutually incompatible definitions.

## Behavioral RED

Run `e4d0d4d416974672be378bd228543433` executed the exact selector after the seven cases compiled against explicit operation stubs. All seven cases failed because the per-installation reflected adapters were absent or returned failure:

- `ParentAndChildPropertiesAccessOnlyTheirObject`
- `InterfaceLookupIdentifiesConcreteImplementation`
- `NativeStructCopyOwnsIndependentStringStorage`
- `EnumPropertyRoundTripsUnderlyingValue`
- `ReadOnlyPropertyRejectsMutation`
- `TypeFromDifferentOwnerIsRejected`
- `EngineOwnedReferenceRetainsAndReleasesUObject`

Fixture-only setup defects found during RED were repaired before claiming behavioral evidence: dynamic classes received a valid native constructor/within class, the concrete interface fixture uses `UStaticMeshComponent`, and the parent property is addressed through the installed parent type.

## GREEN

- Build `be2240011e904701815d002bd8dffdc4`: `AngelscriptProjectEditor` succeeded after the final fixture isolation repair.
- Exact run `c0d5b24a9267410f9350bc793bd38315`: all 7 task cases succeeded, with zero warnings, errors, skipped, not-run, or incomplete cases.
- Expanded run `c9b308ab2795491c9268c37fcfd213ca`: all 221 discovered `Angelscript.UnitTest.RuntimeBindings.` cases succeeded, with zero warnings, errors, skipped, not-run, or incomplete cases.
- Adjacent definitions run `e1df991033d641bc92c988c8755a42e1`: all 13 `Angelscript.UnitTest.RuntimeBindings.Reflection.Definitions.` cases succeeded.

The first expanded run, `8931f2f8d6574bc4bce0bf8c33e1fdae`, exposed the fixture collision: 36 cases failed from repeated `::UBindingChild` definitions left by the new tests. Unique per-fixture native names repaired the shared registry pollution; the 221-case run above proves the repair across the complete current RuntimeBindings selection.

## Identities

Final SHA-256 identities:

- `AngelscriptTypeBindInfoApply.h`: `1FA1F4F682FE7E7342EF9BA27A6D1E19F6D813207D495A0C77E3D9434440B46A`
- `AngelscriptTypeBindInfoApply.cpp`: `3839A704DD37D29BA12993554FDE15580E96B9C75667CF6B3457BEDAF2E7FC05`
- `AngelscriptTypeBindInfoReflection.cpp`: `EAFBD2B56B3E9BB28B2F9F1E433D8FA0CBD2ABEDC0A743B312906DE5DF24A5E5`
- `RuntimeBindingObjectsTests.cpp`: `9072C02438497BC58A8F6BCB20DB32135FF59DCF759BA914C738A6A6FB34D303`
- `UnrealEditor-AngelscriptRuntime.dll`: `7BB906752ED4DB5CFCF666E97E5FFD2FDD1796BA6A61A838961D859AD647C046`
- `UnrealEditor-AngelscriptTest.dll`: `D7485CFAB5756018762ED073594C06F9348475A3011CB762824206B7B034CCAE`

No broader NativeEngine, baseline, packaging, performance, JIT, or legacy suite was run. The 221-case RuntimeBindings selection covers the affected shared snapshot, metadata installation, value/container, isolation, and ownership contracts; final NativeEngine and baseline gates remain owned by tasks 8.4 and 8.3.
