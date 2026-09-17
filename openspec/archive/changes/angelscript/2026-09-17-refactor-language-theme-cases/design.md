# Language theme pockets

The accepted exploration contract is [attachments/drafts/design.md](attachments/drafts/design.md). Names are in [attachments/drafts/glossary.md](attachments/drafts/glossary.md).

## Goals / Non-Goals

**Goals:** several parentless cases per FileTag; Fail file split; optional Family; function headers; Skill and spec retarget; all Language author files.

**Non-Goals:** generator products; diagnostic oracles; Pending non-Language corpora; database execution.

## Decisions

Parentless versions use `AddVersion` with an empty Parent. `AddRoot` remains only as a compatibility wrapper that forwards to that path, or is removed from Language projections once no caller needs it. A Tag spelled `root` has no privilege.

Cases open with `@begin`. Function contracts live on the function-header block. Casting FileTags are the four glossary names. Other Language leaves stay; they gain `CompileFail` / `RuntimeFail` siblings when they have negatives.

## Call chains

authored `.as` -> Python `container_parser.parse` -> `FAngelscriptTestCodeBuilder.AddVersion` -> `Build()` -> `FAngelscriptTestCode.Get(FileTag, VersionTag)`

C++ test literal -> `FAngelscriptTestSourceParser.Parse` -> same Builder -> `Get`

Measured at: 493bd183

dirty: yes; parent working tree already had unrelated edits. Today `AngelscriptTestSourceParser.cpp` still calls `AddRoot` for the unique parentless node, and `AngelscriptTestCodeBuilder.cpp` emits `VersionParentRequired` / `RootMustUseAddRoot`.
