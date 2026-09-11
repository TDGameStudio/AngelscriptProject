# Design: heading-node task cards

Draft `harness/task-card-format`, design mode. Decisions from Rounds 1–4; names from `glossary.md` (copied beside this file). Pending user review (checklist step 7).

## 1. Problem

Active `tasks.md` files fall into two bad populations (`findings/current-task-format-audit.md`, copied beside this file): five in the retired inline format (Ready = 0, unexecutable) and two in the current root-checkbox format whose cards are 50–60 lines of prose — Cases as sentence chains, no interface signatures, 3 numbered steps across 24 tasks, `## Task X.Y` headings duplicated above each checkbox, four-space indentation for everything, and a 40–60-line per-plan preamble repeating Harness policy. The authoring contract makes only `Files` and `Verification` machine-checked and leaves every other section optional, so they degrade. The delegates plan (`findings/delegates-tasks-review.md`) shows the deeper failure: symbols deferred into a "finish the design" task because no naming round existed when it was created.

## 2. Scope

One Change, `harness/refactor-task-cards-heading-nodes`, with three parts:

1. **CLI parser and release** (`Tools/openspec`, `.agents/skills/openspec/bin`, command docs): heading nodes, diff Files fence, `file_roles[]`, retirement of the root-checkbox list format, version `0.10.0`.
2. **Authoring contract** (`.agents/skills/openspec/references/tasks.md` and example, `openspec/config.yaml` rules.tasks, `harness/references/task-dag.md`, new `harness/references/execution-conventions.md`, `openspec-continue-change` and `openspec-apply-change` preflight, Skill tests, `harness/core` spec MODIFIED).
3. **Migration** of the 7 active `openspec/changes/angelscript/*/tasks.md` to the heading-node syntax, syntax only.

Non-goals: content enrichment of the five thin plans (their owning Changes run `openspec-update-change` with a naming round), archives (untouched, still validated with their own historical rules), Harness scheduling semantics (`files[]`, `after`, `ready` unchanged), markers/visual-explain files, step-level checkboxes.

## 3. Node syntax (parser contract)

```markdown
## [ ] 2.2 Store explicit named-target payloads and receiver state with managed lifetime

Brief paragraph.

**Outcome** ...
**Interfaces** ...
**Cases** ...
**Files**

```diff
 Plugins/.../source/
   frontend/as_frontend_sema_postfix.cpp     # bind-expression semantics
+  as_callable.h                             # asSCallablePayload
+Plugins/.../NewVersion/Delegates/PayloadTests.cpp   # cases 1-9
```

**Verification**

```powershell
<one command>
```

**Notes** ...
```

Rules the parser enforces:

- A node is a level-2 heading whose text starts with `[ ] ` or `[x] ` followed by `X.Y ` and a title. Body = all blocks until the next level-2 or level-1 heading. Level-2 headings without a checkbox (`## 2. Executable callable model`, header sections) are ignored as groups; their content belongs to no node and must not contain `**Files**`/`**Verification**` paragraphs (else `invalid-task-node`).
- `**Files**` is a direct paragraph followed by one ```` ```diff ```` fence. Each fence line: first character `+` (create), `-` (delete) or space (modify); then indentation; then a path segment; optional ` # comment`. A line whose path ends with `/` is a directory prefix for deeper-indented lines. A line with no deeper indentation than the last directory is a sibling. Full paths without nesting are allowed. Empty result → `missing-files`; malformed line → `invalid-files`. The literal `none` alone in the fence means file-free work.
- `**Verification**` is a direct paragraph followed by exactly one fenced code block (unchanged).
- Output: `files[]` (plain resolved paths, fence order) unchanged; new `file_roles[]`.
- Root `- [ ]` list items anywhere in the body → `unsupported-task-format` with the message "root checkbox list nodes are retired; write the task as `## [ ] X.Y Title` with an unindented body". Old inline `— verify:` / `> Files:` keep the same code. Nested checkbox items inside a node body are ordinary Markdown (not nodes) only when they are not at root level; a root-level list checkbox is always the retired format.
- Frontmatter `task_graph` unchanged; key set must equal the heading-node ID set.
- Archives: validated with the rules in force when they were archived is **not** implemented (the CLI has no per-record ruleset); instead `validate --archived` continues to report the pre-existing failures and the baseline count is recorded in the Change's evaluation. No archive is rewritten.

## 4. Plan header (authoring contract)

After the frontmatter, in order: `# <title>`, `## Goal` (one sentence), `## Architecture` (two or three sentences plus a `design.md` link), `## Global constraints` (one line per constraint, copied from the specs delta or prerequisite Changes), `## File map` (optional; one diff tree for the whole plan, comments end with `· <task ids>`), `## Requirement coverage` (table requirement → tasks, followed by one line `Self-review <date>: ... Record: attachments/data/planning-validation.md`), then one line `Execution conventions: .agents/skills/harness/references/execution-conventions.md`. Plan-specific prerequisites stay in Global constraints; Harness policy text is not repeated.

## 5. Card contract (authoring contract)

Behavior task, in order: brief paragraph; `**Outcome**`; `**Interfaces**` (Consumes / Produces sub-lists, signatures in code fences, every new public name followed by its source: draft `glossary.md`, naming round, or existing convention); `**Cases**` as a numbered list of named cases, each with a role tag (new RED / existing control / boundary) and Given / When / Then clauses carrying the literal input and the independently derived expected result; a one-line clause list is allowed when every case fits one line; tables are not used; `**Files**` diff fence; `**Verification**`; optional `**Notes**`; `**Evidence**` after execution. Document or migration task: brief; `**Outcome**`; `**Files**`; `**Verification**`; optional `**Notes**`. No step-level TDD in the card: `test-driven-development` and `openspec-apply-change` run grouped RED/GREEN from the Cases list. No time, word or count quotas (spec rule retained).

Preflight (Skill-side, text checks in `openspec-continue-change` before accepting a plan and in `openspec-apply-change` before starting a task): labels present in order for the task kind; Cases has at least one case tagged `new RED` for behavior tasks; Interfaces has at least one code fence when the task names any symbol; no forbidden phrase; header sections present; `planning-validation.md` exists and is indexed. A card failing preflight is not started; the owning Change repairs it through `openspec-update-change`.

Forbidden phrases: `TBD`, `TODO`, `implement later`, `fill in details`, `add appropriate error handling`, `add validation`, `handle edge cases`, `write tests for the above`, `similar to Task`, `known values`, `existing fixtures`, `preserve behavior` (without an example or evidence link), an Interfaces block with no code fence, a reference to a type or function not defined in any task or inspected source.

Self-review (three items, recorded in `attachments/data/planning-validation.md`): every requirement and acceptance condition maps to a task; placeholder scan clean; symbol names consistent across tasks and with `design.md` "Vocabulary and Naming".

## 6. `execution-conventions.md`

New reference owning the text plans used to repeat: Harness import in the current PowerShell 7 process, build before Automation after C++ edits, what counts as PASS (Harness status plus enforced report, not shell exit), shared-run evidence rules, source-write freeze during UE operations, no unconditional full suite. Plans link it; `task-dag.md` points to it.

## 7. Migration

For each of the 7 active plans: convert each root checkbox to a heading node, de-indent its body, convert `**Files**` lists (or `> Files:` quotes) to a diff fence with modify markers (no role information exists → all space-marked except paths that do not exist yet, marked `+`), convert `— verify:` to a `**Verification**` fence, drop redundant `## Task X.Y` headings, keep IDs and frontmatter, move the plan-specific preamble into `## Global constraints`, add `## Goal`/`## Architecture` from the proposal, add `## Requirement coverage` from any existing acceptance table. Content is not enriched; cards lacking Interfaces/Cases stay as they are and are blocked by apply preflight until their Change updates them. Task 1.1-style "finish the design" nodes are kept verbatim (renaming or removing them is that Change's decision). Each migrated plan must pass `openspec validate <id> --strict` and show the same `done` set and dependency graph as before.

## 8. Verification of the Change

- Rust: `cargo test` in `Tools/openspec` with new fixtures (heading node parse, diff Files parse incl. nested/flat/`none`/malformed, retired list-format diagnostic, `file_roles[]` JSON, existing graph tests unchanged); `cargo fmt --check`, `cargo clippy` as the publisher runs them.
- Release: `Publish-OpenSpecPackage.ps1` from a clean tagged `v0.10.0` commit (needs user authorization for the submodule commit and tag and the parent EXE swap); manifest SHA recorded.
- Skill tests: `OpenSpecSkill.Tests.ps1` scoped (tokens for the new contract; filled example parses through the new EXE), `Protocol.Tests.ps1` temp copy, Skill validator on touched Skills.
- Records: `openspec validate --all --strict` for the 7 migrated Changes and this Change; `task.status` per migrated Change shows Ready > 0 where the graph allows; `harness/core --type spec --strict` after sync.
- Baseline debt outside this Change is listed, not fixed.

## 9. Vocabulary and naming

See `glossary.md`. New public names: Change ID, `file_roles[]`, card labels `Interfaces`/`Notes`, header sections, `execution-conventions.md`, `planning-validation.md`, CLI `0.10.0`.

## 10. Specification delta

`harness/core` MODIFIED: "Harness-recognized Task Graph" (heading nodes, diff Files, `file_roles[]`, retired list format), "Ready-to-execute Task authoring" (mandatory card labels and header, preflight, forbidden phrases, self-review record, no step-level TDD; quota prohibition retained), "Deterministic OpenSpec package" (version `0.10.0` release). No new requirement.

## Self-review

- Placeholders: none; every proposed rule has its owner file.
- Contradictions: the retained "no quotas" rule vs mandatory labels — resolved: labels are information, not size; the spec text will say so.
- Size: one Change is large (parser + docs + 7 migrations) as the user chose; tasks will be grouped so the CLI part can complete and release before migration starts.
- Ambiguity: diff-fence indentation rules are specified in §3; archives explicitly untouched.
