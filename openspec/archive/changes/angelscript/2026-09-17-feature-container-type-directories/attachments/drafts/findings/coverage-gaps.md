# How coverage expands

Source: draft finding (Chinese original; approval R6).

Admission is still a source fixture, not an AngelScript compile/execute pass. Expanding coverage means adding complete parentless programs that `Get` can retrieve, whose bodies actually observe that bind.

## Do not expand this way

- Dump `Pending/Containers` wholesale
- Paste Bindings axis files (`Behavior_01`, `Queries_02`)
- Stack `_FString` / `_UObject` / `&in` / `&out` inside one `@begin`
- Add empty versions to inflate counts

## Four axes (by payoff)

```
bind method
  // public MethodSurface overloads and defaults that are only half observed
  ├─ element / key types
  │    // beyond int: FString, FName, FVector, UObject*, struct-with-array
  ├─ call shape
  │    // local / UPROPERTY / const&in / &out / &inout, each its own @begin
  └─ polarity
       // thicken existing CompileFail/RuntimeFail; do not invent polarity
```

TArray already names the bind surface. Prefer observation depth over new API names: Last(0) vs Last(1) vs const Last; Copy index combinations; Empty/Reset reserved size; Sort descending; Add/Insert of temporaries and UObject handles. Existing `StructsContainingArrays`, `ObjectProperty`, and `UObjectReferences` are the grain for new cases.

TMap / TSet look thin because giant dump blocks hide Find / FindOrAdd / GetKeys. Split first, then see the holes.

Pointer types already tell lifetime stories. Thicken along object lifetime (clear, retarget, weak does not keep alive). Do not copy a `container-api` block.

## FileTags

FileTag is `Containers/<Type>/<Observation>` (R4/R5). Watch generated volume. A 459KB TArray author once hit C4883; one file per begin is the volume fix.

Do not invent binds a type does not have just to match TArray's file count.
