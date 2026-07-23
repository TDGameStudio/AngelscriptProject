## MODIFIED Requirements

### Requirement: Standalone wiki repository plan

The project SHALL use `TDGameStudio/AngelscriptWiki` as the standalone source repository for the integrated TiddlyWiki product.

#### Scenario: Repository identity is reviewed

- **WHEN** maintainers review the Wiki repository
- **THEN** it SHALL identify TiddlyWiki source, product plugins, content, tests, and offline build scripts as the repository deliverable
- **AND** it SHALL not describe plugin packages or MkDocs as the primary product

### Requirement: GitHub Pages publishing plan

GitHub Pages deployment SHALL remain deferred and manual until maintainers explicitly approve publication of the validated offline TiddlyWiki artifact.

#### Scenario: Normal CI runs

- **WHEN** a pull request, main-branch push, or tag is processed before publication approval
- **THEN** CI SHALL verify and build the Wiki product
- **AND** it SHALL not deploy Pages, publish plugin packages, or create plugin releases

### Requirement: Pages URL plan

The project SHALL retain `https://tdgamestudio.github.io/AngelscriptWiki/` as the planned initial Pages URL if publication is later approved.

#### Scenario: Publication is prepared

- **WHEN** maintainers explicitly approve a Pages rollout
- **THEN** the deployment design SHALL publish the validated offline Wiki artifact at the planned URL
- **AND** it SHALL not introduce a separate MkDocs site or plugin-library publication

### Requirement: Host repository submodule plan

The host repository SHALL consume the standalone Wiki repository at `Wiki/` as a git submodule and SHALL update the gitlink only after Wiki changes are committed.

#### Scenario: Host project records a Wiki update

- **WHEN** a Wiki implementation change is ready for host integration
- **THEN** the Wiki repository SHALL be committed first
- **AND** the parent repository SHALL record only the resulting Wiki gitlink and related OpenSpec artifacts without mixing unrelated dirty paths

### Requirement: Planning-only boundary

Publishing records SHALL NOT by themselves create remote repositories, change Pages settings, deploy the Wiki, push branches, or publish plugin packages.

#### Scenario: Architecture hardening is applied

- **WHEN** this architecture change is implemented and verified
- **THEN** local product workflows and records MAY change
- **AND** all external publishing actions SHALL remain deferred pending explicit approval

