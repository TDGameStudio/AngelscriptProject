# Cache V2 Current Status

Date: 2026-08-11 (Asia/Shanghai)

This file is the sole current progress authority. The pre-vertical status, including
the complete IC-138–IC-209 table and old B/C/D/E critical path, is preserved at
`history/pre-vertical-refactor-2026-08-09/status.md`. Detailed evidence and issues
remain in `verification.md` and `implementation-issues.md`.

## Current architectural decision

The target has not been simplified to a module Blob Cache. Cache V2 continues to
require function-level stable identity, FunctionBody records, compile-input reuse
and StaticJIT mapping, while module parsing/structure and active activation retain
their module-level boundaries.

Implementation scope is the complete `Plugins/Angelscript` source tree, including
the maintained AngelScript fork. Cache V2 may add or revise lower-level AS APIs,
state, compiler/bytecode hooks, serialization and VM restoration when required by
the design and tests; the Runtime wrapper boundary is not a restriction.

```text
source detection       File / Module input
preprocess/declaration affected Module
compiler reuse         StableFunctionKey invocation
persistent records     Function / Type / ModuleState
StaticJIT matching     StableFunctionKey + content/profile/ABI
active publication     complete ModuleSnapshot
physical storage       aggregate Pack + Manifest
```

The execution plan is now vertical: first establish a real cold/warm/edit loop,
then close per-function compiler reuse, lifecycle and final package acceptance.

## Evidence vocabulary

| State | Meaning |
|---|---|
| Accepted foundation | Previously built/tested identity or archive behavior remains valid. |
| GREEN | The named focused production behavior executed and passed. |
| Partial GREEN | Some named families pass; the milestone exit condition does not. |
| Compile frontier | Source compiles or links only; behavior is not inferred. |
| RED | A compiled/linked focused test executes and fails for the intended missing behavior. |
| Planned | No implementation evidence is claimed. |

SingleFile compilation is never behavioral evidence. Exact SHA review is required
only for frozen bytes/identity, ownership/allocation and publication safety
boundaries, not every ordinary local implementation edit.

## Vertical milestone board

| Milestone | State | Current truth |
|---|---|---|
| V0 Accepted foundation and execution reset | GREEN | Identity/archive authorities are retained. The vertical OpenSpec rewrite passed strict validation and history/link checks; no Runtime behavior changed in this rewrite. |
| V1 Complete in-memory module artifact transaction | GREEN | The supported representative vertical is complete. All seven record kinds cross one immutable decoder/factory and the sole `ValidateModuleSnapshotGraph`; a real enum/function module produces byte-identical complete artifacts in two isolated engines. Production execution/debug codecs validate reachable opaque bytes exactly once. Truncated and corrupt execution/debug candidates rebuild valid surrounding hashes/RecordIds/links, reach OpaqueCodec with exact offsets, and leave zero graph records plus zero promoted output. Function-reader byte accounting, detached error routing, narrow simple-Enum admission and SourceIndex external-context ownership are corrected. The affected module aggregation is `30/30` and complete Cache is `334/334`. Unsupported/unrepresentable selected-module type/layout/method/state forms remain fail-closed until later restore/compiler-reuse verticals widen them; IC-221 retains non-blocking diagnostic breadth. |
| V2 Generation data plane, Store and cold publication | GREEN | Deterministic Pack/Manifest construction and the Win64 Saved Store are production behavior. V2.3 composes the namespace lock, all-three-root reread/rebase, strict temp cleanup, writer Pack-count preflight, immutable installation and old-or-new pointer publication. V2.4 owns delete-sharing pinned handles, cumulative Current/Previous/Pending selection and crash-safe two-phase compaction. V2.5 publishes/reopens one normal clean seven-record cold generation. V2.6 executes all twelve exact crash checkpoints with recovery and real publisher/publisher plus pinned-reader/writer threads. V2.7 adds the read-only standalone Python root/Manifest/Pack inspector with deterministic text/JSON, all required filters, physical BLAKE3/Zlib/link diagnostics, common summaries, opaque VM policy and structured corrupt-input errors. Python is `13/13`, Store remains `91/91`, and complete Cache was `340/340` before removal of one redundant dump-tool UE test. |
| V3 Direct source candidates and exact warm restore | GREEN — V3.1–V3.14 complete | Production discovery and exact warm startup restore complete admitted module batches with zero frontend work. The admitted live shape now includes root and mutually referencing script UClasses, reflected properties/functions, Base/Middle/Leaf inheritance and position-independent VFT ownership. IC-453 restores 3 types/14 routes and executes two-level override dispatch with result `51`; IC-455 TypeSchema v2 preserves the exact UE/original/AS reflected-name tuple and is `69/69` GREEN. IC-454/IC-456 restore an arbitrary duplicate/distinct StaticName global function against deliberately conflicting producer/consumer indices, execute to `454` and leave the consumer name table unchanged; the adjacent positive/negative/literal set is `11/11` GREEN. IC-459 establishes one owner for reflected argument derivation: a sibling-class input/return signature restores 16 records, 2 types and 5 routes into a fresh Engine, producer/consumer UFunction parameter inventories match exactly, every VM/UObject type coordinate is consumer-owned, and the reflected call returns the exact consumer Peer object. V3.12 restores admitted reflection flags/metadata/defaults exactly, and V3.13 proves late two-class failure leaves no active VM/UClass/descriptor/route residue before authoritative same-name recompile. V3.14 makes the class-graph producer select ready siblings by stable namespace/name authority and group functions by canonical owner without changing class-local property/method/VFT order. Opposite source order now preserves ModuleInterface, ModuleState, two TypeSchemas and eight function identities; both fresh consumers restore 2 types/8 routes and execute `28/14`, while only moved debug records and their owning bodies change. Focused behavior is `1/1` and class-graph adjacency is `9/9` GREEN. |
| V4 Changed-module oracle and incremental publication | GREEN — V4.1–V4.5 | Existing HotReload remains the compile authority and changed disk source uses explicit `ForceClean`. Semantic RecordId comparison, mixed old/new Generation publication and deterministic next-wave propagation are complete. The production-backed clean oracle covers unchanged, body, signature, class/property/layout, global storage, initializer, include/input, compile-option and debug-only mutation families; complete Cache passed `415/415` at `Saved/Tests/cache-v45-complete-regression/20260810_172027_716_69873a57`. `ExpectedAbi` consistently means declaration SignatureHash while layout/value content uses the separate content coordinate. |
| V5 Per-function compiler reuse | GREEN — V5.1–V5.6 complete | Clean Capture, immutable graph lookup, maintained-builder hooks and two-Engine parity are implemented and focused tests prove all supported invocation families. The selected session survives safe zero-activation exact misses into normal `CompileModules`; graph-validated callbacks are attached after function layout and before stage 3. Production body edits restore unchanged global and reflected class methods while compiling edited methods and executing current behavior (`1001/2002`, `1101/2102`). Type/property/global authority, shared-producer convergence, diagnostics and packaged unchanged-warm reuse are closed by the schema-4 V5.6 implementation and V7 package matrices. |
| V6 Lifecycle and StaticJIT isolation | GREEN — V6.1–V6.5 complete | Every Engine owns one Cache service and normal initial/reload compilation freezes complete Current or PendingColdStart publications without weakening last-good activation. Bounded shutdown and explicit Flush publish through the same Saved-root policy. Runtime exposes pointer-free Status/JSON, bounded trace, typed Explain, shallow/deep Verify, two-phase Compact, transactional ForceClean and Disabled/Manual/Automatic packaged RuntimeReload; Python owns read-only physical validation, session correlation, semantic Generation diff and persisted dependency explanation. Accepted compile/restore rebuilds an immutable per-Engine StableFunctionKey-to-current-FunctionId Native/VM route snapshot. A safe-point StaticJIT refresh republishes only that transient route snapshot: injected Provider arrival/departure, per-function miss and rejected Live Coding outcomes preserve the exact Current/PendingColdStart/LatestSuccessful publications and unrelated Native routes. Provider ABI/catalog matching and the Live Coding state machine remain sibling-owned. StaticJITIsolation is `3/3`, FunctionRouteSnapshot `4/4`, DecisionTrace `3/3`, Python `20/20`, and the final complete Cache prefix is `490/490`, failed/not-run `0/0`. |
| V7 Cutover and final acceptance | GREEN — V7.1–V7.7 complete | The legacy `PrecompiledScript.Cache` production path is removed. Editor/NullRHI PIE, Development and Shipping seven-launch matrices, complete Cache/HotReload/generated-AOT StaticJIT, Python Store inspection, schema-4 diagnostics, deterministic bounded-parallel Pack preparation and the 56-row benchmark all passed. Final CoarseDynamic acceptance ran 37 tasks in four slots and passed `2971/2971`; Cache was `536/536`, Debugger `39/39`, Compiler `81/81` and Standalone `19/19`. The tiny benchmark proves integrity/parity but not startup acceleration, as retained in IC-503. |

## Current source frontier

These hashes identify the working source being continued; they are not approval or
completion claims.

| File | SHA-256 | Current classification |
|---|---|---|
| `AngelscriptCacheTypeSchema.cpp` | `7438E1C8B47456A46A44EEB6E549497C20E46F1967E507F0B4580A3FDCDDE0AD` | Shared producer/decoder validation includes exact Dependency, Method/VFT, seven-kind KindPayload, fixed descriptor, Property/Layout and Reflection form/member rules. |
| `AngelscriptCacheTypeSchema.h` | `E0F230E8450B152F7D05FDDF9EBF0032A8768FCF635F96CDC5B27B31A0228075` | Public captured-field enum is append-only through `ReflectionKind=39` and `ClassReflectionFlags=40`; the unit-test-only allocation event now exposes its physical origin offset. |
| `AngelscriptCacheTypeSchemaTests.cpp` | `7682DD84C37D7CE56648A5F5DCBDEBCD76831155EF5ECF05418A97492967F82B` | Historical TypeSchema TU carries focused Property/Layout and Reflection matrices plus synchronized single-fault fixtures. Broad-prefix synchronization remains incremental; file splitting is not a gate. |
| `AngelscriptCacheTypeSchemaDependencyTests.cpp` | `5CFFD7AF71E9E5489554F7CC80C20694AB46470FD0A3C7B46EC9130C5D8E5C38` | Focused producer test is linked and GREEN across 4 legal, 4 structural, 6 missing and 2 extra cases. |
| `AngelscriptCacheDecodedRecord.cpp` | `92E8EC6912E876BC9594137DB4391CA716F2AFD9BC0FF33985DC921FE78CA4BC` | All seven record tags dispatch through the sole immutable factory; one Generation batch now accumulates decoded candidates under a shared transaction and promotes exactly once after reachability. |
| `AngelscriptCacheDecodedRecord.h` | `4EA9A161AB344A7AC84059BB8CB1307005ECB73D06B5A77915A5900734856316` | Immutable candidate storage owns exact ModuleState, SourceIndex and recursive ModuleInterface nested offset shapes; opaque function validation now also receives the graph-owned declared dependency view used to prove relocation membership. |
| `AngelscriptCacheTypes.h` | `4B06DADB5409940DB408654504F812879E7D0D2F9E4F5809AD3FD09807B39762` | The one read Budget owns monotonic stored/decompressed/decoded/reference counters, combined live resident accounting, temporary RAII reservations and aggregate candidate transactions. |
| `AngelscriptCacheSemanticRecords.cpp` | `948ADF92970C1A96088A1DE770E4CB3E44A54C20BCC48B203D6B6BB0936EAF33` | SourceIndex/ModuleInterface retain one captured physical read. V6.1 splits exact-fast-path matching into reusable one-time hook-index preparation plus per-module closure work and atomically publishes a sorted, cumulatively budgeted producer batch without changing single-query semantics or the frozen wire schema. |
| `AngelscriptCacheSemanticRecords.h` | `34FEC66B4640EF696950E6DE92AC70D1A4AD4E4268BE29F360B6A236CFF8AD41` | Public semantic archive exposes canonical SourceIndex projection/direct-input digest operations and the pointer-free eligibility batch DTO/entry point; test-only malformed writers remain isolated. |
| `AngelscriptCacheService.h/.cpp` | `EF0B5A8A3CF3CC485DA296BE6391A7D7645107EA132B9E8E4FE9B6CFB8E1758C` / `ACABDBEC8EB354540FFB55AB41F54193A48D58B822FC174BB432C5B89A8D6C47` | V6.1 owns the per-Engine mutation gate, ephemeral service/epoch/thread token, lifecycle admission phases and the self-owned shared-const successful-publication DTO. Freeze accepts only validated complete module artifacts inside the current gate and preserves latest-good/transaction atomicity. |
| `AngelscriptCacheSourcePlanner.h/.cpp` | `0CB967575CF129B23EBCEE228C036404F568F01AFDC98B8AA4BCCAD884F704ED` / `ADC4BAFA357B46BDECE96DE51E0058E620125B42BD0A0D6A7E549A08499D1FE4` | V3.1 constructs bounded direct inputs and the frozen first-stage digest. V3.2 adds bounded candidate composition and a callback-free observation-table validator with explicit Exact/direct/unavailable/dependency outcomes and exact-only atomic SourceIndex output. |
| `AngelscriptCacheSourceDiscovery.h/.cpp` | `E2EDC52713E8411A1E9E8A01A4F28FB672521E3984DB0A5A91547569256A50B7` / `D4AC634E12D5F22CB7D1A93C4E49783148FB51F8402C77FE3331DE35766F16A0` | Production discovery validates exact bytes/descriptors/module coordinates and builds relocation-free direct plans plus current observations without preprocessing. V6.1 closes IC-292 by routing every sorted discovered module through one validated/prepared eligibility batch rather than repeating SourceSnapshot validation and hook-index construction per module. |
| `AngelscriptSourceProvider.h/.cpp` | `FF0B9D35446E82E478EF44FDFA22D6BAE9C65A708D1AA4E0FBD007B8CDE3BE0D` / `C16139541936B07BE10685663D54A4BB5194E09E428335D9D915D04782838CFE` | Backward-compatible provider defaults expose canonical raw bytes and optional stable descriptors; the built-in disk provider reads exact bytes and publishes an absolute-path-free version/configuration identity. Existing provider behavior is `4/4` GREEN. |
| `AngelscriptCacheProductionSourceDiscoveryTests.cpp` | `0F0E3B9483824490AC9106AC0C03FFE31A7F15610E358D8C5B47DBCA1B0F325E` | Twelve production methods cover typed Game/Plugin/Memory inventory, relocation/order, add/delete/rename, exact disk bytes, collisions, provider/hook eligibility, strict encoding/read failure, stable module-coordinate agreement and byte/string budgets. |
| `AngelscriptCacheDependencyObservationTests.cpp` | `E3D9C28B9D61706A572A2791082EB0120F290C309869AE67956EE28DA9809E98` | Two independent methods cover exact and unavailable current observations for source/generated/provider/hook/module/option targets without a preprocessor callback. |
| `AngelscriptCacheDirectSourcePlannerTests.cpp` | `3964B3266952BDB506F49481365906B51011F1845D07A9C81AEE8AFF718D3534` | Independent V3.1 TDD matrix covers canonical order/path equivalence, every direct authority, derived-dependency separation, capability ineligibility, collision/reference/raw limits, NUL/empty keys, shared budgets and frozen identity; focused `10/10`, complete Cache `349/349`. |
| `AngelscriptCacheDependencyCandidateTests.cpp` | `200A0B6C7FDD4400FE0A42E43532F6D69D083B1F449A46258C2323743B47CDA5` | Independent V3.2 TDD matrix covers bounded/order-independent capture, exact atomic rebuild, normal miss taxonomy, corrupt/duplicate rejection, reference/budget failures and the empty candidate; focused `8/8`, complete Cache `357/357`. |
| `AngelscriptCacheSourceInterfaceTests.cpp` | `559C6F4D306E555980A722FEE361CB7FBD7A2FA5CE7930925E891BA1D7349B0D` | Historical wire/semantic/query regression treats nested semantic and physical failures as exact-field diagnostics. |
| `AngelscriptCacheSourceInterfaceCapturedOffsetTests.cpp` | `95500C91376A8FA3C9B08705AF6D045B5378995A6E542F0FA93DBCE6C6DF419B` | IC-232 tables freeze coordinate shapes, exact semantic/duplicate/order/physical routing and actual-allocation exact/short/rollback behavior; the complete SourceInterface prefix is `43/43` GREEN. |
| `AngelscriptCacheRemainingRecords.cpp` | `1C58CBE668F71BF1977FD68DEF25C66AA7F6B5B475B602FB66C0905F065A13E7` | Full local producer/private-decoder behavior for DebugSidecar, FunctionBody, ModuleSnapshot and representative non-empty ModuleState, including shared semantic validation and local hash recomputation. Cross-record graph meaning remains V1.4. |
| `AngelscriptCacheModuleGraph.cpp` | `4F8DB5DA8FD13BA937F891D82ACD0473BA184EC1DF60AB4CAEFB21EAC53E5D55` | Sole graph authority now passes each FunctionBody's canonical actual dependencies into opaque validation and rejects any decoded instruction relocation that is not their exact subset. Selected-module type DAGs and method/behavior breadth remain fail-closed. |
| `AngelscriptCacheCleanCapture.h/.cpp` | `D1BA9EA3613B1EBA745886AC43C266DA5641A383FCCA6E1EAA17796E0B304F66` / `2A79B17985B3542611995E1D66349DA87FC9A4D198146FBA2F7A622AF0C8AB7D` | The admitted enum vertical captures all simple global functions, records real compiler-observed function dependencies, resolves current input digests from current interface/type/state authorities and can reopen its pointer-free artifacts through the same owning graph path. |
| `AngelscriptFunctionArtifactCodec.h/.cpp` | `E030409E3FA32CFDB061A9550FDE264FE3695F34A82F5E92DFC37C5533D7D1BA` / `7BEBD676B02BFED3DD0073EC3AE0936B787882BD0A382736787EF2B75D6423B8` | Execution codec v2 validates the maintained reader's current-module function relocations, derives their stable keys and publishes bounded relocation uses only when an exact persisted Signature dependency exists. Other symbolic tables stay fail-closed. |
| `AngelscriptCacheCompilerBridge.h/.cpp` | `5166A828D23CC73C28E52206F0B824F3C913001A79F05F3653F7AD877686EAE2` / `D843F87C4EDED18CE5FF732AA84ACA866473F8BACD4AD639F2D4E0ED7651BAF1` | V5.4 binary-searches immutable graph function ordinals, checks full stable key/Profile/current source/current input and reaches atomic restore only for a deterministic match; source/input/authority differences remain typed misses. |
| `AngelscriptCacheRestore.h/.cpp` | `D2564333EBCB063AF85E81994B8ACD2345D96704ED136B8C2A3749F79EC936D0` / `4CF335C3837A7C99DFB9A0FEEB2796942A3912DEB87F6D578853B60C0FB1059A` | V3.4 engine-owned immutable-candidate/staging/activation coordinator reconstructs the admitted enum/function module, current numeric ID and stable route, then atomically publishes normal plugin indexes. V3.5 requires a one-to-one persisted/current source projection before staging and installs current virtual/relative/absolute source coordinates while leaving preprocessed `Code` empty. Unsupported shapes fail closed. |
| `AngelscriptCacheExactStartup.h/.cpp` | `3BE0CC80DD763E0F13210D1B01C42C3AE96807B35094F9AD14D32958789F53AF` / `E9224E501216E3D1CC114191D2CB72E80A0F0CB04AFB3ABA351EB2A9AA27D5CF` | V3.5 exact-start coordinator compares current profile, direct/dependency candidate and SourceSnapshot, classifies ordinary differences as safe misses, and invokes restore without owning any frontend/compiler or Store-writer call site. |
| `Cache/Private/AngelscriptCacheRuntimeState.h` | `79548BC073332E50FAAA91168821F47079672915409E58E44E178DC7063CF675` | Per-Engine live stable-route ownership remains private and pointer-bearing; no pointer or numeric ID enters persistent records. |
| `ThirdParty/angelscript/source/as_restore.h/.cpp` | `D36CB05465AF005D81A3BDD95F2773F780E8BA38C39439D2C727339E82917BCE` / `DD9ED2EC42467EAE6A543C406FEE1974EF560940A9216BB5875AEDC711D04C8A` | Function artifact v2 writes a semantic used-function signature table instead of numeric IDs, resolves each entry against the current module before translating bytecode and exposes instruction/operand/current-function relocation summaries without publishing the donor. |
| `Core/AngelscriptEngine.h/.cpp` | `E847052A9E1E45AAD4BDE48B4D8D160BC3A4F36F08D53CD06F40B885728FA41D` / `75B9A55FD93F13F1FF75C6E2F0B89461E3E58922F70CE23060334E3EFEAA790D` | Product-level Engine owns Cache live routes and exactly one V6 Cache service. Normal and test initialization transition the service to runtime game-thread ownership; shutdown closes cache mutation admission before AS teardown and releases the service last. Existing compile-cache policy and normal parser/compiler/JIT/ClassGenerator authority remain unchanged. |
| `AngelscriptCacheServiceTests.cpp` | `86BD62E364C6478F941E96C11004FA1DC0079FBEC7FEF175C483B9BB43011AD3` | Three V6.1 methods cover two-Engine service isolation, explicit-only reentry, stale/off-thread/shutdown rejection, real seven-record Clean Capture freeze, duplicate atomicity, monotonic transaction `1` and DTO lifetime after Engine destruction. |
| `AngelscriptCacheEligibilityBatchTests.cpp` | `1515F809559479162B0F8A6B3E41FC250999112E9CD6A4138E50453B6FA3975F` | Two IC-292 methods prove sorted batch/single-authority parity, one-byte-short atomic budget failure and a 64-module one-preparation/one-index-build diagnostic row. |
| `Core/Compilation/AngelscriptCompilationEvents.h` | `8EDB508C31D20337C9713DB726316351FC4656DB2D5B5824D72BDE3927637D21` | Structured events expose the compile-cache policy and legacy/incremental loaded flags so one run id can prove forced-clean versus artifact reuse rather than infer it from timing. |
| `Core/Compilation/AngelscriptCompilationContext.h/.cpp` | `4B351E9800EA40366FB5F01ED9A52D3BA8F24E089F9B39CCD0657E30E6BCEF38` / `C37D84F6BEC78224897C482D382F6EE1C02962F2F2795F2293A62279519E6630` | The existing per-run authority retains the cache policy and propagates it consistently through begin/module/handoff/end summaries while preserving default-call compatibility. |
| `AngelscriptCacheFreshEngineRestoreTests.cpp` | `C4226C39362F31C431043115E00F8DE65DE22663D8071B56DD601023A023D811` | Three physical-disk/route tests cover Engine A destruction, Engine B execution, duplicate/discard lifecycle and two-Engine numeric-ID isolation. |
| `AngelscriptCacheFreshEngineRollbackTests.cpp` | `C4AEB3B1B741F55B4598B3F45D83CF9F36009E8CBF31BA50A7C98B6AC0322C5F` | Separate late-failure test proves private debug apply rejection leaves no active module/type/route and permits an authoritative compile in the same Engine. |
| `AngelscriptCacheExactWarmStartupTests.cpp` | `A77AB5CA5309507B5F7CBDC9B1B30AE54117B9F34B61F43DAEDE5F690C067B46` | Four physical-Store tests destroy Engine A before independently initializing Engine B, prove unchanged zero-work restore/no publication, changed-source and tampered-projection safe misses, and absolute-root relocation with current source navigation coordinates. |
| `AngelscriptCacheChangedModuleOracleTests.cpp` | `7D50732B9B13820755F0EC28914F515AF1655101679083A828DE52B477783B35` | Separate V4.1 tests prove a real disk HotReload executes preprocess/parse/code-compile once under `ForceClean`, changes `Answer()` from 41 to 42, and clears both legacy/incremental artifact hints; focused `2/2`. |
| `as_restore.h/.cpp` | `CEBA9D0C07FCA2B1A9F9F32588ABD36EC6F1F34C786D1270DACB3877401D81FD` / `73611CDEE322089176418D7A8993A18888F813CD90CE541BF399D24349F9970E` | Maintained-fork reader exposes bounded detached function-artifact stages, exact successful string-byte accounting and half-created cleanup; expected eligibility failures stay in the result channel while ordinary module restore retains engine error messages. |
| `AngelscriptCacheCleanCaptureOpaqueValidationTests.cpp` | `C7D6183BC04F09EDB0D4E961F078C299409BF2A7A7D35B2549F98DF073A4590F` | Separate Runtime-integration class rebuilds outer semantic hashes, RecordIds and Snapshot links around four malicious opaque payloads and proves OpaqueCodec offsets plus atomic empty output. |
| `AngelscriptCacheModuleSnapshotGraphTests.cpp` | `213C254987E52F75D30EE1AD82763D15E4021B30873035DCFED0F8C6FA735353` | Focused graph fixtures cover atomic reachability, exact type/function/debug/global/module-initializer ownership, opaque ordering/hashes and allocator-authoritative candidate rollback; current prefix is `13/13` GREEN. |
| `AngelscriptCacheModuleGraphDependencyTests.cpp` | `F9190DA78E2CCC482BF1A4AF4F6953901C13394085BAFFBDFC7FD91A8E993C31` | Separate dependency fixture covers exact relocation matching, typed external current-symbol failures, selected-module ScriptFunction zero-resolver closure/precedence, and duplicate ModuleInterface/FunctionBody ownership sharing one ordered memo; focused prefix is `4/4` GREEN. Other local kinds, layout resolution and memo/budget breadth remain open. |
| `AngelscriptCacheModuleGraphLayoutTests.cpp` | `A609B46783D93A0C9CA65D95BDBF3D51186F05BA57CE4C731B1672D25065B578` | Separate CurrentLayouts fixture covers a root UClass, exact property declarations, primitive no-query storage and external EnvironmentType DataType resolution. Missing/raw-shape/storage-kind/size/alignment failures clear the graph with observable call counts; focused prefix is `4/4` GREEN. |
| `AngelscriptCacheManifestPack.h` | `82B2FBCC71E4E950E7B0159C179F4A77FD10E6795152E7B0365CDA033ECA8107` | Public V2.1 data-plane interface includes variable-output writer compression and fixed-output reader canonical verification so read scratch remains caller-budgeted. |
| `Tools/CacheV2Dump/cache_v2_format.py` | `1FD55CFC7776D7B372CD852F9E62DD5A49197CA6E7613CAC4750DF846225E6C7` | Dependency-free/optionally accelerated BLAKE3, bounded frozen pointer/Manifest/Pack readers, exact RecordId/RawChecksum/link checks and versioned common semantic summaries; generic opaque payloads remain metadata only. |
| `Tools/CacheV2Dump/cache_v2_dump.py` | `87BF4BD462135FAE7B5B9C3CC26F15A1E4E84F5147521ABB20A3B7DD3C8B8566` | Read-only standalone input discovery, generation/module/kind/stable-key filters, deterministic text/JSON and structured nonzero error output. |
| `Tools/CacheV2Dump/tests/test_cache_v2_dump.py` | `AD94D80C457685DB1642D607F91470708E42A56C81163F77CF6B289B2AA4951C` | Thirteen Python tests cover C++ frozen wire bytes, BLAKE3 vectors, filters, goldens, corruption, structured errors and cache-tree non-mutation. |
| `AngelscriptCacheManifestPack.cpp` | `ACCDD377D00E95B96E712DE53F7A29F05E50C9C24000FC2CC2D6552D88924AA3` | V2.1 production data plane: deterministic None/Zlib aggregate Pack construction, exact pack/index/location validation and decode, canonical Manifest encode/decode, whole-file PackId/GenerationId, one-attempt distinct-Pack loading, pre-allocation cumulative Budget for every retained/scratch array, bounded deduplicated reachability and publication-atomic validated generations. |
| `AngelscriptCacheSemanticDiff.h/.cpp` | `C73843C5316F17DF8C801A71F99F8057CC20B2B125859AF467FA1CF82BB99591` / `48D2CD01EB3673D0BEA585472CE296EFB4C1D2DB21376CB3BFB3000C6F1C76AC` | V4.2 builds immutable semantic views from already graph-validated generations, rejoins every module/type/function/debug owner, compares complete RecordIds, rejects incompatible or subsequently forged shapes, and emits sorted module classifications plus reused/new/retired reachable record sets without consulting Pack locations or a live Engine. |
| `AngelscriptCacheSemanticDiffTests.cpp` | `BF9D3E894F0391E3C20CB62B3062934C53D1B1FA96998370CA470D7BCEAB0F22` | Separate V4.2 test class validates aggregate-versus-sharded physical independence, body-only reuse counts, enum TypeSchema modification, line-shift DebugSidecar isolation, function-key remove/add, incompatible Profile rejection and forged-root atomic failure; focused `7/7`. |
| `AngelscriptCacheIncrementalGeneration.h/.cpp` | `FC129F468AA143E4BDDC1B7685B0260AD68FC432BA1D410A6B6C07046069D481` / `59AF799F230DFA5D29024448C77EDBEE98439F0D9074054B4F153B9FD00A4104` | V4.3 prepares a complete generation from validated base/current values: it owns the semantic diff, copies only current new payloads into deterministic Packs, retains exact old locations for reused IDs, excludes retired IDs, validates/encodes the complete Manifest and leaves atomic empty output on every failure. Store publication remains the sole transaction and physically revalidates old plus new Packs before pointer commit. |
| `AngelscriptCacheIncrementalGenerationTests.cpp` | `396A5BE05E9B5E4F8D394BB4177102F0232ECC22A0606E02B3D77498A912E7E4` | Separate V4.3 class proves body-only exact reuse/new/retired and mixed-graph equivalence, physically regrouped zero-Pack/exact-Generation no-op, real Store mixed old/new publication with a still-readable byte-unchanged pinned base, and forged-base atomic empty failure; focused `4/4`. |
| `AngelscriptCacheManifestPackTests.cpp` | `CEBCCD4EF42C9EE9119369756BB693F2C3BF662ABB03A95F6592DAB5C811F9F0` | Frozen V2.1 byte-golden, scheduling/order, malformed-input, codec, Pack/Manifest identity, exact/one-short Budget, source-call and reachability authority is `27/27` GREEN. |
| `AngelscriptCacheStoreCompaction.cpp` | `E0C2B95EAE6EDBAF35634FC57B0CEFEFE42E5D84D64B005974FF2E1BD2BBF6C2` | V2.4 production compactor implements authority validation, all-three-root semantic-union rewrite, same-slot switches, lock release/reacquire, physical-root re-mark and strict final-only sweep with committed cancellation/sync/deferred-delete classification. |
| `AngelscriptCacheStoreCompactionTests.cpp` | `451EBFA9EC669E049F0A243EF6E3B24701B33732C4611FC4B7EC958C531C088D` | Independent V2.4 matrix covers authority rejection, Phase A/B, all-three-root union, ineligible Pending, intervening publication, duplicate-generation mark deduplication, cancellation, directory-sync failure, deferred retry and old/new pointer mixtures; current class is `12/12` GREEN. |
| `AngelscriptCacheStoreReadSessionTests.cpp` | `692D6D2D57C219E3CA92A2C204038AF66CBE3796A1BD592E19A420C28BF06829` | Pinned-generation selection and production Win64 delete-sharing coverage prove a live session remains bound to old immutable bytes across compaction unlink/path reuse. |
| `AngelscriptCacheStore.h` | `34D4F3E01F2AED58F0CF4EA1813016F5D4A6954B5DC243CE111A1D9806AEFDCB` | Store control plane now includes the exact non-persisted twelve-point fault enum, transaction-local injector and `FaultInjected=22`; normal callers retain the null default. |
| `AngelscriptCacheStore.cpp` | `71C4A0C1A40911173E5BE4DDC704A22719687AAD04F6FC349BC5F5C018183451` | The composed publisher forwards one injector across Pack/Manifest/pointer stages and emits immutable checkpoints only after their frozen write/flush/reopen/rename/sync boundaries. |
| `AngelscriptCacheStorePointer.cpp` | `954E589CBF5A62E69BFDEC4D6DD74ED872A18BF61FACB8EB4B9A4E814AD5A3D2` | Pointer publication emits all-temps, Previous and Current/Pending pre/post points with exact old-or-new commit classification and no crash-simulation cleanup. |
| `AngelscriptCacheStoreFaultInjectionTests.cpp` | `0197B547750608233942CB40575C12201F161228EDF92A288612028CE1D5EE09` | Three production-disk methods exercise all twelve points, exact visible state and subsequent normal-writer recovery. |
| `AngelscriptCacheStoreConcurrencyTests.cpp` | `45CE173D95E465180B0CC526EF49E762B726D1E7B799EE40BDAFDF754ACD55DD` | Two actual-thread production compositions prove one-commit/one-no-op publisher serialization and pinned-old/new-current reader/writer visibility without sleeps. |

## Last trustworthy focused evidence

- V2.1 Pack/Manifest/Generation is `27/27` GREEN at
  `Saved/Tests/cache-v21-ic253-packformat-final-attempt-1/20260810_015042_611_77e41215`
  after the complete Development Editor link at
  `Saved/Build/cache-v21-ic253-green-build-attempt-1/20260810_014948_242_7bf97904`.
  This includes IC-251 validate-once/aggregate promotion, IC-252 exact
  Manifest/Pack-index pre-allocation accounting and IC-253 fixed-output canonical
  verification plus a record-count-bounded reachability queue.
  This closes the in-memory generation data plane only; Saved Store, real
  compiler capture, cold/warm/edit restore, Editor/PIE and package evidence remain
  open.
- TypeSchema physical decode B5 focused behavior: `5/5` GREEN.
- Shared Behavior/Relations/LayoutInputs regression: `15/15` GREEN at its recorded
  pre-split source frontier.
- LayoutInputs focused producer/decoder set: `4/4` GREEN.
- V1.1 Dependency producer is `1/1` GREEN with all 16 logged cases; decoder is
  `1/1` GREEN with five admitted and six rejected common kinds. The complete linked
  Editor target also passed after both fixture-coordinate repairs.
- V1.2 Method/VFT producer-local family is `1/1` GREEN across its asserted `121`
  calls (`20` legal / `101` rejected), with independent array order and legal
  cross-array FunctionKey aliasing. This advances V1.2 but does not close it.
- V1.2 KindPayload producer is `1/1` GREEN for selected-arm, callable ABI,
  Funcdef multicast, primitive-only Typedef and Enum producer rules. The retained
  Enum decoder is independently `1/1` GREEN with exact KindPayload coordinates.
  The adjacent Typedef/Funcdef descriptor regression is now GREEN under IC-218.
- V1.2 Property/Layout producer is `1/1` GREEN across an internal `660`-call
  ledger (`83` legal / `577` rejected). The final linked Runtime/Test build is
  GREEN and adjacent KindPayload/Enum/descriptor regressions are `3/3` GREEN.
- V1.2 Reflection producer and decoder-local surface is GREEN: producer `1/1`,
  form/name prefix `2/2`, class-mask exhaustive `1/1`, form isolation `1/1`,
  UFunction member shape `1/1`, and the append-only `0..40` captured-coordinate
  matrix `1/1`. Property/Layout, KindPayload, Enum and fixed descriptor regressions
  remain independently GREEN. IC-221 retains the broader Property/DataType
  subfield-coordinate precision gap rather than reopening Reflection behavior.
- The broad TypeSchema prefix is not GREEN and terminated at a static fixture
  `check`: it exposed remaining V1.2 semantics plus fixtures that mutate DTO fields
  without rebuilding exact Dependency coverage. This artifact is diagnostic only,
  not a regression-pass or a replacement for the focused V1.1 evidence.
- V1.3 remaining-record plus frozen debug-absence identity evidence is `5/5`
  GREEN for DebugSidecar, FunctionBody and ModuleSnapshot, including exact
  canonical lengths/offsets, canonical dependencies, bounded references and one
  aggregate promotion.
- ModuleState now has one representative non-empty record GREEN. After the intended
  missing-hash-API compile RED and empty-only serialization RED, the full codec
  linked at
  `Saved/Build/cache-v13-modulestate-full-codec-build-attempt-1/20260809_182641_574_1af6cddd`
  (`5/5` actions). The positive fixture passed `1/1`, then the separated validation
  family exposed and closed IC-229. The final combined ModuleState prefix at
  `Saved/Tests/cache-v13-modulestate-focused-green/20260809_183154_140_bfbdfafb`
  passed `5/5`. It proves all six collections, a `1075`-byte representative wire,
  canonical insertion-order independence, exact nested derived-hash diagnostics,
  trailing-data precedence, nine bounded stable references and zero candidate
  temporary bytes after promotion. It does not prove full negative breadth,
  cross-record declaration ownership/coverage, real-engine capture or seven-kind
  dispatch.
- The minimal SourceIndex/ModuleInterface sole-factory sequence is complete at its
  stated narrow boundary: SourceIndex linked GREEN, the corrected fixture reached
  an ordinary ModuleInterface RED, the full Editor target then passed `13/13`, and
  `Angelscript.TestModule.Cache.Archive.SourceInterfaceFactory` passed `1/1` at
  `Saved/Tests/cache-v13-source-interface-factory-minimal-green-attempt-1/20260809_185822_378_b92b2f0e`.
  This proves reachable seven-kind dispatch and minimal immutable promotion only;
  IC-231/IC-232 retain representative nested coverage, single public decoder
  authority and exact semantic diagnostic routing.
- The common-token exact-fast-path step is GREEN at its current boundary. A
  test-first compile RED proved the query still required
  `FAngelscriptValidatedSourceIndex`; after adding the common-token path, the
  complete Editor target passed at
  `Saved/Build/cache-ic231-copied-handle-green-attempt-1/20260809_191558_515_38f1d0b7`
  (`4/4`). The focused factory prefix then passed `3/3` at
  `Saved/Tests/cache-ic231-copied-handle-green/20260809_191618_730_13b0b101`.
  This proves actual wrong-kind routing, zero query-Budget mutation on that
  rejection and copied-handle lifetime for one eligible SourceIndex. It does not
  close IC-231 because the old owning decoder/query overload still exists.
- IC-232 now has two exact nested semantic batches GREEN. The first linked intended RED
  returned SourceIndex parent byte `52` instead of capability byte `250`, and
  ModuleInterface parent byte `92` instead of parameter-ordinal byte `293`.
  Production now borrows allocation-free lookup views over the immutable
  candidate's sole captured store; the focused two-method prefix is `2/2` GREEN.
  The second RED exposed both parent routing and a stale nested cursor: six
  SourceIndex derived keys and six ModuleInterface derived-hash/import/slot
  cases now select their own occurrence. The combined focused prefix is `4/4`
  GREEN. This is a representative slice, not the complete nested-field matrix.
- IC-231 test migration now compiles through the complete UE 5.8 Development
  Editor target at
  `Saved/Build/cache-ic231-test-migration-green-attempt-1/20260809_193820_405_9590cb9`
  (`13/13` actions). The first broad SourceInterface run at
  `Saved/Tests/cache-ic231-test-migration-broad-attempt-1/20260809_193844_659_50791bc1`
  is diagnostic, not GREEN: `35/37` passed. One failure is an obsolete shallow
  Mounts-count offset assertion (`151`) now receiving the intended exact
  MountKey offset (`155`); the other is IC-234's UE 5.8 allocator-slack fixture,
  which stops before invoking Runtime Cache behavior. All new Factory, common
  Handle lifetime, wrong-kind and captured-offset methods in that prefix passed.
- The migration regression is now GREEN at its pre-removal boundary. IC-234's
  allocator-slack assumption was removed without weakening actual-capacity or
  one-byte-short Budget checks. Updating the first shallow offset assertion then
  exposed a stale declaration-order cursor and an incorrectly early exact slot
  precheck. Production now reports the second wire declaration for
  `NonCanonicalOrder`, validates declaration/import slot kinds in their global
  phases with exact occurrence coordinates, and retains local declaration hashes
  before owner validation. After two IC-235 compile-only repair attempts, the
  complete target passed at
  `Saved/Build/cache-ic232-slot-phase-exact-build-attempt-4/20260809_195435_353_c20cb7cf`
  and the full SourceInterface prefix passed `37/37` at
  `Saved/Tests/cache-ic231-source-interface-broad-green-attempt-2/20260809_195448_341_b7ca8c98`.
  This was the final pre-removal baseline; IC-232 remains open for the untested
  coordinate families.
- IC-231 is now closed and SourceIndex/ModuleInterface have one physical Runtime
  decoder authority. `FAngelscriptValidatedSourceIndex`, the public record-specific
  SourceIndex/ModuleInterface deserializers, the old query overload, the test-only
  SourceIndex deserializer and their noncapturing whole-record readers were
  removed. A full `Plugins/Angelscript/Source` search found zero obsolete-symbol
  references. The complete Development Editor target rebuilt and linked `13/13`
  at
  `Saved/Build/cache-ic231-old-decoder-removal-build-attempt-1/20260809_200152_369_0b946304`,
  and the post-removal SourceInterface regression passed `37/37` at
  `Saved/Tests/cache-ic231-old-decoder-removal-tests-attempt-1/20260809_200226_338_f82c8cd2`.
  This closes only decoder duplication, not IC-232, V1.3 as a whole, graph/store,
  warm restore or Editor/PIE/package behavior.
- IC-232 no longer has a second shallow offset model in Runtime. Both old
  `F*ReadOffsets` structs and all uses are gone; physical enclosing-field cursors
  are taken directly at read time, while every semantic coordinate is resolved
  through the retained captured store. The full Editor target passed at
  `Saved/Build/cache-ic232-single-offset-authority-build-attempt-1/20260809_200719_041_e051f77e`
  and SourceInterface stayed `37/37` at
  `Saved/Tests/cache-ic232-single-offset-authority-tests-attempt-1/20260809_200731_450_5686fc81`.
  IC-232 remains open on exhaustive coordinate/index, semantic-routing,
  physical-precedence and retained-allocation/Budget evidence.
- IC-232's next routing batch is GREEN. All `0..89` SourceIndex and `0..88`
  ModuleInterface captured-field values now have compile-time contiguous-enum
  and runtime applicable/missing/unused/out-of-range index-shape coverage.
  Source scalar/graph/ordinal mutations and Module DataType qualifier,
  Parameter trait, Reflection, Import target and Dependency target/content
  mutations report their exact field offsets. The intended Module RED is at
  `Saved/Tests/cache-ic232-module-semantic-routing-red/20260809_202439_496_5fb22a6f`;
  it returned declaration parent byte `102` instead of exact byte `291`. The
  production split linked at
  `Saved/Build/cache-ic232-module-semantic-routing-green-build-attempt-1/20260809_202934_162_1f24b4c9`,
  and the focused table passed at
  `Saved/Tests/cache-ic232-module-semantic-routing-green-attempt-1/20260809_202949_669_1b298a98`.
  The first broad run exposed IC-236's obsolete parent-offset assertion (`39/40`);
  after migrating that preserved six-case test, the complete prefix passed
  `40/40` at
  `Saved/Tests/cache-ic232-exact-nested-sourceinterface-green-attempt-1/20260809_203426_964_3ff46014`.
  IC-232 remains open for optional-present breadth, duplicate/order occurrence
  routing, physical precedence and exact AR-SCR-SI/MI Budget rows.
- IC-232 is now closed. Duplicate/order errors select their first proving wire
  occurrence, invalid optional tags preserve physical precedence, and the complete
  prefix passed `42/42`. A final allocation matrix then inventoried every actual
  allocation of representative non-empty SourceIndex (`29` / `5766` bytes) and
  ModuleInterface (`36` / `5357`), injected failure at each one, and distinguished
  retained, cumulative and combined-peak budgets. It passed focused `1/1`; the
  complete SourceInterface prefix is `43/43` at
  `Saved/Tests/cache-ic232-allocation-sourceinterface-broad-attempt-1/20260809_211152_055_b8b0acbb`.
- IC-228 corrected the remaining-record byte-payload primitive from u32 to the
  frozen u64 wire count before non-empty ModuleState capture. The complete
  RemainingRecordCodec family is now `5/5` GREEN with exact DebugSidecar and
  FunctionBody lengths/offsets updated; identity hash streams were not changed.
- V1.4 now has external and selected-module FunctionBody dependency verticals
  plus ModuleInterface-owned external dependency participation. The focused
  dependency prefix passed `4/4` at
  `Saved/Tests/cache-v14-interface-dependency-green-attempt-1/20260809_234450_228_de5fc0f1`,
  and the established graph prefix remained `13/13` at
  `Saved/Tests/cache-v14-interface-dependency-graph-regression-attempt-1/20260809_234536_554_97d68ed5`.
  This proves relocation-subset comparison, external current-symbol missing/ABI/
  content failures, selected-module ScriptFunction zero-resolver closure, and one
  resolver call when an identical external dependency appears in both Interface
  and FunctionBody. Other selected-module kinds, CurrentLayouts and TypeSchema/
  ModuleState/action dependency breadth remain open.
- V1.4 has its first real CurrentLayouts vertical. A locally valid root UClass
  with ShadowSuper/CodeSuper, an external CodeRoot LayoutInput and exact
  EnvironmentAbi dependency passed `2/2` at
  `Saved/Tests/cache-v14-current-layout-green-attempt-1/20260809_235914_413_850e43ed`.
  The resolver log proves one current-symbol call, one TypeLayoutInput call, zero
  DataTypeLayout/opaque calls; missing result, wrong boundary/alignment and a
  missing required raw coordinate all rejected atomically. The established graph
  prefix remained `13/13` at
  `Saved/Tests/cache-v14-current-layout-graph-regression-attempt-1/20260809_235951_589_c25b5a8c`,
  and the dependency prefix remained `4/4` at
  `Saved/Tests/cache-v14-current-layout-dependency-regression-attempt-1/20260810_000024_900_4281c906`.
  At that checkpoint selected-module BaseType/value DAGs and property DataType
  layouts were still open; the following two bullets supersede that frontier.
- V1.4 property ownership and storage eligibility are now GREEN at the first two
  real routes. The layout prefix moved from intended `2/4` at
  `Saved/Tests/cache-v14-property-layout-red-attempt-1/20260810_000551_381_f16c10c5`
  to `4/4` at
  `Saved/Tests/cache-v14-property-layout-green-attempt-1/20260810_001044_656_46885c7a`.
  A primitive int32 uses the versioned build-layout constants and makes zero
  DataType resolver calls; a stored size/alignment contradiction fails before
  layout-input lookup. An external EnvironmentType uses one canonical DataType
  lookup after its Environment ABI and CodeRoot input, with missing/kind/size/
  alignment failures typed and atomic. The established graph/dependency prefixes
  stayed `13/13` and `4/4` at their property-layout regression artifacts.
- V1.4 selected-module `BaseType` closure is now GREEN. The expanded layout
  prefix moved from intended `4/6` at
  `Saved/Tests/cache-v14-local-base-cycle-red-attempt-1/20260810_002315_197_d1494c7b`
  to `6/6` at
  `Saved/Tests/cache-v14-local-base-layout-green-attempt-1/20260810_002623_430_7ac3a132`.
  A local base declaration is matched by stable TypeKey and declaration ABI; its
  stored boundary/alignment are compared with the linked base TypeSchema, and a
  budgeted iterative color walk rejects self/multi-node base cycles. Valid local
  inheritance makes zero resolver calls for `BaseType` and only the derived
  UClass CodeRoot produces one symbol plus one layout call. Wrong declaration
  ABI, wrong numeric layout and a two-type cycle all fail as
  `GraphAbiMismatch/ModuleGraph` before deliberately wrong source/profile state,
  with zero current calls, an empty output graph and zero temporary resident
  bytes. The established graph/dependency prefixes remained `13/13` and `4/4`
  at the corresponding local-base regression artifacts. This single-parent
  traversal was immediately superseded by the combined inheritance/by-value DAG
  described below.
- V1.4 selected-module inline `ScriptType` value layout is now GREEN. The focused
  layout prefix moved from intended `7/8` at
  `Saved/Tests/cache-v14-local-value-layout-red-attempt-1/20260810_003420_263_5b0fceca`
  to final `8/8` at
  `Saved/Tests/cache-v14-local-value-layout-final-attempt-1/20260810_004017_987_79643fd3`.
  A local value-Struct property is linked by stable TypeKey and declaration ABI;
  its stored size/alignment must equal the target TypeSchema and the target must
  carry ValueType semantics. Production now builds one exactly budgeted adjacency
  graph containing both BaseType and direct InlineValue ScriptType property edges,
  then applies iterative Kahn cycle detection. Valid local inline value layout
  makes zero current/DataType resolver calls; wrong ABI, wrong numeric storage and
  a two-type value cycle fail `GraphAbiMismatch/ModuleGraph` before source/profile/
  current eligibility, with empty output and zero temporary resident bytes. Final
  graph/dependency regressions remained `13/13` and `4/4` at
  `Saved/Tests/cache-v14-local-value-final-graph-regression-attempt-1/20260810_004052_802_de645600`
  and
  `Saved/Tests/cache-v14-local-value-final-dependency-regression-attempt-1/20260810_004126_521_b19e9a0b`.
- The IC-254/IC-255 TypeSchema and TS-SCR closure is now GREEN. A real unbudgeted
  tenth `FlatHeaderOffsets` append was fixed, intrusive-controller accounting now
  uses the allocator's actual charge (`1024` on this UE 5.8 run, not the `960`
  quantization hint), and the independent reference authority now contains the
  exact 78 valid cases after replacing forbidden TemplateCallback rows with the
  omitted ReleaseRefs rows. TS-SCR passed `11/11` at
  `Saved/Tests/cache-ic255-reference-authority-green-attempt-1/20260810_030043_067_a3eb367f`;
  the complete current TypeSchema prefix passed `67/67` at
  `Saved/Tests/cache-ic255-typeschema-full-green-attempt-2/20260810_030403_223_eb384cce`.
  The first complete rerun then isolated IC-227 as the sole failure (`244/245`).
  UE 5.8 validly uses exact reserve capacity for this large typed-array element;
  preserving the independent TCHAR slack witness while accepting the typed exact-
  reserve branch closed that stale test assumption. Archive.Primitives passed
  `13/13`, and the authoritative complete Cache prefix passed `245/245`, failed/
  skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v1-complete-cache-green-attempt-1/20260810_030957_530_7bdf5872`.
- No pointer publication, compiler-hook, Cache-service, GUI Editor cold/warm
  lifecycle, PIE or package behavior is GREEN. The focused runner does initialize
  `UnrealEditor-Cmd.exe` under NullRHI; that is Automation evidence only.
- V2.2 is now GREEN on Win64. The Runtime owns the Store result model, injectable
  atomic-file seam, canonical namespace/final/temp paths, first-launch directory
  setup and immutable Pack/Manifest installation. The combined Store prefix is
  `13/13` and the complete Cache prefix is `258/258`; IC-256–IC-259 retain the
  progressive defect/contract chronology.
- V2.3 now has an all-three-root transaction and strict crash-temp cleanup:
  production StoreDisk is `7/7`, the composed transaction is `17/17`, the Store
  prefix is `62/62`, and the complete Cache prefix is `307/307`.
  It reads all pointer roots under lock, validates each distinct Manifest/Packs
  before mutation, deduplicates duplicate GenerationIds, repairs an unchanged
  corrupt Current without rotating it, and physically proves two-generation
  rotation, reopen and winner no-op. After the lock and directory validation it
  enumerates all three exact directories and removes only the five canonical
  direct temp forms before any root read. Cleanup failure is a sanitized non-fatal
  diagnostic. The writer also applies caller `MaxGenerationPacks` through the
  canonical Manifest validator before lock/filesystem access and proves the exact
  positive boundary. High-level transaction coverage now also freezes cancellation
  after an immutable Pack commit, Manifest write/sync failures, failed and
  indeterminate Current replacement, and a concurrent same-semantic winner with a
  different physical Pack layout. V2.3 is closed at the publication-transaction
  boundary; V2.6 still owns exhaustive named fault-point and concurrent-reader/
  writer evidence, while V2.4 owns pinned readers.
- V2.4 is GREEN on Win64 across pinned sessions, Pending promotion and explicit
  two-phase compaction.
  `OpenReadPinned` owns a real
  delete-sharing file handle whose reads stay bound to the original immutable
  object after its path is unlinked and reused. Manifest validation is now one
  internal Prepare/Complete transaction: it decodes once under the lock, rejects
  Pack-count overflow before Pack opens, pins every distinct handle, releases the
  lock, then validates Packs/records/graph solely through the pinned objects.
  Current-to-Previous-to-optional-Pending fallback shares one monotonic Budget
  and rejects an ineligible Current before Pack pinning. Active selection skips
  Pending; explicit fresh/cold selection may use it. A later Current promotion
  removes only a matching Pending after Current commits and preserves
  `CurrentCommitted` across cleanup failure. The completed compactor requires
  nonzero source/profile authority before any lock/filesystem call. Phase A
  rebuilds the all-root semantic union, removes only an authority-ineligible
  Pending, same-slot switches Previous/Pending/Current, preserves old immutable
  files, then releases/reacquires the lock. Phase B rereads every physical root,
  deduplicates repeated GenerationIds for bounded mark work, preserves an
  intervening publication and sweeps only strict lowercase full-hash final names.
  Every successful final deletion is directory-synced before progress continues;
  cancellation and sync failure preserve the committed rewrite, while a pinned
  sharing refusal is a committed `DeleteDeferred` that does not stop other orphan
  cleanup and is retried by a later explicit compaction. Pointer-switch failure
  leaves a valid old/new mixture without Phase B, and indeterminate replacement is
  reread before reporting committed state. `StoreCompaction` is `12/12`, Store is
  `86/86`, and Cache is `331/331`, with failed/skipped `0/0`.

## Active design/implementation boundaries

1. `StableFunctionKey`, `FunctionSourceDigest`, `FunctionInputDigest` and
   `FunctionContentHash` remain required; the plan rewrite does not remove them.
2. Direct source inputs must be distinguishable from persisted preprocess-derived
   dependency candidates. Lookup may not rebuild the include graph by preprocessing
   before an exact warm decision.
3. TypeSchema Dependencies validate record self-consistency and later graph inputs;
   they are not a file-change classifier or unbounded dependency database.
4. Full clean compile remains the fallback/equivalence oracle. V5.5 now proves
   production graph admission plus clean-versus-cached parity for all eight
   stable invocation families; V6 must preserve that oracle while integrating
   the reusable per-Engine authorities and lifecycle service.
5. Physical records may be granular, but no partial ModuleSnapshot may mutate the
   active Engine.
6. StaticJIT consumes stable function/content/profile/ABI coordinates only; Cache
   Pack/Manifest/Generation and ProviderGeneration stay separate identity domains.
7. 64 MiB is a Pack writer hypothesis. V7 must benchmark 4/16/64 MiB.
8. `Plugins/Angelscript` is the complete authorized implementation surface for
   Cache V2. The maintained AngelScript fork—including builder/compiler,
   bytecode, VM and restore internals—may be extended when that produces the
   coherent artifact hook/restore boundary. This is not restricted to an outer
   Runtime adapter and does not imply a language-syntax change.
9. V2.4's production pinned-session and explicit compaction composition passes
   `12/12` StoreCompaction. Physical root
   retention is independent of active selection: Current/Previous/Pending are
   reread after Phase A, duplicate GenerationIds share one mark decode, and only
   unmarked strict finals are swept. This closes the V2.4 lifetime/GC boundary;
   V2.5 plus real opaque/factory/graph closure raises complete Cache to
   `334/334`. V2.6 then executes every exact named crash point plus recovery and
   real publisher/publisher and pinned-reader/writer interleavings. Store is now
   `91/91`; complete Cache was `339/339` before V2.7. V2.7's standalone Python
   suite is `13/13`; it reads the exact existing C++ Pack/Manifest/Zlib golden
   bytes instead of duplicating Python behavior in a UE test. Complete Cache was
   `340/340` before that redundant one-method test was removed and therefore has
   an expected next-run discovery count of `339`. V3.1 then adds ten methods, so
   the authoritative complete Cache prefix is now `349/349`, failed/skipped
   `0/0`, process/wrapper `0/0`.
10. V3.1's direct digest is an exact safe-miss gate over raw bytes, logical
    coordinates, options, profile and provider/hook authorities. It deliberately
    excludes persisted preprocess/include/generated values. V3.2 now validates
    those bounded candidates from a candidate-scoped observation table without a
    callback or preprocessor path.
11. V3.2 treats direct, unavailable and dependency differences as normal
    non-exact outcomes; malformed, corrupt, duplicate or over-budget data remains
    a typed validation failure. Only Exact returns the rebuilt current
    SourceIndex. V3.3 now owns authoritative production construction of the
    direct projection and observation table.
12. V3.3's producer-side eligibility uses the same matching authority as decoded
    SourceIndex records. V6.1 closes IC-292: production discovery validates and
    prepares one batch, then evaluates all sorted modules under one cumulative
    Budget without forking a second matching algorithm. Batch output remains
    empty and live resident accounting returns to zero on any failure.
13. V3.5 does not deserialize a complete old `FAngelscriptEngine`. Engine B first
    performs normal process-local initialization for native/manual/generated
    binds, engine properties, namespaces, BindState/BindDatabase/TypeDatabase,
    current native addresses, contexts and JIT services. Cache V2 then rebuilds
    only the pointer-free script projection as new live modules, types and
    functions, current numeric FunctionIds, plugin indexes and stable routes.
    Old pointers, numeric FunctionIds, native addresses and preprocessor scratch
    are never persisted. Current proof covers the admitted enum plus a complete
    simple global-function set, including a cached caller relocated to a newly
    compiled current-Engine callee; later verticals must reconstruct class,
    property, inheritance, import and module-state relations before broad startup
    integration can be claimed.
14. V4.1 makes cache reuse policy orthogonal to reload policy. `Initial`,
    `SoftReloadOnly` and `FullReload` continue to own activation/reinstancing;
    `Default` versus `ForceClean` owns persisted-artifact eligibility. HotReload
    currently selects `ForceClean`, clears legacy and incremental loaded hints on
    direct and dependency-cloned module descriptors, and still permits the normal
    current-process JIT handoff after authoritative bytecode compilation. V5 may
    add validated function reuse to this same request surface, but may not remove
    or emulate the forced-clean oracle.
15. V4.2 compares only graph-validated immutable semantic content. Stable
    ModuleKey/TypeKey/FunctionKey owners are joined first; equality then uses the
    full `{kind,BLAKE3-256}` RecordId. PackId, codec, offset, compressed bytes and
    GenerationId are deliberately absent. SourceIndex and ModuleSnapshot roots
    join the reused/new/retired sets, while interface/type/state/body/debug retain
    separate classifications for V4.3/V4.4. Different compatibility/profile
    coordinates and subsequently forged public generation values fail atomically.
16. V4.4 plans only the next deterministic forced-clean module wave. It rebuilds
    declaration, type/property layout, global/hard-value, initializer, import and
    FunctionBody-content authorities from the validated candidate; unresolved
    external targets use the injected resolver and uncertainty is a normal safe
    miss. `Target.ExpectedAbi` is always declaration ABI. ValueLayout and
    PropertyLayout carry TypeLayoutHash/PropertyLayoutFingerprint separately in
    ExpectedContentOrValue, so layout-only edits do not masquerade as declaration
    changes. The planner never activates modules or reconstructs a fresh Engine.
17. V6.3 debug tooling is capability-based, not language-count-based. C++ owns
    live Engine DTO/status, transactional controls and lifecycle timing; Python
    owns Unreal-free persisted-store inspection and richer offline analysis. A
    correct capability does not need a second mechanical implementation in the
    other language. Agreement is tested only at the shared JSON/wire boundaries.
    `as.Cache.Status [Json=...]` and explicit/current-Engine typed Flush plus
    `as.Cache.Flush [Timeout=...]` are now GREEN. Shutdown and explicit Flush use
    one root resolver, so config, command-line and Saved-default selection agree.
    Python now also owns semantic `--diff` and bounded `--explain`; its complete
    suite is `20/20`. The bounded C++ journal retains deterministic publication,
    Flush and packaged RuntimeReload events, shares the Status JSON event schema,
    and `as.Cache.Explain` filters captured events by typed stable coordinates.
    Shallow/deep Verify reuses the pointer/Manifest and full production Store
    validators; Compact reuses two-phase rooted compaction with immutable Current
    authority; ForceClean queues the authoritative compiler transaction and keeps
    last-good on syntax failure. A duplicate C++ `as.Cache.Diff` is deliberately
    absent: Python `--diff` is the formal persisted semantic comparison. The final
    MaintenanceApi prefix is `4/4`, packaged Runtime reload is `7/7`, and the
    complete Cache prefix is `483/483`, failed/not-run `0/0`, at
    `Saved/Tests/cache-v63-final-full-regression2/
    20260811_051548_756_cac5af13`. V6.3 is closed at task `34/43`.
18. V6.4 replaces transient numeric FunctionId persistence with one immutable route
    snapshot owned by each live Engine. Every accepted normal compile or validated
    restore resolves the sole full-width StableFunctionKey authority to the current
    Engine's function pointer/FunctionId, records VM versus Native as transient
    execution state, and publishes a new ordinal snapshot. FunctionBody identities
    are derived only after the complete clean graph validates, then joined by the
    full stable key; they are a pointer-free live handoff, not another persisted
    record or identity algorithm. Body-only reload retained the key while changing
    ExecutionContentHash, failed reload retained the exact prior snapshot, and two
    Engine instances proved numeric FunctionIds cannot resolve across owners. Real
    bounded `StableRoute` events contain stable key/content/profile coordinates but
    no pointer or numeric ID. Focused FunctionRouteSnapshot, FreshEngineRestore,
    ExactWarmRestore and DecisionTrace passed `4/4`, `4/4`, `4/4` and `3/3`; the
    final complete Cache prefix passed `487/487`, failed/not-run `0/0`, at
    `Saved/Tests/cache-v64-final-full-regression2/
    20260811_061428_230_16b5d5f7`. V6.4 is closed at task `35/43`.
19. V6.5 closes the Cache-owned StaticJIT isolation seam without absorbing the
    sibling change's Provider ABI, catalog matcher or Live Coding state machine.
    `RefreshFunctionRouteSnapshotAfterStaticJITChange` runs only after an upstream
    safe-point decision has either applied an already validated provider state or
    rejected it. An accepted state takes the per-Engine RouteRefresh mutation gate
    and republishes the immutable StableFunctionKey-to-current-FunctionId route
    snapshot; a rejected state publishes nothing and retains the exact prior
    snapshot. Tests inject Provider arrival, departure, absence, content/profile/
    entry-ABI/provider-generation mismatch and failed Live Coding outcomes. They
    prove the exact Current, PendingColdStart and LatestSuccessful pointers never
    change, the stable key remains intact, one affected function can fall back to VM
    while an unrelated function stays Native, and a rejected update preserves the
    exact route snapshot. StaticJITIsolation passed `3/3` at `Saved/Tests/
    cache-v65-staticjit-isolation-focused2/20260811_064059_480_cb500973`;
    FunctionRouteSnapshot and DecisionTrace regressions passed `4/4` and `3/3` at
    `Saved/Tests/cache-v65-function-route-regression1/
    20260811_064146_152_2f9eff3c` and `Saved/Tests/
    cache-v65-decision-trace-regression1/20260811_064355_272_91dc91f3`.
    The complete Cache prefix passed `490/490`, failed/not-run `0/0`, errors `0`,
    at `Saved/Tests/cache-v65-final-full-regression1/
    20260811_064632_370_b1327e7c`; the independent Python dump suite passed
    `20/20` at `Saved/Tests/cache-v2-dump/20260811_065533_724`. The broad existing
    StaticJIT run passed all `19` runnable tests; its `11` AOT-dependent tests were
    not valid regression evidence because the matched local
    `StaticJITAotFixture.Cache`/generated-source pair was absent (IC-404). V6 is
    complete and the OpenSpec is now at task `36/43`.

20. V7.1-V7.3 complete the direct production cutover and package-test entry without
    claiming real package acceptance. Cache V2 performs existence-only rejection of
    every fixed legacy `PrecompiledScript.Cache*` name and never opens, migrates or
    hashes those payloads; `Binds.Cache` remains a separate accepted input. Normal
    startup no longer parses legacy generation/ignore/skip-JIT flags, probes or
    writes an old cache, generates it before packaging, or forces process exit for
    generation. The only retained `PrecompiledData` use is the explicitly named
    sibling StaticJIT diagnostic/AOT compatibility bridge inventoried in
    `staticjit-compatibility-bridge-inventory.md`. LegacyCutover passed `4/4`,
    StaticJIT NativeForms `2/2`, and Engine Isolation `14/14`. Packaging now stages
    authoritative Script as loose NonUFS, validates `.as` plus `Binds.Cache` and
    rejects both legacy and packaged Cache V2 baselines. A separate typed
    `CachePackage` suite contains exactly Development and Shipping and remains out
    of `All`; temporary-tree helpers and both dry-run entries pass without building
    a real package. The previously specified but missing C++
    `-as-cache-report=<absolute-json-path>` boundary now emits the same pointer-free
    stable DTO after shutdown flush; SettingsAndShutdown passes `3/3`. Python/C++
    remain complementary: the package process writes C++ session JSON and later
    offline Python inspects/diffs the persisted Store. V7 is at task `39/43`.

21. V7.4 is GREEN after a real affected-prefix defect was found and corrected. The
    first complete HotReload run crashed while formatting a retained consumer
    function whose provider struct type had already been replaced. Route publication
    now receives the transaction's rebuilt-module and dependency-artifact-invalidated
    module sets. Newly rebuilt functions derive identity only from new compiler
    metadata; safe retained functions reuse the prior snapshot's owned stable key and
    declaration; dependency-invalidated retained functions keep only the stable key,
    clear verified content/profile identity and select VM until authoritative
    recompile. No stale AngelScript type metadata is traversed and no persisted wire
    identity changed. The corrected build passed, the exact HotReload dependency
    prefix passed `2/2`, route/StaticJIT/trace regressions passed `4/4`, `3/3` and
    `3/3`, complete HotReload passed `122/122`, complete Cache passed `495/495`, and
    the dedicated generated-AOT StaticJIT workflow passed `30/30`. V7 is at task
    `40/43`; real PIE, real Development/Shipping packages and benchmarks remain.

22. V3.12 closes exact admitted reflection reconstruction. One real reflected
    class crosses an 11-record artifact into an isolated consumer Engine as one
    restored type and three stable routes. Producer and consumer descriptor flags,
    raw UClass/UFunction/FProperty flags, complete metadata maps, argument name,
    default and passing mode agree exactly; reflected execution returns `44`.
    A module mixing that supported class shape with an unsupported native AS
    delegate returns typed `NotCacheable`, clears pre-populated output sentinels
    and leaves the compiled active module, script module, class/delegate inventory
    and route-visible state unchanged. The focused contract is `2/2` GREEN at
    `Saved/Tests/cache-v312-reflection-contract-test2/
    20260811_164406_516_ab218430`; reflection/signature/inheritance/property/
    StaticName/global adjacency is `7/7` GREEN at `Saved/Tests/
    cache-v312-adjacent-regression1/20260811_164456_041_38066073`. V3 is at
    task V3.12; only the promoted multi-class rollback and declaration-order
    invariants remain before the latest broad Editor/package acceptance.

23. V3.13 closes the late multi-class rollback risk without a production-code
    change. A 22-record artifact owns two mutually referencing UClasses and eight
    stable function routes. At injected `AfterModulePrepared`, one private raw VM
    staging module exists while active modules, descriptors and the immutable route
    publication are still unchanged. After the typed `ActivationFailed`/
    `FinalizeModule` return, raw VM modules return from one to zero, all 11,756 VM
    object-type entries match the pre-restore sorted inventory, both descriptor and
    UClass lookups equal their baseline, the exact route-publication pointer is
    retained and none of the eight stable keys resolve. A following authoritative
    compile of the same module and class names succeeds, recreates both cross-links
    and executes to `73`. The Development Editor build is `4/4` GREEN at
    `Saved/Build/cache-v313-multiclass-rollback-build1/
    20260811_165502_874_46bbc2da`; focused behavior is `1/1` at `Saved/Tests/
    cache-v313-multiclass-rollback-test1/20260811_165555_279_fa8c98f3`, and the
    adjacent restore set is `8/8` at `Saved/Tests/
    cache-v313-adjacent-regression1/20260811_165651_953_9dc85d0c`.

24. V3.14 closes the final promoted V3 identity risk. The first opposite-order
    sibling-class test was intentionally RED `0/1`: both 22-record captures had the
    same ModuleKey, but ModuleInterface RecordIds differed because declaration and
    function slot ordinals inherited source/compiler traversal before the declaration
    set was StableKey-sorted. Runtime now performs a deterministic base-before-derived
    topology: among ready siblings it selects case-sensitive namespace/name authority,
    then stable-groups functions by canonical owner while preserving the compiler's
    class-local order. TypeSchema property/method/VFT/behavior sequences, generic wire
    serialization and restore are unchanged. The repair builds `4/4` at `Saved/Build/
    cache-ic462-declaration-order-fix-build2/20260811_171917_127_2c3d8656`; focused
    behavior is `1/1` at `Saved/Tests/cache-ic462-declaration-order-fix-test2/
    20260811_172131_657_8aa2fcd0`, and nine adjacent methods are `9/9` at
    `Saved/Tests/cache-v314-adjacent-regression1/20260811_172243_716_bf94f918`.
    Cache test source inventory is now 94 C++ translation units and 518 methods.
    OpenSpec mechanical progress is `51/53`; only V7.6 and V7.7 remain.

25. The post-V3.14 authoritative Cache run exposed five repairable regressions
    rather than an architectural rollback. Four focused contract/fixture repairs
    are GREEN, while the corrected v5 execution-envelope test exposed and fixed a
    genuine callback-order defect: Factory bytecode referenced constructors before
    their `asCScriptFunction` artifact identity had been initialized. The
    maintained builder now publishes invocation kind and semantic owner at
    declaration time, preserving function-granular StableFunctionKeys for Cache
    and sibling StaticJIT. The explicit lifecycle test transitions from three
    missing constructor keys to three valid forward-reference keys; all 19
    invocation-family artifacts restore without compiler fallback and with exact
    VM/debug/behavior parity. Adjacent identity/dependency tests pass `10/10`; the
    authoritative complete Cache prefix is now `518/518`, failed/not-run/in-process
    `0/0/0`, at `Saved/Tests/cache-v314-full-regression2/
    20260811_181500_343_270718d5`. Mechanical progress remains `51/53`; cross-
    feature HotReload/StaticJIT and current Editor/PIE evidence are refreshed before
    the last Development/Shipping and benchmark tasks.

26. Post-identity cross-feature acceptance is refreshed GREEN: complete HotReload
    `122/122`, official generated-AOT StaticJIT `30/30`, and the combined real
    Cache PIE/EditorLifecycle/HotReload PIESession set `12/12`, all with zero
    failures or unrun tests. The last combined set exercises actual PIE start/stop,
    unchanged warm Current, body and structural reloads, last-good failure policy,
    PendingColdStart and promotion. Only V7.6 Development/Shipping multi-launch
    and V7.7 performance/debug-store evidence remain unchecked.

27. The first real Development packaged matrix corrected two validation-tool
    defects under IC-474, then exposed IC-475 rather than reaching an unchanged
    warm hit. Cold launch published Generation
    `67226cfdcd28741843f2284981b3da1e11d729e210f46761d9ad817ae326b6d6`
    with nine admitted module snapshots, 79 diagnostic records and 56 stable
    function routes. Warm launch selected that same Generation and source snapshot,
    but exact-start restore returned typed `ModuleSetMismatch(9)` because current
    discovery contained eleven modules. The fallback compiled normally and
    republished the same nine-module result with `restoredFromStore=false`.
    Source inspection then proved that production `InitialCompile()`/
    `CompileModules()` never installs the maintained builder's artifact restore or
    compile-result callbacks; only direct Cache tests do. V5 component behavior is
    therefore valid but its production connection is incomplete. V5.6 is reopened
    as an explicit task, mechanical progress is corrected from `51/53` to `51/54`,
    and V7.6/Shipping/performance remain downstream rather than weakening the warm
    assertion or removing the two unsupported real modules.

28. V5.6 Slice 2 closes the first production compiler-reuse boundary without
    weakening exact startup. One selected read session now survives only the safe
    zero-activation `ModuleSetMismatch` path. During authoritative compilation,
    modules finish function layout first; an exact complete SourceSnapshot match
    then permits graph validation and installs per-module restore/result callbacks
    immediately before stage 3. The focused test uses two normal, independent
    `InitialCompile()` calls: cold publication admits one of two modules; warm exact
    restore misses on the two-versus-one set, restores the admitted function by
    StableFunctionKey before its compiler closure, compiles the unsupported module,
    executes both results as `901/902`, and republishes safely. The full Development
    Editor build succeeded across 105 actions at `Saved/Build/
    cache-v56-production-reuse-green-build1/
    20260811_191302_827_020780d8`; focused behavior is `1/1` at `Saved/Tests/
    cache-v56-production-reuse-green-test1/
    20260811_191544_967_beeb8116`. This is an implementation checkpoint, not V5.6
    completion: changed-source/body-edit reuse still needs current pre-compile
    declaration/type/state/function authority rather than reusing persisted exact-
    source authority. Mechanical progress therefore remains `51/54`.

29. V5.6 Slice 3 now has its required production RED. A dedicated body-only edit
    method builds `4/4`, and the production prefix is exactly `2/1/1/0`: the
    earlier partial-Generation method stays GREEN, while the new method cold-
    publishes two function artifacts, changes only one body, starts a fresh Engine,
    reaches typed `DirectInputMismatch`, executes current values `1001/2002`, and
    republishes a different SourceSnapshot. Its sole failure is the absent
    unchanged-function `FunctionLookup/Restored` event at line 388. Evidence is
    `Saved/Build/cache-v56-bodyedit-red-build1/
    20260811_192159_355_948d4777` and `Saved/Tests/
    cache-v56-bodyedit-red-test1/20260811_192219_981_49441350`. This proves the next
    implementation boundary is changed-source candidate retention plus current
    pre-compile semantic authority, not test plumbing or execution correctness.

30. V5.6 Slice 3 primitive/global production behavior is GREEN. A shared
    `FAngelscriptCacheCurrentModuleAuthority` producer now supplies current
    declaration, type, interface and module-state authority after layout and before
    stage 3 without encoding execution artifacts or writing the Store. On changed
    source it never trusts candidate function-content authority; callbacks match
    each current compiler input against the persisted StableFunctionKey and only
    restore an exact artifact hit. The first GREEN attempt exposed and root-caused
    IC-478 because ClassGenerator's enum output pointers do not exist at that hook;
    the phase-correct producer instead validates descriptor enum name and current
    staging-module enum authority. Build `4/4` is at `Saved/Build/
    cache-v56-bodyedit-green-build2/20260811_193206_238_bc12cbf6`; the unchanged
    production prefix is `2/2/0/0` at `Saved/Tests/
    cache-v56-bodyedit-green-test2/20260811_193224_024_f34526db`. The body-edit
    oracle restored the unchanged key, compiled the changed key, executed
    `1001/2002`, and published the complete current Generation atomically.
    Mechanical progress remains `51/54`: authority widening, bounded hybrid
    diagnostics, broad regressions and package acceptance still belong to V5.6.

31. The next Slice 3 production RED proves the complete test Engine can exercise
    the class-cache reconstruction path without Editor or PIE. A dedicated test
    cold-compiles and flushes one reflected root class, destroys that Engine,
    changes only one of two UFUNCTION bodies, creates a second Full Engine, runs
    normal `InitialCompile()`, materializes a UClass through ClassGenerator,
    creates an instance, and executes reflected results `1101/2102`. Cold and warm
    transactions each publish exactly one module; the sole failure is the missing
    unchanged-method `FunctionLookup/Restored` event because current authority
    emits a typed class `NotCacheable`. Build evidence is `Saved/Build/
    cache-v56-class-bodyedit-red-build2/20260811_194054_757_b2b97b37`; RED evidence
    is `Saved/Tests/cache-v56-class-bodyedit-red-test1/
    20260811_194107_096_ff4da2ae`, total/pass/fail/skip `1/0/1/0`. The next code
    boundary is phase-correct root-class authority from the staging VM type and
    preprocessor descriptor, not an Editor-only harness or synthetic cache DTO.

32. The root-class method-only production vertical is GREEN. IC-479 corrected the
    producer's concrete-versus-optional return-type mapping, then IC-480 identified
    the real phase-order gap: generated class invocations retained canonical source
    only after the host had to install restore callbacks. A semantic-only maintained-
    builder preparation pass now runs after successful function layout and shares
    the exact invocation/source retention helper used by stage 3; it does not emit
    callbacks, restore bytecode or invoke the compiler. The affected build passed
    32/32 at `Saved/Build/cache-v56-class-bodyedit-green-build3/
    20260811_195247_870_9fc1c403`. The dedicated two-Full-Engine test passed `1/1`
    at `Saved/Tests/cache-v56-class-bodyedit-green-test2/
    20260811_195331_681_6bc99df3`: 17 decision events show the unchanged reflected
    method restored, the edited method compiled, ClassGenerator produced the UClass,
    and reflection returned `1101/2102`. This is not V5.6 completion; properties,
    class graphs and remaining admitted authority still require focused coverage.

33. The next property-bearing root-class RED is established in its own test file.
    It uses the same production disk-source, virtual-path, InitialCompile, Store,
    two-Full-Engine and ClassGenerator path, but the unchanged reflected method
    reads `UPROPERTY int StoredValue = 31`. Build is 11/11 at `Saved/Build/
    cache-v56-class-property-red-build1/20260811_200333_717_94bcb914`; focused
    behavior is intentionally `1/0/1/0` at `Saved/Tests/
    cache-v56-class-property-red-test1/
    20260811_200356_014_8b219a26`. Stable module/type/property identities, both
    property offsets, defaults `31/31`, execution `1131/2132` and complete
    publications are correct. The only failed contract is unchanged-method restore,
    with exact typed rejection that current root-class authority admits no local
    properties. IC-481 owns the production correction.

34. The property-bearing root-class hybrid now publishes successfully. IC-481
    builds current property declaration/layout authority from staging VM and
    preprocessor data; IC-482 preserves the already graph-validated pointer-free
    dependency provenance of a truly restored function through post-ClassGenerator
    Clean Capture without replaying raw dependency pointers. The correction build
    is `Saved/Build/cache-v56-restored-deps-green-build1/
    20260811_201933_516_dfc27246`, process/wrapper `0/0`; focused evidence is
    `1/1/0/0` at `Saved/Tests/cache-v56-restored-deps-green-test1/
    20260811_202009_776_cc91d84c`. The second batch reports exactly one graph-
    carried dependency set, captures one module with zero skips, publishes the
    changed SourceSnapshot and preserves `48/48`, `31/31`, `1131/2132` plus the
    required Restored/Compiled split. A third-generation consumption proof and
    class-graph/inheritance authority still keep V5.6 open at `51/54`.

35. The property-bearing production fixture now closes the third-Engine repeated-
    startup boundary. It uses three independent Full Engines, a real temporary
    project `Script/` tree mapped through Game virtual identity, a dedicated
    on-disk Cache V2 Store, normal `InitialCompile()`, ClassGenerator, reflection
    and explicit atomic flushes. The corrected build is at `Saved/Build/
    cache-v56-ic483-green-build2/20260811_203104_595_1317d31f`; focused evidence
    is `1/1/0/0` at `Saved/Tests/cache-v56-ic483-green-test1/
    20260811_203125_690_a9ffe86b`. The third Engine selects the warm Generation,
    restores four persisted functions, carries four dependency sets, publishes
    one complete module and preserves `48/48`, `31/31`, `1131/2132`. Exact startup
    correctly reports V3.5 `ModuleIneligible` for the reflected-class shape; V5.6
    hybrid reuse classifies the derived `UClass StaticClass()` helper as typed
    `NotCacheable`, compiles it from current authority and leaves zero unexplained
    FunctionKey misses. This is production-path Engine integration, not a claim
    that final Editor/PIE or Development/Shipping executable acceptance is already
    complete. Class graph/inheritance is the next focused boundary; mechanical
    progress remains `51/54`.

36. IC-489's same-module inheritance current-authority gap is now focused GREEN.
    A dedicated producer reconstructs the base-before-derived type/property/
    method/VFT/behavior authority from staging VM plus preprocessor descriptors;
    candidate schema and later UClass/UFunction pointers are not used as current
    truth. Official adaptive non-unity build `4/4` is at `Saved/Build/
    cache-v56-class-graph-green-build1/
    20260811_210151_995_94bd243b`; the three-Engine production test passed
    `1/1/0/0` at `Saved/Tests/cache-v56-class-graph-green-test1/
    20260811_210208_843_e91246b7`. The edited second Engine reports
    `Restored=1111`, only the changed method compiled, stable offsets
    `48/48/56/56`, reflected `Super::` execution `1020/132` and complete
    publication. The third Engine restores the resulting Generation with zero
    unexplained misses. V5.6 remains open for adjacent/broad regressions and its
    remaining admitted authority/diagnostic surfaces; progress remains `51/54`.

37. IC-489 has crossed the adjacent and complete Cache regression gates. The
    production class family passed `3/3`, all `Cache.ClassGraph` capture/restore/
    rollback tests passed `7/7`, and the complete current Cache prefix passed
    `523/523` with zero failures/skips and process/wrapper `0/0`. Evidence is at
    `Saved/Tests/cache-v56-class-authority-adjacent1/
    20260811_210448_790_8007b5d4`, `Saved/Tests/
    cache-v56-class-graph-adjacent1/20260811_210632_604_b0fc6b24` and
    `Saved/Tests/cache-v56-class-graph-complete-cache1/
    20260811_210811_423_7792b2ec`. Current Authority now covers every shape that
    Clean Capture currently admits: zero-or-one enum plus globals, one reflected
    root UClass, or a two-or-more reflected UClass graph. Structs, delegates,
    imports, typedefs, post-init declarations and multi-source modules remain the
    same explicit typed fail-closed boundary on both sides, not an unimplemented
    Current Authority mismatch. HotReload/StaticJIT/Editor/PIE and V5.6 diagnostic
    acceptance remain next; progress is not advanced yet.

38. IC-490 closes the V5.6 diagnostic/oracle implementation gap. Compile reuse
    now publishes a thread-safe pointer-free run summary into diagnostic schema 4
    after authoritative compilation, while Clean Capture failure events retain
    their bounded reason detail. Separate C++ summary tests pass `2/2`, real
    production partial/body-edit methods pass `2/2`, Python dump tests pass
    `26/26`, and package-helper exact/hybrid/fallback/detail self-tests exit 0.
    Final build evidence is `Saved/Build/
    cache-v56-function-reuse-detail-green-build3/
    20260811_214138_453_1fbe37b2`; production evidence is `Saved/Tests/
    cache-v56-function-reuse-detail-green-test3/
    20260811_214158_583_d23e73a2`. The mechanical count remains `51/54` until
    HotReload/StaticJIT/Editor/PIE and the Development package matrix revalidate
    this latest schema/runtime surface.

39. The first complete Cache regression after IC-490 is GREEN `525/525`, failed/
    skipped `0/0`, process/wrapper `0/0`, no timeout, at `Saved/Tests/
    cache-v56-schema4-complete-cache1/20260811_214725_359_47cc403d`. Both new
    FunctionReuseDiagnostics methods executed inside the complete prefix. This
    advances the current acceptance run, but does not change the mechanical
    `51/54` count until adjacent HotReload/StaticJIT/Editor/PIE and Development
    package evidence also pass.

40. The post-IC-490 complete HotReload regression is GREEN `122/122`, failed/
    skipped `0/0`, process/wrapper `0/0`, no timeout, at `Saved/Tests/
    cache-v56-schema4-full-hotreload1/20260811_220234_137_ce997a2f`. Generated-AOT
    StaticJIT, combined Editor/PIE and Development package evidence remain next;
    mechanical progress remains `51/54`.

41. The official post-IC-490 generated-AOT StaticJIT workflow is GREEN: baseline
    build, commandlet artifact generation, generated-source rebuild and complete
    StaticJIT `30/30`, failed/skipped `0/0`, process/wrapper `0/0`. Final test
    evidence is `Saved/Tests/cache-v56-schema4-staticjit-aot1_04_tests/
    20260811_220610_129_80592a91`. Combined Editor/PIE and Development package
    acceptance remain; progress stays `51/54`.

42. The post-IC-490 combined real Cache PIE, Cache EditorLifecycle and HotReload
    PIESession set is GREEN `12/12`, failed/skipped `0/0`, process/wrapper `0/0`,
    at `Saved/Tests/cache-v56-schema4-editor-pie1/
    20260811_220825_648_ef942b3d`. Real PIE cold/warm, body/invalid/structural
    reload, last-good, PendingColdStart and promotion all execute on the latest
    binary. Development package acceptance is now the last V5.6 gate; mechanical
    progress remains `51/54`.

43. The fresh Development package is partially GREEN and exposed IC-491. Package,
    cold, unchanged warm and body-edit completed; unchanged warm restored 19
    functions and body edit restored 18 while compiling five misses from the same
    cold candidate Generation. `04-invalid-source` then hung because unattended
    Windows startup entered the interactive compile-error Slate modal, so the
    one-hour wrapper returned `124`. The orphan was stopped by exact command line.
    Fix/test noninteractive startup failure handling, resume the package matrix,
    then rerun a fresh Development package. Progress remains `51/54`.

44. V5.6 through V7.6 are now complete. IC-491/492/493 closed unattended invalid-
    source failure reporting; IC-494 closed deterministic package dumps; IC-495
    and IC-496 closed configuration-specific Shipping compile/link gaps; IC-497
    added the Shipping-safe explicit startup-complete acceptance hook. The final
    fresh Development matrix is `7/7` at `Saved/CachePackage/
    cache-v76-schema4-development6-Development/
    20260812_000259_158_0c22d163`; final Shipping is `7/7` at
    `Saved/CachePackage/cache-v76-schema4-shipping4-Shipping/
    20260812_002908_845_b0d46d29`. `tasks.md` now records `V7.6 [x]` and
    mechanical progress is `53/54`.

45. V7.7 production bounded-parallel immutable preparation is implemented. The
    normal writer policy is 64 MiB/four workers with config and process
    overrides; forced serial remains the deterministic oracle. Separate test
    files prove real worker-thread execution, bounds, output clearing,
    serial/parallel byte equality and 4/16/64 MiB grouping, plus writer-policy
    ownership/defaults/clamps. The official 106-action build passed at
    `Saved/Build/cache-v77-writer-policy-green-build1/
    20260812_004755_958_6ebdd738`; combined focused tests passed `6/6` at
    `Saved/Tests/cache-v77-writer-parallel-green-test1/
    20260812_004931_819_965c666d`.

46. The fresh bounded-parallel Development archive at `Saved/CachePackage/
    cache-v77-parallel-development1-Development/
    20260812_005543_023_59f48f29` passed all seven real launches after the
    ModuleState fixture was corrected to a supported const global. The complete
    V7.7 benchmark `cache-v77-real4` then passed 61 package processes and emitted
    56 accepted rows: 14 groups, one warmup and three measured each. Serial/
    parallel semantic and physical parity passed for every target. The tiny
    32.7 KiB single-Pack corpus does not show a performance win: warm median is
    26.7% slower than cold and parallel medians are 0.40–1.45% slower than
    serial. This limitation is explicit in IC-503, the benchmark analysis and
    both guides; no time threshold or speedup claim is fabricated.

47. The only failure in the previous 37-shard parallel All was root-caused as a
    Windows `core.autocrlf=true` checkout conflict with strict LF Standalone wire
    fixtures, not a Cache or UE Automation failure. A narrow `.gitattributes`
    rule and fixture normalization closed it; the official Standalone suite is
    now GREEN `19/19` at `Saved/StandaloneTests/
    cache-v77-standalone-lf-green1_01_Standalone/` (run timestamp recorded in its
    metadata). Fresh post-writer-policy Shipping is also GREEN `7/7` at
    `Saved/CachePackage/cache-v77-parallel-shipping1-Shipping/
    20260812_012557_854_9584ba9c`: 41 Shipping actions plus Cook/Stage/Archive
    and every schema-4 report/dump launch passed in `226078 ms`. Latest complete
    Cache remains running before the final parallel All gate.

48. The post-writer-policy complete Cache prefix is GREEN `536/536`, failed/
    skipped `0/0`, with official wrapper exit `0` at `Saved/Tests/
    cache-v77-final-complete-cache1/20260812_012618_824_19ba7032`. The remaining
    acceptance gate is the independent official four-slot CoarseDynamic `All`;
    V7.7 stays unchecked until that aggregate is green and audited.

49. The first 37-task four-slot All completed `2969/2970` in `1089506 ms`;
    Cache `536/536` and Standalone `19/19` remained green, while one Debugger
    setup exposed IC-504's cross-process test-port collision. The test Session
    now validates listener readiness, rejects occupied explicit ports and retries
    bounded automatic candidates. Final build, occupied-port `1/1` and complete
    Debugger `39/39` are green. A fresh parallel All is the only acceptance gate.

50. The second four-slot All proved the Debugger fix under real collision (two
    failed candidates recovered, Debugger `39/39`) and reached `2970/2971` in
    `963532 ms`. Its only failure was IC-505: concurrent editors raced UE's
    shared AssetRegistry `.ref.tmp` writer while Compiler happened to be active.
    Parallel Unreal shards now receive `-NoAssetRegistryCacheWrite`; the runner
    self-test is green and complete Compiler passed `81/81` with the exact flag.
    A third fresh parallel All is the remaining acceptance gate.

51. The third and authoritative four-slot All is GREEN `2971/2971`, failed
    shards/tests `0/0`, across all 37 tasks in `943955 ms` at `Saved/Tests/
    cache-v77-final-all-parallel3_20260812_022730`. Cache passed `536/536`,
    Debugger `39/39`, Compiler `81/81` and Standalone `19/19`. Every UE command
    line carried `-NoAssetRegistryCacheWrite`, the aggregate logs contain zero
    shared AssetRegistry move errors, and both IC-504 and IC-505 are closed.
    `tasks.md` is now `54/54`; V0–V7.7 are complete.

52. Pre-archive OpenSpec status/strict validation passed, then the official
    archive command synchronized 48 deltas into three main specs and moved this
    record to `archive/2026-08-11-refactor-as-incremental-function-cache`. All
    three resulting specs pass strict validation. Full-repository validation is
    `127` valid plus one unrelated existing failure in
    `docs-as-mutable-global-feasibility`; no change was made to that sibling.

## Immediate executable work

1. No implementation or verification gate remains. Preserve the benchmark's
   explicit no-speedup limitation and archive this completed OpenSpec change.

## What is explicitly not current work

- no changes to Bind_AActor or unrelated binding layout;
- no edits to project/business `.as` scripts merely to simulate cache behavior;
  maintained AngelScript C++ fork sources inside `Plugins/Angelscript` are
  explicitly in scope when Cache V2 requires them;
- no subagent execution unless explicitly requested again;
- no worktree creation, commit, stage, push or parent gitlink update;
- no real PIE or Development/Shipping package run before V6 focused behavior is
  ready;
- no claim that the existing Editor can use Cache V2 before V3/V6 integration.
