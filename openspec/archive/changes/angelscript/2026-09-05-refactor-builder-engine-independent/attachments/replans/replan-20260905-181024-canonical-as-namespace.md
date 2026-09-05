---
replan_id: replan-20260905-181024-canonical-as-namespace
status: applied
source: user
source_ref: user request to replan refactor-builder-engine-independent after accepting canonical AS names without the nested frontend namespace
scope: canonical C++ declaration and consumer cutover after obsolete implementation isolation
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: e8fa76a3e2541976f0b6ad07a59853cbe663e8bd2318f4030b823c52c764dd38
result_tasks_sha256: 0062a1bb971eb91605bb9e664d3ec1561f0eb807b9476427651c1a2277c3d07f
created_at: 2026-09-05T18:10:24.3690689+08:00
resume_task: "4.2"
---

## Trigger and Evidence

The user explicitly selected a replan after inspection showed that the final reconstructed API still uses frontend qualification. Existing durable reflection-dependencies/spec.md:11,33 requires the lowercase namespace; declarations/spec.md:9–15 calls it final and names qualified Parser/Decl types; ast/core/spec.md:38 owns nodes through frontend::asCASTContext. Original 6.1 removes competing ASTs but never requires namespace consolidation. Thus the new accepted naming outcome is absent from the plan and conflicts with explicit current contracts.

Actual root and frontend declarations coexist for Parser, Tokenizer, SourceManager and ASTContext. as_builder.h:191–205 and as_metadata_image.h:98–105 expose the qualified source/compilation/key/context types; Core descriptor/artifact and NativeEngine consumers use them too. These are source/API facts, not a newly run UE failure. The outer namespace macros in Core/angelscript.h:55–63 already select AngelScript or global scope.

## Decision

Remove the nested frontend C++ surface after the old compiled/transitive include conflicts leave. Preserve BEGIN_AS_NAMESPACE, END_AS_NAMESPACE, AS_NAMESPACE_QUALIFIER and AS_USE_NAMESPACE. Keep source/frontend organization and as_frontend_* filenames unless an actual include conflict is established. Do not add Frontend/V2 replacements, compatibility aliases, or a new configuration switch.

Add one independently acceptable task 6.2 for real declaration/consumer consolidation, structural RED/GREEN, canonical compile/link proof and the affected NativeEngine regression selection. Keep old source isolation in 6.1. Script namespaces, semantic identity inputs, key bytes, wire versions, ownership and dormant execution gates remain unchanged.

## Impact

Proposal and design now state the final naming scope and C++ binary-rebuild boundary. AST, declarations and reflection deltas explicitly replace all three durable namespace promises and clarify single AST authority; existing codec/identity/grammar clauses remain intact. Add the canonical C++ naming requirement with include, cross-consumer and semantic-preservation scenarios.

When preserving complete Scenario Cards, retain the already completed Parser-only-Sema constructor boundary rather than copying the obsolete Preprocessor-taking signature. Explicitly rename the old preprocessor-facade Requirement to the compilation facade and preserve its concrete result, branch, diagnostics and failure scenarios. This matches the already accepted directive-only preprocessing design, not an additional semantic pass.

Current durable specs and their knowledge files remain unchanged until verified 7.2 synchronization. That task explicitly owns updating the two current namespace-qualified knowledge examples. Historical archives, applied replans, diagrams and raw reports are not renamed.

## Old Task Disposition

All 17 existing IDs and their checkbox states are preserved. The eight completed nodes remain complete with the same historical evidence. Pending 6.1 is preserved with its duplicate-name handoff made explicit; 7.1 is preserved with the new prerequisite. New 6.2 is pending. Existing 4.2–4.5, 4.1 and 5.2 retain their semantic scopes and prerequisites.

Total becomes 18, complete 8, pending 10. Resume remains 4.2. Final naming is deliberately not injected into the currently Ready access implementation.

## Diff Snapshot

- Affected git status before edits: " m Plugins/Angelscript"; "?? openspec/changes/angelscript/refactor-builder-engine-independent/".
- Affected tracked diff stat: Plugins/Angelscript | 0; one dirty gitlink path, zero insertions/deletions. The active record directory is untracked; no source or submodule commit is changed here.
- Task +6.2; task ~6.1 handoff; task ~7.1 predecessor; task ~7.2 explicit namespace/facade sync; no removed/reused node.
- Edge -7.1<-6.1; edges +6.2<-6.1 and +7.1<-6.2. All other edges are unchanged.
- Artifact ~proposal/design/tasks; ~three existing delta specs; ~coverage/INDEX; +this immutable record and indexed planning validation evidence.
- Candidate graph derives from the portable TaskPlan, not a second YAML parser. Before writes, checks establish matching body/graph IDs, no missing/self/cyclic dependencies, preserved completion and sole Ready 4.2. Exact before/result task hashes are above.

## Preserved Work

No plugin or test source, generated artifact, build setting, Skill, Harness executor, current spec or historical record is edited by this replan. Existing user changes and unverified access/conversion WIP remain intact. The previous 481/481 report proves its original v6 snapshot only. Both indexed AS material issues remain open.

## References and Result

Read tasks 6.1/6.2/7.1, the canonical C++ design section and the three delta specs for implementation. data/namespace-replan-validation-20260905.md records actual planning checks and proof limits. This turn performs strict record and scoped owner verification only; no UE operation, implementation, commit or archive is authorized. Resume 4.2 on the next implementation request.
