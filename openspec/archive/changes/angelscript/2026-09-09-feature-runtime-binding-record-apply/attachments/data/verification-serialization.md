# Task 7.6 Serialization Verification

## Outcome

Task 7.6 records and installs the JSON object/value/iterator, wildcard struct conversion, `FInstancedStruct`, and `FMemoryReader` providers in a fresh Engine. The selected family contains exactly 84 member contributions and 12 native recipes. Its installed behavior parses and reads JSON fields, rejects malformed JSON, preserves reflected values through JSON conversion, keeps copied instanced structs independent, and enforces memory-reader bounds.

## Setup and observed RED

- Builds `24cf981efff84efa96058f7c57cf3228` and `5bb3eedd67694ca08a13c4d4353c0443` exposed fixture compile/link boundaries before execution: the public reflected conversion fixture needed the `JsonUtilities` replacement-test dependency, while tests could not link private non-exported bind helpers. The applied replan `replan-20260909-091920-serialization-test-dependency` owns the dependency correction; tests invoke installed bindings or public module APIs.
- The interrupted foreground build `485be4e7b4374b108ea7206eddc9c352` reached 11/12 actions before its caller ended and was closed through `ue.run.cancel`; it is not correctness evidence. Build `5dcabf19351d4a7eba5181b2b3548d99` then passed.
- Run `65859b90a03648798c698c45f66bc69f` discovered all six cases and asserted during engine-free `FInstancedStruct` recording because its namespace requested the legacy target Engine. After that repair, run `91622cc20d524fae9187845e0c9e4400` exposed the same detached-recording defect in the JSON namespace. These crashes are setup failures, not behavioral RED.
- Run `13fd51892cb548d7854a02fa9439fc7b` executed all six cases: five behavior controls passed and provider accounting failed. Diagnostic run `c54101fccef0494fbfea341726eee106` established the independent frozen-image surface as 84 contributions and 12 native recipes. The missing engine-free namespace behavior was the task's observed RED; the already-correct installed behaviors remain characterization controls.

## Implementation

- `Json`, `FJsonObjectConverter`, and `FInstancedStruct` namespace scopes now record through the detached `FAngelscriptBinds` facade rather than accessing `GetTargetEngine()`.
- The replacement test module declares `JsonUtilities` for its public reflected conversion fixture.
- JSON assertions call the installed parse and field-access bindings. The reflected round-trip uses the public `FJsonObjectConverter` API, and native container/reader assertions use method-owned values with deterministic cleanup.

## Exact GREEN

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Serialization.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `6549e12e713545efbbec8abbd104c597` passed 6/6 with zero warnings and zero errors:

- `EverySerializationProviderIsAccounted`
- `InstancedStructCopyOwnsIndependentValue`
- `JsonLiteralParsesAndExposesFields`
- `MalformedJsonReportsFailure`
- `MemoryReaderReadsKnownSequenceAndRejectsOverrun`
- `ReflectedStructRoundTripPreservesFields`

Final build `9dffc3667a934c729668ea1add2ebd11` succeeded. Relevant SHA-256 identities are:

- `Bind_Json.cpp`: `ea6f996fd6c92af51a2ad66c713b67e21344f821a9a1e35259763ed4d183740a`
- `Bind_JsonObjectConverter.cpp`: `4aa47326eb470196704a09cd80294f10f7487792a5c8a3a627b2d49e7a945e9b`
- `Bind_FInstancedStruct.cpp`: `4e4e59b97c87cd28600a54a1a64aea503f8340ee9b53234a11d433da1c48795c`
- `Bind_FMemoryReader.cpp`: `769289cce9cc197667c80cdf9745bb64e32b6e9622a676308f90cb04556f83c0`
- `RuntimeBindingSerializationTests.cpp`: `552dccaf824b44a526f33f34c117f8f1e9679b89b2b8067b1915e85175d360af`
- `UnrealEditor-AngelscriptRuntime.dll`: `40a9a18199a01f91f0facfd58ff7237a441b00b2bc17cfb0f21a7a3e546b9be2`
- `UnrealEditor-AngelscriptTest.dll`: `b32653e5885f0ec937bf8162c10f9234ff8a18cfc6b791a271dcdc24c9ef62c5`

## Shared regression proof

Harness run `84690ce336b24b598dc21e0e9b8e0256` selected `Angelscript.UnitTest.RuntimeBindings.` and passed 284/284 with zero warnings, errors, skips or incomplete tests against the same DLL identities. This covers affected recording, declaration, reflected layout, template, native-call and owner-lifetime contracts. No broader suite was selected because the demonstrated impact remains inside RuntimeBindings.
