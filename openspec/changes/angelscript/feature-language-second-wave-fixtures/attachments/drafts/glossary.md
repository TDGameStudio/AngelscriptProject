# Names (pending-coverage)

| term | chosen | rejected | reason |
|---|---|---|---|
| Change ID | `angelscript/feature-language-second-wave-fixtures` | `feature-testcode-language-second-wave` | Q28 |
| Positive FileTags | `Language/Auto` `Language/Class` `Language/Inheritance` `Language/Destructors` `Language/Typedef` `Language/Mixin` | one concern per file; `Language/Class/ThisKeyword` | Q26 one pair per theme |
| Fail siblings | same leaf plus `CompileFail` / `RuntimeFail` when needed | `Reject/` subdirectory | accepted Fail contract |
| Author path | `AngelscriptTestCode/Language/<Theme>.as` | remain in Pending | projection only after admission |
| Corpus method | `CorpusHasSecondWaveThemes` | new test class | neighbor `CorpusHasClassHandleCast` |

Shared pocket words (`@begin`, `@function`, `@summary`) stay as accepted in `theme-case-containers`.
