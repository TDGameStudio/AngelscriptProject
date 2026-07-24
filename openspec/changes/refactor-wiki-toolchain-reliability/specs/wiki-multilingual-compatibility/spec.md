## ADDED Requirements

### Requirement: Wiki supports a defined bilingual locale contract

The integrated Wiki SHALL support `zh-Hans` and `en-GB` as its product locales. `$:/language` SHALL default to `zh-Hans`; when a supported product-specific language value is unavailable, the product SHALL use `en-GB` as the content fallback.

#### Scenario: Reader opens the default Wiki
- **WHEN** a reader opens the Wiki without changing the language preference
- **THEN** `$:/language` SHALL select `zh-Hans`
- **AND** product content and navigation SHALL select their Chinese presentation

#### Scenario: Reader selects English
- **WHEN** `$:/language` selects `en-GB`
- **THEN** bilingual product content and navigation SHALL select their English presentation
- **AND** a product-specific missing language value SHALL fall back to English rather than expose an unresolved title

### Requirement: Product-visible text uses compatible localization entry points

Project-owned UI text SHALL use a core `$:/language/...` tiddler, `<<lingo>>` under an explicit lingo base, or the established `$:/language`-conditioned bilingual WikiText form. Product TypeScript SHALL reuse existing language tiddlers for visible controls and notifications rather than introduce one-language literal labels.

#### Scenario: Maintainer adds a user-visible product control
- **WHEN** a maintainer adds a new button, menu item, notification, configuration description, or navigation caption
- **THEN** the change SHALL provide compatible zh-Hans and en-GB presentation through an approved localization entry point
- **AND** its tests SHALL cover the localization contract or reuse an already-covered core language tiddler

### Requirement: Theme lingo translations retain product identity and compatible lookup

The local Angelscript theme SHALL provide matching en-GB and zh-Hans translation key sets under `$:/themes/angelscript/language/`. Its project-owned visible translations SHALL identify the product as AngelScriptWiki or AngelScript and SHALL NOT retain the upstream TidGi or 太记 theme identity. The local lingo compatibility patch SHALL retain both legacy base-title lookup and language-code fallback until the locked TiddlyWiki baseline is reviewed.

#### Scenario: Theme configuration resolves in either supported locale
- **WHEN** the reader opens the Angelscript theme configuration under zh-Hans or en-GB
- **THEN** each lingo key used by the theme configuration SHALL resolve through the supported lookup paths
- **AND** visible theme identity text SHALL describe AngelScriptWiki rather than the inherited upstream theme
