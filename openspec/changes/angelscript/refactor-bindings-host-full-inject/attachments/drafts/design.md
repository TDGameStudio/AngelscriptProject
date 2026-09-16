# Accepted design: complete host freeze and retire Store tests

Translated from the local `host-bind-completion` design. Approval: bindings-gap-audit Q69-Q78; create authorization 2026-09-16. Do not reopen `host-collect-inject`. Prerequisite: archived Change `angelscript/2026-09-16-refactor-bindings-process-host-typeinfo`.

## Settled

| Round | Decision |
|---|---|
| Q69 | Green is the kept corpus, not the old 310 RuntimeBindings tests as-is |
| Q71=A | Isolate or retire Recording/Store; migrate family and Calls contracts to Host; FullRuntime uses Collection inject |
| Q72=B | One Change: Temp oracle first, then product, family tests after |
| Q73=A | Editor injects the complete frozen graph; migrated types no longer use `ExecuteRegisteredBinds` |
| Q74=A | All seven phases run in one `ExecuteToHost` (including Blueprint class writes); `BindScriptTypes` injects only |
| Q75=A | Delete the Store/Apply production path at the end of this Change; retire Recording tests with it |
| Q76=A | Change id `angelscript/refactor-bindings-host-full-inject` |
| Q77 | First B (stay in draft); flipped on 2026-09-16 by the create request |
| User 2026-09-16 | Later tests must not pack graph+inject+call+accounting into one method |
| Q78=A | Scheme/perf gates are S1-S6 / P1-P4 in verification-gates.md |
| User 2026-09-16 | Post-bind oracle is `AngelscriptTest/Temp` plus bind logs, not Host* pointer calls |

## Goal

A bound engine is proven first under `AngelscriptTest/Temp`: `InitializeWithoutInitialCompile`, then Prepare/Execute `TArray` / `FString` / `FVector` / `Print`, then read `AS_BIND_*` / `GetLastSnapshot()`. Post-inject compile uses `asCBuilder`. Production collection no longer filters. One `ExecuteToHost` writes the HostProcess graph through the existing seven phases and freezes it. Editor `BindScriptTypes` only calls `EnsureProcessHostCollection` and `InjectDefinitions`. HostScheme keeps inject-only / share / freeze. Tests move remaining family contracts onto Host fixtures and isolate or retire descriptor-library tests. Old cache suites stay out.

## Non-goals

UHT generator, disk cache, old cache suites, manifest v2, wholesale directory rearrange, legacy revival, hot replacement of a published engine. Do not reopen the predecessor design. Do not treat old Store tests or Host* pointer calls as the bind-after-engine gate.

## Architecture

```text
every process FAngelscriptBind record
        |
        v
EnsureProcessHostCollection        // no IsProcessHostEligibleRecord whitelist
        |
ExecuteToHost                      // all seven phases; no skip of Infrastructure/Reflection
  TypeDeclarations
  TypeInfrastructure
  ExplicitBindings
  GeneratedBindings
  ReflectionBindings               // Blueprint class writes; as.Bind.WriteWorkers unchanged
  PostReflectionBindings
  Finalization
        |
        v  freeze HostProcess
BindScriptTypes
  InjectDefinitions(HostDefs)      // no ExecuteRegisteredBinds
CreateForBindings() / CreateForBindings(Collection)
  same frozen graph into test engines
```

After freeze, `ExistingClass("FString").Method` must fail. Every callback that writes host types must finish before freeze — that is why all seven phases run once.

## Product changes

1. Delete or empty `IsProcessHostEligibleRecord`. `EnsureProcessHostCollection` copies every registered record that `Append` accepts.
2. `ExecuteToHost` removes the `continue` for `TypeInfrastructure` and `ReflectionBindings`.
3. `BindScriptTypes`: host capture failure is an error return, not a Verbose skip; success injects; it does not call `ExecuteRegisteredBinds`.
4. No-argument `CreateForBindings()` uses the Collection freeze, not Recorder to Store to Apply.
5. `CreateForBindings(Store)` remains only until the remaining Store tests are retired, then it is deleted.

Blueprint write waves stay class-owned; `WriteWorkers` default 1. They write Host types on the Collection, not live types on the editor Engine.

Host-incompatible sidecars (string factory, TypeDatabase) may keep an `IsHostTarget()` early return. That is not a skip of the phase.

## Test changes (Q71=A)

| Bucket | Disposition |
|---|---|
| Recording ~53 | Isolate or retire; not a green gate |
| Types/Calls ~48 | Move contracts onto the Host graph; delete "two Engines each own a TypeInfo" |
| Reflection ~53 | Move behavior onto Host; Accounted-only cases leave with Store |
| Engine Store 18 | Creation uses Collection; old Isolation aligns on shared pointers |
| Family ~130 | Move Core/Math/Containers/... onto `Bindings.Host*` |
| FullRuntime 6 | Full Collection, ExecuteToHost, inject |

New proofs use `CreateForBindings(Collection)` or inject-then-Prepare/Execute. `GetBindingInstallation()` is not a success condition.

Style: one method, one scene. Prefer `ASTEST_AS` when proving the post-inject script surface. See host-test-style.md.

## Verification (Q78=A)

Completion uses verification-gates.md.

**Scheme gates S1-S6**: inject only, no replay; injected `.as` compiles and calls FString/FVector/TArray; two engines share pointers and IDs; post-freeze writes fail; a phase failure publishes no partial graph.

**Perf gates P1-P4**: record one freeze wall-clock; a second inject does not rerun registration; destroying one engine leaves the shared graph callable; record Len/opAdd median/p95. No "must be faster" threshold. Numbers go in `attachments/data/`. A perf node cannot complete without that attachment.

**Not gates**: old 310 tests green as-is, unadapted Legacy Performance, WriteWorkers speedup, Insights full traces, unconditional Quick/Integration.

Family migration is tracked separately from S/P gates.

## Naming

Change: `angelscript/refactor-bindings-host-full-inject` (Q76=A).
Neighbor: `refactor-bindings-process-host-typeinfo`. This design adds no new public C++ types.
Scheme/perf prefixes: `Angelscript.UnitTest.Bindings.HostScheme` and `Angelscript.UnitTest.Bindings.HostPerf`.

## Failures and edges

- Any production callback failure: no published freeze, `BindScriptTypes` fails, no half graph is injected.
- Repeat `EnsureProcessHostCollection`: reuse a frozen graph; do not rerun callbacks.
- External-module binds still enter the same Collection before freeze.
- Test-module `Host*` records may enter the production freeze (already on the previous whitelist), or Finalize may drop `AngelscriptTest` owners using the existing OwnerModule convention. Do not invent a new public name for that filter.
