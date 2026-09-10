## ADDED Requirements

### Requirement: External providers can extend a primary type through recording callbacks

The system SHALL accept module-owned registration functions or captureless lambdas that append binding descriptions to a primary type without redefining it or accessing a script engine.

#### Scenario: An extension is registered before its primary provider

- **GIVEN** a project extension describes ExtraMethod for ExampleType before ExampleType's primary provider is registered
- **WHEN** both providers participate in one capture
- **THEN** the sealed database contains one ExampleType definition and the extension member with its own source provenance
- **AND** an engine created from the database can invoke ExtraMethod
- **BUT** an extension attempting to redefine ExampleType's native layout or lifecycle fails with both sources identified

#### Scenario: Conflicting members do not depend on callback order

- **GIVEN** two extension providers supply incompatible definitions for the same owner and complete member signature
- **WHEN** the providers are captured in either order or in parallel
- **THEN** capture reports the same conflict with both provider identities
- **BUT** distinct valid overloads remain distinct members

### Requirement: Captures isolate provider generations

The system SHALL fix an immutable provider collection for each capture while allowing subsequent external registrations to participate in later captures.

#### Scenario: Register another lambda after a database is sealed

- **GIVEN** database D1 was captured before an external extension lambda was registered
- **WHEN** the host registers that lambda and captures D2
- **THEN** D2 contains the extension and D1 remains unchanged
- **AND** engines created from D1 retain their original surface while an engine created from D2 exposes the new member

#### Scenario: Duplicate provider identity is rejected

- **WHEN** a module registers a second callback using the same module/provider identity
- **THEN** registration fails without replacing the first callback
- **AND** a capture already holding a provider collection remains unchanged

### Requirement: Native target enrichment preserves member identity and dispatch semantics

The system SHALL permit external/manual/generated native targets to enrich existing binding members using explicit transport, origin, signature and lifetime information. Contribution origin SHALL be independent of call transport.

#### Scenario: Attach a compatible native target to a reflected declaration

- **GIVEN** an existing declaration permits direct native dispatch and has a reflective fallback
- **WHEN** an external provider supplies a compatible typed native target for its exact member identity
- **THEN** installation can select that target and VM calls return the native implementation's independently expected result
- **AND** inspection identifies the chosen transport and provider origin

    A NativeDirect pointer and a generated NativeThunk are different transports. Both may originate from an external generator. A descriptive JIT recipe alone is neither transport.

#### Scenario: Incompatible generated target does not silently fall back

- **WHEN** a supplied native target has an incompatible signature, receiver mode, parameter direction, layout version or calling convention
- **THEN** preparation rejects the candidate with the member and target source identified before engine publication
- **BUT** an optional candidate with no eligible implementation can retain an explicitly declared fallback with a visible exclusion reason

#### Scenario: Blueprint-sensitive dispatch retains its behavior

- **GIVEN** a member's callable contract requires reflected or Blueprint override dispatch
- **WHEN** an additional native address is available for its C++ implementation
- **THEN** ordinary invocation still respects that callable dispatch contract
- **BUT** merely possessing the address does not authorize bypassing the override

### Requirement: External registration exposes a supported public boundary

The system SHALL expose provider, builder and native-target contracts through public binding headers and SHALL keep installation internals private.

#### Scenario: Register from a separate plugin module

- **WHEN** a separate module includes the supported binding header and registers an extension lambda or typed native batch
- **THEN** it compiles and participates in capture without including private binding implementation headers
- **AND** its default callback policy executes live UE-dependent work on GameThread
- **BUT** a callback opts into worker execution only under the documented immutable-input contract
