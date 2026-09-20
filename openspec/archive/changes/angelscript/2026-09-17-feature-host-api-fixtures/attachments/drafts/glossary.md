# Names (container-home)

Source draft: `openspec/drafts/angelscript/language-fixture-quality/designs/container-home/glossary.md` (Chinese original; approval R29 / Q32–Q36).

| term | chosen | rejected | reason |
|---|---|---|---|
| Change ID | `angelscript/feature-host-api-fixtures` | `feature-container-fixtures` | Q36: covers T* and FMath/FString/AActor |
| Value-container root | `AngelscriptTestCode/Containers/` | `Unreal/Containers/`; revive Bindings | Q32 |
| FileTag prefix (T*) | `Containers/` | `Language/`; `Bindings/` | Host parameterized types, not core language |
| Non-T* root | `AngelscriptTestCode/Unreal/<Type>` | dump everything under `Containers/`; add `Library/` | Q35=A |
| Spec capability (convention) | `angelscript/testing/host-api-fixtures` | `testing/container-fixtures` | Same family as the Change ID; Ensure plan may split inventories |

Shared topic words stay in the local draft glossary; this export is the scoped name set.
