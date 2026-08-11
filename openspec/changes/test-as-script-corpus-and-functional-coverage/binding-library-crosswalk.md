# Binding And Function-Library Crosswalk Contract

This artifact defines how implementation maps binding sources and their C++ tests to reader-facing corpus cases and independent AS functional tests. It is not the completed 204-row audit; the dated audit output is created during implementation under `research/` so it reflects the exact source revision being tested.

## Audited Inputs

| Input surface | Planning baseline | Required disposition |
|---|---:|---|
| `AngelscriptRuntime/Binds/Bind_*.cpp` | 204 files | Every file belongs to exactly one logical provider family and every family maps to corpus/test rows or an explicit non-corpus reason |
| `AngelscriptTest/Bindings/*.cpp` | 87 files | Every source is AS spelling/contract/route evidence for one or more rows or is marked internal-only |
| `AngelscriptTest/FunctionLibraries/*.cpp` | 18 files | Every source is signature/parity/behavior evidence for one or more BlueprintLibraries/domain rows or is support-only |
| `AngelscriptRuntime/FunctionLibraries/*` | Current headers and implementations | Every published class/function/mixin maps to a library/domain row or an explicit unavailable/internal reason |
| Final initialized core `UBlueprintFunctionLibrary` surface | Fresh implementation-time engine inventory | Every AS-visible class/function maps to a domain/BlueprintLibraries row or an explicit internal/unsupported/environment-bound reason |

The current binding-file characteristics are overlapping: 127 have API-table-like comments, 59 register global functions, 57 participate in namespace registration, and 94 register methods. These counts guide review workload; they are not example quotas.

## Implementation Audit Files

Implementation creates two evidence files:

### `research/manual-bind-provider-audit.csv`

| Column | Meaning |
|---|---|
| `source_file` | Exact project-relative `Bind_*.cpp` path |
| `provider_family` | Stable logical family after `_Type`, `_Functions`, and registration shards are combined |
| `publication_kind` | `Type`, `Constructor`, `Method`, `Property`, `Operator`, `Global`, `Namespace`, `Mixin`, `Reflective`, `GeneratedOverride`, `Infrastructure`, or a semicolon-separated combination |
| `published_as_surface` | Verified AS namespace/type/receiver and representative declarations; never a registrar callback name |
| `runtime_library_source` | Function-library/reflection/generated source when the binding delegates publication or behavior |
| `matrix_rows` | Owning domain, `BPLIB-*`, and/or `BIND-*` IDs |
| `corpus_targets` | One or more exact corpus paths or `None` |
| `script_test_targets` | One or more exact AS-test paths or `None` |
| `disposition` | `DomainOwned`, `BlueprintLibraryOwned`, `BindingMechanicOwned`, `InternalOnly`, `Unsupported`, `EnvironmentBound`, or `OutOfScope` |
| `reason` | Required for every disposition other than the three owned forms |

### `research/binding-test-crosswalk.csv`

| Column | Meaning |
|---|---|
| `test_source` | Exact Bindings or FunctionLibraries `.cpp` path |
| `automation_prefixes` | Current discovered prefix or prefixes |
| `evidence_kind` | `ASSpelling`, `CompileAndCall`, `Signature`, `Parity`, `Behavior`, `Negative`, `Infrastructure`, or a combination |
| `provider_families` | Logical provider families proved by the source |
| `matrix_rows` | Normalized user scenarios supported by the source |
| `project_script_signal` | What a themed `.as` test adds beyond this C++ evidence, or `NoAdditionalSignal` with a reason |
| `cxx_gap` | `None` or the missing behavior and its correct C++ owner |

### `research/blueprint-function-library-audit.csv`

| Column | Meaning |
|---|---|
| `native_library_class` | Final initialized UE/Runtime `UBlueprintFunctionLibrary` class |
| `published_as_namespace_or_receiver` | Verified AS namespace, static class, or mixin receiver after metadata and generation |
| `published_functions` | Stable user-visible function families, normalized by workflow |
| `publication_path` | Manual bind, Runtime library, generated/UHT path, or reflective fallback |
| `matrix_rows` | Owning domain and `BPLIB-*` rows |
| `corpus_targets` | Existing/new focused targets or `None` |
| `script_test_targets` | Existing/new AS-test targets or `None` |
| `disposition` | `DomainOwned`, `BlueprintLibraryOwned`, `InternalOnly`, `Unsupported`, `EnvironmentBound`, or `OutOfScope` |
| `reason` | Required when no positive owner exists |

## Provider-Family Normalization Rules

- `Bind_FVector_Type.cpp`, `Bind_FVector_Functions.cpp`, and `Bind_FVector.cpp` are reviewed as one FVector provider family while preserving each file in the CSV.
- A `Bind_*_Functions.cpp` implementation file without registration is not assigned a fake corpus file; it inherits the owning family's rows.
- A file that publishes multiple unrelated AS surfaces may list multiple matrix rows, but it still has one primary provider family for accounting.
- `Bind_FunctionLibraryMixins.cpp` and generated-override files map through the underlying Runtime library classes and their published `ScriptName`/`ScriptMixin` forms.
- Registration architecture, native-module bridging, configuration, and deprecation infrastructure remain `InternalOnly` unless a stable author-visible behavior is exposed.
- A Bindings test with many methods is normalized by scenario; test-method count never determines AS file or test-leaf count.

## Corpus Ownership Rules

| Surface characteristic | Primary corpus owner |
|---|---|
| A realistic gameplay/data workflow already owns the API | Existing domain file under `Script/<Theme>` |
| Discovering/combining a static, namespace, WorldContext, callback, or receiver-mixin library is the lesson | `Script/BlueprintLibraries/` |
| Alias, overload, operator, constructor, iterator, reference, reflective-call, or diagnostic semantics are the lesson | `Script/Bindings/` |
| Only registrar/generator/native-routing internals are involved | No corpus; `InternalOnly` evidence |
| API is unsupported or environment-dependent | Negative/domain test or explicit `Unsupported`/`EnvironmentBound` row |

One family may be indexed in a domain file and a specialized BlueprintLibraries/Bindings file, but the executable workflows must be distinct and cross-linked. Copying the same function body into two themes is not acceptable.

## Blueprint And Runtime Library Evidence Order

1. Read the Runtime function-library header and `ScriptName`/`ScriptMixin`/WorldContext metadata.
2. Read the relevant `Bind_*.cpp` generated override or manual registration.
3. Confirm the exact AS declaration in Bindings/FunctionLibraries tests or generated API evidence.
4. Confirm behavior, null guards, callbacks, side effects, and environment requirements in FunctionLibraries/Coverage/Functional tests.
5. Put the verified AS form and evidence paths in the corpus table; native library names remain evidence, not user syntax.

## Completion Checks

- The audit contains 204 unique binding source paths with no duplicate or missing file.
- The test crosswalk contains 87 unique Bindings test sources and 18 unique FunctionLibraries test sources.
- The Blueprint library audit enumerates the final initialized core library surface rather than only the hand-written wrappers known when this plan was recorded.
- Every non-internal stable positive provider family has teaching evidence, project-script behavior evidence, and sufficient C++ contract/behavior evidence.
- `InternalOnly`, `Unsupported`, `EnvironmentBound`, and `OutOfScope` rows have exact reasons.
- No corpus path exists solely to make a source-file count line up.
