# INDEX

## Current position

Both Task DAG nodes are complete and completion verification is green: Python unit tests and drift checking pass, the editor target builds, and the focused Framework Automation report is 27/27. The durable `angelscript/testing/code-database` delta has been synchronized into the current capability. The remaining lifecycle work is terminal evolution evidence and completed archive.

## Hard conclusions

- `AngelscriptTestCode/**/*.as` is authored truth; `CodeGenTool/**` is excluded.
- One `.as` maps to one mirrored checked-in `.generated.cpp` under the `AngelscriptTest` module.
- `generate` is the only writer; `check` is read-only; ordinary UBT never invokes Python.
- Generated and handwritten providers share the existing public registration, parser, activation, and database path.
- The Windows RCDATA carrier is removed rather than retained in parallel.

## Forbidden

- Do not implement `TestSource-old` recipe, history, catalog, diagnostics, reload, LSP, or DAP behavior in this Change.
- Do not add a second runtime database, generated aggregate/index, private batch bridge, or Python parser for `.as` metadata.
- Do not delete or archive the older planning-only unified-framework Change as part of this scope.
- Do not make UBT invoke the Python generator.

## Attachment index

- `drafts/design.md` — approved architecture, carrier mapping, modularity, safety, and migration decisions — read for implementation design and task boundaries.
- `drafts/glossary.md` — settled public and filesystem names — read before naming interfaces or files.
- `drafts/handoff.md` — approval provenance, scope, success criteria, exclusions, and carryover — read when planning or checking scope.
- `drafts/findings/generated-cpp-manual-sync.md` — inspected code and repository-generation evidence, including a clearly superseded early bridge suggestion — read when validating reuse and removal boundaries.
- `data/planning-validation.md` — requirement coverage, placeholder scan, and symbol consistency self-review — read when validating or revising the Task DAG.
- `data/workflow-evaluation.md` — terminal lifecycle timing, friction, evidence disposition, and exact active-input digest — read before completed closure.
- `data/closure.yaml` — intentional completed-closure input for the portable archive command — read only at the archive boundary.
