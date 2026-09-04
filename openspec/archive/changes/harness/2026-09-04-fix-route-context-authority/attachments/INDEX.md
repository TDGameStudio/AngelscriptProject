# Attachment Index

- `data/workflow-evaluation.md` — Terminal self-hosting evaluation for dispatcher Context authority.

## Conclusions

- The selected Context is the sole dispatcher authority for target and primary roots.
- Matching explicit aliases normalize to the selected root; blank, conflicting, and different values fail before leaf invocation.
- `git.integrate` requires a primary Context and retains only `SourceWorkspaceRoot` as a different registered workspace.

## Forbidden interpretations

- This evidence does not weaken leaf-level Git, workspace, or Unreal validation.
- This evidence does not authorize native OpenSpec commands to select a second repository root.
