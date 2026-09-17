# Namespace migration

| FileTag | Disposition | Legacy sources |
| --- | --- | --- |
| `Language/Namespace/QualifiedName` | adapted language forms; host observers excluded | `TestSource-old/Language/Namespace/Function/NamespaceQualifiedCall.as`; `TestSource-old/Language/Namespace/Function/NamespaceQualifiedName.as` |
| `Language/Namespace/Nested` | adapted language forms; host observers excluded | `TestSource-old/Language/Namespace/Function/NamespaceNestedAccess.as`; `TestSource-old/Language/Namespace/Function/NamespaceNestedScope.as` |
| `Language/Namespace/GlobalVersusScoped` | adapted language forms; host observers excluded | `TestSource-old/Language/Namespace/Function/NamespaceGlobalVersusScoped.as`; `TestSource-old/Language/Namespace/Function/NamespaceScopedGlobal.as` |
| `Language/Namespace/Shadowing` | adapted language forms; host observers excluded | `TestSource-old/Language/Namespace/Function/NamespaceScopeShadowing.as` |
| `Language/Namespace/Enum` | adapted language forms; host observers excluded | `TestSource-old/Language/Namespace/Function/NamespaceWithEnum.as` |

## Theme exclusions

- Dropped `UFUNCTION` Observe helpers, namespace test wrappers, and UE types (`FString`, `FQuat`, `UEnum`, `TArray`).
- Reject files that only encode host diagnostics stay excluded; language-illegal forms are `invalid-*` children of `root`.
- Preprocessor and comment-literal versions may carry `SourceOnly`; admission is not compilation.
