# Planning validation

Date: 2026-09-17. Change: angelscript/feature-module-register-identity.

## Coverage

ADDED type-registry requirements (per-file `asCModule` at Register, name-only lookup) map to 2.1 and 1.1. MODIFIED builder CompileOutput `ScriptModule` null-until-Register maps to 2.1. Empty-engine and factory-absent conditions map to 1.1.

## Placeholder scan

`tasks.md`, `proposal.md`, root `design.md`, and both spec deltas contain none of: TBD, TODO, implement later, fill in details, add appropriate error handling, write tests for the above.

## Symbol consistency

Lookup is `asIScriptEngine::GetModule(const char* name) const`, `GetModuleCount`, `GetModuleByIndex` from `attachments/drafts/glossary.md`. Register overload is `Register(Sets, Output)` from the seeded design. Host `FAngelscriptEngine::GetModule` stays `ModuleDesc`. Test identities stay under `Angelscript.UnitTest.NativeEngine.Compile`.
