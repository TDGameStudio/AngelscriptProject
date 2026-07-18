## ADDED Requirements

### Requirement: Wiki defaults identify AngelscriptWiki

The Wiki SHALL provide its own default site title, subtitle, home tiddler, and default tiddler list without referencing `$:/plugins/your-name/plugin-name` as product content.

#### Scenario: Default site identity is loaded

- **WHEN** the development Wiki starts with no user override
- **THEN** `$:/SiteTitle` SHALL identify `AngelscriptWiki`
- **AND** `$:/SiteSubtitle` SHALL describe the AngelscriptWiki documentation surface
- **AND** `$:/DefaultTiddlers` SHALL open the AngelscriptWiki home entry

### Requirement: Wiki home exposes two documentation tracks

The home tiddler SHALL expose separate navigation entry points for Angelscript users and plugin maintainers, with Chinese and English content selected through the existing Wiki language state.

#### Scenario: Home navigation is available in both languages

- **WHEN** `$:/language` resolves to Chinese or English
- **THEN** the home tiddler SHALL render a localized AS user track
- **AND** it SHALL render a localized plugin maintainer track
- **AND** it SHALL provide links to the AS status and theme roadmap pages

### Requirement: Stable defaults remain packaged

Stable site defaults SHALL remain in `src/angelscript-wiki-config/`, while migrated stable `$__*.tid` defaults SHALL not remain in `wiki/tiddlers/system/`.

#### Scenario: Default configuration is packaged

- **WHEN** the configuration plugin is built
- **THEN** its payload SHALL contain the site title, site subtitle, default tiddlers, theme selection, view selection, CPL startup default, and guarded browser startup action
- **AND** the Wiki system directory SHALL not contain duplicate files for those stable defaults
