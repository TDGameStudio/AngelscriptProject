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

  > Context: Preserve the public parser contract while rejecting ambiguous input.

  > Inputs: The accepted grammar and the failing fixture from exploration.

  > Produces: A parser change and focused regression coverage.

  > Constraints: Do not widen the grammar or change diagnostics outside this boundary.

  1. Add the failing behavior test and observe the expected failure.
  2. Implement the smallest passing change.
  3. Run the exact verification command.
```

Rules:

- One top-level checkbox is one DAG node. Nested steps are ordered-list items, never checkboxes.
- `task_graph.version` is `1`; `depends_on` is incoming adjacency (`task -> direct prerequisites`).
- Every body task ID appears exactly once as a quoted Graph key, every dependency ID is quoted, and roots use `[]`.
- The Graph key set exactly matches the body task ID set. Every task body has a permanent unique `X.Y` ID, a one-line node statement with an exact verify command or observable outcome, and a `Files:` line.
- Present Graph keys and task blocks in natural numeric order, but never infer dependencies from their order.
- IDs are never reused. A completed task is never unchecked.
- A replan adds new IDs. A completed task that needs more work keeps `[x]`, receives `needs_followup`, and points to a new task.
- Allowed old-task dispositions are `preserved`, `superseded`, `cancelled`, and `needs_followup`.
- Historical body-level `After` records are read-only compatibility. A current task plan writes frontmatter only, and mixed syntax is invalid.
- No `> Graph:` line, Mermaid source of truth, separate `task-dag.yaml`, GraphRevision, snapshot tree, or hidden task database.

## Authoring quality

Build a file, artifact, and exclusive-resource map before drawing dependencies. Each top-level node is the smallest independently reviewable outcome, not one command and not an unbounded work package. A zero-context implementer must be able to execute it from the record alone.

Every node states:

- on its one-line checkbox statement, the concrete outcome plus one exact verification command or directly observable result;
- on a following `> Files:` line, exact paths or an explicitly bounded package-wide glob with exclusions.

Choose that command through the Harness [impact-scoped verification policy](../../harness/references/verification.md): start with the smallest reliable scope that directly proves the node. When broader verification is required, state the concrete reason in ordinary Task Card or completion-evidence prose; do not add a parser field or make aggregate profiles universal gates.

Add only the concise detail that helps a zero-context implementer. A Task Card may freely use ordinary Markdown such as short prose, `> Context:`, `> Inputs:`, `> Produces:`, `> Constraints:`, numbered steps, examples, or other useful notes. These are authoring aids, not parser fields or a rigid template. When another node depends on an interface, artifact, or state, explain that handoff somewhere in the card using the clearest compact form.

Nested numbered steps are real execution order, including RED/GREEN/refactor when behavior changes; they are not placeholder examples. Do not use `TBD`, "appropriate handling", "similar to Task N", or other prose that delegates design back to the implementer.

Before accepting a plan, map every requirement and acceptance condition to at least one node, then self-review IDs, names, dependencies, interfaces, `Files`, verification, and spec coverage for consistency. A plan-only delivery is complete only when `tasks.md` is ready to execute without another planning pass.

Derived state:

```text
Done     = [x]
Ready    = [ ] and every derived after dependency is Done
Blocked  = [ ] and at least one derived after dependency is not Done
Parallel = Ready plus disjoint Files, generated artifacts, and resource leases
```

OpenSpec owns deterministic frontmatter/Markdown parsing and returns the stable `tasks[].after/ready` JSON contract. Harness owns workspace selection and scheduling; it must not duplicate a YAML parser. Validation rejects malformed or duplicate IDs, Graph/body mismatch, unquoted IDs, missing/self edges, unknown dependencies, cycles, a done task depending on pending work, mixed syntax, and missing `Files`/verify. Fenced examples do not create task metadata. The current in-progress task is session state, not a second committed status field.
