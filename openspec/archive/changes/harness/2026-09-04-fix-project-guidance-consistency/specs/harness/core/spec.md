## ADDED Requirements

### Requirement: Consistent maintained project guidance

Every maintained project entry document and live Harness-facing Skill SHALL describe the same active operating contract: project Skills are enabled, `Harness` is the only live framework identity, UE 5.8 is the current engine baseline, PowerShell 7 Core is the supported host, the selected Git workspace is authoritative, Codex `/goal` is continuation rather than a repository mode, Review begins only on explicit request, and Unreal operations use `ue.*` routes without a root `Tools` wrapper fallback. Chinese agent guidance MUST be updated before or together with its English counterpart when this contract changes.

Maintained guidance MUST distinguish an ordinary Harness call, which imports and invokes modules directly in the caller's current PowerShell 7 process, from an intentional child `pwsh` process used for isolated test hosts, Git hooks or native fixtures, and Harness-managed Unreal workers. It MUST NOT instruct callers to launch Windows PowerShell or a redundant child shell for normal route dispatch.

#### Scenario: Enter the project through maintained guidance

- **WHEN** an agent or developer follows any maintained project entry document or live Harness-facing Skill
- **THEN** they reach the same selected-workspace, PowerShell 7, Harness, explicit-Review, and UE 5.8 contract without encountering a conflicting live instruction

> Inputs: `AGENTS_ZH.md`, `AGENTS.md`, the root `README.md`, `.agents/skills/README.md`, and the live Harness and Unreal Skill guidance.
> Observables: Current facts and examples agree across all maintained entry surfaces; historical archives remain unchanged.
> Boundaries: Independently versioned `Tools/openspec` source documentation and unrelated `Documents/` migration work are not silently rewritten by a parent Harness Change.
> Verification: A focused static cutover gate checks required facts and rejects representative retired terms and entry points in their authoritative sections.

#### Scenario: Invoke Harness in an existing PowerShell session

- **GIVEN** a caller already runs PowerShell 7 Core
- **WHEN** the caller imports Harness and dispatches an ordinary route
- **THEN** the route executes in that current process without launching another PowerShell host
- **BUT** an isolated test, hook/native fixture, or managed Unreal worker may intentionally launch a bounded child `pwsh` process

#### Scenario: Run an Unreal operation

- **WHEN** maintained guidance directs a build, Automation test, suite, commandlet, status, progress, or cancellation operation
- **THEN** it uses the matching Harness `ue.*` route for the exact selected workspace and does not offer a root `Tools` PowerShell wrapper as a fallback

## MODIFIED Requirements

### Requirement: Reusable PowerShell entry

Harness SHALL require PowerShell 7.0 or later with the Core edition and SHALL support repeated Workspace, Git, observation, OpenSpec, and Unreal invocations directly in one caller session without polluting caller location or shared global state. Ordinary route dispatch MUST NOT launch a redundant PowerShell process. Intentional child `pwsh` processes MAY be used only where process isolation or lifetime ownership is part of the declared contract, including test hosts, Git hooks or native fixtures, and Harness-managed Unreal workers. Every invocation SHALL return an independent run ID and the common result envelope. Session-local caches MAY retain bounded stable facts but MUST NOT cache dirty state, branch tips, authorization decisions, or mutation preconditions.

#### Scenario: Reuse one PowerShell 7 session

- **WHEN** Harness commands run repeatedly in one supported session
- **THEN** leaf modules remain reusable in that process, caller location is restored, every invocation has an independent run ID, and no Windows PowerShell 5.1 or redundant child-shell path is exposed

#### Scenario: Start an intentional isolated process

- **WHEN** a declared test-isolation, hook/native-fixture, or Unreal-worker boundary requires a child PowerShell process
- **THEN** Harness uses `pwsh`, keeps the child bounded to that operation, and does not redefine ordinary route dispatch as process spawning

#### Scenario: Observe mutable facts

- **WHEN** branch, dirty-state, authorization, or process facts change between invocations
- **THEN** Harness reads the current fact instead of trusting a stale cache
