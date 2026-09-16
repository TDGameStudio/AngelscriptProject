# Old RuntimeBindings catalog

Observation from 2026-09-16. Excludes `Bindings.Host*` (those 30 cases are the new contract and were green). Identity prefix is `Angelscript.UnitTest.RuntimeBindings.*`, plus `Bindings.RuntimeBindingIsolation` (new, green).

Suggestions below became decisions in Q70/Q71.

## How to read

Each group: which path, what it proves, overlap with new Host tests, disposition.

```text
Store record --> Seal / Validate --> TypeBindInfoApply::Install
                                      |
                                      +-- CreateForBindings(Store) --> BindingInstallation
                                           |
                                           +-- count Store members / dump
                                           +-- Prepare/Execute installed natives
                                           +-- MaterializeTemplate + hit FScriptArray
```

There is no `CompileModule`. The so-called VM calls already-installed C++ functions.

## 1. Descriptor library — Recording

| Class | Prefix | Count | What it does |
|---|---|---|---|
| Store | `.Recording` | 7 | Store owns input lifetime; sealed store rejects writes |
| Facade | `.Recording` | 8 | No Engine; record ValueClass/methods/globals |
| Providers | `.Recording` | 8 | Collection callback order, module filter |
| Validation | `.Recording` | 7 | Pre-seal cycles, layout, missing native |
| Ownership | `.Recording` | 6 | Policy snapshot; two owners share one Store |
| Manifest | `.Recording` | 10 | dump JSON/CSV without executing callbacks |
| DefinitionCatalog | `.Values` | 7 | Declaration prescan, lifecycle recipe, worker refuse |

Disposition: keep only while `TypeBindInfoStore` remains. Product path is Collection/Host. Isolate or retire with Store.

## 2. Handwritten Store + Apply — Types / Calls

| Class | Prefix | Count | What it does |
|---|---|---|---|
| Declarations | `.Types` | 8 | Declaration parse: const/&, templates, default expressions |
| Layouts | `.Types` | 9 | Derived layout, cycles, align, enum/interface |
| Members | `.Types` | 11 | After install: overload/offset/ctor; second Engine owns a distinct image |
| Native | `.Calls` | 20 | Install+ConnectNative: generics, auxiliary, rebind |

Disposition: move declaration/layout/call contracts onto the Host graph. `SecondEngineOwnsDistinctImage` contradicts shared Host pointers and cannot stay as-is.

## 3. Reflection into Store — Reflection

| Class | Prefix | Count | What it does |
|---|---|---|---|
| Definitions | `.Reflection` | 13 | Capture UStruct/UEnum/delegates/editor-only without an Engine |
| Delegates | `.Reflection.Delegates` | 6 | Subscribe, multicast, payload, foreign key |
| Pointers | `.Reflection.Pointers` | 7 | Strong/weak/soft; two owners do not share mutable |
| Mixins | `.Reflection.Mixins` | 6 | Mixin writes receiver, WorldContext |
| Functions | `.Reflection.Functions` | 7 | Reflected UFunction uses generic, inout |
| NativeMaps | `.Reflection.NativeMaps` | 7 | Handwritten native table overrides generated |
| Objects | `.Reflection.Objects` | 7 | Parent/child properties, interfaces, read-only, UObject lifetime |

Disposition: move behavior cases onto Host (HostObjects is already a thin start). Accounted-only member-count cases leave with the descriptor library.

## 4. Store-built engines — Engine

| Class | Prefix | Count | What it does |
|---|---|---|---|
| Creation | `.Engine` | 9 | `CreateForBindings(Store)` callable; default runtime dormant; failure has no owner |
| Isolation | `.Engine.Isolation` | 9 | Two Engines each own metadata/installation; 6.1 green |
| RuntimeBindingIsolation | `Bindings.RuntimeBindingIsolation` | 2 | New: shared Host pointers; green |

Disposition: Creation uses `CreateForBindings(Collection)`. Old Isolation must not treat distinct pointers as success; keep foreign-key/destroy/auxiliary semantics aligned with new Isolation.

## 5. Production families — Values / Containers / Runtime

Shared fixture: `RecordInstallableTypeDeclarations` + `RecordSelectedProviders` + `CreateForBindings(Store)`. Some then Prepare/Execute; some containers hit `FScriptArray` directly.

| Class | Count | Production surface | Host* overlap |
|---|---|---|---|
| Vectors | 7 | FVector family declarations + representative calls | HostMath thinner |
| Rotations | 6 | Transform/Quat/Matrix | HostMath |
| Bounds | 7 | Box/Sphere/Plane | HostMath |
| ColorsLayout | 6 | Color/Margin/Anchors/Geometry | HostMath |
| StringName | 6 | FString/FName append, split, Join | HostCore |
| Text | 7 | FText format | HostCore |
| TimeIdentity | 8 | Timespan/Date/Guid/Range/Math | HostMath |
| Array | 7 | TArray surface + operations-only | HostContainers / HostTemplates |
| Map | 7 | TMap | HostContainers |
| Set | 6 | TSet | HostContainers |
| Optional | 7 | TOptional | HostContainers |
| Instances | 8 | Template instantiate, missing copy/hash | HostTemplates |
| Collision | 6 | Shape/Query/Hit + transient World | HostGameplay |
| Actors | 6 | Spawn/Scene/World | HostObjects |
| Services | 5 | Timer/Subsystem | HostServices |
| Diagnostics | 6 | Console/Log/Profiler | HostServices |
| Platform | 6 | Parse/Paths/File/CommandLine | HostServices |
| Serialization | 6 | Json/InstancedStruct/MemoryReader | HostServices |
| Assets | 6 | Bundle/DataTable/SoftPath | HostServices |
| InputUI | 6 | Axis/Mapping/Widget | HostGameplay |
| Finalization | 5 | ToString/Skip/Deprecate | no Host counterpart |

Disposition: this is the meat of "each bind runs". Host* today is ledger plus a few calls. Move behavior cases onto Host fixtures. `Complete…IsRecorded` Store counts become Host-graph queries or are dropped.

## 6. Full Store capture — FullRuntime

| Class | Count | What it does |
|---|---|---|
| FullRuntime | 6 | No-arg `CreateForBindings()` = Recorder captures every provider; two owners, accounting, dump |

Disposition: replace with full Collection → ExecuteToHost → inject. The no-arg factory still uses Store today, which matches neither editor DirectBinds nor the Host whitelist.

## Counts

| Bucket | Approx |
|---|---|
| 1 Recording | 53 |
| 2 Types/Calls | 48 |
| 3 Reflection | 53 |
| 4 Engine Store (excluding new Isolation 2) | 18 |
| 5 Family | ~130 |
| 6 FullRuntime | 6 |
| Old total | ~310 |
| New Host + new Isolation | 32 |

## Relation to "all green"

Green 310 as-is = keep feeding Store/Apply.
Green retained set = choose contracts, move them to Host, then delete or isolate old files.

Historical 2026-09-15: `Calls.Native` 4 Fail, Array AV, then 292 NotRun. This round did not rerun them and does not claim current red/green.
