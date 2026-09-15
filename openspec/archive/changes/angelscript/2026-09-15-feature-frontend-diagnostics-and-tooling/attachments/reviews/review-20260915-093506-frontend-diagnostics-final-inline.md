---
review_schema: review-v2
review_kind: final
requested_by: user
state: closed
assigned_at: 2026-09-15T09:35:06.240398+08:00
reviewed_at: 2026-09-15T09:38:15.137492+08:00
closed_at: 2026-09-15T11:02:43.603910+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260915-110219-frontend-diagnostics-repaired
snapshot_sha256: a615a6132c4c78fb82ee7b7dc7ad918d2fdfa11d8451cf545b8d71c940876a0d
verdict: APPROVE
---

## Assignment and verification story

User-requested Final Review of Change `angelscript/feature-frontend-diagnostics-and-tooling` after apply reported 16/16 GREEN. Coordinator froze 204 files (Change records, `frontend/**`, Builder/CompileOutput headers, Diagnostics/Tooling/ParallelLex tests, and the proving Automation reports) into the snapshot above. Manifest SHA-256 is `4660e3c23cd4f40dd898c77439289f89118e7c0dc1b5eea25cc4dfb7889cd16c`. Plugin HEAD at assignment was `2a8c1dc40e8204e6f1f64584aac63ea6643f41a9` with dirty frontend/Builder/test bytes; no file under the reviewed trees was newer than NativeEngine run `a8f886db1ab04088aa3a6cf730a32b36` (mtime cutoff 2026-09-15 00:12:43). Unrelated parent dirty Documents/Guides and other Changes are excluded.

Paths below are inside that copy. `R` is `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript`. `T` is `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine`. `C` is the Change directory.

Tests were read first, then the owning runtime. No product code, tasks, INDEX, or earlier Reviews were edited during this pass. Broad UE gates were not re-launched; the supplied reports were authenticated from `AutomationReport/index.json`. `openspec.validate --strict` and `openspec.doctor` both Succeeded on the live workspace that matches this snapshot's product bytes.

### Supplied execution evidence (authenticated)

| Selection | Run | Report facts |
|---|---|---|
| `Angelscript.UnitTest.NativeEngine` | `a8f886db1ab04088aa3a6cf730a32b36` | succeeded=1150 failed=0 notRun=0 inProcess=0 succeededWithWarnings=0; created 2026.09.14-16.12.40 |
| `Angelscript.UnitTest.NativeEngine.DiagnosticsToolingIntegration` | `06adc1ebf2b84578b2a36aa167ee97e6` | 3/3 Success |
| `Angelscript.UnitTest.Baseline` | `71959936e39644d5bd4662e2013f653c` | succeeded=2 succeededWithWarnings=1 failed=0; three cases all `Success` (`RuntimeDormantByDefault`, `OptionalIntegrationsDormantByDefault`, `LegacySuiteExcludedByDefault`) |

The Baseline `succeededWithWarnings` count is the UE report envelope (retained MetaSound-class warnings), not a failed case. Feature-group classes present in the 1150-run include DiagnosticProduction, ParallelLexPreprocess (5), DiagnosticsCore/Presentation/Position/Edit/Syntax/Semantic/Builder, CallAssessment (2), LanguageService (3), ToolingAnalysis (3), ToolingCursor (2), ToolingCompletion (2), ToolingNavigation (2), DiagnosticsToolingIntegration (3).

Intentionally omitted Quick/Performance/Integration/Standalone/VM-JIT remain consistent with the Change's acceptance text. This Review does not claim those gates.

```
asCBuilder / asCCompilationSession
  ├─ Lex/PP workers [X,K]          // 1.2 joined products; local lexical gate
  ├─ asCDiagnosticFragment.Diag    // 1.1 move-only stream; explicit Submit
  ├─ catalog + asSDiagnosticGroup  // 2.1–2.4 render / codec / atomic edits
  └─ Sema / AssessCall             // 3.x causes + non-mutating candidates
        │
        ├─ asCLanguageService.AttachCompilation   // 5.1 format / ApplyFix only
        └─ asCToolingSession
              ├─ Analyze → FreezeForTooling       // 4.1 owned result; not valid-seal
              ├─ PrepareCursor (scratch parse)    // 4.4 request-local; formal AST untouched
              ├─ Complete / GetSignatureHelp      // 4.2
              └─ GetHover / FindDefinition        // 4.3 token-to-binding
```

## Findings

### Finding F01 — ToolingCompletion does not implement or discover the card's third case

severity: Required
status: resolved
**Locations:** `C/tasks.md` 4.2 Cases 1–3; `T/Tooling/ToolingCompletionTests.cpp` (only `ScopeAndMemberCompletion`, `RealSignatureContext`); `R/frontend/Sema/as_tooling_completion.cpp`:115–245; `R/frontend/Sema/as_tooling_types.h`:73–78.

**Original observation:** Task 4.2 names three cases. Sister diagnostic cards materialize the “Additional accepted boundaries” case as a discovered `TEST_METHOD`. ToolingCompletion discovers 2/2 and the GREEN evidence cites only those two. The third case’s oracles are not present: expected-type ranking that does not hide unknown-type candidates; namespace/type/keyword grammar contexts; `Pick(Second: 4, First: 3)` authored-to-formal 1 then 0 compared with ordinary compilation; cursor leaving Inner selecting Outer; list-initializer context; frozen-host candidates and unsupported-default isolation; Lambda/`function` rejection as a behavioral oracle (the filter exists, the test does not); formal AST/diagnostics unchanged after signature queries. `asSSignatureHelpResult` only stores `Status`, `ActiveParameter`, and assumed `CallName`, so it cannot carry ordered signatures, viability, or formal maps that 3.3 already computes.

**Reproduction/evidence:** `T/Tooling/ToolingCompletionTests.cpp` has no third method. `GetSignatureHelp` uses `AssessCall` Incomplete only to pick `ActiveParameter` (`R/frontend/Sema/as_tooling_completion.cpp`:233–244) and discards candidate lists. `CallAssessment.CompleteAndIncompleteMapping` already proves the named-argument map that 4.2 said to reuse; ToolingCompletion never asserts that parity on a cursor request. NativeEngine 1150/1150 cannot invent the missing case.

**Impact:** The Change’s apply checkbox for 4.2 overstates completion against its own card. Hosts cannot observe completed-call / compilation agreement or host-candidate rejection through the public signature-help value.

**Resolution condition:** Add a discovered `ToolingCompletion` case (or expand the two existing methods) that executes every oracle listed under 4.2 case 3 with independent expected payloads. Surface enough of `asSCallAssessment` on `asSSignatureHelpResult` to assert authored-to-formal maps, viability, and Inner-versus-Outer after the cursor leaves the inner call. Keep formal diagnostics/body projection unchanged after those queries. Re-run the card prefix and a mapped NativeEngine selection on a new binary.

**Re-review (repaired snapshot `review-20260915-110219-frontend-diagnostics-repaired`):** Resolved by 7.3/7.5. Snapshot `as_tooling_types.h` owns `asSSignatureCandidate` / `Signatures`. `GetSignatureHelp` copies AssessCall viability, maps and slots. Discovered methods `ObservableOverloadAndNamedArgumentPayload` and `NestedHostAndNonmutationBoundaries` plus grammar/scope cases ran Success on NativeEngine `58e6f563f214438bbf7ace83d26d4aeb` (1164/1164). Original apply snapshot `review-20260915-093506-frontend-diagnostics-final` remains historical.

### Finding F02 — Inaccessible members are only filtered as `Private`

severity: Required
status: resolved
**Locations:** `R/frontend/Sema/as_tooling_completion.cpp`:152–160; `R/frontend/AST/as_ast_fwd.h`:33; `C/tasks.md` 4.2 case 1 (“exclude inaccessible receiver members”) and case 3 (“private/incompatible receiver members”).

**Original observation:** Member completion skips `asEAccessSpecifier::Private` and otherwise adds every named record decl. `Protected` exists on the enum and is inaccessible from a free function such as `void F(){ Item obj; obj.| }`. The tests only hide `private int Hidden`.

**Reproduction/evidence:** Read the loop at `as_tooling_completion.cpp`:152–160. `ScopeAndMemberCompletion` asserts `Hidden` absent and `Value` present; no protected member fixture exists in the 2/2 GREEN report `3d92470c754b47af8de674e36a2773b3`.

**Impact:** `Complete` can offer members the language would reject at that cursor. That is a broken accessibility contract, not a style issue.

**Resolution condition:** Treat non-accessible members (at least `Protected` from a non-member/non-derived receiver context, plus any incompatible members the card names) as absent. Add a real `protected` field fixture to `ToolingCompletion` and re-prove the prefix.

**Re-review:** Resolved by 7.4. Snapshot completion uses `CanAccessMember` and `SetAccessCaller`; `ProtectedMemberFromFreeFunction` and `LegalClassAccessAndCompatibleReceiver` Success on the 1164-run.

### Finding F03 — Navigation snapshot matching ignores source bytes when `Identity` is zero

severity: Required
status: resolved
**Locations:** `R/frontend/Sema/as_tooling_navigation.cpp`:14–39; `R/frontend/Sema/as_tooling_types.h`:42–48; `T/Tooling/NativeToolingTestSupport.h`:10–31; `C/tasks.md` 4.3 case 3 (“Changed input/environment identity … return their specific statuses”).

**Original observation:** `SameAnalysisInputs` compares `Identity` only when both sides are non-zero, then owned-set pointer equality and `FAngelscriptSource::GetPath()`. `MakeInputs` never assigns `Identity` and does not hash bytes. Two sessions that share logical paths and have empty host sets compare equal even when the UTF-8 contents differ. `GetHover` / `FindDefinition` then return `Success` instead of `SnapshotMismatch`. The only mismatch fixture is Bare session versus Hosted result (owned-set count).

**Reproduction/evidence:** `SameAnalysisInputs` at `as_tooling_navigation.cpp`:16–39. `HostLocationAbsence` (`T/Tooling/ToolingNavigationTests.cpp`:180–185) only differs by `OwnedDefinitionSets`. No test pairs two `Value.as` buffers with different text.

**Impact:** A caller can attach a foreign analysis result that happens to use the same paths and receive `Success` hover/definition from that foreign graph. Status is part of the accepted query contract. The displayed binding still comes from the passed `Result`, so this is not a use-after-free; it is a missing identity check.

**Resolution condition:** Compare the session’s inputs to the result’s inputs by content revision (or a stamped `Identity` that Analyze always sets from the owned snapshot/options/host bundle), not path-only when `Identity` is 0. Add a same-path different-bytes `SnapshotMismatch` case and re-prove `ToolingNavigation`.

**Re-review:** Resolved by 7.1. Snapshot `SameAnalysisInputs` compares StableScope, TypeContext, owned-set pointers, path and `GetSourceText()`. `RejectSamePathForeignResults` and `RetainedProvenanceAndExactTargets` Success on the 1164-run.

### Finding F04 — Several cards closed without a third discovered boundary method or observed RED

severity: Advisory
status: resolved
**Locations:** `C/tasks.md` 3.1 Evidence (no pre-implementation RED); 4.1 case 4; 4.3 case 3; 4.4 (no third method); 2.1/2.2/2.4/3.4/5.1/6.1 Evidence blocks that start at GREEN.

**Original observation:** 3.2, 2.2, and 5.1 land `Accepted*Boundaries` methods. 4.1/4.3/4.4 fold some extra oracles into the RED methods and omit others (4.1 mid-analysis cancel and invalid EOF position; 4.3 member/qualified/overload/comment probes). 3.1 records that implementation and tests landed together.

**Reproduction/evidence:** Compare `T/Diagnostics/DiagnosticSemanticTests.cpp` `AcceptedSemanticBoundaries` with the Tooling classes. 3.1 Evidence in `C/tasks.md` states there is no separate pre-implementation RED.

**Impact:** Process/provenance only. The existing GREEN oracles that were written still match their reports. Does not by itself falsify 1150/1150.

**Resolution condition:** Either add the missing discovered boundary methods and historical-honest RED notes, or record in the cards that those extra oracles are deferred to a named follow-up. Do not relabel later tests as historical RED.

**Re-review:** Resolved by 8.1 disposition plus 7.x discovered methods. `implementation-verification.md` records that 4.1/4.2/4.3/4.4 third-method gaps and 3.1/2.x/5.1/6.1 GREEN-only cards are not historical RED. 7.1–7.7 each have observed RED/GREEN. Not deferred.

### Finding F05 — `Complete` / `GetSignatureHelp` swallow non-cancel cursor failures

severity: Advisory
status: resolved
**Locations:** `R/frontend/Sema/as_tooling_completion.cpp`:136–145 and :196–202; `R/frontend/Sema/as_cursor_context.cpp`:146–160.

**Original observation:** `PrepareCursor` returns `InvalidPosition` when the offset is not inside a deferred body and `AnalysisUnavailable` when declarations did not resolve. Both query methods only special-case `Cancelled`, then force `Success` (possibly empty). File-scope / EOF completion therefore cannot be distinguished from “in a comment”.

**Reproduction/evidence:** Control flow as cited. No ToolingCompletion case places the cursor outside a function body.

**Impact:** Clients cannot tell invalid positions from successful empty sets. Design lists `InvalidPosition` as a first-class status.

**Resolution condition:** Propagate `PrepareCursor` status unless the card explicitly treats that site as successful-empty. Add file-scope and unknown-file cases.

**Re-review:** Resolved by 7.2. Snapshot Complete/GetSignatureHelp copy non-Success cursor status. `InvalidUnavailableAndEmptyAreDistinct` and `CancellationAfterWorkStarts` Success on the 1164-run.

### Finding F06 — `FreezeForTooling` is a mutation flag, not an ownership audit

severity: Advisory
status: resolved
**Locations:** `R/frontend/AST/as_ast_context.cpp`:226–235 and :77, :113; `C/design.md` “Native query facade and ownership”.

**Original observation:** `FreezeForTooling` refuses only an already sealed context, sets `bFrozenForTooling`, and makes later `Create` return null. It does not walk edges, ranges, or retained definition leases. `Analyze` treats freeze failure as `AnalysisUnavailable`, but freeze does not fail a recovery-containing or pointer-unsafe graph. `PartialReadFreeze` correctly shows freeze ≠ `IsSealed` and that `VerifyAST` still fails.

**Reproduction/evidence:** `FreezeForTooling` body is the four-line flag set. Design text requires a safe-ownership check before a traversable result.

**Impact:** An unsafe graph can still be published as `Partial`/`Success` if Builder produced it. Current tests never construct an unsafe-but-built graph, so this is unproven rather than demonstrated corruption.

**Resolution condition:** Either implement the ownership/range audit the design names and return `AnalysisUnavailable` on failure, or record that freeze is mutation-lock-only and that Builder admission is the safety gate. Keep freeze distinct from `VerifyAndSeal`.

**Re-review:** Resolved by 7.6. Snapshot `FreezeForTooling` walks node ownership, ordered ranges, children, cross-references and type references before setting the freeze flag; still distinct from `VerifyAndSeal`. `ForeignRangeOrReadableEdge` and `TransitiveLeasesAndPartialFreezeControl` Success on the 1164-run.

### Finding F07 — Completion rebuilds declarations twice per request

severity: Advisory
status: resolved
**Locations:** `R/frontend/Sema/as_tooling_completion.cpp`:129–136; `R/frontend/Sema/as_cursor_context.cpp`:121–124.

**Original observation:** `Complete` and `GetSignatureHelp` each construct a declaration Builder, then `PrepareCursor` constructs another through `DeclarationsResolved` and prefix-parses the body. Design already rejected incremental caches; the extra identical wave is still avoidable inside one request.

**Reproduction/evidence:** Two `MakeUnique<asCBuilder>` / `RunThrough(DeclarationsResolved)` sequences on one `Complete` call.

**Impact:** CPU cost only; no correctness failure in the 1150-run. Matches the accepted “independent cursor parse” cost model except for the duplicated first wave.

**Resolution condition:** Share one declaration Builder between the non-code probe, cursor parse, and member lookup for a single request. No new public API required.

**Re-review:** Resolved by 7.7. Snapshot Complete/GetSignatureHelp pass the request Builder into `PrepareCursor`; `RunStage(DeclarationsResolved)` is counted once. `OneActualDeclarationPreparation` Success on the 1164-run.

## Verified sound

- **1.1 / 1.2 / 2.x / 3.1 / 3.2 / 3.4 / 5.1 / 6.1 executed oracles.** DiagnosticProduction, ParallelLexPreprocess (queue identity, local PP gate, hard-failure drain, exactly-once Preprocessed, X/K bounds), catalog/policy/presentation/codec/edits, syntax and semantic producer IDs (including Cout→Count typo + unique fix and notes-only Count/Court), Builder/CompileOutput retention, language-service attach-after-Builder-death, exact Clang-style format string in `LanguageService.AcceptedLanguageServiceBoundaries`, compile-fix-reanalysis pointer-identity `OwnsFix`, X/K early-phase A/B/C retention, Baseline dormancy. Reports match the cards.
- **3.3 AssessCall.** Complete named reorder 1 then 0; Incomplete unknown-future slots; duplicate named rejection; host candidate-local failure without mutating node count (`CallAssessment` 2/2 inside the 1150-run).
- **4.1 Analyze / freeze / handles.** Host definition sets survive caller `Reset`; raw `Options.Dependencies` without ownership is `InvalidInput`; `Missing`/`G` is `Partial`, `FreezeForTooling` true, `IsSealed` false, late `Create` null, `VerifyAST` false; handles include AST `ContextID`; pre-cancelled Analyze is `Cancelled` with no result.
- **4.4 PrepareCursor.** Scratch prefix parse sees `Inner`/`Outer`; formal diagnostics, body projection, statement count, and source bytes stay identical; `Item` receiver works in both file orders; cancelled cursor is empty and does not drop the formal `F` lookup.
- **4.2 implemented slice.** `obj.|` offers `Value` not `Hidden`; nested scope hides `Later`; `obj.Va|` keeps a non-empty replacement span; `Pick(|)` / `Pick(1, |)` / `Pick(Second: |)` / `Outer(Inner(1, |)` match the recorded CallName and ActiveParameter; comments yield successful empty completion. Parser `NoteIncompleteMember` on every `Dot` and `NoteIncompleteCall` on failed arguments are what make the incomplete-body oracles work; formal NativeEngine consumers stayed green on the same binary.
- **4.3 implemented slice.** Return-use hover is `int Value` not the function; semicolon is empty Success; identifier-end affinity on `Value ;`; host `Host::Add` is hover + `NoSourceTarget`; `Shared()` in B.as defines in A.as; Bare vs Hosted is `SnapshotMismatch`; formal body projection unchanged after hover/cancel.
- **Architecture boundaries.** Language service does not wrap Complete/Hover; query stubs stay `Unavailable`. No Engine creation in these tests. `ApplyFix` is in-memory only. Legacy suite remains gated by Baseline.
- **Record validation.** Task DAG 16/16 complete, 0 ready. Strict Change validate and doctor Succeeded.

## Verdict

**APPROVE** after 8.2 re-review of the repaired snapshot `review-20260915-110219-frontend-diagnostics-repaired` (manifest `a615a6132c4c78fb82ee7b7dc7ad918d2fdfa11d8451cf545b8d71c940876a0d`). Original apply-snapshot observations are unchanged. F01–F07 resolution conditions hold on the repaired bytes and NativeEngine `58e6f563f214438bbf7ace83d26d4aeb` (1164/1164). No Critical or Required finding remains open. Coordinator closed this report; archive/commit/push were not performed.
