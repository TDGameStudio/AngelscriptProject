## Context

The host sources already live at `Plugins/Angelscript/AngelscriptLSP/`. CMake still `project(AngelscriptStandalone)` and still sets `ANGELSCRIPT_FORK_ROOT` to `${ANGELSCRIPT_RUNTIME_ROOT}/ThirdParty/angelscript/source`. Plugin README still lists `Standalone/`. Archived language-surface work kept this tree dormant after add-on removal. Diagnostics tooling already split in-process `asCLanguageService` from a later JSON-RPC adapter and from `Extensions/AngelscriptVSCode/`.

See `attachments/drafts/design.md` for the approved identity sketch.

## Goals / Non-Goals

**Goals:**

- Compile the same host sources against `Source/AngelscriptRuntime/angelscript`.
- Teach live docs and tools the directory name `AngelscriptLSP` while keeping Standalone product identity.
- Fail closed if a script still looks under `Standalone/`.
- List sibling Changes that still Files `Standalone/`.

**Non-Goals:**

- Implementing a language-server protocol or renaming the CLI.
- Certifying a CMake/CTest host binary.
- Adding an AngelscriptLSP Unreal module.
- Rewriting other Changes' `tasks.md`.

## Decisions

### Directory rename only

The folder name `AngelscriptLSP` is a filesystem rename of dormant Standalone. Product, CLI, CMake project, tests prefixed `AngelscriptStandalone.*`, and `ue-as-standalone-v1` stay. Alternative considered: treat this Change as the native LSP host. Rejected because JSON-RPC is later work and the TypeScript server already lives in `Extensions/AngelscriptVSCode/`.

### CMake fork root follows the first-party SDK

`ANGELSCRIPT_FORK_ROOT` becomes `${ANGELSCRIPT_RUNTIME_ROOT}/angelscript`. That string is owned by `angelscript/refactor-runtime-owned-sdk-layout`. This Change does not edit `AngelscriptRuntime.Build.cs`. Either git commit may land first because the SDK folder already exists; the CMake task lists the SDK Change as a coordinator prerequisite, not a same-graph edge.

### No dual-path search

Scripts that still look under `Standalone/` must fail with a missing path. Searching both names would hide incomplete retargets.

### `CheckRemovedAddons.py` stays a source audit

Default `--root` is `parents[1]` of the script (the host tree). The invocation path in README changes; the audit policy does not. Passing that Python command does not certify a working `as-standalone` binary.

## Risks / Trade-offs

- Root `Tools/RunTestSuite.ps1` and `TestSuiteDefinitions.ps1` are legacy deletion candidates relative to Harness `ue.*` routes. They still name a working directory that must exist if anyone runs those suites, so this Change retargets the directory string and does not revive those wrappers as the live route.
- Dated ZH knowledge and archive tasks.md will keep saying `Standalone/`. That is historical, not a live instruction.
