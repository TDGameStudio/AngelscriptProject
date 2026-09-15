# Attachment Index

## Maintenance baseline — 2026-09-12

Read the current migration inventory and coverage replan before implementation. [Current-baseline maintenance](data/maintenance-20260912.md) records the earlier format/path-only update. It records current source ownership, preserved task state, exact format checks and remaining planning boundaries. Historical talks, research snapshots and applied replans are provenance rather than current API authority.

## Current position

Planning-only Change after the September 12 coverage replan; fourteen independently bounded pending outcomes. Product implementation has not started. `tasks.md` is the sole execution-state authority. Resume at `1.1` when apply is separately authorized.

## Hard conclusions and boundaries

- Extend the canonical engine-independent Builder and typed AST baseline. Do not revive the preserved legacy runtime, old frontend versions, or old tests.
- Cover all currently supported frontend diagnostic paths, including existing text-only errors and API/internal failure boundaries. Merely replacing generic diagnostic IDs is not complete migration.
- Keep specific source errors distinct from derived stage observations, diagnostic presentation policy, internal invariant failures, and recoverable API status returns.
- Implement diagnostics, native completion/signature/hover/definition queries, and an in-process `asCLanguageService` for compile-time format plus structured note/fix query. JSON-RPC, document scheduling, workspace indexing, and the existing TypeScript language server remain outside this Change. Load the in-process language-service architecture knowledge when tracing compile-time format/fix versus later LSP mapping.
- Use the real Parser/Sema and shared side-effect-free candidate assessment. Tool queries must not mutate formal compilation results or weaken definition-publication barriers.
- Retain UTF-8 byte offsets as source authority and expose explicit snapshot-bound position conversion. Do not fabricate source locations for source-less failures or host declarations without source.
- UE foundational types remain permitted; ordinary native frontend tests do not require creating an AS Engine. Do not introduce a nested `frontend` namespace, Standalone requirements, or removed `import`/`asset` syntax.
- Product verification will use bounded feature-group RED/GREEN and Harness-owned UE execution. Planning validation alone does not prove product behavior.

## Attachment index

- [data/diagnostic-migration-inventory-20260905.md](data/diagnostic-migration-inventory-20260905.md) — Preserved diagnostic migration inventory 20260905 — read when tracing predecessor history or superseded closure.
- [data/diagnostic-migration-inventory.md](data/diagnostic-migration-inventory.md) — Current producer families, exact reason/enum inventory, lossy boundaries, test owners, and mandatory branch-audit dispositions mapped to product tasks. Read when: Defining catalog coverage, migrating a producer family, or checking final coverage completeness.
- [data/maintenance-20260912.md](data/maintenance-20260912.md) — Preserved maintenance 20260912 — read when tracing predecessor history or superseded closure.
- [data/planning-validation.md](data/planning-validation.md) — Creation-only strict validation, scoped owner checks, original eight pending tasks, authoring checks and explicit unexecuted product/Git boundaries. Read when: Checking what creation verified before the language-service replan.
- [data/superseded-closure.yaml](data/superseded-closure.yaml) — Preserved superseded closure — read when tracing predecessor history or superseded closure.
- [data/supersession.md](data/supersession.md) — Preserved supersession — read when tracing predecessor history or superseded closure.
- `data/workflow-evaluation.md` — Preserved workflow evaluation — read when tracing predecessor history or superseded closure.
- [knowledges/in-process-language-service-architecture.md](knowledges/in-process-language-service-architecture.md) — Superseded: four-layer SDK model, compile-time attach/format/fix, ToolingSession queries, later LSP mapping; not promoted. Read when: Implementing 1.2/5.1/4.1 or designing a later protocol adapter without turning the facade into a server.
- [knowledges/native-diagnostics-and-tooling-boundaries.md](knowledges/native-diagnostics-and-tooling-boundaries.md) — Superseded: reusable grouping, cursor parsing, non-mutating assessment, lifetime and coordinate lessons; not promoted or product-verified. Read when: Implementing shared query foundations or planning future native-backed LSP integration.
- [replans/replan-20260905-160000-in-process-language-service.md](replans/replan-20260905-160000-in-process-language-service.md) — Applied DAG/spec update adding 5.1 and Clang-style compile-time SDK consumption. Read when: Inspecting why the original ninth node was added; the coverage replan preserves it.
- [replans/replan-20260912-073639-current-baseline.md](replans/replan-20260912-073639-current-baseline.md) — Preserved replan 20260912 073639 current baseline — read when tracing predecessor history or superseded closure.
- [replans/replan-20260912-075547-frontend-coverage.md](replans/replan-20260912-075547-frontend-coverage.md) — Preserved replan 20260912 075547 frontend coverage — read when tracing predecessor history or superseded closure.
- [talks/talk-20260905-160000-in-process-language-service.md](talks/talk-20260905-160000-in-process-language-service.md) — User-accepted replan: SDK facade for format/note/fix; JSON-RPC still out of scope. Read when: Implementing 5.1 or deciding whether a later protocol adapter is required.
- [talks/talk-20260905-221408-diagnostics-tooling-lsp-boundary.md](talks/talk-20260905-221408-diagnostics-tooling-lsp-boundary.md) — Accepted scope, Clang source evidence, rejected alternatives and the condition requiring a later adapter/index/cache Change. Read when: Rechecking why this native Change does not implement the existing extension or an LSP service.
