---
replan_id: replan-20260906-115220-acceptance-gaps
status: applied
source: user
source_ref: "Explicit request to replan missing sub-tasks and record a Review; review-20260906-112533-acceptance-gaps-reviewer.md F01-F10"
scope: "Residual VM/image/cache/source acceptance and evidence ownership"
base_commit: d8343d314f0b948a43a323fc443cf305ff2f5dc3
base_tasks_sha256: b1a7ef17b7e658d914b777978bdf91bba9350f73a73a4901af06d64333791ca8
result_tasks_sha256: 3a477a773f5e81bbfc8ccef9c292d33b971b66e934514405d07c4433dad2e03d
created_at: 2026-09-06T11:52:20+08:00
resume_task: "6.1"
---

## Trigger and Evidence

The user requested finer missing sub-tasks and an audit Review. The immutable 281-file snapshot and user-requested External Review document ten Required/open findings. The original 19 checked tasks coexist with explicitly unproved required Cases, incomplete verifier/publication/cache/lifetime/source contracts and no complete historical source/binary manifest. This invalidates current completion/proof ownership; severity alone does not trigger this Replan.

The snapshot manifest digest is 4a143b0f981b679a625550dd035b4fba71184188c2eec5213c45082499632b5d. Existing product progress and historical 704/704 twice remain valid for their named cases. Source-derived review counterexamples remain explicitly unexecuted.

## Decision

Preserve all completed IDs, checkboxes, required Cases and evidence. Add 23 bounded feature-group follow-ups, each with exact Files/verify, consumed/produced contracts and independent positive/negative/boundary oracles. Keep grouped RED/GREEN and justified shared proving runs; do not implement dependencies early to fill a batch.

Retain all five accepted capability deltas. Complete immutable executable sidecars, canonical contracts, frame/CFG admission, atomic publication, object-domain/runtime leases and typed source lowering without changing the minimal SDK Engine or definition-free cache mode. Evolve incomplete wire version 1 explicitly to 2.

## Impact

Proposal and design distinguish historical implementation from remaining acceptance. tasks.md becomes 42 nodes: 19 historical completed, 23 pending, initial Ready 6.1. The opcode inventory retains every original row/primary assignment and adds exact 9.1/9.2/9.3 proof owners (121/43/49). Review findings stay open; task assignment is not repair evidence.

## Old Task Disposition

1.1-1.3 are preserved with their actual metadata/fingerprint proof. 2.1-5.5, including historical 4.2, retain completion and receive needs_followup; exact per-ID owners are on their cards and in acceptance-gap-matrix.md. 11.3 owns new final acceptance. Original graph edges remain unchanged; no completed task depends on pending work.

## Diff Snapshot

Captured affected status before this review/replan delivery:

```text
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/INDEX.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/fingerprint-contract.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/implementation-verification.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/opcode-inventory.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/planning-validation.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/runtime-dependency-inventory.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/source-execution-matrix.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/source-execution-replan-validation.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/knowledges/identity-compatibility-runtime-lifetime.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/replans/replan-20260906-011652-source-and-detached-tests.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/talks/talk-20260906-002459-definition-free-cache.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/talks/talk-20260906-011138-source-and-detached-tests.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/change.yaml
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/design.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/proposal.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/specs/angelscript/language/types/definitions/spec.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/specs/angelscript/language/types/stable-identity/spec.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/specs/angelscript/runtime/bytecode/spec.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/specs/angelscript/runtime/vm/spec.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/specs/angelscript/testing/baseline/spec.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/tasks.md
```

git diff --stat for this exact Change was empty because these files were untracked, not because their text was unchanged.

- Task +: 6.1, 6.2, 6.3, 6.4, 7.1, 7.2, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 9.1, 9.2, 9.3, 10.1, 10.2, 10.3, 10.4, 10.5, 11.1, 11.2, 11.3.
- Task -: none. Task ~: historical disposition annotations, current execution/evidence contract and final proof ownership.
- Edge -: none. All original incoming edges are preserved.
- Edge + (task -> direct prerequisites):
  - 6.1 -> 1.1, 1.2, 2.1
  - 6.2 -> 6.3
  - 6.3 -> 6.1
  - 6.4 -> 6.3
  - 7.1 -> 6.3
  - 7.2 -> 6.2, 6.4, 7.1
  - 8.1 -> 7.2
  - 8.2 -> 7.2
  - 8.3 -> 7.2
  - 8.4 -> 8.3
  - 8.5 -> 8.3
  - 8.6 -> 8.4, 8.5
  - 9.1 -> 7.2
  - 9.2 -> 7.2
  - 9.3 -> 8.1, 8.2, 8.4, 8.5
  - 10.1 -> 7.2
  - 10.2 -> 10.1, 9.1, 9.2
  - 10.3 -> 10.2, 8.1
  - 10.4 -> 10.3, 8.3
  - 10.5 -> 10.4, 8.5
  - 11.1 -> 8.2, 8.6
  - 11.2 -> 10.5, 11.1
  - 11.3 -> 9.1, 9.2, 9.3, 11.2
- Artifact ~: proposal.md, design.md, tasks.md, attachments/INDEX.md, opcode-inventory.md; Review receives appended coordinator triage only.
- Artifact +: fixed snapshot manifest, External Review, acceptance ownership talk/matrix, this applied record and update-validation evidence.
- Artifact unchanged: five capability deltas, original case/implementation evidence and prior immutable Replan records.

## Preserved Work

No C++, test implementation, compile gate, public Harness API, durable spec or unrelated workspace file is edited. No new UE build/Automation, archive, synchronization, commit or push occurs. Keep dormant legacy/UE startup, original stable identity, complete maintained opcode acceptance and cache mode one.

## References and Result

Candidate graph/body/Files/verify/state and acyclicity were checked before current-truth writes. All 19 original Evidence lines are preserved. The recorded result digest binds the applied tasks content; strict CLI/owner checks and actual saved-file hash verification are recorded in data/acceptance-replan-validation.md. tasks.md remains the sole current task authority. Review state is open, verdict CHANGES_REQUIRED, with no claimed repair.
