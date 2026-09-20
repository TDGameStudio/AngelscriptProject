# Why GetModule was removed

Source: local draft finding `getmodule-why-removed.md`. Provenance: `openspec/archive/changes/angelscript/2026-09-08-refactor-language-surface-ue-focused`.

## Who removed it

Task 2.2 of `2026-09-08-refactor-language-surface-ue-focused`, not the 09-12 compile-lifecycle Change. 09-12 only reused “the public compile entry is already gone”. The 09-17 ClassGen Change said “do not restore GetModule” to avoid bringing the **old compile factory** back inside a bind helper.

## Three jobs were cut as one SDK surface

Public “module management” was deleted as one policy slice:

1. **Script-owned module policy** — `shared` / `external`, `IsShared` / `SetShared`, owner reassignment. Engine selects source/module membership; scripts do not declare sharing.
2. **Mutable legacy provenance** — `Type.GetModule()`, `Function.GetModuleName()`, module pointer as type identity. Replaced by stable source/definition keys. Provenance must not expose a mutable legacy module object.
3. **Old compile entry** — `GetModule(name, ALWAYS_CREATE)` created an empty `asCModule`, then `AddScriptSection` / `Build` / `ImportModule`. New compile is Engine-free Builder.

The same design said: **do not delete the `asCModule` class** because it is named Module. Keep it for dormant boundaries; keep it off the replacement public surface.

`NativeEngine.Compile.SDK` locked the cut with `ModuleManagementAndMutableProvenanceAreAbsent`, `PublicModuleCompilationAndImportsAreAbsent`, and no `GetModule` on Engine.

## Not the same as the restore now

Removed: `GetModule` = create + compile + provenance pointer.

Wanted now: after Register, look up an existing `asCModule` by name. No flag. No `Build`.
