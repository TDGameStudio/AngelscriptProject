# Why

`FAngelscriptEngineHooks` was a thin container struct that wrapped 19 delegate fields on `FAngelscriptEngine` and exposed them via `GetHooks()`. Audit confirmed it had **zero non-`GetHooks()` consumers** (no parameter passing, no stored references, no separate include site beyond `AngelscriptEngine.h` itself), so the struct existed purely as a stylistic indirection. Removing it eliminates 133 redundant `Engine.GetHooks().` prefixes across 30 files without losing any encapsulation property.

# What Changes

- Delete `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.{h,cpp}` entirely
- Inline the 19 delegate fields and their `Get*()` accessors directly onto `FAngelscriptEngine`
- Move 13 `DECLARE_*_DELEGATE_*` macros, `EnumNameList` typedef, and 9 forward declarations from the deleted hooks header into `AngelscriptEngine.h` (alongside the existing forward-decl block)
- Replace 133 call sites: `Engine.GetHooks().GetOnXxx()` → `Engine.GetOnXxx()` (mechanical text substitution; verified by grep)
- Update `as-engine-owned-hooks` spec calling-pattern requirement: `FAngelscriptEngine::Get().GetHooks().GetOnXxx()` → `FAngelscriptEngine::Get().GetOnXxx()`

No new capability; no requirement change other than the calling-pattern surface. The 8 reload hooks added by `refactor-as-runtime-deglobalize-completion` remain present and per-engine — only the access path is simplified.

# Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `as-engine-owned-hooks`: hook accessors are now direct members of `FAngelscriptEngine` rather than reached via a separate `FAngelscriptEngineHooks` container struct. The "engine-owned" property is unchanged; only the syntactic access path changes.

# Impact

- **Code**: 30 files in `Plugins/Angelscript/Source/{AngelscriptRuntime,AngelscriptEditor,AngelscriptTest}/`. All changes mechanical except `ClassReloadHelper.h` and `AngelscriptHotReloadMultiEngineHooksTests.cpp` which had local `FAngelscriptEngineHooks&` reference variables that needed elimination (inlined the engine accessor at each subscription site instead).
- **API**: `FAngelscriptEngineHooks` type and `Engine.GetHooks()` method removed. No external plugin (AngelscriptGAS, AngelscriptGameplayTags) used either; verified.
- **Spec**: `as-engine-owned-hooks` calling-pattern segment updated; no requirement semantics changed.
- **Header size**: `AngelscriptEngine.h` grew ~80 lines (1,442 → ~1,520) absorbing the macros/typedefs/fields; this is a known trade-off accepted in exchange for removing the wrapper.
- **Build/test**: Verified via Smoke/RuntimeCpp/Bindings/HotReload/Engine prefix; `GetHooks()` and `FAngelscriptEngineHooks` greps both zero in plugin source.
