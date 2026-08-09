## ADDED Requirements

### Requirement: Project modules publish a versioned StaticJIT provider view

`AngelscriptRuntime` SHALL define a versioned `IAngelscriptStaticJITArtifactProvider` modular-feature interface and POD-style provider/entry views. A provider view MUST declare struct size, ABI version, provider name, provider generation, artifact profile, Native environment fingerprint, entry table/count, and bucket count.

#### Scenario: Compatible provider is enumerated

- **WHEN** a project StaticJIT module registers a view with the supported struct size and ABI version
- **THEN** Runtime copies and validates the complete view during enumeration
- **AND** it does not retain provider-owned view memory after the accessor returns

#### Scenario: Provider ABI is incompatible

- **WHEN** a provider reports an unknown version, too-small struct, invalid entry count, or malformed view
- **THEN** Runtime rejects the provider before reading unsupported fields or entries
- **AND** script execution remains available through VM

### Requirement: Provider entries use stable full-hash identity

Every provider entry MUST identify a Native implementation using the complete stable function key, selected execution/debug content hashes, entry ABI hash, artifact profile, and Native environment fingerprint. Temporary AngelScript FunctionId and derived display GUID MUST NOT be authoritative provider keys.

#### Scenario: FunctionId changes but content matches

- **WHEN** a replacement AS function has a different current-engine FunctionId but the same full stable identity/content/profile/ABI
- **THEN** the provider entry matches that replacement function

#### Scenario: Display GUID collides

- **WHEN** two test entries share a diagnostic display GUID but differ in the remaining full-hash bytes
- **THEN** Runtime rejects ambiguity or treats them as distinct
- **AND** it never attaches by display GUID alone

### Requirement: Native mismatch is isolated per function

The route builder SHALL validate provider entries per function and SHALL attach VM for an entry with missing key, content mismatch, profile mismatch, environment mismatch, entry ABI mismatch, stale generation, or duplicate/collision state without clearing unrelated exact matches.

#### Scenario: One function body changes

- **WHEN** a provider matches every current function except the changed function's content hash
- **THEN** unchanged functions retain Native routes
- **AND** the changed function receives a VM route with `ContentMismatch`

#### Scenario: Provider profile is wrong

- **WHEN** an entire provider targets a different platform, configuration, target, or binding environment
- **THEN** its entries are rejected for the current engine
- **AND** other compatible providers may still contribute exact matches

### Requirement: Route state is owned by each AngelScript engine

Each `FAngelscriptEngine` SHALL own its stable-key-to-current-function map, immutable route snapshot, route generation, match/miss state, and execution counters. A process-level provider catalog MUST NOT own current AS FunctionIds or active function routes.

#### Scenario: Two engines reuse numeric FunctionIds

- **WHEN** two engines assign the same numeric FunctionId to different stable functions
- **THEN** each engine builds and publishes independent routes
- **AND** one engine's provider match cannot attach a pointer to the other engine's function

#### Scenario: One engine recompiles

- **WHEN** one engine replaces modules while another engine remains unchanged
- **THEN** only the recompiling engine rebuilds its current-function map and route snapshot

### Requirement: Provider generations publish atomically

Runtime SHALL build a complete immutable route snapshot from one validated set of provider generations and SHALL publish it only at an engine compilation/safe point. Failed validation MUST leave the previous valid snapshot unchanged.

#### Scenario: New provider generation is valid

- **WHEN** a newer provider generation is enumerated and all selected entries validate
- **THEN** Runtime atomically publishes a new route snapshot
- **AND** new calls observe that snapshot

#### Scenario: New provider generation is ambiguous

- **WHEN** duplicate providers claim the same provider name/generation with conflicting manifests or entries
- **THEN** the new selection is rejected as ambiguous
- **AND** the previous route snapshot or VM fallback remains active

#### Scenario: Calls are in flight during refresh

- **WHEN** a route refresh is requested while script calls are active
- **THEN** publication waits for the engine safe point or retains the old immutable snapshot for those calls
- **AND** no in-flight call dereferences released route state

### Requirement: Provider departure falls back safely

Module/provider unload SHALL remove only routes supplied by the departed generation and SHALL publish VM or another exact compatible provider entry at the next safe point.

#### Scenario: Provider module unloads

- **WHEN** a registered project StaticJIT provider unregisters
- **THEN** affected engine routes stop selecting its Native pointers
- **AND** unaffected provider routes and AS function-cache state remain intact

### Requirement: Immutable cooked direct calls require complete set validation

Cooked profiles MAY emit direct Native script-to-script calls only when the complete immutable provider artifact-set digest and Native environment fingerprint match. A partially matching direct-call set MUST NOT be mixed with VM/per-function entries in a way that can call stale symbols.

#### Scenario: Complete cooked set matches

- **WHEN** every entry and the immutable artifact-set digest match the packaged scripts/environment
- **THEN** Runtime may enable direct-call optimized entries

#### Scenario: One direct-linked entry is stale

- **WHEN** any required entry or artifact-set digest in an immutable direct-call provider is stale
- **THEN** Runtime disables the affected immutable set according to its manifest
- **AND** execution uses safe VM/provider fallback rather than a stale direct callee
