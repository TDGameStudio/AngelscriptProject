# Evolution Closure Validation Design

## 1. Separate active policy from historical audit

Ordinary exact status remains available for active and archived Changes. `RequireTerminal` is valid only for an active Change because it decides whether current mutable evidence may close. Archived history is immutable and is audited by the portable CLI. New strict fields are never retrofitted into old archives.

## 2. Let OpenSpec own Task DAG parsing

Harness invokes the packaged OpenSpec `instructions apply --json` path for the exact active Change and consumes its TaskPlan. Harness does not parse `task_graph` YAML. A completed closure requires at least one task and every returned task complete. Abandoned and superseded closures still require a valid TaskPlan but allow incomplete nodes because their final dispositions belong to the closure manifest and portable archive validator.

## 3. Bind evaluation to current inputs

`workflow-evaluation.md` adds:

```yaml
closure_kind: completed | abandoned | superseded
input_sha256: <lowercase SHA-256>
```

The digest uses ordinally sorted, workspace-relative forward-slash paths and raw file bytes for every ordinary file under the active Change except `attachments/data/workflow-evaluation.md`. Each path and content payload is length-framed before hashing, preventing concatenation ambiguity. `harness.evolution.status` always reports `CurrentInputSha256`, allowing the evaluation to be written last without a second implementation-specific tool.

The evaluation capture time cannot precede the latest terminal issue or Review timestamp. A content change after evaluation changes the digest and blocks closure even if filesystem timestamps are misleading.

## 4. Validate current evidence strictly

Active `attachments/implementation/**/issue-*.md` records must be v2, indexed exactly once, refer only to Task IDs in the current TaskPlan, use ordered lifecycle timestamps, and retain the required non-empty issue sections. A superseded issue points to one active, indexed, non-superseded v2 owner whose `source_ref` reciprocally names the source issue.

Active `attachments/reviews/**/review-*.md` records must be `review-v2`, indexed exactly once, use valid lifecycle fields and timestamp order, and be closed or superseded before terminal closure. A closed Review requires an approving verdict. Structured Critical or Required findings cannot remain open or deferred.

## 5. Keep verification proportional

`HarnessEvolution.Tests.ps1` constructs a temporary Change and calls the real exported Harness route with a bounded manual context. It uses the real packaged OpenSpec executable only for TaskPlan interpretation; no Git worktree, UE process, network, or unrelated leaf module is involved. Closure work runs this focused test and Protocol/OpenSpec checks only. The existing broad Quick profile remains available for broader integration Changes but is not a per-edit default.
