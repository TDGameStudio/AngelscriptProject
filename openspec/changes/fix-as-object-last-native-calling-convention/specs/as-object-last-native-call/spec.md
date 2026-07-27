## ADDED Requirements

### Requirement: Object-last native calls preserve ABI and stack state

Supported object-last and native system calls SHALL receive the exact registered
object and arguments, return the correct value, and leave the context stack and
owned temporaries balanced.

#### Scenario: Supported object-last call executes

- **WHEN** a supported native object-last method is registered with a valid fork
  caller and invoked with sentinel object/argument values
- **THEN** the native target SHALL observe the exact values and order, the script
  SHALL observe the exact return value, and context cleanup SHALL return to
  baseline

#### Scenario: Failure path cleans arguments

- **WHEN** a native or script exception terminates the call
- **THEN** argument temporaries, return storage, context state, and object
  ownership SHALL be cleaned exactly once and the supported recovery path SHALL
  remain usable

### Requirement: Missing native caller is rejected

The fork SHALL reject a non-generic native registration/invocation that requires
but does not provide a valid caller payload.

#### Scenario: Caller payload omitted

- **WHEN** a supported-looking non-generic object/native call is registered
  without the required caller
- **THEN** the operation SHALL fail with the fork's missing-caller diagnostic and
  SHALL not execute through an implicit alternative convention

### Requirement: Compatible save/load preserves native-call identity

Native-call bytecode SHALL serialize stable function identity and restore a
validated destination pointer rather than persisting an address.

#### Scenario: Object-last call survives round trip

- **WHEN** a module containing an object-last native call is saved and loaded
  into a compatibly registered destination engine
- **THEN** exact call behavior and cleanup SHALL match the source module

#### Scenario: Generated object-last call preserves explicit argument order

- **WHEN** StaticJIT generates, compiles, and executes an object-last constructor
  with two distinct explicit sentinel arguments
- **THEN** the native target SHALL receive both explicit arguments before the
  destination object, and the generated entry SHALL execute exactly once

### Requirement: No-count implicit handles do not dispatch release

The runtime SHALL keep a by-value generic argument registered as
`asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE` application-owned and
SHALL NOT dispatch a missing release behavior.

#### Scenario: Generic callback receives a no-count implicit handle

- **WHEN** a generic callback receives the no-count implicit handle by value
- **THEN** the callback SHALL execute with the exact object, normal ownership
  cleanup SHALL NOT claim or release the handle, the argument slot SHALL be
  discarded through VM stack retirement, and application ownership SHALL remain
  unchanged
