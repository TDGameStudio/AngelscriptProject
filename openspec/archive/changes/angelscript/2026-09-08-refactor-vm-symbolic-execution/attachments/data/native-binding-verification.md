# Native binding generation and runtime layout verification

Captured 2026-09-08T12:09:44.516025+08:00. Task 7.4 resolves Y01 and the remaining F02 native/parameter-layout clauses. Final 11.4 acceptance and immutable re-evaluation remain separate.

## Actual grouped evidence

| Stage | Run | Actual outcome |
|---|---|---|
| First six-case RED | 55912995d80c48f88752c14314b8cd7d | Five assertion failures; invalid-replacement control already succeeds. |
| Refined seven-case RED | a6673a97354541ad964c03bb17cef1c5 | Six assertion failures, one existing valid control. Missing owning acquisition stops dangerous callback execution; retired Bind reports MissingDeclaration instead of Retired. No crash. |
| First shared VM attempt | 1544c10106e24887a5f5c6ff2581f22b | 370/455 Success, 85 assertion failures. Six native-generation cases succeed; parameterized binding rejects because frozen declarations have no VM parameter offsets. |
| Runtime-layout handoff | 77c2dd89fd574b69a6e40e77fdd2058c | 453/455 Success, all seven generation cases succeed. Two shutdown-drain destructor counters expose premature current-binding release. |
| Final build | a4929db98d08414abab2ea74e31e35e6 | Succeeded. |
| Final shared VM | b8635307b314450a94b7ad8f60dde702 | 455/455 Success, including all seven native-generation and both shutdown regressions. |
| Native-generation stomp run | 43a848e5413640d59b2f378319671f2e | 7/7 Success; -stompmalloc used after owning acquisition and cleanup exist. |

The earlier compile 6cda8c1ae4e5404e9af903eaf1ae06d3 failed from an unsynchronized CallFunctionCaller definition; 7dbd19800b4a456a87bc41237adec0f3 repaired it. Compilation failures are not behavioural RED. The layout/retirement iterations remain visible above; no failed aggregate is called GREEN. Additional immutable-layout assertions were added when shared failures demonstrated the omitted layout handoff, not retroactively claimed as the first RED.

## Implementation and independent observations

- BindNativeFunction validates and prepares a private descriptor and call frame, then publishes under executablePublicationMutex with live generation/retirement checks. Invalid preparation leaves the prior map entry intact.
- AcquireSystemInterface returns shared ownership. Generic, typed caller, Thiscall1, lowering and native destructor dispatch retain a generation through callback and cleanup. The descriptor also retains its original declaration image. A replaced generation is reclaimed on final release.
- asSVMCallFrame stores derived parameter offsets and storage sizes in runtime records. Lowering/binding no longer call CalculateParameterOffsets on frozen declarations. Context argument setup and nested restoration, Generic getters and explicit host-call parameter stacks consume runtime layout.
- Retirement stops new admission and removes metadata/executable public visibility. The Engine retains only the last installed native descriptor per key as its cleanup lease through remaining GC/object drain and releases these shared map entries at final Engine destruction. Replaced historical generations are not accumulated.

| Exact public case suffix | Independent oracle |
|---|---|
| ConcurrentReadersSeeCompleteRetainedGenerations | Two readers invoke 400 acquired callbacks during 100 replacements; each returns exactly 41 or 42, zero missing/partial results; independently held original still returns 41. |
| DescriptorLeaseKeepsDeclarationReadableAfterEngineAndProducerRelease | After Engine and producer release, binding lease preserves actual Native declaration name/signature; final reset expires the descriptor. |
| InvalidReplacementPreservesInstalledCallback | Unsupported replacement returns InvalidArgument; previous callback still returns 41 and declaration sysFuncIntf stays null. |
| OldGenerationInvokesOriginalAfterReplacementAndExpiresOnRelease | Held old callback returns 41, current callback/context returns 42; weak old generation expires only after final old release. |
| ReentrantReplacementCleansTransferredValueExactlyOnce | Real allocated value argument 41 survives callback; self-replacement keeps active descriptor, cleanup frees and nulls its transferred stack slot, later Unprepare succeeds; frozen declaration offsets/size remain unchanged. |
| ReentrantReplacementRetainsActiveDescriptorThroughReturn | Callback replaces itself; weak old descriptor stays live inside callback, original result 41 finishes, old expires after return, next Context executes 42. |
| RetiredEngineRejectsReplacementBeforeBindingMutation | Retired Engine returns Retired for replacement before metadata lookup/mutation. |

Full prefix for every row: `Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.`. The shared report also individually contains Success for `VMShutdownDrain.RetainedObjectDelaysDestroyUntilFinalRelease` and `VMShutdownDrain.ShutdownAbortsSuspendedAndReleasesRoot`: destructor count reaches one after final object/root release.

## Commands and frozen provenance

Shared proving command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM'; Fast = $true; NoWait = $true; TimeoutMs = 600000 }`.

Memory-checking command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime'; ExtraArguments = @('-stompmalloc'); NoWait = $true; TimeoutMs = 600000 }`.

Source SHA-256 `df5421a34bc732fe169889c26195c441762ed0a0883e83c0f53d7b794f03163e`, 2317 entries, full inventory Saved/native-generation-final-identity.json. Writers stayed frozen across the final build/runs. Shared report SHA-256 `853d7338791a7c6d6130722f1da408aacd952e0d0d4c94e5f10657058f6410a9`; stomp report SHA-256 `08ef991393036d0d217439af27a032da41d0d1c4a6859c5882f80e4058f67fff`.

| Binary | SHA-256 |
|---|---|
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptEditor.dll | 38b28dec8314c2252116a42e77822c4346c6efce88ab8267b14c77fb41797087 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | 9406956903bffc57a5b831789938ef48473cfcef210b24067162643983a620be |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | 7714b43542c014b83356d542301004a49d557fe83b52c1fc3328942ec1444b79 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTestJIT.dll | 93d55dadfad9fcdfc18a091ead9133ce77da193b4ea3296a2a267649da8ace5e |

Shared VM: 0 reported warning events; 0 cases with warnings.

Native stomp: 1 reported warning events; 1 cases with warnings.
Warning sample: LogHttp: HTTP request timed out after 3.00 seconds URL=https://www.google.com/generate_204

The shared VM superset is justified by changed Context/Generic/native layout and shutdown contracts, including 112 source consumers. Full NativeEngine/Baseline are reserved for final 11.4 on this same binary. Unrelated Quick, Performance, Integration and full UE suites are omitted because their contracts are not affected. Memory checking is bounded evidence, not exhaustive race detection, fuzzing or a native sandbox.
