# wiki-repository-publishing Specification

## Purpose
TBD - created by archiving change docs-wiki-repository-publishing-plan. Update Purpose after archive.
## Requirements
### Requirement: Standalone wiki repository plan

The project SHALL use `TDGameStudio/AngelscriptWiki` as the planned standalone repository for the MkDocs wiki source.

#### Scenario: Repository identity is reviewed

- **WHEN** maintainers review the wiki publishing plan
- **THEN** the plan identifies `TDGameStudio/AngelscriptWiki` as the intended wiki source repository
- **AND** the plan does not require using GitHub's built-in `.wiki.git` repository

### Requirement: GitHub Pages publishing plan

The project SHALL publish the wiki through GitHub Pages from a GitHub Actions workflow that builds MkDocs strictly.

#### Scenario: Publishing workflow is prepared

- **WHEN** maintainers initialize the standalone wiki repository
- **THEN** the planned publishing workflow builds with `python -m mkdocs build --strict`
- **AND** the planned deployment publishes the generated `site/` directory through GitHub Pages artifacts

### Requirement: Pages URL plan

The project SHALL use `https://tdgamestudio.github.io/AngelscriptWiki/` as the planned initial Pages URL for the standalone wiki.

#### Scenario: Site URL is configured

- **WHEN** maintainers prepare the standalone wiki repository
- **THEN** `mkdocs.yml` is expected to set `site_url` to `https://tdgamestudio.github.io/AngelscriptWiki/`

### Requirement: Host repository submodule plan

The host repository SHALL later consume the standalone wiki repository at `Wiki/` as a git submodule after the standalone repository is created and publishing is verified.

#### Scenario: Host project links the wiki

- **WHEN** the standalone wiki repository exists and its Pages deployment succeeds
- **THEN** maintainers can replace the ignored local `Wiki/` workspace with a `Wiki/` submodule pointing to `TDGameStudio/AngelscriptWiki`
- **AND** host documentation is expected to describe submodule initialization

### Requirement: Planning-only boundary

This change SHALL remain a planning record and MUST NOT itself create the remote repository, move the current `Wiki/` directory, delete local wiki files, or add a git submodule.

#### Scenario: Planning change is applied

- **WHEN** this OpenSpec change is reviewed
- **THEN** it contains repository and publishing guidance only
- **AND** the current host repository `Wiki/` workspace remains in place

