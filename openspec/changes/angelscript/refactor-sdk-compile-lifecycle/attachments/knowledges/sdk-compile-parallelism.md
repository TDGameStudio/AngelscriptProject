---
disposition: candidate
---

# SDK compile parallelism is per-body, not a module wave

## Reusable Insight

`WorkerCount` on `asCBuilder` only parallelizes `AnalyzeBodies` (stride `std::thread` after serial initializers). `ResolveDeclarations` takes the count and stays serial. Emit and Registration are serial. Cross-module ordering is the caller’s DAG of `asCModuleDefinitionSet`. The SDK does not run independent Builders on a thread pool; they typically share one `asCTypeContext` intern table.

## Evidence

- `asCCompilationSession::AnalyzeBodies` starts `min(WorkerCount, function count)` threads.
- Host `CompileModules` `ParallelFor` currently stubs `asNOT_SUPPORTED`; Stage1–3 fail on purpose.

## Boundaries

Does not specify a future host scheduler. Does not make identity Intern concurrent-safe across two Builders.

## Application

Do not add module-level `ParallelFor` in this Change. Keep Registration off the worker count.

## Sources

- attachments/drafts/findings/parallel-and-module-deps.md
- attachments/drafts/design.md
