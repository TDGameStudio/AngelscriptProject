# Diagnostics, ABI Freeze And Final Verification Notes

## Scope

This attachment records Group 8 implementation evidence, design clarifications,
test iterations, and final verification results. `tasks.md` remains the concise
checklist; this file preserves the progressive detail requested for problems
encountered during implementation.

## Diagnostic surfaces

The existing `as.StaticJIT.DumpDiagnostics` command and schema revision 2 are
unchanged and remain the authoritative loaded-Provider/AOT route diagnostic.
The new non-Shipping `as.JIT.DumpDiagnostics` command reports the Engine-local
coordinator and Runtime tier through a deterministic pointer-free schema
revision 1. It accepts `-Function=<declaration-or-function-key>` and
`-Output=<json-file>`.

The coordinator snapshot contains:

- execution mode validity and Runtime configuration validity/error;
- selected Runtime BackendId and compile policy;
- Runtime factory/session availability and debugger/coverage gate;
- per-function requested and actual tier, Static match result, Runtime
  profile/state/reason, revision and canonical declaration;
- compile attempts/results/stale/cancel totals, active operations, latency,
  code size, execution markers, and live/retired code-lease counts.

`FAngelscriptStateSnapshotBuilder` observes this data only through
`FAngelscriptJITDiagnostics::CaptureSnapshot()`. The Dump implementation does
not include or inspect coordinator-private state tables, queues, sessions, or
leases. The generic console command uses the existing
`AS_WITH_STATIC_JIT_DIAGNOSTICS` exclusion, while coordinator/state collection
methods are absent under `UE_BUILD_SHIPPING`; the remaining public capture
entry returns an empty snapshot in Shipping.

Static generation diagnostics are carried by pointer-free
`FAngelscriptStaticJITGeneratorOutput`: requested Static BackendId, Bytecode or
VerifiedTypedHIR capture profile, deterministic fallback chain, and each
function's final actual BackendId/disposition plus ordered backend
attempt/disposition/detail records. Loaded AOT Provider
diagnostics remain the responsibility of the unchanged Static command rather
than being relabelled with generation-time provenance that the Provider ABI
does not persist.

## Compile and execution markers

The Static backend contract already records each function's actual BackendId
and disposition. Group 8 adds explicit requested backend/capture/fallback task
diagnostics and preserves the reason from every per-function backend attempt,
so BytecodeJIT and TypedASTJIT tests can prove which producer ran and why a
fallback occurred.

Runtime compile attempts and terminal results are counted in the shared request
state machine. Published Runtime Bindings now enter through a Runtime-owned host
trampoline. The trampoline resolves the immutable Binding context from
`FScriptExecution`, increments an atomic execution counter, and then invokes
the backend's real VMEntry while the maintained-fork Binding reader continues
to retain the context, session, and code lease. No public AngelScript test hook
was added.

The `RuntimePublicationDoesNotMutateTheAotProviderRegistry` and source-boundary
coverage from Group 7 continue to prove these markers do not publish Runtime
code as an AOT Provider or persist it in Cache V2/typed-HIR storage.

## Runtime ABI freeze

The external Runtime backend contract is frozen for the first MIR/LLVM plugin
implementations at:

```text
FAngelscriptRuntimeJITBackendAbi::Revision = 2
FAngelscriptRuntimeJITBackendAbi::EntryAbiRevision = 1
```

The contract suite statically checks standard-layout/trivially-copyable ABI
values and explicitly asserts revision 2. Its fake factory/session harness is
the conformance oracle for metadata validation, duplicate IDs, platform and
configuration selection, serialized/concurrent compile calls, cancellation,
typed result validation, malformed snapshots/elements, code-lease release, and
shutdown behavior. A concrete MIR/LLVM module must compile against the public
repository header and pass this harness before advertising revision 2.

Any future public layout, enum semantic, validation vocabulary, helper-token,
or result-contract change must bump the Runtime backend revision. The separate
Entry ABI revision changes only when the host call shape changes.

The internal Static contract, stable IDs `bytecode` and `typed-ast`, complete
graph versus emit-set separation, and generation-only Engine seam were already
committed in Groups 2 and 3. They are the handed-off prerequisites for
`feature-as-typed-semantic-aot`; that change does not consume the Runtime
snapshot ABI.

## TDD iterations and implementation incidents

The initial diagnostics RED build failed on the intentionally absent
coordinator diagnostic types and generator-output fields:

- `Saved/Build/jit-group8-diagnostics-red/20260814_054214_526_0edc187f`.

Implementation introduced the pointer-free snapshot/JSON surface, Runtime
execution trampoline/counter, Static requested/capture/fallback metadata, and
public-observer state-dump rows. Compile iteration exposed and closed three
issues:

1. the first implementation used `Invalid` where the maintained enum names the
   value `Unknown`;
2. moving Runtime publication through the host trampoline requires the full
   maintained-fork `FScriptExecution` definition, so the `.cpp` now directly
   includes `as_context.h` rather than relying on unity order;
3. a full non-unity action exposed that
   `AngelscriptStaticJITGenerationSnapshot.h` used `AS_CAN_GENERATE_JIT`
   without directly including `StaticJITConfig.h`; the header now declares its
   own prerequisite.

An outer launcher timeout left an already-running UBT/XGE child during the
first iteration. The exact process IDs were inspected and stopped before the
next build; a second XGE maximum-build error was therefore an orchestration
incident, not a product failure. Later commands use the repository runners with
their own timeout and no competing invocation.

The state dump originally narrowed 64-bit compile/execution counters through
`int32`. Final self-review added a `uint64` count-row overload so observer
snapshots preserve the complete marker value. The first overload spelling made
existing AngelScript `asUINT` rows ambiguous between `int32` and `uint64`; the
RED compiler output exposed this immediately, and the wide path was renamed to
the dedicated `AddUInt64CountRow` helper without touching existing rows.

The same review found that a final BytecodeJIT result overwrote the preceding
TypedASTJIT unsupported detail. New RED assertions require ordered backend
attempts and a task-level capture error. The generator now owns and preserves
each attempt's BackendId, typed disposition, and detail while final Provider
packaging continues to consume only the selected emitted function. Provider
identity, generated source, and Provider ABI remain unchanged.

Shipping review also tightened the difference between “command absent” and
“inspection unavailable”: coordinator/state collection methods no longer
compile in Shipping and the remaining public capture entry returns an empty
snapshot. Development tests additionally execute the registered generic
command with both `-Function` and `-Output`, reload its JSON file, and verify
the exact Runtime execution marker.

The first complete StaticJIT-prefix run exposed an older Group 3 completeness
edge through the new diagnostics fixture: a global `UFUNCTION` synthesizes a
reflection-only `Module_*Statics` class whose `ScriptType` is intentionally
null. Snapshot capture previously copied a zero descriptor key from that null
type, and the correct fail-closed completeness check terminated the fixture
compile. The focused RED reproduction is
`Saved/Tests/jit-statics-identity-red/20260814_062624_341_3b1e31a6`.
Generation capture now derives the synthetic class identity from the stable
module key, namespace, `Class` entity kind, and canonical `class <name>`
declaration—the same authority used by Cache clean capture. The strict
completeness check remains unchanged. The incremental build and exact GREEN
regression are respectively
`Saved/Build/jit-statics-identity-green-build/20260814_062756_823_8ea50e23`
and
`Saved/Tests/jit-statics-identity-green/20260814_062814_213_c546f20d`
(`1/1 PASS`).

Continuing the complete prefix then exposed a related test-host purpose mix-up:
the Group 3 helper had derived `StaticJITGeneration` versus `Runtime` purpose
from the unrelated Cache V2 persistence boolean. Existing execution fixtures
passed `false` to avoid persistent Cache writes, so they compiled correctly but
intentionally published no Runtime routes. The complete prefix made the first
three diagnostic route assertions fail while the Provider catalog remained
visible. Fixture construction now accepts Engine purpose independently:
generation/verify explicitly uses `StaticJITGeneration`, while AOT execution,
diagnostics, multi-Engine and UASFunction fixtures remain `Runtime` regardless
of whether Cache persistence is enabled. Cache restore also explicitly creates
a Runtime consumer. The helper build and focused diagnostics GREEN are
`Saved/Build/jit-fixture-purpose-green-build/20260814_063247_758_251ef6de`
and
`Saved/Tests/jit-fixture-purpose-green/20260814_063306_135_19103d5f`
(`5/5 PASS`).

The first post-fix complete-prefix retry used an outer one-second shell timeout.
The Editor continued as an orphan and its first five diagnostic methods passed,
but the repository runner could no longer finalize metadata. It was stopped at
the sixth method and is not counted as verification; the authoritative retry
below keeps the runner alive through its own timeout.

## Focused GREEN evidence

- canonical build after the core diagnostic implementation:
  `Saved/Build/jit-group8-diagnostics-green-build-4/20260814_055125_728_fd87b25d`
  — PASS;
- build after updating Runtime Binding expectations for the host trampoline:
  `Saved/Build/jit-group8-runtime-binding-test-update/20260814_055530_881_a7a8bbf4`
  — PASS;
- coordinator diagnostic/observer/marker method:
  `Saved/Tests/jit-group8-runtime-diagnostics/20260814_055156_434_f3e89d07`
  — `1/1 PASS`;
- corrected Static generator diagnostic method:
  `Saved/Tests/jit-group8-static-diagnostics-corrected/20260814_055402_526_df2d67d9`
  — `1/1 PASS`;
- complete coordinator Routing prefix after the trampoline and diagnostics:
  `Saved/Tests/jit-group8-routing-diagnostics-regression/20260814_055549_646_74d98705`
  — `13/13 PASS`.
- fallback provenance RED build:
  `Saved/Build/jit-group8-static-provenance-red/20260814_060740_027_4c90c3c2`
  — expected missing attempt/task-error fields, plus the wide-count overload
  ambiguity described above;
- fallback provenance and full-count helper build:
  `Saved/Build/jit-group8-static-provenance-green/20260814_060836_122_48dfd146`
  — PASS;
- complete Static backend contract after provenance preservation:
  `Saved/Tests/jit-group8-static-provenance-green/20260814_060858_670_8a7c2801`
  — `7/7 PASS`;
- full 137-action Development build after the Shipping inspection boundary:
  `Saved/Build/jit-group8-shipping-diagnostic-boundary-green/20260814_061144_077_9f48794d`
  — PASS;
- generic command execution/file/filter regression build:
  `Saved/Build/jit-group8-command-execution-green/20260814_061624_043_ca6e418a`
  — PASS;
- generic command execution/file/filter regression:
  `Saved/Tests/jit-group8-command-execution-green/20260814_061642_975_424924b2`
  — `1/1 PASS`.

The earlier `jit-group8-static-diagnostics` invocation used a non-existent
prefix and correctly reported no matching tests. It was immediately replaced
by the exact method prefix above; it is not counted as product validation.

## Final verification

Final strict OpenSpec validation, canonical build, focused StaticJIT,
RuntimeJIT and Native compiler prefixes, Standalone suite, configured All
suite, and the isolated follow-up are recorded below. Commit and archive
identities are recorded by Git/OpenSpec history rather than predicted in this
pre-commit attachment.

Current authoritative focused results:

- canonical final build after the complete-prefix fixture fixes:
  `Saved/Build/unified-jit-final-post-suite-fixes/20260814_064840_375_199424f8`
  — PASS;
- RuntimeJIT prefix:
  `Saved/Tests/unified-jit-runtime/20260814_061911_470_5159a809`
  — `48/48 PASS`, zero failures/skips;
- StaticJIT prefix after both complete-suite fixes:
  `Saved/Tests/unified-jit-static-authoritative/20260814_063702_883_6440538e`
  — `158/158 PASS`, zero failures/skips, runner exit 0.
- native AngelScript compiler prefix:
  `Saved/Tests/unified-jit-compiler/20260814_064504_712_06a31285`
  — `122/122 PASS`, zero failures/skips, runner exit 0.
- independent Standalone Debug CMake/CTest suite:
  `Saved/StandaloneTests/unified-jit-standalone_01_Standalone/20260814_064617_980_9c552b97`
  — `19/19 PASS`, zero failures, including package/corpus/soak/benchmark.
- configured parallel `All` suite:
  `Saved/Tests/unified-jit-all_20260814_064858`
  — all `37` shards completed; `3233 PASS / 1 FAIL / 3234` aggregated
  tests. RuntimeJIT, StaticJIT (`158/158`), Cache (`546/546`), current
  AngelScriptSDK (`696/696`), compiler, Standalone, and every other shard
  passed. The only failure was the pre-existing
  `Debugger.Pause.FAngelscriptDebuggerPauseTests.PauseStopsAtNextScriptLine`
  source-line timing assertion under four-Editor parallel load. The pause
  request was sent, the second pause was observed, and the invocation
  completed; only the allowed source-line set assertion failed.
- isolated serial follow-up for that exact Debugger method:
  `Saved/Tests/unified-jit-debugger-pause-serial/20260814_071447_301_c87adf7c`
  — `1/1 PASS`, zero failures, runner exit 0. This classifies the All-suite
  result as parallel scheduling variance outside the JIT change rather than a
  product regression; no Debugger production or test code was changed.
- strict change validation:
  `openspec validate refactor-as-unified-jit-coordinator --type change --strict --no-interactive`
  — PASS before the final commit/archive cycle and repeated after the final
  evidence update.

At the verification checkpoint the `Plugins/Angelscript` submodule was
intentionally dirty with only the Group 8 implementation/tests/docs waiting
for its milestone commit, and the parent showed the expected dirty submodule
gitlink plus this change's Chinese architecture note, checklist, and this
attachment. Unrelated user-owned
`openspec/changes/feature-as-typed-semantic-aot/*` edits and untracked
`.superpowers/sdd/jit-group5a-*` reports were explicitly excluded from staging
and commits.
