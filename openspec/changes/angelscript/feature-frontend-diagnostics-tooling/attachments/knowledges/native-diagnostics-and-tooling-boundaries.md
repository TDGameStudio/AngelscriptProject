# Native diagnostic and semantic-tooling boundaries

## Reusable insight

Clang-style diagnostic quality and clangd-style editing share semantic facts but have different output and execution boundaries. A language frontend should expose structured diagnostics and reusable semantic assessment before an editor protocol adapter is introduced.

- Keep one primary diagnostic associated with its notes and fix alternatives. A flat sorted collection can destroy explanation relationships, especially across files.
- Completion needs the parser's context at the cursor. A finished AST is valuable for hover/navigation but is not a substitute for local scope, incomplete call and member-access state.
- Candidate probing and committing conversions/defaults are different operations. A tooling query must not change the formal compilation result while trying possibilities.
- One root result must retain AST, source/token/identifier storage, type context and external semantic dependencies. Retaining source alone cannot keep AST or host function references alive.
- Error-tolerant inspection must remain separate from valid compilation/publication. A recoverable typed graph is useful without claiming it is executable.
- Internal UTF-8 offsets, editor UTF-16 coordinates, display columns and client document versions are distinct. Convert at explicit boundaries and bind results/edits to their actual immutable input.

## Evidence

Clang 22.1.8 `Diagnostic.h`/`Diagnostic.cpp` provide parameterized messages and note/policy sequencing. clangd `Diagnostics.h::Diag` retains Notes/Fixes, and `ParsedAST` retains frontend owners. `SemaCodeCompletion.h` and clangd `CodeComplete.cpp` supply cursor-driven semantic callbacks; `SourceCode.h` supplies encoding conversion at the editor boundary.

Current AS inspection demonstrates why these distinctions matter: source-only diagnostic ownership, generic semantic messages, lost candidate reasons, mutable call-resolution paths and snapshot-local handles already exist. The independent TypeScript LSP currently uses a different position and semantic model. These observations motivate the proposed architecture; the new AS behavior has not yet been implemented or verified.

## Boundaries and application

Apply when implementing this Change's diagnostic/result/candidate/query contracts or planning the later native-backed LSP adapter. For the AS four-layer SDK split (compile attach versus cursor query versus later JSON-RPC), load `in-process-language-service-architecture.md`. Do not infer a requirement to link LLVM, copy all Clang internals, restore C++ preprocessing/import behavior, build a server, add a workspace index or activate the dormant runtime.

Explicit group storage is an AS design adaptation inspired partly by clangd; Clang's diagnostic engine itself emits an ordered stream. Source content hashes are revision hints, not cryptographic authority. JSON adapters must preserve 64-bit revisions and fixed stable keys without JavaScript-number loss.

Status: **candidate**. Promote only after the corresponding AS implementation and regression evidence establish reusable guidance. No current capability knowledge or project instruction is changed by this planning delivery.

## Sources

- Versioned local reference: `D:/LLVM/llvm-project-22.1.8.src/clang/{include/clang/Basic,include/clang/Sema,lib/Basic,lib/Sema}` and `clang-tools-extra/clangd`.
- [clangd feature and infrastructure walkthrough](https://clangd.llvm.org/design/code).
- Current AS evidence: this Change's indexed diagnostic migration inventory and native frontend headers/implementations named there.
