# Workspace Identity and Session Selection

## Two different facts

`AgentConfig.ini` describes the workspace that contains it. The process environment describes the workspace selected for one PowerShell session. They must not be collapsed into a shared active-workspace file.

```text
workspace-local AgentConfig.ini -> durable root/project/common-Git identity
PowerShell process environment  -> replaceable Current/Goal selection
build or test launch            -> both facts must agree with the target root
```

The canonical primary checkout is the only default source for machine-shared settings. Projection into a Goal preserves non-managed settings and comments, but always rewrites the managed identity and `Paths.ProjectFile`.

## Execution boundary

Before a workspace-sensitive Unreal command resolves engine tooling, validate registration, managed identity, the workspace-owned `.uproject`, optional process selection, and the caller's registered workspace when it can be inferred. Do not allow an alternate `ConfigPath` to bypass that identity.

Read-only cross-worktree process discovery remains independent of activation. Build mutexes, output roots, and execution slots continue to key by the requested project root.
