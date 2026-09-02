# Core publication and primitives

Binding publication mechanics, primitive/global facilities, diagnostics, console, profiling, memory-reader, hashing, logging, stats, and native-module bridge surfaces.

## Accounting

- Logical units: 15
- Planned AS-facing surface rows: 165
- Planned `.as` files: 36
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-007` | `BlueprintCallable` | 1 | 0 | 0 | `NoCurrentTest` |  | `InfrastructureOnly` |
| `MB-008` | `BlueprintEvent` | 1 | 14 | 3 | `REF-0039` `REF-0040` `REF-0041` `REF-0042` `REF-0043` `REF-0044` `REF-0045` `REF-0046` | `Engine` | `PlannedSource` |
| `MB-009` | `BlueprintType` | 1 | 44 | 7 | `REF-0047` `REF-0048` `REF-0049` `REF-0050` `REF-0051` `REF-0052` `REF-0053` `REF-0054` `REF-0055` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-011` | `ConfigEnums` | 1 | 3 | 1 | `REF-0064` `REF-0065` `REF-0066` | `World` | `PlannedSource` |
| `MB-012` | `Console` | 2 | 15 | 4 | `REF-0067` `REF-0068` `REF-0069` `REF-0070` `REF-0071` `REF-0072` | `Engine` | `PlannedSource` |
| `MB-013` | `CoreGlobals` | 1 | 4 | 1 | `REF-0073` `REF-0074` `REF-0075` `REF-0076` `REF-0077` `REF-0078` `REF-0079` `REF-0080` `REF-0081` | `Engine` | `PlannedSource` |
| `MB-014` | `Debugging` | 2 | 10 | 3 | `REF-0082` `REF-0083` `REF-0084` `REF-0085` `REF-0086` `REF-0087` `REF-0088` `REF-0089` `REF-0090` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-016` | `Deprecations` | 1 | 1 | 1 | `REF-0098` | `World` | `PlannedSource` |
| `MB-032` | `FCpuProfilerTraceScoped` | 1 | 1 | 1 | `REF-0190` `REF-0191` `REF-0192` `REF-0193` | `World` | `PlannedSource` |
| `MB-054` | `FMemoryReader` | 2 | 17 | 4 | `REF-0325` `REF-0326` `REF-0327` `REF-0328` `REF-0329` `REF-0330` `REF-0331` `REF-0332` | `Engine` | `PlannedSource` |
| `MB-087` | `Hash` | 1 | 8 | 1 | `REF-0524` `REF-0525` `REF-0526` `REF-0527` `REF-0528` `REF-0529` `REF-0530` `REF-0531` `REF-0532` | `Engine` | `PlannedSource` |
| `MB-093` | `Logging` | 2 | 29 | 4 | `REF-0549` `REF-0550` `REF-0551` `REF-0552` `REF-0553` `REF-0554` `REF-0555` `REF-0556` | `World` `ExpectedDiagnostic` `Engine` | `PlannedSource` |
| `MB-094` | `NativeModuleFunctionBinding` | 1 | 1 | 1 | `REF-0557` `REF-0558` `REF-0559` | `Engine` | `PlannedSource` |
| `MB-095` | `Primitives` | 2 | 13 | 3 | `REF-0560` `REF-0561` `REF-0562` `REF-0563` `REF-0564` `REF-0565` `REF-0566` `REF-0567` `REF-0568` | `Engine` | `PlannedSource` |
| `MB-097` | `Stats` | 1 | 5 | 2 | `REF-0578` `REF-0579` `REF-0580` `REF-0581` `REF-0582` `REF-0583` `REF-0584` | `Engine` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-BLUEPRINTEVENT-001` | `TestSource/Bindings/BlueprintEvent/Test_MutationAndLifecycle_01.as` | `MB-008-S011` `MB-008-S012` `MB-008-S013` `MB-008-S014` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTEVENT-002` | `TestSource/Bindings/BlueprintEvent/Test_NamespaceAndGlobalFunctions_01.as` | `MB-008-S009` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTEVENT-003` | `TestSource/Bindings/BlueprintEvent/Test_Behavior_01.as` | `MB-008-S001` `MB-008-S002` `MB-008-S003` `MB-008-S004` `MB-008-S005` `MB-008-S006` `MB-008-S007` `MB-008-S008` `MB-008-S010` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTTYPE-001` | `TestSource/Bindings/BlueprintType/Test_ConstructionAndAssignment_01.as` | `MB-009-S011` `MB-009-S012` `MB-009-S013` `MB-009-S014` `MB-009-S026` `MB-009-S027` `MB-009-S028` `MB-009-S036` `MB-009-S037` `MB-009-S038` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTTYPE-002` | `TestSource/Bindings/BlueprintType/Test_Operators_01.as` | `MB-009-S016` `MB-009-S017` `MB-009-S029` `MB-009-S030` `MB-009-S039` `MB-009-S040` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTTYPE-003` | `TestSource/Bindings/BlueprintType/Test_Queries_01.as` | `MB-009-S018` `MB-009-S019` `MB-009-S020` `MB-009-S021` `MB-009-S031` `MB-009-S041` `MB-009-S042` `MB-009-S043` `MB-009-S044` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-BLUEPRINTTYPE-004` | `TestSource/Bindings/BlueprintType/Test_MutationAndLifecycle_01.as` | `MB-009-S015` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTTYPE-005` | `TestSource/Bindings/BlueprintType/Test_NamespaceAndGlobalFunctions_01.as` | `MB-009-S002` `MB-009-S006` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTTYPE-006` | `TestSource/Bindings/BlueprintType/Test_Behavior_01.as` | `MB-009-S001` `MB-009-S003` `MB-009-S004` `MB-009-S005` `MB-009-S007` `MB-009-S008` `MB-009-S009` `MB-009-S010` `MB-009-S022` `MB-009-S023` | `Positive` | `Engine` |
| `TS-BIND-BLUEPRINTTYPE-007` | `TestSource/Bindings/BlueprintType/Test_Behavior_02.as` | `MB-009-S024` `MB-009-S025` `MB-009-S032` `MB-009-S033` `MB-009-S034` `MB-009-S035` | `Positive` | `Engine` |
| `TS-BIND-CONFIGENUMS-001` | `TestSource/Bindings/ConfigEnums/Test_ConstructionAndAssignment_01.as` | `MB-011-S001` `MB-011-S002` `MB-011-S003` | `Positive` | `World` |
| `TS-BIND-CONSOLE-001` | `TestSource/Bindings/Console/Test_ConstructionAndAssignment_01.as` | `MB-012-S001` `MB-012-S002` | `Positive` | `Engine` |
| `TS-BIND-CONSOLE-002` | `TestSource/Bindings/Console/Test_Queries_01.as` | `MB-012-S007` `MB-012-S008` `MB-012-S009` `MB-012-S010` | `Positive` | `Engine` |
| `TS-BIND-CONSOLE-003` | `TestSource/Bindings/Console/Test_MutationAndLifecycle_01.as` | `MB-012-S011` `MB-012-S012` `MB-012-S013` `MB-012-S014` | `Positive` | `Engine` |
| `TS-BIND-CONSOLE-004` | `TestSource/Bindings/Console/Test_Behavior_01.as` | `MB-012-S003` `MB-012-S004` `MB-012-S005` `MB-012-S006` `MB-012-S015` | `Positive` | `Engine` |
| `TS-BIND-COREGLOBALS-001` | `TestSource/Bindings/CoreGlobals/Test_Queries_01.as` | `MB-013-S001` `MB-013-S002` `MB-013-S003` `MB-013-S004` | `Positive` | `Engine` |
| `TS-BIND-DEBUGGING-001` | `TestSource/Bindings/Debugging/Test_Queries_01.as` | `MB-014-S006` `MB-014-S007` `MB-014-S009` | `Positive` | `Engine` |
| `TS-BIND-DEBUGGING-002` | `TestSource/Bindings/Debugging/Test_ConversionAndFormatting_01.as` | `MB-014-S010` | `Positive` | `Engine` |
| `TS-BIND-DEBUGGING-003` | `TestSource/Bindings/Debugging/Test_Behavior_01.as` | `MB-014-S001` `MB-014-S002` `MB-014-S003` `MB-014-S004` `MB-014-S005` `MB-014-S008` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-DEPRECATIONS-001` | `TestSource/Bindings/Deprecations/Test_Behavior_01.as` | `MB-016-S001` | `Positive` | `World` |
| `TS-BIND-FCPUPROFILERTRACESCOPED-001` | `TestSource/Bindings/FCpuProfilerTraceScoped/Test_Behavior_01.as` | `MB-032-S001` | `Positive` | `World` |
| `TS-BIND-FMEMORYREADER-001` | `TestSource/Bindings/FMemoryReader/Test_MutationAndLifecycle_01.as` | `MB-054-S001` `MB-054-S006` `MB-054-S007` `MB-054-S008` `MB-054-S009` `MB-054-S010` `MB-054-S011` `MB-054-S012` `MB-054-S013` `MB-054-S014` | `Positive` | `Engine` |
| `TS-BIND-FMEMORYREADER-002` | `TestSource/Bindings/FMemoryReader/Test_MutationAndLifecycle_02.as` | `MB-054-S015` `MB-054-S016` `MB-054-S017` | `Positive` | `Engine` |
| `TS-BIND-FMEMORYREADER-003` | `TestSource/Bindings/FMemoryReader/Test_ConversionAndFormatting_01.as` | `MB-054-S002` | `Positive` | `Engine` |
| `TS-BIND-FMEMORYREADER-004` | `TestSource/Bindings/FMemoryReader/Test_Behavior_01.as` | `MB-054-S003` `MB-054-S004` `MB-054-S005` | `Positive` | `Engine` |
| `TS-BIND-HASH-001` | `TestSource/Bindings/Hash/Test_NamespaceAndGlobalFunctions_01.as` | `MB-087-S001` `MB-087-S002` `MB-087-S003` `MB-087-S004` `MB-087-S005` `MB-087-S006` `MB-087-S007` `MB-087-S008` | `Positive` | `Engine` |
| `TS-BIND-LOGGING-001` | `TestSource/Bindings/Logging/Test_NamespaceAndGlobalFunctions_01.as` | `MB-093-S023` `MB-093-S024` `MB-093-S025` `MB-093-S026` `MB-093-S027` `MB-093-S028` `MB-093-S029` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-LOGGING-002` | `TestSource/Bindings/Logging/Test_Behavior_01.as` | `MB-093-S001` `MB-093-S002` `MB-093-S003` `MB-093-S004` `MB-093-S005` `MB-093-S006` `MB-093-S007` `MB-093-S008` `MB-093-S009` `MB-093-S010` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-LOGGING-003` | `TestSource/Bindings/Logging/Test_Behavior_02.as` | `MB-093-S011` `MB-093-S012` `MB-093-S013` `MB-093-S014` `MB-093-S015` `MB-093-S016` `MB-093-S017` `MB-093-S018` `MB-093-S019` `MB-093-S020` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-LOGGING-004` | `TestSource/Bindings/Logging/Test_Behavior_03.as` | `MB-093-S021` `MB-093-S022` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-NATIVEMODULEFUNCTIONBINDING-001` | `TestSource/Bindings/NativeModuleFunctionBinding/Test_Behavior_01.as` | `MB-094-S001` | `Positive` | `Engine` |
| `TS-BIND-PRIMITIVES-001` | `TestSource/Bindings/Primitives/Test_ConstructionAndAssignment_01.as` | `MB-095-S013` | `Positive` | `Engine` |
| `TS-BIND-PRIMITIVES-002` | `TestSource/Bindings/Primitives/Test_Behavior_01.as` | `MB-095-S001` `MB-095-S002` `MB-095-S003` `MB-095-S004` `MB-095-S005` `MB-095-S006` `MB-095-S007` `MB-095-S008` `MB-095-S009` `MB-095-S010` | `Positive` | `Engine` |
| `TS-BIND-PRIMITIVES-003` | `TestSource/Bindings/Primitives/Test_Behavior_02.as` | `MB-095-S011` `MB-095-S012` | `Positive` | `Engine` |
| `TS-BIND-STATS-001` | `TestSource/Bindings/Stats/Test_ConstructionAndAssignment_01.as` | `MB-097-S001` `MB-097-S002` | `Positive` | `Engine` |
| `TS-BIND-STATS-002` | `TestSource/Bindings/Stats/Test_Behavior_01.as` | `MB-097-S003` `MB-097-S004` `MB-097-S005` | `Positive` | `Engine` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
- Units without a selected representative TEST_METHOD: `MB-007 BlueprintCallable`. Their Bind source is the primary reference.
