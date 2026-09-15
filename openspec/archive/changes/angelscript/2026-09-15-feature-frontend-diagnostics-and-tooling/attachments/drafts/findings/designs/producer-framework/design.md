# Accepted production slice incorporated into the successor

English translation of the selected successor's cited source angelscript/diagnostic-engine/designs/producer-framework/design.md. The standalone source retained a candidate label, but its Q1/Q4/N2/Q8/N1d decisions were incorporated into Q9's successor approval; it has no independent Change handoff.

## Problem and outcome

Current producers hand-fill asSDiagnosticRecord; Parser forwards recovery strings and Session can create one fragment per diagnostic. Engine ownership already flows from the top. Stabilize one production convention so a new diagnostic specifies location, ID and arguments rather than duplicating record construction. Preserve concurrent Submit and deterministic ordering.

The initial slice does not implement the facade, JSON-RPC, all semantic catalogue migrations, an engine single in-flight slot or LLVM/TableGen. The complete successor separately owns catalogue/groups, notes and facade. A later immediate listener is not part of this slice.

## Composition and flow

```text
asCDiagnosticsEngine                           // Merge and EmitTo authority
└─ asCDiagnosticFragment                       // Phase/work-item bucket
   └─ Diag(Range, ID) → asCDiagnostic           // Move-only reporting obligation
      ├─ operator<< fills payload               // Arguments, fixes, related ranges, scalars
      └─ destructor reports into the fragment  // No immediate consumer dispatch
```

Tokenizer/Preprocessor/Sema use ordinary Diag members; Parser forwards Token/Range to Sema and does not own a fragment. Session/Builder use the current work-item fragment, never one fragment per record. asIDiagnosticConsumer remains the consumer polymorphic seam. Phases do not inherit diagnostic/LSP interfaces.

Tokenizer opens its lexer fragment at construction and submits at FlushDiagnostics. Preprocessor opens a fragment per Process and submits at its end. Sema uses BeginFragment/EndFragment. Explicit Flush/EndFragment/Process completion remains the submission barrier; fragment destruction does not implicitly submit.

## Payload and extensibility

Initial records retain ID, severity and primary range. Diag without operator<< is valid. The initial stream set is Argument, FixIt, RelatedRange, FStringView, int64 and bool; Note is introduced with full group support rather than invented in this first slice. See [streaming details](../../streaming-diag-how.md).

The original sequence established lexical/PP production first, then catalogue/default severity/format/groups, then rendering and nonlocated failures. Q12–Q17 insert parallel Lex/PP between production and catalogue. Optional immediate listeners remain later work; EmitTo remains snapshot authority.

## Failure and verification

A diagnostic targeting an already flushed/empty fragment must not emit; debug assertions may enforce misuse. Invalid ranges fail as Fragment.Report does, without silently becoming nonlocated. Concurrent workers use distinct fragments. Collector Reset semantics remain unchanged initially.

Proof includes lexical ID 1005 with the same range/stable projection, two fragments submitted in either order with the same merged result, and Parser recovery IDs/ranges once its migration task runs. The intended file remains as_diagnostics.h in Basic, with no new phase directory.
