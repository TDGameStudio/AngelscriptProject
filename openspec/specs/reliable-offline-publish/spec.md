# reliable-offline-publish Specification

## Purpose
TBD - created by archiving change fix-tw-offline-publish-output. Update Purpose after archive.
## Requirements
### Requirement: Offline publish produces complete HTML

The Wiki offline publishing command SHALL return success only after the configured HTML output exists, is non-empty, and contains a complete closing `</html>` tag.

#### Scenario: Successful offline publish

- **WHEN** a maintainer runs `npm run publish:offline` in `Wiki/`
- **THEN** the command exits with code 0
- **AND** `Wiki/dist/index.html` has a size greater than zero
- **AND** the file contains a closing `</html>` tag

#### Scenario: Incomplete output is not accepted

- **WHEN** the renderer creates an empty or truncated output file
- **THEN** the publisher continues waiting until the completion condition is met or the timeout expires
- **AND** it does not report success for the incomplete file

### Requirement: Offline publish waits before temporary cleanup

The publisher SHALL keep its temporary TiddlyWiki input directory available until the HTML completion condition has been satisfied.

#### Scenario: Asynchronous renderer completes after file creation

- **WHEN** the renderer creates `index.html` before finishing its asynchronous write
- **THEN** the publisher SHALL wait for non-empty stable complete content
- **AND** only then remove the temporary input directory

### Requirement: Existing offline publish contents remain included

The project-level wrapper SHALL preserve the existing offline publish behavior, including plugin library generation, Wiki tiddlers, and source plugins, without requiring manual copying.

#### Scenario: Theme and configuration are published

- **WHEN** offline publishing completes
- **THEN** the generated Wiki includes the Angelscript theme and configuration plugin artifacts
- **AND** the default theme selection remains available in the generated HTML

### Requirement: Offline renderer has its required template plugin

The project-level wrapper SHALL preload the `tiddlywiki/tiddlyweb` plugin that provides the offline HTML template when the source Wiki does not list that plugin in `tiddlywiki.info`.

#### Scenario: Template is available in a minimal Wiki configuration

- **WHEN** `tiddlywiki.info` omits `tiddlywiki/tiddlyweb`
- **THEN** offline publishing SHALL still resolve `$:/plugins/tiddlywiki/tiddlyweb/save/offline`
- **AND** the generated HTML SHALL contain the rendered Wiki rather than an empty file
