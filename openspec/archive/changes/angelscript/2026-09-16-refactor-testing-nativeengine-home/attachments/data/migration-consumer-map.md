# Migration consumer map

Current `NewVersion/` selectors after tenant relocation. Historical archives and this Change's own planning snapshots stay immutable.

## Repaired current owners

| Owner | Old selector | Replacement | Disposition |
|---|---|---|---|
| `AGENTS.md` reconstruction baseline | `AngelscriptTest/NewVersion/` and flat `Angelscript.UnitTest.<Area>.<Scenario>` | Four module-root homes; NativeEngine `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>` | Updated in 2.5 |
| `.agents/skills/angelscript-test/SKILL.md` | `NewVersion/` homes and flat NativeEngine TestDir | Durable homes and nested TestDir | Updated in 2.5 |
| `.agents/skills/angelscript-test/cqtest.md` | Flat `Angelscript.UnitTest.NativeEngine` sample | `Angelscript.UnitTest.NativeEngine.Basic` + `NativeEngine/NativeEngineTestSupport.h` | Updated in 2.5 |
| `.agents/skills/angelscript-test/references/test-code-database.md` | `NewVersion/Framework/...` includes | `Framework/...` | Updated in 2.5 |
| `.agents/skills/angelscript-test/references/legacy-source-isolation.md` | Active `NewVersion/` tree and live quarantine script path | Four tenant homes; archived quarantine helper is historical | Updated in 2.5 |
| `AngelscriptTestModule.cpp`, `Core/AngelscriptTestModule.h` | `NewVersion/Framework/...` | `Framework/...` | Rewritten during relocation |
| `TestCode/Generated/**` | `NewVersion/Framework/...` | `Framework/...` | Rewritten during relocation |
| `AngelscriptTestJIT/NewVersion/TestCodeProviderRegistration.cpp` | `NewVersion/Framework/...` | `Framework/...` | Rewritten during relocation; JIT execution not expanded |
| `AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/cpp_renderer.py` | emitted `NewVersion/Framework/...` | emitted `Framework/...` | Current generator path; corpus `.as` text unchanged |
| Framework and FrameworkTests translation units | `#include "NewVersion/Framework/..."` | `#include "Framework/..."` | Rewritten during relocation |
| FrameworkTests gold path | `.../NewVersion/FrameworkTests/Gold/...` | `.../FrameworkTests/Gold/...` | Rewritten during relocation |

## Active sibling Changes (not implemented here)

| Owner | Old selector | Disposition |
|---|---|---|
| `angelscript/refactor-testing-unified-framework` | Tasks, design, and class-contracts still cite `NewVersion/Framework/**` | Recorded only. This Change does not implement that plan or rewrite its Files trees. |

## Historical / immutable

| Owner | Disposition |
|---|---|
| This Change's proposal, design, talks, reviews, and task Files diffs | Keep `NewVersion/` as the pre-move source of truth |
| `openspec/archive/**` including `Test-LegacyTestQuarantine.ps1` | Immutable. The archived helper still requires `AngelscriptTest/NewVersion/` and is not a current selector |
| Current `openspec/specs/angelscript/testing/baseline/spec.md` | Durable delta already lives on this Change; synchronize at closure, not during apply |

## Remaining current `NewVersion/` code includes

Plugin and `AngelscriptTestCode` C++/Python generators have zero remaining `NewVersion/` include or gold-path consumers after relocation.
