# GetModule lookup is not the compile factory

Disposition: candidate

## Reusable Insight

`asIScriptEngine::GetModule` used to mean create-an-empty-module-then-compile. The 09-08 LanguageSurface cut removed that factory together with sharing policy and mutable provenance. A later lookup-only `GetModule(name)` after Register is a different API: it finds an `asCModule` that already exists.

## Evidence

Archive `2026-09-08-refactor-language-surface-ue-focused` task 2.2 and [getmodule-why-removed.md](../drafts/findings/getmodule-why-removed.md). `NativeEngine.Compile.SDK` still asserts the compile entry is absent.

## Boundaries

Does not authorize `AddScriptSection`, `Build`, or `ALWAYS_CREATE`. Does not authorize `Type.GetModule()` as public provenance.

## Application

When restoring module lookup or writing SDK tests, assert lookup presence and compile-entry absence as two separate facts.

## Sources

[getmodule-why-removed.md](../drafts/findings/getmodule-why-removed.md). Provenance: draft finding, log R8.
