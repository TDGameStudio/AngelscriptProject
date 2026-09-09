# TMap and iterator verification

Task: 5.5. Parent base `a9afd56e73b9289ed32dee8210d7b96ac0b3b578`; plugin base `edc13e98d7a63fa22b76620302d1294fe6126641`.

## Commands and outcomes

- Build: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`.
- Exact tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Map.'; Fast = $true; TimeoutMs = 600000 }`.
- The first compile `e57722759d5a4ba28fa8423871d68bf2` failed only because the new files used the nonexistent `Containers/ScriptMap.h`; UE 5.8 exposes `FScriptMap` through `Containers/Map.h`. The corrected setup build `7cb38da47df84ae3974132c382c6993a` succeeded.
- First behavioral run `decc18ed81fe48b68d946d5187d96234`: six map-operation cases succeeded; the provider-accounting case was RED because the installable declaration catalog retained `TMap` but filtered out `TMapIterator` and `TMapConstIterator`. The complete surface therefore failed with `Recorded type '::TMapIterator' has not been declared.`
- The focused diagnostic run `f45c64d21a1f44b689dc96d82165fc1d` reproduced that exact boundary. Adding the two iterator templates to the installable catalog fixed the provider without changing its declarations.
- Final build `b7134ec3968541bd9234b03ca4b99d45` succeeded.
- Exact GREEN `0dcd28df93314de58185b203004f4a63`: seven successes, zero warnings/errors and exit 0 with a complete valid report.
- Shared tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.'; Fast = $true; TimeoutMs = 600000 }`.
- Shared GREEN `90f5283af17c40a489c937756f35a098`: 22 successes, zero warnings/errors and exit 0 with a complete valid report.

The complete provider oracle accounts for 30 `TMap` members, nine `TMapIterator` members and seven `TMapConstIterator` members. The per-specialization operation adapter owns independent key hashing/equality and value construction/copy/destruction, derives the UE script-map layout from the concrete arguments, and traverses valid sparse indices for iteration and reference enumeration.

## Exact cases

| Case | Proof | GREEN |
|---|---|---|
| `CompleteTMapProviderSurfaceIsRecorded` | All 46 map and iterator contributions retain their callable targets or property facts | Success |
| `SetExistingKeyReplacesItsValue` | Setting key `a` to `2` then `5` keeps one entry whose value is `5` | Success |
| `CopySurvivesOriginalRemoval` | A copied map retains `a -> 5` after removal from the source | Success |
| `MissingKeyLeavesOutputUnchanged` | A missing lookup returns false, emits no failure diagnostic and leaves the explicit output untouched | Success |
| `IteratorYieldsExpectedKeyAndValueAndRejectsPastEnd` | Sparse iteration yields the expected pair and invalid access reports the iterator contract | Success |
| `CountedValuesReleaseOnReplaceAndRemove` | Replacement and removal each destroy exactly one owned value while each insertion copies once | Success |
| `NestedArrayValueCopyIsIndependent` | A `TArray<int>` map value retains `5` after the source array is emptied | Success |

## Final identities

| Path | SHA-256 |
|---|---|
| `Core/AngelscriptTypeBindInfoApply.cpp` | `ca866aa3fdc507d05ece8f3e2e6171e2ec1224389a00d2666e1da66cd08bea38` |
| `Core/AngelscriptTypeBindInfoApply.h` | `086603b2c040a4103568d875613654a878c48d3d4315aac1d9ba3d69e5613efe` |
| `Core/AngelscriptTypeBindInfoCatalog.cpp` | `344c1757c62291f64db255e36ad36dfc0854f122d37c88c8bd51f236c1ff1621` |
| `RuntimeBindingMapTests.cpp` | `f2ab7783ec2ff6c8f8bf77c5cc57243109f91df7c9d41a75c6586a86d6b7926a` |
| `UnrealEditor-AngelscriptRuntime.dll` | `369aed2b455bea9600eb3136bb2347bc45c2e0dafdf75ed06195f628cd432813` |
| `UnrealEditor-AngelscriptTest.dll` | `5f7e3afae13cce3472761adccbe2daae258ae40dc87e363bbe837dffba32bb68` |

Exact GREEN report `Saved/Harness/Unreal/Runs/0dcd28df93314de58185b203004f4a63/AutomationReport/index.json`: `9865b36aef890229f1e78552c1a17ff7a2070192ac95574434085ee0f55afb07`.

Shared GREEN report `Saved/Harness/Unreal/Runs/90f5283af17c40a489c937756f35a098/AutomationReport/index.json`: `74984cc19b99818cc0f938aa86e1ef57e8fd842bf1e4f67033acd3d79f47d592`.

Set and optional complete members, remaining Runtime families, full Runtime accounting, startup, packaging, legacy suites and Performance are omitted because this task owns the map and iterator family. The 22-case shared container run covers the affected catalog and template-operation contracts.
