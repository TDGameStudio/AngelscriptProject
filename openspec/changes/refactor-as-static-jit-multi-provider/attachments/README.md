# Incremental Attachment Routing

This directory holds progressive evidence and engineering notes discovered while completing `refactor-as-static-jit-multi-provider`. The normative current requirements remain in `design.md`, `specs/`, and `tasks.md`; attachments may explain why those files changed but do not override them.

Use focused files rather than one growing scratchpad:

- `problem-<topic>.md`: observed behavior, exact reproduction, evidence, alternatives tried, decision, and resulting spec/task changes;
- `migration-<topic>.md`: old/new generated layouts, ownership markers, cleanup samples, and compatibility boundaries;
- `runtime-<topic>.md`: provider lifetime, route publication, engine isolation, or Live Coding traces;
- `benchmarks/<topic>.csv`: raw samples with build/profile/hardware columns;
- `logs/<label>.txt`: concise extracted logs only when the normal `Saved/` report is not durable enough.

When a finding changes the implementation direction:

1. record the evidence here;
2. update `design.md` or the applicable capability delta;
3. rewrite affected items in `tasks.md` and `implementation-plan.md`;
4. mark prior evidence superseded in `verification.md` instead of deleting history;
5. continue from the revised plan and collect new RED/GREEN evidence.

Do not put routine command output here when an existing `Saved/Build` or `Saved/Tests` report already provides authoritative evidence. Do not let attachment commentary replace an unchecked acceptance item.

Current focused notes also include
`diagnostics-provider-route-cutover.md` for the schema-v2 Runtime observer,
function query, multi-Provider conflict proof, inspector fixtures, and measured
diagnostic-capture cost. Raw task-11.4 measurements and their methodology live
under `../benchmarks/`, including routing/reference phases, Cache V2 restore,
generated-file scale, strict per-module rebuild scope, and packaged
Native/direct-call status.

`documentation-provider-lifecycle-cutover.md` records the stale-document audit,
the current Chinese-first/English consumer guidance surface, removal of the
unused process-global JIT-loaded flag, and the build/diff-check evidence used
to close task 11.5.

`real-editor-livecoding-smoke.md` is the reproducible real-process acceptance
procedure for task 9.4. It records the fixed function identity, launch/wait and
diagnostic-JSON oracle, invalid GUI-process orchestration, the Cache current-
registration crash fix, progressive Provider view/metadata/image/owner fixes,
and the final same-Editor Native-to-VM-to-Native evidence.

`ue-livecoding-module-lifecycle-knot.md` records the Knot UE5-main source
research and local UE 5.8 cross-check for normal ModuleManager load/unload,
Live++ module enablement, patch/reinstancing callbacks, patch-image lifetime,
and the resulting Editor/Runtime/generated-code responsibility placement.

`problem-final-staticjit-gate.md` records the layered final-gate debugging
that found a missed by-value Provider-view adaptation, an invalid in-memory
fixture coordinate, and an AngelScript template-constructor reader crash. It
explains why each fix belongs respectively in the fixed carrier/test, the test
fixture, and the vendored reader without weakening stable Cache identity.

`final-test-timing.md` records the final-gate suite and individual-test timing
ranking, explains why Cache and fresh-Engine/AOT scenarios dominate wall time,
and separates safe future fixture optimizations from isolation semantics that
must remain intact.

`readable-generated-layout-and-metadata.md` records the direct profile/source-
relative generated layout, short-key collision algorithm, schema-3 metadata,
unchanged full internal symbols, revision-2 legacy-root migration safety, the
compiler-synthesized function line-number discovery, and real regeneration/
build evidence.
