# Workstream 01: Portable Core and Native Runtime

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


## Context

The authoritative fork reports AngelScript `2.33.0 WIP` and contains selective later compatibility plus extensive UE changes. Native SDK automation tests already compile and execute script contexts, but the fork sources directly reference UE containers, memory, math, atomics, assertions, logging, hot-reload bookkeeping, and editor-only tracking. The vendored fork contains only `source/`; common upstream add-ons are present only in the pinned `Reference/angelscript-v2.38.0` checkout.

This workstream is the first implementation phase of the standalone roadmap. It must deliver a useful native product and a genuinely portable core, not a syntax-only prototype.

## Goals / Non-Goals

**Goals:**

- Configure, build, test, and package the maintained fork on Win64 without UE.
- Compile native source to deterministic bytecode.
- Execute native source through a bounded generic-binding standard library.
- Preserve current UE and NativeCore behavior while removing direct UE dependencies from shared fork code.
- Establish architecture checks and repository-standard verification used by later workstreams.

**Non-Goals:**

- UE dialect, UE bundle, reflection symbols, UE containers, resource paths, or portable UE preprocessing.
- Native file/network/process/dynamic-library access or arbitrary FFI.
- Running a bytecode file supplied to the CLI; `run` compiles selected source in-process before execution.
- Linux/macOS packaging, JIT/StaticJIT, debugger server, coverage, or hot reload.

## Decisions

### 1. Source and target ownership

Create:

```text
Plugins/Angelscript/Standalone/
  CMakeLists.txt
  CMakePresets.json
  Source/Host/
  Source/Compiler/
  Source/Runtime/
  Source/StdLib/
  Source/CLI/
  Tests/
  ThirdParty/AngelScriptAddons/
```

CMake explicitly lists maintained fork source inputs. It builds:

- `AngelscriptCompilerCore`;
- `AngelscriptStandaloneHost`;
- `AngelscriptStandaloneCLI` (`as-standalone.exe`);
- `AngelscriptStandaloneTests`.

The UE module continues compiling the same fork source files. Portable source lists and architecture scans fail if a copied compiler tree appears under Standalone.

### 2. Port shared fork code unconditionally

Refactor one dependency family at a time:

1. containers and move helpers;
2. allocation and memory operations;
3. atomics;
4. math/algorithms;
5. assertions and diagnostics;
6. editor/hot-reload tracking storage.

Use AngelScript-owned structures where their semantics are already part of the engine; otherwise use focused STL types. Host-only diagnostics and platform behavior go through narrow interfaces or selected translation units.

No shared standalone business branch is permitted. `ANGELSCRIPT_LANGUAGE_STANDALONE` is confined to the LanguageCore platform header and standalone CMake/test-host configuration. The remaining allowlist contains only upstream platform/symbol selection, `AS_MAX_PORTABILITY`, and dedicated implementation-file guards with a reason and removal condition.

### 3. Use a maximum-portability generic host profile

Standalone excludes native application-call assembly paths not required for script bytecode execution and registers all host functions/behaviors through `asCALL_GENERIC`. Script-to-script execution remains real AngelScript context execution.

The native profile has a stable surface hash over engine properties and registered standard-library declarations. Artifacts record that hash and the maintained fork identity.

### 4. Maintain a patched bounded standard library

Import reviewed sources for:

- `scriptstdstring`;
- `scriptarray`;
- `scriptdictionary`;
- `scriptmath`.

Copies live in `Standalone/ThirdParty/AngelScriptAddons/` and retain upstream license headers. `ThirdParty/README.md` records the pinned reference revision, copied paths, changes, and why no runtime dependency on `Reference/` exists.

Only portable UTF-8 `string`, `array<T>`, `dictionary`, math, `print`, and `assert` are registered. Generic wrappers replace any unavailable native registration path. File, filesystem, socket, process, environment, dynamic-library, and arbitrary FFI surfaces are absent.

### 5. Route runtime allocations through a counted host

The standalone process uses one engine and one execution at a time. Engine allocation functions and patched standard-library allocations report current and peak bytes to `AngelscriptStandaloneAllocator`.

Default limit is 256 MiB. An allocation that would exceed the configured limit fails through the existing AngelScript allocation/error path, aborts the active context, and records a resource-limit diagnostic. Cleanup tests require zero live tracked allocations after engine shutdown, excluding explicitly documented process/runtime allocator overhead.

### 6. Enforce deadline and cancellation through context callbacks

`run` defaults to 5000 ms. A context callback compares a monotonic deadline and an atomic cancellation flag, aborting the active context when reached. Long-running standard-library loops check the same cancellation service at bounded intervals.

Timeout and memory-limit terminations exit `4`; script exception or explicit abort exits `3`. Diagnostics include source/function/call stack when the context exposes them.

### 7. Fix the native entry and result contracts

Accepted entry declarations:

```angelscript
void main(const array<string> args)
int main(const array<string> args)
```

CLI arguments after `--` are converted to a read-only array of UTF-8 strings. A normal integer return is written to `result.json.scriptResult`; normal completion exits `0`.

Compile/source/entry failure exits `1`; usage/I/O/internal/profile incompatibility exits `2`.

### 8. Emit deterministic profile-scoped artifacts

`compile --dialect native` writes:

```text
<output>/
  result.json
  diagnostics.jsonl
  modules/<module-id>.asbc
```

`result.json` records schema, native-runtime profile, fork/compiler/profile/add-on hashes, normalized source roots/entries, module graph/input hash, modules, diagnostics, and status. `run` writes the same result plus resource usage, execution status, and optional `scriptResult`.

Bytecode repeatability excludes elapsed time, peak memory, and runtime output; those fields are stored outside the deterministic compile identity.

### 9. Integrate through repository test entry points

`Tools/RunTestSuite.ps1 -Suite Standalone` configures the CMake preset, builds, and runs CTest. Runner self-tests cover discovery, isolated reports, timeout, and failure propagation.

Architecture tests scan CMake link/include inputs and portable/shared sources. Native corpus cases are indexed with source evidence, expected compile/execute outcome, and intentional fork-specific differences. UE build and NativeCore suites gate every portability batch.

## Risks / Trade-offs

- **[Portability refactor changes UE behavior]** → Change one dependency family per task and require NativeCore plus UE build after each batch.
- **[Official add-ons assume a different public API]** → Import only selected sources, patch against the maintained fork, record all deltas, and test generic registration/save-load/execution.
- **[Memory accounting misses add-on allocations]** → Patch every selected add-on allocation path to the host allocator and scan the profile for unapproved direct allocation.
- **[Line callbacks do not interrupt a long host operation]** → Add bounded cancellation checks inside standard-library loops.
- **[Maximum portability hides native-call regressions]** → This target intentionally tests generic host calls; existing UE NativeCore tests remain authoritative for native calling conventions.
- **[Artifact determinism is polluted by runtime fields]** → Separate compile identity from run telemetry and normalize paths/module order.

## Migration Plan

1. Add the empty target, repository suite, and architecture gates.
2. Port shared fork dependency families with UE/NativeCore checks after each family.
3. Add native compile and deterministic save-bytecode.
4. Import and adapt the bounded standard library.
5. Add execution, entry binding, limits, and telemetry.
6. Run corpus, packaging, architecture, NativeCore, and UE build gates.

Rollback removes standalone-owned targets/add-ons/runner integration. Shared portability changes are retained only when the UE and NativeCore gates pass independently.

## Open Questions

None for this workstream. Bytecode-file execution, additional add-ons, arbitrary host APIs, and other platforms are separate changes.
