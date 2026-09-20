# Author quality debt

Source: draft finding (Chinese original; approval R6). These are not thin spots that extra cases would hide. They make later hand-writes pile onto dirty files and they push generated volume toward C4883.

## Tag and body disagree

First `@begin array` in `Containers/TArray.as`:

- Summary says `Last() is 40`
- The file header still carries a Bindings `Behavior_01` story (Swap/Last/Copy/range-for)
- The body only asserts empty `TArray<int32>` / `TArray<FName>` `IsEmpty` and `Num()==0`

Real `Last` lives later as `@begin last` and already covers `Last(1)` and const Last. `array` is merge leftover, not an empty-construction name.

`swap` / `copy` also keep `// Last() is 40` fragments cut from a source header.

## One `@begin` holds a whole old program

`Containers/TMap.as` `@begin contains-contains` (about lines 835–1333):

- Repeats `class UTMapContainsObject`
- Leaves half `@function` / `@Kind Observe` / `@Kind RoundTrip` comments
- Stacks `ContainsPresentAndAbsent`, `ReadContains(&in)`, `FillMapForContains(&out)`, `AppendForContains(&inout)`, then `_FString` / `_UObject` copies
- The catalog looks like one Contains case while the block is five hundred lines

That creates two false pictures: too few cases, and a file already large (TMap.as about 63KB).

`contains-missing` has a leftover sentence `with Add(10, 100); Contains(99)` between comments and `UFUNCTION`. `add-overwrite` has a broken `int> Add(10, 100)` comment.

## The merge produced the debt

Host-api flattened Bindings Observe entries and Pending/Containers onto one FileTag with a converter. Some Pending files became clean parentless `@begin` cases. Others were dumped whole, still carrying `@version root` / `@Kind` / `UFUNCTION` scaffolding.

This Change forbids Python batch rewrites. Implementation is hand-written: one behavior, one complete program, one matching summary.

## Conclusion used by the design

Rewrite the nine pockets into readable one-behavior programs first, then thicken along each bind surface. Adding cases onto dirty TMap/TArray pockets locks the debt in.
