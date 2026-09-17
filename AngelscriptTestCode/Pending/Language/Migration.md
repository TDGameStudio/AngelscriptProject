# Pending Language wave

Host-free declaration families that the admitted 47 FileTags do not own as standalone containers. Class casts already live under `Language/Casting/ClassCast`; these files keep the type-system concern itself.

| Pending FileTag | Disposition | Legacy / generator anchors |
| --- | --- | --- |
| `Language/Syntax/Class` | authored host-free class, this, constructor | `TestSource-old/Language/Syntax/Keywords/Reject/ThisOutsideClass.as`; `TestSource-old/Language/Syntax/EdgeCases/Reject/DuplicateClassName.as`; `TestSource-old/Language/Syntax/EdgeCases/Reject/ClassWithoutName.as` |
| `Language/Syntax/Inheritance` | authored override, super, final | `TestSource-old/Language/Syntax/Keywords/Reject/InheritFromFinalClass.as`; `TestSource-old/Language/Syntax/Keywords/Reject/OverrideWithoutParentMethod.as`; `TestSource-old/Language/Syntax/Keywords/Reject/SuperOutsideClass.as`; `LANG-INH-DISPATCH` |
| `Language/Syntax/Destructors` | authored declared destructors | `LANG-DTOR-DECLARATION` |
| `Language/Syntax/Typedef` | authored typedef aliases | `LANG-DECL-FAMILY-SCOPE-ORDER` typedef branch |
| `Language/Syntax/Properties` | authored get_/set_ virtual properties | `LANG-PROP-ACCESSOR` |

AActor / UFUNCTION / FString observers stay excluded. Promotion into `Language/` is a later plugin-projection step.
