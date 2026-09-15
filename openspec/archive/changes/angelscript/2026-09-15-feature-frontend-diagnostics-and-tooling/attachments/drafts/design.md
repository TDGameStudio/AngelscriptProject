# Accepted design: diagnostic production, parallel lexing and native tooling

English translation of source topic angelscript/diagnostic-engine, design diagnostics-tooling-successor/design.md. Accepted 2026-09-14: Q9 diagnostics; Q12 combined scope; Q13–Q17 parallel Lex/PP; N3 identity; Q10/Q18 carryover and creation. No product implementation is authorized by this handoff.

## Problem

The predecessor angelscript/feature-frontend-diagnostics-tooling planned catalogues, groups, rendering, queries and an in-process asCLanguageService, but never entered product apply and did not provide a Diag production convention. This successor combines those accepted contracts with fragment-bound streaming diagnostics and parallel RunStage(Lexed), including same-thread preprocessing.

## Goals

- Each phase uses Diag() returning asCDiagnostic; operator<< fills structured payload and destruction writes into the current fragment. Submit remains an explicit phase barrier.
- Absorb as_diagnostic_catalog.def, groups, policy, caret/JSON rendering, position conversion, atomic fixes, all producer migration, shared assessment, four asCToolingSession queries and asCLanguageService.
- Establish lexical/PP Diag first, then parallel Lex with same-thread PP, then catalogue/groups, rendering/fixes, Sema/Session migration, the facade and queries.
- WorkerCount=1 retains successful-path token and diagnostic observations. If one file has lexical errors, clean files now retain PP products; this is an accepted change from the former global gate.
- Hosts consume only needed layers: logs may use IDs/ranges; suggestions use the native facade; JSON-RPC remains excluded.

## Exclusions

No product apply in this creation delivery. Supersede the predecessor only after the successor is fully created and planned. Preserve IDs 1001–1006, 2001–2014, 3002 and 3004–3007; do not introduce LLVM/TableGen, phase diagnostic/LSP inheritance, an engine-wide single in-flight slot, parallel declaration collection, a new stable identity contract, lock-free dictionaries or third-party concurrent maps. PP runs in the same worker behind a per-file gate, without a separate PP pool. Declaration work retains its collection barrier.

## Inherited and new boundaries

The predecessor contributes catalogue, groups, policy, rendering, position codec, edit applier, concrete producer causes, shared semantic assessment, native queries and the Format/GetGroups/ApplyFix facade. This topic contributes Diag/asCDiagnostic/operator<<, early lexical/PP migration, selective layer consumption, and X-by-K queued lexical/PP work with a locked session identifier table.

Read [parallel scheme](findings/parallel-lex-scheme.md), [same-thread PP](findings/parallel-pp-same-thread.md), and [module dependencies](findings/module-dependencies.md). The existing inventory and architecture rationale are carried evidence, not discarded planning history.

## Architecture

See [layer ownership](findings/architecture-stack.md) and the accepted production slice in [producer framework](findings/designs/producer-framework/design.md). Preserve all fourteen predecessor acceptance boundaries and add production plus parallel scheduling before catalogue/syntax migration, so the catalogue does not establish another generation of hand-filled records.

## Vocabulary and naming

| Role | Accepted name or boundary |
|---|---|
| Phase production function | Diag (N2) |
| Move-only RAII diagnostic | asCDiagnostic (N1d) |
| Initial streaming values | Argument, FixIt, RelatedRange, FStringView, int64, bool (Q8); no initial Note overload |
| Successor | angelscript/feature-frontend-diagnostics-and-tooling (N3) |
| Predecessor closure | superseded, with this successor as superseded_by |

The initial no-Note streaming boundary does not remove notes from the inherited full group/tooling contract.
