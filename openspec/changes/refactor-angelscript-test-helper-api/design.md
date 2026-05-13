## Context

`AngelscriptTest` is an Editor test module that already owns reusable helper families for runtime integration, binding coverage, UE functional tests, reflection access, and native AngelScript SDK tests. Its build rule currently exposes the module root as a public include path, so extension test modules can include headers such as `Shared/AngelscriptTestMacros.h` through a normal `AngelscriptTest` dependency.

`AngelscriptGASTest` already depends on `AngelscriptTest`, but it also adds a private include path that reaches into `Plugins/Angelscript/Source/AngelscriptTest`. That makes the extension plugin depend on the physical source layout instead of the module boundary and leaves future extension plugins without a clear pattern.

## Goals / Non-Goals

**Goals:**

- Treat `AngelscriptTest` as the supported helper provider for Angelscript extension plugin test modules.
- Define a curated public helper surface that covers the current GAS binding and functional test usage.
- Remove the GAS test module's hardcoded source include workaround.
- Update test documentation so helper include paths match the actual repository layout.

**Non-Goals:**

- Do not create a separate `AngelscriptTestSupport` module in this change.
- Do not move or rename existing helper headers.
- Do not make every `AngelscriptTest` helper or fixture part of the stable external API.
- Do not rewrite existing GAS tests unless they fail after the dependency cleanup.

## Decisions

- Keep `AngelscriptTest` as the reusable test helper module. A separate support module would create a cleaner long-term split, but it would also require moving exported symbols and reshaping dependencies before there is enough evidence that the existing module boundary is insufficient.
- Use documented include prefixes instead of new wrapper headers for this change. Existing consumers already include `Shared/...` helper headers, and `PublicIncludePaths.Add(ModuleDirectory)` supports that style.
- Define the supported surface as a curated contract: macros, engine helper, binding coverage/build/assertion helpers, functional/world helpers, reflection access, global function invocation, and native SDK adapter helpers. Specialized debugger, learning, performance, StaticJIT, and internal fixture helpers remain internal unless promoted by a later change.
- Validate the contract through `AngelscriptGASTest` because it is the first extension test module currently using `AngelscriptTest` helpers and the only known module with a hardcoded source include workaround.

## Risks / Trade-offs

- A documented public surface inside an existing broad include root still permits accidental use of internal headers. Mitigation: document supported headers explicitly and use search checks to prevent extension modules from adding source-path workarounds.
- Some documented helper headers may rely on private include assumptions when compiled from an external module. Mitigation: prefer minimal build-rule fixes in `AngelscriptTest` over restoring downstream source paths.
- Keeping one module avoids churn now but leaves runtime/editor/test-support separation less precise than a dedicated support module. Mitigation: record `AngelscriptTestSupport` as a future option only if more extension consumers need a smaller dependency surface.

## Migration Plan

- Update documentation and build rules in one compatible change.
- Remove only the downstream workaround from `AngelscriptGASTest`; keep the `AngelscriptTest` module dependency.
- Run a full editor build and the `Angelscript.GAS.` automation prefix to verify that the extension module still compiles and its tests can consume the documented helpers.
- Roll back by restoring the GAS private include path if validation proves a helper dependency cannot be made public safely within this change.
