## Why

The local `Wiki/` workspace is currently ignored by the host repository, but the project needs a stable path to publish the MkDocs wiki through GitHub Pages and later consume it from `AngelscriptProject` as a submodule.

This change records the repository, publishing, and submodule strategy without creating the GitHub repository or modifying the current `Wiki/` directory.

## What Changes

- Document `TDGameStudio/AngelscriptWiki` as the planned standalone GitHub repository for the MkDocs wiki source.
- Document GitHub Pages publishing through GitHub Actions, using `python -m mkdocs build --strict` and Pages artifacts.
- Document the intended Pages URL shape: `https://tdgamestudio.github.io/AngelscriptWiki/`.
- Document the future host-project submodule shape: `Wiki/` points to `TDGameStudio/AngelscriptWiki`.
- Record migration boundaries: keep this as a planning record only; do not create the remote repository, move files, delete `Wiki/`, or add a submodule in this change.

## Capabilities

### New Capabilities

- `wiki-repository-publishing`: Captures the expected repository layout, GitHub Pages publishing behavior, and future submodule integration for the MkDocs wiki.

### Modified Capabilities

- None.

## Impact

- Future standalone repository: `TDGameStudio/AngelscriptWiki`.
- Current local workspace: `Wiki/` with `mkdocs.yml`, `docs/`, `requirements.txt`, and `README.md`.
- Future host repository metadata: `.gitmodules`, `.gitignore`, `README.md`, `AGENTS.md`, and `AGENTS_ZH.md`.
- Future documentation dependencies: MkDocs, Material for MkDocs, `mkdocs-static-i18n`, and optional draw.io/font assets.
