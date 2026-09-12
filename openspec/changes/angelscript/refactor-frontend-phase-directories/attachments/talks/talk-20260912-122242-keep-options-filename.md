# Keep the filename as_frontend_options.h

## Context

Implementation files drop the leftover `as_frontend_` stem so they match their headers. This header is the one file that already carries that stem on the `.h` itself.

## Evidence

- The header holds only `asSLexOptions` (Unicode identifier policy and trivia mode).
- Other headers are already short (`as_parser.h`, `as_sema.h`, `as_tokenizer.h`).
- The user chose move-only for this file: keep the name, place it in `Lexer/`.

## Options

| Option | Result |
| --- | --- |
| A. `frontend/Lexer/as_lex_options.h` | Matches content and the stem-cleanup rule |
| B. `frontend/Basic/as_options.h` | Treats it as general options |
| C. Move to `Lexer/`, keep `as_frontend_options.h` | One remaining `frontend_` token in a header name |

## Settled Decision

Option C.

## Consequences and Flip Condition

Do not rename this header in the same Change as the impl-stem cleanup. If later work folds language-surface options into the same header, revisit the name and home together.

## Sources

- `attachments/drafts/findings/as-frontend-prefix.md`
- `attachments/drafts/findings/folder-map.md`
- Draft `log.md` Round 3 Q5 (original wording stays in the draft)
