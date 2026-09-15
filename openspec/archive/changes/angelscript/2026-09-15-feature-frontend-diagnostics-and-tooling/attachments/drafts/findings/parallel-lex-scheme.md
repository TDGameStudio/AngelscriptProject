# Accepted queued parallel Lex and same-thread PP

English translation of angelscript/diagnostic-engine/findings/parallel-lex-scheme.md, 2026-09-14. Q12 combines this with diagnostics/tooling; Q13–Q17 accept the scheme.

## Outcome and scheduling

Replace the sequential per-file RunStage(Lexed) loop with X fixed workers that repeatedly take at most K unprocessed files from a shared queue. X uses WorkerCount; X=1 executes on the calling thread. K is a new configurable option, default 4, at least 1. Do not dispatch one TaskGraph task per file, use ParallelFor over files, or reuse body's static i, i+X stride.

Queue locking only protects work acquisition. A second lock protects the session identifier table. K reduces queue-lock operations, not Intern operations. Optional keyword/reflection-spelling pre-interning may reduce worker misses; successful single-worker observable counters remain controlled.

```text
Builder prepares immutable sources and the work queue   // Shared inputs
└─ X workers repeatedly pop up to K files               // Queue lock
   └─ File-local tokenizer / stream / raw tokens        // Private state
      ├─ Intern into the session table                  // Independent table lock
      └─ Lex → Flush → per-file gate → Process          // PP owns its own table
         └─ Store results in worker-local arrays        // No concurrent State.Add
join and merge by LogicalSourceKey                     // Deterministic products
└─ Record overall success/failure                       // Keep clean PP products
```

## Identifier ownership

Use the single asCBuilderState::Identifiers table. Equal spellings yield the same asCIdentifierInfo pointer. Start with FCriticalSection around Intern; read/write locks or hash sharding are later evidence-driven tuning. Do not use FName, a third-party concurrent map, lock-free intern, per-file lexical tables or per-worker tables followed by pointer repair. Identifier cards represent spelling/classification, not semantic type or stable identity. PP continues to create its own IdentifierOwner and re-intern its output.

Tokenizer, stream, RawTokens and lexer fragment are file-private. SourceManager is shared read-only. Diagnostic Submit already serializes merge. Declaration collection and asCStableIdentityRegistry remain outside the parallel slice; body scheduling is unchanged.

## Failure and observability

Lexical 1001–1006 recover to EOF; Lex()==false is a distinct hard failure. Both block PP only for that file. Workers continue claiming the remaining work after a failure, join, then report overall failure. A clean file may finish PP even when another file fails. Overall HasErrors is not the per-file PP gate. PP validity participates in overall success.

Worker-local lexical and PP products are merged on the calling thread and ordered by LogicalSourceKey. Successful X=1 projections match the prior sequential behavior; error-path continuation and per-file PP are intentional changes. A source lookup failure also needs a recorded failed work item rather than dropped work.

## Verification boundary

Compare X=1/4 and K=1/4 token and diagnostic projections; check equal-spelling pointer identity, retained owner lifetime, and deterministic file membership. Verify hard failure leaves other files' tokens/diagnostics, recoverable lexical error skips only that file's PP, and clean PP results survive. Measure performance before changing the lock strategy; no unmeasured speedup is promised.

Implementation order is Q16: first lexical/PP Diag migration, then this scheduler.
