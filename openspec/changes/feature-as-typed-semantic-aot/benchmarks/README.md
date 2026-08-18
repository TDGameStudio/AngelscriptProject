# First-version TypedASTJIT measurements

Task 8.1. These numbers do **not** change the default backend.

## What is measured here

| File | Source | Date |
| --- | --- | --- |
| `first-version-isolated.csv` | Official `Angelscript.TestModule.StaticJIT.AOT.Benchmarks` | 2026-08-18 |
| `generated-artifact-sizes.csv` | TestJIT `Generated/EditorDevelopment` file lengths | 2026-08-18 |
| `official-run-wallclock.csv` | Official runner metadata | 2026-08-17/18 |

`first-version-isolated.csv` is the 8.1 source of truth:

- HIR capture: 2835.414 ms; working-set delta 239964160 bytes
- Isolated BytecodeJIT generate: 3117.025 ms / 5829 bytes
- Isolated TypedASTJIT generate: 3165.067 ms / 6122 bytes
- Scalar Raw: 20.312 ns/call (result 6)
- Direct capability Raw (header-inline body): 20.703 ns/call
- Bridged `InvokeBoundViaVM`: 162.500 ns/call (result 42)

Official report:
`Saved/Tests/semantic-aot-81-bench/20260818_095928_629_67a04473` (1/1 PASS).

Whole-target compile time from official `semantic-aot-final` is **1623 ms**
(`Saved/Build/semantic-aot-final/20260818_100730_924_48bb60a9`, target
up-to-date). That is the 8.3 command wall-clock, not a clean rebuild.

8.3 official counts (fail=0 skip=0 timeout=false):

- Build `semantic-aot-final`: exit 0, 1623 ms
- Compiler: **188/188** (`semantic-aot-compiler-final/20260818_100123_085_bca3853f`)
- StaticJIT: **408/408** (`semantic-aot-staticjit-final/20260818_100752_147_6fc0cb22`)

8.4 official counts (fail=0 skip=0 timeout=false; do **not** copy 2396/2396):

- Suite Standalone `semantic-aot-standalone-final`: **20/20**
- Suite All `semantic-aot-all-final`: **3558/3558** (37 prefixes, suite exit 0, 5068.34 s)
- Unreal prefixes 01–36 only: **3538/3538**
- All StaticJIT prefix: **408/408** (`semantic-aot-all-final_33_StaticJIT/20260818_125621_901_3e2f84c3`)

Isolated generation times include a fresh generation Engine (Bind replay
plus one-function emit). They are not hot-path microseconds.
