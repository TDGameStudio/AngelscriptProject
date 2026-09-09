---
replan_id: replan-20260908-181452-text-wildcard-type
status: applied
source: implementation-evidence
source_ref: task 4.8 RED run d2af96a8cd4a430f928dc574a5563515
scope: preserve the generic ?& parameter type required by the complete detached FText format surface
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 3a4cc4af40797d29d69442f50ac9a7eeda33ace890c9803d813a922424d9dc22
result_tasks_sha256: f9a4b95063d6bd6e35f8cca3552a25ae0a21007f129e401140f21d82d07cada5
created_at: 2026-09-08T18:14:52Z
resume_task: 4.8
---

# Trigger and Evidence

Task 4.8's exact seven-case group reached six successes in run `d2af96a8cd4a430f928dc574a5563515`. The complete-provider case failed during detached validation because five real `FText::Format` generic overloads contain `const ?&`, and the extracted binding type parser rejected `?` as a base type at bytes 40..41.

The provider surface and AngelScript generic-call contract require this wildcard. The accepted task boundary named the FText providers and Core consumer but omitted the shared syntax, binding-resolution and stable-type identity owners needed to represent it without replacing or deleting provider declarations.

# Decision

Add the focused frontend type syntax, binding declaration and type identity files to task 4.8. Represent `?` as a distinct stable wildcard type use, preserve its reference and const qualifiers, and resolve it to AngelScript's existing wildcard data type when applying records. State this requirement explicitly in the task outcome.

# Impact

- Proposal, durable specifications, design, task cases, proving command and dependency edges remain valid.
- Task 4.8 keeps its ID and grouped RED evidence.
- The implementation boundary expands to the shared parser and identity files that own `?&`.
- Existing primitive, nominal and callable identities retain their values and behavior.

# Old Task Disposition

- Task 4.8: `preserved`; remains active with six passing behavior cases and one failing complete-provider case.
- Completed tasks and their evidence: `preserved`.
- All other pending tasks and DAG edges: `preserved`.

# Diff Snapshot

- Affected current artifact: `tasks.md` within the active uncommitted Change.
- Task changes: `~4.8` file boundary and explicit wildcard handoff; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.
- Implementation evidence at capture consisted of the new text fixture and bounded FText/provider recording repairs; unrelated root and plugin workspace changes were preserved.

# Preserved Work

The successful build `aceef1217cfa4b2d98473c53f317685f`, six passing task behaviors, deterministic culture restoration, explicit invalid-format diagnostic and missing-string-table isolation remain valid. No overload or case is removed to bypass wildcard parsing.

# References and Result

- RED summary: `Saved/Harness/Unreal/Runs/d2af96a8cd4a430f928dc574a5563515/Summary.json` — six successes, one failure.
- Exact diagnostic: malformed generic `FText::Format` declaration at wildcard bytes 40..41 in that run's Unreal log.
- Inverse task patch: `attachments/data/replans/replan-20260908-181452-text-wildcard-type-before.patch`.
- Strict validation: run `b0df5df0356b4cfaa04419b1fe43ecc1`, PASS.
- Result: task 4.8 remains the resume node with all parser and stable-type owners required for its complete provider surface.
