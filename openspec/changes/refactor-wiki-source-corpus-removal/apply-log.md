# Apply Log — refactor-wiki-source-corpus-removal

Session: continue-implement. All values re-measured at apply time (design §Context requires this).

## Preflight (Phase 1) — measured

| Item | Planning baseline | Measured at apply |
| --- | --- | --- |
| Wiki base `origin/main` | `48b181fe5220db2571971e5c36a1d400d1959e22` | `48b181fe5220db2571971e5c36a1d400d1959e22` (unchanged) |
| Wiki tip `main` | `151d015…` | `247cf7ce5d7d289cc20253d5d0f0c32c090babc6` (advanced this session) |
| Wiki unpublished count | 29 | 32 |
| Wiki range linear (merges) | linear | linear (no merges) |
| Corpus introducer | Wiki tip `151d015` | `151d015324a94119b2539d88c406f6a2e2c8bde1` (NOT tip → alternate replay) |
| Introducer public? | no | no (not ancestor of refreshed origin/main) |
| Parent base `origin/main` | `f84f9bbf…` | `f84f9bbf9167bbdde727fdce60382b0f034c014a` (unchanged) |
| Parent tip `main` | `c6d0913…` | `c1f52fe40d9303b6ad67489c2e1682013851e290` (advanced this session) |
| Parent unpublished count | 47 | 49 |
| Parent range linear | linear | linear (no merges) |
| Parent commits w/ Wiki gitlink in rewritten range | — | 47 of 49 |
| Distinct in-range Wiki gitlinks referenced by parent | — | 27 |
| Snapshot revision | `4e2e23ca…` | `4e2e23ca16ae9f1786258fb96b09b268259b1aad` (manifest) |
| Snapshot tracked files / bytes | 1158 / 17,692,585 | 1068 tracked / 17,692,585 bytes (du) |
| Target-path overlap with dirty work | must be none | none (Wiki + parent target paths clean) |
| git-filter-repo | absent, not required | not used |

All corpus deletion-map paths were introduced by a single commit `151d015`. Shared files also edited by later in-range commits: `scripts/document-content-contract.test.mjs`, `package.json`, `scripts/publish-offline.test.mjs` (must reconcile during replay).

## Backup refs (Phase 1.4) — created before any mutation

- stamp: `20260730-142141`
- parent: `refs/backup/refactor-wiki-source-corpus-removal/parent-main-20260730-142141` = `c1f52fe40d9303b6ad67489c2e1682013851e290`
- wiki:   `refs/backup/refactor-wiki-source-corpus-removal/wiki-main-20260730-142141` = `247cf7ce5d7d289cc20253d5d0f0c32c090babc6`

## Old→new commit map (Wiki) — filled during Phase 4

Method: isolated temp clone `/tmp/wiki-rewrite`; `git filter-branch --index-filter` stripped
corpus paths from `48b181f..main` (32 commits); one text-cleanup commit applied on the
filtered tip. Only 4 commits changed SHA (introducer + 3 descendants); the 28 pre-corpus
commits kept identical SHAs. Candidate tip tree has 0 corpus paths; the 10 edited files are
byte-identical (modulo CRLF) to the Phase-3-verified worktree.

| old (real) | new (candidate) |
| --- | --- |
| `151d015324a94119b2539d88c406f6a2e2c8bde1` | `5089d98a3d3c411d6a9768296c92bb07aeb9b1d2` |
| `ba84325b37e18754657ee0c7f49c80baec285bcd` | `9281d5ccdb25e4a5ae12dbdee41cb16187f9ef44` |
| `daf7c3e0680dd78cd521856d50e6df343fa95cac` | `a8b7f067e21dee99e75ed3ac848d091c5e8476b0` |
| `247cf7ce5d7d289cc20253d5d0f0c32c090babc6` (old Wiki tip) | `0b92f7ba1c754a5db552f8c2263fc74219b7772a` (new Wiki tip) |

Parent commits referencing each changed old SHA (only these need gitlink remap):
`151d015`×2, `daf7c3e`×1, `247cf7c`×1 → 4 parent commits total.

## Handoff record — filled during Phase 6

Method chosen (per user): genuine history rewrite (option B), simplified via `filter-branch`
rather than the design's manual cherry-pick loop. Both rewrites done in isolation; the dirty
worktrees of both repos were never touched.

Refs moved (guarded with expected-old-value):
- Wiki `main`: `247cf7ce5d7d289cc20253d5d0f0c32c090babc6` → `0b92f7ba1c754a5db552f8c2263fc74219b7772a`
- Parent `main`: `c1f52fe40d9303b6ad67489c2e1682013851e290` → `900b803e7c452521dea2dee8b93c8b38d6832961`

Parent commit map (4 tip commits, only Wiki gitlink changed per commit):
- `c46b1a7` → `ef1f9a8`
- `c6d0913` → `aece1bd`
- `691afaa` → `fa3092d`
- `c1f52fe` → `900b803`

Audits (all pass):
- 0 `source-corpus/` paths in any of the 32 unpublished Wiki commits (backup ref still has 1068).
- No unpublished parent commit references a superseded Wiki SHA.
- Each rewritten parent commit differs from its original by only the `Wiki` gitlink.
- `git diff --check` clean in both repos.
- Contract tests 38/38 pass on the moved Wiki HEAD (`document-content-contract`, `test-execution-commands`, `publish-offline`).
- `openspec validate --strict` passes.
- Offline build + publish (Phase 3) produced an artifact with 0 generated `as-source.*` and 0 raw `source-corpus/` titles.

Working-tree preservation:
- Wiki: only the 6 pre-existing unrelated dirty entries remain (tag-popup.tid, 3 spec.ts, 2 jpg) — identical to preflight.
- Parent: unrelated dirty work unchanged; `Wiki` gitlink index entry realigned to new HEAD via path-scoped `git reset -- Wiki`.

Backup refs retained (rollback without network):
- `refs/backup/refactor-wiki-source-corpus-removal/wiki-main-20260730-142141` = `247cf7c`
- `refs/backup/refactor-wiki-source-corpus-removal/parent-main-20260730-142141` = `c1f52fe`

NOT done (deliberately): no push, no force-push, no backup-ref deletion, no reflog expiry, no
`git gc`, no archive, no unrelated commit. Objects (incl. the 16.87 MiB corpus) remain on disk
locally until a later successful push + explicit cleanup approval.

(pending)
