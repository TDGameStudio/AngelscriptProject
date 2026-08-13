# Provider DLL lifetime and generation retirement — 2026-08-12

## Why copied catalogs were not sufficient

Before Task 3.6, `FAngelscriptJITProviderRegistry` synchronously copied every
Provider view, entry, stable reference descriptor, and diagnostic string into
Runtime-owned immutable catalogs. A selected Binding retained that catalog and
its Engine-local resolved reference table until the last active reader exited.
This protected data ownership but did not by itself protect generated code:
the copied VM/Raw/Parms values remain function pointers into the Provider's
loaded image.

Consequently, a physical DLL unload could leave a perfectly live copied
catalog containing unmapped entry addresses. A `TSharedPtr` to metadata is not
a DLL code-lifetime guarantee.

## UE 5.8 evidence

The local UE 5.8 `FModuleManager` behavior was rechecked before implementation:

- `UnloadModule(..., bIsShutdown=false, bAllowUnloadCode=true)` calls
  `ShutdownModule()`, destroys the module object, and releases its platform DLL
  handle.
- engine shutdown intentionally does not release DLL code pages.
- `UnloadOrAbandonModuleWithCallback()` consults
  `IModuleInterface::SupportsDynamicReloading()`. A module returning `false` is
  abandoned instead of physically unloaded for that reload path.
- `SupportsDynamicReloading()` does not constrain a caller that explicitly
  invokes `UnloadModule()`.
- Live Coding patches an already loaded target module and does not rely on a
  second `StartupModule()` registration. The fixed Provider feature therefore
  continues to query the generated current-view accessor after a patch.

Evidence paths:

- `Engine/Source/Runtime/Core/Private/Modules/ModuleManager.cpp`
- `Engine/Source/Runtime/Core/Public/Modules/ModuleInterface.h`
- `Engine/Source/Runtime/Core/Private/Windows/WindowsPlatformProcess.cpp`

## Implemented ownership contract

Primary module loading remains exclusively owned by UE. StaticJIT does not
load an absent Provider module or replace `.uproject` / `.uplugin` target
selection.

When a loaded Provider is registered, Runtime creates one immutable
`FAngelscriptJITProviderLifetime` for that ProviderId/generation. In a modular
build it enumerates the current process code images, resolves every non-null
VM/Raw/Parms entry address to its containing image, and obtains one additional
platform DLL reference per distinct image. This intentionally follows the
address rather than trusting `OwnerModuleName`, so entries patched into a Live
Coding DLL retain the patch image rather than only the original UE module DLL.
In a monolithic build the process image is inherently process-lifetime. Every
Registry registration path uses the same proof; a Provider is rejected when
its claimed owner module is absent or any published entry address cannot be
resolved and retained. Logical-only leases exist only for manually assembled
unit-test Bindings that never enter the Registry.

The copied catalog owns this lease. Selections, Bindings, route snapshots, and
active execution readers already retain the catalog, so the lease naturally
survives:

```text
UE loads module
  -> StartupModule registers fixed feature
  -> Runtime validates view and pins every actual entry code image
  -> immutable catalog owns generation lease
  -> Engine Binding owns catalog
  -> active call owns retired Binding snapshot
  -> final reader releases catalog
  -> Runtime releases the extra DLL handle
```

Provider unregistration publishes a new Registry snapshot immediately. It
therefore blocks new matching from that Provider without clearing unrelated
Providers. Engine route refresh removes or replaces already selected entries
at its next safe publication point. Any old call that had already acquired its
Binding continues to own the old catalog, reference table, and code pin until
it returns.

Generated `AngelscriptJIT` and `AngelscriptTestJIT` carrier modules also return
`false` from `SupportsDynamicReloading()`. This makes UE's ordinary dynamic
reload path abandon the old image. The Runtime generation lease remains the
stronger protection for explicit unload and in-flight retirement; the module
flag is defense in depth and preserves the fixed-feature Live Coding model.

## Live Coding boundary

The lease follows each entry-point address into the currently loaded base or
Live Coding patch image. After patch completion, the existing fixed feature
accessor exposes the new ProviderGeneration and Registry publication acquires
a new generation lease for the new addresses. Old Binding snapshots keep their
earlier catalog/lease and patch-image handles until the last reader exits.

Adding or removing a generated AS-module `.jit.cpp` still changes UBT's source
set and is not eligible for Live Coding. That transition requires a normal full
build. Only content changes under an unchanged source-file set use the patch
path.

## Failure behavior

- An invalid view is rejected before any code pin is accepted.
- A Provider whose claimed owner module is not loaded, whose entry address
  cannot be mapped to a process image, or whose containing DLL handle cannot be
  retained is rejected with `CodeLifetimeUnavailable` on every registration
  path.
- Registry replacement and unregistration move the old catalog and published
  snapshot out of the Registry lock before their final references can release
  a DLL handle. Retirement is reference-count driven and does not wait for an
  active call while holding that lock.
- No Provider-owned array, string, lease deleter, or release callback is stored
  by Runtime.

## Focused evidence

- Runtime directed build:
  `Saved/Build/staticjit-provider-address-lifetime-runtime/20260812_205333_576_51335b40`
- Test-module directed build:
  `Saved/Build/staticjit-provider-address-lifetime-test/20260812_205351_828_b6d573ce`
- Registry, multi-provider, binding-publication, execution-context, and
  scaffold regression, 28/28:
  `Saved/Tests/staticjit-provider-address-lifetime-regression/20260812_205417_089_c21ee304/Report`

The focused suite proves real entry-address resolution/pinning in the loaded
`AngelscriptTest` DLL, rejection of an unavailable owner module, immediate
owner-scoped Registry removal, old-generation lease survival across an active
native call, deterministic conflict/recovery, unrelated-provider continuity,
and two-Engine binding/reference isolation. At this checkpoint physical
unload/reload of the dedicated generated carrier was still coupled to the real
`AngelscriptTestJIT` module work and kept OpenSpec tasks 3.6 and 3.8 open.

## Dedicated carrier closure — 2026-08-13

The real `AngelscriptTestJIT` carrier now supplies the missing ModuleManager
boundary proof. `TestCarrierDepartureRetainsOldCodeAndUnrelatedProviders`
starts with three concurrently visible ownership domains: the committed
`AngelscriptTestJIT` provider, a project-shaped provider, and a plugin-shaped
provider. It retains the copied TestJIT catalog, explicitly calls
`FModuleManager::UnloadModule(AngelscriptTestJIT, false, true)`, and verifies:

- the current Registry snapshot immediately stops exposing TestJIT while the
  project and plugin providers remain present;
- the retired TestJIT catalog still owns its Runtime code-image lease;
- the retained generated VM entry for
  `IndependentModuleEntryForAOT()` remains callable after module departure and
  still returns `87`;
- reloading the fixed carrier republishes the same ProviderId and unchanged
  content-derived ProviderGeneration without disturbing the other providers.

The first Registry regression after adding this proof exposed a stale
single-provider test assumption: `ModularFeatureArrivalAndDepartureAreObserved`
expected the discovery snapshot to contain exactly one provider after adding
its fixture, but discovery correctly already contained the real TestJIT
provider. The test was fixed to capture the discovered provider set as its
baseline, locate its own fixture by ProviderId, and prove owner-scoped removal
preserves every baseline catalog. No Runtime selection or retirement behavior
was loosened.

Closure evidence:

- initial test compile RED caused by a malformed aggregate brace, then fixed:
  `Saved/Build/staticjit-real-provider-retirement-test/20260813_035303_467_5cd1e71c`;
- compiled real-carrier proof:
  `Saved/Build/staticjit-real-provider-retirement-test-compile-fix/20260813_035359_571_11d1b858`;
- real carrier, project/plugin coexistence, deterministic conflict/recovery,
  multi-AS-module ownership, and unload/reload, 6/6 PASS:
  `Saved/Tests/staticjit-real-provider-retirement-runtime-prefix/20260813_035515_264_d606657d/Report`;
- active Binding reader and two-Engine lease retirement, 5/5 PASS:
  `Saved/Tests/staticjit-provider-retirement-binding-publication/20260813_035629_875_d1b826f8/Report`;
- stale single-provider baseline RED, 6/7 PASS:
  `Saved/Tests/staticjit-provider-retirement-registry/20260813_035720_264_380316a4/Report`;
- baseline-aware test build:
  `Saved/Build/staticjit-provider-registry-baseline-fix/20260813_035903_276_c2c3df72`;
- copied-catalog, atomic replacement, ProviderId conflict/recovery, modular
  feature arrival/departure, and unavailable-code rejection, 7/7 PASS:
  `Saved/Tests/staticjit-provider-retirement-registry-green/20260813_035925_752_08a6331d/Report`;
- explicit VM/Raw/Parms execution context and re-entrant restoration, 5/5
  PASS:
  `Saved/Tests/staticjit-provider-retirement-execution-context/20260813_040019_673_2ddfe7c8/Report`.

Together with the earlier active-call and two-Engine tests, this closes
OpenSpec tasks 3.6 and 3.8. Physical unload blocks new selection immediately;
retired callers keep copied metadata, Engine-local reference tables, complete
Bindings, and the actual code image alive through the final reader.

## Windows balanced-reference correction — 2026-08-13

The first real project `AngelscriptJIT` Provider exposed a Windows-specific
hole that the dedicated TestJIT unload/reload test did not reproduce. All
three project profiles verified as `Current` with `DifferenceCount=0`, but the
Editor commandlet crashed later in `FModuleManager::UnloadModulesAtShutdown()`:

- RED commandlet:
  `Saved/AngelscriptJITRuns/staticjit-host-verify-all-final/20260813_054224_251_fc61f6d2`;
- commandlet result before shutdown: success, zero verification differences;
- final failure: `EXCEPTION_ACCESS_VIOLATION` while ModuleManager called the
  next module's shutdown virtual function.

The root cause was an unbalanced Windows DLL reference. UE 5.8
`FWindowsPlatformProcess::GetDllHandle()` calls
`LoadLibraryWithSearchPaths()`. When its input is an existing full DLL path and
the image is already loaded, that function returns `GetModuleHandle()`
directly. `GetModuleHandle()` does **not** increment the Windows loader
reference count. The StaticJIT lifetime nevertheless stored that handle and
later paired it with `FreeDllHandle()` / `FreeLibrary()`. At engine shutdown an
Engine-owned Binding could keep the Provider lease alive until Runtime
shutdown; releasing that lease then subtracted a reference it never acquired,
unmapped a carrier DLL early, and left ModuleManager with a module object whose
vtable pointed into the unmapped image.

Runtime now uses `GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS)`
on Windows. Omitting `GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT` is
intentional: it acquires one real loader reference for the exact image that
contains the VM/Raw/Parms entry point, including a Live Coding patch image.
The lifetime destructor's existing `FreeDllHandle()` is therefore balanced.
Non-Windows `dlopen`-based retention remains unchanged.

Evidence:

- Runtime build with the balanced acquisition primitive:
  `Saved/Build/staticjit-dll-retain-refcount-fix-build/20260813_054920_621_1a42b717`;
- GREEN repetition of the same real project `Verify All`, all three profiles
  current, every `DifferenceCount=0`, complete module shutdown, and final
  `ProcessExitCode=0`:
  `Saved/AngelscriptJITRuns/staticjit-host-dll-lifetime-green/20260813_054956_174_87828f5d`.

This correction does not change the ownership model: UE still owns primary
module loading, the Registry still copies Provider data, and active/retired
Bindings still keep the exact code image mapped. It makes the platform handle
used by that model a genuinely owned, symmetrically released reference.
