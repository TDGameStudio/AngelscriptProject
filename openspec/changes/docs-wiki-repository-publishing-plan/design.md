## Context

`Wiki/` is currently a local MkDocs Material workspace ignored by the host repository. It contains the source for a bilingual documentation site (`mkdocs.yml`, `docs/`, `requirements.txt`, `README.md`) and generated/local artifacts (`site/`, serve logs).

The intended long-term shape is a standalone GitHub repository named `TDGameStudio/AngelscriptWiki`, with `AngelscriptProject` consuming it at `Wiki/` as a git submodule. The wiki source should publish to GitHub Pages, while generated site output stays out of source control.

## Goals / Non-Goals

**Goals:**

- Establish `TDGameStudio/AngelscriptWiki` as the planned ordinary GitHub repository for wiki source.
- Publish the MkDocs site through GitHub Pages at `https://tdgamestudio.github.io/AngelscriptWiki/`.
- Use GitHub Actions as the publishing mechanism, with `python -m mkdocs build --strict` as the build gate.
- Keep `site/`, serve logs, virtual environments, and caches out of the wiki source repository.
- Later replace the host repository's ignored `Wiki/` workspace with a submodule pointing at `TDGameStudio/AngelscriptWiki`.

**Non-Goals:**

- Do not create the GitHub repository in this planning change.
- Do not move, delete, or rewrite the current `Wiki/` directory in this planning change.
- Do not add the submodule in this planning change.
- Do not use GitHub's built-in `.wiki.git` repository as the primary documentation source.
- Do not require a custom domain for the initial publishing path.

## Decisions

### Use `TDGameStudio/AngelscriptWiki` instead of a GitHub built-in wiki

The current documentation site depends on MkDocs, Material for MkDocs, navigation configuration, static i18n, custom CSS, and future optional assets such as draw.io diagrams or fonts. A normal repository preserves that structure and can be validated by CI before publishing.

Alternative considered: GitHub built-in Wiki. It is simpler for basic Markdown pages, but does not naturally preserve the current MkDocs build, theme, bilingual routing, or plugin pipeline.

### Use GitHub Actions Pages deployment instead of `mkdocs gh-deploy`

The planned workflow builds the site from `main`, uploads the generated `site/` directory as a Pages artifact, and deploys it using GitHub Pages Actions. This keeps generated output out of git history and makes the build gate explicit.

Alternative considered: `mkdocs gh-deploy` to a `gh-pages` branch. It is convenient locally, but it stores generated output in a branch and makes the publishing source less explicit.

### Use project Pages URL first

The planned initial URL is:

```text
https://tdgamestudio.github.io/AngelscriptWiki/
```

This allows `TDGameStudio/AngelscriptWiki` to remain a normal project repository. The organization root URL `https://tdgamestudio.github.io/` would require a repository named `tdgamestudio.github.io`, which is not the preferred shape for a plugin-specific documentation site.

### Keep `Wiki/` as submodule path in the host project

After `TDGameStudio/AngelscriptWiki` exists and the site publishes successfully, the host repository should replace the ignored local `Wiki/` directory with a submodule:

```powershell
git submodule add git@github.com:TDGameStudio/AngelscriptWiki.git Wiki
```

The host repository must remove or adjust the existing `/Wiki/` ignore rule before committing the submodule path.

### Keep generated output excluded

The standalone wiki repository should track source files only:

```text
docs/
mkdocs.yml
requirements.txt
README.md
.github/workflows/pages.yml
.gitignore
```

It should exclude:

```text
/site/
mkdocs-serve*.log
.venv/
__pycache__/
.cache/
```

## Risks / Trade-offs

- GitHub Pages URL drift -> Update `site_url`, plugin metadata, README links, and future `.uplugin` `DocsURL` together when the final URL changes.
- Submodule workflow complexity -> Document `git submodule update --init --recursive` in the host README and agent guides before requiring the submodule for normal setup.
- Generated output accidentally committed -> Add wiki repository `.gitignore` before the first import commit and validate that `site/` is absent from `git status`.
- MkDocs dependency drift -> Pin wiki dependencies in `requirements.txt` and validate with `python -m mkdocs build --strict` in CI.
- Draw.io or font assets add extra dependencies -> Prefer static assets under `docs/assets/`; if `mkdocs-drawio` is added later, include it in `requirements.txt` and keep the Pages build strict.

## Migration Plan

1. Create the GitHub repository `TDGameStudio/AngelscriptWiki`.
2. Copy the current `Wiki/` source snapshot into a separate local clone, excluding `site/`, serve logs, virtual environments, and caches.
3. Add `.gitignore` and `.github/workflows/pages.yml`.
4. Update `mkdocs.yml` `site_url` to `https://tdgamestudio.github.io/AngelscriptWiki/`.
5. Run `python -m pip install -r requirements.txt` and `python -m mkdocs build --strict`.
6. Commit and push the standalone wiki source to `main`.
7. Enable GitHub Pages with `Source: GitHub Actions`.
8. Confirm the Pages deployment succeeds.
9. In `AngelscriptProject`, move the old ignored `Wiki/` workspace aside, remove the `/Wiki/` ignore rule, add the submodule at `Wiki/`, and update host documentation.

## Open Questions

- Should the wiki initially include `mkdocs-drawio`, or should draw.io support be added in a follow-up change after the repository is published?
- Should fonts be system-font based at first, or should the wiki self-host a Chinese web font set?
- Should the final documentation URL remain `AngelscriptWiki`, or should a custom domain be introduced later?
