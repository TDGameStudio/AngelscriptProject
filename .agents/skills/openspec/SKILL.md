---
name: openspec
description: Use the project-local portable OpenSpec CLI for deterministic record operations, command help, validation, and CLI maintenance. Route lifecycle policy to the matching openspec-* skill; never use the incompatible global Node CLI.
---

# Portable OpenSpec

The packaged Release executable is:

```text
<project>/.agents/skills/openspec/bin/openspec.exe
```

Normal agent calls go through the imported Harness module so one PowerShell session can reuse context and receive a stable result envelope:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext                         # discover the registered workspace from the current directory
# $context = New-HarnessContext -WorkspaceRoot D:\work\my-linked-workspace
Invoke-Harness -Command openspec.doctor -Context $context -ArgumentList @('--json')
Invoke-Harness -Command openspec.change -Context $context -ArgumentList @('list', '--json')
```

One context selects one explicit or discovered `WorkspaceRoot`. A Codex `/goal` invocation may continue the work unattended, but it is not a repository mode, branch convention, or alternate OpenSpec lifecycle.

Routes are `openspec.init|doctor|status|instructions|validate|domain|spec|change|workflow|completion`. Never invoke bare `openspec`, `npx @fission-ai/openspec`, or a `target/` build for project operations. Direct EXE invocation is reserved for package self-test and release verification.

## Command lookup

Read [commands/README.md](commands/README.md), then only the one command document needed. The 31 group/leaf documents mirror the executable's Clap tree. `completion install/uninstall` changes user shell state; `workflow fork/init --force` may replace project packages and requires matching authority.

## Lifecycle routes

Before creating or renaming a Change, follow the project `<domain>/<type>-<scope>-<outcome>` convention in [record schema](references/record-schema.md). Harness rejects a nonconforming target before the portable CLI runs; historical archives remain immutable.

- Deep discovery before creating a new feature, architecture refactor, or major behavior-change record: `openspec-explore`; its accepted decision-complete handoff feeds `change create` and planning. Never invoke it after the target Change exists.
- Create the next missing artifact: `openspec-continue-change`.
- Revise existing artifacts or apply an evidence-gated replan: `openspec-update-change`.
- Implement ready Task DAG nodes and resolve task-local technical uncertainty: `openspec-apply-change`; do not restart deep Explore inside a Ready task.
- Verify a fixed snapshot: `openspec-verify-change`.
- Merge durable delta specs: `openspec-sync-specs`.
- Apply close policy and archive: `openspec-archive-change`.

For record layout, load only the relevant reference: [record schema](references/record-schema.md), [Specification and Scenario Card authoring](references/specs.md), [Task DAG](references/tasks.md), [attachments and closure](references/attachments.md), [material implementation issues](references/implementation-issues.md), or [knowledge promotion](references/knowledge.md). Load the specification reference only when creating, modifying, synchronizing, or verifying durable specs. A complex behavior clause may own an immediately indented clause-owned detail block using quoted labels, prose, ordered or unordered lists, examples, or tables with no Task state; preserve it beneath that exact clause as part of the complete Scenario Card.

## Deterministic boundary

The CLI owns manifests, identities, moves, workflow/status/instructions, validation, explicit closure metadata, completion scripts, and a pure archive move. It does not decide requirements, merge specs, run implementation, schedule worktrees, update Skills, detect AI tools, send telemetry, or make review/replan decisions.

`instructions --json` constraints are prompts, not artifact text. A glob has no writable path; use `existingOutputPaths` and a concrete workflow-permitted file. Prefer JSON for automation and preserve non-zero exit codes.

## CLI maintenance

Source lives in the tracked `Tools/openspec` submodule; this is the intentional exception to the retirement of root `Tools` PowerShell entrypoints. Runtime calls use the packaged `.agents/skills/openspec/bin/openspec.exe`. Use the [package publisher](scripts/Publish-OpenSpecPackage.ps1) only from a clean source commit with an exact annotated `v<version>` tag. It runs locked fmt, Clippy, all-target tests, command-doc parity, and Release-build gates before staging any package files; it then verifies and transactionally swaps the EXE, command docs, and manifest with rollback. The manifest binds the peeled tag target, gate results, target/profile/toolchain, EXE SHA-256, and command-doc digest. Commit the packaged EXE in the parent only after the final fixed snapshot is approved, and replace it once per accepted release; never create parent commits for candidate binaries. Startup is intentionally process-per-call; do not add a daemon.
