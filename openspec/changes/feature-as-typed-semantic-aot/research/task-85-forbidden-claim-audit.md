# Task 8.5 forbidden-claim audit

Date: 2026-08-18. Worktree `V:\` (`D:\Workspace\AngelscriptProject\.worktree\feature-as-typed-semantic-aot`).

Re-run after official Suite All `semantic-aot-all-final` exited 0
(**3558/0/0**, timeout false) and after the Cache provenance remap plus
Compiler.Events fixture fix. Probes were executed again from `V:\`.

## Probe / validator / OpenSpec / whitespace

| Check | Result | Notes |
| --- | --- | --- |
| `research/probes/Test-SemanticExecutionSourceEvidence.ps1` | PASS 28 assertions | Retargeted to `StaticJIT/BytecodeJIT/AngelscriptBytecodeJIT.cpp` and `AngelscriptBytecodes.cpp`. Debug metadata is now `SCRIPT_DEBUG_CALLSTACK_FRAME` + `SCRIPT_DEBUG_CALLSTACK_POSITION`. |
| `research/probes/Test-SemanticExceptionCleanupSourceEvidence.ps1` | PASS 24 assertions | Same path retarget. Cleanup emit is reverse declaration order. Script destructors use `AngelscriptDestroyScriptObjectIsolated`. Throw goes through `SetExternalException`. VM maps JIT failure via `PublishException`. |
| `research/probes/Test-SemanticExceptionCleanupContract.ps1` | PASS 20 assertions | Unchanged. |
| `research/fixtures/semantic-aot-v1/Test-ValidateFixtures.ps1` | PASS 21 assertions | Schema-v3 validator tests. |
| `research/fixtures/semantic-aot-v1/Validate-Fixtures.ps1` | PASS 10/10 | Schema-v3 corpus. |
| `openspec validate feature-as-typed-semantic-aot --strict` | valid | Exit 0. |
| `git -C V:\ diff --check` | exit 0 | CRLF warnings only. |
| `git -C V:\Plugins\Angelscript diff --check` | exit 0 | CRLF warnings only. |

## Forbidden claims

| Claim | Status | Evidence |
| --- | --- | --- |
| BytecodeJIT deleted | **Not deleted.** | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/BytecodeJIT/AngelscriptBytecodeJIT.h` still defines `FAngelscriptBytecodeJIT`. Official StaticJIT prefix **408/408** includes BytecodeJIT cases. |
| Production `dual` backend | **Not introduced.** | Generation BackendId must be `bytecode` or `typed-ast` (`AngelscriptStaticJITGenerationProfile.h`). `TEXT("dual")` appears only in `AngelscriptStaticJITBackendTests.cpp` as a rejected parse. Docs state there is no production `dual` backend. |
| Position-only frames equated with debugger/coverage/timeout | **Not advertised.** | ZH `RT_StaticJIT.md` / EN README: debug-frame position is not debugger/coverage/loop-timeout parity. |
| `bExceptionThrown` equated with a complete public exception payload | **Not advertised.** | Same docs: `bExceptionThrown` is not a complete public exception payload. |
| C++ lexical scope as unverified AngelScript cleanup | **Not advertised.** | Docs: cleanup plans are explicit, reverse, live-only; C++ lexical scope is not an AngelScript cleanup plan. BytecodeJIT emit uses reverse `Cleanup.Positions`. |
| Current source-level try/catch supported | **Not advertised.** | Docs: current source-level `try`/`catch` remains rejected. Probe asserts compiler does not produce `.TryBlock(` and language tests reject the syntax. |
| Default backend changed from 8.1 numbers | **Not changed.** | `FAngelscriptStaticJITGenerationProfile` still defaults to `FAngelscriptStaticJITBackendId::Bytecode()` (`TEXT("bytecode")`). `TryParse` accepts only `bytecode` and `typed-ast`. 8.1 CSV is a record only. |

## Implementation identity (no commit this turn)

User did not request a commit. Working trees are dirty from the whole change.

| Repo | HEAD | Working tree |
| --- | --- | --- |
| Parent | `6ded86387f54339b3bef28d2fc7f49abf80b6191` | Dirty. OpenSpec, docs, generated AngelscriptJIT files, staged + unstaged. |
| `Plugins/Angelscript` submodule | `5a1d0e68f54fb31850d8fcebac0231ae39f31c04` | Dirty. Runtime/Test/TestJIT TypedASTJIT work plus group-8 probe/doc/bench files. |
| Parent gitlink | `5a1d0e68f54fb31850d8fcebac0231ae39f31c04` (`git submodule status`) | Gitlink SHA matches submodule HEAD; dirty work is not in that SHA. |

This turn's group-8 record edits: `benchmarks/`, `tasks.md` 8.1–8.3/8.5 marks, this audit, and research probe path/assertion retargets. No production backend default change.

## 8.3 counts used by this audit

- Build `semantic-aot-final`: exit 0, 1623 ms, `Saved/Build/semantic-aot-final/20260818_100730_924_48bb60a9`
- Compiler: 188 passed / 0 failed / 0 skipped / timeout false, `Saved/Tests/semantic-aot-compiler-final/20260818_100123_085_bca3853f`
- StaticJIT: 408 passed / 0 failed / 0 skipped / timeout false, `Saved/Tests/semantic-aot-staticjit-final/20260818_100752_147_6fc0cb22` (prefix timeout 1200000 ms)

## 8.4 counts recorded after this audit's second probe pass

- Suite Standalone `semantic-aot-standalone-final`: 20/20, fail=0, skip=0, timeout=false
- Suite All `semantic-aot-all-final`: **3558** passed / **0** failed / **0** skipped / timeout=false, suite exit 0, 5068.34 s, 37/37 prefixes
- All Unreal prefixes 01–36: **3538/3538**
- All StaticJIT prefix: **408/408** (`20260818_125621_901_3e2f84c3`)
- All Cache prefix: **549/549**; All Compiler prefix: **81/81**
