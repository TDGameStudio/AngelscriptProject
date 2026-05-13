## 1. Standalone Repository

- [ ] 1.1 Create the GitHub repository `TDGameStudio/AngelscriptWiki` as a normal repository, not a GitHub built-in wiki.
- [ ] 1.2 Import the current `Wiki/` source snapshot into a separate local clone, excluding `site/`, serve logs, virtual environments, and caches.
- [ ] 1.3 Add a wiki-repository `.gitignore` that excludes generated output and local environment artifacts.

## 2. GitHub Pages Publishing

- [ ] 2.1 Update `mkdocs.yml` in the standalone wiki repository so `site_url` is `https://tdgamestudio.github.io/AngelscriptWiki/`.
- [ ] 2.2 Add `.github/workflows/pages.yml` that installs `requirements.txt`, runs `python -m mkdocs build --strict`, uploads `site/`, and deploys with GitHub Pages Actions.
- [ ] 2.3 Enable repository Pages publishing with `Source: GitHub Actions` and verify the Pages deployment succeeds.

## 3. Host Repository Submodule

- [ ] 3.1 After Pages deployment is verified, move the current ignored host `Wiki/` workspace aside before replacing it.
- [ ] 3.2 Remove or adjust the host repository `/Wiki/` ignore rule so the submodule path can be tracked.
- [ ] 3.3 Add `git@github.com:TDGameStudio/AngelscriptWiki.git` as the host repository `Wiki/` submodule.
- [ ] 3.4 Update host repository setup documentation to mention `git submodule update --init --recursive`.

## 4. Follow-Up Decisions

- [ ] 4.1 Decide whether `mkdocs-drawio` is included before the first wiki repository import or added in a later documentation enhancement.
- [ ] 4.2 Decide whether the wiki uses system font stacks first or self-hosts Chinese/code fonts under `docs/assets/`.
- [ ] 4.3 Decide whether to keep the project Pages URL or add a custom domain later.
