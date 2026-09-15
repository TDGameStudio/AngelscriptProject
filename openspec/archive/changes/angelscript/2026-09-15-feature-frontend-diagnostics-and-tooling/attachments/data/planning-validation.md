# Planning validation — 2026-09-14

## Scope and authority

Planning-only creation from the accepted diagnostics-tooling-successor handoff. Q18 confirms the three added knowledge candidates and creation. No product task has executed, no RED/GREEN is claimed, no current capability spec is synchronized and no Git operation is included.

## Authoring preflight

- Coverage: all seven capability deltas and their scenarios map below; every predecessor feature boundary transfers through predecessor-disposition.md. Two new nodes own production and concurrent early phases.
- Placeholder scan: no forbidden task-authoring phrase remains. All sixteen heading-node cards have ordered Outcome/Interfaces/Cases/Files/Verification, a concrete new RED, interface shape, owned file roles and one exact proving command.
- Symbols: Diag/asCDiagnostic/initial streams follow N2/N1d/Q8. LexBatchSize derives from existing PascalCase options under Q15's delegation. DiagnosticProduction and ParallelLexPreprocess follow inspected replacement CQTest identities. Inherited public shapes remain future outputs of their producing tasks, not existing APIs.
- Compatibility: inspected RunStage, tokenizer Flush, preprocessor Process, identifier Intern and source-diagnostic payloads. The hard-Lex-failure loop clarification is recorded in design.md. UnsupportedInclude is 2014; the short include fixture spans [0,15).
- English and links: the exported explanatory material is English, all Markdown attachment links resolve within this Change, and no link depends on ignored drafts. Unicode position fixtures use explicit escape notation.
- Verification scope: creation uses structural/static checks only. Product task proving commands select bounded NativeEngine classes or the shared NativeEngine scope when source/ownership/stage impact crosses components.

## Exact checks and results

Commands run from the selected workspace with the imported Harness context:

| Check | Exact operation | Result |
|---|---|---|
| Workspace/record health | Invoke-Harness -Command openspec.doctor -Context $context -ArgumentList @('--json') | Passed, zero diagnostics |
| Strict successor | Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-frontend-diagnostics-and-tooling','--type','change','--strict','--json') | Passed |
| Task DAG | Invoke-Harness -Command task.status -Context $context -Parameters @{ Change='angelscript/feature-frontend-diagnostics-and-tooling' } | 16 total, 0 complete; ready 1.1 and 2.3 |
| Attachment audit | Exact Test-AttachmentIndexCompatibility from .agents/skills/harness/tests/Protocol.Tests.ps1, with this ChangeRoot | Passed; every attachment appears once and INDEX is below 120 lines |
| Local authoring checks | Temporary Python preflight: card labels/order, case-role grammar, new RED, one command, forbidden phrases, CJK explanatory text, local Markdown links | Passed |
| Historical baseline before predecessor archive | Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--archived','--strict','--json') | 57 existing archives: 11 passed, 46 failed before this closure |

The audit loaded only the two existing Harness attachment-index functions through PowerShell AST extraction, without modifying the protocol or running unrelated full-suite assertions. Temporary script/output files are scratch material under Saved/Harness, not dependencies of this Change. The command identities, summarized results and source hashes here are the durable evidence.

Historical failures are existing retired task-format/graph/closure incompatibilities, not product failures and not introduced by this successor. Preserve immutable archives; post-move verification compares the preexisting failed IDs and issues and separately checks the newly archived predecessor.

Intentionally omitted: Unreal build/Automation, Harness Quick/Performance/Integration and legacy/full suites. This delivery modifies records only; no product binary was built and no runtime result is inferred from static validation.

## Requirement and scenario coverage

Every scenario listed in a row is accepted by the indicated task group; final integration retains the full inventory and per-case coverage obligation.

| Requirement | Tasks | Covered scenarios |
|---|---|---|
| Single reconstructed AST authority | 4.1, 4.4, 6.1 | Consume AST facts at a subsystem boundary |
| Read-only partial AST results preserve ownership and validity boundaries | 4.1, 6.1 | Inspect a retained recovery graph; Reject cross-result handles and late mutation |
| Body diagnostics explain semantic rejection without cascades | 3.2, 3.3, 6.1 | Explain an unsuccessful overload call; Continue past an invalid expression without repeated consequences |
| Builder preserves root diagnostics and explicit stage outcomes | 3.4, 4.1, 6.1 | Propagate a semantic stage failure; Fail before lexing produces tokens; Inspect partial analysis without publishing it; Preserve structured emission failure; Reject an illegal request without poisoning compilation |
| Queued early phases finish independently before deterministic join | 1.2, 2.1, 6.1 | Worker and batch counts vary; One lexical failure does not suppress clean-file PP; Preprocessing fails in one eligible file |
| Early PP is consumed once by public stage advancement | 1.2, 3.4, 6.1 | Run early stages separately or together; Failed early work remains inspectable |
| Declaration failures retain specific semantic explanations | 3.1, 3.2, 6.1 | Resolve an unknown declaration type; Explain declaration conflicts and invalid annotations |
| Tokens and identifiers have compact session-owned representation | 1.2 | Repeated spellings arrive concurrently |
| Lexical failure facts are file-local and independent of presentation | 1.1, 1.2, 2.1 | One tokenizer fails while another is clean |
| Frontend diagnostics are structured before rendering | 1.1, 2.1, 3.1–3.4, 6.1 | A diagnostic is captured without a live Engine; Parallel diagnostics have deterministic order |
| Diagnostic causes and arguments are machine-readable | 2.1, 3.1–3.4, 6.1 | Distinguish semantic failures without parsing messages; Report a failure without a source location |
| Diagnostic policy preserves failure facts | 1.2, 2.1, 3.4, 6.1 | Suppress display without suppressing failure; Promote a warning to a build failure; Limit or terminate diagnostics at a group boundary |
| Diagnostic presentation preserves structured meaning | 2.2, 5.1, 6.1 | Render and export a source diagnostic; Render a suggestion note with a caret |
| Presentation coordinates have explicit encoding | 2.3 | Convert multibyte source positions |
| Fix alternatives are source-safe atomic proposals | 2.4, 3.1, 3.2, 5.1, 6.1 | Apply a safe correction in memory; Reject a stale or conflicting edit set; Keep ambiguous corrections advisory |
| Diagnostic production uses fragment-bound reporting obligations | 1.1, 2.1, 3.1, 3.2 | A temporary diagnostic carries values until submission; The phase explicitly publishes its fragment |
| Owned engine-independent analysis results | 4.1, 6.1 | Result survives release of the caller's compilation inputs; Recoverable source remains inspectable without becoming publishable |
| Explicit snapshot-bound native query surface | 4.1–4.4, 6.1 | Query answers only the supplied compilation environment; Native query capability does not require an editor service |
| In-process language service exposes compile diagnostics and suggestions | 5.1, 6.1 | Format and inspect suggestions after a failed compilation; Diagnostic attachment survives caller release; Disabled features stay unavailable |
| Shared non-mutating semantic candidate assessment | 3.3, 4.2, 4.4 | Query and compilation agree without query side effects; An unfinished call is not rejected as a completed short call |
| Contextual completion through independent cursor parsing | 4.2, 4.4, 6.1 | Member completion works immediately after a member access token; Lexical scope and expected type influence candidates; Incomplete identifiers and EOF retain useful completion context |
| Signature help preserves call and parameter context | 3.3, 4.2, 4.4, 6.1 | Named argument maps to its formal parameter; Nested and unclosed calls select the cursor's call |
| Precise semantic hover and definition targets | 4.1, 4.3, 6.1 | Token identity wins over broad enclosing AST ranges; A resolved call points to its selected overload; Host symbol lacks a source declaration |
| Explicit query status and revision-safe positions | 2.3, 4.1–4.4, 6.1 | Cancellation is distinguishable from a valid empty response; A handle or position is used with a different analysis; Native offsets and editor coordinates remain distinguishable |

Coverage totals: 24 requirements, 54 scenarios, seven delta files, sixteen product tasks.

## Source provenance

These hashes bind the selected current source observations, not future implementation evidence. The carried migration inventory retains its original September 12 hashes and must be refreshed for affected producer rows during apply.

| Inspected source | SHA-256 |
|---|---|
| Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp | d1bbb2a276f544640848c40491584b4fa8282ba08d724bef3fe8c9a0daf7a1ec |
| Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_identifier_table.h | be613d4ca0205abab97c60cea811197b7ebec37e7ad9057ba26244fd4fa92281 |
| Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.h | 8f0928aaa8163eae1e743e2b8aca61e4ad6cbf3d0def30294fc8c9e7d133c730 |
| Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.h | 00b76633c4e2febfe726e8d97a1652f53a7faafa31ce9f0dd2d091ef3f87e5ae |
| Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_preprocessor.h | 6a2b17382bd104d52c7c6e47d5ba96c158f4453de92664d25e8baa406c378b7b |
| Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_builder_stages.h | 9a441c855bb893fe871c312cef9f9e41e4fd43b5282694ce2b8c2a7b65d8409a |

## Historical audit baseline

Failed archive IDs before this closure:

- angelscript/2026-09-04-fix-reflection-payload-projection
- angelscript/2026-09-04-refactor-frontend-bodies-semantic-authority
- angelscript/2026-09-04-refactor-frontend-clang-typed-ast
- angelscript/2026-09-04-refactor-frontend-declarations-semantic-authority
- angelscript/2026-09-04-refactor-frontend-lexer-token-pipeline
- angelscript/2026-09-04-refactor-frontend-preprocessor-directive-record
- angelscript/2026-09-04-refactor-frontend-stable-type-identity
- angelscript/2026-09-04-refactor-legacy-runtime-tests-quarantine
- angelscript/2026-09-04-refactor-preprocessor-reflection-dependency-output
- angelscript/2026-09-05-refactor-builder-engine-independent
- angelscript/2026-09-05-refactor-frontend-source-diagnostics-model
- angelscript/2026-09-05-refactor-native-engine-test-foundation
- angelscript/2026-09-08-refactor-language-surface-ue-focused
- angelscript/2026-09-08-refactor-vm-symbolic-execution
- angelscript/2026-09-09-feature-runtime-binding-record-apply
- angelscript/2026-09-11-feature-types-explicit-ownership
- hardness/2026-09-03-close-evolution-feedback-loop
- hardness/2026-09-03-fix-post-archive-gates
- hardness/2026-09-03-integrate-unreal-development
- hardness/2026-09-03-refactor-skill-system
- hardness/2026-09-03-refactor-unified-workspace-core
- hardness/2026-09-03-refactor-workspace-git-operations
- hardness/2026-09-03-restore-exploration-authoring-contracts
- hardness/2026-09-03-standardize-powershell-7
- hardness/2026-09-04-complete-unreal-runner-cutover
- harness/2026-09-03-enforce-angelscript-main-baseline
- harness/2026-09-03-rename-hardness-to-harness
- harness/2026-09-04-enrich-spec-scenario-cards
- harness/2026-09-04-fix-evolution-closure-validation
- harness/2026-09-04-fix-git-commit-isolation
- harness/2026-09-04-fix-git-copy-scope-false-positive
- harness/2026-09-04-fix-openspec-change-naming
- harness/2026-09-04-fix-project-guidance-consistency
- harness/2026-09-04-fix-route-context-authority
- harness/2026-09-04-fix-scenario-detail-authoring-priority
- harness/2026-09-04-fix-spec-clause-detail-blocks
- harness/2026-09-04-fix-unreal-execution-reliability
- harness/2026-09-04-fix-unreal-run-labels
- harness/2026-09-04-improve-spec-card-detail-blocks
- harness/2026-09-04-refactor-agent-guidance-progressive-routing
- harness/2026-09-05-feature-web-workbench
- harness/2026-09-05-refactor-task-planning-batched-tdd
- harness/2026-09-09-refactor-document-authoring-structured-markdown
- harness/2026-09-11-fix-brainstorming-round-form
- harness/2026-09-11-refactor-code-review-single-skill
- harness/2026-09-11-refactor-explore-brainstorming-drafts

## Final supersession checks

The predecessor terminal evolution gate passed with ClosureKind=superseded and RequireTerminal=true. The project CLI archived it at 2026-09-14T13:33:21Z to openspec/archive/changes/angelscript/2026-09-14-feature-frontend-diagnostics-tooling. Its fourteen tasks remain unchecked and all have successor dispositions. The predecessor INDEX was normalized to exact path entries; the terminal evaluation uses the inline-code entry form recognized by both existing audit implementations. No shared Harness code changed.

Post-move strict archived audit: 58 records, 12 passed, 46 failed. The new predecessor archive is valid with zero issues. Comparing every preexisting failed archive ID and its complete issue list before/after found exact equality. No existing archive was edited. Doctor passes with zero diagnostics. Final task.status reports 16 total, 0 complete, ready 1.1 (production) and 2.3 (position codec). Ready is dependency state, not product-apply authorization.

The final successor strict validation and exact attachment audit were rerun after evidence/index updates. Scratch generators, text fragments and JSON envelopes created for this operation are removed from Saved/Harness after checking; this record retains the commands, outcomes, source hashes and historical failure baseline.

## Review follow-up replan validation (2026-09-15T10:10:08.170653+08:00)

Applied `replan-20260915-100735-tooling-review-followups`. All seven capability deltas remain unchanged. Both Reviews' complete finding sets map to 7.1-7.7, final-content proof to 8.1, and explicit Review closure to 8.2; see the immutable replan mapping. Original sixteen task card contents (excluding appended follow-up disposition) exactly match the review snapshot. No historic RED is manufactured and no old Review is resolved by planning.

Pre-write candidate checks: graph/body equality, unique permanent IDs, existing prerequisites, acyclic edges, bounded task cards with Interfaces/Cases/Files/one proving command, exact existing file paths. Post-write self-review: all relevant acceptance boundaries have owners; forbidden-placeholder scan clean; names use inspected SDK interfaces and existing Tooling/CallAssessment test identities. No new public entry point or stable-key family is assumed.

Actual commands run in the selected workspace through the current PowerShell Harness context:

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-frontend-diagnostics-and-tooling', '--strict', '--json')
Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = 'angelscript/feature-frontend-diagnostics-and-tooling' }
```

Strict validation: Succeeded, one valid Change, zero issues (also passed before the update). Canonical task.status: Succeeded; 25 total, 16 complete, 9 remaining; Ready 7.1, 7.2, 7.3, 7.6, 7.7. Resume 7.1. Shared files and exclusive build/test lanes require sequential execution where applicable. Attachment membership checked exactly once per file (31 attachments); INDEX is below 120 lines. Tasks SHA-256 matches the applied replan: `31d3916984c65372fd85d7f142f98eeec34e23d6810fabd7c89ed341c4709ec5`. Product bytes still match the authenticated review snapshot.

This turn executed no product build/tests, spec synchronization, archive or Git mutation. UE and broader suites are omitted because only planning records changed; each future repair card names its impact-related proving selection. Strict archived audit is not repeated because no archive changed; the previously documented 46 historical failures retain their separate bounded disposition. The two operation-owned candidate files beneath Saved/Harness/ReplanPrepare are removed after validation; durable evidence is this record and the applied replan.
