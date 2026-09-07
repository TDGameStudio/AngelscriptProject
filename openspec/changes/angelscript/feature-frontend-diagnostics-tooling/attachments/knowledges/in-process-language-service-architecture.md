# In-process language service architecture

## Reusable insight

This Change's "LSP-shaped" product is a **library**, not a language-server process. Clang-style suggestions are produced by Parser/Sema, stored on diagnostic groups, formatted and queried in-process, and only later (a different Change) translated to JSON-RPC.

```
╔══════════════════════════════════════════════════════════════════╗
║  Host: CQTest, compile log, UE editor, later VS Code adapter     ║
╠══════════════════════════════════════════════════════════════════╣
║  4. Protocol (NOT this Change)                                   ║
║     JSON-RPC / stdio / didOpen / publishDiagnostics / codeAction ║
╠══════════════════════════════════════════════════════════════════╣
║  3. asCLanguageService   SDK facade (task 5.1)                   ║
║     AttachCompilation, GetGroups, Format, ApplyFix               ║
║     Feature bits: Diagnostics | Fixes  (queries reserved)        ║
╠══════════════════════════════════════════════════════════════════╣
║  2. Presentation and edits                                       ║
║     asCDiagnosticRenderer, JSON, asCSourcePositionCodec,         ║
║     asCSourceEditApplier                                         ║
║     asCToolingSession / asCAnalysisResult  (cursor queries)      ║
╠══════════════════════════════════════════════════════════════════╣
║  1. Language authority                                           ║
║     Lexer/PP/Parser/Sema/Builder → asSDiagnosticGroup            ║
║     typed AST, asCTypeContext, frozen MetadataImage              ║
╚══════════════════════════════════════════════════════════════════╝
```

Compile-time consumption (this Change, no editor):

```
asCBuilder stages
      │  producers fill Groups (cause, args, notes, optional fixes)
      ▼
asCDiagnosticResult + source snapshot
      │  AttachCompilation  (borrow, do not copy the graph)
      ▼
asCLanguageService
      ├─ Format(group)     Clang-style text: error + caret + did-you-mean note
      ├─ GetGroups/notes   typed args, ranges, keys  (do not parse the text)
      └─ ApplyFix          new snapshot; original result unchanged
               │
               ▼
         caller may Builder/Analyze the new snapshot
```

Editor-style queries stay on a second facade in the same SDK:

```
asSAnalysisInputs  (snapshot, options, type context, frozen host images)
      │
      ▼
asCToolingSession::Analyze  →  owned asCAnalysisResult
      │                         FreezeForTooling ≠ DefinitionsFrozen
      ├─ Complete / GetSignatureHelp   isolated cursor Parser/Sema
      └─ GetHover / FindDefinition     retained typed graph
```

`asCLanguageService` does not wrap those query methods in this Change. Reserved feature bits report unavailability instead of a successful empty list.

A later native-backed adapter maps without a second Sema:

| Native | Later LSP |
|---|---|
| `GetGroups` + `Format` | `textDocument/publishDiagnostics` + `relatedInformation` |
| `ApplyFix` alternatives | `textDocument/codeAction` (quickfix) |
| `Complete` | `textDocument/completion` |
| `GetSignatureHelp` | `textDocument/signatureHelp` |
| `GetHover` | `textDocument/hover` |
| `FindDefinition` | `textDocument/definition` |
| UTF-8 bytes + `asCSourcePositionCodec` | LSP UTF-16 `Position` + document version |
| source content revision | not the client `version` field |

The existing TypeScript language server is not this stack. It has an independent parser/type database and currently turns UE messages into whole-line ranges. A future adapter replaces that semantic backend; it does not enable the old socket.

## Evidence

- Settled replan: in-process `asCLanguageService` for format/note/fix; JSON-RPC excluded (`talk-20260905-160000-in-process-language-service.md`).
- Design API sketches for `asCLanguageService`, `asCDiagnosticRenderer` and `asCToolingSession`.
- Clang 22 / clangd split: Sema produces notes and Fix-Its; clangd stores groups and speaks LSP. This knowledge copies that split into AS SDK layers.
- `Extensions/AngelscriptVSCode/language-server/src/server.ts` still builds diagnostics from a string plus a full-line range.

This architecture is planning truth. Product objects named above are not yet implemented.

## Boundaries and application

Apply when implementing 1.2 (renderer text), 5.1 (facade), 4.1 (attach → format → apply → re-analyze), or planning a later protocol adapter.

Do not:

- Put JSON-RPC, document sync, a scheduler, or a workspace index in `asCLanguageService`.
- Parse formatted English to recover cause, notes or fixes.
- Copy diagnostic groups into a second authority inside the facade; attach the compilation result.
- Treat `FreezeForTooling` as permission to freeze definitions or register a MetadataImage.
- Create an `asCScriptEngine` for ordinary frontend tests or language-service calls.
- Use the TypeScript server as a fallback semantic provider.
- Promote this file until implementation and regression evidence exist.

Status: **candidate**.

## Sources

- This Change: `design.md` language-service and tooling-session sections; tooling and source-diagnostics delta specs.
- Talks: `talk-20260905-221408-diagnostics-tooling-lsp-boundary.md`, `talk-20260905-160000-in-process-language-service.md`.
- Sibling candidate: `native-diagnostics-and-tooling-boundaries.md` (Clang grouping, cursor parse, assess-versus-commit).
- clangd code walkthrough: https://clangd.llvm.org/design/code
