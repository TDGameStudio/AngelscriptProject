# Implementation Plan: Remove the Wiki Source Corpus

## Execution Boundary

This document is the ready-to-run plan for a later apply session. Creating this OpenSpec does not authorize product deletion or history mutation in the current session.

The later apply session ends after local cleanup, local unpublished-history rewrite, and verification. It does not push either repository, delete backup refs, expire reflogs, run garbage collection, archive the OpenSpec, or commit unrelated working-tree changes.

## Completion Criteria

The change is complete locally only when all of the following are true:

1. The public plugin snapshot, its manifest/reports, public corpus registry, scripts, commands, generated tiddlers, and corpus-specific tests are absent from the Wiki candidate tree.
2. The three consuming documents contain neither an `as-source.*` field value nor a generated-source transclusion and remain navigable in the browser suite.
3. Generic source metadata, broad source keys, `source-references/hazelight-restricted.json`, and the private-source restrictions remain.
4. Focused document, browser, offline-build, publication, lint, and type checks pass.
5. No removed path or corpus object is reachable from the rewritten Wiki unpublished range.
6. No parent unpublished commit references an obsolete Wiki commit from the rewritten range.
7. Unrelated dirty and staged work is preserved.
8. Dated backup refs remain available in both repositories.

## Planning Baseline

The following values must be re-measured at apply time:

| Item | Planning value |
| --- | --- |
| Snapshot revision | `4e2e23ca16ae9f1786258fb96b09b268259b1aad` |
| Snapshot size | 1,158 files / 17,692,585 bytes |
| Snapshot test subtree | 645 files / 10,646,075 bytes |
| Local plugin tip | `dc99986febf1f0911a3ebfdc6d987cc3c0594907` |
| Wiki public base | `48b181fe5220db2571971e5c36a1d400d1959e22` |
| Wiki local tip | `151d015324a94119b2539d88c406f6a2e2c8bde1` |
| Wiki unpublished count | 29 |
| Parent public base | `f84f9bbf9167bbdde727fdce60382b0f034c014a` |
| Parent local tip | `c6d09135f7ffbf73f5763e7320ac2a1c5f5ec552` |
| Parent unpublished count | 47 |
| Corpus introducer | Wiki tip `151d015324a94119b2539d88c406f6a2e2c8bde1` |
| Extra history tool | `git-filter-repo` absent and not required |

## Exact File Map

### Delete from `Wiki/`

- `source-corpus/angelscript/`
- `source-corpus.json`
- `source-corpus-sync-report.json`
- `source-corpus-sync-report.md`
- `source-references/angelscript.json`
- `scripts/source-corpus.mjs`
- `scripts/source-corpus.test.mjs`
- `scripts/sync-source-corpus.mjs`
- `scripts/generate-source-excerpts.mjs`
- `wiki/tiddlers/generated/source/as-source-runtime-class-reload-planner.tid`
- `wiki/tiddlers/generated/source/as-source-runtime-preprocessor.tid`
- `wiki/tiddlers/generated/source/as-source-uht-binding-policy.tid`

If `wiki/tiddlers/generated/source/` becomes empty, remove the empty directory from the worktree. Git records no standalone directory entry.

### Modify in `Wiki/`

- `Agents_ZH.md`: remove public corpus layout, synchronization, report, registry, and generation instructions first; retain and reword the private Hazelight restriction so it no longer depends on `source-references/` as a public corpus concept.
- `Agents.md`: mirror the reviewed Chinese contributor-guidance change.
- `package.json`: remove `sync:source-corpus`, `generate:source-excerpts`, `pretest:source-corpus`, and `test:source-corpus`; remove `test:source-corpus` from `test:contracts`.
- `scripts/test-execution-commands.test.mjs`: update the expected `test:contracts` command graph.
- `scripts/document-content-contract.test.mjs`: remove the public corpus-registry/generated-excerpt contract while keeping generic `as-sources`, source registry, and document integrity coverage.
- `scripts/publish-offline.test.mjs`: remove expectations for the three generated tiddlers; retain or replace the negative assertion proving raw `source-corpus/` content is absent from the artifact if the assertion remains meaningful without a source directory.
- `wiki/tiddlers/docs/data/SourceRegistry.tid`: remove only the three `as-source.*` entries.
- `wiki/tiddlers/docs/zh-Hans/hot-reload/reload-pipeline-internals.tid`: remove `as-source.runtime-class-reload-planner` and its complete “固定源码证据” block.
- `wiki/tiddlers/docs/zh-Hans/unreal-language/feature-implementation-principles.tid`: remove `as-source.runtime-preprocessor` and its complete “固定源码证据” block.
- `wiki/tiddlers/docs/zh-Hans/bindings-uht-extensions/uht-plugin-internals.tid`: remove `as-source.uht-binding-policy` and its complete “固定源码证据” block.

### Explicitly retain

- `source-references/hazelight-restricted.json`
- `wiki/tiddlers/docs/data/SourceRegistry.tid` as a generic registry
- the `as-sources` field and all non-`as-source.*` values
- broad entries such as `angelscript-plugin`, `project-guide`, `project-knowledge-zh`, `script-examples`, and `openspec`
- Hazelight public-document crosswalks and comparison catalogs
- all article prose outside the three generated-evidence blocks

### Reusable cleanup pathspec

Create this array in any PowerShell session that performs a path-scoped status, diff, commit, or index-alignment operation:

```powershell
$cleanupPathspecs = @(
  'source-corpus'
  'source-corpus.json'
  'source-corpus-sync-report.json'
  'source-corpus-sync-report.md'
  'source-references/angelscript.json'
  'scripts/source-corpus.mjs'
  'scripts/source-corpus.test.mjs'
  'scripts/sync-source-corpus.mjs'
  'scripts/generate-source-excerpts.mjs'
  'scripts/test-execution-commands.test.mjs'
  'scripts/document-content-contract.test.mjs'
  'scripts/publish-offline.test.mjs'
  'package.json'
  'Agents_ZH.md'
  'Agents.md'
  'wiki/tiddlers/generated/source/as-source-runtime-class-reload-planner.tid'
  'wiki/tiddlers/generated/source/as-source-runtime-preprocessor.tid'
  'wiki/tiddlers/generated/source/as-source-uht-binding-policy.tid'
  'wiki/tiddlers/docs/data/SourceRegistry.tid'
  'wiki/tiddlers/docs/zh-Hans/hot-reload/reload-pipeline-internals.tid'
  'wiki/tiddlers/docs/zh-Hans/unreal-language/feature-implementation-principles.tid'
  'wiki/tiddlers/docs/zh-Hans/bindings-uht-extensions/uht-plugin-internals.tid'
)
```

## Phase 1: Preflight and Safety Gates

1. From the root repository, capture full `git status --short`, `git diff --cached --name-status`, current branches, worktrees, submodule status, remotes, and exact root/Wiki/plugin commits.
2. Fetch `main` from the actual root and Wiki public remotes without changing local branches.
3. Resolve and record:
   - `rootBase = root origin/main`
   - `rootTip = root main`
   - `wikiBase = Wiki origin/main`
   - `wikiTip = Wiki main`
   - every Wiki commit that first adds any path in the deletion map
   - every Wiki gitlink value in each parent commit from `rootBase..rootTip`
4. Prove that the corpus introducer and every rewritten Wiki commit are not ancestors of refreshed Wiki `origin/main`. If any is public, stop; do not force-push and do not continue under this design.
5. Prove that both unpublished ranges are linear with:

   ```powershell
   git rev-list --merges origin/main..main
   git -C Wiki rev-list --merges origin/main..main
   ```

   Any output is a stop condition until the replay procedure is updated to preserve merge topology.
6. Check staged and unstaged state for every file-map path. Any pre-existing target-path change is an overlap and requires user direction. A dirty submodule marker caused solely by unrelated files is not an overlap.
7. Confirm that no normal Wiki command outside the listed corpus subsystem dynamically constructs a corpus command or generated tiddler title:

   ```powershell
   rg -n --hidden --glob '!node_modules/**' --glob '!source-corpus/**' --glob '!vendor/**' 'sync:source-corpus|generate:source-excerpts|test:source-corpus|source-corpus|Generated/Source|as-source\.' Wiki
   ```

8. Create dated backup refs with the exact old tips, for example:

   ```powershell
   $rewriteStamp = Get-Date -Format 'yyyyMMdd-HHmmss'
   $rootTip = (git rev-parse refs/heads/main).Trim()
   $wikiTip = (git -C Wiki rev-parse refs/heads/main).Trim()
   git update-ref "refs/backup/refactor-wiki-source-corpus-removal/parent-main-$rewriteStamp" $rootTip
   git -C Wiki update-ref "refs/backup/refactor-wiki-source-corpus-removal/wiki-main-$rewriteStamp" $wikiTip
   ```

9. Record the backup-ref names, public bases, old tips, introducer, and old parent gitlinks in a change-local apply log before mutating files.

## Phase 2: Apply the Wiki Tree Cleanup

1. Update `Wiki/Agents_ZH.md`, then mirror the decision in `Wiki/Agents.md`.
2. Remove the exact corpus, manifest, report, public registry, script, test, and generated-tiddler paths.
3. Update `package.json` and the command-graph test so normal contract testing no longer invokes the removed suite.
4. Remove corpus-specific assertions from the document and publication tests; do not weaken unrelated source-boundary or offline-publication assertions.
5. Remove the three keys from `SourceRegistry.tid`.
6. In each consumer, remove the one `as-source.*` token and the whole generated evidence heading/explanatory text/transclusion block. Do not insert a replacement source URL, excerpt, or citation field.
7. Run `git -C Wiki diff --check` and review `git -C Wiki diff -- $cleanupPathspecs`. Confirm no article paragraph outside the intended blocks changed.

## Phase 3: Verify the Wiki Candidate Before History Rewrite

Run from `Wiki/` unless the command says otherwise.

### Residual-path and reference scans

```powershell
git ls-files | rg '^(source-corpus/|source-corpus\.json$|source-corpus-sync-report\.(json|md)$|source-references/angelscript\.json$|scripts/(source-corpus(\.test)?|sync-source-corpus|generate-source-excerpts)\.mjs$|wiki/tiddlers/generated/source/)'
rg -n --hidden --glob '!node_modules/**' --glob '!vendor/**' 'sync:source-corpus|generate:source-excerpts|test:source-corpus|\$:/ASWiki/Generated/Source/as-source\.|as-source\.(runtime-class-reload-planner|runtime-preprocessor|uht-binding-policy)'
```

Both commands must return no matches after accounting for documentation that deliberately describes the removal outside the Wiki repository.

Confirm retained metadata:

```powershell
Test-Path -LiteralPath 'source-references/hazelight-restricted.json'
rg -n 'angelscript-plugin|project-guide|project-knowledge-zh|script-examples|openspec' wiki/tiddlers/docs/data/SourceRegistry.tid
```

### Focused contract tests

```powershell
node --test scripts/document-content-contract.test.mjs scripts/test-execution-commands.test.mjs
```

### Browser behavior

```powershell
node scripts/run-product-tests.mjs feature document
```

This must cover navigation/rendering of the three edited document pages without missing generated tiddlers.

### Offline artifact

```powershell
node scripts/build-offline-wiki.mjs
node --test scripts/publish-offline.test.mjs
```

Inspect the built artifact title inventory and prove it contains neither `$:/ASWiki/Generated/Source/as-source.*` nor any raw `source-corpus/` title.

### Static checks

Run the repository's existing scoped ESLint command for the modified `.mjs` files and its existing TypeScript `--noEmit` command. Do not add dependencies, a replacement unit-test suite, or a corpus-specific test harness.

## Phase 4: Rewrite the Wiki Unpublished Range

### Preferred baseline path: introducer is still the Wiki tip

1. Reconfirm the current Wiki `HEAD` equals the recorded `wikiTip`, the introducer is `HEAD`, the range is unpublished, and target paths have no user overlap.
2. Amend only exact cleanup paths. Use a path-scoped commit operation that ignores unrelated staged entries; do not use `git add -A`, `git commit -a`, or a broad staging command.
3. Preserve the original commit message and author. Record `oldWikiTip -> newWikiTip`.
4. Confirm unrelated staged and unstaged entries remain present.

The intended Git shape is a path-scoped equivalent of:

```powershell
git -C Wiki commit --amend --no-edit --only -- $cleanupPathspecs
```

Before execution, validate the final pathspec list with `git -C Wiki status --short -- $cleanupPathspecs`. If the local Git version cannot safely express the directory deletions with `--only`, use the alternate replay path instead of broad staging.

### Alternate path: the introducer is no longer the tip

1. Create an isolated temporary clone from the local Wiki repository. Do not use a worktree.
2. Detach at the refreshed `wikiBase`.
3. Replay `wikiBase..wikiTip` in original order with standard `git cherry-pick --no-commit` plus `git commit -C $oldCommit`, preserving empty commits when needed.
4. At the first commit that introduces the corpus subsystem, apply the exact tree cleanup before recreating that commit.
5. Resolve later commits so they do not restore deleted paths or generated references.
6. Record an old-to-new commit map for every replayed Wiki commit; this map drives parent gitlink replacement.
7. Verify the temporary candidate completely before fetching it into a local candidate ref.
8. Resolve the verified candidate into `$newWikiTip`, update real Wiki `main` with `git -C Wiki update-ref refs/heads/main $newWikiTip $wikiTip`, then align only `$cleanupPathspecs` to the new `HEAD`. Do not reset or checkout unrelated paths.

### Wiki history audit

Against the candidate, run:

```powershell
git -C Wiki rev-list --objects origin/main..main
git -C Wiki log --all -- source-corpus source-corpus.json source-corpus-sync-report.json source-corpus-sync-report.md source-references/angelscript.json scripts/source-corpus.mjs scripts/source-corpus.test.mjs scripts/sync-source-corpus.mjs scripts/generate-source-excerpts.mjs wiki/tiddlers/generated/source
```

The first command must contain none of the removed paths. The second may show the dated backup ref, but no commit reachable from candidate `main` may contain a removed path. Keep the backup ref; its reachability is intentional until later cleanup approval.

Compare old and new unpublished sequences:

- same number and order of logical commits, except an intentionally amended introducer;
- same subjects and authors;
- no non-target tree difference caused by the rewrite; and
- all candidate generated/document tests still pass.

## Phase 5: Rewrite the Parent Unpublished Range

1. Reconfirm `rootBase`, `rootTip`, linear topology, unchanged refreshed public base, and no staged parent gitlink change at `Wiki`.
2. Create an isolated temporary clone from the local parent repository and detach at `rootBase`.
3. Replay `rootBase..rootTip` in original order. For each commit:
   - apply it without committing;
   - inspect the staged `Wiki` gitlink;
   - if the gitlink equals an old Wiki commit in the rewrite map, replace it with the mapped new commit using an index-only `160000` entry;
   - recreate the commit with its original author and message; and
   - preserve intentionally empty commits.
4. Reject any Wiki gitlink into the old rewritten range for which no mapping exists.
5. Save the result under a local parent candidate ref and verify it before moving real `main`.
6. Fetch the candidate ref back into the real parent repository, then use:

   ```powershell
   $newRootTip = (git rev-parse refs/candidates/refactor-wiki-source-corpus-removal/parent-main).Trim()
   git update-ref refs/heads/main $newRootTip $rootTip
   git reset HEAD -- Wiki
   ```

   The reset is path-scoped and updates only the parent index's gitlink entry. It must not touch the Wiki worktree or any unrelated staged file.

## Phase 6: Final Verification and Handoff

### Parent gitlink audit

Enumerate the `Wiki` gitlink for every rewritten parent commit:

```powershell
git rev-list --reverse origin/main..main | ForEach-Object { git ls-tree $_ Wiki }
```

No tree may reference `151d015324a94119b2539d88c406f6a2e2c8bde1` or any other superseded Wiki commit for which a rewrite mapping exists.

### Scope and status audit

1. Compare root and Wiki `status --short` plus cached-name lists to their preflight captures.
2. Explain every difference. Unrelated entries must be unchanged; the Wiki submodule may remain dirty for the same unrelated reasons recorded at preflight.
3. Run `git diff --check` in both repositories.
4. Re-run the residual reference scans and focused verification commands after refs and indexes are aligned.
5. From the parent root, run:

   ```powershell
   openspec validate refactor-wiki-source-corpus-removal --strict
   ```

6. Record:
   - refreshed public bases;
   - old and new Wiki tips;
   - old and new parent tips;
   - the full Wiki commit map;
   - backup refs;
   - verification commands and exit codes; and
   - confirmation that no push, force-push, backup deletion, reflog expiry, garbage collection, or archive occurred.

Stop locally and request explicit direction before any push or backup-ref cleanup.
