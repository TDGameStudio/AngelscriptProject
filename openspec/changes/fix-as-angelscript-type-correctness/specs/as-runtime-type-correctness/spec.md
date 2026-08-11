## ADDED Requirements

### Requirement: Type Usage Payload Is Deterministic

Every `FAngelscriptTypeUsage` construction and reset path MUST establish a deterministic payload state before the usage can be compared, copied, queried, or passed to an adapter. Constructing a usage from an adapter MUST preserve the current struct layout and MUST initialize the shared payload storage to null.

#### Scenario: Adapter constructor initializes payload

- **WHEN** a usage is constructed from a valid `FAngelscriptType` adapter
- **THEN** its adapter is valid, its payload storage is null, its subtype list is empty, and its const/reference flags are false

#### Scenario: Fresh equivalent usages compare deterministically

- **WHEN** two usages are independently constructed from the same adapter without assigning an adapter-specific payload
- **THEN** equality and unqualified equality return deterministic results without reading indeterminate storage

#### Scenario: Reset restores the empty invariant

- **WHEN** a populated usage with qualifiers, subtypes, and payload is reset
- **THEN** its adapter is invalid, payload is null, subtype list is empty, and qualifiers are false

### Requirement: Property Finder Resolution Is Transactional

Property type resolution MUST isolate every registered finder candidate and MUST commit a candidate only when the finder reports success with a valid type. Mutations made by a finder that reports failure MUST NOT affect later finders or fallback property matching.

#### Scenario: Failed finder mutation is discarded

- **WHEN** a finder writes a type, subtype, qualifier, or payload and then returns false
- **THEN** the next finder receives a fresh usage and the rejected mutations are absent from the final result

#### Scenario: Successful valid finder wins

- **WHEN** an earlier finder fails and a later finder returns true with a valid type
- **THEN** the later candidate is committed and receives the reflected property's const/reference qualifiers

#### Scenario: Successful invalid finder fails closed

- **WHEN** a finder returns true without assigning a valid type
- **THEN** the runtime emits a contract diagnostic and continues to a later finder or the ordinary property fallback

### Requirement: Explicit Type Database Routing Is End To End

An API that accepts `FAngelscriptTypeDatabase` explicitly MUST resolve names, properties, type IDs, data types, parameters, return types, and recursive template subtypes exclusively through that database and its paired script engine. It MUST NOT consult the ambient `FAngelscriptEngine` or its database.

#### Scenario: Explicit signature with no ambient engine

- **WHEN** a reflected function signature is constructed with an explicit database while current-engine resolution is suppressed
- **THEN** every argument, return type, and mixin lookup is resolved through the supplied database

#### Scenario: Explicit signature ignores a different ambient engine

- **WHEN** database A is supplied while engine B is the ambient current engine
- **THEN** the signature contains only adapters registered in database A

#### Scenario: Explicit signature on a worker thread

- **WHEN** a read-only reflected signature is constructed on a worker thread with an explicit database and no inherited engine scope
- **THEN** construction succeeds deterministically and performs no ambient-engine lookup

#### Scenario: Compatibility overload uses checked current engine

- **WHEN** a legacy overload without an explicit database is called under a valid engine scope
- **THEN** it resolves the checked current engine once and delegates to the corresponding explicit implementation

### Requirement: Enum Usage Matches The Current Byte ABI

The runtime MUST produce a valid `FEnumType` usage only when the native enum property and all published values can be represented faithfully by the current one-byte AngelScript enum ABI. Unsupported native storage or values MUST fail closed with a deterministic diagnostic and MUST NOT leak a partial type-finder result.

#### Scenario: Byte-backed native enum remains supported

- **WHEN** a reflected enum property uses byte storage and every exposed value is in the range 0 through 255
- **THEN** type resolution returns a valid one-byte enum usage and existing copy, compare, call, hash, debugger, and property behavior remains available

#### Scenario: Wide enum property is rejected

- **WHEN** an enum property uses an int16, uint16, int32, uint32, int64, or uint64 underlying property
- **THEN** type resolution returns no enum usage and reports the enum path and underlying property class without truncating or under-copying a value

#### Scenario: Out-of-range native enum is not published as byte-backed

- **WHEN** a native UEnum exposes a value below 0 or above 255
- **THEN** the byte-backed script enum registration is skipped with a deterministic diagnostic

#### Scenario: Rejected enum cannot contaminate fallback

- **WHEN** the enum finder recognizes an enum but rejects its storage or value range
- **THEN** its adapter and payload mutations are discarded before later finders or fallback matching run

### Requirement: Existing Runtime Type Compatibility Is Preserved

The repairs MUST preserve supported byte-backed enum behavior, existing ambient type APIs under a valid engine scope, ordinary property qualifier propagation, and the `FAngelscriptTypeUsage` binary layout. They MUST NOT change AngelScript bytecode or the generated native-module binding layout.

#### Scenario: Existing focused owners remain green

- **WHEN** the TypeUsage, TypeDatabase, BindingArchitecture Fluent, UEnum coverage, and container binding test owners run after the repair
- **THEN** their pre-existing supported scenarios pass without declaration, bytecode, or binding-layout changes
