## ADDED Requirements

### Requirement: Asset declarations describe Primary Asset records
The language SHALL interpret `asset Name of PrimaryAssetType { ... }` as a Dynamic Asset description whose identifier is exactly `PrimaryAssetType:Name`. `asset` SHALL be the declaration keyword and the language SHALL NOT require or define a `UASSET` macro for this capability.

#### Scenario: Primary Asset identifier
- **WHEN** a module declares `asset Sword of Weapon`
- **THEN** its normalized identifier is `Weapon:Sword` and no UObject or `.uasset` is created

#### Scenario: Declaration inside a namespace
- **WHEN** otherwise identical declarations are placed in different module namespaces
- **THEN** their generated APIs resolve in those namespaces but the backend identity remains the exact `PrimaryAssetType:Name`

#### Scenario: Invalid identifier token
- **WHEN** Type or Name would produce an invalid `FPrimaryAssetId`
- **THEN** candidate validation fails at the declaration and the active module remains unchanged

### Requirement: Asset builders are pure deterministic descriptions
An Asset body SHALL only set an optional `FSoftObjectPath AssetPath` and construct `FAssetBundleData Bundles` through the documented allowlist using compile-time-known names and top-level asset paths. It SHALL NOT execute arbitrary functions, access UObject/World/Singleton state, perform control flow, load assets or mutate external state.

#### Scenario: Valid description
- **WHEN** a declaration provides a valid optional AssetPath and one or more valid Bundle asset paths
- **THEN** validation produces a normalized immutable descriptor without executing runtime script code

#### Scenario: Reordered equivalent description
- **WHEN** two descriptions differ only in Bundle/path insertion order or duplicate path insertion
- **THEN** normalization sorts and deduplicates them to the same fingerprint

#### Scenario: Side-effectful builder
- **WHEN** a body calls an external function, reads UObject/World/Singleton state, loops or branches
- **THEN** preprocessing fails before the candidate module can change active state

#### Scenario: Invalid AssetPath or Bundle path
- **WHEN** AssetPath is non-null but not an asset path, or a Bundle path is invalid/non-top-level
- **THEN** validation rejects the declaration with the offending field and source location

### Requirement: Every Dynamic Asset contains a non-empty Bundle
A valid declaration MUST normalize to at least one named Bundle containing at least one valid asset path. AssetPath alone SHALL NOT satisfy this requirement.

#### Scenario: Empty Bundles
- **WHEN** a declaration has no Bundle paths or removes every Bundle path during its allowed builder operations
- **THEN** candidate validation fails before `AddDynamicAsset` can interpret the record as removal

#### Scenario: None Bundle name
- **WHEN** a Bundle entry uses `NAME_None`
- **THEN** validation rejects that entry and identifies the declaration

### Requirement: Asset declarations generate ID, async load and unload APIs
Each declaration SHALL generate a namespace with `FPrimaryAssetId Name::GetId()`, two `void Name::LoadAsync(...)` overloads and `int Name::Unload()`. The async callback parameters SHALL match the existing UAssetManager binding contract.

#### Scenario: Direct default async load
- **WHEN** script calls `Name::LoadAsync()` without first calling GetId
- **THEN** the runtime ensures delayed registration and asynchronously requests all Bundle names declared by Name

#### Scenario: Direct subset async load
- **WHEN** script calls `Name::LoadAsync(LoadBundles, Priority, CallbackObject, FinishedName, CanceledName)`
- **THEN** the runtime ensures delayed registration and delegates that Bundle subset and callback arguments to the existing UAssetManager async adapter

#### Scenario: ID interoperability
- **WHEN** script calls `Name::GetId()`
- **THEN** it receives the exact PrimaryAssetId after delayed registration without loading any Bundle UObject

#### Scenario: Generated callback defaults
- **WHEN** script omits optional LoadAsync arguments
- **THEN** Priority is 0, callback object is null, and finished/canceled function names are `NAME_None`

### Requirement: Dynamic Asset registration is delayed and retryable
Compilation, module activation, descriptor lookup and State Dump SHALL NOT call `AddDynamicAsset`. The first successful GetId or LoadAsync SHALL materialize the normalized descriptor exactly once for that owner; a failed materialization SHALL remain retryable.

#### Scenario: Unused declaration
- **WHEN** a valid declaration is compiled and none of its generated runtime APIs are called
- **THEN** no Dynamic Asset record or backend owner is added

#### Scenario: First GetId
- **WHEN** GetId is the first runtime API call and backend registration succeeds
- **THEN** one materialized owner is recorded and repeated GetId calls do not call AddDynamicAsset again

#### Scenario: First LoadAsync
- **WHEN** LoadAsync is the first runtime API call
- **THEN** registration completes before the asynchronous load request is submitted

#### Scenario: Registration failure and retry
- **WHEN** the AssetManager is unavailable or AddDynamicAsset fails
- **THEN** the call throws an actionable script exception, no owner is committed, last error is observable, and a later call may retry

### Requirement: Loading never becomes an implicit synchronous operation
Declaration, validation, GetId, State Dump and unload of an unmaterialized declaration SHALL NOT synchronously load resource objects. Generated LoadAsync SHALL use the existing AssetManager asynchronous streaming path and SHALL NOT add a packaged-runtime synchronous fallback.

#### Scenario: GetId on unloaded resources
- **WHEN** GetId materializes a descriptor whose Bundle paths are not currently loaded
- **THEN** the paths remain unloaded after GetId returns

#### Scenario: Missing cooked resource
- **WHEN** LoadAsync requests a path that was not included in the packaged build
- **THEN** the existing AssetManager failure/cancel behavior is observed and the runtime does not read files synchronously or create an asset

### Requirement: Unload releases load state but retains registration
For a materialized declaration, `Name::Unload()` SHALL delegate to `UAssetManager::UnloadPrimaryAsset(Id)` and return the number of affected handles. It SHALL NOT remove the source owner or Dynamic Asset record. For an unmaterialized declaration it SHALL return 0 without materializing it.

#### Scenario: Unload after LoadAsync
- **WHEN** an ID has active AssetManager load state and script calls Unload
- **THEN** the affected handle count is returned while GetId remains valid and no AddDynamicAsset re-registration is required for a later LoadAsync

#### Scenario: Unload before any materialization
- **WHEN** Unload is the first generated API called
- **THEN** it returns 0 and causes no AddDynamicAsset or load request

#### Scenario: Shared ID unload semantics
- **WHEN** multiple callers use the same materialized PrimaryAssetId and one calls Unload
- **THEN** AssetManager applies its ID-level unload semantics, while descriptor owner reference counts remain unchanged

### Requirement: Dynamic Asset ownership is coordinated across Engines
Each Angelscript Engine SHALL retain its own source definitions and owner tokens. A shared production backend SHALL share a materialized PrimaryAssetId only when normalized descriptions are identical, SHALL reject conflicting or externally owned records, and SHALL remove an AS-owned record only after its last owner exits.

#### Scenario: Identical description across two Engines
- **WHEN** two Engines materialize the same ID with the same normalized AssetPath and Bundles
- **THEN** one backend record is shared, its AS owner count is two, and one Engine shutdown does not remove it

#### Scenario: Conflicting description across Engines
- **WHEN** a second owner requests an existing ID with a different normalized fingerprint
- **THEN** the request fails without changing the existing record or its owners

#### Scenario: Disk-scanned PrimaryAssetType
- **WHEN** the requested Type is already configured as non-dynamic/disk-scanned
- **THEN** candidate/materialization is rejected without attempting to convert or rename that Type

#### Scenario: Pre-existing unowned Dynamic Asset
- **WHEN** an ID exists in AssetManager but is not owned by the AS backend coordinator
- **THEN** the AS request rejects by default instead of overwriting the external record

#### Scenario: Last owner exits
- **WHEN** the last module/Engine owner of a materialized AS record exits
- **THEN** the backend unloads the ID, removes the Dynamic Asset record through the supported deletion contract, and clears its coordinator entry

#### Scenario: Unmaterialized owner exits
- **WHEN** a module containing an unused declaration unloads
- **THEN** only Engine-local descriptor state is removed and no AssetManager call occurs

### Requirement: Non-PIE reload updates descriptors transactionally
Outside PIE, an unmaterialized descriptor SHALL be replaceable without backend calls. A materialized same-ID descriptor change SHALL update only when all owners are compatible and SHALL rollback to last-good on failure. An ID change SHALL release the old owner and install the new descriptor as unmaterialized.

#### Scenario: Equivalent normalized edit
- **WHEN** source ordering changes but the normalized descriptor fingerprint does not
- **THEN** no backend update, unload or owner change occurs

#### Scenario: Unmaterialized description edit
- **WHEN** an unused same-ID declaration changes outside PIE and validates
- **THEN** only the Engine-local descriptor changes and the first later API materializes the new description

#### Scenario: Exclusive materialized update
- **WHEN** the only owner changes AssetPath or Bundles for the same ID outside PIE
- **THEN** the backend validates and applies the new description transactionally without implicitly loading resources

#### Scenario: Shared-owner incompatible update
- **WHEN** one of multiple owners changes the shared ID to a different fingerprint while another owner retains the old one
- **THEN** the candidate update is rejected and the old module, descriptor, record and owners remain active

#### Scenario: Backend update failure
- **WHEN** AddDynamicAsset rejects the candidate update or rollback validation fails before commit
- **THEN** the last-good record and module descriptor remain authoritative and the failure is diagnosed

#### Scenario: PrimaryAssetId change
- **WHEN** Type or Name changes outside PIE
- **THEN** the old owner is released and the new definition is installed unmaterialized without automatically registering or loading the new ID

### Requirement: PIE rejects every Asset-related reload
While PIE is active, any change to an Asset declaration, builder, normalized descriptor or generated API SHALL be rejected before module swap and queued for a full reload after PIE. Existing descriptors, records, owners and load state SHALL remain last-good.

#### Scenario: Bundle-only edit during PIE
- **WHEN** only a Bundle name/path changes during PIE
- **THEN** the old module and backend record remain active and the latest source is queued

#### Scenario: AssetPath or ID edit during PIE
- **WHEN** AssetPath, PrimaryAssetType or Name changes during PIE
- **THEN** no owner/refcount/record mutation occurs and a full reload is queued

#### Scenario: Equivalent textual reordering during PIE
- **WHEN** source changes only reorder duplicate/equivalent Bundle operations and normalization yields the same descriptor
- **THEN** the classifier may treat the Asset descriptor as unchanged and no backend mutation occurs

#### Scenario: Unrelated body reload during PIE
- **WHEN** a changed ordinary function has no dependency on an Asset declaration or generated API
- **THEN** the existing soft-reload policy may apply without touching Dynamic Asset state

#### Scenario: Apply after PIE
- **WHEN** PIE ends after multiple related edits
- **THEN** the latest source is evaluated once through the non-PIE transaction rules

### Requirement: Former UObject literal assets fail with a Singleton migration
The runtime MUST reject the former UObject literal interpretation when the `of` token resolves to a UClass or the body uses old UObject property initialization. The diagnostic MUST show a complete migration using the `singleton` keyword and an `Init` block.

#### Scenario: Old Global UObject literal
- **WHEN** source contains the former `asset DefaultConfig of UGameConfig` object initializer
- **THEN** compilation fails with an example containing `USINGLETON(Global)`, `singleton DefaultConfig of UGameConfig`, `Init { ... }`, and `DefaultConfig::Get()` guidance

#### Scenario: Old World-owned object literal
- **WHEN** the former Type is Actor, Widget or Component
- **THEN** the diagnostic directs the author to `USINGLETON(World)` and does not reinterpret the UClass name as a PrimaryAssetType

### Requirement: Dynamic Asset observability is read-only and offline execution is forbidden
State Dump SHALL report definitions, materialization and shared ownership without triggering registration or loading. Standalone UE-validation SHALL validate descriptors/generated signatures but SHALL NOT simulate UAssetManager or execute Dynamic Asset runtime APIs.

#### Scenario: Dump unmaterialized declaration
- **WHEN** State Dump captures an unused declaration
- **THEN** it reports ID/fingerprint/Bundle counts and Materialized=false without calling AddDynamicAsset

#### Scenario: Dump shared materialized record
- **WHEN** two Engines own one identical record
- **THEN** Engine-local rows and backend owner/refcount data make the sharing explicit

#### Scenario: Standalone runtime call
- **WHEN** Standalone code attempts to execute GetId, LoadAsync or Unload
- **THEN** it fails through an explicit UE-runtime trap rather than fabricating an ID registration or load
