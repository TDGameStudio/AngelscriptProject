---
disposition: candidate
---

# Knowledge candidate: provenance of the project's code-review rules

Reusable insight: when adapting an external review guide, compare it idea-by-idea against the project's existing lifecycle reference and real archived Review records before copying anything; most ideas are already present under other names, one or two are genuinely missing, and at least one core premise (here, mandatory per-task cadence) contradicts project policy and must be rejected explicitly.

Evidence: the table below (captured 2026-09-11 from brainstorming draft `openspec/drafts/harness/code-review-skills/findings/superpowers-review-analysis.md`) and 36 archived `review-*.md` records.

Boundaries: describes superpowers `receiving-code-review` / `requesting-code-review` as of the pinned `Reference/superpowers` clone; the project rules themselves live in `.agents/skills/code-review/SKILL.md` and `harness/references/review.md`, not here.

Application: read before adapting any other external review, triage, or PR-etiquette guidance; reuse the adopt / adapt / reject columns as the template.

Sources: `Reference/superpowers/skills/requesting-code-review/code-reviewer.md`; project `review.md`; talk `talk-20260911-155000-single-code-review-skill.md`.

---


## 1. `requesting-code-review` + its `code-reviewer.md` template

| Idea | Have it? | Where / note |
|---|---|---|
| Reviewer gets crafted context, never the coordinator's session history | Yes | `review.md` "Fixed snapshot": reviewer receives snapshot + output path, not the conversation |
| Review unit = `BASE_SHA..HEAD_SHA` git range | Yes, more general | Ours is an immutable `snapshot_ref` (commit, synthetic ref, or hash-table Markdown for untracked dirs — see `review-20260910-141459-process-typeids.md`) |
| Read-only on this checkout; use a temp worktree for other revisions | Partly | `code-reviewer` says "never follow a moving live workspace"; nothing says how to inspect another revision safely |
| Reviewer must not dispatch sub-reviewers (anti-recursion, "second opinion" is waste) | No | Absent. Our archive shows the *coordinator* splitting one Change into 4 parallel Reviews (`builder-ast/coordinator/metadata/semantics`) — that is fine; the reviewer itself forking is not |
| Check list: plan alignment / code quality / architecture / testing / production readiness | Yes | `code-reviewer` "Evaluate" list; adds security, bounded resources |
| "If the plan itself is wrong, say so" | Half | `code-reviewer` says "Do not prescribe Replan" but never tells the reviewer to *label* a planning defect distinctly so the coordinator can evaluate it |
| Calibration: not everything is Critical; acknowledge strengths | No definitions | We name `Critical / Required / Advisory` but never define them; no "what was checked and found sound" section |
| Output: Strengths / Issues by severity / Recommendations / "Ready to merge?" verdict | Yes for verdict | `APPROVE` / `CHANGES_REQUIRED`; no required coverage statement |
| Mandatory cadence: after every task, before merge | **Contradicts ours** | Project rule: explicit request only. This is the part to reject |
| "Rationalizations" table (don't review the diff inline yourself) | No | Useful psychology, wrong premise here: inline Review is allowed |

## 2. `receiving-code-review`

| Idea | Have it? | Where / note |
|---|---|---|
| Verify against codebase before implementing a finding | Yes | `review.md` "Triage": reproduce or verify against the snapshot, then classify |
| Reject wrong findings with technical reasoning | Yes | `rejected` status with evidence |
| No performative agreement / gratitude; state the fix | No | Absent. Cheap, and it matches the project's existing "no mannered prose" preference |
| Clarify **all** unclear items before implementing **any** (items may be related) | No | Absent. Relevant: multi-finding Reviews are the norm in our archive |
| Repair order: blocking → simple → complex; test each individually | No | `review.md` has classification but no repair ordering; grouped TDD would say "one feature group at a time" |
| Trust differs by source (human partner vs external reviewer) | Partly | `requested_by: user | external-agent` is recorded but no behavioral difference is stated |
| Finding conflicts with a prior user architectural decision → stop, ask the user | No, and needs adapting | In Harness this is a user-owned decision surfacing after Change creation: attended → put it to the user; unattended → park via `openspec-update-change` replan. Never decide it locally |
| YAGNI check ("implement properly" → grep usage first) | No | Absent; small but real (reviewers love asking for completeness) |
| Correct your own wrong pushback factually, no apology | No | Style rule; fold into the "state the fix" line |
| GitHub thread replies via `gh api` | N/A | No PR workflow here |

## 3. What our archive says about real practice

- 36 Review files across 9 Changes; heavy use of re-review chains (`-rereview`, `-recheck`, `-final-recheck`, up to 5 rounds on `refactor-vm-symbolic-execution`). Rules for re-review exist ("append under the original finding") but there is no rule bounding a chain: when does a 5th recheck stop being a Review and become a verification loop?
- Several early records were `requested_by: hardness` — auto-started Reviews, since banned. The ban is now enforced by `harness.evolution.status`.
- Reviews are long, evidence-heavy, and often planning-plus-code (the sample reviews design sections and spec requirements alongside source). Our reviewer rules already fit that; superpowers' "diff between two SHAs" would not.
- Reviews were split by area in parallel with separate reviewer identities — coordinator-side fan-out is an existing practice worth writing down.

## 4. Rules our code review needs (candidate list)

Reviewer side — belongs in `code-reviewer/SKILL.md`:

1. Input contract: the assignment names requester, kind, `snapshot_ref` + digest, scope, exclusions, requirements/tasks, and the verification evidence already run. Missing any → report the limitation, do not guess.
2. Read the tests and the task cards first; then the code; judge whether tests prove the promised behavior.
3. Read-only. Inspect other revisions via `git show` / a temporary worktree, never by moving HEAD or touching the index.
4. No sub-dispatch: one reviewer per assigned Review file; split-by-area is the coordinator's decision, made before assignment.
5. Do not rerun broad gates already supplied as evidence; focused reproduction is fine.
6. Severity definitions: **Critical** = wrong behavior, data/safety loss, or a broken contract that must block; **Required** = must be fixed before this Change closes but does not endanger the snapshot's correctness claim (architecture, missing case, test gap); **Advisory** = optional improvement, may be deferred with a named follow-up.
7. Every finding: file/line (or record/section for planning findings), observation, impact, evidence or reproduction, concrete resolution condition, `status: open`.
8. Planning findings are labelled as such ("the requirement/design is the defect") and never prescribe Replan.
9. A "Verified sound" section lists what was checked and found acceptable — coverage statement for re-review, not praise.
10. Verdict plus a verification story; `APPROVE` only with no open Critical/Required; record the real `reviewed_at`.

Coordinator side — belongs in `harness/references/review.md` (Triage section):

11. Reproduce or verify every finding against the snapshot before acting; reject with evidence when it does not hold.
12. Clarify every ambiguous finding before repairing any; partial repair on partial understanding is forbidden.
13. Repair order: Critical → Required → Advisory; within a severity, blocking → simple → complex; verify each repair with its owning task's proving selection before the next.
14. A finding that contradicts a user-owned decision recorded in the design/talks is not repaired locally: attended, put it to the user; unattended, park it through `openspec-update-change` replan.
15. A finding that asks for functionality nobody calls is answered with usage evidence, not implementation.
16. Language: state the repair and its evidence; no performative agreement, no gratitude, no apology when a rejection turns out wrong — record the correction.
17. Re-review chains: a re-review checks only the resolution conditions of the previous findings on a new immutable snapshot; a new scope is a new Review. (Bounds the 5-round pattern.)
18. Fan-out: the coordinator may split one snapshot into several Reviews by area, each with its own file and reviewer; the same reviewer never reviews two overlapping scopes of one snapshot.

Everything else in the two superpowers files (cadence, GitHub replies, rationalization tables, "your human partner" framing) is either contrary to project policy or irrelevant here.
