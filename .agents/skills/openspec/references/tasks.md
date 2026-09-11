# Task plan and heading-node cards

Read this reference when writing, validating, or replanning `tasks.md`.

`tasks.md` is the sole execution state and DAG. Its top-of-file YAML frontmatter is the one dependency authority. A level-2 heading with a checkbox names one bounded outcome; the unindented Markdown beneath it, up to the next `##`, is its card. Group headings and document order are presentation, never dependencies.

## Machine-readable surface

- One `## [ ] X.Y Short title` or `## [x] X.Y Short title` heading is one task node. Preserve permanent unique IDs; present them in natural numeric order. A level-2 heading without a checkbox (`## Goal`, `## 2. Parser`) is a header or group heading and owns no metadata.
- The card body is every block until the next level-1 or level-2 heading, written without indentation. Level-3 and deeper headings, lists, tables, quotes, fences and images inside the body stay inside the card.
- `task_graph.version` is `1`; `depends_on` maps each task to its direct prerequisites. Every key and dependency is a directly quoted stable ID. Roots use `[]`; the key set exactly equals the body task set.
- Exactly one direct paragraph `**Files**` is followed by one ```` ```diff ```` fence. Each fence line starts with `+` (create), `-` (delete) or a space (modify), then indentation, then a path segment; text after ` # ` is a comment. A segment ending in `/` is a directory prefix for the deeper-indented lines beneath it; a flat full path is allowed; the literal `none` alone means file-free work. Spaces, commas and Unicode are part of the path. The projection keeps `files` as plain resolved paths and adds `fileRoles` (`path`, `role`).
- Exactly one direct paragraph `**Verification**` is followed by exactly one fenced executable command. Multiline commands retain their line breaks. State working directory, setup and completion criteria in the surrounding prose; other examples belong in a deeper container.
- Labels in a quote, fence or nested example are ordinary content, not metadata. The parser consumes only the heading, the two direct sections and the frontmatter graph.
- Root checkbox list items (`- [ ] X.Y`), inline `— verify:`, `> Files:` and body `> After:` are retired formats and yield `unsupported-task-format` with no Ready work. There is no compatibility parser or silent migration; migrate a record only when a task owns that migration.

## Plan header

After the frontmatter, in this order:

1. `# <Change title>`
2. `## Goal` — one sentence.
3. `## Architecture` — two or three sentences and a `design.md` link when one exists.
4. `## Global constraints` — one line per plan-specific constraint: prerequisite Changes, language or test-identity policy, forbidden substitutes. The last line links `.agents/skills/harness/references/execution-conventions.md`; Harness policy is not repeated.
5. `## File map` (optional) — one ```` ```diff ```` tree for the whole plan; comments end with `· <task ids>`.
6. `## Requirement coverage` — a table mapping every requirement and acceptance condition to task IDs, followed by one line `Self-review <date>: coverage …; placeholders …; symbols …. Record: attachments/data/planning-validation.md`.

Group headings such as `## 1. Parser and release` may follow between cards.

## Card contract

A card is written for a zero-context implementer. Labels are information requirements, not size targets: a label is present because its information is needed, and its content is as long as that information. No word, test, file, time or process-launch quotas.

**Behavior task**, in order:

1. Brief paragraph directly under the heading: what changes and what stays.
2. `**Outcome**` — the accepted behavior and its explicit exclusions.
3. `**Interfaces**` — `Consumes` and `Produces` lists with signatures in code fences. Every new public name (type, module, file, public function, test identity) is followed by its source: the draft `glossary.md`, a naming round, or an existing convention per the [naming grill](../../brainstorming/references/naming.md). Do not invent an established API that has not been inspected; cite `file:line` for consumed symbols. Required whenever the task produces or consumes any symbol.
4. `**Cases**` — a numbered list of named cases, each opening with one header line `N. **Name** — <role> · <kind>` (the `· <kind>` suffix is optional) and a body that carries the literal input, the independently derived expected result and the oracle when a count or invariant is asserted; a plain case is one Given / When / Then clause. Standard roles are `new RED`, `existing control`, `boundary` and `deferred RED until X.Y`; kinds and any custom role or kind word (defined once in `Roles:` / `Kinds:`), the optional `Setup:` and `Replaces:` paragraphs, and every body shape live in the [case catalog](cases.md). A behavior task has at least one `new RED` case; "add complete tests" is not a case.
5. `**Files**` — the diff fence; explain glob exclusions in one sentence after it.
6. `**Verification**` — one fence plus working directory and completion criteria.
7. `**Notes**` (optional) — ordering advice, risks, deferred tuning.
8. `**Evidence**` — appended only after execution.

There is no step-level test-driven-development script in the card: `test-driven-development` and `openspec-apply-change` derive grouped RED/GREEN from the Cases list.

**Document or migration task**: brief paragraph, `**Outcome**`, `**Files**`, `**Verification**`, optional `**Notes**`; Interfaces and Cases are omitted, not left empty.

### Forbidden phrases

A card containing any of these fails preflight: `TBD`, `TODO`, `implement later`, `fill in details`, `add appropriate error handling`, `add validation`, `handle edge cases`, `write tests for the above`, `similar to Task`, `known values`, `existing fixtures`, `preserve behavior` without an example or evidence link, an Interfaces block with no code fence, a type or function referenced but defined in no task and no inspected source.

### Self-review

Before a plan is accepted, record three checks in `attachments/data/planning-validation.md` and index it: every requirement and acceptance condition maps to a task; the placeholder scan is clean; symbol names are consistent across tasks and with the design's vocabulary. The one-line summary goes under `## Requirement coverage`.

### Preflight

`openspec-continue-change` accepts a plan only when the header sections exist, every card has the labels for its kind in order, each behavior card has a `new RED` case and an Interfaces fence when it names a symbol, no forbidden phrase appears, and `planning-validation.md` is indexed. `openspec-apply-change` refuses to start a card that fails the same checks and routes the repair to `openspec-update-change`. Preflight checks presence; the reviewer judges content.

### Semantic authoring check

Follow each card's evidence chain: inspected interface or prerequisite output → concrete case → proving selection → observable completion.

- When reusing existing tests, name the source file and case, retain its actual inputs and results, and distinguish native-host controls, metadata checks and end-to-end execution. Future interfaces and fixtures are named as future work with their producing task.
- Make every case reachable by the proving selector; explain wrapping or an exact shared selection when a case is outside its prefix.
- Inspect the baseline of every record included in a final validation command; name a pre-existing failure and its bounded disposition before claiming the plan can close.
- One node owns the smallest independently acceptable feature outcome, not one test, command, file or commit. Split when one deliverable can pass acceptance while another is rejected; length alone is not a reason to split.

## Complete example

Illustrative Rust API, not a repository feature. It shows a filled behavior card with literal expectations.

````markdown
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

# Declaration policy

## Goal

Reject ambiguous option declarations without producing partial output.

## Architecture

`parse_options` stays the only public boundary; key identity is validated before each declaration is accepted. See `design.md` §2.

## Global constraints

- The exporter schema and the fast/safe mode set do not change.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Duplicate and unknown keys are rejected without partial Options | 1.1 |

Self-review 2026-09-11: coverage complete; no placeholder phrases; symbols consistent with `design.md` §4. Record: `attachments/data/planning-validation.md`.

## [ ] 1.1 Reject ambiguous option declarations without partial output

Duplicate and unknown keys currently pass silently; after this task they return the existing `ConfigError` variants and no `Options`.

**Outcome**

Accept the existing fast/safe modes while rejecting duplicate and unknown keys. A failed parse returns no Options. Excluded: exporter schema changes, additional modes.

**Interfaces**

Consumes (existing, `src/options.rs:12`):

```rust
fn parse_options(text: &str) -> Result<Options, ConfigError>;
enum ConfigError { DuplicateKey(String), UnknownKey(String) }
```

Produces: no new public names.

**Cases**

1. **Fast mode still parses** — existing control
   Given `mode=fast` When parsed Then `Ok(Options { mode: Mode::Fast })`
2. **Safe mode still parses** — existing control
   Given `mode=safe` Then `Ok(Options { mode: Mode::Safe })`
3. **Conflicting duplicate** — new RED
   Given `mode=fast⏎mode=safe` Then `Err(DuplicateKey("mode"))`
4. **Identical duplicate is still a duplicate** — boundary
   Given `mode=safe⏎mode=safe` Then `Err(DuplicateKey("mode"))`
5. **Unknown key carries the offending name** — new RED
   Given `mdoe=fast` Then `Err(UnknownKey("mdoe"))`
6. **No partial success** — new RED
   Given `mode=fast⏎mdoe=safe` Then `Err(UnknownKey("mdoe"))` and no Options
7. **Reparse after error leaves no state** — new RED · sequence
   1. parse `mode=fast⏎mdoe=safe` → `Err(UnknownKey("mdoe"))`
   2. parse `mode=safe` with the same parser → `Ok(Options { mode: Mode::Safe })`; oracle: the accepted-key set is empty between calls

`⏎` denotes one input newline. Expected values are written by hand, not produced by the implementation under test.

**Files**

```diff
 src/options.rs          # key identity check before acceptance
+tests/option_policy.rs  # cases 1-7
```

**Verification**

Run from the package root.

```sh
cargo test option_policy
```

All seven cases execute and pass; both error variants carry the actual key; the public Result boundary is unchanged.

**Notes**

Track accepted keys in a set so case 4 is rejected by identity, not by value comparison.
````

## Execution and validation

Choose proving commands through [impact-scoped verification](../../harness/references/verification.md). Keep every owned path in Files. Newly discovered independent products, hidden prerequisites or an insufficient proving selection invalidate the boundary: revise pending nodes through the update lifecycle. Ordinary local debugging stays inside the task.

A completed task is never unchecked and its ID is never reused. Replans add new IDs; old-task dispositions are `preserved`, `superseded`, `cancelled` or `needs_followup`. A completed task needing follow-up remains checked and points to its new task. No GraphRevision, separate DAG file, Mermaid source of truth or hidden status database.

```text
Done     = [x]
Ready    = valid whole plan + [ ] + all direct prerequisites Done
Blocked  = [ ] + at least one prerequisite incomplete
Parallel = Ready + disjoint Files/artifacts/resource leases
```

An invalid plan exposes diagnostics and **no Ready work**, including otherwise independent tasks. OpenSpec owns parsing and graph validation; its `tasks[].after/ready` JSON remains stable. Harness owns workspace selection and scheduling and must not duplicate a YAML or Markdown parser.
