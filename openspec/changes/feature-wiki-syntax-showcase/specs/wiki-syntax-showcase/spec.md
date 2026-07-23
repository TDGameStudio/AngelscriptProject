## ADDED Requirements

### Requirement: Rendered syntax showcases remain discoverable without homepage navigation
The Wiki SHALL provide the titles `Markdown 基础示例`, `Markdown 扩展语法示例`, `Markdown More 示例`, and `TiddlyWiki 语法示例` as directly openable and searchable tiddlers, and SHALL NOT add them to the Wiki homepage.

#### Scenario: A reader opens a showcase directly
- **WHEN** a reader navigates to any showcase title through a direct Wiki route
- **THEN** the tiddler SHALL render without missing tiddler links

### Requirement: The searchable syntax directory preserves syntax-family boundaries
The Wiki SHALL provide a directly openable and searchable `语法展示范式` tiddler that groups links to the Markdown and WikiText showcase pages. It SHALL NOT transclude, tab-render, or otherwise mix the Markdown and WikiText showcase bodies in the directory itself, and SHALL NOT add the directory to the Wiki homepage.

#### Scenario: A reader opens the syntax directory
- **WHEN** a reader navigates directly to `语法展示范式`
- **THEN** the directory SHALL render one link each to `Markdown 基础示例`, `Markdown 扩展语法示例`, `Markdown More 示例`, and `TiddlyWiki 语法示例` without rendering the linked showcase bodies

### Requirement: Markdown showcase provides a comprehensive rendered baseline
The `Markdown 基础示例` tiddler SHALL render the reference Markdown baseline's heading forms and levels, emphasis variants, links and anchors, blockquotes, ordered/unordered/nested lists, task lists, separators, aligned tables, inline/indented/fenced code, image, HTML `details`, keyboard keys, and emoji. It SHALL remain a rendered-only document without a duplicate source panel or source/result comparison layout.

#### Scenario: Markdown styling is inspected
- **WHEN** the Markdown showcase renders
- **THEN** its comprehensive baseline semantic surfaces SHALL be present as rendered HTML content and no embedded Markdown source tutorial SHALL be present

### Requirement: Markdown extension showcase isolates parser-supported surfaces
The `Markdown 扩展语法示例` tiddler SHALL render parser-supported extended Markdown surfaces, including footnotes, definition lists, abbreviations, insertions, marks, subscripts, superscripts, and reference-style links or images. It SHALL remain rendered-only and SHALL NOT be merged into the Markdown More tiddler.

#### Scenario: Markdown extension styling is inspected
- **WHEN** a reader opens `Markdown 扩展语法示例`
- **THEN** extension-specific semantic surfaces SHALL render without missing tiddler links, a source panel, or Markdown More checklist/admonition containers

### Requirement: Markdown More showcase covers extension surfaces
The `Markdown More 示例` tiddler SHALL render checked and unchecked checklist items, normal and collapsible admonitions, nested admonitions, and an example block without an in-page table of contents.

#### Scenario: Markdown More styling is inspected
- **WHEN** the Markdown More showcase renders
- **THEN** its extension-specific containers and initial checklist states SHALL be visible without test automation toggling a checklist or rendering an in-page table of contents

### Requirement: WikiText showcase covers dynamic TW5 surfaces without persistence
The `TiddlyWiki 语法示例` tiddler SHALL render WikiText formatting, structured blocks, transclusion, filtered content, and a widget interaction whose state is stored only under `$:/temp`.

#### Scenario: A reader triggers the WikiText widget
- **WHEN** the reader activates the showcase interaction
- **THEN** its feedback SHALL become visible without writing a persistent source tiddler
