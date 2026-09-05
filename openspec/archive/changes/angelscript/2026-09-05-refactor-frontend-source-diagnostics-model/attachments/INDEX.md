# INDEX

## Current position

All four tasks are complete. The immutable source/provenance model, deterministic diagnostic engine, 11/11 focused proof, CLI-created frontend identities, durable contract, and promoted knowledge are ready for completed closure.

## Hard conclusions

- Keep explicit snapshot-local `(FileID, UTF-8 byte offset)` locations and half-open ranges.
- Root frontend products own one immutable snapshot lease; nodes store ranges, not per-node manager or preprocessing pointers.
- Diagnostics are structured, engine-independent, and deterministically ordered before rendering.

## Forbidden

- Do not copy Clang raw location packing, treat line numbers as stable identity, or persist snapshot-local IDs.
- Do not route the new source model into the current production frontend during this Change.

## Attachment index

- `data/completed-closure.yaml` — explicit completed disposition consumed by the deterministic OpenSpec archive operation.
- `talks/talk-20260905-010100-source-coordinate-and-diagnostic-boundary.md` — rationale for adopting Clang's layering without its raw encoding — read before defining source handles or diagnostic presentation.
- `knowledges/clang-source-provenance.md` — promoted into `openspec/specs/angelscript/language/frontend/source-diagnostics/knowledges/clang-source-provenance.md`; the attachment remains the Clang source-evidence provenance.
- `implementation/issue-20260905-023432-ubt-duplicate-source-basename.md` — resolved UBT input-planning issue proving that the new manager implementation unit needs a unique basename while the old source remains preserved.
- `replans/replan-20260905-023432-unique-source-manager-implementation.md` — applied path-only Replan preserving the public source-manager API and old production implementation — resume Task `1.1`.
- `replans/replan-20260905-023915-source-manager-query-ownership.md` — applied Task `1.2` ownership correction adding the SourceManager query facade to the snapshot/provenance work — resume Task `1.2`.
- `implementation/issue-20260905-024820-missing-frontend-domain.md` — resolved OpenSpec identity issue proving the shared frontend domain must precede its first capability.
- `replans/replan-20260905-024820-create-frontend-domain.md` — applied Task `3.1` correction adding CLI-owned parent-domain registration before capability creation — resume Task `3.1`.
- `data/source-diagnostics-verification.md` — RED/GREEN runs, final 11-test report, source hashes, and impact boundary for completion and closure.
- `data/workflow-evaluation.md` — canonical completed-closure evaluation written last against the final active Change digest.
