# Harness Core Knowledge Index

- [Workspace Query Cost and Freshness](query-performance.md)
  - Summary: Remove repeated root resolution inside a query while retaining live identity/configuration checks; compare native-call counts and bounded before/after timings.
  - Serves: Persistent PowerShell dispatch, workspace status cost and evidence-based performance tuning.
  - Source: 2026-09-19 direct authorized maintenance, before commit `87d93ed8`, isolated Git/OpenSpec fixtures and `WorkspaceQueryPerformance.Tests.ps1`.
  - Status: current; timings describe the recorded local samples, not a service-level guarantee

- [Active Change Registration Checkpoint](change-registration-checkpoint.md)
  - Summary: Resolve one exact Git-registered WorkspaceRoot, canonical active Change, and Ready task before implementation, with an honest recovery path when registration was missed; Codex `/goal` is continuation only.
  - Serves: Unified workspace context, two-tier exploration, and OpenSpec-scoped execution readiness.
  - Source: `openspec/archive/changes/harness/2026-09-03-restore-exploration-authoring-contracts/attachments/implementation/issue-20260903-111408-change-created-after-implementation-start.md` plus active Change `harness/refactor-unified-workspace-core`.
  - Status: current; admission is part of the active Change's verification and completed closure gate

- [Exploration Carryover](exploration-carryover.md)
  - Summary: Classify accepted exploration into canonical truth, decision rationale, reusable knowledge, or discard without copying transcripts or treating markers as state.
  - Serves: Exploration markers and durable carryover.
  - Source: `openspec/archive/changes/harness/2026-09-03-restore-exploration-authoring-contracts/attachments/knowledges/exploration-marker-carryover.md`.
  - Status: current

- [Dogfooding the Harness](dogfooding.md)
  - Summary: Evidence classification and self-hosted acceptance for Harness/OpenSpec evolution.
  - Serves: Harness dogfooding feedback.
  - Source: `openspec/archive/changes/harness/2026-09-03-refactor-skill-system/attachments/knowledges/dogfooding.md`.
  - Status: current

- [Harness Evolution](harness-evolution.md)
  - Summary: Map the live harness surface once, keep raw observations ignored, promote one compact evaluated insight, and load durable knowledge progressively.
  - Serves: Harness dogfooding feedback and progressive harness knowledge promotion.
  - Source: `openspec/archive/changes/harness/2026-09-03-refactor-skill-system/attachments/knowledges/harness-evolution.md` plus active Change `harness/refactor-unified-workspace-core` workflow evaluation.
  - Status: current; admission is part of the active Change's verification and completed closure gate

- [Explicit Review Intake and Direct Closure](review-gate-scheduling.md)
  - Summary: Diagnose discovered problems directly, replan only when planning truth fails, archive verified work without Review ceremony, and gate only explicitly requested Reviews.
  - Serves: Explicit Review intake and direct closure.
  - Source: historical Review scheduling evidence plus `harness/refactor-unified-workspace-core` Replan `remove-automatic-final-review`.
  - Status: current
