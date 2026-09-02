# Review Protocol

Review is automatic only at planned high-risk slice gates and the final gate, or when the user explicitly requests it. Do not review every task.

## Fixed snapshot contract

The coordinator assigns one new review file and an immutable snapshot: base/head commits, allowed diff, requirements, verification evidence, and review scope. An external reviewer may write only that assigned file. It must not edit code, `tasks.md`, design/specs, `attachments/INDEX.md`, implementation records, replans, or existing reviews.

Review file state is `open | closed | superseded`. Each finding keeps its original text and has:

```yaml
severity: Critical | Required | Advisory
status: open | resolved | rejected | deferred
```

Append resolution, rationale, evidence, resolving task or commit, and re-review result below the original finding. Never rewrite history. Advisory findings may be deferred with a concrete follow-up; Critical and Required findings gate completion.

## Triage and Replan

A finding never directly triggers Replan. The coordinator reproduces or verifies it against the assigned snapshot, then asks whether it invalidates a requirement, design boundary, Task DAG edge, verification contract, or required artifact.

- Local implementation defect: create or link a follow-up task; no Replan.
- Material technical issue: record it under `attachments/implementation/` with `open | resolved | superseded`.
- Non-obvious decision: link a concise `attachments/talks/` record.
- Invalid planning boundary: update current truth, apply the Replan protocol, then resume.
- Incorrect finding: mark `rejected` with evidence.

For material findings, the trace is:

```text
review finding -> implementation issue -> talk (when needed) -> design/spec -> replan -> task
```

Close a Review Gate only after all Critical and Required findings are resolved or rejected with evidence, required re-review passes, and the review file is closed or superseded. Archive closure requires every review file closed/superseded, no open or deferred Critical/Required finding, and a closure summary explaining how findings were resolved. Advisory deferrals must name their follow-up.
