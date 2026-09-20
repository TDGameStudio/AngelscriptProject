---
replan_id: replan-20260912-142757-current-spec-indentation-prerequisite
status: applied
source: verification
source_ref: "strict current-spec validation runs abbfe24103474acda6ece10d790d644a and ecd73d17a4864c938a7e894bb91d5537"
scope: "Indentation-only normalization of the two affected current specs before delta synchronization; no behavior or implementation change"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: dbfc90fd4f0d3d7e34bcfbaf95668c8128da76158ea998aa8db3a5f799415f76
result_tasks_sha256: b3ea2b24f6f4fbcb80abafa276e2a0bc2e317faa0cc9e17f4cfde242e850ecbe
created_at: 2026-09-12T14:27:57+08:00
resume_task: "1.4"
---

## Trigger and Evidence

Completion verification first validated the active Change and its completed Task DAG, then applied the specification contract's required pre-sync check to both affected current targets. The clean current `angelscript/language/frontend/lexing` spec failed strict Harness run `abbfe24103474acda6ece10d790d644a`; the clean current `angelscript/testing/baseline` spec failed strict Harness run `ecd73d17a4864c938a7e894bb91d5537`. Every diagnostic identifies pre-existing two-space direct-clause detail or continuation indentation where the current Scenario Card contract requires four spaces. Neither current spec had uncommitted changes, and the Change's own strict validation succeeded.

This invalidates the assumed synchronization prerequisite and the three-task terminal DAG, not any accepted lexer behavior. Directly formatting the current specs would exceed the existing task Files and accepted scope, while synchronizing into invalid current targets would violate the spec contract and leave closure unverifiable.

## Decision

Add task 1.4 after completed implementation tasks 1.1 and 1.3. It may normalize only leading Markdown indentation in the two exact current specs targeted by this Change. All non-whitespace text, Requirement/Scenario order, behavior clauses, detail blocks, nested Markdown content, and parentage remain byte-for-byte equivalent after removing leading whitespace. Strictly validate each current spec before synchronization and edit no unrelated spec.

Lift the same bounded authorization into proposal acceptance, design, the task File map, and requirement coverage. This is a format prerequisite only: it adds no capability, public name, product code, test behavior, or broader migration authority.

## Impact

Completed tasks 1.1, 1.2, and 1.3 and all retained evidence remain valid. Task 1.4 modifies two current Markdown specs and is Ready immediately after application. Its proof is strict current-spec validation plus a whitespace-normalized before/after comparison; no UE rebuild or Automation run is warranted. Delta synchronization and archive remain pending until 1.4 completes.

## Old Task Disposition

Tasks 1.1, 1.2, and 1.3 remain checked under their permanent IDs. New task 1.4 owns the discovered format prerequisite. It depends on 1.1 and 1.3 because those tasks supply the nested-identity and BOM deltas whose targets are being prepared; task 1.2 remains an already-complete sibling and needs no new edge. Resume at task 1.4.

## Diff Snapshot

- Affected canonical Change status is `?? openspec/changes/angelscript/test-lexer-isolated-coverage/`; the Change remains untracked as one unit.
- Current spec targets are clean before application; their strict failures are validator-only baseline evidence.
- Task `+`: 1.4; Task `~/-`: none.
- DAG edge `+`: `1.4 <- 1.1`, `1.4 <- 1.3`; other edges are preserved.
- Artifacts `~`: `proposal.md`, `design.md`, `tasks.md`, and `attachments/INDEX.md`.
- Artifact `+`: this applied replan. Durable delta specs and implementation source are unchanged.

## Preserved Work

The final-content Harness build `bfecef23c75145e1af2a8cabab9291b8` and shared Lexer run `b591e841a50e4bbaa37bd60bafb27a97` remain the implementation proof: 31/31 passed, mapped to 18 Contracts, four SpelledKinds, and nine Recovery methods. Product/test implementation, completed task evidence, delta behavior, public identities, helper contracts, and all historical attachments remain unchanged. Unrelated dirty workspace content is untouched.

## References and Result

- Specification authorization boundary: `.agents/skills/openspec/references/specs.md`.
- Failure evidence: Harness strict spec validation runs `abbfe24103474acda6ece10d790d644a` and `ecd73d17a4864c938a7e894bb91d5537`.
- Candidate strict validation succeeded in Harness run `c3380c455c084bf5bdfa87860c885866`; candidate task status run `f2f5573d1bce43749860b7597098689f` reported exactly four tasks, the first three Done and task 1.4 Ready.
- Canonical strict validation succeeded in Harness run `b6bcb3cf0f364d91a9ee330759b54f2c`; canonical task status run `c9498a93a34f40de81c9a3253b9313f6` reported exactly the same four-task state before task 1.4 execution.

Canonical replan application is complete; resume at task 1.4.
