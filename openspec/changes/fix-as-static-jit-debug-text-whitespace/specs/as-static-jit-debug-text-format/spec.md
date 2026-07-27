## ADDED Requirements

### Requirement: StaticJIT instruction debug text has no trailing whitespace

The StaticJIT instruction formatter SHALL return debug text without trailing
horizontal whitespace for both operand-bearing and no-operand bytecodes.

#### Scenario: No-operand instruction is rendered

- **WHEN** the formatter renders an instruction whose debug form has no operand
  text
- **THEN** the returned string SHALL end with the opcode text rather than a
  synthetic separator

#### Scenario: Operand-bearing instruction is rendered

- **WHEN** the formatter renders an instruction with one or more operands
- **THEN** the returned string SHALL preserve the opcode/operand content and
  SHALL contain no trailing horizontal whitespace

### Requirement: Generated AOT comments preserve normalized debug text

Generated StaticJIT AOT source SHALL embed normalized instruction debug text
without introducing trailing whitespace on debug-comment lines.

#### Scenario: AOT fixture is regenerated and verified

- **WHEN** the documented AOT generation and verification workflow processes
  the representative fixture
- **THEN** generated output SHALL match the checked fixture and a literal
  trailing-whitespace scan SHALL return zero lines
