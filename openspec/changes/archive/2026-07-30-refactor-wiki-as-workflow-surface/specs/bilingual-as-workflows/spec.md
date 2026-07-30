## ADDED Requirements

### Requirement: AS status is documented as a dated snapshot

The Wiki SHALL provide a bilingual AS status page that distinguishes current plugin capabilities, module boundaries, test baselines, and known limitations from future work.

#### Scenario: Status page identifies current capabilities

- **WHEN** a reader opens the AS status page
- **THEN** the page SHALL describe Runtime, Editor, Test, optional GameplayTags/GAS, UHTTool, DebugServer V2, CodeCoverage, StaticJIT, HotReload, and BlueprintImpact boundaries
- **AND** the page SHALL label numeric test and feature counts with a snapshot date

### Requirement: AS user workflow is documented

The Wiki SHALL provide a bilingual user-facing workflow covering setup, authoring, compilation, hot reload, debugging, testing, and release boundaries.

#### Scenario: User can follow the AS workflow

- **WHEN** a reader follows the AS user workflow from the home page
- **THEN** the reader SHALL find the order of setup, script authoring, reload, DebugServer/VS Code debugging, tests, and packaging
- **AND** the page SHALL identify which steps execute in the Unreal host rather than in the browser Wiki

### Requirement: Plugin maintainer workflow is documented

The Wiki SHALL provide a bilingual maintainer workflow covering binding strategy, build/test entry points, diagnostics, and documentation synchronization.

#### Scenario: Maintainer can choose a binding path

- **WHEN** a maintainer opens the binding workflow
- **THEN** the page SHALL distinguish manual bindings, UHT-generated tables, safe direct binds, and reflective fallback
- **AND** the page SHALL point to the host repository's authoritative build and test guides

### Requirement: AS presentation roadmap is documented

The Wiki SHALL document the planned visual improvements for AS code cards and theme behavior without claiming Runtime performance changes.

#### Scenario: Theme roadmap states measurable goals

- **WHEN** a reader opens the theme roadmap
- **THEN** it SHALL cover token contrast, code-card readability, responsive layout, focus states, reduced motion, copy feedback, and user/maintainer navigation hierarchy
- **AND** it SHALL identify AST views, C++ comparison, and local diagnostics bridges as future capabilities rather than current behavior
