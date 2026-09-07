# Language-surface alignment verification

Date: 2026-09-07. User-authorized planning update only. The existing delegate record had ten pending tasks and no authored design or delta specs; this update retains that state and does not claim to finish task 1.1.

## Verified changes

- Proposal removes all Lambda/anonymous-function/capture goals and Lambda-specific binding operations, preserving named/member targets, explicit payloads, native/dynamic adapters and multicast semantics.
- Task 2.2 keeps its ID and binding-lifetime responsibility; the proving prefix changes from Delegates.Closures to Delegates.Payloads. Dedicated Lambda Files ownership is removed.
- Dependent native/cooked examples now invoke named AddOffset with explicit payload 40 and input 2, expecting 42. Bind-time payload lifetime remains executable acceptance rather than parser-only proof.
- Task 1.1 checks structured callable metadata from language-surface task 2.1 before delegate product execution. It remains the owner of unresolved host/Blueprint/cooked design prerequisites.
- Candidate task frontmatter and IDs/check states were identical to the baseline after newline normalization. All ten remain unchecked and local DAG edges are unchanged.

## Commands and evidence

Portable `openspec.validate angelscript/feature-delegates-ue-interop --type change --strict --json` passed before and after the update. Harness `task.status` successfully parsed the resulting ten-node graph. Scoped checks inspect current proposal/tasks for obsolete positive Lambda/closure requirements and verify INDEX links and applied task hashes. Historical inventory and the indexed reverse patch are excluded from current-scope searches because they preserve superseded evidence.

Applied replan: `../replans/replan-20260907-220002-named-callables-no-lambda.md`. Its result task SHA-256 is `454e5cd58de36ddfef2c72095085a20ffd984653a9e291a56ef60e0811c59b3c`. The prior untracked proposal/tasks/INDEX are recoverable through the indexed reverse patch; no raw implementation or binary content was copied.

No implementation, UE build, Automation, standalone/cooked run, review, current-spec sync, archive or Git action was performed. Strict planning validation does not prove callable execution, reflection or payload lifetime.
