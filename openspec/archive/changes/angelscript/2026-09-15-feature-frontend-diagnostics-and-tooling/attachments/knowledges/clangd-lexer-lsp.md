# clangd lexer lsp

Status: candidate. Confirmed carryover on 2026-09-14 (Q10); not product-verified or promoted.

## Reusable Insight

Lexical diagnostics use the same structured output path as semantic diagnostics. Language recovery policy is independent of LSP transport.

## Evidence

The [English source finding](../drafts/findings/clangd-lexer-lsp.md) preserves inspected source rationale and accepted boundaries with original topic provenance. Creation does not claim execution evidence.

## Boundaries

This candidate explains decisions; canonical requirements and task completion remain in specs and tasks. Do not infer unimplemented APIs are present or transfer dormant-runtime behavior to the maintained frontend.

## Application

Apply when extending lexical diagnostics or planning native-backed adapters; do not infer clangd's complete recovery policy for AS.

## Sources

[Source finding](../drafts/findings/clangd-lexer-lsp.md) and [selected handoff](../drafts/handoff.md).
