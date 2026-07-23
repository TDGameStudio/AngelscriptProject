## ADDED Requirements

### Requirement: Normal page file drops do not invoke the core importer
The Wiki SHALL replace the page-wide `$dropzone` in `$:/core/ui/PageTemplate` with an ordinary `tc-page-container-inner` layout container. Dropping an external file or cross-Wiki payload over a normal rendered page SHALL NOT invoke the TiddlyWiki `$:/Import` workflow. Explicit core Import controls SHALL remain available.

#### Scenario: A reader drops an external file on a rendered document
- **WHEN** an external file is dropped over the normal page surface
- **THEN** the normal page surface SHALL NOT be rendered as a core `tc-dropzone`
- **AND** the core `$:/Import` workflow SHALL NOT be invoked by that page surface

### Requirement: Core internal drag-to-reorder behavior remains enabled
The Wiki SHALL leave `$:/config/DragAndDrop/Enable` unset and SHALL preserve the default core drag-and-drop enablement for sidebar, tag, and list ordering targets.

#### Scenario: A reader drags an open-sidebar tiddler within the Wiki
- **WHEN** a core Open-sidebar droppable target receives a dragover event
- **THEN** that core target SHALL continue to handle the event as an enabled droppable target
