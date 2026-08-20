# If internals may change: highest-ROI multithread (especially compile)

Assumption: we may reshape fork tables and the compile pipeline, not only add a `RegisterObjectType` window. Goal is **parallel compile / intern**, not lock-free `asCArray` as a religion.

Measure first. Host already logs `script compilation stage1 and stage2`, `class layouting`, `stage3`, `stage4`. Cache V2 ExactStartup **skips** this path; parallel compile pays off on cold start / ForceClean / big dirty sets.

## What is already parallel

Parse across modules (`ParallelFor` → `BuildParallelParseScripts`). Stage3 (bytecode) is still a serial `for` over modules, and inside that a serial `for` over functions. That is the usual CPU hog.

## Do not start here (low ROI / high blast radius)

| Change | Why not first |
|---|---|
| Lock-free `asCArray` / thread-safe `TMap` globally | Historical bind-parallel plan already rejected this. Every `PushLast` site becomes a new memory model. |
| FNamePool 256-way shards for type names | Bind/compile type counts are tiny vs FName. One intern lock is enough until measured. |
| Two overlapping `module->Build()` on one engine | Need concurrent intern **and** no stage barriers. Host already batches; overlapping full Builds is the hardest shape. |
| Parallel Stage4 `ResetGlobalVars` | Executes script / UObject. |
| `ParallelFor(CallBinds)` including methods | Still `defaultNamespace`, `PreviouslyBoundFunction`, method tables. Type-only window is the slice that matches intern. |

## Structure changes that actually buy threads

Think of the engine as **intern tables + bump allocators + per-function CPU**. Make intern linearizable; leave CPU outside the lock.

### 1. Real `engineRWLock` + GC critical sections (floor)

Restore macros in `as_criticalsection.h`; Standalone must not compile `AS_NO_THREADS` if we want this tested. Also restore `Suspend`/`Abort` if Execute-from-timeout matters.

Unlocks: stock concurrent **Execute**, lazy type-id, userdata, GC add. Does **not** by itself ParallelFor stage3 (bytecode still creates template instances without that lock today).

Cost: low–medium. Must flip Standalone `AS_NO_THREADS`.

### 2. Single intern API for types (highest dual-use)

One exclusive section (or `InternScriptType(name, ns, factory)`):

- uniqueness / `shared` winner
- `allScriptDeclaredTypes` / `registeredObjTypes` insert
- **eager** `typeId` assign + `mapTypeIdToTypeInfo` (no lazy `-1` during compile)

Unlocks:

- Concurrent `RegisterObjectType` (existing OpenSpec v1)
- Parallel **GenerateTypes** across modules
- Bytecode `GetTypeIdFromDataType` becomes a **read**

This is the same lock as type registration, not a second invention.

### 3. Intern `GetTemplateInstanceType` (highest **compile** ROI)

Stage3’s `asCCompiler` calls this often. On miss it:

- inserts `templateInstanceBuckets`
- may `GenerateNewTemplateFuncdef` / clone methods → **`AddScriptFunction` during bytecode**
- may lazy type-id

So “function ids are all assigned before stage3” is **false** for templates.

Cheap version: **whole `GetTemplateInstanceType` under exclusive intern lock** (double-checked: lookup shared, create exclusive). ParallelFor `CompileFunctions` then only serializes on first-touch of a new `TArray<Foo>`.

Cleaner version (more compiler work): **eager template collection** before stage3 (walk AST / type uses, intern all instances serially), then bytecode is read-only on type/function tables. Better scaling, bigger patch.

Do this before rewriting `freeScriptFunctionIds`.

### 4. Merge `GetNextScriptFunctionId` + `AddScriptFunction` into one `AllocateFunction`

Two-phase peek is the race, not the `++`. One function: lock (or monotonic id + locked `PushLast`), return reserved slot.

Keep hole reuse **inside that lock** at first. Dropping reuse is optional later.

Needed as soon as template intern or GenerateFunctions runs on several threads. If GenerateFunctions stays serial and only `GetTemplateInstanceType` is locked (and it calls `AllocateFunction` inside that lock), you may **not** need a concurrent free-list yet.

### 5. Diagnostics: per-builder or per-thread buffer, merge at barrier

Parse is already racy on `WriteMessage` / host `bHadCompileErrors`. Any extra ParallelFor makes this mandatory. Small, do with (3).

### 6. Layout DAG flags → atomics / mutex per declaration (optional)

`isLayouting` / `hasLayouted` + `EnsureClassLayouted` is already recursive work-steal across modules. Making those flags safe allows ParallelFor layout of independent trees. Measure `class layouting` vs `stage3` first; layout is often cheaper.

### 7. `asCArray` append-only under the intern lock — not a new container

Do **not** make `asCArray` thread-safe. Require all engine-table `PushLast` to happen in intern/`AllocateFunction`. Parsers keep using unsynchronized arrays **owned by one builder**.

## Recommended ladder (compile-first)

```text
0. Confirm timers: stage3 >> parse? Cache miss only.
1. Floor locks (Execute/GC/type-id publish).
2. Eager type id at type creation.
3. Lock GetTemplateInstanceType (+ AllocateFunction inside it).
4. Host: ParallelFor CompileFunctions (per function, Unbalanced).
5. Same intern lock for GenerateTypes / RegisterObjectType window.
6. Only then: parallel GenerateFunctions, layout DAG, drop function-id reuse, shards.
```

Approaches:

- **A — lock intern, keep tables.** Restore RW lock; intern types/templates/function-slots under it; ParallelFor bytecode. Smallest internal change. Recommended first product.
- **B — two-pass intern then pure parallel codegen.** Serial intern of types + all template instances; stage3 has no engine writes. Best scaling, more builder/compiler work.
- **C — concurrent containers.** Sharded maps, lock-free vectors. Only if A’s intern lock shows up in Insights on huge projects.

Recommend **A**, with **B** as the follow-on if stage3 still waits on template intern. Type-registration v1 is a **slice of A** (type intern), not a substitute for (3)+(4).
