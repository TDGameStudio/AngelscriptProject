Source: angelscript/bindings-gap-audit, designs/host-bind-completion. Accepted 2026-09-16, Q69-Q78. Create authorization: user 2026-09-16 request to create the Change (flipped Q77=B).

# Complete host freeze and Store-test cleanup

## Draft / Problem

The previous Change landed a shared HostProcess graph, but production still copies only eight names and editor `BindScriptTypes` still runs `ExecuteRegisteredBinds`. Old `RuntimeBindings.*` tests still prove Store/Apply. Three surfaces remain, so plugin binds are not proven on the inject path.

## Success Criteria

- Temp Prepare/Execute plus bind logs prove a bound engine before product freeze work. `TArray` / `FString` / `FVector` / `Print` run after `InitializeWithoutInitialCompile`. `asCBuilder` compile is after inject.
- Every registered bind enters one seven-phase `ExecuteToHost` and freezes. TypeInfrastructure and ReflectionBindings are no longer skipped.
- `BindScriptTypes` injects only. Failure fails startup. There is no Installation and no replay of migrated host types.
- Scheme gates S1-S6 and perf gates P1-P4 all pass (verification-gates.md). No "must be faster" threshold.
- Recording/Store tests and the Store/Apply production path are retired. Family executable contracts move to Host fixtures.
- New tests use one method per scene and prefer `.as` for the post-inject surface.

## Evidence

remaining-bind-coverage.md, old-runtimebindings-catalog.md, verification-after-host.md, verification-gates.md, host-test-style.md. Archived Change `angelscript/2026-09-16-refactor-bindings-process-host-typeinfo` is the prerequisite. Do not reopen its design.

## Scope and Exclusions / Constraints

In: remove the whitelist, freeze all seven phases, editor inject-only, no-arg CreateForBindings uses Collection, S1-S6/P1-P4, migrate/retire old tests by bucket, delete Store/Apply at the end.

Out: UHT, disk cache, manifest v2, wholesale directory rearrange, legacy revival, hot replacement of a published engine, keeping all 310 old tests green as-is, unadapted Legacy Performance, WriteWorkers speedup, Insights full traces, unconditional Quick/Integration.

Do not reopen host-collect-inject. Engine ownership still cannot be inferred from a shared definition.

## Options / Decision and Rationale / Flip Condition

Keeping the descriptor library as a second production path would make "all binds green" forever describe the wrong surface. The user chose one Change, editor inject, all seven phases in one freeze, Store deletion in this Change, and S1-S6/P1-P4 as the gates. If evidence shows Blueprint reflection cannot finish the host graph before freeze, replan. Do not silently restore DirectBinds.

## Architecture, Components, and Data Flow

```text
all FAngelscriptBind
  -> EnsureProcessHostCollection (no whitelist)
  -> ExecuteToHost, seven phases
  -> freeze HostProcess
  -> BindScriptTypes / CreateForBindings inject only
```

A write to a host type after freeze must fail. Blueprint class writes still use `as.Bind.WriteWorkers` and write Host types on the Collection.

## Failures and Edge Cases / Verification

S1-S6 / P1-P4 are completion gates. Numbers go in attachments/data/. Test style is host-test-style.md. Ensure plan owns exact Harness commands.

## OpenSpec Handoff

- ID: `angelscript/refactor-bindings-host-full-inject` (Q76=A).
- Title: Finish process-host binding by injecting the full frozen graph.
- Capabilities: `angelscript/bindings/runtime` (primary); `angelscript/runtime/binding-engine` if the create/inject contract changes.
- Artifacts: English proposal/design/spec deltas/tasks, index, planning-validation. Tasks: product freeze and entry, scheme gates, perf gates, family migration, Store retirement, spec sync.
- Authority: create and Ensure plan. Product implementation waits for a later apply instruction unless the user continues immediately.

## Exploration Carryover

The create authorization accepts this recommended carryover (the full log stays local):

| Kind | Source | Target | Reason |
|---|---|---|---|
| talk | Q73/Q74; design | talks/editor-inject-only | Prevent reopening editor replay |
| talk | Q71/Q75; catalog | talks/store-corpus-retirement | Prevent treating Store tests as the green gate |
| talk | Q78; verification-gates | talks/scheme-perf-gates | Prevent relaxing S/P gates or adding "must be faster" |
| knowledge | BindScriptTypes inject-only | knowledges/bindscripttypes-inject-only.md | Reusable entry contract |
| knowledge | verification-gates | knowledges/host-scheme-perf-gates.md | Reusable completion gates |
| knowledge | host-test-style | knowledges/host-test-readability.md | Reusable test style |

Export design/handoff/glossary and the findings those rows cite. Temporary navigation and the full transcript stay local.
