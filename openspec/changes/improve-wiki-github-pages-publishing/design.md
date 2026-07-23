## Context

`TDGameStudio/AngelscriptWiki` is already a standalone TiddlyWiki repository
and is consumed by `AngelscriptProject` through the `Wiki/` submodule. The Wiki
currently contains:

- `.github/workflows/gh-pages.yml`, which installs dependencies, runs
  `pnpm run publish`, uploads `dist/`, and invokes GitHub Pages Actions;
- `scripts/publish-offline.mjs`, which produces `dist/index.html` by compiling
  the maintained local and vendored product sources directly into the Wiki;
- `scripts/publish-offline.test.mjs`, which verifies that the offline document
  is complete and contains the selected runtime plugins; and
- `package.json` entries for `build:wiki`, `test:artifact`, and `verify`.

The existing workflow predates acceptance of the current Wiki presentation and
does not by itself establish that the artifact, trigger policy, repository
Pages settings, or deployed site are production-ready. The parent OpenSpec
still describes the retired MkDocs layout, `mkdocs.yml`, and `site/` output.

This is a deferred, record-only change. Implementation starts only after the
maintainer explicitly declares the Wiki milestone ready.

## Goals / Non-Goals

**Goals:**

- Define the production publishing contract for the TiddlyWiki repository.
- Make the offline artifact reproducible from the lockfile and local repository
  sources.
- Deploy `dist/` through GitHub Pages Actions without generated files in git.
- Require local artifact and deployed-site verification before accepting the
  Pages URL.
- Keep the parent repository's public Wiki references synchronized with the
  accepted Pages URL.

**Non-Goals:**

- Do not modify or disable the current workflow in this record-only session.
- Do not change GitHub repository Pages settings in this session.
- Do not deploy the current in-progress Wiki as an accepted production site.
- Do not introduce a custom domain, service worker, analytics, authentication,
  or a separate `gh-pages` content branch.
- Do not redesign Wiki content, navigation, code presentation, or mobile
  behavior as part of deployment.

## Decisions

### 1. Resume only after an explicit Wiki readiness decision

The change remains pending until the maintainer explicitly confirms that the
Wiki content and desktop experience are ready for publication. At resumption,
the implementation must re-audit the repository instead of assuming that the
workflow and package scripts still match this record.

Alternative considered: deploy every intermediate theme revision. This gives
early hosting feedback but turns an unfinished presentation into the public
documentation endpoint and makes deployment failures harder to distinguish
from content work.

### 2. Publish the dedicated offline artifact

The production build entry point will be `pnpm run build:wiki`, followed
by `pnpm run test:artifact`. The deployable root is `dist/`, with
`dist/index.html` as the required entry document. The integrated Wiki build
must not retain `dist/library/` or standalone plugin package JSON files.

The workflow must install the package manager version declared by
`packageManager` and use the committed `pnpm-lock.yaml` without updating it.
The publisher must continue using only checked-in sources under `src/`,
`vendor/`, and the generated local bridge; it must not fetch reference
repositories during the Actions run.

Alternative considered: retain `pnpm run publish` as the site build. That
command belonged to the plugin-dev publishing entry point and does not
express the offline Wiki contract as clearly as the dedicated, tested
publisher.

### 3. Use GitHub Pages artifacts, not a generated branch

The workflow will upload `dist/` with the maintained Pages artifact action and
deploy it with the maintained Pages deployment action. GitHub Pages will use
`Source: GitHub Actions`. Generated HTML and plugin-library files remain
ignored by git.

Alternative considered: commit generated output to `gh-pages`. That creates a
second history containing derived files, complicates review, and weakens the
connection between a source commit and its validated artifact.

### 4. Use a controlled production workflow

The accepted workflow will:

- run for `main` after readiness is approved and support
  `workflow_dispatch` for the first controlled deployment;
- use the `pages` environment and expose the deployment URL from the deploy
  step;
- grant only the permissions needed by checkout and Pages deployment;
- use a Pages concurrency group so a newer main deployment supersedes an
  obsolete queued deployment without interrupting an active publication; and
- avoid path filters that can silently skip deployable TiddlyWiki content.

Exact action versions must be rechecked against official GitHub documentation
when implementation resumes rather than frozen to the versions present when
this record was created.

### 5. Validate both the artifact and the public result

Before deployment, CI must run the maintained type check, complete lint,
external-source boundary tests, build, Wiki tests, Playwright suite, and
offline-publish test. The artifact gate must confirm a complete non-empty
`dist/index.html`, the expected selected plugins, and the absence of retired or
template plugins.

After the first deployment, a browser smoke check must open
`https://tdgamestudio.github.io/AngelscriptWiki/` and verify initial load,
desktop navigation, command palette, AS outline, AngelScript highlighting,
bounded code scrolling, and copying. The final check must use the public URL,
not only a local server.

### 6. Keep publication identity centralized

The initial canonical URL is
`https://tdgamestudio.github.io/AngelscriptWiki/`. After it is verified, parent
repository documentation and future consumer-facing documentation links must
use that URL. A custom domain is outside this change and can be proposed
separately.

## Risks / Trade-offs

- **Existing workflow may produce a different artifact than the dedicated
  offline publisher** → Replace the build step only after reproducing and
  testing `dist/index.html` locally and in CI.
- **Action or runner versions may drift before implementation resumes** →
  Recheck maintained GitHub Actions and supported Node/pnpm versions at
  implementation time.
- **A single-file TiddlyWiki can become large** → Record artifact size during
  verification and treat optimization as a separate change unless it blocks
  Pages limits or acceptable initial load.
- **A successful Actions job can still deploy a broken interactive Wiki** →
  Require public-URL Playwright or equivalent browser smoke verification.
- **Push filters can omit content-only changes** → Do not retain broad
  `paths-ignore` rules for deployable Wiki source.
- **Pages settings are external state** → Record the confirmed source,
  environment URL, deployment run, and rollback procedure in verification
  notes when the change is implemented.

## Migration Plan

1. Wait for explicit maintainer approval that the Wiki milestone is ready.
2. Re-audit the workflow, package scripts, lockfile, current action versions,
   Pages repository settings, and current public URL state.
3. Run the complete local Wiki validation baseline and the offline publisher.
4. Add or update workflow-contract tests before changing workflow behavior.
5. Update the workflow to build and validate the offline artifact with locked
   dependencies and controlled Pages permissions/concurrency.
6. Push the implementation and perform the first deployment through
   `workflow_dispatch`.
7. Verify the public Pages URL in Chromium, then enable/accept automatic
   deployment from `main`.
8. Update public documentation links only after the deployed URL is verified.

Rollback consists of reverting the workflow change and redeploying the most
recent verified source commit. If the Pages endpoint itself must be withdrawn,
disable the Pages source in repository settings; generated output does not
need to be removed from git because it is never committed.

## Open Questions

None are blocking the record. Action versions, artifact size, and the current
Pages repository setting are intentionally re-audited when implementation
resumes because they are time-sensitive external state.
