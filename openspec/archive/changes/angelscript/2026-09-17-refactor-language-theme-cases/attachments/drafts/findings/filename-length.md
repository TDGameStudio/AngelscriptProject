# Longer Casting pocket names

Source: exploration finding `filename-length.md` (Chinese). Q7=P2. Accepted for this Change at R20.

Rule: last path segment is PascalCase and states the language claim. Do not put generator `LANG-*` tokens in the path.

| Current | Positive FileTag | Fail siblings |
|---|---|---|
| `Language/Casting/ClassCast` | `Language/Casting/ClassHandleCast` | `ClassHandleCastCompileFail`, `ClassHandleCastRuntimeFail` |
| `Language/Casting/Nullptr` | `Language/Casting/NullHandle` | `NullHandleCompileFail`, `NullHandleRuntimeFail` |
| `Language/Casting/NumericImplicit` | `Language/Casting/NumericImplicitConversion` | matching CompileFail / RuntimeFail |
| `Language/Casting/NumericExplicit` | `Language/Casting/NumericExplicitConversion` | matching CompileFail / RuntimeFail |

Other one-word Language leaves (`If`, `Enum`, `Const`) keep their current names in this Change.
