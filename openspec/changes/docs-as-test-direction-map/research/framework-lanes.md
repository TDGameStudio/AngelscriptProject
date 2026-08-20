# Two-lane test framework

The subject ladder answers **what the `.as` is about**. This note answers **which runner executes the test**. Identity stays `(subject, question)`. The lane is not a ninth identity.

**Target:** a plugin-owned **COMPLEX framework** on `FAutomationTestBase` plus a per-leaf **session** with tool facades (Engine, Corpus, World, Blueprint, …). The data-driven catalog is one enumerator on that framework. CQTest is the **incubator** only. Stable tests SHALL NOT depend on CQTest. Detail: `test-as-data-driven-engine-harness/research/complex-framework.md`.

```text
  Fixtures/   subject tree   (.as once)
       │
       ▼
  FAngelscriptTestScriptCorpus
       │
       ├── Incubator   CQTest          WIP only; TEST_METHOD + ASTEST_AS
       │
       └── House       COMPLEX framework
           FAngelscriptComplexAutomation  (GetTests enumerators)
           FAngelscriptComplexSession     (tools: Engine, Corpus, World, Blueprint)
                ├── Catalog enumerator     cases.json × profiles
                └── C++-on-session leaves  unique stories until a catalog kind exists
```

## Incubator — CQTest

Keep today’s `TEST_CLASS` / `TEST_METHOD` **while the API is moving**. Inline `ASTEST_AS` is allowed. The COMPLEX framework MUST NOT `#include` CQTest or use `ASSERT_THAT`.

After the feature is stable, CQTest MUST NOT own the only copy of the `.as`, and MUST NOT remain the driver for World ticks / Blueprint compile once the matching session tool exists.

## House of record — COMPLEX session + tools

Handwritten `FAutomationTestBase` (`bInComplexTask`). Steal CQTest’s **per-leaf isolation**, not its macros. Precedent for expansion: `FBridge` mechanism only — do not reuse `FBridge` or prefix `Angelscript.ScriptTests`.

Session tools wrap Shared helpers that already take `FAutomationTestBase&`:

| Tool | Wraps |
|---|---|
| Engine | `FAngelscriptTestFixture` / named profiles |
| Corpus | `FAngelscriptTestScriptCorpus` |
| World | `FAngelscriptTestWorld` |
| Blueprint | `AngelscriptBlueprintTestUtils` |
| Assert | `FAutomationTestBase` (`TestEqual` / `AddError`) |

Catalog observation kinds call tools. A unique World story MAY call `Session.World()` from C++ before a JSON `kind` exists. Native SDK / Standalone CTest stay outside. Teaching `UAngelscriptTestSuite` stays `FBridge`.

Prefix for the catalog enumerator: `Angelscript.TestModule.DataDriven.*`. Additional enumerators MAY use sibling prefixes (HotReload corpus).

## Question → runner (after graduation)

| Question | After graduation |
|---|---|
| `native-fork` | Native / CTest (never this framework) |
| `surface-form` | Catalog `compile` (+ profiles when Cache/JIT matter) |
| `bind-contract` | C++ smoke; any `.as` in `Fixtures/`. Not Wave A tools. |
| `behavior-matrix` | Catalog `vm` / generate products |
| `world-story` | **Session.World()** (not leftover CQTest). Catalog kinds later. |
| `reload-generation` | Sibling enumerator on the same session tools when it lands |
| `same-as-profile` | Catalog `profiles[]` |
| `host-machinery` | C++ if no AS program; DAP is a later session tool |

## Graduation

```text
  exploring
       │  CQTest + ASTEST_AS
       ▼
  stable
       ├─ (subject, question)
       ├─ .as → Fixtures/
       ├─ catalog-expressible → cases.json + profiles[]
       ├─ World / Blueprint → Session tools (C++ leaf or later catalog kind)
       └─ delete inline CQTest copy
```

Do not force-migrate the existing 400+ CQTest files in harness Wave A. New work uses the framework from the day Session.Engine + Corpus ship; World/Blueprint facades are the next slice.

## Approaches rejected

- Stamp one CQTest `TEST_METHOD` per `(fixture, profile)`.
- Put the engine matrix on `UAngelscriptTestSuite`.
- One JSON DSL that also encodes DAP and bind smoke on day one (wrong oracle). **A shared session with separate tools is not that.**
- Rewrite CQTest macros to scan JSON.
- Reimplement World/Blueprint from scratch instead of wrapping `FAngelscriptTestWorld` / `AngelscriptBlueprintTestUtils`.

## Apply order

1. Wave A: Session + Engine + Corpus + catalog compile/execute goldens.
2. Session.World + Session.Blueprint C++ facades; one non-CQTest World.Actor golden.
3. This map’s docs/suite.
4. Extractors; optional catalog kinds for spawn/tick.
5. Wave B: Coverage generate products.

File map: `openspec/changes/test-as-data-driven-engine-harness/tasks.md` and `research/complex-framework.md`.
