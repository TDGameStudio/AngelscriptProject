## Why

The maintained Standalone compiler can already compile and analyze AngelScript outside Unreal Engine, but it is still a process-oriented CLI: it recreates compilation state per request, has no browser build, and is not a reusable document service. At the same time, Unreal, the existing TypeScript VS Code Language Server, and a future Wiki editor can produce overlapping diagnostics from different implementations, which would create multiple sources of truth for rule behavior.

We need one plugin-owned semantic and diagnostic authority that can run natively in Unreal, natively in Standalone/LSP, and as WebAssembly in the offline Wiki. This also gives AngelscriptWiki a focused, article-embedded code experience without turning the Wiki into an IDE, requiring a local service, or executing user scripts.

## What Changes

- Add a host-neutral C++ diagnostics core with one normalized fact model, one rule registry, stable rule IDs, default severities, message templates, suppression behavior, and a versioned rule-set hash.
- Run that same diagnostics implementation in `AngelscriptRuntime`, Native Standalone, WebAssembly, and the later Native Language Server; remove migrated duplicate rules from the TypeScript Language Server.
- Extend the maintained-fork semantic observation and offline export facts only as needed to provide the same rule inputs outside UE, without introducing Standalone branches into existing binds or ClassGenerator.
- Refactor Standalone compilation behind a resident, versioned document Language Service that supports analysis, lightweight completion, and static class-outline results while preserving the existing CLI.
- Add a deterministic compact `.aslp` language-service profile derived from an explicit complete UE offline bundle and a curated Wiki API allowlist. The Wiki profile is always declared partial and contains no source, executable bytecode, native addresses, or private machine paths.
- Add an Emscripten build, stable C ABI, ESM wrapper, and Worker-oriented JS API for the same C++ Language Service.
- Add a separate, lazy AngelscriptWiki product plugin exposing an article-embedded `$angelscript-editor` widget with editing, lightweight completion, real-time compiler/shared diagnostics, reset, and a static class-structure preview.
- Keep ordinary `$angelscript-code`, core code blocks, and direct `text/x-angelscript` tiddlers read-only and unchanged; do not restore the retired global `tiddlywiki-codemirror-6` plugin.
- Add an opt-in Rich Diagnostics message to DebugServer without changing the legacy diagnostics payload, and update the VS Code bridge to consume shared diagnostics without duplicates.
- Add a later Native stdio LSP adapter and an explicitly selected VS Code offline backend. The existing UE-connected backend remains the default and retains its current full IDE/debug feature set.
- Add Native/UE/WASM parity fixtures, deterministic asset and security checks, browser lifecycle tests, and bounded performance/size gates.

## Capabilities

### New Capabilities

- `as-cross-host-diagnostics`: Defines the shared fact model, canonical rule set, non-fatal static-diagnostic semantics, cross-host parity, and version identity.
- `as-standalone-language-service`: Defines the resident native document service, versioned analysis, lightweight completion, class outline, and existing CLI compatibility.
- `as-language-service-profile`: Defines deterministic compact `.aslp` production, partial-profile semantics, integrity, provenance, and prohibited content.
- `as-language-service-web`: Defines the Emscripten C ABI/ESM/Worker surface, browser resource limits, offline packaging, and Native/WASM parity.
- `wiki-angelscript-interactive-editor`: Defines the explicit article widget, lazy lifecycle, ephemeral editing, lightweight completion, diagnostics, class preview, fallback, accessibility, and offline artifact budgets.
- `as-native-language-server`: Defines the later Native stdio LSP diagnostics adapter and explicit offline-backend boundary.

### Modified Capabilities

- `debugger-protocol-v2`: Add per-client negotiation and backward-compatible transport for versioned rich diagnostics while retaining the legacy diagnostics payload.
- `vscode-lsp-protocol-compat`: Make the VS Code bridge consume authoritative shared diagnostics, avoid duplicate TypeScript rules, and preserve the existing UE-connected default behavior.

## Impact

- **Plugin submodule:** `Plugins/Angelscript/Source/AngelscriptRuntime` gains the shared diagnostics implementation and UE adapter; the maintained fork gains bounded semantic observations; DebugServer gains a negotiated rich-diagnostics message; offline export gains versioned semantic facts.
- **Standalone:** `Plugins/Angelscript/Standalone` gains the resident Language Service, compact-profile packer, Emscripten targets, JS package assets, Native/WASM tests, and later stdio LSP target. The current native-runtime and ue-validation safety boundaries remain intact.
- **VS Code:** `Extensions/AngelscriptVSCode` removes only diagnostics now owned by the shared core, adds rich-diagnostics decoding and an explicit offline backend, and retains its current UE-connected completion/navigation/debug behavior by default.
- **Wiki submodule:** `Wiki/src/angelscript-workbench` becomes a new local product plugin. It uses a minimal audited CodeMirror 6 module selection, embedded Worker/WASM/profile assets, and adds focused article fixtures and browser tests; it does not load on ordinary pages.
- **Repository tooling/docs:** Standard runners gain a typed WebAssembly suite and optional machine-local Emscripten path. Chinese guidance is updated before English guidance. Release packaging records plugin/profile/rule-set provenance and hashes.
- **Compatibility:** Existing DebugServer diagnostics, Standalone CLI profiles, complete offline-bundle selection rules, ordinary Wiki code rendering, and the VS Code UE backend remain supported. No user script execution, UObject simulation, network access, project-directory access, or automatic Wiki persistence is introduced.
