## ADDED Requirements

### Requirement: Basic loop runner compatibility
RalphLoop SHALL continue to run a selected agent command for a bounded number of iterations while writing prompt, stdout, stderr, last-message, run metadata, and final state artifacts.

#### Scenario: Basic loop completes without verification
- **WHEN** RalphLoop runs in the default workflow with one iteration and no verification command
- **THEN** it writes the standard iteration artifacts and exits after reaching the configured maximum iteration count

#### Scenario: Verification stops the loop
- **WHEN** RalphLoop runs with a verification command that exits successfully after an iteration
- **THEN** it stops early and records a verification-passed final state

### Requirement: Provider profiles include explicit trusted execution
RalphLoop SHALL resolve provider command templates from profiles and SHALL only use dangerous unattended permission flags when explicit trusted execution is requested.

#### Scenario: Safe provider command is default
- **WHEN** RalphLoop runs a built-in provider without trusted execution
- **THEN** the provider command excludes dangerous permission-bypass flags

#### Scenario: Trusted provider command is requested
- **WHEN** RalphLoop runs a built-in provider with trusted execution enabled
- **THEN** the provider command uses the provider's trusted command template

### Requirement: Claude provider profile
RalphLoop SHALL provide a Claude provider profile that can run Claude Code in non-interactive prompt mode.

#### Scenario: Claude profile is selected
- **WHEN** RalphLoop is invoked with the Claude agent profile
- **THEN** it resolves the Claude command template and exports provider-neutral loop environment variables
