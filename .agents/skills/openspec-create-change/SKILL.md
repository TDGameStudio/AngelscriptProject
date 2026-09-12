---
name: openspec-create-change
description: Create a Change from one selected approved brainstorming design and its confirmed handoff. Export English design, handoff, names and cited evidence, materialize confirmed talks/knowledge, then route to Ensure plan. One invocation per scoped handoff; a topic may yield several Changes. Resume an existing target without replaying creation.
---

# Create a Change from a Scoped Design

This Skill owns `change create` and the export of one accepted handoff. It connects brainstorming to openspec-apply-change, whose Ensure plan writes planning artifacts. Use only when OpenSpec work is selected; explicitly requested direct edits without a Change do not enter this route.

## Preconditions

1. Resolve the exact source: openspec/drafts/<domain>/<topic>/designs/<scope>/, or the explicitly selected legacy flat draft per the [draft contract](../brainstorming/references/drafts.md). Never select by timestamp or newest directory. The selected README has status: designed, or the same handoff is being resumed after target creation. A topic still exploring or currently in research mode is not a blocker; a sibling's approval is not authority.
2. The selected design is accepted, its relevant glossary names are settled, and handoff.md contains OpenSpec Handoff and a confirmed Exploration Carryover (each source, target, reason). Approval references identify the exact scope and rounds. Missing user-owned choices remain open; do not invent them or repeat settled approval.
3. The Change ID follows <domain>/<type>-<scope>-<outcome> per the [record schema](../openspec/references/record-schema.md) and is confirmed in the selected glossary/handoff. Parked or abandoned work is not ready for creation. A material accepted-design revision before export requires the affected approval to be revisited.

## Steps

1. Inspect whether the exact named Change already exists. If it does, read tasks.md and attachments/INDEX.md first and verify the source identity and existing seeded material. Resume missing export/index/status steps only; do not create another Change, overwrite accepted planning, or replay already materialized talks/knowledge. A complete export with a stale local designed state needs only that state/navigation repaired before Ensure plan. An unrelated identity/content conflict must be resolved, never overwritten.
2. If absent, import Harness once and run openspec.change create <id> --title <title> --json in the selected workspace. Never hand-create `change.yaml`. Keep one handoff tied to this target identity, including if later steps are interrupted.
3. Export only the selected design.md, handoff.md and applicable glossary.md into attachments/drafts/. Copy English source text; faithfully translate other languages into English, preserving identifiers, accepted scope and rationale. Mark translated sources with plain-text source identity and approval provenance; keep originals local. If no names apply, seed an explicit not-applicable glossary. Topic-shared terms needed by the design must be included in this selected glossary, not all sibling names.
4. Export cited findings needed by the design, handoff, confirmed talks or knowledge beneath attachments/drafts/findings/, following required local references transitively so the output is self-contained. Preserve nested relative identity to avoid basename collisions. English explanatory text and diagram labels are required throughout the Change; do not carry a non-English original as an attachment exception. Rewrite links into the Change copies; no Change file may depend on an openspec/drafts/ path. A textual provenance identifier is allowed. Do not invent decisions when translation is ambiguous.
5. Materialize exactly the confirmed Exploration Carryover:
   - Talk candidates become attachments/talks/talk-YYYYMMDD-HHmmss-<theme>.md with Context, Evidence, Options, Settled Decision, Consequences and Flip Condition, useful Visual, and Sources. Use English explanations and identify original discussion rounds as textual provenance.
   - Knowledge candidates become attachments/knowledges/<theme>.md with Reusable Insight, Evidence, Boundaries, Application and Sources, disposition candidate per the [knowledge contract](../openspec/references/knowledge.md).
   - Unconfirmed items, sibling research and the full log.md stay local. Do not regenerate an existing confirmed item merely because the session resumed.
6. Write attachments/INDEX.md per the [attachment contract](../openspec/references/attachments.md): source scope and current position, hard conclusions, forbidden items, and every attachment indexed once with its reading reason. Check English output, preserved meaning and local link closure.
7. Run strict change validation and the Harness attachment audit. Once seeded material is complete, set only the selected design README to status: handed-off with handed_off and target_change; update topic navigation while preserving its current activity and unfinished siblings. For a legacy root, label its handoff scope explicitly. Exported local originals remain in the draft.
8. Invoke openspec-apply-change, whose Ensure plan consumes the same attachments/drafts/handoff.md, design.md and glossary.md destination paths and writes planning artifacts.

## Boundaries

- One selected design, one handoff, one Change. A second Change in the topic requires its own scoped design and confirmed handoff; never overwrite the first design as a way to authorize the second.
- Do not write proposal, specs, design, or tasks here; those are Change planning artifacts owned by Ensure plan. Source design content is not rewritten during export; only scoped state and topic navigation are updated.
- A Change created without a draft for a clear fix or mechanical documentation skips this Skill; Ensure plan states the skipped-gate assumption and does not fabricate attachments/drafts/. An explicit no-Change request creates no Change at all.
- Unattended continuation may consume an already accepted handoff but never invents names, confirms carryover or opens brainstorming. Report a missing prerequisite through the existing continuation route.
