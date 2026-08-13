## 1. Runtime tool contract and runner

- [ ] 1.1 Add `AngelscriptToolRunnerTestTypes.h` plus failing runner tests for valid ownership, no global singleton, default-key normalization, same-session reuse and runner/class/key isolation. <!-- TDD -->
- [ ] 1.2 Add failing tests for stable returned `FAngelscriptToolSessionId`, exact reset after class removal, reset-all isolation and the 256-session admission limit. <!-- TDD -->
- [ ] 1.3 Add failing tests for invalid/abstract/deprecated classes, invalid or oversized argument/response JSON, oversized messages, tool-declared failure, off-thread dispatch and same-session recursion. <!-- TDD -->
- [ ] 1.4 Implement reflected invocation/response/run-result/session/status types, abstract `UAngelscriptTool`, caller factory and transient `UAngelscriptToolRunner` storage in `AngelscriptRuntime/Tooling/AngelscriptToolRunner.*`. <!-- TDD -->
- [ ] 1.5 Add failing WorldContext tests proving explicit context reaches ambient world-sensitive bindings and `UAngelscriptTool::GetWorld`, null context does not guess Editor/PIE, context changes do not split sessions and prior scope is restored. <!-- TDD -->
- [ ] 1.6 Implement scoped `FAngelscriptEngineScope` dispatch, call-scoped tool ContextObject bridging, the narrow reflected-call exception capture, per-runner active keys and the process dispatch-depth guard used by Editor compile safety. <!-- TDD -->
- [ ] 1.7 Add inline AngelScript fixtures proving reflected override, compatible state, structured response, ContextObject consumption and script-exception reporting through C++ and AS callers. <!-- TDD -->
- [ ] 1.8 Add GC and build-policy tests proving reflected runner storage retains live sessions, release permits collection, and Test/Shipping reject execution while retaining reflected types. <!-- TDD -->

## 2. Editor compile-only and run-compiled source

- [ ] 2.1 Add failing tests for SourceId segment/total bounds, ToolClassName identifier bounds, non-empty/1 MiB source limits, bounded diagnostics and deterministic `/Angelscript/Memory/Tools/<SourceId>.as` virtual path/module mapping. <!-- TDD -->
- [ ] 2.2 Add failing compile-only tests proving valid source resolves the exact module-local class without creating a Runner/session or dispatching `Run`, while invalid/missing/abstract/deprecated classes return scoped failures. <!-- TDD -->
- [ ] 2.3 Implement reflected Editor request/result/diagnostic types and `CompileToolSource` in `AngelscriptEditor/Tooling/AngelscriptEditorToolSource.*`. <!-- TDD -->
- [ ] 2.4 Add failing `RunCompiledTool` tests proving compile once/run many, exact active-module resolution, different SessionKeys and absence of preprocessing/compilation during reruns. <!-- TDD -->
- [ ] 2.5 Implement `RunCompiledTool` and the composed `CompileAndRunSource`; failed composition must not run either the attempted source or the previous active version. <!-- TDD -->
- [ ] 2.6 Add failing last-known-good tests proving failed updates return scoped diagnostics plus the prior exact active class/revision when known, first failure returns none and explicit run-compiled can continue using the active version. <!-- TDD -->
- [ ] 2.7 Implement attempted-versus-active reporting and exact revalidation without adding a stateful Editor source manager or global same-name fallback. <!-- TDD -->
- [ ] 2.8 Add and satisfy the active-dispatch Busy regression proving compile-only and compile-and-run reject Full Reload from any tool dispatch stack, including a different runner/session. <!-- TDD -->

## 3. Hot Run and logical-session reload behavior

- [ ] 3.1 Add a body-only Hot Run fixture proving stable SourceId/module, identical physical tool UObject, preserved fields and updated function behavior. <!-- TDD -->
- [ ] 3.2 Add a compatible structural Full Reload fixture proving the physical UObject may change while the same SessionId and migrated compatible `UPROPERTY` state remain observable through the runner. <!-- TDD -->
- [ ] 3.3 Add rename/removal/incompatible fixtures proving no migration claim and exact cleanup of the old entry through its previously returned SessionId. <!-- TDD -->
- [ ] 3.4 Add failed-reload and bounded-SourceId regressions proving sessions are not reset, source/session/history deletion does not imply module unload and existing Immediate Snippet unique-module/default-discard behavior remains unchanged. <!-- TDD -->

## 4. Editor-local Tool History

- [ ] 4.1 Add failing pure Editor tests for v1 root containment, project-standard BLAKE3 SourceId storage keys, schema/identity validation, UTF-8 JSON limits and same-directory atomic publication order. <!-- TDD -->
- [ ] 4.2 Implement `AngelscriptEditorToolHistoryTypes.h`, Editor-per-project-user `UAngelscriptEditorToolSettings` and focused internal `AngelscriptEditorToolHistoryStore.*` primitives. <!-- TDD -->
- [ ] 4.3 Add failing tests for compile/compile-and-run default `SourceAndDiagnostics`, run-compiled default `None`, explicit request `None`, settings-disabled status and proof that Snippet/disk/runtime/global compilation events do not write Tool History. <!-- TDD -->
- [ ] 4.4 Implement policy routing in Editor Tool Source operations without adding history writes to Runtime or global compilation listeners. <!-- TDD -->
- [ ] 4.5 Add failing revision/attempt tests proving pre-compile source journaling after validation, content-addressed source deduplication, a distinct compile attempt per compile, scoped diagnostics, pre-validation failure omission and last-known-good manifest updates only after success. <!-- TDD -->
- [ ] 4.6 Implement immutable revision, compile-attempt, manifest and root-index publication with independent `FAngelscriptToolHistoryResult` reporting. <!-- TDD -->
- [ ] 4.7 Add failing run-summary tests proving only the explicit summary policy records runs and persisted JSON excludes ContextObject, ArgumentsJson, PayloadJson and tool UObject fields. <!-- TDD -->
- [ ] 4.8 Implement optional bounded run summaries in Editor `RunCompiledTool`/`CompileAndRunSource`; Runtime `RunTool` remains persistence-free. <!-- TDD -->
- [ ] 4.9 Add failing deterministic-retention tests for 100 SourceIds, 50 revisions, 100 attempts, 100 runs, 256 MiB, protected newest/last-known-good records and independent capacity failure. <!-- TDD -->
- [ ] 4.10 Implement configurable finite retention and stale-temp maintenance without allowing history failure to override compile/run truth. <!-- TDD -->
- [ ] 4.11 Add failing corruption/recovery tests for missing/malformed/oversized/identity-mismatched records, inert unsupported schema and explicit bounded index rebuild from valid manifests. <!-- TDD -->
- [ ] 4.12 Implement validated recent-source/revision list, exact revision load, last-known-good load and explicit rebuild APIs; every load remains data-only. <!-- TDD -->
- [ ] 4.13 Add failing exact-forget tests proving same-parent tombstone publication removes one SourceId subtree/index entry, interrupted tombstones remain inert, active modules and runner sessions remain untouched, and no reflected clear-all API exists. <!-- TDD -->
- [ ] 4.14 Implement `ForgetToolHistory(SourceId)` with exact containment and deterministic not-found/delete-failure results. <!-- TDD -->

## 5. Compatibility and documentation

- [ ] 5.1 Update `Documents/Knowledges/ZH/Guide_EditorExtension.md` first with runner-scoped-not-singleton semantics, compile-only/run-many examples, logical-versus-physical reload behavior, WorldContext, Last Known Good, history recovery and trusted-code/reset boundaries. <!-- Non-TDD -->
- [ ] 5.2 Update `Plugins/Angelscript/README.md` with the corresponding concise English capability, Saved path, data-minimization, build-availability and non-feature summary. <!-- Non-TDD -->
- [ ] 5.3 Confirm no product `.as` tool, project tool directory, Editor UI/menu/console command, registry, global runner, transport, cross-restart UObject state, Runtime history write or new Runtime dependency was added. <!-- Non-TDD -->

## 6. Verification

- [ ] 6.1 Build through `Tools\RunBuild.ps1 -Label as-tool-execution -TimeoutMs 1800000 -NoXGE`. <!-- Non-TDD -->
- [ ] 6.2 Run `Angelscript.TestModule.Tooling.StatefulToolRunner`, `Angelscript.Editor.ToolExecution`, `Angelscript.Editor.ToolHistory` and `Angelscript.TestModule.Core.SnippetExecution` through separate `Tools\RunTests.ps1` invocations. <!-- Non-TDD -->
- [ ] 6.3 Run the named Smoke suite through `Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix as-tool-smoke -TimeoutMs 600000`. <!-- Non-TDD -->
- [ ] 6.4 Package Development and Shipping through `Tools\RunPackage.ps1` and confirm Runtime reflected types compile, restricted execution fails closed and Editor-only history code is absent. <!-- Non-TDD -->
- [ ] 6.5 Re-run `openspec validate feature-as-stateful-tool-execution --type change --strict --no-interactive` and record final verification evidence outside `tasks.md`. <!-- Non-TDD -->
