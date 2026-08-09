# Refactor Wiki TiddlyWiki Submodule Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `TDGameStudio/AngelscriptWiki` from a clean `Modern.TiddlyDev` clone and consume it from the host repository at `Wiki/` as a git submodule.

**Architecture:** Preserve the upstream TiddlyWiki development history as the first commit lineage, then add the new repository as a host submodule. Keep `Experiment/AngelscriptTiddlyDev` and the existing MkDocs backup outside the new repository; future AS Wiki features will be added in later changes.

**Tech Stack:** Git, GitHub CLI, TiddlyWiki 5, `tiddlywiki-plugin-dev`, TypeScript, Playwright, PowerShell.

## Global Constraints

- Use `TDGameStudio/AngelscriptWiki`; `TDStudio` is not an available organization.
- Seed only from `git@github.com:tiddly-gittly/Modern.TiddlyDev.git`.
- Do not copy `Experiment/AngelscriptTiddlyDev` changes into the first remote snapshot.
- Preserve the current host checkout and unrelated user changes.
- The host path must be a tracked git submodule at `Wiki/`.

---

### Task 1: Record the repository boundary

**Files:**
- Create: `openspec/changes/refactor-wiki-tiddlywiki-submodule/proposal.md`
- Create: `openspec/changes/refactor-wiki-tiddlywiki-submodule/design.md`
- Create: `openspec/changes/refactor-wiki-tiddlywiki-submodule/specs/wiki-tiddlywiki-workspace/spec.md`
- Create: `openspec/changes/refactor-wiki-tiddlywiki-submodule/specs/wiki-repository-publishing/spec.md`
- Create: `openspec/changes/refactor-wiki-tiddlywiki-submodule/tasks.md`

- [x] Write the motivation, clean-seed rule, submodule boundary, and deferred AS migration scope.
- [x] Record that the old MkDocs workspace and experimental TiddlyWiki checkout remain backups, not seed inputs.
- [x] Mark the OpenSpec tasks complete only after each remote and host verification command passes.

### Task 2: Create a clean upstream seed

**Files:**
- Create: `D:/Workspace/Temp/AngelscriptWikiSeed/` as a temporary clone only.

- [x] Run `git clone git@github.com:tiddly-gittly/Modern.TiddlyDev.git D:/Workspace/Temp/AngelscriptWikiSeed`.
- [x] Verify the seed has no uncommitted changes with `git -C D:/Workspace/Temp/AngelscriptWikiSeed status --short`.
- [x] Verify the seed source is not `Experiment/AngelscriptTiddlyDev` by checking its remote and HEAD history.

### Task 3: Create and publish the standalone repository

**Files:**
- Create remotely: `TDGameStudio/AngelscriptWiki`.
- Modify locally: `D:/Workspace/Temp/AngelscriptWikiSeed/.git/config` and branch metadata.

- [x] Create the public GitHub repository with `gh repo create TDGameStudio/AngelscriptWiki --public`.
- [x] Set the seed remote to `git@github.com:TDGameStudio/AngelscriptWiki.git`.
- [x] Rename the seed branch to `main` and push it with `git push -u origin main`.
- [x] Verify `gh repo view TDGameStudio/AngelscriptWiki` resolves to the new repository and `main` exists.

### Task 4: Replace the host Wiki path with a submodule

**Files:**
- Move: current ignored `Wiki/` workspace to a preserved backup location under `Experiment/`.
- Create: `.gitmodules` entry for `Wiki`.
- Create: `Wiki/` submodule checkout.
- Modify: `.gitignore` to stop ignoring the tracked submodule path.

- [x] Confirm the current `Wiki/` backup remains available before moving the ignored workspace.
- [x] Run `git submodule add git@github.com:TDGameStudio/AngelscriptWiki.git Wiki`.
- [x] Verify `git submodule status` reports the pushed `main` commit.
- [x] Verify `Wiki/package.json` and `Wiki/wiki/tiddlywiki.info` come from the clean upstream seed.

### Task 5: Update host documentation and setup guidance

**Files:**
- Modify: `README.md` with Wiki submodule initialization guidance if the existing setup section is the appropriate host entry point.
- Modify: `AGENTS.md` and `AGENTS_ZH.md` where they describe Wiki ownership or setup.
- Modify: `Documents/Guides/SubmoduleWorktreeWorkflow.md` if the new `Wiki/` submodule needs to be listed.
- Modify: `openspec/specs/wiki-repository-publishing/spec.md` through the archived change only after the new behavior is implemented and verified.

- [x] Document `git submodule update --init --recursive` for a fresh host checkout.
- [x] State that AS feature migration happens inside `Wiki/` in later changes and is not part of the clean seed.
- [x] Keep MkDocs/old TiddlyWiki backups outside the submodule source of truth.

### Task 6: Verify the first migration milestone

**Files:**
- Verify: `D:/Workspace/Temp/AngelscriptWikiSeed/`.
- Verify: `Wiki/`.
- Verify: `.gitmodules`, `.gitignore`, and parent Git status.

- [x] Run `git -C Wiki status --short` and confirm the seed checkout is clean.
- [x] Run `npm run check` or the upstream-supported type-check command from `Wiki/`.
- [x] Run `npm run test:playwright` from `Wiki/` after starting the upstream dev server.
- [x] Run `git diff --check` in the host and standalone repositories.
