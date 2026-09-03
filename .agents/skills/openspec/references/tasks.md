# Task DAG Contract

Read this reference when writing, validating, or replanning `tasks.md`.

`tasks.md` is the sole current execution state and DAG. Its top-of-file frontmatter is the one dependency graph. Headings and Markdown order are presentation only.

```markdown
---
task_graph:
  version: 1
  depends_on:
    "1.2": []
    "2.1": ["1.2"]
---

## 2. Implementation

- [ ] 2.1 Implement the parser boundary — verify: `cargo test parser_boundary`
  > Files: `src/parser.rs`, `tests/parser.rs`

  1. Add the failing behavior test and observe the expected failure.
  2. Implement the smallest passing change.
  3. Run the exact verification command.
```

Rules:

- One top-level checkbox is one DAG node. Nested steps are ordered-list items, never checkboxes.
- `task_graph.version` is `1`; `depends_on` is incoming adjacency (`task -> direct prerequisites`).
- Every body task ID appears exactly once as a quoted Graph key, every dependency ID is quoted, and roots use `[]`.
- The Graph key set exactly matches the body task ID set. Every task body has a permanent unique `X.Y` ID, an exact verify command/outcome, and `Files:`.
- Present Graph keys and task blocks in natural numeric order, but never infer dependencies from their order.
- IDs are never reused. A completed task is never unchecked.
- Replan adds new IDs. A completed task that needs more work keeps `[x]`, receives `needs_followup`, and points to a new task.
- Allowed old-task dispositions are `preserved`, `superseded`, `cancelled`, and `needs_followup`.
- Historical body-level `After` records are read-only compatibility. A current task plan writes frontmatter only, and mixed syntax is invalid.
- No `> Graph:` line, Mermaid source of truth, separate `task-dag.yaml`, GraphRevision, snapshot tree, or hidden task database.

## Authoring quality

Build a file, artifact, and exclusive-resource map before drawing dependencies. Each top-level node is the smallest independently reviewable outcome, not one command and not an unbounded work package. A zero-context implementer must be able to execute it from the record alone.

Every node states:

- the concrete outcome and scope boundary;
- exact paths, or an explicitly bounded package-wide glob with exclusions;
- the interface, artifact, or state it consumes and produces when another node depends on it;
- one exact verification command and the result that proves the outcome.

Nested numbered steps are real execution order, including RED/GREEN/refactor when behavior changes; they are not placeholder examples. Do not use `TBD`, "appropriate handling", "similar to Task N", or other prose that delegates design back to the implementer.

Before accepting a plan, map every requirement and acceptance condition to at least one node, then self-review IDs, names, dependencies, interfaces, `Files`, verification, and spec coverage for consistency. A plan-only delivery is complete only when `tasks.md` is ready to execute without another planning pass.

Derived state:

```text
Done     = [x]
Ready    = [ ] and every derived after dependency is Done
Blocked  = [ ] and at least one derived after dependency is not Done
Parallel = Ready plus disjoint Files, generated artifacts, and resource leases
```

OpenSpec owns deterministic frontmatter/Markdown parsing and returns the stable `tasks[].after/ready` JSON contract. Hardness owns workspace selection and scheduling; it must not duplicate a YAML parser. Validation rejects malformed or duplicate IDs, Graph/body mismatch, unquoted IDs, missing/self edges, unknown dependencies, cycles, a done task depending on pending work, mixed syntax, and missing `Files`/verify. Fenced examples do not create task metadata. The current in-progress task is session state, not a second committed status field.
