## Context

Language admission already exists. Second-wave themes live as six flat FileTags. First-wave theme directories exist, but 35 of 53 positives have five or fewer `@begin` cases. Live frontend syntax is the coverage authority: `as_token_kinds.def` and `frontend/Parser/*`, not leftover `as_tokendef.h` `tokenWords`. This Change thickens, splits, and adds those live claims. It does not compile or execute AngelScript.

Measured at: `9ec12a734400cf36e4841e7f0fc42721142edf16`.

The working tree is dirty with unrelated Pending Bindings leftovers and other files. Those paths are not in this Change.

## Goals / Non-Goals

**Goals:**

- Per-syntax chapter directories for Auto, Class, Inheritance, Typedef, Mixin, Destructors.
- Every first-wave positive with ≤5 `@begin` cases thickened; mashups split.
- Hand-author `Language/Interface/`, `Language/Delegate/`, `Language/Event/`, and `Language/Syntax/FunctionModifiers`.
- Fold live-frontend gaps into the same Task DAG: drop illegal local `auto&` and class-level `final`; add `protected`, `access`, interface extends/multiple, `**`/`>>>`/`^^` and bitwise assigns, `fallthrough;`, `foreach` keyword, heredoc `"""`, handle/foreach-key `auto`, and live spellings `nullptr` / `Cast<>`.
- Update generate, language-fixtures, Skill, Migration, corpus.
- Author chapters may run in parallel; one generate join and one corpus join.

**Non-Goals:**

- Removed syntax: import, asset, funcdef, template, coroutine, shared/external, `property` decorator.
- Leftover spellings: `null`, lowercase `cast<>`, `is`/`!is`, word and/or/not.
- Pending Properties, FString literals, Syntax/EdgeCases, UClass.
- Python-generated authors, mashup generators, or any batch author script.
- Reopening `feature-language-second-wave-fixtures` design.
- Compile or execute AngelScript as an admission gate.

## Decisions

1. Grain is coverage, not one rule. A syntax becomes a directory when several independently named claims remain after thickening. A thin leftover may stay one file.
2. `invalid-auto-without-initializer` and foreach-auto belong to Auto. Ordinary `get_Value()` belongs to Class. Strings leave Variables for Syntax.
3. `interface` is a first-class chapter. Function modifiers (`local`, `access`) live under Syntax.
4. `delegate` and `event` are live callable types via `ParseCallableDeclaration`. They get parallel task 7.2 as `Language/Delegate/` and `Language/Event/`. `funcdef` stays out.
5. The live frontend is the coverage authority. Local `auto&` is rejected by the parser and is not a Qualifiers claim. Class-level `final` is not a ParseRecord claim; method `final` stays.
6. Implementers hand-write every `@begin` after reading the matching lexer/parser site. `codegen.py generate/check` is a projection of authors, never an authoring step.
7. One Change. Chapter author tasks have empty `depends_on`. Tasks 12.1, 12.2, and 13.1 join after 1.1–11.1 and 7.2.

## Call chains

Parser discovery walks every non-Pending `.as` under the author root:

`discover_sources` (`CodeGenTool/angelscript_test_codegen/discovery.py:46`)
-> `parse_source_file` (`CodeGenTool/angelscript_test_codegen/container_parser.py:243`)
-> FileTag = posix path without `.as`

Runtime catalog serves those FileTags:

`FAngelscriptTestCode::Get` (`Plugins/Angelscript/Source/AngelscriptTest/Framework/Catalog/AngelscriptTestCode.h:26`)
-> `FindFiles` (`Plugins/Angelscript/Source/AngelscriptTest/Framework/Catalog/AngelscriptTestCode.h:31`)
-> `LanguageFixtureCorpusTests.cpp`

Authoring inspects the live frontend, then writes the pocket by hand:

`as_token_kinds.def` / `frontend/Parser/*`
-> handwritten `AngelscriptTestCode/Language/<Chapter>/*.as`
-> chapter pytest (`tests.test_language_*_authors`)

Generate is a projection of authors, not an authoring step:

`python -m angelscript_test_codegen generate --check`
-> `Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/`

Chapter author tests stay disjoint so parallel tasks do not share one pytest file.

Measured at: 9ec12a734400cf36e4841e7f0fc42721142edf16
dirty: unrelated Pending Bindings leftovers and other files not owned by this Change

## Risks / Trade-offs

- Parallel authors can invent colliding FileTags. Mitigation: glossary plus per-chapter exclusive trees.
- Corpus can stay green on stale flats if generate is skipped. Mitigation: 12.1 is the join; 13.1 asserts chapter FileTags and rejects retired flats.
- Agents may treat move-as-done or generate authors with a script. Mitigation: every author card lists required `@begin` names and requires a frontend inspect note; Python author generation is a global constraint.
- Super has no frontend parse today. Mitigation: keep Super as an admission corpus; do not invent a class-level `final` Fail that the parser cannot reject.

## Migration Plan

Delete flat `Language/<Theme>.as` only after the chapter positives exist. Update Migration notes and Skill examples in 12.2. No production runtime migration.

## Open Questions

None. Approval_round R8 closed the handoff. Talk `talk-20260917-094513-live-frontend-handwrite-171592` settled the live-frontend and hand-write corrections.
