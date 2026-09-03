---
review_schema: review-v2
review_kind: final
requested_by: hardness
state: open
assigned_at: 2026-09-03T13:15:01+08:00
reviewed_at: 2026-09-03T13:20:52.5294379+08:00
closed_at:
snapshot_ref: commit:09c7978d111a31f5b1f251cdbff03e3f27911524
snapshot_sha256: a543f69b6415a8263a1532104530bcd3d891a81f552a78c14bef62e46d71aacb
verdict: CHANGES_REQUIRED
---

# Hardness Workflow Final Review

Review the complete committed semantic snapshot for `hardness/restore-exploration-authoring-contracts`.

## Assigned snapshot

- Review commit: `09c7978d111a31f5b1f251cdbff03e3f27911524`
- Change baseline: `7f4e8667cf7a987111d8b3fc47da10401540ee90`
- Commit tree: `ce12f4031eccd3084b53e0e5a85948ab379ce3b3`
- Snapshot manifest: all `5762` lines produced by `git ls-tree -r --full-tree 09c7978d111a31f5b1f251cdbff03e3f27911524`, joined with LF and one trailing LF, then hashed as UTF-8 SHA-256.
- Snapshot manifest SHA-256: `a543f69b6415a8263a1532104530bcd3d891a81f552a78c14bef62e46d71aacb`

The assigned Review file and later coordinator-owned Review/Task/INDEX bookkeeping are excluded from the snapshot. Read content from the Git object, not from the moving working tree.

## Review scope

Review the complete change from the baseline through the review commit, including:

- pre-Change deep exploration and post-creation lifecycle routing;
- Task DAG, attachment, material-issue, knowledge-admission, and marker/carryover contracts;
- event-driven Incident, impact-gated Final, and user/agent-started External Review behavior;
- asynchronous immutable-snapshot review and the prohibition on routine review cadence;
- the correction that makes Final Review the last semantic gate;
- active and durable Hardness specifications, capability knowledge, dogfood records, Replans, and protocol regression tests;
- internal consistency, progressive-loading boundaries, accurate English, and closure readiness.

Explicitly check that every substantive deliverable precedes this Review, that no intended knowledge promotion remains after it, and that only Review/Task/INDEX bookkeeping plus deterministic closure metadata and archive movement may follow approval without another freeze.

## Supplied verification evidence

- `Protocol.Tests.ps1`: PASS.
- `OpenSpecSkill.Tests.ps1`: PASS.
- PS7 Quick Skill-only gate: `5/5` PASS (`Hardness` 17198 ms, gate contract 4753 ms, Protocol 826 ms, Workspace 40069 ms, OpenSpec Skill 4288 ms).
- Strict active validation: `1/1` valid, zero issues, 4 ms at the recorded final run; it passed again after commit.
- Focused diff checks: PASS.
- Task progress at assignment: `16/17`, with `5.5` as the only incomplete Task DAG node.
- UE, StaticJIT, Performance, Integration, plugins, `Tools/openspec`, binaries, and unrelated dirty workspace paths are outside this change.

## Reviewer instructions

- Perform a senior fixed-snapshot review; do not edit implementation, specs, tests, Tasks, INDEX, Replans, existing Reviews, or knowledge files.
- Write only this assigned file.
- Preserve detailed evidence; there is no Review-file line limit.
- Classify findings as `Critical`, `Required`, or `Advisory`, and give each finding `status: open` initially unless the snapshot itself proves it rejected or already resolved.
- Record actual `reviewed_at` and set `verdict` to `APPROVE` or `CHANGES_REQUIRED`; leave `state: open` and `closed_at` empty for coordinator triage.
- Do not rerun the broad Quick gate unless a concrete finding requires targeted reproduction.

## Review outcome

The immutable snapshot is internally coherent across its exploration, post-creation routing, Task DAG, attachment, knowledge, Review-trigger, asynchronous-snapshot, Replan, and last-semantic-gate design. The final ordering correction is real: every substantive deliverable, including both planned capability-knowledge files and their intended final INDEX entries, is present in the review commit. Only this Review's lifecycle plus coordinator-owned Task/attachment-INDEX bookkeeping and deterministic closure/archive metadata or movement remains outside the snapshot.

One Required finding prevents approval. The executable `review-v2` closure checker calls a regex-only timestamp predicate that accepts strings which are not real ISO-8601 instants, and it never verifies assignment/completion/closure ordering. This contradicts the new truthful-lifecycle contract and leaves the principal regression gate unable to reject impossible Review histories.

## Snapshot integrity and scope

- `7f4e8667cf7a987111d8b3fc47da10401540ee90` and `09c7978d111a31f5b1f251cdbff03e3f27911524` both resolve as commits. The baseline is an ancestor of the review commit through `4f6db850d8c2ab990e97db0b3dd4c477ebd40160`.
- The review commit resolves to tree `ce12f4031eccd3084b53e0e5a85948ab379ce3b3`, matching the assignment.
- Recomputing the declared manifest from all `5762` lines of `git ls-tree -r --full-tree 09c7978d111a31f5b1f251cdbff03e3f27911524`, joined with LF plus one trailing LF and hashed as UTF-8 SHA-256, produced `a543f69b6415a8263a1532104530bcd3d891a81f552a78c14bef62e46d71aacb` exactly.
- The complete baseline-to-review range contains two commits and 47 changed paths: 2,551 insertions and 103 deletions. All reviewed content was read from the exact Git objects, never from the moving working tree. The only working-tree content consulted was this assigned Review record, which is intentionally outside the snapshot.
- The second commit, `09c7978d`, contains the applied Replan that supersedes the unused, never-dispatched premature Final Review path; materializes `exploration-carryover.md` and `review-gate-scheduling.md` plus their capability INDEX entries; updates the protocol/spec/test language; completes Tasks `4.13` and `5.4`; and leaves `5.5` as the sole incomplete node.

## Semantic review

### Exploration and lifecycle routing

- `openspec-explore` now has one narrow trigger: unresolved discovery for a new feature, architecture refactor, or major behavior change before creation of the target Change. Its entry file remains short and progressively links the full exploration, question-round, and optional marker references.
- The decision-complete handoff covers evidence, scope and exclusions, constraints, viable options, recommendation, flip condition, architecture/data flow, failures, verification, OpenSpec handoff, and selective carryover. It is explicitly planning input rather than an active record.
- Hardness, the OpenSpec router, Continue, Apply, routing guidance, root OpenSpec README, project instructions, and active/durable specs consistently prohibit re-entering deep Explore after target Change creation. Continue owns missing artifacts, Update/Replan owns invalid planning truth, and Apply owns in-scope uncertainty inside a Ready node.
- The active-Change checkpoint is explicit in both Current and Goal modes. The recovery issue truthfully records that this implementation began before registration and was detected before commit; it does not retrofit a false earlier Change chronology.

### Task, attachment, issue, and knowledge contracts

- The Task reference makes `tasks.md` the sole current DAG, with stable permanent IDs, frontmatter-only dependencies, exact file/artifact/resource mapping, independently reviewable outcomes, explicit interfaces, proving verification, and requirement/acceptance coverage. Superseded IDs are preserved in the four immutable Replans rather than reused or silently rewritten.
- The current DAG contains 17 nodes in a single valid chain and records 16 complete nodes with only `5.5` pending. The completed Task `1.1` phrase `canonical eight-node Task DAG` is historical verification from the initial recovery plan, not a claim about the expanded current graph; the later Replans explicitly account for every added and superseded node. This is therefore not a finding.
- Attachment routing is focused and progressive. The 11 snapshot attachments comprise one resolved implementation issue, two change-local knowledge candidates, four applied Replans, two closed earlier Reviews, and two talks. Each appears exactly once in the 59-line attachment INDEX, below the 120-line ceiling.
- The material-issue contract distinguishes investigated or cross-boundary root causes from routine RED/GREEN and progress summaries. The active issue has canonical frontmatter, one demonstrated root cause, chronological evidence, exact RED/GREEN commands and references, proof limits, resolution linkage, and no duplicate task checkboxes.
- Capability knowledge remains capability-local and is loaded through one INDEX. The INDEX covers all five knowledge files exactly once with summary, served requirement/capability, source, and status. The two new files contain generalized rules rather than incident chronology, hashes, or machine-specific data.
- The knowledge-order correction is consistent: complete intended bytes and intended final status are materialized before Final Review, explicitly provisional until approval, and require re-freeze if content changes. `Status: current` in the fixed capability INDEX is the intended post-approval status, not an unreviewed post-snapshot mutation; this is therefore not a finding.

### Marker and carryover contracts

- The 14-marker vocabulary is scoped to optional presentation: ten evidence/decision markers and four round-only navigation markers. Every use retains a stable English label; emoji is forbidden as the sole state source and from YAML identities, filenames, Task DAG edges, Review/issue state, and commands.
- `✅ Settled:` means an accepted decision rather than a passing test. Historical red/green circle meanings are deliberately rejected to avoid collision with risk/heat notation.
- Accepted material is classified once: canonical truth enters proposal/spec/design/tasks; rationale that prevents re-decision enters an indexed talk; reusable evidence-backed insight or visual enters indexed change-local knowledge; transient questions, navigation, redundant prose, one-off visuals, and the full transcript are discarded. Talks and knowledge do not become a parallel execution truth.

### Event-driven and immutable-snapshot Review

- The maintained entry points expose exactly three routes: evidence-gated Incident Review for a demonstrated major boundary failure, one scope-frozen Final Review for broad impact, and explicit user/agent-started External Review intake. Routine tasks, expected TDD failures, local repairs, documentation/presentation changes, Advisory observations, and diff size do not create a Review cadence.
- Verified low-impact work records `Final Review: not required` with rationale and creates no placeholder file. Incident and External Reviews cannot silently replace a required Final Review.
- Reviewer subagents receive a unique file and materializable immutable reference; a digest alone is correctly described as insufficient. The reviewer is restricted to the assigned Review file, while the coordinator owns registration, triage, Task/INDEX state, closure, and any Replan decision.
- A moving workspace does not redefine reviewed scope. Deliverable-content changes invalidate current Final-Review coverage and must be batched into one incremental review after re-freeze; unrelated explicitly excluded paths do not. Detailed Review evidence has no line cap.
- The fixed review commit satisfies those ordering rules. Both prior Reviews are closed approvals of their own earlier immutable snapshots; the unused `13:04:02` assignment was never dispatched and is correctly represented only in the applied ordering Replan, not fabricated as a Review event.

### Last semantic gate and closure readiness

- Proposal, design, delta spec, durable spec, Review/attachment/knowledge references, regression tests, talks, change-local candidates, capability knowledge, issue resolution, and all four Replans precede this assigned Review.
- The attachment INDEX records strict validation, both focused protocol passes, the fresh PS7 Quick `5/5`, exact excluded suites/paths, spec-sync disposition, broad-impact classification, and intended completed closure input.
- After an approving Final Review, the declared remaining operations are limited to Review lifecycle, Task/attachment-INDEX bookkeeping, explicit closure metadata, deterministic archive movement, strict archived validation, and the smallest lifecycle gate. No intended implementation, document, specification, test, script, talk, issue, Replan, or capability-knowledge content remains to be authored.
- Closure is nevertheless blocked by Finding 1 because the new Review lifecycle gate does not yet prove the timestamp truth promised by the protocol.

## Verification evidence

Accepted supplied evidence:

- `Protocol.Tests.ps1`: PASS.
- `OpenSpecSkill.Tests.ps1`: PASS.
- PS7 Quick Skill-only gate: `5/5` PASS — Hardness 17,198 ms; gate contract 4,753 ms; Protocol 826 ms; Workspace 40,069 ms; OpenSpec Skill 4,288 ms.
- Strict active validation: `1/1` valid, zero issues, including the post-commit run.
- Focused diff checks: PASS.
- Task state at assignment: `16/17`; Task `5.5` only incomplete.

The broad Quick gate was not rerun. Review work added only immutable-object inspection, manifest recomputation, complete diff/content comparison, and the focused timestamp reproduction below. UE, StaticJIT, Performance, Integration, plugins, `Tools/openspec`, binaries, and unrelated workspace paths remain excluded as assigned.

## Findings

### Finding 1 — `review-v2` accepts impossible and causally reversed lifecycle timestamps

severity: Required
status: open

Affected content:

- `.agents/skills/hardness/tests/Protocol.Tests.ps1:140-145` (`Test-ReviewIso8601Timestamp`)
- `.agents/skills/hardness/tests/Protocol.Tests.ps1:171-191` (`Test-ReviewClosureGate` timestamp use)
- Durable requirement `Event-driven asynchronous Review and closure`
- Change requirement `Event-driven asynchronous Review`
- Task `4.9` (`Review routes and lifecycle metadata`) and the Task `5.5`/completed-archive closure claim

Observation:

`Test-ReviewIso8601Timestamp` checks only this lexical shape:

```text
YYYY-MM-DDTHH:MM:SS[.fraction](Z|+HH:MM|-HH:MM)
```

It does not parse the value as an actual instant. Consequently, impossible months, days, hours, minutes, seconds, and offsets satisfy the predicate. The closure checker then validates `assigned_at`, `reviewed_at`, and `closed_at` independently and performs no chronological comparison, so a closed Review whose completion precedes assignment or whose closure precedes completion also passes this portion of the gate.

Focused reproduction against the exact predicate in the review commit:

```text
Value                       : 2026-99-99T99:99:99+99:99
ReviewValidatorRegexAccepts : True
DateTimeOffsetAccepts       : False
```

The same test file already contains a stronger `Test-IsoTimestamp` helper for implementation issues: it first checks the intended shape and then calls `DateTimeOffset.TryParse` with invariant culture and `RoundtripKind`. The Review path duplicates only the weak lexical half instead of establishing real timestamp validity. The supplied positive/negative `review-v2` fixtures cover missing fields and obviously malformed short text, but they do not include an impossible calendar value or a reversed lifecycle.

Impact:

The change makes truthful Review lifecycle metadata part of immutable-snapshot and closure evidence. A gate that accepts a non-existent instant or causally impossible sequence can certify fabricated or corrupted assignment/completion/closure history. That weakens reproducibility and closure provenance precisely at the new broad-impact Final Review boundary. The current assigned Review's timestamps are real, so this is not evidence of bad chronology in this record; it is a concrete defect in the durable validator and its claimed regression coverage.

Resolution condition:

1. Validate every populated `review-v2` timestamp as a real `DateTimeOffset` value, preferably by sharing the existing strict parser rather than maintaining two divergent predicates.
2. Enforce lifecycle order: `reviewed_at >= assigned_at` for completed reviews, and `closed_at >= reviewed_at`; for a Review superseded before completion, require `closed_at >= assigned_at` while allowing the intentionally unavailable completion value according to the documented schema.
3. Add negative fixtures that prove rejection of at least one lexically shaped but impossible timestamp and one reversed assignment/completion/closure sequence, while retaining the existing valid offset/fractional-time fixture.
4. Rerun the focused Protocol test and the smallest applicable Skill-only verification, update the frozen semantic snapshot, and request the required incremental Final Review because the repair changes reviewed test content.

Finding counts: 0 Critical, 1 Required, 0 Advisory.

## Decision

**CHANGES_REQUIRED.** The architecture, lifecycle ordering, fixed-snapshot semantics, knowledge materialization, progressive loading, dogfood records, and closure plan are otherwise approval-ready, but Finding 1 leaves a Required defect in the new truthful Review-lifecycle gate. Keep this Review `open`; repair and verify the validator on a new immutable snapshot, then append resolution evidence and obtain incremental re-review before coordinator closure, Task `5.5` completion, or archive.

## Coordinator triage and repair

- Disposition: accepted as a local defect inside Task `5.5`; it does not invalidate a requirement, design boundary, Task DAG edge, or artifact plan, so no Replan is required.
- RED: after adding the impossible-timestamp fixture, `pwsh.exe -NoProfile -File .agents/skills/hardness/tests/Protocol.Tests.ps1` exited `1` with `Assertion failed: lexically shaped but impossible review timestamp is rejected`.
- Repair: the duplicated regex-only Review predicate now shares strict invariant `DateTimeOffset` parsing; populated timestamps must be real offset-bearing instants; completed Reviews enforce `assigned_at <= reviewed_at <= closed_at`; superseded-before-completion Reviews may omit `reviewed_at` but still require `closed_at >= assigned_at`.
- Regression coverage: valid completed and superseded lifecycles remain accepted; impossible calendar/offset values, completion before assignment, closure before completion, and superseded closure before assignment are rejected.
- Documentation: `review.md` now states the same real-instant and causal-order contract guarded by Protocol assertions.
- GREEN: `Protocol.Tests.ps1` PASS; `OpenSpecSkill.Tests.ps1` PASS; strict active validation reports `1/1` valid with zero issues. The earlier PS7 Quick `5/5` remains the broad pre-review baseline; the focused repair did not touch its other four suites.
- State: repair is complete and awaits incremental fixed-snapshot re-review. Finding status remains open until the reviewer verifies the new immutable commit.
