# AS Corpus And Script Functional Coverage Matrix

This index turns the plugin's implementation-oriented tests and bind providers into a user-capability plan. It does not replace `openspec/changes/test-coverage/coverage-matrix.md`; that record remains the detailed authority for the 1022-method C++ Coverage baseline.

## Planning Baseline, 2026-08-11

| Surface | Current scale | Use in this change |
|---|---:|---|
| Manual binding source files matching `Bind_*.cpp` | 204 | Audit every file, normalize split files into provider families, and map each family to a capability row or explicit non-corpus disposition |
| Binding files with API-table-like source comments | 127 | Reuse as evidence, then verify AS spelling and behavior rather than copying the tables blindly |
| Binding files registering global functions | 59 | Normalize global and namespace entry points into user workflows |
| Binding files participating in namespace registration | 57 | Confirm the published namespace and aliases in script-facing evidence |
| Binding files registering methods | 94 | Confirm member, mixin, property, operator, and overload behavior; categories overlap with the rows above |
| Coverage domain matrices | 18 | Reuse scenario evidence and unsupported boundaries |
| Coverage test methods | 1022 | Evidence only; do not mirror one-to-one |
| Bindings `.cpp` files | 87 | Confirm AS spelling, declarations, and representative native reachability |
| FunctionLibraries `.cpp` files | 18 | Confirm Runtime library/mixin contracts, signatures, parity, null guards, callbacks, and behavior |
| Final initialized core Blueprint-function-library classes | Fresh implementation-time inventory | Map generated, reflected, and manually adapted UE libraries, not only Runtime wrappers visible in source scans |
| Functional `.cpp` files | 52 | Confirm UObject/World/Actor/Component/runtime semantics |
| Syntax `.cpp` files | 19 | Confirm language spelling and compile boundaries |
| Host corpus examples | 27 under `Script/Examples/**` | Classify and migrate/split/retire explicitly |
| Host script tests | 9 under `Script/Tests` | Retain the reflected-suite reference; migrate the one path-loaded hot-reload fixture; replace or explicitly dispose shallow fixtures |

Counts are a scan baseline, not completion targets. Implementation begins by re-running the inventory commands in `source-audit.md` and recording any drift.

## Dispositions

| Disposition | Meaning |
|---|---|
| `Covered` | Corpus, AS behavior test, and sufficient C++ evidence already satisfy the row |
| `CorpusGap` | A realistic reader-facing theme example is missing or too shallow |
| `ScriptTestGap` | The normal project script path lacks an executable reflected AS test |
| `CxxBehaviorGap` | Existing C++ coverage proves only declaration/compile shape or omits stable runtime semantics |
| `NeedsNativeFixture` | A bounded test-only native reflected type/function/delegate is required |
| `Unsupported` | Current fork rejects or intentionally omits the surface; negative evidence is required |
| `EnvironmentBound` | Stable behavior requires an asset, RHI, editor service, user/input device, or network topology unavailable to the default headless path |
| `OutOfScope` | Optional plugin, internal-only implementation, or separate product concern |

Rows may carry more than one gap. A row becomes `Covered` only after its required corpus/test/evidence combination and focused verification pass.

## Matrix Index

| Matrix | Themes | Primary evidence |
|---|---|---|
| [01-language.md](matrices/01-language.md) | Language | Syntax, Compiler, Preprocessor, Coverage language rows |
| [02-math.md](matrices/02-math.md) | Math | `Bind_FMath*`, math value-type binds, Coverage Math, FunctionLibraries Math |
| [03-containers.md](matrices/03-containers.md) | Containers | TArray/TMap/TSet/TOptional/range binds and Coverage matrices |
| [04-text-reflection-objects.md](matrices/04-text-reflection-objects.md) | Text, Reflection, Objects | FString/FName/FText, UClass/UObject/UStruct/UEnum, reference binds |
| [05-inheritance-interface-delegates.md](matrices/05-inheritance-interface-delegates.md) | Inheritance, Interface, Delegates | Functional dispatch and delegate/event tests |
| [06-actor-component.md](matrices/06-actor-component.md) | Actor, Component | Actor/Component binds and Functional lifecycle tests |
| [07-world-subsystems-timers.md](matrices/07-world-subsystems-timers.md) | World, Subsystems, Timers | World binds, subsystem tests, timer Coverage/Functional tests |
| [08-engine-features.md](matrices/08-engine-features.md) | Input, Collision, UI, Animation, Assets | Engine feature binds, Coverage, FunctionLibraries |
| [09-networking.md](matrices/09-networking.md) | Networking | RPC/compiler and real network functional evidence |
| [10-interop-diagnostics.md](matrices/10-interop-diagnostics.md) | Interop, Diagnostics | UFUNCTION marshalling, logging/error/debug/console/platform/file/json paths |
| [11-blueprint-function-libraries.md](matrices/11-blueprint-function-libraries.md) | BlueprintLibraries | UE Blueprint libraries and AngelscriptRuntime static/mixin function libraries |
| [12-binding-surface-cases.md](matrices/12-binding-surface-cases.md) | Bindings | AS-facing aliases, namespaces, operators, construction, iterators, reflection, references, delegates, and diagnostics |

## Completion Rules

- Every current manual provider appears in `source-audit.md` inventory output and maps to at least one matrix row or a named internal/non-corpus disposition.
- Every one of the 87 Bindings test sources and 18 FunctionLibraries test sources maps to one or more matrix rows as contract/behavior evidence or receives an explicit internal-only disposition in `binding-library-crosswalk.md`.
- Every stable, user-visible positive row has a meaningful corpus example, a reflected AS behavior test, and sufficient existing or newly planned C++ evidence unless the row explains why one layer adds no signal.
- API-dense corpus targets have verified source-local AS usage tables.
- No row remains `CorpusGap`, `ScriptTestGap`, `CxxBehaviorGap`, or `NeedsNativeFixture` at change completion.
- `Unsupported`, `EnvironmentBound`, and `OutOfScope` rows remain valid only with specific evidence and reasons.
- Script-test pass/fail comes from assertions. Logs provide bounded learning/diagnostic context only.
- The optional GameplayTags/GAS plugins are not counted in core completion.
