## 1. Baseline, fixtures, and file boundaries

- [ ] 1.1 Add a reviewed cross-host fixture catalog under `Plugins/Angelscript/Standalone/Tests/Fixtures/LanguageService/` covering all eight initial `ASLINT` rules, positive/negative/suppressed cases, compiler cascades, CRLF, BMP/non-BMP Unicode, and partial unknown facts; record complete expected diagnostic tuples and source/profile identities. <!-- TDD -->
- [ ] 1.2 Add Native fixture readers and failing golden tests in `Plugins/Angelscript/Standalone/Tests/AngelscriptCrossHostDiagnosticsTests.cpp`; register the test in `Plugins/Angelscript/Standalone/CMakeLists.txt` before implementing the shared evaluator. <!-- TDD -->
- [ ] 1.3 Add UE Automation parity fixtures under `Plugins/Angelscript/Source/AngelscriptTest/Diagnostics/` using filenames prefixed `Angelscript`; prove the current UE adapter cannot yet produce the normalized fixture tuples. <!-- TDD -->
- [ ] 1.4 Add protocol fixture tests under `Extensions/AngelscriptVSCode/language-server/tests/` for legacy diagnostics, proposed rich diagnostics, stale document versions, Unicode ranges, and duplicate `ASLINT` emission; add deterministic Node test scripts to the extension root package. <!-- TDD -->
- [ ] 1.5 Add Wiki contract/Playwright fixtures under `Wiki/wiki/tiddlers/tests/playwright/` and `Wiki/tests/playwright/product/code/` for an interactive generated-class example, two-widget lifecycle, failure fallback, narrow layout, and ordinary-page non-loading; initially require the absent widget/plugin behavior to fail. <!-- TDD -->
- [ ] 1.6 Record pre-change Native engine initialization/update metrics in `Plugins/Angelscript/Standalone/Tests/Benchmarks/`, current `Wiki/dist/index.html` bytes, and a fixed 500-LOC browser fixture environment under `openspec/changes/feature-as-cross-host-language-service/benchmarks/`. <!-- Non-TDD -->
- [ ] 1.7 Add architecture scans to `AngelscriptStandaloneArchitectureTests.cpp` and Wiki source-boundary tests that reserve `Core/Diagnostics`, `Standalone/Source/LanguageService`, `Standalone/Source/Web`, and `Wiki/src/angelscript-workbench`, forbid UE headers from the host-neutral core, and keep the retired BTC CodeMirror plugin absent. <!-- TDD -->

## 2. Shared diagnostics core and UE integration

- [ ] 2.1 Define standard-C++ normalized fact/result types, four-level severity, tags, related locations, explicit `nonFatal`, completeness, zero-based UTF-16 ranges, profile identity, and canonical serialization under `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Diagnostics/`; compile those sources explicitly in Standalone CMake. <!-- TDD -->
- [ ] 2.2 Implement a deterministic rule registry in `Core/Diagnostics` with canonical ordering, `ruleSetVersion`, and `ruleSetHash`; make tests prove identity changes for normative catalog changes and remains stable for host-adapter refactors. <!-- TDD -->
- [ ] 2.3 Implement `ASLINT1001` and `ASLINT1002` from normalized declaration/reference/import facts, including the Unnecessary tag and partial-knowledge behavior. <!-- TDD -->
- [ ] 2.4 Implement `ASLINT1003` and `ASLINT1004` from proven inheritance/override/metadata/Super-call facts, including parent/override `NoSuperCall` suppression. <!-- TDD -->
- [ ] 2.5 Implement `ASLINT1005` from resolved bind-target/signature facts, return related target information, and preserve Error presentation with non-fatal semantics. <!-- TDD -->
- [ ] 2.6 Implement `ASLINT1101`–`ASLINT1103` using one Unreal naming policy and suggested-name data rather than host-specific messages. <!-- TDD -->
- [ ] 2.7 Implement one tested UTF-8/compiler-row-column to zero-based UTF-16 mapping utility in `Core/Diagnostics`, covering CRLF and surrogate pairs, and route all public diagnostic/completion/outline ranges through it. <!-- TDD -->
- [ ] 2.8 Implement deterministic cascade suppression and client rule-group masks without allowing clients to change rule definitions or default severities. <!-- TDD -->
- [ ] 2.9 Add the UE fact provider beside the core under `Core/Diagnostics`, sourcing authoritative compiler, ModuleDesc, UClass/UFunction metadata, import, override, Super-call, delegate, and naming facts without storing reflection pointers in normalized results. <!-- TDD -->
- [ ] 2.10 Integrate shared evaluation into the UE compile lifecycle after sufficient semantic facts exist, publish a separate static-diagnostic snapshot, and prove non-fatal Error results do not set module failure, reject eligible hot reload, or alter packaging success. <!-- TDD -->
- [ ] 2.11 Add UE result/reset/lifecycle coverage under `AngelscriptTest/Diagnostics` for initial compile, hot reload, cleared diagnostics, partial facts, multiple engines, and engine shutdown; use `Angelscript.TestModule.Diagnostics.Shared.*`. <!-- TDD -->

## 3. Semantic observation and offline facts

- [ ] 3.1 Extend `AngelscriptSemanticObserverTests.cpp` with failing tests for declaration/reference use, override resolution, exact Super calls, and delegate bind observations while proving compilation without an observer is unchanged. <!-- TDD -->
- [ ] 3.2 Extend `Core/angelscript.h` and maintained-fork `ThirdParty/angelscript/source/as_compiler.*` with the minimum pointer-free observations required by the normalized fact provider; keep the observer optional and read-only. <!-- TDD -->
- [ ] 3.3 Adapt `Standalone/Source/Compiler/AngelscriptStandaloneSemanticObserver.*` to normalize new observations and stable type/symbol identities without exposing compiler pointers beyond the observation callback. <!-- TDD -->
- [ ] 3.4 Add versioned explicit semantic fields to `Dump/AngelscriptOfflineContractTypes.*`, JSON/serializer code, symbol metadata/exporters, and deterministic bundle identity; include BlueprintEvent, `RequireSuperCall`, `NoSuperCall`, signature identity, inheritance, and override availability only. <!-- TDD -->
- [ ] 3.5 Extend Runtime/Editor offline-export Automation tests and `Standalone/Tests/AngelscriptOfflineContractTests.cpp` with producer/consumer fixtures for the new schema, deterministic hashes, old-version rejection/compatibility policy, and absence of arbitrary metadata/code/addresses/private paths. <!-- TDD -->
- [ ] 3.6 Extend `Standalone/Source/Contract/AngelscriptOfflineRecords.*`, manifest/loader/indices/type oracle, and the Standalone fact provider to validate and consume the new semantic fields before compilation. <!-- TDD -->
- [ ] 3.7 Re-export the checked-in complete default bundle only through `Tools/RunCommandlet.ps1`, update its recorded hashes/provenance, and verify two exports are byte-identical before accepting the schema increment. <!-- Non-TDD -->

## 4. Compact language-service profile

- [ ] 4.1 Add malformed, incomplete, incompatible, dangling-dependency, forbidden-content, and deterministic profile fixtures under `Standalone/Tests/Fixtures/LanguageService/Profile/`; add `AngelscriptLanguageServiceProfileTests.cpp` before implementing the packer. <!-- TDD -->
- [ ] 4.2 Define the `.aslp` manifest and compact table schema under `Standalone/Schemas/LanguageService/`, including source bundle, allowlist, adapter, rule-set, completeness, count, and per-payload hash fields. <!-- TDD -->
- [ ] 4.3 Implement the profile model, canonical reader/writer, integrity validation, and index under `Standalone/Source/LanguageService/Profile/`; reject unknown/incompatible schemas and any invalid explicit profile without search or fallback. <!-- TDD -->
- [ ] 4.4 Implement the reviewed root allowlist and stable-ID dependency-closure packer under `Standalone/Source/LanguageService/Profile/`, requiring all schema dependencies or an explicit external/unknown classification. <!-- TDD -->
- [ ] 4.5 Add structural/raw-byte security scans that reject source bodies, executable bytecode, native addresses, UObject layouts/offsets, asset payloads, arbitrary metadata, credentials, and absolute/private paths. <!-- TDD -->
- [ ] 4.6 Add deterministic profile reports with bytes/records by category, allowlist delta reporting, atomic publication, and a release size gate compatible with the 16 MiB Workbench payload budget. <!-- TDD -->
- [ ] 4.7 Add a CLI subcommand to create/inspect/verify an `.aslp` from explicit paths while preserving existing CLI profile selection and exit codes; document that this pack is derived and never a second implicit default bundle. <!-- TDD -->

## 5. Resident Native Language Service

- [ ] 5.1 Add lifecycle-first tests in `Standalone/Tests/AngelscriptLanguageServiceTests.cpp` for single engine/profile initialization, repeated full-text updates, document close/reopen, service disposal, and no module/observer/allocator leaks. <!-- TDD -->
- [ ] 5.2 Implement service/result/error interfaces under `Standalone/Source/LanguageService/` for create, open, update, analyze, complete, outline, close, and dispose; expose no execution context, raw bytecode, compiler pointer, or process-local ID. <!-- TDD -->
- [ ] 5.3 Refactor UE-validation setup so the service owns validated registration/profile state once and document updates rebuild only invalidated module state; retain explicit complete-bundle selection rules. <!-- TDD -->
- [ ] 5.4 Implement URI/version document storage, monotonically increasing full-text updates, stale/missing/closed result errors, and cleanup that leaves shared service state reusable. <!-- TDD -->
- [ ] 5.5 Implement `analyze` with compiler diagnostics, shared static diagnostics, class information, completeness, profile identity, and rule-set identity; preserve compiler/static fatality separation. <!-- TDD -->
- [ ] 5.6 Implement bounded context-sensitive completion for language keywords/specifiers, current-document declarations, and visible selected-profile declarations/members, including deterministic ranking and incomplete-result marking. <!-- TDD -->
- [ ] 5.7 Implement static class outlines with declared bases, properties, functions, flags, ranges, completeness, and related diagnostics; exclude UClass/CDO/offset/runtime claims. <!-- TDD -->
- [ ] 5.8 Refactor `Standalone/Source/Compiler/AngelscriptStandaloneUECompiler.*` and `Source/CLI` onto the resident service path; keep current CLI normalized results, deterministic artifacts, safety behavior, and exit codes compatible. <!-- TDD -->
- [ ] 5.9 Add source/document/result/time/count limits, structured error recovery, multi-document isolation, repeated-edit soak tests, and resident-versus-request-scoped benchmarks. <!-- TDD -->

## 6. Rich DebugServer diagnostics and VS Code consumer

- [ ] 6.1 Add UE protocol tests under `AngelscriptTest/Debugger/Protocol/` for legacy byte layout, rich schema, per-client negotiation, simultaneous legacy/rich clients, cleared snapshots, non-fatal Error, UTF-16 ranges, and stale versions before changing wire code. <!-- TDD -->
- [ ] 6.2 Add an append-only DebugServer message type and versioned rich structures in `Debugging/AngelscriptDebugServer.h`; retain the exact existing `FAngelscriptDiagnostic`/`FAngelscriptDiagnostics` serialization. <!-- TDD -->
- [ ] 6.3 Store rich-diagnostics capability per socket/client in `AngelscriptDebugServer.*`, add explicit request/negotiation, and route legacy or rich snapshots without using global adapter-version state. <!-- TDD -->
- [ ] 6.4 Extend UE diagnostic snapshot ownership to publish complete versioned replacements and empty clears while keeping compiler diagnostics available to legacy clients. <!-- TDD -->
- [ ] 6.5 Add matching TypeScript message IDs/decoders and rich-to-LSP mapping in `language-server/src/unreal-buffers.ts`, `server.ts`, and the extension debug client as required; keep legacy fixtures decodable. <!-- TDD -->
- [ ] 6.6 Replace migrated logic in `language-server/src/ls_diagnostics.ts` with authoritative snapshot storage/filtering only; retain unrelated diagnostics and code actions, and assert exactly one result per shared rule. <!-- TDD -->
- [ ] 6.7 Add root/child package scripts and Node tests so `npm test` builds and runs legacy/rich decoder, stale-range, backend, and no-duplicate suites without an Unreal process. <!-- TDD -->

## 7. Emscripten, ESM, and Worker package

- [ ] 7.1 Add optional machine-local `Paths.EmsdkRoot` handling to bootstrap/config resolution and a typed `StandaloneWeb` entry in `Tools/Shared/TestSuiteDefinitions.ps1`; add runner self-tests for valid/missing SDK configuration. <!-- TDD -->
- [ ] 7.2 Add Emscripten configure/build/test presets and targets in `Standalone/CMakePresets.json` and `CMakeLists.txt` that compile the same maintained fork, frontend, adapters, Language Service, and diagnostics core. <!-- TDD -->
- [ ] 7.3 Add C ABI contract tests and implement opaque service/document handles, profile-byte loading, versioned operation/result/error buffers, and exact deallocation under `Standalone/Source/Web/`. <!-- TDD -->
- [ ] 7.4 Add the versioned `@tdgamestudio/angelscript-language-service` ESM wrapper under `Standalone/Web/`, covering create/open/update/analyze/complete/outline/close/dispose and ABI/schema mismatch. <!-- TDD -->
- [ ] 7.5 Add a Worker adapter under `Standalone/Web/` with versioned request IDs, stale-result rejection, bounded queueing, structured initialization/limit failure, and no main-thread compiler entry point. <!-- TDD -->
- [ ] 7.6 Add export-surface and binary/package scans proving no run/execute/context invocation, filesystem, network, process, dynamic-library, arbitrary FFI, or native registration capability is reachable. <!-- TDD -->
- [ ] 7.7 Add Native/WASM parity tests for complete diagnostic tuples, light completion, class outline, partial unknowns, Unicode ranges, invalid profiles, and deterministic canonical serialization. <!-- TDD -->
- [ ] 7.8 Extend Standalone release assembly/inspection to include Native CLI, later LSP, versioned `web/` assets, manifests, profile tooling, licenses, and hashes without describing WASM analysis artifacts as UE-loadable or executable. <!-- TDD -->

## 8. AngelscriptWiki interactive editor

- [ ] 8.1 Select only required CodeMirror 6 npm modules, pin versions in `Wiki/package.json`/`pnpm-lock.yaml`, and update `product-sources.json`, provenance validation, and `THIRD_PARTY_NOTICES.md`; record that `Reference/tiddlywiki-codemirror-6` is research-only and the retired plugin remains absent. <!-- Non-TDD -->
- [ ] 8.2 Add `Wiki/src/angelscript-workbench/plugin.info`, browser module metadata, scoped styles, localized strings, and a new user-action lazy runtime policy with manifest/source-contract tests. <!-- TDD -->
- [ ] 8.3 Add a committed Workbench asset manifest and validated embedded ESM/Worker/WASM/`.aslp` tiddlers; make normal Wiki dev/test/build validate hashes without invoking UE, Emscripten, parent paths, or network. <!-- TDD -->
- [ ] 8.4 Implement a reference-counted browser runtime loader in `angelscript-workbench` that lazily creates one Worker/service/profile for the first widget and releases Worker, object URLs, listeners, documents, and WASM for the last widget. <!-- TDD -->
- [ ] 8.5 Implement `$angelscript-editor` with `sourceTiddler` precedence over `code`, TW5-safe source resolution, per-widget URI/version state, in-memory draft, reset, refresh behavior, and no tiddler/storage/filesystem/network writes. <!-- TDD -->
- [ ] 8.6 Integrate locally scoped CodeMirror editing, AS syntax support, line numbers, brackets, search, keyboard commands, and approximately 250 ms debounced full-document updates without affecting global Wiki edit widgets. <!-- TDD -->
- [ ] 8.7 Render current-version compiler/shared diagnostics in the gutter and accessible problem list, preserving IDs, severity, non-fatal/source distinction, tags, related information, and source-range navigation without implementing rules in TypeScript. <!-- TDD -->
- [ ] 8.8 Render bounded lightweight completion from Worker results for language/local/profile contexts, label the selected profile `Wiki Sandbox / Partial UE API`, and never advertise project-wide or complete-engine knowledge. <!-- TDD -->
- [ ] 8.9 Render the optional class outline with declared bases/properties/functions/flags/completeness/diagnostic state and an explicit “static semantic preview, not a generated UE UClass” notice. <!-- TDD -->
- [ ] 8.10 Implement CodeMirror, Worker, WASM/profile, analysis, and limit failure fallbacks that retain readable escaped source/editing where possible, accessible status/retry, and unaffected surrounding tiddler content. <!-- TDD -->
- [ ] 8.11 Complete keyboard, focus, screen-reader, non-color severity, localized Chinese/English, reduced-motion, and narrow-screen stacked-layout coverage in the `code` and `document` Playwright domains. <!-- TDD -->
- [ ] 8.12 Add reviewed article examples sourced from `text/x-angelscript` tiddlers: one generated Actor-like class with class preview and one intentionally broken/fixed diagnostic exercise; leave ordinary `$angelscript-code` examples read-only. <!-- Non-TDD -->
- [ ] 8.13 Enforce exactly one `dist/index.html`, no runtime network request, final HTML ≤24 MiB, Workbench payload ≤16 MiB, cold initialization ≤5 s, 500-LOC warm p95 ≤500 ms excluding debounce, and no analysis-attributable main-thread task >50 ms. <!-- TDD -->

## 9. Native stdio LSP and explicit offline backend

- [ ] 9.1 Add framed JSON-RPC/LSP tests under `Standalone/Tests/LanguageServer/` for initialize/shutdown/exit, didOpen/full didChange/didClose, current-version diagnostics, malformed/oversized messages, stderr logging, and deterministic disposal. <!-- TDD -->
- [ ] 9.2 Implement `Standalone/Source/LanguageServer/` as a thin stdio adapter over the resident service and add an `as-language-server` CMake/install/package target; advertise only implemented synchronization and diagnostics capabilities. <!-- TDD -->
- [ ] 9.3 Add explicit executable/profile-or-bundle CLI options, compatible identity validation, no cache search/merge/fallback, bounded Content-Length, and non-zero unrecoverable failure exits. <!-- TDD -->
- [ ] 9.4 Add `UnrealAngelscript.languageServer.backend = unreal|standalone` plus explicit offline executable/profile settings to the VS Code manifest and launcher; default to `unreal` and restart on backend changes. <!-- TDD -->
- [ ] 9.5 Keep online completion/hover/signature/definition/references/rename/assets/navigation/debug registered in the UE backend, and ensure the first offline backend neither advertises nor simulates them. <!-- TDD -->
- [ ] 9.6 Add online/offline integration tests for backend startup, state clearing, invalid explicit configuration, current-version diagnostics, shared rule-set replacement, and zero duplicate `ASLINT` publication. <!-- TDD -->

## 10. Verification, documentation, and coordinated release

- [ ] 10.1 Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -TimeoutMs 1200000` and record the fresh build log/result under the change verification directory. <!-- Non-TDD -->
- [ ] 10.2 Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Diagnostics.Shared+Angelscript.TestModule.Debugger.Protocol" -TimeoutMs 1200000` and record counts with zero failures/timeouts. <!-- Non-TDD -->
- [ ] 10.3 Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -TimeoutMs 900000`, `-Suite StandaloneWeb -TimeoutMs 1200000`, and `-Suite StandaloneRelease -TimeoutMs 1200000`; keep Native and Web counts distinct from UE Automation. <!-- Non-TDD -->
- [ ] 10.4 Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStandaloneExternalSmoke.ps1` against the final Release archive and prove deterministic project export plus external CLI/profile consumption. <!-- Non-TDD -->
- [ ] 10.5 From `Extensions/AngelscriptVSCode`, run `npm ci`, `npm run compile`, and `npm test`; record legacy/rich protocol, backend, Unicode/stale, and no-duplicate results. <!-- Non-TDD -->
- [ ] 10.6 From `Wiki`, run `pnpm install --frozen-lockfile`, `pnpm run test:fast`, `pnpm run test:feature -- code`, `pnpm run test:feature -- document`, and `pnpm run verify`; record artifact size, network, lifecycle, accessibility, and performance evidence. <!-- Non-TDD -->
- [ ] 10.7 Run repeated UE/Native/WASM golden parity comparison over full rule/source/severity/nonFatal/message/range/tags/related/profile/rule-set tuples and resolve every unexplained difference before promotion. <!-- Non-TDD -->
- [ ] 10.8 Run complete bundle/profile/Web/Release ZIP security and provenance scans, verify two `.aslp` builds are byte-identical, and record category sizes plus baseline/regression metrics under `benchmarks/` and `verification/`. <!-- Non-TDD -->
- [ ] 10.9 Update Chinese guidance first in `AGENTS_ZH.md`, Wiki Chinese authoring guidance, Standalone/offline bundle guide, and VS Code guide; then synchronize English guidance, support matrices, release packaging, safety, partial-profile, rule-version, and asset-refresh boundaries. <!-- Non-TDD -->
- [ ] 10.10 Commit `Plugins/Angelscript` first, commit `Wiki` second after selecting matching release assets, then update only the intended parent OpenSpec/tool/extension/docs paths and both gitlinks; review `git diff --submodule=log` and never stage unrelated dirty files. <!-- Non-TDD -->
- [ ] 10.11 Run `openspec validate feature-as-cross-host-language-service --type change --strict --no-interactive`, update final verification evidence and task states, and leave archiving to a separate explicit close request. <!-- Non-TDD -->
