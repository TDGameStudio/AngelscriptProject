# Admit host API fixtures

The accepted exploration contract is [attachments/drafts/design.md](attachments/drafts/design.md). Names are in [attachments/drafts/glossary.md](attachments/drafts/glossary.md).

## Goals / Non-Goals

**Goals:** admitted `AngelscriptTestCode/Containers/`; T* plus SoftObjectPath plus Pending/Containers rewritten as pockets; remaining Bindings types under `Unreal/<Type>`; projections and a host-api-fixtures inventory.

**Non-Goals:** Language six themes; Unreal first-batch UClass+World source list; compile or run container programs; revive `Bindings/`.

## Decisions

FileTag prefix for value containers and pointers is `Containers/`. Non-T* Bindings folders use `Unreal/<Type>`. Capability id is `angelscript/testing/host-api-fixtures`. Per-type grain is one positive pocket plus CompileFail and RuntimeFail when that polarity exists.

## Call chains

authored `AngelscriptTestCode/Containers/TArray.as`
→ `discover_sources` skips only `CodeGenTool/` and `Pending/` (`discovery.py:59`)
→ `parse_source_file` (`container_parser.py:243`)
→ `codegen.py generate` writes `TestCode/Generated/Containers/TArray.generated.cpp`
→ `FAngelscriptTestCode::Get` / `FindFiles` (`AngelscriptTestCode.h:26-33`)

The same chain applies to `AngelscriptTestCode/Unreal/FMath.as` with prefix `Unreal/`.

Measured at: 9ec12a734400cf36e4841e7f0fc42721142edf16

dirty: yes; parent working tree already had unrelated edits. No `Containers/` author root exists today. Discovery will pick it up as soon as `.as` files land outside Pending.
