---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-15T12:21:43.145791+08:00
reviewed_at: 2026-09-15T12:22:54.904712+08:00
closed_at: 2026-09-15T14:07:08.380084+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260915-122143-nativeengine-home-design
snapshot_sha256: f5bf00ba0e046da8d715531817335ed2f3075c015dd38b2dbdfee09d13971883
verdict: APPROVE
---

# NativeEngine home design/handoff review

## Scope and stage

User requested review and an explanation of the post-change structure. This is a fixed-snapshot review of the approved design/handoff before Ensure plan, not a Final implementation review. The Change contains change.yaml and seeded attachments; proposal.md, design.md, specs and tasks.md are not materialized. Canonical openspec.status confirms apply waits for tasks, with zero task nodes. Their absence at this seeded stage is not itself a defect.

Snapshot includes 283 files: Change records, maintained non-Legacy test-module C++/headers/build rules, root AGENTS.md, test-authoring Skill and current baseline specification. All manifest hashes authenticated. Runtime implementation correctness, unrelated Changes, Legacy and build/run artifacts are excluded. There is no implementation/test execution evidence for this Change to certify. No UE build or Automation run was started. File references below refer to this snapshot; live links are convenient references, not a moving review target.

## Finding F01 — Migration verification cannot detect a missing renamed test

severity: Required
status: resolved

Planning finding. Location: attachments/drafts/design.md:119 (phase-1 verification), :125 (old-to-new mapping risk); handoff.md Verification.

Observation: Phase 1 moves/nests all NativeEngine layers but only requires smoke for Basic, Lexer and VM plus the other tenants, then zero retired flat names. Compile, Sema, AST, Diagnostics, Tooling, Definitions, Identity, TypeOwnership and Registration are not covered by those smoke selectors. An old-to-new path list alone is not a discovered public-test identity comparison.

Impact/evidence: if a moved Tooling registration is accidentally dropped or put behind a wrong gate, the build and all listed smoke prefixes can pass, and its old flat name still disappears. The required checks therefore admit a migration that silently loses coverage. This is a verification gap, not an observed loss in already moved code.

Resolution condition: during Ensure plan require a pre/post discovered identity manifest and explicit old-to-new identity mapping for every moved method; assert no missing/unexpected/duplicate registrations and correct layer-prefix membership. Preserve unchanged Framework/RuntimeBindings/Baseline identity sets. Bound any deliberate splits/renames by explicit dispositions. Retain focused smoke, and ensure runtime proof exists for moved/shared-helper consumers whose behavior can change; do not mandate a blind full suite when identity discovery suffices.

Resolution: Ensure plan added 1.1 comparator + map schema; 2.1–2.4 relocate with pre/post identity maps; 2.6 freezes the phase-1 manifest. `Test-MigrationIdentity.ps1` and `Test-Phase1MigrationConservation.ps1` reject missing/duplicate/wrong-layer destinations. Framework/Baseline/Bindings-isolation run green; RuntimeBindings stays Found-list conservation (312/312) because of the pre-existing Array crash. `Naming assumed: BuilderStages`. Evidence: `attachments/data/migration-verification.md`, `migration-identity-map.json`.

Re-review 2026-09-15T14:07:08.380084+08:00 against `Saved/Harness/Reviews/review-20260915-140708-nativeengine-home-rereview`: resolution condition holds. Final NativeEngine run `b99a111c19a2478a9f15027ae270f89f` keeps relocated identities and adds only explicit Parser/matrix cases.

## Finding F02 — Root authoring instructions still mandate the retired source root

severity: Required
status: resolved

Planning finding. Location: attachments/drafts/design.md:81; AGENTS.md:30.

Observation: the mandatory rewrite list names the angelscript-test Skill and baseline spec but omits root AGENTS.md. That file explicitly directs new C++ Automation tests into Plugins/Angelscript/Source/AngelscriptTest/NewVersion/ and documents the old broad public-identity shape.

Impact/evidence: the migration can satisfy the current checklist while its highest-level repository entry instructions still tell future work to recreate NewVersion. Updating only the leaf Skill/spec leaves contradictory current workflow guidance.

Resolution condition: add the applicable AGENTS.md reconstruction-baseline paragraph to phase-1 owned Files and synchronize its physical homes/public identity routing with the approved tenant design. Check current executable/authoring references for old paths and distinguish them from immutable historical archives/Review evidence, which must not be mass-rewritten.

Resolution: Task 2.5 rewrote root `AGENTS.md` reconstruction baseline to module-root homes and `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`. `angelscript-test` Skill/references and `migration-consumer-map.md` record current consumers. Archives and this Review snapshot were not rewritten. Current `openspec/specs/angelscript/testing/baseline/spec.md` synced at 4.1.

Re-review 2026-09-15T14:07:08.380084+08:00: live `AGENTS.md` line 30 forbids `NewVersion` as a source root. Resolution condition holds.

## Finding F03 — Boundary cells lack the expected outcomes needed for coverage acceptance

severity: Required
status: resolved

Planning finding. Location: attachments/drafts/design.md:102-110; handoff.md Success Criteria item 4.

Observation: the matrix names division by zero, signed overflow 'per product', over-wide shifts, 'failed narrowing', and conditional inheritance/global rejection, but does not bind those cells to types, literal/runtime inputs, the expected phase or an exact observable outcome. These choices distinguish normal results, diagnostics and VM failure. Production frontend changes are explicitly out of scope.

Impact/evidence: a task can currently claim coverage merely because it exercised an operation, or bless observed implementation behavior as the expected answer. Unsigned versus signed operands and integer versus floating division need different oracles. A newly failing matrix test also must not silently authorize a frontend feature/fix outside the accepted scope. This is not a claim that the arithmetic implementation is defective.

Resolution condition: before starting each matrix group, map required operator/type/context cells to existing tests or concrete new tests and independently sourced expectations, including compile rejection versus VM failure/result. Record accepted unsupported/retired outcomes explicitly. Where the existing language contract is settled, derive the oracle from it; where it is not settled, surface that decision instead of guessing. A demonstrated product defect needs an explicit owner/disposition under the existing scope/replan policy; passing by weakening the oracle is not completion. The Retired row is rejection-only and is exempt from the generic positive/boundary/rejection wording.

Resolution: Task 1.2 certified the ledger before 3.x. `attachments/data/coverage-oracles.md` maps each required cell to existing-proven identities or named new methods and records compile-reject versus VM-fault versus value. Product already implemented most shapes; 3.x tests are characterization. Comma has no expression operator (for-increment 73, multi-decl 31). Compound assign and in-range shifts analyze but do not emit; oracles stay Sema-ok plus existing IntegralConstants/VM opcode proof, not weakened numeric guesses. Retired stays rejection-only. No production frontend/VM edit.

Re-review 2026-09-15T14:07:08.380084+08:00: ledger plus NativeEngine `b99a111c19a2478a9f15027ae270f89f` satisfy the condition.

## Verified sound

- Four tenant ownership is coherent with the current tree: NativeEngine, Bindings, Framework (+ its self-tests), and Baseline have separate responsibilities. TestCode remains its own corpus, and TestFramework/NativeEngine remains helper-only.
- Compile versus SourceExecution distinguishes build/metadata lifecycle proof from source-to-link-to-VM behavior; VM remains focused low-level execution coverage.
- Basic.Foundation follows CQTest TestDir.Class.Method composition without duplicating a layer token. Existing Lexer nesting is a usable migration control.
- The handoff explicitly catches NewVersion/Framework includes, generated TestCode and the secondary AngelscriptTestJIT provider. Snapshot secondary-provider includes confirm these dependencies are real.
- The design retains replacement/legacy gates and stable Framework/RuntimeBindings/Baseline public prefixes, separates relocation from new matrix work, rejects counting .as files as execution evidence and avoids implementing the independent unified-framework Change.
- Missing formal artifacts reflect the seeded stage. This review does not ask to undo approved directory names, split the approved single Change, or manufacture implementation failures.

## Verdict and next boundary

CHANGES_REQUIRED for execution planning: address the three bounded planning findings in Ensure plan before implementation. The approved directory/taxonomy direction is coherent, but no implemented migration is being approved. Each finding needs a concrete resolution and review disposition; writing tasks alone does not automatically close this report. No implementation, accepted draft, previous Review or task was changed by the reviewer.

## Coordinator closure

2026-09-15T14:07:08.380084+08:00. All Required findings are `resolved`. Re-review used immutable snapshot `Saved/Harness/Reviews/review-20260915-140708-nativeengine-home-rereview` (`MANIFEST.sha256` digest `d207d4ba95bb113f29ca81b345e102304079bfd1256de3cc6e65626dc29a5253`). Final proof: NativeEngine `b99a111c19a2478a9f15027ae270f89f` (1239 Success) and `attachments/data/final-verification.md`. Verdict updated to APPROVE. No archive, commit, push, or workspace action.
