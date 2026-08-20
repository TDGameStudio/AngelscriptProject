# JIT-generated function handles

Recorded: 2026-08-18. Question: should each Runtime JIT compiled function be managed with a handle?

## Current objects (already almost a handle, but not API-shaped)

| Type | Role | Problem as a public token |
| --- | --- | --- |
| `asJITFunction` (`VMEntry`) | Raw code pointer | Cannot tell which backend, revision, or Engine it belongs to; storing it after retire is UAF |
| `FAngelscriptRuntimeJITCodeLease` | `TSharedPtr` over executable memory | Keeps code alive, but has no identity; two backends’ leases are indistinguishable |
| `FAngelscriptRuntimeJITPublishedCode` | Fat bag: identity + VMEntry + session + lease + metrics | Copied into Binding context; too large and too raw for host events / switch / compare |
| `FAngelscriptRuntimeJITBindingContext` | Binding.UserData payload | Tied to one attached Binding; cannot name the *other* warm backend’s code for the same script function |
| `FAngelscriptStableFunctionKey` + BackendId | Identity only | Does not keep code alive; lookup can miss after retire |

So lifetime is already shared-pointer based. What is missing is a **small, copyable, owning identity** that the host, events, switch, and compare can pass around without touching `VMEntry`.

## UE analogs

| Pattern | Keeps resource alive? | Fit |
| --- | --- | --- |
| `FDelegateHandle` | No | Bad: dispatch/compare would dangle after retire |
| `FTimerHandle` / `FGameplayAbilitySpecHandle` / `FMassEntityHandle` | Index + generation | Good *identity*, still need a table + separate lifetime |
| `TSharedPtr` / StaticJIT `FAngelscriptJITProviderLifetime` | Yes | This is what CodeLease already is |
| One `UObject` per compiled function | Yes, via GC | Bad: thousands of functions, game-thread, GC pauses, workers cannot hold them |
| LLVM ORC `ResourceTracker` | Yes, per-module/code blob | Same idea as a compiled-function artifact |

Recommendation: **owning value-type handle**, not UObject, not `FDelegateHandle`.

## Proposed type

```text
FAngelscriptRuntimeJITFunctionHandle
  public identity (pointer-free, loggable):
    BackendId, EngineNamespace, PublicationOrdinal,
    FunctionKey, FunctionRevision, EntryAbiHash
  private:
    TSharedPtr<const FAngelscriptRuntimeJITCompiledFunction, ThreadSafe>
      → PublishedCode / CodeLease / SessionKeepAlive / metrics
```

`IsValid()` means the strong ref is alive (code still mapped). A handle that only matches identity but whose artifact was released is invalid.

Coordinator cache:

```text
WarmHandles[FunctionKey][BackendId] -> Handle   // current ordinal only
DispatchHandle[FunctionKey]         -> Handle   // the one SetJITBinding uses
```

Retire ordinal: drop cache entries; copies already in Binding.UserData keep the artifact alive until the last reader exits (same as today).

## Why this is more convenient

- Switch: `DispatchHandle = WarmHandles[Fn][llvm]`, then `SetJITBinding` from that handle. No hunting through PublishedCode.
- Compare: two handles for the same FunctionKey; measure by temporarily dispatching each handle.
- Events: `CompileCompleted` / `BindingPublished` carry a handle, not `asIScriptFunction*` plus a pile of hashes.
- Unload: handles of that BackendId fail `IsValid()` after drain; other backends’ handles stay.
- Tests: assert handle identity/generation instead of raw `VMEntry` pointer equality.

## What it must not be

- Not a UObject per function.
- Not a host-visible raw `asJITFunction`. Binding still needs VMEntry internally; host APIs do not return it.
- Not a replacement for CodeLease; the handle **owns** the lease.
- Not shared across Engines (`EngineNamespace` is part of identity).
- Not a way to dual-issue one call.

## Relation to Binding.UserData

`FAngelscriptRuntimeJITBindingContext` should hold the same `TSharedPtr` the handle holds (or hold the handle itself). `FromBindingUserData` can recover the handle for diagnostics. Fork `ReleaseFunctionBinding` still drops the last Binding copy.

## Decision

Adopt `FAngelscriptRuntimeJITFunctionHandle` as the host-facing unit of compiled Runtime code. Implementation stays in this OpenSpec change, before MIR/LLVM adapters.
