## ADDED Requirements

### Requirement: Clean upstream repository seed

The standalone `TDGameStudio/AngelscriptWiki` repository SHALL be initialized from `git@github.com:tiddly-gittly/Modern.TiddlyDev.git` without importing files or commits from `Experiment/AngelscriptTiddlyDev`.

#### Scenario: Initial repository is reviewed

- **WHEN** maintainers inspect the first `AngelscriptWiki` commit and its remote history
- **THEN** the source history is traceable to `tiddly-gittly/Modern.TiddlyDev`
- **AND** no experimental AS Wiki or ImGui files are present in the initial seed

### Requirement: TiddlyWiki development workspace

The standalone repository SHALL retain the upstream TiddlyWiki development entry points, including `package.json`, `wiki/tiddlywiki.info`, and the upstream-supported build and test scripts.

#### Scenario: Fresh checkout starts the upstream workspace

- **WHEN** a developer runs the documented dependency and development commands from `Wiki/`
- **THEN** the TiddlyWiki development server can start using the repository's existing scripts
- **AND** the checkout does not require the host project's Unreal Engine or Angelscript plugin

### Requirement: Experimental workspace isolation

The host migration SHALL preserve `Experiment/AngelscriptTiddlyDev` as an independent workspace and SHALL add AS-specific content to the standalone repository only through later, deliberate changes.

#### Scenario: Clean seed is compared with experiment

- **WHEN** maintainers compare the new `Wiki/` checkout with `Experiment/AngelscriptTiddlyDev`
- **THEN** the two workspaces remain separate Git repositories
- **AND** the initial `Wiki/` checkout contains no uncommitted experiment-only changes
