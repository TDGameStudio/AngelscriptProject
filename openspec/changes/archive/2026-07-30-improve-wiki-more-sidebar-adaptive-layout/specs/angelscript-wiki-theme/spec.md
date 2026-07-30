## MODIFIED Requirements

### Requirement: Angelscript visual theme

The local Angelscript theme SHALL provide the itonnote-derived document styling and the Notion palette with readable text, visible focus states, document-oriented sidebar and tiddler presentation, and compatible generic code styling. On desktop, the left sidebar, story river, and product-owned resize slider SHALL share a single effective layout width; More MAY raise that width to its documented readability minimum without overwriting an unmodified user sidebar preference. The theme SHALL render More as a component-scoped navigation and content surface that preserves its native tabs, tag tiddler fields, popups, plugins, and responsive drawer behavior. The theme SHALL render body metadata tags, More tags, and native `$:/TagManager` table tags as a shared 4px-corner component: tags with no valid configured `color` field SHALL use the neutral engineering-blue baseline; tags with a valid configured `color` field SHALL derive a subdued surface, legible foreground, border, and 2px colour accent from that field without using hard-coded demonstration colours.

#### Scenario: Migrated theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the page, story river, tiddlers, sidebar, controls, links, code blocks, and editors SHALL receive the migrated document styling
- **AND** the existing sidebar segments SHALL remain available
- **AND** desktop More SHALL use the shared effective sidebar-width boundary without changing the mobile drawer behavior

#### Scenario: Configured and neutral tags remain visually coherent

- **WHEN** a body metadata tag, More tag, or native TagManager table tag has a valid `color` field
- **THEN** it SHALL retain the shared square geometry while displaying a subdued variant derived from that colour
- **AND** a tag without a valid `color` field SHALL use the neutral baseline without an accent marker
