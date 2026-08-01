## Why

The maintained AngelScript fork, UE-AngelScript frontend, final registered API surface, and bytecode builder currently require an Unreal Engine process even when a developer only needs a fast native-script loop or offline validation. A standalone host can shorten feature iteration substantially, but native execution and UE-backed validation require different trust, registration, and artifact contracts.

## What Changes

- Add a Win64-first standalone host that builds the maintained AngelScript fork without an Unreal installation, Unreal include/library paths, generated code, or process startup. A CMake-only `Standalone/Compat` include facade supplies the small UE Core API subset already named by the fork so portability does not rewrite fork containers, memory, atomics, math, assertions, or host facades.
- Add a `native-runtime` profile that compiles and runs native AngelScript with a bounded portable standard library, deterministic artifacts, and default time/memory limits.
- Add a separate `ue-validation` profile that consumes exactly one deterministic UE export bundle, compiles UE-AngelScript to analysis-only bytecode, emits a portable class model, and never executes compile-only UE symbols.
- Export final UE registration, reflection relationship, script-baseline, adapter, engine-setting, loaded module/plugin scope, and Asset Registry facts as a complete symbol snapshot without native addresses, C++ source, executable code, or asset payloads.
- Provide a plugin-owned export Commandlet that any Unreal project using the `Angelscript` plugin can invoke to publish its own complete final JSON bundle without changing manual, generated, reflected, optional-plugin, or project binding sources.
- Ship a generated `default-engine` bundle from this repository's checked-in `AngelscriptProject` host and its normally enabled plugins, project registrations, successful script baseline, and declared asset scope; allow an explicitly selected project-generated complete bundle to replace it without union, overlay, or fallback.
- Reconstruct bundle declarations with non-executable generic stubs, stable symbol identities, explicit capability classification, and signature-based bytecode linkage.
- Keep the mature UE `FAngelscriptPreprocessor` as the authoritative UE frontend and restore the two algorithms that had temporarily delegated into a shared Language layer.
- Own source/module preprocessing, declaration IR, rewrite plans, source maps, diagnostics, and portable SHA-256 inside `Standalone/`; the standalone frontend is a private implementation rather than a UE Runtime abstraction.
- Add standalone-only UE container/object-wrapper adapters and typed resource-path validation without adding standalone branches to existing `Bind_*.cpp` or ClassGenerator logic.
- Keep standalone portability out of the maintained fork wherever include-path substitution or target-selected translation units can preserve the existing UE spelling. Fork changes are limited to host-independent language/runtime behavior such as semantic observation and separately tested compiler/runtime correctness fixes.
- Keep one canonical OpenSpec lifecycle, organized into an up-front feasibility gate and six ordered implementation workstreams with independent verification records.
- Keep VS Code offline-bundle projection as a non-blocking later change.
- Do not add UE-AS execution, fake UObject/World/GC behavior, UE-loadable standalone bytecode, arbitrary native FFI, file/network access in the native runtime, or first-release Linux/macOS packaging.

## Capabilities

### New Capabilities

- `angelscript-standalone-native-runtime`: Compile and safely execute native AngelScript with the maintained fork and a bounded portable host profile.
- `angelscript-standalone-frontend`: Provide deterministic standalone-private source preprocessing and declaration analysis without Unreal includes, libraries, or runtime ownership.
- `ue-angelscript-standalone-analysis`: Compile and analyze bundle-backed UE-AngelScript without Unreal Engine or UE runtime execution.
- `ue-angelscript-offline-contract`: Export and consume a deterministic, versioned contract for final UE-AngelScript symbols, script baselines, adapters, and assets.

### Modified Capabilities

- None.

## Impact

- The implementation roadmap spans `Plugins/Angelscript/Standalone/`, the minimal semantic portions of the maintained fork, the restored UE preprocessor, a host-project-independent UE-side export Commandlet, release packaging, and repository test tooling. Mechanical portability belongs to `Plugins/Angelscript/Standalone/Compat/` and CMake target selection; there is no Runtime-owned standalone frontend layer.
- The packaged `default-engine` name denotes the distribution's default selected snapshot, not a promise that its producer contains only engine/core-plugin symbols. Its manifest exposes the exact `AngelscriptProject` modules, plugins, registrations, script baseline, and asset scope captured by the release.
- Existing UE bindings, including the separately planned manual Binding architecture, ClassGenerator materialization, native UE execution, hot reload, editor integration, RPC routing, and GC remain UE-owned and gain no standalone serialization or conditional-compilation responsibility.
- This change is the sole standalone lifecycle. Its four capability specs, phase-grouped task list, internal workstream designs, and milestone verification records remain active until the complete first-release contract is delivered and archived once. Earlier records that describe a shared `AngelscriptLanguageCore` are historical evidence superseded by the standalone-private frontend correction recorded here.
