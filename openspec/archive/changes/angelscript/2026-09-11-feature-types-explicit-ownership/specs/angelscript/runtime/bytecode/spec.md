## MODIFIED Requirements

### Requirement: Stable symbol linking is transactional and generation-owned

The SDK SHALL resolve complete canonical requirements to the current Engine's materialized TypeInfo and live bindings, and publish executable resources atomically only after identity, visibility, ownership, schema, layout and callable ABI checks succeed.

#### Scenario: Resolve a type use and callable in the current Engine

- **GIVEN** a live Engine with materialized publications, its private TypeInfo and explicit native/global bindings
- **WHEN** it links nominal, qualified and generic type symbols together with callable and property requirements
- **THEN** the snapshot exposes that Engine's TypeInfo pointers, published IDs, lowered type uses, callable entries and field addresses

    Primitive type uses resolve to primitive storage. Specializations resolve by their complete canonical identity. FunctionKey equality never substitutes for complete return/parameter agreement.

- **BUT** global Registry lookup cannot supply a missing admission, and linking cannot attach unadmitted publications, adopt another Engine's TypeInfo, create missing definitions or treat metadata FunctionIds as legacy array indices

#### Scenario: Bind one cache independently in two Engines

- **WHEN** two Engines with compatible admitted publications link the same cached image
- **THEN** each executes through its own snapshot and live TypeInfo
- **AND** releasing A does not invalidate B's execution
- **BUT** cache loading does not authorize foreign TypeInfo adoption or replacement of an installed body

### Requirement: Canonical source compilation produces the same verified executable image

The SDK SHALL compile the bounded supported AS source surface from its verified canonical frontend into the same symbolic executable format used by direct bytecode authoring, without an Engine prerequisite or legacy compiler fallback.

#### Scenario: Source-produced cache retains definition-free loading

- **WHEN** a source-produced image is encoded, its producer inputs are released, and another Engine supplies compatible TypeInfo independently
- **THEN** decoding, linking and actual execution preserve expected results through that Engine's own bindings
- **BUT** source provenance and cached signatures cannot create missing TypeInfo, restore live values, attach an unadmitted publication or adopt another Engine's TypeInfo

## ADDED Requirements

### Requirement: Source definition placement preserves published dependencies and private ownership

The SDK SHALL keep source compilation engine-independent and SHALL allow the receiving Engine to uniquely own successful private TypeInfo batches that reference only its admitted publications.

#### Scenario: Adopt compiled source using a prebuilt native type

- **GIVEN** a published Pair record materialized in the receiving Engine
- **WHEN** source compilation produces a function that uses Pair
- **THEN** the compiled TypeInfo/functions belong to that Engine
- **BUT** another Engine must materialize Pair itself before linking the same cache
