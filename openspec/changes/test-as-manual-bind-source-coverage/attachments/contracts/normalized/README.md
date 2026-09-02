# Normalized Contract V2 planning ledger

This directory is the machine-readable source for the exhaustive OpenSpec `tasks.md` review projection. It is planning evidence only; it is not a substitute for the later reviewed sidecars under `TestSource/Generation/Contracts/**`.

## Inputs

- `../audit-coverage-reconciliation.json` is the canonical 3,041-source / 11,987-current-callable identity ledger.
- The domain audit JSON/Markdown files in the parent directory provide initial proposals and evidence.
- `../../implementation/tarray-contract-v2-audit.md` and `../containers-tarray-contract-audit.json` provide the two TArray designs.
- `../../implementation/high-risk-lifecycle-audit.md` supplies lifecycle, GC, ProcessEvent, DefaultComponent, timer, delegate, NewObject, Blueprint, and HotReload corrections.
- Domain resolution supplements replace raw audit candidates where owner, semantic name, declaration, vector, fixture, coverage, or line-map evidence required correction.

## Outputs

- `manifest.json`: input hashes, plan revision, exact counts, status/blocker counts, domain JSONL hashes, and generated `tasks.md` hash.
- `<Domain>.jsonl`: one normalized row per proposed callable or source-only assertion.
- `plan-row-schema.json`: Draft 2020-12 row schema.

## Invariants

1. The current identity ledger contains exactly 3,041 source paths and 11,987 unique pre-edit callable identities.
2. Every current callable has at least one explicit disposition. A split emits multiple replacement rows; a retire disposition names its replacement group.
3. Every proposed callable has a stable CaseId/subcase, owner, semantic name, exact annotation-plus-declaration block, immediate English comment, typed parameters/result/writebacks, concrete vectors, body plan/prohibited calls, fixture/cleanup, coverage, status, blocker list, literal commands, and provenance hash.
4. Every zero-callable source has one or more source assertions and no fabricated callable.
5. A blocked proposal still contains the exact candidate declaration being reviewed; the blocker names the missing evidence and resolution task. Placeholders, `VariantNN`, `ObservedConditionNN`, ellipses, and generic diagnostics are forbidden.
6. `runner-blocked` is orthogonal to design review and never implies compile/runtime/external PASS.
7. `tasks.md` contains one checkbox per normalized proposed callable/source assertion and one verification checkbox per source.
8. A second generation/check is byte-identical. Source hash drift, row hash drift, missing fields, duplicate identities, unresolved raw audit pointers, or count drift fails closed before writing outputs.

## Review lifecycle

The first complete ledger is `plan-v1` and remains `review-ready` or explicitly blocked. User acceptance records the accepted row hashes and produces a new manifest state; it does not itself modify `TestSource`. Later implementation agents may edit a source only when all normalized rows for that file are accepted and the pre-edit source hash still matches.
