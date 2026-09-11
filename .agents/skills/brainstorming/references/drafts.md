# Draft Directory Contract

Load this reference when opening, updating, handing off, or abandoning a brainstorming draft.

## Location and layout

```text
openspec/drafts/<domain>/<topic>/
├── README.md      # frontmatter: draft, status, opened, handed_off, target_change
├── log.md         # append-only, verbatim: each agent reply and each user message as written
├── findings/      # agent evidence: code inspections, comparisons, spikes, external references
├── glossary.md    # chosen and rejected names with reasons
├── design.md      # the approved design (the artifact the user signs off)
└── handoff.md     # decision-complete handoff with Exploration Carryover
```

`<domain>` matches an OpenSpec domain (`angelscript`, `harness`). `<topic>` is lowercase kebab-case and describes the idea, not a Change type.

## README frontmatter

```yaml
---
draft: <domain>/<topic>
mode: research | proposal | design
status: exploring | designed | handed-off | parked | abandoned
opened: YYYY-MM-DD
handed_off: YYYY-MM-DD        # when status is handed-off
target_change: <domain>/<change>   # once the Change exists
archived_as: openspec/archive/changes/<domain>/<date>-<change>   # optional, after the Change archives
---
```

- `exploring` from the first round; `designed` once the user approved `design.md` and confirmed the carryover list; `handed-off` once `openspec-create-change` created the target Change and seeded its attachments; `parked` when the exploration is worth keeping but no Change is wanted now, with one line on what would revive it; `abandoned` when the user drops the idea, with one sentence why.
- Reviving a `parked` draft reopens `brainstorming` on the same directory: append to `log.md`, set `status: exploring`, keep the earlier findings.
- `mode` is the entry mode from the Skill's "Entry modes" table. Only `design` may reach `designed`; upgrading `research` or `proposal` rewrites `mode` in place, appends a `Mode upgraded` line to `log.md`, and completes the skipped steps.

## Rules

- Open the draft before the first grilling round, or as soon as the reply contains a proposal, a trade-off, or more than one diagram — whichever comes first. Announce `Draft opened: <path> (mode: <mode>)` once. Append to `log.md` as rounds are asked and answered, pasting both the agent's reply and the user's message verbatim — no summaries or paraphrase; never rewrite earlier entries.
- `findings/` holds one file per research topic (`findings/<topic>.md`): the evidence, any ASCII or Mermaid diagram embedded as produced, and a closing "Conclusions / Open" block. Diagrams and comparisons never live only in the chat.
- In `proposal` mode `design.md` starts as the agent's draft and is marked `Status: proposal draft` at the top until the user approves it; the approval line is removed when the mode upgrades to `design`.
- Drafts stay under `openspec/drafts/` permanently on the author's machine; `/openspec/drafts/` is git-ignored, so the Change's `attachments/drafts/`, talks, and knowledge are the only shared copies. They are working records, not OpenSpec artifacts: no checkboxes, Task state, Ready state, or DAG. Harness does not scan them and the portable CLI does not validate them; do not add either.
- `openspec-create-change` creates the target Change, copies `design.md` and `handoff.md` into `changes/<domain>/<change>/attachments/drafts/`, materializes the confirmed carryover into `attachments/talks/` and `attachments/knowledges/`, indexes everything once in `attachments/INDEX.md`, and sets the draft README to `handed-off` with `target_change`. `log.md`, `findings/`, and `glossary.md` remain only in the draft; talks quote from them with provenance.
- Language: `design.md` and `handoff.md` are English like every OpenSpec record. `log.md` and `findings/` may retain the user's original-language wording; this is the declared exception to the English rule.
- One draft per idea. If brainstorming splits a large request into sub-projects, open one draft per sub-project and link them from each README.
- Resuming: read `README.md`, then the tail of `log.md`, then `design.md`; do not reload the whole history unless a decision is being reopened.
