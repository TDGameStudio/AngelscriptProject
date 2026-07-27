## ADDED Requirements

### Requirement: Double-to-64-bit conversion decodes both operands

The interpreter SHALL decode `asBC_dTOi64` and `asBC_dTOu64` according to the
current-fork two-word destination/source operand layout and SHALL resume
dispatch after both words.

#### Scenario: Double converts to signed 64-bit

- **WHEN** compiled bytecode converts a double stack value to signed 64-bit
- **THEN** the interpreter SHALL read the source from operand 1, write the
  destination identified by operand 0, advance two words, and produce the exact
  converted value

#### Scenario: Double converts to unsigned 64-bit

- **WHEN** compiled bytecode converts a double stack value to unsigned 64-bit
- **THEN** the interpreter SHALL read the source from operand 1, write the
  destination identified by operand 0, advance two words, and produce the exact
  converted value

### Requirement: Interpreter and StaticJIT honor the same conversion layout

Interpreter and StaticJIT execution SHALL agree on operand meaning and result
for representative signed and unsigned double-to-64-bit conversions.

#### Scenario: Both execution modes run representative conversions

- **WHEN** the conversion regressions execute through interpreter and StaticJIT
  paths
- **THEN** the interpreter functions SHALL contain `asBC_dTOi64` and
  `asBC_dTOu64` and SHALL have no attached JIT entry
- **AND** the loaded AOT functions SHALL expose `jitFunction`,
  `jitFunction_Raw`, and `jitFunction_ParmsEntry`
- **AND** each generated entry counter SHALL increment exactly once
- **AND** both paths SHALL complete without operand-word misdispatch, produce
  exact results `-4294967296` and `4294967296`, agree exactly, and discard all
  contexts and modules
