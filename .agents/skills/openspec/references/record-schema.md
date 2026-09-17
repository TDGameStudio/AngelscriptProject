# OpenSpec Record Schema

Read this reference only when creating, moving, or closing records under `openspec/`.

## Repository

```text
openspec/
├── project.yaml
├── config.yaml
├── workflows/<name>/
├── domains/<domain>/domain.yaml
├── specs/<domain>/<capability>/spec.yaml
│   ├── spec.md
│   └── knowledges/
├── changes/<domain>/<change>/change.yaml
│   ├── proposal.md
│   ├── design.md
│   ├── specs/**/spec.md
│   ├── tasks.md
│   └── attachments/
├── drafts/<domain>/<topic>/          # brainstorming working records, not CLI artifacts
│   ├── README.md
│   ├── log.md
│   ├── findings/
│   └── designs/<scope>/{README,design,handoff,glossary}.md
├── archive/drafts/<domain>/<date>-<topic>/ # ignored explicit completed/abandoned drafts
└── archive/changes/<domain>/<date>-<change>/
```

The CLI owns `project.yaml`, `domain.yaml`, `spec.yaml`, `change.yaml`, Change identity, Change moves, and Change archive paths. Never fabricate or hand-move those files. `drafts/` is owned by the `brainstorming` Skill ([draft contract](../../brainstorming/references/drafts.md)): the CLI does not validate it, Harness checks only an exact topic or scope, and it carries no task state. `openspec-create-change` is the Skill that turns one selected approved scoped design into a Change. Maintained project records, Skills, workflows, templates, and command documentation use English; new local draft materials under `openspec/drafts/` default to the user's conversation language unless the user specifies another draft language, and explicitly named `_ZH` documents retain their existing localization exception. Every final Change record and attachment is English, including exported draft design/handoff, research and diagram explanations.

## Change identity

New AngelscriptProject Change IDs use `<domain>/<type>-<scope>-<outcome>`. The leaf is lowercase kebab-case and its type is exactly one of `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, or `chore`. Use `feature`, not the Git commit type `Feat` or the alias `feat`.

Use `refactor` when module boundaries, dependencies, or structural shape change. Use `improve` for quality, diagnostics, performance, readability, or ergonomics without a structural reshape. Keep both a concrete scope and an outcome; do not use a bare verb or bundle unrelated outcomes into one Change.

Harness enforces this project policy for `harness.change.create` and `change move --to` targets. The generic `openspec.change create` route rejects creation; use the typed Harness route with `Origin = Draft` and exact scope, or `Origin = Direct` and a reason. An existing nonconforming active source may move to a conforming target. The portable CLI remains project-neutral, and immutable archive IDs and paths are never renamed by this policy.

Every newly marked Change keeps `attachments/data/harness-origin.json`. Draft-backed Changes pass `harness.change.seed.verify` after indexed, self-contained English export and before Ensure plan; Harness also checks the seed when `openspec.instructions` requests a planning artifact. Every new Change has a root `design.md` with `## Call chains`: actual caller-to-callee paths and `Measured at` (revision plus dirty paths) for code, or `none` with a reason for a non-code change. `harness.change.plan.verify`, `task.status`, and `openspec.instructions apply` enforce this on marked Changes. The exact pre-gate active IDs in `harness/scripts/legacy-change-plan-exemptions.json` retain their accepted contract; an unmarked new ID cannot claim grandfathering. The workflow's optional design artifact remains optional for those legacy IDs.

## Change attachments

```text
attachments/
├── INDEX.md
├── drafts/
├── reviews/
├── implementation/
├── replans/
├── knowledges/
├── talks/
├── scripts/
└── data/
```

`INDEX.md` is the only default attachment entry. Do not bulk-load attachments or historical replans. Read [attachments.md](attachments.md) only when writing or closing an attachment.

Focused authoring contracts are separate so they load only when needed:

- [specs.md](specs.md) owns Requirement and Scenario Card authoring, artifact content boundaries, validator-profile meaning, and delta synchronization semantics.
- [tasks.md](tasks.md) owns Task DAG structure and ready-to-execute authoring quality.
- [implementation-issues.md](implementation-issues.md) owns material problem history during implementation, verification, or review repair.
- [knowledge.md](knowledge.md) owns explicit promotion from change evidence to capability knowledge and, only for cross-capability invariants, project instructions.

There is no independent schema Skill and no project-level `openspec/knowledges/` tree. The portable CLI validates record structure and Task DAGs; Harness protocol tests own attachment and knowledge policy that the CLI does not parse.

## Instructions output

Treat `context` and `rules` as prompt constraints, never artifact content. An artifact response distinguishes:

```text
outputKind          file | glob
outputPattern       workflow-owned relative pattern
existingOutputPaths concrete files already present
writePath           concrete writable file, or null for a glob
```

Never write to `outputPattern` or a wildcard. Choose a concrete path permitted by the workflow and validate it after writing.

## Active and archived manifests

Active changes forbid `archived_at` and `closure`. Archive records one explicit closure:

```yaml
closure:
  kind: completed | abandoned | superseded
  reason: <required for abandoned or superseded>
  superseded_by: <domain/replacement when applicable>
  task_dispositions:
    "2.3":
      status: cancelled | superseded | needs_followup
      reason: <why the incomplete task will not complete here>
      follow_up: <change/task reference when applicable>
```

`completed` requires all tasks and close gates. `abandoned` and `superseded` require a reason plus a disposition for every incomplete task. Archives created before 0.7 without `closure` are audited as legacy completed records.
