## ADDED Requirements

### Requirement: Body phase preserves declaration inputs and failure state
The body stage SHALL analyze retained preprocessed input and SHALL propagate every parsing or semantic failure to its owning result.

#### Scenario: Analyze a body with selected conditional branches
- **WHEN** declarations were collected under a frozen flag configuration
- **THEN** later body analysis sees only that configuration's selected statements and retains valid identifier ownership
- **AND** body errors prevent executable or finalized success even when declarations resolved
  > Observables: Empty/missing body output cannot be accepted merely because a parser return value was ignored.

