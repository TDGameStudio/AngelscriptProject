# Draft Directory Contract

Load when opening, resuming, updating or handing off a topic draft.

## Location and layout

```text
openspec/drafts/<domain>/<topic>/    // One continuing topic; zero, one or several Changes may result.
├─ README.md                        // Current focus, mode, continuation and design navigation.
├─ log.md                           // Append-only actual conversation, including diagrams and answers.
├─ findings/                        // Shared evidence and optional topic entry pages.
├─ glossary.md                      // Shared vocabulary, only when needed.
└─ designs/<scope>/                 // An independently describable delivery outcome, before approval.
   ├─ README.md                     // This design's boundary, status and approval sources.
   ├─ design.md                     // Candidate, then accepted design for this scope.
   ├─ glossary.md                   // Relevant settled names, when needed.
   └─ handoff.md                    // Written once the design and Change carryover are confirmed.
```

Domain follows OpenSpec conventions; topic and scope use lowercase kebab-case outcome names. A scope name need not equal the eventual Change ID. Create only needed files: a small investigation may have only README.md and log.md. Research without a bounded delivery stays in findings/<topic>.md; once its outcome is identifiable, create the scoped README/candidate design without waiting for approval. A/B alternatives for one outcome belong in one design; independently deliverable outcomes may have sibling directories. Split genuinely independent topics into linked drafts, not merely because a second Change is possible.

## Topic README

```yaml
---
draft: <domain>/<topic>
mode: research | proposal | design
status: exploring | parked | abandoned
opened: YYYY-MM-DD
---
```

The body begins with five concise Markdown list items, then optional reading order and design links:

- **此刻**：current activity in plain language.
- **焦点**：one relative local link to the current finding, log, or design.
- **已决**：the latest settled decision and its source round, or `无`.
- **下一问**：the next open decision, or `无`.
- **讲清于**：`[R<n>](log.md#r<n>) · YYYY-MM-DD` for the last visible explanation, or `未讲`.

`harness.draft.status` checks these five fields, link closure, and the log-round anchor; it cannot establish that the explanation really appeared in chat or that the log is verbatim. The author maintains those facts. Link to authoritative scoped status; do not maintain a second approval ledger.

Mode describes the current activity: investigate, propose, or converge a design. Switch it with the focus and append the reason to log.md. It is not approval or a one-way maturity ladder. Each design keeps its own state, without its own mode. Going back to research does not undo approval or reopen an existing Change's design.

Topic status stays exploring while conversation or research remains. Waiting for a reply or handing off one design does not park it. Park when discussion is intentionally paused, with what would revive it; abandon when dropped, with why. Resume a parked topic in the same directory. Never mark an entire multi-design topic handed-off because one design produced a Change.

## Scoped design README

```yaml
---
design: <scope>
status: exploring | designed | handed-off | parked | abandoned
opened: YYYY-MM-DD
handed_off: YYYY-MM-DD            # once this design was handed off
target_change: <domain>/<change>  # once its Change exists
archived_as: <archive-path>       # optional later navigation
---
```

The body states this design's scope/exclusions, links its design and related research, records approval and naming/carryover round sources, and gives its next step. State belongs here, not in emoji markers or the topic mode.

- exploring: candidate or incomplete design, including partial approval and waiting for replies.
- designed: this exact design is accepted and its required names and OpenSpec carryover are settled; handoff.md is decision-complete. Topic mode may now describe other work.
- handed-off: its named Change exists and the selected English attachments/carryover are seeded and verified. Creation or export interrupted midway is resumed before marking this state.
- parked / abandoned: retain this design and reason without closing its siblings. Reviving parked work resumes its earlier context; substantive revisions invalidate the affected prior approval and are presented again before a new handoff.

One scoped handoff creates one Change. Its accepted design/handoff are historical inputs after handoff; later work on the same Change routes to update-change/apply. A separately approved new outcome may become a sibling design, with dependencies and overlap identified explicitly. Never use the topic's mode or another design's approval to authorize it.

Explicitly authorized direct implementation without a Change uses the accepted design and records the user instruction, outcome and verification in the design's continuation/evidence. Do not fabricate target_change or handed-off, demand Change-only carryover, or invent a new lifecycle state. The topic may remain exploring or be parked when discussion pauses; implementation completion is described in prose.

## Conversation and navigation

- Announce Draft opened: <path> (mode: <mode>) once. Keep log.md append-only: every actual user message, assistant discussion, displayed diagram, submitted tool question/options and returned answer retains original wording. Corrections, interruptions and resumed replies are new entries; a summary never replaces the original. Do not log prepared text as already delivered or an empty tool result as a choice.
- Send the situation brief in chat before the form. Saved text, tool output and links are not a conversational explanation. Log the delivered brief before a blocking question when practical; tool history preserves pending questions until logging resumes.
- Each findings/<topic>.md carries evidence, diagrams as shown, conclusions and open points. Identify observations versus proposals and the source/time context when it affects interpretation. Optional topic entry pages help large findings collections; avoid empty navigation scaffolds.
- Resume through `harness.draft.status`, the focused finding or scoped README/design, then the cited log rounds. Use the tail for recent messages, not as the sole proof of approval. Mark reopened decisions with their original decision reference.
- Shared glossary.md carries common terms. The selected design's glossary records its relevant names and any shared definitions it relies on, with provenance. New public names use the naming round. Do not silently change the meaning of a name already exported to a Change.

## Language and export

New local draft material defaults to the user's conversation language, including README.md, findings, design.md, handoff.md, glossary.md and diagram explanations. Honor an explicit draft-language preference; otherwise infer the language from the user's conversation. Do not rewrite historical files merely because the discussion language changes. log.md retains original-language wording. Every final Change record and attachment is English, including carried findings and explanatory diagram labels; preserve code identifiers and accepted meaning.

openspec-create-change exports the selected design.md, handoff.md and glossary.md into attachments/drafts/, plus cited research dependencies into attachments/drafts/findings/. Copy English text or faithfully translate other languages with source/approval provenance. If no naming decisions apply, create an explicit not-applicable glossary for the receiving contract. Preserve original local files. No Change file may depend on an openspec/drafts/ filesystem link; provenance may identify the local source and round as plain text. Material translation ambiguity must be resolved without inventing decisions. Do not translate or export the entire transcript or unselected sibling material.

The consumer materializes only confirmed talks/knowledge, indexes the English output and updates only the selected design's state and topic navigation. Local originals, including design and cited findings, remain; exporting copies never moves or deletes them.

## Legacy flat drafts

Existing top-level design.md/handoff.md/glossary.md and the root target_change remain readable as one legacy scoped record. Preserve those paths and historical approval; do not bulk-migrate old drafts or logs. A root handed-off record may cover only part of a topic: use the documented scope and remaining research rather than treating the entire topic as exhausted.

When another bounded outcome appears in a legacy topic, create designs/<scope>/ for that new design and clearly label the old root files/target as legacy provenance in the topic README. Maintain the new current-focus/mode/topic status without erasing the old handoff mapping or reinterpreting its approval. If continuing residual research without a bounded outcome, use shared findings and a continuation note; no new design directory is required. Before export, select the exact scoped directory or explicitly selected legacy root. If several candidates exist and the request does not identify one, do not guess by timestamps or newest paths.

## Boundaries

- Drafts remain local and ignored under `openspec/drafts/`; they carry no Task state, Ready state, or DAG. Harness checks one exact topic or selected scope, never a tree-wide inventory. The portable CLI does not validate drafts.
- Use `harness.draft.check` for the selected designed scope before creating a draft-backed Change. Its structural check includes handoff headings, target identity, referenced local files, and a scoped approval round for behavior work. Human review still owns approval meaning, English translation, and chat/log identity.
- Use `harness.draft.archive` only for an explicitly completed or abandoned topic. Completion requires no next question and no exploring or parked scoped design. A parked topic stays active. Archived drafts are immutable under ignored `openspec/archive/drafts/<domain>/<date>-<topic>/`; restart discussion in a new linked topic.
