---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

# <!-- Change title -->

<!-- Replace every comment with inspected interfaces and literal cases.
     Read .agents/skills/openspec/references/tasks.md in this project.
     Keep related tests, implementation and wiring in one bounded outcome.
     Add more permanent IDs and exact dependency entries when needed. -->

## Goal

<!-- One sentence. -->

## Architecture

<!-- Two or three sentences and a design.md link when one exists. -->

## Global constraints

- <!-- One line per plan-specific constraint: prerequisite Changes, test identities, forbidden substitutes. -->
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| <!-- requirement or acceptance condition --> | 1.1 |

Self-review <!-- date -->: coverage <!-- complete -->; placeholders <!-- none -->; symbols <!-- consistent with design -->. Record: `attachments/data/planning-validation.md`.

## 1. <!-- Deliverable group -->

## [ ] 1.1 <!-- Short outcome title -->

<!-- Brief paragraph: what changes and what stays. -->

**Outcome**

<!-- State the accepted behavior and its explicit exclusions. -->

**Interfaces**

Consumes:

```text
<!-- inspected signatures with file:line -->
```

Produces:

```text
<!-- new signatures; every new public name followed by its source (glossary.md, naming round, convention) -->
```

**Cases**

1. **<!-- case name -->** — new RED
   Given <!-- literal input --> When <!-- action --> Then <!-- independently derived expected result -->
2. **<!-- case name -->** — existing control
   Given <!-- input --> Then <!-- unchanged result -->
3. **<!-- case name -->** — new RED · <!-- kind: sequence | example-table | invariant | absence | measurement | golden, or a word defined in Kinds:; omit for a plain behavior case -->
   <!-- body shaped per .agents/skills/openspec/references/cases.md -->

**Files**

```diff
 path/to/implementation
+path/to/tests
```

**Verification**

<!-- State exact working directory and setup. Choose the smallest proving
scope through the project's impact policy; explain any broader selection. -->

```sh
<exact executable proving command>
```

<!-- State concrete completion conditions and required case coverage.
Add Evidence only after real execution, with actual results and any shared
run's task-to-case mapping. Body lines are not indented. -->
