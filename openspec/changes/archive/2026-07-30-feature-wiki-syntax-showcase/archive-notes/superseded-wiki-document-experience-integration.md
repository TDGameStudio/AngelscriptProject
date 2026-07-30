## Archive reconciliation

This delta targeted the former umbrella requirement
`Selected document plugins are source-managed and verified`. Before this change
was archived, later completed Wiki changes split that umbrella into narrower
shared requirements for source provenance, reproducible source preparation,
Markdown configuration, and page-drop behavior.

The Markdown More ownership and runtime contract below is retained for history
and is canonically represented by this change's
`wiki-markdown-more-source-integration` capability. The page-drop contract is
canonically represented by the subsequently archived
`fix-wiki-page-file-drop-import` change. This file therefore remains evidence
inside the archived change but is intentionally excluded from delta application
so that the archive does not replace newer shared-spec semantics.

## Superseded MODIFIED Requirements

### Requirement: Selected document plugins are source-managed and verified
The runtime SHALL load the local Angelscript theme, the selected external document plugins, the official highlight and Markdown plugins, and the source-managed `$:/plugins/cdr/markdown-more` plugin. Every declared external plugin SHALL identify its repository path, audited baseline commit, source path, and expected plugin title in `external-plugins.json`; normal build, test, and development commands SHALL validate those source locations and create the disposable `.generated/plugin-sources/` bridge without fetching, publishing, or modifying the source repositories. Markdown More SHALL resolve the AngelscriptWiki defaults `admonition/style = pastel` and `toc/enable = no`.

#### Scenario: Runtime confirms the selected plugin set
- **WHEN** the Wiki opens a representative document
- **THEN** the local theme, retained external plugins, official highlight and Markdown plugins, and Markdown More SHALL be present while retired document plugins remain absent

#### Scenario: Source preparation rejects an invalid external plugin declaration
- **WHEN** a declared external plugin path is missing or its plugin title does not match the manifest
- **THEN** source preparation SHALL fail before the plugin development tool starts

#### Scenario: Markdown More renders without an in-page table of contents
- **WHEN** a Markdown tiddler renders in the Wiki
- **THEN** the resolved admonition style SHALL be `pastel`, TOC enablement SHALL be `no`, and no in-page TOC container SHALL render on desktop or narrow screens

### Requirement: Core external drag-and-drop importing is disabled
The Wiki SHALL override `$:/core/ui/PageTemplate` to replace only the page-wide external-import `$dropzone` with the ordinary `tc-page-container-inner` layout container. Dropping an external file on a normal page SHALL NOT activate the core drag-and-drop importer. Intentional imports SHALL continue to use the explicit core import controls. `$:/config/DragAndDrop/Enable` SHALL remain unset so ordinary core drag-to-reorder interactions retain their default enablement.

#### Scenario: External file is dragged across a rendered page
- **WHEN** a user drags an external file across the normal Wiki page drop zone
- **THEN** the normal page container SHALL NOT render as a core `$dropzone` or open the core importer
