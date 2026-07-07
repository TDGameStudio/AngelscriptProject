## Context

`FAngelscriptBinds` is the AngelScript bind framework wrapping AS engine `RegisterObjectMethod` / `RegisterObjectBehaviour` / `RegisterGlobalFunction` / `RegisterObjectProperty` / `RegisterGlobalProperty` / `RegisterEnum` calls. It serves ~120 hand-written `Bind_*.cpp` files plus generated `ASRuntimeBind_*` / `ASEditorBind_*` shards. Today every registration call writes a static global `FAngelscriptBindState::PreviouslyBoundFunction` (`AngelscriptBinds.cpp:78-86`, `:530-554`); subsequent free functions like `SetPreviousBindIsEditorOnly` / `DeprecatePreviousBind` / `MarkAsImplicitConstructor` (15 entry points) read it back to mutate the just-registered `asCScriptFunction`.

This couples register and trait-set into a strict same-thread, immediately-adjacent sequence. Across hundreds of callsites, the pattern is so pervasive that any future Prepare/Commit split (already shipped for `Bind_Defaults` / Phase 2A/2B with `as.Bind.ParallelPrepare`, see `Bind_BlueprintType.cpp:1370-1591`) cannot generalize without first breaking this contract. Appendix A of `Documents/Plans/Plan_BindParallelization.md` documents the exact constraint and rules out lock-free surgery on the AS fork as out-of-scope per `AGENTS.md`.

The user-approved exploration plan (`C:\Users\scottmei\.claude-internal\plans\fangelscriptbinds-c-unified-cat.md`) selected this refactor as the next step. It does **not** itself produce performance gains — it removes the structural prerequisite for the next OpenSpec change to extend Prepare/Commit beyond `Bind_Defaults`.

## Goals / Non-Goals

**Goals:**

- Replace the static `PreviouslyBoundFunction` ↔ `SetPreviousBind*` coupling with `FBoundFunction` / `FBoundProperty` return-value, member-method chaining.
- Migrate all hand-written `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/*.cpp` callsites (~120 files) to the new chained API.
- Preserve trait write semantics byte-for-byte: type counts, method counts, function-id sequence, `Binds.Cache` binary content all unchanged.
- Maintain backward compatibility for downstream plugins / submodules: legacy free-function trait setters keep working with `[[deprecated]]`.
- Ship two co-located low-risk optimizations: pre-sort cache for `GetSortedBindArray()`, per-bind timing instrumentation hook (dev-only).
- Document Phase 1.1 / Phase 2 / Phase 3.1 closure in `Documents/Plans/Plan_BindParallelization.md`.

**Non-Goals:**

- No performance contract. Total `CallBinds` time may move ±10 % from the cache change but no other speedup is promised.
- No generalization of Phase 2A/2B Prepare/Commit beyond what already ships (next change).
- No build-time codegen extensions to `AngelscriptUHTTool`.
- No removal of legacy `SetPreviousBind*` / `DeprecatePreviousBind` / `MarkAsImplicitConstructor` / `CompileOutPreviousBind*` / `PreviousBindPassScript*` API entries; they keep behaving and only gain `[[deprecated]]`. Removal is a future cleanup change.
- No edits to AS engine fork (`asCArray`, `asCMap`, `defaultNamespace`, `nextScriptFunctionId`).
- No FBind-constructor parallel `Add` work (analytically not the hot path; left as plan-appendix open question).

## Decisions

### Decision 1 — Return-value chained API instead of removing legacy entirely

`FAngelscriptBinds::BindMethod` and siblings will return `FBoundFunction` (a 4-byte handle around `int32 FunctionId`). Existing callers that ignore return values keep compiling. Existing callers that follow with `SetPreviousBindIsEditorOnly(true);` keep compiling because legacy free-functions stay (with `[[deprecated]]` warning).

**Alternatives considered:**

- **Hard-replace** — delete `SetPreviousBind*` and `PreviouslyBoundFunction` entirely. *Rejected:* invalidates ~120 callsites in a single PR, plus any external `Plugins/AngelscriptGAS` / downstream user binds. Massive blast radius for zero perf gain in one shot.
- **Leave the static, add chained on top** — keep `PreviouslyBoundFunction` as the only source of truth, layer chained `.EditorOnly()` over it. *Rejected:* defeats the purpose; the static still pins the threading contract. Future Phase 2A/2B generalization cannot rely on chained API in worker threads if it still routes through the static.
- **Chain via lambda capture** — return a wrapper holding a captured trait-mutator lambda, evaluated lazily at commit time. *Rejected:* over-engineered for current need; trait setters need to run synchronously within the bind lambda anyway because asEngine writes happen there.

The chosen approach is **additive return-type evolution + opt-in migration + `[[deprecated]]` legacy**. Lowest risk, allows incremental migration, future cleanup change can finish removal once warning count is zero.

### Decision 2 — `FBoundFunction` reuses existing static-mutator implementations

Each chained method (`.EditorOnly()`, `.Deprecate()`, …) internally calls the same trait-write path (`Function->traits.SetTrait(asTRAIT_EDITOR_ONLY, true)` etc.) currently in `AngelscriptBinds.cpp:466-528`. The only diff: it reads `this->FunctionId` instead of `GetPreviouslyBoundFunctionRef()`. Trait-write semantics are byte-identical → equivalence proof is trivial.

### Decision 3 — `OnBind()` keeps writing `PreviouslyBoundFunction`

During migration, mixed call patterns exist (new chained API + legacy free-function calls in same bind lambda). Both paths must work. `OnBind()` continues to write the static so the legacy free-functions read the correct id. Chained API path is independent of the static.

When migration completes (all callsites converted, legacy free-functions warning-free), a follow-up cleanup change can remove the static write and the legacy API together.

### Decision 4 — Pre-sort cache invalidated only via `ResetBindState()`

`GetSortedBindArray()` (`AngelscriptBinds.cpp:182-187`) currently copies + sorts the static `GetBindArray()` on every call. Since `RegisterBinds` is the only writer and only runs during static init / `LoadModule`, post-init the array is stable. Cache is a `static TArray<FBindFunction> CachedSortedBinds` plus `static bool bSortCacheValid`. Set valid on first sort. `ResetBindState()` (used by tests) clears it. `RegisterBinds` does **not** invalidate (binds register before first `CallBinds` always — observable behavior unchanged).

### Decision 5 — Per-bind timing under `WITH_DEV_AUTOMATION_TESTS || AS_PRINT_STATS`

Per-bind timing hooks into the existing `FAngelscriptBindExecutionObservation` infrastructure (`Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptBindExecutionObservation.h`) which already runs under `WITH_DEV_AUTOMATION_TESTS`. Add a sibling `RecordBindTiming(FName, int32, double)` API plus an exposed `GetRecordedBindTimings()` accessor for tests / log dumps. Shipping path stays zero-cost.

`AS_PRINT_STATS` is also recognized as an alternative gate so production-style timing dumps work for performance investigations on Test/Development non-automation builds. Output format: a single `UE_LOG(Angelscript, Log, ...)` summary at end of `CallBinds` listing top-N slowest binds plus per-`EOrder` tier totals.

### Decision 6 — `Method()` template wrappers in `AngelscriptBinds.h:196-383` change return type

The 18 overloads of `Method()` and similar template wrappers around `BindMethod` / `BindExternMethod` currently return `void` or `int`. They become `FBoundFunction`. Existing call patterns ignoring the return value compile unchanged. Variants that return `int FunctionId` for downstream `CompileOut*` chains: the existing free `CompileOut*(int)` retains its signature; new `FBoundFunction::CompileOut*()` overloads chain on the wrapper. Both work.

### Decision 7 — Migration is mechanical for the dominant pattern

```
Foo.Method("…", METHOD(C, F));  FAngelscriptBinds::SetPreviousBindXxx(arg);
```

becomes

```
Foo.Method("…", METHOD(C, F)).Xxx(arg);
```

A regex-driven rewrite catches >80 % of callsites. Hand-converted minorities: multi-line setups, `CompileOut*` chaining with `int FunctionId`, places that capture `GetPreviousFunctionId()` for later use. Each hand-converted file is reviewed manually; mechanical edits are spot-checked.

## Risks / Trade-offs

- **Risk: trait-write order regression** — chained `.EditorOnly().Deprecate(…)` evaluates left-to-right; legacy `SetPreviousBindIsEditorOnly(true); DeprecatePreviousBind(...);` does the same. Identical order. → Mitigation: snapshot `asCScriptFunction::traits` for sample binds before/after; binary diff equal.
- **Risk: rare callsite captures `GetPreviousFunctionId()` for use across multiple trait calls** — chained API loses access if not tracked. → Mitigation: `FBoundFunction` is copyable/movable; keeps the id; `auto FB = Foo.Method(...);` pattern works. Hand-review during migration.
- **Risk: `asEngine` not seeing trait set when chained method is on a temporary** — temporary lifetime extends to end of full-expression, all chained calls evaluate within that lifetime. C++ standard guarantees. → Mitigation: unit test asserts trait flags equal post-chain.
- **Risk: Phase 2A worker threads accidentally use chained trait setter that touches `asCScriptFunction*`** — that would be a regression of the current Prepare/Commit guarantee that AS engine writes are GameThread-only. → Mitigation: chained trait setters internally `check(IsInGameThread())` in `WITH_DEV_AUTOMATION_TESTS` builds; documented in `FBoundFunction` comment block.
- **Risk: pre-sort cache stale across hot-reload / live-bind scenarios** — `ResetBindState()` is the documented reset path used by tests; live hot-reload of bind module DLLs is not supported in the current architecture (binds are static-init only). → Mitigation: explicit `check`/`ensure` in `RegisterBinds` if it runs after the cache is populated, fail fast in dev builds.
- **Risk: ~120-file mechanical migration introduces silent errors** — automated rewrite + manual review + automation-test parity (counts, ids, Binds.Cache binary diff) bounds this.
- **Trade-off: `[[deprecated]]` warnings become noisy** — once migration completes, tens of legacy calls remain temporarily for downstream compatibility. Mitigation: gate `[[deprecated]]` on `AS_DEPRECATE_PREVIOUS_BIND_API` macro defaulting to `1`; downstream plugins can `#define` it `0` for a release cycle if they need silence.

## Migration Plan

1. **Stage A — additive types and methods** (no callsite touched yet):
   - Add `FBoundFunction` / `FBoundProperty` to `AngelscriptBinds.h`.
   - Add chained-method overloads on `FAngelscriptBinds` returning these.
   - Land cache + timing instrumentation. Run full test suite. Ship as commit 1.

2. **Stage B — mechanical migration** (dominant pattern):
   - PowerShell / Python regex rewrite all `*.cpp` files under `Binds/`. Build, run automation, diff `Binds.Cache`. Spot-check 5 random files. Ship as commit 2.

3. **Stage C — manual migration** (residual complex callsites):
   - Hand-convert files where regex didn't match (multi-line, capture-id, `CompileOut*` chains). Build, run, diff. Ship as commit 3.

4. **Stage D — `[[deprecated]]` and docs**:
   - Add `[[deprecated]]` to legacy free-functions. Update `Documents/Plans/Plan_BindParallelization.md`. Ship as commit 4.

**Rollback:** Each commit is independent. Reverting commit 4 restores warning-free legacy. Reverting commits 2-3 restores callsite uses. Reverting commit 1 removes new types. No persistent state is migrated; rollback is purely code.

## Open Questions

- Should `FBoundFunction` be `[[nodiscard]]`? Pro: catches accidental `Foo.Method(...);` patterns where the caller forgot to chain. Con: floods diagnostics for legitimate fire-and-forget binds. **Tentative: no nodiscard for now**, add if migration reveals high accidental discard. Decided in tasks.md task 1.4.
- Should `FBoundProperty::PureConstant<T>(value)` be templated on the value type, or take `asQWORD ConstantValue` directly mirroring the legacy `SetPreviousBoundPropertyPureConstant`? Tentatively templated, since current usage is uniformly typed-callsite. Decided in tasks.md task 1.5.
- Naming: `EditorOnly()` vs `IsEditorOnly()`? Legacy is `SetPreviousBindIsEditorOnly`. Choose method-name style consistent with chained fluent APIs in UE codebase (e.g. `SParameters::IsEditorOnly()` patterns). **Tentative: `EditorOnly()`** (terser; chained APIs favor verbs/adjectives over `Set*`). Decided in tasks.md task 1.2.
