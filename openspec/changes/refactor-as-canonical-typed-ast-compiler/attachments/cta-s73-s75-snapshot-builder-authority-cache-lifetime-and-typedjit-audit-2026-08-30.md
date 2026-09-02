# CTA-S73–S75 snapshot, Builder authority, Cache lifetime and TypedASTJIT audit — 2026-08-30

## Status

This attachment records the non-Standalone work completed after CTA-S72 and
the remaining issues found by static review. It is both an implementation
evidence card and an issue ledger. Standalone adaptation and validation are
deliberately excluded by current user scope.

The native AngelScript syntax AST remains intentionally retained for parsing,
syntax recovery, explicit LEGACY compilation, differential tests and reference
work. HIR remains removed. The goal of these slices is to prevent CANONICAL
semantic consumers from reattaching meaning by coordinates, names, dumps or
Engine-local numeric TypeIds.

## CTA-S73 — snapshot publication and `CompileFunction`

### Missing pending Context now fails closed

`asCModule::PublishCanonicalASTSnapshot()` previously had a generic path that
could fabricate an empty translation unit when no pending Canonical Context
existed. An empty, sealed graph is not valid proof of complete source
semantics. The publisher now returns without publication when the pending
Context is null.

TDD evidence:

- RED: `Saved/Tests/cta-s73-snapshot-missing-pending-red2/20260830_061805_051_71e3cdbe`
  — **10/11**, the new missing-pending test failed as expected.
- build: `Saved/Build/cta-s73-snapshot-fail-closed-green-build/20260830_061842_724_69b65114`
- GREEN: `Saved/Tests/cta-s73-snapshot-fail-closed-green/20260830_061905_001_98f319c4`
  — **11/11**.

### Public `CompileFunction` is a node-free Canonical entry

The independent public single-function route was verified with CANONICAL
selection, Canonical publisher, zero legacy-compiler invocations,
`PUBLIC_SINGLE_FUNCTION` purpose, `hasNode == false`, and non-empty Canonical
source coordinates.

- GREEN: `Saved/Tests/cta-s73-compilefunction-node-free-green/20260830_061938_063_087873de`
  — **1/1**.

This closes the earlier concern that whole-module `Build()` evidence was being
incorrectly reused for `CompileFunction()`.

## CTA-S74 — exact producer-carried declaration identity

### Globals and enumerators

The retained Builder global record now carries generation-local exact
`CanonicalASTDeclaration` and durable stable declaration key fields.
`RegisterGlobalVariables()` consumes that carrier and no longer scans the
Canonical declaration inventory using `name + section + offset`.

The strengthened test poisons the retained native global identifier position
after the producer registration stage. The late consumer must still bind the
same exact Canonical DeclId.

- RED build: `Saved/Build/cta-s74-global-direct-carry-red-build/20260830_062740_421_7ae57c35`
- RED: `Saved/Tests/cta-s74-global-direct-carry-red/20260830_062807_745_bc1f639d`
  — **0/1**.
- GREEN build: `Saved/Build/cta-s74-global-direct-carry-green-build/20260830_062953_009_eca51d8a`
- GREEN: `Saved/Tests/cta-s74-global-direct-carry-green/20260830_063052_207_275bb38d`
  — **1/1**.

The broad Compiler run then exposed one honest regression:
`PreparedEnumInitializerConsumesSealedConstantWithoutLegacyCompiler` failed,
leaving the prefix at **633/634**. Root cause was not the direct carrier: normal
global parsing bound the identifier to its Canonical DeclId, but
`ParseEnumeration()` created the Canonical enumerator without completing the
same parsed-declaration identity binding. The old coordinate scan had masked
that producer omission. The parser now calls
`BindCompletedParsedDeclarationIdentity(sema, ident, canonicalEnumerator)` at
the enumerator-name completion boundary.

- enum GREEN build:
  `Saved/Build/cta-s75-enum-green-lifetime-exact-red-build/20260830_064905_442_9fd1297b`
- enum exact gate:
  `Saved/Tests/cta-s75-enum-producer-identity-green/20260830_064928_100_45e5f9d9`
  — **1/1**.
- final Compiler CanonicalAST:
  `Saved/Tests/cta-s75-compiler-canonical-full-green/20260830_065539_752_63f81b52`
  — **634/634**.

Static review found one medium hardening opportunity: for enum pseudo-globals,
the direct carrier verifies exact id/kind/name/key, while the enum-parent kind
check remains in the later enum initializer consumer. The current route fails
closed and does not silently miscompile, but owner/type equivalence should be
considered for a later focused producer-boundary test before another consumer
reuses the carrier.

### Classes and interfaces

The retained class declaration record now carries its exact Canonical DeclId
and stable key. `FindCanonicalObjectDeclaration()` matches the already-created
Runtime type shell to those fields and no longer reattaches through the native
class node.

- RED build: `Saved/Build/cta-s74-class-direct-carry-red-build/20260830_063146_572_30ba8cc2`
- RED: `Saved/Tests/cta-s74-class-direct-carry-red/20260830_063208_806_fdbd5f63`
  — **0/1**.
- GREEN build: `Saved/Build/cta-s74-class-direct-carry-green-build/20260830_063305_131_0899ee22`
- GREEN: `Saved/Tests/cta-s74-class-direct-carry-green/20260830_063403_392_0a584e57`
  — **1/1**.

### Function/member distinction

`BindCanonicalFunctionIdentity()` and member access-specifier binding still
receive a native parser node at the Builder registration boundary. They use it
once to bind an exact stable declaration key into the Runtime shell; Canonical
body emission later consumes the carried key with `hasNode == false`. This is
not the late whole-inventory reattachment defect that existed for globals and
classes, and the retained native AST is intentional. It remains a reviewable
producer bridge, not Canonical backend semantic authority.

## Task 3.4 acceptance — last-good executable and snapshot

`SnapshotPreparationFailureKeepsLastGoodExecutableAndSnapshot` builds
generation A under explicit CANONICAL + RETAIN, acquires its snapshot and
executes `F() == 1`, then injects snapshot-preparation OOM while compiling valid
generation B (`F() == 2`). The build fails with OOM; A remains current, the
exact prior snapshot pointer/key remains visible, `F()` still returns 1, the
publisher remains Canonical, and legacy invocation count stays zero.

- build: `Saved/Build/cta-s74-snapshot-cache-lease-build2/20260830_063754_473_82aed24c`
- focused GREEN:
  `Saved/Tests/cta-s74-snapshot-preparation-failure-green/20260830_063815_017_b7f02b77`
  — **1/1**.
- complete Snapshot group:
  `Saved/Tests/cta-s74-snapshot-full-green/20260830_063854_532_a163c9f8`
  — **12/12**.

Together with CANONICAL discard-policy, missing-pending fail-closed,
successful generation replacement, failed candidate preservation, and public
lease tests, this satisfies Task 3.4 for the CANONICAL source-build scope. The
explicit LEGACY compiler remains intentionally available and does not need to
own a Canonical AST through Canonical CodeGen. Physical removal of the native
AST/LEGACY system is a separate future OpenSpec.

## Cache clean-capture AST lifetime

Static review found `DescribeCanonicalSourceAuthority()` traversing a raw
Canonical Context. It now acquires a public V1 `asIASTSnapshot` lease, uses an
RAII release guard, and traverses only while that lease is held.

The API contract now also states the larger lifetime boundary: the caller must
own the compile transaction or equivalent Engine mutation exclusion for the
module/function/script-data/dependency inventory. The shared descriptor object
does not make those raw Runtime collections independently thread-safe, and the
capture API is not a concurrent reload/discard entry point.

A deterministic serialized RED for the internal reference count is not
available without adding a production barrier/test hook or exposing internal
refcount state. The raw and leased implementations produce the same output in
a single-threaded fixture. This slice therefore uses static lifetime evidence,
the public snapshot protocol's existing lease tests, broad Cache behavior, and
an explicit transaction contract rather than inventing a test-only production
synchronization API.

The first complete Cache rerun used the runner's ten-minute default and was
cut off after roughly 447 of 584 tests with no reported assertion failure:

- incomplete/timeout evidence only:
  `Saved/Tests/cta-s74-cache-full-green/20260830_063854_532_d4e759a4`

That path is not counted as PASS. A new 30-minute rerun completed successfully:

- `Saved/Tests/cta-s75-cache-full-long-timeout/20260830_065630_462_60d7d389`
  — **584/584 PASS**, zero failed/skipped, runner exit 0, duration
  **735407 ms**.

The prior complete behavioral baseline was CTA-S72 Cache
**584/584**:
`Saved/Tests/cta-s72-cache-full-green/20260830_054157_730_86347fca`.

## CTA-S75 — exact lifetime cleanup owner

Review found cleanup authoring/lifetime verification accepting either the
complete owner stable key or the class's unqualified name. That can conflate
same-name value types from different namespaces. The new adversarial fixture
uses type key `FValue`, an owner name `FValue`, and owner stable key
`Wrong::FValue`; old name fallback incorrectly accepted it.

The exact owner rule is now shared by:

- Sema cleanup/destructor authoring;
- local-value destructor lifetime matching;
- aggregate value/factory owner matching;
- foreach and scope-exit cleanup verification.

It requires complete stable-key equality. Adjacent constructor/operator/
deferred-setter compatibility checks were not changed without their own TDD
fixtures; they remain a separate exact-relation audit.

Evidence:

- RED:
  `Saved/Tests/cta-s75-lifetime-qualified-owner-red/20260830_064928_100_d8f66629`
  — **0/1**, old implementation accepted the forged same-name owner.
- initial fixture correction: the hand-built class had to explicitly receive
  `Wrong::FValue`; `CreateDecl()` intentionally initializes a stable key from
  its local name and does not synthesize a qualified key.
- build:
  `Saved/Build/cta-s75-lifetime-exact-owner-fixture-build/20260830_065339_851_11f1697b`
- exact GREEN:
  `Saved/Tests/cta-s75-lifetime-qualified-owner-green3/20260830_065357_411_c700d331`
  — **1/1**.
- existing valid qualified-owner gate:
  `Saved/Tests/cta-s75-lifetime-existing-qualified-owner-green/20260830_065430_359_e4c48200`
  — **1/1**.
- Frontend CanonicalAST:
  `Saved/Tests/cta-s75-frontend-canonical-full-green/20260830_065504_436_704c5d58`
  — **182/182**.
- Compiler CanonicalAST:
  `Saved/Tests/cta-s75-compiler-canonical-full-green/20260830_065539_752_63f81b52`
  — **634/634**.

## TypedASTJIT read-only audit

Tasks 7.2, 7.4 and 7.5 remain open. The audit confirms several important
sub-boundaries are already real:

- generation owns a V1 Publishable AST lease;
- verified typed eligibility and emission consume exact Canonical Decl/Stmt/
  Expr identities without HIR or Bytecode-body analysis;
- supported script-call edges use exact same-Context DeclIds and SCC/recursion
  budgeting;
- typed lifetime summaries consume the authenticated shared lifetime view and
  emit pointer-free summaries;
- unsupported mutable globals/imports and nonrepresentable lifetime shapes
  fail closed.

The highest-priority newly recorded issue is receiver omission. Typed
eligibility explicitly skips `asAST_EDGE_EXPR_RECEIVER`; the call collector
recurses only ordinary children; the emitter evaluates only reverse-formal
children. A receiver-bearing call can therefore omit receiver-side effects,
nested call dependencies and effective-receiver ABI facts.

The minimum safe next TDD slice is not partial lowering. Until complete
receiver provenance/evaluation/ABI lowering exists, any call with a valid
receiver should take explicit per-function `UnsupportedReceiver` fallback.
The fixture must include a receiver containing a nested call so closure loss is
also observable. Later Tasks 5.3/5.4 can introduce exact receiver facts and
direct/native-bridge/script-helper lowering together.

Other open TypedASTJIT findings:

- native targets still reconcile through declaration/owner strings rather
  than a verifier-authenticated immutable runtime-binding relation;
- suspend and zero-cleanup exception-region facts do not yet drive explicit
  typed fallback;
- production script-callee scalar bridge availability is false, so unsupported
  callees fall back at whole-root granularity;
- formal lookup, managed input allowlists and some global dependencies still
  reconcile through Runtime type/name/ordinal projections;
- dependency closure is a safe fail-closed hybrid of Canonical semantic uses
  plus the frozen generation graph, not yet pure Canonical dependency data.

These findings are safe-default blockers or feature-closure work, not evidence
that the main Canonical Bytecode publication path is broken. The main
detached-artifact, relocation, rollback and atomic publication route is already
implemented and covered by transaction tests.

## Current disposition

- Task 3.4 may be closed for the specified CANONICAL source-build scope.
- CTA-S73, CTA-S74 and the exact-lifetime CTA-S75 slice are implemented and
  broadly green.
- Tasks 7.2/7.4/7.5 stay open.
- Product default stays LEGACY until receiver safety, remaining semantic/
  backend breadth, cutover scans and the final verification matrix are closed.
