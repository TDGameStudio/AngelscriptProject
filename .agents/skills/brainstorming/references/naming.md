# Naming Grill

Load this reference when a design or task introduces a new public name, or when apply discovers one the task did not list. Shared by `brainstorming` and `openspec-apply-change` (planning in `Ensure plan`, discovery during implementation).

## What counts as a public name

Types (classes, structs, enums, interfaces), modules and namespaces, source and header files, public functions and methods, Automation test identities, Harness routes, OpenSpec capability IDs, and Skill or reference names. Local variables and private helpers are not grilled.

## Before asking

1. Inspect the neighbours: sibling files, the owning module's prefixes and suffixes, existing test identities, and any glossary entry in the draft or in capability knowledge.
2. Derive one convention-backed recommendation and one or two alternatives that differ in a way the user might care about (scope word, verb vs noun, abbreviation vs full word).
3. Check for collisions with existing names in the repository and with well-known engine or standard-library names.

## Round shape

Track required names in their owning design. Related independent naming decisions may share a round per [grilling.md](grilling.md); dependent names wait. Send the situation brief first: inspected neighbours, conventions, responsibility and scope. The example below is a content guide; use the host's permitted question mechanism.

```text
Round <N> — Naming

Situation
📌 Pinned fact: Types/ holds `FAngelscriptTypeDatabase`, `FAngelscriptTypeIdTable`; suffix `Table` = flat lookup, `Database` = owning store. 🔗 Source: Plugins/Angelscript/Source/AngelscriptCode/Public/Types/.
Why now: design section 3 settled the ownership table; its class and header need names before tasks are written.

❔ Open decision: N1 — <what the thing is>
    A. `FAngelscriptTypeOwnershipTable`  (matches `FAngelscript*Table` in Types/)
    B. `FAngelscriptOwnedTypeRegistry`   (emphasizes registration; no sibling uses Registry)
👉 Recommendation: A — <reason>.
📌 Pinned fact: siblings are `FAngelscriptTypeDatabase`, `FAngelscriptTypeIdTable`. 🔗 Source: <path>.
```

Record each settled name in designs/<scope>/glossary.md as `| term | chosen | rejected | reason |`, and in that design's Vocabulary and Naming section. Topic glossary.md holds shared vocabulary; include this design's required shared terms with provenance before export. Legacy flat designs retain their glossary path. Draft explanations default to the user's conversation language unless explicitly specified otherwise; Change exports use English and preserve identifiers.

## Into tasks

Every task's **Interfaces** lists the new public names it introduces, with the source (`glossary.md` or the round). A task that introduces a public name without listing it fails the authoring preflight.

## In apply

Apply never asks the user. When implementation requires a new public name the task does not list, choose the convention-derived recommendation you would have put first in a naming round, write `Naming assumed: <name> — <one-line reason>` in the task's **Evidence**, and continue. Verification lists every `Naming assumed` entry so the user reviews them before the task closes; a rejected name is renamed before commit. Frequent assumed names mean the tasks stage skipped the naming round — fix that in planning, not by asking during apply.

Renaming an existing public name is a design decision, not a naming grill; it needs its own round or a Change.
