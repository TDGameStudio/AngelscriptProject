## Draft records and ownership

- Load when opening, resuming or handing off a topic. Drafts are local ignored working records, with no Task state, Ready state or Task DAG.
- New topics start with README and CONTEXT only. Add research, attachments and scoped designs when they have real content; do not create empty directory scaffolding.

```text
openspec/drafts/<domain>/<topic>/   // One continuing topic may support several selected outcomes.
├─ README.md                       // Identity and a small navigation entry.
├─ CONTEXT.md                      // Current intent, key decisions, open points and continuation.
├─ research/                       // Optional evidence, explanations and naming comparisons.
├─ attachments/                    // Optional source materials, images or other supporting artifacts.
└─ designs/<scope>/                // One independently deliverable outcome.
   ├─ design.md                    // Scope metadata, candidate/current design and vocabulary.
   └─ handoff.md                   // Prepared only after the user requests convergence.
```

## Topic identity and context

- New README frontmatter uses the following identity. Keep narrative navigation small; current decision truth belongs in CONTEXT.

```yaml
---
schema: harness-draft-v2
draft: <domain>/<topic>
mode: research | proposal | design
status: exploring | parked | abandoned
opened: YYYY-MM-DD
---
```

- CONTEXT explains the current objective and focus, settled key decisions and reasons, unresolved choices, necessary assumptions, evidence/source references and next step.
- Refresh it on resume, correction, focus change and meaningful decisions. Retain consequential rejected/superseded choices and why they changed, without reproducing every conversation turn.
- Preserve actual answer provenance. Distinguish user-confirmed decisions, recommendations and provisional assumptions; never label an inference as a user answer.
- Link the selected design and useful research instead of duplicating their full content. A lightweight heading/bullet structure is enough; no exact chat format or full-transcript coverage is required.
- Mode describes the topic's activity. It neither grants handoff approval nor revokes another scope's accepted design.
- A parked topic stays resumable in place. Its context states what would allow continuation.

## Scoped design

- Store scope metadata in `designs/<scope>/design.md`, not a mandatory sibling README. Keep vocabulary/naming decisions in this design rather than requiring a separate glossary.

```yaml
---
design: <scope>
status: exploring | designed | handed-off | parked | abandoned
opened: YYYY-MM-DD
---
```

- Explain problem/outcome, scope and exclusions, evidence, architecture, roles, data/call flow, lifecycle, chosen approach and alternatives, failures/constraints, relevant proof and unresolved choices.
- Add a Vocabulary and Naming section when public names or terms matter. Include selected names, responsibilities, useful rejected alternatives and the source/reason.
- A candidate stays `exploring` until its actual design is settled. `designed` does not itself authorize creation or Replan.
- Prepare handoff only after user-driven convergence. Record target Change and handoff outcome after the corresponding operation; do not claim `handed-off` before creation/application and required verification succeed.
- A sibling scope's approval does not approve this scope. An unrelated open sibling does not invalidate a scoped decision, but remains relevant to topic archival.

## Research and attachments

- Put investigation and reusable explanation in `research/<subject>.md`. More naming candidates go to `research/naming-<subject>.md`.
- Use `attachments/` for actual supporting material such as an input diagram, captured example or source artifact. Link files from context/design; add an INDEX when an attachment collection needs navigation.
- Do not duplicate each chat explanation into research. Preserve material when it is needed for continuing work or evidence.
- Keep relative local links valid and explain each material's relevance. New records follow the user's conversation language and retain precise identifiers.

## Handoff and export

- Read [scoped handoff](deep-exploration.md) only after the user requests convergence.
- `harness.draft.check` validates the exact selected scope and returns `HandoffRevision`. The creation/Replan preview is read-only; structural readiness is not the user's Gate answer.
- Carry only the selected design, prepared handoff and needed evidence/decision summaries into Change-local English attachments. A separate glossary is optional when vocabulary is already in design.
- Rewrite exported links to self-contained Change-local files, retain local originals and index each exported attachment once.
- Do not make a Change depend on an ignored draft filesystem path. Do not export the full conversation or unrelated sibling research.
- After handoff, record the actual target and outcome in this draft. The explicit follow-up decides whether to retain/archive the draft and when execution is scheduled.

## Recording checkpoints

- New drafts use key-decision context, not mandatory verbatim recording. No transcript bind/sync, hook, duplicated response or source-coverage check is required before asking, handing off or sending final.
- Optional existing recorders remain available through [recording.md](recording.md). The repository does not register Codex project hooks; an unbound session never guesses a draft.
- If recording was explicitly selected, preserve its originals and honestly report coverage. Do not make optional recorder gaps block an otherwise valid new-layout handoff.

## Existing layouts and archive

- Read legacy `log.md`, `findings/`, flat design/handoff/glossary and scoped README layouts in place. Preserve existing content, identities, target mapping and approved sources.
- Do not migrate old topics, rewrite transcripts, rename findings or create new-layout duplicates merely on resume or archive.
- Existing meaningful approval evidence remains readable; the current operation still needs the exact handoff choice required by its Gate.
- Archive only after an explicit user disposition through `harness.draft.archive` with its actual `SourceRef`. Move the topic to ignored `openspec/archive/drafts/` without deleting unresolved work or claiming completion.
- Archive metadata records when and why/source; semantic topic/design status remains intact. Retaining the draft permits continued discussion without requiring another topic.
- Treat archived records as history. A later exploration may reference that history in an active topic without silently modifying the archive.
