# Container type directories

Draft-backed Change from `angelscript/container-fixture-coverage` scope `container-pocket-rewrite` (approval R6). Destination names: [attachments/drafts/glossary.md](attachments/drafts/glossary.md). Author rules: [attachments/drafts/findings/authoring-standard.md](attachments/drafts/findings/authoring-standard.md).

## Goals / Non-Goals

**Goals:** admit nine container types as `Containers/<Type>/<Observation>` authors with CompileFail/RuntimeFail subdirectories, project them, and query them by prefix.

**Non-Goals:** Language, Unreal first-batch, `Math/`, Pending dumps, conversion scripts, compile or execute AngelScript.

## Decisions

- One directory per type. One parentless `@begin` per file. Leaf is lengthened Pascal without a type prefix.
- Nine type author tasks have no inter-type edges. Spec and corpus sit on a join after generate.
- Trees follow each bind surface. TMap missing-key `[]` throws. Fail directories exist only with Bind evidence.

## Call chains

hand-written `AngelscriptTestCode/Containers/TArray/AddAndOrder.as`
→ `discover_sources` (`discovery.py:46`)
→ `parse_source_file` (`container_parser.py:243`)
→ `codegen.py generate` writes `TestCode/Generated/Containers/TArray/AddAndOrder.generated.cpp`
→ `FAngelscriptTestCode::Get` (`AngelscriptTestCode.h:26`)
→ `HostApiFixtureCorpus` (`HostApiFixtureCorpusTests.cpp:12`)

Measured at: 9ec12a73

dirty: yes; parent tree already has Language, Unreal, host-api, and pending-math admissions plus untracked Pending/Bindings leftovers.
