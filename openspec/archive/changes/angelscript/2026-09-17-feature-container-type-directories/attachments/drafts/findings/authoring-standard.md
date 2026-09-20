# Hand-written author standard

Source: draft finding (Chinese original; approval R6). Subagents follow the task card. Do not invent a converter.

## Shape of one `@begin`

```
/**
 * @begin EmptyConstruction
 * @summary Default TArray<int32> and TArray<FName> are empty.
 * @topic Containers
 */
bool EmptyConstruction()
{
	TArray<int32> Numbers;
	TArray<FName> Names;
	return Numbers.IsEmpty() && Numbers.Num() == 0
		&& Names.IsEmpty() && Names.Num() == 0;
}
/** @end */
```

Must:

- Live at `Containers/<Type>/<Observation>.as` or `.../CompileFail/<Observation>.as` / `.../RuntimeFail/<Observation>.as`
- `<Observation>` is lengthened Pascal that states the assertion, not a method alias. See [extended-names.md](extended-names.md)
- One parentless `@begin` per file; the tag equals the Pascal stem
- Do not mix `@version` and `@begin`
- `@topic Containers`
- English summary that matches the assertion
- One entry function that returns this observation (or a compile-fail / must-fail program)
- A complete parseable program; declare only the `UCLASS` types this case needs

Must not:

- Leave Pending `@Kind Observe` / `@Kind RoundTrip` / `@Covers` scaffolding
- Stack `_FString` / `_UObject` / `&in` / `&out` functions inside one begin
- Generate authors from `Pending/Containers` or Bindings axis files
- Write empty shells to match a count
- Copy TArray Last/Insert/Swap onto types that do not bind them
- Edit Language / Unreal first-batch / create `Math/`

Flexible:

- Nine types share observation names, not leaf lists
- Type-axis files only for binds that accept that element/key
- Fail directories follow Throw evidence; not every type needs both polarities
- Pointer cases that are already long only Pascalize; do not wrap them in CRUD

## Tags

- Tag = stem = lengthened Pascal. `AddAndOrder`, not `add`, not `array`.
- The filename states the assertion. Quality renames `array` to `EmptyConstruction`.
- FileTag is `Containers/TArray/EmptyConstruction`, not flat `Containers/TArray`.
- Stems are unique in a directory. Type variants add a type word: `AddAndOrderFString`.

## Type axis

Name the element/key types this case uses. Prefer new coverage on `FString`, `FName`, `FVector`, `UObject`, and structs that contain arrays. Each variant is its own `@begin`.

## Fail pockets

- CompileFail: programs the bind rejects (nested containers, missing type args, wrong element type).
- RuntimeFail: bounds the current bind throws or must fail. Put the Throw text in the summary. One condition per case.
- Do not open a polarity without Bind `Throw` / Validate evidence.
- Delete leftover Pending fragments between `@begin` and the function.

RuntimeFail sample:

```
/**
 * @begin InsertIndexPastNum
 * @summary Insert past Num throws Need to insert between 0 and ArraySize.
 * @topic Containers
 */
void InsertPastNum()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Insert(9, 2);
}
/** @end */
```

## Proof

Author side: CodeGen `parse_source_file` / existing unittest, named FileTag+version present with a key token in the body.  
Projection: `codegen.py generate` then `check`.  
Corpus: `Get(Containers/TArray/AddAndOrder, AddAndOrder)` when needed.  
Do not treat UE Automation compiling AngelScript, or executing UFUNCTION, as this wave's green light.

## Volume

If a generated cpp again approaches the old C4883 size, stop. Do not invent `Containers/TArray/Queries`. Do not flatten back to `TArray.as`.
