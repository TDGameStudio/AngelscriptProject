# clangd handles lexical diagnostics through the ordinary diagnostic path

English translation of angelscript/diagnostic-engine/findings/clangd-lexer-lsp.md, 2026-09-14. Evidence provenance is the inspected local LLVM 22.1.8 source, particularly clang-tools-extra/clangd. This export does not claim fresh online or runtime verification.

clangd has no separate lexical LSP interface. Lexer/LiteralSupport/PP::Diag feeds DiagnosticsEngine, StoreDiags::HandleDiagnostic, owned clangd::Diag values, toLSPDiags and publication. Lexical category metadata, CharSourceRange highlights and token/range conversion distinguish content, not transport.

For an unterminated literal, Clang's RAII DiagnosticBuilder immediately calls the diagnostic consumer. StoreDiags formats the message, obtains category, selects a range (caret-containing highlight, then fix range, then a token range), collects fix alternatives and associates subsequent notes. Diagnostics from the preamble and AST combine before publication. Component=Lex changes catalogue/category/code, not consumer identity.

clangd also groups notes, filters unrelated headers, can move header errors to include sites, converts ranges to UTF-16 and adds document version in its adapter. Completion/signature help use a separate cursor parse, not the diagnostic list. IncludeFixer, clang-tidy and include-cleaner are additional producers of the same output representation.

Clang recovers lexical errors and continues parsing/semantic analysis. AS likewise retains Invalid/Unterminated tokens and scans to EOF, but its prior Builder gate failed Lexed and prevented PP. Q17 now permits clean files' PP without adopting clangd's entire continued-analysis policy. AS IDs 1001–1006, token byte ranges and stage-owned diagnostics remain native data; later catalogue/fix support enriches them.

Reusable conclusion: collect lexical errors as ordinary structured diagnostics and translate at a later adapter boundary. Stage failure/recovery policy remains an AS product decision, not a consequence of LSP.
