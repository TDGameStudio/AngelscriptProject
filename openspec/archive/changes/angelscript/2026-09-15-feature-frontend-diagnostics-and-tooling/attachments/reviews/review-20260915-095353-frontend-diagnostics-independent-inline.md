---
review_schema: review-v2
review_kind: final
requested_by: user
state: closed
assigned_at: 2026-09-15T09:53:53.308089+08:00
reviewed_at: 2026-09-15T09:55:21.798239+08:00
closed_at: 2026-09-15T11:02:43.603910+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260915-110219-frontend-diagnostics-repaired
snapshot_sha256: a615a6132c4c78fb82ee7b7dc7ad918d2fdfa11d8451cf545b8d71c940876a0d
verdict: APPROVE
---

# Independent Final Review

## Assignment and evidence boundary

The user requested review of the apparently completed diagnostic-engine implementation. This independent pass reuses the existing materialized snapshot after authenticating all 204 manifest entries (zero missing or mismatched files). The digest above identifies MANIFEST.sha256. The timestamp records explicit binding of this report to the authenticated artifact after initial inspection. Source and planning inspection began earlier in this turn. Live comparison found only subsequent attachment-index bookkeeping different from the snapshot; implementation content is unchanged.

Scope: the successor Change's tasks and delta requirements, frontend diagnostic production, parallel Builder Lex/PP and identifier interning, analysis ownership/query surface, cursor preparation, completion, signature assessment and navigation, and their supplied tests. Excluded: dormant legacy runtime, unrelated dirty paths, other Changes, Documents/Guides, editor protocol integration, and files not materialized in the snapshot. References below are snapshot-relative, and their implementation content also matches the live checkout at review time.

The earlier review `review-20260915-093506-frontend-diagnostics-final-inline.md` remains historical open input. This report independently confirms three of its correctness observations and adds cursor scope and query-status findings; it does not close, supersede, or claim to resolve that report's other findings.

Existing authenticated AutomationReport/index.json records show NativeEngine run `a8f886db1ab04088aa3a6cf730a32b36`: 1150 succeeded, zero failed; Integration `06adc1ebf2b84578b2a36aa167ee97e6`: 3 succeeded, zero failed; Baseline `71959936e39644d5bd4662e2013f653c`: 2 succeeded, 1 succeededWithWarnings, zero failed. These are supplied execution evidence, not newly executed tests. No new UE build or suite was run: source inspection establishes the findings, and repeating the existing suite would not add the absent boundary cases. Example inputs below are static reproduction recipes, not claimed runtime reproductions.

All findings are implementation findings. `Critical` follows this repository's definition of wrong behavior or a broken contract; it does not imply that each issue is a crash or memory-safety vulnerability. P1/P2 below describe practical repair priority.

## Finding F01 — Reject foreign analysis even when optional identity is zero

severity: Critical
status: resolved
priority: P1

Location: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_navigation.cpp:14` (SameAnalysisInputs, especially lines 16 and 34); `frontend/Sema/as_tooling_types.h:47` relative to the same angelscript directory.

Observation: Identity is compared only when both values are nonzero. Otherwise the comparison checks host-owner pointers and source path strings, but not source bytes/revisions or compilation configuration. Identity defaults to zero, and analysis does not assign a mandatory identity to these inputs.

Impact/evidence: construct two valid sessions with the same logical path and default Identity=0, empty host sets, and different text at that path. Pass session A's analysis result to session B's GetHover or FindDefinition. QueryPrelude's input check accepts the foreign result, allowing an answer from A's retained revision under B's request. An incompatible options change is also invisible to this comparison. This violates explicit snapshot-bound queries and revision-safe positions. This confirms prior F03.

Resolution condition: bind results and sessions to validated immutable source revisions plus the semantic environment, or enforce a unique owned input identity rather than an optional caller hint. Tests must reject same-path/different-content and same-content/different-configuration results with default identity, while accepting a result belonging to its own session.

**Re-review (repaired snapshot `review-20260915-110219-frontend-diagnostics-repaired`):** Resolved by 7.1. Snapshot `SameAnalysisInputs` compares scope, TypeContext, owned sets, path and source bytes. `RejectSamePathForeignResults` Success on NativeEngine `58e6f563f214438bbf7ace83d26d4aeb`. Original apply snapshot remains historical.

## Finding F02 — Signature help cannot return its required semantic payload

severity: Critical
status: resolved
priority: P1

Location: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_types.h:73`; `frontend/Sema/as_tooling_completion.cpp:216` relative to the same angelscript directory.

Observation: asSSignatureHelpResult contains only Status, ActiveParameter and CallName. GetSignatureHelp collects script candidates and argument names, calls AssessCall, uses a selected formal index in one branch, then discards the assessment. It returns no candidate signatures, viability/rejection information, or authored-to-formal mapping; no host candidate population appears in this path.

Impact/evidence: the accepted tooling requirement “Signature help preserves call and parameter context” explicitly requires relevant signatures and argument-to-formal mapping. A consumer cannot display even two overload signatures using this API. This is not merely an untested edge case: the return type cannot represent the promised result. Existing RealSignatureContext assertions inspect only call name and active parameter. This confirms prior F01.

Resolution condition: expose and populate owned signature/candidate and parameter-mapping data through the result, preserving incomplete-call uncertainty and authoritative assessment. Verify overloads, named/default/incomplete arguments and explicit host candidates against the actual returned payload, including absence of formal-analysis mutation.

**Re-review:** Resolved by 7.5. Snapshot `asSSignatureHelpResult` carries `Signatures` with viability, rejection, maps and slots. `ObservableOverloadAndNamedArgumentPayload` and `NestedHostAndNonmutationBoundaries` Success on the 1164-run.

## Finding F03 — Completion exposes inaccessible protected members

severity: Critical
status: resolved
priority: P2

Location: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp:155`.

Observation: member completion iterates record declarations and filters only Private. It does not evaluate access from the current lexical/receiver context. Protected declarations therefore pass the filter from an unrelated free function.

Reproduction recipe: declare a class with a protected field and a public field, instantiate it in a free function, and request completion after `obj.`. Both fields pass this collection path, although the protected field is inaccessible there. The accepted accessible-member requirement forbids this. Conversely, the blanket private exclusion cannot implement context-dependent private access. This confirms prior F02; the protected case is sufficient to establish the defect.

Resolution condition: collect members through authoritative context-aware accessibility and receiver rules. Add unrelated/free-function protected exclusion and legal class-context access cases; compare offered applicability with ordinary semantic lookup.

**Re-review:** Resolved by 7.4. Snapshot member completion uses `CanAccessMember` plus caller/receiver facts. `ProtectedMemberFromFreeFunction` and `LegalClassAccessAndCompatibleReceiver` Success on the 1164-run.

## Finding F04 — Cursor visibility includes locals from scopes already exited

severity: Critical
status: resolved
priority: P2

Location: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.cpp:227`; consumer `frontend/Sema/as_tooling_completion.cpp:166` relative to the same angelscript directory.

Observation: after parsing the prefix body, PrepareCursor walks every declaration statement in the resulting body and appends its variable name to VisibleNames. It does not retain/filter by the active lexical scope at the cursor. Complete forwards that list into candidates.

Reproduction recipe: `void F() { { int Expired = 1; } /*cursor*/ }`, querying at the comment's start (or remove the marker and retain its byte offset). The prefix AST still contains the completed inner block and its declaration, so the visitor collects Expired after its scope ended. The existing nested-scope test checks a cursor inside the inner scope; it does not prove visibility after exiting it. The tooling contract explicitly excludes declarations from unrelated scopes.

Resolution condition: obtain visible declarations from cursor-position scope context, with proper shadowing, rather than flattening the prefix AST. Verify exited blocks, sibling blocks, loop-local lifetime and nested shadowing; assert both exclusions and surviving visible names.

**Re-review:** Resolved by 7.3. Snapshot cursor collects live-scope locals (exited blocks absent, nearest shadow wins). `ToolingCursor.ExitedScopesAndNearestShadow` and `ToolingCompletion.ExitedScopesAndNearestShadow` Success on the 1164-run.

## Finding F05 — Completion and signature help turn invalid positions into success

severity: Critical
status: resolved
priority: P2

Location: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp:136` and `:196`; originating statuses in `frontend/Sema/as_cursor_context.cpp:131` through `:159` relative to the same angelscript directory.

Observation: both query wrappers propagate only Cancelled from PrepareCursor, then assign Success. PrepareCursor explicitly returns InvalidPosition for an unknown logical file/no enclosing function or invalid prefix, and AnalysisUnavailable when the required session/phase is unavailable. These statuses are discarded. MakeDeclarationBuilder also ignores RunThrough's outcome.

Reproduction recipe: with valid session inputs, call Complete or GetSignatureHelp with a nonempty nonexistent logical source key. Initial input validation passes, PrepareCursor returns InvalidPosition, and the wrapper returns Success with an empty payload. An out-of-range byte position follows the same error-erasure path. This violates the requirement to distinguish successful empty responses from invalid positions and unavailable analysis.

Resolution condition: validate the position and preserve meaningful cursor/analysis status in the query response. Test unknown file, out-of-range offset and unavailable declaration context, separately from valid empty/non-code queries and cancellation. Handle valid non-function contexts intentionally rather than treating all failures as empty success.

**Re-review:** Resolved by 7.2. Snapshot Complete/GetSignatureHelp propagate cursor status. File-scope EOF stays Success; missing key, past-end, mid-codepoint, and declaration-stage failure are distinct. `InvalidUnavailableAndEmptyAreDistinct` Success on the 1164-run.

## Verified sound and review limits

- The inspected parallel Lex/PP path uses bounded workers, a locked batch queue, per-worker result storage, and a join before deterministic logical-key ordering. Lexical acquisition/failure observations are file-local; the tests exercise worker/batch combinations, order variation and hard-failure injection.
- Identifier interning serializes allocation and same-spelling lookup under its lock; allocated entry ownership preserves stable entry addresses. This inspection does not constitute a stress/sanitizer proof.
- Diagnostic and tooling tests and the integrated reports establish the exercised basic paths. Completion/signature tests do not establish the richer accepted contracts identified above. Passing counts alone cannot support their task-completion claims.
- No new demonstrated corruption in the diagnostic producer or worker merge was identified in this pass. This is a bounded source-inspection statement, not certification of every concurrency, cancellation, ownership-closure or diagnostic-catalog scenario. Earlier report findings outside this pass remain unresolved.

## Verdict

**APPROVE** after 8.2 re-review of the repaired snapshot `review-20260915-110219-frontend-diagnostics-repaired`. Original observations are unchanged. Independent F01–F05 resolution conditions hold on the repaired bytes and NativeEngine `58e6f563f214438bbf7ace83d26d4aeb` (1164/1164). No Critical finding remains open. Coordinator closed this report; archive/commit/push were not performed.
