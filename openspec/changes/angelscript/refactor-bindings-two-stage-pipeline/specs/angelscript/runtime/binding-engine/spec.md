## MODIFIED Requirements

### Requirement: Hosts can explicitly create a binding engine

The system SHALL provide FAngelscriptEngine::CreateForBindings for a fresh full Runtime database, an existing sealed database or a shared immutable preparation, returning an owned usable Engine or diagnostic failure. Preparation SHALL build external metadata once and support repeated Engine installation with separate mutable state.

#### Scenario: Create without ambient runtime services

- **WHEN** a host explicitly creates a binding engine
- **THEN** Runtime types, native calls and recorded type adapters are available through that engine
- **BUT** the operation does not activate default subsystem ownership, script scanning, initial script compilation, hot reload, debugger or cache services

#### Scenario: Prepare once and create multiple Engines

- **GIVEN** a valid shared immutable preparation built from one sealed Runtime database
- **WHEN** a host creates Engines A and B from that preparation
- **THEN** both admit the same original external metadata and IDs without rerunning providers or metadata preparation
- **AND** each constructs its own mutable installation, native bindings and recorded adapters

### Requirement: Binding engine resources remain isolated

The system SHALL associate mutable adapter, context, native, template-operation and delegate state with its exact Engine while sharing external definitions and preparation facts. Recorded adapter factories and property-finder descriptions SHALL reconstruct that owner's adapter registry automatically.

#### Scenario: Destroy one of two engines

- **GIVEN** two Engines created from one shared preparation
- **WHEN** one engine is destroyed
- **THEN** the surviving engine still resolves its types, finds its adapters and invokes its methods correctly
- **AND** the destroyed engine's contexts and binding resources are released without changing an ambient default engine

#### Scenario: Restore adapters and property finders from recording

- **GIVEN** a primary provider records an adapter factory and a property-finder description for a native value type
- **WHEN** a host creates two engines from the resulting database
- **THEN** each engine resolves its own adapter by type identity/name and maps the supported property to that adapter
- **AND** property conversion and value lifecycle use the owning engine's adapter state
- **BUT** constructing the engines does not rerun the provider or require manual post-creation adapter registration

## ADDED Requirements

### Requirement: Delegate subscriptions respect host storage lifetime

The binding system SHALL require an explicit valid host-storage scope for native delegate subscriptions and SHALL identify subscriptions independently from borrowed storage addresses.

#### Scenario: Native storage ends before its engine

- **GIVEN** a native delegate and a subscription whose host-storage scope ends before the delegate leaves scope
- **WHEN** the native storage is subsequently destroyed and its binding engine is destroyed later
- **THEN** engine cleanup performs no access to the expired delegate storage
- **AND** the subscription is no longer invocable or removable through a stale token

#### Scenario: Rebinding cannot be cleared by the previous owner

- **GIVEN** one live host-storage scope whose single delegate is rebound from engine A to engine B
- **WHEN** A or A's subscription token is destroyed
- **THEN** B's current binding remains intact and callable
- **AND** repeated unsubscribe of A's expired token has no effect

#### Scenario: Multicast cleanup preserves other listeners

- **GIVEN** a native multicast contains an existing host listener and one binding-owned listener
- **WHEN** the binding-owned subscription is released
- **THEN** only that listener is removed and the original host listener still executes
- **BUT** a duplicate owned subscription that the native storage cannot independently identify is rejected explicitly

### Requirement: Delegate payload execution retains stable resources across callbacks

The system SHALL retain an admitted payload call's target, signature, payload and parameter cleanup state independently of mutable subscription containers until that call completes.

#### Scenario: A payload callback unregisters itself and grows the registry

- **GIVEN** an admitted callback with a copied payload value of 7
- **WHEN** it unregisters itself and adds enough bindings to relocate the registry during its host callback
- **THEN** the admitted callback observes 7 and its parameter/payload resources are released exactly once after their final owner finishes
- **AND** a subsequent invocation of the removed handle fails as unbound

#### Scenario: Nested execution survives unrelated removal

- **WHEN** an admitted payload callback removes an earlier registry entry and makes a nested call
- **THEN** both admitted calls retain valid independent parameter cleanup state
- **AND** later calls observe the current registry membership without changing the outer call's lifetime
