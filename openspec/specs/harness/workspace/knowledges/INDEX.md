# Harness Workspace Knowledge Index

- [Workspace Identity and Session Selection](workspace-identity.md)
  - Summary: Separate durable per-workspace identity from replaceable per-process selection so concurrent agents cannot redirect one another.
  - Serves: Harness-managed local configuration, per-session workspace selection, and workspace-sensitive execution guard.
  - Source: `openspec/archive/changes/harness/2026-09-03-refactor-workspace-git-operations`, validated by WorkspaceLifecycle fixtures.
  - Status: current
