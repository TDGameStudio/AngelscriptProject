# Research index

All exploration for `feature-as-multithreaded-type-registration`. Native `asCScriptEngine` only; Hazelight `myas` is not a design source.

| File | What it records |
|---|---|
| `native-as-multithread-contract.md` | Stock official multithread = Execute, not Register* |
| `type-id-and-register-audit.md` | This fork: empty lock macros; type id is lazy `++` |
| `ue-types-and-container-thread-safety.md` | `TMap`/`TMultiMap`/`FPlatformAtomics` in the fork; FNamePool analogue |
| `approaches-and-recommendation.md` | Atomic-only vs restore locks vs registration window |
| `as-and-ue-multithread-surfaces.md` | Other native surfaces + UE dispatch APIs |
| `compile-stage-parallelism.md` | Why each compile stage is serial or already parallel |
| `id-allocators-and-atomics.md` | Why atomic counters do not replace intern+publish |
| `internal-structure-multithread-roi.md` | If internals may change: intern lock vs two-pass vs concurrent containers |
| `upstream-2.38-and-wip-2.39-multithread.md` | Local `Reference/angelscript-v2.38.0` + GitHub master / 2.39 WIP |
| `implementation-plan.md` | Ready-to-execute A0/A1/A2 plan: file map, APIs, test sketches, verification commands |

## Conclusions (do not lose)

1. Official “AS supports multithreading” is **concurrent Execute** (separate contexts), `asPrepareMultithread`, atomic refcounts, app lock for registered objects, GC from execute threads. **`RegisterObjectType` is not concurrent. `Build` is one thread** (`asBUILD_IN_PROGRESS`).
2. This fork is **weaker than stock** on locks (`as_criticalsection.h` always no-op; UE `as_thread.cpp` has no `asPrepareMultithread`; `Suspend`/`Abort` stub `asERROR`; Standalone CMake defines `AS_NO_THREADS`).
3. UE host already `ParallelFor`s **Parse** across modules inside one `RequestBuild`. GenerateTypes / functions / layout / bytecode stay serial. `BuildParallelParseScripts` itself is a serial `for`.
4. Atomic id is optional **inside** a lock. Function/import ids are peek+free-list, not bump counters. Type id lazy-publish needs DCL + map insert.
5. Highest ROI if internals may change: intern lock (types + `GetTemplateInstanceType`) then ParallelFor stage3 bytecode. Do not start with lock-free `asCArray`. Type-registration v1 is a slice of type intern, not parallel compile.
6. **2.38.0 and 2.39.0 WIP do not add concurrent Register* or parallel Build.** Same TODO in `asCModule::Build`. 2.39 WIP adds Windows Fiber Local Storage for TLS, not compile parallelism.
7. **Implement as A0 → A1 → A2** (`implementation-plan.md` / `tasks.md`). A0 = floor locks + Standalone threads-on. A1 = registration window. A2 = template intern + cvar-gated ParallelFor bytecode (default off). Approach B/C stay follow-ons.
