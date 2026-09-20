# Restore lookup GetModule and generate one shell per .as

## Context

ClassGen needs `ModuleDesc->ScriptModule`. The new pipeline compiles `asCDefinitions` without creating `asCModule`. The 09-08 SDK cut removed `GetModule` as part of module-management deletion.

## Evidence

AskQuestion Q1 = runtime identity after Register; Q3 = lookup only; Q4 = public `asIScriptEngine`; N1 = `feature-module-register-identity`; N2 = `GetModule(name)` with no flags. User: each `.as` is a module, so generate it; no need to fully separate Engine and Module. Draft log R4–R7.

## Options

Restore compile factory (`AddScriptSection` / `Build` / `ALWAYS_CREATE`) versus lookup only. Engine-free `asCModule` versus birth at Register with Engine. Public SDK versus host-only `ScriptModule`.

## Settled Decision

Compile stays on `asCDefinitions`. At Register, `new asCModule(name, engine)` per ModuleDesc. Restore `GetModule(const char* name) const`, `GetModuleCount`, `GetModuleByIndex`. Do not restore the compile entry or `Type.GetModule()`.

## Consequences

`NativeEngine.Compile.SDK` must allow lookup and still forbid `AddScriptSection` / `Build`. Host `FAngelscriptEngine::GetModule` remains a `ModuleDesc` lookup.

## Flip Condition

Restore `GetModule(name, flags)` only if a compiled caller still requires `asEGMFlags`. That enum is already gone.

## Visual

See [register-module-flow.md](../drafts/findings/register-module-flow.md).

## Sources

[glossary](../drafts/glossary.md), [handoff](../drafts/handoff.md). Provenance: draft log R4–R7.
