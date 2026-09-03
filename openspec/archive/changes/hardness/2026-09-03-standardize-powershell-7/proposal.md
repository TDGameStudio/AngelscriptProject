# Standardize Hardness on PowerShell 7

## Why

Hardness currently runs every script gate under both Windows PowerShell 5.1 and PowerShell 7. The duplicate host matrix makes the real Git/worktree safety suite run twice even though the project has selected PowerShell 7 as its only supported harness host.

## What Changes

- Require PowerShell 7.0 or later with the Core edition for the Hardness and Workspace modules.
- Remove the public host selector and every PS5 check from the Hardness gate runner.
- Keep explicit `PS7` result names so retained evidence identifies its execution host.
- Update maintained entry documentation, Task DAG examples, capability requirements, and dogfooding knowledge to use `pwsh.exe` only.
- Retain one new PS7-only performance snapshot; preserve both completed dual-host archives as immutable historical evidence.

## Boundaries

- No OpenSpec binary or Rust source change.
- No Unreal Engine build, Automation, StaticJIT, or standalone test.
- No migration of the deferred `unreal-engine-develop` leaf or legacy UE tooling documents; those require their own change.
- No rewrite or deletion of prior PS5 raw or archived evidence.
