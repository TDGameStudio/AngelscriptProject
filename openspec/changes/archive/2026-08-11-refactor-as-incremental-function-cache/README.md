# Incremental Function Cache OpenSpec

This directory is the single active OpenSpec change for AngelScript Cache V2.
It retains the original change name and all frozen contracts while separating
current execution truth from historical implementation churn.

## Authorized implementation scope

All code under `Plugins/Angelscript` is in scope when Cache V2 needs it. This
explicitly includes the maintained AngelScript fork beneath
`Source/AngelscriptRuntime/ThirdParty/angelscript`: its builder/compiler,
bytecode, VM, module/function representation and restore internals may be
extended to provide a coherent cache capture, validation or restore seam. The
implementation is not restricted to an outer Runtime adapter. Existing
AngelScript syntax remains unchanged by default, but that compatibility goal
does not prohibit lower-level fork changes.

> Scope clarification recorded 2026-08-10: the complete Angelscript plugin is
> an authorized modification surface, including the maintained AngelScript
> sources themselves. If Cache V2 needs capabilities that the current lower-level
> API does not expose, implementation may extend or refactor that source instead
> of working around it outside the fork. Such changes remain requirement-driven,
> focused, tested, and progressively documented in this OpenSpec; they do not
> require a separate scope exception.

## Read order

1. `proposal.md` — product intent and compatibility boundary.
2. `specs/`, `record-wire-v1.md`, `record-wire-v1-remaining.md`,
   `manifest-pack-wire-v1.md`, `store-publication-v1.md`, matrices, authorities
   and golden vectors — normative behavior and bytes.
3. `design.md` — architecture and lifecycle decisions.
4. `vertical-execution-refactor-2026-08-09.md` — current Chinese execution
   decision separating direct source inputs, persisted candidates, module authority,
   per-function reuse and StaticJIT mapping while defining the V0–V7 checkpoints.
5. `cache-v2-flow-and-change-classification.md` — Chinese explanatory article
   covering end-to-end flow, record/store mechanics, `.as` change classification,
   stage boundaries, lifecycle and ASCII diagrams; non-normative.
6. `external-cache-design-research.md` — non-normative source-backed comparison
   with ccache, sccache, LLVM ThinLTO, Bazel/REAPI, UE DDC and SQLite, including
   the file/CAS-versus-SQLite storage recommendation and the explicit limit that
   mature action caches do not prove this project's function-level VM/JIT layer.
7. `cache-pack-staticjit-livecoding-notes.md` — Chinese non-normative design
   clarification covering aggregate Pack count and grouping, complete manifests
   versus patch replay, file/CAS versus SQLite implications, and the boundary
   between Cache V2, StaticJIT slices and UE Live Coding patch DLLs.
8. `status.md` — the only current progress/blocker authority.
9. `implementation-plan.md` — vertical execution handbook.
10. `tasks.md` — executable V0–V7 checklist.
11. `lessons-learned.md` — mandatory execution/review/test discipline.
12. `producer-b2-coverage-audit.md`, `workspace-source-manifest-b1.txt`,
   `implementation-issues.md`, `verification.md` and `reviews/` — the current
   producer gap map, explicit source snapshot, issues, evidence summaries,
   direct-interface golden recomputation and exact-SHA independent-review
   attachments.
13. `history/` — immutable, non-normative pre-refactor records, including the
    complete pre-vertical plan/tasks/status snapshot.

## Authority rule

When documents disagree, the frozen delta specs and their named wire/matrix/
authority attachments win, followed by `design.md`. The vertical decision and
execution documents never
silently revise wire bytes, error numbers, identity domains, ownership or
publication semantics. A discovered contract defect must be recorded explicitly
and corrected in its owning normative artifact.

## Current headline

Stable identity, shared function/content/profile coordinates and the seven-record
archive baseline are established. TypeSchema and the private remaining-record
codecs have focused GREEN evidence, while the complete real clean-module graph
transaction remains open. Deterministic aggregate Pack/Manifest plus the Win64
Saved Store's namespace lock, all-root reread/rebase, strict temp cleanup,
immutable publication and old-or-new pointer protocol are implemented through
V2.3. V2.4 has production pinned read sessions, cumulative fallback Budget,
fresh-versus-active Pending selection and matching-Pending cleanup after Current
promotion; explicit two-phase compaction remains open. Real cold/warm restore,
compiler reuse, lifecycle and package acceptance also remain open. Current execution follows V0–V7
vertical checkpoints and retains the final per-function compiler/StaticJIT goals.
See `status.md`.

Historical global ratios such as `15/67` or the later horizontal checkbox count are
preserved only in `history/`; they are not current progress measures.
