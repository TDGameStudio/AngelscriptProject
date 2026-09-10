# Task DAG and Rich Markdown Cards

Read this reference when writing, validating, or replanning `tasks.md`.

`tasks.md` is the sole execution state and DAG. Its top-of-file YAML frontmatter is the one dependency authority. A short top-level checkbox names one bounded outcome; its indented Markdown card supplies everything needed to execute it. Headings and document order are presentation, never dependencies.

## Machine-readable surface

- One root `- [ ] X.Y Short title` or `- [x] X.Y Short title` is one task. Preserve permanent unique IDs; present them in natural numeric order.
- `task_graph.version` is `1`; `depends_on` maps each task to its direct prerequisites. Every key and dependency is a directly quoted stable ID. Roots use `[]`; the key set exactly equals the body task set.
- All direct task detail blocks start with **four spaces**, with a blank line before each paragraph, list, table, quote, heading, or fence. Indent deeper content beneath its own Markdown container. Do not rely on lazy paragraph continuation.
- Exactly one direct paragraph `**Files**` owns a list of individually code-formatted paths or bounded globs. Each list item contains one path; spaces, commas and Unicode are part of the path, not separators. Use the literal `none` only for genuinely file-free work. Explain glob exclusions in ordinary prose.
- Exactly one direct paragraph `**Verification**` owns exactly one fenced executable command. Multiline commands retain their line breaks. State working directory, setup, expected exit/results and task-to-case mapping in accompanying prose. Other examples belong outside Verification or in a deeper example container.
- Labels in a quote, fence, nested example or nested list are ordinary content, not task metadata. The parser consumes only the two direct sections above and the root checkbox/graph. All other card content remains ordinary Markdown.
- A detached unindented paragraph/list/fence after a task is an ownership error. Put shared context before the first task. Use root headings to organize groups, not to detach task details.
- Old inline `— verify:`, old `> Files:` and body `> After:` metadata are unsupported; there is no compatibility parser or silent migration. Do not rewrite existing business or archive records unless explicitly tasked with migrating them.

## Write for a zero-context implementer

Start from the information required to make the task executable, not a length target. Detail may be substantial. A reader should understand the goal, actual interfaces, inputs, expected results, implementation order and proof without reverse-engineering another task or making deferred design decisions.

The default reading order is **Outcome → Context and interfaces → Cases → Implementation → Files → Verification**. Add **Evidence** only after work has actually run. These are useful navigation labels, not a mandatory field matrix: combine or rename non-machine sections when that communicates better. Files and Verification keep their exact names and direct ownership.

For every behavior task, supply:

- The concrete outcome, included behavior, explicit exclusions, current behavior and what changes.
- Actual consumed and produced interfaces: symbol names, signatures/types, artifact shapes and prerequisite handoffs. Explain identity, lifetime, ownership, invariants and failure-state behavior wherever they affect correctness. Name known interfaces; do not invent an established API that has not been inspected.
- Concrete representative inputs with independently derived literal outputs/errors. Include normal, negative and boundary cases that distinguish accepted from rejected implementations. Use a table when the cases have repeated fields; use code, prose or a sequence when those are clearer.
- The missing-behavior cases expected to fail in grouped RED, separately from existing regression controls. “Add complete tests” is not a test plan.
- Ordered test preparation, observed grouped RED, bounded implementation and wiring, grouped GREEN, and relevant refactoring/reverification. Put necessary construction detail here, not in a specification.
- One exact proving command plus completion criteria. If a justified shared run provides proof, record the selection and individual case mapping for this task.

Use prose, nested headings, numbered or unordered lists, fenced code, tables, quotations, links, images, formulas or other supported Markdown when they carry information. Examples may include nested checkbox-shaped Markdown inside an owned example; those are not DAG nodes. Prefer numbered lists for actual execution steps. Do not add empty scaffolding, repeat the title as “detail”, copy whole implementations, or fill optional labels mechanically.

A simple task can be short when its clauses already settle every relevant decision. A complex task should carry its full necessary detail; do not compress it into a one-line slogan, send its missing decisions to generic tail prose, or impose word/test/minute quotas.

### Semantic authoring check

Before handing off a card, follow its evidence chain: inspected interface or prerequisite output -> concrete case -> proving selection -> observable completion. This is an authoring check, not another required section or machine schema.

- When reusing existing tests, name the source file and relevant case, retain its actual inputs/results, and distinguish native-host controls, metadata/operations checks and end-to-end execution. A case name alone does not prove it exercises the boundary required by this task. Future interfaces and fixtures must be identified as future work, with their producing task or construction step.
- Replace phrases such as "known values", "existing fixtures" or "preserve behavior" with the relevant example or an exact evidence link. Representative cases need not enumerate every provider, but coverage beyond them must have an independently defined inventory/oracle and an owner; do not derive expectations from the migrated output.
- Make every required case reachable by the proving selector. Explain reuse/wrapping or an exact shared selection when an existing case is outside that prefix. A future test name is a plan, not proof that discovery or execution already succeeds.
- Inspect the baseline of every existing record included in a final validation command. If preserved content already fails, name the failure and an authorized, bounded disposition before claiming the plan can close. A passing delta does not imply a passing merged target; never silently migrate unrelated records or weaken validation.
- Put repeated setup once before the first task. Keep card-local completion conditions specific to its outcome; a document-only handoff does not inherit product-build or provider-coverage boilerplate. Choose prose, steps or tables for the actual information, not to fill every optional label.

Build the file, artifact and exclusive-resource map before drawing dependencies. One node owns the smallest independently acceptable **feature outcome**, not one test, command, file or commit. Keep related tests, implementation, interface wiring and necessary documentation with their outcome. Split when one deliverable can pass acceptance while another is rejected. Length alone is not a reason to split, and a large unbounded subsystem is not made acceptable by adding more prose.

## Complete example: declaration policy

The following is an illustrative Rust API, not a new repository feature. It shows a filled card with literal expectations; replace the example with the actual inspected domain contract.

````markdown
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

- [ ] 1.1 Reject ambiguous option declarations without partial output

    **Outcome**

    Accept the existing fast/safe modes while rejecting duplicate and unknown
    keys. A failed parse returns no Options. Do not change the exporter schema
    or introduce additional modes.

    **Context and interfaces**

    The public boundary remains:

    ```rust
    fn parse_options(text: &str) -> Result<Options, ConfigError>;
    ```

    Options owns its parsed values. The current parser silently overwrites
    duplicate mode declarations and ignores unknown keys. Preserve the valid
    mode path; replace those two acceptance behaviors with the existing
    ConfigError variants DuplicateKey(String) and UnknownKey(String).

    **Cases**

    | Input | Expected result | Role |
    | --- | --- | --- |
    | `mode=fast` | `Ok(Options { mode: Mode::Fast })` | Existing regression control |
    | `mode=safe` | `Ok(Options { mode: Mode::Safe })` | Existing regression control |
    | `mode=fast\nmode=safe` | `Err(DuplicateKey("mode"))` | New RED case |
    | `mode=safe\nmode=safe` | `Err(DuplicateKey("mode"))` | Duplicate identity, not value conflict |
    | `mdoe=fast` | `Err(UnknownKey("mdoe"))` | Preserve actual offending key |
    | `mode=fast\nmdoe=safe` | `Err(UnknownKey("mdoe"))` and no Options | No partial success |

    In this table `\n` denotes one actual input newline, not two literal
    characters. Assertions call the real parser; expected values must not be
    produced by the implementation under test.

    **Implementation**

    1. Add the six named cases in option_policy and run the proving selection.
       Observe duplicate/unknown cases fail for their missing behavior while
       the two valid-mode controls remain green.
    2. Validate key identity before accepting each declaration. Track accepted
       keys so identical duplicate values are still rejected. Return the
       existing error variant without publishing a partially populated Options.
    3. Run the same group for GREEN. Refactor shared setup only when it leaves
       literal expectations visible, then rerun the selection.

    **Files**

    - `src/options.rs`
    - `tests/option_policy.rs`

    **Verification**

    Run from the Rust package root:

    ```sh
    cargo test option_policy
    ```

    Completion requires all six cases to execute and pass, both error variants
    to carry the actual key, and the public Result boundary to remain unchanged.
````

An independently acceptable exporter receives a separate task with its schema, fixtures and dependency on the Options interface. Expensive tests can share a process without merging outcomes or creating a second graph.

## Execution and validation

Choose proving commands through [impact-scoped verification](../../harness/references/verification.md). Start with the smallest reliable selection that proves the entire task. Explain a broader run's concrete impact reason in ordinary prose; aggregate profiles are not universal gates.

Keep every owned path in Files. Newly discovered independent products, hidden prerequisites or an insufficient proving selection invalidate the relevant boundary: revise pending nodes through the update lifecycle. Ordinary local debugging remains inside the task.

A completed task is never unchecked and its ID is never reused. Replans add new IDs; old-task dispositions are `preserved`, `superseded`, `cancelled` or `needs_followup`. A completed task needing follow-up remains checked and points to its new task. No GraphRevision, separate DAG file, Mermaid source of truth or hidden status database.

```text
Done     = [x]
Ready    = valid whole plan + [ ] + all direct prerequisites Done
Blocked  = [ ] + at least one prerequisite incomplete
Parallel = Ready + disjoint Files/artifacts/resource leases
```

An invalid plan exposes diagnostics and **no Ready work**, including otherwise independent tasks. OpenSpec owns parsing and graph validation; its `tasks[].after/ready` JSON remains stable. Harness owns workspace selection and scheduling and must not duplicate a YAML or Markdown parser.

Before accepting a plan, map every requirement and acceptance condition to a task, check IDs, dependencies, real interfaces, Files, proof and spec coverage, and ensure the record can be executed without another design pass. Record actual commands and outcomes in Evidence only after execution; never prefill successful results.
