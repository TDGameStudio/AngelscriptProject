## Context

`Wiki/source-corpus/angelscript/` is an immutable copy of plugin revision `4e2e23ca16ae9f1786258fb96b09b268259b1aad`. At the planning baseline it contains 1,158 files and 17,692,585 bytes (16.87 MiB):

| Snapshot subtree | Files | Bytes | Approx. MiB |
| --- | ---: | ---: | ---: |
| `Source/AngelscriptTest` | 645 | 10,646,075 | 10.15 |
| `Source/AngelscriptRuntime` | 409 | 6,092,896 | 5.81 |
| `Source/AngelscriptEditor` | 86 | 843,157 | 0.80 |
| `Source/AngelscriptUHTTool` | 14 | 101,716 | 0.10 |

Only three registered excerpts are rendered:

| Stable key | Consumer |
| --- | --- |
| `as-source.runtime-class-reload-planner` | `AS/Docs/zh-Hans/hot-reload/reload-pipeline-internals` |
| `as-source.runtime-preprocessor` | `AS/Docs/zh-Hans/unreal-language/feature-implementation-principles` |
| `as-source.uht-binding-policy` | `AS/Docs/zh-Hans/bindings-uht-extensions/uht-plugin-internals` |

The corpus also requires a manifest, two reports, a public registry, four scripts, package commands, generated tiddlers, contract tests, publication assertions, and contributor instructions. The source copy is outside the TiddlyWiki boot payload, but it still expands the Git repository and creates a second source lifecycle that must be synchronized and reviewed.

At plan creation:

- the snapshot and the public plugin remote both resolve to `4e2e23ca16ae9f1786258fb96b09b268259b1aad`;
- the local plugin is at `dc99986febf1f0911a3ebfdc6d987cc3c0594907`, ten commits beyond the snapshot and dirty;
- Wiki `main` is at `151d015324a94119b2539d88c406f6a2e2c8bde1`, 29 commits ahead of `origin/main` at `48b181fe5220db2571971e5c36a1d400d1959e22`;
- parent `main` is at `c6d09135f7ffbf73f5763e7320ac2a1c5f5ec552`, 47 commits ahead of `origin/main` at `f84f9bbf9167bbdde727fdce60382b0f034c014a`;
- the corpus subsystem was introduced by the current Wiki tip; and
- `git-filter-repo` is not installed.

These values are evidence, not execution-time assumptions. The apply phase must fetch and re-resolve all refs, counts, commit relationships, dirty paths, and introduction points before changing anything.

The root repository and Wiki submodule both have unrelated uncommitted work. The implementation must preserve it, must not use broad stash/reset/clean operations, and must stop if any user modification overlaps a removal or page-integrity target.

## Goals / Non-Goals

**Goals:**

- Remove the entire public plugin source-corpus subsystem and its generated outputs.
- Leave the three consuming articles valid after their generated excerpt blocks are removed.
- Preserve generic source metadata and the existing broad source keys.
- Preserve the private Hazelight metadata-only and no-network safety boundary after the corpus capability disappears.
- Prevent the unpublished corpus objects and obsolete Wiki gitlink from being introduced into the public Wiki or parent branch histories.
- Provide a reversible local history-rewrite process that protects unrelated dirty work and requires no new Git tooling.
- Verify deletion, document integrity, offline publication, and rewritten history with focused commands.

**Non-Goals:**

- Replacing the corpus with a smaller snapshot, test-excluded snapshot, submodule, Git LFS object, downloaded build input, or on-demand source cache.
- Synchronizing the current plugin revision or adding a new synchronization/update tool.
- Deciding whether future authors should paste source, link to GitHub, or introduce another evidence mechanism.
- Rewriting article prose beyond removing the three corpus-specific evidence blocks and keys.
- Removing generic `as-sources` support, broad source-registry entries, Hazelight public-document mappings, or restricted Hazelight metadata.
- Changing plugin source, tests, UE modules, runtime behavior, Wiki navigation, or visual design.
- Pushing rewritten refs, force-pushing, deleting backup refs, running Git garbage collection, archiving this change, or committing unrelated working-tree changes.

## Decisions

### 1. Retire the subsystem instead of reducing the snapshot

The complete `wiki-source-reference-corpus` capability will be removed. Keeping only Runtime/Editor/UHT files would lower the byte count, but it would retain nearly all synchronization, manifest, license, excerpt, registry, and validation complexity. Three consumers do not justify a dedicated second source-distribution pipeline.

Alternatives rejected:

- Excluding only `AngelscriptTest`: saves most bytes but retains the full maintenance surface.
- Updating to the latest plugin first: imports more unpublished source immediately before deletion and gives no reader benefit.
- Moving the snapshot outside Git or downloading it during builds: introduces storage/network dependencies and conflicts with offline, reproducible Wiki commands.

### 2. Repair pages minimally and leave future citation policy undecided

The three `as-source.*` values, “固定源码证据” sections, and generated transclusions will be removed. Their surrounding technical explanations, tests, broad `angelscript-plugin` references, and other `as-sources` keys remain.

No replacement link or inline code will be inserted. That choice belongs to future article work and may differ per page. This prevents the cleanup from silently creating a new citation convention.

### 3. Keep generic source metadata; remove only corpus-owned records

`AS/Docs/Data/SourceRegistry` and the `as-sources` field remain because they also describe project guides, knowledge pages, examples, OpenSpecs, public documentation, and other broad sources. Only these three generated-corpus records are removed:

- `as-source.runtime-class-reload-planner`
- `as-source.runtime-preprocessor`
- `as-source.uht-binding-policy`

`source-references/angelscript.json` is deleted because every record in it belongs to the retired public corpus. `source-references/hazelight-restricted.json` remains because it is metadata-only comparison evidence with a separate authorization and license boundary.

### 4. Make the private-source boundary independent of corpus implementation

The current corpus capability contains a private Hazelight prohibition. Removing the capability must not weaken that rule. A requirement is therefore added to `wiki-content-architecture` stating that authorized private source may be represented only by revisioned identity/path/purpose metadata and paraphrased conclusions.

Private bodies, excerpts, patch bodies, body-derived payloads, public source URLs, and private mirrors remain prohibited. Normal development, tests, builds, and page rendering remain prohibited from contacting the private repository.

### 5. Rewrite unpublished history instead of adding a forward deletion commit

The corpus introduction has not reached either public `main`. A normal deletion commit would leave all source blobs in the Wiki history and the obsolete Wiki gitlink in the parent history. The apply phase will therefore rewrite only each repository's `origin/main..main` segment.

The rewrite has mandatory guards:

1. Fetch both public `main` refs and prove that the corpus-introducing Wiki commit is not reachable from the refreshed remote.
2. Record exact old bases/tips, path-scoped status, and commit/gitlink inventories.
3. Create dated local backup refs in both repositories before changing refs.
4. Abort on overlapping dirty paths, unexpected published reachability, or an unhandled merge topology.
5. Use standard Git only; do not install or add `git-filter-repo`.
6. Verify candidate histories before moving either checked-out `main`.
7. Move refs with expected-old-value checks, then align only the affected index paths.
8. Keep backup refs and avoid garbage collection until a later successful push and explicit cleanup approval.

If the Wiki introducer is still its unpublished tip, the preferred path is a path-scoped `commit --amend --only` after the cleanup is verified. This avoids absorbing unrelated staged changes. If the introducer or later Wiki history has changed, replay the linear unpublished segment in an isolated temporary clone, applying the cleanup at the introduction commit and resolving later commits without reintroducing removed paths.

The parent unpublished segment is replayed in an isolated temporary clone. Every old Wiki gitlink that points into the rewritten Wiki segment is replaced using the old-to-new Wiki commit map. Candidate commits preserve original author/message information. The real parent branch is updated only after the candidate passes tree and history checks.

### 6. Preserve dirty work through explicit path ownership

All deletion, modification, staging, index alignment, and status checks use the exact file map in `implementation-plan.md`. Broad `git add -A`, `git commit -a`, `git stash`, `git reset --hard`, `git clean`, recursive workspace moves, and checkout-based restoration are prohibited.

If a target path already has an unrelated staged or unstaged change, implementation stops for user direction. Unrelated dirty paths elsewhere remain untouched and must have the same status after the operation.

### 7. Keep validation proportional to a deletion change

Focused contract tests, the document browser suite, offline build/publication checks, static checks, residual-reference scans, and Git object/gitlink audits provide the required confidence. The change does not create replacement implementation logic, so it does not add a new unit-test subsystem.

## Risks / Trade-offs

- **A corpus commit becomes public before apply** → Fetch both remotes immediately before work; if the introducer is remote-reachable, stop and redesign. Never force-push public history under this change.
- **A remote advances during local rewrite** → Re-fetch and compare the recorded base again before moving local refs or later pushing. A changed base invalidates the candidate.
- **Unrelated dirty work is accidentally committed or unstaged** → Reject overlapping target paths, use explicit pathspecs and expected-old-value ref updates, compare before/after status, and never use broad index/worktree commands.
- **History replay loses or changes unrelated commits** → Create backup refs first; compare commit counts, subjects, authors, and non-Wiki tree diffs; keep backup refs until later approval.
- **Deleted generated tiddlers leave broken documents** → Remove the three fields/transclusions together, scan all Wiki sources, run document tests and browser tests, then inspect the offline artifact title set.
- **Private-source restrictions disappear with the old spec** → Add the independent content-architecture requirement and retain restricted metadata plus contributor guidance.
- **Future maintainers lose automatic source freshness checks** → Accepted trade-off. The project intentionally returns source evidence choices to ordinary article maintenance rather than retaining a global synchronizer.
- **Repository size does not shrink immediately on disk** → Expected while backup refs and reflogs retain objects. The goal is clean future public history; local object pruning is explicitly deferred.

## Migration Plan

1. Re-resolve public bases, local tips, introduction commits, topology, gitlinks, target-path status, and snapshot measurements.
2. Stop if any old corpus commit is public, if either unpublished range has an unsupported merge, or if user changes overlap target paths.
3. Create dated backup refs for Wiki and parent `main`, and record the old/new mapping location.
4. Apply the exact Wiki deletion and page-integrity edits, updating Chinese contributor guidance before English guidance.
5. Run focused source, document, browser, offline-build, publication, lint, and type checks against the working-tree candidate.
6. Amend the current unpublished Wiki tip when the baseline shape still holds; otherwise replay the unpublished Wiki range in a temporary clone and build an old-to-new commit map.
7. Audit the rewritten Wiki candidate to prove the removed paths and objects are absent from `origin/main..candidate`.
8. Replay the parent's unpublished linear range in a temporary clone, replacing every rewritten Wiki gitlink through that map.
9. Audit the parent candidate, then update the real Wiki and parent refs with expected-old-value guards and align only affected index paths.
10. Re-run residual-reference, history, status, and strict OpenSpec validation. Stop locally without pushing, deleting backup refs, garbage collecting, or archiving.

Rollback before any future push consists of moving `main` back to the dated backup ref with an expected-current-value check, then aligning only the affected paths. Because backup refs and objects are retained, no reflog recovery or network operation is required.

## Open Questions

None. Runtime state changes discovered during apply are safety preconditions: they require stopping and updating this record rather than making an unrecorded policy choice.
