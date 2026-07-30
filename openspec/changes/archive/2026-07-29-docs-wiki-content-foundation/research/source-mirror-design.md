# AngelScript Plugin Source Mirror Design Notes

Captured: 2026-07-25

## Requested use

The Wiki may later retain a synchronized copy of the AngelScript plugin's original source so implementation-principle pages can cite and show the code they explain. The useful product is not merely a copied directory: it is a reproducible source corpus with stable citations, bounded excerpts, license provenance, and update diagnostics.

## Captured local facts

| Fact | Captured value |
|---|---|
| Local plugin path | `Plugins/Angelscript` |
| Local Git remote | `git@github.com:TDGameStudio/UnrealAngelscriptPlugin.git` |
| Canonical browser repository | `https://github.com/TDGameStudio/UnrealAngelscriptPlugin` |
| Local branch | `main` |
| Captured committed revision | `4e2e23ca16ae9f1786258fb96b09b268259b1aad` |
| Top-level license | MIT; copyright Hazelight Games AB and TDGameStudio |
| Embedded AngelScript library | zlib license under `Source/AngelscriptRuntime/ThirdParty/angelscript/` |
| Local worktree state | Dirty; many modified and untracked plugin/test files |

The dirty local worktree is valuable implementation evidence, but it is not a publishable or reproducible snapshot. A corpus update must come from the requested published GitHub commit in an isolated temporary checkout.

The private `Hazelight/UnrealEngine-Angelscript` repository is explicitly outside this corpus. Hazelight comparison pages may retain a restricted evidence key containing repository identity, pinned commit, path, capture date, and purpose, but no private file body, excerpt, generated index, or reader-facing public link is emitted. Adding any Hazelight source snapshot would require separate authorization and license/publication review.

## Preferred storage model

The later implementation plan assigns the following preferred paths. If the Wiki's repository state changes before execution, revise this OpenSpec deliberately rather than silently choosing a different boot/source boundary:

```text
Wiki/
├── source-corpus.json                 # repositories, revision, tree hash, paths, licenses
├── source-corpus/
│   └── angelscript/                   # raw pinned snapshot, never loaded as tiddlers
├── source-references/
│   └── angelscript.json               # stable keys, paths, anchors, ranges, hashes, consumers
├── scripts/
│   ├── sync-source-corpus.mjs         # explicit networked maintainer command
│   ├── index-source-corpus.mjs        # deterministic offline index/excerpt generation
│   └── source-corpus.test.mjs         # manifest/license/reference/boot-boundary tests
└── wiki/tiddlers/generated/source/
    └── ...                            # selected excerpts only, generated and bounded
```

`source-corpus/angelscript/` must not sit beneath `wiki/tiddlers/` or a product plugin source directory. Normal TiddlyWiki loading and `prepare:product-sources` must not traverse it.

## Snapshot manifest

A repository record needs:

- stable repository ID such as `tdgamestudio-unreal-angelscript`;
- canonical HTTPS URL and fetch URL;
- exact 40-hex commit;
- imported tree hash and capture time;
- included and excluded path rules;
- top-level notice paths;
- per-subtree license classifications;
- generated index and registry schema versions;
- update provenance, without machine-specific absolute paths.

The manifest is committed with the snapshot. It must not point only at `main`, a tag, or “latest”.

## Stable source reference

A candidate registry record:

```json
{
  "key": "as-runtime.hot-reload.class-reload-helper",
  "repository": "tdgamestudio-unreal-angelscript",
  "revision": "4e2e23ca16ae9f1786258fb96b09b268259b1aad",
  "path": "Source/AngelscriptEditor/HotReload/ClassReloadHelper.cpp",
  "symbol": "FClassReloadHelper",
  "anchor": "FClassReloadHelper",
  "reviewedRange": { "start": 1, "end": 1 },
  "excerptSha256": "<64-hex digest produced from the reviewed excerpt>",
  "license": "plugin-mit",
  "purpose": "Entry point for the class-reinstancing explanation"
}
```

The concrete path and range above are illustrative data-shape values, not a verified current source location. The implementation batch must derive and test registry entries against its pinned snapshot before accepting them. A registry record should prefer a real symbol or specific textual anchor over a naked line range.

## Page consumption

An implementation-principle document should keep its semantic citation in `as-sources`, for example a stable key that resolves through the registry. A future source component may render:

- repository and commit;
- file and symbol;
- selected excerpt with existing AngelScript/C++ code presentation;
- a commit-pinned GitHub link;
- license/provenance note;
- stale or changed status after synchronization.

The article must remain understandable without opening GitHub and without loading the whole source tree. Generated excerpts are inputs to review, not automatically trusted documentation.

## Update lifecycle

1. Maintainer chooses an exact published commit.
2. The synchronizer uses a temporary checkout and verifies repository identity.
3. It audits notice/license paths and refuses unknown third-party boundaries.
4. It constructs a replacement snapshot without touching the current live corpus.
5. It regenerates the path/symbol index and selected excerpts.
6. It validates keys and lists unchanged, changed, moved-candidate, ambiguous, and missing references.
7. It writes a review report and only then swaps the staged snapshot into place.
8. The maintainer reviews content/license/payload diffs and runs full Wiki verification.
9. Commits and pushes occur only when explicitly requested.

The update process must be transactional: validation failure leaves the prior committed corpus usable.

## Ongoing synchronization model

“Continuously synchronized” means regularly proposed, reviewable snapshot updates, not a floating branch inside published pages.

Preferred operating modes:

1. a maintainer runs the explicit sync command for a reviewed commit; or
2. a later approved scheduled/manual GitHub Actions workflow resolves the newest permitted `main` commit, runs the same synchronizer and verification, and opens or updates a review branch/PR.

Automation must never push directly to the Wiki `main` branch, auto-merge a corpus change, rewrite article revisions, or publish excerpts whose references became stale. The proposed update report must make the old/new commit, tree hash, license delta, raw/generated byte delta, changed keys, and consuming pages visible to reviewers. The committed manifest still contains the resolved immutable commit, even when a scheduled job discovered it from `main`.

## Why alternatives were rejected

| Alternative | Reason not selected as the baseline |
|---|---|
| Link every article to `main` on GitHub | Links and line numbers drift; reviewed explanations lose a reproducible source |
| Copy the current parent plugin directory | It may contain uncommitted work, generated files, or a revision not published to consumers |
| Fetch GitHub during `build:wiki` | Breaks offline/reproducible builds and introduces network/authentication failure into normal verification |
| Convert every source file into a boot tiddler | Inflates startup memory/artifact size and makes source volume part of every reader's initial load |
| Use line numbers as identity | Nearly every source edit invalidates the citation even when the symbol remains |
| Hide third-party boundaries under one MIT label | Incorrectly discards the embedded AngelScript library's zlib notice and may miss other notices |
| Install the source repository as an executable Wiki plugin | The corpus is documentation data, not browser code |

## Measurements required before a full source browser

A later full-browser proposal must measure:

- tracked raw bytes and Git repository growth;
- generated excerpt and index bytes;
- offline HTML size delta;
- boot tiddler count, parse time, and memory;
- first load and source-search latency;
- Chromium and mobile behavior;
- update time and changed-reference count;
- whether lazy chunks remain usable in the offline distribution.

Until those measurements exist, the foundation supports selected excerpts and commit-pinned external links only.
