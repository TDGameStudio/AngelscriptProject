## ADDED Requirements

### Requirement: AngelScript exposes one minimal public Event namespace
`UnrealEventAngelscript` SHALL register the stable public operations `Event::Listen`, `ListenWorld`, `ListenObject`, `Send`, `SendWorld`, `SendObject`, `Unlisten`, and `UnlistenAll`, plus opaque `FUnrealEventHandle`. It MUST NOT expose Store, Once, request/response, collections, GameplayTag overloads, Blueprint/K2 helpers, Fast-suffixed APIs, SymbolIndex, Store pointers, or public per-Key generated APIs.

The adapter MAY register implementation-only configured functions under reserved `__UnrealEventInternal`; that namespace is not a supported consumer contract and SHALL NOT be documented as public API.

#### Scenario: Public surface is enumerated
- **WHEN** supported AS declarations and consumer documentation are inspected
- **THEN** the exact Event operations and handle are present
- **AND** no excluded/Fast/per-Key public operation is present

#### Scenario: Script uses ordinary names
- **WHEN** script calls `Event::Send(n"Player.Hurt", 25, Causer)`
- **THEN** the normal FName source spelling is accepted
- **AND** script does not name an internal adapter or generated Key wrapper

### Requirement: Configured literal calls are transparently specialized in memory
Before AS preprocessing/initial compilation, a file-static `FAngelscriptBind` provider SHALL register one typed internal Listen/Send family for every valid configured Key using its exact startup-native signature and SymbolIndex. Adapter names SHALL combine sanitized Key text with a deterministic full-canonical-Key-string hash. Runtime configuration SHALL already be frozen, and the `OnPostProcessCode` hook SHALL already be installed, before the bind registry is sealed. Registration and preprocessing MUST NOT generate `.as`, `.h`, or `.cpp` files. Because `IAngelscriptExtension::OnEngineAttached` occurs after initial compilation, it MUST NOT be the declaration-registration mechanism.

#### Scenario: Startup ordering reaches initial compilation
- **WHEN** the maintained AS engine prepares registered bind phases and preprocesses initial script modules
- **THEN** Runtime configured metadata, public/internal declarations, and the rewrite hook already exist
- **AND** no configured declaration depends on a post-compile extension callback

`FAngelscriptPreprocessor::OnPostProcessCode` SHALL rewrite valid configured FName-literal `Event::Listen*`/`Send*` calls to their reserved adapter and remove the Key argument. Unconfigured literals and variable expressions SHALL remain on public generic overloads.

#### Scenario: Configured literal Send is preprocessed
- **WHEN** source calls `Event::Send(n"Player.Hurt", Damage)` and configuration defines `Player.Hurt(int32)`
- **THEN** processed code calls the hashed internal typed adapter without the Key argument
- **AND** adapter user data already identifies the configured SymbolIndex/signature

#### Scenario: Sanitized names collide
- **WHEN** two configured Keys sanitize to the same identifier text
- **THEN** their full-Key hashes produce distinct internal declarations and rewrites

#### Scenario: Variable contains a configured Key
- **WHEN** script calls public generic `Event::Send(Key, Damage)` and `Key` equals a configured name
- **THEN** Runtime automatic routing uses that configured Store
- **AND** the call retains generic marshalling cost because preprocessing cannot prove the Key

#### Scenario: Configured binding artifacts are inspected
- **WHEN** the build and source tree are checked after binding registration
- **THEN** no config-generated AS or C++ source artifact is required

### Requirement: Configured adapters cache the complete warm marshalling plan
Internal adapter user data SHALL retain SymbolIndex, configured signature/fingerprint, canonical descriptors, resolved native/AS type identities, property/layout copy-destruction operations, and AS engine generation. A warm configured literal Send MUST NOT repeat Key routing, `PropertyFromString`, `FindFunction`, or parameter-layout discovery.

#### Scenario: Warm typed Send repeats
- **WHEN** one configured literal Send runs repeatedly after initial binding/cache setup
- **THEN** Key-route, reflected-type-name, method-name, and layout-resolution counters remain zero
- **AND** every call reaches the current GameInstance's configured Store directly by SymbolIndex

#### Scenario: AS engine generation changes
- **WHEN** engine/reload lifecycle invalidates the adapter generation
- **THEN** stale adapter/callback metadata is not executed
- **AND** the current engine rebuilds or re-resolves the required cache before use

### Requirement: Listen operations return stable handles and validate named callbacks
The three public Listen operations SHALL accept FName Key, non-null listener, FName Method, `Order=0`, and `Times=-1`; `ListenObject` SHALL additionally accept valid Source first. Success SHALL return active `FUnrealEventHandle`; failure SHALL return the default invalid handle without partial registration. Configured literal Listen MAY be transparently rewritten but SHALL preserve identical public behavior.

#### Scenario: Valid script UFUNCTION registers
- **WHEN** a script UObject supplies a named `UFUNCTION()` returning void with a compatible input-only signature
- **THEN** Listen returns a handle owned by the listener's GameInstance subsystem
- **AND** accepted matching Send invokes the method

#### Scenario: Configured listener registers before Send
- **WHEN** Listen targets a configured Key before any Send
- **THEN** callback compatibility is validated immediately against configuration
- **AND** the slot is never provisional

#### Scenario: Dynamic listener registers before Send
- **WHEN** Listen targets an unconfigured Key with no established signature
- **THEN** a valid callback may be provisional
- **AND** first Send later deactivates it if its prefix is incompatible

#### Scenario: Method is not reflected
- **WHEN** Method names a script-only function without `UFUNCTION()`
- **THEN** registration returns invalid handle with diagnostic

#### Scenario: Callback declaration is invalid
- **WHEN** method has return value, output/non-const-ref, unsupported type, or too many parameters
- **THEN** registration fails or a dynamic provisional slot later deactivates
- **AND** fabricated conversion is never used

#### Scenario: Times zero is requested
- **WHEN** a Listen operation receives `Times=0`
- **THEN** it returns invalid handle and creates no slot

### Requirement: Send operations provide zero through eight public generic overloads
Each public `Send`, `SendWorld`, and `SendObject` SHALL have overloads for zero through eight payloads; `SendObject` SHALL place Source before Key. Send SHALL return true when thread/context/source/Key/count/types/signature are valid and the message is accepted, even with no matching listener; otherwise false with no callback.

#### Scenario: Every supported arity compiles
- **WHEN** scripts compile zero through eight payload calls for all three Send families
- **THEN** each resolves to a public generic or transparently selected configured typed binding with identical result semantics

#### Scenario: Ninth payload is provided
- **WHEN** script attempts nine payload values
- **THEN** no public or internal matching v1 overload exists

#### Scenario: Accepted send has no listeners
- **WHEN** a configured signature matches or dynamic Send establishes/matches but no listener matches scope
- **THEN** Send returns true

#### Scenario: Configured signature mismatches
- **WHEN** configured event receives different count/canonical type
- **THEN** Send returns false, invokes none, and cannot replace the configured signature

### Requirement: Generic and configured AS type matrices are explicit
Public generic marshalling SHALL accept bool/numeric primitives, FName, FString, enums, UObject-derived handles, and reflected USTRUCT values available to the runtime bridge. Configured typed adapters SHALL be limited to the same primitive/name/string categories plus startup-registered native UEnum/UClass/UScriptStruct paths. Neither path SHALL perform implicit numeric conversion or accept containers, non-UObject pointers, arbitrary unsupported FFI, output arguments, or more than eight payloads.

#### Scenario: Supported generic matrix is sent
- **WHEN** script sends each supported generic category with a matching signature
- **THEN** listener observes exact value and canonical type

#### Scenario: Supported configured matrix is bound
- **WHEN** configuration uses primitives and valid native reflected paths
- **THEN** typed adapters register before script compilation
- **AND** processed calls receive compile-time typed declarations

#### Scenario: AS-defined configured type is requested
- **WHEN** configuration attempts to use a type that exists only after AS compilation
- **THEN** configuration rejects that fast entry
- **AND** the type may only be used through an otherwise supported dynamic/generic route

#### Scenario: Numeric types differ
- **WHEN** established/configured type is Int32 and script sends Int64, float, or another numeric kind
- **THEN** Send rejects rather than converts

#### Scenario: Unsupported container is sent
- **WHEN** script attempts TArray/TSet/TMap or another unsupported generic container
- **THEN** compilation or runtime validation rejects it with diagnostic

### Requirement: Callback parameters are an exact payload prefix
The adapter SHALL construct callback parameters from the first N declared payload arguments using current UFunction layout/lifecycle. It MUST NOT pass trailing values, synthesize defaults, reorder/skip values, or expose borrowed buffers after return.

#### Scenario: Listener ignores trailing payload
- **WHEN** a three-argument event invokes a compatible one-argument listener
- **THEN** only argument zero is marshalled
- **AND** callback runs once

#### Scenario: Listener skips first argument
- **WHEN** callback first type matches payload argument one but not zero
- **THEN** it is rejected because compatibility is prefix-based

### Requirement: Cached UASFunction dispatch uses the valid fastest callback path
For a named AS callback, weak Listener + Method SHALL remain authoritative and the resolved UFunction SHALL be cached with engine/reload generation. A current compatible `UASFunction` with valid `JitFunction_ParmsEntry` SHALL use that exact parameter-entry ABI; otherwise the adapter SHALL use `ProcessEvent` with correctly managed parameter storage.

#### Scenario: StaticJIT parameter entry is available
- **WHEN** current compatible UASFunction has non-null valid parameter entry
- **THEN** warm dispatch uses it
- **AND** performs neither `FindFunction` nor `ProcessEvent`

#### Scenario: Parameter entry is unavailable
- **WHEN** callback is interpreted/native/reflected or lacks valid parameter entry
- **THEN** dispatch uses `ProcessEvent`
- **AND** initializes, copies, and destroys the declared prefix exactly

#### Scenario: Callback execution fails
- **WHEN** AS callback raises an exception/failure
- **THEN** failure is diagnosed and finite Times stays consumed
- **AND** later listeners remain eligible

### Requirement: Hot Reload and teardown invalidate every stale AS cache
The AS module SHALL register an `IAngelscriptExtension` for post-publication engine/cache lifecycle and invalidate callback/typed-adapter caches on compatible implementation replacement, incompatible signature change, method removal, module discard, engine teardown, or adapter shutdown. Static bind providers remain responsible for declarations on each new engine. Stale UFunction/JIT addresses MUST never execute.

#### Scenario: Compatible implementation reloads
- **WHEN** registered method is replaced compatibly
- **THEN** next dispatch resolves/calls the new implementation
- **AND** old address is not called

#### Scenario: Method disappears or changes incompatibly
- **WHEN** current method is missing or no longer exact-prefix compatible
- **THEN** slot deactivates and reports once
- **AND** later sends do not retry stale address

#### Scenario: Engine tears down
- **WHEN** AS engine/module shuts down
- **THEN** extension releases function/adapter cache state and hooks
- **AND** Runtime Hub retains no AS-owned strong pointer

#### Scenario: Engine fails before post-compile attachment
- **WHEN** configured adapter contexts were created during bind phases but initial compilation/publication fails before `OnEngineAttached`
- **THEN** engine/module cleanup releases every adapter context and function user-data owner
- **AND** no post-compile callback is required to prevent a leak or stale pointer

### Requirement: Unlisten operations are exact and GameInstance-local
`Event::Unlisten` SHALL return true only when it removes the active supplied handle. `Event::UnlistenAll` SHALL resolve listener GameInstance, remove all its active Game/World/Object registrations, and return exact count. Invalid/default/stale/foreign handles or invalid listener SHALL produce false/zero without unrelated mutation.

#### Scenario: One active handle is removed
- **WHEN** script calls Unlisten with current handle
- **THEN** exactly that slot is removed and true returned

#### Scenario: UnlistenAll spans scopes
- **WHEN** one listener has two Game, one World, and three Object slots in one GI
- **THEN** UnlistenAll returns six and removes all six

#### Scenario: Foreign handle is supplied
- **WHEN** script passes default, stale, or foreign-GI handle
- **THEN** Unlisten returns false
- **AND** no active unrelated slot changes

### Requirement: AS boundary errors fail closed with useful diagnostics
Invalid context/source/listener/Key/method/thread/arity/callback/payload/signature SHALL reject before callback. Development diagnostics SHALL identify Event operation, Key/scope, and constraint. Shipping SHALL retain compact validation while verbose text may compile out.

#### Scenario: Invalid source is sent
- **WHEN** `SendObject` receives null, dead, or cross-GI Source
- **THEN** it returns false, invokes none, and establishes no dynamic signature

#### Scenario: Configured adapter cannot resolve current GI
- **WHEN** a rewritten configured call has no authoritative active GameInstance
- **THEN** it fails without dereferencing any configured Store from another GI

#### Scenario: One callback fails
- **WHEN** callback execution reports failure
- **THEN** diagnostic identifies Key/method when verbose diagnostics are enabled
- **AND** later listeners still run
