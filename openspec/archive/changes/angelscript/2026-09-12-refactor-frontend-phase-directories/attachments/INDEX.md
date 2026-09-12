# INDEX

## Current position

Ready to archive as completed. Specs synced; knowledge promoted. Next: terminal evaluation then archive.

## Hard conclusions

- Six colocated folders: `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}/`.
- Includes: `#include "frontend/<Phase>/as_*.h"`; no new UBT include root.
- Impl files match header stems; exception: keep `as_frontend_options.h` in `Lexer/`.
- `as_builder.h` / `as_builder.cpp` stay at the SDK root. Host trio lives in `Compile/`.
- No include/lib split. No nested `frontend/Frontend/`. No C++ namespace change.

## Forbidden

- Do not copy Clang `include/` vs `lib/`.
- Do not name a folder `Frontend/` under `frontend/`.
- Do not use spec ids (`declarations/`, `bodies/`) as source directories.
- Do not move `as_builder.h` or bytecode emit into `frontend/`.
- Do not add `frontend/` or a phase folder as a UBT include root.
- Do not rename `as_frontend_options.h` in this Change.
- Do not rewrite `openspec/archive/`.

## Attachment index

- `drafts/design.md` — approved layout design — load before planning or apply
- `drafts/handoff.md` — Change identity and task boundaries — load at Ensure plan
- `drafts/glossary.md` — settled folder and file names — load when naming
- `drafts/findings/frontend-layout.md` — Clang vs spec vs flat folder — load when explaining the split
- `drafts/findings/as-frontend-prefix.md` — impl-stem rename map — load when renaming files
- `drafts/findings/folder-map.md` — per-file folder assignment — load when moving files
- `talks/talk-20260912-122242-no-include-lib.md` — no include/lib, no nested Frontend — load before inventing a seventh layer
- `talks/talk-20260912-122242-lexer-parser-folder-names.md` — Lexer/Parser vs spec ids — load before renaming folders
- `talks/talk-20260912-122242-builder-stays-sdk-root.md` — Builder at SDK root — load before moving as_builder
- `talks/talk-20260912-122242-keep-options-filename.md` — keep as_frontend_options.h — load before header renames
- `knowledges/frontend-phase-directories.md` — promoted: six-folder include contract — durable copy at `openspec/specs/angelscript/language/ast/core/knowledges/frontend-phase-directories.md`
- `knowledges/impl-stem-matches-header.md` — promoted: header/impl stem rule — durable copy at `openspec/specs/angelscript/language/ast/core/knowledges/impl-stem-matches-header.md`
- `data/planning-validation.md` — plan-acceptance self-review — load when judging coverage or placeholders
- `data/closure.yaml` — completed closure input for archive — load at archive
- `data/workflow-evaluation.md` — terminal workflow evaluation — load before completed archive
- `scripts/Move-FrontendPhases.ps1` — one-shot git mv + include rewrite — load only if replaying the move
