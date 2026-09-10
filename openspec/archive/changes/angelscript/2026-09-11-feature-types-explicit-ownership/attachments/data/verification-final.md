# Task 7.9 verification

Repeat of the 1.1 Baseline fixtures on the unique-TypeInfo path. Semantic VM results are the completion gate. Setup Cost nanoseconds are recorded without an invented tolerance.

## Commands

Build after the Pair oracle update:

```powershell
$result = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Serialize'; ConcurrencyPolicy = 'Wait'; NoXge = $true; TimeoutMs = 3600000 }
```

Run `64c2bf27b969404aade95cdef47fe88e`, state Succeeded, exit 0.

Proving selection:

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
```

First post-oracle proving run `e1fca0fe764f4024a329c4d94cf7601c` (Unreal `704c9bc5385c42709258b17f5458f305`), state Succeeded, exit 0. Repeatability sample `374941a23bb342639868fa61deec4dc5` (Unreal `0ec7b5ba08ca4943bdda390e1728907c`), state Succeeded, exit 0.

Pre-oracle RED run `3382d71bcca549feb277c88431f4c378` failed only Baseline.Pair: detached member TypeId was `asTYPEID_INT32` (4), not `-1`. Object `GetTypeId` remains `-1` until Engine attach. Primitive tokens do not need BoundTypeIds.

## Cases

| Case | Result |
| --- | --- |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.Pair | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.PrivateOwners | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.ConsumerLedger | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.VMExecution | Success |
| Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline.Cost | Success |

Discovered 5, executed 5, failed 0, not-run 0. Report complete on both proving runs.

## Identity

| Item | SHA-256 |
| --- | --- |
| TypeOwnershipBaselineTests.cpp | `1f8e92ece68c7fa33d391f638ebe7e64b0de4402273e5e1abcf0b9fa1715a2a7` |
| UnrealEditor-AngelscriptTest.dll | `50a74763c1ac0c271340edea5e07da1967b4fa56265e67b7548bc64ce9f86a49` |
| UnrealEditor-AngelscriptRuntime.dll | `3133c70107efa4d1975571a45fb7c80b36865b6509bcfdb5403f35dcc820efc9` |

Workspace HEAD at evidence time: `0f0cf23ee78e563bf93dcf20b43a55381948273d` (primary `main`). Semantic fixture MD5: `D724E66C82D29F67FE9A878B7169FDB4`.

## Semantic results versus 1.1

- Detached Pair: object `GetTypeId`/`GetId` remain `-1`; `GetEngine` and Image `GetBoundEngine` remain null. Primitive member TypeIds are `asTYPEID_INT32` without Engine attach.
- After Engine register: original TypeInfo/Function pointers round-trip through `GetTypeInfoById`/`GetFunctionById`; native Sum/GetX/GetY/One execute as 42/20/22/1.
- Independent ScriptThing images keep distinct pointers and keys; B cannot adopt A's already-taken unique Image; B remains usable after A is destroyed.
- VMExecution: arithmetic 20+22, native CALLSYS add, ALLOC/FREE, Cast, concurrent 1/2/8 engines. Installed native template operations remain unsupported in this NativeEngine baseline. Handle copy remains recorded rather than fabricated.
- Cost fixture still 128 types × 4 methods and executes Sum/GetX/GetY/One as 42/20/22/1.

## Cost nanoseconds

| Phase | 1.1 (`72d04f2d6b524bbba54443fb365997c0`) | 7.9 run 1 | 7.9 run 2 |
| --- | ---: | ---: | ---: |
| prepare_ns | 42410900 | 53521300 | 50290900 |
| attach_ns | 702800 | 1292000 | 1131000 |
| query_ns | 40600 | 59400 | 57800 |
| release_ns | 107400 | 279100 | 133700 |

Setup attach is higher than 1.1 because unpublished `RegisterMetadataImage` now reserves process IDs (private AS uniqueness) instead of Engine-local counters. That cost is outside VM dispatch. BindInfo unique-TypeInfo materialize publishes once, then each Engine applies those IDs; it does not Reserve again per instruction. Context Prepare still compares `func->GetEngine()` pointers. No Registry lookup was added to the interpreter loop.

VM execution semantic fixtures passed on both proving runs. No repeatable VM-dispatch regression is attributed to this Change.

## Intentionally omitted

Harness Quick, Performance, Integration, full `Angelscript.UnitTest.NativeEngine` and Unreal suites. Task 7.9 reuses the 1.1 Baseline selector; those heavier gates do not match this impact.
