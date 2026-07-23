## 1. Resume Gate And Deployment Audit

- [ ] 1.1 <!-- Non-TDD --> Record the maintainer's explicit approval to resume
  publication work in
  `openspec/changes/improve-wiki-github-pages-publishing/verification.md`;
  do not begin the remaining tasks before that approval.
- [ ] 1.2 <!-- Non-TDD --> Audit
  `Wiki/.github/workflows/gh-pages.yml`, `Wiki/package.json`,
  `Wiki/pnpm-lock.yaml`, `Wiki/scripts/publish-offline.mjs`, and
  `Wiki/scripts/publish-offline.test.mjs` against the then-current repository
  state.
- [ ] 1.3 <!-- Non-TDD --> Verify the maintained versions and required
  permissions for `actions/checkout`, `actions/setup-node`,
  `pnpm/action-setup`, `actions/upload-pages-artifact`, and
  `actions/deploy-pages` from official GitHub and pnpm documentation; record
  the selected versions and source links in `verification.md`.
- [ ] 1.4 <!-- Non-TDD --> Inspect the `TDGameStudio/AngelscriptWiki`
  repository Pages source, `github-pages` environment, current deployment
  state, and public URL; record the read-only findings in `verification.md`
  before changing external settings.

## 2. Workflow Contract Tests

- [ ] 2.1 <!-- TDD --> Create
  `Wiki/scripts/github-pages-workflow.test.mjs` with failing assertions that
  `.github/workflows/gh-pages.yml` uses `main` plus `workflow_dispatch`, has no
  broad deployable-content `paths-ignore`, uses the `pages` environment and a
  Pages concurrency group, installs with `pnpm install --frozen-lockfile`,
  runs `pnpm run build:wiki` and `pnpm run test:artifact`, uploads
  `dist/`, and grants only the permissions required for Pages.
- [ ] 2.2 <!-- TDD --> Add
  `"test:pages-workflow": "node --test scripts/github-pages-workflow.test.mjs"`
  to `Wiki/package.json`, run `pnpm run test:pages-workflow`, and record the
  expected RED result caused by the current workflow's publishing command,
  trigger filters, environment, or concurrency contract.
- [ ] 2.3 <!-- TDD --> Extend
  `Wiki/scripts/publish-offline.test.mjs` with failing artifact assertions for
  a complete `dist/index.html`, no `dist/library/` metadata, and exclusion
  of draft/temp/template/retired runtime content, and an artifact-size report
  that does not impose a new limit unless GitHub Pages or measured loading
  makes one necessary.

## 3. Production Pages Workflow

- [ ] 3.1 <!-- TDD --> Update
  `Wiki/.github/workflows/gh-pages.yml` to use the audited action versions,
  locked pnpm installation, `main` and `workflow_dispatch` triggers, no broad
  content-skipping path filter, the `pages` environment with deployment URL,
  least-privilege permissions, and a Pages concurrency group.
- [ ] 3.2 <!-- TDD --> Make the workflow run
  `pnpm run check`, `pnpm run lint:all`,
  `pnpm run test:external-plugins`, `pnpm run test:source-boundaries`,
  `pnpm run verify`, `pnpm run build:wiki`, `pnpm run test:artifact`, and
  `pnpm run test:pages-workflow` before uploading `dist/`.
- [ ] 3.3 <!-- TDD --> Run `pnpm run test:pages-workflow` and
  `pnpm run test:artifact`; confirm both workflow and artifact contract
  tests are GREEN.

## 4. Local Publication Verification

- [ ] 4.1 <!-- Non-TDD --> From `Wiki/`, run `pnpm install --frozen-lockfile`,
  `pnpm run check`, `pnpm run lint:all`,
  `pnpm run test:external-plugins`, `pnpm run test:source-boundaries`,
  `pnpm run verify`; record command
  results and test counts in `verification.md`.
- [ ] 4.2 <!-- Non-TDD --> Run `pnpm run build:wiki` followed by
  `pnpm run test:artifact`, confirm that `dist/index.html` is complete,
  and record the HTML and total `dist/` sizes in `verification.md`.
- [ ] 4.3 <!-- TDD --> Add a static-artifact Playwright entry or equivalent
  maintained browser harness under `Wiki/wiki/tiddlers/tests/playwright/`
  that serves `dist/` and verifies initial load, desktop navigation, command
  palette, AS outline, AngelScript highlighting, bounded code scrolling, and
  copying against the generated artifact.
- [ ] 4.4 <!-- Non-TDD --> Run the static-artifact browser suite in Chromium
  and attach its exact command and passing result to `verification.md`.

## 5. Controlled GitHub Pages Deployment

- [ ] 5.1 <!-- Non-TDD --> Commit the verified workflow, tests, and publisher
  changes in the `Wiki` submodule using the repository commit convention.
- [ ] 5.2 <!-- Non-TDD --> Set the `TDGameStudio/AngelscriptWiki` Pages source
  to `GitHub Actions`, then trigger the first production candidate through
  `workflow_dispatch` instead of relying on an incidental push.
- [ ] 5.3 <!-- Non-TDD --> Inspect the Actions run and Pages deployment, record
  the source commit, run URL, deployment URL, artifact size, environment
  status, and any warnings in `verification.md`.
- [ ] 5.4 <!-- Non-TDD --> Open
  `https://tdgamestudio.github.io/AngelscriptWiki/` in Chromium and repeat the
  accepted static-artifact smoke checks against the public URL; do not mark
  deployment complete from the Actions result alone.
- [ ] 5.5 <!-- Non-TDD --> If public verification fails, revert the workflow
  change or redeploy the most recent verified Wiki commit and record the
  rollback result before attempting another production deployment.

## 6. Parent Integration And OpenSpec Closure

- [ ] 6.1 <!-- Non-TDD --> After the public URL passes, update parent
  documentation and consumer-facing Wiki links to
  `https://tdgamestudio.github.io/AngelscriptWiki/` without adding a custom
  domain in this change.
- [ ] 6.2 <!-- Non-TDD --> Update the parent `Wiki` gitlink to the deployed and
  verified Wiki commit, then commit the submodule pointer and this OpenSpec
  record separately from unrelated parent-repository changes.
- [ ] 6.3 <!-- Non-TDD --> Run
  `openspec validate improve-wiki-github-pages-publishing --strict`, verify
  `git diff --check` in both repositories, and confirm every completed task
  has corresponding evidence in `verification.md`.
- [ ] 6.4 <!-- Non-TDD --> After acceptance, archive the completed change with
  `openspec archive "improve-wiki-github-pages-publishing"` and verify the
  merged `wiki-repository-publishing` specification no longer contains MkDocs,
  `mkdocs.yml`, or `site/` publishing assumptions.
