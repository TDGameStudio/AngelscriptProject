## Why

The standalone Wiki has moved from the historical MkDocs plan to a TiddlyWiki
offline application, but the maintained publishing specification still
describes MkDocs and the existing GitHub Pages workflow has not been accepted
as the production publishing path. Deployment should be finalized only after
the Wiki content, desktop theme, navigation, and AngelScript presentation are
declared ready.

## What Changes

- Replace the obsolete MkDocs publishing contract with a TiddlyWiki offline
  publishing contract for `TDGameStudio/AngelscriptWiki`.
- Treat the existing `.github/workflows/gh-pages.yml` as an implementation to
  audit rather than as proof that production publishing is complete.
- Define readiness gates for enabling the production Pages deployment:
  maintainer approval of the Wiki milestone, repository validation, offline
  artifact validation, and browser smoke coverage.
- Publish the generated `dist/` artifact through GitHub Pages Actions without
  committing generated output to `main` or introducing a `gh-pages` content
  branch.
- Keep this change record-only until the maintainer explicitly resumes it
  after the Wiki is sufficiently complete.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `wiki-repository-publishing`: Replace the retired MkDocs assumptions with
  the standalone TiddlyWiki repository, offline `dist/index.html` artifact,
  GitHub Pages Actions deployment, readiness gates, and published-site
  verification requirements.

## Impact

- Future Wiki implementation:
  `Wiki/.github/workflows/gh-pages.yml`, `Wiki/package.json`,
  `Wiki/scripts/publish-offline.mjs`, and
  `Wiki/scripts/publish-offline.test.mjs`.
- Repository configuration: GitHub Pages source, Actions permissions,
  deployment environment, concurrency, and the canonical Pages URL.
- Documentation and links that identify the public Wiki URL, including the
  parent repository and any future plugin `DocsURL`.
- No Wiki source, workflow, repository setting, generated artifact, or remote
  deployment is changed by recording this OpenSpec change.
