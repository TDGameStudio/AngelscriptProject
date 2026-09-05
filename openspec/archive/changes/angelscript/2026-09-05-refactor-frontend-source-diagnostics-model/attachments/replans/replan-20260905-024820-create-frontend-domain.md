---
replan_id: replan-20260905-024820-create-frontend-domain
status: applied
source: verification
source_ref: run-20582204a57e431ebcc20841b019f5c0
scope: first frontend capability domain registration
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: f74ba1fb5c3bfc946e5f5a18de65b3cbd5e1b19fe431efde2be5388d7c31353f
result_tasks_sha256: efdba1738629a66c5b3734f45d80c21a0813ef607c7729fa7122d7b284f138b2
created_at: 2026-09-05T02:48:20+08:00
resume_task: 3.1
---

# Replan: create the shared frontend domain before its first capability

## Trigger and Evidence

Harness run `20582204a57e431ebcc20841b019f5c0` executed the accepted capability-create command and the portable CLI rejected it because `angelscript/language/frontend` was not registered. Task `3.1` therefore omitted a necessary CLI-owned artifact.

## Decision

Use `openspec.domain create angelscript/language/frontend --title Frontend --json` when the domain is absent, then retry the existing source-diagnostics capability creation. Both identity manifests remain owned by the portable CLI.

## Impact

Task `3.1` gains one domain file and one prerequisite CLI command. The delta merge, strict validations, Task DAG edges, product implementation, and verification scope are unchanged. Later frontend capabilities reuse this shared registered domain.

## Old Task Disposition

Tasks `1.1`, `1.2`, and `2.1` remain complete with valid compiled evidence. Task `3.1` remains incomplete and resumes at current-capability creation.

## Diff Snapshot

- Task changes: one file, one context block, and one parent-domain create command added to Task `3.1`.
- Edge changes: none.
- Product source changes: none.
- Preserved final proof: build `a13d244bdb6f48e09e4fecd19eaf7e9f` and test `1c6cad52becb4c528a8f1970ac3d5033`.

## Preserved Work

All implementation, tests, prior Replans, material issue resolution, and exact UE evidence remain applicable. Only the missing durable identity prerequisite is added.

## References and Result

- Issue: `implementation/issue-20260905-024820-missing-frontend-domain.md`.
- Result: resume Task `3.1` with CLI-created domain, CLI-created capability, semantic spec merge, and strict validation.

