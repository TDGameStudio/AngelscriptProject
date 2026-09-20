## Own the explanation before Create or Replan

- Read this reference whenever preparing the first handoff Gate for a new Change or an existing Change's Replan, including a formal direct-origin operation. It owns the visible explanation and question; [discussion operations](discussions.md) owns the receipt and mutation protocol.
- Enter only after the user initiates convergence. During ordinary Grill, keep explaining and asking consequential questions without proposing creation/application. An explicit bounded direct edit does not manufacture this Gate.
- Prepare the complete proposal/design/tasks/applicable spec candidates, required exports and explicit GitPlan for a new Create, or the complete changed Replan candidates and baseline hashes. Validate them in the read-only preview. Present the same material, repository selection and target that produced its `HandoffRevision`; resolve discrepancies before asking.
- Treat this as a full explanation for an intelligent reader who has never seen this system. Do not assume that earlier discussion, technical experience, a class name or a familiar acronym makes the mechanism understood. Explain patiently without childish language or talking down to the user.
- A short overview may orient the reader, but cannot replace the complete account below. No word, paragraph, diagram or question quota justifies dropping relevant detail. Completeness means every material relationship and consequence needed for this decision, not an unrelated repository dump.

## Make the pending Gate unmistakable

- Start the presentation with a visible label translated into the conversation language, such as **“Full explanation before Change creation | Awaiting your confirmation”** or **“Full explanation before Replan application | Awaiting your confirmation”**. Identify the exact target, selected scope and preview revision; explain that this is the proposed version, not a completed operation.
- Present the substantive explanation in the conversation before opening the confirmation form. Use readable sections, Markdown lists, comparisons, language-tagged code and ASCII diagrams where they help. A saved Markdown/HTML file, console output, revision hash, file list or link alone is not a presented design.
- If the account is long, deliver coherent parts in order during the same preparation. Finish the full relevant account before asking; do not require the user to say “continue” merely to obtain the remaining explanation. If the host interrupts delivery, resume the missing part before any Gate question.
- Keep the user's language for the explanation and exact identifiers for code/records. Final Change planning/export language remains governed by the owning lifecycle Skill.

## Explain the background and the present system

- State the original need, who or what encounters it, the observable problem and the desired outcome. Give a concrete triggering example; identify constraints and earlier decisions that make this design necessary.
- Explain what exists today, using current evidence. Show the relevant architecture and boundaries before suggesting replacements. Separate implemented behavior, previously accepted but unimplemented plans, historical notes and new proposals.
- Introduce each important class, module, service, artifact or workflow stage by responsibility: what it owns, what calls or consumes it, what it produces and why it exists. Define unfamiliar terms when first used, with a small concrete example where the name alone does not explain the concept.
- Trace a representative request through the current system from trigger and caller to entry point, important callees/branches, data changes and observable result. Include the upstream caller chain and downstream consumers needed to understand the change; do not stop at an arbitrary call depth.
- Explain relevant object/resource creation, initialization, ownership, updates/rebuilds and release. Describe data shape, origin, representation and next consumer; cover thread/order constraints, configuration and CVar defaults/effects when they influence this decision. For a workflow change, use its actors, records, transitions and controls rather than inventing C++ classes.
- Connect the observed problem to the exact mechanism or boundary that causes it. Mark an unproven causal explanation as an inference, with evidence and the check needed; do not present a guess as a diagnosed fact.

## Explain the complete proposed change

- Show the resulting whole relevant architecture, preserving context around changed relationships. Mark added, modified, removed and unchanged responsibilities so the user can locate each difference. Keep useful ASCII diagrams; a simplified diagram must still explain what its arrows mean.
- Carry the same concrete example through the proposed path. Explain what now happens differently at each affected phase, why it happens and what the user or downstream system will observe.
- For important code changes, show verified source excerpts or explicitly labeled proposed/simplified code in language-tagged blocks, with functional explanations beside the relevant statements. Preserve real class/function names for implemented code and label invented candidate names. Do not paste long bodies whose omitted details are immaterial.
- Map the changed behavior to owning classes/modules, interfaces, files or record artifacts. Explain responsibility moves, public names, caller/callee changes, inputs/outputs and key logic. A path inventory or diff alone does not explain the design.
- Explain relevant lifecycle, data format, compatibility, persistence, error/cancellation/retry behavior, concurrency, performance and controls. Show meaningful failure paths and boundaries, not only the happy path. Skip unrelated lenses; explain an omission only when it could otherwise mislead the reader about the scope, and do not invent machinery to fill it.
- State scope and exclusions explicitly, including adjacent systems left for later. Explain the selected naming and any unresolved sibling scope; do not silently absorb it into this handoff.

## Explain the reasons, uncertainties and proof

- Compare meaningful alternatives against the same concrete criteria and example. State why the selected approach fits, its costs and disadvantages, what useful properties it gives up, and evidence or changed conditions that would favor another option. Preserve consequential rejected decisions without replaying the transcript.
- Distinguish user-confirmed decisions, engineering assumptions, recommendations and unresolved matters. Investigate discoverable facts. A necessary unanswered user-owned choice returns to explained Grill; do not hide it as future work inside an apparently ready Gate.
- Describe the actual candidate Task DAG, bounded outcomes, dependencies and proving commands before Create. Ensure plan later verifies these committed artifacts and retains historical-plan compatibility; it does not defer new planning until after this Gate. For Replan, show the actual candidate task/artifact changes and retained completed IDs.
- Explain how success will be demonstrated: expected observable behavior, concrete cases and suitable proving commands when determined, evidence already obtained, and checks still to run. Explain why a test proves the claimed behavior and any important limit. Never report proposed checks as passed.
- Cover real migration/rollout/recovery needs, compatibility effects and material risks when relevant. Do not invent a migration, exhaustive suite or risk ceremony for an unaffected area.
- Use [explaining-work](../../explaining-work/SKILL.md) for source investigation, causal explanation, code walkthroughs and visuals. A reader should be able to explain why this change exists, how it works and what accepting it permits without opening a separate file.

## Add the Replan-specific account

- Identify the existing Change, interrupted task/return position and actual trigger. Explain which accepted requirement, architecture boundary, dependency, verification contract or required artifact has become invalid, with its evidence.
- Compare the accepted plan, actual work already completed and proposed revised plan as distinct states. Show preserved implementation/completed tasks, changed/new task outcomes and edges, affected artifacts, and proof that remains valid versus proof that must be repeated.
- Explain what is paused, what this application writes, where execution can resume and how it affects the already authorized queue. The Replan Gate does not itself restart execution; the later arrangement chooses continuation.
- Keep the accepted planning records intact until the exact Replan is approved and applied. Use the same presented candidate/baseline map in the mutation; a material change requires a fresh preview, explanation and answer.
- Show that Replan commits only the accepted formal records and provenance. Existing implementation remains as-is for continued work; dissatisfaction or Replan does not authorize an incomplete-code checkpoint, withdrawal or abandonment.

## Explain the exact Git boundary

- Show each selected repository/branch, baseline, paths and meaningful hunks, plus excluded live/staged work. Explain what the proposed commit contains and why each part belongs to this scope. Mixed files require an explicit selected patch; a directory inventory alone is insufficient.
- Create/Replan save the complete accepted formal planning before the arrangement Gate, including a visible commit message/intent. Their Git failure is planning-applied/commit-pending and blocks execution; the exact retry preserves the original decision and UID/applied record.
- Planning approval does not approve future implementation commits. Explain that the final close normally contains those results and its specific Gate; no default per-task commit or extra old-code checkpoint is implied.

## Show the handoff boundary and then actually ask

- Close the account with a visibly separate **“GATE: Confirm this version”** block translated into the conversation language. Restate the operation, exact target and `HandoffRevision`, the chosen scope and what approval immediately changes. This concise confirmation follows the full explanation; it does not replace it.
- Explain carryover: selected design/handoff, required research, decision rationale and attachments, where they go and why; state relevant excluded siblings. Reuse the actual export list instead of implying the entire draft will be copied.
- Explain the next boundary: successful Create/Replan opens a separate arrangement Gate for draft archive/retain and execution now/queue/later. This first choice does not silently approve archive or start/resume implementation.
- Then actually submit the required choice through a host mechanism permitted to collect approval. Use concrete labels: **create this version / apply this Replan**, **continue explaining and discussing**, **park this scope**. Tailor the operation and consequences; do not reduce the choice to an ambiguous “OK?” or combine it with an unrelated naming question.
- Respect [host interaction](../../grill/references/hosts.md): a clarification-only tool cannot collect approval. If a form fails or is unavailable, deliver the complete actionable question through the permitted visible fallback. A promise to ask, unsent payload or tool acceptance without an answer is not a decision.
- Actual approval binds its source to this presented target/revision. Silence, cancelled forms, past convergence, “I understand” or agreement with one explanation is insufficient. A free-text request to change the design returns to discussion rather than being coerced into approval.
- Continue discussion when selected: re-explain the resulting relevant architecture after each answer and ask the next ready substantive question without requiring “continue”. Park only when actually selected; preserve the return position.
- When the user says an explanation is incomplete, use [explaining-work](../../explaining-work/SKILL.md)'s improvement loop to distinguish missing explanation, unclear spec, missing knowledge, missed retrieval or an unproven cause. Capture the sourced question in the existing topic draft, improve the current account and return to this Gate. A material candidate change invalidates its old decision; a clearer explanation alone does not invent new authority.

## Keep records light and authority exact

- This file is the shared Gate instruction, not an additional lifecycle or mandatory per-round document. Reuse the selected scope's `design.md` and `handoff.md`, or the Replan candidate/talk, for concrete decisions and handoff facts. Do not create another compulsory `GATE.md`, duplicate the full visible explanation into CONTEXT, or mirror the conversation.
- If the user requests a standalone readable account, save it in that draft's existing research or Change attachment location and link it from the owning record. Still present the relevant explanation before asking.
- Runtime revision checks protect identity and mutation boundaries; they do not prove that the user received or understood a good explanation. Do not claim that a checker validated comprehension, or add a fake “explained=true” as approval evidence.
- The operation's actual receipt remains authoritative. After successful handoff, use [discussion operations](discussions.md) for the distinct arrangement Gate and its exact recorded answers.
