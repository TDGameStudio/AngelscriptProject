## MODIFIED Requirements

### Requirement: Angelscript visual theme

The local Angelscript theme SHALL provide modular itonnote-derived document styling and the Notion palette with readable text, visible focus states, document-oriented left-sidebar and tiddler presentation, compatible generic code styling, and responsive behavior derived from the configured sidebar breakpoint. On desktop it SHALL preserve the accepted left-sidebar and focused-story layout while keeping the production sidebar resize target discoverable through hover and active-drag feedback, rendering one More-sidebar content divider clearly separated from its category controls, and compacting only the excessive description-to-tag spacing for `as-sdk-document: yes` without changing its existing title, description, tag, body order or normal tag-to-body reading break. Standalone comparison artifacts SHALL NOT change this production contract until a later visual selection is recorded.

#### Scenario: Migrated theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the accepted left sidebar, story river, tiddlers, SDK documents, controls, links, code blocks, editors, and More panel SHALL receive the migrated document styling
- **AND** the existing sidebar segments SHALL remain available
- **AND** an idle sidebar resize target SHALL not show a visible rail while hover and active drag SHALL provide clear resize feedback
- **AND** the More-sidebar SHALL show a single content divider that does not overlap its category controls
- **AND** an SDK document with tags and a description SHALL retain one compact tag group after its description and before its body
- **AND** standalone sidebar experiment files SHALL not alter the selected production theme behavior
