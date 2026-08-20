## ADDED Requirements

### Requirement: Native-form recipes live in a stable process-global catalog
Every real bind replay SHALL continue registering declarations into its Engine. When registration has a reviewed native form, the Runtime SHALL insert or validate a process-global recipe keyed by stable declaration identity plus target/bind profile. Recipes SHALL distinguish HeaderInline, module-exported, and bridge-only callability and carry canonical declaration ABI, include/header, owner module, spelling/thunk, route-safety, and linkage metadata.

#### Scenario: Repeated Engine registration is deterministic
- **WHEN** two Engines register the same stable declaration under the same profile with equivalent reviewed metadata
- **THEN** the catalog yields one equivalent recipe and does not depend on either Engine's `asIScriptFunction*`

#### Scenario: Registration disagrees
- **WHEN** a replay presents conflicting ABI, header, owning module, spelling, or route metadata for the same stable declaration/profile
- **THEN** catalog validation reports a deterministic conflict
- **AND** typed generation does not select either recipe as a safe direct call

### Requirement: Matching-profile AST generation resolves native forms without sibling replay
Matching-profile primary Engine TypedASTJIT generation SHALL resolve call recipes by stable canonical AST declaration identity from the catalog. It MUST NOT require `bCollectStaticJITCompatibilityBinds=true` or construct a sibling generation Engine solely to retain pointer-keyed forms.

#### Scenario: Reviewed catalog hit emits a safe call
- **WHEN** canonical AST resolves a call whose exact profile/declaration/ABI/route recipe is HeaderInline or safely module-exported
- **THEN** TypedASTJIT may emit the reviewed form with its required include/linkage contract

#### Scenario: Display name lacks linkage proof
- **WHEN** a native form has only a C++ display spelling or a provider-private implementation
- **THEN** the catalog does not classify it as externally linkable
- **AND** emission uses a reviewed bridge or typed fallback

### Requirement: Catalog lifetime is independent from AST and Engine pointers
Catalog recipes SHALL contain stable immutable metadata and MUST NOT own or retain `asIScriptFunction*`, AST node pointers, Engine-local IDs, registration lambdas, or generation Engine objects. Removing an Engine/module/snapshot SHALL not invalidate equivalent recipes for other current profiles.

#### Scenario: Source module Hot Reloads
- **WHEN** Hot Reload replaces script functions and canonical AST nodes but the reviewed native declaration ABI/profile is unchanged
- **THEN** the same stable catalog recipe remains selectable for the new generation
