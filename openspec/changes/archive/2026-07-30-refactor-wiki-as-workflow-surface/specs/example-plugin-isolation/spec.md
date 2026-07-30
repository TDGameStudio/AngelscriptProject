## ADDED Requirements

### Requirement: Example plugin is excluded from default workflows

The Wiki SHALL retain `Wiki/src/plugin-name/` as an experimental Modern.TiddlyDev fixture while excluding the plugin titled `$:/plugins/your-name/plugin-name` from the default `dev`, `test`, `build`, `build:library`, `publish`, and `publish:offline` workflows.

#### Scenario: Default build excludes the example plugin

- **WHEN** a maintainer runs the standard Wiki build or library build
- **THEN** the generated plugin artifacts SHALL include the Angelscript theme, tools, and configuration plugins
- **AND** the generated plugin library SHALL NOT include `$:/plugins/your-name/plugin-name`

#### Scenario: Default development server excludes the example plugin

- **WHEN** a maintainer starts the standard `pnpm dev` server
- **THEN** the Wiki runtime SHALL not load `$:/plugins/your-name/plugin-name`
- **AND** the AngelscriptWiki product tests SHALL remain runnable without the example widget

### Requirement: Example plugin remains explicitly usable

The Wiki SHALL provide explicit examples commands and a separate Playwright configuration that load the retained example plugin for tutorial verification and experimentation.

#### Scenario: Examples workflow loads the fixture

- **WHEN** a maintainer runs `pnpm dev:examples` or `pnpm test:examples`
- **THEN** `$:/plugins/your-name/plugin-name` SHALL be available
- **AND** the `RandomNumber` example widget SHALL render and respond to clicks

### Requirement: Example tests are isolated from product tests

The example tiddler and Playwright specs SHALL live outside the default product Playwright test directory, while remaining discoverable by the examples Playwright configuration.

#### Scenario: Product test suite does not require examples

- **WHEN** a maintainer runs `pnpm test:playwright`
- **THEN** the suite SHALL exercise only AngelscriptWiki product scenarios
- **AND** it SHALL not depend on `.tc-example-widget` or `RandomNumber`
