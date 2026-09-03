# Knowledge Promotion

Load this reference only when a change produces a reusable learning or when capability knowledge is created, updated, indexed, or retired.

## Ownership levels

```text
change evidence
  -> capability knowledge plus knowledges/INDEX.md
  -> AGENTS project instruction only for cross-capability invariants
```

- Change attachments retain snapshot-specific Reviews, issues, Replans, talks, and data.
- `attachments/knowledges/` retains change-local reusable candidates, including accepted exploration insights and visuals, until their disposition is decided.
- `openspec/specs/<domain>/<capability>/knowledges/` retains concise guidance reused by later work on that capability.
- `AGENTS.md` retains only stable rules that apply across capabilities and materially change project-wide agent behavior.

Do not create a project-level `openspec/knowledges/` tree. Do not copy chronology, transient paths, machine data, hashes, or incident trivia into capability knowledge.

## Exploration candidates

An accepted pre-Change handoff may nominate a `💡 Knowledge candidate:` but Explore itself stays read-only. After the target Change exists, create a change-local candidate only when it has evidence, an application boundary, and plausible reuse across tasks or later work. Preserve the useful table or text diagram when it carries part of the reusable model; discard temporary question state and transcript prose.

The candidate is not current requirements or execution state. Copy settled truth into proposal/spec/design/tasks, index the candidate in the same edit, and record its `candidate | promoted | superseded | retired` disposition in `attachments/INDEX.md`. Emoji is optional presentation; headings, labels, evidence, and INDEX status remain authoritative.

## Capability INDEX

Every capability `knowledges/` directory has one `INDEX.md`, and every other knowledge file appears in it exactly once. Each entry includes:

- a concise summary;
- the requirement or capability it serves;
- the originating change attachment or other provenance;
- a status such as `current`, `superseded`, or `retired`.

INDEX is the only default entry; load the linked knowledge file only when the current task needs it.

## Admission and promotion

Promote only after evidence establishes the finding, repair and regression verification pass, required re-review closes, and the learning proves reusable beyond one task. Archive never promotes automatically.

Copy the generalized learning from the change into capability knowledge and keep the archived original frozen. Record source and status in the capability INDEX. If a later change invalidates the guidance, update or supersede it through that later change while retaining provenance; do not rewrite an archive.
