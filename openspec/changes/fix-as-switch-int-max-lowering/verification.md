# Verification

## Retained evidence

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Tests/as-native-sdk-controlflow-repair5-rerun/20260724_132425_735_9aed04c4/Report/index.json` | Matching `2147483643` selected default before repair. | Historical red root-cause evidence. |
| `Saved/Build/as-native-sdk-switch-boundary-overflow-fix/20260724_140619_158_70e5e3ab/UBT.log` | Runtime/Test build passed after P066-P069. | Historical build evidence. |
| `Saved/Tests/as-native-sdk-controlflow-boundary-overflow-fix/20260724_140643_788_7d78de49/Report/index.json` | ControlFlow 4/4; all high-end controls executed. | Historical green support, not fresh final evidence. |
| `Saved/Tests/as-native-sdk-full-after-switch-overflow-fix/20260724_140754_067_f7bb8f41/Report/index.json` | Full SDK improved by the exact ControlFlow owner and shut down normally. | Historical aggregate support. |

## Required fresh gates

1. Build:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Target AngelscriptProjectEditor -Label fix-as-switch-int-max-lowering -TimeoutMs 1800000 -NoXGE`

2. Exact regression owner:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language.ControlFlow.Switch" -Label fix-as-switch-int-max-lowering-focused -TimeoutMs 600000`

3. ControlFlow parent:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language.ControlFlow" -Label fix-as-switch-int-max-lowering-controlflow -TimeoutMs 1800000`

4. Complete SDK:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label fix-as-switch-int-max-lowering-sdk -TimeoutMs 3600000`

Every run must report terminal totals, exit/process exit 0, no timeout/crash,
normal shutdown, and printed high-end source IDs. Then run
`openspec validate fix-as-switch-int-max-lowering --strict` and scoped
whitespace checks.

No fresh build or automation was run while creating this record.
## Final verification — 2026-07-28

| Gate | Evidence | Result |
| --- | --- | --- |
| Coherent build | `Saved/Build/as-native-sdk-unit-tests-restored-final/20260728_000229_699_38a673dd` | **PASS**, process/final exit 0/0; no new error. |
| Exact high-end switch controls | `Saved/Tests/fix-as-switch-int-max-lowering-focused-final/20260727_233338_382_afd747a7` | **2/2 PASS**. Printed sources contain the `INT_MAX - 5`, `INT_MAX - 4`, and dense `INT_MAX - 2` through `INT_MAX` cases. |
| ControlFlow parent | `Saved/Tests/fix-as-switch-int-max-lowering-controlflow-final/20260727_233419_394_85b3d04b` | **12/12 PASS**, normal shutdown and no crash. |
| Complete SDK | `Saved/Tests/as-native-sdk-comprehensive-restored-final/20260728_000418_207_c7795abc` | **683/683 PASS**, zero failed/skipped, no timeout or crash. |
| Final project suite | Final restored All suite | **35/35 prefixes and 2,396/2,396 tests PASS**. |
| Record/whitespace gates | Strict OpenSpec; parent/plugin `git diff --check` | **PASS**, zero errors. |

Tasks 3.1–3.5 are complete with fresh execution at the final source state.
