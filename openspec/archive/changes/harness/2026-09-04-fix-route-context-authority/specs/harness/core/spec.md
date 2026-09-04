## MODIFIED Requirements

### Requirement: Unified workspace context

Harness MUST use one Git-derived workspace model in both the primary checkout and any registered linked worktree. The exact selected Context SHALL be authoritative for every dispatcher-owned workspace, repository, primary-root, and internal-context argument; caller parameters MAY repeat a matching root but MUST NOT retarget the operation. Codex `/goal` is an external continuation facility only and MUST NOT select a repository mode, imply worktree creation, constrain branch names, or change Git authority. New worktrees default to `.worktrees/<name>` on branch `<name>`, while existing registered worktrees remain valid at their current path and branch. Integration, non-force push, and worktree removal MUST remain three separate operations requiring explicit user intent.

#### Scenario: Work in the primary checkout
- **WHEN** the caller selects the registered primary checkout
- **THEN** Harness targets that exact root without creating, switching, or assigning a repository mode and preserves unrelated local changes

#### Scenario: Work in an existing linked worktree
- **WHEN** the caller selects any worktree registered in the same Git common directory
- **THEN** Harness accepts its actual path and branch without requiring `.worktrees/<name>` or a branch prefix

#### Scenario: Interpret Codex Goal continuation
- **WHEN** work is running under Codex `/goal`
- **THEN** repository selection still comes from the explicit or discoverable WorkspaceRoot and no repository-mode state is created

#### Scenario: Reject a route target override
- **GIVEN** Harness has resolved one exact selected Context
- **WHEN** caller parameters supply a blank, conflicting, or different dispatcher-owned root or internal Context
- **THEN** Harness returns `ContextAuthorityMismatch` before loading or invoking the leaf and does not mutate either the selected or requested target

> Inputs: Workspace routes, Git routes, Unreal routes, and internal Harness routes with both canonical parameter names and supported aliases.
> Observables: Matching explicit roots are normalized to the selected Context; rejected results contain no leaf data and no target-side effect.
> Boundaries: Portable native OpenSpec and task routes receive authority through their working directory and never accept a second repository-selection parameter.
> Verification: Table-driven dispatcher fixtures cover every routed root category and an alternate registered worktree.

#### Scenario: Integrate from the primary Context
- **WHEN** `git.integrate` is dispatched from the canonical primary Context with an explicitly selected registered linked source
- **THEN** the target remains that primary Context and `SourceWorkspaceRoot` is the only authorized different workspace root

> Boundaries: Selecting a linked Context and silently redirecting its target to `PrimaryRoot` is forbidden.
