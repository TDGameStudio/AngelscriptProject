# Hardness frontmatter Task Graph

## Question

How should `tasks.md` expose an exact DAG that Hardness can recognize without repeating dependency state under every task or creating a second task database?

## Considered forms

- Per-task `After:` is exact and local but hides the overall graph and repeats metadata throughout the body.
- A chain such as `1 -> {2-4} -> 5` is compact but needs a custom range/fork grammar and cannot safely represent arbitrary cross-branch joins without multiple statements.
- Edge objects repeat IDs and need a separate node declaration to distinguish an intentionally independent task from an omitted task.
- Execution stages are only a topological presentation and add false barriers when treated as dependency truth.

## Decision

Use a single YAML frontmatter at the start of `tasks.md`:

```yaml
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
---
```

`depends_on[task]` is the complete set of direct predecessors. Every task appears exactly once, roots use `[]`, IDs are quoted strings, and the Graph key set equals the Markdown checkbox ID set. The body remains the sole home of checkbox status, description, `Files:`, verification, and steps.

Hardness owns discovery, Ready/Blocked selection, Review/Replan policy, and scheduling. The portable OpenSpec CLI remains the deterministic parsing/validation primitive and preserves its `TaskNode.after/ready` JSON output. This keeps Hardness as a static router instead of duplicating a YAML parser or state store.

New/current files use frontmatter. Historical `After:`-only records remain readable; mixed syntax is invalid. Graph keys and Markdown task blocks use natural numeric ID presentation order, but order never implies an edge.

## Consequences

- The immutable 0.7.4 release remains preserved; the new input contract is published as 0.8.0.
- The active dogfood change migrates only after the new parser passes its RED/GREEN and compatibility tests.
- Replan records continue to store semantic node/edge deltas and task hashes, not full graph snapshots.
