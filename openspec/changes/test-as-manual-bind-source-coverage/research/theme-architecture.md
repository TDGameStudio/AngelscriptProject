# TestSource theme architecture

`TestSource` is the canonical source centre for reviewed, reusable, handwritten AngelScript test programs. C++ test folders remain drivers and reference locations; plugin fixtures, inline C++ strings, generated static functions, and release copies are consumers.

## Theme kinds

| Kind | Themes | Rule |
|---|---|---|
| Contract | `Bindings` | AS-facing entry visibility and wiring; keep the logical Bind layout. |
| Framework | `TestFramework` | The reflected AS test protocol is the subject; final results require an independent C++ oracle. |
| Semantic | `Language`, `Definitions`, `Containers`, `Feature`, `World`, `Gameplay`, `Optional` | Store reusable programs by the AngelScript/UE subject being proved. |
| Transition | `HotReload` | Keep versioned source members together and state the transition oracle. |
| Protocol payload | `Debugger` | Stable marker programs for debugger clients; the DAP transport remains host machinery. |
| Tooling | `Generation` | Rules, recipes and goldens owned by the generation OpenSpec; not a test theme. |

## Theme versus question

The physical TestSource theme answers “where is this reviewed source maintained?”. The question id answers “what does the driver prove?”. `Bindings` normally uses `bind-contract`; semantic sources use `surface-form`, `behavior-matrix`, `world-story`, `reload-generation`, or `same-as-profile`. The test framework does not create a ninth question id.

Bindings and semantic themes may mention the same API family only when their oracles differ. A bind smoke proves the entry exists and routes correctly; a semantic source proves returned values, state, order, identity, diagnostics, lifecycle, or profile parity.

## Canonical layout

```text
TestSource/
├── Bindings/
├── TestFramework/
├── Language/
├── Definitions/
├── Containers/
├── Feature/
├── World/
├── Gameplay/
├── Optional/
├── HotReload/
├── Debugger/
└── Generation/      # tooling package, not a test theme
```

No empty directory is required. A target appears only when a planned source row exists.

## Reference dispositions

Every current test method and source candidate uses one of:

- `PlanHandwrittenSource`
- `ExistingTestSource`
- `ReferenceOnlyNativeSDK`
- `ReferenceOnlyTeaching`
- `HostOnly`
- `DuplicateReference`
- `GeneratedLater`
- `Blocked`
- `NoReusableAngelScript`

The inventory is intentionally broader than the planned source list. Accounting for host-only and generated-later evidence is how the record proves that a C++ theme was considered without manufacturing a meaningless `.as` file.
