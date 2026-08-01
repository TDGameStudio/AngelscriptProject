# Compat-first fork minimization verification — 2026-08-01

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


Status: implemented and freshly verified. This record covers the
Compat-first correction only. It does not close the remaining external-project
Commandlet, documentation, or revised final-release tasks in `tasks.md`.

## Outcome

The maintained AngelScript fork keeps its existing Unreal-facing spellings and
build assumptions. CMake supplies the bounded subset through
`Standalone/Compat`, selected first only for `AngelscriptMaintainedFork`.
UBT continues to compile the same fork against real Unreal headers and
implementations.

The correction removes the earlier fork-wide portability mechanism:

- no `as_portable_containers.h`;
- no `as_memoryarena.h`;
- no `as_host_services.cpp/.h`;
- no UE Runtime `AngelscriptSDKHostServices.*`;
- no Runtime startup/shutdown host-service install/reset;
- no public UBT standalone switch;
- no standalone conditional in the maintained fork;
- no Compat dependency from LanguageCore, binds, ClassGenerator, or ordinary
  standalone host code.

Standalone-owned behavior is now confined to:

- `Standalone/Compat/UECompat.h` and include-compatible entry headers;
- `AngelscriptStandaloneMemoryCompat.cpp`;
- `AngelscriptStandaloneThreadCompat.cpp`;
- `AngelscriptStandaloneEngineCompat.cpp`.

The engine compat translation unit deliberately combines policy, string scan,
raw-script-object registry, and `asIScriptObject::GetObjectType()` definitions.
There is no separate ScriptObject compat translation unit.

## Test-first architecture sequence

The architecture test was changed before the compatibility implementation.
Its RED result identified the missing Compat include tree/CMake selection, the
fork-owned portable containers and arena, the host-service files, and the UE
Runtime host-service install. After the Compat implementation and restoration,
the same test passed and now scans both source boundaries and the generated
Visual Studio project.

The architecture policy allows `TArray`, `TMap`, `FMemory`, `FMath`,
`FAngelscriptEngine`, and `UASClass` spellings in the maintained fork. It
rejects replacement-container names, direct standard-container rewrites,
standalone fork macros, real UE include/library paths in the generated CMake
target, and Compat leakage into UBT-owned code.

## Maintained-fork reconciliation

Twenty-two portability-only files that had content edits were restored
byte-for-byte to the plugin submodule `HEAD`. Together with the removed
standalone-only portability headers/sources, this eliminates the mechanical
STL/host-service rewrite from the fork.

The remaining maintained-fork diff is restricted to nine files:

| File | Retained reason |
| --- | --- |
| `Core/angelscript.h` | Host-neutral semantic observation POD/API, typed user data, and public primitive aliases required by maintained add-ons. |
| `as_compiler.cpp/.h` | Read-only semantic observer callbacks plus removal of allocator-owned function-static `asCString` values. |
| `as_context.cpp` | Stop immediately when an instruction callback changes the execution status. |
| `as_parser.cpp` | Accept unnamed parameters in application registration declarations. |
| `as_restore.cpp` | Keep script-struct constructor bytecode write/read symmetric; value types have no factory record. |
| `as_scriptengine.cpp` | Template factory/generic parameter-stack correctness and deterministic engine/module/type teardown. |
| `as_scriptobject.cpp` | Remove unusable maximum-portability wrappers and provide the fork's explicit generic caller metadata. |
| `as_typeinfo.h` | Match the typed public user-data API. |

The two function-static compiler strings allocated 15 and 34 bytes under the
first per-run allocator and lived until process exit. Comparing directly
against string literals preserves behavior while allowing per-engine tracked
allocation count to return to zero. This is retained as a lifecycle correctness
fix, not as a portability abstraction.

Unrelated manual-binding, binding-origin, UHT, exporter, test-coverage, and
LanguageCore work already present in the dirty submodule was not reverted or
reclassified as part of this correction.

## Standalone verification

Fresh Debug build/test directory:

`Plugins/Angelscript/Standalone/out/build/win64-msvc`

Post-reconciliation commands:

```powershell
cmake --build Plugins/Angelscript/Standalone/out/build/win64-msvc --config Debug --target AngelscriptStandaloneArchitectureTests AngelscriptStandaloneCompatTests
ctest --test-dir Plugins/Angelscript/Standalone/out/build/win64-msvc -C Debug -R "AngelscriptStandalone\.(Architecture|Compat)" --output-on-failure
ctest --test-dir Plugins/Angelscript/Standalone/out/build/win64-msvc -C Debug --output-on-failure
```

Results:

- focused architecture/Compat: 2/2 passed;
- complete Debug CTest inventory: 18/18 passed;
- package inspection: passed;
- semantic observer, LanguageCore, add-ons, CLI/native/UE E2E, runtime,
  OfflineContract, UE analysis, adapters, resources, corpus, soak, and
  benchmark tests: passed;
- tracked allocation lifecycle/soak: passed.

Fresh independent Release directory:

`Plugins/Angelscript/Standalone/out/build/compat-first-release`

The clean Release configure/build and complete CTest run passed 18/18 before
the final UE verification. The restored portability-only source hashes are
identical to the sources used for that run.

## Unreal Engine 5.8 build

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label standalone-compat-first-rerun -TimeoutMs 1800000 -NoXGE
```

Result: succeeded, 91/91 UBT actions, process/final exit code 0.

Evidence:

`Saved/Build/standalone-compat-first-rerun/20260801_004611_916_39e099be`

The first build attempt exposed two stale tests from the removed portability
rewrite: one used `.size()` on the restored UE `TArray`, and one included
the removed `as_memoryarena.h`. They were restored to `TArray::Num()` and
`FMemStackBase` respectively. The successful rerun also confirmed the
`WITH_AS_DEBUGSERVER` and `AS_REFERENCE_DEBUGGING` Build.cs definitions no
longer produce duplicate macro definitions because the header fallbacks are
guarded.

## Focused Unreal automation

All runs used `Tools/RunTests.ps1` with `-TimeoutMs 600000`.

| Prefix / label | Result | Evidence directory |
| --- | ---: | --- |
| `Angelscript.TestModule.AngelScriptSDK` | 691/691 | `Saved/Tests/standalone-compat-first-native-core/20260801_004936_683_19f24de2` |
| `Angelscript.TestModule.Compiler` | 81/81 | `Saved/Tests/standalone-compat-first-compiler/20260801_005318_178_eb08ef02` |
| `Angelscript.TestModule.Preprocessor` | 60/60 | `Saved/Tests/standalone-compat-first-preprocessor/20260801_005402_032_245c109c` |
| `Angelscript.TestModule.Bindings.` | 244/244 | `Saved/Tests/standalone-compat-first-bindings/20260801_005516_894_8ec6755b` |
| `Angelscript.TestModule.CppTests.OfflineContract` | 12/12 | `Saved/Tests/standalone-compat-first-offline-runtime/20260801_005647_583_ec055f20` |
| `Angelscript.Editor.OfflineContract` | 9/9 | `Saved/Tests/standalone-compat-first-offline-editor/20260801_005746_765_82219956` |

Every report has zero failed and zero not-run tests. The report schema records
one Compiler, five Preprocessor, eleven Bindings, and two runtime
OfflineContract results as succeeded-with-warnings; they remain passing test
results and do not hide failures.

## Structural validation

```powershell
openspec validate feature-ue-angelscript-standalone-compiler --strict
openspec validate refactor-as-language-core-ue-facade-parity --strict
git -C Plugins/Angelscript diff --check
git diff --check
```

Results:

- both OpenSpecs are strictly valid;
- both diff checks exited 0 with no whitespace errors;
- explicit fork contamination search returned no
  `as_portable_containers.h`, `as_memoryarena.h`,
  `as_host_services.h`, replacement container/arena names, or direct
  `std::vector` / `std::atomic_ref` / `std::shared_mutex` rewrite;
- explicit UBT-owned source search returned no Compat path, standalone fork
  macro, or `AngelscriptSDKHostServices` reference;
- the obsolete portability/host-service files are absent.

Git emitted the repository's normal LF-to-CRLF working-tree notices during
the diff checks; those are warnings from `core.autocrlf`, not whitespace
errors, and both commands exited 0.

## Review boundaries

The Compat-first correction intentionally does not claim completion for:

- making the external-project export Commandlet fully host-independent;
- the reopened Chinese-first/English documentation pass;
- revised final package/default-bundle evidence across all historical phase
  records;
- the separate `refactor-as-language-core-ue-facade-parity` change.

Those items remain unchecked in `tasks.md`.
