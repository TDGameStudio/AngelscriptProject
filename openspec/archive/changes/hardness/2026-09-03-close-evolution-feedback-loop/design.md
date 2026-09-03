## Context

The current self-evolution path is:

```text
ignored observation -> aggregate status -> workflow evaluation -> archive
```

That path is useful for timing and low-cost telemetry, but it cannot own a material workflow defect. OpenSpec already has a detailed material implementation-issue lifecycle, yet its admission guidance assumes a problem discovered while an active Change is being implemented. A material issue discovered during archive, exact commit, or final handoff can therefore fall between ignored observations and tracked issue state.

The first real example is delivery commit `e183e17d2fdac4a8975dd93b9324fe552ad8231b`. The selected Hardness paths were ready, but unrelated work was already staged. Hardness rejected the operation by design because it subsequently uses an ordinary whole-index commit. Git's native `commit --only` safely committed the exact selected paths and preserved the unrelated staged patch, but this capability discovery was not admitted to a material issue before the final handoff.

The same retrospective audit found no coherent indexed talk for the original cross-capability Hardness request. Canonical artifacts correctly own current truth, but the interacting user constraints, corrections, and rejected interpretations were distributed across several immutable Changes and non-durable conversation history.

## Goals

- Ensure a material dogfooding problem never exists only in conversation, ignored telemetry, or a final summary.
- Reuse the detailed material implementation-issue lifecycle instead of creating a parallel finding category.
- Give each new issue a small versioned machine surface and an evidence-backed terminal disposition.
- Preserve immutable archives by routing late discoveries to an exact suitable active Change, creating a successor only when no suitable owner exists.
- Resolve the first scoped-commit issue with a safe opt-in rather than weakening default commit behavior.
- Preserve one bounded original-intent baseline and make future intent carryover selective and major-only.
- Keep status and closure checks cheap enough for normal agent cadence.

## Non-goals

- Do not turn every timing sample, idea, expected TDD failure, typo, or raw observation into tracked work.
- Do not introduce an `attachments/evolution/` tree, database, daemon, event bus, mandatory Review, or automatic Replan.
- Do not make an intent talk mandatory for every Change or attempt to infer missing talks by scanning conversation text.
- Do not make `PreserveOutsideStaged` the default or combine it with all-change commit intent.
- Do not change integration, push, cleanup, Unreal execution, current durable specifications, or OpenSpec binary behavior during planning normalization.

## Decision 1: Separate raw observations from admitted material issues

`hardness.observe` remains a local ignored evidence stream. Admission is a judgment checkpoint, not a new Review stage. A dogfooding discovery enters tracked issue state when evidence shows a repeatable safety, correctness, lifecycle, evidence, or high-friction capability gap that should change future Hardness decisions. Explicit user admission, a required manual bypass of a public Hardness route, invalidated completion evidence, or a cross-task/capability defect always meets that threshold.

```text
raw observation / conversation / implementation evidence
                         |
                    material?
                    /       \
                  no         yes
                  |           |
          ignored evidence    v
                 attachments/implementation/issue-*.md
                              |
                 +------------+------------+
                 |            |            |
              resolve       reject      supersede
                 |       with evidence   exact owner
                 +------------+------------+
                              |
                         terminal issue
```

Ordinary timing variation, unverified preferences, one-off environment noise, routine first RED results, obvious immediate corrections, and duplicate symptoms remain non-material. A Review finding continues to follow Review lifecycle; only a distinct material workflow root cause is admitted to an implementation issue.

## Decision 2: Version the existing detailed issue format

New material issues remain under:

```text
openspec/changes/<domain>/<change>/attachments/implementation/issue-*.md
```

They retain the existing detailed body: Symptom, Investigation Log, Root Cause, Disposition, Evidence with RED/GREEN and proof limits, and Links. New records add this compact frontmatter contract:

```yaml
issue_schema: openspec-material-issue-v2
issue_id: issue-...
status: open | resolved | rejected | superseded
source: dogfooding | user | implementation | verification | review | dependency
source_ref: <exact evidence>
affected_tasks: ["..."]
created_at: <ISO-8601>
```

Open records omit terminal fields. A `resolved` or `rejected` issue requires `resolved_at` and `resolution_ref`; a `superseded` issue requires `resolved_at` and `superseded_by`. `superseded_by` uses exact `hardness/<change>#issue-<id>` syntax and must resolve to an existing v2 issue. Historical issue files without `issue_schema` remain readable legacy v1 records and are not rewritten.

Every issue is indexed exactly once in `attachments/INDEX.md`. Long logs remain in focused data or linked evidence rather than being copied into the issue. Multiple symptoms with one root cause remain one issue.

## Decision 3: Make post-admission disposition mandatory

Whether evidence crosses the material threshold remains a bounded agent/user judgment. Once admitted, structure and disposition are mandatory:

- `open` is the only non-terminal status and blocks every archive closure kind.
- `resolved` means repaired in the owning Change with an exact task, test, commit, or artifact reference.
- `rejected` means deliberately not implemented with an evidence-backed rationale or discussion reference.
- `superseded` means another exact v2 issue owns the remaining concern; free-floating deferral is forbidden.

A material issue triggers Replan only when its evidence invalidates accepted planning truth. Otherwise it is handled inside a current task, rejected with evidence, or superseded. Review remains explicit-only.

## Decision 4: Keep status and closure exact and bounded

`hardness.evolution.status` accepts or resolves one exact active Change and parses only v2 issue frontmatter plus the canonical workflow-evaluation frontmatter. It reports counts by status, open issue paths, structural errors, the latest evaluation identity, and closure readiness without loading raw observations or attachment bodies.

Before archive, the closure gate verifies only the selected Change:

1. Every `attachments/implementation/issue-*.md` v2 record has valid state-specific fields.
2. Every issue and INDEX entry has exact one-to-one membership.
3. Each affected task exists; closure-specific checks ensure required owner tasks are complete.
4. `resolution_ref` or `superseded_by` satisfies the terminal status contract, with no self-reference or direct cycle.
5. No v2 issue remains open.
6. One indexed, versioned `attachments/data/workflow-evaluation.md` has a parseable result.

The gate does not scan conversation history, ignored observation bodies, unrelated active Changes, or archive bodies and does not infer that a missing intent talk should exist. Those semantic admission choices remain governed by the planning/handoff checkpoint and positive/negative protocol fixtures.

After an archive move, the archive remains immutable. A newly admitted material issue enters one exact suitable active Change before handoff; if none exists, the coordinator creates an immediate successor Change and issue. Unrelated implementation may continue once the issue has a tracked owner.

## Decision 5: Preserve outside staged content only through an explicit path-only mode

Default scoped commits keep the existing fail-closed rejection. With exact repository/path scopes and `PreserveOutsideStaged = $true`, each repository:

1. Calculates effective scopes and scope-external index entries before mutation.
2. Rejects pathspec magic, ambiguous scope, an unmerged index, all-change intent, or an unverifiable index state.
3. Completes static preflight for every affected repository, including planned parent gitlinks, before the first commit.
4. Runs path-limited staging and `git commit --dry-run --only -- <scopes>`.
5. Uses `git commit --only -- <scopes>` for the actual commit.
6. Confirms the commit contains only effective-scope paths and that the outside index fingerprint is equivalent afterward.

Submodules still commit before the parent. The preservation fingerprint uses index entries—path, stage, mode, object identity, and relevant flags—with a deterministic binary patch hash as supporting evidence. Preview distinguishes selected paths from preserved staged paths. If a later repository or commit hook fails after earlier submodules committed, the operation returns completed and pending repositories without resetting user state.

## Decision 6: Preserve original user intent only for a major decision cluster

Canonical requirements remain in proposal, specifications, design, and tasks. One selective indexed intent talk is required only when an extended user-led exploration establishes multiple interacting cross-capability constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide.

The checkpoint is semantic and major-only. A clear defect, mechanical documentation edit, one-step request, routine task-local choice, or decision already explained completely by canonical artifacts does not create a talk or a `not required` placeholder. Machines validate a talk only after it has been admitted and indexed; they do not infer need from chat or diff size.

An admitted talk records provenance, capture date, source limits, settled intent, exclusions, architecture-changing corrections, and canonical mappings. It excludes transcripts, question-round navigation, task state, progress logs, test output, repeated canonical requirements, and temporary decisions. A reconstructed talk states that fact and never impersonates contemporaneous evidence.

This Change uses `attachments/talks/talk-20260903-212650-original-hardness-user-intent.md` as the one bounded recovery baseline. The corresponding open material issue cannot resolve until the selective checkpoint and its positive/negative protocol evidence exist.

## Decision 7: Make the workflow evaluation a final self-hosting checkpoint

Every Hardness or OpenSpec self-hosting Change retains one indexed `attachments/data/workflow-evaluation.md` with versioned frontmatter, exact Change identity, capture time, and parseable result. It records compact elapsed stages, material friction, corrections, superseded owners, and raw-data provenance without copying samples. Empty categories may say `None observed`; they do not require boilerplate narrative.

The canonical evaluation is refreshed after the last semantic implementation and before closure, and any material delivery-stage discovery receives issue ownership before handoff. `hardness.evolution.status` reads its frontmatter only. Historical evaluations without the new schema remain immutable compatibility evidence.

## Risks and mitigations

- **Materiality inflation:** use explicit admission criteria and negative examples; do not upgrade raw observations automatically.
- **Talk accumulation:** require one talk only for a major decision cluster whose rationale would otherwise be lost, never for routine work and never as a not-required placeholder.
- **False-positive closure:** inspect only admitted v2 frontmatter and exact INDEX membership in the selected Change; do not scan conversation, raw bodies, unrelated Changes, or history.
- **Pathspec expansion:** pass literal normalized exact scopes after rejecting pathspec magic; cover leading dots, dashes, spaces, Unicode, and prefix collisions.
- **Index races:** compare the outside fingerprint immediately before and after commit and fail visibly on drift.
- **Commit-hook failure:** preserve the outside index and report scoped index state without destructive cleanup.
- **Cross-repository partial completion:** preflight every repository first and return completed/pending repositories if a later commit fails.
- **Historical compatibility:** retain legacy v1 issues and evaluations unchanged; apply strict new rules only to v2/current records.
