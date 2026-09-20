# INDEX

## Maintenance baseline — 2026-09-12

Read [Current-baseline maintenance](data/maintenance-20260912.md) before historical attachments. It records current source ownership, preserved task state, exact format checks and remaining planning boundaries. Historical talks, research snapshots and applied replans are provenance rather than current API authority.

## Current position

Research and feature-record creation only. proposal.md owns the accepted direction; tasks.md owns future work. No product instrumentation, build or Automation execution was performed. Harness PlanOnly validated trace-argument routing.

## Hard conclusions

- Observe the accepted post-removal native lifetime model: final release and shutdown drain. The deletion Change remains pending; current as_gc source is transitional. UE GC and retained UClass tombstones are separate host observations.
- Extend existing Stats/LLM/CPU/CSV facilities; repair coverage rather than assuming SDKAlloc sees every allocation.
- Physical allocation, logical object lifetime, reusable capacity and GC phase work are separate measures.
- Native Memory Insights already traces FMemory: do not emit duplicate manual heap events.
- Historical collector return codes and incremental iterations are not current target metrics. Removed collector metrics report unavailable.

## Attachment index

- data/research-evidence.md — Current source and UE 5.8/official/Knot findings, source limitations and successful capture PlanOnly evidence; read when checking APIs and existing coverage.
- data/metrics-and-probes.md — Recommended measurement matrix, insertion points, arithmetic oracles and capture workflow; read when completing design and executable task cards. Metric policy is owned by proposal.md.

- [Applied current-baseline replan](replans/replan-20260912-073639-current-baseline.md) — accepted record maintenance; current paths, ownership and proof boundaries; read before resuming the pending plan.
