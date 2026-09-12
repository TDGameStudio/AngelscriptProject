# AST Core Knowledge Index

- `clang-typed-ast-shape-and-lifetime.md` — evidence-backed guidance for concrete subclasses, taxonomy-driven casts and traversal, context-owned lifetime, canonical type separation, immutable projections, and the new codec; promoted from the typed-AST reconstruction Change.
- `first-party-sdk-root.md` — current — first-party SDK lives at `Source/AngelscriptRuntime/angelscript/` (flattened; language headers under `frontend/<Phase>/`; public C header stays `Core/angelscript.h`). Serves Canonical AngelScript C++ names / include reconstructed headers. Origin: `angelscript/refactor-runtime-owned-sdk-layout/attachments/knowledges/first-party-sdk-root.md`.
- `frontend-phase-directories.md` — current — reconstructed language sources live under `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}/`; include `"frontend/<Phase>/as_*.h"`. Serves Canonical AngelScript C++ names / include reconstructed headers. Origin: `angelscript/refactor-frontend-phase-directories/attachments/knowledges/frontend-phase-directories.md`.
- `impl-stem-matches-header.md` — current — implementation stems match headers except `as_frontend_options.h`; `as_builder.cpp` stays at the SDK root. Serves Canonical AngelScript C++ names. Origin: `angelscript/refactor-frontend-phase-directories/attachments/knowledges/impl-stem-matches-header.md`.

