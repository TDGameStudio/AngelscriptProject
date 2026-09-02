---
name: openspec-schema
description: The on-disk schema of OpenSpec records - both trees. The change tree (contract layer proposal/design/tasks/specs plus the attachments layer with INDEX.md and six fixed directories), the specs tree (capability directories, spec.md, spec-side knowledges), and the three-level knowledge architecture with promotion rules, plus authoring standards for tasks.md and every attachment type. Use when writing or organizing any file under openspec/.
---

# OpenSpec Schema: The Two Trees

This skill defines **what OpenSpec records look like on disk and how to write their contents** — both trees:

- `openspec/changes/<name>/` — the **change tree**: working records of one change in flight.
- `openspec/specs/<capability>/` — the **specs tree**: the durable contract that outlives changes.

Boundaries:

- **Operations are not here.** Creating, continuing, implementing, archiving, and every CLI invocation live in the sibling `openspec` skill.
- **Templates are not here.** The proposal/design/tasks/delta-spec templates are owned by the CLI workflow — `openspec/workflows/<workflow>/templates/`, resolved per change by `openspec instructions <artifact>` (run through `.agents/skills/hardness/scripts/openspec.ps1`). This skill only adds authoring standards the templates cannot carry.

Detail files, one level deep — read the one matching the file you are about to write:

| File | Covers |
|---|---|
| [openspec-tasks.md](openspec-tasks.md) | tasks.md on-disk format: dependency graph, task content requirements, quote blocks |
| [openspec-attachments.md](openspec-attachments.md) | attachments/INDEX.md template and the full rules for each of the six attachment directories |

# The Change Architecture

Two layers: a fixed contract layer and a free-form (but structured) attachments layer.

- [openspec-attachments.md](openspec-attachments.md) detailed specifications of the attachments directory
- [openspec-tasks.md](openspec-tasks.md) tasks.md on-disk format: dependency graph, task content requirements, quote blocks

```text
openspec/changes/<name>/
├── proposal.md                 contract: why this change exists
├── design.md                   contract: how, decisions and trade-offs
├── tasks.md                    contract: task checklist
├── specs/                      contract: delta specs
└── attachments/
    ├── INDEX.md                sole default entry: current state + per-file attachment index (overwrite-style, ≤120 lines)
    ├── knowledges/             knowledge distilled during the change
    ├── reviews/                review reports
    ├── implementation/         progressive implementation records
    ├── talks/                  discussion records for this change
    ├── scripts/                scripts accumulated while working
    └── data/                   benchmarks / matrices / tables / key logs, text-first
```

## `attachments` When to Write

- Review completed → drop a file into `reviews/` immediately.
- Stuck, diagnosing, or disposing of a problem → open an entry in `implementation/`.
- A discussion produced a decision → record it in `talks/`; once the conclusion stabilizes, lift it into `design.md` and mark the original entry as lifted.
- Learned something that will be looked up again (admission test) → distill it into `attachments/knowledges/<theme>.md`.
- Decisions handed over from exploration → route: requirements → the capability's spec doc · design decisions → `design.md` · scope changes → `proposal.md` · new tasks → `tasks.md` · overturned assumptions → the artifact that recorded them.
- Before ending a session → update the change's `attachments/INDEX.md` (the only INDEX carrying session state).
- Before archiving → finish `data/` trimming; decide knowledge promotion (see Knowledge Architecture below).

## tasks.md — Writing Standards

`tasks.md` is a **pure checklist** — the only checkboxes anywhere in the change; commentary, data, and analysis go to `attachments/`. Write tasks for an engineer with zero context for this codebase:

- **File map first.** Before writing tasks, map which files each task creates or modifies (exact paths). Decomposition gets locked in here.
- **Right-sizing.** A task is the smallest unit that carries its own verification and is worth a reviewer's gate. Fold setup, scaffolding, and docs into the task whose deliverable needs them; split only where a reviewer could reject one task while approving its neighbor.
- **Bite-sized steps.** One action per step — write the failing test, run it to see it fail, implement minimally, run it to see it pass, commit — with exact commands and expected outcomes.
- **Interfaces between tasks.** When a later task relies on an earlier one, state the exact names and signatures in both — a reader may take tasks out of order.
- **No placeholders.** "TBD", "add appropriate error handling", "similar to Task N", steps that describe without showing — these are plan failures. Write the actual content.
- **Self-review before delivering.** Spec coverage (every requirement maps to a task), placeholder scan, name/type consistency across tasks. Fix inline and move on.
- **Plan-only is first-class.** When the user wants a plan without implementation, this quality bar *is* the deliverable — ready to execute, not a skeleton.

On-disk format — dependency graph rules, task content requirements, quote-block usage — lives in [openspec-tasks.md](openspec-tasks.md).

# The Specs Architecture

```text
openspec/specs/
└── <capability-path>/              lowercase kebab-case; may nest (e.g. identity/user-auth)
    ├── spec.md                     the durable contract: requirements + scenarios
    └── knowledges/                 long-lived knowledge serving this capability
        ├── INDEX.md                pure catalog: one line per file — what it covers, which requirements it serves, status
        └── <theme>.md / <theme>.html   one theme per file, named for content
```

## Knowledge Architecture

- **Change level** — `changes/<name>/attachments/knowledges/`: admits anything useful while the change runs; freezes as history when the change archives.
- **Spec level** — `specs/<capability-path>/knowledges/`: admits only what serves that capability's contract; every file carries the mandatory header.
- **Project level** — `openspec/knowledges/`: admits only what spans capabilities — coding conventions, overall architecture, engine constraints.
- **One file form at every level** — `<theme>.md`, or `<theme>.html` with a same-name `.md` sidecar; named for content, no prefixes, no timestamps. What separates the levels is scope and admission bar, not format.
- **One `INDEX.md` at every level** — project and spec level are pure catalogs; the change level's `attachments/INDEX.md` is working memory.
- **Knowledge only moves up** — every promotion is explicit, never a side effect of archiving; the target level is chosen by the knowledge's scope:
  - change → serves one capability's contract → `specs/<capability>/knowledges/` — **copy**; the original stays and freezes at archive as the record of what was known at the time
  - change → spans capabilities (conventions, overall architecture, engine constraints) → `openspec/knowledges/`, directly — no stopover at spec level — **copy**
  - spec → scope outgrew its capability → `openspec/knowledges/` — **move**; both are live trees, a copy left behind would put the same current-valid knowledge in two places. The move deletes the file's line from the source `INDEX.md` in the same stroke, and is not tied to any archive — execute it whenever the outgrown scope is noticed
  - every promotion adds or refreshes the target-level header and updates the target `INDEX.md` in the same stroke — `serves` points to requirements at spec level, to the spanned capabilities or areas at project level; `against` / `verified_at` / `status` are identical everywhere

```text
openspec/
├── knowledges/                     project-global: knowledge spanning capabilities
│   ├── INDEX.md                    pure catalog
│   └── <theme>.md / <theme>.html   conventions, overall architecture, engine constraints
│
├── specs/<capability-path>/
│   └── knowledges/                 capability-scoped: serves this capability's contract
│       ├── INDEX.md                pure catalog
│       └── <theme>.md / <theme>.html
│
└── changes/<name>/attachments/
    ├── INDEX.md                    working memory, not just a catalog
    └── knowledges/                 change-scoped: anything useful while the change runs
        └── <theme>.md / <theme>.html
```

