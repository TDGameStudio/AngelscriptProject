# tasks.md — On-Disk Format

## Dependency Graph

- Default order needs no annotation: tasks run top-to-bottom within a group, groups run in numerical order; add a `> Graph:` quote line at the top of the file **only when groups may run in parallel** — a strictly sequential file carries no graph line at all
- When one line gets hard to read, split into multiple `> Graph:` lines, one chain per line (see template)
- Two groups may share a brace only if their file maps are disjoint and neither consumes an interface the other defines
- Task-level exception: when a task's real dependency is not its direct predecessor, note `> 🔗 after: <task IDs>` in its quote block; the graph line stays group-level
- A DAG with nesting or many joins does not fit one-liners — switch to a fenced `mermaid` block instead

## Task Content

A task is never just one sentence. Before it counts as written, its text must let an engineer with zero context answer: **where to change** (exact paths), **what not to touch** (constraints, scope edges), **how to self-verify** (exact command or observable outcome).

- Every task line ends with `— verify: <exact command / observable result / delivered artifact>`; for a task with sub-steps, the last sub-step is the verification step
- A multi-step task gets `X.Y.Z` sub-steps, each a single action; sub-steps count toward progress, so only write real ones — no illustrative placeholders
- Long-lived supplements go in a quote block under the task line — plain prose only, **never a checkbox after `>`**
- Optionally prefix a quote line with a marker for scannability — shared vocabulary in skill `openspec-explore/markers.md`; not mandatory, plain prose is fine
- HTML comments are fill-in scaffold only — delete them when the slot is filled

## Template

The full on-disk template (graph line, quote-block markers, verify suffix, group structure) is **owned by the CLI workflow**, not this skill: read `openspec/workflows/<workflow>/templates/tasks.md`, or run `openspec instructions tasks` against the active change via `.agents/skills/hardness/scripts/openspec.ps1`.
