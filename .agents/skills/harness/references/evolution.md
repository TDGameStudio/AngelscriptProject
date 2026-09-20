# Feedback, improvement and update visibility

## Keep new feedback in its topic draft

- Capture concrete workflow friction, routing mistakes, incomplete explanations and tool gaps with `harness.observe`: bounded `Category`/`Summary`, actual `SourceRef`, optional `DedupKey`, `OwnerDraftId`, `OwnerScope`, Change/stage/correlation. Prefer a meaningful existing owner, such as a Harness-upgrade topic; the tool creates an ignored topic when none is provided. Modes remain research/proposal/design, not a new upgrade type.
- The source can be “this explanation was unclear”; the cause is still a question. Capture alone neither diagnoses a Skill defect nor selects its repair. Do not turn expected RED, ordinary unfamiliarity or cancellation into proof of broken prompts.
- New observations live inside the owning `openspec/drafts/<domain>/<topic>/designs/<scope>/design.md`, with README navigation and key context. Repeats retain actual sources under the same owner. No new Saved observation JSON, triage ledger, derived INBOX.md or separate harness-update Skill is required.
- `harness.evolution.status` with `InboxOnly=$true` is a read-only grouped view. Check Issues and Truncated before treating it as complete. Historical Saved/Hardness observations and archived draft observations remain readable and unchanged; they are not writable new-feedback stores.
- Drafts remain ignored/local. A commit or `updates.json` does not back them up across machines. Preserve old material in place; do not migrate or delete it as routine cleanup.

## Explain, select and improve

- When the user says “what does this mean?”, “I did not understand”, or asks for another explanation, invoke explaining-work's [improvement loop](../../explaining-work/references/improvement.md). First improve the current explanation from source, current specification and the owning knowledge INDEX/entry. Distinguish explanation method, unclear intended spec, missing capability knowledge, missed retrieval and unproven cause. Grill only the consequential ambiguity, without a compulsory understanding quiz.
- Record the sourced improvement question in the owning topic and preserve the interrupted work/Gate/Grill return point. Capture may remain draft-only indefinitely. It does not create a Change, queue item or default successor, and does not block unrelated authorized work.
- At a useful discussion point, present a batch with source/example, impact, suspected owner, confidence, bounded proposed change and proving check. Read each actual source before calling it an unresolved defect. User unfamiliarity, synthetic fixtures and historical corrections have different meanings.
- Use `harness.evolution.triage` with exact `ObservationIds`, actual `DecisionSource`, bounded `Scope`, and selected/deferred/dismissed disposition. Selection can come from existing explicit task authority; avoid asking twice. Unselected observations stay unchanged. Further work on historical/archived feedback reuses its actual source in an active topic, without rewriting the old record.
- Route selected work by intent: explicitly authorized direct maintenance stays direct; substantial unsettled design remains in Brainstorming/Grill; an accepted formal outcome uses the ordinary Create/Replan Gates. No separate upgrade workflow is necessary.
- A current authorized Change may already own the improvement. Otherwise, do not edit unrelated Skills, behavior specs or tools merely because an observation recurred. Factual knowledge publication follows the owning [knowledge admission contract](../../openspec/references/knowledge.md) and actual authority; behavior changes still need their accepted scope and proof.

## Resolve with evidence, archive without erasing questions

- Resolution requires an actually selected scope, concrete `Result` and nonempty `Evidence` through `harness.evolution.triage -Disposition resolved`. Record the implemented correction, appropriate regression or independent consumer evidence, and proof limits. A handoff, user selection, draft archive or Change directory move is not repair evidence.
- Preserve pending/deferred/unproven questions when explicitly archiving a draft. Explain their disposition first; archival is a safe move, not a cleanup that silently declares all discussed problems fixed.
- Report repaired, factually supplemented, dismissed and still-open topics separately. Historical reconciliation must cite actual completion evidence and identify itself as reconciliation, not a new test run.
- Corrupt records, unknown IDs and changed draft blocks are errors. Queries never repair them; triage validates the selected draft blocks before publication.

## Publish the verified workflow update

- After a verified release, update `harness/updates.json`: revision, published_at, human-readable summary and affected_skills. Describe observable changes and their bounds.
- `harness.status` is the update source; display the revision/summary at entry or when it changes. Missing/invalid metadata is UpdatesIssue. No seen registry, watcher, daemon or external notification is implied.
- Exact Change terminal checks remain in [closure](closure.md). Ignored topic feedback is non-blocking until admitted as a material issue in the current scope. Post-archive discoveries preserve history and await selected authority; never auto-create a successor.
