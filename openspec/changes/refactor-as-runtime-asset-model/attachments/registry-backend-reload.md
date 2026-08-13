# Dynamic Asset registry, backend and reload design

## 1. Layering

```text
FAngelscriptEngine
└─ FAngelscriptDynamicAssetRegistry
   ├─ normalized definitions by SourceOwnerId
   ├─ local materialization state / LastError
   └─ injected IAngelscriptDynamicAssetBackend
      ├─ test: in-memory deterministic fake
      └─ production: shared UAssetManager coordinator
         └─ PrimaryAssetId -> fingerprint, descriptor, AS owner set
```

The Registry is Engine-local because modules and reload state are Engine-local. The production coordinator is shared because `UAssetManager` is shared. `FAngelscriptEngineDependencies` supplies the backend so isolated Engine tests never silently touch the production AssetManager.

## 2. Source owner and backend record

Source owner identity contains Engine lifetime token, module stable ID, namespace and declaration name. Backend record identity is only `FPrimaryAssetId`.

```text
BackendRecord
  PrimaryAssetId
  NormalizedDescriptor
  Fingerprint
  Origin = AngelscriptOwned
  Set<SourceOwnerId> Owners
```

Adding an owner:

- absent ID: verify Type is dynamic-compatible and no external record exists, call AddDynamicAsset, commit one owner;
- existing AS ID/same fingerprint: add owner without another AddDynamicAsset;
- existing AS ID/different fingerprint: reject without mutation;
- disk-scanned Type or external/unowned existing ID: reject by default.

The coordinator never adopts or overwrites an external record merely because a best-effort descriptor comparison looks equal; provenance is required for safe deletion later.

## 3. Local materialization state

Each definition tracks:

```text
Unmaterialized -> Materializing -> Materialized
                       |
                       +--failure--> Unmaterialized + LastError
```

GetId and LoadAsync call `EnsureMaterialized(SourceOwnerId)`. Re-entry during Materializing is an error. Only after backend success does the local definition become Materialized. Backend failure leaves no committed owner and is retryable.

Unload does not change this state. Owner release changes Materialized to removed as part of module/Engine teardown.

## 4. Production backend operations

Conceptual interface:

```text
Validate(desc) -> result
Acquire(owner, desc) -> result
Update(owner, oldDesc, newDesc) -> result
Release(owner, id) -> result
LoadAsync(id, bundles, priority, callbacks)
Unload(id) -> int32
Snapshot() -> read-only rows
```

`Acquire` and `Update` run on the Game Thread and never invoke synchronous object loading. `LoadAsync` calls the existing `FAngelscriptUAssetManagerBinds` adapter after Acquire succeeds.

## 5. Last-owner removal

When a materialized source owner exits:

1. remove that owner from the coordinator entry;
2. if owners remain, keep record and return;
3. call `UAssetManager::UnloadPrimaryAsset(Id)` to release ID-level load state;
4. call `AddDynamicAsset(Id, previous AssetPath, EmptyBundleData)` using the validated engine-version deletion contract;
5. verify the record is no longer present;
6. remove coordinator metadata.

If deletion fails, keep a diagnostic tombstone/coordinator entry rather than claiming the ID is free. Engine shutdown logs it prominently; a later Engine must not overwrite the stale external state accidentally.

## 6. Load semantics and callback forwarding

Generated LoadAsync performs:

1. resolve Engine and SourceOwnerId;
2. EnsureMaterialized;
3. build all declared Bundle names or accept caller subset;
4. forward ID, bundles, priority, callback object, finished function name and canceled function name to the existing adapter;
5. return void immediately.

The adapter retains UE's current behavior for invalid callbacks, cancellation and handle management. The Dynamic Asset Registry does not invent Loaded/Failed states because UAssetManager may aggregate loads from other callers and APIs.

Generated Unload is ID-level, not owner-level. It calls the same UAssetManager unload API and returns its result; the source definition remains Materialized.

## 7. Non-PIE transaction matrix

| Old local/backend state | Candidate | Action |
| --- | --- | --- |
| Unmaterialized | same ID, new valid desc | replace local desc only |
| Materialized | normalized fingerprint equal | update source metadata only; no backend call |
| Materialized, sole owner | same ID, new fingerprint | transactional backend Update |
| Materialized, other owners same old fingerprint | same ID, new fingerprint | reject candidate; last-good remains |
| Materialized | new ID | release old owner; install new Unmaterialized desc |
| any | invalid builder/Type/path | reject before active module swap |

Same-ID update transaction:

1. normalize/validate candidate and prove no incompatible co-owner;
2. retain old descriptor/fingerprint and module routes;
3. call AddDynamicAsset with new descriptor;
4. verify backend record matches new descriptor;
5. commit coordinator fingerprint, local descriptor and module swap together;
6. on failure, reapply/verify old descriptor and preserve last-good module;
7. if rollback itself fails, mark backend entry poisoned, block further overwrite and report both failures.

The update does not call Load or Unload. Existing resource handles remain under UAssetManager semantics; a subsequent generated LoadAsync uses the new Bundle data.

## 8. ID-change ordering

For `Type:Name` change outside PIE:

1. validate the new descriptor and symbol surface;
2. stage the new local definition as Unmaterialized;
3. commit module routes;
4. release the old owner (which may or may not remove the shared old record);
5. do not acquire the new backend ID until its GetId/LoadAsync is called.

If module commit cannot be atomic with old-owner release, hold both until commit succeeds, then release old. Candidate failure must never delete the last-good old record.

## 9. PIE policy

Before module swap, compare normalized descriptors and generated API surface. Any semantic change to ID, AssetPath, Bundle names/paths or API/lowering is Asset-related and returns the queued-full-reload outcome. No Acquire/Update/Release/Load/Unload occurs as part of rejection.

Textual edits that normalize to the same descriptor are not semantic Asset changes; if the remaining code diff is unrelated, normal soft reload may proceed. Repeated semantic edits coalesce to latest source and run one non-PIE transaction after PIE.

## 10. Failure and diagnostics

All backend diagnostics include PrimaryAssetId, requesting SourceOwnerId/Engine, existing owner identities, old/new fingerprint, backend phase and whether last-good was preserved. State Dump reads these values but never retries a failed operation.

Critical invariants:

- no local Materialized state without a committed backend owner;
- no backend AS owner without a live local owner or explicit tombstone;
- no record removal while any owner remains;
- no AddDynamicAsset from compile, module activation, Dump or unmaterialized Unload;
- no synchronous resource load anywhere in descriptor/backend update paths.
