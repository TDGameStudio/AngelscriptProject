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

An accepted pre-Change handoff may nominate a `💡 Knowledge candidate:` but brainstorming writes nothing outside its draft. `openspec-create-change` creates the change-local candidate once the user confirmed it in the carryover round and it has evidence, an application boundary, and plausible reuse across tasks or later work. Preserve the useful table or text diagram when it carries part of the reusable model; discard temporary question state and transcript prose.

The candidate is not current requirements or execution state. Copy settled truth into proposal/spec/design/tasks, index the candidate in the same edit, and record its `candidate | promoted | superseded | retired` disposition in `attachments/INDEX.md`. Emoji is optional presentation; headings, labels, evidence, and INDEX status remain authoritative.

## Capability INDEX

Every capability `knowledges/` directory has one `INDEX.md`, and every other knowledge file appears in it exactly once. Each entry includes:

- a concise summary;
- the requirement or capability it serves;
- the originating change attachment or other provenance;
- a status such as `current`, `superseded`, or `retired`.

INDEX is the only default entry; load the linked knowledge file only when the current task needs it.

## Admission and promotion

Promote only after evidence establishes the finding and its reuse. Admission depends on the kind of claim and existing authority:

- A repair-derived learning needs established behavior/root cause, the selected repair and its appropriate regression verification. An unclear explanation alone is not that evidence.
- A factual explanation may be admitted under an already authorized documentation/improvement scope when inspected source, current contract and a representative example establish its truth and reuse. Record those sources, application boundary and checks; do not invent a failure/repair or require unrelated code RED/GREEN.
- An unclear intended contract, conflicting evidence or unselected behavior/Skill change remains a question or candidate in its topic draft. Use explaining-work's [improvement loop](../../explaining-work/references/improvement.md) and normal scope/handoff rules before changing behavior. Capture alone is not publication authority.

For either admitted kind, read the existing capability INDEX first, update an applicable article instead of duplicating it, and index new files exactly once. A later explanation proves reuse by actually reading the updated INDEX/entry and applying its relevant model against current source/spec. Review is not an admission prerequisite. Archive never promotes automatically or resolves pending questions.

Copy the generalized learning from the change into capability knowledge and keep the archived original frozen. Record source and intended final status in the capability INDEX before admission. If an explicitly requested Review includes that knowledge, materialize the exact intended file and INDEX entry before its immutable snapshot; later semantic changes remain outside that report and require the requester to review a new snapshot if the request still applies. If a later Change invalidates the guidance, update or supersede it through that later Change while retaining provenance; do not rewrite an archive.
