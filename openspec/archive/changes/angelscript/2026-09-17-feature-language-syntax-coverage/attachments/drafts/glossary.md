# Names

Source: draft `syntax-coverage` glossary. Approval: Q5, Q8. Translated from Chinese.

| term | chosen | rejected | reason |
|---|---|---|---|
| Change ID | `angelscript/feature-language-syntax-coverage` | several Change IDs | Q5; Q8 keeps one Change |
| Capability | `angelscript/testing/language-fixtures` (MODIFIED) | a new inventory | still the Language author catalog |
| Auto slices | `Language/Auto/InferFromLiteral` `InferFromCall` `InferInLoop` `Qualifiers` | flat `Language/Auto` | Q1; Auto has several claims after thickening |
| Class slices | `Language/Class/Constructor` `Fields` `Methods` `Access` `This` | one `Language/Class.as` | 547 lines / 22 cases already mashup |
| Interface | `Language/Interface/Declare` `Implement` `Handle` | `Language/Syntax/Interface` | live keyword, several claims |
| Delegate / Event | `Language/Delegate/Declare` `Language/Event/Declare` | `funcdef` | live `ParseCallableDeclaration`; leftover `funcdef` stays out |
| local / access | `Language/Syntax/FunctionModifiers` | `Language/Class/LocalFunction` | `local` and `access` policy stay under Syntax |
| coverage authority | live `as_token_kinds.def` and `frontend/Parser/*` | leftover `as_tokendef.h` `tokenWords` | author bodies follow the live frontend |
| Fail suffix | slice name + `CompileFail` | one theme-wide Fail | first-wave contract |
| Corpus query | prefixes such as `Language/Auto/` | exact `Language/Auto` | flat names retire |

Unlisted slice leaves are named in the owning task. Apply derives a same-directory Pascal/theme token and records `Naming assumed`.
