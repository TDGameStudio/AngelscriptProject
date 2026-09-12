# Implementation files match header stems

## Reusable Insight

After reconstruction cutover, the folder already says `frontend/`. Implementation files must use the same stem as their header: `as_parser.h` + `as_parser.cpp` + `as_parser_statements.cpp`. Do not prefix implementations with `as_frontend_`.

The one settled exception is the header `as_frontend_options.h` (lex knobs only), which keeps that filename and lives in `Lexer/`.

SDK-root Builder implementation follows the same stem rule: `as_builder.h` + `as_builder.cpp`.

C++ type names stay `asC*` / `asS*` / `asE*`.

## Evidence

- Seventeen `as_frontend_*` files existed while matching headers were already short (`as_parser.h`, `as_sema.h`, `as_tokenizer.h`).
- `as_compilation_session_types.cpp` already followed the stem rule.
- Editor Development build RunId `196f9e5ffcc74c4fa21bfb1e0c2495e1` succeeded after the stem alignment.

## Boundaries

- Not a C++ rename and not a namespace change.
- Does not authorize renaming `as_frontend_options.h` in a drive-by edit.
- Does not apply to dormant Legacy sources unless they are in the live build.

## Application

When splitting a frontend implementation, name the extra TU `<header-stem>_<topic>.cpp`. When reviewing a new file, reject a fresh `as_frontend_` implementation prefix.

## Sources

- `openspec/changes/angelscript/refactor-frontend-phase-directories/attachments/knowledges/impl-stem-matches-header.md`
