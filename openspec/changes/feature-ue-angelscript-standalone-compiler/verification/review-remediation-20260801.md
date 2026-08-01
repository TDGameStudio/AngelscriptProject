# Standalone review remediation — 2026-08-01

## Outcome

The post-Compat review findings are closed without introducing a public
standalone plugin option, a UBT-visible standalone macro, or a second binding
implementation. The maintained fork keeps its UE-spelled source surface. The
standalone-only compatibility and exception policy remain private to the CMake
target and the shipped V1 package remains CLI-only.

The remediation covers four correctness groups:

1. the configured memory budget is now a hard allocation limit rather than a
   post-allocation observation limit;
2. raw-object, instruction-callback, string-factory, and thread-manager
   lifetimes are balanced through normal engine teardown;
3. exported availability is enforced only for semantically used symbols and
   cannot be bypassed by `--allow-ue-required`;
4. reviewed C++ names use UE acronym conventions and package inspection uses
   an exact allowlist.

## Implementation boundary

### Maintained fork

- `as_config.h` keeps the UE/UBT default `AS_NO_EXCEPTIONS` policy and allows
  only an explicitly defined `AS_USE_EXCEPTIONS` build to activate the fork's
  existing guarded exception paths.
- `as_context.cpp` emits instruction callback `AFTER` only for an instruction
  that actually executed.
- `as_module.cpp` retains the restored UE-spelled container syntax correction.
- `as_scriptengine.cpp` unregisters raw script objects while their type data is
  still valid and supplies the maintained calling-convention API shape.

No standalone macro was added to these sources. CMake defines
`AS_USE_EXCEPTIONS=1` privately on `AngelscriptMaintainedFork`; UBT does not.

### Standalone host and Compat

- `AngelscriptStandaloneAllocator.cpp` atomically reserves before calling the
  backing allocator and records rejected allocations without crossing the
  configured limit.
- `UECompat.h` routes Compat container storage through the counted allocator,
  corrects UE-like method signatures, and keeps the compatibility headers
  build-tree private.
- `AngelscriptStandaloneEngineCompat.cpp` owns the raw-object registry only
  while registrations exist; the registry's counted allocator cannot survive
  into a later allocator cycle.
- `AngelscriptStandaloneThreadCompat.cpp` implements balanced prepare/get/
  unprepare ownership and rejects conflicting external managers.
- `AngelscriptStandaloneRunner.cpp` rejects native budgets below the 16 MiB
  bootstrap floor and maps counted allocation failure to exit code `4`.

### Maintained add-ons

- string objects, string cache/map nodes, string streams, dictionary keys, and
  dictionary map nodes use `asAllocMem` / `asFreeMem` backed allocation;
- the engine owns and cleans up the string and dictionary factories;
- `regexFind` is no longer registered because `std::regex` transitive
  allocation cannot be made part of the advertised hard counted boundary;
- allocation failure is translated through AngelScript's generic-call guard
  instead of crossing it as undefined context state.

### Offline availability and naming

- the registration runtime map indexes availability by stable ID;
- semantic observations append `editor-only` or `unavailable` capabilities
  only for resolved symbols used by the source;
- either availability class becomes deterministic `unsupported`, including
  with `--allow-ue-required`;
- reviewed names now use `UERequired`, `bAllowUERequired`, `UETypePath`,
  `UEFunctionPath`, and `UEPropertyPath`; getter names use `Get...` form;
- a source scan found no remaining `Ue*`/`b*Ue*` spelling in Standalone
  sources outside generated data.

### Packaging and documentation

- V1 installation remains an executable-and-data CLI product; it does not
  install Compat headers or libraries;
- package inspection rejects every file not present in its exact allowlist;
- the Chinese test guide and catalog now identify the current independent
  Standalone count as `18/18` and list the Compat gate. Older phase records
  retain their historical `17/17` results.

## Test-first evidence

Focused tests were added before the corresponding fixes for:

- hard-limit rejection before backing allocation;
- counted Compat and add-on storage returning to zero;
- a 20 MiB native run rejecting a large string growth with exit `4`;
- direct `Engine::Release()` raw-object teardown across allocator cycles;
- instruction callback `BEFORE` termination without a false `AFTER`;
- balanced thread-manager prepare/get/unprepare;
- used versus unused `editor-only` / `unavailable` symbols;
- fake-UObject and reviewed Compat API compile-time shape;
- exact package contents.

## Standalone verification

Commands:

```powershell
Set-Location Plugins\Angelscript\Standalone
cmake --build --preset win64-msvc-debug
ctest --preset win64-msvc-debug --output-on-failure
cmake --build --preset win64-msvc-release
ctest --preset win64-msvc-release --output-on-failure
```

Results:

- Debug: `18/18` passed, zero failures;
- Release: `18/18` passed, zero failures;
- `AngelscriptStandalone.Package` passed in both configurations, including
  exact-content inspection and installed help/version/native/default-contract
  smoke;
- runtime, add-on, Compat, UE analysis, raw teardown, memory-limit, soak, and
  architecture tests all passed.

## Unreal Engine 5.8 verification

Build command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label standalone-review-remediation -TimeoutMs 1800000 -NoXGE
```

Result: succeeded, `95/95` UBT actions, process/final exit code `0`.

Evidence:

`Saved/Build/standalone-review-remediation/20260801_112445_378_c9833160`

The build produced existing deprecation/test-helper cast warnings but no
errors. In particular, it proves the standalone-only exception opt-in does not
change the UE Runtime build policy.

Focused commands:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label standalone-review-native-core -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label standalone-review-compiler -TimeoutMs 600000
```

Results and evidence:

| Prefix | Result | Evidence directory |
| --- | ---: | --- |
| `Angelscript.TestModule.AngelScriptSDK` | `691/691`, zero failed/skipped | `Saved/Tests/standalone-review-native-core/20260801_112700_750_cbbbc18d` |
| `Angelscript.TestModule.Compiler` | `81/81`, zero failed/skipped | `Saved/Tests/standalone-review-compiler/20260801_112956_769_71a6db10` |

## Structural verification

Commands:

```powershell
openspec validate feature-ue-angelscript-standalone-compiler --strict
git diff --check
git -C Plugins/Angelscript diff --check
rg -n --glob '!out/**' --glob '!Contracts/**' --glob '!*.json' --glob '!*.jsonl' "\bUe[A-Z][A-Za-z0-9_]*|\bb[A-Z][A-Za-z0-9_]*Ue[A-Z][A-Za-z0-9_]*" Plugins/Angelscript/Standalone
```

Results:

- the OpenSpec is strictly valid;
- both diff checks exited `0`; Git printed only the repository's normal
  LF-to-CRLF working-tree notices;
- the naming scan returned no matches;
- `AS_USE_EXCEPTIONS` appears only in the standalone CMake target and the
  guarded `as_config.h` policy; it is absent from `AngelscriptRuntime.Build.cs`.

## Remaining change-level work

This closes the review-remediation subsection only. It does not claim the
entire OpenSpec is complete. The external-project Commandlet closure,
Chinese-first/English general documentation pass, historical phase-record
refresh, and final two-OpenSpec closeout remain explicitly unchecked in
`tasks.md`.
