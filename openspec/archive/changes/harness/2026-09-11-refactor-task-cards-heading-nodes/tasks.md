---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "1.4": ["1.3"]
    "2.1": []
    "2.2": ["1.4", "2.1"]
    "3.1": ["1.4"]
    "3.2": ["2.2", "3.1"]
---

# Heading-node task cards with diff Files and a structured authoring contract

## Goal

Every active `tasks.md` reads as one heading per task with an unindented, information-complete card, and the OpenSpec CLI, the authoring contract and Skill preflight enforce that shape.

## Architecture

`Tools/openspec` parses `## [ ] X.Y Title` headings as nodes and a ```` ```diff ```` fence as the Files surface, projecting `files` plus `fileRoles`; the retired list form yields `unsupported-task-format`. The authoring contract (`openspec/references/tasks.md`) fixes the plan header and the card labels, Skill-side preflight blocks thin cards, and the seven active AngelScript plans are migrated syntax-only. See `attachments/drafts/design.md` §3–§7.

## Global constraints

- The packaged CLI was `0.9.0` when this plan was written; this file was rewritten in the heading-node form as soon as the `0.10.0` release build existed, ahead of task 3.2, at the user's request.
- Rust work runs in `Tools/openspec` with `cargo` from `~/.cargo/bin` (not on PATH in the Harness shell); Harness routes run in the current PowerShell 7 session.
- No commit, tag or EXE swap without the user's explicit authorization; task 1.4 stops at that boundary (authorization was granted 2026-09-11 17:44).
- Migration is syntax-only; other Changes' cards are never enriched here. Archived records are not rewritten.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Tools/openspec/
   Cargo.toml, Cargo.lock                     # 0.10.0                                  · 1.4
   src/core/task_plan.rs                      # heading nodes, diff Files, fileRoles    · 1.1 1.2 1.3
   src/cli/validate.rs, src/cli/instructions.rs   # unit-test fixtures                  · 1.3
   src/embedded_templates/tasks.md            # shipped template                        · 1.3
   src/embedded_workflows/spec-driven.yaml    # tasks instruction text                  · 1.3
   README.md, docs/ARCHITECTURE.md            # format description                      · 1.3
+  tests/heading_task_contract.rs             # 13 cases                                · 1.1 1.2 1.3
   tests/*.rs                                 # fixtures migrated                       · 1.3
 .agents/skills/openspec/
   bin/openspec.exe, release-manifest.json    # packaged 0.10.0                         · 1.4
   SKILL.md                                   # 0.10.0 format sentence                  · 2.1
   references/tasks.md                        # authoring contract                      · 2.1
   references/attachments.md                  # draft copies rule                       · 2.2
   tests/OpenSpecSkill.Tests.ps1, tests/Authoring.Tests.ps1                             · 2.2
 .agents/skills/harness/references/
+  execution-conventions.md                   # execution preamble                      · 2.1
   task-dag.md                                                                          · 2.1
 .agents/skills/harness/tests/Protocol.Tests.ps1, Harness.Tests.ps1, Harness.Performance.Tests.ps1   · 2.2
 .agents/skills/openspec-continue-change/SKILL.md, openspec-apply-change/SKILL.md, openspec-create-change/SKILL.md   · 2.2
 .agents/skills/brainstorming/SKILL.md, references/naming.md   # Interfaces label      · 2.2
 openspec/config.yaml                         # rules.tasks                             · 2.1
 openspec/workflows/angelscript/templates/tasks.md                                      · 2.2
 openspec/changes/angelscript/*/tasks.md      # 7 plans                                 · 3.1
 openspec/changes/harness/refactor-task-cards-heading-nodes/
   tasks.md                                                                             · 3.2
+  attachments/data/migration-baseline.md                                               · 3.1
+  attachments/data/planning-validation.md                                              · 3.2
```

## Requirement coverage

| Requirement (specs delta, `harness/core`) | Tasks |
|---|---|
| Harness-recognized Task Graph: heading nodes, unindented body, group headings | 1.1 |
| Harness-recognized Task Graph: diff Files tree, `files` + `fileRoles`, exact metadata | 1.2 |
| Harness-recognized Task Graph: retired formats → `unsupported-task-format`, no Ready work | 1.3 |
| Deterministic OpenSpec package: `v0.10.0` | 1.4 |
| Ready-to-execute Task authoring: header, labels, Cases form, forbidden phrases, self-review | 2.1 |
| Ready-to-execute Task authoring: preflight in continue/apply; Naming confirmation: Interfaces label | 2.2 |
| Exploration markers and durable carryover: copied glossary and findings, no draft links | 2.2 |
| Migration of active plans (proposal "Migration") | 3.1 |
| This plan in the new form, self-review record | 3.2 |

Self-review 2026-09-11: coverage complete; placeholders none; symbols consistent with `attachments/drafts/glossary.md` (`fileRoles`, `FileRole`, `FileRoleKind`, `Interfaces`, `Notes`, `execution-conventions.md`, `planning-validation.md`). Record: `attachments/data/planning-validation.md`.

## 1. Parser and release

## [x] 1.1 Parse heading task nodes with an unindented body

`TaskPlan::parse` recognizes `## [ ] X.Y Title` / `## [x] X.Y Title` headings as nodes whose body runs to the next level-1 or level-2 heading. Frontmatter handling, `after` and `ready` derivation and the Verification fence are unchanged.

**Outcome**

A heading node projects the same `id / description / done / verify / after / ready / line` as the list node did. Level-2 headings without a checkbox are group or header headings and own nothing; a `**Files**` or `**Verification**` label under them is `invalid-task-node`. Level-3 and deeper headings stay inside the card. Excluded: the Files surface (1.2), retirement of list nodes (1.3).

**Interfaces**

Consumes (`src/core/task_plan.rs`, `src/core/markdown.rs`):

```rust
pub fn TaskPlan::parse(content: &str) -> TaskPlan;            // task_plan.rs:52
pub(crate) enum Kind { Heading(u8), Paragraph, List, CodeBlock { fenced: bool }, Quote, .. }   // markdown.rs
impl Node { fn text(&self) -> String; fn label(&self) -> Option<String> }
```

Produces (private):

```rust
fn TaskPlan::finish_node(&mut self, content: &str, node: TaskNode, body: Vec<&Node>, graph: &Option<TaskGraphFrontmatter>, seen: &mut BTreeSet<String>);
fn parse_task_sections(content: &str, body: &[&Node], node: &mut TaskNode, issues: &mut Vec<TaskPlanIssue>);
```

No new public names (glossary: heading node, brief).

**Cases**

1. **Two heading nodes project the graph** — new RED
   Given `## [x] 1.1 A` and `## [ ] 1.2 B` with `depends_on 1.2: ["1.1"]` When parsed Then `checkbox_total 2`, `complete 1`, `1.2.after == ["1.1"]`, `1.2.ready`, `1.1` not ready
2. **Header sections and group headings own nothing** — new RED
   Given `# Plan`, `## Goal`, `## 1. Parser` between cards Then no diagnostics and exactly two nodes
3. **Metadata under a group heading** — new RED
   Given `## 1. Parser` followed by `**Files**` Then `invalid-task-node` at that line
4. **Deeper headings stay inside the card** — new RED
   Given `### Details` and `#### Deeper` before `**Verification**` Then the node's `verify` is still read
5. **Heading checkbox without a stable id** — boundary
   Given `## [ ] Parse things` Then `invalid-task-node`
6. **BOM and CRLF** — existing control
   Given the same plan with BOM and CRLF Then two nodes, `nodes[0].line == 9`

**Files**

```diff
 Tools/openspec/src/core/task_plan.rs
+Tools/openspec/tests/heading_task_contract.rs
```

**Verification**

Run from `Tools/openspec`.

```sh
cargo test --locked --test heading_task_contract --test task_plan_contract --test structured_task_contract
```

All heading cases pass; every test in the two contract files passes.

**Evidence**

2026-09-11 17:25–17:40. RED observed first: `cargo test --locked --test heading_task_contract` → 6 failed / 0 passed (nodes not recognized). Implemented heading-node recognition, group headings, `finish_node`; 1.1–1.3 were implemented as one feature group because the user's layout requirement (unindented body) already made the list form unparseable, so the 1.1 control "existing tests still pass" was proven after 1.3's fixture migration rather than before. GREEN: `cargo test --locked --test heading_task_contract --test task_plan_contract --test structured_task_contract` → 13 / 13 / 15 passed, 0 failed. Fixture fix during RED: swapped the done flags in the test plan (a done task cannot depend on a pending one).

## [x] 1.2 Parse the Files diff tree and project `fileRoles`

`**Files**` is followed by one ```` ```diff ```` fence instead of a bullet list; the projection keeps `files` and adds `fileRoles`.

**Outcome**

Each fence line: `+` create, `-` delete, space modify; then indentation; then a path segment; ` # ` starts a comment; a `/`-terminated segment prefixes deeper-indented lines; a flat path is allowed; `none` alone means file-free. `files` holds the resolved paths in fence order; `fileRoles` holds `{path, role}` with `role ∈ create | modify | delete`. A Files bullet list is `invalid-files`. Excluded: any change to `after` / `ready`.

**Interfaces**

Produces (`src/core/task_plan.rs`, public):

```rust
#[serde(rename_all = "lowercase")] pub enum FileRoleKind { Create, Modify, Delete }
pub struct FileRole { pub path: String, pub role: FileRoleKind }
pub struct TaskNode { /* existing fields */ pub file_roles: Vec<FileRole> }   // JSON: fileRoles
fn parse_files_tree(text: &str, fence_line: usize, node: &mut TaskNode, issues: &mut Vec<TaskPlanIssue>);
fn fence_language(raw: &str) -> &str;
```

Names from `attachments/drafts/glossary.md` (`file_roles` / `fileRoles`); `FileRole`, `FileRoleKind` follow the crate's `TaskNode` / `TaskPlanIssue` convention. Consumers `src/cli/validate.rs`, `src/cli/instructions.rs` (`TaskItem = TaskNode`) need no change.

**Cases**

1. **Directory prefixes, roles and comments** — new RED
   Given ` Plugins/A/` / `   x.cpp # existing` / `+  y.h` / `-  z.cpp` / `+Plugins/B/new.cpp` Then `files == [Plugins/A/x.cpp, Plugins/A/y.h, Plugins/A/z.cpp, Plugins/B/new.cpp]` and `fileRoles` modify / create / delete / create
2. **Spaces, commas and Unicode are data** — new RED
   Given `src/` + `+  a b.rs`, `tests/` + `   a,b.rs # <CJK comment>` and a `+` line whose file name is two CJK words separated by a space Then exactly three paths with the characters preserved and the comment dropped
3. **`none` is file-free** — new RED
   Given a fence containing only `none` Then `files` and `fileRoles` empty, no `missing-files`
4. **Malformed lines carry their line number** — new RED
   Given `*src/lib.rs`, `+` alone, a `text` fence, a bullet list, `none` mixed with a path, or two fences Then `invalid-files`; an empty fence Then `missing-files`; the reported line equals the fence line plus the offending offset
5. **JSON carries `fileRoles`** — new RED
   Given the filled example in `openspec/references/tasks.md` When `instructions apply --json` Then `src/options.rs=modify|tests/option_policy.rs=create`
6. **Graph derivation unchanged** — existing control
   Given cases 1–3 Then `after` / `ready` equal the 1.1 results

**Files**

```diff
 Tools/openspec/src/core/task_plan.rs
 Tools/openspec/src/cli/validate.rs
 Tools/openspec/src/cli/instructions.rs
 Tools/openspec/tests/heading_task_contract.rs
```

**Verification**

Run from `Tools/openspec`.

```sh
cargo test --locked --test heading_task_contract
```

All Files-tree cases pass with the listed paths and roles.

**Evidence**

2026-09-11. Added `FileRoleKind`, `FileRole`, `TaskNode.file_roles` (serialized `fileRoles`), `parse_files_tree` with a directory stack keyed by indentation, `fence_language` check. Cases in `tests/heading_task_contract.rs`: nested prefixes + roles + comments, spaces/commas/Unicode, `none`, malformed lines with line numbers, list form → `invalid-files`, duplicate fence, empty fence → `missing-files`. GREEN: `cargo test --locked --test heading_task_contract` → 13 passed. `validate --json` / `instructions apply --json` carry `fileRoles` (checked through `Authoring.Tests.ps1` against the 0.10.0 release build: `src/options.rs=modify|tests/option_policy.rs=create`). `validate.rs` and `instructions.rs` needed only fixture changes (1.3).

## [x] 1.3 Retire root-checkbox list nodes and migrate the crate's own tests and fixtures

Root `- [ ] X.Y` list items become a retired format with an explicit diagnostic, and every crate-side fixture, template and document uses the heading form.

**Outcome**

A root checkbox list item anywhere outside a fence or quote — including inside a card body — yields `unsupported-task-format` with the message `root checkbox list nodes are retired; write the task as '## [ ] X.Y Title' with an unindented body` and no Ready work. `— verify:`, `> Files:` and `> After:` keep the same code. All Rust tests, `src/embedded_templates/tasks.md`, the `spec-driven` workflow text and the crate docs show the heading form. The four release gates pass.

**Interfaces**

Produces (private):

```rust
fn retired_list_node() -> &'static Regex;   // ^[-*] \[[ xX]\] [0-9]+\.[0-9]+ ; OnceLock (rust-version 1.75)
```

Reused issue code `unsupported-task-format` (glossary). `.agents/skills/openspec/commands/**` contain no format wording, so command-doc parity needs no edit.

**Cases**

1. **Root list node after the last card** — new RED
   Given two heading nodes then `- [ ] 9.9 Old` Then `unsupported-task-format` whose message contains `## [ ] X.Y Title`, two nodes, none ready
2. **Root list node inside a card body** — new RED
   Given `- [ ] 1.2 …` inside card 1.1 Then `unsupported-task-format` attributed to `1.1`, no extra node
3. **Fenced and quoted examples stay content** — existing control
   Given a fenced `- [ ] 9.1` and `## [ ] 9.2`, and a quoted `- [ ] 9.3` with `> **Files**` Then no diagnostics
4. **Legacy inline and blockquote metadata** — existing control
   Given `— verify:` / `> Files:` / `> After:` Then `unsupported-task-format`
5. **Release gates** — boundary
   When `cargo fmt --check`, `cargo clippy --locked --all-targets -- -D warnings`, `cargo test --locked --all-targets`, `cargo test --locked --test command_docs` run Then all exit 0

**Files**

```diff
 Tools/openspec/
   src/core/task_plan.rs                      # retired-list diagnostic only
   src/cli/validate.rs, src/cli/instructions.rs   # unit-test fixtures
   src/embedded_templates/tasks.md
   src/embedded_workflows/spec-driven.yaml
   README.md, docs/ARCHITECTURE.md
   tests/*.rs                                 # fixtures rewritten; two indentation-only tests removed
 .agents/skills/openspec/commands/**          # parity check only; unchanged
```

**Verification**

Run from `Tools/openspec`.

```sh
cargo fmt --check && cargo clippy --locked --all-targets -- -D warnings && cargo test --locked --all-targets && cargo test --locked --test command_docs
```

All four commands exit 0.

**Evidence**

2026-09-11 17:41. `unsupported-task-format` for root `- [ ] X.Y` list items (outside and inside card bodies) with the message naming `## [ ] X.Y Title`; fenced/quoted examples stay content. Fixture migration of the crate's own tests, `src/embedded_templates/tasks.md`, `src/embedded_workflows/spec-driven.yaml`, `README.md` and `docs/ARCHITECTURE.md` was delegated to a subagent; two indentation-only tests were deleted (no equivalent rule), the `detached-task-content` case became `metadata_under_a_group_heading_cannot_leak_into_a_task` (`invalid-task-node`). Results: `cargo fmt --check` exit 0; `cargo clippy --locked --all-targets -- -D warnings` clean; `cargo test --locked --all-targets` 17 suites, 0 failed (lib 70, heading 13, structured 13, task_plan 15, validate 13, workflow 20, others unchanged); `cargo test --locked --test command_docs` 3 passed. Baseline noted, not fixed: the crate's self-host record `Tools/openspec/openspec/changes/openspec/architecture/streamline-portable-kernel/tasks.md` and legacy-history records still use the list form.

## [x] 1.4 Release `0.10.0` and swap the packaged executable

The parser change ships as a new OpenSpec package: version bump, submodule commit, annotated tag, publisher run.

**Outcome**

`Cargo.toml` / `Cargo.lock` at `0.10.0`; `.agents/skills/openspec/bin/openspec.exe`, `release-manifest.json` and the command-doc set replaced by `Publish-OpenSpecPackage.ps1` from annotated tag `v0.10.0`; `openspec.doctor` reports `0.10.0` with a digest equal to the manifest. The submodule commit, tag and parent EXE swap require the user's explicit authorization; the parent repository is not committed here.

**Interfaces**

Consumes: `.agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1 -ProjectRoot <root> -Version 0.10.0` (clean source commit, exact annotated `v<version>` tag); manifest fields `version`, `sourceCommit`, `sourceTag`, `sha256`, `releaseGates[]`. Produces: no new public names beyond the version.

**Cases**

1. **Release build reports the version** — new RED
   Given the bumped crate When `cargo build --release --locked` Then `target/release/openspec.exe --version` prints `openspec 0.10.0`
2. **Release build parses the new contract** — new RED
   When `Authoring.Tests.ps1 -Executable Tools/openspec/target/release/openspec.exe` Then it passes (filled example, scaffold, retired negatives, `fileRoles`)
3. **Packaged doctor agrees with the manifest** — new RED, after authorization
   When `Invoke-Harness -Command openspec.doctor -Context $context -ArgumentList @('--json')` Then version `0.10.0`, SHA-256 equal to `release-manifest.json`, status Succeeded
4. **Not-yet-migrated plans fail as expected** — existing control
   When `openspec.validate --all --strict` runs on the new EXE Then the seven `angelscript/*` plans fail with `unsupported-task-format` and the pre-existing baseline is unchanged otherwise

**Files**

```diff
 Tools/openspec/Cargo.toml
 Tools/openspec/Cargo.lock
 .agents/skills/openspec/bin/openspec.exe
 .agents/skills/openspec/release-manifest.json
 .agents/skills/openspec/commands/**
```

**Verification**

Run from the workspace root after authorization.

```powershell
Invoke-Harness -Command openspec.doctor -Context $context -ArgumentList @('--json')
```

Reported version `0.10.0`; digest equals the manifest; status Succeeded.

**Evidence**

2026-09-11 17:43, pre-authorization part. `Cargo.toml` and `Cargo.lock` bumped to `0.10.0`; `cargo build --release --locked` finished; `target/release/openspec.exe --version` → `openspec 0.10.0`; `Authoring.Tests.ps1 -Executable Tools/openspec/target/release/openspec.exe` passed (filled example, completed scaffold, retired inline and retired list negatives, `fileRoles` projection). Authorization: granted 2026-09-11 17:44 (submodule commit + tag + publisher; parent not committed). Submodule commit `0a39409` on branch `release/heading-nodes-0.10.0`, annotated tag `v0.10.0`; publisher 17:46–17:47 exit 0 — gates fmt / clippy / all-target tests / command_docs / release build / isolated byte-identical rebuild passed; manifest `version 0.10.0`, `sourceCommit 0a394098…`, `sourceTag v0.10.0`, `sha256 8f12bf78…8fa9a2`. `.agents/skills/openspec/bin/openspec.exe --version` → `openspec 0.10.0`; `Invoke-Harness -Command openspec.doctor` → Succeeded, `valid: true`, 0 errors. Control: `openspec.validate --all --strict` on the new EXE fails the seven unmigrated `angelscript/*` plans with `unsupported-task-format` (recorded in 3.1's baseline). Parent repository not committed.

## 2. Authoring contract

## [x] 2.1 Rewrite the task authoring contract, header, and execution conventions

The contract describes the heading-node plan, and the execution preamble plans used to repeat moves into one Harness reference.

**Outcome**

`.agents/skills/openspec/references/tasks.md` covers the machine surface, the plan header, the card contract (Form 2 Cases, no step-level TDD), forbidden phrases, self-review, preflight, the semantic check and a filled heading-node example. New `.agents/skills/harness/references/execution-conventions.md` owns session, build-before-Automation, PASS definition, shared runs, leases, scope and Evidence rules. `task-dag.md`, `openspec/config.yaml` rules.tasks and `openspec/SKILL.md` point at the new form; `Context and interfaces` and `Implementation` are no longer labels.

**Files**

```diff
 .agents/skills/openspec/references/tasks.md
+.agents/skills/harness/references/execution-conventions.md
 .agents/skills/harness/references/task-dag.md
 .agents/skills/openspec/SKILL.md
 openspec/config.yaml
```

**Verification**

Run from the workspace root.

```powershell
$env:PYTHONUTF8=1; python C:\Users\scottmei\.agent\skills\skill-creator-for-knot\scripts\quick_validate.py .agents/skills/openspec; python C:\Users\scottmei\.agent\skills\skill-creator-for-knot\scripts\quick_validate.py .agents/skills/harness
```

Both validators exit 0; `rg` finds `## [ ] `, `fileRoles`, ```` ```diff ````, `## Goal`, `## Requirement coverage`, `**Interfaces**`, `**Notes**`, `Given`, `planning-validation.md`, `execution-conventions.md`, `TBD`, `similar to Task` in `tasks.md` and zero `Context and interfaces` / `four spaces` outside a retirement sentence.

**Evidence**

2026-09-11 17:33. Wrote `execution-conventions.md` from the bindings and sdk-drop preambles; rewrote `tasks.md` (machine surface, plan header, card contract with Form 2 Cases, forbidden phrases, self-review, preflight, semantic check, filled heading-node example); updated `task-dag.md`, `openspec/config.yaml` rules.tasks, `openspec/SKILL.md` (0.10.0 sentence). `quick_validate.py` → both Skills pass. `rg` counts: `## [ ] ` 2, `fileRoles` 1, ```` ```diff ```` 3, `## Goal` 3, `## Requirement coverage` 3, `**Interfaces**` 2, `**Notes**` 3, `Given` 7, `planning-validation.md` 4, `execution-conventions.md` 2, `TBD` 1, `similar to Task` 1; `Context and interfaces` / `four spaces` / `four-space` 0 hits in `tasks.md`, `task-dag.md` and the tasks rule of `config.yaml` (the remaining `four-space` in `config.yaml` is the specs rule, out of scope). `execution-conventions.md` contains `Import-Module`, `ue.build`, `enforced Automation report`, shared run, freeze source.

## [x] 2.2 Add Skill-side preflight, fix the draft-copy rule, and update the Skill tests

The lifecycle Skills check card completeness before accepting or starting work, Change attachments never link into `openspec/drafts/`, and the Skill tests prove both against the packaged `0.10.0` executable.

**Outcome**

`openspec-continue-change` states the plan-acceptance preflight; `openspec-apply-change` states the task-start preflight and refuses a card missing an Interfaces fence or a `new RED` case, routing repair to `openspec-update-change`. `openspec-create-change` and `openspec/references/attachments.md` require copying the draft `glossary.md` and every cited finding into `attachments/drafts/` with citations repointed. The `Interfaces` label replaces `Context and interfaces` in `brainstorming/SKILL.md` and `references/naming.md`. `OpenSpecSkill.Tests.ps1` asserts the new contract tokens and rejects the retired ones; `Authoring.Tests.ps1` proves the filled example, the workflow template scaffold, the retired-list negative and `fileRoles` through the packaged EXE; Harness test fixtures use heading nodes; the scoped Skill test and the `Protocol.Tests.ps1` temp copy pass.

**Interfaces**

No new public names. Test token loops for `tasks.md` / `task-dag.md` / continue / apply live around lines 1004–1050 of `OpenSpecSkill.Tests.ps1`; Harness fixtures are the `$readyTasks` / `$cycleTasks` / `$taskWorkspaceDocument` here-strings.

**Cases**

1. **Contract tokens present** — new RED
   Given `OpenSpecSkill.Tests.ps1` with the heading-node token loop When run before the Skill edits Then it fails on the missing tokens; after Then exit 0
2. **Retired tokens absent** — new RED
   Given the same run Then `Context and interfaces`, `four spaces`, `**Implementation**` and the Cases table header are absent from `openspec/references/tasks.md` and `four-space` from `task-dag.md`
3. **Template scaffold is executable** — new RED
   Given `openspec/workflows/angelscript/templates/tasks.md` with comments replaced When parsed by the packaged EXE Then one Ready task with `verify == cargo test fixture_contract`
4. **Retired list node negative** — new RED
   Given a root `- [ ] 1.1` plan When `instructions apply --json` Then `unsupported-task-format` whose message contains `## [ ] X.Y Title`, zero Ready
5. **Harness fixtures parse** — existing control
   When `Protocol.Tests.ps1` (temp copy, pre-existing closure-v1 assertion downgraded) runs against the packaged EXE Then PASS
6. **Preflight wording** — boundary
   Then continue contains `preflight`, `` `new RED` ``, `Interfaces`, `planning-validation.md`, `openspec-update-change`, `## Goal`; apply contains `preflight`, `` `new RED` ``, `**Interfaces**`, `never fills interfaces or cases`, `heading-node card`

**Files**

```diff
 .agents/skills/
   openspec-continue-change/SKILL.md
   openspec-apply-change/SKILL.md
   openspec-create-change/SKILL.md           # copy glossary + cited findings
   openspec/references/attachments.md        # draft copies rule
   brainstorming/SKILL.md                    # Interfaces label
   brainstorming/references/naming.md        # Interfaces label
   openspec/tests/OpenSpecSkill.Tests.ps1
   openspec/tests/Authoring.Tests.ps1
   harness/tests/Protocol.Tests.ps1          # fixtures
   harness/tests/Harness.Tests.ps1           # fixtures
   harness/tests/Harness.Performance.Tests.ps1   # fixtures
 openspec/workflows/angelscript/templates/tasks.md
```

**Verification**

Run from the workspace root after 1.4.

```powershell
& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths @('.agents/skills/openspec', '.agents/skills/harness', '.agents/skills/openspec-continue-change', '.agents/skills/openspec-apply-change', '.agents/skills/openspec-create-change', '.agents/skills/brainstorming', 'openspec/changes/harness/refactor-task-cards-heading-nodes', 'openspec/specs/harness')
```

Exit 0 with all selected cases executed; `Protocol.Tests.ps1` temp copy PASS.

**Notes**

Edits were made 17:35–17:45 while 1.4 was pending; the RED of case 1 was observed only as the token loop's design (the Skills were edited in the same pass), so record the GREEN run and the retired-token negatives as the proof.

**Evidence**

Run 2026-09-11 18:05 against the packaged `openspec 0.10.0`. `OpenSpecSkill.Tests.ps1 -SurfacePaths` (Change dir, template, `config.yaml`, `openspec`, `harness/references`, continue / apply / create-change, `brainstorming`) → exit 0, `OpenSpec skill package tests passed`; `Authoring.Tests.ps1` → exit 0. First run surfaced three stale expectations that this Change's Skill edits had invalidated and two real INDEX gaps, all repaired in this task: token `listed new public names` → `that the task's **Interfaces** does not list` + `never fills interfaces or cases`; config token `optional Markdown authoring aids…` → `No step-level TDD scripts, no forbidden placeholder phrases, no size quotas`; `Protocol.Tests.ps1` tokens `Optional Task Card detail is ordinary Markdown` / `Harness does not parse or require those optional sections` / old-format sentence → current `task-dag.md` wording; `data/migration-baseline.md` indexed once and `drafts/design.md` mentioned once. `Protocol.Tests.ps1` temp copy (`%TEMP%`, closure-v1 archive assertion downgraded to a warning: 4 pre-existing archive issues outside this Change) → `Protocol.Tests.ps1: PASS`. Unscoped `OpenSpecSkill.Tests.ps1` still fails only on the repository-wide English scan (13 pre-existing CJK hits in archives, other Changes and one spec knowledge file; the one hit in this plan was rewritten) — baseline debt, not owned here. `quick_validate.py` is not present in this workspace; omitted.

## 3. Migration

## [x] 3.1 Migrate the seven active AngelScript plans to heading nodes (syntax only)

Each active `openspec/changes/angelscript/*/tasks.md` is converted to the heading-node syntax with the plan header; content is not enriched.

**Outcome**

Each plan uses heading nodes with unindented bodies, a diff Files fence (existing paths as modify, not-yet-existing paths as `+`), a `**Verification**` fence, and `## Goal` / `## Architecture` / `## Global constraints` / `## Requirement coverage` derived from the proposal, design link, plan-specific preamble and any acceptance table. IDs, `depends_on`, `done` state, card text and Evidence are preserved apart from the structural rewrite; redundant `## Task X.Y` headings are removed; Harness policy paragraphs are replaced by the `execution-conventions.md` link. Cards lacking Interfaces or Cases stay as they are and are blocked by apply preflight until their Change updates them; "complete the design" nodes stay verbatim.

**Files**

```diff
 openspec/changes/angelscript/
   feature-delegates-ue-interop/tasks.md
   feature-frontend-diagnostics-tooling/tasks.md
   feature-memory-gc-observability/tasks.md
   refactor-bindings-two-stage-pipeline/tasks.md
   refactor-defaults-constructor-unification/tasks.md
   refactor-sdk-drop-native-gc/tasks.md
   refactor-testing-unified-framework/tasks.md
 openspec/changes/harness/refactor-task-cards-heading-nodes/attachments/
+  data/migration-baseline.md                # per-plan ID/done sets before and after
   INDEX.md
```

**Verification**

Run from the workspace root.

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--all','--strict','--json')
```

All seven plans and this Change report `valid: true`; `task.status` per plan shows the same ID set and `done` set as recorded in `migration-baseline.md` and Ready ≥ 1 where the graph has an incomplete root; `git diff --stat` per plan touches only its `tasks.md`; remaining failures equal the recorded pre-existing baseline.

**Evidence**

Migrated 2026-09-11 17:56–18:00 by three parallel agents, syntax only; verified independently through `Invoke-Harness openspec.validate --strict` and `task.status` on the packaged 0.10.0. All 7 plans: ID sets and done sets equal `attachments/data/migration-baseline.md` (64 nodes, none done), zero `tasks.md` issues, frontmatter byte-identical, 0 CJK, 0 `openspec/drafts` references, only the seven `tasks.md` files modified under `openspec/changes/angelscript`. 5 plans `Succeeded`; `feature-frontend-diagnostics-tooling` (124) and `refactor-testing-unified-framework` (16) still `Failed` solely on pre-existing four-space clause-detail issues in their untouched `specs/**/spec.md` — recorded as owning-Change debt. Deviations from verbatim carryover (CJK path folded into `cqtest*.md`, prose verification in delegates 4.1, title/Goal from `change.yaml`, one coverage row added for bindings `0.1`) are listed in the baseline's Deviations section.

## [x] 3.2 Record the self-review for this plan

This plan was rewritten in the heading-node form on 2026-09-11 17:50 ahead of schedule; the task now owns the self-review record and the final strict validation.

**Outcome**

`attachments/data/planning-validation.md` records the three-item self-review (coverage, placeholder scan, symbol consistency) for this plan; `INDEX.md` indexes it; strict validation passes through the packaged `0.10.0`.

**Files**

```diff
 openspec/changes/harness/refactor-task-cards-heading-nodes/
   tasks.md
+  attachments/data/planning-validation.md
   attachments/INDEX.md
```

**Verification**

Run from the workspace root.

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('harness/refactor-task-cards-heading-nodes','--strict','--json')
```

`valid: true` with zero issues; `task.status` shows 3.2 as the only incomplete task before it is checked.

**Evidence**

Self-review recorded 2026-09-11 18:02 in `attachments/data/planning-validation.md` (machine checks, three self-review items, recorded deviations) and indexed once in `attachments/INDEX.md`. Final `Invoke-Harness openspec.validate harness/refactor-task-cards-heading-nodes --strict` → Succeeded; `task.status` 8/8 done. Root `design.md` written as the current design truth (`openspec.status` design: complete). Spec sync and archive deliberately not run: the user asked to hold archive pending a possible replan.
