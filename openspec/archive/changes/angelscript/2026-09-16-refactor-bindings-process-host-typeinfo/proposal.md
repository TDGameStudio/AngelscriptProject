## Why

Runtime binding construction currently has two incompatible entry paths: production BindScriptTypes directly calls mostly disabled SDK Register APIs, while test capture retains descriptive BindInfo and creates separate type/function objects for each Engine. The accepted model instead creates stable C++ host definitions once and injects their identical pointers into multiple Engines. That changes SDK ownership, execution admission and definition lifetime, not only a binding wrapper.

The user approved this scope and naming in bindings-gap-audit Q65-Q68 on 2026-09-16. Creation is planning-only; no product task is executed by this delivery.

## What Changes

- FAngelscriptBindCollection directly constructs and retains frozen HostProcess definitions and native interfaces with process-wide type/function IDs.
- InjectDefinitions admits the same host graph into multiple Engines transactionally. Context admission requires exact receiving-engine membership; graph sharing does not grant execution authority.
- RegisterExternalDefinitions keeps script objects private and transfers only their owned definitions, even when their dependency closure includes shared host definitions.
- Reconstruct current live Register object/member/global/interface/enum/alias/string/default-array families on the maintained SDK. LiveRegister objects belong to one Engine and cannot change frozen host definitions.
- Route production binding creation and all eligible Runtime registration families through collection/injection, preserving external extensions, provenance, actual container calls and required adapter/native lifetime behavior.
- Add class-level Blueprint creation/member workers with the approved barriers and as.Bind.WriteWorkers behavior; retain independent Prepare configuration.
- Apply the approved Definitions/Registration vocabulary and reconcile old ownership specs and tests.

## Capabilities

### New Capabilities

None. These changes belong to existing SDK and binding capabilities.

### Modified Capabilities

- angelscript/language/types/definitions: origin-aware definition ownership, shared immutable host graphs, private script transfer and graph leases.
- angelscript/runtime/type-registry: pre-Engine host identity and identical pointers/IDs across admitted Engines; live registration remains private.
- angelscript/runtime/binding-engine: reusable collection-based engine creation and isolated mutable sidecars.
- angelscript/runtime/vm: receiving-engine admission, shared native targets and exact local execution ownership.
- angelscript/bindings/runtime: direct host collection, full production coverage, template origin and configurable Blueprint writes.
- angelscript/language/frontend/builder: renamed definition outputs and immutable shared host dependencies without Engine construction.
- angelscript/runtime/bytecode: link private source against an admitted shared host graph without transferring host ownership.

## Scope and Non-goals

The maintained Plugins/Angelscript submodule owns product implementation, SDK APIs, runtime binds and replacement tests. Parent-repository work owns the Change and eventual durable spec synchronization. Source/AngelscriptProject remains minimal; unrelated uncommitted changes remain outside scope.

No legacy startup or test-corpus reactivation, MetadataImage, removed RegisterFuncdef, UHT generator, executable disk cache or hot replacement of a published collection. Full Core/Math/etc. directory rearrangement, manifest v2 and comprehensive performance/memory/Insights measurement are deferred. Required production/ownership safety repairs cannot be deferred merely because an independent larger adapter/delegate project is excluded.

## Impact

Shared host identity requires coordinating SDK definitions, registry, registration, Context/VM and native leases. Script ownership and bytecode publication stay private. Live registration is a positive capability reconstruction: rejecting every call with asNOT_SUPPORTED cannot pass. Blueprint worker correctness and actual overlap are tested separately from performance claims.

The predecessor angelscript/refactor-bindings-two-stage-pipeline was archived as superseded on 2026-09-16 after this plan was complete. Its 24 unfinished tasks retain dispositions in the archive; none are marked completed. The replacement's [handoff](attachments/drafts/handoff.md), [vocabulary](attachments/drafts/glossary.md) and [source evidence](attachments/drafts/findings/change-readiness-20260916.md) are self-contained English exports.
