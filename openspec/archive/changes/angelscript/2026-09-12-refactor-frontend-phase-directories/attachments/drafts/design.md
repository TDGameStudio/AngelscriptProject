# Frontend phase directories

Status: design draft (awaiting user review)

English record; user-facing discussion may stay Chinese. Draft: `angelscript/frontend-layout`.

## Context

Reconstructed language sources are 107 colocated files under `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/`. OpenSpec capabilities are already phased (`lexing`, `preprocessing`, `source-diagnostics`, `declarations`, `bodies`, `builder`, plus `language/ast/core`). Clang 22.1.8 phases the same pipeline as `include/clang/{Basic,Lex,Parse,AST,Sema,Frontend}` and a matching `lib/` tree.

C++ names stay in `BEGIN_AS_NAMESPACE`. The folder `frontend/` is not a namespace. Include root stays `angelscript/`, so live includes remain `"frontend/…"`.

Recommended Change ID: `angelscript/refactor-frontend-phase-directories`.

## Goals / Non-Goals

**Goals:**

- Split `frontend/` into six colocated phase folders: `Basic/`, `Lexer/`, `Parser/`, `AST/`, `Sema/`, `Compile/`.
- Drop the leftover `as_frontend_` stem on implementation files so they match their headers (`as_parser.cpp`, `as_sema.cpp`, …).
- Rewrite `#include "frontend/as_*.h"` to `#include "frontend/<Phase>/as_*.h"`.
- Rename SDK-root `as_builder_frontend.cpp` to `as_builder.cpp`.
- Retarget live spec/knowledge sentences that cite the old flat `frontend/as_*.h` paths.

**Non-Goals:**

- No `include/` vs `lib/` split.
- No nested `frontend/Frontend/`.
- No extra C++ namespace, no `asC*` renames.
- No product lexer/parser/sema behavior change.
- No move of `as_builder.h` / bytecode emit into `frontend/`.
- No new `language/frontend/parsing` spec in this Change.
- No test-tree reorg beyond include retargets that compilation requires.
- Do not start while `angelscript/test-lexer-isolated-coverage` or `angelscript/refactor-bindings-two-stage-pipeline` still mutate the same files, unless the user explicitly sequences this after them.

## Decisions

### Six folders (Q1, Q2)

```text
angelscript/
├─ as_builder.h
├─ as_builder.cpp                 // today as_builder_frontend.cpp
├─ as_bytecode_emitter.*
└─ frontend/
   ├─ Basic/                      // source, diagnostics, identifiers, surface, stable key
   ├─ Lexer/                      // tokens + preprocessor + as_frontend_options.h
   ├─ Parser/
   ├─ AST/
   ├─ Sema/
   └─ Compile/                    // session, builder stages, host trio
```

Rejected: Clang short `Lex`/`Parse` (Q2 B). Rejected: spec-id folders that would split Parser/Sema by declaration-vs-body stage (Q2 C). Rejected: include/lib (Q1 C).

Preprocessor files live in `Lexer/`, not a seventh `Preprocess/` folder.

### File assignment (Q7)

Exact list: `attachments/drafts/findings/folder-map.md`. Highlights:

- `as_type_syntax*` → `Parser/` (grammar, not `asCType` storage).
- `as_type_context` → `AST/`; `as_type_identity` → `Sema/`.
- `as_stable_key` → `Basic/` (Engine/TypeInfo include it).
- Host trio → `Compile/` (Q4 B).

### Implementation file names (Q1, Q6)

Apply the map in `attachments/drafts/findings/as-frontend-prefix.md`, except Q5.

- `as_frontend_parser.cpp` → `as_parser.cpp` (same for the other 15 impl files).
- `as_builder_frontend.cpp` → `as_builder.cpp` at the SDK root (Q6 A).
- `as_frontend_options.h` **keeps its name** and moves to `frontend/Lexer/as_frontend_options.h` (Q5 C).

C++ types stay `asCParser`, `asCSema`, `asCTokenizer`, `asSLexOptions`.

### Include contract

Before: `#include "frontend/as_tokenizer.h"`  
After: `#include "frontend/Lexer/as_tokenizer.h"`

Do not add `frontend/` or a phase folder as a new UBT include root. Short names like `"as_scriptengine.h"` stay at the SDK root.

`as_builder.h` stays `#include "as_builder.h"`.

### Builder stays at SDK root (Q3)

`asCBuilder::RunThrough` includes `ByteCodeEmitted`. The public compile entry remains beside the engine, not inside `frontend/Compile/`. Only `as_builder_stages.h` and `as_compilation_session*` move into `Compile/`.

### Spec and knowledge retarget

Update live citations of flat `frontend/as_*.h` in:

- `openspec/specs/angelscript/language/ast/core/spec.md` (directory sentence may say headers live under `angelscript/frontend/<Phase>/`)
- `openspec/specs/angelscript/language/ast/core/knowledges/first-party-sdk-root.md`
- Any other **live** spec/knowledge that names a moved header

Do not rewrite immutable `openspec/archive/`.

No new parsing capability in this Change.

## Error handling and edge cases

- A missed include is a compile break; the proving command is a focused Runtime/test compile, not a behavior oracle.
- Legacy/dormant tests that still include deleted flat paths are retargeted only when they are part of the live build. Isolation-bound Legacy sources follow the existing isolation rules.
- Git history: prefer `git mv` so the phase split stays reviewable.

## Verification

Smallest proof: after the moves, the AngelscriptRuntime module and the live tests that include moved headers compile. Record the exact Harness `ue.*` command chosen at task time. Do not treat Quick/Performance/Integration as an unconditional gate.

Omitted unless include fallout appears: full Automation suite, lexer behavior tests (owned by the lexer-coverage Change).

## Vocabulary

See `attachments/drafts/glossary.md`. Folder names are public source paths. The one kept exception is `as_frontend_options.h`.
