# Admitted Unreal root

The accepted exploration contract is [attachments/drafts/design.md](attachments/drafts/design.md). Names are in [attachments/drafts/glossary.md](attachments/drafts/glossary.md).

## Goals / Non-Goals

**Goals:** admitted `AngelscriptTestCode/Unreal/`; first-batch pockets for 124 UClass files plus World; projections and an Unreal inventory.

**Non-Goals:** Language six themes; 580 Bindings leftovers; compile or run World stories.

## Decisions

FileTag prefix is `Unreal/`. First-batch leaves are the glossary pocket list. EdgeCases/UClass 89 files split into Casting, GarbageCollection, Input, Events, Reflection, and ActorClass. Capability id is `angelscript/testing/unreal-fixtures`.

## Call chains

authored `AngelscriptTestCode/Unreal/<Pocket>.as`
→ `discover_sources` skips only `CodeGenTool/` and `Pending/` (`discovery.py:59`)
→ `parse_source_file` (`container_parser.py:243`)
→ `codegen.py generate` writes `TestCode/Generated/Unreal/<Pocket>.generated.cpp`
→ `FAngelscriptTestCode::FindFiles({Unreal})` / `Get` (`AngelscriptTestCode.h:26-33`)

Measured at: f68cf60f

dirty: yes; parent working tree already had unrelated edits. No `Unreal/` author root exists today. Discovery will pick it up as soon as `.as` files land outside Pending.
