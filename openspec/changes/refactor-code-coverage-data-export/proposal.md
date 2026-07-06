## Why

The current Angelscript code coverage output is split between a small JSON summary and C++ hardcoded HTML pages. That makes the report easy to smoke-test but difficult to evolve into a richer static visualization site or a broader runtime diagnostics export.

This change proposes moving presentation out of runtime C++: the plugin should export stable structured data, while an external tool renders the HTML site and can later consume additional diagnostics such as function timing when those collection points are proven.

## What Changes

- **BREAKING**: Deprecate or remove runtime C++ generation of coverage `index.html` and per-file `*.as.html` pages.
- Add a complete structured coverage data package that includes run metadata, summary counts, file-level coverage, line-level hit counts, directory aggregation, source line counts, exclude-pattern effects, and schema metadata.
- Leave static HTML visualization to an external tool that consumes the exported data instead of runtime C++ string templates.
- Add an explicit diagnostics expansion contract so future data sections can include function timing, call counts, module/function metadata, compile diagnostics, or other script runtime observations without redesigning the export format.
- Record a performance-data exploration track: identify what can be collected today, which AS VM/JIT/UASFunction call paths would be needed for function timing, and which data should remain out of scope until instrumentation is validated.

## Capabilities

### New Capabilities

- `code-coverage-data-export`: Defines the stable machine-readable coverage data package emitted by the Angelscript runtime.
- `code-coverage-external-visualization`: Records the external visualization boundary for tools that consume the exported data package.
- `script-runtime-diagnostics-export`: Defines the extensible diagnostics data contract and exploration requirements for future performance and runtime information.

### Modified Capabilities

- None.

## Impact

- Runtime code coverage paths under `Plugins/Angelscript/Source/AngelscriptRuntime/Extension/CodeCoverage/`.
- Coverage automation tests under `Plugins/Angelscript/Source/AngelscriptTest/Core/`.
- Future tool entry point under `Tools/` or another project-approved external-tool location.
- Documentation and test catalog entries that currently describe HTML output as the primary code coverage artifact.
- Existing consumers that open runtime-generated HTML directly will need to switch to the external visualization tool after this change is applied.
