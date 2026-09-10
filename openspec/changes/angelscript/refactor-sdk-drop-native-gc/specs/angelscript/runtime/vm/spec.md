## REMOVED Requirements

### Requirement: SDK cycle collection and weak references honor live roots

## ADDED Requirements

### Requirement: Native cycle collection is absent

The SDK SHALL destroy native AngelScript objects by reference count and Engine shutdown leases, and SHALL NOT provide a cycle collector, public garbage-collect APIs, or `asOBJ_GC` types.

#### Scenario: Reject garbage-collected type publication

- **WHEN** a host publishes an object type with `asOBJ_GC` or registers a GC behaviour

    The rejected surface includes `RegisterObjectType` flags, metadata `DefineType` flags, and behaviours `asBEHAVE_GETREFCOUNT`, `asBEHAVE_SETGCFLAG`, `asBEHAVE_GETGCFLAG`, `asBEHAVE_ENUMREFS`, and `asBEHAVE_RELEASEREFS`.

- **THEN** publication fails with an explicit invalid-flag or illegal-behaviour error

    No type is admitted. No object is placed on a collector list because the collector does not exist.

- **BUT** `asOBJ_REF`, `asOBJ_NOCOUNT`, and `asOBJ_VALUE` publication without `asOBJ_GC` remains valid

#### Scenario: Destroy an acyclic object on last release

- **GIVEN** a refcounted native VM object whose remaining handles form no cycle
- **WHEN** the last `Release` or `asVmRelease` runs
- **THEN** its destructor runs exactly once and its payload storage is freed
- **AND** a weak flag for that object becomes invalid only at that destruction

    Weak-flag invalidation is a last-release effect. It does not wait for a collector pass.

#### Scenario: Leave an unrooted cycle alive until shutdown drain

- **GIVEN** a self-cycle or two-object handle cycle with no external root and no prepared Context root
- **WHEN** execution returns and the former full-collection entry point would have run
- **THEN** the objects remain allocated and their destructors have not run

    Runtime leak of unreachable cycles is accepted. The SDK does not scan or break cycles while the Engine is live.

- **AND** Engine shutdown walks remaining VM object leases and destroys those objects

    Shutdown drain is lease-based. It is not `GarbageCollect`, incremental detection, or a public collector API.

- **BUT** an externally retained or Context-rooted object stays alive across shutdown admission close until that owner releases it

    `ShutDownAndRelease` still stops new admission. A caller-held object is destroyed on its own final release, matching current drain tests that keep an object alive across shutdown.

#### Scenario: Expose no public collector API

- **WHEN** a host inspects `asIScriptEngine`
- **THEN** the interface has no `GarbageCollect`, `GetGCStatistics`, `NotifyGarbageCollectorOfNewObject`, `GetObjectInGC`, `GCEnumCallback`, `ForwardGCEnumReferences`, or `ForwardGCReleaseReferences`
- **AND** engine properties do not include `asEP_AUTO_GARBAGE_COLLECT`
- **AND** `$func` and callable types are not flagged `asOBJ_GC`

    Function objects and delegates follow ordinary AddRef/Release. A delegate-capture cycle is not reclaimed at runtime.

## MODIFIED Requirements

### Requirement: Context control and shutdown retain valid cleanup bindings

#### Scenario: Shut down with active execution and retained metadata

- **WHEN** Engine shutdown begins while contexts or runtime objects still own executable resources
- **THEN** new admissions stop and active calls/objects are cleaned before bindings and IDs retire

    | Operation after the shutdown request | Observable behavior |
    |---|---|
    | New public Prepare, Execute, image link, definition registration or native/global binding | Rejected without replacing retained cleanup bindings |
    | An already executing call | Keeps the code, IDs and native contracts required for its continuation |
    | Destruction of an already owned object | Can invoke script or native destructors and release temporary objects through owned cleanup services |

- **AND** a shutdown request from inside an active callback defers final destruction until the callback exits

    Remaining native VM objects are destroyed through their leases and last releases. Unreachable cycles are not collected by a separate runtime pass; shutdown drain may destroy leased leftovers.

- **BUT** a retained metadata pointer alone cannot prepare or execute after retirement

#### Scenario: Release the last runtime object after its host owners

- **GIVEN** an SDK object whose producer, caller-held executable snapshot and host Engine owners have been released
- **WHEN** its last external runtime reference is released
- **THEN** its native or script destructor completes exactly once with its required type, code and native bindings still valid

    A script destructor may call a helper from a separately linked executable image. Ownership covers the complete cleanup dependency path, not only the destructor declaration.

- **AND** object and Engine ownership is released after cleanup without a permanent metadata-to-Engine reference cycle
- **BUT** internal cleanup authority does not reopen public execution or reattach retired definitions

    A separately retained executable snapshot may remain readable after the Engine is destroyed; releasing that snapshot cannot call its former Engine.
