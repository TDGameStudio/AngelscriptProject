# Harness entry and route ownership

## Select by intent

- Use the [Harness entry](../SKILL.md) for the two loops and Gate authority. A direct edit, explanation or tool request goes straight to its leaf when scope is already clear.
- Use `Get-HarnessCommand` for the authoritative executable inventory; it returns route descriptions/dispatch metadata. Read the matching leaf for parameter contracts. Do not maintain a second exhaustive command list.

| Intent | Owner | Surface |
| --- | --- | --- |
| Substantial exploration / current design | [brainstorming](../../brainstorming/SKILL.md) | `harness.draft.create/status/check/archive` |
| Explain architecture, code, lifecycle or tradeoffs | [explaining-work](../../explaining-work/SKILL.md) | Evidence, annotated code, ASCII/appropriate artifact |
| User-owned choices | [grill](../../grill/SKILL.md) | Explain each round; user-led convergence |
| Create the approved exact Change | [create](../../openspec-create-change/SKILL.md) | `harness.change.create`, seed/plan verify |
| Update accepted Change truth | [update](../../openspec-update-change/SKILL.md) | `harness.replan.apply/status`; linked draft and Gates |
| Execute one Change or ordered scope | [change-queue](../../change-queue/SKILL.md), then [apply](../../openspec-apply-change/SKILL.md) | `harness.execution.*`, `harness.queue.*`, `task.status` |
| Handoff arrangement / durable discussion | [discussions](discussions.md) | `harness.talk.create/update/status` |
| Explicit optional transcript capture | [draft recording](../../brainstorming/references/drafts.md) | `harness.draft.record`, `harness.conversation.record` |
| Current tasks, queue, workspace or run | [queries](queries.md) | Read-only selected route |
| Workflow improvement batch | [evolution](evolution.md) | `harness.observe`, `harness.evolution.status/triage` |
| Unreal discovery/build/test/run | [unreal-engine-develop](../../unreal-engine-develop/SKILL.md) | `ue.*`, selected workspace, lazy leaf |
| Workspace identity/configuration/explicit lifecycle | [workspace-lifecycle](../../workspace-lifecycle/SKILL.md) | `workspace.*` |
| Exact commit/integrate/explicit push | [git-operations](../../git-operations/SKILL.md) | `git.*` |
| Portable record primitive/package maintenance | [openspec](../../openspec/SKILL.md) | `openspec.*`, `openspec.maintenance.status` |
| Complete verification/spec sync/archive | Respective `openspec-*` leaf and [closure](closure.md) | Native validation, `harness.specs.read/write`, terminal gate |
| Explicit fixed-snapshot Review | [code-review](../../code-review/SKILL.md) and [review intake](review.md) | No routine automatic Review |
| Unexpected failure / behavior implementation | [systematic-debugging](../../systematic-debugging/SKILL.md) / [TDD](../../test-driven-development/SKILL.md) | Task-local diagnosis / grouped RED-GREEN |

## Keep peripheral tools independent

- Peripheral leaves consume the selected Context, retain their authority checks and common envelope, and load lazily. Adding a tool does not add a third lifecycle.
- UE routes retain exact workspace/lease/run semantics; root Tools wrappers are not fallback entrypoints. `Get-HarnessCommand ue.build` locates its owner, while the Unreal leaf describes typed arguments.
- The portable OpenSpec CLI owns deterministic records and validation, not approval, queue scheduling or Skill edits. Direct `openspec.change create` remains closed in normal agent routing.
