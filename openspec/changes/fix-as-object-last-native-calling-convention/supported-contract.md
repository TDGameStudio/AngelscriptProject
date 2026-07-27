# Supported Native Caller Contract

Status: coherent source batch written; build and runtime verification pending.

## Current-fork caller rules

- Non-generic native functions require a bound `asFunctionCaller`. A missing
  caller remains registration-compatible but execution fails before entering
  the native target with:
  `Native calling convention support is disabled. Make sure you're passing a correct Caller.`
- A free-function pointer paired with `asCALL_THISCALL` is rejected at
  registration with `asWRONG_CALLING_CONV` and is not published.
- `asCALL_GENERIC` does not require an automatic caller.
- `asCALL_CDECL_OBJLAST` receives explicit script parameters first and the
  native object/destination pointer last.

## Object-last shapes owned by this change

| Registration surface | Explicit parameters | Return | Current-fork disposition | Direct owner |
|---|---|---|---|---|
| Value constructor | none | `void` | Supported | `CallingConvention.ObjectLastSupportedShapesPreserveSentinelsAndReturnStorage` |
| Value constructor | `int` | `void` | Supported | same |
| Value constructor | `int, int64, int` | `void` | Supported | same |
| Copy constructor | `const value& in` | `void` | Supported | same |
| Destructor | none | `void` | Supported | same |
| External const method | `int, int64, int` | `int` | Supported | same |
| External const method | `int` | value object through return storage | Supported source owner; build/runtime pending | same |
| External const method | `int` | script exception | Supported failure/recovery owner | `CallingConvention.ObjectLastNativeExceptionCleansAndContextCanBeReused` |
| Restored external const method | `int, int64` | `int` | Compatible destination registration required | `Module.SaveLoad.ObjectLastNativeCallIdentitySurvivesCompatibleDestinationLoad` |
| Generated AOT constructor | `int, int` | `void` plus script `int` observation | Generated execution required | `StaticJIT.AOT.ObjectLastNativeConstructorUsesGeneratedEntry` |

## Generic implicit-handle cleanup

- Counted implicit handles remain cleanup-owned and must invoke their registered
  release behavior exactly once.
- `asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE` values transfer no
  reference-count ownership. They are excluded from `cleanArgs`, and their
  argument slots are discarded when the VM retires the call stack rather than
  being explicitly cleared by ownership cleanup.
- If stale or malformed cleanup metadata nevertheless contains a no-count entry,
  the generic cleanup loop defensively clears that moved slot without
  dispatching function id zero.
- Direct owner:
  `Embedding.GenericInterfaceDepth.NoCountImplicitHandleByValueDoesNotInvokeMissingRelease`.

## Deferred compatibility

No additional ABI shape is claimed merely because registration succeeds.
Any 2.38-only shape that lacks a current-fork public API must be introduced as
an enabled Disabled test tagged `#as-v238-backport`, not as a fabricated
positive. This source batch did not identify a new shape requiring that tag.
