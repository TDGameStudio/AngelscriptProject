---
replan_id: replan-20260905-204839-review-required-followups
status: applied
source: user
source_ref: user request to replan from reviews/review-20260905-194335-builder-coordinator.md and specialist metadata/ast/semantics reports (seven Required findings)
scope: review-required admission, conversion projection and Sema qualifier follow-ups before canonical-name cutover
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: cecbb72e39bad1b99009ef2b9a951d19a1e7e7d3afe112b128bd584f15d47153
result_tasks_sha256: e58011e76d6b95dc378788d63d3a0d96e7e26bd4578d99c3be484d676ed93e83
created_at: 2026-09-05T20:48:39.9546884+08:00
resume_task: "8.1"
---

## Trigger and Evidence

The user directed a replan from the four open `review-v2` records. Coordinator verdict is CHANGES_REQUIRED with seven Required findings (M1/M2, AST-01/02, SEM-1/2/3). Live source still matches those traces: `ValidateFrozenLayout` compares offsets not `Property->type`; ordinary `ValidateFrozenIdentity` ignores `objectType`; `IsExpressionRecord` ends at `ValueInitExpr` and omits `UserConversionExpr`; `ConversionFunction` is absent from function-role classification; `ResolveCall` treats equal scores as ambiguous; `ActOnConditional` stores bare types; foreach `StatementCanInitialize` ignores const while the verifier demands equal qualifiers.

These are omitted consumer checks on completed 3.2/4.1/4.3/5.1 contracts, not a new architecture. Completed nodes cannot be unchecked. 6.2's namespace cutover cannot absorb them without hiding unresolved semantics. Archive is blocked while Required findings stay open.

6.1 isolation was already proven by Editor builds `539de9eacd1846ad9ec1a98b0e8b6016` and `ccd0686340f140ada5be30f936dbef20` plus an ACTIVE_FORBIDDEN=0 scan; that evidence is recorded here rather than left as an unchecked Ready node.

## Decision

Add three follow-up feature groups after 6.1 and before 6.2:

- 8.1 authenticates frozen field datatypes and kind-specific exposed `objectType`.
- 8.2 includes every maintained expression kind in projection and authenticates decoded ConversionFunction keys.
- 8.3 applies mutable-receiver const preference, conditional handle qualifiers, and foreach handle-const agreement.

Keep durable spec text unchanged. Preserve 6.2 as mechanical naming only. 7.1/7.2 still follow 6.2; 7.2 must close the four Reviews after 8.1–8.3 evidence. 8.1/8.2/8.3 Files are disjoint enough for parallel writers and share NativeEngine.

## Impact

Proposal/design now state that review-required holes close before the canonical-name cutover. No capability delta is added. Task DAG grows by three pending nodes. 6.2 gains 8.1–8.3 predecessors. Resume is any Ready 8.x node; 8.1 is the named resume.

## Old Task Disposition

- 1.1–5.2 preserved complete. 3.2, 4.1, 4.3 and 5.1 gain `needs_followup` to 8.1/8.3/8.2/8.1.
- 6.1 preserved and completed with the isolation builds above.
- 6.2 preserved pending; predecessors now 6.1+8.1+8.2+8.3.
- 7.1/7.2 preserved pending; 7.2 explicitly closes Reviews.
- New 8.1, 8.2, 8.3 pending.

## Diff Snapshot

- Affected git status before edits: ` m Plugins/Angelscript`; `?? openspec/changes/angelscript/refactor-builder-engine-independent/`.
- Affected tracked diff stat: plugin gitlink dirty; Change directory untracked. No parent commit.
- Task +8.1 +8.2 +8.3; task ~6.1 complete; task ~6.2 predecessors; task ~3.2/~4.1/~4.3/~5.1 needs_followup; task ~7.1/~7.2 review closure; no removed/reused ID.
- Edges +8.1<-6.1, +8.2<-6.1, +8.3<-6.1; edge ~6.2<-6.1 becomes 6.2<-6.1,8.1,8.2,8.3. 7.1<-6.2 unchanged.
- Artifact ~proposal/design/tasks/INDEX; +this record. Review files unchanged (still open).

## Preserved Work

No plugin or test source is edited by this replan. 6.1 isolation source remains. Historical NativeEngine reports stay valid for their original snapshots. Open conversion-target and stale OpenSpec-engine-context issues are unchanged. Reviews are not closed here.

## References and Result

Read tasks 8.1/8.2/8.3 and the four Review files for resolution conditions. Resume 8.1; 8.2 and 8.3 are also Ready. No UE operation in this planning-only replan.
