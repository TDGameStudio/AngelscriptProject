# Confirmed exploration carryover

English export of angelscript/diagnostic-engine/findings/carryover-candidates.md. Q10 accepted the original package; Q18 accepted the three later parallel/PP candidates and creation on 2026-09-14.

| Source provenance | Target relative to attachments | Reason |
|---|---|---|
| Predecessor talk-20260905-160000-in-process-language-service.md | talks/talk-20260905-160000-in-process-language-service.md | Preserve accepted in-process facade |
| Predecessor talk-20260905-221408-diagnostics-tooling-lsp-boundary.md | talks/talk-20260905-221408-diagnostics-tooling-lsp-boundary.md | Preserve exclusion of extension/LSP service |
| Topic Q1/Q4/N2/Q7/Q8/N1d and production/streaming findings | talks/talk-20260914-131000-diagnostic-production.md | Prevent re-decision of fragment binding, name and streaming |
| Topic Q6/N3 and successor finding | talks/talk-20260914-131001-successor-scope.md | Preserve replacement and superseded closure rationale |
| Predecessor in-process-language-service-architecture.md | knowledges/in-process-language-service-architecture.md | SDK layers and facade ownership |
| Predecessor native-diagnostics-and-tooling-boundaries.md | knowledges/native-diagnostics-and-tooling-boundaries.md | Groups, cursor parsing and coordinates |
| findings/architecture-stack.md | knowledges/architecture-stack.md | Selective layer consumption |
| findings/streaming-diag-how.md | knowledges/streaming-diag-how.md | AS streaming adaptation without Clang single-slot engine |
| findings/clangd-lexer-lsp.md | knowledges/clangd-lexer-lsp.md | Ordinary lexical diagnostics; distinct recovery policy |
| findings/parallel-lex-scheme.md | knowledges/parallel-lex-scheme.md | Queued workers and two locks |
| findings/parallel-pp-same-thread.md | knowledges/parallel-pp-same-thread.md | Local PP gate and stage barrier |
| findings/module-dependencies.md | knowledges/module-dependencies.md | Dependency graphs do not schedule Lex/PP |
| Predecessor current diagnostic-migration-inventory.md | data/diagnostic-migration-inventory.md | Producer coverage and reserved IDs |

Excluded: the full log, comparison-only investigations, redundant LSP findings, naming diary, historical replans, obsolete September 5 inventory and old planning-validation. Current planning evidence is written afresh.
