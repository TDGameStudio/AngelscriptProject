# UE data-driven automation (distilled)

Distilled from the working dump `数据驱动参考.txt` (repo root) plus Engine `FAutomationTestBase` / CQTest notes already used by this change. Do not treat the root `.txt` as the design authority; this file is the attachment.

This change uses **COMPLEX `FAutomationTestBase`**, not CQTest, Automation Spec, or Catch2, as the leaf expander. Details of what we steal from CQTest live in `design.md` Decision 3.

## What UE means by data-driven

A simple test (`IMPLEMENT_SIMPLE_AUTOMATION_TEST`) is one class → one leaf. A complex test is **one registered class instance → N leaves**. You enumerate data in `GetTests`; the framework calls the same `RunTest` N times with different `Parameters` and reports each result separately.

That is the whole mechanism. There is no extra runtime besides `GenerateTestNames` zip-ing two parallel string arrays.

```text
data source (JSON catalog / generator table / scanned files)
        │
        ▼
GetTests()  fills aligned arrays
        OutBeautifiedNames[i]   → Session Frontend label
        OutTestCommands[i]      → RunTest(Parameters)
        │
        ▼
FAutomationTestBase::GenerateTestNames()
        beautified = PrettyName + "." + BeautifiedNames[i]
        complete   = TestName + " " + ParameterNames[i]
        │
        ▼
RunTests prefix / Session Frontend picks one leaf
        │
        ▼
RunTest(Parameters[i])   same function, different key
```

`bComplexTask = true` is the only base-class flag that requires you to implement `GetTests`. Simple-test macros emit a one-entry empty `GetTests`. Direct `FAutomationTestBase(Name, true)` subclasses are equivalent to `IMPLEMENT_COMPLEX_AUTOMATION_TEST`; this repo already does that in `FAngelscriptScriptTestAutomation::FBridge`.

`GetTests` that runs longer than about 10 seconds warns (Session Frontend hitch). Parse catalogs once into an immutable snapshot.

## `Parameters` is only an `FString`

`OutTestCommands[i]` is stored on `FAutomationTestInfo` and passed unchanged into `RunTest`. Anything that must travel that channel has to be a string.

Engine-typical pattern (use this): **command is a lookup key**, structured data lives in a snapshot both `GetTests` and `RunTest` can read.

| Pattern | Use here? |
|---|---|
| Key only (`theme/caseId@profileId`) | **Yes.** Catalog / generator snapshot holds fixtures, observations, `cacheRoot`. |
| Integer index into a static table | Acceptable for generated product cells if the snapshot is stable for that enumerate. |
| Comma-packed values (`Skill_001,100,85`) | **No** for this harness. Do not serialize `FAngelscriptEngineConfig`, observation arrays, or paths with spaces. |
| Raw filesystem path as the command | Avoid. Spaces break complete-name parsing (`TestName + " " + Parameters`). Python tests use paths; our bridge follows `FBridge` (opaque command after the last space). |
| JSON object / `@file` inside `Parameters` | **No.** GMP XConsole can do that on **argv tokens** (`research/gmp-xconsole-parameters.md`). COMPLEX `Parameters` is one space-joined string. Fat payloads stay in the catalog snapshot (or a Saved sidecar keyed by the command). |

Command-line `-ExecCmds="Automation RunTests <prefix>"` filters beautified names. It does not inject extra `Parameters`. `Tools\RunTests.ps1 -TestPrefix` is the project equivalent. Do not invent a second command-line dialect to rewrite catalog fields.

## Other UE data-driven styles (not this harness)

| Style | How it expands | Why not the matrix driver |
|---|---|---|
| COMPLEX / `IMPLEMENT_COMPLEX_AUTOMATION_TEST` | `GetTests` at enumerate time | **This is the driver.** Prefer a handwritten subclass so we can override `GetTestSourceFileName(CompleteName)`. |
| Automation Spec | `Describe` + loop of `It`, lambda capture; `Redefine()` when files change | BDD for logic tests. Cannot own isolated generation engines, Cache V2 two-phase, or coordinator modes cleanly. |
| Catch2 LLT | Generators / `SCENARIO` outside UObject | Matrix needs `FAngelscriptEngine`. Native SDK already has its own layer. |
| CQTest | `TTestRunner::GetTests` lists **`TEST_METHOD` names** registered at static init | Excellent for Bindings / World / one-off C++. Not a catalog expander unless you rewrite `GetTests`, which is COMPLEX wearing CQTest clothes. |

The dump's skill-damage CSV example is the right *shape* (one `RunTest`, N independent leaves) and the wrong *payload* (a calculator + numbers). This harness's row is `(fixture or generated AS, engine profile)`, not `(SkillID, InputDamage, ExpectedOutput)`.

Engine samples that cartesian-product names × methods × stages (`FPipelineTestAdvancedNodes`) are explicitly **out**. Catalogs list `profiles[]`; the harness does not invent a full product.

## CQTest, from the same dump

CQTest is a fourth scaffolding on `FAutomationTestBase`, not a replacement for COMPLEX.

```text
FAutomationTestBase
    TTestRunner<Asserter>          // registered instance; GetTests = method names
        creates per leaf:
    TTest<Derived, Asserter>       // new object each TEST_METHOD
```

Worth copying into **our** COMPLEX driver:

- New object per leaf so members cannot leak across `RunTest` calls (COMPLEX is one long-lived instance).
- Setup / teardown around each leaf (`BEFORE_EACH` / `AFTER_EACH` as session ctor/dtor).
- Assertions still write `ExecutionInfo` via `FAutomationTestBase` (`TestEqual`, `AddError`, `AddInfo`). Existing `ExpectGlobalInt` already takes that reference.
- Source mapping (`GetTestSourceFileName` / line) so Session Frontend opens the `.as` fixture.

Not copying:

- `TEST_CLASS` / `TEST_METHOD` / `FFunctionRegistrar` (compile-time leaf table).
- `ASSERT_THAT` / custom Asserter types.
- `FWaitUntil` / `TestCommandBuilder` latent chains (v1 has no World).
- Replacing the existing CQTest corpus with this base class.

A dump table that says CQTest “data-driven: same as COMPLEX, customizable” is misleading. Customizing CQTest `GetTests` to scan JSON is a second COMPLEX implementation, not a CQTest feature.

## Mapping onto this change

| Dump concept | Harness |
|---|---|
| One class, N leaves | `FAngelscriptDataDrivenAutomation` : `FAutomationTestBase(Name, true)` |
| Data source | `Fixtures/**/cases.json` + C++ product generators |
| Beautified name | `Angelscript.TestModule.DataDriven.<Theme>.<CaseId>.<ProfileId>` |
| Command / Parameters | `theme/caseId@profileId` (key into catalog snapshot) |
| `RunTest` body | Construct `FAngelscriptDataDrivenLeafSession`, run observations, destroy |
| Jump-to-source | `GetTestSourceFileName` → primary `.as`; generated leaves dump numbered AS |
| Per-leaf driver params | Compact `AddInfo` `[AS-DD-DRIVER]` on every `RunTest` (pass/fail/skip). Failures repeat the card in `AddError`. Not packed into `Parameters`. See `design.md` Decision 15. |
| Precedent | `FAngelscriptScriptTestAutomation::FBridge` — copy the COMPLEX expansion only. See `research/fbridge-precedent.md`. This is a **second** bridge, not an extension of `Angelscript.ScriptTests`. Coverage `AddInfo(CaseLabel)` is the Info-card precedent. |

Two-layer rule (see `design.md` Decision 3): the registered Automation object holds only the catalog snapshot and must not store `FAngelscriptEngine*` or compiled modules. Each `RunTest` owns a short-lived session (CQTest isolation without CQTest macros).
