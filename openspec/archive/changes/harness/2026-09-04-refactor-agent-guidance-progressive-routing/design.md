## Context

Harness currently has focused test scripts and three unchanged aggregate profiles, but lifecycle prose makes the aggregates look like routine universal gates. The root project guidance also duplicates volatile facts already owned by Skills, specifications, source, and indexes, including a root Chinese mirror. This change is guidance- and contract-only; its design must remain compatible with the existing dispatcher, task parser, validator profiles, Unreal routes, and aggregate test runner.

The parent worktree is already dirty with unrelated user changes, including edits to `README.md`. Exact scoped commit isolation is therefore part of the delivery boundary, and the two README replacements must be reviewed as individual hunks before commit.

## Goals / Non-Goals

**Goals:**

- Keep one short root entry that survives architecture and test-count churn.
- Give Harness and OpenSpec lifecycle Skills one shared impact-scoped verification policy through progressive disclosure.
- Preserve exact task-level RED/GREEN verification and evidence-driven escalation or Replan.
- Make focused static tests enforce the ownership boundaries without demanding duplicated prose.
- Close the self-hosting Change with a current workflow evaluation, strict validation, durable spec synchronization, and exact-scope commit.

**Non-Goals:**

- Change any Unreal, plugin, Standalone, or generated code.
- Change Harness route APIs, `Test-Harness.ps1` profile composition, OpenSpec parser fields, `record-v1`, `requirements-v1`, or the portable CLI.
- Rewrite historical archives, migrate material being removed from `Documents/`, or alter `Wiki/Agents_ZH.md`.
- Run broad Harness profiles or real Unreal operations without evidence that this guidance-only change affects those contracts.

## Decisions

### One canonical root entry

`AGENTS.md` remains the only project-level entry and is capped at roughly 80 lines. It keeps the stable plugin-first objective, progressive Skill/OpenSpec routing, selected-workspace authority, Change naming, impact-scoped verification default, Harness-only `ue.*` routing, current-process PowerShell boundary, exact Git scope, and authoritative indexes. Architecture inventories, mutable counts, historical milestones, detailed commands, configuration tutorials, and reference catalogs are deleted rather than moved into another general document.

The root `AGENTS_ZH.md` is removed. This does not establish a repository-wide ban on localized subsystem documentation; `Wiki/Agents_ZH.md` and immutable historical records retain their own ownership.

### One focused verification reference

Detailed selection rules live in `.agents/skills/harness/references/verification.md`. The Harness entry and the apply, verify, and archive lifecycle Skills link that reference at their decision points. The workflow `tasks.md` template and task authoring contract require each node to name one exact verification command directly related to its files and outcome.

The reference maps content and route categories to the smallest proving tests and defines evidence-based escalation. It records broader-test rationale in ordinary Task Card or final evidence prose, so no new YAML/parser field or OpenSpec CLI change is needed.

### Aggregates remain available but conditional

The public `Quick`, `Performance`, and `Integration` profiles are unchanged. Guidance distinguishes availability from selection: performance changes select `Performance`, integration-boundary changes select `Integration`, and `Quick` is reserved for multi-group or unbounded Harness impact (or an explicit broader user request). Actual Unreal execution remains conditional on product-code impact, inability of fixtures to prove behavior, a release gate, or explicit request.

### Focused static contract coverage

Existing `HarnessCutover.Tests.ps1`, `Protocol.Tests.ps1`, and `OpenSpecSkill.Tests.ps1` gain semantic assertions for the single entry and shared policy. They continue to protect the current PowerShell process, `ue.*` routing, Change naming, and Review/Replan boundaries. `HarnessEvolution.Tests.ps1` remains the terminal-evidence regression. Tests should assert durable concepts and reference routing, not copy the entire entry or verification reference into every owner.

## Risks / Trade-offs

- A thinner root entry gives less immediate background. Stable links and explicit load order mitigate this while preventing stale mandatory context.
- Static wording tests can become brittle. Assertions will target owner links, prohibited heavy categories, and stable behavioral distinctions rather than complete sentences.
- Removing the Chinese root mirror reduces localized project-level guidance. This is intentional to eliminate dual maintenance; subsystem-owned Chinese material remains untouched.
- A focused verification default can miss hidden coupling. The escalation rule addresses this by widening to adjacent surfaces on evidence and selecting `Quick` when impact cannot be bounded reliably.
