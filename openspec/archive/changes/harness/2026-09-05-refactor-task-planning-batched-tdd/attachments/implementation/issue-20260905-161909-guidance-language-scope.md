---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-161909-guidance-language-scope
status: resolved
resolved_at: 2026-09-05T16:43:34.0665824+08:00
resolution_ref: attachments/data/verification.md
source: verification
source_ref: default OpenSpecSkill.Tests.ps1 baseline
affected_tasks: ["2.1"]
created_at: 2026-09-05T16:19:09+08:00
---

## Symptom

The default owner test scans all OpenSpec surfaces and fails on two unrelated existing files, preventing the chosen command from being an impact-scoped guidance proof.

## Investigation Log

- Full baseline exits 1 after package safety passes.
- Exact findings: openspec/changes/angelscript/refactor-testing-unified-framework/tasks.md:75 and openspec/specs/angelscript/language/frontend/preprocessing/knowledges/clang-directive-and-source-backquery.md:18.
- The language checker correctly identifies those characters. Its unconditional repository-wide input selection, rather than the English rule, conflicts with this task's bounded ownership.

## Root Cause

The language-only correction passed its fixtures and exact content check, then exposed the same input coupling in the knowledge-index audit. Eight unrelated existing entries lack the required Markdown links: clang-typed-ast-shape-and-lifetime, deterministic-body-fragments, declaration-barrier-before-resolution, clang-lexer-hot-path, clang-directive-and-source-backquery, semantic-events-to-reflection-and-dependency-graphs, clang-source-provenance, and stable-type-identity-witnesses. They remain unchanged.

The verification contract has no explicit proving-surface input for a guidance-only change in a dirty workspace. Fixing unrelated contents or silently exempting named files would be incorrect.

## Disposition

Preserve default full-scan failure and unrelated contents. The first language-only correction is retained as immutable history; the follow-up replan selects validated SurfacePaths for repository English/knowledge/attachment audits, retaining all hermetic and package/protocol/link checks. A selected child brings its complete owning index into scope. No filename exemption is introduced.

## Evidence

### Failure Evidence (RED)

- Command: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Artifact: the two exact existing paths in Investigation Log; full output ends with expected zero / actual two English violations.
- Result: exit 1. This is a baseline scope mismatch, not a regression caused by the new guidance.

### Resolution Evidence (GREEN)

- Command: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths $guidanceSurfacePaths`; exact stable array is declared in tasks.md.
- Artifact: `attachments/data/verification.md`; script SHA-256 FB135158C9FD50023265A277D2197E09D4B22BA00765D6F9637A78B21368D320.
- Result: PASS after explicit-input and owner-closure fixture RED/GREEN, retaining all hermetic/package/authoring/link checks. The two affected Change directories also pass explicit content/owner selection after indexing existing AS diagram companions. The unchanged default full scan still fails on unrelated baseline content; this resolution only establishes the bounded proving contract.

### What This Proves

Task-specific guidance verification needs a bounded, auditable content selection while retaining meaningful fixture coverage.

### What This Does Not Prove

It does not prove the entire repository conforms to the English rule or authorize modifying the unrelated files.

## Links

- `../replans/replan-20260905-161909-guidance-language-scope.md`
