# Test authoring contract

## Purpose

Preserve readable C++ test scenarios, explicit inline-source behavior and one
truthful authoring guide throughout the testing framework reconstruction.

## ADDED Requirements

### Requirement: Class-local test intent remains visible

Replacement CQTest authoring SHALL keep a scenario's action and assertions in its
test method and keep single-class support within the class.

#### Scenario: One CQTest class needs helper state
- **WHEN** constants, observations or a narrow helper serve only that class
- **THEN** they are declared inside the class, normally private
- **BUT** an anonymous namespace is not created solely to hold that class's support

#### Scenario: Hooks follow private helpers
- **WHEN** a test class has private declarations before its CQTest hooks or methods
- **THEN** the hooks and methods restore public visibility

#### Scenario: Shared preparation is extracted
- **WHEN** several classes share stable preparation code
- **THEN** a focused support abstraction may own that preparation
- **BUT** scenario-specific compile/reload/observe/assert intent is not hidden in a single boolean wrapper

### Requirement: Inline source macros have explicit transformation semantics

The system SHALL provide an owning normalized source macro and an explicit
exact-text alternative without changing the legacy string-returning macro API.

#### Scenario: Readable raw-string source is normalized
- **WHEN** `AS_TEST_SOURCE` receives an indented source literal
- **THEN** it produces UTF-8 source with LF newlines, at most one visual envelope removed and only a shared literal whitespace prefix dedented
- **AND** extra intentional blank lines and relative source indentation remain

#### Scenario: Text layout is the test input
- **WHEN** a test uses the exact-text entry
- **THEN** its supplied literal value is retained without trim, dedent or newline normalization

    > Boundaries: Exact physical bytes are supplied through the length-delimited byte entry.

#### Scenario: A source macro is evaluated
- **WHEN** the macro creates its source value
- **THEN** it owns the resulting bytes and captures an authoring origin
- **BUT** it does not create an engine, compile source, register a test or publish a global source entry

### Requirement: Source-location precision is stated honestly

The system SHALL distinguish exact logical AS coordinates, literal-relative
mapping and the C++ macro authoring anchor.

#### Scenario: A normalized multiline literal produces a diagnostic
- **WHEN** the diagnostic points into the normalized payload
- **THEN** the report retains the exact logical UTF-8 range and the available literal mapping
- **AND** it identifies the C++ authoring anchor separately
- **BUT** the macro's line number alone is not presented as an exact arbitrary C++ body location

### Requirement: Current guidance describes available capabilities

The testing Skill SHALL distinguish currently supported APIs from planned
interfaces and SHALL preserve a single current guidance authority.

#### Scenario: A reader follows the current test-writing route
- **WHEN** the Skill supplies an executable example
- **THEN** its symbols, gates, test names and verification route correspond to implemented replacement capabilities
- **BUT** a planned macro or runtime adapter is not presented as callable current code

#### Scenario: A reader encounters historical instructions
- **WHEN** an old note references legacy engine macros, old gates, Documents authority or Tools runners
- **THEN** the Skill identifies it as historical and routes current work to the maintained replacement guide and Harness

#### Scenario: A new interface becomes documented as current
- **WHEN** the owning implementation and representative example have been verified
- **THEN** the corresponding focused Skill reference may promote that interface to current guidance
- **AND** its example remains traceable to verified source and behavior
