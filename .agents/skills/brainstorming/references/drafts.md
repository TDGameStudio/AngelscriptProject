# Draft Directory Contract

- Load when opening, resuming, recording or handing off a topic. Drafts are ignored local working records, with no Task state, Ready state or Task DAG.

```text
openspec/drafts/<domain>/<topic>/    // One continuing topic can yield several independent Changes.
├─ README.md                        // Current focus, continuation and design navigation.
├─ log.md                           // Append-only original conversation and round outcomes.
├─ findings/                        // Evidence and research, only as needed.
├─ glossary.md                      // Shared vocabulary, when needed.
└─ designs/<scope>/                 // One independently deliverable outcome.
   ├─ README.md                     // Scope, status and approval sources.
   ├─ design.md                     // Candidate, then accepted design.
   └─ handoff.md                    // Only when an OpenSpec handoff is selected.
```

## Topic README

```yaml
---
draft: <domain>/<topic>
mode: research | proposal | design
status: exploring | parked | abandoned
opened: YYYY-MM-DD
---
```

- **此刻**：current activity.
- **焦点**：one relative local Markdown link to the current finding, log or design.
- **已决**：latest settled decision and source round, or `无`.
- **下一问**：next open decision, or `无`.
- **讲清于**：`[R<n>](log.md#r<n>) · YYYY-MM-DD`, or `未讲`.

- Refresh these five fields on resume, correction, focus change and handoff; update the owning design's current decisions at the same time. Preserve superseded conclusions and their sources in the log.
- Mode describes current activity; it neither approves nor revokes a scoped design. Topic status remains exploring while research continues. Park only when intentionally paused, with a resumption condition; abandon with a reason.
- `harness.draft.status` checks these fields, links and round existence. It cannot prove approval meaning or conversation completeness.

## Scoped design README

```yaml
---
design: <scope>
status: exploring | designed | handed-off | parked | abandoned
opened: YYYY-MM-DD
approval_round: R8                # actual scoped approval, required before handoff
target_change: <domain>/<change>  # once the Change exists
handed_off: YYYY-MM-DD            # after export and seed verification
---
```

- State scope/exclusions, link design and research, retain naming/carryover approval sources, and give the next step.
- `exploring` includes candidates and partial approval; `designed` means the selected design and required handoff choices are settled; `handed-off` means its exact Change is created, exported and seed-verified.
- A sibling's state and the topic's current focus do not authorize or block this selected scope. Revisit only decisions affected by a substantive revision.
- Direct implementation records authorization, outcome and verification in continuation/evidence. Do not invent a Change identity or mark direct work handed-off.

## Recording checkpoints

- Preserve every visible user message, assistant commentary/final, displayed diagram, submitted question payload and returned answer verbatim, with original source and order. Summaries and corrections supplement originals; never replace them.
- Codex: bind the exact workspace/session/source/draft and first task message line. Do not bind injected setup instructions or a child agent's private conversation. The recorder recognizes Codex 0.154.x JSONL and reports unsupported formats explicitly.

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot $PWD
Invoke-Harness harness.draft.record -Context $context -Parameters @{
    Action = 'bind'; DraftId = '<domain>/<topic>'; SessionId = '<exact-session-id>'
    Source = '<absolute-transcript.jsonl>'; StartLine = <first-task-message-line>
}
Invoke-Harness harness.draft.record -Context $context -Parameters @{ Action = 'status'; SessionId = '<exact-session-id>' }
```

- `sync` reconciles the bound source; `status` reads the last coverage, binding and `last_hook` checkpoint without writing. `unbind` flushes and closes it. Switching drafts uses `bind` with the same source and a later, nonoverlapping start line; it closes the previous range first.
- State is local to `Saved/Harness/draft-record/` in the selected workspace. An unbound hook does nothing; it never selects the newest draft. Replaying a source event is idempotent; identical words at different source positions remain separate occurrences.
- Optional Codex hooks call this recorder at `SessionStart` startup/resume/compact, `UserPromptSubmit` and `Stop`. Tool calls and interruptions do not sync; the next boundary reconciles their delivered originals. New or changed definitions require native `/hooks` trust; configuration alone is not evidence of activation. See [Codex hooks](https://learn.chatgpt.com/docs/hooks).
- On resume and before handoff, inspect the recorded range and any gaps. A partial line, changed/missing source, unsupported format or interrupted write requires retry/reconciliation; a successful hook run only covers the source bytes actually available then.
- Existing logs are append-only. The recorder appends canonical source occurrences even when similar legacy text exists; `legacy_overlap` identifies unresolved historical matching, not a reason to discard a message.
- Without a working hook, sync or reconcile original messages on entry and before questions/final. The current unsent final stays pending until a later source sync; never prewrite it as delivered. For other hosts or unavailable originals, record the exact available boundary and missing range manually, without inventing quotations.

## Language and export

- New README, findings, design, handoff, glossary and diagram prose follows the user's conversation language. Preserve historical wording; log originals are never translated.
- The [handoff](deep-exploration.md) lists exact Source / Target / Reason rows. Export selected design, handoff, applicable glossary, necessary findings and confirmed talks/knowledge in English with source/approval provenance.
- Rewrite links into Change-local copies, retain local originals and index each attachment once. No Change file may depend on an `openspec/drafts/` filesystem link. Never export the full conversation or unselected sibling material.
- Run `harness.draft.check` for the exact selected scope. Its approval field and round checks establish structural evidence; the author still checks actual user acceptance and translation meaning.

## Legacy records and archive

- Preserve flat legacy design/handoff/glossary paths and their target mapping as historical provenance. Do not bulk-migrate old topics, logs or schema 1 Change origins.
- For a new handoff from legacy material, prepare only the explicitly selected `designs/<scope>/` with the actual approved content, explicit approval field and carryover table. Retain originals and already-given approval; do not ask again merely for the new fields.
- Resume a parked topic in place. Archive a completed or abandoned topic only through explicit `harness.draft.archive`; completion requires no next question and no exploring/parked design.
- Explicit completed archive also accepts a preserved flat `handed-off` record with dated handoff, original log/design/handoff files and one exact existing target Change. Keep that legacy layout; no conversion to scoped designs is required.
- Archived drafts remain ignored under `openspec/archive/drafts/<domain>/<date>-<topic>/`. Preserve them as historical inputs; renewed discussion opens a linked topic.
