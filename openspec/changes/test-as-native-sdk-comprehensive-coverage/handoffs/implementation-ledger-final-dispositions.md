# Implementation ledger final dispositions

Date: 2026-07-27

This handoff is the authoritative terminal disposition of every row that was
unchecked in `implementation-ledger.md` at review time. It is a planning-record
reconciliation, not a source-implementation count and not a build or runtime-test
claim. The historical checkboxes remain unchanged so the original sequence is
preserved.

## Relationship to the active checklist

`tasks.md` remains the concise authoritative closing checklist. At this review
state it contains 48 tasks: 39 complete and 9 open. A ledger row classified
`SupersededBy` may point to an active task that is still open. The historical
row no longer owns execution; the receiving task is not thereby complete.

The executable catalog and the 673/673 current-source SDK result are evidence
for their exact owners only. Neither is accepted as bulk proof for planned
assertion depth, StaticJIT parity, linked production ownership, physical source
organization, configured suites, or final records.

## Counts

| Final disposition | Rows |
| --- | ---: |
| `CompletedWithEvidence` | 86 |
| `SupersededBy` | 49 |
| `DeferredWithPrerequisite` | 14 |
| `StillActionable` | 10 |
| **Total** | **159** |

The mergeable row set is
`handoffs/implementation-ledger-final-dispositions.csv`. It has exactly one row
per historically unchecked ID and preserves the complete original ledger line.

## Disposition rules

- `CompletedWithEvidence` requires an exact authoritative task plus existing
  evidence records. Catalog/source presence or an aggregate green prefix alone
  is insufficient.
- `SupersededBy` requires a named task and a product family or audit that now
  owns the work. Open status is read from the receiving task.
- `DeferredWithPrerequisite` requires a source-backed issue or linked change
  and a concrete enable condition. Deferred products remain visible and are not
  current executable successes.
- `StillActionable` requires one exact remaining gate. These rows stay open
  until that gate is evidenced or explicitly transferred.

## ID groups

### CompletedWithEvidence — 86

`3.9; 4.3, 4.4, 4.6, 4.7, 4.8; 5.1–5.9; 6.14; 7.12; 8.17;
9.25; 10.15; 11.1–11.19; 12.11; 13.1–13.11; 14.1–14.10;
15.1–15.5, 15.7, 15.8; 17.3–17.6, 17.8, 17.10; 18.2, 18.7;
19.1–19.3; 20.0a, 20.2, 20.6, 20.8, 20.9; 21.1, 21.11f`

### SupersededBy — 49

`6.1–6.3; 9.21–9.24, 9.26; 10.2–10.7, 10.9–10.14; 12.1–12.9;
16.1–16.13; 17.1, 17.2, 17.7, 17.9; 20.10; 21.10, 21.11`

### DeferredWithPrerequisite — 14

`7.8, 7.9; 8.6b, 8.6b.5, 8.6c; 12.10; 15.6; 20.0f;
20.0c, 20.0d, 20.0e; 21.11a, 21.11c, 21.11d`

### StillActionable — 10

`18.9; 20.7; 20.11; 21.2–21.7; 21.9`

## Test depth that is genuinely not implemented or executable

1. Counted native-reference overwrite, null assignment, parameter/return,
   exception/frame cleanup, save/load compatibility, and equivalent StaticJIT
   lifecycle execution remain owned by
   `fix-as-reference-bytecode-ownership-persistence`.
2. A generated explicit-parameter object-last StaticJIT/AOT source has not
   executed. The generic AOT 10/10 result does not establish that ABI product.
3. `LANG-CTOR-TRANSFER` has Interpreter evidence for all 448 IDs, but no real
   StaticJIT raw/count-ref ownership execution.
4. Selected-2.38 property-accessor carriers still require normalized future
   declarations, a discoverable Disabled rebuild successor, and exact recovery
   ownership under `LANG-002`.
5. `RESTORE-018` still lacks a positive persisted execution path that actually
   emits `DestructScript`.
6. Assertion-depth has three prerequisite-backed Deferred products:
   `ENG-OBJECT-SERVICE-DELEGATE-LIFECYCLE`,
   `ENG-OBJECT-SERVICE-REFCAST-CONTRACT`, and
   `V238-DESIRED-BEHAVIOR`. They are not current positive execution evidence.
7. Production ownership and linked regressions remain open under tasks 2.6 and
   2.7. Module and Language closure remain under tasks 5.5 and 5.8. Configured
   suites and final static/documentation gates remain under tasks 6.5–6.7.

Physical source organization is delegated to living task 4.7 instead of being
frozen by this handoff. At the current source state its audit reports seven
remaining semantic splits:

- `Frontend/AngelscriptNativeParserCartesianDepthTests.cpp`
- `Frontend/AngelscriptNativeTokenizerDeepCoverageTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionEvaluationTests.cpp`
- `Language/References/AngelscriptNativeReferenceDirectionTests.cpp`
- `Language/References/AngelscriptNativeReferenceIdentityTests.cpp`
- `Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp`
- `Module/AngelscriptNativeModuleApiContractTests.cpp`

## Machine-readable contract

The CSV columns are:

`ledger_id, section, original_text, final_disposition, evidence_kind,
evidence_owner_task, evidence_product_ids, evidence_paths, superseded_by_task,
prerequisite_issue, prerequisite_change, enable_condition, remaining_gate,
verified_artifact, reviewed_at, review_note`.

Consumers must validate the category-specific required fields and treat
`tasks.md` as the current completion count. Historical checkbox counts are
preserved only for auditability.
