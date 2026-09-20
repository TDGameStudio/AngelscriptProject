Source: angelscript/bindings-gap-audit, designs/host-collect-inject; accepted 2026-09-16 in Q65-Q68.

# Accepted scoped handoff

## Draft / Problem

The selected [design](design.md) replaces recorded recipes and per-Engine TypeInfo materialization with directly created shared HostProcess objects. Existing production registration reaches unsupported SDK entry points; explicit live Register reconstruction is included by Q65.

## Success Criteria

A and B share frozen host type/function pointers, stable keys and process IDs with null GetEngine; uninjected C cannot execute them. Releasing the external collection and A leaves B callable, with final cleanup exactly once. Script ownership remains unique, including mixed host dependencies. Live registration executes normally without changing host definitions or another Engine. Production BindScriptTypes and eligible registrations use the collection/injection path. Host templates execute real members. Blueprint worker values 0/1/2/4 yield equivalent semantics with default serial writes.

## Evidence

The [source check](findings/change-readiness-20260916.md) and the five focused findings linked by design.md supply current boundaries. Current source and accepted design supersede early discarded descriptor proposals.

## Scope and Exclusions / Constraints

Include host graph ownership, transactional admission, modern live registration families, required production/template/adapter/native integration, configurable Blueprint writes and approved renames. Execution ownership comes from Context or object ownership; use the existing ID registry. No legacy startup, removed funcdef API, MetadataImage, UHT generator, disk cache or published-collection hot replacement. Full directory rearrangement, manifest v2 and comprehensive performance/memory observation are deferred. Sharing-related safety and usable production adapters are mandatory.

## Options / Decision and Rationale / Flip Condition

Q40/Q41 selected a new Change and superseded archive because shared pointers contradict the old accepted architecture. Reuse Collection and asCDefinitions rather than a new library or base hierarchy. Host injection retains shared lifetime; script registration transfers only its private definitions. Evidence invalidating admission/lifetime requires replan rather than silently returning to copied host objects.

## Architecture, Components, and Data Flow

Registration callbacks construct the host graph in ordered phases, then Collection owns its frozen form. InjectDefinitions populates Engine-local directories atomically. Context admission checks exact injected membership and a valid callable lease. Engine native overrides precede immutable process interfaces. Script registration retains unique private objects; explicit Register calls create Engine-owned live objects. Blueprint workers own classes and synchronize between shell, base and member waves.

## Failures and Edge Cases / Verification

Cover duplicate names/keys/IDs, missing dependencies, invalid layout, uninjected calls, failed publication, either-consumer destruction, script ForeignEngine, host mutation from live APIs, mixed template arguments, native auxiliary reentry and inherited Blueprint members. Each behavior task observes grouped RED/GREEN and actual execution rather than counts. The creation delivery validates records only.

## OpenSpec Handoff

- Change: angelscript/refactor-bindings-process-host-typeinfo.
- Title: Share process-owned host definitions and restore engine-local registration.
- Capabilities: language/types/definitions; runtime/type-registry; runtime/binding-engine; runtime/vm; bindings/runtime; language/frontend/builder; runtime/bytecode, all under angelscript.
- Required artifacts: proposal, design, durable deltas, tasks, INDEX and planning-validation.
- Task boundaries: vocabulary migration; host graph; injection; script closure; Context/native calls; live registration families; collection/templates; production families; Blueprint writes; final affected regressions and spec synchronization.
- Once this replacement is complete as a record, supersede and archive angelscript/refactor-bindings-two-stage-pipeline with all 24 unfinished-task dispositions. Preserve its identity/history.
- Q67 authorizes planning and that archive only. Do not execute product tasks in this delivery.

## Exploration Carryover

Q68 approved exactly these four items:

| Kind | Source | Target | Reason |
|---|---|---|---|
| Talk | Q20-Q39, Q48-Q50, Q60/Q61; accepted design | ../talks/talk-20260916-024548-host-definition-ownership.md | Preserve the shared-host/private-script choice and two admission APIs |
| Talk | Q51-Q58; worker/phase findings | ../talks/talk-20260916-024548-blueprint-write-boundaries.md | Preserve class work units, barriers and serial default |
| Knowledge | execution-contract/StableKey findings and source check | ../knowledges/host-definitions-execution-ownership.md | Reusable admission, identity and lifetime rules; candidate |
| Knowledge | Blueprint inheritance/worker findings | ../knowledges/blueprint-class-write-boundaries.md | Reusable prewarming and exclusive class writes; candidate |

Export design, handoff, glossary and necessary evidence in English. Keep the full transcript and unselected alternatives local. No Change link depends on the local draft.
