# Attachments

- `class-map.md` — discovery vs catalog vs per-engine runtime; why `FAngelscriptBind` stays.
- `dsl-ownership.md` — who implements each `RegisterTArray` / `RegisterFVector` DSL call.
- `recording-model.md` — how `FAngelscriptBind` callbacks write per-type TypeBindInfo.
- `storage.md` — subsystem array, row/member fields, `EApplySlot`.
- `angelscript-type-adapter.md` — `FAngelscriptType` stays per-engine; TypeBindInfo stores only the recipe to rebuild it.
- `register-timing.md` — when Register functions run (once per surface at expand, not per Engine).
- `authoring-examples.md` — one `FAngelscriptBind` per type family; recording Expand; `EApplySlot` metadata.
- `performance.md` — first Engine vs extra Engine cost; parallel expand is not a startup win.
- `multithreaded-write.md` — UE write patterns (ParallelForWithTaskContext, unique-index, MPSC queue); TypeBindInfo expand vs sealed.
- `ue-analogs.md` — Knot-backed UE examples mapped to Register / expand / apply / parallel write (shader types, FRepLayout, BlueprintType Phase 2A, AttributeTypeRegistrar, …).
- `as-engine-threaded-registration-follow-on.md` — why concurrent `Register*` is later.
