## Context

GenericMessagePlugin/GMP's `XConsole` implementation contains a useful pattern: typed command registration, argument conversion, command metadata, command-file execution, ordered command pipelines, pause/continue for asynchronous UE flows, and machine-readable command results.

The current `XConsole` implementation also includes responsibilities that should not define the new reusable API surface: an `IConsoleManager` wrapper, HTTP `/xcmd` remote execution, Python support, commandlet execution, crash/hang helper commands, and GMP-specific `z.*` naming. The user wants this capability generalized as a standalone plugin named `CommandFlow`.

Implementation must consult the upstream GenericMessagePlugin/GMP GitHub repository for the latest `XConsole` source and behavior. The local snapshot remains useful, but it should not be the only reference when extracting behavior.

## Goals / Non-Goals

**Goals:**

- Add a standalone `CommandFlow` plugin that can be consumed independently.
- Provide a small runtime command framework for typed command registration, argument parsing, command metadata/help, command context, results, and command pipeline control.
- Provide a separate automation runner layer for command files, commandlets/headless execution, wait helpers, CI-friendly exit/result output, and reproducible issue scripts.
- Preserve the useful design lessons from GMP `XConsole` without keeping the `XConsole` name or copying unnecessary HTTP/Python/console-manager surface into runtime.

**Non-Goals:**

- Do not add HTTP, WebSocket, MCP, or Python remote execution in the initial `CommandFlow` plugin.
- Do not provide a marketplace-style console button UI or Console Variables Editor replacement.
- Do not make `CommandFlowRuntime` depend on `AngelscriptRuntime`, `PythonScriptPlugin`, or `HTTPServer`.

## Decisions

### Create a standalone `CommandFlow` plugin

`CommandFlow` should live under `Plugins/CommandFlow/`. Angelscript diagnostics, coverage, state dumps, debugger startup, and future tools can benefit from a common typed command pipeline.

Alternative considered: keep this as ad hoc diagnostics helpers inside the first consumer. That keeps initial integration smaller but makes a general command framework harder to reuse.

### Split runtime command SDK from automation runner

The plugin should start with two module concepts:

- `CommandFlowRuntime`: command registry, typed argument conversion, execution context, result model, metadata/help, command pipeline primitives, and pause/continue.
- `CommandFlowAutomation`: command file runner, commandlet/headless entry point, CI result output, wait helpers, and reproducible script execution.

The exact second module name may be revisited during implementation, but the module boundary should remain: runtime SDK stays lightweight; automation entry points can carry commandlet/editor/headless concerns.

Alternative considered: one runtime module for everything. That would simplify descriptor work but repeat GMP's problem by mixing reusable SDK code with automation and future remote entry points.

### Keep remote execution out of the initial change

GMP `XConsole` can bind an HTTP `/xcmd` route and invoke Python. Those are useful in controlled internal setups but create security, packaging, dependency, and platform risks. If needed later, add `CommandFlowRemote` or `CommandFlowEditor` through a separate OpenSpec change with explicit opt-in behavior.

### Model commands as typed functions with explicit context and result

Commands should be registered with a stable name, help text, typed parameters, and a handler. Handlers should receive a context object when they need world/output/pipeline control and should return an explicit result. This is the core design to preserve from GMP `FXConsoleCommandLambda*`, but it should not require inheriting or proxying all of UE `IConsoleManager`.

### Use upstream GMP as reference during implementation

Implementation tasks should inspect the upstream GenericMessagePlugin/GMP GitHub repository before extracting behavior. The relevant GMP files include `XConsoleManager.h`, `XConsoleManager.cpp`, and `XConsolePythonSupport.h`, but the actual file layout should be verified against the upstream repo at implementation time.

## Risks / Trade-offs

- **Scope creep into a remote-control platform** -> Keep HTTP/WebSocket/MCP/Python out of this change and require separate specs for each remote surface.
- **Runtime module becomes too heavy** -> Keep `CommandFlowRuntime` free of `HTTPServer`, `PythonScriptPlugin`, and Angelscript dependencies.
- **Argument parsing diverges from UE expectations** -> Start with documented support for simple UE-safe types, JSON strings, and file-backed payloads; expand only through tests.
- **Over-copying GMP implementation** -> Treat GMP as a behavior reference and preserve license attribution if source is copied; prefer clean-room extraction where practical.
- **Command pipelines are hard to test** -> Require TDD tasks for command parsing, command metadata, result handling, pause/continue, and command-file execution.

## Migration Plan

1. Create the `Plugins/CommandFlow` plugin with `CommandFlowRuntime` and `CommandFlowAutomation` module descriptors.
2. Fetch or inspect upstream GenericMessagePlugin/GMP from GitHub and record the exact commit or tag used as XConsole reference.
3. Implement the runtime command registry, argument conversion, metadata, context, result, and pipeline primitives behind `CommandFlow` names.
4. Implement automation runner support for command files, commandlet/headless execution, result output, and wait helpers.
5. Add tests for positive and negative command registration/execution, argument conversion, command-file parsing, pipeline pause/continue, and automation result output.

## Open Questions

- Should the automation module be named `CommandFlowAutomation` or the narrower `CommandFlowRunner`?
- Should `CommandFlow` live as a submodule-backed standalone repository immediately, or start as a local plugin inside this host repository and split later?
- Which typed parameter set belongs in v1: primitive types only, `FName`/`FString`/`UObject` soft paths, JSON-backed structs, or selected `FProperty` import support?
- Should `CommandFlowAutomation` include a commandlet in v1, or only expose a runtime runner API that existing project tools call?
