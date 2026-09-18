# Workspace Query Cost and Freshness

## Reusable finding

- Measure native calls before adding a cache. Repeated repository-root resolution inside one public query can dominate the PowerShell work even when route lookup is cheap.
- Resolve the root at the identity boundary and reuse that call's result through `Status -> ConfigStatus -> Identity` and `Context -> Identity`. Keep each new public call live: branch, HEAD, workspace identity and configuration changes must appear without a refresh flag.
- Preserve the dispatcher's independent workspace authorization check. Passing a caller-supplied identity to bypass it would change the trust boundary.
- This repair adds neither cross-call caching nor a resident worker. Queue status also reads task and discussion state through native/Python boundaries; optimize those only after measuring their actual cost and consistency requirements.

## Measured comparison

- Measured on 2026-09-19, PowerShell 7.6.0 Core X64. The before source is commit `87d93ed8ceed44d243ed2ea2aac639889cb51fb6`; the after source changes only the workspace query composition for this comparison.
- Standard runner: `.agents/skills/harness/tests/Harness.Performance.Tests.ps1 -WarmupRuns 3 -MeasurementRuns 15 -BatchSize 1000`. Before and after use the same fixture sizes and parameters, in serial runs. All eight existing performance budgets pass on both versions.
- The additional queue/execution/preview probe uses one isolated, planned Change with an execution binding. It does not mutate a real Change or queue. Other document/Git work may contribute ambient load.

| Public query | Median before / after (ms) | p95 before / after (ms) |
|---|---:|---:|
| `workspace.status` Fast | 467.063 / 298.121 | 797.632 / 408.024 |
| `harness.status` | 486.669 / 286.725 | 784.704 / 346.852 |
| `task.status` | 401.347 / 314.945 | 509.311 / 512.905 |
| `queue.status`, additional fixture | 1201.065 / 902.544 | 1505.498 / 1513.041 |
| `execution.status`, additional fixture | 376.748 / 270.262 | 585.756 / 328.348 |
| Handoff preview, additional fixture | 309.559 / 238.328 | 426.152 / 308.241 |

- With 15 samples, nearest-rank p95 equals the maximum. Queue and task tail samples did not improve; fresh-process p95 also rose from 1022.247 to 1176.878 ms. These are local comparisons, not production latency promises.
- Detailed workspace scanning was measured only in a small isolated repository. It does not establish full UE-repository scan performance.
- Pure route lookup was unchanged by this repair; its timing variation is not credited to the optimization. The stronger causal evidence is the actual native-call reduction below.

## Deterministic proof and regression boundary

| Query | Git calls before / after | Root probes before / after |
|---|---:|---:|
| Workspace Context | 4 / 3 | 2 / 1 |
| Config status | 4 / 3 | 2 / 1 |
| Workspace status leaf | 5 / 3 | 3 / 1 |
| `harness.status` | 9 / 6 | 5 / 2 |
| `queue.status` | 12 / 9 | 6 / 3 |
| `execution.status` | 4 / 3 | 2 / 1 |
| Handoff preview | 4 / 3 | 2 / 1 |

- Trace the real Git boundary without replacing returned data. Instrumented single-call timing is separate from the uninstrumented sample distributions.
- `WorkspaceQueryPerformance.Tests.ps1` first observed three resource-boundary failures: the Context, Config and Status leaf queries performed 2, 2 and 3 root probes. After repair each performs one.
- All 12 assertions pass, including nested paths, default workspace selection, live branch/HEAD/config changes, invalid identity visibility, missing-configuration read-only behavior and Detailed dirty-file evidence. The runner registers this test as `WorkspaceQueryPerformance.PS7`.
- Keep deterministic resource-count and freshness assertions in regression tests; avoid millisecond assertions that fail with unrelated machine load. Retain the existing coarse performance budgets separately.

## Evidence provenance

- Raw reports and samples remain ignored under `Saved/AgentTemp/harness-quality/performance/`; the full local report is `Saved/AgentTemp/harness-quality/performance-baseline.md`. This indexed note preserves the reusable conclusion and bounded aggregates.
- SHA-256 identifies the exact raw reports used above:

| Relative raw report | SHA-256 |
|---|---|
| `before-20260919/Summary.json` | `d55fc15d4f7bb3eb8a1fc691fb63fa0c8feba449bf9de3bf8be6560969592a46` |
| `after-20260919/Summary.json` | `d157cd3a6b094b11ca81f61f4b49c10397283cef3c12505f1d6f286ab33dd18c` |
| `before-hotpaths.json` | `091fc3ca79907da07ef00ff8bcf9e7c621297b6a56f35e6679ce33b37498374d` |
| `after-hotpaths.json` | `0af694d45591fd1648991f10961c9b6a68f298416e714262151d907fa537ea57` |
