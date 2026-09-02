# Delegates, mixins, and subsystems

Delegate publication/invocation, payload/world-context helpers, function-library mixins, and subsystem lookup/lifecycle surfaces.

## Accounting

- Logical units: 5
- Planned AS-facing surface rows: 67
- Planned `.as` files: 12
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-015` | `Delegates` | 2 | 45 | 6 | `REF-0091` `REF-0092` `REF-0093` `REF-0094` `REF-0095` `REF-0096` `REF-0097` | `Engine` | `PlannedSource` |
| `MB-019` | `FAngelscriptDelegateWithPayload` | 1 | 4 | 2 | `REF-0114` `REF-0115` `REF-0116` `REF-0117` `REF-0118` `REF-0119` `REF-0120` | `Engine` | `PlannedSource` |
| `MB-020` | `FAngelscriptGameThreadScopeWorldContext` | 1 | 1 | 1 | `REF-0121` | `World` | `PlannedSource` |
| `MB-080` | `FunctionLibraryMixins` | 1 | 8 | 2 | `REF-0476` `REF-0477` `REF-0478` `REF-0479` `REF-0480` `REF-0481` `REF-0482` | `Editor` `ExpectedDiagnostic` `World` | `PlannedSource` |
| `MB-098` | `Subsystems` | 2 | 9 | 1 | `REF-0585` `REF-0586` `REF-0587` `REF-0588` `REF-0589` `REF-0590` `REF-0591` `REF-0592` | `Editor` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-DELEGATES-001` | `TestSource/Bindings/Delegates/Test_ConstructionAndAssignment_01.as` | `MB-015-S003` `MB-015-S014` `MB-015-S030` `MB-015-S039` | `Positive` | `Engine` |
| `TS-BIND-DELEGATES-002` | `TestSource/Bindings/Delegates/Test_Queries_01.as` | `MB-015-S005` `MB-015-S006` `MB-015-S007` `MB-015-S015` `MB-015-S022` `MB-015-S031` `MB-015-S035` `MB-015-S036` `MB-015-S040` | `Positive` | `Engine` |
| `TS-BIND-DELEGATES-003` | `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_01.as` | `MB-015-S008` `MB-015-S009` `MB-015-S010` `MB-015-S011` `MB-015-S016` `MB-015-S017` `MB-015-S018` `MB-015-S019` `MB-015-S020` `MB-015-S023` | `Positive` | `Engine` |
| `TS-BIND-DELEGATES-004` | `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_02.as` | `MB-015-S024` `MB-015-S025` `MB-015-S026` `MB-015-S027` `MB-015-S032` `MB-015-S034` `MB-015-S041` `MB-015-S042` `MB-015-S043` `MB-015-S044` | `Positive` | `Engine` |
| `TS-BIND-DELEGATES-005` | `TestSource/Bindings/Delegates/Test_Behavior_01.as` | `MB-015-S001` `MB-015-S002` `MB-015-S004` `MB-015-S012` `MB-015-S013` `MB-015-S021` `MB-015-S028` `MB-015-S029` `MB-015-S033` `MB-015-S037` | `Positive` | `Engine` |
| `TS-BIND-DELEGATES-006` | `TestSource/Bindings/Delegates/Test_Behavior_02.as` | `MB-015-S038` `MB-015-S045` | `Positive` | `Engine` |
| `TS-BIND-FANGELSCRIPTDELEGATEWITHPAYLOAD-001` | `TestSource/Bindings/FAngelscriptDelegateWithPayload/Test_Queries_01.as` | `MB-019-S002` | `Positive` | `Engine` |
| `TS-BIND-FANGELSCRIPTDELEGATEWITHPAYLOAD-002` | `TestSource/Bindings/FAngelscriptDelegateWithPayload/Test_MutationAndLifecycle_01.as` | `MB-019-S001` `MB-019-S003` `MB-019-S004` | `Positive` | `Engine` |
| `TS-BIND-FANGELSCRIPTGAMETHREADSCOPEWORLDCONTEXT-001` | `TestSource/Bindings/FAngelscriptGameThreadScopeWorldContext/Test_Behavior_01.as` | `MB-020-S001` | `Positive` | `World` |
| `TS-BIND-FUNCTIONLIBRARYMIXINS-001` | `TestSource/Bindings/FunctionLibraryMixins/Test_Queries_01.as` | `MB-080-S001` `MB-080-S004` `MB-080-S008` | `Positive;NegativeDiagnostic` | `Editor;ExpectedDiagnostic` |
| `TS-BIND-FUNCTIONLIBRARYMIXINS-002` | `TestSource/Bindings/FunctionLibraryMixins/Test_MutationAndLifecycle_01.as` | `MB-080-S002` `MB-080-S003` `MB-080-S005` `MB-080-S006` `MB-080-S007` | `Positive` | `World` |
| `TS-BIND-SUBSYSTEMS-001` | `TestSource/Bindings/Subsystems/Test_Queries_01.as` | `MB-098-S001` `MB-098-S002` `MB-098-S003` `MB-098-S004` `MB-098-S005` `MB-098-S006` `MB-098-S007` `MB-098-S008` `MB-098-S009` | `Positive` | `Editor` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
