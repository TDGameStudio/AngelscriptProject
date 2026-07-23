## ADDED Requirements

### Requirement: Product sources have one authoritative manifest

The Wiki SHALL use one tracked product-source manifest to define local, vendor, example, and reference plugin sources. Build preparation, lint/source-boundary checks, runtime plugin allowlisting, and vendor provenance validation SHALL consume that manifest rather than maintaining independent source lists.

#### Scenario: Product sources are prepared

- **WHEN** a maintainer runs a standard Wiki development, verification, or offline build command
- **THEN** only entries with the `product` profile SHALL be prepared for the product runtime
- **AND** example and reference entries SHALL remain available in source without being packaged

### Requirement: Initial runtime is local and allowlisted

The Wiki SHALL ship only manifest-approved runtime plugins and SHALL make no off-origin request during initial navigation. Any external behavior SHALL be explicitly declared and SHALL require a user action before it starts.

#### Scenario: Reader opens the Wiki

- **WHEN** the initial document finishes loading
- **THEN** no CPL, telemetry, authentication, statistics, or other off-origin request SHALL have been issued
- **AND** unowned serialized plugins SHALL not be present in the runtime plugin set

#### Scenario: Reader edits a Draw.io tiddler

- **WHEN** the reader explicitly starts the Draw.io editing flow
- **THEN** the declared Draw.io iframe MAY connect to its configured external service
- **AND** this exception SHALL not apply to initial navigation

### Requirement: Test fixtures are hidden system tiddlers

Browser and TiddlyWiki test fixtures SHALL use the `$:/tests/TDGameStudio/AngelscriptWiki/` title namespace. Reader-facing showcases SHALL use separate ordinary titles.

#### Scenario: Reader inspects ordinary content

- **WHEN** the reader opens More, All, Recent, or ordinary search results
- **THEN** internal test fixtures SHALL not appear
- **AND** deliberate syntax and code showcases SHALL remain discoverable

### Requirement: Product responsibilities remain modular

The theme plugin SHALL own visual tokens and styles, the tools plugin SHALL own browser interaction behavior, and the configuration plugin SHALL own product defaults and narrow policy overrides. The configuration plugin SHALL not contain startup interaction modules.

#### Scenario: Sidebar implementation is inspected

- **WHEN** a maintainer traces the left-sidebar capability
- **THEN** shell appearance SHALL be defined by the theme
- **AND** resize and mobile-navigation behavior SHALL be defined by tools
- **AND** width and breakpoint defaults SHALL be defined by configuration

### Requirement: Core overrides are guarded

Any full-title override of a TiddlyWiki core tiddler SHALL have a source contract test that identifies the permitted delta from the installed core baseline.

#### Scenario: TiddlyWiki changes PageTemplate

- **WHEN** the installed `$:/core/ui/PageTemplate` changes outside the permitted page-level dropzone wrapper delta
- **THEN** verification SHALL fail with a diagnostic requiring review
- **AND** internal tiddler drag behavior SHALL remain covered separately

### Requirement: Offline artifact has explicit boundaries and budgets

The product build SHALL emit a complete offline Wiki without a plugin library or standalone plugin-package artifacts. It SHALL validate the HTML structure, runtime plugin allowlist, initial-network boundary, and a checked decoded-size budget.

#### Scenario: Offline Wiki is built

- **WHEN** `pnpm run build:wiki` completes successfully
- **THEN** `dist/index.html` SHALL be complete and non-empty
- **AND** `dist/library` and standalone plugin JSON packages SHALL be absent
- **AND** the artifact SHALL not exceed 5,800,000 decoded bytes without an explicit reviewed budget update

### Requirement: Host status is revisioned data

Volatile host-repository baselines displayed by the Wiki SHALL come from a generated, revision-stamped system data tiddler rather than hand-maintained prose.

#### Scenario: AS status is rendered

- **WHEN** the Wiki displays catalog, SDK, or disabled-test counts
- **THEN** it SHALL display the source revision and generation date
- **AND** the values SHALL be generated from declared host source documents without runtime network access

