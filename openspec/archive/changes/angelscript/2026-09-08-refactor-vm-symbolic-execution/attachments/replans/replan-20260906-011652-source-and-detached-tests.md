---
replan_id: replan-20260906-011652-source-and-detached-tests
status: applied
source: user
source_ref: "2026-09-06 user approval: replan to add execution tests and resolve failures; followed by manual AS object type/function testing without Engine"
scope: "canonical source execution acceptance and real detached metadata testing"
base_commit: d8343d314f0b948a43a323fc443cf305ff2f5dc3
base_tasks_sha256: ad0aeed192f28bb3998241676ae2cf338f058bdbddeb9b5fbb01de9a659ddee4
result_tasks_sha256: 9113a64eaaab9e7ac892e25fc12a78d55610a84fdc48b2c0ee035816f46b6ce0
created_at: 2026-09-06T01:16:52+08:00
resume_task: "1.1"
---

## Trigger and Evidence

The user accepted source-language execution coverage in addition to complete direct-bytecode VM tests, then asked to manually create and directly test AS types/functions without an Engine. The previous proposal/design/tasks explicitly excluded source compilation and any source compiler, so their scope and completion proof became invalid.

The current canonical Builder reaches verified AST/frozen definitions but does not produce executable code. MetadataImageTests already creates real detached types/functions; that existing ability is not a reason to add fake classes or bypass runtime services. Evidence and source anchors are in the indexed source-execution matrix and settled source/detached test talk.

## Decision

Use one bytecode image/verifier/linker/interpreter with two producers: direct authoring and the current canonical AST emitter. Add a real authenticated detached-definition fixture and direct metadata lifetime/signature tests. Preserve the selected minimal SDK Engine for actual execution; an Engine-less production runtime is a separate architecture decision, not assumed from manually constructing metadata.

## Impact

Proposal, bytecode/testing deltas, design and Task DAG now require bounded basic AS source execution and source-produced cache proof. Constructor source-ordinal projection/codec/verifier preservation and emitter cleanup state are explicit 5.4 prerequisites, not hidden future work. No current durable specs, CLI manifests or product code are changed.

## Old Task Disposition

All original IDs 1.1-4.2 are preserved and unchecked; no completed work is reopened. 1.1-4.1 retain their complete accepted behavior. 2.1 now consumes the shared detached fixture; 4.2 additionally closes metadata/source coverage. Existing metadata/AST checks are regression controls, not fabricated new RED or execution proof.

## Diff Snapshot

Captured affected status before applying this Replan (all 16 existing Change files were untracked):

```text
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/INDEX.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/fingerprint-contract.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/opcode-inventory.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/planning-validation.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/data/runtime-dependency-inventory.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/knowledges/identity-compatibility-runtime-lifetime.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/talks/talk-20260906-002459-definition-free-cache.md
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

git diff --stat for this exact Change was empty because its files were untracked; this is not a claim that their text was unchanged.

- Task +: 1.3; 5.1, 5.2, 5.3, 5.4, 5.5.
- Task -: none. Task ~: 2.1 fixture handoff, 4.2 source/metadata completion; execution contract distinguishes source from direct fixtures.
- Edge - (task -> prerequisite): 2.1 -> 1.1; 4.2 -> 4.1.
- Edge +: 1.3 -> 1.1; 2.1 -> 1.3; 5.1 -> 3.1; 5.2 -> 5.1; 5.3 -> 5.2, 3.2; 5.4 -> 5.3, 3.6; 5.5 -> 5.4, 4.1; 4.2 -> 5.5.
- Artifact ~: proposal.md, design.md, tasks.md, bytecode/testing delta specs and attachments/INDEX.md.
- Artifact +: source/detached decision talk, source-execution matrix, this applied record and update-only planning validation evidence.

## Preserved Work

Complete maintained opcode coverage, SchemaHash/LayoutHash, canonical witnesses, explicit native layout, transactional linking, definition-free cache load, single-Engine image ownership, replacement CQTest and dormant legacy/UE startup remain required. No product implementation or earlier test result is claimed by planning validation. Unrelated workspace files, submodules and Git staging are untouched.

## References and Result

The candidate DAG and Scenario Cards were checked before current-truth writes; 19 unique pending nodes preserve all 13 original IDs and form an acyclic graph. Derived initial Ready remains 1.1. The actual saved tasks SHA-256 equals result_tasks_sha256.

Strict Change/TaskPlan and scoped OpenSpec authoring checks are recorded separately in data/source-execution-replan-validation.md. tasks.md remains sole execution truth. No UE build or Automation execution occurs in this planning-only Replan.
