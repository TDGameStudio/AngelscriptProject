# Implementation Lessons And Mandatory Working Rules

These rules summarize the concrete failures and successful repairs recorded in
IC-001 through IC-141. They guide future work; they do not replace normative wire
or behavior contracts.

## 1. Freeze only after the candidate builds

Required order for a reviewed boundary:

1. Write a bounded RED.
2. Compile the complete target test TU.
3. Link the relevant Runtime/Test modules when the boundary exists.
4. Freeze exact SHA/size/line shape.
5. Run independent review.
6. Implement GREEN.
7. Run focused behavior and integration evidence.

A missing-header RED is acceptable only for a first declaration boundary. Once the
header exists, RED must compile/link and fail behavior. Any source repair creates a
new review candidate; approval never transfers automatically between SHAs.

## 2. Evidence levels are not interchangeable

- SingleFile compile proves syntax and declarations only.
- Module link proves symbol availability only.
- Focused Automation proves the named behavior only.
- Integration proves the real upstream/downstream production path.
- PIE/package acceptance proves environment behavior.

Every status or task update names its evidence level. A build process crash,
unresolved symbol or unrelated missing header is not behavioral RED.

## 3. Review bounded authorities, not every incidental edit

Independent 0C/0I review is mandatory for frozen bytes/identity domains, ownership
and immutable publication, exact allocator/Budget boundaries, atomic store state and
other shared safety contracts. Ordinary local implementation uses TDD, normal code
review and focused verification. This avoids repeating full reviews for mechanical
compile repairs while preserving rigor where drift would corrupt persisted data.

Large matrices keep immutable authority data separate from test execution logic.
Tests do not derive their representative cases from the production candidate pool,
use first-match selection as an oracle, or hide compile errors behind an early
missing include.

## 4. There is one production ownership path

- One decoder owner and final by-value seven-alternative record.
- One decoded candidate transaction and one final shared controller allocation.
- One token-owned canonical payload.
- One promotion before no-fail const-handle publication.
- One module graph traversal.

Tests may observe or inject private checkpoints on that same path. They may not add
a second semantic decoder, owner, graph traversal, direct publisher, ambient/TLS
probe or Runtime-owned growing event store.

## 5. Allocation evidence observes the real allocator

Budget rejects before Reserve/allocation. The predicted reserved bytes must equal
the allocator result; disagreement fails closed and is not corrected after the
allocation. Controller, payload, nested arrays/strings, scratch and retained output
participate in one chronology and combined-live peak model. Monotonic totals are not
refunded; temporary/live ownership is released on every exit.

Guarded test observation uses caller-owned fixed-capacity views, reports overflow,
does not escape the call and compiles out of Shipping. Enabled and disabled test
seams must leave production outputs, hashes, errors and Budget behavior identical.

## 6. Persist granularly, activate atomically

- FunctionBody: function execution unit.
- DebugSidecar: function/profile debug unit.
- TypeSchema: individual type/layout/reflection unit.
- ModuleState: atomic globals/initializers/post-init unit.
- ModuleSnapshot: module activation root.
- SourceIndex: generation source root.
- Pack: physical aggregate of many logical records.

This retains unchanged functions/types without pretending that Unreal class layout,
globals or active module publication are safely function-granular.

## 7. First launch and runtime policy are source-authoritative

First Editor or packaged launch may compile and create Cache V2. Later launches
reuse exact records and incrementally publish new generations. Invalid source does
not overwrite the last committed generation. Editor hot reload may use last-good
active state; a fresh startup failure must remain a typed failure rather than
silently executing a different-source cache.

Shipping code-only updates may activate at a safe point. Class, property,
inheritance, signature, global layout, interface, delegate or enum structural
changes return `RequiresRestart`. Closing the Editor may request a bounded flush but
is not the only correctness path for cache generation.

## 8. StaticJIT and Live Coding are consumers, not cache owners

StaticJIT consumes stable function key, execution content and profile through its
sibling provider contract. Provider absence/removal/mismatch changes Native versus
VM routing only and never invalidates a valid Cache V2 generation. Editor Live
Coding can refresh an external generated C++ provider module; it cannot determine
whether `.as` records are current.

## 9. Vertical checkpoints, review scope and concurrency are explicit

The current implementation proceeds serially unless the user explicitly requests
independent parallel work. Each active task still states owned files, prerequisites,
forbidden shortcuts, applicable RED/GREEN command and required evidence, but
ordinary local TDD does not require a separately frozen exact-SHA ready packet.
Create a formal packet/review boundary only for stable wire/identity, shared
ownership/allocation, immutable publication, VM attachment or another genuinely
high-risk contract.

Progress is reported at V0–V7 vertical checkpoint outcomes rather than horizontal
checkbox ratios. A representative cold/warm/edit production path is established
early; broad negative matrices expand the same path and must not indefinitely keep
Store, compiler and service integration outside the critical path. If parallel work
is later authorized, workers never edit the same production file, frozen authority
or OpenSpec ledger; the primary agent alone updates current execution truth.

## 10. No legacy Cache fallback

V2 parity is followed by direct removal of `PrecompiledScript.Cache`, DataGuid cache
correctness, old pointer/FunctionId relocation and package pre-generation. There is
no reader, migration, overlay or V2-failure-to-V1 fallback. Numeric transport still
needed by the sibling StaticJIT provider is inventoried separately and has no Cache
correctness authority. `Binds.Cache` remains unaffected.
