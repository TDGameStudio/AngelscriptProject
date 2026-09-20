# How Language authors look today

Survey date: 2026-09-17. Authority is `AngelscriptTestCode/Language/**/*.as` and `Pending/Language/` on disk.

## Two contracts

FileTag is the path under `AngelscriptTestCode/` without `.as`. Changing the directory changes the public identity.

```
AngelscriptTestCode/Language
├─ Syntax/Variables.as              // FileTag Language/Syntax/Variables
├─ ControlFlow/If.as                // FileTag Language/ControlFlow/If
├─ Casting/ClassHandleCast.as
├─ Operators/Arithmetic.as
├─ Namespace/Nested.as
├─ Preprocessor/IfElifElse.as
├─ Auto.as                          // FileTag Language/Auto  — second-wave flat file
├─ Class.as
├─ Inheritance.as
├─ Destructors.as
├─ Typedef.as
└─ Mixin.as
```

First wave is already theme-directory plus slice files. Second-wave Change `feature-language-second-wave-fixtures` flattened six themes to `Language/<Theme>.as`. `Auto.as` (11 `@begin`) is that flat pocket.

## Admitted volume

| Theme directory or flat file | Author files | `@begin` |
|---|---:|---:|
| Syntax | 34 | 165 |
| Operators | 19 | 118 |
| ControlFlow | 18 | 99 |
| Casting | 9 | 43 |
| Class (flat) | 2 | 35 |
| Namespace | 10 | 29 |
| Typedef (flat) | 2 | 25 |
| Inheritance (flat) | 2 | 30 |
| Mixin (flat) | 2 | 18 |
| Destructors (flat) | 2 | 18 |
| Auto (flat) | 2 | 17 |
| Preprocessor | 4 | 16 |

About 106 admitted `.as` files and about 613 cases. `Language/Migration/` is not an author.

## Second-wave contract (do not reopen its design)

Active Change `angelscript/feature-language-second-wave-fixtures` finished four tasks. FileTags are flat `Language/Auto` names. Corpus tests assert those names. This Change retires those identities; it does not patch that Change's design.

## How second-wave entered from Pending

`Pending/Language/Auto/InferFromInt.as` still uses `@version root` and `@parent`. Admitted `Language/Auto.as` flattened int/float/bool/constructor into 11 parentless `@begin` cases. The six Pending Auto files are adapted, not missing.
