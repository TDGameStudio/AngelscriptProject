# Glossary

| term | chosen | rejected | reason |
|---|---|---|---|
| layout axis | phase subfolders under `frontend/` + drop `as_frontend_` on impl files; keep `#include "frontend/…"`; colocate `.h`/`.cpp` | rename-only; include/lib split; docs-only | Q1 = A |
| impl prefix `as_frontend_` | drop; files match header stem (`as_parser.cpp`) | keep as historical marker | leftover from replacement cutover; folder already says frontend |
| C++ names | unchanged (`asCParser`, `asCSema`, …) | Clang-style unprefixed `Parser` | already settled in ast/core spec |
| folder set | `Basic/` `Lexer/` `Parser/` `AST/` `Sema/` `Compile/` | Clang `Lex`/`Parse`; spec ids | Q2 = A; preprocessor lives in `Lexer/` |
| `as_builder` location | stay at `angelscript/` SDK root | move into `frontend/Compile/` | Q3 = B; `RunThrough` includes bytecode |
| host trio | stay in `frontend/Compile/` | SDK root; `frontend/Host/` | Q4 = B |
| `as_frontend_options.h` | keep the filename; move to `frontend/Lexer/` | `as_lex_options.h`; `as_options.h` | Q5 = C |
| `as_builder_frontend.cpp` | `as_builder.cpp` at SDK root | keep `_frontend` in the name | Q6 = A |
| file map | `attachments/drafts/findings/folder-map.md` as written | per-file exceptions | Q7 = A |
| Change ID | `angelscript/refactor-frontend-phase-directories` (recommended) | | naming; confirm in review |
