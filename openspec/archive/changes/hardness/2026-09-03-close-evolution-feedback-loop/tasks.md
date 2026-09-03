---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["1.3"]
    "3.1": ["2.1", "2.2"]
    "3.2": ["3.1"]
---

## 1. Normalize the recovery and establish RED evidence

- [x] 1.1 Normalize the active Change, intent talk, two material issues, delta specifications, and attachment index — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/openspec/bin/openspec.exe' validate 'hardness/close-evolution-feedback-loop' --strict --json; exit $LASTEXITCODE"`
  > Files: `openspec/changes/hardness/close-evolution-feedback-loop/change.yaml`, `proposal.md`, `design.md`, `specs/**`, `attachments/implementation/issue-20260903-212218-preserve-outside-staged.md`, `attachments/implementation/issue-20260903-212650-missing-original-intent-talk.md`, `attachments/talks/talk-20260903-212650-original-hardness-user-intent.md`, `attachments/INDEX.md`, `tasks.md`

  1. Preserve the completed `2026-09-03-integrate-unreal-development` archive unchanged and retain honest limits around unavailable transient Git evidence.
  2. Reuse the existing detailed material implementation-issue lifecycle with `openspec-material-issue-v2`; do not introduce a parallel `attachments/evolution/` category.
  3. Keep both issues open until implementation and focused verification establish exact terminal dispositions.
  4. Reconstruct one bounded, dated original-intent talk with exact durable sources, canonical mappings, positive hook/visual intent, and a selective major-only carryover boundary.

- [x] 1.2 Add lifecycle, evaluation, and intent-talk RED tests — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/hardness/tests/Protocol.Tests.ps1'; & '.agents/skills/hardness/tests/Hardness.Tests.ps1'"`
  > Files: `.agents/skills/hardness/tests/Protocol.Tests.ps1`, `.agents/skills/hardness/tests/Hardness.Tests.ps1`

  1. Cover the v2 material-issue schema, legacy v1 compatibility, exact INDEX membership, state-specific fields, exact supersession targets, and open-issue closure failure.
  2. Cover parseable canonical workflow-evaluation frontmatter and exact-Change status summaries that do not load bodies or unrelated Changes.
  3. Add positive and negative fixtures for selective major-only intent carryover without requiring a transcript, machine inference from chat, or a boilerplate talk for routine work.
  4. Prove RED only for the planned lifecycle/status/guidance capabilities rather than unrelated existing behavior.

- [x] 1.3 Add `PreserveOutsideStaged` RED tests — verify: `pwsh.exe -NoProfile -File .agents/skills/git-operations/tests/GitOperations.Tests.ps1`
  > Files: `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`, `.agents/skills/hardness/tests/Hardness.Tests.ps1`

  1. Preserve the existing default rejection case.
  2. Cover explicit opt-in for primary and submodule scopes, preview separation, exact commit paths, outside index equivalence, and parent gitlink inclusion.
  3. Cover all-change rejection, unmerged indexes, ambiguous pathspecs, leading dots, dashes, spaces, Unicode, prefix collisions, hook failure, and resumable partial completion.
  4. Prove RED only because the typed option and path-only implementation do not yet exist.

## 2. Implement the independent repairs

- [x] 2.1 Implement material-issue status, exact closure, workflow-evaluation parsing, and intent guidance — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick`
  > Files: `.agents/skills/hardness/scripts/Hardness.psm1`, `.agents/skills/hardness/references/closure.md`, `.agents/skills/openspec/references/attachments.md`, `.agents/skills/openspec/references/implementation-issues.md`, `.agents/skills/hardness/tests/**`

  1. Keep raw observation behavior backward compatible, ignored, and non-blocking.
  2. Parse only exact active-Change v2 issue and canonical workflow-evaluation frontmatter for status and closure decisions; preserve legacy v1 history without rewriting it.
  3. Require every admitted open issue to become resolved, rejected, or superseded by an exact existing v2 issue before any archive closure kind.
  4. Route post-archive material discoveries into a suitable active owner, creating a successor only when none exists, without starting Review or Replan automatically.
  5. Publish selective major-only intent-talk guidance with positive and negative boundaries; never require transcript storage or a not-required placeholder.

- [x] 2.2 Implement Git opt-in, preflight, fingerprint, and path-only commit — verify: `pwsh.exe -NoProfile -File .agents/skills/git-operations/tests/GitOperations.Tests.ps1`
  > Files: `.agents/skills/git-operations/scripts/GitOperations.psm1`, `.agents/skills/git-operations/references/commits.md`, `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`, `.agents/skills/hardness/scripts/Hardness.psm1`, `.agents/skills/hardness/tests/Hardness.Tests.ps1`

  1. Retain default fail-closed behavior and reject opt-in for all-change intent, ambiguous pathspecs, unmerged indexes, or unverifiable state.
  2. Preflight every repository and effective scope before mutation, including expected parent gitlinks.
  3. Use path-only dry-run and commit semantics, then verify each commit path set and scope-external index fingerprint.
  4. Return selected, preserved, completed, and resumable-partial evidence without reset, push, integration, or cleanup.

## 3. Synchronize, verify, and close

- [x] 3.1 Synchronize current core/Git specifications, reconcile intent, create the final evaluation, and give both issues terminal evidence dispositions — verify: `current hardness/core and hardness/git specs match passing implementation; both v2 issues are terminal with exact evidence; one indexed final workflow evaluation is parseable`
  > Files: `openspec/specs/hardness/core/spec.md`, `openspec/specs/hardness/core/knowledges/harness-evolution.md`, `openspec/specs/hardness/git/spec.md`, `openspec/changes/hardness/close-evolution-feedback-loop/attachments/**`

  1. Merge only verified delta requirements into current specifications and focused capability knowledge.
  2. Reconcile the original-intent mapping against final current truth without copying the talk into canonical specifications.
  3. Create one final versioned workflow evaluation with elapsed stages, friction, corrections, superseded owners, and raw-data provenance.
  4. Give both open issues a valid terminal disposition only after their focused tests pass; otherwise reject with exact evidence or supersede each with an exact existing v2 issue.

- [x] 3.2 Run PS7 closure gates, archive, run the post-move gate, and create exact commits without push — verify: `focused tests, the full non-UE Quick profile, strict active validation, strict archived validation, post-move gate, and exact commit audit all pass`
  > Files: `openspec/changes/hardness/close-evolution-feedback-loop/**`, `openspec/archive/changes/hardness/**`, exact Change-owned implementation/specification paths

  1. Confirm every task, v2 issue, attachment index entry, delta specification, final workflow evaluation, and required verification is complete.
  2. Do not create Final Review unless the user or an external agent explicitly requests one.
  3. Archive through the normal lifecycle and run the smallest archive-stable non-UE gate.
  4. If archive, exact commit, or delivery exposes another material problem, admit it to a suitable active Change before handoff; create a successor only when no suitable owner exists.
  5. Commit exact Change-owned paths while preserving unrelated staged, unstaged, untracked, ignored, and submodule content. Do not push.
