## MODIFIED Requirements

### Requirement: Angelscript visual theme

The local Angelscript theme SHALL provide the itonnote-derived document styling and the Notion palette with readable text, visible focus states, document-oriented sidebar and tiddler presentation, and compatible generic code styling. On desktop, the left sidebar, story river, and product-owned resize slider SHALL share a single effective layout width; More MAY raise that width to its documented readability minimum without overwriting an unmodified user sidebar preference. The theme SHALL render More as a component-scoped navigation and content surface that preserves its native tabs, tag colours, popups, plugins, and responsive drawer behavior.

#### Scenario: Migrated theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the page, story river, tiddlers, sidebar, controls, links, code blocks, and editors SHALL receive the migrated document styling
- **AND** the existing sidebar segments SHALL remain available
- **AND** desktop More SHALL use the shared effective sidebar-width boundary without changing the mobile drawer behavior
