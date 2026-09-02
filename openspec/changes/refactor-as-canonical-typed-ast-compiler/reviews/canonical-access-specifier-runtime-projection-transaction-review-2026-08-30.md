# Canonical AccessSpecifier Runtime projection transaction review — 2026-08-30

## Verdict

The revised AccessSpecifier path is architecturally sound for the supported
CANONICAL Stage 2 boundary. It follows the intended Clang-like separation:
Parser produces a typed action, Sema owns exact declaration relations, the
compiler-owned Canonical context is the semantic authority, and Runtime
projection performs mechanical, generation-local materialization. The retained
native syntax tree is no longer replayed for access meaning.

The timing boundary matters: Stage 2 runs before final verifier/Seal, so this is
not a Frozen/Publishable snapshot consumer and not detached CodeGen. Class and
member native nodes are still accepted as build-local completed-coordinate
keys for finding exact Canonical declarations. They do not supply access names,
permission lists, traits or member-edge meaning.

The implementation is accepted for CTA-S69 after the review-derived blocker
matrix, Parser OOM closure, complete Compiler/Frontend Canonical regressions
and static boundary scans. This is not an acceptance of the entire OpenSpec or
the final CANONICAL default flip.

## Finding disposition

| Finding | Severity | Disposition | Evidence |
|---|---|---|---|
| Field access was authenticated after property-shell publication | High | Fixed; resolve before `AddPropertyToClass` | focused `125/126` RED, then `126/126` GREEN |
| Definition inventory/order still followed retained native access nodes | High | Fixed; inventory is exact Canonical owner-child order | focused two-failure RED, then `127/127` GREEN |
| Repeated wildcard traits overwrote instead of accumulated | Medium | Fixed with OR semantics matching LEGACY metadata | same `127/127` GREEN |
| Dangling owner child was ignored before the zero-definition fast path | High | Fixed; dangling child is rejected before counting/early success | `128/131` RED, then `131/131` GREEN |
| Distinct AccessSpecifier DeclIds with one name were accepted | High | Fixed; exact name uniqueness now matches Parser/Sema and LEGACY registration | same `131/131` GREEN |
| One permission DeclId could appear twice | High | Fixed; duplicate permission DeclId is rejected before DTO commit | same `131/131` GREEN |
| AccessSpecifier embedded self-ID could disagree with the owner child ID | High audit question | Existing production guard is correct; permanent mutation test added | `131/133` mutation RED, then `133/133` GREEN |
| Permission child self-ID was not authenticated against the listed child ID | High | Fixed as part of permission-shape validation and independently mutation-authenticated | same `131/133` mutation RED, then `133/133` GREEN |
| Record owner and field/method objects were found by indexed DeclId without authenticating their embedded self-ID | High | Fixed; owner lookup and member-edge resolution now require `record->id == requestedId` before any aggregate/member shell can publish | `147/150` RED with exactly three failures, then `150/150` GREEN |
| Foreign method access could potentially publish a method shell | High audit question | Existing ordering was correct; permanent negative test added and was GREEN in RED matrix | `PreparedForeignMethodAccessEdgePublishesNoMethodShell` |
| `PushLast` could silently drop a permission on OOM | High | Fixed; checked growth and deterministic second-append failure test | compile RED, build GREEN, SemaAuthority `423/423` |
| `asCBuilder::Reset()` referenced the compiler-only access binding member when `AS_NO_COMPILER` removes that member | Medium configuration defect | Fixed by aligning the reset statement with the member's existing `#ifndef AS_NO_COMPILER` boundary | normal UE build PASS; dedicated no-compiler/Standalone configuration remains deferred and is not claimed |
| Dormant mixin-class expansion still performs LEGACY access-name lookup | Not reachable in the current product grammar | Recorded, not expanded into CTA-S69: `ParseMixin()` accepts free mixin functions only, `RegisterMixinClass()` has no callers, and current tests explicitly reject `mixin class` | static grammar/call-site review; no production path to authenticate in this gate |
| Different permission DeclIds sharing a permission name or `*` | Not a defect | Deliberately retained; LEGACY permits repeated entries and wildcard traits accumulate | implementation and repeated-wildcard regression |

## Architecture assessment

### What is now strong

1. **Semantic authority is explicit.** The Runtime projector starts from exact
   Canonical owner/child/edge DeclIds. It does not decode retained access text
   or traverse native access permission/modifier nodes; native class/member
   nodes are limited to exact completed-coordinate lookup.
2. **Durable and Runtime identity are separated.** Canonical declaration
   identity remains pointer-free; `asSAccessSpecifier*` exists only in the
   current generation's materialization view.
3. **Publication is staged.** All DTO allocations and validation happen before
   the per-class aggregate swap. The failure path owns and deletes only staged
   objects.
4. **Borrowers cannot observe unauthenticated targets.** Fields and methods
   resolve exact access edges before their respective Runtime shells become
   visible.
5. **Failure is honest at the projection/publication boundary.** CANONICAL
   records malformed or unallocatable input, does not silently route through
   LEGACY, does not publish a truncated access aggregate, and the failed module
   is not swapped active. The UE outer orchestrator's later work on that doomed
   candidate is a separately recorded lifecycle boundary.
6. **LEGACY remains independent.** The old native AST and
   `RegisterAccessSpecifier` remain available under explicit LEGACY selection,
   satisfying the requested reference/rollback boundary.

### Why this resembles the useful Clang model

The useful reference point is not Clang's full C++ access-control complexity.
AngelScript's custom `access NAME = ...` dialect is much smaller. The relevant
architectural pattern is:

- syntax parsing builds recoverable syntax state;
- typed Sema actions create exact declarations and relations;
- later consumers read exact semantic records rather than re-decoding syntax;
- target-specific objects are materialized after semantic validation;
- target-local numeric IDs and pointers do not become AST identity.

CTA-S69 now follows that pattern. It does not import C++ `public/protected/
private` lookup rules, friendship, modules or C++ inheritance semantics that
the AngelScript dialect does not have.

Because the materialization precedes Freeze, the closest Clang analogy is
Sema-owned declaration facts feeding a target-specific declaration shell
during compilation, not a serialized AST reader or later LLVM backend.

## Transaction boundary review

The current boundary is intentionally two-level:

1. the complete AccessSpecifier DTO list for one class is staged and committed
   atomically;
2. each field/method access borrower is authenticated before publishing that
   member shell.

That is adequate for the reachable CTA-S69 failure modes and is backed by
negative tests. It is not a claim that the entire module's types, funcdefs,
globals, functions, access metadata and bindings are committed by one universal
transaction. The broader detached-artifact/Commit protocol remains Task 13.6.

The early-stop added around `ParseScripts()` applies to any CANONICAL Stage 2
error, not only access projection. CTA-S69 directly proves the access failure
family; it does not establish rollback/diagnostic parity for every other error
category that reaches the same guard.

The scope of that early stop is local to `BuildGenerateFunctions()`: it skips
that function's `CompileClasses()` and `RegisterGlobalVariables()` calls. The UE
staged compiler currently continues to call `BuildLayoutClasses()`,
`BuildAllocateGlobalVariables()` and Stage 3/JIT entry points on the failed
candidate. Final `bHadCompileErrors` prevents active-generation swap and the
candidate is reset/discarded, so review found no active publication or dynamic
TypeId/pointer escape. It is nevertheless reachable failed-candidate partial
materialization and remains a high-priority Task 13.6 lifecycle cluster.

The access DTO aggregate and all class members also do not form one transaction:
a later member-edge error can leave earlier shells in the failed candidate until
module discard. CTA-S69 guarantees aggregate staging plus per-member pre-shell
authentication, not per-class member-set rollback.

## Dynamic TypeId and pointer review

The implementation correctly avoids treating Runtime identity as durable:

- Canonical relations are DeclId/stable-key facts;
- Runtime `asSAccessSpecifier*`, object types, properties, method IDs and
  numeric TypeIds are resolved only against the current prepared generation;
- the transient binding table is rebuilt for that generation;
- no pointer or numeric TypeId is written into Sidecar/public AST identity;
- failure before publication discards the candidate-local materialization.

This is the required mitigation for AngelScript's dynamic TypeId model. The
remaining Hot Reload rule is unchanged: old-generation consumers must retain
their own generation lease, while new resolution uses stable identity against
the new generation. Copying a numeric TypeId or DTO pointer across generations
would be a regression.

## Remaining review boundaries

These items are recorded but were not allowed to expand CTA-S69 without a
reachable contract and a focused gate:

- dormant shared-class comparison branches;
- constructor/destructor access behavior;
- dormant virtual-property source/name lookup, whose current producer path is
  rejected before registration;
- dormant mixin-class-expanded access definitions or member edges. The current
  Parser supports free `mixin` functions, not `mixin class`, and
  `RegisterMixinClass()` has no production caller;
- interface-specific access metadata;
- UE failed-candidate layout/global allocation/Stage 3 after Stage 2 error, and
  retry after broader partial module materialization;
- uniform immediate Parser failure for `asCString` payload-copy OOM after the
  already checked permission-array growth;
- persistence of any Runtime access binding beyond one generation;
- final removal of remaining Parser-node semantic body adapters;
- final CANONICAL default flip;
- Standalone adaptation.

CTA-S69 also does not change Sidecar V8 or add any AST/public schema field. Its
new Stage 2 tests do not themselves prove a detached artifact, VM execution,
publisher provenance, Hot Reload or Cache restore for access metadata.

The first five should be re-audited when their production reachability becomes
part of a later risk cluster. Standalone remains explicitly deferred by user
direction. None justifies restoring HIR, deleting the native AST, changing
public AST V1 or introducing a production dual/fallback mode.

## Verification summary

- ProductionCodeGen focused matrix: **150/150 PASS**. The final owner/member
  self-ID cluster first produced exactly three intended failures
  (**147/150**); the earlier definition/permission cluster produced exactly two
  intended failures (**131/133**).
- SemaAuthority complete class: **436/436 PASS**.
- Complete Compiler CanonicalAST: **631/631 PASS**.
- Complete Frontend CanonicalAST: **175/175 PASS**.
- Runtime/Editor/test build: PASS.
- exact projection scan: no native access-node or LEGACY registration call;
  one staged aggregate swap.
- exact Parser scan: no silent permission `PushLast`; one checked growth and
  one typed publication.
- forbidden HIR source scan: zero Runtime matches outside Standalone.
- `AS_NO_COMPILER` reset/member guards are statically aligned. No dedicated
  no-compiler build is claimed because Standalone is explicitly deferred.

Detailed paths and RED/GREEN chronology are retained in
`attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.
