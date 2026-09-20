# Second-wave Language theme pockets

The accepted exploration contract is [attachments/drafts/design.md](attachments/drafts/design.md). Names are in [attachments/drafts/glossary.md](attachments/drafts/glossary.md).

## Goals / Non-Goals

**Goals:** admit Auto, Class, Inheritance, Destructors, Typedef, and Mixin as theme pockets with CompileFail siblings; merge existing ClassDeclarationCompileFail overlap; project and list them.

**Non-Goals:** Unreal root; Bindings leftovers; first-wave thickening; parser changes; language execution.

## Decisions

Each theme is one positive FileTag `Language/<Theme>` plus `Language/<Theme>CompileFail`. Author path is `AngelscriptTestCode/Language/<Theme>.as`. Cases use `@begin` and parentless `AddVersion`. Class/Inheritance negatives that already live in `Language/Syntax/ClassDeclarationCompileFail` move once.

## Call chains

authored `AngelscriptTestCode/Language/<Theme>.as`
→ `discover_sources` skips `Pending/` (`discovery.py:59`)
→ `parse_source_file` (`container_parser.py:243`)
→ `codegen.py generate` writes `TestCode/Generated/Language/<Theme>.generated.cpp`
→ `FAngelscriptTestCodeRegistration` → `FAngelscriptTestCode::Get` / `FindFiles` (`AngelscriptTestCode.h:26-33`)

Measured at: f68cf60f

dirty: yes; parent working tree already had unrelated edits. Today `discover_sources` already admits any non-Pending `.as`. `LanguageFixtureCorpusTests.cpp:334` only asserts `Language/Casting/ClassHandleCast`.
