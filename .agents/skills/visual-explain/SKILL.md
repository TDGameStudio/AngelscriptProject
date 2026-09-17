---
name: visual-explain
description: "Use whenever a reply explains architecture, a workflow, state or lifecycle, memory layout, call chains, or a decision with three or more related branches — draw it with a concise ASCII diagram, code-shape sketch, or focused HTML artifact instead of prose alone. Project style: no enclosing boxes, tree chains with // sentence comments."
---

## guidance

- Help the user understand the current topic of conversation visually.
  - Skip the preamble and keep prose brief.
  - Pick the smallest view that makes the key point clear.
- Trigger proactively when the explanation contains three or more important relationships or mappings, dependent branches, a multi-step sequence or state transition, hierarchy or layout, or a decision structure that is materially easier to scan than prose.
- Also trigger when the user explicitly asks to visualize or compare.
- Do not add a visual for a single fact, a trivial one-step action, a simple edit, or information already clear in a short paragraph or list.
- Prefer a lightweight inline text diagram; create a focused HTML artifact only when exploration, navigation, interaction, or export materially helps.
- Place each visual next to the short text it supports.
  - Keep only the calls, files, props, states, and boundaries needed to answer the user's current question or the options to resolve the current discussion point.
- You may use one visual, you may use several, it is unlikely you will use all of them.
  - Use your judgement and don't overwhelm the user.
  - Treat every example as a shape hint, not a fill-in-the-blanks form.
- A proven pairing for walking through a function or class: a call tree for navigation plus a simplified-code excerpt for depth — the tree shows where, the excerpt shows how.
- Project preference: no enclosing boxes or frames in ASCII figures.
  - Prefer indented trees (`└─`, `├─`, `│`) with bracketed edge labels (`[calls]`, `[member]`, `[inherits]`) and an aligned `//` sentence comment per node instead of file:line columns.
  - Use a boxed pattern from the catalog only when the user asks for it.
- All ASCII example figures live in the `ascii/` directory next to this file: one file per category, one worked example per diagram type.
  - Pick the diagram types you need from the catalog below, then read only the matching category file — or just the one fragment, by searching that file for the exact section heading text and reading until the next heading.
  - Never read all category files.

## Diagram catalog for the ascii/ directory

- Each category below maps to one file; each "Section heading" is a `##` heading inside that file, exact text — use it as the search key.

### Code-shaped views — `ascii/code-shaped-views.md`

| Diagram type                     | Section heading                                                |
|----------------------------------|----------------------------------------------------------------|
| Simplified code with file banner | Show logic or an algorithm as simplified code                  |
| Skeleton struct / union excerpt  | Show the essentials of a struct or union as a skeleton excerpt |
| Phase-grouped annotated function | Show a long function as phase-grouped annotated code           |

### Calls & control flow — `ascii/calls-control-flow.md`

| Diagram type                             | Section heading                                                |
|------------------------------------------|----------------------------------------------------------------|
| Call tree (plus numbered-step variant)   | Show runtime control flow as a call tree                       |
| Flowchart, guard chain                   | Show branches, guards, and early exits as a flowchart          |
| Nested decision tree                     | Show one decision with many outcomes as a nested decision tree |
| Loop flowchart with back-edge            | Show a polling or retry loop as a flowchart with a back-edge   |
| Fork-join flowchart                      | Show parallel work that must rejoin as a fork-join flowchart   |
| Cascade / fallback flowchart             | Show ordered fallback paths as a cascade flowchart             |
| Algorithm sketch (structured pseudocode) | Show a core loop or heuristic as an algorithm sketch           |

### Interaction & concurrency — `ascii/interaction-concurrency.md`

| Diagram type                                                          | Section heading                                                       |
|-----------------------------------------------------------------------|-----------------------------------------------------------------------|
| Sequence diagram (wide, round-trip self-loop, narrow, elbow variants) | Show cross-system interaction as a sequence diagram                   |
| Vertical ownership lanes                                              | Show data ownership crossing threads as vertical lanes                |
| Compact thread timeline                                               | Show waits, stalls, and hand-offs as a compact thread timeline        |
| Worker timeline pair (blocking vs pipe)                               | Show a blocking wait versus a pipe dependency chain on workers        |
| Pipe-merge dependency timeline                                        | Show parallel pipes merging into one task as a dependency timeline    |
| Teardown fence timeline                                               | Show cross-thread teardown ordering as a fence timeline               |
| Atomic hand-off state trace                                           | Show an atomic hand-off race as a state trace                         |
| Boxed multi-thread swimlane (heavyweight)                             | Show frames in flight across threads as a boxed multi-thread swimlane |

### State & lifecycle — `ascii/state-lifecycle.md`

| Diagram type               | Section heading                                   |
|----------------------------|---------------------------------------------------|
| State machine              | Show a lifecycle as a state machine               |
| Before / After buffer pair | Show one buffer mutating as a Before / After pair |

### Structure & architecture — `ascii/structure-architecture.md`

| Diagram type                    | Section heading                                                     |
|---------------------------------|---------------------------------------------------------------------|
| Member / composition tree       | Show what a type contains as a member / composition tree            |
| Inheritance tree with overrides | Show a class hierarchy with overrides as an inheritance tree        |
| Layered architecture spine      | Show a cache / storage stack as layered architecture                |
| Double-line banner zones        | Show conceptual zones with embedded sketches as double-line banners |
| Dependency map                  | Show module boundaries as a dependency map                          |
| Shallow file tree               | Show file responsibility or a broad refactor as a shallow file tree |

### Pipelines & phases — `ascii/pipelines-phases.md`

| Diagram type                             | Section heading                                                                  |
|------------------------------------------|----------------------------------------------------------------------------------|
| Top-down stage pipeline                  | Show frame stages as a top-down stage pipeline                                   |
| Banner-separated phase pipeline          | Show ordered execution phases as a banner-separated phase pipeline               |
| Boxed pass pipeline with resource access | Show a sequence of GPU / RDG passes as boxed steps with per-pass resource access |
| Threshold bar                            | Show policy bands over a continuous value as a threshold bar                     |
| Width-proportional profile bar           | Show measured time cost as a width-proportional profile bar                      |

### Data & format layout — `ascii/data-format-layout.md`

| Diagram type                                | Section heading                                                      |
|---------------------------------------------|----------------------------------------------------------------------|
| Bit-field / byte-offset box                 | Show packed bits or memory layout as a field box                     |
| 2D coordinate-annotated layout              | Show regions packed into a 2D space as a coordinate-annotated layout |
| Line-numbered spec box (grammar / bytecode) | Show a grammar or text format as a line-numbered spec box            |
| Pointer diagram (ring buffer, free list)    | Show linked nodes or a ring buffer as a pointer diagram              |

### Changes & comparisons — `ascii/changes-comparisons.md`

| Diagram type                  | Section heading                                                               |
|-------------------------------|-------------------------------------------------------------------------------|
| Diff-marked file tree         | Show a file-layout change as a diff-marked file tree                          |
| Diff-marked call tree         | Show a call-tree or call-stack change as a diff-marked call tree              |
| Diff-marked pseudocode        | Show a state or control-flow change as diff-marked pseudocode                 |
| Side-by-side call stacks      | Show the same function reached from N entry paths as side-by-side call stacks |
| Crash stack with FIX footer   | Show a crash postmortem as a boxed stack with collapse and FIX footer         |
| Design-option comparison pair | Show design options side by side as a comparison pair                         |

### Marking & annotation — `ascii/marking-annotation.md`

| Diagram type                | Section heading                                                      |
|-----------------------------|----------------------------------------------------------------------|
| Colored Unicode row markers | Mark emphasis, status, or severity on tree rows with colored Unicode |
| External callouts           | Put long annotations outside the figure as external callouts         |
