# Canonical custom access-specifier typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-17 — fork custom `access NAME = ...` declaration plus exact member binding |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | `access Internal = private, Friend(inherited), *(readonly, editdefaults);` plus one field and one method bound through `access:Internal` |
| Construction/sealed-AST assertion | one `AccessSpecifierDecl` owns ordered `AccessPermissionDecl` children; base visibility and per-permission wildcard/readonly/editdefaults/inherited facts are typed traits; field/method carry an explicit DeclId edge to the exact specifier |
| Architecture assertion | `ParseAccessDecl` publishes pointer-free payloads; function/variable headers carry only the authored access-group spelling; Sema resolves the exact record-local specifier and no consumer reconstructs access facts from `snAccessDeclaration` |
| Expected RED | no Canonical access decl kinds/permission traits/member edge or typed action payload exists; Parser-only access declarations disappear from the sealed graph and `access:NAME` is absent from Canonical field/method facts |
| Production edit allowed after RED | append-only AST kinds/traits/view edge, traversal/sidecar/verifier/dump support, typed Parser actions, exact Sema lookup/binding, and metadata-only CodeGen acceptance required by the new sealed facts |

## Locked design

1. Add append-only public/internal declaration kinds
   `asAST_DECL_ACCESS_SPECIFIER` and `asAST_DECL_ACCESS_PERMISSION`.
   `AccessSpecifierDecl` is a record child named by the authored group;
   ordered permissions are its declaration children.
2. Reuse existing `PRIVATE`/`PROTECTED` traits for the specifier base. Add
   append-only permission traits for wildcard, readonly, editdefaults and
   inherited. A wildcard permission is named `*`; named permissions preserve
   the complete authored spelling.
3. Add one explicit `accessSpecifier` DeclId edge to `asCDecl` and the
   capacity-aware public declaration view. Fields/methods using `access:NAME`
   point to the exact record-local `AccessSpecifierDecl`; they do not store a
   numeric Runtime pointer or re-run name lookup in CodeGen.
4. Parser publishes one pointer-free `asSAccessSpecifierAction` only after the
   complete terminating `;`. It contains the name, base trait, ordered
   permission payloads and exact half-open ranges. The retained
   `snAccessDeclaration` is LEGACY/recovery syntax storage only.
5. Variable/function signature actions carry the access-group spelling parsed
   from their prefix. Sema resolves only a same-record access specifier; missing
   or ambiguous names fail closed with a stable diagnostic and no fake edge.
6. The edge and new declarations participate in verifier, deterministic dump,
   traversal/parent-edge inventory, sidecar round-trip and public snapshot
   capacity rules. Metadata-only declarations are accepted but never emitted
   as executable functions.
7. Builder `RegisterAccessSpecifier` and Runtime `asSAccessSpecifier` remain the
   comparison/public-registration path in this slice. Final Canonical Runtime
   installation and Builder retirement require later aggregate cutover gates.

## Required evidence

1. test-only build and valid RED before production edits;
2. direct typed-action semantic fixture and source-to-sealed-AST Parser fixture;
3. public-view/traversal/sidecar mutation coverage for the new explicit edge;
4. Runtime/Editor build after repair;
5. focused CTA-S-17 and complete SemaAuthority GREEN;
6. existing access-specifier syntax/registration regressions GREEN;
7. ProductionCodeGen GREEN, strict OpenSpec validation, and parent/plugin
   `git diff --check`;
8. every issue/RED/root cause/repair/evidence/non-claim copied to the final
   issue, execution, task and progress ledgers.

## Mutation checks

Permanent tests must fail if a future change:

- drops or reorders a permission;
- loses private/protected, wildcard, readonly, editdefaults or inherited facts;
- binds a member to a same-named specifier from another record or by Runtime
  pointer/numeric ID;
- restores Parser-node access reconstruction or omits the access definition
  from the sealed graph;
- publishes a dangling/foreign/wrong-kind access edge;
- treats access metadata as an executable function declaration;
- changes existing Builder/Runtime access behavior while claiming this shadow
  migration.

## Non-claims

- This does not retire Builder `RegisterAccessSpecifier` or Runtime
  `asSAccessSpecifier`.
- This does not prove final detached Runtime installation/hot-reload of access
  metadata from Canonical artifacts.
- This does not restore removed virtual-property syntax.
- This does not migrate general type/parameter/default/lambda/body/expression/
  statement/lifetime actions or complete Tasks `4.2`–`4.5`/`13.2`.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD and implementation result

### Valid RED

The four permanent test families were added before production edits:

- Sema action and Parser authority:
  `SemaAccessSpecifierActionRecordsPermissionsAndExactMemberEdges`,
  `ParserAccessSpecifierPublishesTypedFactsBeforeLaterSyntaxFailure`, and
  `ParserAccessSpecifierUsesTypedActionsWithoutNodeReplay`;
- Sidecar V5 round trip:
  `SidecarRoundTripPreservesAccessSpecifierPermissionAndMemberEdge`;
- traversal/verifier mutation:
  `AccessSpecifierReferenceIsNamedIndexedAndWrongKindRejected`;
- capacity-aware public snapshot:
  `RetainedV1SnapshotPublishesAccessSpecifierAndCapacityAwareMemberEdge`.

The test-only build failed for exactly the absent production contract: no
access declaration kinds, permission traits, action payloads, explicit member
edge, public-view field or sidecar setter existed. Evidence:

`Saved/Build/cta-access-specifier-red-test-build/20260827_131137_537_f1456a76/RunMetadata.json`

That build also exposed one test-gate API mistake before production work: the
direct Sema fixture called the already-existing `ActOnStartMethodDecl` with
three arguments instead of supplying its canonical return type. The fixture
was corrected to pass `IntType`; this is a test compile correction, not a
product defect or a skipped RED.

### Production repair

The repair implements the locked design without moving the product boundary:

- append-only `ACCESS_SPECIFIER`/`ACCESS_PERMISSION` declaration kinds and
  wildcard/readonly/editdefaults/inherited traits;
- one explicit `accessSpecifier` DeclId edge in the internal declaration and
  capacity-aware public view, including named traversal and verifier rules;
- pointer-free `asSAccessSpecifierAction` and
  `asSAccessPermissionAction` payloads, plus authored access-group spelling on
  variable/function header actions;
- exact same-record Sema lookup and member binding with missing/ambiguous names
  failing closed;
- deterministic dump/shadow comparison, metadata-only CodeGen acceptance and
  Sidecar schema **V5** encode/decode/reference/content-identity support;
- Parser publication only after the access declaration's terminating `;`, with
  zero `NotifySema` calls in the exact `ParseAccessDecl` slice and no
  `case snAccessDeclaration:` semantic decoder.

The first Runtime/Editor production build passed:

`Saved/Build/cta-access-specifier-first-fix-build/20260827_133435_740_8ebc274d/RunMetadata.json`

### GREEN triage and fixture corrections

Three post-repair failures were investigated as separate hypotheses rather
than weakening production validation:

1. The first traversal run was **5/6** because the hand-built
   `AccessSpecifierDecl` omitted the contractually required PRIVATE or
   PROTECTED base trait. The verifier was correct. The fixture was repaired by
   setting PRIVATE, rebuilt, and passed **6/6**:
   `Saved/Tests/cta-access-specifier-traversal-green/20260827_134017_612_99752cfd/RunMetadata.json`,
   `Saved/Build/cta-access-specifier-fixture-correction-build/20260827_134526_487_31a7fab7/RunMetadata.json`,
   `Saved/Tests/cta-access-specifier-traversal-second-green/20260827_134815_198_011a6ded/RunMetadata.json`.
2. The first snapshot run was **9/10** because the test demanded a Runtime
   `asSAccessSpecifier` from a CANONICAL module. That contradicted this gate's
   explicit non-claim: the current CANONICAL Build seals and lowers the
   detached graph but does not yet run LEGACY `RegisterAccessSpecifier`. The
   permanent test now proves legacy Runtime registration in a separate LEGACY
   module and Canonical public snapshot facts in the CANONICAL module. Rebuild:
   `Saved/Build/cta-access-specifier-snapshot-fixture-correction-build/20260827_135555_624_bbfbcb9e/RunMetadata.json`.
3. The second snapshot run was **9/10** because the fixture searched a class
   method as `FUNCTION`; Parser/Sema correctly publishes it as `METHOD`. The
   oracle was corrected without production changes, rebuilt, and the third run
   passed **10/10**:
   `Saved/Tests/cta-access-specifier-snapshot-second-green/20260827_135611_833_d223062b/RunMetadata.json`,
   `Saved/Build/cta-access-specifier-method-kind-fixture-build/20260827_135733_991_e0dc9595/RunMetadata.json`,
   `Saved/Tests/cta-access-specifier-snapshot-third-green/20260827_135753_785_3d252b3f/RunMetadata.json`.

These are retained test-oracle corrections. None changes the verifier,
same-record lookup, snapshot capacity rule or Runtime-installation boundary.

### Final evidence

| Gate | Result | Evidence |
|---|---:|---|
| Complete SemaAuthority | **329/329 PASS** | `Saved/Tests/cta-access-specifier-sema-authority-first-green/20260827_133752_645_73f70bcc/RunMetadata.json` |
| Traversal/verifier | **6/6 PASS** | `Saved/Tests/cta-access-specifier-traversal-second-green/20260827_134815_198_011a6ded/RunMetadata.json` |
| Cache ASTBodySidecar V5 | **18/18 PASS** | `Saved/Tests/cta-access-specifier-sidecar-green/20260827_134953_130_02805a42/RunMetadata.json` |
| Public Module Snapshot | **10/10 PASS** | `Saved/Tests/cta-access-specifier-snapshot-third-green/20260827_135753_785_3d252b3f/RunMetadata.json` |
| ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-access-specifier-production-codegen-green/20260827_135836_707_f0720c25/RunMetadata.json` |
| Parser declarations | **18/18 PASS** | `Saved/Tests/cta-access-specifier-parser-declarations-green/20260827_140000_944_d201f485/RunMetadata.json` |

Static verification finds one typed access action publication and zero
`NotifySema` calls inside the exact `ParseAccessDecl` slice, zero
`case snAccessDeclaration:`, matching Sidecar schema constants at **5**, and
the expected access implementation/test references. Strict OpenSpec validation
passes. Parent and plugin `git diff --check HEAD` both exit **0**; their output
contains existing LF/CRLF conversion notices only.

### Result and remaining boundary

CTA-S-17 is closed as a bounded typed-action slice. Tasks `4.2`, `4.4`, `4.5`
and `13.2` remain unchecked: general type/parameter/default/property/lambda/
body/expression/statement/lifetime authority, final Canonical Runtime access
installation, aggregate registration parity, Builder retirement, complete
detached CodeGen, HIR retirement and default cutover are still open. Compiler
default remains LEGACY and Cache V2 remains default-disabled.

## 2026-08-30 CTA-S69 follow-up — Canonical Runtime projection

The 2026-08-27 statement above remains the historical CTA-S-17 boundary. It is
now superseded only for the supported prepared CANONICAL class projection:
CTA-S69 installs Runtime `asSAccessSpecifier` metadata mechanically from the
exact Canonical declaration graph and binds ordinary field/method borrowers
through a generation-local relation table. Explicit LEGACY continues to use
the native `RegisterAccessSpecifier` path.

The follow-up closes review findings that were not part of the original typed-
action gate:

- class definition inventory/order no longer follows retained native access
  node coordinates;
- Runtime DTOs are fully staged and committed with one class-aggregate swap;
- field/method access edges are authenticated before the corresponding Runtime
  member shell is published;
- dangling owner children, duplicate definition identities/names, permission
  self-ID mismatches and duplicate permission identities fail closed;
- indexed owner, field and method objects must self-identify with the exact
  requested Canonical DeclId before aggregate or member-shell publication;
- repeated wildcard traits accumulate with OR semantics;
- Parser permission-array OOM fails before publishing a truncated typed action.

The current broad evidence is SemaAuthority **436/436 PASS**, Compiler
CanonicalAST **631/631 PASS** and Frontend CanonicalAST **175/175 PASS**.
Focused ProductionCodeGen is **150/150 PASS** after a three-failure owner/
field/method self-ID RED. Complete RED/GREEN chronology,
implementation boundaries and non-claims are recorded in
`attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`
and
`reviews/canonical-access-specifier-runtime-projection-transaction-review-2026-08-30.md`.

This follow-up still does not close general Runtime declaration publication,
module-wide transaction coverage, remaining Parser-node body adapters, final
CANONICAL default cutover or Standalone. Public AST V1 is unchanged, HIR stays
absent, and the native AST/Builder/Compiler remain for explicit LEGACY and
reference use.
