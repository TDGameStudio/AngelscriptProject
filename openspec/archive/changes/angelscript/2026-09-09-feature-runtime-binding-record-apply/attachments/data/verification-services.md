# Task 7.9 Services Verification

## Outcome

Task 7.9 records and installs subsystem accessors, system timers, game-instance and local-player members, and the two explicitly contextual Runtime test-helper providers in fresh Runtime Engines. The selected reflected snapshot contributes exactly 226 members and 12 explicit native recipes across the six service providers. The callable parser also preserves the existing `allow_discard` suffix used by the test helpers.

The invocation checks stay fixture-owned. They create and destroy one transient world, install no ambient AngelScript owner, start no default script services or legacy test pool, and release timer handles and fresh Engines before completion.

## RED and implementation

- The first implementation run `630d7f4af0d5430d8d9a280a8bc250b0` passed four cases and showed that a newly scheduled timer remains in `FTimerManager`'s pending set until a later frame. Advancing only elapsed time did not promote it; advancing the frame before both elapsed ticks invoked the looping fixture twice.
- The final fixture performs a zero-time promotion tick, advances `GFrameCounter`, and then advances beyond the timer interval. This produces one callback. It invokes the installed `System::ClearAndInvalidateTimerHandle` binding, verifies the handle is invalid, advances another frame, and proves no second callback occurs.
- Detached subsystem recording now consumes the store's captured reflected snapshot instead of querying the ambient Engine/type database. Its explicit library functions and reflected native subsystem accessors therefore remain tied to the fresh snapshot and target policy.
- Runtime test-helper recording uses explicit providers and a recording-aware namespace scope. Without an active method leaf, the installed `FAngelscriptTest::GetTestWorld` function raises the existing explicit diagnostic instead of activating legacy automation state.
- The existing helper declarations use a callable-level `allow_discard` suffix. Applied replan `replan-20260909-103907-services-allow-discard-suffix` added the owning frontend files to task 7.9 and taught declaration parsing to preserve that suffix. Strict validation run `b00bc65686d748fcb4f33df2abb36f5b` passed after the boundary correction.
- Two bounded accounting probes established the final snapshot oracle: run `048366bcbaa7435ca7f4f413d402edf1` reported 226 selected members, and run `dc214f199d83484288f202d7c314f996` reported 12 members carrying native recipes. The final test asserts both exact values.

## Exact GREEN

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Services.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `a7b6233294fa421eb4ec44cdbc6dc5ee` passed 5/5 with zero warnings and zero errors:

- `AllTimerContextResourcesReleaseAndProvidersAreAccounted`
- `FixtureTimerFiresOnceThenCancellationPreventsFurtherCalls`
- `GameInstanceAndLocalPlayerRecordsAreComplete`
- `RuntimeTestHelperWithoutActiveContextReturnsExplicitDiagnostic`
- `SubsystemLookupUsesFixtureWorldAndRejectsWrongOrNullContext`

Final build `339367aa426f41588e3af70776a1e51b` succeeded. Relevant SHA-256 identities are:

- `RuntimeBindingServicesTests.cpp`: `6f722b0ac03f27e3aaa6bb52ee42d3cad48c30ad226bee030e5ea04cb89dfdcd`
- `Bind_Subsystems.cpp`: `06c57ca9259b7fad861ca8f4f5d748cc98dbab6007da0505d844ab04b308b217`
- `Bind_SystemTimers.cpp`: `16e5d748ff00e37fc0f7a67d54bcc4362631f81366345bf586120c1c16177a26`
- `Bind_UGameInstance.cpp`: `d72cc976f91fcfbf2158f70f989e8b18c68aca7c2b84eb4f0a08d13871308de3`
- `Bind_ULocalPlayer.cpp`: `52be207a17e91776ae8cbd79732769d58086800dbda4662952756c11c386dfb4`
- `AngelscriptTest.cpp`: `fb330705ab4ce2417bea9e0efe5328e2f24188dbff5386e96f1ebf389fcbe3da`
- `as_binding_declaration.cpp`: `4186d230af2c21601536cf1a2c90d2d0d79d6df4188b28f3b46672f6033ad9a7`
- `UnrealEditor-AngelscriptRuntime.dll`: `82b08786d52d2c2721613239a013c84697f77ec01c37271326cdf63c94728af5`
- `UnrealEditor-AngelscriptTest.dll`: `57e10352052536a2ac98c46a948f53165a32a7dabc96450524c9f525842641e6`

## Shared regression proof

Harness run `6021ae3a95a9428f8906ee2a7fbcd4c5` selected `Angelscript.UnitTest.RuntimeBindings.` and passed 301/301 with zero warnings, errors, skips or incomplete tests against the same binary identities. This covers the affected declaration parser, reflected snapshot recording, provider accounting, native-link installation, contextual Engine lookup and owner-lifetime contracts. No broader suite was selected because task 7.9's demonstrated impact remains within RuntimeBindings; task 8.4 owns the final shared NativeEngine regression after every provider family is complete.
