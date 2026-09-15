# In-process SDK language service, not JSON-RPC

## Context

The Change originally treated native queries as a future LSP-safe contract and listed JSON-RPC/clangd cloning as non-goals. The user then asked to replan so compile-time hosts can format Clang-style suggestions and inspect notes/fixes from the plugin SDK, without building a language-server process.

## Evidence

- Current `asSMessageInfo` / `WriteMessage` carries one section, row, column and string. Notes, carets and fix alternatives cannot be queried from that callback.
- The existing TypeScript language server mixes an independent parser with UE diagnostics that occupy a whole line (`character: 0..10000`) and have no source revision.
- Design already specified grouped diagnostics, Clang-inspired rendering, `asCSourceEditApplier` and `asCToolingSession`. Those are sufficient backends for an in-process facade.

## Options

- **A. In-process `asCLanguageService` in this Change:** attach a compilation diagnostic result, format groups, inspect structured notes/fixes, apply a selected alternative in memory. No JSON-RPC.
- **B. A plus a thin JSON-RPC subset in this Change:** didOpen/didChange, publishDiagnostics, codeAction and the four queries.
- **C. Leave this Change unchanged and open a later language-service Change.**

## Settled decision

The user accepted **A**. Completion, hover, definition and signature help stay on `asCToolingSession`. Feature bits for those queries are reserved on the language service and report unavailability. JSON-RPC, document scheduling, workspace index and the VS Code extension remain later work.

## Consequences and flip condition

Task 5.1 is the SDK facade. Task 1.2 owns Clang-style renderer text. Task 4.1 consumes the facade for format/fix round-trips. A later requirement for stdio/pipe LSP, VS Code behavior or workspace-wide discovery needs a separate adapter Change, not a widening of 5.1 into a server.

## Sources

- User confirmation to replan with in-process `asCLanguageService` only.
- Indexed talk `talk-20260905-221408-diagnostics-tooling-lsp-boundary.md` (LSP transport remains out of scope).
- `Extensions/AngelscriptVSCode/language-server/src/server.ts` diagnostic adapter.
