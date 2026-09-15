# Diagnostic quality, native queries and the later LSP adapter

## Context

The accepted exploration selected two explicit commitments: migrate all currently supported AS frontend diagnostic paths, and implement native completion/signature/hover/definition queries without implementing an LSP service. The user subsequently reiterated that this delivery only creates the Change.

## Evidence

The historically inspected diagnostic header (now `frontend/Basic/as_diagnostics.h`) stores IDs, severity, byte ranges, generic typed values and replacement bytes, but actual semantic producers commonly supply generic IDs and reason strings. The migration inventory records text-only declaration failures and source-less messages rejected by the current collector. Existing manually assembled fix/range tests are evidence for storage, not real diagnostic quality.

Local Clang 22.1.8 sources distinguish diagnostic production from semantic tooling. `clang/include/clang/Basic/Diagnostic.td` defines cause metadata; `clang/lib/Basic/Diagnostic.cpp` handles policy and note sequencing. `clang/lib/Sema/SemaLookup.cpp::CorrectTypo` filters semantic candidates, and `clang/include/clang/Sema/SemaCodeCompletion.h::ProduceCallSignatureHelp` exposes contextual signature machinery. clangd `Diagnostics.h::Diag` adds owned Notes/Fixes associations, while `ParsedAST` retains AST, source and preprocessing lifetimes.

The repository's `Extensions/AngelscriptVSCode/language-server/src/server.ts` already advertises LSP features but uses a separate TypeScript parser/type database. Its old UE diagnostic adapter reads a character value then constructs whole-line ranges, and its diagnostic publication lacks a source-revision contract. The old runtime bridge remains intentionally dormant. A future native-backed adapter is therefore a semantic integration project, not simply enabling an existing socket.

## Options

- **Rich records only:** smaller, but rejected because the current producer quality and missing compiler-side queries would remain unresolved.
- **Native diagnostics plus real semantic queries:** selected. One Parser/Sema supplies language authority; owned query products can be proven directly without protocol or editor execution.
- **Immediate clangd-style server and extension migration:** rejected for this Change. Document synchronization, stale async work, workspace indexing, scheduling and transport introduce independently acceptable products.

## Settled Decision

Select native diagnostics and real semantic queries. Within the selected option, completed-AST-only completion was rejected. Clang performs a dedicated cursor parse because scope and parser state are not all retained in a finalized AST. Native query evaluation must separate candidate assessment from AST conversion/default commitment; directly exposing today's mutating `ResolveCall` is insufficient.

## Consequences and flip condition

The Change is substantial but bounded by the current language and the successor task plan. It does not promise an editor-visible feature immediately. The existing extension remains untouched; no native query falls back to its independent semantic model.

Initial cursor requests may reparse immutable inputs rather than reuse an incremental cache. This accepts a measurable native CPU cost without introducing an unproven cache invalidation contract. A user requirement for immediate VS Code behavior, workspace-wide discovery or an evidenced interactive latency target would require a separately scoped adapter/index/cache Change or an explicitly accepted replan.

## Sources and application boundary

- Source baseline: maintained plugin files and the indexed `data/diagnostic-migration-inventory.md`, inspected read-only on 2026-09-05.
- Local source baseline: `D:/LLVM/llvm-project-22.1.8.src`, particularly Clang Basic/Sema and `clang-tools-extra/clangd`. The actual local source path was used rather than assuming the Reference junction was usable.
- [clangd code walkthrough](https://clangd.llvm.org/design/code): compiler diagnostics, AST queries, dedicated completion parsing and separate scheduler/index responsibilities.
- [Clang internals: diagnostics](https://clang.llvm.org/docs/InternalsManual.html#the-diagnostics-subsystem): diagnostic arguments, consumers and correction presentation. Online documentation may track a newer development version; the inspected local 22.1.8 source is the versioned reference here.

This talk preserves rationale only. Proposal/specs/design own accepted behavior, tasks owns execution, and no runtime verification or automatic knowledge promotion is implied.

## Visual

```text
Native production → retained diagnostic result   // One semantic authority
└─ In-process format/fix and native queries       // Current accepted scope
   └─ Future protocol adapter                    // Separate delivery
```

Provenance: carried from the same relative attachment in predecessor angelscript/feature-frontend-diagnostics-tooling, confirmed by Q10. Ownership terminology is aligned to its September 12 accepted design; original historical evidence dates remain explicit.
