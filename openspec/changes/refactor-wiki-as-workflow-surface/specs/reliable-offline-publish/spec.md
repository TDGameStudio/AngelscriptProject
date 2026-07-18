## MODIFIED Requirements

### Requirement: Existing offline publish contents remain included

The project-level wrapper SHALL preserve the existing offline publish behavior, including plugin library generation, Wiki tiddlers, and all non-fixture source plugins, while excluding the explicitly configured Modern.TiddlyDev example plugin.

#### Scenario: Theme and configuration are published

- **WHEN** offline publishing completes
- **THEN** the generated Wiki SHALL include the Angelscript theme and configuration plugin artifacts
- **AND** the default theme selection SHALL remain available in the generated HTML
- **AND** the plugin library SHALL include `$:/plugins/TDGameStudio/angelscript-tools`
- **AND** the plugin library SHALL NOT include `$:/plugins/your-name/plugin-name`
