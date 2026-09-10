# Structured document ownership

## Accepted decisions

- A top-level task is `- [ ] X.Y Title`. Its details use four spaces; Files is a direct paragraph label followed by a list of code-formatted paths, and Verification is a direct label followed by one fenced executable command. Labels are exactly `**Files**` and `**Verification**`.
- Preserve the existing TaskNode JSON fields. The command retains internal newlines. Metadata missing, duplicate, detached or expressed in the retired dialect yields an exact diagnostic and no Ready nodes. The sole dependency graph remains frontmatter version 1; there is no legacy After fallback.
- Use a CommonMark event/source-range parser for document container boundaries. Rich content is retained as original Markdown; headings, task samples, quoted labels and code fences do not become unrelated structure.
- Specification structural headings and behavior clauses are recognized only at the correct container depth. Each scenario requires one WHEN and THEN; supplementary detail belongs to its immediately preceding clause. Preserve exact complete raw cards during semantic synchronization.
- Expanded content has no fixed length limit. Default task reading order is Outcome, Context and interfaces, Cases, Implementation, Files, Verification, and postexecution Evidence. Mechanical tasks may combine explanatory sections without omitting decision-critical information.
- Scope is new rules/templates/parser/examples and local package cutover only. Existing business tasks/specs and archives remain untouched. Historical full-library validation is not a new-format acceptance gate.

## Bootstrap and rollout

The installed 0.8.1 package can only schedule the old task surface. This newly created implementation record temporarily uses that surface so current Harness can establish Ready work. After the new parser and package are verified, convert only this implementation record to the accepted new format. No production compatibility branch is retained. Tests that generate tasks must generate the new surface; tests of historical rejection keep literal old input as negative controls.

## Verification

Observe new task parsing and new scenario ownership failures before implementation. Reuse existing graph cases after migrating their fixture representation, retaining independent expected IDs, edges and statuses. Validate documentation generation through the same independent raw requests before and after guidance edits. Package gates include the complete Rust test set, command docs, static analysis and reproducible Release build. Harness proofs use hermetic new-format records and preserve explicit known old-record migration diagnostics.
