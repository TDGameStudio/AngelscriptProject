---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-06T11:25:33+08:00
reviewed_at: 2026-09-06T11:36:57.9219888+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: Saved/Harness/Reviews/review-20260906-112346-acceptance-gaps
snapshot_sha256: 4a143b0f981b679a625550dd035b4fba71184188c2eec5213c45082499632b5d
verdict: CHANGES_REQUIRED
---

# External Review: VM acceptance gaps

The user explicitly requested this review of the current Change's acceptance against implementation and supplied execution evidence. Analysis is restricted to the materialized immutable snapshot named above. The reviewer may write only this new report; implementation, planning state, indexes and lifecycle disposition belong to the coordinator.

## Snapshot, method and evidence boundary

The SHA-256 of the materialized `SNAPSHOT.md` was read and matches the assigned digest. Its parent HEAD is `d8343d314f0b948a43a323fc443cf305ff2f5dc3`, plugin HEAD is `1fd9301891914240f9c550448336843b150af3f6`, and captured `tasks.md` SHA-256 is `b1a7ef17b7e658d914b777978bdf91bba9350f73a73a4901af06d64333791ca8`. Product/planning inspection used those copied files, never their moving workspace counterparts. Tests were inspected first, including the verifier/linking/scalar fixtures and source expression cases; subsequent comparisons included image/cache, source object cases, the recorded case matrix and raw Automation report. A bounded read-only assistant independently checked the malformed-image counterexamples.

Scope includes verifier schema/CFG/frame/unwind admission, immutable executable ownership and link transaction, opcode execution completeness, native/object/dispatch/GC/Context/cache acceptance, and the bounded canonical source emitter. UE integration, Standalone, JIT backends, unrelated Changes and the dormant corpus are excluded. No test, build or new runtime reproduction was run for this review. Source-derived counterexamples below are explicitly **unexecuted**. A report of an admitted malformed instruction or incorrect emitted opcode is not a claim that a crash or particular runtime result was observed.

The supplied evidence preserves substantial executed progress:

- `Saved/Harness/Unreal/Runs/bf8cfb03ed9a4607b347c40a1442660f/Summary.json:14` and `Saved/Harness/Unreal/Runs/6f4ed80cd8fa46369d45f2e6bf6f4049/Summary.json:14` each report 704 total, 704 succeeded, zero failed/skipped/not-run/in-process. The second run's supplied `AutomationReport/index.json` contains 704 `Success` records, including the named VM and source cases discussed below.
- The source fixtures use actual `CreateContext`, `Prepare` and `Execute`; `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMScalarTests.cpp:10` and `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Compiler/VMSourceExpressionsTests.cpp:10` provide concrete examples. The maintained interpreter is being exercised; this is real product progress.
- `Saved/Harness/Unreal/Runs/93bdb999a8174b809010337c778ba330/Summary.json:14` records three Baseline cases: two succeeded and one succeeded with warnings, zero failures. Its 2,436 warnings remain part of that historical result; this review does not reclassify them as VM failures.
- Build `ba09bbfe1fda4452aedffabe1946343d` is recorded as succeeded in its supplied `RunMetadata.json:6`. These historical records identify runs, paths and timing, but do not include a complete source/binary digest manifest. The immutable review snapshot authenticates reviewed source; it cannot retrospectively prove that every copied byte was compiled into the historical binaries.

Path shorthand used below is an exact snapshot-relative prefix substitution, not a reference to live workspace content:

| Prefix | Snapshot-relative directory |
|---|---|
| `R/` | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` |
| `T/` | `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/` |
| `C/` | `openspec/changes/angelscript/refactor-vm-symbolic-execution/` |

Every `path:line` below resolves through these prefixes inside the assigned snapshot. Requirement references use the Change's captured delta specs, not a later synchronized specification.

## Findings

| ID | Severity | Status | Original finding |
|---|---|---|---|
| F01 | Required | open | Verifier admission omits operand schema, signed frame ranges, CFG stack and cleanup contracts. |
| F02 | Required | open | Executable/native bindings mutate declarations, and failed linking leaves earlier bodies installed. |
| F03 | Required | open | Supported opcode acceptance is not reconciled to per-opcode execution. |
| F04 | Required | open | Native ABI and dynamic/indirect call acceptance remains incomplete. |
| F05 | Required | open | SDK/native object ownership and lifetime stress contracts remain unsafe or unproved. |
| F06 | Required | open | Cache requirements omit authenticated witnesses/full signatures, and linking ignores layout compatibility. |
| F07 | Required | open | Source scalar lowering uses AST shape instead of typed operation/ABI decisions; admission controls are incomplete. |
| F08 | Required | open | Source control transfer, lexical cleanup, exceptional unwind and owned source observations are incomplete. |
| F09 | Required | open | Completed task/evidence state exceeds the acceptance actually represented by the supplied proof. |
| F10 | Required | open | Wire strings are read without their declared bound, and image roundtrip/canonicalization proof is incomplete. |

### F01 — Verify the complete executable contract before admission

severity: Required  
status: resolved
**Locations:** `R/as_bytecode_verifier.cpp:41`, `:45`, `:62`, `:68`; `R/as_bytecode_image.h:54`; `R/as_bytecode_image_codec.cpp:256`; `R/as_bytecode_linker.cpp:479`; `T/VM/VMByteCodeVerifierTests.cpp:40`, `:85`; `C/tasks.md:104`.

**Original observation:** verification checks opcode and operand count but never compares supplied operand `Kind` with `Info.Operands`. Branch, symbol and local checks are selected by the caller-supplied tag. The local check has only a positive upper bound and skips even that bound when `FrameSize == 0`; it does not validate argument offsets or access widths. Its `Stack` starts at zero, only increments for `PshC4`, and resets at `RET`, so the `Stack < 0` rejection cannot prove ordinary underflow. There is no CFG join analysis, call/return signature validation or construction/unwind representation to validate. `asSByteCodeFunctionBody` only contains keys, sizes, instructions and `DebugOffsets`.

**Reproduction/evidence, unexecuted:** starting from the registered no-argument function fixture in `T/VM/VMLinkingTests.cpp:12`, directly construct or decode `JMP(Kind=ImmediateS32, Immediate=99); RET(ImmediateS16,0)`. Builder `Emit` rejects that wrong kind (`R/as_bytecode_image_builder.cpp:183`), but public decoded/direct image admission does not: verifier returns success, linker emits 99 and skips invalid-target patching. `R/as_context.cpp:2097` would advance the instruction pointer by 101 DWORDs from a three-DWORD body. Separately, `FrameSize=4, ParameterSize=0; SetV4(Local=-32768, ImmediateS32=7); RET(0)` satisfies the declared operand tags and passes verification. `R/as_bytecode_linker.cpp:91` preserves that signed short; `R/as_context.cpp:3102` addresses `l_fp + 32768`, outside the declared local/argument region. No crash or memory write was executed by this review.

**Impact:** malformed images can pass the advertised pre-execution barrier and reach out-of-function instruction fetch or out-of-declared-frame addressing. Valid authoring checks are insufficient when codec/direct-image inputs enter separately. The three supplied verifier test identities prove a constant/forward-jump control, opcode/closure rejection and a correctly tagged invalid jump; `ValidConstantAndLoopPass` has no loop backedge.

**Affected requirements:** `C/specs/angelscript/runtime/bytecode/spec.md:52` (Executable verification precedes publication), its malformed-control-flow scenario at `:56`, and task 2.2 cases at `C/tasks.md:110`. Task 2.1's typed image and task 2.3's verified admission depend on this contract.

**Resolution condition:** all public author/decode/link admissions validate opcode-defined kinds, wire/target widths, symbol roles and complete closure, signed local/argument bounds including zero/max/narrowing cases, branch targets, CFG stack joins, call/return ABI, initialized construction ranges and unwind targets. Each malformed class returns a specific failing instruction/contract with no executable; include both concrete counterexamples through direct-image and decoded-image routes. Linker must reject an impossible destination if one reaches lowering. Establish a real terminating backedge control and independently specified CFG/frame/cleanup rejection cases.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.1–6.13: real callable storage contracts, complete typed argument consumption and opcode-defined operand/frame/CFG admission. VMCallAdmission, VMManualAdmission and the complete VM admission selections pass. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F02 — Separate executable state and make publication transactional

severity: Required  
status: resolved
**Locations:** `R/as_execution_snapshot.h:30`; `R/as_bytecode_linker.cpp:10`, `:426`, `:492`, `:565`, `:598`, `:619`; `R/as_bytecode_emitter.cpp:64`; `T/VM/VMLinkingTests.cpp:10`; `C/tasks.md:118`.

**Original observation:** `asCExecutableSnapshot` publicly exposes a mutable image and maps of original type/function pointers; it has no prepared frame/call binding ownership beyond those pointers. `LowerFunction` allocates and clears `Function.scriptData`, sets stack/object-local fields, recalculates offsets, and writes bytecode on the original registered declaration. Native binding deletes/replaces the declaration's `sysFuncIntf`. Source emission also recalculates parameter offsets on frozen functions. Link iterates and mutates bodies before the final output assignment; error cleanup only releases snapshot references. `LinkByteCodeImage` checks retirement once at entry, without a synchronized candidate commit/recheck in this implementation.

**Reproduction/evidence, unexecuted:** use an image whose first body F resolves and lowers, followed by a nonempty G body whose key has no registered declaration (or whose late `CALLSYS` lacks a binding). The verifier does not reject the missing body declaration. F's bytecode is written at `:492`; G returns failure at `:574` or `:585`; destructor `:10` only releases leases. `OutSnapshot` remains null but F retains its installed body, so a retry can fail with `BodyConflict`. Existing `MissingDeclarationAndBodyConflictReject` tests an early missing declaration and an intentional second successful install; it does not compare state after a late failure. Pointer equality in `LinkResolvesOriginalFunctionPointers` is valuable but does not prove separate executable ownership.

**Impact:** unsuccessful linking can change callable state, contrary to the atomicity promise, and runtime execution/native rebinding remains tied to mutable declaration fields. The snapshot does not establish the immutable execution and cleanup ownership required by contexts, dispatch, cache and shutdown.

**Affected requirements:** `C/specs/angelscript/language/types/definitions/spec.md:28` (Executable bodies remain separate from immutable callable declarations), `C/specs/angelscript/runtime/bytecode/spec.md:68` and `:82` (transactional generation-owned linking/late failure), `C/tasks.md:122`, `:124`, `:127`, `:172`.

**Resolution condition:** retain original declaration pointer identity while storing executable bytecode, frame/unwind data, native call interfaces and runtime dispatch in independent immutable Engine-owned bindings. Prepare all candidates before one synchronized publication; validate shutdown/conflict at commit and release all candidate resources on failure. Prove late failure leaves prior bodies/bindings/storage/resource counts unchanged, competing publications have at most one winner, and live execution/cleanup leases remain valid without modifying frozen metadata. Rebinding must have an explicit checked lifetime/transaction contract.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 7.1–7.4/8.7: independent immutable executable/native records, synchronized candidate commit/rollback and Context/frame/snapshot/native/operation ownership. VMExecutableOwnership/AtomicLink/ExecutableLeases/NativeBindingLifetime/RuntimeDrain pass, including nonrecursive missing-code rejection. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F03 — Close the opcode execution ledger, not only handler families

severity: Required  
status: resolved
**Locations:** `C/attachments/data/opcode-inventory.md:100`, `:179`, `:189`, `:197`, `:226`; `C/attachments/data/implementation-verification.md:61`, `:82`; `T/VM/VMScalarTests.cpp:10`, `:39`; `T/VM/VMIntegrationTests.cpp:474`, `:510`, `:930`; `C/tasks.md:138`, `:228`.

**Original observation:** the accepted scope is 212 supported runtime opcodes, separate rejection of STR, all 38 reserved ordinals and all five pseudo records, with each supported variant executed. The final evidence table maps representative operand/semantic families; its statement that remaining operand lowering is table-driven does not identify their executed cases. For concrete examples, the snapshot NativeEngine test sources have no explicit references to `GETOBJREF`, `fTOu64`, `dTOu64`, `ADDi64`, `SUBi64`, `MULi64`, `DIVi64`, `MODi64`, `BSLL64`, `POWdi` or `POWu64`; those inventory rows remain assigned. The source producer also does not supply a demonstrated execution mapping for them.

**Reproduction/evidence:** compare the listed inventory rows to the exact family table at `implementation-verification.md:63` and the supplied `6f4.../AutomationReport/index.json` case names. A source scan alone is not proof an opcode never executes indirectly; the finding is that no per-opcode executed or permitted rejection disposition is supplied. The actual `VMIntegration.RejectsRetiredReservedAndPseudoOpcodes` test at `:474` does iterate the rejected ordinals and is preserved as positive coverage.

**Impact:** aggregate GREEN and common packing paths can conceal incorrect widths, signedness, operands, register effects, exceptional boundaries and instruction advance in unrepresented variants. Task 3.1 and final 4.2 have a materially stronger acceptance condition than this family summary proves.

**Affected requirements:** `C/specs/angelscript/testing/baseline/spec.md:19`, especially `:23` (each assigned runtime opcode has an execution or explicit rejection disposition), and `C/specs/angelscript/runtime/vm/spec.md:7`; task 3.1 `C/tasks.md:138` and 4.2 `:228`.

**Resolution condition:** supply a complete 213-row assigned-opcode ledger plus reserved/pseudo rejection ledger, each mapped to full public test identity, an executed path and an independent result/state/lifetime/error oracle. Cover every supported width/operand variant and documented arithmetic/null/stack boundary. Shared runs may supply multiple rows, but handler existence or a sibling opcode cannot substitute for executing the row. Preserve the existing proven cases and clearly identify any unsupported disposition requiring a changed accepted requirement.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 9.1–9.3: all 213 assigned opcode rows map to individually successful exact case identities with execution or explicit retired/reserved rejection oracles in the preserved opcode inventory. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F04 — Finish native ABI and dynamic/indirect target acceptance

severity: Required  
status: resolved
**Locations:** `T/VM/VMNativeCallsTests.cpp:183`, `:244`, `:474`; `T/VM/VMDispatchTests.cpp:77`, `:193`, `:322`, `:402`; `C/tasks.md:145`, `:150`, `:169`, `:174`; `C/attachments/data/implementation-verification.md:26`, `:28`.

**Original observation:** task 3.2 explicitly says object-first/object-last and virtual/base-adjusted callers are not claimed, while its accepted cases require those forms. The supplied native cases prove Generic/typed int addition, a receiver/padding case, selected primitive/out paths and rejection controls, but not the full bool/int8/int16/int32/int64/float32/float64/reference/value/handle return-storage matrix. Task 3.4 explicitly says interface factory/funcdef signature metadata/wrong-signature CALLBND are unclaimed; `asFUNC_INTERFACE` creation remains rejected in its own evidence. Existing `CALLINTF` over a base method and ordinary function-pointer execution do not establish an authentic interface declaration or complete funcdef/target signature contract.

**Reproduction/evidence:** this is an acceptance/evidence gap grounded in the captured task's own exclusions and exact 10-case native/10-case dispatch reports, not a claimed new execution failure. `BoundCallUnboundNativeThrows` observes a runtime exception; it does not prove the distinct promised wrong-signature or missing-slot rejection before execution. Existing `Thiscall1AddsSevenToReceiver` in `T/VM/VMIntegrationTests.cpp:698` supplies additional real receiver coverage and must remain credited.

**Impact:** consumers cannot rely on the promised host ABI/receiver/ownership surface or indirect-call rejection policy from the current completion state. These call paths also feed object construction/destruction, delegates and cache linking.

**Affected requirements:** `C/specs/angelscript/runtime/vm/spec.md:24` (authenticated explicit host contracts), `:42` and `:61` (complete object/dynamic dispatch), task 3.2 `C/tasks.md:150` and 3.4 `:174`.

**Resolution condition:** execute every accepted native shape with literal values, exact callback/receiver traces, surrounding sentinels and return/out/inout ownership checks; reject unsupported or incompatible contracts before callback entry. Add authentic interface/default/inherited/base-adjustment paths, full funcdef return/parameter validation, invalid indirect targets, and CALLBND script/native/delegate plus missing/wrong-signature admission cases. Preserve frozen method membership and keys while proving these behaviors through actual execution.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 8.1/8.2, 6.11 and 11.4: VMNativeABI/DispatchContracts/IndirectAdmission and adjacent CallableSDK pass with callback/receiver/value/sentinel/full-signature and cleanup oracles preserved. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F05 — Complete object domains, atomic ownership and lifecycle stress

severity: Required  
status: resolved
**Locations:** `R/as_vm_object.h:12`; `R/as_vm_object.cpp:21`, `:54`, `:88`, `:135`, `:161`; `T/VM/VMObjectsTests.cpp:119`; `T/VM/VMGCTests.cpp:372`; `T/VM/VMContextsTests.cpp:135`, `:383`; `C/tasks.md:157`, `:162`, `:181`, `:186`, `:193`, `:198`.

**Original observation:** runtime strong references use a plain `asUINT RefCount` with unsynchronized `++`/`--`, despite the explicit atomic ownership acceptance. GC member traversal accepts object handles and funcdefs, then `asVmReleaseAllReferences` probes every reference as an SDK payload and casts every failed SDK lookup to `asCScriptFunction*`. A declared native-object handle is neither automatically an SDK allocation nor a funcdef. The probe itself reads the word before the supplied pointer before checking ownership, then recognizes only a fixed 512-byte prefix distance. The allocation helper stores a raw `Type` pointer without establishing an explicit object/runtime lease in this helper. These are relevant to legitimate mixed SDK/native ownership and retained live objects, not a speculative hostile-pointer sandbox claim.

**Reproduction/evidence, unexecuted:** retain a declared native reference-object handle as a member of a GC-managed AS object and release the AS object's references. `ForEachVmHandle` admits the field at `:145`; the release branch at `:168` tries SDK header recovery, then the fallback at `:173` treats a non-SDK native object as a function. A typed native release behavior is not selected there. Concurrent valid holders of one SDK object also reach non-atomic refcount changes at `:93`/`:101`; no race failure was executed. An allocation alignment above the recovery distance requires either explicit rejection or compatible recovery; no result is claimed for that boundary.

**Further acceptance gap:** the task cards explicitly leave compound/partial-member constructor failure, collection during construction exception/shutdown, suspended-handle GC and abort, reference observer enabled traces, configured stack limit and shutdown requested from a native callback unclaimed. Current object, cycle/weak and Context successes are useful controls but do not prove initialized-member-only reverse unwind, live binding drain, external runtime object leases, or GC while a local survives suspension. A prepared root case does not substitute for a yielded local-handle case.

**Impact:** legitimate native handles can be routed through the wrong object domain; shared strong-reference ownership lacks its promised atomic contract; required failure and shutdown edges remain without evidence that destructors, weak state and runtime bindings stay valid exactly once.

**Affected requirements:** `C/specs/angelscript/runtime/vm/spec.md:42`, `:54`, `:67`, `:80`, `:97`, `:104`; `C/specs/angelscript/language/types/definitions/spec.md:51`; task 3.3 `C/tasks.md:160`, `:162`, 3.5 `:186` and 3.6 `:198`.

**Resolution condition:** dispatch reference enumeration/release by authenticated declared object domain and prepared behaviors; establish safe SDK allocation identity/recovery, validated alignment and explicit live type/executable ownership. Prove atomic strong references from valid retained leases. Add compound/base/by-value initialization and reverse cleanup, second-member failure with no whole-object destructor, handle assignment/temporary balance, native value release, allocation/list boundaries, observer callback/no-op behavior, GC during callbacks/exception/suspension, abort/reprepare, precise stack-limit error, and shutdown-from-callback deferred drain. Independent counters/weak state/storage sentinels must prove live roots survive and cleanup completes exactly once before binding retirement.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 8.3–8.7: runtime payloads own Type/Engine resources; active operations retain metadata/code through private script/native cleanup. VMRuntimeDrain proves actual final host/producer/snapshot release, cross-snapshot script destruction, weak expiry, callback-cycle GC, suspended roots, concurrent active continuation and closed public admissions. Twelve cases pass under Stomp, alongside 467 shared VM cases. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F06 — Carry and enforce full authenticated cache compatibility

severity: Required  
status: resolved
**Locations:** `R/as_bytecode_image.h:38`; `R/as_bytecode_image_builder.cpp:17`, `:54`, `:110`; `R/as_bytecode_linker.cpp:514`, `:524`, `:535`; `T/VM/VMCacheTests.cpp:255`, `:277`, `:325`; `C/tasks.md:124`, `:209`, `:214`.

**Original observation:** a requirement stores key, schema/layout digests, a caller-supplied referenced-key list and display name, without the canonical witnesses/full callable or type-use/property contract promised for authentication. `MakeTypeRequirement` obtains witness views but discards them; `AddFunctionRequirement` records key/name and possibly owner only, without return/parameters or their dependency closure. Duplicate role/key requirements silently keep the first contract. Link handles Type/Function/Global roles only; its type branch checks Schema only when the digest is nonzero and the current fingerprint query succeeds. It ignores Layout and can fall through after a fingerprint-query failure. Its function branch resolves the nominal key and checks only existing bytecode, never a complete signature. Body `SignatureKey` is not compared during lowering.

**Reproduction/evidence, unexecuted:** encode a body against an ordinary `int Run()` and register an independently created `double Run()` with the same ordinary FunctionKey in the destination. The detached identity test already establishes that ordinary keys can agree when return types differ (`T/Definitions/VMDetachedMetadataTests.cpp`, test `OrdinaryFunctionKeyCanAgreeWhenReturnTypeDiffers`; mapped at `C/attachments/data/implementation-verification.md:21`). The image/function requirement lacks the return contract and linker cannot reject this distinction. Separately change only a supported native offset while preserving schema/key: no layout comparison exists in `:524`-`:531`. A failed current fingerprint query also fails to trigger rejection. Equal injected digests with unequal canonical witnesses cannot be authenticated from bytes that omit the witnesses.

**Evidence limitations:** `DestinationLayoutChangeRejectsLink` renames `y` to `z` and expects `SchemaMismatch`; it does not isolate layout-only incompatibility. Existing schema/indirect-dependency mismatch and native cache tests are preserved. Task 4.1 explicitly does not claim specialization, qualified/delegate/string execution, destination global sentinel preservation, same-key changed return or offset-only layout. Source cache task 5.5 currently proves missing free function and body conflict, not its full missing class/native binding/changed signature-layout/foreign image matrix.

**Impact:** a definition-free cache can bind a nominally matching but ABI/layout-incompatible destination, defeating the exact compatibility boundary that makes independent Engine reuse valid. A digest-only supplied dependency list cannot establish canonical witness authenticity or complete role/signature closure.

**Affected requirements:** `C/specs/angelscript/runtime/bytecode/spec.md:26`, `:39`, `:46`, `:68`, `:72`, `:91`, `:135`; `C/specs/angelscript/language/types/stable-identity/spec.md:32`, `:39`, `:54`; tasks 2.1/2.3/4.1/5.5 at `C/tasks.md:96`, `:124`, `:214`, `:296`.

**Resolution condition:** persist and authenticate full canonical witnesses, role/owner/type-use/specialization and callable ABI contracts; enumerate complete dependencies from those contracts; reject conflicting duplicate requirements and missing/failed fingerprints. Revalidate schema, target layout and full return/parameter/native contracts against current live definitions before candidate publication. Prove isolated same-key return, native offset-only and indirect layout/schema failures; injected digest collisions; missing/foreign/retired declarations; and independent generic/qualified/delegate/string/global cases after producer destruction. Destination storage sentinels and existing body/definition counts must remain unchanged on all failures and must not be restored from cached live state.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.1/11.1/11.2: VMImageContracts/Fingerprints/CacheContracts/SourceCacheContracts authenticate complete witnesses and target schema/layout/native contracts, preserving independent destination storage and publication on failure. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F07 — Use typed source operation and ABI decisions, with explicit admission failures

severity: Required  
status: resolved
**Locations:** `R/as_bytecode_emitter_expressions.cpp:173`, `:244`, `:256`, `:377`, `:403`; `R/as_bytecode_emitter_statements.cpp:32`, `:100`; `R/as_bytecode_emitter.cpp:14`, `:37`, `:77`; `R/as_bytecode_emitter.h:9`; `T/Compiler/VMSourceExpressionsTests.cpp:111`, `:136`; `C/tasks.md:242`, `:244`.

**Original observation:** all numeric implicit casts emit `iTOd`; integer literals narrow to int32; unary/binary/comparison operations generally choose int32 handlers. If either immediate operand node is a floating literal or implicit cast, Add, Subtract and Multiply all become `ADDd`. Arithmetic width and return width are inferred from AST node shape rather than resolved types; local initialization/assignment and conditional result copies use four bytes. Return of a double variable/parameter has a different shape from a double literal although its ABI is the same. The seven expression cases prove selected int32 and one mixed addition path, not the accepted widths/conversion/operator surface.

**Reproduction/evidence, unexecuted:** `double Run(double x) { return x - 2.5; }` with `x=7.5` should return 5.0; the floating-right-operand branch selects `ADDd` at `:410`. `double Run(double x) { return x * 2.0; }` likewise selects addition. These are opcode-selection counterexamples from inspected source, not measured wrong results. Typed runtime tests must additionally cover variable/parameter return, signed/unsigned widths, bool storage, conditional double results, every supported conversion direction and enum values; constant-only success cannot prove those paths.

**Admission observation:** Emit checks that a session and matching-key body exist, then dereferences `GetDefinitions()` and lowers all available script fragments. It does not establish verified/sealed AST plus exact matching frozen definitions at its entry. Most lowering failures collapse to `Incomplete`; the result contains only image/status and no structured owned source diagnostic. Existing frontend error controls do not prove all producer-specific unready/mismatched/unsupported/target cases fail distinctly with no partial image.

**Impact:** valid bounded scalar source can be lowered to the wrong operation/width, while unsupported or unready input lacks the promised stage-specific admission contract. Success on `1+2.5` does not generalize to typed floating arithmetic.

**Affected requirements:** `C/specs/angelscript/runtime/bytecode/spec.md:99`, `:103`, `:125`; `C/specs/angelscript/testing/baseline/spec.md:64`; task 5.1 `C/tasks.md:242`, `:244` and source matrix `C/attachments/data/source-execution-matrix.md:24`, `:40`.

**Resolution condition:** select conversions, operations, lvalue load/store, local allocation and return ABI from resolved semantic types and conversion decisions, with exact width/signedness. Execute related scalar cases using runtime inputs and independent numeric/representation oracles, including both counterexamples. Reject unsupported valid forms explicitly. Establish AST verification/sealing, definitions ownership/signature match and target compatibility before lowering, and test unready/recovery/mismatch/unsupported/target failures with owned source/stage diagnostics, no partial image and no callback/publication.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 10.1/10.2: VMSourceAdmission/Numeric execute typed runtime-input arithmetic/representation controls and reject unsupported/unready/mismatched input with owned diagnostics and no partial publication. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F08 — Lower lexical control flow, live construction state and source observations

severity: Required  
status: resolved
**Locations:** `R/as_bytecode_emitter_internal.h:17`, `:21`; `R/as_bytecode_emitter_statements.cpp:112`, `:144`, `:276`; `R/as_bytecode_emitter_lifetime.cpp:36`, `:73`; `R/as_bytecode_emitter.cpp:65`, `:83`; `R/as_bytecode_image.h:54`; `T/Compiler/VMSourceObjectsTests.cpp:150`, `:193`; `C/tasks.md:256`, `:277`, `:284`.

**Original observation:** `LiveObjects` is one emission-time list, without lexical scope removal or runtime initialized-state records. Compound statements only recurse. Break/continue emit bare jumps and no cleanup. The while emitter does not push its own break/continue labels, so it cannot supply the nearest while target; it may fail when no outer target exists or inherit an outer one. Destruction traverses the whole flat list, while construction allocates before evaluating/calling constructor arguments and supplies no exceptional unwind metadata. Every source body uses a fixed 64-word frame regardless of allocator growth. Body/image structures have no executable initialized-local/unwind/source-observation representation; `DebugOffsets` is neither populated here nor serialized by the codec.

**Reproduction/evidence, unexecuted:** extend the existing `SourceReverseDestroyOnReturn` Box/Host::Mark fixture to `int Run() { { Box Inner(2); } Host::Mark(3); return 0; }`. The required trace is `[2,3]`; compound exit emits no destructor, leaving destruction at the later return. A conditional declaration skipped at runtime still contributes to the later emission-time cleanup list. A `while` with `break` must choose its own exit, but the emitter has no while target stack entry. For-initializer/body objects across continue/break need distinct cleanup depths that the flat list cannot express. A constructor/native/division exception bypasses explicit normal cleanup without an initialized-object unwind record. No resulting runtime leak/crash/trace was measured in this review.

**Evidence limitations:** `SourcePairNamedConstructorFormalOrder` uses constants and proves storage placement, not the promised `[2,1]` constructor side-effect trace. The source-ordinal codec test proves roundtrip and old-version rejection, not corrupt/duplicate/missing ordinals. `SourceMixedLoopObjectExceptionCache` adds useful real exception/reprepare evidence but does not establish live-count zero, initialized-member-only unwind, source/call-site accuracy or return-97 reuse across the accepted failure matrix. Cross-section calls and the precise native/ref/default acceptance also remain explicitly unclaimed in `C/tasks.md:263`; they need their own source oracles, not direct-VM substitutes.

**Impact:** valid bounded source scopes/transfers can destroy values at the wrong time or select the wrong target; conditional/exceptional paths lack a complete ownership model. The promised portable, source-owned observations and diagnostic/unwind behavior cannot be represented by the current artifact.

**Affected requirements:** `C/specs/angelscript/runtime/bytecode/spec.md:103`, `:114`, `:125`; `C/specs/angelscript/testing/baseline/spec.md:64`; task 5.2 `C/tasks.md:256`, 5.3 `:268`, 5.4 `:280`, `:284`, and source matrix `C/attachments/data/source-execution-matrix.md:30`, `:60`.

**Resolution condition:** represent lexical cleanup depths, dynamically completed construction, handles/temporaries and frame/unwind/source records in the shared executable format. Compute the actual required frame and lower each loop/switch target with the correct cleanup transition. Execute nested scopes/else/loop-switch nearest-target traces, for-initializer continue/break lifetimes, conditional construction and partial-constructor/stack/division/native failures; assert exact destructor order, zero leaked live objects, accurate source/call-site data and successful Context reuse returning 97. Add constructor argument side effects/default ordinals and malformed mapping cases, cross-section calls and outstanding source reference/default controls. Producer release/cache roundtrip must preserve those observations without retaining AST/session pointers.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 10.3–10.5/11.2/6.8: VMSourceCallContracts/ScopeCleanup/Unwind/CacheContracts preserve argument/default side effects, lexical cleanup, partial constructor destruction, owned observations and Context recovery after source producer release. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F09 — Align completion state and verification claims with represented acceptance

severity: Required  
status: resolved
**Locations:** `C/tasks.md:28`, `:32`, `:145`, `:157`, `:169`, `:193`, `:209`, `:222`, `:231`, `:263`, `:277`; `C/attachments/INDEX.md:5`; `C/attachments/data/implementation-verification.md:3`, `:17`, `:82`, `:88`; snapshot `SNAPSHOT.md:14`.

**Original observation:** all 19 task nodes are checked and the index says implementation is complete through 4.2, although those same cards explicitly disclaim required cases and the final reconciliation marks required source rows "No". The opcode map remains family-level. The task-level statement of planning-only work at `:28` is also stale. Task 5.3 describes an earlier crashing run as RED even though `:32` says crashes are not behavioral RED; its later three failing assertions must be treated separately. The final "frozen identity" claim relies on Build/RunIds, while the supplied material explicitly lacks a full source/binary digest manifest.

**Reproduction/evidence:** compare checked task acceptance and omissions at the listed lines with the supplied raw `6f4.../AutomationReport/index.json`. Its 704 successes confirm discovered identities, including three verifier, two linking and seven source-expression cases, and do not create tests for absent acceptance. The `implementation-verification.md:94` and `:96` unclaimed source rows make the mismatch visible without a new runtime run. This finding does not invalidate reported successes or manufacture missing historical RED.

**Impact:** downstream verification/synchronization/closure could treat a partly represented contract as fully implemented. A reviewer or maintainer cannot determine completion by the checkboxes/aggregate alone or safely attribute current source bytes to the historical binary.

**Affected requirements:** `C/specs/angelscript/testing/baseline/spec.md:19`, `:34`, `:49`, `:77`; task execution contract `C/tasks.md:32`, `:36` and final acceptance `:228`, `:231`. This finding concerns evidence truth, separately from the implementation findings above.

**Resolution condition:** preserve historical reports and successful observations, but reconcile every required case/opcode/source row to actual proof and distinguish completed versus outstanding work in the state authority. Record crashes as failed/incomplete executions rather than behavioral RED; retain honest baseline GREEN and any irreversible historical RED gap. Subsequent proof must bind a frozen source manifest and relevant built binary identities to exact discovered/executed cases. Do not synthesize retroactive evidence. Complete the accepted missing behavior before claiming final reconciliation, and retain justified exclusions for Standalone/JIT/UE integration/unrelated suites.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 11.3/11.4: final-runtime-drain-acceptance.md authenticates all 55 task selectors, 213 opcode rows and 112 source cases against the final 1080/1080 report and frozen source/four DLL identities; existing VMCache and adjacent regressions have current passing proof. Historical crashes, fixture failures and missing earlier RED remain explicitly historical. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### F10 — Respect bounded wire strings and prove full deterministic roundtrip

severity: Required  
status: resolved
**Locations:** `R/as_bytecode_image_codec.cpp:80`, `:86`, `:89`, `:134`, `:175`; `R/as_bytecode_image_builder.cpp:264`, `:295`; `R/as_bytecode_image.h:61`; `T/VM/VMByteCodeImageTests.cpp:45`, `:89`, `:125`; `C/tasks.md:96`, `:98`.

**Original observation:** after validating the declared string length, `ReadString` first calls NUL-terminated UTF-8 conversions on the raw input at `:86` and `:89`, before the bounded copied-and-terminated buffer at `:90`. Even a zero-length string reaches the first conversion. The later safe copy cannot undo an earlier read outside the supplied byte view. The wire format writes length-prefixed bytes without a NUL terminator. Separately, `Finish` copies `Strings` in insertion order and does not remap string slots, and codec omits `DebugOffsets`; current roundtrip tests check a subset of fields and the "golden" case checks only the magic/version prefix, not an independent complete wire vector. Decoder accepts either pointer width and arbitrary nonzero float byte without proving compatibility against the execution target in verifier/linker.

**Reproduction/evidence, unexecuted:** supply a valid header/count prefix whose next requirement name or string has a length ending exactly at the end of a non-NUL-terminated view, with the following record truncated. A bounded decoder must return truncation; this implementation performs a NUL scan before discovering the missing following record. No out-of-bounds read or crash was executed here. For deterministic proof, build semantically equivalent images adding two different strings in opposite orders and remapping authored uses: `Finish` preserves the order at `:295`, so the encoded string table differs. A nonempty `DebugOffsets` array is not among the fields written at `:134` and therefore cannot survive encode/decode.

**Impact:** malformed/truncated cache input can be read beyond its declared view before rejection. The encoded artifact does not yet preserve all advertised fields or canonicalize all symbolic resources, and target incompatibility rejection is not established by accepting a supported enum value alone.

**Affected requirements:** `C/specs/angelscript/runtime/bytecode/spec.md:26`, `:39`, `:46`; task 2.1 `C/tasks.md:96`, `:98` and task 2.2 budget/target checks `:110`.

**Resolution condition:** decode strings only within validated byte ranges, with deliberate zero-length, multibyte UTF-8, missing terminator, truncation and count/length/overflow budget cases. Authenticate and preserve every promised wire field, canonicalize resources and remap all uses, and validate target pointer/float/opcode ABI before executable admission. Add an independently authored complete minimal byte vector and multi-resource/multi-function reordered roundtrip containing source/debug/frame/unwind data. Failure must leave no usable partial image.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.1/6.2/11.1: VMWireFormat/VMImageContracts/VMCacheContracts cover bounded strings/budgets, an independent complete minimal vector, deterministic resource remapping and full-section roundtrip with no partial image on failure. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Verification story and disposition

The report credits the supplied two 704/704 NativeEngine runs and Baseline result as historical execution evidence for their exact discovered cases. It does not claim new failed runtime tests or a fresh build of this source snapshot. Read-only source, task/spec comparisons and supplied report parsing establish the observations above; all executable counterexamples are unexecuted. The historical build-to-current-source provenance limitation remains explicit.

Ten Required findings remain open. The appropriate verdict for this immutable acceptance snapshot is **CHANGES_REQUIRED**. The coordinator owns finding triage, task mapping, repair evidence, any later re-review and lifecycle closure; this report does not prescribe a Replan or close any finding. Original finding text must remain intact when resolution evidence is appended.

## Coordinator triage and applied planning disposition

The coordinator accepts F01-F10 as open inputs. The verified mismatch between required Cases and completed task/evidence state invalidates the remaining execution plan; the user explicitly requested Replan and this Review. Requirements are retained. Ordinary implementation defects will be fixed in their owning follow-up groups, not by automatically creating more Reviews.

| Finding | Disposition | New task owners | Closure evidence required |
|---|---|---|---|
| F01 | Accepted; open, not repaired | 6.3, 6.4 | Original resolution condition plus exact executed cases and source/binary evidence |
| F02 | Accepted; open, not repaired | 7.1, 7.2 | Original resolution condition plus exact executed cases and source/binary evidence |
| F03 | Accepted; open, not repaired | 9.1, 9.2, 9.3, 11.3 | Original resolution condition plus exact executed cases and source/binary evidence |
| F04 | Accepted; open, not repaired | 8.1, 8.2 | Original resolution condition plus exact executed cases and source/binary evidence |
| F05 | Accepted; open, not repaired | 8.3, 8.4, 8.5, 8.6 | Original resolution condition plus exact executed cases and source/binary evidence |
| F06 | Accepted; open, not repaired | 6.1, 7.2, 11.1, 11.2 | Original resolution condition plus exact executed cases and source/binary evidence |
| F07 | Accepted; open, not repaired | 10.1, 10.2, 10.3 | Original resolution condition plus exact executed cases and source/binary evidence |
| F08 | Accepted; open, not repaired | 10.3, 10.4, 10.5, 11.2 | Original resolution condition plus exact executed cases and source/binary evidence |
| F09 | Accepted; open, not repaired | 11.3 | Original resolution condition plus exact executed cases and source/binary evidence |
| F10 | Accepted; open, not repaired | 6.2 | Original resolution condition plus exact executed cases and source/binary evidence |

All 19 historical completed IDs and evidence remain; residual acceptance receives new IDs. The canonical acceptance-gap matrix details handoffs and negative oracles. Assigning these tasks does not resolve, defer or close any finding. CHANGES_REQUIRED and state=open remain unchanged. The coordinator has not run a new product test or claimed any unexecuted source counterexample as an observed failure.

## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
