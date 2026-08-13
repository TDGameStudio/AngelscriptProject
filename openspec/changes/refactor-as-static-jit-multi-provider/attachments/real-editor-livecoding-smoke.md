# Real Editor Live Coding Smoke

## Purpose

This attachment records the real-process acceptance method and progressive
evidence for task 9.4. It deliberately separates four independent claims:

1. a normally built `EditorDevelopment` Provider initially routes the target
   function Native;
2. changing the authoritative `.as` source invalidates only the old entry and
   routes the changed function through VM before a patch;
3. explicit StaticJIT refresh regenerates the existing per-AS-module
   `.jit.cpp` source set and a real UE Live Coding compile succeeds;
4. the running Provider exposes the exact new generation and the Router
   publishes Native again without closing the Editor.

A successful C++ compile alone does not prove item 4. The before/after
diagnostic JSON is the acceptance oracle.

## Fixed Probe Identity

The current probe uses a body-only edit, so it does not change the AS module,
function declaration, class layout, or generated `.jit.cpp` source set:

- source: `Script/Examples/Core/Example_Math.as`;
- AS module: `Examples.Core.Example_Math`;
- function: `void ExecuteExampleMath()`;
- stable module key:
  `7fca37092c5c2190e0f260bc2042b7bf9b5624688450cfef86d9ebac2c0eb40e`;
- stable function key:
  `283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112`;
- generated source:
  `Source/AngelscriptJIT/Private/Generated/Profiles/EditorDevelopment/Modules/7fca37092c5c2190e0f260bc2042b7bf9b5624688450cfef86d9ebac2c0eb40e.EditorDevelopment.jit.cpp`.

The committed/normal baseline expression is:

```angelscript
float WaveValue = Math::Sin(1.0f * 2.0);
```

The temporary smoke edit changes only `2.0` to `3.0`. The source is restored
immediately after the Editor process exits. Generated artifacts are restored
with a final baseline `Generate` plus build/verify; restoring the `.as` file
alone is not enough because the refresh deliberately changed owned generated
files on disk.

## Repeatable Procedure

### 1. Establish a matching Native baseline

Generate the profile, perform a normal Editor build, and verify before opening
the smoke Editor:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile EditorDevelopment
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label static-jit-livecoding-baseline -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Verify -Profile EditorDevelopment
```

Record the baseline ProviderGeneration. The 2026-08-13 baseline generation was
`cd4129dd6623c91cea89b675a09289289e80edb43228123fa9b6456dcd0671d5`;
the generation is content-derived and will legitimately differ after later
source changes.

### 2. Apply one controlled body-only source edit

Use a narrowly scoped patch and verify that the stable module/function identity
does not change. Do not add or remove an AS module in this test: a changed
`.jit.cpp` source set intentionally requires a normal full build and is a
different acceptance scenario.

### 3. Launch the full Editor and wait for the real GUI process

The tested command line is equivalent to:

```powershell
$editor = 'C:\Program Files\Epic Games\UE_5.8\Engine\Binaries\Win64\UnrealEditor.exe'
$project = 'D:\Workspace\AngelscriptProject\AngelscriptProject.uproject'
$functionKey = '283edffc1d10fd79397f21a0539a2a1412991441ce7568df98fb21efeab04112'
$outputRoot = 'D:\Workspace\AngelscriptProject\Saved\Tests\static-jit-real-livecoding-smoke'
$exec = "as.StaticJIT.DumpDiagnostics -Function=$functionKey -Output=$outputRoot/before.json,as.StaticJIT.EditorRefresh,as.StaticJIT.DumpDiagnostics -Function=$functionKey -Output=$outputRoot/after.json,QUIT_EDITOR"
$arguments = @(
    $project,
    '-LiveCoding',
    '-Unattended',
    '-NoPause',
    '-NoSplash',
    '-stdout',
    '-FullStdOutLogOutput',
    '-UTF8Output',
    "-ABSLOG=$outputRoot/Editor.log",
    '-NOSOUND',
    '-NullRHI',
    "-ExecCmds=$exec"
)
$startInfo = [System.Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $editor
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
foreach ($argument in $arguments) {
    [void]$startInfo.ArgumentList.Add($argument)
}
$process = [System.Diagnostics.Process]::Start($startInfo)
$process.WaitForExit()
if ($process.ExitCode -ne 0) { throw "Editor smoke failed: $($process.ExitCode)" }
```

Important orchestration details:

- use `UnrealEditor.exe`, not `UnrealEditor-Cmd.exe`, because this is a real
  Editor Live Coding test;
- `-Unattended -NullRHI` hides the normal Editor UI and GPU rendering, but the
  Live Coding console can still appear;
- use `ProcessStartInfo.ArgumentList`, rather than relying on
  `Start-Process -ArgumentList` to rejoin a string array. `-ExecCmds` contains
  spaces and must remain one argument; losing that boundary makes UE execute
  only the first parameterless command;
- `WaitForExit()` is required on Windows. A direct PowerShell invocation of a
  GUI executable may return while the Editor is still starting, which can
  cause the source to be restored too early;
- UE separates `-ExecCmds` commands with commas. A semicolon remains part of a
  console command and does not sequence these operations;
- a full Editor exits through `QUIT_EDITOR`; plain `Quit` is not the reliable
  command for this path;
- `Quick restart disabled when re-instancing is enabled.` is a Live Coding UI
  capability notice. It does not by itself mean that compilation failed.

### 4. Inspect the machine-readable verdict

```powershell
python Tools\Diagnostics\InspectStaticJITDump.py "$outputRoot\before.json"
python Tools\Diagnostics\InspectStaticJITDump.py "$outputRoot\after.json" --fail-on-mismatch
```

The intended state transition is:

| Checkpoint | Current AS content | Provider content | Expected route |
|---|---|---|---|
| normal baseline | baseline | baseline | Native / Exact |
| `before.json` | edited | old baseline | VM / content mismatch candidate |
| `after.json` | edited | new exact generation | Native / Exact |

`before.json` is expected to contain a mismatch and should not be passed to
`--fail-on-mismatch`. `after.json` must pass it. Also compare
`providers[0].providerGeneration`: it must be different from the old baseline
and equal the generation written by the refresh.

### 5. Restore both source and generated baseline

In a `finally`-style cleanup, restore the `.as` source even if the Editor
fails. Then regenerate `EditorDevelopment`, build, and verify again so source,
generated C++, DLL, and Provider manifest all describe the same baseline.

## Progressive Evidence — 2026-08-13

### Cache/current-registry prerequisite: GREEN

The first real refresh reached reference discovery but crashed while the cache
environment resolver formatted a retained historical system function from
`asCScriptEngine::scriptFunctions`. That table is a FunctionId/history table,
not the authoritative current registration surface.

`FAngelscriptCacheEnvironmentIdentity::CollectCurrentRegisteredFunctions`
now collects only current globals, current registered-type methods/factories/
behaviours, and the engine-owned `$obj`/`$func` pseudo-type behaviours. It
filters by engine/system-function ownership, deduplicates, and sorts by current
function ID. Cache resolution and StaticJIT reference discovery share this
collector.

Evidence:

- RED compile proving the missing collector:
  `Saved/Build/static-jit-current-function-registry-red/20260813_131529_435_410abbad`;
- final build:
  `Saved/Build/static-jit-current-function-registry-green-r4/20260813_133145_712_e426cb14`;
- focused retained-history, built-in-behaviour, and PIE Native tests, 3/3:
  `Saved/Tests/static-jit-current-function-registry-green-r4/20260813_133208_146_e75a405f`;
- full Cache Environment plus EditorRouting regression, 15/15:
  `Saved/Tests/static-jit-current-function-registry-full-green/20260813_133354_318_9a41c17d`.

The subsequent real Editor run exited with code 0 and did not reproduce the
cache crash.

### Invalid orchestration run `r3`: not acceptance evidence

`Saved/Tests/static-jit-real-livecoding-smoke-r3` used a direct PowerShell GUI
launch. PowerShell returned before the detached Editor finished loading, so the
temporary source was restored before AS compilation. Both diagnostic samples
therefore described the same baseline and the refresh correctly reported
already-current. This run is retained only as evidence for the explicit
process/wait rule.

### Valid orchestration run `r4`: Native-to-VM proven, VM-to-Native still RED

Evidence root:
`Saved/Tests/static-jit-real-livecoding-smoke-r4`.

The process ran for approximately 104 seconds, exited with code 0, and the
source was then restored to `* 2.0`. `before.json` proves the edited source was
actually authoritative:

- current execution hash:
  `dbdcba697063c537a5ece2f9f9c5741328f987593c3e15fc80608dc6d6092afc`;
- old ProviderGeneration:
  `cd4129dd6623c91cea89b675a09289289e80edb43228123fa9b6456dcd0671d5`;
- old candidate execution hash:
  `94a2e4d4f07ce258cc97431d4df646f00c4e4f0bdb1e6c6c93086e4098bcceff`;
- route: `Vm`;
- candidate result: `ContentMismatch`.

The UE Live Coding build itself succeeded. The UBT log records exactly two C++
compile actions—the changed module `.jit.cpp` and `Provider.generated.cpp`—and
the Editor log records `Live coding succeeded`. The generated provider on disk
contains the new generation
`e3113fde3f01e70e559b6994c18fb8589f9357aa05a21929586123680b3484b8`.

However, `after.json` still reports the old generation `cd412...`, the same VM
route, and the same content-mismatch candidate. The refresh correctly fails
closed with:

```text
Live Coding completed, but the Provider still exposes the previous generation.
```

This isolated the first Live Coding storage problem: an already-initialized
function-local `static const FAngelscriptJITProviderView` survived the patch.

### Valid runs `r5` and `r6`: progressively refreshed view and metadata

The provider accessor now returns a view by value and the generated selector
copies it into thread-local call storage. TDD evidence is the 5/6 RED run at
`Saved/Tests/static-jit-livecoding-view-red` and the final GeneratedOutput 6/6
plus ProjectScaffold 6/6 runs at
`Saved/Tests/static-jit-livecoding-view-green-generated` and
`Saved/Tests/static-jit-livecoding-view-green-scaffold`.

Run `r5` then exposed the next retained local-static layer: the scalar view was
new, but the old global entry/reference arrays failed manifest validation.
Generation now emits thread-local entry/reference arrays and overwrites every
slot on each accessor call. The 5/6 RED and 6/6 GREEN evidence is under
`Saved/Tests/static-jit-livecoding-metadata-red` and
`Saved/Tests/static-jit-livecoding-metadata-green`.

Run `r6` passed manifest validation and reached Registry publication, isolating
the code-image lifetime lease. Windows lifetime acquisition now uses the loader
as the authoritative address-to-PE-image source and owns one reference per
unique non-executable image. This includes Live++ `.patch_N.exe` images even
when `FPlatformStackWalk` does not list them. Refresh diagnostics also name the
registration code instead of returning an opaque incompatibility message.

TDD/build evidence:

- diagnostic RED, 4/5:
  `Saved/Tests/static-jit-livecoding-lifetime-diagnostic-red/20260813_141427_738_4aa10469`;
- address-pin build:
  `Saved/Build/static-jit-livecoding-lifetime-address-pin-green-build/20260813_141622_231_8c20c3c3`;
- RefreshService plus ProviderRegistry GREEN, 12/12:
  `Saved/Tests/static-jit-livecoding-lifetime-address-pin-green/20260813_141644_856_68130e7f`.

### Invalid orchestration run `r7`: `-ExecCmds` argument boundary lost

`Start-Process -ArgumentList` rejoined the argument array without retaining the
required whole-argument quoting around `-ExecCmds`. UE logged only
`Cmd: as.StaticJIT.DumpDiagnostics`, wrote neither JSON file, never requested a
patch, and therefore never reached `QUIT_EDITOR`. The exact smoke Editor PID
was verified before termination and the AS source was immediately restored.
This run is retained to justify the `ProcessStartInfo.ArgumentList` procedure.

### Valid run `r8`: image retained, stable identity owner still conflicted

With exact argument boundaries and address-based image retention, Live Coding
succeeded and registration returned the new explicit diagnostic:

```text
ProviderIdConflict (validation=0)
```

Live Coding can replace the generated C++ provider object, so its process
address is not a stable owner identity. Registry now permits an owner handoff
only when ProviderId, ProviderName, and OwnerModuleName all agree. A different
provider claiming the same ProviderId remains rejected. The owner-transfer RED
was 7/8 at
`Saved/Tests/static-jit-livecoding-owner-handoff-red/20260813_142739_199_49012203`;
ProviderRegistry + MultiProvider + RefreshService are GREEN 19/19 at
`Saved/Tests/static-jit-livecoding-owner-handoff-green/20260813_142945_509_a24aa8c1`.

### Valid run `r9`: complete Native-to-VM-to-Native acceptance GREEN

Evidence root:
`Saved/Tests/static-jit-real-livecoding-smoke-r9`.

The real `UnrealEditor.exe` process exited 0 after about 101.6 seconds.
`before.json` records:

- publication `2`, route generation `2`;
- current execution hash `dbdcba6970...`;
- old generation `cd4129dd66...` candidate with `ContentMismatch`;
- target route `Vm`.

UE then logged `Live coding succeeded` and:

```text
Live Coding published Provider generation e3113fde3f01e70e559b6994c18fb8589f9357aa05a21929586123680b3484b8; Native=19 VM=0.
```

`after.json` records:

- publication `3`, route generation `5`;
- exact new generation `e3113fde3f01e70e559b6994c18fb8589f9357aa05a21929586123680b3484b8`;
- target entry index `16`, references `7/7`;
- target route `Native`, result `Exact`;
- `InspectStaticJITDump.py --fail-on-mismatch` exit `0`.

The source was immediately restored to `* 2.0`. The generated C++, DLL, and
manifest baseline were then restored and independently verified:

- Generate:
  `Saved/AngelscriptJITRuns/static-jit-livecoding-r9-restore-generate/20260813_143312_610_b237fa9b`;
- Build:
  `Saved/Build/static-jit-livecoding-r9-restore-build/20260813_143419_339_2001351b`;
- Verify:
  `Saved/AngelscriptJITRuns/static-jit-livecoding-r9-restore-verify/20260813_143436_405_cbdd2676`.

Task 9.4's real-process acceptance criteria are satisfied.

## Completion Criteria

Task 9.4 closed after `r9` showed all of the following in one controlled run:

- pre-patch edited function is VM and the old Provider candidate is a typed
  content mismatch;
- Live Coding compiles the expected existing module `.jit.cpp` and Provider
  selector source without changing the source set;
- observed ProviderGeneration equals the newly generated expected generation;
- Registry publication advances and the target route becomes Native/Exact;
- `after.json --fail-on-mismatch` exits 0;
- the Editor exits cleanly and the baseline source/generated artifacts are
  restored and verified afterwards.
