# Frontend phase directories

Approved design from `attachments/drafts/design.md`. Talks under `attachments/talks/` record the include/lib, folder-name, Builder-location, and options-filename decisions.

## Context

Reconstructed language sources are 107 colocated files under `angelscript/frontend/`. Include root is `angelscript/`. C++ names stay in `BEGIN_AS_NAMESPACE`. Clang 22.1.8 phases the same pipeline as `include/clang/{Basic,Lex,Parse,AST,Sema,Frontend}` plus a matching `lib/` tree. This Change copies the phase split only.

## Goals / Non-Goals

**Goals:**

- Six colocated phase folders under `frontend/`.
- Implementation stems match headers, except `as_frontend_options.h`.
- Includes become `#include "frontend/<Phase>/as_*.h"`.
- `as_builder_frontend.cpp` becomes `as_builder.cpp` at the SDK root.

**Non-Goals:**

- include/lib split; nested `frontend/Frontend/`; C++ namespace or `asC*` renames.
- Product language behavior; moving `as_builder.h` or bytecode emit.
- A new parsing spec; test-tree reorg beyond required include retargets.

## Decisions

### Six folders

```text
angelscript/
├─ as_builder.h
├─ as_builder.cpp
├─ as_bytecode_emitter.*
└─ frontend/
   ├─ Basic/
   ├─ Lexer/          // tokens + preprocessor + as_frontend_options.h
   ├─ Parser/
   ├─ AST/
   ├─ Sema/
   └─ Compile/        // session, stages, host trio
```

File assignment: `attachments/drafts/findings/folder-map.md`.

### Includes

Do not add `frontend/` or a phase folder as a UBT include root. `as_builder.h` stays `#include "as_builder.h"`.

### Sequencing

Do not start the moves while `angelscript/test-lexer-isolated-coverage` or `angelscript/refactor-bindings-two-stage-pipeline` still mutate the same files, unless the user sequences this after them.

## Risks / Trade-offs

- Large include rewrite; a missed path is a compile break.
- Dormant Legacy tests may still name flat paths; retarget only live-build TUs.
- Folder names do not match spec ids (`lexing`, `declarations`, `bodies`) on purpose.
