---
state: superseded
reviewed_at: 2026-09-02T19:40:12+08:00
superseded_at: 2026-09-03T01:29:26.4121259+08:00
superseded_by: review-20260902-openspec-072-rereview.md
review_scope: OpenSpec 0.7.0 source, package, command documentation, and lifecycle integration
snapshot:
  source_commit: 675daca34035d7a7e1055ce5b105d2ef3e7e6041
  source_tag: v0.7.0
  source_tag_kind: annotated
  release_exe_sha256: 79b431269fd53e8397fb0aadd8db560624c7d82a7b6f65556dc58da7b1a880c2
  parent_base: 4129487f63fab930800a896ae7f932d7bd4e6e70
  parent_allowed_diff:
    - Tools/openspec
    - .agents/skills/openspec/**
    - .agents/skills/openspec-*/**
    - .gitignore
  parent_patch_id: 4e2170054edec3e3e695e5dd381d0c125455afec
---

# OpenSpec 0.7 Package Review

The Review Gate remains open. The fixed release is internally bound to the assigned source commit, annotated tag, executable hash, and command-document digest, and its normal validation paths pass. One Critical and eleven Required findings still block closure.

## Fixed-snapshot verification

- Tools/openspec was clean at commit 675daca34035d7a7e1055ce5b105d2ef3e7e6041.
- Annotated tag v0.7.0 resolves to that exact commit.
- The source Release executable and bundled .agents/skills/openspec/bin/openspec.exe are both 2,814,464 bytes, report openspec 0.7.0, and have SHA-256 79b431269fd53e8397fb0aadd8db560624c7d82a7b6f65556dc58da7b1a880c2.
- The source and bundled command packages each contain README plus 31 recursive Clap group/leaf documents. Every bundled file matches its source file.
- The deterministic command-document digest is c636f171602c6868a9b7adeee0ef9656f0f276754f19d0b33736aeae16edd137 and matches release-manifest.json.
- cargo fmt --check passed.
- cargo clippy --locked --all-targets -- -D warnings passed.
- cargo test --locked --all-targets passed: 115 passed, 0 failed.
- OpenSpecSkill.Tests.ps1 passed without changing repository state.
- The bundled executable passed doctor and workflow validate angelscript.
- Validation failures are emitted completely and then mapped to process exit code 1 through ValidateOutcome, CliOutcome, and main.
- Twenty-call measurements were approximately 19 ms median for --version, 23 ms for doctor, and 30 ms for validate --all. No ordinary startup or validation performance blocker was observed.

## Finding 1 — Workflow names can escape workflow roots and expose arbitrary templates

    severity: Critical
    status: resolved
    affected_tasks: 1.2, 1.3

Files and lines:

- Tools/openspec/src/core/workflow_definition.rs:330-351
- Tools/openspec/src/core/manifest.rs:391-416
- Tools/openspec/src/core/manifest.rs:440-447
- Tools/openspec/src/core/config.rs:90-96
- Tools/openspec/src/core/config.rs:136-160
- Tools/openspec/src/core/workflow.rs:103-111
- Tools/openspec/src/cli/workflow_definition.rs:98-103
- Tools/openspec/src/cli/workflow_definition.rs:118-139
- Tools/openspec/src/cli/workflow_definition.rs:213-282

The central resolver joins an unvalidated workflow name directly below the project and user workflow directories. Change manifests and project config require only non-empty workflow text. The kebab-case validator is applied to a fork destination, but not to a requested source, a change workflow, a config workflow, or a CLI workflow override.

Once an escaped workflow.yaml is found, template loading reads from its adjacent templates directory and instructions returns the content as prompt input. workflow fork can also recursively copy the escaped directory; its directory tests follow links.

Reproduction:

1. Place outside/workflow.yaml and outside/templates/secret.md below the fixture project root but outside openspec/workflows.
2. Create a change with --workflow ../../outside.
3. Run openspec instructions leak --change <id> --json.
4. The command exits 0, reports a workflow path containing openspec/workflows/../../outside/workflow.yaml, and returns the secret template marker.

This is both local-file disclosure and prompt-injection exposure. An absolute workflow name can replace the joined base on supported platforms, and fork expands the impact into arbitrary recursive copy.

Expected fix:

- Move workflow-name validation into one core function and apply it to config, manifests, CLI overrides, resolve, which, validate, and fork source/destination names.
- Canonicalize every project/user workflow package and prove physical containment below its configured root.
- Reject symbolic links, Windows junctions, and other reparse points in workflow packages and templates.
- Require the loaded definition name to match the requested package identity.
- Make recursive copy use symlink_metadata and refuse links rather than following them.
- Add traversal, absolute-path, mixed-separator, user-workflow, project-workflow, symlink, and junction regression tests.

## Finding 2 — completion uninstall ignores its advertised deletion confirmation

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3

Files and lines:

- Tools/openspec/src/cli/args.rs:334-340
- Tools/openspec/src/cli/args.rs:442-443
- Tools/openspec/src/cli/completion.rs:114-150
- Tools/openspec/docs/commands/completion/uninstall.md:3-10

The public --yes flag is parsed and then intentionally discarded as _yes. run_completion_uninstall also names the parameter _yes and never reads it. If the user-level completion file exists, the command immediately removes it whether or not --yes was provided. The documentation says --yes suppresses confirmation, implying that the default path confirms or refuses.

Reproduction:

1. Install or create the expected OpenSpec completion file for bash, zsh, or fish.
2. Run openspec completion uninstall <shell> without --yes.
3. The implementation reaches remove_file directly and deletes the user-level file without a prompt or refusal.

Expected fix:

- Prefer a deterministic automation contract: require --yes whenever a file would be removed, and otherwise report the path without mutation.
- If an interactive prompt is retained, detect non-interactive input and fail safely instead of assuming consent.
- Return an error through run and CliOutcome rather than calling process exit inside library code.
- Test absent file, existing file without --yes, existing file with --yes, and exact-target preservation.

## Finding 3 — Public Clap help, command docs, and runtime behavior are not semantically equivalent

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3, 3.1

Files and lines:

- Tools/openspec/src/cli/args.rs:77-90
- Tools/openspec/src/cli/args.rs:106-107
- Tools/openspec/src/cli/args.rs:318-340
- Tools/openspec/src/cli/instructions.rs:98-103
- Tools/openspec/src/cli/completion.rs:32-64
- Tools/openspec/src/cli/completion.rs:114-140
- Tools/openspec/docs/commands/instructions.md:3-10
- Tools/openspec/docs/commands/completion/install.md:3-10
- Tools/openspec/docs/commands/completion/uninstall.md:3-10
- Tools/openspec/tests/command_docs.rs:51-84

Three released semantic mismatches remain:

- Clap and both install/uninstall documents present elvish as a supported shell, while runtime exits 1 with “not yet supported.”
- Clap help and instructions.md show ARTIFACT in optional brackets, but invoking instructions without it returns “Missing required argument” and exits 1.
- validate --archived help says it validates completed task records, although 0.7 also audits abandoned and superseded closure dispositions.

The parity test derives the document file set from Clap but verifies only the heading and four prose markers. It does not compare Usage, arguments, flags, supported values, or exit behavior.

Reproduction:

1. Run openspec completion install elvish or completion uninstall elvish; observe the documented value fail at runtime.
2. Run openspec instructions --help and observe [ARTIFACT], then run openspec instructions --json and observe exit 1 because the argument is required.
3. Run openspec validate --help and observe the completed-only description.

Expected fix:

- Either implement Elvish install/uninstall or remove it from those operations while retaining it for generate.
- Make ARTIFACT a required Clap argument, or implement a documented no-argument behavior.
- Update archived help to describe closure and task-history audit.
- Extend command tests to compare generated Usage/flags/value sets and add a legal/illegal behavior matrix for every leaf command.

## Finding 4 — superseded_by is not a resolvable, non-self, acyclic successor

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3, 4.2

Files and lines:

- Tools/openspec/src/core/manifest.rs:234-270
- Tools/openspec/src/cli/objects.rs:671-732
- Tools/openspec/src/cli/validate.rs:421-537
- Tools/openspec/tests/project_commands.rs:261-297

ChangeClosure validates only the syntax of superseded_by. Archive and archived validation do not resolve the successor, reject self-reference, or build a successor graph to detect cycles. The existing project_commands test archives a record pointing to Runtime/replacement without creating that change, so the suite currently codifies a dangling successor as valid.

Reproduction:

1. Prepare a canonical completed Task DAG.
2. Archive with kind: superseded and superseded_by: product/does-not-exist.
3. change archive succeeds.
4. validate --archived exits 0 and reports the record valid.

The same path accepts superseded_by equal to the record itself and allows two or more archived records to form a cycle.

Expected fix:

- Resolve superseded_by against the combined active and archived change identity set.
- Reject missing and self successors.
- Detect cycles across the full archived successor graph.
- Preserve a stable UID link, or define an unambiguous canonical-ID policy when multiple historical records reuse an ID.
- Test active successor, archived successor, alias, missing target, self target, two-node cycle, and longer cycle.

## Finding 5 — Early abandoned or superseded changes cannot pass archived audit

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3, 4.2

Files and lines:

- Tools/openspec/src/cli/objects.rs:671-732
- Tools/openspec/src/cli/validate.rs:421-481
- .agents/skills/openspec-archive-change/SKILL.md:18-20
- .agents/skills/openspec/references/record-schema.md:56-72

The archive primitive accepts a valid abandoned or superseded closure and moves the record without enforcing planning completion, which is the intended primitive/policy boundary. Post-archive validation, however, checks for tasks.md and at least one canonical Task DAG node before branching on closure kind.

Therefore a change intentionally terminated before task planning can archive successfully and then remain a permanent validate --archived failure, even though it has no actual incomplete tasks requiring dispositions.

Reproduction:

1. Create a change with proposal or early exploration records but no tasks.md.
2. Archive it using an abandoned closure with a reason, or a superseded closure with reason and successor.
3. Archive succeeds.
4. validate --archived fails with “Archived change must contain tasks.md” or “must contain at least one canonical Task DAG node.”

Expected fix:

- Keep completed closure strict: a readable canonical tasks.md is required and every node must be complete.
- For abandoned/superseded closure, permit tasks.md to be absent when no Task DAG was created.
- If tasks.md exists, require UTF-8 and a valid canonical DAG, then require exactly one disposition for each incomplete node and reject dispositions for unknown/completed nodes.
- Synchronize the closure reference, archive skill, README/architecture prose, and tests.

## Finding 6 — Default apply semantics silently promote optional artifacts to mandatory

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3

Files and lines:

- Tools/openspec/src/cli/instructions.rs:220-235
- Tools/openspec/src/core/artifact.rs:228-234
- Tools/openspec/src/core/workflow_definition.rs:15-22

When a custom workflow omits the apply section, both operation-instruction and legacy status logic default apply.requires to every artifact. This includes artifacts explicitly declared required: false. Optional planning records therefore become mandatory only at apply time.

Reproduction:

1. Define a valid custom workflow with required proposal and optional design, but no apply section.
2. Create proposal and leave design absent.
3. Run instructions apply.
4. The result is waiting with missingRequires containing design.

Expected fix:

- Default apply requirements to artifacts whose required flag is true, or make apply explicit and required in the workflow schema.
- Never reinterpret required: false as mandatory through an implicit fallback.
- Add status/instructions parity tests for omitted apply, explicit empty apply, and mixed required/optional artifacts.

## Finding 7 — An invalid Task DAG is reported as ready to apply

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3

Files and lines:

- Tools/openspec/src/cli/instructions.rs:246-259
- Tools/openspec/src/cli/instructions.rs:262-278
- Tools/openspec/src/cli/status.rs:93-113
- .agents/skills/openspec-apply-change/SKILL.md:8-13

Operation instructions correctly parse the shared TaskPlan and expose taskIssues. However, when required artifacts exist and the task plan is invalid, task_plan_valid is false only for the Complete branch; control falls through to WorkflowState::Ready. status propagates the same state.

The apply skill consumes instructions first and derives ready nodes from it. It runs strict validation only after the implementation loop, so a malformed plan can be advertised as executable before the validation gate.

Reproduction:

1. Create proposal and tasks.md so the required artifact files exist.
2. Give tasks.md a cycle, a missing After field, or another canonical TaskPlan error.
3. Run instructions apply --json or status --json.
4. Observe non-empty taskIssues together with state: ready.

Expected fix:

- Add an explicit invalid/blocked operation state, or report waiting whenever tracked TaskPlan issues exist.
- Ensure apply can never be Ready or Complete with taskIssues.
- Require strict change validation before the first implementation node in the lifecycle skill.
- Add status and instructions regression tests for every TaskPlan issue class.

## Finding 8 — Portable workflow paths accept Windows alternate data streams

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3

Files and lines:

- Tools/openspec/src/core/workflow_definition.rs:216-243
- Tools/openspec/src/cli/instructions.rs:151-200

The portable-path validator rejects a colon only when it appears in the first slash-separated segment. A later segment such as nested/record.md:secret passes workflow validation. On Windows this can address an NTFS alternate data stream, while instructions exposes it as a normal concrete writePath.

Reproduction:

1. Define a workflow artifact with generates: nested/record.md:secret and a normal template.
2. Run workflow validate; it exits 0 and reports the workflow valid.
3. Resolve instructions for that artifact; writePath contains the ADS path.

Expected fix:

- Apply one centralized portable relative-path validator to generates, template, apply/archive tracks, and any other workflow-owned paths.
- Reject colon and control characters in every segment.
- Reject Windows reserved device names and trailing dot/space aliases.
- Retain the existing absolute, parent traversal, separator, glob, symlink, junction, and physical-containment checks.
- Add Windows ADS, UNC, device-name, and trailing-dot/space tests.

## Finding 9 — Validation concurrency can create an unbounded number of OS threads

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3

Files and lines:

- Tools/openspec/src/cli/args.rs:123-124
- Tools/openspec/src/cli/validate.rs:265-305

The argument parser accepts any positive usize. Worker count is limited only by the number of selected records, not by a safe process maximum. A large repository combined with a large flag or OPENSPEC_CONCURRENCY value can request thousands of native threads and exhaust address space or OS handles before useful validation completes.

Reproduction:

1. Prepare a repository with a very large number of independently valid records.
2. Run validate --all --concurrency with an equally large positive value, or set OPENSPEC_CONCURRENCY.
3. execute_tasks spawns min(requested, task_count) native threads.

Expected fix:

- Apply a documented hard upper bound, preferably also informed by available_parallelism.
- Use a bounded worker pool rather than one native thread for every requested worker.
- Report the effective concurrency in debug/structured output where useful.
- Test extreme CLI and environment values without creating extreme threads.

## Finding 10 — workflow fork --force can destroy the old package and leave a partial replacement

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3

Files and lines:

- Tools/openspec/src/cli/workflow_definition.rs:118-139
- Tools/openspec/src/cli/workflow_definition.rs:252-300

With --force, the existing destination is permanently removed before any source copy, rewrite, or final validation succeeds. An I/O, permission, disk-space, template, or serialization failure leaves the prior workflow lost and the replacement absent or partial. Recursive copy also uses read_dir(...).flatten(), silently dropping directory-entry errors.

Reproduction:

1. Create a valid destination workflow containing user changes.
2. Fork another on-disk workflow over it with --force.
3. Inject a copy/read/write failure after destination removal.
4. The original package is gone and no rollback restores it; a partially copied package may remain.

Expected fix:

- Copy into a sibling staging directory.
- Reject links using symlink_metadata, propagate every directory-entry error, rewrite the name, and fully validate the staged workflow/templates.
- Atomically swap the staged package into place with a backup/rollback path.
- Add failure-injection tests at read, copy, rewrite, validation, and rename boundaries.

## Finding 11 — The package publisher does not enforce its declared release gates

    severity: Required
    status: resolved
    affected_tasks: 1.2, 1.3, 3.1

Files and lines:

- .agents/skills/openspec/SKILL.md:47-49
- .agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1:57-82
- .agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1:84-129
- .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1:51-93

The documented release contract requires clean source, an exact tag, fmt, Clippy, locked tests, locked Release build, command-doc parity, and a bound package manifest. The publisher checks clean status and an exact tag but runs only cargo build --release --locked. It can package a clean, tagged commit whose tests or Clippy fail as long as it compiles.

The tag check uses git describe and does not prove that the tag is annotated. The current release is correctly annotated, but future publisher runs do not enforce that property. Package replacement also removes the current command directory before the new copy and manifest are completely staged and verified.

Reproduction:

1. Commit and tag a source change that compiles but causes a test or Clippy failure.
2. Run Publish-OpenSpecPackage.ps1.
3. The script builds, copies the binary/docs, and emits a release manifest without running the failed gate.

Expected fix:

- Before any package mutation, run cargo fmt --check, cargo clippy --locked --all-targets -- -D warnings, cargo test --locked --all-targets, and cargo build --release --locked.
- Verify v<version> is an annotated tag object and peels to sourceCommit.
- Run the Clap/document parity gate before packaging.
- Stage EXE, docs, and manifest together, verify their hashes/digest/version, then replace the package with rollback.
- Record exact gate commands/results or immutable CI provenance in the manifest.
- Extend the package test to verify tag type/target and release-gate metadata.

## Finding 12 — Archive and update skills point to nonexistent schema references

    severity: Required
    status: resolved
    affected_tasks: 1.3, 3.1, 4.2

Files and lines:

- .agents/skills/openspec-archive-change/SKILL.md:8
- .agents/skills/openspec-update-change/SKILL.md:13
- .agents/skills/openspec/references/record-schema.md
- .agents/skills/openspec/references/attachments.md

The archive skill tells the agent to read openspec/references/record-schema.md and openspec/references/attachments.md. The update skill uses the same openspec/references prefix. Relative to either sibling SKILL.md, those paths resolve below openspec-archive-change/openspec or openspec-update-change/openspec and do not exist. Relative to the project root, they instead point into the record repository, where they also do not exist.

The real references are under the sibling .agents/skills/openspec/references directory. The broken mandatory read prevents lifecycle policy from being followed deterministically.

Reproduction:

1. Resolve the paths exactly as written from the declaring SKILL.md directory.
2. Test both files.
3. Neither exists; only ../openspec/references/<file> exists.

Expected fix:

- Use explicit clickable relative links to ../openspec/references/record-schema.md and ../openspec/references/attachments.md.
- Add a link/path checker covering every mandatory lifecycle reference.
- Keep the current useful boundary: top-level openspec routes binary/commands, while continue/update/apply/verify/sync/archive own policy.

## Finding 13 — Closureless legacy classification has no provenance

    severity: Advisory
    status: resolved
    affected_tasks: 1.2, 4.2

Files and lines:

- Tools/openspec/src/core/manifest.rs:311-326
- Tools/openspec/src/core/project_repository.rs:453-475
- Tools/openspec/src/cli/validate.rs:448-472

The compatibility rule treats every archived record without closure as legacy completed history. There is no archive-schema version, migration marker, or cutoff provenance. Removing closure from a newly created 0.7 archive while retaining archived_at lets a fully checked legacy-style list pass the weaker compatibility audit and discards the original reason/dispositions.

This behavior matches the current minimal backward-compatibility rule, so it is Advisory rather than a gate blocker. It should nevertheless be an explicit trust decision.

Reproduction:

1. Create a 0.7 archive with closure.
2. Remove only closure while preserving archived_at and a fully checked legacy checklist.
3. doctor and validate --archived accept it as legacy.

Suggested follow-up:

- If tamper-evident closure matters, migrate known legacy records explicitly and require closure for the current archive schema, or add an unambiguous legacy/schema marker.
- Otherwise document that Git history, rather than the validator, is the provenance boundary for closureless records.

## Finding 14 — TaskPlan is reparsed and recompiles regexes on hot validation paths

    severity: Advisory
    status: deferred
    affected_tasks: 1.2

Files and lines:

- Tools/openspec/src/core/task_plan.rs:49-56
- Tools/openspec/src/cli/validate.rs:540-565
- Tools/openspec/src/cli/validate.rs:570-572

validate_text_file first calls task_progress, which parses the TaskPlan, then parses the same content again to append issues. Each parse recompiles the legacy and canonical regular expressions.

Correctness is unaffected and measured project validation remains fast, so this does not block the release.

Suggested follow-up:

- Parse each tasks.md once and reuse the TaskPlan for progress and diagnostics.
- Store fixed regular expressions in LazyLock or OnceLock.
- Add a focused benchmark only if repositories grow enough for this path to matter.

## Finding 15 — Move/archive rollback failures are silently discarded

    severity: Advisory
    status: deferred
    affected_tasks: 1.2, 4.2

Files and lines:

- Tools/openspec/src/cli/objects.rs:940-956

Rollback restores manifests, directories, and parents with ignored results. Under a second I/O failure, the caller sees only the original error and may assume the active source was restored even when rollback was partial.

Normal collision preflight and rollback paths are otherwise sound and covered, so this is an extreme-failure diagnostic gap.

Suggested follow-up:

- Aggregate rollback errors with the original failure.
- Report every path requiring manual recovery.
- Add injected failures for manifest restore, parent creation, and reverse rename.

## Coordinator resolution evidence — OpenSpec 0.7.1

Resolution snapshot:

- Source commit: `eb895601ce736f2d708802be492a54c74fe7d8e2`.
- Annotated tag: `v0.7.1`; tag object `9e86f49f39038b119777fedc6a5b73be791b00e5`; peeled target equals the source commit.
- Bundled Release EXE: `openspec 0.7.1`, 2,889,216 bytes, SHA-256 `0c73be92ffe2a9cc6481d3ec612a2ada56bddaa9db5981f22df935f2552d0e1d`.
- Command package: 32 files, digest `4b19a386a0722b17f512263b920349b7bf3b371b6af70587bc189dee8320dfc3`.
- Release gates: `cargo fmt --check`, locked all-target Clippy with warnings denied, locked all-target tests, focused command-doc parity, and locked Release build all passed before package mutation. The all-target run passed `145/145` tests.
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1` passed in Windows PowerShell 5.1 and PowerShell 7 after publication.

Finding resolutions:

1. **Resolved.** One core workflow-name contract now governs definitions, project/user resolution, CLI overrides, config, manifests, `which`, `validate`, `fork`, and `init`. Physical containment and definition/package identity are checked; packages, templates, recursive-copy entries, junctions, links, reparse points, traversal, absolute/mixed paths, and Windows aliases are rejected. `workflow_contract` and `manifest_model` contain project/user traversal, identity, link/junction, and portable-name regressions.
2. **Resolved.** Existing completion files require `--yes`; absent files are a no-op; only the exact managed file is deleted. The library path returns errors instead of exiting. Isolated unit tests cover absent, refusal/preservation, and confirmed exact-target removal.
3. **Resolved.** Elvish is supported only by `generate`; install/uninstall expose Bash, Zsh, and Fish. `instructions` requires `ARTIFACT` at Clap, and archived help names closure/task-history audit. `command_docs` recursively compares command paths, public long options, usage semantics, required artifact behavior, and the shell matrix.
4. **Resolved.** Supersession resolves combined active/archive canonical IDs and aliases, stores `superseded_by_uid`, rejects missing/self/ambiguous targets and cycles, gives active identities precedence, and audits tampered archive graphs. Active, archived, alias, ambiguity, self, two-node, and long-cycle tests pass.
5. **Resolved.** Completed closure requires a readable non-empty all-done canonical DAG. Abandoned/superseded may end before task planning; when nodes exist their DAG and exact incomplete-task dispositions are validated. Focused closure tests and docs agree.
6. **Resolved.** Omitted `apply` now requires only artifacts declared `required: true`; explicit empty requirements stay empty. Legacy status and operation instructions share the behavior and parity tests.
7. **Resolved.** A tracked Task DAG with any parse/dependency/cycle/completion issue yields `waiting`, never `ready` or `complete`, in both instructions and status. Five issue-class regressions pass.
8. **Resolved.** The centralized portable-path validator rejects colons/ADS, controls, UNC/drive paths, reserved device aliases (including superscript variants), trailing dots/spaces, invalid globs, links, and containment escapes in every segment and workflow-owned field.
9. **Resolved.** Effective validation concurrency is bounded by host available parallelism, selected item count, and hard maximum 32 at both parse and execution boundaries. JSON reports `effectiveConcurrency`; extreme flag/environment values are tested without extreme thread creation.
10. **Resolved.** Forced fork/init stages and validates a sibling package, swaps through a unique backup, rolls back failed install rename, and cleans only after success. Reads/copies propagate errors and reject linked existing destinations. Validation preservation, install failure, successful force-init, and junction tests pass.
11. **Resolved.** The publisher derives the Cargo version, verifies a clean exact annotated tag and peeled target, runs all five gates before mutation, stages the EXE/docs/manifest, verifies hashes/digests/version, and swaps with rollback. The manifest binds gate results and tag object/target; the package test enforces every field.
12. **Resolved.** Lifecycle Skills use clickable `../openspec/references/...` links. The package test resolves every declared lifecycle reference and fails on a missing target.
13. **Resolved.** Current archives declare `archive_schema: closure-v1`; the three known self-hosted compatibility records explicitly declare `legacy-completed-v0`. Removing current closure no longer silently reclassifies a record as legacy, and tamper tests cover the provenance rule.
14. **Deferred Advisory.** Correctness and the measured project validation path remain bounded; the 0.7.1 gate does not require speculative caching. Follow-up is the separately named future maintenance change `optimize-openspec-taskplan-and-rollback-diagnostics`, which will parse each task file once and benchmark before introducing a regex cache.
15. **Deferred Advisory.** Existing collision preflight and normal rollback behavior remain tested; the residual issue concerns reporting a second, injected rollback failure. The same future maintenance change `optimize-openspec-taskplan-and-rollback-diagnostics` will aggregate original/rollback errors, emit manual-recovery paths, and add reverse-rename/manifest-restore fault injection.

Task `1.2` owns the source fixes and release evidence. Independent re-review of this new immutable snapshot is required before Task `1.3` or this review state can close.

## Positive architectural findings

- instructions, status, active validation, and archived validation share the same TaskPlan parser.
- Missing dependency, self dependency, cycles, duplicate IDs, malformed nodes, and completed-on-incomplete dependency errors are implemented and tested.
- Required artifact validation rejects absence while optional artifact absence is accepted.
- Glob artifacts return outputKind: glob and writePath: null.
- Strict repository inspection rejects symbolic links, Windows junctions, and reparse points inside object leaves.
- validate emits the complete deterministic report before main maps a failed total to exit code 1.
- Archive preflights collisions, records explicit closure, performs a pure directory move without spec merge, and has best-effort rollback.
- Source/bundled EXE and command docs are cryptographically bound for this fixed snapshot.
- The lifecycle skill split is directionally sound: top-level openspec owns binary and command routing; update/apply/verify/sync/archive retain distinct policy boundaries.
- No normal-path security or performance problem was found in bounded default validation concurrency, process startup, JSON output, or Release binary size.

## Gate disposition

The fixed package must not be marked reviewed or ready for archive while Finding 1 or any Required finding remains open. The coordinator should reproduce/triage each item, create follow-up tasks without rewriting this review, attach resolution evidence, request re-review, and only then close or supersede this file.

## Review supersession

This historical REQUEST_CHANGES snapshot is superseded. Findings 1-13 were resolved by the coordinator evidence above and carried through the later immutable releases. Findings 14-15 are Advisory, remain explicitly deferred to `optimize-openspec-taskplan-and-rollback-diagnostics`, and do not gate closure. The later 0.7.2 review replaced this release gate; the final accepted package is independently bound and approved by `review-20260903-003535-openspec-081-fixed-snapshot.md`. The original observations and verdict remain unchanged.
