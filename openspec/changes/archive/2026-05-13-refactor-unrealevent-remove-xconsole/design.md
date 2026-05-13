## Context

`Plugins/UnrealEvent` is a GMP-derived standalone plugin. The active runtime still includes GMP's XConsole system: a typed console-command wrapper, command pipeline state, command-line execution hooks, optional HTTP command server support, optional Python script execution, and an XConsole commandlet. The only active non-pipeline use outside XConsole itself is two signal-debug controls in `GMPSignalsImpl.cpp`.

The disabled `Source/GMPEditor` reference tree also includes `XConsoleManager.h` and `FXConsoleCommandLambda` registrations. Although that source is not currently declared in `UnrealEvent.uplugin`, keeping those references makes later cleanup and re-enablement ambiguous.

## Goals / Non-Goals

**Goals:**

- Remove the XConsole pipeline and all startup hooks that process XConsole command lines.
- Remove XConsole-only `HTTPServer` and `PythonScriptPlugin` dependencies from build metadata and plugin descriptor.
- Preserve `gmp.key.debug` and `gmp.msgkey.debug` as ordinary Unreal debug controls for non-shipping builds.
- Remove XConsole references from `Source/GMPEditor` without deleting the reference modules themselves.
- Keep unrelated GMP runtime systems, HTTP package support, protobuf support, ThirdParty source, and module names intact.

**Non-Goals:**

- Do not add a replacement command pipeline, HTTP command server, Python execution path, or commandlet.
- Do not remove GMP's separate HTTP package support unless a search proves it is only XConsole-owned.
- Do not physically delete the `Source/GMPEditor` reference modules in this change.
- Do not archive this OpenSpec change until implementation and verification are complete.

## Decisions

- **Delete XConsole rather than stub it.** Keeping dummy headers would preserve accidental dependencies. Removing the source/header files makes any remaining XConsole usage fail at compile or search time.
- **Preserve only simple signal debug controls.** `gmp.key.debug` and `gmp.msgkey.debug` are local diagnostics in `GMPSignalsImpl.cpp`; replacing their registrations with standard Unreal console variables keeps the useful behavior without retaining XConsole typed invocation.
- **Remove command-line lifecycle hooks from module startup.** The map-open, post-load-map, and post-start-play callbacks only exist to drive XConsole command processing, so they should be removed with the pipeline.
- **Treat GMPEditor as cleanup scope, not active feature scope.** Remove XConsole includes and registrations from the disabled reference tree. Preserve surrounding reference code where it remains useful and compiles without XConsole.
- **Use search plus build as acceptance.** This is a dependency-pruning refactor with little meaningful new runtime behavior to test; validation should focus on absence of symbols, descriptor validity, OpenSpec strict validation, and the unified build.

## Risks / Trade-offs

- **Hidden XConsole dependency remains** -> Run a targeted repository search for XConsole symbols and remove every reference in `Source/UnrealEvent` and `Source/GMPEditor`.
- **Build dependency removed too aggressively** -> Keep `HTTP` / `GMP_WITH_HTTP_PACKAGE` unless a separate audit shows it is unused; remove only `HTTPServer`, `GMP_HTTPSERVER`, and `PythonScriptPlugin`.
- **Debug controls lose type conversion behavior** -> Use standard Unreal console variables and a small sink/update path if needed so the debug filter state still accepts runtime updates.
- **Disabled GMPEditor source may not compile today** -> Still remove XConsole-only constructs there so future re-enablement has one fewer dependency; do not broaden the cleanup into unrelated editor module fixes.
- **Dirty host repository state** -> Stage only the UnrealEvent submodule gitlink and this OpenSpec change in the parent repository.

## Migration Plan

- Generate OpenSpec artifacts for this change before editing runtime code.
- Remove XConsole files and references from the active runtime module.
- Replace or remove XConsole registrations in `Source/GMPEditor`.
- Remove XConsole-only build and descriptor dependencies.
- Validate by strict OpenSpec validation, descriptor JSON parsing, targeted symbol search, and `Tools\RunBuild.ps1`.
- Commit `Plugins/UnrealEvent` first, then commit the parent repository gitlink and OpenSpec artifacts.

## Open Questions

- None. The chosen scope includes both active runtime and disabled `Source/GMPEditor` reference source.
