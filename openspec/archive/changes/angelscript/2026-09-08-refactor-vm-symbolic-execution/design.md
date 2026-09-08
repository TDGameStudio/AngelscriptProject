# SDK VM Symbolic Execution Design

## 1. Accepted Boundary and Current Evidence

The first cache mode is **pre-registered definitions plus cached executable code**. It is not a definition loader. Types, global/method/constructor/destructor/native callable declarations, and globals with storage must already exist in the destination Engine. Cached full signatures authenticate those declarations; no global-function exception silently creates missing declarations. Body conflicts fail rather than replace existing code.

Retain `asCScriptEngine` as the runtime owner of registration, executable bindings, Contexts, allocation and GC. Remove the execution prerequisite on Builder, source compilation, legacy module state and ambient UE services. UE foundational containers and atomics remain permitted. The real interpreter is adapted; there is no toy VM, Engine clone, nested `frontend` namespace, or second metadata authority.

The initial, pre-implementation coupling inventory is retained in `attachments/data/runtime-dependency-inventory.md` as historical provenance, not current runtime status. The maintained Context/interpreter, native callbacks, symbolic cache and bounded source producer now execute real tests. The fixed snapshot in the indexed External Review records the current gaps; two historical 704/704 reports prove their actual named cases, without a complete source/binary digest manifest. Remaining acceptance follows sections 10-11 and tasks 6.1-11.3; original completed evidence is not discarded.

## 2. Identity and Compatibility

| Value | Question answered | Authority and lifetime |
|---|---|---|
| `asSStableKey` (32 bytes) | Which nominal declaration, full type use, or callable? | Existing versioned canonical identity registry; known when the object is created |
| `asSSchemaHash` (32 bytes) | Is the definition's semantic contract unchanged? | Authenticated frozen metadata; target-independent local schema |
| `asSLayoutHash` (32 bytes) | Is its physical storage compatible on this target? | Authenticated frozen metadata plus explicit target/storage ABI |
| `asSByteCodeSymbolSlot` | Which requirement in this image? | Compact image-local ordinal, never global identity |
| executable binding slot | Which live runtime resource can this instruction use? | One Engine-owned snapshot and its execution lease |
| runtime type/function ID or pointer | Which object in this live Engine? | Current Engine registration only; never persisted |

`asSSchemaHash` and `asSLayoutHash` are thin distinct digest values using existing BLAKE3/canonical encoding infrastructure. They are not new type-description graphs. `asCTypeInfo::TryGetSchemaHash` and `TryGetLayoutHash` delegate to their owning metadata image; success supplies a digest and retained canonical witness. Failure clears the output and returns a typed status. Proposed statuses distinguish NotReady, UnauthenticatedDefinition, InvalidDefinition and UnsupportedTarget.

Preserve existing `Freeze()` acceptance, including low-level shell fixtures. A caller-supplied nonzero key is not identity authentication. Fingerprinting requires complete canonical identity, definition, layout and access validation. Building, Attaching, incomplete and tampered definitions cannot obtain a successful new fingerprint. Retired immutable metadata may be inspected if authentic, but cannot link or execute. Existing `IsFrozen()` means `State != Building`; never use that predicate alone as executable admission.

The full hash-input contract is in `attachments/data/fingerprint-contract.md`. In brief:

- Schema includes kind, semantic flags, owner/base/interface/generic relations, ordered fields with full qualified TypeUse and access, enum values, typedef targets, method and behaviour membership, full return/parameter contracts, parameter modes, relevant function traits, and supported list/access contracts.
- Ordinary FunctionKey intentionally excludes return type. Schema and callable binding therefore include the complete signature independently; comparing method key sets is insufficient.
- Layout includes explicit target ABI version, pointer size, byte order, primitive/float representation, object storage ABI, payload size/alignment, base/by-value dependent layouts, actual member addressing and offsets. Native call ABI is checked with the callable requirement, not a raw address hash.
- Exclude runtime addresses/IDs, refcounts, registration order, function bodies, debug/source positions, container memory images and mutable caches. Preserve field declaration order; sort semantically unordered sets by canonical stable identity.
- Local schema uses referenced keys, not recursively embedded schema hashes. The cache includes a sorted dependency requirement closure. Layout recursion follows base/by-value edges only; handles/references use pointer representation. Invalid value cycles fail explicitly.

Digest equality is an accelerator. Canonical witnesses, versions and domains remain the final equality check. Link admission revalidates the actual frozen definitions, including mutable legacy-exposed fields, instead of trusting a previously cached digest.

### Native member addressing

Add `asCMetadataImage::DefineNativeProperty(Owner, Name, Type, Address, OutProperty)` and `asSNativePropertyAddress` on the existing property graph. Preserve `SetNativeLayout(sizeof(T), alignof(T))`; `FinalizeLayouts` validates native offsets rather than replacing them with AS sequential packing.

`Address` is a tagged Direct / CompositeInline / CompositeIndirect value. Direct stores an owner-relative offset. Composite modes store an owner-relative composite offset, the canonical composite storage type, and a member offset; indirect additionally requires pointer representation and a checked runtime null path. The descriptor is stable data, never a C++ accessor pointer. Link validates each storage segment against its actual type/layout and checks arithmetic, containment and declared alignment. Direct declared members cannot overlap. A packed native declaration requires an explicit supported packing policy; unsupported packing rejects rather than silently accepting unaligned access. Null indirect bases raise a VM exception before access.

Registration is atomic: wrong owner, duplicate member, incomplete type, offset overflow, out-of-bounds extent, incompatible alignment/address mode, overlap or frozen mutation leaves the definition unchanged. Actual C++ `sizeof`, `alignof` and `offsetof` fixtures prove padding and member access; a matching declared total size alone is not proof.

## 3. Independent Producers and One Execution Boundary

The metadata-only layer uses actual image-owned types/functions, not mocks. Factories remain the only construction route; a shared test fixture owns the canonical identity context and image, with no hidden Engine. External type/function AddRef leases retain the graph, not callable runtime services. Atomic refcounts do not permit resurrection from an expired raw pointer or concurrent unsynchronized draft-field writes.

```text
No AS Engine
  manual real Type/Function definitions       AS source
    -> canonical identities + frozen image     -> current Builder / sealed AST
    -> typed bytecode image builder             -> canonical AST emitter
                   |                                      |
                   +--------------+-----------------------+
                                  v
                         same symbolic image
                         verifier / codec / dump
                                  |
Runtime owner required            v
  independently supplied definitions -> explicit Engine registration
  image + native/global bindings     -> transactional link
                                      -> snapshot + execution leases
                                      -> real Context / interpreter
```

Definitions and executable bodies have separate ownership. A frozen class is not reopened to install methods; methods were declared before freeze, while the snapshot attaches executable bodies externally by their authenticated function identity. Every body must bind to a pre-existing compatible declaration. String constants are image resources; global addresses/storage come from explicit current Engine bindings. No cached heap, global value, suspended frame or definition construction recipe is included.

### SDK interfaces and handoffs

The implementation uses the existing AS namespace and establishes these interfaces (precise C++ overload spelling may follow existing result/container conventions without changing their contracts):

```cpp
asCByteCodeImageBuilder;     // No asCBuilder or Engine constructor argument.
asCByteCodeImage;            // Immutable, Engine-free code + requirements.
asCByteCodeImageCodec;       // Encode / Decode / Dump.
asCByteCodeVerifier;         // Validate image structure and frame contracts.
asCExecutableSnapshot;      // One Engine's immutable executable bindings.

// Typed operations: declaration identity is not a parsed signature string.
Builder.AddRequirement(CanonicalRequirement, OutSymbolSlot);
Builder.BeginFunction(FunctionKey, FullSignature, FrameDescriptor);
Builder.NewLabel();
Builder.BindLabel(Label);
Builder.Emit(Opcode, TypedOperands);
Builder.EndFunction();
Builder.Finish(OutImage);

Engine.BindNativeFunction(FunctionKey, FullSignature, NativeBinding);
Engine.BindGlobalStorage(DeclarationKey, FullTypeUse, StorageBinding);
Engine.LinkByteCodeImage(Image, OutSnapshot);
Engine.CreateContext();
Context.Prepare(Snapshot, FunctionKey);
```

ImageBuilder emission uses the maintained opcode vocabulary and declared operand schema, with labels, checked immediates, local/frame locations and typed symbol slots for types, full type uses, functions, properties, globals and strings. `Finish` rejects incomplete labels/bodies; a missing implementation never returns successful empty executable output. It does not wrap old `asCByteCode(asCBuilder*)` with a fake Builder.

The snapshot prepares actual interpreter operand forms and direct checked slots once. Hot dispatch must not query a locked metadata map or decode stable strings every opcode. Runtime numeric IDs remain usable through checked Engine APIs, but metadata IDs are never interpreted as legacy array indexes. Native binding stores live Generic/typed `asFunctionCaller` entries, call convention, return/argument lowering and lifetime ownership; function addresses do not enter any canonical hash.

The builder consumes authenticated canonical definition witnesses for requested roots, traverses their referenced identities and emits the complete deduplicated requirement closure. Missing witness input fails before Finish. The verifier independently traverses the serialized witnesses to reject a removed indirect requirement; the linker compares every admitted requirement against the actual destination definitions. An A-to-B handle edge therefore detects a changed B schema even if A's own fingerprints remain unchanged. Function bodies and their side tables are canonically ordered as well as symbols, so function discovery order cannot change encoded bytes.

### Complete versioned image format and verifier

Use an explicitly versioned, length-framed little-endian wire format. Header fields identify format version, maintained SDK opcode ABI, target architecture/endianness/pointer width and object/call storage ABI. Cross-target loading remains rejected, even though stable identity and semantic schema may agree. Follow-up 6.2 advances the incomplete FormatVersion=1 wire to version 2 to encode the complete accepted witnesses/frame/unwind/source contracts; old version 1 is rejected explicitly. This wire revision does not change the selected cache mode one.

Sections contain canonical symbol requirements/dependency closure, complete body signatures, opcode bodies with typed image-local operands, label-resolved instruction boundaries, frame/stack descriptors, local object live ranges/cleanup and exception/unwind metadata, optional source/debug locations, and string constants. Encode only declared fields, never raw C++ struct images. Equivalent inputs receive deterministic symbol ordering and remapped operands. Resource counts, byte extents, recursion and stack budgets are bounded with checked arithmetic; decoder failure exposes no partial image.

Each type requirement has role, canonical identity witness, expected schema/layout witnesses and hashes where relevant, plus explicit target/storage requirements. Full TypeUse requirements resolve qualifiers/arguments through the existing identity context. Ordinary nominal types resolve by TypeDeclKey; template instances use their complete unqualified specialization identity. Primitive uses resolve to configured primitive storage, not a fictional ObjectType. Property requirements authenticate owner/name/full type/address contract. Callable requirements authenticate owner/kind/full signature/native ABI; globals authenticate declaration/type/storage contract.

Verifier admission covers known runtime opcodes, operand widths/roles, symbol bounds, jump targets on instruction boundaries, frame/local/argument ranges, control-flow stack shape, return/call contracts, local-object construction and unwind records, and required symbol closure. Reserved/compiler-only/retired instructions, corrupt lengths, mismatched roles and invalid cleanup all fail before publication. Host native callbacks remain trusted: this structural/type verifier is not an untrusted-code security sandbox.


### Canonical AST bytecode producer

Add an explicit asCByteCodeEmitter consumer, not another Builder, semantic AST, parser or interpreter. Builder remains independently constructible and its default RunThrough endpoint remains DefinitionsFrozen. The producer requires the current session's verified/sealed AST, no errors/recovery, and matching authenticated frozen definitions. It consumes body work items/fragments, typed expressions/statements and lifetime facts through their actual APIs. AST serialization/dump text is not a semantic input.

The emitter returns a typed asSByteCodeEmissionResult: status, an owned immutable image only on success, and diagnostics through the existing asCDiagnosticsEngine. Inputs are the asCCompilationSession, its frozen asCMetadataImage and explicit target options; no Engine constructor argument. NotReady/InvalidInput/UnsupportedLowering/resource failures publish no partial image. Source diagnostics use the current diagnostic infrastructure and owned location data; the separate advanced-diagnostics Change is not a prerequisite.

Each body work item's StableFunctionKey selects the existing frozen asCScriptFunction declaration. The producer adds requirements and emits maintained instructions through asCByteCodeImageBuilder, then the same verifier. Source ranges, string constants and diagnostic/debug observations needed after emission are copied into owned image data; AST/session/Builder addresses never survive in the executable. Tests release producer inputs before linking.

Code generation reads selected callees/members, full TypeUse and explicit conversions from the AST. It maintains emitter-private value/address results, frame slots, labels and initialization/cleanup state; these are lowering state, not a second semantic type or AST authority. Preserve single evaluation of writable bases and argument expressions. Map named/default arguments to formal positions, then evaluate last formal to first for AS/native/constructor calls. Current local DefaultArgumentExpr refers to a typed Parameter initializer after AST verification: evaluate that initializer at each call site, never reparse its string or cache its runtime value. External defaults require the existing typed-default contract; metadata default strings alone are insufficient.

Historical task 5.4 added constructor source-ordinal work. Follow-up 10.3 retains that work, verifies full formal/source/default mapping and completes any missing canonical constructor projection/codec/verifier checks, while keeping evaluation order explicitly reverse-formal. Inspect the current wire version before further payload changes; do not assume the original version-7 observation remains current. A zero-argument implicit construction or same-type implicit copy may have no constructor declaration; lower the corresponding supported storage operation, not an invented FunctionKey or post-freeze method. Receiver-relative call ordering must follow the maintained AS semantic authority and be established with a trace before expanding source cases that depend on it.

Current asCBodyLifetimePlan records selected nominal-local cleanup obligations for return/break/continue; it is not complete executable unwinding. Follow-up 10.4 owns lexical and transfer live-object destroy. Follow-up 10.5 owns exceptional source cleanup end-to-end: emit Normal versus Exception path records from typed AST plus those obligations, remap cleanup TypeSlots at image Finish, copy objVariablePos/Info/Types/objVariablesOnHeap and source lineNumbers at link, run CleanStack before Execute returns EXCEPTION, and invoke SCRIPT destructors from metadataBehaviours with SDK heap asVmRelease. 8.3/8.5 prove object domains and Context limits; they do not close source-emitted exception unwind. Preserve the for-initializer versus loop-body scope distinction; clean only initialized values, in reverse order. Test actual destructor/refcount effects rather than equating an AST plan with executed cleanup.

The bounded source matrix is attachments/data/source-execution-matrix.md: expressions and storage, structured control and lazy branches, script/native/reference calls, basic AS objects and cleanup, then source-produced cache execution. Full maintained opcode semantics remain required independently. Valid source beyond the matrix (including lambda/delegate generation, user operators, foreach/list initialization, generic instantiation and complex global initialization) fails explicitly rather than quietly producing incomplete code. Native field syntax is not implicitly added to the current frozen host semantic view; basic source interop uses explicit native calls while direct VM tests prove native property addressing.

Clang is a code-generation architecture reference, not this fork's language semantics. Local LLVM 22.1.8 CodeGen uses typed AST visitors, distinct value/address emission, conditional RHS blocks, loop-specific jump destinations and branches through cleanup. Adopt those responsibilities with AS bytecode labels and frame/unwind records; do not introduce LLVM IR or an LLVM dependency. Source anchors and the AS reverse-formal counterexample are retained in the source matrix.

## 4. Link and Publication

```text
Decoded image + registered definitions
    -> validate ABI, requirements, actual frozen witnesses and ownership
    -> resolve every type / callable / property / global / string
    -> prepare slots, frames, cleanup, native calls, and resource leases
    -> one checked atomic publish
    -> new contexts may execute

Any pre-publish failure -> discard candidate resources -> Engine unchanged
```

Require a live owning Engine and explicit Attached definitions before binding. A caller may register valid Frozen definitions through the existing separate transactional registration API, but linking does not implicitly attach images, invent declarations or attach foreign/retired metadata. Revalidate ownership/generation at commit under the Engine's publication synchronization; a concurrent shutdown or conflicting body cannot publish half a candidate.

Errors distinguish malformed image, unsupported format/target/opcode, identity collision or wrong role, missing declaration, schema/layout/call mismatch, missing native/global binding, foreign/retired metadata, body conflict, and resource failure. Include the offending stable symbol, role and expected/actual contract, not only raw IDs. No callable replacement, global write or binding visibility change occurs on failure; temporary allocations and retained leases are balanced. Already installed body conflicts fail even if bytes match; no implicit hot reload or hidden idempotent replacement.

The same symbolic image can bind to two Engines only through independently created equivalent definition images and separate snapshots. Equal keys/hashes do not permit sharing one attached metadata graph. Destroying Engine A never makes B depend on A's pointers or ID assignments.

## 5. Real SDK Runtime and Object Storage

Restore the real `asCContext` interpreter over snapshot bindings, keeping SDK-only scalar/script-call preparation functional before adding the object/native families. All existing function parameter/return widths, stack setup and cleanup requirements must be supplied directly; code bytes alone are insufficient.

SDK AS heap objects use an allocation-owned header before an aligned payload:

```text
allocation base                                  exposed object pointer
      |                                                   |
      v                                                   v
 [ SDK header | alignment padding / recovery data ] [ payload fields ... ]
   dynamic Type*, atomic ref/weak state, owner/lease        field offset 0
```

Keep metadata field offsets payload-relative. Inline by-value objects use payload layout without an independent reference header. Allocation bookkeeping lets SDK object APIs recover the header/dynamic type safely; never probe arbitrary native/UObject memory for a speculative header. Ordinary native values/objects remain caller or registered-behaviour owned, with no inserted AS header. The SDK path does not consult the UASClass raw registry, UASStruct lookup or global UObject fallback. Narrow Core public object-method routing belongs to this Change; no UE subsystem reactivation follows.

Implement construction/copy/assignment/destruction, inheritance/interface conversion, funcdefs/delegates, refcount/weak-reference behaviour and cycle GC against the actual frozen metadata. Partial construction unwinds only initialized members in reverse order and releases all temporary references. Native operations use explicit registered behaviours and caller storage/lifetime; ownership is never guessed from a C++ pointer. GC enumerates actual metadata-owned fields/delegate captures and preserves external/live Context roots.

Supported native calls are the maintained Win64 Generic and typed `asFunctionCaller` routes, including supported global/member/object-first/object-last shapes, primitive/object returns and reference parameters. Historical platform assembly backends remain disabled. Unsupported conventions are rejected with explicit tests; their cases are not skipped and counted as semantic coverage.

## 6. Context and Shutdown Lifetime

Contexts hold snapshot/code and metadata leases for Prepare, Execute, suspension and cleanup. Metadata leases preserve readable objects; only a live snapshot plus its Engine execution lease preserves callable bindings. SDK exceptions, suspend/resume/abort, reprepare, stack limits, nested native callbacks, thread-local active context and independent multi-context operation must work without UE settings, WorldContext injection, Blueprint guards or DebugServer startup.

```text
Engine Running
  -> stop new link / prepare / execution admissions
  -> request active contexts abort at safe points; drain active calls
  -> unwind contexts and objects while native/code/type bindings remain live
  -> collect/release Engine-owned objects and snapshots
  -> retire metadata bindings and numeric IDs
  -> release Engine owner (external metadata may remain readable)
```

Do not wait synchronously for the current native callback to exit from inside itself. Shutdown requested by an active callback returns a deferred/pending disposition; final destruction completes after its execution lease leaves. Stalled host callbacks cannot be forcibly killed safely. Teardown does not retire IDs before destructors/GC. Exceptions during cleanup are reported without double destruction; abort is not successful normal completion. Live externally retained runtime objects keep required runtime ownership until explicit release; retaining plain metadata alone never permits post-retirement execution.

## 7. Opcode Coverage Decisions

The current public enum assigns 213 runtime values (0..212). The inventory in `attachments/data/opcode-inventory.md` maps every one to a task and evidence obligation, not a claim that its existing case is usable.

| Instruction | Accepted disposition |
|---|---|
| `STR` (60) | Retired; builder/decoder/verifier reject explicitly |
| `CALLBND` (62) | Bind a stable callable slot for script/native/delegate targets; do not restore source `import` |
| `DestructScript` (202) | Implement script destruction and instruction-pointer advance; current commented body is not a no-op contract |
| `JitEntry` (175), `SaveReturnValue` (210) | Preserve VM marker/no-op behaviour and advance; no JIT backend |
| `ResolveObjectPtr` (204) | Explicit optional SDK host callback; checked no-op when absent |
| `TrackRef`, `UntrackRef`, `ValidateRef` (206..208) | Explicit SDK reference-debug policy/callbacks and deterministic disabled behaviour |
| Reserved 213..250; compiler pseudo 251..255 | Reject as executable instructions; assembler labels are separate authoring objects |

The remaining instructions require actual interpreter cases with independent numerical/state/callback oracles. Shared handler implementations do not excuse unrepresented opcode variants. Source-level `try/catch` and removed `asset`/`import` syntax remain outside the source producer. A bounded canonical AST compiler now feeds this same bytecode capability; full source-language coverage is not inferred from complete VM opcode coverage.

## 8. Tests, Migration and Risk Control

Use existing replacement CQTest under `WITH_ANGELSCRIPT_TESTS`; keep legacy `.ubtignore` and `WITH_ANGELSCRIPT_UNITTESTS=0`. VM fixtures explicitly own minimal SDK Engines and definition images per scenario; frontend common support must not gain an ambient Engine. Store VM-only helpers under `NewVersion/NativeEngine/VM/NativeVMTestSupport.h`. Detached definition helpers live separately under `Definitions/NativeDetachedDefinitionTestSupport.h`; source-execution orchestration lives under `Compiler/NativeSourceExecutionTestSupport.h`. Tests show the actual create/emit/register/link/execute sequence in each method. Source generation and structural checks still create no AS Engine; execution creates one explicitly.

Borrow behavioural expectations from the dormant native SDK corpus, not its source-compiling helpers. Direct VM test methods visibly construct definitions, assemble instructions, link, execute and assert; source tests use the current Builder and new emitter without legacy module entry points. Detached tests assert real metadata relations, fingerprints and lease release without execution. Hash/map lookup, successful encoding or an unexecuted instruction is not VM proof. Use CQTest `IsNear` for approximate floats or explained exact `IsTrue(Expected == Actual)`; never floating-point `AreEqual`.

Nineteen bounded feature groups carry their concrete cases, RED conditions, files and handoffs in `tasks.md`. For missing APIs, add only compile-enabling declarations or explicit unavailable seams before runtime RED as allowed by TDD; compilation success is not behavioral GREEN. Compatible Ready work can share builds and test processes with exact case maps and frozen source/binary identity. Do not implement the entire subsystem first and call one final run TDD.

Risks include native offset corruption, wrong function table domain, object-header/payload mismatch, cycles in hash or runtime ownership, incomplete unwind records, partial link mutation and teardown-before-destructor. Each has a negative or lifetime oracle in the owning task. Full VM semantics make this a substantial Change despite the completed initial implementation; no scalar-only completion is acceptable. Ordinary defects stay task-local; a disproved boundary, required ABI or missing product prerequisite requires an evidence-backed Replan before expanding pending ownership.

No legacy compiler/cache entry point is enabled. The new explicit emitter is the only source-to-bytecode addition; Existing implemented SDK APIs remain available; a new unimplemented boundary reports a typed unavailable status rather than returning a fabricated successful artifact. Rollback before publication discards a candidate. Product rollback preserves frozen metadata and existing dormant startup instead of loading legacy modules as a fallback. Final verification covers NativeEngine plus the separate Baseline dormancy selector because shared type/function/Context contracts changed; Standalone, JIT, UE reflection and unrelated Harness aggregates remain excluded.

## 9. Planning and Future Closure

Creation, the acceptance-gap Replan and the progress-residual Replan run strict Change validation and DAG mapping. Completed nodes stay checked; 6.4 and 7.1 point to 6.5 and 7.3 with needs_followup. 8.3 is serial after 7.3 because they share Context, snapshot and Engine writers. Both user-requested External Reviews remain open, not resolved by task assignment. Two new capability manifests are created through the portable CLI only during eventual spec synchronization. Future completed closure requires actual task evidence, current-spec synchronization, attachment dispositions and the existing terminal gate.

## 10. Acceptance-gap implementation decisions

The fixed-snapshot Review identifies missing guarantees already required by the five capability deltas. Requirements stay unchanged; the invalid artifacts are the over-complete task/evidence state and insufficiently executable remaining ownership boundaries. The acceptance-gap matrix maps every finding and historical residual Case to its new owner.

### Canonical image and typed verification

Extend existing requirement/body types instead of adding a parallel type graph. Carry role-tagged canonical identity, schema/layout witnesses and full qualified callable signatures, modes and native traits; FunctionKey still does not authenticate return type. Derive the complete dependency closure across frozen image dependencies. Equal digests with unequal witnesses, omitted indirect requirements and failed fingerprint lookups reject.

The function body owns asSByteCodeFrameDescriptor: all storage units are DWORDs; argument and local regions are distinct signed ranges; each operand has explicit read/write width. Registers, result/parameter ABI, initialized object slots, cleanup targets and source/call-site records are declared rather than inferred from untrusted operand tags. Extend asSByteCodeOpcodeInfo as the sole operand/control/stack schema. A bounded CFG worklist checks joins, loops, call/return effects and live/initialized cleanup state before a sealed immutable image is admitted. Decoding uses bounded UTF-8 spans before any conversion; all accepted fields roundtrip with deterministic symbol/function/string ordering. Typed failures identify function, instruction and violated contract without partial output.

### Executable sidecars and atomic publication

asCExecutableFunction is the runtime sidecar for one immutable declaration: code, native interface, parameter offsets, frame/unwind data and direct call targets belong here, not in declaration scriptData/sysFuncIntf. asCExecutableSnapshot owns these records and retained metadata/resources privately. Context and each call-stack frame keep both the original declaration identity for inspection and its explicit executable binding; Prepare(snapshot,key) and the compatibility declaration adapter resolve the same binding. Adapt all actual interpreter/native/object/GC consumers; do not clone definitions or introduce a reduced interpreter.

Link prepares a private candidate, validates every requirement/target/native/global contract, acquires cleanup leases and lowers without publishing or modifying original declarations. One Engine lock/generation commit rechecks live attachment, conflicts and shutdown. Late failure leaves all prior bindings, global contents and resource counts unchanged; competing candidates have at most one winner. Native rebinding follows the same immutable candidate/commit lifetime rules. No partial body remains to poison a corrected retry.

### Object domains and runtime drain

Classify each value by its declared SDK-object/native-object/inline-value/funcdef domain before lifetime dispatch. Ordinary native references must never be probed as SDK allocation prefixes or released as script functions. SDK headers remain outside payload; explicit ownership/type leases and validated alignment preserve field zero. Construction records distinguish completed base/member/local objects from uncompleted whole storage. Copy, assignment, exceptional cleanup and reverse destruction share this live-state authority.

External references use supported atomic operations from an already held valid lease; weak creation/invalidation and GC root enumeration are synchronized. Suspended and nested Contexts retain their true roots and executable cleanup data. Shutdown progresses Running -> Draining -> Retired, rejecting new runtime admissions at Draining and preserving cleanup services for active calls/objects. A native callback requesting shutdown receives deferred completion instead of waiting on itself. Published Engine/snapshot ownership must not form an unreleasable strong cycle; active execution/object leases, not plain metadata, retain necessary runtime lifetime.

### Canonical source handoffs

Keep the explicit emitter Engine-free and Builder a thin optional adapter. Check session AST verification/seal and exact frozen-definition ownership; emission neither recalculates offsets on frozen functions nor retains producer pointers. Preserve existing diagnostic fragments/stable anchors in owned results without depending on the advanced-diagnostics Change.

Use canonical QualType for every opcode, conversion, lvalue address and return width; literal/cast syntax shape cannot choose arithmetic. Measure frame storage against explicit budgets instead of a fixed 64-word guess. Canonical semantic import preserves host void, qualifiers and in/out modes; reference assignment writes the referent, while reference binding validates its source category. Typed defaults resolve external declarations in initializer work, and constructor source ordinals remain separate from reverse-formal evaluation order.

Source scope stacks emit cleanup for fallthrough, return and the correct nearest break/continue destination; for-initializer and loop-body lifetimes differ. Exceptional source unwind is a pipeline, not emitter-only records: Path=Exception DestroyObject encodes asOBJ_INIT and Path=Normal encodes asOBJ_UNINIT; ALLOC without a construct expression still CALLs the declared default constructor so constructor Fail is reachable; linker objVariablePos uses the positive local index for exception cleanup (`stackFramePointer[-pos]`); Execute unwinds live objects before returning EXCEPTION; SCRIPT destructors run through metadataBehaviours, not UASClass ReleaseRawScriptObject. Test every failure followed by Recovery=97 in the same Context. Encode/decode of those records is 10.5 roundtrip proof; codec ownership remains 6.2/11.1. Source-produced caches use manually pre-registered B definitions after destruction of all A producer/runtime state.

## 11. Follow-up proof and scheduling

Tasks 6.1-6.4 establish image/operand/CFG/codec contracts; 7.1-7.2 separate executable ownership and atomic admission. Runtime groups 8.1-8.6 independently close ABI, dispatch, objects, GC roots, Context limits/hooks and shutdown drain. Opcode groups 9.1/9.2/9.3 own 121/43/49 assigned rows, respectively (the last includes STR rejection), plus reserved/pseudo rejection. Source groups 10.1-10.5 close admission, numeric lowering, call facts, normal cleanup and unwind. Cache groups 11.1/11.2 precede final acceptance 11.3.

Each group prepares related positive/negative/boundary cases, observes behavioral RED, implements its owned outcome, then proves GREEN. Existing passing controls are not fabricated RED. Compiler failures/crashes require diagnosis but do not establish behavioral RED. Ready groups can share expensive builds/runs only when source writers are stopped, shared Files are serialized, and exact per-group case/source/binary mapping is retained. A broad suite cannot hide incomplete required cases.

11.3 reconciles every accepted Case and Review resolution condition with fresh frozen-source and binary evidence, all opcode rows and actual NativeEngine plus separate Baseline execution. The broader NativeEngine selector is justified by shared definition/binding/Context/AST contracts; unrelated suites, Standalone, UE reflection and JIT remain excluded. Historical 704/704 and warning-bearing Baseline evidence stay unchanged. Review findings close only through appended, verified resolution against a new fixed snapshot, never because a repair was planned.


## 2026-09-08 admission producer correction

The user-authorized residual Review demonstrates that earlier width tests fabricated a TypeUse.NativeOffset fact absent from real AddFunctionRequirement. Callable image contracts must own explicit checked DWORD storage and value/address categories for each parameter and result, produced from detached metadata and authenticated against target metadata. These fields participate in complete witness and codec versioning. The verifier propagates bounded abstract stack categories and rejects incompatible joins; raw scalar bits are not proof of a reference argument.

Lifetime image records and CFG validation share actual VM construction/destruction semantics. InitializedObjectSlots identifies tracked local storage; it does not certify entry liveness. Track allocation destinations from local-address stack provenance, successful construction/init markers and FREE transitions. Validate records against real operations and types; propagate states through branches/loops with normal-exit and exceptional-cleanup coverage. Reconstruction permits later destruction of a new instance. Existing positive metadata-only cleanup fixtures must become real-operation fixtures. Source exception markers retain successful-operation timing, partial construction remains distinct from completed objects, and actual destructor/recovery traces remain authoritative. Tasks 6.7 and 6.8 own these bounded corrections; 11.4 owns final acceptance and all existing Review reconciliation. Earlier planning-only prose records historical delivery scope; this user request authorizes these implementation repairs and normal completion.


The lifetime verifier consumes 6.7 local-address stack provenance and may return a verified per-function state map. The linker lowers those states as PC-ordered changes to existing objVariableInfo, so Context observes proven incoming state even when instruction order differs from control flow. Constructor transitions require authenticated declaration-kind traits; method names are insufficient. This handoff is a prerequisite edge for 6.8, not just shared-file scheduling.


Verified pending allocations expose an existing Context fallback ownership defect: constructor `this` and reference arguments are borrowed, including their aliases. Exceptional fallback scanning must exclude them; the caller remains responsible for its pending allocation. A return emits destruction without consuming lexical ownership needed to generate sibling branches. These source/runtime consumer corrections are part of lifetime task 6.8.


## Remaining physical frame and control ABI contracts

The interpreter coordinate is authoritative: operands address `Frame - Offset`, locals occupy positive offsets 1..LocalDwords, and arguments occupy 0..-(ParameterDwords-1). Multi-DWORD values extend toward decreasing symbolic offsets and must remain in one storage region. Managed cleanup slots are local-only complete, disjoint pointer spans. Result descriptors use an explicit valid local span. Authoring, decoder, linker and source descriptor generation share this meaning.

Each function body authenticates its argument/receiver DWORD size against its callable and target metadata, and every RET retains the same pop count. Constant shorthand lowering preserves the supplied ABI. Indirect CallPtr carries an expected FunctionSlot shape, which drives static argument consumption and a cached per-PC runtime target comparison. Bound receivers are supplied by delegates and excluded from the expected external argument shape. Indexed JMPP validates every fixed-width table JMP and propagates every successor; a cached per-PC bound prevents runtime dispatch outside the declared table. These executable directories are generation-owned and require no stable-key lock per opcode.


The body ABI follow-up authenticates hidden return-destination storage using CallableTraits bit 64 (DoesReturnOnStack), in addition to the existing receiver and parameter storage. Requirement witness and target metadata comparison include this bit; caller analysis consumes its pointer address. It remains within the current unreleased v3 wire contract.


The current unreleased wire-v3 CallPtr contract is [Local, FunctionSlot]. The expected shape survives the existing operand codec; incomplete former one-operand encodings are invalid. Physical CallPtr remains one DWORD. The generation caches its authenticated expected declaration at each lowered PC; runtime shape matching and failed-call argument cleanup use that declaration, with bound delegates supplying their receiver internally.


Manually supplied images pass the same unique (role,key) requirement and unique nonzero body identity admission as canonical producers. Local frame declarations fit positive signed-16-bit addressing (at most 32767 DWORDs). Verification derives the maximum reachable expression/argument stack extent and hands it to linking alongside lifetime state. Runtime stack reservation includes both the local frame and this measured peak, using checked full-width arithmetic; the cached validation flag never authorizes publication.


### Runtime object and retirement drain ownership

A live SDK payload retains its actual metadata and runtime services until final destruction. Runtime ownership spans active interpreter/native execution and GC operations as well as externally retained objects; an atomic object reference count alone does not provide these leases. Shutdown closes public Prepare/Execute/link/native admission, while retained cleanup keeps the existing metadata, executable and native bindings available. A dedicated internal cleanup path executes script destructors through the same interpreter without reopening normal admission. Retirement occurs after those owned operations drain. Final object release and GC must release Engine ownership without a permanent collector/object/Engine cycle or destruction of an Engine while its collection method is still using it. Existing shutdown tests must balance their own extra Engine references, and final ownership tests drop all producer/caller owners.
