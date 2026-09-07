## ADDED Requirements

### Requirement: Builder preserves root diagnostics and explicit stage outcomes

The Builder SHALL expose one authoritative diagnostic result across its stages, preserve already-reported causes without text rewrapping, and distinguish analyzed coverage, language validity, policy failure and publication eligibility.

#### Scenario: Propagate a semantic stage failure

- **GIVEN** declaration or body analysis has already reported a concrete diagnostic group
- **WHEN** Builder records the failed stage and a consumer reads the complete result and its stage views
- **THEN** the same root group remains available once with its ranges, semantic arguments and attached notes intact
  > Observables: A stage view identifies groups in the authoritative collection; concatenating cumulative copies is not required.
- **BUT** the failed stage does not add a first-token generic diagnostic containing serialized earlier errors

#### Scenario: Fail before lexing produces tokens

- **WHEN** an input, transition or environment precondition prevents the requested Builder stage
- **THEN** the stage fails with an explicit status and a visible nonlocated root diagnostic if no earlier group explains the failure
  > Boundaries: Low-level metadata/AST status codes retain their own meaning; the boundary adds context rather than inventing a source-language error.
- **AND** no later stage is reported successful solely because the diagnostic display was empty

#### Scenario: Inspect partial analysis without publishing it

- **WHEN** recovery or cancellation leaves only a subset of requested analysis complete
- **THEN** the result identifies completed stages and available fragments independently of diagnostic display policy
  > Observables: Callers distinguish language errors, internal failure, policy-only build failure, truncation and cancelled work.
- **BUT** diagnostic continuation or a read-only tooling result does not satisfy definition freeze, AST verification or Engine registration
