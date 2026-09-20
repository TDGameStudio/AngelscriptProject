# INDEX

## Current position

Tasks 1.1 and 2.1 complete. Next Ready nodes: 2.2 (opt-in stage dumps) and 3.1 (read-only per-module declarations). Resolved issue: [implementation/issue-20260913-105100-shared-source-makes-emit-real.md](implementation/issue-20260913-105100-shared-source-makes-emit-real.md). tasks.md remains the execution authority.

## Hard conclusions

- One FAngelscriptSource retains host fields and one FUtf8String body; SDK receives prepared shared references and does not load files.
- One file identifies one module; resolved declarations publish once with deep-read-only access.
- Ordinary callbacks may fail; final notification reaches all valid registrations once; Take waits for terminal execution to return.

## Forbidden

- Do not import the discussion transcript, question rounds, or withdrawn candidate inventory.
- Do not add a public source collection/context, silently copy source bodies, reactivate legacy code, or absorb VFS/streaming/LSP work.

## Attachment index

- drafts/design.md — accepted English design — read for complete contracts.
- drafts/handoff.md — scoped authority and confirmed carryover — read for scope and exclusions.
- drafts/glossary.md — settled public names — read before interface edits.
- drafts/findings/builder-source-storage-evidence.md — inspected host fields and copying boundaries — read for Source migration.
- drafts/findings/builder-source-lifecycle-evidence.md — inspected projection, overwrite, and borrowing — read for Builder output migration.
- talks/talk-20260913-041359-source-host-boundary.md — concise source-boundary rationale — read when evaluating ownership changes.
- talks/talk-20260913-041359-descriptor-callback-lifecycle.md — concise declaration and terminal-lifetime rationale — read when evaluating publication changes.
- knowledges/utf8-source-storage-and-views.md — candidate, not promoted or runtime-verified — read for encoding/view distinctions.
- data/planning-validation.md — plan preflight, actual record checks, and pre-existing spec-format baseline — read before implementation or synchronization.
- implementation/issue-20260913-105100-shared-source-makes-emit-real.md — resolved; shared-source identity made RunThrough emit and Register publish; proving run `14ff26d1e7c347a2b6e660eda966136a` is green.
