## ADDED Requirements

### Requirement: Wiki verification exposes named risk-based execution levels

The integrated Wiki SHALL expose named `guard`, `fast`, `affected`, `integration`, and `release` verification levels. `guard` SHALL validate the supported toolchain before standard commands. `fast` SHALL contain deterministic low-cost type, local-lint, and source-contract checks with a 30-second target, and SHALL NOT publish an artifact or reserve the fixed browser-test port. `affected` SHALL select explicitly named functional domains. `integration` SHALL run the complete product runtime and browser regression suite plus the isolated artifact-server contract on explicit request. `release` SHALL validate offline publication, artifact structure, and the complete vendor audit before delivery.

#### Scenario: Maintainer develops an ordinary feature
- **WHEN** a maintainer changes one declared Wiki product surface during normal development
- **THEN** the documented local workflow SHALL require `fast` and that surface's `affected` suite
- **AND** it SHALL NOT require the complete integration or release suite for every edit

#### Scenario: Maintainer requests complete local verification
- **WHEN** a maintainer explicitly runs the aggregate verification command
- **THEN** the command SHALL run every applicable verification level
- **AND** documentation SHALL identify it as the all-level command rather than the default edit-loop command

### Requirement: Product browser regressions declare stable surface ownership

Each Playwright product regression SHALL belong to exactly one stable functional domain: `shell`, `sidebar`, `document`, `code`, `tools`, or `i18n`. A launch-critical product journey SHALL additionally carry an `@smoke` title marker. The selection mechanism SHALL use a repository-owned suite registry and SHALL NOT infer ownership from changed Git paths.

#### Scenario: Maintainer changes the More sidebar
- **WHEN** a maintainer changes the declared sidebar/More surface
- **THEN** the affected-test command SHALL select the `sidebar` browser regressions
- **AND** unrelated visual, code, and content regressions SHALL remain available to the full integration level

#### Scenario: Repository paths are reorganized
- **WHEN** a product source or test file moves without changing its owned surface
- **THEN** affected-suite selection SHALL continue to use the declared surface ownership
- **AND** it SHALL NOT silently change solely because a file path changed

### Requirement: Regression tests are admitted at the lowest viable layer

New Wiki regression coverage SHALL reproduce a defect or contract at the lowest viable verification level. A test SHALL be added to an existing product-surface suite when it protects that suite's contract. A separate spec SHALL be created only when its fixture lifecycle or product boundary is independently owned; a historical task, experiment, or screenshot alone SHALL NOT create a permanent suite boundary.

#### Scenario: Maintainer fixes a source-contract defect
- **WHEN** the defect can be reproduced through a deterministic Node or source-level assertion
- **THEN** the regression SHALL be added at that level
- **AND** a duplicate browser scenario SHALL NOT be required

#### Scenario: Maintainer changes a reader-visible sidebar interaction
- **WHEN** the defect requires the integrated browser runtime to reproduce
- **THEN** the regression SHALL extend the existing sidebar/More product suite
- **AND** it SHALL participate in the sidebar/More affected command and complete integration gate

### Requirement: CI makes fast validation automatic and complete integration explicit

Pull-request CI SHALL run and require only the `fast` level. The CI workflow SHALL expose manually dispatchable `integration` and `release` jobs with distinct reports. Release validation SHALL be required before delivery. Normal local feature documentation SHALL not represent the complete integration/release sequence as mandatory for every edit.

#### Scenario: Pull request changes an ordinary Wiki feature
- **WHEN** a pull request targets `main`
- **THEN** CI SHALL run and require the fast gate
- **AND** the maintainer SHALL run the explicit affected command for the changed functional domain

#### Scenario: Maintainer requests complete regression
- **WHEN** a maintainer explicitly dispatches the integration workflow or runs the aggregate integration command
- **THEN** the workflow SHALL run the complete runtime and browser regression suite
- **AND** this run SHALL not be an automatic pull-request requirement

#### Scenario: Delivery artifact is prepared
- **WHEN** a Wiki delivery or release validation is requested
- **THEN** the release level SHALL validate offline publication, artifact structure, and the configured vendor audit
- **AND** a successful browser-only run SHALL not be treated as release validation

### Requirement: Test-owned previews isolate generated source roots

Every default browser-test Wiki preview SHALL build and serve a unique isolated offline artifact from a generated product-source root unique to that preview instance. It SHALL NOT use, delete, replace, or watch an interactive developer preview or its generated source root. The test workflow SHALL retain deterministic source preparation while allowing an interactive preview to remain running. `PLAYWRIGHT_BASE_URL` SHALL be the explicit opt-in for testing an externally supplied server; only when it is set may a browser test bypass creation of its default isolated artifact preview.

#### Scenario: Interactive preview is already running
- **WHEN** a maintainer starts an affected or integration browser test without `PLAYWRIGHT_BASE_URL` while an interactive Wiki preview owns its generated source root
- **THEN** the default test preview SHALL build and serve its own unique isolated offline artifact from a separate generated source root
- **AND** it SHALL NOT use the interactive developer preview or fail because it attempts to remove that preview's root
- **AND** setting `PLAYWRIGHT_BASE_URL` SHALL be the explicit opt-in to test an externally supplied server instead
