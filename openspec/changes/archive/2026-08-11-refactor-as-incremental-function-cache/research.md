# Current Research Conclusions

The complete exploratory record through 2026-08-09 is preserved byte-for-byte at
`history/pre-refactor-2026-08-09/research.md`. This current document contains only
the conclusions that still guide implementation.

## Stable conclusions

- Cache correctness uses full 256-bit stable identity and semantic content hashes;
  GUIDs are display-only and numeric FunctionIds remain current-engine state.
- Cache granularity is hybrid: FunctionBody and DebugSidecar are function/profile
  units, TypeSchema is a type unit, ModuleState is module-atomic, ModuleSnapshot is
  the activation root and SourceIndex is the generation source root.
- Physical persistence uses bounded aggregate packs, never one file per function.
- First launch compiles authoritative loose source and writes Cache V2. Later runs
  reuse unchanged content-addressed records and update only invalidated closures.
- Editor may maintain Current/Pending and hot-update supported structures. Packaged
  structural changes require restart; code-only changes may use a safe-point reload.
- StaticJIT owns its optional provider/module/native routing. Cache V2 shares stable
  function identity/content/profile only. Live Coding refreshes Editor C++ provider
  modules and is not a cache-validity mechanism.
- No `PrecompiledScript.Cache` compatibility reader, migration or fallback is
  allowed. `Binds.Cache` is unrelated and remains supported.

## Implementation consequences

- One immutable seven-kind factory owns decode candidate, controller, payload,
  captured offsets and publication.
- One graph traversal validates a module snapshot and retains only reachable handles.
- Manifest generation consumes that graph; it cannot invent a second decoder or
  reachability implementation.
- Active module restore/swap/ClassGenerator remains module-atomic even when
  persistence and invalidation are more granular.
- Real PIE and Development/Shipping multi-launch runs remain the final acceptance,
  after pure archive, store, compiler and focused lifecycle tests are GREEN.

See `lessons-learned.md` for the execution rules derived from the implementation
history and `status.md` for current blockers.
