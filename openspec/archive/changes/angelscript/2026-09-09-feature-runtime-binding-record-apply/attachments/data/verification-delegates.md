# Task 6.8 — native delegates, multicast delegates and reflected events

## Outcome

The Runtime binding installation now owns explicit native adapters for single-cast and multicast script delegates, copied payload frames and reflected Blueprint events. Delegate targets are validated against the requested `UFunction` signature before mutation. Every subscription, retained payload and reflected-event record belongs to one Engine installation; foreign-owner execution is rejected and owner destruction clears its live subscriptions without changing another owner.

Payloads are retained as copies of their actual `UScriptStruct`, independently of the caller frame. Execution creates and destroys the reflected function parameter value around `ProcessEvent`, and unbind explicitly releases the retained struct scope. This preserves native copy/destructor behavior rather than treating a `UFunction` parameter frame as the retained value type.

The selected Runtime providers now record detached declaration surfaces without consulting the live target type database. Delegate and Blueprint-event dynamic type scans remain live-only; fixed helper globals still record. `FLatentActionInfo::CallbackTarget` records with its native `TWeakObjectPtr<UObject>` layout. Reflected function recording accepts an optional native-type selection so a bounded fixture can record only its receiver while the default remains the complete snapshot.

## Behavioral RED

The first fixture runs were excluded because setup stopped before reaching behavior: runs `a27e523067ef4c98ad3205c1c6f63197` and `1b4dd0b31af44deba824e85a0e3a3285` mixed snapshots, run `1ae8a4d3dbd7466191c7ffdc066692f3` queried the live Blueprint-event type database, runs `5731ca36545a420cb4ce2b7110ac42f7` and `b9a029a962d840798ca2c735de17fdc8` exposed the latent weak-pointer declaration mismatch, and run `975c8230b54346068f3d40a2ec5b7be6` traversed an unrelated loaded reflected function. None is claimed as behavioral RED.

After those fixture boundaries were repaired, build `ea989a28b2574dd7826f4d9b0bb66fa1` succeeded against the final six-case test shape with the four delegate/event entry points temporarily unavailable. Exact run `9aaca5c51dbf4e6ba0b60308cfd5a30d` selected all 6 cases and all 6 failed with one expected adapter error each:

- `DestroyingOwnerReleasesItsRegistryWithoutAffectingAnother`
- `MulticastInvokesTwoAndRemovalPreventsRemovedCall`
- `NativeSubscriberExecutesOnce`
- `PayloadSurvivesCallerFrameThenReleasesAtUnbind`
- `ReflectedEventArgumentAndOutSignatureMatchesFixture`
- `WrongSignatureAndForeignOwnerAreRejected`

The temporary unavailable branches were removed after this run. The restored `AngelscriptTypeBindInfoApply.cpp` SHA-256 was `7E4B1763081D13FA3B931AFC6FAA02793ADAB33B228E2C33B6876C7B6FB3C83E`, exactly matching the pre-RED green source.

## GREEN and diagnosis

An intermediate complete run `1cc11f85ef764e4ab30ad7f2ddc5e6a4` passed 5/6 cases and isolated payload release. The live counter observation in `04a57a67aea5408e8e4ff0e3296599fe` showed that call temporaries copied and destructed correctly while unbinding a retained `FStructOnScope` typed as `UFunction` did not dispatch the payload struct destructor. Storing the actual payload `UScriptStruct` and explicitly constructing/destructing the reflected call parameter fixed that root cause; focused run `7621815d238c4b48a504f0221951a06e` passed. The earlier CPU loop was caused by test-local destruction order: stack delegates were destroyed before the installation that held their subscription addresses. The final fixtures declare registered delegates before their installation owners, matching the teardown contract.

- Final build `a40ef37ecd7d40fbaaf5c0e138812072`: `AngelscriptProjectEditor` succeeded.
- Exact run `cc11a5c973f24b9e84d7ce178c03e5be`: all 6 `Angelscript.UnitTest.RuntimeBindings.Reflection.Delegates.` cases succeeded; zero warnings, errors, skipped, not-run or incomplete cases.
- Shared run `e2c94826140e40af957bb54e08dde9c3`: all 254 `Angelscript.UnitTest.RuntimeBindings.` cases succeeded on the same final build; zero warnings, errors, skipped, not-run or incomplete cases.

The exact cases prove single-cast invocation, two-subscriber multicast invocation/removal, retained payload execution and destruction at unbind, reflected Blueprint-event in/out directions, signature and foreign-owner rejection, and isolated registry teardown.

## Identities and scope

Final SHA-256 identities:

- `AngelscriptTypeBindInfoApply.cpp`: `7E4B1763081D13FA3B931AFC6FAA02793ADAB33B228E2C33B6876C7B6FB3C83E`
- `AngelscriptTypeBindInfoApply.h`: `878E109BBC13076BB632F45E741C25D90FB5A40B944D71CB7DA44D20EE440E3A`
- `AngelscriptTypeBindInfoReflection.cpp`: `3C204F7D2F5197D200F951F3D11C524052E1413A90B8146917CB7E03C5F41D3E`
- `AngelscriptTypeBindInfoReflection.h`: `F783E6CFEF2B3FBE69A352F590F1C22E802300ADD381CFB686F78DA824F9D9D1`
- `Bind_BlueprintEvent.cpp`: `ECB3F911A59792FD046539C7F788FFC2CDE27482A3CF485379FEBDE98EDF941C`
- `Bind_Delegates.cpp`: `5595159A4CD89A84A63DF3DB850F92E5E9481D735414896DE349F8E78A8ECE51`
- `Bind_FLatentActionInfo.cpp`: `C5EBA69972042D2EEC9AEA38C8ADE293F8F7DD97EA8F35BB1E6CE8AC76EE27BB`
- `RuntimeBindingDelegatesTests.cpp`: `A04F5ADCF1E198C8CC9A914CE6F09BF4B11ABC6F93CC41122EAD30C5AE857BD1`
- `RuntimeBindingDelegateTestTypes.h`: `9C3FB666139413CC02B7AB8EE09B51DB6C199F0DE9EBF8F1058C31D00DD310CF`
- `UnrealEditor-AngelscriptRuntime.dll`: `CCBDC70EC0CB1E78636EA7DB5234FE05CFF22C5F4FAE0BD276B30369DAFF767B`
- `UnrealEditor-AngelscriptTest.dll`: `2F1FD9F695EB750782D5E316404BFDAAEC03E333F1C92EA729DA05DA9A9D324F`

Baseline, NativeEngine, packaging, performance, JIT and legacy suites were omitted. The exact selector proves this bounded delegate/event outcome, and the complete current RuntimeBindings selection covers the shared reflection and installation contracts changed here. Final whole-surface nodes own the later baseline and NativeEngine gates.
