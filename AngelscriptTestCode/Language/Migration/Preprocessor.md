# Preprocessor migration

| FileTag | Disposition | Legacy sources |
| --- | --- | --- |
| `Language/Preprocessor/IfElifElse` | adapted language forms; host observers excluded | `TestSource-old/Language/Preprocessor/Function/EditorConfigurationFlagBranch.as`; `TestSource-old/Language/Preprocessor/Function/IfElifElseEndifBranches.as` |
| `Language/Preprocessor/DirectiveInString` | adapted language forms; host observers excluded | `TestSource-old/Language/Preprocessor/Function/StringLiteralDoesNotTriggerDirectiveLexer.as` |

## Theme exclusions

- Dropped `UFUNCTION` Observe helpers, namespace test wrappers, and UE types (`FString`, `FQuat`, `UEnum`, `TArray`).
- Reject files that only encode host diagnostics stay excluded; language-illegal forms are `invalid-*` children of `root`.
- Preprocessor and comment-literal versions may carry `SourceOnly`; admission is not compilation.
