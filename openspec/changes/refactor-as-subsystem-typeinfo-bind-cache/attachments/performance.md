# Performance impact (v1)

No measured numbers yet. This is the expected cost model; task 8 should add expand/apply timers under `AS_PRINT_STATS` before claiming a speedup.

## What actually costs time today

Bind startup is not 121 tiny `FColor` lambdas. It is:

1. Walking native `UClass` / `UStruct` / `UEnum` (`Bind_BlueprintType`, `Bind_UStruct`, `Bind_UEnum`).
2. `asIScriptEngine::Register*` for every type, method, and property.
3. Per-engine `FAngelscriptType` adapter construction and type finders.

`FVector` / `FColor` Explicit fills are cheap. Parallelizing only those will not move Editor startup much.

## First Engine (primary Editor / cooked process)

v1 is **expand then sequential apply**, not concurrent `Register*`.

| Step | Today | This change |
|---|---|---|
| UClass / BindDB walk | once, inside lambdas | once, inside Reflection generators |
| `Register*` into `asIScriptEngine` | once, inside lambdas | once, during apply |
| Extra | none | fill `TArray<FAngelscriptTypeBindInfo>` (strings, member records) |

Expect **similar or slightly slower** first bind: same walk + same Register*, plus copying declarations into TypeBindInfo. Do not sell v1 as a primary-startup win.

A second surface pass (Editor then Shipping) **does** extra walk/fill. Design default is lazy: only expand Shipping when a generation Engine needs it.

## Second Engine (isolation tests, StaticJIT generation)

This is the win.

Today: full lambda replay, including another UClass walk.

After seal: filter + sequential `Register*` from TypeBindInfo. No `TObjectRange`, no BindDB re-scan, no `Bind_FColor` C++.

Cost roughly tracks `Register*` only. That dominates extra-engine creation in tests and Generate.

## Parallel expand

Allowlisted Explicit fills on workers overlap cheap C++. Reflection stays on the Game Thread.

Net: small expand-time saving, not a substitute for faster `Register*`.

## Memory

The process keeps declaration strings and callable identities for the whole surface, in addition to what each live `asIScriptEngine` already stores. That is the cache. Do not persist TypeBindInfo to disk in v1. Do not put it on GameInstance.

## What would actually make first-engine bind fast

Follow-on: threaded/atomic `Register*` on `asCScriptEngine`, applying independent TypeBindInfo groups. Out of this change. See `as-engine-threaded-registration-follow-on.md`.
