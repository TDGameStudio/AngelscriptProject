## 1. Record the migration boundary

- [x] 1.1 Record the clean `Modern.TiddlyDev` seed rule and the deferred AS migration scope.
- [x] 1.2 Record the `TDGameStudio/AngelscriptWiki` repository identity and `Wiki/` submodule contract.

## 2. Create the standalone repository

- [x] 2.1 Clone `git@github.com:tiddly-gittly/Modern.TiddlyDev.git` into a temporary seed directory outside `Wiki/`.
- [x] 2.2 Verify the seed checkout is clean and contains only upstream history before publishing.
- [x] 2.3 Create `TDGameStudio/AngelscriptWiki` as a public repository.
- [x] 2.4 Set the seed remote to `git@github.com:TDGameStudio/AngelscriptWiki.git`, rename the branch to `main`, and push.

## 3. Replace the host Wiki path

- [x] 3.1 Confirm the existing MkDocs workspace is preserved under `Experiment/`.
- [x] 3.2 Move the current ignored `Wiki/` workspace aside without deleting it.
- [x] 3.3 Add `git@github.com:TDGameStudio/AngelscriptWiki.git` as the host `Wiki/` submodule.
- [x] 3.4 Remove the host `/Wiki/` ignore rule while preserving `/Experiment/` isolation.

## 4. Document and verify

- [x] 4.1 Document submodule initialization and the deferred AS Wiki migration boundary.
- [x] 4.2 Verify the Wiki submodule points to the pushed `main` commit.
- [x] 4.3 Run the upstream-supported type-check and Playwright commands from `Wiki/`.
- [x] 4.4 Run `git diff --check` and inspect parent/submodule status without staging unrelated user changes.
