---
disposition: candidate
---

# Knowledge candidate: auditing a task plan for executability

Reusable insight: a plan's executability can be measured before reading any card in depth by counting four things per `tasks.md` — machine-valid nodes (`task.status` Ready > 0), numbered implementation steps, literal cases with expected values, and interface signatures in code fences — and by checking whether any task's outcome is "complete the design" or "specify the interface names". Optional section labels degrade into prose under time pressure; only labels that are checked (by parser or preflight) stay filled. A first task that finishes the design means the symbols were never settled in a naming round, and every later card will say "consume task 1.1's contract" instead of naming anything.

Evidence: captured 2026-09-11 in `attachments/drafts/findings/current-task-format-audit.md` (7 active plans: 5 retired-format with Ready = 0; 2 rich-format with 3 numbered steps across 24 tasks, Cases as sentence chains, 0 interface fences) and `attachments/drafts/findings/delegates-tasks-review.md` (`angelscript/feature-delegates-ue-interop`: task 1.1 "Complete the delegate design … specify actual public/internal interface names", nine later cards consuming it, test classes named only by prefix, one prose Verification).

Boundaries: describes plans written under the root-checkbox contract before the heading-node contract of `harness/refactor-task-cards-heading-nodes`; the counts are indicators, not the contract. Plans created before 2026-09-11 predate the brainstorming naming gate, which explains deferred naming without excusing it.

Application: run the four counts and the "finish the design" check before accepting, migrating, or applying any plan; a plan failing them goes to `openspec-update-change` with a naming round, not to apply.
