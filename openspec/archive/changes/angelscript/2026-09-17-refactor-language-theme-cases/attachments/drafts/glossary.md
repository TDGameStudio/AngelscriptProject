# Names (theme-case-containers)

Source: draft `designs/theme-case-containers/glossary.md`. Approval: R20.

| term | chosen | rejected | reason |
|---|---|---|---|
| Change ID | `angelscript/refactor-language-theme-cases` | `improve-language-fixture-quality` | Container topology and file splits are a `refactor` |
| Case open | `@begin <tag>` | `@tag` plus `@version <tag>` | Q12=B1 |
| Callable entry | `@function` | `@entry` / `UFUNCTION` | Q14 |
| Function description | `@summary` | `@description` / `@brief` | Q17; same word as file and case headers |
| Function contract placement | function-header block | case header only; AS comments only | Q15=C2 at approval |
| Language function fields | `@function` `@summary` `@inputs` `@return`, optional `@covers` | full Pending Kind table | Q16=D1 at approval |
| Fail file suffixes | `CompileFail` / `RuntimeFail` | `Negative` / `Reject` / single `Fail` | Q9 two Fail files; Q11 taken as the recommendation |
| Casting positive FileTags | `ClassHandleCast` `NullHandle` `NumericImplicitConversion` `NumericExplicitConversion` | current short leaves | Q7=P2; this Change lengthens only Casting |
| Other Language FileTags | keep the current leaf | lengthen the whole corpus | `If` / `Enum` wait for a later table |
| Positive VersionTag | kebab claim; no required `valid-` prefix | mandatory `valid-*` | `@begin` already carries identity |
| Negative VersionTag | `invalid-<kebab>` | a new scheme | Q4b=V2 |
| Parentless version API | ordinary `AddVersion` with no Parent | privileged `AddRoot` plus Tag `root` | `root` is no longer reserved |
