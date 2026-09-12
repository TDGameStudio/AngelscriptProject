Draft: `angelscript/frontend-layout` (accepted 2026-09-12)

# Problem

Reconstructed language sources are 107 colocated files under `angelscript/frontend/`. Specs are already phased; Clang phases the same pipeline by directory. Navigation cost is the flat bag plus leftover `as_frontend_*` implementation names that do not match their headers.

# Success Criteria

- Live language headers and implementations sit under `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}/`, headers beside cpp.
- Includes are `#include "frontend/<Phase>/as_*.h"` against the existing `angelscript/` include root.
- Implementation files match header stems (`as_parser.cpp`, `as_sema.cpp`, …). The one kept exception is `as_frontend_options.h` in `Lexer/`.
- SDK-root `as_builder_frontend.cpp` is `as_builder.cpp`. `as_builder.h` and bytecode emit stay at the SDK root.
- Live spec/knowledge sentences that cite flat `frontend/as_*.h` are retargeted.
- AngelscriptRuntime and live tests that include moved headers compile. No language-behavior change.

# Evidence

- Inventory and Clang/spec comparison: `attachments/drafts/findings/frontend-layout.md`.
- Rename map: `attachments/drafts/findings/as-frontend-prefix.md`.
- Folder assignment: `attachments/drafts/findings/folder-map.md`.
- Settled Q1 A, Q2 A, Q3 B, Q4 B, Q5 C, Q6 A, Q7 A, Q8 A, Q9 A.
- ast/core already says directory layout is independent of C++ scope and headers live under `frontend/`.

# Scope and Exclusions

In: six-folder `git mv`; impl-stem renames; include rewrite; `as_builder.cpp` rename; live spec/knowledge path retarget; focused compile proof.

Out: include/lib split; nested `frontend/Frontend/`; C++ namespace or `asC*` renames; product lex/parse/sema behavior; moving `as_builder.h` or bytecode emit; a new `language/frontend/parsing` spec; test-tree reorg beyond required include retargets.

# Constraints

- Do not start file moves while `angelscript/test-lexer-isolated-coverage` or `angelscript/refactor-bindings-two-stage-pipeline` still mutate the same files, unless the user explicitly sequences this after them.
- Do not add `frontend/` or a phase folder as a new UBT include root.
- Do not rewrite immutable `openspec/archive/`.
- Prefer `git mv`.

# Options

Compared in the draft: phase folders + stem rename (A); rename-only (B); Clang include/lib (C); docs-only (D). User chose A, then full role folder names, builder at SDK root, host trio in `Compile/`.

# Decision and Rationale

Normalize source to match the already-phased specs and Clang's phase split, without copying Clang's include/lib scale or a nested Frontend name. Builder stays at the SDK root because `RunThrough` includes `ByteCodeEmitted`.

# Flip Condition

If a move would collide with the in-flight lexer-coverage or bindings Changes and only a cheap win is wanted, do rename-only and leave the folder flat. If Builder is later treated as a Clang `CompilerInstance` that must live with the session, move `as_builder_frontend.cpp` (then `as_builder.cpp`) into `Compile/` and keep `as_builder.h` at the root.

# Architecture, Components, and Data Flow

See `attachments/drafts/design.md` and `attachments/drafts/findings/folder-map.md`.

```text
asCBuilder::RunThrough                 // SDK root; includes bytecode
└─[owns] asCCompilationSession         // frontend/Compile/
   ├─[owns] asCASTContext              // frontend/AST/
   ├─[owns] asCSema                    // frontend/Sema/
   └─[calls] asCParser                 // frontend/Parser/
      └─[reads] asCTokenizer / PP      // frontend/Lexer/
```

# Failures and Edge Cases

- A missed include is a compile break, not a behavior oracle.
- Retarget Legacy/dormant includes only when they are in the live build.
- `as_frontend_options.h` is the only header that keeps the `frontend_` token.

# Verification

Smallest proof: AngelscriptRuntime and live tests that include moved headers compile via the task's exact Harness `ue.*` command. Omit Quick/Performance/Integration and lexer-behavior prefixes unless include fallout reaches them.

# OpenSpec Handoff

- Change ID: `angelscript/refactor-frontend-phase-directories`
- Title: Split reconstructed frontend sources into phase directories
- Goal: Move reconstructed language sources into `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}/`, align implementation filenames with headers, rewrite includes, and retarget live path citations, without changing language behavior or C++ namespaces.
- Workflow: `angelscript`
- Affected areas: `angelscript/language`
- Required artifacts: proposal, design, tasks. Specs: ast/core path-sentence delta only; update `first-party-sdk-root` knowledge. No new parsing capability.
- Task boundaries: (1) `git mv` + stem renames including `as_builder.cpp`; (2) include rewrite across live Runtime/tests; (3) live spec/knowledge path retarget; (4) focused compile proof.

# Exploration Carryover

Confirmed by Q9 A.

Talk candidates:

- Draft `log.md` Round 1 Q1 + `attachments/drafts/findings/frontend-layout.md` → talk: no include/lib split; no nested `frontend/Frontend/`.
- Draft `log.md` Round 2 Q2 → talk: `Lexer/`/`Parser/` full names; do not use spec declarations/bodies as directories.
- Draft `log.md` Round 2 Q3 → talk: `as_builder` stays at the SDK root because `RunThrough` includes bytecode.
- Draft `log.md` Round 3 Q5 → talk: keep the filename `as_frontend_options.h` and move it into `Lexer/`.

Knowledge candidates:

- `attachments/drafts/findings/folder-map.md` → knowledge: six-folder map and `#include "frontend/<Phase>/as_*.h"`.
- `attachments/drafts/findings/as-frontend-prefix.md` → knowledge: implementation files match header stems; one header-name exception.

Discard: Clang file-count tables; process questions; uncited findings.
