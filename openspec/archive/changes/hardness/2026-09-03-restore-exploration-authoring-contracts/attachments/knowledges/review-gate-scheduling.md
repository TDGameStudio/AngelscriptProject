# Review Gate Scheduling

## Reusable Insight

Review should be triggered by demonstrated incident severity, broad final impact, or explicit external intent rather than by task count or diff cadence. Detailed Review evidence remains valuable; elapsed time is reduced by freezing one immutable snapshot, dispatching asynchronously, and avoiding repeated scans.

## Evidence

- A small marker increment took only minutes to implement and seconds to test, while an immediately dispatched broad Review took longer and began before scope settled.
- The long Review records preserved useful evidence. Premature timing and moving-snapshot risk, not report length, caused the workflow inefficiency.
- `attachments/talks/talk-20260903-122738-review-gate-scheduling.md` records the evaluated options and accepted boundary.

## Boundaries

- Incident Review requires demonstrated major impact and does not replace diagnosis.
- Final Review is required only for broad public, cross-boundary, safety, compatibility/release, production-performance, or architectural impact after scope freeze.
- Verified small low-impact work records `Final Review: not required` with rationale and creates no placeholder Review.
- External Review is evidence input until Hardness binds its snapshot, reproduces findings, and triages them.
- A reviewer subagent reads an immutable snapshot, never a moving live workspace. Main-thread changes to reviewed final scope require one batched incremental Final Review after re-freeze.
- Final Review is the last semantic gate. Planned capability knowledge, verification, and closure inputs are complete before assignment; only Review/Task/INDEX bookkeeping and deterministic archive metadata or move follow approval.

## Application

```text
classify trigger -> classify impact -> complete every semantic deliverable
                 -> freeze immutable scope
                 -> dispatch reviewer asynchronously when required
                 -> continue disjoint work
                 -> triage findings without automatic Replan
                 -> close gate or record low-impact skip
```

Do not cap Review file length. Supply existing verification evidence once, retain concrete findings and resolution history, and avoid rerunning broad gates unless a focused reproduction requires it.

## Sources

- `.agents/skills/hardness/references/review.md`
- `.agents/skills/code-review/code-reviewer/SKILL.md`
- `attachments/talks/talk-20260903-122738-review-gate-scheduling.md`
