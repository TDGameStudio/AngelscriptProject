## ADDED Requirements

### Requirement: Bytecode operands retain their referenced runtime objects

Executable script functions SHALL retain every type and function referenced by
an embedded bytecode operand and SHALL release the same references exactly once
when the function is destroyed.

#### Scenario: Reference-copy function outlives its source module lookup path

- **WHEN** a compiled function containing reference-copy object-type operands is
  retained while ordinary module references are discarded
- **THEN** the function SHALL remain safely inspectable/executable for its
  supported lifetime and teardown SHALL return ownership counters to baseline

#### Scenario: Function reference teardown is symmetric

- **WHEN** a function containing the affected operands is released
- **THEN** every acquired type/function reference SHALL be released without
  leaks, double releases, or stale module pointers

### Requirement: Bytecode persistence uses validated stable identities

The bytecode writer SHALL serialize stable type/function identities rather than
process addresses, and the reader SHALL validate and translate them to the
destination engine's pointer-sized operands.

#### Scenario: Save and load preserves behavior

- **WHEN** a module using affected reference and native-call opcodes is saved and
  loaded into a compatible destination engine
- **THEN** exact declarations, metadata, runtime results, reference identity,
  and cleanup behavior SHALL match the source module contract

#### Scenario: Invalid stream identity is rejected

- **WHEN** a stream marker, version, type identity, function identity, or operand
  layout is invalid
- **THEN** loading SHALL fail deterministically without publishing a partial
  module or dereferencing a serialized address

### Requirement: GETOBJ reference offsets survive persistence

The bytecode writer and reader SHALL preserve both words of the current-fork
`asBCTYPE_W_rW_ARG` layout and SHALL apply stack-position adjustment only to
operand 1.

#### Scenario: GETOBJ bytecode is saved and restored

- **WHEN** a function containing `GETOBJ(offset, variableOffset)` is saved,
  loaded, and remapped into a destination module
- **THEN** the value operand SHALL remain unchanged, the reference offset SHALL
  be adjusted exactly once, and restored execution SHALL preserve the original
  value and ownership result

#### Scenario: Precompiled reference-copy operands are remapped

- **WHEN** the test module invokes
  `FAngelscriptPrecompiledFunction::Process` on serialized reference-copy
  bytecode for a distinct destination engine
- **THEN** the production reader SHALL replace source type operands with the
  destination type, preserve the serialized source evidence, and execute the
  restored null-reference result
