---
record_id: final-integration-evidence
status: resolved
source: verification
created_at: 2026-09-03T02:08:29.8291339+08:00
resolving_task: "4.1"
snapshot_commit: f8b94bacced721f55ebb1d42fff9778c6ed12269
---

# Final Integration Evidence

## Committed snapshot

```text
dedba4c3 Workspace lifecycle
408e26d7 final OpenSpec 0.8.1 package
ccbce3f3 OpenSpec lifecycle Skills
3f0447b5 Hardness core and protocols
f8b94bac project entry points and change records
```

The parent history between base `4129487f63fab930800a896ae7f932d7bd4e6e70` and this snapshot contains `.agents/skills/openspec/bin/openspec.exe` in exactly one commit: `408e26d7c83399c802da6f55250b2c819e2a268c`. `Tools/openspec` is clean at annotated `v0.8.1` commit `1930040ab18acba43d44fcd635d2a91a701f04ce`.

## Integration gate

`Test-Hardness.ps1 -Profile Integration -PowerShellHosts Both -WarmupRuns 3 -MeasurementRuns 15` passed `16/16` on the committed snapshot:

- Hardness, runner contract, Protocol, Workspace, and OpenSpec package tests passed in Windows PowerShell 5.1 and PowerShell 7 (`10/10`).
- Hardness Performance passed in both hosts (`2/2`); retained raw runs are `gate-20260902T180553261Z-864e788b-{PS5,PS7}`.
- Hardness installation, OpenSpec doctor, workflow validation, and strict change validation passed (`4/4`).

The accepted privacy-trimmed baseline remains `attachments/data/hardness-performance-baseline-20260903-014536.json`; the Integration rerun creates ignored raw evidence only and does not replace that accepted aggregate.

## Independent final Review

`attachments/reviews/review-20260903-020906-hardness-final.md` is `closed` with verdict `APPROVE`, no Critical, Required, or Advisory finding, and SHA-256 `89627be4202e1b94b0fe8e90585cee42aef6f3381ee0289a2564693a5d9e03a5`. The reviewer explicitly permits Task `4.1` completion and the Task `4.2` durable-spec and closure work.

## Exclusions

The gate did not load or execute `unreal-engine-develop`, its stashed prototype, public UE wrappers, Editor build, Automation, Smoke, Standalone, complete All, or StaticJIT All. Those paths remain outside this delivery.
