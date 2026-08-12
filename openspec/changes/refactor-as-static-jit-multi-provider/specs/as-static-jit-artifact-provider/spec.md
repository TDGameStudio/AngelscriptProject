## ADDED Requirements

### Requirement: Modules publish current-revision JIT provider views

`AngelscriptRuntime` SHALL define `IAngelscriptJITArtifactProvider` and POD-style entry/provider views. A view MUST declare struct size, current ABI revision, full stable ProviderId, diagnostic provider name, content-derived ProviderGeneration, complete artifact-set digest, artifact profile, Native environment fingerprint, entry table/count, and bucket count. Runtime SHALL NOT provide old-revision adapters.

#### Scenario: Compatible provider is enumerated

- **WHEN** any test, project, or plugin JIT module registers a view with the current struct size and ABI revision
- **THEN** Runtime copies and validates the complete view during enumeration
- **AND** it does not retain provider-owned view, entry, string, or array memory after the accessor returns

#### Scenario: Provider ABI is incompatible

- **WHEN** a provider reports an unknown revision, too-small struct, invalid count, null required field, malformed entry, or inconsistent artifact-set digest
- **THEN** Runtime rejects it before reading unsupported data
- **AND** script execution remains available through VM

#### Scenario: Provider generation record is ambiguous

- **WHEN** two views claim the same ProviderId and ProviderGeneration but contain different manifests
- **THEN** Runtime rejects the ambiguous generation
- **AND** it retains the previous exact routes or VM fallback

### Requirement: The Runtime registry supports multiple provider modules

The Runtime JIT Registry SHALL support several concurrently loaded UE provider modules without merging their ownership into one FunctionId map. A UE module MAY expose one or more stable ProviderIds, and one Provider MAY contain entries owned by several AngelScript modules. Provider and entry selection MUST be independent of UE load order, registration order, pointer value, and numeric FunctionId.

#### Scenario: Test and project Providers coexist

- **WHEN** `AngelscriptTestJIT` and the project `AngelscriptJIT` module are loaded in the same Editor process
- **THEN** each registers its own stable ProviderId and current ProviderGeneration in the same Runtime Registry
- **AND** the test Provider contains only plugin-owned test-fixture entries
- **AND** the project Provider contains only its configured project source-domain entries
- **AND** loading, refreshing, or unloading either Provider does not clear the other's catalog entries or exact routes

#### Scenario: One Provider contains several AS modules

- **WHEN** one generated Provider contains functions from several AngelScript source modules
- **THEN** each entry retains its StableModuleKey and StableFunctionKey
- **AND** functions from all included AS modules can independently match current functions
- **AND** changing one AS module does not remove exact entries from an unrelated module in the same Provider generation unless complete-set dependencies require it

#### Scenario: One UE module exposes separate Provider domains

- **WHEN** one UE module intentionally registers more than one provider feature object
- **THEN** each view has a different stable ProviderId and independently validated manifest
- **AND** shutdown unregisters only the ProviderIds owned by that UE module

### Requirement: Provider selection is generation-aware and conflict-safe

For one ProviderId, Runtime SHALL select only its current compatible ProviderGeneration and SHALL retire older generations safely. Different ProviderIds SHALL coexist. If different ProviderIds both remain exact candidates for one complete current function identity, Runtime SHALL publish VM for that function with `AmbiguousExactProvider`; it MUST NOT choose by registration order, module load order, provider name, or entry-pointer address.

#### Scenario: Same Provider publishes a newer generation

- **WHEN** a ProviderId publishes a newer compatible ProviderGeneration after generation or Live Coding
- **THEN** Runtime replaces only that ProviderId's selected generation at a safe point
- **AND** unrelated ProviderIds remain registered and selected
- **AND** in-flight calls may retain the older immutable generation until they exit

#### Scenario: Different Providers claim the same exact function

- **WHEN** two different ProviderIds contain otherwise exact entries for one current StableModuleKey, StableFunctionKey, Execution hash, profile, environment, ABI, and reference set
- **THEN** that function receives VM with `AmbiguousExactProvider`
- **AND** diagnostics list every conflicting ProviderId and ProviderGeneration
- **AND** unrelated non-conflicting functions may still select Native entries

#### Scenario: Conflicting Provider departs

- **WHEN** one of two conflicting Providers unregisters and exactly one candidate remains
- **THEN** Runtime may publish the remaining exact Native Binding at the next safe point
- **AND** no AS recompilation or Cache V2 invalidation is required solely for the Provider departure

### Requirement: Provider entries use stable full-hash identity

Every provider entry MUST identify its Native implementation using the complete stable function key, Execution and Debug content hashes, artifact profile, Entry ABI hash, Native environment fingerprint, entry points, and ordered stable reference slots. Numeric FunctionId and derived display GUID MUST NOT be authoritative provider keys.

#### Scenario: FunctionId changes but identity matches

- **WHEN** a current function receives a different numeric FunctionId but retains the same full stable key, Execution content, profile, ABI, environment, and references
- **THEN** the provider entry remains an exact match

#### Scenario: Display GUID collides

- **WHEN** two entries share a diagnostic display GUID but differ in remaining full-hash bytes
- **THEN** Runtime treats them as distinct or rejects an actual full-key collision
- **AND** it never attaches by display GUID alone

#### Scenario: Whitespace changes only debug identity

- **WHEN** source formatting changes Debug hash without changing StableFunctionKey or Execution hash
- **THEN** a runtime-debug-mapped entry remains eligible for Native execution
- **AND** diagnostics report the current and provider Debug hashes

#### Scenario: Entry requires exact debug identity

- **WHEN** an entry declares exact-debug matching and its Debug hash differs
- **THEN** that entry receives a typed Debug mismatch and uses VM

### Requirement: Generated references resolve through stable Engine-local slots

Every generated external/type/function/global/layout reference required by an entry SHALL be described as `ReferenceKind + full StableKey + ExpectedAbi + SlotIndex`. Runtime SHALL resolve the ordered slots against the current Engine and binding environment before selecting Native.

#### Scenario: Every required reference resolves

- **WHEN** all stable keys resolve uniquely and their current ABI fingerprints match
- **THEN** Runtime publishes an immutable Engine-local reference table for that entry
- **AND** generated code accesses it through the current execution/Binding context

#### Scenario: One required reference is missing or stale

- **WHEN** a required slot is missing, ambiguous, wrong-kind, or ABI-incompatible
- **THEN** only entries that require that slot fall back to VM with a typed reference reason
- **AND** no generated code dereferences a process address captured during generation

#### Scenario: Two engines resolve the same manifest

- **WHEN** two AngelScript engines consume one process-visible provider
- **THEN** each engine owns a separate resolved reference table
- **AND** one engine's function/type pointers cannot appear in the other's table

### Requirement: Native mismatch is isolated per function

The route builder SHALL validate entries per function and SHALL select VM for a missing key, Execution or required Debug mismatch, profile/environment/Entry ABI mismatch, reference mismatch, stale generation, or duplicate/collision state without clearing unrelated exact matches.

#### Scenario: One function body changes

- **WHEN** a provider matches every current function except one function's Execution hash
- **THEN** unchanged functions retain Native routes
- **AND** the changed function receives VM with `ContentMismatch`

#### Scenario: Signature or reflected ABI changes

- **WHEN** a function signature, owner, UFUNCTION contract, call-frame shape, or required layout changes
- **THEN** its stable identity or Entry ABI fails the old entry
- **AND** current AS/ClassGenerator behavior remains authoritative while the function uses VM

#### Scenario: Provider profile is wrong

- **WHEN** a provider targets a different platform, configuration, target, script-preprocessor profile, or binding environment
- **THEN** its incompatible entries are rejected for the current engine
- **AND** another compatible provider may still supply exact entries

### Requirement: Route state is owned by each AngelScript engine

Each `FAngelscriptEngine` SHALL own the stable-key-to-current-function map, verified artifact identities, complete JIT Bindings, resolved references, immutable route snapshot, publication ordinal, match/miss state, and execution counters. A process provider catalog MUST NOT own current FunctionIds, AS pointers, or active routes.

#### Scenario: Two engines reuse numeric FunctionIds

- **WHEN** two engines assign the same numeric FunctionId to different stable functions
- **THEN** each engine builds and publishes independent routes
- **AND** one engine cannot attach the other's function or reference pointers

#### Scenario: Cache V2 restores current functions

- **WHEN** Cache V2 commits restored modules into one engine
- **THEN** it publishes current VM functions through the neutral function-artifact route
- **AND** StaticJIT enriches that same route rather than maintaining a competing route manager

#### Scenario: One engine recompiles

- **WHEN** one engine replaces modules while another engine remains unchanged
- **THEN** only the recompiling engine rebuilds current-function and JIT route state

### Requirement: Provider generations publish atomically

Runtime SHALL build a complete immutable route snapshot from one validated set of provider generations and SHALL publish it only at an Engine compilation/safe point. Failed validation MUST leave the prior snapshot unchanged.

#### Scenario: New generation is valid

- **WHEN** a newer expected provider generation validates against current functions
- **THEN** Runtime atomically publishes the new snapshot and complete Bindings
- **AND** new calls observe the new routes

#### Scenario: Calls are in flight

- **WHEN** refresh is requested while script calls can still execute old entries
- **THEN** publication waits for a safe point or retains the old immutable snapshot/provider state for those calls
- **AND** no active call dereferences released route or reference memory

#### Scenario: Provider module unloads

- **WHEN** a provider unregisters or departs
- **THEN** only its selected entries are removed at the next safe publication
- **AND** affected functions select another exact provider or VM without invalidating Cache V2 state

### Requirement: Immutable packaged direct calls require complete set validation

Development/Shipping providers MAY emit direct Native script-to-script calls only when the complete immutable artifact-set digest and Native environment fingerprint match. A partially matching direct-call set MUST NOT call stale implementation symbols.

#### Scenario: Complete immutable set matches

- **WHEN** every required entry/reference and the artifact-set/environment digests match the packaged script state
- **THEN** Runtime may enable direct-call optimized entries

#### Scenario: One direct-linked entry is stale

- **WHEN** any entry/reference or the complete set digest is stale
- **THEN** Runtime disables every entry whose direct links depend on that set
- **AND** execution uses routed Native or VM fallback
