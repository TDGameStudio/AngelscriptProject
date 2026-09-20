# Final affected execution

Frozen snapshot after 5.2 production entry plus 6.1 local control adaptations. No further product source was written after this build.

## Binary

- Build: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }` run `2b852fdd69e241fcb0291484937fded5`, Succeeded, 9273 ms.
- `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `4F8D783BAEB0136B9F1BE9C77AAEE26BB3E87C933ABCE91CFC40B2E2FEA6B042`
- `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `B0A673A80EC97EBB128A91061A1644261658A6C780A17903A893CAF7C28F9249`

## Prefix proofs

Each command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = '<prefix>'; Fast = $true; TimeoutMs = 1800000 }`.

| Prefix | Run | Duration ms | Total | Succeeded | Failed | Complete |
|---|---|---|---|---|---|---|
| Angelscript.UnitTest.NativeEngine.Definitions. | 256101054ca84ed0bd898e66d06bd7fc | 30326 | 89 | 89 | 0 | yes |
| Angelscript.UnitTest.NativeEngine.Registration. | 553d937a1b6d4301977bd205b7dac74e | 27304 | 38 | 38 | 0 | yes |
| Angelscript.UnitTest.NativeEngine.TypeOwnership. | 93fe58f57eff48cf93308b45807118eb | 30075 | 20 | 20 | 0 | yes |
| Angelscript.UnitTest.NativeEngine.Identity. | c615e11aa16a40258d520e85b588ccd8 | 27727 | 48 | 48 | 0 | yes |
| Angelscript.UnitTest.NativeEngine.VM. | b12948b93d8146b393573389e8c66be0 | 44853 | 333 | 333 | 0 | yes |
| Angelscript.UnitTest.NativeEngine.Compile. | 12412873e7bf44d68b6034fbf4b2ddfb | 31843 | 147 | 147 | 0 | yes |
| Angelscript.UnitTest.NativeEngine.SourceExecution. | b4b7685d11a14f4d93df8e4fd7be1f6c | 30848 | 131 | 131 | 0 | yes |
| Angelscript.UnitTest.Bindings.Host | 728567ad94a24a8d910b3881c009ad5b | 28448 | 30 | 30 | 0 | yes |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation. | 9fd30d75f33c48d594f832fd90fde92e | 26664 | 9 | 9 | 0 | yes |
| Angelscript.UnitTest.Bindings.RuntimeBindingIsolation. | 4fba98cfdc054345a2c053b9d6074c8c | 26138 | 2 | 2 | 0 | yes |
| Angelscript.UnitTest.Baseline. | 69661a1f91314093b7f84247416d05eb | 26629 | 3 | 2 + 1 warning | 0 | yes |

Host 30 includes HostGraph-adjacent collection/templates plus HostCore/Math/Containers/Objects/Gameplay/Services (3 each), HostBlueprintWrites (3) and HostProduction (3). Isolation families retained Store/live/foreign/auxiliary rebinding. Baseline is complete with one SucceededWithWarnings case (2436 warnings, 0 errors).

## Production site dispositions

Family site tables remain the coverage oracle. Seed CSV rows stay historical; 5.2 WholeSourceReconciliation counted the same 332 sites:

| Family | Sites | executable | metadata_only | companion |
|---|---|---|---|---|
| Core | 35 | 6 | 22 | 7 |
| Math | 118 | 2 | 80 | 36 |
| Containers | 16 | 4 | 8 | 4 |
| Objects | 49 | 0 | 40 | 9 |
| Gameplay | 63 | 0 | 52 | 11 |
| Services | 51 | 0 | 40 | 11 |
| Total | 332 | 12 | 242 | 78 |

Eligible production host capture is FString/FVector TypeDeclarations plus FString.ExplicitBindings/FVector and TArray/TMap/TSet/TOptional declarations. Remaining ExplicitBindings stay engine-replay.

## Local 6.1 repairs on this snapshot

- TypeOwnership.Baseline.ConsumerLedger needle restored to archived `nextMetadataTypeId` (1.1 left the consumer-migration CSV unchanged).
- Unadmitted Prepare controls now expect `asINVALID_ARG` (1.5 admission-before-bytecode): `VMImageContracts.UnregisteredScriptFunctionHasNoRuntime`, `CompileLifecycle.PrepareBeforeRegisterReturnsNoFunction`.
- ExecuteToHost runs every collection-local ExplicitBindings record; TypeInfrastructure/Reflection stay skipped. Production subset filtering stays in `EnsureProcessHostCollection`. Host Collection/Core failure-boundary cases require this.

## Omitted

Quick/Performance/Integration, memory trace, FullRuntime/Creation recorder fixtures, and manifest v2. No unmatched binary across the table above.
