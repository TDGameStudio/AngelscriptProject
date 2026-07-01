## 1. Investigation

- [x] 1.1 Locate the crashing `DoSoftReload` code path
- [x] 1.2 Confirm the Blueprint-derived class null-cast hypothesis

## 2. Regression Coverage

- [x] 2.1 Add a focused HotReload Blueprint-child regression test <!-- TDD -->
- [x] 2.2 Record RED verification status: the initial RED run was interrupted before result collection, so no reconstructed RED evidence is claimed; the crash root cause and regression are recorded in `investigation.md`, and the final focused regression passed after the production fix.

## 3. Runtime Fix

- [x] 3.1 Fix Blueprint generated class script-type propagation
- [x] 3.2 Verify the focused regression test passes
