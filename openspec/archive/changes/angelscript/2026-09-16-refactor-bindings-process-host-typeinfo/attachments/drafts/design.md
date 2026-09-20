# Accepted design: collect and inject process-owned host definitions

English export of the selected local design: topic angelscript/bindings-gap-audit, scope host-collect-inject. Originally drafted 2026-09-15; accepted 2026-09-16 in Q66-Q68 after Q65 added live registration reconstruction. Historical pending labels in the working draft were resolved by these answers. Identifiers and the accepted decisions are preserved.

## Problem and outcome

Production BindScriptTypes currently runs DirectBinds against SDK Register entry points that return asNOT_SUPPORTED. The fixture recording path stores descriptions and materializes different TypeInfo objects for each Engine. Late template materialization can still reference the emptied Draft set. Replace this model with callbacks directly constructing actual host types and functions, retained once in a process collection and injected into multiple Engines.

## Scope and exclusions

Include direct host construction, process IDs, shared definition lifetime, transactional injection, execution admission, native interface leases, production registration migration, actual container calls, required adapter and auxiliary lifetime integration, Blueprint class-level parallel writes, the approved naming changes, and reconstruction of existing public live Register families.

Exclude a UHT generator, executable disk cache, MetadataImage, legacy startup reactivation, replacement of an already published binding collection, a separate descriptor database, PreparedBindings as the shared object, and a separate Host/Script definitions base class. Do not retain a production DirectBinds bypass. Whole-tree directory reorganization, manifest v2 and the complete performance/memory/Insights program are explicitly deferred. Independent comprehensive delegate/adapter redesign is deferred, but fixes required by the admitted production surface and sharing safety are included.

## Ownership and data flow

FAngelscriptBindCollection owns frozen HostDefs. Each eligible registration callback directly creates asCObjectType/asCScriptFunction instances on asCDefinitions. Callbacks do not see an Engine. EAngelscriptBindPhase remains the actual ordering boundary; ExplicitBindings remains the author default. OwnerModule continues to come from UE_MODULE_NAME. External registrations may extend existing types before sealing, preserving source/module provenance and executable native targets.

HostProcess types and functions have typeInfoKind=HostProcess and permanently null engine. Their immutable system calling interface lives on the process function. Freeze assigns the shared type and function IDs through the existing process registry. Host-closed template instances join this graph; any specialization involving ScriptEngine or LiveRegister arguments belongs to its receiving Engine.

InjectDefinitions(const asCDefinitions&) enters identical pointers in each receiving Engine's name/key/ID tables. It does not move the collection, write engine, mutate IDs, or transition the shared bag to Attached. A fresh Engine can inject the same graph independently. The Engine-side consumer and active callable/native leases keep the owning graph alive; destroying one Engine only removes its admission and mutable sidecars. Last-owner cleanup happens exactly once.

ScriptEngine definitions use the same asCDefinitions type, but RegisterExternalDefinitions transfers their unique ownership, writes their receiving Engine and retains the Attaching/Attached states. A second Engine rejects the same script ownership with ForeignEngine. Mixed dependency closure checks already-injected HostProcess dependencies without transferring, retiring or changing those shared dependencies.

LiveRegister definitions are created by explicit SDK Register calls and belong to their receiving Engine. They cannot overwrite a shared host name or mutate its methods, properties, behaviours or frozen layout.

## Construction ordering and Blueprint writes

Create shells before resolving base relationships or by-value layout dependencies, then finalize layout and members according to the current phase contracts. Missing extension targets and recursive value layouts fail collection before publication. Keep stage barriers; phases are not concurrently registered.

Blueprint collection takes a GameThread reflection snapshot and prewarms FuncMap. A fixed worker group uses atomic Next++ to take one UClass at a time. Each worker exclusively owns that class's member tables. Shared identity/index publication uses bounded synchronization rather than one lock across entire callbacks. Join shell creation before setting base/shadowType relations, then run the member wave. Blueprint properties use ExcludeSuper and inherit through shadowType; UStruct is not implicitly changed. Static global-function writes stay serial.

as.Bind.WriteWorkers controls only creation/member write waves: default 1, 0 treated as 1, N>=2 enables the bounded worker count. Preparation remains independently controlled by as.Bind.ParallelPrepare. Equivalent 0/1/2/4 results and evidence of concurrent class work are required; no unmeasured speedup or parallel default is promised.

## Execution and error contracts

Context.Prepare derives the executing Engine from Context. HostProcess does not bypass admission: that Engine must have injected the exact callable and required definitions, be accepting execution, and resolve a valid native target. A third Engine without injection rejects it. Script and live functions retain exact-owner rejection.

AcquireSystemInterface first preserves Engine-local publication/override semantics, then may use the shared process function interface with an owning lease. Auxiliary data, mutable adapters, object cleanup and nested cross-Engine calls remain local to the executing owner. Audit HostProcess-reachable GetEngine consumers, including delegate creation, object allocation/cleanup, type queries and JIT diagnostics; changing only Prepare is insufficient.

Inject preflights graph kind, freeze/layout, names, keys, IDs and dependencies. Any failure leaves receiving maps and already-live consumers unchanged. Reverse collision with a previously registered LiveRegister type also rejects the whole injection. Registration of script closures and failed native publication obey the same no-partial-callability rule. StableKey and fingerprint meaning do not change because identifiers are renamed.

## Live Register reconstruction

Q65 explicitly includes a maintained implementation, not enabling the dormant backend. Retain existing public signatures for RegisterObjectType, RegisterObjectProperty, RegisterObjectBehaviour, RegisterObjectMethod, RegisterGlobalFunction, RegisterGlobalProperty, RegisterInterface, RegisterInterfaceMethod, RegisterTypedef, RegisterEnum, RegisterEnumValue, RegisterStringFactory and RegisterDefaultArrayType. Do not reintroduce removed RegisterFuncdef.

Prove positive lookup and actual execution, invalid declaration/offset/target rejection without partial tables, host-name/member protection, symmetric injection conflicts, and independent same-name live types in A/B. Type services resolve admitted types and keep their state per Engine. Live declarations may reference admitted immutable host types but cannot mutate them. Retired Engines reject new work while existing cleanup retains its required resources. This does not promise arbitrary runtime hot mutation of already-published code.

## Vocabulary and migration

The approved [glossary](glossary.md) owns names, including asCDefinitions, asSDefinitionOptions, asETypeInfoKind, InjectDefinitions, RegisterExternalDefinitions, RetireExternalDefinitions and asEDefinitionState. Remove the selected Image-era metadata names in the maintained SDK. Exclude list-pattern/fingerprint families, Legacy, UE UMETA and unrelated comments.

The old descriptor/per-Engine materialization plan is superseded, not marked implemented. Preserve its UID, body and uncompleted tasks in the archive with per-task successor/defer dispositions. Migrate all eligible Runtime registration sites and external extension behavior needed by production; do not silently omit registrations because a sample fixture works.

## Verification and current-spec impact

Minimum proofs: shared type/function pointers and IDs with null Engine; surviving consumer after producer/A release; rejecting uninjected C; script unique ownership and mixed host closure; normal live registration plus both conflict directions; host-closed versus owner-local templates; actual VM/native outputs; Engine-local auxiliary and adapter restoration; Blueprint serial/parallel equivalence and inherited member lookup; production entry routing.

Use both families in RuntimeBindingIsolationTests.cpp, retaining their foreign-call, owner, adapter, nested auxiliary and replacement-generation controls. Historical Array crashes and Calls.Native failures are baseline observations, not new pass evidence.

Durable updates cover language/types/definitions, runtime/type-registry, runtime/binding-engine, runtime/vm, bindings/runtime, language/frontend/builder and runtime/bytecode. Preserve script isolation while replacing the old requirement that every host TypeInfo pointer differs per Engine.

## Evidence and carryover

Read [current source evidence](findings/change-readiness-20260916.md), [execution contracts](findings/three-engine-contracts.md), [identity and VM](findings/stable-key-and-vm.md), [phase ordering](findings/keep-bind-phases.md), [Blueprint workers](findings/blueprint-worker-pool.md) and [Blueprint inheritance](findings/blueprint-parallel.md). The [handoff](handoff.md) records the confirmed work route and four carryover items. This is a planning-only creation; no implementation, build or Automation result is claimed.
