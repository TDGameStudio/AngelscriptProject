Source: angelscript/diagnostic-engine; selected design: diagnostics-tooling-successor; accepted 2026-09-14 (Q9, Q12–Q17, N3, Q10 and Q18).

# Confirmed OpenSpec handoff

Faithful English export of the selected handoff.md. Q18 confirmed the additional three knowledge candidates and authorized creation/planning. Product implementation is not authorized by this handoff.

## Problem

Unify frontend diagnostic production, inherit the complete diagnostics/native-tooling contract of the unimplemented predecessor, and execute each file's Lex and PP in the same worker.

## Success Criteria

- Diag returns asCDiagnostic with initial Argument/FixIt/RelatedRange/FStringView/int64/bool streaming. RAII completion reports into a fragment; phases explicitly submit fragments.
- X uses WorkerCount; K is configurable, default 4, minimum 1. Fixed workers take batches from a shared queue. X=1 runs on the calling thread.
- The session identifier table uses an independent FCriticalSection. Equal spellings retain equal Info pointers; queue and dictionary locks are distinct, and identifier pointers are not stable semantic identities.
- Each file reaches PP on the same thread only if its own Lex had neither a lexical Error nor a hard failure. Other work continues after either failure, workers join, and compilation fails overall. Clean PP products remain available.
- Catalogue/groups/policy, caret/JSON, position codec, atomic fixes, full producer migration, shared assessment, four ToolingSession queries and LanguageService have explicit task and test coverage.

## Evidence

The [accepted design](design.md) and [glossary](glossary.md) record Q9 diagnostics, Q12 combined scope, Q13–Q17 parallel boundaries and N3 identity. Its incorporated [production slice](findings/designs/producer-framework/design.md) requires no second approval.

See [parallel scheme](findings/parallel-lex-scheme.md), [same-thread PP](findings/parallel-pp-same-thread.md) and [module dependencies](findings/module-dependencies.md). The predecessor's fourteen unchecked task boundaries and six capability deltas are preserved in the successor planning records. Current as_builder.cpp::RunStage separates Lexed/Preprocessed and uses the session identifier table plus global HasErrors, so scheduling, stage execution and result submission require adaptation.

## Scope and Exclusions

The selected scope combines diagnostics, parallel Lex/PP and native tooling; there is no separate production Change. Preserve IDs 1001–1006, 2001–2014, 3002 and 3004–3007. Exclude JSON-RPC, extension migration, workspace indexing, parallel declaration collection, stable-identity reconstruction, lock-free/third-party maps, LLVM/TableGen and dormant runtime/test activation.

Creation/planning does not authorize product apply, UE execution or Git operations. This request replaces prior temporary instructions not to create. Q6 authorizes superseding the old Change once the successor is fully materialized.

## Constraints

Implementation belongs in Plugins/Angelscript. The diagnostic engine owns merging/policy; asIDiagnosticConsumer remains the consumer virtual seam. Phase composition is ordinary membership, Parser forwards to Sema, and source authority stays snapshot-bound UTF-8 byte ranges.

## Options

Accepted: one successor, fragment-bound RAII production, a locked session table, batched queue, same-thread PP and a per-file gate. Rejected: separate concurrent Changes, immediate single-slot engine emission, per-file TaskGraph jobs, static worker stride, per-worker intern tables with pointer repair, and a separate PP pool.

## Decision and Rationale

Migrate lexical/PP Diag first, then scheduling, then catalogue/groups and consumers. A stable producer protocol limits the scheduling change to concurrency and synchronization. PP has no inter-file input prerequisite; later declaration collection retains a join barrier.

## Flip Condition

Replan if evidence proves an unmodelled mutable PP dependency, an incompatible public stage contract that cannot support the accepted early PP observation, or invalid shared identifier lifetimes. Lock tuning needs measured evidence; an exploratory FRWLock suggestion does not replace Q13.

## Architecture, Components, and Data Flow

```text
Builder session                           // Owns source, diagnostics and identifiers
└─ X workers claim K-file batches          // Queue and dictionary locks are independent
   └─ Lex → local gate → same-thread PP    // Private fragment and result storage
      └─ Join, sort, merge and decide      // Retain clean-file PP products
         └─ Later declaration/semantics   // Preserve completeness and publication gates
```

Diagnostics flow from Diag through RAII fragment write and explicit Submit to owned groups/results, then rendering, edits and LanguageService. ToolingSession uses real Parser/Sema for four queries without mutating formal compilation results.

## Failures and Edge Cases

Distinguish recoverable lexical diagnostics from Lex()==false, but both prevent only their own file's PP. Hard failure does not stop other acquisition. PP failure clears its own ActiveTokens and fails the overall operation. Workers never concurrently Add to State.Inputs or Preprocessed; merge and ordering occur after join.

Display suppression does not erase failure facts. The PP gate uses local lexical facts rather than global HasErrors. RAII reporting does not imply fragment submission. Successful single-thread observations remain compatible; continued work after failure and local PP gating are deliberate changes. Early PP must not repeat at the later public stage transition; planning/tests cover observable stage adaptation.

## Verification

Creation checks structural OpenSpec validity, attachment audit, English export, link closure, and requirement-to-task coverage. It does not prove product behavior.

Each bounded task owns an exact Harness proving command and grouped RED/GREEN cases. Cover production lifetime/argument ownership/explicit submission; X=1/4 and K=1/4 token/diagnostic/PP projections; shared spelling pointers; recoverable errors, hard failures and PP failures; retained clean products; no duplicate PP; and all inherited fourteen task acceptance boundaries. Heavy verification is selected by impact, not made a creation gate.

## OpenSpec Handoff

- Source identity: angelscript/diagnostic-engine/designs/diagnostics-tooling-successor.
- Target: angelscript/feature-frontend-diagnostics-and-tooling (N3).
- Title: Frontend diagnostics, parallel lexing and native tooling.
- Capabilities: inherit six predecessor deltas and extend lexing/builder concurrency and stage-failure contracts.
- Required artifacts: English source exports and referenced findings, confirmed talks/knowledge, migration inventory, proposal/specs/design/tasks and planning evidence.
- Task boundaries: production and lexical/PP migration; parallel Lex/PP; catalogue/groups; position conversion; renderer/fixes; syntax/semantic/Builder migration; shared assessment and query preparation; facade; queries; integrated proof. Preserve predecessor acceptance boundaries without mechanically freezing its dependency graph.

## Exploration Carryover

Confirmed Q10: two historical talks, two new talks (production and supersession), five knowledge candidates and migration inventory. Confirmed Q18: three more knowledge candidates. All source/target/reason entries are in [confirmed carryover](findings/carryover-candidates.md). No transcript, sibling exploratory research, old replans or obsolete inventory is imported. Candidates remain change-local and unverified; none is promoted to current specs by creation.
