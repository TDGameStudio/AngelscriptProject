# Query and ownership acceptance matrix

Historical matrix written against Image-owned TypeInfo. After replan-20260910-182000, publications are BindInfo records, Image is unique/discarded, and A/B have distinct TypeInfo pointers with the same ID. Task IDs in the table are superseded (see 7.2-7.7). Keep literal Pair 20/22/42.

| Query/input | Scoped external publication | Admitting Engine | Rejection/lifetime rule | Task/case |
| --- | --- | --- | --- | --- |
| Pair published numeric ID | Original Pair before an Engine exists | Same pointer/ID in A/B | Unknown ID returns empty | 2.1 DetachedPair; 3.1 Shared |
| Pair typed ID with its publication generation | Retained metadata lease | Accepts admitted publication generation | Wrong generation rejects even with a valid numeric ID | 2.2 Negative/Retained; 3.1 Shared |
| A's ScriptThing ID | Not visible | A resolves; B rejects | Retired A ID cannot resolve a new type | 3.1 Private; 4.2 FinalLease |
| int32 fixed ID | TypeInfo is null; type-use resolves int32 | Same primitive contract | Never manufacture a nominal primitive object | 2.2 PrimitiveAlias |
| enum Mode and typedef Counter=int32 | Own published objects/IDs; alias target int32 | Same admitted graph | Preserve alias identity separately from canonical target | 2.2 PrimitiveAlias |
| Obj@ and const Obj@ | Underlying Obj plus legal use qualifiers | Same, only if admitted | Const-handle without handle and reserved bits reject before masking | 2.2 Qualified/Negative |
| const Pair& type use | Canonical use preserves qualifiers absent from int IDs | Same explicit type environment | No silent loss or invented integer qualifier bits | 2.2 Qualified |
| namespace-qualified name/key/declaration | Exact published definition | Exact visible definition | Unqualified ambiguity is an error | 2.2 Pair/Negative |
| Pair fields X/Y and Sum() | int32 IDs, actual offsets, zero parameters, int32 return | Same definition | No provider execution or Engine creation | 2.2 Pair/Signatures |
| Constructor/factory/behaviour/method overload | Exact original callable and signature | Definition plus Engine-local binding | Query is not execution authorization | 2.2 Signatures; 4.1 Admission |
| Bases/interfaces/callable signature | Complete retained graph | Same admitted graph | Foreign equal-key object does not grant membership | 2.2 Pair; 3.1 ForeignDataType |
| Prebuilt concrete array/native generic | Same complete external specialization | Reuses pointer/ID | Signature/layout mismatch rejects | 3.2 Prebuilt |
| Missing array<ScriptThing> declaration query | NotFound; no mutation | NotFound until private compilation publishes it | Query never materializes the type | 2.2 Negative; 3.2 PrivateArray |
| Private source-generated specialization | Absent | Only receiving Engine | Publication cannot depend on a private argument | 3.2 PrivateArray |
| FunctionId and parameter/return IDs | Queryable before Engine | Shared definition, independent executable/native binding | No legacy array-index interpretation | 2.2 Signatures; 4.1 SymbolicReuse |
| GetEngine on external definition | Null | Still null | Execution uses receiving Context/Engine | 4.1 NativeOwners/Admission |
| Retained type/method after private retirement | Existing lease remains readable | Fresh lookup unavailable | No prepare, execution or reattachment | 4.2 FinalLease |
| Enumeration during publish/retire | Immutable publication snapshot | Complete published snapshot | No half-batch visibility | 3.1 Atomic; 4.2 Concurrent |

Raw integer APIs retain borrowed-return compatibility. AcquireType must validate and AddRef under the same owner snapshot; raw pointer retention across teardown is not made safe retroactively. TypeUse queries carry non-integer qualifiers. Runtime IDs are never durable cache keys.


## Global asCTypeIdRegistry queries

The table above describes scoped views. These additional rows define host-only global inspection; all are future proofs.

| Input/action | Global retained result | Engine/view result | Task/case |
| --- | --- | --- | --- |
| External Pair ID before any Engine | Original Pair pointer with one owned AddRef | No Engine needed | 2.4 GlobalQueries.Detached |
| A's live private type or function ID | Original A declaration with one owned AddRef | A accepts; B rejects even with that reference | 3.1 Admission.GlobalPrivate; 4.1 Admission |
| Equal names/keys in two publications | Distinct IDs resolve distinct objects | Names resolve in the explicit view | 2.4 GlobalQueries.Scopes; 3.1 Private |
| Retired or unpublished numeric ID | NotFound, null output | Unavailable; never another object | 2.4 GlobalQueries.RetireRace; 4.2 FinalLease |
| Valid ID with wrong generation | WrongGeneration, empty output | No membership implied | 2.4 GlobalQueries.Invalid |
| Primitive ID / legal handle ID | Primitive: NotFound/no TypeInfo; legal handle: underlying type with one owned AddRef | Primitive storage through scoped ResolveTypeId | 2.4 GlobalQueries.Invalid |
| Type use/name/key lookup without a view | No global single-result API | Requires publication/Engine and TypeContext | 2.2 Queries.Qualified/Negative |
| Acquire while retirement starts | Valid pinned graph before boundary or unavailable after | Existing execution drains on its owner | 2.4 GlobalQueries.RetireRace; 4.2 Lifetime.GlobalRetire |
| Last authority and last metadata lease release | Directory entry removed, then graph memory releases exactly once | No Engine kept alive by Registry | 2.4 GlobalQueries.NoCycle |

Global APIs return status plus AddRef-owned references, never borrowed pointers. Null-input failures leave Out null. A non-null Out returns InvalidArgument before ID lookup, preserving its pointer and reference count; the caller retains its Release obligation. The integer-only overload is safe against ID reuse because runtime IDs never recycle; the typed overload additionally authenticates publication generation. Global lookup validates every encoded bit before normalization and rejects a type-kind mismatch. Allocator lock protects only numeric reservations; directory lock protects visibility and graph pinning. Neither operation makes a mutable Image safe for concurrent construction.

## Creator-owned registration and release

| Operation | Observable contract | Proving owner |
| --- | --- | --- |
| Host Register(Image) | Existing frozen graph, IDs available with zero Engines; repeat preserves IDs | 2.1 CreatorOwned |
| Host Unregister with attached Engine/dependent registration | InUse; graph/IDs/visibility unchanged | 3.1 HostWithdrawal |
| Unregister with only query references left | Success; new lookup unavailable, old AddRef-owned reference readable | 2.2 ReferenceBalance; 2.4 WithdrawalRace |
| Acquire success/failure | Success adds one reference, caller Release; null-input failure leaves null output; non-null output is rejected unchanged | 2.2 ReferenceBalance |
| Private Image passed to host Unregister/Register | Ownership/state rejection; only owning Engine retires it | 3.1 HostPrivateDependency |
| Metadata versus object cycle collection | Owner/refcount releases Image; each Engine GC handles its instance cycles | 4.2 MetadataAndObjectGC |

No TypePublication owner or custom query-handle class is required. Internal registration controls retain generation/state, and old names in historical talks/replans do not describe the current API. Existing scoped borrowed APIs still require a protected owner lifetime.

Registration closure and release details: each newly registered Image has its own generation; already-live dependencies preserve theirs. GlobalQueries.OverlappingClosure/Publication.Closure prove shared dependency registration. GlobalQueries.RejectedAcquireRelease and RollbackRelease cover last temporary-owner destruction on failure, after all directory/owner locks are released. Image owns its internal ID/control record; Registry reverse references are weak.
