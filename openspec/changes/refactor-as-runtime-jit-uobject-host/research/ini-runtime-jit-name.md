# INI-configurable Runtime JIT name

Recorded: 2026-08-18. User request: each JIT has a name; Settings/INI selects the Runtime JIT when that name is registered.

## Names

Each `UAngelscriptRuntimeJIT` subclass exposes:

| Field | Role | Example |
| --- | --- | --- |
| `GetBackendId()` | Stable ini token, lowercase ASCII, unique | `angelsea-mir`, `angelsea-llvm` |
| `GetDisplayName()` | Editor/diagnostics only, not matched in ini | `Angelsea MIR` |

Do not add `GetName()` for this; `UObject::GetName()` already returns the instance/class name.

INI MUST store BackendId, never DisplayName (spaces, localization). `none` and empty string both mean “no Runtime JIT”.

## Settings home

Put the fields on existing `UAngelscriptSettings` (`Config=Engine, DefaultConfig`), not a second settings class. That section already appears under Project Settings → Plugins → Angelscript.

```ini
[/Script/AngelscriptRuntime.AngelscriptSettings]
; Dispatch + auto-warm. Empty or none = VM/AOT only.
RuntimeJITName=angelsea-mir
; Optional extra warm backends for switch/compare. Do not have to include RuntimeJITName.
+RuntimeJITWarmNames=angelsea-llvm
```

Suggested UPROPERTY:

- `FString RuntimeJITName` — Config, EditDefaultsOnly, Category Runtime JIT, `GetOptions` from registered names
- `TArray<FString> RuntimeJITWarmNames` — optional extras
- Empty defaults

Command line `-as-runtime-jit-backend=` overrides `RuntimeJITName` for that process.

## If the named JIT is not registered

Do not fail Engine init. Log a configuration diagnostic naming the missing BackendId. Primary Engine stays VM/Static AOT. When the plugin later loads and that BackendId is already `RuntimeJITName` / `RuntimeJITWarmNames` (after CLI) or already requested live on the primary Engine, apply at the next safe point — do not wait for editor restart. Catalog rebuild still MUST NOT warm a newly appeared backend that nothing has named. Same missing-name diagnostic if the class is present but `IsAvailable()` is false.

Test Engines ignore `UAngelscriptSettings::RuntimeJITName` unless they opt in; they keep passing `FAngelscriptJITCoordinatorConfig`.
