# Accepted PowerShell 7 Performance Evidence

## Run

- Host: PowerShell Core 7.6.0, X64
- Warmup runs: 1
- Measurement runs: 5
- Persistent API batch size: 500
- Correctness: every retained sample passed
- Overall budget status: Passed

## Aggregate

| Scenario | Unit | Min | Median | P95 | Max | P95 budget |
|---|---:|---:|---:|---:|---:|---:|
| FreshProcess | ms | 396.3479 | 423.9212 | 447.4598 | 447.4598 | 5000 |
| PersistentApi | us/op | 57.9414 | 71.3036 | 96.8232 | 96.8232 | 5000 |
| TaskStatus | ms | 43.2553 | 44.9239 | 47.4364 | 47.4364 | 2000 |
| WorkspaceReadRoutes | ms/3 routes | 4534.8159 | 4641.5963 | 4732.5041 | 4732.5041 | 15000 |

`WorkspaceReadRoutes` measures `workspace.config.status`, `workspace.status`, and `git.status` together against the real dirty primary checkout and its initialized top-level submodules. It is a catastrophe guard and comparison baseline, not a portable fine-grained performance promise.

## Raw artifact identity

- Run ID: `workspace-git-final-20260903-PS7`
- `Summary.json` SHA-256: `b609f9c1a39124b82e0e66c55edb9de82fa23dbf4dba016ae14f7b1738de9406`
- `Samples.csv` SHA-256: `12626148a5f9ba033546595059078e2347cd1e62902bf074742cb10b5c99144b`
- Raw location class: ignored `Saved/Harness/Hardness/Performance/<run-id>/`

The durable record intentionally omits absolute paths, user identity, computer identity, and raw per-sample rows.
