# Current author markers (two layers)

Source: exploration finding `current-markers.md` (Chinese).

The live v1 grammar has no `@begin`, `@tag`, or `@function`. Python `container_parser` and C++ `FAngelscriptTestSourceParser` agree.

```
.as file
├─ [path] FileTag = path without .as
├─ container headers (unknown directives fail)
│  ├─ file: @version v1 + @summary + @topic*
│  └─ case: @version <tag> + required @parent (except root) + @summary + @topic*
├─ case body
│  └─ coordinate marks, stripped from clean source: @point / @breakpoint / @range-*
└─ /** @end */                       // exactly those 11 characters, unnamed
```

This Change replaces case `@version <tag>` with `@begin <tag>` and drops the forced parent. Coordinate marks stay a separate layer. Pending `@Inputs` / `@Return` values contain spaces and do not fit the one-token coordinate grammar; they belong on the function-header block.
