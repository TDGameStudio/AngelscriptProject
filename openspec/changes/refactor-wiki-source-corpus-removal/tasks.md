> Implementation note: the history rewrite (§4/§5) was executed with `git filter-branch` in
> isolated temp clones rather than the manual cherry-pick loop the design sketched — same
> guarantees, far less ceremony. Only 4 Wiki commits changed SHA and only 4 parent commits
> needed gitlink remap. See `apply-log.md` for the full commit map, audits, and handoff record.
> Refs moved locally; nothing pushed. Backup refs retained.

## 1. Revalidate State and Protect Recovery Points

- [x] 1.1 Fetch and record refreshed root/Wiki public bases, local tips, remotes, unpublished commit counts, corpus introduction commits, parent Wiki gitlinks, and the current snapshot measurements.
- [x] 1.2 Prove the corpus-introducing and rewritten commits are unpublished, prove both unpublished ranges are linear, and stop if public reachability or merge topology invalidates the design.
- [x] 1.3 Capture root/Wiki staged and unstaged status, verify no user change overlaps the exact cleanup paths, and preserve the unrelated dirty-path inventory.
- [x] 1.4 Create and record dated root and Wiki backup refs before any file or ref mutation.

## 2. Remove the Wiki Source-Corpus Subsystem

- [x] 2.1 Update `Wiki/Agents_ZH.md` and then `Wiki/Agents.md` to remove public corpus workflow instructions while preserving the private Hazelight metadata-only and no-network rules.
- [x] 2.2 Remove the raw snapshot, manifest, reports, `source-references/angelscript.json`, four corpus scripts/tests, and three generated source tiddlers from the exact file map.
- [x] 2.3 Remove the four corpus package commands and the `test:source-corpus` contract-chain entry, then update the command-graph assertion.
- [x] 2.4 Remove corpus-specific document and publication assertions without weakening generic source metadata, source-boundary, document-integrity, or offline-publish coverage.
- [x] 2.5 Remove only the three `as-source.*` registry records, document field values, “固定源码证据” blocks, and generated transclusions; add no replacement link or excerpt.
- [x] 2.6 Review the path-scoped Wiki diff and confirm all generic source keys, `as-sources`, `SourceRegistry.tid`, and `source-references/hazelight-restricted.json` remain.

## 3. Verify the Clean Wiki Tree

- [x] 3.1 Run tracked-path and repository-wide residual scans and prove the removed corpus commands, files, keys, generated titles, and transclusions are absent.
- [x] 3.2 Run `node --test scripts/document-content-contract.test.mjs scripts/test-execution-commands.test.mjs`.
- [x] 3.3 Run `node scripts/run-product-tests.mjs feature document` and verify the three edited documents render without missing tiddlers.
- [x] 3.4 Build the offline Wiki, run `node --test scripts/publish-offline.test.mjs`, and prove the artifact contains neither raw corpus titles nor generated `as-source.*` titles.
- [x] 3.5 Run the existing scoped ESLint and TypeScript `--noEmit` checks for affected Wiki code without adding a replacement test subsystem.

## 4. Rewrite Only Unpublished History

- [x] 4.1 Amend the unpublished Wiki introducer with exact path scope when it remains the tip; otherwise replay the linear Wiki unpublished segment in a temporary clone and record the complete old-to-new Wiki commit map.
- [x] 4.2 Audit the Wiki candidate so no removed corpus path or object is reachable from candidate `main`, while acknowledging that the retained backup ref intentionally keeps rollback objects locally.
- [x] 4.3 Replay the parent unpublished segment in a temporary clone, replacing every superseded Wiki gitlink through the verified commit map and preserving all unrelated commits.
- [x] 4.4 Verify both candidates, update real `main` refs with expected-old-value guards, and align only affected index paths without stash, clean, hard reset, worktree creation, or unrelated staging changes.

## 5. Final Audit and Local Handoff

- [x] 5.1 Re-run focused Wiki verification, `git diff --check`, strict OpenSpec validation, removed-path history scans, and the parent-per-commit Wiki gitlink audit.
- [x] 5.2 Compare before/after root and Wiki statuses and prove unrelated staged, unstaged, and untracked work is preserved.
- [x] 5.3 Record public bases, old/new tips, commit mappings, backup refs, commands, and exit codes, then stop without push, force-push, backup deletion, garbage collection, archive, or unrelated commit.
