# Runner integration audit

## Scope and conclusion

This was a read-only audit of the present PowerShell runner stack. No tests were
run. The current implementation is entirely UE-Automation-prefix based; adding
`Standalone` as an ordinary `Prefix` entry would send CTest text to
`RunTests.ps1 -TestPrefix` and is therefore unsafe. The smallest safe direction
is an explicit, shared entry kind with a CMake/CTest dispatcher and a
per-invocation report layout, while leaving the `All` list and all its derived
coarse/monolithic plans unchanged.

## 1. Existing data model

`Tools/Shared/TestSuiteDefinitions.ps1` owns an `[ordered]` hashtable named
`$script:AngelscriptTestSuiteDefinitions`. Its keys are suite names (`Smoke`,
`NativeCore`, ..., `All`); each value is an array of untyped hashtables. Every
current entry has exactly the de-facto fields:

| Field | Current meaning |
|---|---|
| `Prefix` | UE Automation name prefix passed to `RunTests.ps1 -TestPrefix`. |
| `Label` | Human/output-label suffix. |
| `Tier` | `Heavy` or `Light` scheduler classification. |
| `PreferredSlot` | Not authored in definitions; added by the dynamic shard planner to a copied entry. |

`Resolve-AngelscriptTestSuiteEntryTier` defaults a missing `Tier` to `Light`.
`Get-AngelscriptTestSuiteEntries` returns the raw hashtables unchanged.
Consequently there is no `Kind`, command, working directory, CMake preset,
CTest selector, or report schema in the suite-entry contract today.

At run time the sequential runner derives `RunLabel`; the parallel runner
projects entries into a `PSCustomObject` with `Index`, `Label`, `Prefix`,
`Tier`, `RunLabel`, and `ExecutionSlot`. UE worker metadata (`RunTests.ps1`) is
also prefix-shaped: `Target`, Automation log/report paths, `TimeoutMs`, process
and final exit codes, and then a `Summary.json` parsed from UE's exported
Automation report. The parallel aggregate serializes those per-shard values in
`ParallelSuiteSummary.json`.

## 2. Places that presently assume an Unreal Automation prefix

The following are the relevant assumptions, grouped by effect rather than just
by the name `Prefix`.

1. **Primary sequential dispatch.** `Tools/RunTestSuite.ps1:81-131` unconditionally constructs `RunTests.ps1 -TestPrefix $entry.Prefix`, prints it as a prefix, and records failed runs as `Prefix`. This is the direct blocker for a CTest entry.
2. **Definition helpers/catalog.** `Tools/Shared/TestSuiteDefinitions.ps1:95-99` identifies TestModule entries with `Prefix -like 'Angelscript.TestModule*'`; `:116-121` prints all entries as a tier plus prefix. All declared entries at `:8-73` use the prefix-only shape.
3. **UE-only worker.** `Tools/RunTests.ps1:1-142` requires `-TestPrefix` or UE Automation `-Group`, converts prefixes to `^...` Automation filters, and rejects broad filters that include crash-only Automation tests. `:172-201` launches `UnrealEditor-Cmd.exe` with `Automation RunTests` and `-ReportExportPath`; its output and summary handling at `:230-372` are UE-report-specific. A Standalone entry must never enter this script.
4. **Parallel runner.** `Tools/RunTestSuiteParallel.ps1:107-128` chooses prefix-only coarse/dynamic/monolithic/Fine entries. `:192-216` stores `Prefix` and unconditionally starts `RunTests.ps1 -TestPrefix`; `:258-285` finds UE worker metadata under `Saved/Tests/<RunLabel>` and expects its `Summary.json`; `:301`, `:428`, and `:561` use the same prefix identity in diagnostics. Its result and aggregate model have no entry kind or generic report path.
5. **Coarse/monolithic profiles.** `Tools/Shared/TestLaunchProfile.ps1:20-47` synthesizes Automation-prefix shard entries and a `+`-joined Automation target. These profiles are necessarily UE-only and must not include Standalone.
6. **Dynamic shard planning.** `Tools/Shared/TestShardPlanner.ps1:6-161` uses prefix-keyed default/observed timing and UE `RunMetadata.json`/`Summary.json`. `:255-286` partitions `All` by `Angelscript.TestModule*` versus top-level Automation prefixes, and `:361-367` emits prefix-shaped worker-plan JSON. It must filter/route by `Kind`, not infer kind from a prefix, before it can safely see mixed entries.
7. **Parallel self-test fixture.** `Tools/Diagnostics/tests/RunTestSuiteParallelSelfTests.ps1:164-212` installs only a fake `RunTests.ps1` with mandatory `TestPrefix` and UE-style `Summary.json`/`RunMetadata.json`; its only assertion (`:221-258`) proves an Automation-style parallel aggregate. It cannot exercise CMake/CTest dispatch today.
8. **Automation-entry-point validator and its fixture.** `Tools/Diagnostics/powershell/Test-AutomationEntryPoints.ps1:103-177` calls every parsed suite entry a prefix and requires it to match a compiled `Angelscript.*` Automation test. The parser is already stale relative to the shared definition file (it scans `RunTestSuite.ps1` for inline definitions), but any corrected version must explicitly select `Kind = 'UnrealAutomation'`; it must skip Standalone rather than report it as an unmapped Automation prefix. `Tools/Diagnostics/tests/TestAutomationEntryPointsSelfTests.ps1:126-167` builds the same prefix-only fixture.
9. **Ancillary prefix consumers.** `Tools/Diagnostics/powershell/AnalyzeTestRunTiming.ps1:12-65` treats metadata `Target` as an Automation prefix and aggregates known prefix families. `Tools/Diagnostics/powershell/RunRemainingAllSuite.ps1:10-65` has its own hard-coded Automation-prefix version of `All`. Neither should be made the Standalone dispatcher; both need either explicit UE-only scope/documentation or kind-aware filtering if they remain supported tooling.
10. **Documentation.** `Documents/Guides/Test.md:5-12`, `:193-205`, `:285-332`, and `:657-693` describe the standard runner exclusively as UE Automation and prescribe UE `Automation.log`/`Report/` products. This documentation must be extended once the command exists, without describing CTest results as UE Automation reports.

## 3. Minimum safe change

### Typed entry contract

Make `Kind` mandatory for every definition rather than relying on a default.
Use two values only in the initial change:

```powershell
@{ Kind = 'UnrealAutomation'; Prefix = 'Angelscript.TestModule.AngelScriptSDK'; Label = 'AngelScriptSDK'; Tier = 'Heavy' }
@{ Kind = 'CMakeCTest'; Label = 'Standalone'; Tier = 'Heavy'; CMakePreset = 'win64-msvc'; CTestPreset = 'win64-msvc' }
```

The exact preset names should be constants owned by the Standalone CMake
definition rather than guessed in the runner. `CMakePreset`/`CTestPreset` may
instead be one deliberately named `StandalonePreset` field if CMake's final
presets use the same name. Do not overload `Prefix` for a command or CTest
regular expression.

Add the second entry only to a new `Standalone` suite. **Do not add it to
`All`**, `Get-AngelscriptTestCoarseShards`,
`Get-AngelscriptTestMonolithicPrefix`, or dynamic `All` planning. This keeps
the present All suite, Fast runner, Coarse runner, and Monolithic runner
unchanged until the release-soak gate.

### Dispatch and isolation

Extract a small common operation from both suite runners conceptually named
`Invoke-AngelscriptSuiteEntry` (the concrete helper file/name is an
implementation decision). It should switch on `Kind` before it constructs any
child arguments:

- `UnrealAutomation`: preserve the existing `RunTests.ps1 -TestPrefix` path.
- `CMakeCTest`: use `cmake --preset <preset>`, `cmake --build --preset
  <preset>`, then `ctest --preset <preset> --output-on-failure` (or the final
  documented equivalent), executing each process with the entry timeout.

The CTest branch should call `New-CommandOutputLayout` from
`Tools/Shared/UnrealCommandUtils.ps1`, using the supplied `OutputRoot` and its
unique run ID. It should emit its own `Standalone.log`, command transcripts
(configure/build/ctest), and `RunMetadata.json`/`Summary.json` into that run
root; no UE `ReportExportPath`, `Automation.log`, or shared CMake build/report
directory is acceptable. The generic metadata needs at least `Kind`, `Label`,
`RunLabel`, `TimeoutMs`, `OutputRoot`, command report paths, timed-out phase,
raw child process exit code(s), and final suite-entry exit code. The generic
summary should identify CTest result counts when available, otherwise preserve
the raw nonzero result instead of inventing Automation counts.

Preserve existing suite failure semantics: a failed child causes the suite
process to return nonzero (currently normalized to `1`), while the report
keeps each raw CMake/CTest exit code. If the team instead requires the exact
child exit code as the suite's exit code, declare that as a deliberate
cross-runner contract and update the existing UE tests too; it is not current
behavior.

For the task-0.8 proof, make the parallel runner and shard planner consume the
same typed contract rather than merely adding the primary path. Fine mode can
dispatch the CTest entry through the same helper. Coarse/Dynamic/Monolithic
must stay explicitly UE-only until `Standalone` is intentionally admitted to
`All`; a kind-aware filter/assertion should make a future accidental admission
fail loudly rather than turn CTest into `-TestPrefix` text.

## 4. Test-first location and exact red tests

Add a new primary-runner fixture test at
`Tools/Diagnostics/tests/RunTestSuiteSelfTests.ps1`, following the temporary
fixture, captured-process, and cleanup conventions already present in
`RunTestSuiteParallelSelfTests.ps1`. Extend that sibling parallel self-test for
parallel/planner behavior. The primary test needs a fake `cmake`/`ctest`
command shim recorded in the fixture `PATH` (or an explicitly injected tool
path); never depend on a developer's real CMake installation.

Write the following tests first; they should fail on today's code for the
specific reason stated.

| Test name | Red assertion / required final behavior |
|---|---|
| `StandaloneDefinitionIsTypedAndExcludedFromAll` | `Get-AngelscriptTestSuiteEntries Standalone` returns exactly one `Kind='CMakeCTest'` entry with no `Prefix`; all legacy entries declare `Kind='UnrealAutomation'`; `All` contains no `CMakeCTest` entry and no label `Standalone`. Today `Standalone` is unknown and entries are untyped. |
| `SequentialStandaloneDispatchesConfigureBuildAndCTest` | Fixture shims record ordered configure, build, and CTest invocations. `RunTestSuite.ps1 -Suite Standalone` succeeds and no recorded command contains `RunTests.ps1`, `-TestPrefix`, `UnrealEditor-Cmd`, or `-ReportExportPath`. Today it always invokes `RunTests.ps1 -TestPrefix`. |
| `SequentialStandaloneTimesOutAndStopsLaterPhases` | A configure/build/CTest shim that exceeds the supplied small test timeout produces nonzero exit, `TimedOut=true`, the correct `TimedOutPhase`, and does not launch a later phase. The report preserves the phase-specific timeout. Today no CTest path or timeout boundary exists. |
| `SequentialStandalonePropagatesCTestFailure` | The CTest shim exits a distinctive nonzero value (for example `17`). The suite exits nonzero (under current normalized suite semantics, `1`), the entry metadata records `ProcessExitCode=17`/phase `CTest`, and `ContinueOnFail` still runs later entries only when requested. Today no CTest child can be recorded. |
| `SequentialStandaloneWritesPrivateReportsPerInvocation` | Two invocations with the same label and optional custom `OutputRoot` produce different run roots; each contains CTest transcript(s), `RunMetadata.json`, and `Summary.json`; neither contains nor shares UE `Report/` data. Today there is no Standalone report layout. |
| `ParallelFineDispatchesMixedKindsWithoutPrefixCoercion` | A fixture `Fine` suite containing one Automation and one CTest entry runs both through their correct shims and serializes each shard's `Kind`, raw exit code, and report path. Today parallel unconditionally adds `-TestPrefix`. |
| `PlannerAndAllRemainStandaloneFree` | Dynamic and coarse plans derived from `All` contain only `Kind='UnrealAutomation'`; a CMake entry passed accidentally to an Automation-only plan is rejected with a clear kind message. Today the planner uses prefix heuristics and has no kind check. |
| `AutomationEntryPointValidationSkipsCMakeCTestEntries` | The validator accepts a typed standalone suite entry without looking for an `Angelscript.*` compiled test, while still rejecting an unknown `UnrealAutomation` prefix. Today its suite parser/validator is prefix-only. |

The last three are required to satisfy task 0.8's explicit parallel, shard
planner, and self-test coverage; the first five are the focused task-1.2
primary-runner slice.

## 5. Allowed standard verification commands

Use the repository PowerShell entry points and explicit timeouts. After the
new self-tests exist, the short runner checks are:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\tests\RunTestSuiteSelfTests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\tests\RunTestSuiteParallelSelfTests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\tests\TestAutomationEntryPointsSelfTests.ps1
```

The contract's required real integration command is the OpenSpec task-1.2
command (once the CMake preset/targets exist):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix standalone-runner -TimeoutMs 600000
```

For existing UE regression coverage, repository guidance permits the standard
wrapper rather than a hand-written `UnrealEditor-Cmd` command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix native-core-runner-regression -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -TimeoutMs 1800000 -NoXGE
```

Do not use `Tools/RunTests.ps1` for Standalone: that script is intentionally a
UE Automation runner. Do not run `All` for this phase; Standalone must remain
outside it. The current `Documents/Guides/Test.md` says normal test commands
must have explicit timeouts and use per-run private directories; the new CTest
branch should retain those guarantees.

## 6. OpenSpec task compatibility

- **0.8:** There is no design conflict, but a primary-only change is
  insufficient to claim this task. Task 0.8 explicitly requires mixed dispatch
  across definitions, primary *and parallel* runners, shard planner, isolated
  reports, labels, timeouts, and failure propagation. Implement the shared
  kind contract and all red cases above before marking 0.8 complete.
- **1.2:** The proposed new `Standalone` suite plus sequential CMake
  configure/build/CTest dispatcher, failure propagation, and isolated reports
  directly implements this task. It depends on task 1.1 supplying actual
  presets/targets. The existing `RunTestSuite.ps1` has no report abstraction of
  its own, so the CTest report layout must be added rather than reusing the UE
  `RunTests.ps1` format by implication.
- **6.16:** No conflict. It expressly defers adding Standalone to `All` until
  the standalone soak passes. Keeping `Standalone` separate now, and retaining
  kind checks in all All-derived profiles, is the safest way to make that
  future addition an intentional reviewed change rather than an accidental
  `-TestPrefix` coercion.

## Audit concerns

1. `Test-AutomationEntryPoints.ps1` currently parses obsolete inline suite
definitions from `RunTestSuite.ps1`, whereas the real definitions live in
`Tools/Shared/TestSuiteDefinitions.ps1`. Generalizing the entry model without
repairing this validator would create a false sense of coverage.
2. The current parallel result lookup uses a broad recursive label match
(`RunTestSuiteParallel.ps1:258-262`). The CTest branch should return its exact
new metadata path to the parent, or its report discovery must be narrowed to
the generated run ID, to avoid colliding with similarly named concurrent runs.
3. The exact CMake/CTest preset names and desired suite-level exit-code policy
are not yet frozen. These are small contract decisions that must be specified
in the runner self-test fixture before implementation, not silently inferred
from a machine CMake installation.
