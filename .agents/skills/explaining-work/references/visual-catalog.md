## Use the preserved catalog

- Select only the category and section needed for the explanation. All nine existing ASCII categories and examples remain available.
- Paths below are relative to the Skill root; from this reference, use `../ascii/`. Boxed examples remain specialized references; prefer unboxed variants in ordinary conversation.
- Examples illustrate shapes. Verify code symbols, relationships and version behavior against the subject before using them as facts.

## Diagram catalog for the ascii/ directory

- Each category below maps to one file; each "Section heading" is a `##` heading inside that file, exact text — use it as the search key.

## Code-shaped views — `ascii/code-shaped-views.md`

| Diagram type                     | Section heading                                                |
|----------------------------------|----------------------------------------------------------------|
| Simplified code with file banner | Show logic or an algorithm as simplified code                  |
| Skeleton struct / union excerpt  | Show the essentials of a struct or union as a skeleton excerpt |
| Phase-grouped annotated function | Show a long function as phase-grouped annotated code           |

## Calls & control flow — `ascii/calls-control-flow.md`

| Diagram type                             | Section heading                                                |
|------------------------------------------|----------------------------------------------------------------|
| Call tree (plus numbered-step variant)   | Show runtime control flow as a call tree                       |
| Flowchart, guard chain                   | Show branches, guards, and early exits as a flowchart          |
| Nested decision tree                     | Show one decision with many outcomes as a nested decision tree |
| Loop flowchart with back-edge            | Show a polling or retry loop as a flowchart with a back-edge   |
| Fork-join flowchart                      | Show parallel work that must rejoin as a fork-join flowchart   |
| Cascade / fallback flowchart             | Show ordered fallback paths as a cascade flowchart             |
| Algorithm sketch (structured pseudocode) | Show a core loop or heuristic as an algorithm sketch           |

## Interaction & concurrency — `ascii/interaction-concurrency.md`

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

## State & lifecycle — `ascii/state-lifecycle.md`

| Diagram type               | Section heading                                   |
|----------------------------|---------------------------------------------------|
| State machine              | Show a lifecycle as a state machine               |
| Before / After buffer pair | Show one buffer mutating as a Before / After pair |

## Structure & architecture — `ascii/structure-architecture.md`

| Diagram type                    | Section heading                                                     |
|---------------------------------|---------------------------------------------------------------------|
| Member / composition tree       | Show what a type contains as a member / composition tree            |
| Inheritance tree with overrides | Show a class hierarchy with overrides as an inheritance tree        |
| Layered architecture spine      | Show a cache / storage stack as layered architecture                |
| Double-line banner zones        | Show conceptual zones with embedded sketches as double-line banners |
| Dependency map                  | Show module boundaries as a dependency map                          |
| Shallow file tree               | Show file responsibility or a broad refactor as a shallow file tree |

## Pipelines & phases — `ascii/pipelines-phases.md`

| Diagram type                             | Section heading                                                                  |
|------------------------------------------|----------------------------------------------------------------------------------|
| Top-down stage pipeline                  | Show frame stages as a top-down stage pipeline                                   |
| Banner-separated phase pipeline          | Show ordered execution phases as a banner-separated phase pipeline               |
| Boxed pass pipeline with resource access | Show a sequence of GPU / RDG passes as boxed steps with per-pass resource access |
| Threshold bar                            | Show policy bands over a continuous value as a threshold bar                     |
| Width-proportional profile bar           | Show measured time cost as a width-proportional profile bar                      |

## Data & format layout — `ascii/data-format-layout.md`

| Diagram type                                | Section heading                                                      |
|---------------------------------------------|----------------------------------------------------------------------|
| Bit-field / byte-offset box                 | Show packed bits or memory layout as a field box                     |
| 2D coordinate-annotated layout              | Show regions packed into a 2D space as a coordinate-annotated layout |
| Line-numbered spec box (grammar / bytecode) | Show a grammar or text format as a line-numbered spec box            |
| Pointer diagram (ring buffer, free list)    | Show linked nodes or a ring buffer as a pointer diagram              |

## Changes & comparisons — `ascii/changes-comparisons.md`

| Diagram type                  | Section heading                                                               |
|-------------------------------|-------------------------------------------------------------------------------|
| Diff-marked file tree         | Show a file-layout change as a diff-marked file tree                          |
| Diff-marked call tree         | Show a call-tree or call-stack change as a diff-marked call tree              |
| Diff-marked pseudocode        | Show a state or control-flow change as diff-marked pseudocode                 |
| Side-by-side call stacks      | Show the same function reached from N entry paths as side-by-side call stacks |
| Crash stack with FIX footer   | Show a crash postmortem as a boxed stack with collapse and FIX footer         |
| Design-option comparison pair | Show design options side by side as a comparison pair                         |

## Marking & annotation — `ascii/marking-annotation.md`

| Diagram type                | Section heading                                                      |
|-----------------------------|----------------------------------------------------------------------|
| Colored Unicode row markers | Mark emphasis, status, or severity on tree rows with colored Unicode |
| External callouts           | Put long annotations outside the figure as external callouts         |
