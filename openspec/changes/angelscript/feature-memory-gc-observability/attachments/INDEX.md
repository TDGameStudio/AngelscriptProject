# INDEX

## Current position

Research and feature-record creation only. proposal.md owns the accepted direction; tasks.md owns future work. No product instrumentation, build or Automation execution was performed. Harness PlanOnly validated trace-argument routing.

## Hard conclusions

- Observe before changing GC policy. AS-managed heap, UE-owned objects and compiler/generation resources have distinct ownership.
- Extend existing Stats/LLM/CPU/CSV facilities; repair coverage rather than assuming SDKAlloc sees every allocation.
- Physical allocation, logical object lifetime, reusable capacity and GC phase work are separate measures.
- Native Memory Insights already traces FMemory: do not emit duplicate manual heap events.
- Current AST uses new/delete; current GC return codes and incremental iterations are not object-count metrics.

## Attachment index

- data/research-evidence.md — Current source and UE 5.8/official/Knot findings, source limitations and successful capture PlanOnly evidence; read when checking APIs and existing coverage.
- data/metrics-and-probes.md — Recommended measurement matrix, insertion points, arithmetic oracles and capture workflow; read when completing design and executable task cards. Metric policy is owned by proposal.md.
