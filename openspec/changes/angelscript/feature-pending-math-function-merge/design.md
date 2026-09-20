# Complete Pending/Math Function merge

Direct-origin Change. Destination and FileTag names come from archived `angelscript/feature-host-api-fixtures`.

## Goals / Non-Goals

**Goals:** admit the 30 leftover Pending/Math Function programs as parentless `@begin` cases on existing `Unreal/FVector`, `Unreal/FVector2D`, `Unreal/FTransform`, `Unreal/FRotator`, and `Unreal/FLinearColor`.

**Non-Goals:** `AngelscriptTestCode/Math/`; FQuat rewrite; Bindings leftovers; compile or execute the Function programs.

## Decisions

Keep FileTags on the already admitted Unreal type pockets. Version tags are kebab-case Pending stems (`function-parameters-in`). Fail polarity is not present on these 30 files.

## Call chains

authored `AngelscriptTestCode/Unreal/FVector.as` (appended Function cases)
→ `discover_sources` (`discovery.py:46`)
→ `parse_source_file` (`container_parser.py:243`)
→ `codegen.py generate` writes `TestCode/Generated/Unreal/FVector.generated.cpp`
→ `FAngelscriptTestCode::Get` (`AngelscriptTestCode.h:26`)

Measured at: 9ec12a73

dirty: yes; parent tree already has Language second-wave, Unreal first-batch, and host-api admissions.
