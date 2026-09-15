# Fragment-bound Diag and streaming payload

## Context

The engine already has top-down ownership and parallel fragment merge, but producers repeat record assembly. Parser forwards strings; Session can emit one fragment per record.

## Evidence

Accepted topic angelscript/diagnostic-engine, Q1/Q4/N2/Q7/Q8/N1d, incorporated into Q9. See [production slice](../drafts/findings/designs/producer-framework/design.md) and [streaming](../drafts/findings/streaming-diag-how.md).

## Options

Immediate engine-wide reporting would introduce a single in-flight diagnostic model. Per-record fragments discard phase ownership. Stage interface inheritance adds a virtual dependency unrelated to result consumption. The chosen approach reuses phase-local fragments with a move-only reporting object.

## Settled Decision

Diag returns asCDiagnostic. A stream accepts Argument, FixIt, RelatedRange, FStringView, int64 and bool. It supports no-stream diagnostics and temporary chaining. Destruction reports once into the current fragment, while explicit phase Flush/EndFragment submits the bucket. Parser forwards to Sema; stages use ordinary members. asIDiagnosticConsumer remains the result consumer seam. Initial streaming excludes Note; inherited groups still support notes.

## Consequences and Flip Condition

Lexical/PP production migrates before scheduler changes. Payload ownership must survive the full expression, moves and eventual Submit. Catalogue enrichment later preserves the call shape. Revisit only if concrete lifecycle evidence prevents safe fragment-bound reporting; do not import Clang's single-slot ownership by analogy.

## Visual

```text
Phase.Diag → asCDiagnostic            // Bound to its current fragment
└─ operator<< → destructor           // Own payload, report once into bucket
   └─ Explicit Flush → Submit        // Barrier, then deterministic merge
```

## Sources

[Accepted design](../drafts/design.md), [accepted names](../drafts/glossary.md), and the cited production/streaming exports. The local source conversation remains outside the Change.
