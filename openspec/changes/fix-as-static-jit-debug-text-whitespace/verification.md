# Verification

## Retained evidence

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Tests/as-native-sdk-staticjit-aot-generated-format-repair_04_tests/20260724_093303_090_6f70a1ae/Report/index.json` | AOT automation 10/10 and zero failed/skipped. | Historical support from `JIT-004`; not fresh final evidence for this linked change. |
| Literal scan of `ASStaticJITAotFixture.as.jit.hpp` recorded with `JIT-004` | Zero trailing-whitespace lines. | Historical support; regenerate before final closure. |
| Current plugin diff | P019 adds only the terminal trim in `GetInstrDebugString()`. | Source-present evidence, not build/runtime evidence. |

## Required fresh gates

1. Build:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Target AngelscriptProjectEditor -Label fix-as-static-jit-debug-text-whitespace -TimeoutMs 1800000 -NoXGE`

   Required result: process/final exit 0 and no new compile/link errors.

2. Documented StaticJIT AOT workflow:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -AotOnly -LabelPrefix fix-as-static-jit-debug-text-whitespace -BuildTimeoutMs 1800000 -CommandletTimeoutMs 600000 -TestTimeoutMs 600000`

   Required result: generation exit 0, generated-code build exit 0, AOT
   automation terminal pass, and no crash/timeout.

3. Literal generated-output scan:

   `rg -n "[ \t]+$" Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/ASStaticJITAotFixture.as.jit.hpp`

   Required result: exit 1 with no matching lines.

4. Record validation:

   `openspec validate fix-as-static-jit-debug-text-whitespace --strict`

   Required result: the change is valid.

No fresh build, generation, or automation was run while creating this record.
## Final verification — 2026-07-28

| Gate | Evidence | Result |
| --- | --- | --- |
| Coherent build | `Saved/Build/as-native-sdk-unit-tests-restored-final/20260728_000229_699_38a673dd` | **PASS**, process/final exit 0/0; no new error. |
| Canonical AOT generation/build/execution | `Saved/Tests/as-native-sdk-comprehensive-current-final-green1_04_tests/20260727_222852_888_6d5de814` | **12/12 PASS** after baseline build, four paired artifacts, generated-source build, and generated execution. |
| Complete StaticJIT parent | `Saved/Tests/as-native-sdk-comprehensive-current-staticjit-full/20260727_222954_004_8d8fb9d3` | **30/30 PASS**, normal shutdown and no crash. |
| Literal generated fixture scan | `rg -n '[ \t]+$' Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/ASStaticJITAotFixture.as.jit.hpp` | **PASS**: zero matches. |
| Final aggregate | Restored final SDK and All suite | SDK **683/683** and All **2,396/2,396 PASS**. |
| Record/whitespace gates | Strict OpenSpec; parent/plugin `git diff --check` | **PASS**, zero errors. |

Tasks 3.1–3.4 are complete. The earlier canonical AOT crash remains retained as
the red half of the diagnostics-fixture repair.
