# Task 1.1 verification

Observation-only baseline. No ownership SDK behavior was changed. Characterization tests record current detached IDs, ForeignEngine rejection, survivor lifetime, VM samples and 128-type costs.

## Commands

Build (source freeze, then Automation on this binary):

```powershell
$result = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000; BuildConcurrency = 'Auto' }
```

Run `cdcea3a595fa4706a935a9a366b942a4`, state Succeeded, exit 0.

Proving selection:

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
```

Run `72d04f2d6b524bbba54443fb365997c0`, state Succeeded, exit 0.

## Cases

| Case | Result |
| --- | --- |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.Pair | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.PrivateOwners | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.ConsumerLedger | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.VMExecution | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.Cost | Success |

Discovered 5, executed 5, failed 0, not-run 0. Report complete.

## Identity

| Item | SHA-256 |
| --- | --- |
| TypeOwnershipTestSupport.h | `7f1486dc1dcfb6a6d75ebb4b55350fca62d6eab12dcad2578c428707fe29f145` |
| TypeOwnershipBaselineTests.cpp | `b9415940a587feddbefd9ec7eb3956c39883628ada2801b69f80b201ab558eed` |
| consumer-migration.csv | `88a3ffb2f593c6c669446f8c6542661e4ef33d8b135a93edca5ce68a05d8a143` |
| UnrealEditor-AngelscriptTest.dll | `af9b44c6e1c85da283250be0b3643d0322968c2c882d3aedc5245d15291b490d` |
| UnrealEditor-AngelscriptRuntime.dll | `49d8614fe6f33e366427d1c8f2b200118310455bd28d288b4ecd345e87710a6f` |
| AutomationReport/index.json | `ded9e1d7f38db6f199c4b319ec2874ae1b2a2461b5369413b0c8b9d876e5bfcb` |

Workspace HEAD at evidence time: `0f0cf23ee78e563bf93dcf20b43a55381948273d` (primary `main`). Semantic fixture MD5: `D724E66C82D29F67FE9A878B7169FDB4`.

## Observed current contract

- Detached Pair: `GetTypeId`/`GetId`/`member typeId` are `-1`; `GetEngine` and `GetBoundEngine` are null; `GetTypeIdByDecl("Pair")` is `asNOT_SUPPORTED`; `GetTypeInfoByDecl` is null.
- After Engine register: original pointers round-trip through `GetTypeInfoById`/`GetFunctionById`; member X/Y type IDs are `asTYPEID_INT32`; native Sum/GetX/GetY/One execute as 42/20/22/1.
- Independent ScriptThing images have distinct pointers and keys. Registering A's image on B returns `ForeignEngine`. AddRef survivor after A shutdown reports null engine and `-1` ID; reattach is `Retired`. B remains usable.
- VM samples: arithmetic 20+22, native CALLSYS add, ALLOC/FREE, Cast, concurrent 1/2/8 engines. Installed native template operations are unsupported in this NativeEngine baseline (recorded, not timed). Handle copy is attempted; unsupported outcomes are recorded rather than fabricated.
- Cost (128 types × 4 methods): prepare_ns=42410900, attach_ns=702800, query_ns=40600, release_ns=107400.

## Intentionally omitted

Harness Quick, Performance, Integration, full `Angelscript.UnitTest.NativeEngine` and Unreal suites. Task 1.1 is a local observation ledger; those gates do not match this impact.
