## MODIFIED Requirements

### Requirement: Standalone wiki repository plan

The project SHALL use `TDGameStudio/AngelscriptWiki` as the standalone
TiddlyWiki source repository and SHALL consume it from
`AngelscriptProject/Wiki` as a git submodule.

#### Scenario: Repository identity is reviewed

- **WHEN** maintainers review the Wiki source and publishing boundary
- **THEN** the source repository is `TDGameStudio/AngelscriptWiki`
- **AND** the source format is TiddlyWiki rather than MkDocs
- **AND** publication does not depend on GitHub's built-in `.wiki.git`
  repository

### Requirement: GitHub Pages publishing plan

After the Wiki is explicitly declared ready, the project SHALL publish a
validated TiddlyWiki offline artifact through GitHub Pages Actions.

#### Scenario: Publishing workflow is prepared

- **WHEN** maintainers resume the deferred Pages deployment change
- **THEN** the workflow installs dependencies from the committed pnpm lockfile
- **AND** it builds the site with `pnpm run build:wiki`
- **AND** it validates the artifact with `pnpm run test:artifact`
- **AND** it publishes `dist/` through GitHub Pages artifact and deployment
  actions
- **AND** it does not commit generated output to `main` or a `gh-pages`
  content branch

#### Scenario: Publication is not yet accepted

- **WHEN** the Wiki milestone has not received explicit maintainer approval
- **THEN** the presence or execution of the existing workflow MUST NOT be
  treated as acceptance of the production Pages deployment
- **AND** this OpenSpec change remains pending

### Requirement: Pages URL plan

The project SHALL use
`https://tdgamestudio.github.io/AngelscriptWiki/` as the initial canonical
Pages URL after the deployed TiddlyWiki has been verified.

#### Scenario: Public URL is accepted

- **WHEN** the offline artifact deploys successfully
- **THEN** maintainers open the public URL in a browser
- **AND** verify initial load, desktop navigation, the command palette, the AS
  outline, AngelScript code presentation, bounded scrolling, and copying
- **AND** update consumer-facing documentation links only after those checks
  pass

### Requirement: Host repository submodule plan

The host repository SHALL retain `Wiki/` as the submodule link to
`TDGameStudio/AngelscriptWiki` and SHALL record a verified Wiki commit whenever
publishing integration changes are accepted.

#### Scenario: Host project records the published Wiki

- **WHEN** the standalone Wiki deployment is verified
- **THEN** `AngelscriptProject/Wiki` points to the verified Wiki source commit
- **AND** host documentation continues to describe submodule initialization
- **AND** unrelated parent-repository changes are not required to build the
  Pages artifact

### Requirement: Planning-only boundary

This change SHALL remain a record-only, deferred change until the maintainer
explicitly asks to resume GitHub Pages implementation after the Wiki is
sufficiently complete.

#### Scenario: Deferred change is recorded

- **WHEN** this OpenSpec record is created
- **THEN** no Wiki source, workflow, package script, generated artifact,
  repository Pages setting, or remote deployment is changed by the record
- **AND** all implementation tasks remain unchecked

#### Scenario: Implementation is resumed

- **WHEN** the maintainer explicitly approves the Wiki for publication work
- **THEN** maintainers re-audit the current workflow, action versions, package
  scripts, repository Pages settings, and public URL before applying the plan
