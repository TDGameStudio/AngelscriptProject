## Context

`FAngelscriptCodeCoverage` currently owns line mapping, hit recording, stop-time report writing, and summary output. `CoverageReportGenerator.cpp` also hardcodes HTML head/footer/style/script strings and writes per-file HTML plus directory `index.html` pages directly from runtime C++.

The current HTML is useful as a local smoke artifact, but it is not a good long-term visualization layer. Richer navigation, filters, source annotations, trend views, or future performance overlays are easier to build in an external static-site tool that consumes stable data. Runtime C++ should instead publish facts: what ran, where it came from, which lines were executable, which lines were hit, which files were excluded, and what diagnostic channels are available.

Coverage is also only one possible observation stream. The runtime can already identify current script function/module/line in the line callback, and possible future performance collection points exist around `asCContext::Execute()`, `asCContext::CallScriptFunction()`, StaticJIT generated calls, and `UASFunction::RuntimeCall*`. Those points need separate exploration before function timing can be treated as reliable data.

## Goals / Non-Goals

**Goals:**

- Replace runtime-generated coverage HTML with stable structured data exports.
- Define enough coverage data for an external tool to reproduce the current HTML report and improve it.
- Make external static HTML visualization a first-class part of the change, not an optional note.
- Preserve a schema extension path for performance, function timing, module metadata, compile diagnostics, and other runtime diagnostics.
- Record the performance-data exploration needed before implementing function-level timing.

**Non-Goals:**

- Do not implement function timing in the first coverage export refactor.
- Do not require the runtime data exporter to embed full source text in JSON.
- Do not introduce a heavy web application runtime; the visualization target is a static HTML artifact.
- Do not broaden coverage collection semantics beyond existing executable-line mapping unless a later task proves a concrete data gap.

## Decisions

### Decision: Runtime exports data, external tool renders HTML

Runtime C++ will stop owning report presentation. It will write a coverage data package, while an external tool reads that package and generates static HTML.

Rationale: HTML string templates in C++ are hard to evolve, hard to test visually, and mix presentation concerns into runtime code. A data-first export gives CI and visualization tools the same source of truth.

Alternative considered: keep C++ HTML and only improve styling. This preserves the current workflow but continues coupling visualization to runtime C++ and does not solve future performance overlays.

### Decision: Keep one primary JSON package before adding extra formats

The first implementation should write one complete `coverage_summary.json` package with schema metadata, run metadata, coverage summary, file entries, line entries, tree aggregation, settings, capture capabilities, and extension placeholders.

Rationale: one authoritative JSON file is easy for tests, CI, and an external generator to consume. Extra formats such as LCOV or Cobertura can be generated later from the same package if needed.

Alternative considered: immediately add LCOV/Cobertura. That is useful for third-party CI dashboards, but it cannot carry all script-specific metadata and would not replace the need for a richer internal package.

### Decision: Do not export full source text in the first schema

Each file entry should include `relative_path`, `absolute_path`, `source_line_count`, coverage counts, summary inclusion status, and line hit data. The external renderer can read source text from disk when needed.

Rationale: paths plus line hit data are enough to recreate the current report, keep JSON smaller, and avoid escaping/source duplication issues. If archived self-contained reports are needed later, a new optional source snapshot section can be added.

Alternative considered: embed source lines in JSON. That improves artifact portability but increases file size and complicates stale-source behavior.

### Decision: Treat performance as a separate diagnostics stream

The first schema should include `capture_capabilities` and `extensions`, but function timing should remain `not_collected` until instrumentation is designed and verified.

Rationale: coverage line hits and function timing have different collection points and overhead profiles. Function timing may need AS VM, JIT, and UASFunction entry coverage to avoid blind spots.

Alternative considered: add timing while refactoring coverage export. This risks mixing a data-format refactor with VM instrumentation and makes failures harder to isolate.

### Decision: External visualization must preserve current report affordances

The external tool must generate a static site that covers the current C++ HTML behavior: total coverage, directory summary, file links, covered and not-covered line highlighting, hit counts, source display, and generated time. It can then add richer UI such as search, filters, sorting, and future diagnostics overlays.

Rationale: removing C++ HTML should not make manual validation worse. The migration is only acceptable if the external tool replaces the current manual inspection workflow.

## Risks / Trade-offs

- **External tool lags runtime JSON** -> Keep `schema_version`, deterministic ordering, and tests that parse required fields before tool rendering.
- **Current HTML users lose a direct artifact** -> Provide a tool task that generates static HTML from the JSON and document the new manual inspection command.
- **Function timing data is incomplete if only one call path is instrumented** -> Treat timing as a later diagnostics collector and first inventory AS VM, StaticJIT, and UASFunction execution paths.
- **JSON grows too large for big projects** -> Start without embedded source text and sort compact line entries; add split-file exports only if real artifact size becomes a problem.
- **Exclude rules are hard to debug** -> Export exclude patterns and per-file inclusion/exclusion status in the data package.

## Migration Plan

1. Introduce data-package export while keeping or shimming the existing stop/write entry point.
2. Update coverage tests to assert JSON data instead of runtime HTML.
3. Add the external static HTML generator and test it against a fixture or generated coverage package.
4. Remove or deprecate C++ HTML output after the external renderer can reproduce the current manual inspection workflow.
5. Document the new workflow and generated artifact paths.

Rollback before archive is straightforward: retain the old C++ HTML generator and keep the external tool as experimental. After archive, rollback would restore the old HTML generation code and tests from git.

## Open Questions

- Which implementation language should the external static HTML generator use: PowerShell to match current tooling, or Node/Python if a richer frontend build step is justified?
- Should the first JSON package include function declarations/ranges derived from AS metadata, or only line-level coverage data?
- Should future performance timing target interpreted AS only first, or attempt to cover interpreted, JIT, and UASFunction dispatch together?
- Should self-contained HTML reports embed source snapshots, or is reading source files next to the project enough for local validation?
