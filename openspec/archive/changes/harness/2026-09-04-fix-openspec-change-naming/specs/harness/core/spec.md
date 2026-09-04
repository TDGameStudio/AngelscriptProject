## ADDED Requirements

### Requirement: Semantic Change naming

New project OpenSpec Changes SHALL use a canonical `<domain>/<type>-<scope>-<outcome>` identity whose leaf is lowercase portable kebab-case. The type MUST be `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, or `chore`; `feature` and the Git commit type `Feat` remain intentionally distinct. Harness MUST reject a nonconforming create target or move target before invoking the portable OpenSpec CLI, while the generic CLI remains free of project-specific semantic policy.

#### Scenario: Create a conforming Change
- **WHEN** a caller creates a Change through Harness with a registered domain and a semantic type, scope, and outcome
- **THEN** Harness permits the portable CLI to create the canonical active identity

> Inputs: A registered domain and a lowercase Change leaf whose first segment is an allowed semantic type and whose remaining segments provide a scope and outcome.
> Observables: The resulting active Change resolves at the requested canonical ID and normal OpenSpec validation remains available.
> Boundaries: This naming rule is an AngelscriptProject policy and does not change portable CLI syntax for other projects.
> Verification: Harness route fixtures cover all allowed types and representative nested outcomes.

#### Scenario: Reject a nonconforming target
- **WHEN** a caller asks Harness to create or move a Change to a leaf with an unknown type, `feat`, uppercase text, or no distinct scope and outcome
- **THEN** Harness returns a structured naming failure before the portable CLI mutates any record

> Observables: No target directory or manifest is created or moved, and the diagnostic states the required form and allowed types.
> Verification: Negative create and move fixtures assert both the failure envelope and an unchanged record tree.

#### Scenario: Repair an active legacy name
- **GIVEN** an active Change predates semantic enforcement and has a nonconforming source identity
- **WHEN** the caller moves it through Harness to a conforming target
- **THEN** the source remains acceptable only for resolution and the conforming target is permitted

> Boundaries: The exception applies only to the existing move source; it never permits a new nonconforming target.

#### Scenario: Preserve immutable archives
- **WHEN** naming validation audits current project records
- **THEN** it checks live Changes and excludes every archived path and historical manifest from semantic renaming

> Verification: Repository fixtures retain known pre-rule archive names byte-for-byte while an invalid active fixture is reported.
