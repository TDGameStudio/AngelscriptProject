---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-08T13:12:51.634300+08:00
reviewed_at: 2026-09-08T13:15:40.054624+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260908-131251-vm-drain-final-acceptance
snapshot_sha256: b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f
verdict: APPROVE
---

## Assignment and verification story

Continuing the user's requested fixed-snapshot acceptance reconciliation, covering all eight historical Reviews (F01–F10, P01–P05, R01–R04, V01–V04, W01–W02, X01–X04, Y01 and Z01). The assigned immutable copy contains runtime implementation, the NativeEngine tests, the Change and supplied execution evidence. All 1,102 manifest entries and the manifest digest were authenticated. The final source identity is `3a9195feac747d5e8f6e7685bb028e3221968d68250a0cb72fc91ce9156b55f0`; all 2,318 source entries and four built DLL hashes still match the coordinator's frozen identity. No implementation was edited and no broad gate was repeated during this Review.

Read tests first: all twelve VMRuntimeDrain cases, native-generation ownership/reentrant value cleanup tests, then focused call/frame/return/indirect/index/lifetime admission fixtures and source unwind controls. Inspected their owning object allocation/release, Engine/GC/operation retirement, Context cleanup admission, snapshot detach, native candidate/acquisition/publication, and verifier CFG/ABI/lifetime paths. Compared the original resolution conditions with the task-specific evidence and final task/opcode/source mapping. R below is Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source; T is Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine, inside the immutable copy.

Supplied complete NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080 Success with zero warnings; shared VM 4d86afaf614c494a8d945050b4e2f2ca is 467/467 with zero warnings. Runtime-drain Stomp b4148c96bb2a4f559091818265c3b2ce is 12/12 with one HTTP startup timeout warning, and its Unreal log confirms the Stomp allocator. Independent Baseline a53eca61567847c29d74e5dbbab70a02 is 3/3, retaining 2,436 MetaSound registration warning events. This is bounded behavioral and memory-checking evidence, not exhaustive race/fuzz coverage.

## Z01 and original F05: runtime ownership and ordered cleanup

The prior defect is repaired in R/as_vm_object.cpp:44–92, :111–198; R/as_scriptengine.cpp:1126–1140, :5158–5243; R/as_scriptengine_metadata.cpp:154–210; R/as_context.cpp:573–585, :819–820, :1176–1210; and R/as_execution_snapshot.cpp:43–56.

Each SDK payload acquires an Engine object lease and AddRefs its Type before publication. Free captures the owners, unregisters/frees payload storage, releases Type and finally releases its Engine lease. Detached allocation remains supported for the previously accepted metadata-only alignment fixture. Engine operations hold their own references, and retirement does not clear IDs, executable bodies or image attachment while objects, active operations or an ongoing retirement drain still need them. Shutdown atomically closes ordinary admission first. Native/global binding and executable publication all reject the requested retirement state.

Script destructors use a private PrepareForVmCleanup entry on a dedicated Context, under an owned cleanup operation. Ordinary Prepare/Execute remain closed. Active execution and cleanup can make temporary allocations while public allocation after shutdown is rejected; the temporary cleanup authority is restored before the operation's final drain. Execute's operation lifetime extends beyond active-context TLS restoration. GC retains the Engine and metadata until the collector and discarded-module processing return; its drain guard prevents recursive collection from object release. An outer callback-triggered shutdown therefore collects an unreachable SDK cycle after the outer operation returns. Final retirement detaches caller-held snapshots from their publisher before releasing Engine publication leases, avoiding a later callback through a dead Engine.

The tests now prove the formerly missing distinction. OnlyObjectRetainsNativeCleanupAfterHostAndProducerRelease and OnlyObjectRetainsScriptAndCrossSnapshotCleanupThenExpires drop producer, caller snapshot and actual host Engine ownership, then observe the exact destructor count and final weak metadata expiry. The script destructor calls a helper from another snapshot. The GC case needs no surviving fixture Engine or explicit post-release GC call. Independent safe ownership assertions precede the dangerous final-owner transition. Other cases establish retained script destruction, suspended-root unwind, callback cycle cleanup before Execute returns, active cross-snapshot continuation during concurrent shutdown, caller snapshot release after Engine expiry, temporary allocations in both cleanup paths and rejected global replacement preserving the original storage address. Historical extra-owner fixtures were balanced; their counts alone are no longer used to infer ownership.

Grouped RED 8f9eea1bc3e6481db0c9a09c4c14bb22, supplemental bb8c043935f84e9eaecfbd2af1dbed86 and actual global-rebind RED f7efe3123e024700a4348a9012f14379 are distinct from the earlier incomplete crash, compile errors and fixture setup failures. Those failures and corrections remain in runtime-drain-verification.md. Z01's concrete resolution conditions are satisfied by task 8.7 and the supplied final proof.

## Y01 and original F02: immutable native generations

R/as_bytecode_linker.cpp:937–980 prepares an owning declaration/descriptor candidate before entering the publication lock, checks live generation at commit and replaces the installed shared descriptor without invalidating active owners. Invalid candidates preserve the old callback. Consumers acquire the exact descriptor generation; the previous generation is released outside locks and expires after its last consumer. Runtime call layout replaces lazy mutation of frozen declaration argument fields. The seven VMNativeBindingLifetime cases prove 41/42 old/new callbacks, failed replacement, shutdown rejection, reentrant replacement and transferred-value cleanup, concurrent acquisition, metadata readability and weak-generation expiry. The reentrant value fixture retains the null argument-slot and unchanged declaration-layout assertions. Task 7.4's original stomp/RED/GREEN evidence is preserved, and all seven pass in the current full run. Y01 is resolved.

## Historical condition reconciliation

| Findings | Resolving work and concrete current evidence | Disposition |
|---|---|---|
| F01, P03, R01/R02, V01/V02/V04, W01, X01–X04 | 6.1–6.13 and 11.4: authenticated argument storage and RET/body ABI; complete signed physical frame spans without result-width truncation; indirect expected signatures through codec/CFG/runtime; both conditional edges and every bounded indexed-table successor. Direct/decoded/manual malformed controls reject before execution, legal counterparts execute literal results, and indexed exceptions recover to 97. | Resolved |
| P04, R03, V03, W02 | 6.8/6.12: per-CFG allocated/constructed/uninitialized state, compatible joins, real init/free sites and managed type consistency. Skipped constructor, bypass, repeated destruction and non-first table paths reject. Reconstruction/exclusive branch controls pass; real source exceptions retain exact reverse destructor traces and Context recovery. | Resolved |
| F02, P01/P02 | 7.1–7.4 and 8.7: separate immutable executable/runtime records, synchronized acquisition and candidate publication, conflict/failure rollback, owning Context/frame/snapshot/native leases and nonrecursive absent-code handling. Native replacement and final runtime drain are covered above. | Resolved |
| F03 | 9.1–9.3: all 213 assigned ledger rows match individually successful report identities; supported variants have explicit execution/state/lifetime oracles, retired STR and reserved/pseudo values have explicit rejection dispositions. | Resolved |
| F04, P05 | 8.1/8.2, 6.11 and final adjacent CallableSDK cases: native ABI callbacks/values/receivers/sentinels, full indirect target shape, delegates and receiver cleanup. The three former CallableSDK failures retain original 42/signature/destructor oracles and now execute the explicit call-site ABI. | Resolved |
| F05 | 8.3–8.7: object domain/allocation identity, atomic retained references, partial construction and root/weak/GC cases, Context boundaries, plus actual Type/Engine/code ownership and ordered script/native drain detailed above. | Resolved |
| F06 | 6.1 and 11.1/11.2: complete compatibility witnesses, schema/layout/type-use/native-shape mismatches, producer-free definitions, independent destination storage and atomic failed admission. | Resolved |
| F07 | 10.1/10.2: typed source operations, runtime-input numeric and representation oracles, source/definition/target admission with owned diagnostics and no partial image for unsupported forms. | Resolved |
| F08 | 10.3–10.5, 11.2 and 6.8: formal/default/side-effect mapping, lexical scope transitions and constructed-only reverse unwind, source/call-site observations, return-97 recovery and cache survival after producer release. | Resolved |
| F09, R04 | 11.3/11.4: exact frozen source/four DLL/report hashes, all 55 task selectors, 213 opcode rows and 112 source-producer identities represented by actual Success cases. Cache failures have replacement passing evidence. Historical crashes, setup failures, baseline GREEN and irrecoverable earlier RED gaps remain historical; none is relabeled as new behavioral RED. | Product/evidence conditions resolved; coordinator owns final lifecycle state |
| F10 | 6.1/6.2/11.1: bounded strings and resource budgets, independently authored complete minimal wire vector, canonical resource remapping and full-section roundtrip with atomic decode failure. | Resolved |

The detailed per-task and public-case inventories are supplied in final-runtime-drain-acceptance.md and the preserved earlier task-specific evidence. Aggregate GREEN is corroboration, not the replacement for the condition-by-condition ownership above.

## Verdict and remaining coordinator work

APPROVE. No open Critical or Required finding remains in the assigned implementation and evidence. The review does not claim complete source-language support, Standalone/JIT/UE reflection integration, unrelated suite coverage, exhaustive fuzzing or race-sanitizer proof. Those are the accepted explicit boundaries, not omitted required repairs.

The coordinator must preserve original finding text, append these resolutions and supersede the historical CHANGES_REQUIRED snapshots with ordered real lifecycle times; then complete final task state, durable spec synchronization and terminal/archive validation. This report itself remains state: open until the coordinator records closure. Approval does not fabricate historical tests or silently archive the Change.

## Coordinator closure

Closed 2026-09-08T13:17:22.117476+08:00 after reviewing the supplied APPROVE result. All eight historical reports are superseded with original observations preserved and finding-specific repair evidence appended. Task 11.4 continues through specification and terminal/archive checks.
