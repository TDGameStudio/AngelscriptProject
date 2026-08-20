# GitHub prior art: data-driven test plugins

Survey (2026-08-19). Question: is there an existing plugin we can adopt for fixture + `cases.json` + named engine profiles on UE Automation?

**Short answer:** no drop-in. Closest UE pieces are COMPLEX `GetTests`, Hazelight `ComplexIntegrationTest_*_GetTests`, OpenUnrealUtilities parameter parser, and Epic PythonAutomationTest file scan. Closest *shape* outside UE is LLVM lit + JSONC case kits (`itestkit`, conformance `cases.json`). Do not vendor any of these into AngelscriptTest.

## Closest to our harness (steal ideas, not code)

| Repo / product | What it is | Steal | Do not steal |
|---|---|---|---|
| Epic COMPLEX `GetTests` / `PythonAutomationTest` | Engine: one class → N leaves; Python plugin scans `test_*.py` | Command is a lookup key; scan files at enumerate; per-leaf `RunTest` | Fat CSV/JSON packed into `Parameters`; `IMPLEMENT_COMPLEX_AUTOMATION_TEST` if we need `GetTestSourceFileName` |
| Hazelight AngelScript [script tests](https://angelscript.hazelight.se/scripting/script-tests/) | `ComplexIntegrationTest_*_GetTests` expands World stories from a registry | Same COMPLEX expansion we already copy from `FBridge` | Potion-registry / map-latent gameplay driver; prefix `Angelscript.IntegrationTests` |
| [JonasReich/OpenUnrealUtilities](https://github.com/JonasReich/OpenUnrealUtilities) | `OUUTestUtilities`: `FAutomationTestWorld`, **`AutomationTestParameterParser`** for COMPLEX `FString` params | World helper analog (`FAngelscriptTestWorld` already exists); parser is the *wrong* payload style | Comma-packed `Parameters`; OUU macros replacing CQTest |
| [n-r-w/itestkit](https://github.com/n-r-w/itestkit) | Go: JSONC cases + registered handlers (setup/action/verify) | Fixture vs handler split; suite lifecycle vs per-case harness | Go runner; HTTP/gRPC domain |
| [metaobjectsdev/metaobjects](https://github.com/metaobjectsdev/metaobjects) `fixtures/validation-conformance` | `cases.json` boolean corpus, many language ports, one verdict | Authored corpus + generated products; no cartesian in the JSON | Multi-language ports |
| LLVM [lit](https://github.com/llvm/llvm-project/tree/main/llvm/utils/lit) + FileCheck | Source file *is* the test; `RUN:` + `CHECK:` | One `.as` as the program; observations beside or in catalog | Python lit as UE Session Frontend driver |

## UE test plugins (wrong job for Lane B)

These are real plugins; they solve **gameplay / UI / Gauntlet**, not “same AS on VM/Cache/JIT”.

| Repo | Job | Why not Lane B |
|---|---|---|
| [splash-damage/automatron](https://github.com/splash-damage/automatron) | UE4 simpler Automation wrappers | Incubator DX, not catalog expansion |
| [janousch/Unreal-Engine-Test-Forge](https://github.com/janousch/Unreal-Engine-Test-Forge) | Blueprint Gauntlet suites + parameterized BP tests + parameter-provider actors | Level/Gauntlet; BP parameters ≠ engine profiles |
| [DaedalicEntertainment/ue4-test-automation](https://github.com/DaedalicEntertainment/ue4-test-automation) | Gauntlet integration-test maps | Packaged client/server, not `FAngelscriptEngine` |
| [calionestevar/NexusQA](https://github.com/calionestevar/NexusQA) | Alternative UE5 runner (assert API, reports, chaos) | Replaces Automation; we stay on Session Frontend |
| [Mithril0rd/uespec-public](https://github.com/Mithril0rd/uespec-public) | JSON UISpec → UMG widgets + JSON test specs + JUnit | UI compile/test commandlets; AngelScript ViewModel bind is incidental |
| Gearbox **Polaris** (Unreal Fest 2023, not open source) | Codeless in-game agent tests | Gameplay QA, not compiler corpus |
| [Wellwick/UnrealDataTableValidation](https://github.com/Wellwick/UnrealDataTableValidation) | DataTable `IsDataValid` | Content validation, not test expansion |

## Language / API data-driven (not UE plugins)

| Piece | Pattern |
|---|---|
| [catchorg/Catch2](https://github.com/catchorg/Catch2) `GENERATE` | In-process generators; Native SDK already has its layer |
| Python `ddt` / pytest parametrize | External JSON payloads; same idea as catalog, wrong host |
| [afsarali273/TestFlowPro](https://github.com/afsarali273/TestFlowPro) | Keyword JSON for REST/UI — too much DSL |
| test262 / compiler golden folders | Directory of programs + expected outcomes — our `Fixtures/` + observations |

## Implication for this change

Keep the already-locked design: handwritten COMPLEX `FAutomationTestBase`, catalog snapshot, `Parameters` = `theme/caseId@profileId`, Shared corpus lookup. Do not adopt Automatron/NexusQA/UESpec as the engine-profile driver. Optional later: OUU-style parameter parser only if we ever need debug dumps of keys (not as the catalog). Hazelight Complex Integration Tests remain a sibling pattern for `world-story`, not Lane B.
