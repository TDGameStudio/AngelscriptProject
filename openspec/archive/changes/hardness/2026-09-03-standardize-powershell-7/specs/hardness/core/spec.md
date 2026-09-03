## MODIFIED Requirements

### Requirement: Retained Hardness performance evidence

Hardness SHALL expose one PowerShell 7 performance-test profile that measures fresh-process and persistent-session harness paths independently. Every sample MUST also validate the invoked behavior. Each run MUST write a unique structured summary and raw sample table without overwriting or automatically deleting prior runs, while the change record retains a privacy-trimmed aggregate baseline and hashes of its raw source artifacts. Default TaskStatus sampling MUST use a hermetic temporary Task Graph that does not depend on an active project change; an explicit `-TaskChange` MAY select an active project record intentionally.

#### Scenario: Record a PowerShell 7 performance run
- **WHEN** the Performance profile runs in the supported PowerShell 7 host
- **THEN** it reports its warmup count, measured samples, min/median/p95/max, behavior result, and broad catastrophe-budget result in one unique Saved run directory

#### Scenario: Preserve comparable evidence without a flaky machine gate
- **WHEN** one accepted run is registered as the current baseline
- **THEN** raw machine-specific samples remain ignored local data, a trimmed aggregate is indexed under change attachments before archive, and a single prior-run regression ratio remains advisory until representative history establishes a portable threshold

#### Scenario: Run without an active project change
- **WHEN** the default Performance profile runs after every project change has been archived
- **THEN** TaskStatus measures the real Hardness/OpenSpec route against an isolated temporary Task Graph and removes that fixture after the run

### Requirement: Reusable PowerShell entry

Hardness SHALL require PowerShell 7.0 or later with the Core edition and SHALL support repeated Workspace and OpenSpec invocations in one supported session without polluting the caller environment. Windows PowerShell 5.1 is not a supported harness host. Every invocation SHALL return an independent run ID and the common result envelope.

#### Scenario: Reuse one PowerShell 7 session
- **WHEN** Hardness invokes Workspace or OpenSpec commands repeatedly in one supported PowerShell 7 session
- **THEN** modules remain reusable, the caller location is restored, and each invocation returns an independent run ID and result

#### Scenario: List the gate matrix
- **WHEN** a caller lists Quick, Performance, or Integration checks
- **THEN** every script and performance check launches `pwsh.exe`, every host-qualified result is labeled `PS7`, and no PS5 or multi-host selector is exposed
