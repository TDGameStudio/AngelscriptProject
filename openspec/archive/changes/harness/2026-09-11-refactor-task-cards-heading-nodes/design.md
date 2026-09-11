## Context

This is the current planning truth for the heading-node task format. It supersedes the draft copy `attachments/drafts/design.md` wherever the two differ; the draft copy keeps the approved shape and rationale, this file keeps what was built. Decisions D1–D8 and the rejected paths are in `attachments/talks/talk-20260911-171700-heading-node-task-cards.md`; names are in `attachments/drafts/glossary.md`.

Before this Change the OpenSpec parser (`Tools/openspec/src/core/task_plan.rs`, 0.9.0) recognized only root `- [ ] X.Y` list items with a four-space owned body, and only `**Files**` (bullet list of code spans) and `**Verification**` as machine sections. Every other label was optional, and the audit in `attachments/drafts/findings/current-task-format-audit.md` shows how optional labels degrade into prose across the seven active plans.

## Goals and non-goals

Tasks read as headings with an unindented, information-complete card; the parser, the authoring contract and Skill preflight enforce that shape; the seven active plans are migrated syntax-only. Harness scheduling semantics (`files`, `after`, `ready`) do not change; a `fileRoles` projection is added beside them.

Not in scope: content enrichment of other Changes' cards, rewriting archived records, a compatibility parser for the list form, step-level checkboxes, changes to `markers.md` or `visual-explain`, any Git commit, tag or EXE swap without explicit authorization.

## Node syntax and parser

A task node is a level-2 heading whose text matches `^\[([ xX])\] ([0-9]+\.[0-9]+) (.+?)\s*$`. Its body is every root block until the next level-1 or level-2 heading; blocks are not indented. A level-2 heading without a checkbox is a group or header heading: it owns nothing, and a `**Files**` or `**Verification**` label paragraph under it is `invalid-task-node`. A `## [ ] …` heading without a stable `X.Y` id is `invalid-task-node` and still counts toward `checkbox_total`. Level-3 and deeper headings, lists, tables, quotes, fences and images inside the body stay inside the card; only a `#`/`##` heading ends it.

`**Files**` is a direct label paragraph followed by exactly one fenced block whose info string is `diff`. Each line: first character `+` (create), `-` (delete) or space (modify); then indentation; then a path segment; text after ` # ` is a comment. A segment ending in `/` is pushed on a directory stack keyed by its indentation and prefixes deeper-indented lines; a shallower or equal line pops it. A flat full path is allowed. The literal `none` alone means file-free work and cannot be mixed with paths. Diagnostics: non-`diff` info string, bullet list, malformed first character, empty path, second fence, `none` plus paths → `invalid-files` with the offending line; empty fence or no fence → `missing-files`.

Projection: `files: Vec<String>` keeps the resolved paths in fence order (unchanged type, so `validate`, `instructions` and Harness `task.status` need no change); `file_roles: Vec<FileRole { path, role: FileRoleKind }>` serializes as `fileRoles` with lowercase roles. `after`, `ready`, graph validation and natural ID ordering are untouched.

Retired formats all report `unsupported-task-format` and suppress every Ready result: root `- [ ] X.Y` list items anywhere outside a fence or quote — including inside a card body — with the message `root checkbox list nodes are retired; write the task as '## [ ] X.Y Title' with an unindented body`; inline `— verify:`; `> Files:`; `> After:`. There is no dual parser. The retired-list regex lives in a `OnceLock` because the crate's `rust-version` is 1.75.

Archives are not re-parsed with historical rules: the CLI has no per-record ruleset, so `validate --archived` keeps reporting the pre-existing failures and no archive is rewritten.

## Plan header and card contract

After the frontmatter: `# <title>`, `## Goal`, `## Architecture`, `## Global constraints` (last line links `.agents/skills/harness/references/execution-conventions.md`), optional `## File map` (one diff tree with `· <task ids>` comments), `## Requirement coverage` (table plus one `Self-review <date>: … Record: attachments/data/planning-validation.md` line). Group headings may follow between cards.

Behavior card, in order: brief paragraph; `**Outcome**`; `**Interfaces**` (Consumes / Produces, signatures in code fences, every new public name with its source: glossary, naming round or existing convention); `**Cases**` as a numbered list of named cases with a role tag (`new RED`, `existing control`, `boundary`) and Given / When / Then clauses carrying the literal input and the independently derived result — one-line clauses allowed, tables not used; `**Files**`; `**Verification**`; optional `**Notes**`; `**Evidence**` after execution. Document or migration card: brief, `**Outcome**`, `**Files**`, `**Verification**`, optional `**Notes**`. No step-level RED/GREEN script in the card; `test-driven-development` derives it from Cases. Labels are information requirements, not size targets; the no-quota rule stands.

Forbidden phrases (`TBD`, `TODO`, `implement later`, `fill in details`, `add appropriate error handling`, `add validation`, `handle edge cases`, `write tests for the above`, `similar to Task`, `known values`, `existing fixtures`, `preserve behavior` without evidence, an Interfaces block without a code fence, an undefined symbol) and the three-item self-review are owned by `openspec/references/tasks.md`. `Context and interfaces` and `Implementation` are no longer labels anywhere in the Skills.

## Preflight

Preflight is Skill-side text policy, not a parser rule. `openspec-continue-change` accepts a plan only when the header sections exist, every card has the labels for its kind in order, each behavior card has a `new RED` case and an Interfaces fence when it names a symbol, no forbidden phrase appears, and `planning-validation.md` is indexed. `openspec-apply-change` refuses to start a card failing the same checks, names the missing element, and routes repair to `openspec-update-change`; it never fills interfaces or cases on the plan's behalf. This is what makes syntax-only migration safe: thin migrated cards are visible and blocked rather than silently executable.

## Draft carryover is self-contained

Drafts under `openspec/drafts/` are local and git-ignored, so a Change may not reference them. `openspec-create-change` copies the draft `design.md`, `handoff.md` and `glossary.md` and every finding cited by the design, a talk or a knowledge into `attachments/drafts/` (findings under `drafts/findings/`) and repoints the citations; only the round log and uncited findings stay in the draft. This rule was added during this Change after the user found draft paths in its knowledge files; `openspec/references/attachments.md`, `openspec-create-change/SKILL.md` and the `harness/core` carryover requirement carry it.

## Release and migration

The parser ships as OpenSpec `0.10.0`: submodule commit `0a39409` on `release/heading-nodes-0.10.0`, annotated tag `v0.10.0`, published through `Publish-OpenSpecPackage.ps1` (fmt, clippy, all-target tests, command-doc parity, release build, isolated byte-identical rebuild) into `.agents/skills/openspec/bin/openspec.exe` and `release-manifest.json`. The parent repository is not committed by this Change.

Migration of the seven active `angelscript/*` plans converts each root checkbox to a heading node, de-indents the body, turns the Files list (or `> Files:` quote) into a diff fence with modify markers (`+` only for paths that do not exist yet), turns `— verify:` into a Verification fence, drops redundant `## Task X.Y` headings, keeps IDs, frontmatter, `done` state and Evidence, moves the plan-specific preamble into `## Global constraints`, and adds `## Goal` / `## Architecture` / `## Requirement coverage` from the proposal and any acceptance table. Nothing is enriched; "complete the design" nodes stay verbatim. Each migrated plan must validate strictly and show the same `done` set and dependency graph as recorded in `attachments/data/migration-baseline.md`.

## Verification of the Change

Rust: `tests/heading_task_contract.rs` (heading nodes, group headings, diff tree, roles, `none`, malformed lines, retired list nodes, fenced examples, legacy metadata) plus the migrated crate tests, `cargo fmt --check`, `cargo clippy -D warnings`, `cargo test --all-targets`, `command_docs`. Package: `openspec.doctor` and the manifest agree on `0.10.0`. Skills: scoped `OpenSpecSkill.Tests.ps1`, `Authoring.Tests.ps1` against the packaged EXE (filled example, template scaffold, retired negatives, `fileRoles`), `Protocol.Tests.ps1` temp copy, `quick_validate.py`. Records: `openspec.validate --all --strict` for the seven migrated plans and this Change; baseline debt outside this Change is listed, not fixed.
