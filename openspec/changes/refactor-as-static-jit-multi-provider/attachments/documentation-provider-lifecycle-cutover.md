# Provider lifecycle documentation cutover

Date: 2026-08-13
Task: 11.5

## Problem found

The primary Chinese StaticJIT article and several adjacent guides still
described the deleted compatibility architecture as current behavior:

- generated `.jit.hpp` plus a local/whole-cache `.Cache`;
- process-global `FJITDatabase` registration by numeric FunctionId;
- one `FStaticJITCompiledInfo::ActiveInfo` and `DataGuid` whole-cache pairing;
- Editor/PIE always disabling StaticJIT;
- HotReload never interacting with StaticJIT;
- `bStaticJITTranspiledCodeLoaded` as the process truth source;
- state dump output named `JITDatabase.csv`.

Those claims conflict with the implemented ABI Revision 2 multi-provider
Registry, Engine-local routes, Cache V2, EditorDevelopment Provider, strict
per-AS-module generation, Live Coding refresh service, and current dump tables.
The engine class still declared/defined `bStaticJITTranspiledCodeLoaded`, but a
whole-repository source scan found no reader or writer beyond its zero
initialization.

## Documentation result

`Documents/Knowledges/ZH/RT_StaticJIT.md` was rewritten as the current primary
Chinese guide. It now explains:

- exact one-AS-module/one-`<StableModuleKey>.<Profile>.jit.cpp` ownership;
- global functions and class methods sharing their owning AS-module file;
- Provider Modular Feature registration and copied immutable Registry catalogs;
- source/Cache V2 authority followed by Engine-local route refresh;
- stable references, VM/Raw/Parms binding publication, typed VM fallback, and
  multi-Provider ambiguity behavior;
- normal save versus explicit Generate/Refresh and Live Coding source-set gates;
- UE-owned DLL load/unload plus Provider code-image leases;
- project generation, Verify, build and package commands;
- schema-v2 diagnostics and Python inspector;
- generated-file/rebuild/reference-resolution benchmark results;
- the explicit fact that production content-specific direct script-call
  emission remains disabled.

Adjacent Chinese guidance was updated in `RT_HotReload.md`, `RT_CodeCoverage.md`,
`RT_ThirdPartyKernel.md`, `RT_GlobalState.md`, `RT_HashMetadata.md`,
`Arch_EditorTestDumpCollaboration.md`, `Build.md`, `Test.md`,
`AngelscriptForkStrategy.md`, and `GlobalStateContainmentMatrix.md`. The
Angelsea comparison is explicitly marked as a research-time snapshot where it
predates the completed provider cutover.

Consumer/maintainer facts were synchronized in root `README.md`, `AGENTS_ZH.md`,
`AGENTS.md`, and `Plugins/Angelscript/README.md`. They distinguish the four
plugin modules (including Editor-only `AngelscriptTestJIT`) from the optional
host `AngelscriptJIT` Runtime/PreDefault carrier.

## Source cleanup

The unused `FAngelscriptEngine::bStaticJITTranspiledCodeLoaded` declaration and
definition were removed. Current process scope is represented by immutable
Provider Registry snapshots; function routes, transient FunctionIds, and
resolved references remain Engine-local.

## Verification

- targeted parent/plugin `git diff --check`: clean;
- source scan: no live `bStaticJITTranspiledCodeLoaded` symbol remains;
- full affected Editor rebuild completed 135/135 actions and reported
  `Result: Succeeded`, UBT 163.53 seconds:
  `Saved/Build/static-jit-doc-lifecycle-cleanup/20260813_123416_916_747bd084`;
- standard runner warm confirmation reported target up to date, exit 0:
  `Saved/Build/static-jit-doc-lifecycle-cleanup-r2/20260813_123754_491_69bd05b1`.

The first run was launched with an overly short outer tool wait, so the parent
runner exited before writing its summary even though the orphaned UBT process
completed successfully and the complete Build/UBT logs record the 135/135
success. The second standard runner invocation supplies complete metadata and
exit evidence.
