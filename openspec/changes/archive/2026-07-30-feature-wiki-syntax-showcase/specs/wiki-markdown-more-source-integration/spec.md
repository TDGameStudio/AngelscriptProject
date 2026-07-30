## ADDED Requirements

### Requirement: Markdown More source is managed through the Wiki vendor boundary
The Wiki SHALL retain the complete MIT-licensed `cdruan/tw-markdown-more` source snapshot under `Wiki/vendor/tw-markdown-more/` and SHALL register `$:/plugins/cdr/markdown-more` through `Wiki/external-plugins.json`.

#### Scenario: Generated source preparation includes Markdown More
- **WHEN** the Wiki prepares external plugin sources
- **THEN** the generated plugin-source bridge SHALL contain a `markdown-more` plugin whose title is `$:/plugins/cdr/markdown-more`

#### Scenario: Build inputs remain offline and reproducible
- **WHEN** a normal Wiki build, test, or development command runs
- **THEN** it SHALL use the committed vendor source and SHALL NOT fetch or publish Markdown More

### Requirement: Markdown More uses AngelscriptWiki visual defaults
The Wiki SHALL override Markdown More defaults with pastel admonitions and a disabled in-page table of contents.

#### Scenario: Runtime configuration keeps the table of contents disabled
- **WHEN** a browser loads the Wiki runtime
- **THEN** Markdown admonitions SHALL use `pastel` and TOC enablement SHALL be `no`
