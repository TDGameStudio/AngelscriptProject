---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-05T19:43:35.9446829+08:00
snapshot_ref: Saved/Harness/Reviews/builder-20260905-194219/snapshot.zip
snapshot_sha256: 89babe822b45e852df8b3858d0c27c7253c011c2ef00f8b4e6f1b797d09a32b1
reviewed_at: 2026-09-05T19:55:02.4333729+08:00
closed_at: 2026-09-05T21:04:23.1488285+08:00
verdict: APPROVE
---

# Integrated Builder code review

Assigned by the coordinator for the user's explicit current-code review. Read only the materialized read-only tree at D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree, verified against the hash-bound ZIP. Do not follow subsequent live source changes.

Scope is the current reconstructed NativeEngine implementation and its requirement/test evidence, including completed access/conversion work. Existing pending host-callable, call-context, old-AST and namespace-cutover outcomes are not presumed complete. No UE execution, source/planning edits, automatic replan, Git commit or archive is part of this assignment.

## Outcome and scope

CHANGES_REQUIRED. Seven distinct Required findings remain open in the three canonical specialist reports linked below; there are no Critical findings. This coordinator report records independent cross-checks and the integrated conclusion rather than creating a second copy of each finding's lifecycle.

The review covers the actual staged Builder, reconstructed Parser/Sema, typed AST projection and codec, stable identity, detached metadata and Engine admission. Tests were read before their implementation. The coordinator separately traced `BuilderStageTests.cpp` and `as_builder_frontend.cpp`, and cross-checked every accepted specialist finding against its frozen producer, validator and consumer paths.

The frozen task graph has 10/18 completed nodes, including 4.2 and 4.3. Pending 4.4/4.5 host-callable and call-context products, 4.1 integrated acceptance, 5.2 host integration, 6.1 old-AST removal and 6.2 namespace consolidation are not presumed complete. Their absence is not reported as a defect. This is not a final-completion review and does not certify the pending products.

## Canonical findings and coordinator triage

All seven findings were `Required` / `open` at review time. They are now `resolved` in their owning reports after tasks 8.1–8.3. Their complete original observations, examples, file/line evidence, impacts and resolution conditions remain in those reports.

| ID and canonical report | Independently confirmed consequence | Primary frozen source location |
| --- | --- | --- |
| [M1](review-20260905-194335-builder-metadata.md#finding-m1--required-frozen-field-types-can-change-without-invalidating-their-saved-layout-or-dependency-ownership) | Frozen property datatype is absent from the saved layout/access witnesses and nominal identity validation. Changing the sole field from int to int64 leaves an inconsistent four-byte layout accepted; a foreign type edge also escapes retention validation. | `source/as_metadata_image.cpp:264` |
| [M2](review-20260905-194335-builder-metadata.md#finding-m2--required-ordinary-function-authentication-ignores-the-actual-object-owner-returned-by-metadata-queries) | Ordinary method identity authenticates the private declaration owner but not the actual public objectType returned by GetObjectType. Null/unrelated/foreign owner substitution survives preflight when no custom access policy is present. | `source/as_metadata_image.cpp:383` |
| [AST-02](review-20260905-194335-builder-ast.md) | ConversionFunction is absent from registry role classification; a source-subtree conversion reference can be changed to a known primitive TypeUse key without failing Decode plus explicit identity validation. | `source/frontend/as_ast_projection.cpp:1353` |
| [AST-01](review-20260905-194335-builder-ast.md) | A valid UserConversionExpr nested under a numeric cast or used as a for condition fails projection's expression-child classifier. Builder therefore fails ASTVerified after the session verifier succeeds. | `source/frontend/as_ast_projection.cpp:1159` |
| [SEM-1](review-20260905-194335-builder-semantics.md) | Ordinary mutable-receiver calls cannot select equally ranked const/non-const overloads, despite distinct valid function identities and the retained language's mutable preference. | `source/frontend/as_frontend_sema_postfix.cpp:480` |
| [SEM-2](review-20260905-194335-builder-semantics.md) | A conditional selecting two Item@ expressions is assigned bare Item semantics, then fails handle return conversion. | `source/frontend/as_frontend_sema.cpp:657` |
| [SEM-3](review-20260905-194335-builder-semantics.md) | Foreach accepts safe Item@ to const Item@ element binding during analysis but rejects it during AST verification. The unsafe inverse is also admitted too early, but verification catches it; no invalid publication is claimed. | `source/frontend/as_frontend_sema_statements.cpp:49`, `source/frontend/as_frontend_ast_verifier.cpp:432` |

Here `source/` is `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` within the immutable tree. The coordinator read all relevant admission predicates for M1/M2, both projection expression classifications and codec external-reference checks for AST-01/02, the actual expression qualifier setter and call-selection paths for SEM-1/2, and both complete foreach conversion predicates for SEM-3. Preliminary speculation that the unsafe foreach conversion could publish was explicitly rejected: the verifier prevents publication.

These are implementation defects in existing contracts, not evidence that the architecture or Task DAG must be redesigned. No Replan is prescribed or performed. Repair scheduling and any necessary task follow-up require the subsequent implementation workflow; completed tasks are not unchecked by this review.

## Why the supplied passing corpus does not discharge these findings

The existing conversion tests are useful positive evidence but do not execute all downstream consumers. `BodiesConversions.UserConversionPrecedesASeparateBuiltinNumericConversion` constructs NumericCast(UserConversion) and calls Session.VerifyAST. Builder's ASTVerified stage additionally calls `asCASTProjection::Build`, whose child classifier omits UserConversionExpr. The source path therefore explains how the supplied positive test and this integration defect coexist without contradicting one another.

Likewise, frozen-image corruption tests cover owner size, function signatures, access flags and conversion declaration facts, but not the current property datatype or exposed method owner. Codec corruption tests change the cross-reference tag and local index, not a valid tag carrying an already admitted key of the wrong semantic role. These gaps require specific cases and consumer assertions, not merely a larger aggregate test count.

## Immutable snapshot and provenance

- Captured at `2026-09-05T19:43:18.1928523+08:00`, including tracked and untracked implementation, replacement tests, relevant requirements and Change artifacts: 1336 files.
- Read-only archive: `Saved/Harness/Reviews/builder-20260905-194219/snapshot.zip`, SHA-256 `89babe822b45e852df8b3858d0c27c7253c011c2ef00f8b4e6f1b797d09a32b1`.
- Read-only materialization: `Saved/Harness/Reviews/builder-20260905-194219/tree/`. Each extracted file was verified against captured content; no review consulted moving source for its findings.
- Parent HEAD `d4f69984b0611ca44956577c242266edad24002b`; plugin HEAD `f8e9bd701902e3707bcb2d5207bf4c2e0c6356f0`. HEAD alone is not the snapshot because uncommitted and untracked code is included.
- Frozen tasks SHA-256 `5124b640817b32aee3a016620ea6f3d2599146c1818d7e60094351cfe776fc1c`. Live tasks changed during the review; this report does not overwrite or reinterpret those subsequent task updates. The six primary source files in the finding table still matched the captured hashes when checked during coordinator triage.
- Supplemental read-only evidence archive: `Saved/Harness/Reviews/builder-20260905-194219/supplied-reports.zip`, SHA-256 `47f2d8c6a8894cc902b9324127b689bc287dff36c95e5d078431f4fd3acf7547`. This retains the two original report files below without altering the source snapshot.

| Supplied Automation run | Independently read report result | Original index.json SHA-256 |
| --- | --- | --- |
| `632220a045ce40d98e2e9f5fbc98314a` | 535 succeeded, 0 failed/notRun/inProcess; all cases Success | `a10645ee64377d927ddf70e3fbf7c7e4a06c593bb2578bd48d05aea2b1dab13e` |
| `8112f3720ec642218ebcf12c562adab1` | 539 succeeded, 0 failed/notRun/inProcess; all 539 cases Success | `e0015313ab89462ff5e5f11fc2370ef9e7b3aaf2b9b45e739b2e289417f2043f` |

Original reports are under `Saved/Harness/Unreal/Runs/<RunId>/AutomationReport/index.json`. The second report explicitly contains successful numeric-after-user-conversion, bool-conversion, V7 conversion-codec, access-authentication and ConversionDefinitions cases. Their hashes match the frozen task evidence. The old 481 report is historical only, not the current passing corpus. These supplied reports prove their original selected cases/binaries; they are not fresh proof for every file in the current review snapshot, especially pending implementation work.

## Verification and lifecycle boundaries

No new C++ fixture, native executable, UE build, UE Automation or sanitizer run was performed. All seven new failure cases are source-derived, not newly observed runtime failures. No timing or performance claim is made.

Only the four new Review records, their exact INDEX entries and ignored immutable evidence were created or updated. Product code, tests, proposal, design, specs, tasks, Git staging and commits were left unchanged. Quick, Performance, Integration, full UE suites and unrelated plugin/Standalone checks were intentionally omitted because this is a scoped source review, not implementation or release validation.

Coordinator closure 2026-09-05T21:04:23.1488285+08:00: tasks 8.1–8.3 repaired and mapped all seven Required findings on NativeEngine `59f6cb38656845afb018ed7291108382` (559 succeeded, 0 failed/notRun/inProcess, SHA-256 3656C5809F065A509DC84AADCAD54615453ABB8CEF302D2296FE53D7C7DFF9B0). Specialist reports are closed APPROVE. This coordinator record is closed APPROVE. No Critical finding existed. 6.2 namespace cutover remains pending and is outside these findings.

### Focused record validation — 2026-09-05T19:58:32.4361635+08:00

- `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`: PASS, exit 0.
- `Invoke-Harness -Command openspec.validate -Context $reviewContext -ArgumentList @('angelscript/refactor-builder-engine-independent', '--strict', '--json')`: PASS, 1/1 change, no issues; run `bb175f130fc64dc69da5f4edeeb26c6f`.
- Read-only, nonterminal `harness.evolution.status` for the exact Change: command succeeded; run `5097207e0fba40bc8f28b48c251a5aaa`. It discovers all four open review-v2 records and all seven open Required findings, with no review-schema, timestamp or INDEX errors. The seven expected finding blockers keep ClosureReady false; this is not an archive-gate pass. Pre-existing issues and remaining tasks are independently retained. No closure or archive action was requested.
- Source snapshot ZIP hash is unchanged. Supplemental ZIP hash and both contained original report hashes match the values above.
- `git diff --check -- openspec/changes/angelscript/refactor-builder-engine-independent/attachments/INDEX.md`: exit 0. All seven findings have explicit Severity/Status fields and parser-discoverable Finding headings.

These checks validate the review records and their retained evidence, not the proposed C++ failure cases. Later live task progression does not change this review's frozen implementation scope.
