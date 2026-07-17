## MODIFIED Requirements

### Requirement: Standalone wiki repository plan

The project SHALL use `TDGameStudio/AngelscriptWiki` as the standalone repository for the TiddlyWiki source, seeded from `git@github.com:tiddly-gittly/Modern.TiddlyDev.git`.

#### Scenario: Repository identity is reviewed

- **WHEN** maintainers review the wiki repository setup
- **THEN** the repository is identified as `TDGameStudio/AngelscriptWiki`
- **AND** its initial source history comes from `tiddly-gittly/Modern.TiddlyDev`
- **AND** the repository is not implemented as GitHub's built-in `.wiki.git` repository

### Requirement: Host repository submodule plan

The host repository SHALL consume `TDGameStudio/AngelscriptWiki` at `Wiki/` as a tracked git submodule.

#### Scenario: Host project links the wiki

- **WHEN** a fresh host checkout runs `git submodule update --init --recursive`
- **THEN** `Wiki/` is initialized from `git@github.com:TDGameStudio/AngelscriptWiki.git`
- **AND** the parent repository records the Wiki gitlink and `.gitmodules` mapping

### Requirement: Active migration boundary

The repository setup SHALL be an active implementation milestone rather than a planning-only record; AS-specific content migration SHALL remain a later change after the clean TiddlyWiki seed is verified.

#### Scenario: First milestone is reviewed

- **WHEN** the repository and submodule setup is complete
- **THEN** the clean upstream TiddlyWiki workspace is available at `Wiki/`
- **AND** experimental content remains outside the initial repository

## REMOVED Requirements

### Requirement: GitHub Pages publishing plan

**Reason**: The previous requirement was specific to the superseded MkDocs workspace. The first TiddlyWiki milestone establishes source ownership and development entry points before selecting a publishing pipeline.

**Migration**: Reintroduce a TiddlyWiki-specific publishing requirement in a later change after the source repository and content model stabilize.

### Requirement: Pages URL plan

**Reason**: The previous Pages URL described the MkDocs site and is not yet a committed TiddlyWiki delivery URL.

**Migration**: Define the final TiddlyWiki deployment URL together with its build/publish workflow in a follow-up change.

### Requirement: Planning-only boundary

**Reason**: This change is explicitly requested as an implementation of the repository and submodule setup.

**Migration**: Use the active migration boundary requirement above; later changes may extend the Wiki submodule without reopening the repository identity decision.
