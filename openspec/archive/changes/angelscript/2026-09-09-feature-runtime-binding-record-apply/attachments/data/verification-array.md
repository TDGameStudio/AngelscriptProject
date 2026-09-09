# TArray and iterator verification

Task: 5.3. Parent base `a9afd56e73b9289ed32dee8210d7b96ac0b3b578`; plugin base `edc13e98d7a63fa22b76620302d1294fe6126641`.

## Commands and outcomes

- Build: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; TimeoutMs = 900000; NoWait = $true }`.
- Exact tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Array.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Behavioral RED `a65781b0cf3e44c49e51de62e7a20925`: seven discovered failures, zero warnings, seven errors and exit 255. The tests established the missing array mutation/copy/index/equality operations and the unrecorded complete provider surface.
- The first implementation run `44fbd96fcff2436cba34318d2fa9a72c` passed the first operation case, failed provider recording, and then crashed when the next fixture started. The smallest isolated provider run `608e5c74dcc04db1882e776ffa83e270` identified the first production boundary exactly: `TArrayIterator` had been filtered from the installable declaration catalog. After retaining both iterator templates, `098617516e064e3db126a15c41a57136` identified the next boundary: template surface records were being installed as if their frozen template host belonged to the ordinary member image. Template surfaces now remain detached for per-specialization materialization.
- The crash was independently traced to the test fixture: stack-constructed `FScriptArray` values were explicitly destructed and then destructed again at scope exit. Stack fixtures now empty their elements and placement-constructed copies retain explicit destruction. No production workaround was added for that fixture defect.
- Final build `42efcfb81c44456486649e391d3b4d34` succeeded.
- Exact GREEN `fd13ceaf57ba436d897051da864f57c4`: seven successes, zero warnings/errors and exit 0 with a complete valid report.
- Shared tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Shared GREEN `97f08336a7d74a46b3dad9175d93ddcc`: 167 successes, zero warnings/errors and exit 0 with a complete valid report.
- All managed operations reached terminal status through `ue.run.status`; no source writes occurred during builds or tests.

The complete recorded provider oracle contains 48 `TArray` members, five `TArrayIterator` members, five `TArrayConstIterator` members, 56 callables, two properties and 41 ordered native recipes. The runtime operation adapter uses each specialization's detached element size, alignment, copy, destruction, equality and reference-enumeration facts.

## Exact cases

| Case | Proof | GREEN |
|---|---|---|
| `CompleteTArrayProviderSurfaceIsRecorded` | All 58 array/iterator contributions, callable pointers, properties and 41 native recipes are retained | Success |
| `CopyThenClearOriginalRetainsTwoAndFive` | Copy, equality and find-index preserve `[2,5]` after the source is cleared | Success |
| `AppendRemoveAndIterationYieldTwoThenFive` | Append/index traversal yields `2,5`, then remove preserves `5` | Success |
| `InvalidIndexReturnsDiagnosticWithoutMutation` | Out-of-range access reports the index interval and leaves the array unchanged | Success |
| `StringCopyIsIndependent` | `TArray<FString>` deep-copies `alpha` and survives source clearing | Success |
| `CountedElementsCopyAndDestroyExactlyOncePerInstance` | The element copy and removed-element destructor each execute exactly once | Success |
| `NestedAndHandleElementsRetainOwnedValues` | Nested arrays retain copied values and handle arrays enumerate their `UObject` reference | Success |

## Final identities

| Path | SHA-256 |
|---|---|
| `Core/AngelscriptTypeBindInfoApply.cpp` | `84b1ee118e21f61e7ba3f08fdc567454878096866cc9fbab70a08728eef3f00c` |
| `Core/AngelscriptTypeBindInfoApply.h` | `3a3d03ccc1b32c64f746f908d3cdd0a06b265edec9ee5e48cba45c10bb7b6272` |
| `Core/AngelscriptTypeBindInfoCatalog.cpp` | `4edf7a8d99b5da91e3b29cb200a5e4fd229cfffd3b253e288bdf81a6ad22877c` |
| `Core/AngelscriptTypeBindInfoCatalog.h` | `0147e0b8ca4253551b3f66b84691a4fc4fe9c7f69bbc1fcbaa4e3ec4e7fbf0dc` |
| `Binds/Bind_TArray.cpp` | `16e00a3d2a7cdd446aeecddb0c840e88639358f163384900a9acb1de6305edb3` |
| `RuntimeBindingArrayTests.cpp` | `0a5ceb58e8080d457959d914753e21f0f7f8926641129ce3de1aaece23a344d2` |
| `UnrealEditor-AngelscriptRuntime.dll` | `a3fb7f1bf331cbdf0561ed358d48f4dc48da06007292becbea1c3508264d9938` |
| `UnrealEditor-AngelscriptTest.dll` | `79187fec91efab25d82c2706d7f72123d347fdd427d1b185d4fe06c485eaa919` |

RED report `Saved/Harness/Unreal/Runs/a65781b0cf3e44c49e51de62e7a20925/AutomationReport/index.json`: `c4d3081bc04df6a845970f1b0835dc98204c4b2dc2dcdbfb0948953992853c56`.

Exact GREEN report `Saved/Harness/Unreal/Runs/fd13ceaf57ba436d897051da864f57c4/AutomationReport/index.json`: `ff17c286ec2ce9fea57aaa3b13750a442f04f66da5e3e24d3afdbbafa82dec0b`.

Shared GREEN report `Saved/Harness/Unreal/Runs/97f08336a7d74a46b3dad9175d93ddcc/AutomationReport/index.json`: `306aed409ca54464c1a2e998f54255b3ce600eec69ea669e4008221da7b54b5c`.

Set, map and optional complete members, string member APIs, remaining Runtime families, full Runtime accounting, startup, packaging, legacy suites and Performance are omitted because this task owns the array and iterator family. The 167-case shared RuntimeBindings run covers the affected catalog, template, application and owner-isolation contracts.
