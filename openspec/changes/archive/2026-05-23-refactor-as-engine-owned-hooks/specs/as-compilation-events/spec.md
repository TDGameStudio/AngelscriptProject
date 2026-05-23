## MODIFIED Requirements

### Requirement: Thin compilation context supports events without replacing the pipeline
The runtime SHALL introduce a per-run compilation context only for shared compile state and summary generation needed by compilation events and future phase extraction, without changing externally observable compile semantics.

#### Scenario: Context is scoped to one compile run
- **WHEN** `CompileModules()` executes
- **THEN** any compilation context used for event generation SHALL be created for that compile run and SHALL NOT become a persistent global engine state

#### Scenario: Engine compile hooks remain compatible
- **WHEN** code subscribes to engine-owned compile hooks such as pre-compile, post-compile, or pre-generate-classes
- **THEN** those hooks SHALL continue to fire according to their existing lifecycle behavior while compilation events provide additional structured read-only information
