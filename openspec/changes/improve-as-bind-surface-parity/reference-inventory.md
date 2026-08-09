# UnrealCSharp Reference Inventory

## Status

This is a seed catalogue for `improve-as-bind-surface-parity`. It records a local source observation, not an API compatibility promise and not a list of confirmed AngelScript gaps.

## Reference snapshot

- Reference repository: `Reference/UnrealCSharp`.
- Hand-authored interop providers: `Script/UE/Private/Domain/Interop/FRegister*.cpp`.
- Snapshot count: 58 provider files, approximately 946 registered functions, 394 properties, and 90 constructors.
- These totals are discovery data only. They must not be compared directly with the AngelScript `Bind_*.cpp` file count because AngelScript separates providers by concern and also exposes reflected and template-driven APIs.

## Normalization rules

Before a member is considered absent, the audit must check whether AngelScript exposes it through:

1. a script instance method instead of a C# static method, or the reverse;
2. an operator, constructor, global helper, `FMath` helper, or differently named script alias;
3. reflected UFunction/UProperty registration;
4. a generic/template binding that intentionally owns the surface; or
5. an equivalent Unreal Engine operation with a more appropriate AngelScript signature.

For example, UnrealCSharp's `FRegisterString.cpp` and `FRegisterText.cpp` contain basic lifecycle and conversion registrations; they do not establish that every C# string-formatting operation needs a manual counterpart. AngelScript already has dedicated `FString` format and apply-format bindings, so that family is not a known formatting gap from this comparison.

## Candidate family waves

| Wave | Families to audit first | Reason for ordering |
| --- | --- | --- |
| Foundation geometry | `FVector`, `FVector2D`, `FVector4`, `FPlane`, `FQuat`, `FRotator`, `FTransform` | High script usage; aliases and operator forms make normalization especially valuable. |
| Foundation utility values | `FColor`, `FLinearColor`, `FDateTime`, `FTimespan`, `FGuid`, `FRandomStream` | Common gameplay and tooling types with compact, independently testable candidate APIs. |
| Generic and object wrappers | arrays/maps/sets, optional, class/object/function/struct, soft/weak/lazy pointers, paths | Many entries may already be covered by templates or reflection and need classification before implementation. |
| Dependency-driven specialty types | ranges/intervals, frame types, `FMatrix`, `FBox2D`, asset bundle and polyglot text data | Audit only after a concrete script need or a clear engine-supported binding path is established. |

## Initial observations to verify in the matrix

- `FVector` comparisons must account for existing constructors, operators, constants, instance methods, and `FMath` helpers before considering vector helpers missing.
- The C# catalogue includes color conversion, date/time factory and parsing, GUID parsing/generation, quaternion/rotator interpolation, transform, and random-stream helpers. Each is only a candidate until equivalent AngelScript coverage and script usefulness are established.
- C# has provider families for `FBox2D`, `FMatrix`, ranges/intervals, frame values, asset bundles, and polyglot text data. Their absence from an AngelScript explicit provider would not by itself prove an API gap: dependencies, reflection, template coverage, and intended module boundaries must be examined first.
