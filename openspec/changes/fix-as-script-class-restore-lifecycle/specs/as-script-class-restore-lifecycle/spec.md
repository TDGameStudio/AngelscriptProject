## ADDED Requirements

### Requirement: Restored script classes are layout-equivalent

A compatible bytecode restore SHALL rebuild script-class layout in dependency
order and SHALL preserve base offsets, inherited-property identity, member
alignment, final size, and property metadata.

#### Scenario: Base and derived class round trip

- **WHEN** a module containing base and derived script classes with primitive
  and embedded value members is saved and loaded
- **THEN** restored sizes, alignments, property declarations/offsets, inherited
  identity, and runtime field reads SHALL match a freshly compiled control

#### Scenario: Invalid restored layout is rejected

- **WHEN** restored class dependencies are cyclic, missing, or inconsistent
- **THEN** loading SHALL fail without publishing a partially usable class

### Requirement: Script-class lifecycle remains balanced

Fresh and restored script classes SHALL run current-fork construction,
copy/assignment, destruction, failure cleanup, and engine teardown without
leaking or double-destroying members or bases.

#### Scenario: Destructor body raises an exception

- **WHEN** a script destructor exits exceptionally before generated member/base
  cleanup completes
- **THEN** every still-live owned member and required base SHALL be destroyed
  exactly once and the context SHALL remain recoverable according to the fork

#### Scenario: Engine teardown removes raw object registrations

- **WHEN** raw script objects are released and their engine is shut down
- **THEN** no process-wide registry entry SHALL retain an object or type pointer
  from that engine and a subsequent independent engine SHALL operate normally

#### Scenario: Public SDK ownership releases a raw script object

- **WHEN** an application creates a standalone raw script object through
  `CreateScriptObject`, `CreateScriptObjectCopy`, or
  `CreateUninitializedScriptObject`, balances any public AddRef/Release pair,
  and performs its final `ReleaseScriptObject`
- **THEN** the object SHALL remain alive through the balanced pair, the final
  release SHALL run its generated script destructor exactly once and free its
  allocation, and later module discard SHALL NOT repeat destruction

#### Scenario: Destructor-time retain preserves the raw object

- **WHEN** the generated script destructor re-enters the public SDK and retains
  its own exact object and TypeInfo
- **THEN** the initiating release SHALL NOT free the object, a later final
  release SHALL free it without invoking the already completed destructor
  again, and a mismatched TypeInfo SHALL NOT change ownership or select a
  destructor

#### Scenario: Derived raw object survives a base or interface view

- **WHEN** the VM assigns a derived standalone raw script object to a
  base-typed or implemented-interface slot and later dispatches through that
  view
- **THEN** the ownership transition SHALL retain the registered dynamic
  object, virtual or interface dispatch SHALL observe a live receiver, final
  release SHALL use the registered dynamic TypeInfo, and an unrelated TypeInfo
  SHALL remain rejected
