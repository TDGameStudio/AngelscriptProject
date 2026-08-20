# COMPLEX test framework (session + tools)

The data-driven catalog is **one enumerator** on a larger framework. The framework is a handwritten COMPLEX `FAutomationTestBase` plus a short-lived **session** that owns tool facades. Stable tests SHALL NOT depend on CQTest (`TEST_CLASS`, `ASSERT_THAT`, CQTest Asserter). CQTest remains an **incubator** only.

Existing Shared helpers already take `FAutomationTestBase&` (`FAngelscriptTestWorld`, `FAngelscriptTestFixture`, `AngelscriptBlueprintTestUtils`). The framework **wraps** those; it does not reimplement World/Blueprint from scratch and does not include CQTest headers.

## Stack

```text
FAutomationTestBase                    UE
        │
        ▼
FAngelscriptComplexAutomation          long-lived registrar
        GetTests()  ← enumerators (catalog, later HotReload pairs, …)
        RunTest(key) → construct session, run, destroy
        holds snapshot only; never FAngelscriptEngine*

        ▼
FAngelscriptComplexSession             per-leaf; THIS is the authoring surface
        Assert      TestEqual / AddError / AddInfo on the Automation Test&
        Corpus      FAngelscriptTestScriptCorpus
        Engine      named profiles, shared | isolated
        World       FAngelscriptTestWorld (spawn, BeginPlay, DispatchActorTick, destroy)
        Blueprint   AngelscriptBlueprintTestUtils (transient child BP, compile)
        (later)     Debugger session, HotReload pair, PIE
```

Two ways to drive a leaf, same tools:

| Mode | When | How |
|---|---|---|
| **Catalog** | Homogeneous or repeatable (profiles, compile/execute, later world observations) | `cases.json` → observation kinds call tools |
| **C++ on session** | Unique story the catalog cannot express yet | Enumerator yields a key; leaf body calls `Session.World().Spawn…` |

Missing a catalog `kind` does **not** mean the tool is missing. Ship the C++ facade first; add JSON kinds when the oracle is stable and homogeneous.

## Tool modules (target)

| Tool | Wraps (already in tree) | First consumers |
|---|---|---|
| Engine | `FAngelscriptTestFixture` / acquisition / profiles | Wave A catalog `vm` / cache / JIT |
| Corpus | `FAngelscriptTestScriptCorpus` (new) | All stable `.as` |
| World | `FAngelscriptTestWorld` | `world-story` graduation; not CQTest |
| Blueprint | `AngelscriptBlueprintTestUtils` | `World.Blueprint` / child-BP stories |
| Assert | `FAutomationTestBase` | Every leaf |
| Debugger | `AngelscriptDebuggerTestSession` | later; not Wave A |
| HotReload | sibling COMPLEX enumerator | later |

Do **not** fold Native SDK / Standalone CTest into this session. Do **not** reuse `FBridge` or prefix `Angelscript.ScriptTests`. Teaching `UAngelscriptTestSuite` stays a separate COMPLEX.

## What this overturns

Earlier: “DataDriven v1 does not Tick Actors; leftover CQTest is the World driver.”  
Now: World/Blueprint are **session tools**. After a story is stable, the driver is COMPLEX session, not CQTest. Wave A still ships Engine + Corpus + catalog compile/execute first; World/Blueprint facades are the next framework slice (C++ API before JSON kinds).

Earlier rejected: “one COMPLEX for World, DAP, and Bindings.”  
That rejected **one JSON DSL / one GetTests bag**. It does **not** reject one **session** with separate tool modules and separate enumerators. Bind-contract C++ smoke and DAP stay out of Wave A tools. DAP becomes a later tool module, not a catalog profile.

## CQTest

- Allowed: WIP `TEST_METHOD` + `ASTEST_AS`.
- Forbidden in the framework: `#include` CQTest, `ASSERT_THAT`, rewriting CQTest `GetTests`.
- After graduation: no leftover CQTest driver for World ticks once `Session.World()` exists. Until that facade ships, existing Functional CQTest may dual-run.
- Do not migrate the existing 400+ CQTest files in harness Wave A.

## Folder sketch (implementation later)

```text
AngelscriptTest/Complex/          framework (Automation + Session + tool facades)
AngelscriptTest/DataDriven/       catalog enumerator + cases.json parse
Shared/                           World, Fixture, Blueprint helpers stay; session wraps them
```

Wave A may keep types under `DataDriven/` and rename to `Complex/` when the World/Blueprint facades land — do not bikeshed the folder in Wave A.

## Apply order

1. Wave A: Session + Engine + Corpus + catalog observations (`compile` / `execute*`) + OptionalEmpty goldens.
2. Framework slice: Session.World + Session.Blueprint C++ APIs (wrap existing helpers); one golden World.Actor leaf that is **not** CQTest.
3. Optional catalog kinds for spawn/tick once those goldens are boring.
4. Extractors move Syntax/Coverage onto catalog; Functional World onto Session.World.
