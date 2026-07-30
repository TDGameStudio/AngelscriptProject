# wiki-bilingual-document-lifecycle Specification

## Purpose
TBD - created by archiving change docs-wiki-content-foundation. Update Purpose after archive.
## Requirements
### Requirement: Localized documents have paired physical pages and one logical key

Formal Wiki documentation SHALL store Chinese and English bodies in separate tiddlers titled `AS/Docs/<locale>/<topic>/<slug>` and sourced from `Wiki/wiki/tiddlers/docs/<locale>/<topic>/<slug>.tid`. Paired pages SHALL share exactly one locale-independent `as-doc-key`.

#### Scenario: Chinese and English versions both exist

- **WHEN** the Wiki contains both supported locales for a logical document
- **THEN** exactly one `zh-Hans` and one `en-GB` page SHALL use the shared `as-doc-key`
- **AND** each page SHALL have an independently reviewable body

#### Scenario: Duplicate locale is introduced

- **WHEN** two pages declare the same `as-doc-key` and `as-locale`
- **THEN** content-contract validation SHALL fail and identify both titles

### Requirement: Chinese is authored and reviewed before English

A formal document SHALL originate as `zh-Hans`. An `en-GB` pair SHALL NOT be marked reviewed unless the Chinese page exists and has `as-content-status` equal to `reviewed` or `published`.

#### Scenario: Chinese document is still a draft

- **WHEN** the Chinese page is a placeholder or draft
- **THEN** an English page SHALL NOT claim reviewed translation status
- **AND** the directory SHALL treat English as pending

#### Scenario: Chinese review completes

- **WHEN** the Chinese page reaches reviewed or published status
- **THEN** an English translation MAY be created against that Chinese content revision

### Requirement: Locale-aware links resolve current locale before Chinese fallback

Formal cross-document links SHALL resolve a logical `as-doc-key` through a shared `as-doc-link` procedure. Resolution SHALL prefer the current supported locale, then `zh-Hans`, then an explicit missing-document state.

#### Scenario: English translation exists

- **WHEN** `$:/language` selects `en-GB` and the requested English pair exists
- **THEN** the logical link SHALL open the English page

#### Scenario: English translation is missing

- **WHEN** `$:/language` selects `en-GB` and only the Chinese page exists
- **THEN** the logical link SHALL open the Chinese page
- **AND** the rendered page SHALL identify that English translation is pending
- **AND** the Wiki SHALL retain the reader's language preference

#### Scenario: No localized page exists

- **WHEN** neither the requested locale nor the Chinese fallback exists
- **THEN** the link SHALL render an explicit missing-document state
- **AND** it SHALL NOT silently target a newly created empty tiddler

### Requirement: Translation revisions expose stale English content

Chinese reviewed content SHALL carry a positive integer `as-content-revision`. English pages SHALL record their Chinese source title in `as-translation-of` and source revision in `as-translation-revision`. A reviewed English page whose translation revision differs from the current Chinese content revision SHALL be treated as stale.

#### Scenario: English translation matches Chinese

- **WHEN** an English page is reviewed and its `as-translation-revision` equals the paired Chinese `as-content-revision`
- **THEN** the Wiki SHALL present the translation as current

#### Scenario: Chinese content changes after translation

- **WHEN** the reviewed Chinese content revision increases beyond the English translation revision
- **THEN** the English page SHALL be identified as stale
- **AND** the reader SHALL be offered the current Chinese page
- **AND** validation SHALL reject a `reviewed` translation status that claims the revisions still match

### Requirement: Navigation and search respect supported document locales

The documentation directory SHALL select pages for the current supported locale and SHALL use Chinese fallback without duplicating both locale entries in the same primary navigation position. Localized document bodies SHALL remain individually searchable.

#### Scenario: Reader browses Chinese documentation

- **WHEN** `$:/language` selects `zh-Hans`
- **THEN** the directory SHALL show Chinese titles and Chinese pages for available documents
- **AND** English pairs SHALL NOT appear as duplicate siblings

#### Scenario: Reader browses English documentation with partial translation

- **WHEN** `$:/language` selects `en-GB`
- **THEN** the directory SHALL show English pairs where available
- **AND** it SHALL show one marked Chinese fallback entry where English is absent
- **AND** it SHALL NOT show both entries for the same `as-doc-key`

### Requirement: UI fallback and article fallback are distinct contracts

The Wiki documentation SHALL distinguish product UI/lingo fallback from localized article-body fallback. UI translation compatibility MAY use the established en-GB fallback, while formal Chinese-first documents SHALL use zh-Hans fallback.

#### Scenario: Multilingual compatibility specs are reconciled

- **WHEN** this capability and the in-progress Wiki multilingual toolchain capability are prepared for archival
- **THEN** their requirements SHALL explicitly distinguish UI strings from formal document bodies
- **AND** no requirement SHALL claim that missing English article content falls back to English
