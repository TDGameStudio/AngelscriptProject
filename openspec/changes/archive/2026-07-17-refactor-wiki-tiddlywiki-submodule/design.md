## Context

The host project currently has an ignored `Wiki/` directory containing a local MkDocs site. A separate `Experiment/AngelscriptTiddlyDev` checkout contains experimental TiddlyWiki and ImGui work, but that checkout is not an acceptable clean starting point for the standalone repository. The user wants the repository established first, with AS-specific migration performed gradually afterward.

## Goals / Non-Goals

**Goals:**

- Create `TDGameStudio/AngelscriptWiki` from the exact upstream `Modern.TiddlyDev` repository.
- Preserve the upstream Git history and use `main` as the published branch.
- Consume the standalone repository at `AngelscriptProject/Wiki` as a git submodule.
- Keep backup and experimental work available without mixing it into the initial remote.

**Non-Goals:**

- Do not upload `Experiment/AngelscriptTiddlyDev` changes.
- Do not migrate Angelscript content, ImGui widgets, dashboards, or data contracts in this change.
- Do not publish GitHub Pages or change the upstream TiddlyWiki framework before the clean seed is verified.
- Do not commit unrelated existing changes in the host repository.

## Decisions

### Use `TDGameStudio`, not `TDStudio`

The authenticated GitHub account can see `TDGameStudio`, and the host repository already uses that organization. `TDStudio` is not an available organization, so the repository will be created as `TDGameStudio/AngelscriptWiki`.

### Preserve upstream history

Clone `git@github.com:tiddly-gittly/Modern.TiddlyDev.git`, change only the destination remote and branch name, and push that history to the new repository. This keeps the first snapshot auditable and avoids copying experimental files through a broad filesystem operation.

### Use `Wiki/` as a real submodule

Move the ignored MkDocs workspace aside after confirming its backup, then run `git submodule add git@github.com:TDGameStudio/AngelscriptWiki.git Wiki`. The parent records the repository through `.gitmodules` and a gitlink rather than treating Wiki as ordinary host files.

### Keep experiments out of the seed

`Experiment/AngelscriptTiddlyDev` remains an independent working copy. Future AS Wiki changes will be applied deliberately inside the `Wiki/` submodule and pushed there as separate commits.

## Risks / Trade-offs

- [Remote naming mistake] → Verify the organization and repository with `gh repo view` before adding the submodule.
- [Experimental content leaks into the seed] → Clone upstream into a separate temporary directory and verify its remote and clean status before pushing.
- [Ignored Wiki backup is lost] → Confirm the existing `Experiment/Wiki备份` and move the current workspace to a uniquely named backup instead of deleting it.
- [Fresh host checkout misses Wiki] → Track `.gitmodules` and document `git submodule update --init --recursive`.
- [Unrelated host changes are staged] → Stage only `.gitmodules`, `.gitignore`, OpenSpec artifacts, and documentation paths belonging to this change.

## Migration Plan

1. Create a clean temporary clone of `Modern.TiddlyDev`.
2. Create `TDGameStudio/AngelscriptWiki`, set the new remote, rename the branch to `main`, and push.
3. Move the ignored current `Wiki/` workspace to a preserved backup path.
4. Add and initialize the new submodule at `Wiki/`.
5. Update host ignore/setup documentation.
6. Verify the standalone checkout, TiddlyWiki commands, submodule gitlink, and remote branch.

Rollback consists of removing only the new `Wiki/` submodule metadata and restoring the preserved ignored workspace; no existing experiment checkout is modified.

## Open Questions

None for this first milestone. AS-specific content and publishing policy will be decided in follow-up changes after the clean seed is in place.
