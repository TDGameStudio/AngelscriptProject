## Why

GMP's `XConsole` contains useful ideas for typed command registration, command-file execution, command pipelines, and automation result output, but its current name and implementation are tied to GMP and carry HTTP/Python/console-manager responsibilities that should not live inside `UnrealEvent` runtime. The project needs a standalone, reusable plugin named `CommandFlow` so UnrealEvent, Angelscript, and future tools can share a small command pipeline layer without inheriting GMP's XConsole identity.

## What Changes

- Add a new standalone `CommandFlow` plugin under `Plugins/CommandFlow/`.
- Add `CommandFlowRuntime` as the core runtime module for typed command registration, argument parsing, command metadata, execution context, command result reporting, and pipeline pause/continue.
- Add an automation-facing runner module, initially named `CommandFlowAutomation`, for commandlet/file-based execution, CI/headless output, and wait/result helper commands.
- Keep remote execution surfaces such as HTTP, WebSocket, MCP, and Python bridge out of the initial plugin unless a later OpenSpec change explicitly adds them.
- Treat GMP `XConsole` as a reference source, not the target API name. Future UnrealEvent/GMP pruning may remove `XConsole` from the GMP-derived runtime after `CommandFlow` covers the useful behavior.
- Require implementation work to consult the upstream GenericMessagePlugin GitHub repository for the latest `XConsole` reference behavior instead of relying only on the current local snapshot.

## Capabilities

### New Capabilities

- `commandflow-plugin`: Defines the standalone `CommandFlow` plugin, runtime module boundary, typed command model, argument parsing, execution context, result model, and metadata/help behavior.
- `commandflow-automation-runner`: Defines command-file execution, commandlet/headless automation entry points, pipeline control, CI-friendly output, and the migration boundary from GMP `XConsole`.

### Modified Capabilities

- None.

## Impact

- New plugin source under `Plugins/CommandFlow/`.
- Host project plugin metadata and setup documentation for an additional local plugin.
- Potential future dependency from `Plugins/UnrealEvent/` diagnostics/tests to `CommandFlowRuntime` or `CommandFlowAutomation`, while keeping UnrealEvent runtime ownership separate.
- Future GMP-derived UnrealEvent cleanup may remove or disable `XConsoleManager`, `XConsolePythonSupport`, HTTP/Python XConsole dependencies, and related `z.*` pipeline commands after replacement coverage exists.
- Reference source: upstream GenericMessagePlugin/GMP GitHub repository, especially `XConsoleManager.h`, `XConsoleManager.cpp`, and `XConsolePythonSupport.h`.
