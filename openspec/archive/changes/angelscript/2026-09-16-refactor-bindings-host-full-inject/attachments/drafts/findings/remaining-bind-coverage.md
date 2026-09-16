# Remaining binds and old tests

Observation from 2026-09-16 after `host-collect-inject` archived. Do not reopen that design. This page compares current source: which path production uses, which path old `RuntimeBindings.*` tests use.

## Three paths now

```text
process-static FAngelscriptBind records
        |
        +-- EnsureProcessHostCollection          // copies 8 production names + Host* test records
        |    ExecuteToHost -> Frozen HostProcess
        |    CreateForBindings(Collection) -> InjectDefinitions
        |    BindScriptTypes captures then does not inject the editor
        |
        +-- BindScriptTypes -> ExecuteRegisteredBinds   // editor still uses this: all callbacks hit this Engine
        |
        +-- TypeBindInfoRecorder / Store / Apply       // old RuntimeBindings tests still use this
             CreateForBindings(Store) -> Install + ConnectNative
```

`ExecuteToHost` skips `TypeInfrastructure` and `ReflectionBindings`. A frozen host cannot `RegisterObject*` again. Production therefore does not inject the full FString/FVector package into the live editor: later `ExistingClass("FString").Method` would hit frozen types.

## Production whitelist (current)

`IsProcessHostEligibleRecord` accepts only:

- Declarations: `FString.TypeDeclarations`, `FVector.TypeDeclarations`, `TArray/TMap/TSet/TOptional.Declaration`
- Members: `FString.ExplicitBindings`, `FVector`, and test records whose names start with `Host`

Inventory: 332 sites (12 executable / 242 metadata_only / 78 companion). Family Host tests copy collection-local records, not the full editor set. `Binds/` has about one hundred `FAngelscriptBind` objects; most still run only in `ExecuteRegisteredBinds`.

## Two test suites

| Suite | Prefix | Approx count | Proves | 6.1 |
|---|---|---|---|---|
| New Host | `Angelscript.UnitTest.Bindings.Host*` | 30 | Collection / ExecuteToHost / inject / family ledger | green |
| New Isolation | `Bindings.RuntimeBindingIsolation` + `RuntimeBindings.Engine.Isolation` | 11 | Shared host and two engines | green |
| Old Recording / Types / Values / Runtime / Calls | `Angelscript.UnitTest.RuntimeBindings.*` | ~310 | Store record, Apply install, some Prepare/Execute | explicitly omitted |

Old tests represent:

- store-only: `Store`, `Facade`, `Providers`, `Manifest`, `Validation` — the descriptor library itself
- `CreateForBindings(Store)`: `Vectors`, `Array`, most Runtime.* — RecordSelectedProviders then Install
- `Calls.Native`: handwritten Store plus `TypeBindInfoApply::Install/ConnectNative`
- operations-only: hit `FScriptArray` directly, no script compile

They prove the descriptor/install architecture this Change replaces, not the HostProcess graph.

## Conclusions (observation, then settled)

1. "Every plugin bind is green" is not "keep the 310 old RuntimeBindings tests as the green gate".
2. Old tests already fork from the product path: editor is DirectBinds, Host tests are Collection, old tests are Store/Apply.
3. Dual oracles explain why 6.1 only proved the new Host contract.
4. Q69 / Q71: keep a retained set; migrate family and Calls onto Host; isolate or retire Recording/Store.

Per-file catalog: [old-runtimebindings-catalog.md](old-runtimebindings-catalog.md).

## Later settlement

- Q74=A: all seven phases enter one `ExecuteToHost`.
- Q77: user authorized `angelscript/refactor-bindings-host-full-inject`.
