# Full role folder names, not spec-id directories

## Context

The six phase folders needed public names. Specs already cut the pipeline as `lexing` / `preprocessing` / `declarations` / `bodies`. Clang uses short `Lex` / `Parse`.

## Evidence

- Parser and Sema each have one primary TU plus topic splits. Spec `declarations` vs `bodies` is a compilation stage cut, not file ownership.
- Putting `as_parser.cpp` / `as_sema.cpp` under declarations/bodies would tear those files in half.
- The user asked for full role names such as `Lexer`, not Clang's `Lex`.

## Options

| Option | Result |
| --- | --- |
| A. `Basic/` `Lexer/` `Parser/` `AST/` `Sema/` `Compile/` | Full role names; preprocessor lives in `Lexer/` |
| B. Clang short `Lex` / `Parse` | Matches upstream Clang, weaker local scan |
| C. Spec ids (`declarations/`, `bodies/`, …) | 1:1 with specs; splits Parser/Sema files |

## Settled Decision

Option A. Preprocessor files live in `Lexer/`. `Sema/` stays short because the type is `asCSema`.

## Consequences and Flip Condition

Spec capability ids do not have to match folder names. If later work wants a 1:1 spec-to-directory map, revisit this talk before renaming folders.

## Sources

- `attachments/drafts/findings/frontend-layout.md`
- `attachments/drafts/design.md`
- Draft `log.md` Round 2 Q2 (original wording stays in the draft)
