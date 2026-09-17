# Header tree table

Source: exploration finding `header-tree-table.md` (Chinese).

File header: list the cases in the pocket. Indent when `@parent` exists; otherwise flatten.

Case header: show only this case's place on the tree. Do not copy the whole pocket tree.

These lines are not new `@` directives. The parser ignores header lines that do not start with `@`. They must not appear in clean source.

Two layers:

- Header indent plus `@parent`: case lineage (who edits whom).
- Body `@point` / `@range-*`: which bytes changed relative to the parent. Stripped from clean source, leaving offsets.

`cast-round-trip` is not a child of `cast-downcast`: it adds an upcast, so it is another complete program.
