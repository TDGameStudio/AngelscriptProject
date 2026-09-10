## ADDED Requirements

### Requirement: Shared publications never determine execution ownership

The SDK SHALL obtain runtime ownership from the executing Engine's materialized TypeInfo, Context or object header, and SHALL retain mutable native, type-user-data and object-lifetime state per Engine.

#### Scenario: Execute one external function with different auxiliary state

- **GIVEN** A and B materialized the same Pair publication, with native auxiliary results 42 and 99 respectively
- **WHEN** each Engine executes Sum
- **THEN** A returns 42 and B returns 99 without changing BindInfo
- **AND** replacing or releasing A's binding does not change B's native state

#### Scenario: Allocate and collect objects using published type metadata

- **GIVEN** A and B materialized the same VM-managed object publication
- **WHEN** their contexts allocate objects and their collectors later release unreachable objects
- **THEN** each object retains its allocating Engine and follows that Engine's cleanup bindings
- **BUT** a numeric publication ID does not transfer an object or its execution authority to another Engine

#### Scenario: Keep mutable type sidecars isolated

- **WHEN** A changes its type user data or template operations state for a materialized publication
- **THEN** B's corresponding state and the BindInfo record remain unchanged
- **BUT** writing Engine-owned state into BindInfo or into a discarded Image is rejected

#### Scenario: Retire one consumer of a shared publication

- **GIVEN** A and B have independent live calls or objects using independently materialized TypeInfo
- **WHEN** A requests shutdown, including from its native callback
- **THEN** A completes its admitted cleanup while B continues execution
- **AND** BindInfo remains until the host drops it

### Requirement: Context admission validates the receiving Engine's definition set

The SDK SHALL admit a callable only when its TypeInfo and required executable/native binding belong to the receiving Engine, without requiring Image or TypeInfo to return a BoundEngine from a shared object.

#### Scenario: Prepare an admitted external callable

- **WHEN** a Context prepares a callable TypeInfo owned by its own Engine
- **THEN** Prepare succeeds
- **BUT** a TypeInfo pointer from another Engine is rejected even when the publication ID matches
