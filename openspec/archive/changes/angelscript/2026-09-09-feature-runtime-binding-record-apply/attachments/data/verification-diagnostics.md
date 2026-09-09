# Task 7.8 Diagnostics Verification

## Outcome

Task 7.8 records and installs console variables and commands, logging, debugging, CPU profiling, message-dialog metadata and stats providers in fresh Runtime Engines. The nine providers contribute exactly 62 members and 1 explicit native recipe in Development. The Shipping policy retains complete provider accounting while excluding the Development-only `Console.Commands` provider with the deterministic disposition `excluded-by-condition`.

Invocation remains bounded: the tests use one uniquely named console variable, one temporary log output sink and one balanced profiler scope. They do not register a console command, open a dialog, break into a debugger, or start a debugger service.

## RED and implementation

- The pre-build discovery run `99f21a34b47c4839976ca5ce7567b768` found no diagnostics tests in the prior binary and is retained only as setup evidence.
- Behavioral RED run `0e4b29168acc419883ad167bac657600` discovered the new selection and asserted because `FMessageDialog` requested a target Engine during detached recording. Its namespace now uses the recording-aware `FAngelscriptBinds::FNamespace` scope.
- RED run `33dfc4a5d8d74502931f05f1d50e7b97` progressed to `Logging.Functions` and crashed because Static JIT ABI extraction dereferenced the detached function placeholder. ABI extraction is now gated on a live installed function.
- Run `d272ed1056a34e889cf9ca98513b1547` passed four cases and exposed two fixture contracts: new console variables defer while the dormant global engine is uninitialized, and log delivery is threaded. The fixture now pre-registers its isolated variable and flushes the temporary sink before inspection.
- Run `c4da85626d8440f282b125d8d703a213` passed five cases and showed that Unreal's default unregister operation retains console-variable state. Cleanup now requests non-retained removal and verifies the name is absent.
- Source inspection invalidated the planned editor-only case: the task providers have no editor-only callable. `Console.Commands` is instead unavailable in Shipping. Applied replan `replan-20260909-102527-diagnostics-conditional-surface` records the correction and the new conditioned-provider registration path.
- `Debugging.Manual` no longer installs its editor end-play delegate while detached records are being captured.

## Exact GREEN

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Diagnostics.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `dc2892f2a71f4e488209b9fb7ac2a8bb` passed 6/6 with zero warnings and zero errors:

- `CompileOutPoliciesDistinguishDevelopmentAndShippingInputs`
- `DialogMetadataExistsWithoutInvocationAndProvidersAreAccounted`
- `FormattedLogReachesTemporaryOutputSink`
- `ProfilerScopeBalancesConstructionAndDestruction`
- `ScopedConsoleIntegerReadsWritesSevenThenIsRemoved`
- `UnavailableDevelopmentOnlyConsoleSurfaceIsExcludedWithReason`

Final build `2d14054aa2414cc0882eadd83193c411` succeeded. Relevant SHA-256 identities are:

- `AngelscriptBinds.h`: `05937749287fa1827eb96a356a54fd74bfc80be87e343ebabeffcdb449c4aa46`
- `AngelscriptBinds.cpp`: `1007fb9d76ff63a7609fd62a1b563c6924b05a842a31eca8499b85b67ef06a2e`
- `Bind_Console.cpp`: `85c6ddf2aaff73e719ed457f4cec740dc43be1648589e58ffc3f21b164ecec73`
- `Bind_Debugging.cpp`: `f9279bfbff8cf37f5b1c45211e3cb205d57ecf654bd6797735e34cffd94f3f16`
- `Bind_FMessageDialog.cpp`: `dce09c29f07264a4bb8906f94ba42b6a9a728e39bfc5e9518c32250d9f39b5af`
- `Bind_Logging.cpp`: `9c9e52c6029392802bbc8f8dca45b7fafdefac65ace68e49c907ce83b3536b4b`
- `RuntimeBindingDiagnosticsTests.cpp`: `93c630b1547e377a618b27ef35875707bcd9eacb9184d08eb32bb27855f5e4df`
- `UnrealEditor-AngelscriptRuntime.dll`: `2d9dcd389464f6baaf48ad61f1d397c39d3606577fddeb1cebea9d62b4cb3522`
- `UnrealEditor-AngelscriptTest.dll`: `0a1a7b5577c3fe43d85edf3c21c3a1c6cc5c46e0b30dc6675b29bdf10aa80c30`

## Shared regression proof

Harness run `478efd0fca024e1b92a2c79a352a4b81` selected `Angelscript.UnitTest.RuntimeBindings.` and passed 296/296 with zero warnings, errors, skips or incomplete tests against the same binary identities. This is the affected provider recording, policy, declaration, native-link and owner-lifetime scope. No broader suite was selected because the demonstrated impact remains inside RuntimeBindings.
