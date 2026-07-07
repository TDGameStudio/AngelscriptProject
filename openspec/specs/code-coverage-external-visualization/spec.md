# code-coverage-external-visualization Specification

## Purpose
TBD - created by archiving change refactor-code-coverage-data-export. Update Purpose after archive.
## Requirements
### Requirement: External tool generates a static HTML coverage site

The project SHALL provide an external tool that reads the exported coverage data package and generates a static HTML site for manual inspection.

#### Scenario: Static site is generated from exported data

- **WHEN** the external visualization tool is run against a valid coverage data package
- **THEN** it SHALL generate static HTML files without requiring Unreal runtime C++ HTML generation
- **AND** the generated site SHALL be openable from the filesystem for local inspection

#### Scenario: Current report affordances are preserved

- **WHEN** a user opens the generated static HTML site
- **THEN** the site SHALL show total coverage, directory-level summaries, file-level summaries, source lines, covered line highlighting, not-covered line highlighting, and hit count details equivalent to the current runtime-generated report

#### Scenario: Visualization can grow beyond coverage

- **WHEN** the exported data package includes future diagnostics sections
- **THEN** the static visualization design SHALL allow those sections to be surfaced without changing the runtime coverage exporter into an HTML renderer again

### Requirement: HTML rendering is decoupled from runtime C++

Runtime C++ SHALL not own rich coverage page layout, styling, or navigation once the external visualization tool is available.

#### Scenario: Runtime presentation code is removed or deprecated

- **WHEN** code coverage output is generated after the migration
- **THEN** the runtime SHALL not need hardcoded HTML templates, CSS strings, or JavaScript snippets to satisfy the coverage reporting workflow

#### Scenario: Manual validation uses external HTML

- **WHEN** a developer wants to inspect coverage visually
- **THEN** the documented workflow SHALL point to the external static HTML tool and its generated output

