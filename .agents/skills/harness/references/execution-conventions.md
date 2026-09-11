# Execution conventions for task plans

Every `tasks.md` links this reference instead of repeating it. It states how a card's Verification is run and what counts as proof. Plan-specific constraints (prerequisite Changes, test identities, language policy) stay in the plan's `## Global constraints`.

## Session

Import Harness once in the current PowerShell 7 process and keep one context for every proving command:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
```

Route UE discovery, builds, tests, suites, commandlets, status and cancellation only through `ue.*`; route OpenSpec through `openspec.*` and `task.status`. Root `Tools` wrappers and a `target/` build are not fallbacks. Paths in cards are relative to the selected workspace root unless the card states a working directory.

## Build before Automation

After any C++, header or `Build.cs` edit, freeze source writers and run a successful `Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }` before any `ue.test`. The proving selector consumes exactly that binary. Document-only or migration tasks do not require a build.

## What counts as PASS

- The Harness result `status` is `Succeeded` and the enforced Automation report shows every case in the card's Cases discovered and executed; a selector that discovers zero or fewer cases than the card names is failure.
- A shell exit code, an aggregate count or a successful dispatch is not case-level proof.
- Grouped RED/GREEN: a behavior task's `new RED` cases fail together before implementation and pass together after; `existing control` cases pass before and after. A `deferred RED until X.Y` case is observed red and named in this task's Evidence but excluded from its pass set; task `X.Y` cites it green. A custom role defined in the card's `Roles:` paragraph is judged as that definition states.

## Shared runs

Several cards may share one run only when the run records exact source and binary identity and a task-specific mapping of discovered and executed cases; each card keeps its own Evidence pointing at that mapping. Compatible tasks share verification through [verification.md](verification.md); they never share an outcome, a checkbox or a graph.

## Leases and concurrency

UE builds and tests hold an exclusive workspace lease. Ready tasks run in parallel only when their Files, generated artifacts and leases are disjoint; overlapping Files means sequential execution even when the graph does not connect the tasks.

## Scope of verification

Start with the smallest selection that proves the whole card. Expand only for an affected shared contract, cross-component impact, adjacent failure evidence, a release gate or an explicit user request. `Quick`, `Performance`, `Integration`, a full suite or an Unreal build are not unconditional gates; record intentionally omitted heavier tests with the reason.

## Evidence

Append `**Evidence**` to the owning card only after the run: the exact command, the result status, discovered/executed counts, the report path or run id, and any `Naming assumed: <name> — <reason>` entries. Never prefill successful results. Attachments listed by a card are created only when their results exist and are indexed in the same edit.
