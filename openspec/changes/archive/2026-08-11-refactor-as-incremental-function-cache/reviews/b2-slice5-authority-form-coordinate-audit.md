# B2 Slice 5 authority legal-form/captured-coordinate audit

Date: 2026-08-09 (Asia/Shanghai)

Disposition: **0 Critical / 0 Important / 0 Minor**. Read-only; no file was
modified by the auditor.

Audited exact inputs:

```text
authority packet
88B55F94470919BB5A01F151CF2F5653AB31D95686E9A463297D0C9D02EA31A3

type-schema-matrix-v1.md
AB9B294C293C7929EE92CA61DF44DDF5827C94666705AF7E57A67B87421B8CD8
```

## Mechanical form closure

The matrix has seven TypeKinds, ten distinct `(TypeKind,ReflectionKind)` enum
pairs, and eleven actual legal forms. Ordinary and statics UClass share
`(Class,UClass)` but the `StaticsClass` discriminator makes them separate forms.
Therefore the exact empty-Behavior baseline count is eleven—not seven or ten:

1. Class + None;
2. ordinary Class + UClass;
3. statics Class + UClass;
4. Struct + None;
5. Struct + UStruct;
6. Interface + None;
7. Enum + None;
8. Enum + UEnum;
9. Delegate + UDelegate;
10. Typedef + None; and
11. Funcdef + None.

Every form admits exactly one concrete empty Behavior baseline after clearing any
HasDefaultConstructor/HasDestructor coupling flags. For statics,
Interface/Enum/Typedef/Funcdef the empty array is required; for the other legal
VM forms it is a legal zero-row state.

## Missing-row and present-row coordinates

- Ordinary UClass missing ShadowSuper, CodeSuper or CodeRoot uses
  `Reflection,{U,U,U}`. Missing required StaticClassGlobalName also uses
  Reflection.
- Statics UClass missing CodeSuper or all reflected members uses Reflection.
- UStruct missing StructHeader uses Reflection.
- TypeKind-intrinsic Enum/Delegate/Typedef/Funcdef payload presence stays in
  KindPayload validation and is not rerouted to form closure.
- Class Base present but BaseType input missing uses the requiring physical
  `Relation` row, not Reflection.
- A present forbidden/excess Relation, LayoutInput, Property, Method, VFT,
  Behavior or reflected-member row uses respectively the actual `Relation`,
  `LayoutInput`, `OrderedProperty`, `OrderedMethod`, `VirtualFunctionSlot`,
  `BehaviorSlot` or `ReflectedFunctionMember` field at the lowest proving physical
  primary index.
- A form-dependent layout mismatch uses `LayoutExpectation`; a form-dependent
  semantic-flag mismatch uses `TypeSemanticFlags`; illegal form/known reflection
  flags/optional reflection strings use `Reflection`.
- Duplicate/conflicting singleton Relation or LayoutInput uses the second matching
  physical row and fails field-locally before closure.

The audit checked these against the current append-only numeric enum:
TypeSemanticFlags 8, Relation 11, LayoutInput 13, LayoutExpectation 15,
OrderedProperty 16, OrderedMethod 20, VirtualFunctionSlot 23, BehaviorSlot 27,
KindPayload 30, Reflection 34 and ReflectedFunctionMember 35. No fictional or
unrepresentable coordinate remains.

This audit is a narrow mechanical cross-check. Atomic semantic release still
belongs to the independent four-file authority review.
