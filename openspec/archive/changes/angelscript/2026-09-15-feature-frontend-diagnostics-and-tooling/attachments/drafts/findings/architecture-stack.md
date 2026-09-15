# One diagnostic foundation, selectively consumed layers

English translation of source finding angelscript/diagnostic-engine/findings/architecture-stack.md, 2026-09-14. Q3/Q4/Q1 settled the boundaries; Q5's diagram was incorporated into Q9. Earlier separate planning scopes are now absorbed by the successor.

A built-in language service does not make the tokenizer speak JSON-RPC or require every compilation to execute completion/hover. Lower layers produce structured diagnostics; hosts select the consumers they need.

```text
Future JSON-RPC / stdio / document synchronization     // Later adapter, excluded
└─ asCLanguageService                                 // Format, GetGroups, ApplyFix
   └─ Catalogue / rendering / atomic edits             // Structured causes and presentation
      └─ Diag → fragment → diagnostic engine           // Lexer, PP, Parser→Sema, Session
         └─ Source snapshots and byte ranges           // Existing source authority
```

The facade enables DIAGNOSTICS and FIXES; query features remain unavailable there, while ToolingSession owns the four native queries. CQTest and logs can observe IDs, ranges and stable projections. Compile-time suggestions use Format and ApplyFix without document events. A later editor adapter translates the native products without adding another semantic authority.

The production slice stabilizes Diag call sites before catalogue and group enrichment. The former tooling plan supplies catalogue, renderer and facade. Lexical IDs 1001–1006 remain stable. Tokenization already recovers to EOF and retains invalid/unterminated tokens in one explicit lexer fragment; Diag adds a uniform production convention. AST/Sema then use the same convention with their own positions and recovery nodes. Ordinary phase composition replaces no class with a diagnostic or LSP base interface.
