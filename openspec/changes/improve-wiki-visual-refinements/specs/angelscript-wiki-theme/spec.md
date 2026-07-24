## MODIFIED Requirements

### Requirement: Angelscript visual theme

The local Angelscript theme SHALL provide modular itonnote-derived document styling and the Notion palette with readable text, visible focus states, document-oriented left-sidebar and tiddler presentation, compatible generic code styling, and responsive behavior derived from the configured sidebar breakpoint. On desktop it SHALL use the selected compact-control-rail layout with a persistent native-icon control rail, a quiet always-present resize seam that strengthens on hover and active drag, one More-sidebar content divider clearly separated from its category controls, and compact spacing only between SDK description and tags without changing title, description, tag, body order or the normal tag-to-body reading break. Narrow layouts SHALL retain the existing left drawer and mobile PageControls instead of the desktop rail.

#### Scenario: Migrated theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the accepted left sidebar, story river, tiddlers, SDK documents, controls, links, code blocks, editors, and More panel SHALL receive the migrated document styling
- **AND** the existing sidebar segments SHALL remain available
- **AND** the `40px` production control rail SHALL use native TiddlyWiki and enabled-plugin button/icon tiddlers
- **AND** an idle sidebar resize target SHALL show a quiet boundary while hover and active drag SHALL provide progressively stronger feedback
- **AND** the More-sidebar SHALL show a single content divider that does not overlap its category controls
- **AND** an SDK document with tags and a description SHALL retain one compact tag group after its description and before its body
- **AND** standalone sidebar experiment fixtures and Unicode icon placeholders SHALL not be copied into the production runtime
