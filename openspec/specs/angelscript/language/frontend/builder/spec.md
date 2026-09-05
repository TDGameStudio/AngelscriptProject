## Purpose

Define independently executable AngelScript frontend stages whose results remain inspectable without a script engine or an active runtime backend.

## Requirements

### Requirement: Independent typed compilation stages
The Builder SHALL compile through explicit typed stage results without requiring an AngelScript engine, and SHALL distinguish declaration readiness, body readiness, definition freeze and runtime binding.

#### Scenario: Stop after declarations and resume bodies
- **WHEN** a caller collects and resolves declarations before analyzing bodies
- **THEN** signatures are inspectable while body storage remains writable by the owning compilation session
  > Observables: Resuming body analysis preserves declaration identity and uses the retained active Token stream.
- **AND** running the same stages separately or together produces equivalent semantic results and deterministic text/JSON observations
- **BUT** an invalid stage transition or failed required stage cannot publish a successful later result

#### Scenario: Compile without a host consumer
- **WHEN** a caller supplies source, immutable language options, explicit type context and diagnostics without an Engine or UE reflection consumer
- **THEN** syntax, semantic definitions and layout validation complete without creating runtime objects
  > Boundaries: Unavailable execution backends remain explicit unsupported operations, not hidden legacy fallbacks.

### Requirement: Maintained language semantics survive frontend replacement
The replacement frontend SHALL preserve the maintained language's declaration, expression and statement semantics except explicitly removed syntax.

#### Scenario: Analyze supported source through the replacement
- **WHEN** supported source exercises type lookup, inheritance, overloads, expressions or control flow
- **THEN** typed nodes and resolved semantic relationships express the language result
- **AND** invalid input emits structured source diagnostics with controlled recovery rather than silently discarding tokens
  > Verification: A migration matrix maps maintained syntax and old native SDK fixtures to positive, negative and boundary tests.
