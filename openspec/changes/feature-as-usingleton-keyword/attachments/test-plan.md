# Singleton implementation test plan

## 1. Test organization

Planned C++ automation files and prefixes:

| File | Prefix | Purpose |
| --- | --- | --- |
| `Preprocessor/AngelscriptPreprocessorSingletonTests.cpp` | `Angelscript.TestModule.Preprocessor.Singleton` | grammar, lowering, descriptors and diagnostics |
| new `Singleton/AngelscriptSingletonRegistryTests.cpp` | `Angelscript.TestModule.Singleton.Registry` | keys, lazy creation, default/named behavior, failures |
| new `Singleton/AngelscriptSingletonObjectFamilyTests.cpp` | `Angelscript.TestModule.Singleton.ObjectFamily` | UObject/Actor/Widget/Component/custom Create matrix |
| `GC/AngelscriptSingletonGCTests.cpp` | `Angelscript.TestModule.GC.Singleton` | strong retention, failed candidates and World cleanup |
| `HotReload/AngelscriptHotReloadSingletonTests.cpp` | `Angelscript.TestModule.HotReload.Singleton` | body/shape/identity reconciliation and rollback |
| `HotReload/AngelscriptHotReloadSingletonPIETests.cpp` | `Angelscript.TestModule.HotReload.Singleton.PIE` | all-related rejection and queued latest reload |
| `HotReload/AngelscriptHotReloadSingletonMultiplayerPIETests.cpp` | `Angelscript.TestModule.HotReload.Singleton.MultiplayerPIE` | server/client slot isolation and atomic deferral |
| `Dump/AngelscriptSingletonStateDumpTests.cpp` | `Angelscript.TestModule.Dump.Singleton` | read-only definition/slot rows and diffs |

Use the repository CQTest/inline-AS conventions and `FScopedAngelscriptModule`/existing HotReload fixtures. Test-only UObject classes for object-family behavior belong in the `AngelscriptTest` module and must not leak into Runtime.

Before implementing lifecycle lowering, run the sibling typed-semantic change's
characterization checks:

```powershell
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-FunctionTraitSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-ExternalImplicitThisRuntime.ps1
```

The application-ready base-language C++ cell is in
`feature-as-typed-semantic-aot/research/patches/external-implicit-this-test-first-patch.md`.
It proves the generated lifecycle function's receiver mechanism without UE.
It does not complete S-P07/S-P07A/S-P07B: Singleton still needs separate
preprocessor signature, Registry explicit-call, UObject, reload, and route
counter assertions.

## 2. Parser and lowering matrix

| ID | Fixture/action | Required assertion |
| --- | --- | --- |
| S-P01 | no macro Global declaration | descriptor scope Global; `Name::Get()` compiles; no PostInit entry |
| S-P02 | `USINGLETON()` and `(Global)` | same normalized descriptor/hash |
| S-P03 | `(World)` | both named Getter overloads compile |
| S-P04 | declaration in namespace | stable ID and generated namespace include enclosing namespace |
| S-P05 | two names, same Type | both descriptors survive and no duplicate-Type rejection occurs |
| S-P06 | duplicate same identity | diagnostic identifies both locations |
| S-P07 | all lifecycle blocks | user blocks have no parameters; hidden globals each retain exactly one declared-Type parameter zero, `external_implicit_this`, no object slot, and a collision-proof name |
| S-P07A | hidden lifecycle body | unqualified field, explicit `this`, unqualified method and accessor resolve through parameter zero; local/parameter shadowing keeps normal lookup precedence |
| S-P07B | hidden lifecycle invocation | Registry passes candidate/replacement/Ready object as argument zero; VM/Legacy/Semantic-fallback counters preserve exactly-once lifecycle order |
| S-P08 | malformed/duplicate blocks | exact `AS-SINGLETON-00x` diagnostic and active module unchanged |
| S-P09 | keywords in comments/strings/nested blocks | only the real declaration is transformed |
| S-P10 | archive/offline round trip | stable IDs/hashes/source metadata are byte-stable |

Each successful parser test also asserts that preprocessing/compilation has not created a UObject or touched a test Registry backend.

## 3. Runtime identity and lifecycle matrix

| ID | Fixture/action | Required assertion |
| --- | --- | --- |
| S-R01 | compile unused named singleton | Empty definition, zero constructed objects |
| S-R02 | first/repeated named Get | one construct, one Init, stable address |
| S-R03 | same Type under two names | two objects, independent Init values |
| S-R04 | named plus default same Type | separate addresses; default executes no named lifecycle |
| S-R05 | default Global repeated Get | one per Engine and DeterminesOutputType works |
| S-R06 | default World across two Worlds | one per World; same-World contexts converge |
| S-R07 | two isolated Engines | separate globals; shutdown isolation |
| S-R08 | Init direct and A/B recursion | no partial result, full chain diagnostic, retry succeeds after fixture changes |
| S-R09 | Create/Init throws once | fresh candidate on next Get; failed object collectible |
| S-R10 | reverse shutdown | observed Deinit order is reverse Ready sequence across named/default slots |
| S-R11 | Deinit throws | later slots still release and diagnostics contain the failing slot |
| S-R12 | off-thread Get | no allocation and deterministic Game Thread error |

## 4. UObject-family and World matrix

Use small native test classes with construction/destruction counters:

- ordinary UObject: Global and World success;
- Actor: World Spawn success, Global rejection, target World and one Spawn only;
- UserWidget: valid World/player context success, Global rejection;
- ActorComponent: registration in target World, cleanup/unregister, custom-owner variant;
- abstract UObject and USubsystem: compile/first-Get rejection with repair guidance;
- custom Create returning null/wrong Type/another World/CDO/already-owned object: never Ready;
- no ambient World and invalid explicit Context: no `GWorld` fallback;
- Game, PIE and GamePreview Worlds accepted; Editor/Inactive/tearing-down Worlds rejected according to the eligible-World helper.

World cleanup tests force GC after cleanup and assert Registry buckets, objects and child references disappear only for the target World.

## 5. Reload matrix

| ID | V1 -> V2 change | Mode | Required assertion |
| --- | --- | --- | --- |
| S-H01 | ordinary method body | non-PIE | same object, new result, no lifecycle replay |
| S-H02 | Init body only | non-PIE | existing object unchanged; newly created second World uses V2 Init |
| S-H03 | add compatible property | non-PIE | replacement address, old compatible values, new default, one Reload |
| S-H04 | Actor class shape | non-PIE | same World/Level/Transform, one replacement, references redirected |
| S-H05 | declaration Name | non-PIE | old Deinit; new Empty; no migrated state |
| S-H06 | Global -> World | non-PIE | old Deinit; no instance until World Get |
| S-H07 | declared Type change | non-PIE | delete+add; no cross-Type copy |
| S-H08 | active default UClass reinstancing | non-PIE | stable default key remapped once |
| S-H09 | invalid candidate | non-PIE | module/routes/slot stay last-good |
| S-H10 | replacement Init/Reload failure | non-PIE | documented pre/post-commit retry outcome, no duplicate object |

## 6. PIE matrix

For each protected change—descriptor, Create body, Init body, Reload body, Deinit body, named Type ordinary body, named Type shape, active default Type body—assert:

1. reload reports the queued/full-reload-needed result;
2. old module and function output remain active;
3. object address, properties and lifecycle counters remain unchanged;
4. no replacement pair is published;
5. after PIE, latest source is reconciled once.

Run the Type-body and Type-shape cases under two-player PIE and verify server/client objects remain distinct and neither side updates early. Include a control edit to an unrelated function proving existing PIE soft reload remains available.

## 7. Dump and Standalone matrix

- Dump an unused definition: definition row/Empty state, construction counter remains zero.
- Dump named/default Ready slots of the same Type: key-kind rows remain distinct.
- Dump two Worlds/two Engines: stable IDs match while Engine/World columns distinguish slots.
- Trigger failure and dump/diff: LastError and failure generation appear; Dump does not retry.
- Export/import descriptor bundle twice: byte-deterministic output.
- Standalone UE-validation compiles generated signatures; executing a Getter reaches an explicit UE-runtime trap.

## 8. Verification commands

Focused commands after implementation:

```powershell
Tools\RunBuild.ps1
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Preprocessor.Singleton"
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Singleton"
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.GC.Singleton"
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.HotReload.Singleton"
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Dump.Singleton"
Tools\RunTestSuite.ps1 -Suite Standalone
Tools\RunTestSuite.ps1 -Suite All
openspec validate feature-as-usingleton-keyword --strict
```

The implementation report records the actual discovered/pass/fail/skip/timeout counts for each command. No baseline number in this planning attachment is treated as proof of a future run.
