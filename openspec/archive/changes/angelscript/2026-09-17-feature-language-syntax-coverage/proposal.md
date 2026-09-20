## Why

Admitted Language already has theme directories for ControlFlow and Syntax, but second-wave themes sit in six flat files and 35 of 53 positive files have five or fewer `@begin` cases. Several cases mashup a whole family. Live frontend syntax (`interface`, `delegate`, `event`, `access`, `protected`, `**`, `>>>`, `^^`, `fallthrough`, `foreach`, heredoc, `nullptr`, `Cast<>`) is missing or spelled from the leftover frontend. Coverage is thin; file count is not.

## What Changes

- Rewrite Auto, Class, Inheritance, Typedef, Mixin, and Destructors as per-claim chapter directories and retire flat `Language/<Theme>` FileTags.
- Thicken every first-wave positive with ≤5 `@begin` cases. Split mashup claims. Add the live-frontend gaps listed above.
- Hand-author `Language/Interface/`, `Language/Delegate/`, `Language/Event/`, and `Language/Syntax/FunctionModifiers`.
- Implementers inspect `frontend/Lexer/as_token_kinds.def` and `frontend/Parser/*` while writing each body. Do not generate author `.as` with Python or any batch author script.
- Update language-fixtures, Skill examples, Migration, projections, and `LanguageFixtureCorpus`.
- Author chapters may run in parallel. One generate and one corpus join close the Change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/language-fixtures`: inventory uses chapter FileTags such as `Language/Auto/InferFromLiteral`, `Language/Interface/Declare`, and `Language/Delegate/Declare`. Flat `Language/Auto` through `Language/Mixin` are not representative FileTags.

## Impact

Parent repository: `AngelscriptTestCode/Language/**`, CodeGenTool chapter tests, angelscript-test Skill, language-fixtures spec, Migration notes.
Plugin submodule: `TestCode/Generated/Language/**`, `LanguageFixtureCorpusTests.cpp`.

## Non-goals

Removed syntax (import, asset, funcdef, template, coroutine, shared/external, `property` decorator). Leftover spellings (`null`, lowercase `cast<>`, `is`/`!is`, word and/or/not). Pending Properties, FString literals, Syntax/EdgeCases, UClass. Python-generated authors. Reopening `feature-language-second-wave-fixtures`. Compile or execute AngelScript.
