## ADDED Requirements

### Requirement: The singleton keyword declares a named singleton
The language SHALL accept a top-level `singleton Name of UObjectType { ... }` declaration. `USINGLETON` SHALL be an optional declaration specifier immediately associated with a `singleton` declaration, and SHALL NOT replace the `singleton` keyword.

#### Scenario: Declaration without a macro
- **WHEN** a module compiles `singleton DefaultConfig of UGameConfig { }`
- **THEN** the declaration is accepted as a Global named singleton and no UObject is created during compilation or module activation

#### Scenario: Explicit Global spellings
- **WHEN** a declaration is preceded by `USINGLETON()` or `USINGLETON(Global)`
- **THEN** it has the same Global semantics as a declaration without `USINGLETON`

#### Scenario: Explicit World spelling
- **WHEN** a declaration is preceded by `USINGLETON(World)`
- **THEN** it is registered as a World named singleton definition

#### Scenario: Invalid macro placement or arguments
- **WHEN** `USINGLETON` has an unsupported argument or is not followed by a `singleton` declaration
- **THEN** preprocessing fails at the specifier with an actionable syntax diagnostic

### Requirement: Named singleton identity is name-based
The runtime SHALL identify a named definition by `(Scope, ModuleStableId, Namespace, DeclarationName)`. The declared UObject Type SHALL be validated metadata but SHALL NOT make different names alias the same slot.

#### Scenario: Multiple names use one UObject type
- **WHEN** one module declares `DefaultConfig` and `PreviewConfig` with the same Global UObject Type
- **THEN** the declarations compile and their first successful Gets create two different instances

#### Scenario: Duplicate named definition
- **WHEN** a candidate module contains two declarations with the same Scope, module, namespace, and declaration name
- **THEN** the candidate is rejected even if their UObject Types are identical

#### Scenario: Names in different namespaces
- **WHEN** two otherwise identical declaration names occur in different AngelScript namespaces
- **THEN** they have different stable definition identities and resolve through their respective namespaces

### Requirement: Named declarations generate typed Get APIs
Each named declaration SHALL generate a namespace named after the declaration and SHALL expose a typed lazy Getter through that namespace.

#### Scenario: Global generated Getter
- **WHEN** `singleton DefaultConfig of UGameConfig` compiles
- **THEN** script code can call `DefaultConfig::Get()` with static return type `UGameConfig`

#### Scenario: World generated Getter overloads
- **WHEN** `USINGLETON(World) singleton CombatManager of ACombatManager` compiles
- **THEN** script code can call both `CombatManager::Get()` and `CombatManager::Get(UObject Context)` with static return type `ACombatManager`

#### Scenario: Generated namespace collision
- **WHEN** the generated namespace or `Get` overload conflicts with an existing symbol in the same module namespace
- **THEN** compilation fails with the declaration source location and the conflicting generated signature

### Requirement: Default unnamed singleton access requires no declaration
The runtime SHALL expose `Singleton::GetGlobal(UClass Type)` and `Singleton::GetWorld(UClass Type, UObject Context)` without requiring a `singleton` declaration. Both functions SHALL determine their script return type from `Type` and SHALL key default slots by Scope and resolved UObject class identity.

#### Scenario: Default Global access
- **WHEN** script calls `Singleton::GetGlobal(UMyService)` twice in one Engine
- **THEN** both calls return the same lazily created `UMyService` instance

#### Scenario: Default World access
- **WHEN** script calls `Singleton::GetWorld(UMyWorldService, Context)` twice with contexts resolving to one eligible World
- **THEN** both calls return the same instance for that World

#### Scenario: Default and named slots use the same Type
- **WHEN** a named Global declaration and `Singleton::GetGlobal` both use `UGameConfig`
- **THEN** they return different objects and neither slot executes or inherits the other slot's lifecycle blocks

#### Scenario: Invalid default Type
- **WHEN** the Type is null, non-UObject, abstract, a subsystem, or invalid for the requested Scope
- **THEN** the call throws an actionable script exception and creates no slot instance

### Requirement: Singleton instances are created lazily and atomically
Compilation, module activation, descriptor lookup, State Dump and generated API registration SHALL NOT create singleton instances. The first successful Get SHALL create and initialize exactly one candidate and SHALL publish it only after initialization succeeds.

#### Scenario: Unused definition
- **WHEN** a valid named declaration is compiled but never accessed
- **THEN** its Registry state remains Empty and no UObject or World side effect occurs

#### Scenario: First and repeated Get
- **WHEN** a valid Empty slot is accessed and Create plus Init succeed
- **THEN** the first call transitions the slot to Ready and all later calls return the published object without replaying Init

#### Scenario: Concurrent or off-thread Get
- **WHEN** a Get is invoked outside the Game Thread
- **THEN** it fails before allocation with a Game Thread diagnostic

### Requirement: Singleton lifecycle blocks have fixed semantics
A named declaration SHALL allow at most one each of `Create`, `Init`, `Reload`, and `Deinit`. Global `Create` SHALL receive no Context; World `Create` SHALL receive the resolved Context. User-authored `Init`, `Reload`, and `Deinit` SHALL be parameterless implicit-this blocks. Their generated hidden functions SHALL remain global functions with exactly one real declared parameter of the singleton Type, SHALL mark that parameter zero with `external_implicit_this`, and SHALL be invoked explicitly with the current candidate, replacement, or Ready object.

#### Scenario: Initialization block
- **WHEN** an `Init` block assigns properties without an explicit receiver
- **THEN** the generated lifecycle function applies those assignments to the candidate instance exactly once before it becomes Ready
- **AND** the generated function retains the candidate as declared parameter zero while member resolution aliases that parameter as implicit `this`

#### Scenario: Hidden lifecycle ABI remains global
- **WHEN** the preprocessor lowers `Init`, `Reload`, or `Deinit`
- **THEN** the hidden function has `objectType == nullptr`, one declared object parameter assignable to the descriptor Type, and `external_implicit_this`
- **AND** the Registry passes the lifecycle object as argument zero
- **AND** no VM, StaticJIT, or Semantic AOT path erases that parameter or adds a second native-this object slot

#### Scenario: Custom Global creation
- **WHEN** a Global declaration supplies `Create` and returns a valid newly owned object compatible with the declared Type
- **THEN** the Registry uses that object and invokes Init before publishing it

#### Scenario: Custom World creation
- **WHEN** a World declaration supplies `Create` and uses its Context to return a valid object in the resolved World
- **THEN** the Registry validates the returned object's Type, World and ownership before invoking Init

#### Scenario: Duplicate or wrong lifecycle signature
- **WHEN** a declaration repeats a lifecycle block, returns an incompatible Create Type, or declares explicit parameters for Init, Reload or Deinit
- **THEN** compilation fails at the lifecycle block without changing the active module

### Requirement: Built-in creation follows Unreal object-family rules
The Registry SHALL support every non-abstract UObject subclass that has a valid built-in or custom creation path for its Scope. Ordinary UObject, Actor, UserWidget and ActorComponent families SHALL use their corresponding Unreal construction protocol, and Global creation SHALL NOT borrow process-global World state.

#### Scenario: Ordinary Global UObject
- **WHEN** a Global slot uses a concrete ordinary UObject class
- **THEN** the Registry creates a transient Engine-owned instance without consulting `GWorld`

#### Scenario: Ordinary World UObject
- **WHEN** a World slot uses a concrete ordinary UObject class
- **THEN** the Registry creates the instance with ownership tied to the resolved World and releases it during that World's teardown

#### Scenario: Actor World singleton
- **WHEN** a World slot uses a concrete Actor class
- **THEN** it is spawned exactly once through the target World's Actor construction path and is fully initialized before Get returns

#### Scenario: Widget or Component World singleton
- **WHEN** a World slot uses a valid UserWidget or ActorComponent class
- **THEN** the Registry uses the appropriate CreateWidget or NewObject/Register path and returns an instance associated only with the target World

#### Scenario: World-owned class requested as Global
- **WHEN** Actor, UserWidget or ActorComponent is requested in Global scope
- **THEN** validation fails with guidance to use `USINGLETON(World)` or a different ordinary UObject type

#### Scenario: Collection-owned or template class
- **WHEN** Type derives from USubsystem, is collection-owned, abstract, a CDO, an archetype or an invalid newer-version class
- **THEN** validation rejects it and identifies the existing UE ownership API where applicable

### Requirement: Custom Create cannot borrow or cross scopes
Custom Create SHALL return a non-null, newly owned, Type-compatible candidate that belongs to the requested Engine/World and is not already owned by another singleton slot or UE collection.

#### Scenario: Invalid custom candidate
- **WHEN** Create returns null, a wrong Type, a CDO/archetype, an object from another World, or an object already owned by another slot
- **THEN** creation fails, the candidate is not published, and the slot returns to Empty for a later retry

#### Scenario: Specialized Actor or Component setup
- **WHEN** a World declaration requires a particular Actor spawn configuration or Component Owner/Attachment
- **THEN** a valid custom Create may supply that configuration while the Registry still enforces Type, World and unique ownership

### Requirement: Slot state detects failures and cycles
Each actual slot SHALL follow `Empty`, `Creating`, `Initializing`, `Ready`, and `Releasing` states. A failed Create or Init SHALL leave no published object and SHALL be retryable; recursive access SHALL fail with a complete creation-chain diagnostic.

#### Scenario: Create throws
- **WHEN** Create throws or returns an invalid candidate
- **THEN** the candidate is released, the slot becomes Empty, last-error diagnostics are recorded, and the next Get may retry

#### Scenario: Init throws
- **WHEN** Init throws after candidate construction
- **THEN** the candidate is released without becoming Ready and the next Get may create a fresh candidate

#### Scenario: Direct recursion
- **WHEN** a slot's Init requests the same slot
- **THEN** the inner Get throws a cycle exception and never returns the partial candidate

#### Scenario: Indirect recursion
- **WHEN** A creates B and B requests A
- **THEN** the diagnostic contains the ordered A-to-B-to-A slot chain

### Requirement: Singleton scopes are Engine and World isolated
Global instances SHALL be unique within exactly one `FAngelscriptEngine`. World instances SHALL additionally be unique within one eligible Game, PIE or GamePreview `UWorld`, and SHALL NOT use an arbitrary process-global World fallback.

#### Scenario: Two Angelscript Engines
- **WHEN** two Engines access the same named or default Global slot
- **THEN** they receive different instances and shutting down one Engine does not modify the other

#### Scenario: Multiplayer PIE Worlds
- **WHEN** server and client PIE Worlds access the same named or default World slot
- **THEN** each World receives a distinct instance

#### Scenario: Missing ambient World
- **WHEN** a named World `Get()` executes without an eligible current Engine World
- **THEN** it throws a script exception and creates no instance

#### Scenario: Explicit invalid Context
- **WHEN** a World Getter receives null, a template object, a tearing-down World, or a Context that cannot resolve an eligible World
- **THEN** it throws before slot lookup and does not fall back to another World

### Requirement: Singleton instances are retained and released deterministically
The Engine Registry SHALL strongly retain active candidates and Ready instances without using the old literal-asset RootSet package. It SHALL release each World's slots during World cleanup and all remaining slots during Engine shutdown in reverse creation order.

#### Scenario: Garbage collection
- **WHEN** no script handle other than the Registry references a Ready singleton
- **THEN** garbage collection preserves the instance and its UObject references

#### Scenario: World teardown
- **WHEN** a World begins teardown
- **THEN** its Ready singleton instances enter Releasing, receive Deinit once in reverse creation order, and are released without affecting another World

#### Scenario: Engine shutdown
- **WHEN** an Engine shuts down with World and Global slots still active
- **THEN** World slots are released before Global slots and each scope releases in reverse creation order

#### Scenario: Deinit throws
- **WHEN** one Deinit block throws
- **THEN** the failure is recorded, that object is still released, and remaining slots continue to Deinit

### Requirement: Non-PIE reload preserves only compatible identity
Outside PIE, body-only changes SHALL preserve Ready instances and Getter routes. A compatible structural replacement of the same stable slot and declared Type SHALL migrate compatible reflected state and invoke Reload exactly once. A Name, Namespace, ModuleStableId, Scope or declared Type change SHALL be handled as removal plus addition without cross-identity migration.

#### Scenario: Ordinary body-only reload
- **WHEN** only an ordinary method or lifecycle body changes outside PIE and descriptor identity and class shape are unchanged
- **THEN** the same object address observes the new function routing and Init, Reload and Deinit are not replayed

#### Scenario: Compatible structural reload
- **WHEN** the declared class is structurally reinstanced for the same stable named slot outside PIE
- **THEN** same-name type-compatible reflected values are copied, new fields retain new defaults, Actor World/Level/Transform are preserved, references are redirected, and Reload runs once on the replacement

#### Scenario: Named identity or declared Type changes
- **WHEN** a named declaration changes Name, namespace, module identity, Scope or declared Type outside PIE
- **THEN** the old Ready slot receives Deinit and is removed while the new definition remains lazy and Empty

#### Scenario: Default class reinstancing
- **WHEN** the UClass of an active default slot is replaced outside PIE without changing its stable class path
- **THEN** the Registry remaps the default key to the replacement class and migrates the instance once

#### Scenario: Candidate reload fails before commit
- **WHEN** preprocessing, compilation, validation or pre-commit migration fails
- **THEN** the last-good module, descriptors, Getter routes and Ready instances remain unchanged

### Requirement: PIE rejects every singleton-related reload
While PIE is active, any candidate change to a named singleton descriptor, lifecycle block, referenced named Type, or class used by an active default slot SHALL be rejected and queued for full reload after PIE. The runtime SHALL NOT partially swap related code or mutate singleton slots.

#### Scenario: Lifecycle body edit during PIE
- **WHEN** only Init, Reload, Deinit or Create body text changes during PIE
- **THEN** the candidate is rejected, the old lifecycle function remains active, and a full reload is queued

#### Scenario: Named singleton Type body or shape edit during PIE
- **WHEN** code for the UObject class referenced by a named declaration changes during PIE
- **THEN** the entire related candidate remains last-good and no object is reinstanced

#### Scenario: Active default singleton Type edit during PIE
- **WHEN** code for a class with a Ready default slot changes during PIE
- **THEN** the candidate is rejected and queued even though no `singleton` declaration exists

#### Scenario: Unrelated soft reload during PIE
- **WHEN** a changed module/function has no singleton descriptor, lifecycle or active singleton Type dependency
- **THEN** the existing soft-reload policy may apply without touching singleton slots

#### Scenario: Queued reload after PIE
- **WHEN** PIE ends after one or more related edits were queued
- **THEN** the next full reload evaluates the latest source once against the non-PIE reconciliation rules

### Requirement: Singleton observability is read-only and offline execution is forbidden
State Dump SHALL expose singleton definition and active-slot state without triggering creation. Standalone UE-validation SHALL validate descriptors and generated signatures but SHALL NOT instantiate UObject, World or Registry state.

#### Scenario: Dump of an Empty definition
- **WHEN** State Dump captures a compiled but unused named definition
- **THEN** it reports the definition and Empty state without invoking Get

#### Scenario: Dump of active slots
- **WHEN** State Dump captures Ready named and default slots
- **THEN** rows distinguish key kind, Engine, scope, World, stable identity/type, instance path, creation order and last error

#### Scenario: Standalone attempts runtime Get
- **WHEN** native-runtime or ue-validation attempts to execute a singleton Getter
- **THEN** it fails through an explicit non-executable UE trap rather than simulating UObject creation
