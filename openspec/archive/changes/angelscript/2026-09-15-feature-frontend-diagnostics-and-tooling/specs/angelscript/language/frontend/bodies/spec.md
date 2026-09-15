## ADDED Requirements

### Requirement: Body diagnostics explain semantic rejection without cascades

Body analysis SHALL report current expression, call, access, conversion, lambda and control-flow failures using concrete cause identifiers and applicable semantic details, while suppressing only errors directly dependent on an already-invalid construct.

#### Scenario: Explain an unsuccessful overload call

- **GIVEN** visible script or frozen-host callable candidates do not yield one best viable call
- **WHEN** Sema analyzes the authored call
- **THEN** the primary diagnostic identifies the call and attached candidate explanations identify the relevant signature and rejection or ambiguity reason

    > Observables:
    >
    > - Arguments retain their authored ranges and formal parameter mapping.
    > - Expected/actual types and const, access, direction or context restrictions are structured when applicable.
    > - Candidate ordering and explanation selection are independent of registration and worker order.
- **BUT** a rejected candidate does not itself commit conversion nodes or emit a premature standalone failure that prevents assessment of later candidates

#### Scenario: Continue past an invalid expression without repeated consequences

- **WHEN** an unresolved name or failed conversion produces an error-bearing expression followed by independent valid and invalid statements
- **THEN** direct secondary errors caused solely by that expression are suppressed, the later valid statement retains its typed meaning, and the independent error still appears

    > Example: A misspelled local in a return expression is not also reported as several unrelated conversion failures.
- **BUT** diagnostic suppression does not clear the body's invalid state, invent cleanup for unconstructed values or permit publication
