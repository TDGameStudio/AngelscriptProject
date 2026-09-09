# Task 6.6 — static libraries, mixins and explicit world context

## Outcome

Reflected function records now retain static/function-library classification, an optional object-first mixin receiver, world-context parameter identity and determines-output parameter identity. Function-library callables install either as globals in the library namespace or as methods on the captured mixin target. Mixin declarations omit the injected receiver while static declarations do not consume an unrelated object.

The engine-local library adapter injects only the selected mixin receiver and explicit world context into the native parameter frame, validates all remaining typed arguments, derives output type from the named object/class parameter, invokes the function-library CDO and restores the previous world context on success or every failure edge. A missing required context is diagnosed without publishing an ambient default.

Generic reflected fallback now copies non-reference UObject inputs from `GetArgObject`. This preserves the implicit-handle ABI for both the cached `UFunction::Invoke` path and the ProcessEvent path; treating `GetAddressOfArg` as pointer storage had copied bytes from the UObject itself.

## Behavioral RED

Build `f2ceb13dec4d4372a809b05ae6770688` succeeded with the final six-case test shape and declaration/installation surface. Exact run `8cd31f0a53564a84bb34d10843d2a130` failed all 6 cases because reflected function-library invocation was deliberately left unavailable:

- `DeterminesOutputTypeMatchesIntendedObjectParameter`
- `FailureRestoresPreviousExplicitCallScopeWithoutAmbientDefault`
- `MissingRequiredWorldContextIsDiagnosed`
- `ObjectFirstMixinMutatesOnlySelectedReceiver`
- `StaticHelperWritesOnlySelectedArgument`
- `SuppliedTransientWorldIsObservedAndPreviousContextRestored`

The earlier unity compile failure from a generic `FFixture` name was setup failure and is excluded from RED evidence.

## GREEN

- Build `a512217bb6b74ae18feeb52ac84dae18`: `AngelscriptProjectEditor` succeeded.
- Exact run `4a146dd8d6f342bf940792d3ba06c80a`: all 6 `Angelscript.UnitTest.RuntimeBindings.Reflection.Mixins.` cases succeeded, with zero warnings, errors, skipped, not-run, or incomplete cases.

The two receiver cases execute the installed generic callables: the static helper is resolved from the function-library namespace and the mixin is resolved as a method on its target type. The remaining cases use the typed installation adapter to inspect diagnostics, explicit context lifetime and determines-output identity.

## Identities

Final SHA-256 identities:

- `AngelscriptTypeBindInfoReflection.h`: `AC2CAB832D8A5C124ADBEA44570F0D62F0200EC1BC27DF39148B714090352874`
- `AngelscriptTypeBindInfoReflection.cpp`: `93F95FECEDAB9099D8ABC63D9B4BA7825D4BCB160A3E6FBBED7CA617A56A500E`
- `AngelscriptTypeBindInfoApply.h`: `DC7CC805B88D2A14C141B391801C55C84D1430FEDEB9AE6E80079B5C6337E1F7`
- `AngelscriptTypeBindInfoApply.cpp`: `FEA8F3F2946D3A855467343B10E730233691B1D9A1A1E48A4E90A8FF8FCD62DE`
- `BlueprintCallableReflectiveFallback.cpp`: `382503674063324A08BBD007766A3A74D0615CCF88FE2012A44EB51399D4604B`
- `RuntimeBindingMixinTestTypes.h`: `A4638CE5BF321F71A1B394F587CB4149F098DFE0FC34FF754104040AECC82E63`
- `RuntimeBindingMixinsTests.cpp`: `B55CD825B1E1EAC5A0A65CB9F0B4002CDC2D65767B009A8EC927B6FFF202DEE1`
- `UnrealEditor-AngelscriptRuntime.dll`: `5A48D71A89C5110EAB35B4A94AA30048E2A685BE2070279DF35888314F6B3A8D`
- `UnrealEditor-AngelscriptTest.dll`: `0B8135E50D103D967D8EE62FB137ABE32B6D1B02253601F7FC96BD4572F42CE5`

No expanded RuntimeBindings, NativeEngine, baseline, packaging, performance, JIT or legacy suite was run. The exact selector exercises the new metadata, both namespace/method installation shapes, cached generic implicit-handle dispatch, explicit typed dispatch, receiver isolation and scoped world-context rules. The dormant legacy fallback tests remain outside the enabled replacement corpus.
