## Why

`Invoke-Harness` accepts one selected `HarnessContext`, but several PowerShell routes currently preserve caller-supplied root parameters instead of binding them to that context. A caller can therefore dispatch from the primary checkout while silently targeting a submodule or another registered worktree, and internal routes can replace the selected context entirely.

## What Changes

- Make the selected Context authoritative for every dispatcher-owned workspace, primary-root, and internal-context parameter.
- Permit an explicit matching root as an idempotent alias, but reject blank, conflicting, or mismatched overrides before a leaf module runs.
- Keep `git.integrate` explicit: it runs only from the canonical primary Context, while `SourceWorkspaceRoot` remains its sole authorized different workspace.
- Return a stable `ContextAuthorityMismatch` error and prove rejected dispatches have no target-side effects.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: Strengthen the unified workspace context into an enforced dispatcher authority boundary.

## Impact

The parent repository changes the Harness dispatcher, focused route fixtures, entry guidance, and Harness core specification. Leaf workspace, Git, Unreal, and portable OpenSpec implementations remain unchanged.
