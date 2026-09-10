# Task DAG Protocol

`tasks.md` is the only current Task DAG. Its top-of-file YAML frontmatter is the sole dependency graph; the Markdown body owns task content and completion. Do not add another graph, graph revision, database, or snapshot copy.

## Graph and node form

See the complete new-format examples in the [Task Card contract](../../openspec/references/tasks.md). Each root checkbox has a short title and four-space owned Markdown. The only machine-readable direct sections are **Files** (one code-formatted path per list item) and **Verification** (one fenced proving command). Full explanation, case tables, signatures and execution steps stay inside the owning task.

Rules:

- One top-level checkbox is one node. Nested steps are ordered lists, never checkboxes.
- `task_graph.version` is `1`. `depends_on` maps each task to its direct prerequisites; quote every task and dependency ID and use `[]` for a root.
- The Graph key set exactly matches the body node IDs. Each body node has a stable `X.Y` ID, `Files`, and one exact verification command.
- Keep Graph keys and body blocks in natural numeric order for people (`1.2` before `1.10`), but order never creates an edge.
- An ID is never reused. A completed node is never unchecked; changed work becomes a new node.
- OpenSpec deterministically validates the Graph and derives each node's `after` and `ready`; Harness consumes that JSON and owns scheduling policy. Never parse YAML again in PowerShell.
- A pending node is ready only when the whole plan is valid and every derived `after` node is complete.
- Ready nodes may run in parallel only when their files, artifacts, and exclusive execution leases are disjoint.
- Update the DAG before starting newly discovered work. Preserve the old node's disposition in a Replan when the plan boundary changed.
- Old inline verify, blockquote Files and body-level After formats are unsupported. An unmigrated record yields explicit diagnostics and no Ready work; migration is a separately scoped action.

## Flexible Task Cards

Before writing or selecting behavior work, use the [ready-to-execute authoring contract](../../openspec/references/tasks.md). A node owns a bounded feature outcome with concrete fixtures, expected RED, interfaces and completion evidence. Tests and implementation can be substantial inside that outcome; neither individual test launches nor an ever-growing subsystem are useful task boundaries.

Use the semantic authoring check in the linked Task contract for Files, handoffs, concrete cases, proving selections and validation baselines; do not maintain a second checklist here. If independent products or hidden prerequisites have accumulated, use an evidence-backed replan before continuing. Do not turn ordinary local failures into Replan. Compatible tasks may share grouped verification through [verification.md](verification.md), but keep separate case-level completion evidence and the existing single DAG.

Optional Task Card detail is ordinary Markdown. After the validated node surface, authors may add only the context that helps execution: intent, constraints, examples, ordered steps, expected output, risks, evidence links, or useful implementation notes. A simple task may need none of these; a difficult task may use extensive sections, lists, tables and code examples. Do not use a compactness target to omit implementation decisions.

Harness does not parse or require those optional sections, labels, or ordering. Do not invent another Task Card schema, encode dependencies in prose, or duplicate completion with nested checkboxes. The frontmatter graph remains the dependency authority, while the body remains readable guidance for agents and people.

Inspect through Harness:

```powershell
Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = 'domain/change' }
```

Do not add a Review node as normal lifecycle cadence. When the user or an external agent explicitly requests a Review and the accepted Task DAG must wait for it, add or retain a node whose verification is Review closure. It is complete only after triage, resolution, any required re-review, and closing or superseding the Review file; report arrival alone is not completion.
