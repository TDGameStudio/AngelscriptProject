## Context

The accepted [scoped design](attachments/drafts/design.md) and [handoff](attachments/drafts/handoff.md) establish the product decisions. The [source finding](attachments/drafts/findings/change-readiness-20260916.md) records current unique registration, unsupported live APIs and production DirectBinds. Tasks own implementation ordering and exact proof.

## Goals / Non-Goals

Deliver actual process-owned host TypeInfo/functions shared across receiving Engines, safe admission and lifetime, modern live registration, full eligible production integration and configurable Blueprint writes. Keep script objects private and preserve stable symbol identity.

The exclusions in proposal.md and the inherited-work disposition below are intentional. No dormant backend is re-enabled. Future implementation uses the existing maintained SDK construction, parsing, native ABI and registration services.

## 1. Object origin and ownership

| Origin | Construction | Engine field | Lifetime / identity |
|---|---|---|---|
| HostProcess | Registration callbacks on Collection-owned asCDefinitions | Permanently null | Graph retained by Collection and consumers/callable leases; process IDs fixed before injection |
| ScriptEngine | Engine-free Builder definition output | Null until unique registration, then exact receiver | Private graph and runtime bytecode retained by its owning Engine/resources |
| LiveRegister | Explicit SDK Register calls | Receiver at creation | Engine-local objects/state; private identity and cleanup |

asETypeInfoKind/typeInfoKind are explicit on both type and function, not inferred only from native/script flags. Existing script/object flags still describe ABI and language shape. A host type with a C++ native flag is not automatically admitted into every Engine.

FAngelscriptBindCollection remains the host owner. The SDK retains a graph lease for admitted use so releasing the external Collection handle cannot dangle an Engine directory. Internal recursive references do not form permanent strong cycles. Immutable native system interfaces can be shared; mutable overrides and auxiliary generations are owned locally.

## 2. Registration APIs and mixed closures

InjectDefinitions(const asCDefinitions&) validates a frozen HostProcess root and dependencies. It stages name/key/ID changes and required lifetime references before committing directory publication. On failure, no staged entries become visible and pre-existing objects remain usable. Reinjecting the identical root into the same Engine returns AlreadyRegistered without duplicate retention; a fresh Engine admits it independently.

RegisterExternalDefinitions keeps the existing script Install+Link transaction and private ownership transfer. A mixed closure may reference an already-injected host graph, but traversal must not write that host graph's engine, ID tables, Attached state or retirement state. Missing host admission fails the private batch. RetireExternalDefinitions retires private ownership; Engine shutdown only detaches shared host admission.

Both registration directions check conflicts: a live/private name can prevent injection, and an injected host name prevents an incompatible live declaration. Namespace and overload identity remain significant. Do not reject valid unrelated overloads simply because an unqualified string matches.

## 3. IDs, lookup and execution

Use asCTypeIdRegistry and its allocator for dynamic type/function numbers. Freeze reserves HostProcess IDs once; Inject only indexes them. Keep fixed primitive/use bits, non-reuse and overflow checks. StableKey, schema and layout hash meanings do not change with vocabulary migration.

Context.Prepare identifies the receiver through its Context, verifies exact admitted host pointers and required types, and checks callability/retirement. Uninjected C must reject A/B's shared host function. Private script/live functions still require their exact owner. Script Prepare still needs Registration-written runtime bytecode; it never compiles or links implicitly.

AcquireSystemInterface preserves current local publication/native override precedence, then falls back to the admitted process function interface while retaining its graph. Object headers and Context identify allocation/cleanup ownership. Audit delegate creation, JIT diagnostics and any HostProcess-reachable Function/Type.GetEngine consumers. Shared userData cannot hold one Engine's mutable sidecar.

## 4. Live Register reconstruction

Reimplement the existing public object/member, global, nominal and type-service APIs on the maintained backend. Keep their signatures and established return/error convention. Directly created LiveRegister objects have a valid receiving Engine and participate in its name/ID queries, native binding and cleanup. Do not revive removed funcdef APIs or expose disabled code as a supported switch.

RegisterObjectType/Property/Behaviour/Method must preserve explicit C++ size/alignment/offsets, generic/typed callers, construction/destruction and qualified names. Global function/property registration retains the actual native target/storage address per Engine. Interfaces, enums/values and aliases have local nominal identity. String factories and default-array selection use admitted definitions but local configuration; factory object ownership follows the existing public contract.

A rejected declaration cannot increase published member counts or replace an earlier target. Attempts to modify frozen HostProcess members fail without touching other Engines. New live declarations can reference admitted host types; a specialization using any script/live argument is private.

## 5. Collection, phases and production migration

Retain the current phase enum, author default ExplicitBindings and implicit UE_MODULE_NAME. Each eligible registration callback runs once per collection and directly constructs or extends real definitions. No descriptor replay during injection, whole-type declaration prepass or production-only DirectBinds bypass remains at completion.

Shells, base relationships, by-value layout and member signatures observe dependency barriers. The original descriptor-model interpretation of TypeDeclarations as only an installation step is obsolete. Missing targets, invalid cycles/layout and missing required executable targets fail before a usable owner is returned with source/registration/stage diagnostics.

The imported registration inventory is historical evidence, not proof of current eligibility. Refresh it against actual source, then migrate Core, Math, Containers, ObjectsReflection, EngineGameplay and EngineServices, recording every eligible/excluded/no-output site. External extension modules remain supported through the existing authoring boundary; broad public-directory reorganization is not required.

Production BindScriptTypes and explicit CreateForBindings converge on the retained collection and Inject. Required adapter/TypeFinder restoration, container operations, delegate storage and auxiliary reentry needed by this surface belong to their owning migration task.

## 6. Templates and Blueprint writes

Create host-closed specializations once on the host graph, including their actual VM-callable members. Script/live-argument specializations and mutable operations remain per Engine. Eliminate the moved-Draft late Set dereference; changing only the null access without fulfilling callable templates is insufficient.

Blueprint snapshot/lazy FuncMap prewarming occurs on GameThread. Run a shell wave, join, establish base/shadow/canonical relations, then run class-local member waves. Each worker claims one UClass by atomic Next++ and exclusively owns its tables. Short shared identity/index locks cannot expand to an entire callback. Properties use ExcludeSuper; the definition-owner lookup path must honor the same inherited relation rather than relying only on the old live-engine shadow path. Static global writes and global duplicate scans remain serial. UStruct semantics are unchanged.

Read as.Bind.WriteWorkers once per run: default 1; 0 normalizes to 1; N>=2 selects bounded worker execution. Retain as.Bind.ParallelPrepare independently. Verify deterministic 0/1/2/4 results and controlled overlap, not a noisy speed ratio.

## 7. Vocabulary, compatibility and retained observation

The [glossary](attachments/drafts/glossary.md) is the approved mapping. Rename the definition container, results, state type, registration APIs, dependency helpers, lookup tables and selected source files across maintained consumers. A migration-only first node keeps the build coherent. Internal new helpers/tests follow inspected conventions and are recorded in task interfaces.

Keep the existing inspection surface meaningful for the new frozen graph, including symbol/provenance and omission diagnostics, without promising manifest v2. Existing retained runtime/Builder specs contain a bounded set of formatting failures; the final document task owns exact indentation-only repair alongside the semantic merge. No current spec is edited during this creation delivery.

## 8. Predecessor dispositions

| Old objective | Replacement disposition |
|---|---|
| Descriptor database, PreparedBindings, per-Engine host materialization | Superseded by Collection/HostDefs/Inject |
| Complete Runtime registration and external extension behavior | Carried into direct collection and six family migrations |
| Template members and required adapter/native/delegate/auxiliary safety | Carried into relevant ownership/template/family tasks |
| Isolated parallel fragments and detached preparation | Replaced by ordered direct construction and class-level Blueprint writes |
| Full directory relocation | Deferred; only required ownership changes are included |
| Manifest v2 / comprehensive inspection rewrite | Deferred; preserve affected existing inspection semantics |
| Complete performance/memory/Insights program | Deferred; worker configurability, equivalence and overlap remain included |

The archive closure supplies all 24 incomplete-task dispositions and successor references, preserving the old UID and body.

## 9. Verification and risk

Each behavior card states concrete independent outputs, failure invariants and one exact selector. The first compile proof covers cross-module renames; behavior groups then observe RED/GREEN against matching binaries. New selectors actually contain their declared cases, including adapted controls from both existing Isolation classes. Zero discovery and operations-only substitutes fail.

Risks include hidden Engine reads on shared objects, accidentally retiring shared dependencies, unsynchronized name/global tables, insufficient production registration accounting and live-registration parser/ABI gaps. Resolve local evidence inside its bounded task; replan only if it invalidates scope, dependencies or acceptance. No automatic Review is introduced.

Final verification covers the affected definition/registration/identity/VM/source-execution contracts and migrated binding cases with recorded source/binary identities. It is justified by this shared contract change, not a daily whole-suite rule. Full performance and unrelated UE suites remain omitted. Product implementation is not authorized in the current planning-only delivery.
