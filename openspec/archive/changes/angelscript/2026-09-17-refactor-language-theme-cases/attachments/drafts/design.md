# Accepted: theme pocket plus many cases, optional inheritance

Source: draft `designs/theme-case-containers/design.md` (Chinese). Approval: R20. Translated for this Change.

Names live in [glossary.md](glossary.md). Casting FileTags live in [findings/filename-length.md](findings/filename-length.md).

## Problem

One Language `.as` file currently stacks three mental models: FileTag as a theme pocket, `root` as a privileged representative, and every `valid-*` / `invalid-*` forced onto a fake modification tree. Casting has no real Family. `@parent root` only satisfies the Builder.

## Accepted direction

- Drop the privileged `root` mark (Q3).
- Several VersionTags in one `.as`; each VersionTag is one case.
- FileTag is the file's theme range.
- Negatives go to separate files: compile-fail and runtime-fail (Q9).
- Inheritance (Family) is optional. Most cases have no parent.
- Cases open with `@begin <tag>` and still close with unnamed `/** @end */` (Q12=B1).
- Callable entries use `@function` (Q14). The function description is also `@summary` (Q17).
- This Change covers the parser, every Language author file, and the Skill/specs (Q18, Q19).

## Contract

```
Current Builder
└─ exactly one root, Tag must be root
   └─ every other version must have a Parent

Target
FileTag = theme range
├─ VersionTag A     // no Parent
├─ VersionTag B     // no Parent
└─ VersionTag C
   └─ [optional] child   // Parent only for a real edit chain
```

This changes `code-database`, the parser, and `AddRoot` / `VersionParentRequired`. Adoption and GeneratedSources lookups of `Get(..., "root")` move with it. `StructFields` may still be a Family; the parent tag becomes `fields-two`.

Parentless versions use ordinary `AddVersion` with no Parent. A tag spelled `root` is an ordinary name with no privilege.

## Shape

```
Language/Casting/ClassHandleCast.as
├─ implicit-derived-to-base
├─ cast-to-parent
├─ cast-downcast
│  └─ cast-downcast-null-guard  [@parent]   // same program plus one edit
└─ cast-round-trip                          // sibling, not a child

Language/Casting/ClassHandleCastCompileFail.as
Language/Casting/ClassHandleCastRuntimeFail.as
```

Split mashup roots into one body per claim. Bleed leaves the current theme. Only a real Family writes `@parent`. The header tree indents children; body `@point` / `@range-*` mark the diff.

## Principles

| P | This Change |
|---|---|
| P1 classify before moving | yes |
| P2 Parent reports lineage only | yes |
| P3 one claim, one body | yes |
| P4 Bleed leaves the theme | yes |
| P5 keep positive siblings; move negatives into Fail files | yes |
| P6 only a Family has Parent | yes |
| P7 the database still does not compile, run, or store diagnostic oracles | yes |

## Author format

- File header: `@version v1`, `@summary`, `@topic*`, optional tree lines (non-`@`, not part of the body).
- Case header: `@begin <tag>`, `@summary`, optional `@parent`, `@topic*`, this case's place on the tree.
- Function header (Q15=C2, Q16=D1) immediately before the callable:

```
/**
 * @function UseOverride
 * @summary Calling the derived object runs the override.
 * @covers override
 * @inputs a default-constructed AChild
 * @return 3
 */
```

Compile-fail cases omit `@function`. `@topic` stays an open label.

This Change lengthens only the four Casting pockets. Other Language leaves keep their current last segment and gain `CompileFail` / `RuntimeFail` siblings.

## In this Change

- Python `container_parser` and C++ `FAngelscriptTestSourceParser` / `FAngelscriptTestCodeBuilder`, plus matching tests.
- Every `AngelscriptTestCode/Language/**` author file and its `.generated.cpp`.
- Adoption / Framework tests that `Get(..., "root")` or require a star tree.
- `.agents/skills/angelscript-test/SKILL.md` and `references/test-code-database.md`.
- `openspec/specs/angelscript/testing/code-database` and `language-fixtures`.

## Out of this Change

- The 122 generator products.
- asCBuilder / diagnostic oracles.
- Bindings / Containers / World / Pending author files.
- Turning the code database into a compile or execute layer.

## Verification

- One positive file can register two parentless VersionTags; queries do not disturb each other.
- A version named `root` has no privilege.
- A fail FileTag does not contain the positive versions.
- `StructFields` `fields-two` / `add-field` still register, with coordinates.
- Cycles and missing parents still fail.
- Language product files no longer use the forced-star v1 shape.
- The Skill and language-fixture specs no longer teach `Get(..., "root")` as the representative source.

## Task order for Ensure plan

1. Parser / Builder / CodeGenTool grammar and tests.
2. The four Casting pockets as the proving set (Fail files, one Family example, `@function`).
3. The remaining Language files by theme.
4. Skill and durable specs.
5. Regenerate Language projections and update Adoption.
