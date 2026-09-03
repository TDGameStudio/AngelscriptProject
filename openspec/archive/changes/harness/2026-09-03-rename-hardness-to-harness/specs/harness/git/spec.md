## ADDED Requirements

### Requirement: Harness Git API identity

The Git operations module SHALL expose only Harness-named context, result, and helper symbols where the shared framework identity appears, while the stable `git.status`, `git.commit`, `git.integrate`, and `git.push` routes retain their existing semantics and authority boundaries. Generated default commit messages and maintained examples SHALL use `[Harness]`; no `[Hardness]` default or old PowerShell alias SHALL remain.

#### Scenario: Invoke Git through Harness
- **WHEN** a caller uses a stable `git.*` route in a Harness context
- **THEN** results and diagnostics use Harness-named types/helpers without changing exact-scope, preservation, integration, or push behavior

#### Scenario: Reject old Git helper names
- **WHEN** a caller attempts to invoke an exported `*-Hardness*` Git helper after cutover
- **THEN** the helper is absent instead of forwarding to its Harness replacement
