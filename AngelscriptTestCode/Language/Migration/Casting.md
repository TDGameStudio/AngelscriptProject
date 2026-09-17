# Casting migration

| FileTag | Disposition | Legacy sources |
| --- | --- | --- |
| `Language/Casting/NumericImplicit` | adapted language forms; host observers excluded | `TestSource-old/Language/Casting/Function/ImplicitBoolToInt.as`; `TestSource-old/Language/Casting/Function/ImplicitDerivedToBase.as`; `TestSource-old/Language/Casting/Function/ImplicitFloatToInt.as`; `TestSource-old/Language/Casting/Function/ImplicitFloatToUint8.as`; `TestSource-old/Language/Casting/Function/ImplicitInt64ToInt.as`; `TestSource-old/Language/Casting/Function/ImplicitIntToFloat.as`; `TestSource-old/Language/Casting/Function/ImplicitIntToInt64.as`; `TestSource-old/Language/Casting/Function/ImplicitLiteralToFloat.as`; `TestSource-old/Language/Casting/Function/ImplicitUint8ToInt.as`; `TestSource-old/Language/Casting/Function/NumericEnumAndStringConversions.as` |
| `Language/Casting/NumericExplicit` | adapted language forms; host observers excluded | `TestSource-old/Language/Casting/Function/ExplicitFloatToInt.as`; `TestSource-old/Language/Casting/Function/ExplicitIntToFloat.as`; `TestSource-old/Language/Casting/Function/ExplicitIntToUint8.as` |
| `Language/Casting/Nullptr` | adapted language forms; host observers excluded | `TestSource-old/Language/Casting/Function/CastNullptrIsNull.as`; `TestSource-old/Language/Casting/Function/NullptrComparison.as`; `TestSource-old/Language/Casting/Function/NullptrHandleAssignment.as` |
| `Language/Casting/ClassCast` | adapted language forms; host observers excluded | `TestSource-old/Language/Casting/Function/CastDowncast.as`; `TestSource-old/Language/Casting/Function/CastRoundTripWithNullCheck.as`; `TestSource-old/Language/Casting/Function/CastToParentClass.as`; `TestSource-old/Language/Casting/Function/ImplicitDerivedToBase.as` |

## Theme exclusions

- Dropped `UFUNCTION` Observe helpers, namespace test wrappers, and UE types (`FString`, `FQuat`, `UEnum`, `TArray`).
- Reject files that only encode host diagnostics stay excluded; language-illegal forms are `invalid-*` children of `root`.
- Preprocessor and comment-literal versions may carry `SourceOnly`; admission is not compilation.
