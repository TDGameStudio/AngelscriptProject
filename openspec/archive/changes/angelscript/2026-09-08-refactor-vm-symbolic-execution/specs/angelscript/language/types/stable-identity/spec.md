## ADDED Requirements

### Requirement: Authenticated schema and layout fingerprints preserve nominal identity

The SDK SHALL expose distinct deterministic schema and layout fingerprints for authenticated frozen definitions without changing their stable declaration identity or strengthening the existing shell-freeze contract.

#### Scenario: Observe identity before compatibility is available

- **WHEN** a caller creates an actual detached ObjectType with a stable declaration key
- **THEN** the object exposes that key immediately, without an Engine or runtime ID
- **BUT** a fingerprint request for an incomplete or unauthenticated definition returns an explicit failure and no digest

  > A nonzero caller-supplied key and successful low-level shell freeze are not proof of a canonical definition. Existing shell freeze remains usable independently.

#### Scenario: Distinguish identity from definition and storage changes

- **GIVEN** independently created versions of the same nominal declaration
- **WHEN** a member, callable contract, target representation or body changes
- **THEN** each comparison changes only in its declared domain

  | Change | Stable declaration key | Schema fingerprint | Layout fingerprint |
  |---|---|---|---|
  | Field name or callable return contract | Unchanged | Changes | Changes only if physical storage changes |
  | Field storage type or order | Unchanged | Changes | Reflects the resulting representation |
  | Target pointer width or storage ABI | Unchanged | Unchanged | Changes |
  | Function body or source location | Unchanged | Unchanged | Unchanged |

- **AND** ordinary callable keys alone do not authenticate complete signatures

  > Return type, parameter direction and relevant definition traits are compared even when an ordinary FunctionKey is equal.

#### Scenario: Recheck a frozen definition at admission

- **GIVEN** a previously fingerprinted definition whose exposed fields were subsequently corrupted
- **WHEN** a consumer authenticates it for executable linking
- **THEN** validation compares the actual definition with its complete canonical contract and rejects the mismatch
- **BUT** a stale cached digest cannot authorize publication

### Requirement: Fingerprint dependencies have explicit cycle and equality rules

The SDK SHALL compute local semantic fingerprints and target layout fingerprints with distinct dependency rules, preserving exact canonical witnesses and rejecting invalid value cycles without partial output.

#### Scenario: Fingerprint recursive handle types

- **GIVEN** types A and B that refer to each other through handles
- **WHEN** their schemas and layouts are fingerprinted
- **THEN** local schema records reference canonical type keys and handle layout uses pointer representation

  > The dependency requirement closure authenticates each referenced definition separately; neither fingerprint recursively embeds the entire handle graph.

- **AND** equivalent definitions created in reversed registration order produce equal canonical witnesses and digests
- **BUT** a by-value A-to-B-to-A cycle returns an invalid-layout result without publishing partial fingerprints

#### Scenario: Reject a digest collision

- **GIVEN** distinct schema or layout witnesses mapped to one injected digest
- **WHEN** a consumer compares compatibility
- **THEN** exact domain, version and witness comparison reports the collision rather than accepting equality

  > Raw memory images, pointers, Engine IDs, FName indices and incidental iteration order are never canonical input.

#### Scenario: Inspect retired metadata without authorizing execution

- **WHEN** an external lease retains an authentic immutable definition after its Engine retires
- **THEN** its semantic identity and fingerprints remain inspectable
- **BUT** fingerprint availability does not grant attachment, executable binding or access to retired runtime IDs

