# Shared Source and Builder Entry Handoff

Source identity: angelscript/virtual-source-filesystem, selected design builder-source-entry. Approved on 2026-09-13. This English export contains the curated handoff, not the discussion transcript.

## Problem and success criteria

The existing snapshot input pipeline copies source bodies and requires callers to assemble compiler services. Later Builder output collapses rich per-file descriptions into a first-file-named batch. Replace that boundary with prepared shared Source input, stable per-module declaration publication, ordered callbacks, and explicit terminal result lifetimes.

Success means one UTF-8 body per Source; preserved host fields; no SDK file loading; immutable published versions; exact source-coordinate retention; no late descriptor degradation; once-only final notification; and safe result transfer after execution returns.

## Evidence

[Storage evidence](findings/builder-source-storage-evidence.md) and [lifecycle evidence](findings/builder-source-lifecycle-evidence.md) are local code observations, not runtime verification.

## Scope, constraints, and decisions

The authoritative accepted contracts are [design.md](design.md) and [glossary.md](glossary.md). Include common Source, Builder entry, required internal coordinates/diagnostic association, stable declaration descriptions, callbacks, result lifetimes, minimal host compatibility, and replacement tests.

Exclude VFS, streaming tokens, full diagnostic tooling, LSP build restoration, UClass publication, hot-reload transactions, other Change edits, and dormant-path activation.

One FAngelscriptSource retains host fields and one FUtf8String body. The host prepares mutable data and stops mutating after shared-const submission; no enforced Freeze protocol is added. Callbacks use direct typed arguments without a context object.

## Rationale and reassessment conditions

UTF-8 views fit the existing character stream. Retaining host fields bounds compatibility work. Stable declaration keys already connect declarations with later definitions. Reassess separately only for a future requirement for VFS/streaming, enforced freezing, bidirectional semantic feedback, or per-module product ownership.

## Flow and failure boundaries

Host preparation leads to shared-const input, staged compilation, one declaration publication, terminal notification, then result transfer after execution returns. Unprepared input, invalid identity/options, or failed hooks stop compilation; prepared empty input text remains valid. Non-located failures carry Error. Failed builds are not publishable replacements. Pauses do not notify completion; abandoned builds are cleaned up by the host.

## Verification

Use replacement NativeEngine CQTest groups with concrete input/output and lifetime oracles. Build changed C++ through Harness before precise test selections. All product tasks begin unchecked. Creation validates records, attachment indexing, and the plan; it runs no UE build or test.

## OpenSpec Handoff

- Change: angelscript/refactor-builder-source-entry.
- Title: Shared Source and Builder Compilation Entry.
- Capabilities: angelscript/language/frontend/builder and angelscript/language/frontend/source-diagnostics.
- Artifacts: proposal.md, design.md, both capability deltas, tasks.md, and indexed curated supporting material.
- Task boundaries: common Source/host compatibility; shared coordinates; Builder input/stage entry; opt-in debug observations; stable read-only declarations; callback lifecycle; terminal transfer; affected-spec synchronization.
- Authority: create and plan only. No C++ implementation, UE execution, specification synchronization, archive, or Git operations.
- Known baseline: the two existing target specs fail current clause-detail indentation rules. Future synchronization includes formatting-only repairs there, preserving all unrelated behavior.

## Exploration Carryover

The user approved exactly two concise rationale notes and one reusable knowledge candidate, with decision-process noise excluded.

| Curated source | Destination | Purpose |
|---|---|---|
| Accepted source contract and storage evidence | talks/source-host-boundary note | Explain retained host fields, single body, and SDK/host boundary. |
| Accepted declaration/callback contract and lifecycle evidence | talks/descriptor-callback-lifecycle note | Explain one-time publication, stable association, final notification, and transfer. |
| Storage evidence | knowledges/utf8-source-storage-and-views.md | Reusable encoding, move, and view boundaries; candidate only. |

Export the selected design, this handoff, glossary, and the two cited findings in English. Full logs, question rounds, misunderstandings, withdrawn candidates, and independent streaming research remain local. Formal records have no links into ignored drafts.
