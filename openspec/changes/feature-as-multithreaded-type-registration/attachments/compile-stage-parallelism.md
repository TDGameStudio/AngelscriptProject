# Why each compile stage is serial or parallel

This is about **script compilation** (`asCBuilder` / host `FAngelscriptEngine` pipeline), not application `RegisterObjectType`. Native `asIScriptModule::Build()` is still one engine slot (`RequestBuild`). The UE host occupies that slot once, then runs **barriers between stages**; only Parse is `ParallelFor` today.

Compilation is not forbidden from being parallel. Stock even TODOs it. What is shared is one engine’s intern tables (names, types, function ids, template instances). Stages that only build per-module AST can run together; stages that intern into those tables cannot, unless the tables themselves become concurrent (same class of problem as type registration).

Host pipeline (`AngelscriptEngine.cpp`, one `RequestBuild` … `BuildCompleted`):

| Host order | Native builder call | Parallel today? |
|---|---|---|
| Stage1 | `GetModule(ALWAYS_CREATE)` + add sections + import | No |
| Parse | `BuildParallelParseScripts` | Yes — `ParallelFor` across modules (100/task) |
| Generate types | `BuildGenerateTypes` | No |
| Generate functions | `BuildGenerateFunctions` | No |
| Layout classes | `BuildLayoutClasses` then template sizes | No |
| Allocate globals | `BuildAllocateGlobalVariables` | No |
| Layout functions | `BuildLayoutFunctions` | No |
| Bytecode | `BuildCompileCode` / `CompileFunctions` | No |
| JIT | `asCModule::JITCompile` | No (per-function mutex exists) |
| Globals init | `ResetGlobalVars` | No (executes script) |

## Stage by stage

### 0. `RequestBuild` / `PrepareEngine`

Writes `isBuilding`, may finalize registered application types.

Why exclusive: two full `Build()`s on one engine would interleave the later intern stages. The host already avoids that by taking the slot **once** for a batch. This is a pipeline lock, not a proof that every stage inside is serial.

### 1. Stage1 — create module, import, add code

Writes:

- `scriptModules` / `scriptModulesByName` (`GetModule(..., create)`)
- Host `TempNameIndex`
- `GetScriptSectionNameIndex` → `scriptSectionNames` + map
- Import copies of types/functions from other modules

Why not ParallelFor today: those are engine-wide arrays/maps. Work is cheap vs parse/codegen. Could lock the inserts; not worth it until tables are concurrent for other reasons.

Must stay **before** Parse: each module needs its own `asCBuilder` and script buffers.

### 2. Parse — `BuildParallelParseScripts`

Writes: per-builder `parsers[]` and AST nodes. Tokenizer `GetToken` is `const`. `IsTemplateType` reads **already-registered C++** template names (stable after binds).

Why this stage **can** (and does) parallel across modules: it does not insert `allScriptDeclaredTypes` / `scriptFunctions`. Each module’s AST is independent.

Caveats already present:

- `builder->WriteError` → engine message callback is not a concurrent log.
- Host `bHadCompileErrors = true` from workers is a data race (bool).
- Sections **inside one module** are still a serial `for`; they could also parallel the same way.

This is the existence proof that “compilation” is not atomically single-thread.

### 3. Generate types — `RegisterTypesFromScript`

Writes:

- `engine->AddNameSpace`
- `CheckNameConflict` against engine-visible names
- `sharedScriptTypes` scan + `PushLast` (reuse existing `shared` class)
- `allScriptDeclaredTypes.Add`
- new `asCObjectType`, `module->classTypes`

Why not parallel **without a lock**:

- Uniqueness is engine-wide (two modules declaring `Foo`, or `shared` merge).
- `TMultiMap` / `asCArray` insert is not thread-safe.
- Same intern problem as concurrent `RegisterObjectType`.

Why there is a **barrier** after all Parses, before any GenerateTypes: later stages resolve `class B : A` by looking up names that may live in **another** module. All declarations must be interned first. That barrier is required even if GenerateTypes itself is later locked-parallel.

Independent unique names **could** insert concurrently under exclusive uniqueness+insert (v1 type-registration lock would be the same primitive). `shared` merge still needs a single winner.

### 4. Generate functions — `CompileInterfaces` / `CompileClasses` / `RegisterGlobalVariables`

Depends on: **all** script types already interned (barrier after stage 3).

Writes:

- `GetNextScriptFunctionId` + `AddScriptFunction` → `scriptFunctions` / `freeScriptFunctionIds` (reuse holes)
- Default ctor / factory / destructor
- `CompileClass` → `EnsureClassCompiled` may call **another module’s** `builder->CompileClass` (inheritance / circular detect via `isResolving`)

Why hard to ParallelFor as-is:

- Function id allocator is a second global bump allocator (explicitly out of type-registration v1).
- `isResolving` / `hasResolved` are non-atomic flags; two workers compiling a parent twice is a race.
- Type lookup reads `allScriptDeclaredTypes` while other threads might still be in stage 3 if the barrier is removed.

Inheritance is a DAG: independent class trees could compile in parallel **after** ids/tables are concurrent and the resolve flags are synchronized. Host keeps a simple serial loop.

### 5. Layout classes — `LayoutClass` / `EnsureClassLayouted`

Depends on: inheritance already resolved; property types known.

Writes `ot->size`, alignment, property offsets, copies parent properties and VFT. Recurses to:

- `derivedFrom` (other module)
- value-type members (other script structs)
- templates (`CalculateTemplateSize`)

Host then turns off `deferCalculatingTemplateSize` and layouts `unvalidatedTemplateInstances` **after every class**.

Why not a naive ParallelFor:

- Child size needs parent size first (order constraint, not “one thread forever”).
- `isLayouting` / `hasLayouted` are not atomic; `EnsureClassLayouted` is recursive work-stealing across builders.
- Template instances live on the engine; sizing them while classes still change is why the host defers them.

Independent layout trees could parallel once the flags are safe. The template pass is a second barrier.

### 6. Allocate globals / layout functions

Globals of script value types need **final sizes** (barrier after layout). `CompileGlobalVariables` can resolve `auto` and, in hot reload, run into old functions (host comment: update bytecode refs **before** this). Function parameter offsets are per-function and mostly local, but still read layouted types and write `engine->scriptFunctions[id]`.

### 7. Bytecode — `BuildCompileCode` / `CompileFunctions`

Each function has its own `asCCompiler` and statement AST. Looks data-parallel.

Still mutates engine during compile:

- `GetTypeIdFromDataType` (lazy `typeIdSeqNbr` + `mapTypeIdToTypeInfo`)
- `GetTemplateInstanceType` (engine template buckets)
- diagnostics

If type-id publish and template intern were locked (stock execute-time lock + registration-style intern), function bodies **could** `ParallelFor` after layout. Today they are not.

Cache V2 artifact restore is per-function and already a skip of `CompileFactory` / function compile; that does not make the remaining compiles concurrent.

### 8. JIT / Stage4 globals

JIT: per-function `jitBindingMutex` already. Init globals **executes** script (UObject / GC) — game thread.

## What “compilation cannot be parallel” actually means

False if it means “the compiler is a single serial algorithm.” Parse is already parallel.

True if it means “two `module->Build()` overlapping on one engine is undefined”: they would race the intern tables. The host’s answer is **one slot + staged barriers**, not concurrent `Build()`.

Closest future parallels, cheapest first:

1. Keep Parse ParallelFor; fix the `bHadCompileErrors` race; optionally parse sections inside a module.
2. Same lock as type registration around GenerateTypes intern (plus `shared` winner).
3. Atomic or locked function-id allocator, then consider ParallelFor of independent `CompileClass` / bytecode with template intern locked.
4. Do **not** ParallelFor Stage4 or anything that runs script.

Type-registration v1 does not unlock compile. It only makes the **same intern problem** solvable for `RegisterObjectType`. Compile still needs function ids, shared script types, template instances, and the cross-module barriers above.
