# Review Protocol

Review is a gate, not a task cadence. Ordinary implementation slices, expected TDD failures, local repairs, documentation edits, marker changes, and Advisory observations do not trigger Review.

## Review routes

There are exactly three routes:

1. **Incident Review** — Hardness starts this only after evidence demonstrates a major incident and an immutable question or repair snapshot exists. A major incident threatens a security or trust boundary, user data or Git history, destructive workspace behavior, public schema/binary/release compatibility, cross-repository or submodule atomicity, or previously accepted completion evidence across boundaries. Review does not replace diagnosis.
2. **Final Review** — Hardness starts one final gate for a broad-impact Change only after scope freeze: implementation, documentation, specifications, planned capability-knowledge content, proving verification, accepted Replans, queued user changes, and closure inputs are complete; the Task DAG has no earlier Ready work; and the exact final semantic snapshot is fixed. A small low-impact Change records `Final Review: not required` with its impact rationale and does not create a Review file.
3. **External Review** — the user or another agent may start a reviewer at any time. Hardness registers the resulting Review file, verifies its snapshot and findings, and triages it at the nearest safe boundary. A credible Critical safety finding stops affected mutation immediately; other external feedback does not interrupt unrelated Goal progress.

Incident and External Reviews do not replace a required Final Review. A user-launched reviewer may perform the Final Review when it is explicitly assigned the frozen final scope and records `review_kind: final` with `requested_by: user`.

## Final impact classification

Final Review is required when the completed scope affects one or more of these boundaries:

- Public behavior, API, schema, command, package, binary, migration, or compatibility contract.
- Multiple modules, plugins, repositories, submodules, capabilities, or user entry points whose interaction must remain coherent.
- Security, permissions, trust, destructive actions, user data, Git history, release, installation, or recovery behavior.
- A production performance or resource-use path where regression impact is material.
- A large architectural replacement or evidence-sensitive change whose failure would invalidate broad completion claims.

Diff size alone does not determine impact. An isolated wording correction, local documentation or presentation adjustment, narrow test repair, or contained implementation change may skip Final Review when focused verification proves the boundary and none of the conditions above applies. Record the classification and rationale in task or closure evidence; do not create a placeholder Review merely to say it was skipped. An explicit user request always requires the assigned Review even when the impact would otherwise be low.

## Fixed snapshot and asynchronous execution

The coordinator assigns a unique Review file and an immutable snapshot that includes the requirements, review scope, verification evidence, excluded paths, and content identifier. `snapshot_ref` must let the reviewer read the exact content without consulting a moving working tree; use a commit, a synthetic local review commit/ref, or an equivalently immutable artifact. A digest alone can verify content but is not sufficient to materialize an asynchronous snapshot.

Dispatch the reviewer as an asynchronous subagent when one is available. Give it the immutable snapshot and assigned output path, not the coordinator's conversation history. The reviewer reads only the snapshot, may write only the assigned Review file, and never edits implementation, `tasks.md`, design/specs, `attachments/INDEX.md`, implementation records, replans, or existing Reviews.

The main thread may continue disjoint work or prepare a later batch while Review runs. It must not admit knowledge, close, archive, integrate, or claim the reviewed Change complete until the applicable Review Gate closes. After Final Review assignment, the only expected writes for that Change are the assigned Review lifecycle, Task/INDEX bookkeeping, and deterministic closure/archive metadata or move; these must not alter reviewed deliverable content. If any implementation, documentation, specification, test, script, or capability-knowledge content changes, the returned report remains evidence for its snapshot but cannot close the current Final Review gate. Absorb all late changes, freeze once more, and request one batched incremental Final Review rather than reviewing every edit. Unrelated dirty workspace paths that were explicitly excluded do not invalidate the snapshot.

## Review record

New records use `review-v2` frontmatter:

```yaml
---
review_schema: review-v2
review_kind: incident | final | external
requested_by: hardness | user | external-agent
state: open | closed | superseded
assigned_at: <actual ISO-8601 assignment time>
reviewed_at: <actual ISO-8601 completion time, when available>
closed_at: <actual ISO-8601 coordinator closure time, when available>
snapshot_ref: <immutable content reference>
snapshot_sha256: <lowercase SHA-256 of the declared snapshot manifest or artifact>
verdict: PENDING | APPROVE | CHANGES_REQUIRED
---
```

`assigned_at` is never reused as a guessed completion time. Every populated lifecycle timestamp is a real ISO-8601 instant with an explicit offset. A completed Review satisfies `assigned_at <= reviewed_at <= closed_at`. A Review superseded before completion may omit `reviewed_at`, but its `closed_at` still cannot precede `assigned_at`; when `reviewed_at` is present, the complete order applies. The reviewer records `reviewed_at` and its verdict when analysis actually finishes; the coordinator owns triage, `closed_at`, and final state. An External Review that arrives without a reproducible snapshot remains open input until Hardness binds and reproduces it or supersedes it with an explicit rationale. It cannot close a Review Gate while unbound.

There is no Review file line limit. Preserve concrete findings, evidence, impact, affected files and requirements, reproduction, proposed resolution conditions, disposition, resolution evidence, and re-review history. Detailed evidence is valuable; avoid repeated scans by supplying the fixed snapshot and existing verification evidence once. A per-file manifest is optional when it materially improves reproducibility, not mandatory for every Review.

Each finding keeps its original text and has:

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

Close a Review Gate only after all Critical and Required findings are resolved or rejected with evidence, required re-review passes, and the Review file is closed or superseded. Completed archive requires either one closed approving Final Review bound to the current final snapshot or a recorded low-impact `Final Review: not required` disposition. Every existing Review must be closed/superseded, no Critical/Required finding may remain open or deferred, and the closure summary explains the disposition and how findings were resolved. Advisory deferrals must name their follow-up.
