# Cache V2 Unit-Test And Testability Matrix

## Purpose

This attachment turns the user-requested high unit-test density into a concrete
implementation contract. It is not a claim that listed tests already pass. Real
PIE and packaged Development/Shipping launches remain the final acceptance layer;
the normal Cache prefix must first make each pure, transactional and lifecycle
decision reproducible without launching a packaged process.

## Current source baseline — 2026-08-08

The isolated worktree currently contains 181 Cache `TEST_METHOD` definitions:

| Translation unit | Definitions | Current role |
| --- | ---: | --- |
| `AngelscriptArtifactIdentityTests.cpp` | 10 | stable keys, digests and profiles |
| `AngelscriptCacheArchiveEnvelopeTests.cpp` | 18 | envelope, checked framing, address-overflow/allocation-capacity alias safety and seven-kind RecordId domain/ordering separation |
| `AngelscriptCacheArchivePrimitiveTests.cpp` | 13 | canonical primitive wire, allocator chronology, bounded recursive output-allocation alias safety, observer-capacity equivalence, candidate rollback and concurrent caller-owned capture isolation |
| `AngelscriptCacheBudgetTests.cpp` | 16 | independent stored/decompressed/reference budgets, cumulative/live decoded Budget, overlapping candidate transactions and per-instance thread affinity |
| `AngelscriptCacheSourceInterfaceTests.cpp` | 29 | SourceIndex, ModuleInterface and eligibility, including caller-owned observation, allocator-authoritative ownership, move-only authority transfer, late-failure rollback and atomic derived-output reset |
| `AngelscriptCacheTypeSchemaTests.cpp` | 54 | TypeSchema/layout/all-record RED authority, including hostile Typedef allocation |
| `AngelscriptCacheRemainingRecordCoordinateTests.cpp` | 11 | four remaining record coordinate/DTO-shape RED contracts, including all-member position sentinels, forbidden Boolean overloads, exact-occurrence optional one-hot, pointer-free and root-specific preorder matrices; complete TU GREEN and independently approved |
| `AngelscriptCacheDecodedRecordDeclarationTests.cpp` | 1 | compile-contract proof that final per-kind storage/variant types are C++-private and the precisely friended codec bridge is empty/non-owning |
| `AngelscriptCacheManifestPackTests.cpp` | 26 | declaration-first pack/manifest goldens, full codec/range/local-invariant matrices, seven-kind reachability, combined-live cumulative Budget, prepopulated-output atomicity, source chronology and explicit completion-ordinal determinism; repaired exact-SHA independent rereview pending |
| `AngelscriptCacheValidationTests.cpp` | 3 | classifier and validation-result basics |

These are source definitions, not a GREEN count. The TypeSchema translation unit's
compile-repaired SHA remains under exact independent rereview after closing a Unity
macro-lifetime finding; its complete SingleFile TU is GREEN, while codec/link and
Automation remain open. The Remaining-record SHA and complete TU are independently
approved. The Manifest/Pack source is a repaired frozen author candidate whose
intentional first RED is the absent production header; its 26 definitions do not
become an approved Task 2.7 authority until fresh independent rereview closes the
first review's `3C/4I` gate.

## Isolated cache test-engine fixture

Engine-backed Cache tests SHALL use composition around the real engine rather than
restore the reverted inheritance design. `FAngelscriptTestEngine` remains a static
test helper; `FAngelscriptEngine` is not made polymorphic merely for tests.

`FAngelscriptCacheTestEngineFixture` will own one isolated real
`FAngelscriptEngine` plus Test-module implementations of Runtime-defined dependency
boundaries: in-memory store, source/current-layout resolvers, compiler and attachment
spies, StaticJIT provider, deterministic clock/executor/cancellation and fixed
caller-owned event/fault buffers. The fixture may expose `SharedModuleClean` by
delegating to the existing shared Full-engine pool for cheap language-only cases,
`IsolatedFull` through `CreateFullTestEngine` for compiler/attachment/StaticJIT and
two-engine isolation, and `ProductionLike` through the existing resolver for
editor/PIE lifecycle coverage. It SHALL NOT reintroduce the removed clone engine;
the surviving `*CloneEngine` helper names are compatibility forwarders to Full
engines, not a distinct engine model.

This fixture is not a second cache implementation. Every substitute is injected at
a production dependency boundary and must exercise the same controller, decoder,
budget, graph, publication and rollback path as the real subsystem. Pure wire,
Budget, pack/store and deterministic filesystem tests remain engine-free; engine
construction is reserved for behavior that genuinely depends on module/type/class
registration or VM/JIT attachment.

## Required unit-test shards

Large tests SHALL be split by ownership so a failure identifies one layer and the
normal suite does not acquire real-package cost:

| Layer | Dedicated coverage before its task closes |
| --- | --- |
| Identity and canonical wire | domain separation, byte goldens, malformed input, error precedence, exact offsets, alias safety |
| Budget and candidate ownership | charge-before-allocation, exact and one-byte-short Total/live/reference limits, overflow, move-only transaction, rollback and one-shot promotion |
| Seven-record decoded factory | every kind, wrong kind, trailing data, RecordId recomputation, one immutable owner, reachable-only retention, output-atomic failure |
| TypeSchema and layout | producer, physical, local semantic, derived-hash and current-layout stages; all coordinates; exact resolver call order; allocator-authoritative TS-SCR matrix |
| Module graph | missing/wrong/cross-owner references, deterministic precedence, reachable-only opaque validation, call counts and anti-O(n^2) lookup counters |
| Manifest and pack | byte goldens, corruption, overlap/range/order, codec canonicality, exact reachability and serial/parallel byte equality |
| Store transaction | every write/flush/close/reopen/rename/sync/pointer fault point, commit-state classification, Current/Previous/Pending recovery and reader pinning |
| Source invalidation | body/signature/type/global/options/provider/ABI mutation matrix, unchanged hit closure, module widening and safe miss reasons |
| Compiler and attachment | every builder family, not-cacheable unstable snippets, relocation completeness, rollback before engine mutation and per-function compile counters |
| Engine/editor lifecycle | first start, warm start, failed fresh compile, code-only reload, structural pending, PIE boundary, cancellation, shutdown deadline and two-engine isolation |
| StaticJIT bridge | provider absent/present/mismatch/removal and Native-versus-VM routing without invalidating valid Cache V2 data |

## Special-support interface rules

Special test support is permitted and expected when final output cannot prove an
internal invariant. Each seam must obey all rows below.

| Concern | Allowed seam | Forbidden shortcut | Integrity tests |
| --- | --- | --- | --- |
| Canonical allocation | explicit synchronous caller-owned fixed capture view | ambient/TLS/global observer or second decoder | disabled/enabled equivalence; zero/one/exact capacity; overflow; two callers |
| Eligibility scratch allocation | explicit per-query caller-owned fixed POD event view on the production internal path | reset/read process-global probe, growing observer storage or alternate query | unobserved/observed output and Budget equality; zero/one/exact capacity; explicit overflow; concurrent callers |
| Candidate/factory allocation | private charge/checkpoint sink on the sole factory transaction | public budget mode or test-owned decoded token | exact chronology; failure cleanup; single final promotion; observer non-escape |
| Wire/validation order | semantic-blind event view plus independent raw scanner | Runtime-supplied expected stage/offset oracle | fixed chronology; competing faults; exact captured offset |
| Opaque payload | production `IAngelscriptCacheOpaquePayloadValidator` spy | test graph parser or direct success injection | reachable exactly once; unreachable zero calls; failure tuple |
| Current symbols/layout | production resolver spies with fixed immutable maps | process-global fallback or authority not exposed by the interface | ordered at-most-once calls; cold-hit zero calls; two-engine isolation |
| Store/platform | production file/lock/atomic replace/directory-sync capability implementation | direct pointer installation or bypassed reopen validation | fault at every operation; old-or-new state; exact commit state |
| Time/cancellation/execution | production clock, cancellation and executor capabilities | sleeps, global clock mutation or hidden synchronous store path | deterministic deadline/race ordering; bounded completion; no cross-test state |
| Compiler/source work | production producer/preprocessor/compiler adapters with counters | fabricated cached success or direct module activation | exact zero-call warm hit and one-body one-compile miss |

Runtime capture adapters and private fault checkpoints compile only with
`WITH_ANGELSCRIPT_UNITTESTS` or live entirely in Runtime Private/Test code. They
must own no growing observer container, UObject, engine pointer or persistent
session state. Public validation/store enums are frozen and never gain a test-only
error. Platform/resolver/compiler interfaces are not test-only APIs: tests supply
substitutes to the same dependency boundary production uses.

## Mandatory seam-integrity cases

Every added seam must prove:

1. Observer absent and observer present return byte-identical output and the same
   public result, Budget counters and publication state.
2. Zero, undersized and exact caller capacity are safe; truncation sets an explicit
   overflow flag and never changes production behavior.
3. Two callers cannot receive one another's events; thread-affine components reject
   cross-thread mutation and thread-safe published handles remain read-only.
4. An injected private checkpoint unwinds Temporary/live state, leaves outputs empty,
   and maps to an already-frozen public outcome at the production boundary.
5. A non-test Runtime/Shipping build contains no capture/fault adapter symbol or
   observer storage and does not change production DTO/controller size.
6. Complete chronology comparison is linear. Representative allocation matrices
   freeze fixture, target and per-site counts so coverage cannot silently explode.

## Execution policy

- RED is captured with the smallest affected translation unit through
  `Tools/RunBuild.ps1`; a missing declaration is recorded separately from a genuine
  behavior failure.
- Focused Automation uses `Tools/RunTests.ps1`/suite wrappers only after the whole
  Test module can compile.
- The normal `Cache` suite owns unit and bounded Runtime integration groups. Store
  subprocess stress can have a separate bounded group. Real PIE and packages remain
  `CachePackage`/final acceptance and do not inflate unit-test timing.
- Source definition counts, discovered/executed counts, failures, skips, timeouts and
  exact report paths are recorded independently; source counts are never reported as
  passing tests.

## Risk-based omission audit — 2026-08-11

The current Cache test directory contains 94 C++ translation units and 518
`TEST_METHOD` definitions. This is a source inventory, not a claim that all 518
have passed in one run. The latest focused evidence for the class-graph vertical is:

- root UClass fresh restore and behavior execution: retained GREEN regression;
- base/derived UClass fresh restore and derived-to-base execution: `1/1` GREEN;
- mutually referencing reflected class properties: `1/1` GREEN, 20 records,
  2 restored types and 7 restored stable routes;
- complete TypeSchema archive prefix after reflected-name payload v2: `69/69`
  GREEN, including 56 allocation sites and captured coordinates 0..43;
- focused ObjectHandle dependency semantics: `2/2` GREEN;
- envelope-aware VM artifact corruption matrix: `1/1` GREEN with eight independent
  mutations and exactly one compiler fallback.

The next tests are ordered by the chance that a warm cold-start could publish a
plausible but wrong class/module, not by ease of adding another assertion.

| Priority | Risk / missing vertical | Existing evidence | Required next test and acceptance |
| --- | --- | --- | --- |
| Closed | Three-level script inheritance with an override can mis-wire inherited method ordinals or the VFT while a one-level non-override test remains green | IC-453/IC-455 now restore 35 records, 3 types and 14 routes; exact topology plus result `51` is GREEN | Retain `AngelscriptCacheClassGraphInheritanceRestoreTests.cpp` as the combined VFT/reflection/generated-name regression |
| Closed | Preprocessed `n"..."` and generated BlueprintEvent wrappers can retain a producer Engine StaticName index and crash in a fresh Engine | IC-454/IC-456 canonical lowering, generated wrapper, and dedicated fresh-Engine conflicting-index behavior are GREEN; the function restores 6 records/1 route, executes to `454`, and does not mutate the consumer table | Retain `AngelscriptCacheStaticNameRestoreTests.cpp`, the registered-callable missing-dependency negative and `Preprocessor.Literals`. Python deliberately keeps VM/string-constant payloads opaque per V2.7; C++ behavior/logs plus payload hash/codec/relocation diagnostics are the authority rather than duplicating a VM decoder in Python |
| Closed | BlueprintEvent/Override UE reflection names can differ from AS implementation names | IC-455 TypeSchema v2 exact three-name tuple, 69/69 TypeSchema and 24/24 Python tests, Base/Middle/Leaf lookup/dispatch GREEN | Retain distinct-name round trip, required-name negatives, allocation sites and three-level behavior regression |
| Closed | Cross-class parameter/return types can restore properties correctly but leave function signatures pointing at producer types | IC-459 fresh-Engine test restores 16 records, 2 types and 5 routes; producer/consumer VM types are distinct, restored input/return VM and reflected object properties are consumer-owned, complete reflected parameter inventories match, and the call returns the exact consumer Peer object | Retain `AngelscriptCacheClassGraphFunctionSignatureRestoreTests.cpp`; the focused run is `1/1` GREEN at `Saved/Tests/cache-ic459-single-owner-arguments-test1/20260811_163220_751_8be326e8`, and class-graph/property/inheritance/global/StaticName adjacency is `5/5` GREEN at `Saved/Tests/cache-ic459-adjacent-regression1/20260811_163319_462_bccda204` |
| Closed | Real UFUNCTION/UPROPERTY flags and metadata may be captured but not recreated exactly | V3.12 restores one 11-record class graph as 1 type/3 routes and compares the producer/restored descriptor, raw UClass/UFunction/FProperty flags, complete metadata maps, argument name/default/passing mode and reflected execution result `44`; an unsupported class-plus-native-delegate module returns typed `NotCacheable` with zero output artifacts and unchanged active Runtime state | Retain `AngelscriptCacheClassGraphReflectionRestoreTests.cpp`; the focused contract is `2/2` GREEN at `Saved/Tests/cache-v312-reflection-contract-test2/20260811_164406_516_ab218430`, and reflection/signature/inheritance/property/StaticName/global adjacency is `7/7` GREEN at `Saved/Tests/cache-v312-adjacent-regression1/20260811_164456_041_38066073` |
| Closed | A late failure after preparing a multi-class module could leak one UClass, descriptor, VM type or stable route | V3.13 captures one 22-record module containing two mutually linked reflected classes and eight stable functions, injects `AfterModulePrepared`, observes the one private staging VM module at the exact fault point, then proves the returned failure restores the exact active-module, raw VM-module, 11,756-entry VM object-type, UClass, descriptor and immutable route-publication snapshots; all eight stable keys remain unresolved and a same-name authoritative compile creates both cross-links and executes to `73` | Retain `AngelscriptCacheClassGraphRollbackTests.cpp`; focused behavior is `1/1` GREEN at `Saved/Tests/cache-v313-multiclass-rollback-test1/20260811_165555_279_fa8c98f3`, and the seven adjacent reflection/signature/inheritance/property/StaticName/global methods plus rollback are `8/8` GREEN at `Saved/Tests/cache-v313-adjacent-regression1/20260811_165651_953_9dc85d0c` |
| Closed | Type declaration order or TypeKey sort order may accidentally become a restore prerequisite | V3.14 compiles the same two mutually referencing reflected sibling classes in opposite source order. The source/debug graph changes, but ModuleKey, ModuleInterface, ModuleState, both TypeSchema records, eight StableFunctionKeys, declaration ABI, execution content and restored cross-links/results remain exact. Each fresh consumer restores 2 types/8 routes and executes `28/14`; only four moved DebugSidecars and their four owning FunctionBody records change | Retain `AngelscriptCacheClassGraphDeclarationOrderTests.cpp`; the original RecordId RED is `0/1` at `Saved/Tests/cache-v314-declaration-order-test1/20260811_171001_478_b942c11b`, the corrected focused behavior is `1/1` at `Saved/Tests/cache-ic462-declaration-order-fix-test2/20260811_172131_657_8aa2fcd0`, and declaration-order plus eight adjacent restore/rollback methods are `9/9` GREEN at `Saved/Tests/cache-v314-adjacent-regression1/20260811_172243_716_bf94f918` |
| P1 | A target class layout-only change could still over-invalidate a holder through another dependency path | TypeSchema unit proof now distinguishes ObjectHandle Declaration/EnvironmentAbi from InlineValue ValueLayout | Extend the clean-oracle mutation shard: change only target layout and prove handle holder TypeLayout/Function bodies remain reusable; add an inline-value control that must invalidate |
| P1 | User globals/static data in a class-graph module may be rejected or incompletely restored | Generated `StaticClass` global is covered; standalone global/enum restore is covered separately | Add explicit admission tests for class plus user global/static property/initializer. If unsupported, require deterministic `NotCacheable` with no partial records; if admitted, prove initialization and shutdown cleanup in a fresh Engine |
| P1 | Interfaces, delegates, structs, enums and class mixtures can be schema-valid while the live restorer only supports a subset | TypeSchema/graph unit matrices and standalone enum restore | One bounded admission matrix per type family: either exact fresh-engine materialization and behavior, or an explicit safe miss before mutation. Never silently drop a type record |
| P1 | Template/container properties and handles can hide nested type dependencies | Environment inline-value schema and ObjectHandle direct target tests | `TArray`/`TSet`/`TMap` or AS template controls for supported forms; prove nested local/external dependency ownership, or stable `NotCacheable` diagnostics for the unsupported route |
| P1 | Reopening/restoring repeatedly may accumulate stale FunctionId routes or collide across isolated engines | Two-engine parity and current route snapshots exist | Restore the same generation into multiple fresh engines and across repeated fixture lifetimes; assert stable keys equal, numeric IDs are engine-local, route counts do not grow, and destroying one engine cannot affect another |
| P1 | Corruption diagnostics may identify a byte offset but not the semantic type/function/property owner | Schema-3 diagnostics, Python correlation and VM corruption details exist | Corrupt one class relation, one property target ABI, one method owner and one VFT implementation owner; require exact record/type/property/function correlation in C++ JSON and Python dump output with zero activation |
| P2 | Whitespace/comment-only edits can cause unnecessary recompilation | Canonical token/source and clean-oracle tests cover related cases but not the final real store | Real-store cold/warm edit test: CRLF/LF, spaces and comments preserve semantic records/function keys; debug-source changes affect only the intended debug coordinate |
| Final | Editor startup, PIE transition and packaged multi-launch may expose lifecycle/file-staging faults absent from isolated engines | Bounded Editor/PIE lifecycle automation exists; real package gate intentionally deferred | Run real Editor cold/warm/close-flush, PIE, Development and Shipping cold/warm/edit/invalid/structural multi-launch last, inspect the generated store with Python dump/diff/verify, then benchmark |

### Test-file placement for the remaining verticals

Do not add the rows above to `AngelscriptCacheTypeSchemaTests.cpp`. Keep that file
as the exhaustive local wire/schema authority. Use the existing focused
`AngelscriptCacheTypeSchemaDependencyTests.cpp` for dependency-kind unit rules and
`AngelscriptCacheClassGraphPropertyRestoreTests.cpp` for the current two-phase
property vertical. Put inheritance/VFT, reflection metadata, rollback and clean-
oracle invalidation in separate translation units named in the table. Shared pack
reopen helpers may move into a small Test-private helper only after a second file
needs the exact same code; the helper must not reproduce production validation or
restore logic.

### IC-451/IC-452 evidence

The mutually referencing class test first failed at capture, then at dependency
closure, then at deterministic layout replay. The final diagnostic exposed
`Type=UCacheV2GraphPropertyLeft size=56 alignment=8 base-boundary=48` and a bogus
`Right offset=48 size=64 alignment=8 storage=2`. The fix uses the profile-owned
8-byte ObjectHandle slot, ScriptType Declaration / EnvironmentType EnvironmentAbi
target authority, and all-type-skeletons-before-properties restore. Official
evidence is recorded in `implementation-issues.md` under IC-451/IC-452.
