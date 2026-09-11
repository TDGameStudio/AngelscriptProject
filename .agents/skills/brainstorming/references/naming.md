# Naming Grill

Load this reference when a design or task introduces a new public name, or when apply discovers one the task did not list. Shared by `brainstorming`, `openspec-continue-change` (tasks), and `openspec-apply-change`.

## What counts as a public name

Types (classes, structs, enums, interfaces), modules and namespaces, source and header files, public functions and methods, Automation test identities, Harness routes, OpenSpec capability IDs, and Skill or reference names. Local variables and private helpers are not grilled.

## Before asking

1. Inspect the neighbours: sibling files, the owning module's prefixes and suffixes, existing test identities, and any glossary entry in the draft or in capability knowledge.
2. Derive one convention-backed recommendation and one or two alternatives that differ in a way the user might care about (scope word, verb vs noun, abbreviation vs full word).
3. Check for collisions with existing names in the repository and with well-known engine or standard-library names.

## Round shape

One naming round lists every name the current design or task needs. Like every grill round it opens with a situation brief: which neighbours were inspected, which convention they follow, and what the names are for.

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

Record each settled name in the draft `glossary.md` as `| term | chosen | rejected | reason |`, and in the design's "Vocabulary and Naming" section.

## Into tasks

Every task's **Interfaces** lists the new public names it introduces, with the source (`glossary.md` or the round). A task that introduces a public name without listing it fails the authoring preflight.

## In apply

Apply never asks the user. When implementation requires a new public name the task does not list, choose the convention-derived recommendation you would have put first in a naming round, write `Naming assumed: <name> — <one-line reason>` in the task's **Evidence**, and continue. Verification lists every `Naming assumed` entry so the user reviews them before the task closes; a rejected name is renamed before commit. Frequent assumed names mean the tasks stage skipped the naming round — fix that in planning, not by asking during apply.

Renaming an existing public name is a design decision, not a naming grill; it needs its own round or a Change.
