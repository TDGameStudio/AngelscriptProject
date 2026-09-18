# AngelscriptProject Skills

## Start with Harness

- [harness](harness/SKILL.md) owns the discussion/execution double loop, workspace context, handoff Gates and progressive routing. Open one matching leaf at a time; entry size is not a reason to remove useful methods or examples.
- [Route ownership](harness/references/routing.md) maps intent to a leaf. `Get-HarnessCommand` is the authoritative runtime route inventory, not a parameter-schema service. [Queries](harness/references/queries.md) inspect live state without starting work.
- Ordinary routes execute in the current PowerShell 7 Core process. Child hosts are bounded tests, Git hooks/native fixtures or Harness-managed UE workers. No repository Codex project hooks, daemon or automatic new chat.

## Discussion methods

- [brainstorming](brainstorming/SKILL.md): automatic substantial-topic drafts with key decisions in CONTEXT, optional research/attachments and independently scoped designs. Old drafts stay readable; no transcript dual-writing by default.
- [explaining-work](explaining-work/SKILL.md): architecture, relevant classes, caller/callee chains, key logic, lifecycle and data, using faithful simplified annotated code and the preserved ASCII methods from visual-explain. Usable on its own and before Grill questions.
- [grill](grill/SKILL.md): explained decision rounds; after each user answer re-display the current relevant architecture and terms. Only user-led convergence opens the handoff Gate; always offer more names when naming is the question.
- [evolution](harness/references/evolution.md): automatically collect friction, present a batch, implement the user-selected scope and record proof. Update notices are small versioned summaries, not background services.

## Change lifecycle

- [create](openspec-create-change/SKILL.md) presents and creates one exact approved handoff, exports self-contained accepted design/evidence, verifies its seed, and records the post-handoff arrangement.
- [update](openspec-update-change/SKILL.md) uses a linked draft to reconsider invalid accepted truth, previews candidate hashes and applies the approved Replan transaction. It does not edit implementation.
- [change-queue](change-queue/SKILL.md) owns every Change's execution, including a single-item adapter. Authorization binds the ordered UID range; appended work is not implicitly authorized.
- [apply](openspec-apply-change/SKILL.md) ensures planning artifacts then implements native Ready tasks with exact proof. Direct authorized work can remain outside OpenSpec entirely.
- [verify](openspec-verify-change/SKILL.md), [sync](openspec-sync-specs/SKILL.md), [archive](openspec-archive-change/SKILL.md) retain verification, durable spec merge and explicit closure. A requested Review uses [code-review](code-review/SKILL.md); normal completion creates no Review.
- [openspec](openspec/SKILL.md) owns portable CLI help, deterministic primitives and maintenance; focused record/schema references live below it. New Change IDs use `<domain>/<type>-<scope>-<outcome>`; archives are immutable.
- Durable Scenario Cards retain useful prose, lists, examples and tables in each clause-owned detail block per [specs](openspec/references/specs.md). Do not flatten records to achieve a line quota. Tasks retain Outcome, Interfaces, Cases, Files and exact Verification, plus their real evidence.

## Peripheral tools

- [workspace-lifecycle](workspace-lifecycle/SKILL.md): minimal replicas, selected plugin worktrees/snapshots, identity, configuration and explicit cleanup. Keep the selected workspace by default.
- [git-operations](git-operations/SKILL.md): exact owned commits, integration and explicit non-force push. Integration, push and workspace removal remain separate authority.
- [unreal-engine-develop](unreal-engine-develop/SKILL.md): UE discovery/builds/tests/suites/commandlets/status/cancellation through `ue.*`, selected Context and lazy module loading. Prefer appropriate previews; a query of a failed run is still a successful query.
- [systematic-debugging](systematic-debugging/SKILL.md), [test-driven-development](test-driven-development/SKILL.md), [angelscript-test-guide](angelscript-test/SKILL.md): focused diagnosis, grouped feature proof and project test patterns.

## Maintenance

- Skills/references and maintained OpenSpec output use English; local drafts follow the conversation language. Recognized original optional transcript frames retain their source language. Existing exact `_ZH` exemptions remain temporary.
- Validate changed Skill frontmatter/links and exercise meaningful behavior. Complex instruction changes also need a realistic independent consumer check. Preserve useful original examples when refactoring guidance; no fixed brevity quota.
- New scratch goes under `Saved/AgentTemp/<topic>/`; preserve old Saved content. Root Tools PowerShell wrappers are retired from the live surface; `Tools/openspec` remains the intentional tracked CLI-source exception with its accepted package release contract.
