## Why

The host repository's ignored `Wiki/` workspace was built around MkDocs, while the intended AS Wiki direction is now TiddlyWiki. The first repository snapshot must be reproducible and reviewable, so it should start from a clean `Modern.TiddlyDev` clone rather than including experimental AS/ImGui changes from `Experiment/AngelscriptTiddlyDev`.

## What Changes

- Create the standalone public repository `TDGameStudio/AngelscriptWiki`.
- Seed its initial history exclusively from `git@github.com:tiddly-gittly/Modern.TiddlyDev.git`.
- Replace the ignored host `Wiki/` workspace with a tracked git submodule pointing to `TDGameStudio/AngelscriptWiki`.
- Keep `Experiment/AngelscriptTiddlyDev` and the old MkDocs workspace as backups and explicitly exclude them from the initial seed.
- Update host setup guidance so fresh checkouts initialize the Wiki submodule.
- Defer Angelscript-specific widgets, content, dashboards, and data integration to later changes.

## Capabilities

### New Capabilities

- `wiki-tiddlywiki-workspace`: Defines the clean upstream TiddlyWiki seed and the boundary for later AS Wiki development.

### Modified Capabilities

- `wiki-repository-publishing`: Replaces the previous MkDocs planning-only direction with an active TiddlyWiki repository and host submodule integration.

## Impact

- GitHub: creates `TDGameStudio/AngelscriptWiki` and pushes the upstream seed history.
- Host repository: changes `.gitignore`, `.gitmodules`, `Wiki/`, and setup documentation.
- Local workspace: preserves existing Wiki material under `Experiment/` and leaves the experimental TiddlyWiki checkout untouched.
- Future development: AS-specific features will be added and tested within the Wiki submodule in follow-up changes.
