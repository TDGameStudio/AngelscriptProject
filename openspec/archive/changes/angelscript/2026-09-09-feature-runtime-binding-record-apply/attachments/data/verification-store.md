# Recording Store verification

Task: 1.2. Selected workspace: primary AngelscriptProject. Parent base a9afd56e73b9289ed32dee8210d7b96ac0b3b578; plugin base edc13e98d7a63fa22b76620302d1294fe6126641. Owned uncommitted content and binaries are identified below.

## Commands and outcomes

- Both builds: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`.
- RED setup build: `9fca6e2dd58048e7acddb4371a47b61f`, succeeded, process exit 0.
- GREEN build: `b1f18d8fc5c04c95af461b96827a6705`, succeeded, process exit 0.
- Both test runs: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Store.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- RED test: `9c36495c72794ac7b1a501cb60f0d9a8`, seven discovered/executed failures, process exit 255.
- GREEN test: `db3ae410f16d4a669ce6d8b66231aeb3`, seven successes, zero case errors/warnings, process exit 0.
- Asynchronous dispatch was followed to terminal state with `ue.run.status`; launch success was not counted as test success.

RED used minimal compilable interfaces. RecordType returned false and Seal returned false; six scenarios stopped at their RecordType precondition and EmptyStoreSeals failed at Seal. This proves missing recording/sealing entry behavior, not independent RED execution of each later negative branch. GREEN executed the complete later assertions, including kind/size/alignment conflicts, sealed mutation and foreign-handle rejection. Assertion diagnostic arguments were removed after RED to avoid evaluating a pointer into an output string in the same call that mutates that string; expected outcomes were unchanged.

## Case mapping

| Scenario | RED | GREEN |
|---|---|---|
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.CompatibleDeclarationsCoalesce` | Fail at missing entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.ConflictingNativeDefinitionReportsBothSources` | Fail at missing entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.EmptyStoreSeals` | Fail at missing entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RecordHandlesSurviveGrowthAndRejectForeignStores` | Fail at missing entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RepeatedSealPreservesIdentity` | Fail at missing entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.SealedMutationRejected` | Fail at missing entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.StoreOwnsInputLifetime` | Fail at missing entry behavior | Success |

## Content identities

| File | RED SHA-256 | GREEN SHA-256 |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h` | `dc321ad893da7768555b7f1a1a78d38f3b9aeca9bdf2450f56498ec7182b1640` | `dc321ad893da7768555b7f1a1a78d38f3b9aeca9bdf2450f56498ec7182b1640` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.h` | `6dcb95fd5991573db38f43a0f135e5b103c56505cd5b06520e780bed0ddb0eaa` | `2c3596bce3f9f842d6fcce8aa9b09495737d643f5eb9700f90722a1e1897c74c` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.cpp` | `d78f3ec174c517abb6c8286a793260d1e41d88ed42d117ee336f78920e348579` | `f9e2602b6c5569f287bb0f5a1425af25f5bc10f6286aecad2537967230168c1b` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingStoreTests.cpp` | `31bd57efe5e73d139145ff25d367fded0deb4798ec41653a4f9b27571543c1af` | `50d1877da6e1a4dc91a6685535228d799ea1d953b9106638136542e401799346` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | `3027f5e1571c557ad8b29f8b372554bd480e850474cc81dde414b7aeee4d0d5b` | `6e853f8c8bad8d222baf15d8f138b4f5ca50f0248dcdf6b4f4bcbd429118a517` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | `b4119c0886db8c9eac68f2efde7c148385601bc33d679b79e05856368441ca8d` | `f535248247bcc20023e2d7e3a2464675f380ca27b6325b55880d8ebeaadc98a6` |

## Reports and scope

- RED report: `Saved/Harness/Unreal/Runs/9c36495c72794ac7b1a501cb60f0d9a8/AutomationReport/index.json`; SHA-256 `249e1d3fa005b19cc11b867172c50e77a3975b69b92807422fb8fb5f9bef8d01`.
- GREEN report: `Saved/Harness/Unreal/Runs/db3ae410f16d4a669ce6d8b66231aeb3/AutomationReport/index.json`; SHA-256 `ad83a421f5bd1b9b4cdd8646e5f03e69b7af1d10b0602f2e6d2bcbbd72313630`.
- Broader NativeEngine, baseline, legacy suites, packaging and Performance were not run for this storage-only outcome. No existing engine, compiler or startup consumer changed; the later integration tasks own those affected checks.
- This evidence becomes stale for any changed owned source or rebuilt binary; later task edits require their own focused proof and final-content verification.
