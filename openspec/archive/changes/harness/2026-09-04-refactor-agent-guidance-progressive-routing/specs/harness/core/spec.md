## ADDED Requirements

### Requirement: Impact-scoped verification by default

Harness lifecycle guidance SHALL begin task execution, Change completion verification, and post-archive checking with the smallest reliable scope that directly proves the affected behavior. Verification MUST expand only when an affected shared contract, cross-component boundary, observed failure, release gate, or explicit user request provides a concrete reason.

#### Scenario: Verify a ready task
- **WHEN** an agent implements one ready task
- **THEN** it runs the task's exact impact-related verification before and after the smallest implementation change
- **AND** a local failure is diagnosed and repaired in the task before expanding to the adjacent affected surface
- **BUT** it enters Replan only when evidence invalidates an accepted requirement, design boundary, Task DAG edge, verification contract, or required artifact

#### Scenario: Select a broader Harness profile
- **WHEN** an agent chooses among focused tests, `Quick`, `Performance`, and `Integration`
- **THEN** it selects the profile whose contract matches the demonstrated impact
  > Details: The escalation rules are:
  >
  > 1. `Performance` applies to performance contracts or suspected performance regressions.
  > 2. `Integration` applies to changed cross-component integration boundaries.
  > 3. `Quick` applies when changes span multiple Harness core groups, the affected surface cannot be bounded reliably, or the user explicitly requests broader regression.
- **BUT** profile availability does not make all profiles unconditional daily gates

#### Scenario: Select Unreal verification
- **WHEN** a change affects a Harness `ue.*` route
- **THEN** it first runs the route's focused fixture or protocol proof
- **AND** it launches the matching Unreal operation only when the actual Unreal behavior cannot be proven by the fixture, product code is affected, release policy requires it, or the user explicitly requests it

#### Scenario: Complete and archive a guidance-only Change
- **WHEN** a completed Change affects only Skills, Markdown, templates, specifications, or their static contracts
- **THEN** completion uses the owning static or protocol tests plus strict OpenSpec validation
- **AND** post-archive checking adds strict archived validation and the smallest non-destructive lifecycle check without repeating unrelated tests
- **AND** final evidence records tests actually run and heavier gates intentionally omitted with their reasons

## MODIFIED Requirements

### Requirement: Consistent maintained project guidance

The root `AGENTS.md` SHALL be the sole canonical project-level agent entry and SHALL contain only stable, cross-capability invariants needed to route work safely. Detailed architecture, commands, lifecycle procedures, validation selection, implementation rules, mutable counts, reference inventories, and history MUST remain in their owning Skills, OpenSpec specifications, source, or existing indexes rather than being copied into the root entry. A second root language mirror MUST NOT be required.

The canonical entry and live Harness-facing Skills SHALL agree that project Skills are enabled, Harness is the project workflow entry, the selected Git workspace is authoritative, Codex `/goal` is continuation rather than a repository mode, Review begins only on explicit request, ordinary routes run in the current PowerShell 7 process, intentional child `pwsh` hosts are bounded exceptions, and Unreal operations use `ue.*` routes without a root `Tools` wrapper fallback.

#### Scenario: Enter the project through maintained guidance
- **WHEN** an agent opens the root project guidance
- **THEN** the sole root `AGENTS.md` provides the stable routing and authority boundaries needed to select the owning Skill, current Change, specification, or index
  > Observables: The entry routes to `.agents/skills/README.md`, Harness and OpenSpec Skills, `openspec/specs/`, and `Reference/README.md` without reproducing their volatile detail.
- **AND** focused static checks reject a second root Agent guide and representative architecture inventories, mutable test counts, reference-repository catalogs, historical milestones, or detailed command tutorials in the canonical entry
- **BUT** immutable OpenSpec archives and subsystem-owned guidance such as `Wiki/Agents_ZH.md` remain outside this single-entry cleanup
