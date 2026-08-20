# Collect binds and the native-form catalog

Recorded from the 2026-08-18 discussion. Normative catalog rules are in
`../specs/as-static-jit-native-call-linkage/spec.md` and `../design.md` decision 4.

## What collect binds is

`FAngelscriptEngineConfig.bCollectStaticJITCompatibilityBinds` (default `false`)
is a per-Engine switch. It does **not** re-run bind discovery. It decides whether
bind replay **keeps** the “how to spell this AS call in C++” side effect.

Script execution does not need it. Only Generate of `.jit.cpp` does.

## What the process actually stores

The process stores sealed bind **callbacks**, not finished bind data.

- Static `FAngelscriptBind` objects register `void (*)(FAngelscriptBinds&)`.
- `FAngelscriptBind::FinalizeRegisteredBinds` seals the collection.
- Every `FAngelscriptEngine` initialization calls `ExecuteRegisteredBinds`, which
  replays **every** lambda into **that** Engine (`AngelscriptBinds.cpp`).

Each lambda does two jobs:

1. `BindGlobalFunction` / equivalent → register into this Engine’s `asIScriptEngine`
   (required; otherwise the Engine has no declarations).
2. `.NativeFunction` / `.NativeMethod` / `.NativeFunctionHeader` / `ExternalNativeCall`
   → try to attach a `FScriptFunctionNativeForm` and optional reviewed descriptor
   onto **this Engine’s** `asIScriptFunction*`.

Step 2 is collect binds. See `AddNativeForm` in
`StaticJIT/BytecodeJIT/StaticJITBinds.cpp`: if the flag is false, `delete` the form
immediately. If true, store it in `FAngelscriptNativeFormState::Forms` keyed by
pointer. `FAngelscriptStaticJITNativeCallRegistry::Attach` is the same gate for
reviewed descriptors (`ExternalCallDescriptors`).

`FAngelscriptStaticJITGenerationProfile::ApplyToEngineConfig` sets the flag true.
`AngelscriptProjectSourceGraph` applies that for `StaticJITArtifact` compiles, not
for HIR dump. The primary Editor Engine keeps the default false.

`NativeFunction` therefore **runs once per Engine bind replay today**. A generation
Engine is a full bind replay plus compile, not a separate “from native” pipeline.
The flag only decides whether the heap object is kept.

## Two tables on a collect-on Engine

```text
FAngelscriptNativeFormState  (dies with the Engine)
  Forms[asIScriptFunction*]                    → C++ spelling (BytecodeJIT)
  ExternalCallDescriptors[asIScriptFunction*]  → reviewed linkage (TypedASTJIT)
```

Generate looks up by **pointer on the Engine that just bound**. There is no
process table today. Primary Editor bind already executes `.NativeFunction` and
then throws the form away.

## Why “primary start fills the catalog” is after the refactor

That sentence is **not** true on current `main`.

After `AddNativeForm` / `ExternalNativeCall` upsert into a catalog **even when
collect is false**:

- The primary Editor must bind on startup anyway.
- The same `.NativeFunction` / `ExternalNativeCall` calls run.
- The recipe is no longer deleted.
- The catalog then holds recipes for declarations **this bind surface actually
  registered** (typically `EditorDevelopment`).

It does **not** mean:

- current `main` already has a filled table;
- Shipping / cooked recipes exist after an Editor-only bind;
- a commandlet process is filled by an Editor Engine (that process’s first
  generation Engine bind is the first fill).

## How the catalog should be generated

Still the bind-replay side effect. No extra pass.

On `AddNativeForm` / `Attach`:

1. Key = stable declaration identity + bind-surface / target profile.
2. Value = current form / descriptor payload (C++ name, trivial, Header /
   Include, HeaderInline vs exported, ABI snapshot). No pointers.
3. Upsert into the process-lifetime catalog regardless of collect.
4. If collect is true, optionally still attach the pointer map for BytecodeJIT
   `GetNativeForm` until emit is switched to catalog lookup.
5. If collect is false, skip the pointer map; the catalog still has the recipe.

```text
lambda replay (still required per Engine, for Register*)
  ├─ this asIScriptEngine gets its own function objects
  └─ catalog upsert: (declaration, bind-surface) → recipe
```

Generate looks up by the compiled call’s declaration key, not `asIScriptFunction*`.
Hit → emit. Miss → bridge / typed fallback.

The catalog is not filled at static-init (no `asIScriptEngine`, ABI unknown). It
is not BindDB. It is not HIR / Cache V2. It does not replace per-Engine `Register*`.

## Headers are part of the recipe

A function that needs a header must record the include on the recipe at bind
time. Generate must not guess a header from a display name.

See `bytecodejit-native-form-and-headers.md` for the existing BytecodeJIT
include collection. For the catalog:

- `.NativeFunctionHeader(Name, Header)` → store Header.
- Reviewed `ExternalNativeCall` → store `Include` + `Linkage` (e.g. HeaderInline
  `CoreGlobals.h`).
- `.NativeFunction(Name)` alone → display name only; not proof of include or
  DLL linkability.

Private `Bind_*.cpp` implementations are not includable from `AngelscriptJIT`.
Illegal module dependencies cannot be HeaderInline; use an exported Runtime
thunk or bridge.

## `IsRunningCommandlet` is only an example

`Bind_CoreGlobals.cpp` binds the ordinary UE API `bool IsRunningCommandlet()` and,
when collect is on, attaches a HeaderInline descriptor (`CoreGlobals.h`). That
is one bind that opted into a reviewed direct call. It is unrelated to
`UAngelscriptJITCommandlet` and unrelated to whether a script calls that API.

## Out of this change

Do not skip bind lambda replay for all Engines by caching “all bind information”
once at process start. That collides with per-`asIScriptEngine` registration and
Editor vs Shipping bind surfaces. See `bind-replay-vs-cached-bind-snapshot.md`.
