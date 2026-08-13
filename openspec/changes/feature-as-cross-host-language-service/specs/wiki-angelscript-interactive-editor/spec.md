## ADDED Requirements

### Requirement: Authors explicitly opt into an interactive AngelScript editor
AngelscriptWiki SHALL provide an `$angelscript-editor` widget from a separate local `angelscript-workbench` product plugin. The widget SHALL accept `sourceTiddler` and `code` initial-source attributes, with `sourceTiddler` taking precedence, and SHALL not alter ordinary `$angelscript-code`, core code blocks, direct `text/x-angelscript` rendering, or the global Wiki editor.

#### Scenario: Author embeds a source tiddler
- **WHEN** an article renders `<$angelscript-editor sourceTiddler="AS/Examples/GeneratedActor" />`
- **THEN** the widget SHALL use that tiddler's text as its initial AngelScript document
- **AND** the source tiddler SHALL remain unchanged

#### Scenario: Author supplies inline code
- **WHEN** `sourceTiddler` is absent and `code` is present
- **THEN** the resolved TW5 widget attribute text SHALL become the initial document
- **AND** HTML-sensitive characters SHALL remain source text

#### Scenario: Both source attributes are present
- **WHEN** both `sourceTiddler` and `code` are supplied
- **THEN** `sourceTiddler` text SHALL take precedence deterministically

### Requirement: Reader edits are ephemeral and isolated
Each widget SHALL keep its current draft only in its own runtime document state. It SHALL not write a tiddler, localStorage, IndexedDB, filesystem entry, project file, or network service. Reset SHALL restore the current author-provided initial source.

#### Scenario: Reader changes an example
- **WHEN** a reader edits source in one widget
- **THEN** that widget SHALL analyze the new in-memory version
- **AND** its source tiddler and another widget's draft SHALL remain unchanged

#### Scenario: Reader resets the example
- **WHEN** Reset is activated
- **THEN** the widget SHALL replace its draft with the current initial source, increment its document version, and refresh diagnostics and outline

#### Scenario: Widget is removed and recreated
- **WHEN** TiddlyWiki removes the widget and later renders it again
- **THEN** the previous draft SHALL not be restored automatically
- **AND** the new widget SHALL start from author-provided source

### Requirement: Interactive assets are lazy and locally scoped
CodeMirror modules, Worker code, WASM, and the `.aslp` profile SHALL be decoded/instantiated only when an `$angelscript-editor` is rendered. The retired `$:/plugins/BTC/tiddlywiki-codemirror-6` plugin SHALL remain absent, and the Workbench SHALL not replace TiddlyWiki's global edit widget.

#### Scenario: Wiki opens an ordinary document
- **WHEN** no interactive AngelScript widget is present
- **THEN** no Workbench Worker or WASM instance SHALL be created
- **AND** existing Highlight.js code presentation SHALL behave unchanged

#### Scenario: First interactive widget appears
- **WHEN** the first widget renders successfully
- **THEN** the Workbench SHALL lazy-initialize its local CodeMirror integration, Worker, WASM service, and pinned partial profile

#### Scenario: Product plugins are inspected
- **WHEN** the built Wiki plugin inventory is read
- **THEN** `angelscript-workbench` SHALL be present as a local product source
- **AND** the retired BTC CodeMirror plugin title SHALL be absent

### Requirement: The widget provides focused language feedback
The widget SHALL provide editable AngelScript text, syntax presentation, line numbers, bracket/search keyboard behavior, diagnostic gutter and list, lightweight completion, service/profile status, and Reset. It SHALL debounce analysis by approximately 250 ms and SHALL never display a stale result over a newer version.

#### Scenario: Reader introduces a compiler error
- **WHEN** the current draft becomes syntactically invalid
- **THEN** the matching version's compiler diagnostic SHALL appear at its UTF-16 source range in the gutter and diagnostic list
- **AND** dependent shared lint cascades SHALL be suppressed

#### Scenario: Reader triggers lightweight completion
- **WHEN** completion is requested at a language, local-symbol, or resolved profile-member context
- **THEN** the widget SHALL display the service's bounded candidates
- **AND** it SHALL not claim project-wide symbols or full UE API coverage

#### Scenario: Older response arrives last
- **WHEN** Worker responses arrive out of document-version order
- **THEN** only the current version SHALL update diagnostics, completion state, and class preview

### Requirement: Shared diagnostics are presented without local rule logic
The Workbench SHALL render compiler and shared static diagnostics returned by the WASM service. Wiki TypeScript and CodeMirror adapters SHALL NOT reimplement registered `ASLINT` matching, severity, messages, or suppression.

#### Scenario: Shared naming rule is triggered
- **WHEN** WASM returns `ASLINT1101` for the current version
- **THEN** the widget SHALL display the returned rule ID, severity, message, and range
- **AND** it SHALL not calculate a second naming diagnostic

#### Scenario: Static Error is displayed
- **WHEN** WASM returns a non-fatal Error such as `ASLINT1005`
- **THEN** the widget SHALL distinguish it from compiler failure using returned source/fatality metadata

### Requirement: Class structure preview is explicitly static
When `showOutline` is not disabled, the widget SHALL display the service-provided declared class name, bases, properties, functions, declaration flags, and related diagnostic state. The UI SHALL state that the result is a static semantic preview and not a generated UE UClass.

#### Scenario: Example declares an Actor class
- **WHEN** the current version produces a complete class outline
- **THEN** the preview SHALL list the declared Actor base and members with navigable source ranges
- **AND** it SHALL display the non-UClass disclaimer

#### Scenario: Outline is partial
- **WHEN** analysis proves only a partial class outline
- **THEN** the preview SHALL mark it partial and show only proven declarations
- **AND** it SHALL not fabricate UProperties, UFunctions, offsets, CDOs, or runtime instances

### Requirement: Multiple widgets share heavy runtime but isolate documents
Widgets on the same page SHALL share one Workbench Worker, WASM service, and profile instance while retaining separate URI, text, version, diagnostics, completion, outline, and lifecycle state.

#### Scenario: Two examples are edited
- **WHEN** two widgets are present and the reader changes one
- **THEN** only that widget's document version and results SHALL change
- **AND** both SHALL use the same initialized service/profile instance

#### Scenario: Last widget is removed
- **WHEN** TiddlyWiki removes the final live widget
- **THEN** the Workbench SHALL close all documents and release the Worker, object URLs, WASM instance, and associated listeners

### Requirement: Failure degrades without breaking document reading
The Workbench SHALL provide readable and accessible fallbacks for CodeMirror initialization, Worker startup, WASM/profile validation, analysis, and limit failures. A Workbench failure SHALL not prevent the rest of the tiddler or Wiki from rendering.

#### Scenario: WASM or profile cannot initialize
- **WHEN** initialization returns an integrity, compatibility, or runtime error
- **THEN** the source SHALL remain readable and editable where possible
- **AND** an accessible analysis-unavailable message and retry action SHALL be shown

#### Scenario: CodeMirror cannot initialize
- **WHEN** the editor dependency fails before an editable surface exists
- **THEN** the widget SHALL render escaped readable source and an unavailable status
- **AND** no source text SHALL be interpreted as HTML

### Requirement: Workbench interaction is accessible and responsive
Workbench controls SHALL have localized Chinese/English labels, keyboard operation, visible focus, semantic control roles, non-color-only diagnostic severity, and an announced diagnostic/status summary. The editor, diagnostic list, and outline SHALL remain usable on narrow screens without horizontal page overflow.

#### Scenario: Keyboard-only reader uses the widget
- **WHEN** the reader tabs through editor and controls, requests completion, selects a diagnostic, and activates Reset
- **THEN** every operation SHALL be available without a pointer
- **AND** focus SHALL move predictably without being trapped

#### Scenario: Narrow viewport renders the example
- **WHEN** viewport width matches the product mobile breakpoint
- **THEN** diagnostics and outline SHALL stack beneath the editor
- **AND** the containing page SHALL not acquire unintended horizontal overflow

### Requirement: Wiki remains a single offline artifact within budgets
The integrated Wiki SHALL continue to emit exactly one offline `dist/index.html` with embedded Workbench assets and no runtime service/network dependency. The final HTML SHALL not exceed 24 MiB; added Workbench assets SHALL not exceed 16 MiB; baseline cold initialization SHALL not exceed 5 seconds; and warm 500-LOC analysis p95 excluding debounce SHALL not exceed 500 ms.

#### Scenario: Offline artifact is inspected
- **WHEN** the release Wiki is built and served with network blocked
- **THEN** one `index.html` SHALL contain the selected Worker/WASM/profile assets and interactive examples SHALL function without network requests

#### Scenario: Release budgets are exceeded
- **WHEN** artifact size, Workbench payload, cold start, warm analysis, or main-thread long-task measurements exceed their configured limits
- **THEN** the owning release validation SHALL fail with the measured category

### Requirement: CodeMirror selection has explicit provenance
Only the minimum approved CodeMirror 6 modules needed by the Workbench SHALL be selected. Exact versions, lockfile state, MIT license obligations, bundled output, and the relationship to the research-only `Reference/tiddlywiki-codemirror-6` checkout SHALL be recorded in product provenance and third-party notices.

#### Scenario: Dependency inventory is reviewed
- **WHEN** Workbench dependencies are validated
- **THEN** every selected CodeMirror package SHALL have a pinned version and license record
- **AND** no complete retired plugin snapshot SHALL be copied into the product
