## ADDED Requirements

### Requirement: Declaration failures retain specific semantic explanations

Declaration analysis SHALL report every current invalid declaration cause as a concrete structured diagnostic, retain the relevant authored name/type/attribute locations, and preserve independent declarations through controlled recovery.

#### Scenario: Resolve an unknown declaration type

- **GIVEN** a declaration names an unavailable type and a later independent function has a valid signature
- **WHEN** declaration resolution completes against the full collected source set
- **THEN** the unknown type diagnostic identifies its authored type use and requested name, while the independent function remains inspectable

    > Observables: The failure is present in the structured collection, not only a stable text projection.
- **BUT** the failed declaration does not satisfy another unresolved type reference or become a publication candidate

#### Scenario: Explain declaration conflicts and invalid annotations

- **WHEN** duplicate declarations, invalid inheritance/signatures or illegal annotation targets are encountered
- **THEN** the diagnostic identifies the specific cause and relevant declaration or annotation, with related-source notes where another declaration explains it

    > Examples: A duplicate points to the conflicting declaration and the prior declaration; an invalid parameter annotation identifies the parameter annotation rather than only setting an invalid bit.
- **AND** valid later declarations remain available after a grammar-appropriate recovery boundary

    > Boundaries: Recovery does not skip semantic checks on independent declarations or emit a generic follow-up for every use of one invalid declaration.
