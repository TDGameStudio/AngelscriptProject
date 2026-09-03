# Review Protocol

Review is explicit, not automatic lifecycle cadence. An explicit user or external-agent request is the only trigger; Harness never auto-starts Review because a change is large, high impact, complete, or experiencing a serious problem. The normal path is:

```text
implement -> verify -> fix a local defect
                    -> Replan only when evidence invalidates planning truth
                    -> otherwise close and archive directly
```

Verified work may close and archive directly without a Review file, impact classification, or not-required Review placeholder. Local defects are fixed and verified inside the task; only planning-invalidating evidence enters Replan.

## Invocation and kinds

Create a Review only after an explicit request from the user or an external agent. The request selects one of the retained `review-v2` kinds:

- **Incident Review** examines a named serious incident or its repair.
- **Final Review** examines an explicitly frozen completion snapshot.
- **External Review** records a user- or agent-initiated review that is not assigned as one of the two kinds above.

These kinds classify the requested report; none is an automatic trigger. Serious safety evidence may still stop affected mutation, and broad changes still need proportionate verification, but Harness diagnoses, fixes, or Replans without manufacturing a Review request.

An external report that arrives without a reproducible snapshot remains open input until Harness binds it to exact content or supersedes it with a recorded rationale.

## Fixed snapshot and execution

Every explicit Review receives one unique Review file and an immutable snapshot containing its requirements, scope, verification evidence, exclusions, and content identifier. `snapshot_ref` must let the reviewer read the exact content without consulting a moving working tree; use a commit, synthetic local review commit/ref, or equivalently immutable artifact. A digest verifies content but does not by itself materialize an asynchronous snapshot.

The Review may run inline or asynchronously. Async is optional: use it only when continuing disjoint work is useful. An asynchronous reviewer receives the immutable snapshot and assigned output path rather than a moving workspace or the coordinator's conversation history. The reviewer writes only its assigned Review file and never edits implementation, tasks, design/specs, `attachments/INDEX.md`, implementation records, Replans, or earlier Reviews.

The main thread may continue disjoint work while an asynchronous Review runs, but cannot close or archive the reviewed work until the Review lifecycle is resolved. A later deliverable-content change does not rewrite what the old report reviewed. If the explicit request still applies, supersede the stale report with rationale and review the new immutable snapshot while retaining the old history. Unrelated dirty paths explicitly excluded from the snapshot do not invalidate it.

## Review record

New records use `review-v2` frontmatter:

```yaml
---
review_schema: review-v2
review_kind: incident | final | external
requested_by: user | external-agent | hardness
state: open | closed | superseded
assigned_at: <actual ISO-8601 assignment time>
reviewed_at: <actual ISO-8601 completion time, when available>
closed_at: <actual ISO-8601 coordinator closure time, when available>
snapshot_ref: <immutable content reference>
snapshot_sha256: <lowercase SHA-256 of the declared snapshot manifest or artifact>
verdict: PENDING | APPROVE | CHANGES_REQUIRED
---
```

`requested_by: hardness` remains readable for existing history, but Harness does not write it for a new Review. New records identify the requesting user or external agent.

`assigned_at` is never reused as a guessed completion time. Every populated lifecycle timestamp is a real ISO-8601 instant with an explicit offset. A completed Review satisfies `assigned_at <= reviewed_at <= closed_at`. A Review superseded before completion may omit `reviewed_at`, but `closed_at` cannot precede `assigned_at`; when `reviewed_at` exists, the complete order applies. The reviewer records `reviewed_at` and its verdict after analysis; the coordinator owns triage, `closed_at`, and final state.

There is no Review file line limit. Preserve a detailed report with concrete findings, evidence, impact, affected files and requirements, reproduction, resolution conditions, disposition, repair evidence, and re-review history. Avoid repeated broad scans by supplying the exact snapshot and existing verification evidence once. A per-file manifest is optional when it materially improves reproducibility.

Each finding keeps its original text and has:

```yaml
severity: Critical | Required | Advisory
status: open | resolved | rejected | deferred
```

Append resolution, rationale, evidence, resolving task or commit, and re-review result below the original finding. Never rewrite history.

## Triage and Replan

A finding never directly triggers Replan. Reproduce or verify it against the assigned snapshot, then classify its effect:

- Local implementation defect: fix it in the owning task and verify the repair; no Replan.
- Material technical issue: when useful, retain its root-cause and repair history under `attachments/implementation/`.
- Non-obvious decision: link a concise `attachments/talks/` record.
- Evidence invalidates a requirement, design boundary, Task DAG edge, verification contract, or required artifact: apply the Replan protocol.
- Incorrect or inapplicable finding: mark it `rejected` with evidence.

For material findings, the possible trace is:

```text
review finding -> local repair and evidence
               -> implementation issue or talk when durable context helps
               -> Replan only when accepted planning truth is invalid
```

Close or supersede a Review only after triage. Before archive, every existing Review file must be closed or superseded, with no open or deferred Critical or Required finding; resolve or reject each with evidence and any required re-review. Advisory findings may be deferred only with an explicit follow-up. When no Review file exists, there is no Review gate or Review disposition to record.
