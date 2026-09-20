# What a dedicated directory changes

The user wants syntax such as `auto` in its own directory. FileTag follows the path.

## Three cuts

```
A  Same as first-wave ControlFlow (chosen when coverage needs slices)
Language/Auto/InferFromLiteral.as     →  Language/Auto/InferFromLiteral
Corpus queries prefix Language/Auto/

B  Directory merges into one FileTag
Every Language/Auto/*.as registers as versions of Language/Auto
Requires a discovery/parser contract change

C  Keep Language/Auto.as
Add @begin cases only
```

A retires second-wave flat names and updates spec / Skill / `LanguageFixtureCorpus`.

B fights "hand-write pockets" and blurs one-file theme range.

C does not give `auto` its own directory.

## Slice grain

A directory may still hold several `.as` files. One slice is one concern. A file may hold a few closely related `@begin` cases (infer / same-type reassign / expression). Do not pack bool+float+int+constructor into one file again.

Fail is `*CompileFail.as` on the same slice.

## Authoring constraint

- Subagents hand-write each `.as`.
- Do not generate author bodies from Pending/Bindings with Python.
- `codegen.py generate/check` runs after authors exist. That is projection, not authoring.
