## Context

The accepted pre-Change exploration compared the compressed current Skills, the earlier customized exploration prompt, official OpenSpec references, the deleted schema guidance, and three recent immutable Hardness dogfood archives. It found that the new architecture was structurally smaller and stronger around Task DAG, Review, Replan, and closure, but had removed four authoring boundaries that still affect execution quality.

Implementation then exposed a fifth boundary: an accepted conversation plan was incorrectly treated as equivalent to an active Change. The working-tree implementation and initial gates existed before the Change manifest. Recovery must preserve that chronology and avoid claiming the normal sequence occurred.

After the first independent Review, the user restored one deliberate part of the earlier exploration UX: a small emoji marker vocabulary and durable carryover of valuable exploration decisions, visuals, and knowledge. This expands the accepted design before closure, so the earlier Review remains valid for its fixed snapshot but cannot serve as the final expanded gate.

The marker increment then exposed a Review scheduling problem. Implementation and focused tests took only minutes, while immediate broad Review added most of the elapsed time and was launched before the user had frozen scope. Review must remain detailed, but its trigger, snapshot, and asynchronous execution need sharper boundaries.

## Goals / Non-Goals

**Goals:**

- Make deep exploration a strict pre-target-Change activity and produce a decision-complete handoff.
- Keep task-local investigation lightweight and autonomous after Change creation.
- Make Apply verify that the canonical active Change and Ready task exist before implementation mutation.
- Restore concise, progressively loaded authoring policies and test their durable semantics.
- Preserve material issue history and promote one reusable self-iteration invariant.
- Make exploration easy to scan without turning emoji into machine state, and retain only accepted decision or reuse value after Change creation.
- Reserve intermediate Review for demonstrated major incidents, run one Final Review after scope freeze only for broad-impact work, let verified small low-impact work skip Review with rationale, and ingest explicit External Reviews without stopping unrelated work.

**Non-Goals:**

- A new loop runtime, database, event store, Rust attachment parser, or OpenSpec executable release.
- A mandatory deep Explore for clear repairs, mechanical documentation, or an already accepted ready plan.
- Editing immutable archives or importing the inactive `openspec-work` draft.
- A review daemon, generic async runtime, mandatory per-file manifest, or Review report length cap.

## Decisions

### 1. Explore exists only before target Change creation

`openspec-explore` is not a general investigation leaf and never re-enters an existing Change. It establishes evidence, scope, viable options, a recommendation, flip condition, risks, verification, and the OpenSpec handoff. Once the target Change exists, Continue creates missing artifacts, Update/Replan revises invalid truth, and Apply owns task-local technical uncertainty.

### 2. An accepted handoff is not an active Change

For OpenSpec-scoped work, Hardness orientation must resolve the canonical Change and Apply must obtain `task.status` before implementation mutation. Current mode changes only the workspace location; it does not remove lifecycle checkpoints. If missing registration is discovered after work begins, the coordinator records a material issue, creates an honest recovery Change before commit, maps the existing diff to tasks, and reruns verification/review.

### 3. Authoring policy is split into focused references

Task quality stays in `references/tasks.md`; event routing in `attachments.md`; issue lifecycle in `implementation-issues.md`; knowledge admission in `knowledge.md`. The entry Skills link only what their current event needs. This retains progressive loading without restoring a broad `openspec-schema` Skill.

### 4. Implementation attachments are issue-only

Routine TDD RED, immediate fixes, progress summaries, final integration evidence, and closure preparation do not create issue files. Multiple symptoms with one demonstrated root cause share one lifecycle. New active issues use stable frontmatter, exact RED/GREEN evidence, proof limits, and same-edit INDEX registration. Existing archives remain untouched.

### 5. Knowledge promotion stays capability-local

Change evidence may produce concise capability knowledge only after repair, verification, and review. Every capability knowledge directory has one INDEX. Project instructions receive only cross-capability invariants; no parallel project knowledge tree is created.

### 6. Markers are presentation; carryover is selective evidence

The recovered marker vocabulary is intentionally narrower than the historical set. `✅` means settled, not test-passed; `🔁` replaces historical `🔴` for reopened decisions; historical `🟢` is removed because it overlaps settled/unblocked state and conflicts with visual-risk conventions. Core markers cover facts, questions, recommendations, risks, outcomes, scope, sources, and knowledge candidates. Round-only markers cover heavyweight, new, held, and reopened navigation.

Every marker line also carries a plain English label. Emoji never appears in YAML identities, filenames, Task DAG edges, or as the sole source of review/issue/task state. An accepted handoff classifies carryover: canonical truth goes to proposal/spec/design/tasks; non-obvious decisions and decision visuals go to indexed talks; reusable evidence-backed insights and reusable visuals go to indexed change-local knowledge; transient conversation state is discarded. Talks and knowledge never become a second current-truth system.

### 7. Review is event-driven and snapshot-bound

Hardness has exactly three Review routes. Incident Review is automatic only when evidence demonstrates a major security/trust, destructive data/history, public compatibility, cross-repository atomicity, or invalidated cross-boundary completion problem. Final Review is a single scope-frozen gate for broad public, cross-boundary, security/destructive, compatibility/release, production-performance, or architectural impact. A verified small low-impact change records `Final Review: not required` with rationale and creates no Review file. External Review is explicit user/agent input that Hardness registers and triages without treating the report itself as a Replan. Diff size alone never determines impact.

Reviewer subagents run asynchronously against an immutable content reference and write only one unique Review file. The main thread may continue disjoint work. If it changes task-owned final scope after assignment, the result remains historical evidence but cannot close the current Final Review; late changes are batched into one incremental Final Review after the next freeze. Review records use actual assignment, completion, and closure timestamps. Reports retain as much detailed evidence as needed and do not have a line limit.

## Risks / Trade-offs

- A strict pre-creation Explore boundary cannot retroactively fix an already created vague Change. Recovery uses Update/Replan or closes the bad scaffold before creating a replacement; it never runs Explore against the existing target.
- Static protocol tests cannot prove writing quality, but they prevent the critical entry points, schema fields, and indexes from disappearing silently.
- Root README already contained unrelated user edits. Its obsolete OpenSpec sections must be staged as isolated hunks so those unrelated edits remain unstaged.
- The recovery Change documents implementation that began early. The issue record makes this visible; tasks describe the remaining verification and closure work rather than inventing a false chronology.
- Too many visual markers become noise and can conflict with other diagram legends. The reference separates a core vocabulary from round-only markers, uses at most one leading marker per line, and requires a textual label so records remain readable without emoji.
- Carrying every exploration note would duplicate the transcript and inflate context. Only accepted decisions whose rationale prevents re-decision and insights with plausible reuse across tasks enter indexed attachments.
- Asynchronous Review can race with a moving workspace. An immutable `snapshot_ref`, explicit exclusions, and final-snapshot comparison prevent the reviewer from unknowingly reviewing later content.
- Starting a required Final Review before user changes settle creates repeated gates. Scope freeze requires all queued changes and Replans to be absorbed; post-freeze edits are accumulated before one incremental Review rather than reviewed individually. Low-impact work skips the gate instead of manufacturing a placeholder Review.
