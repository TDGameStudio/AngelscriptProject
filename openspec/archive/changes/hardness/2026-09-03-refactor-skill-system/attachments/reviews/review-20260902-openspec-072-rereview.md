---
state: superseded
review_result: request_changes
reviewed_at: 2026-09-02T21:33:43.2358681+08:00
superseded_at: 2026-09-03T01:29:26.4121259+08:00
superseded_by: review-20260903-003535-openspec-081-fixed-snapshot.md
review_scope: Portable OpenSpec 0.7.2 source, immutable release identity, packaged executable and command docs, publisher, English-only gate, and archive validation behavior
prior_review: review-20260902-194012-openspec-07-package.md
snapshot:
  source_commit: 7fd7cfab8939565cf80dac35a684329fa9cb028a
  source_tag: v0.7.2
  source_tag_kind: annotated
  source_tag_object: 00675ed5c42032ea456c033c584021e34ea43a75
  source_tag_target: 7fd7cfab8939565cf80dac35a684329fa9cb028a
  release_exe_sha256: d917d5fa7e3b750fd77f369e92ead88360b88fc25e60ea89071195f72d478154
  release_exe_size: 2889216
  command_doc_count: 32
  command_docs_digest: df696be0e80c7b199af5b1f6139c438a69b78dbb5db1da61eaacbbe010abd1ed
  release_manifest_sha256: cce575f49d7673c001312136a70051b0763c196d409060b18926a99f835505ed
  publisher_sha256: 346c460397ab54bfbe78ec445179b89c5afae89514264f64d59b129bf00c06e0
  package_test_sha256: 370bcbcb04bd2682de76a6e9caedbb5b87af99d039529db18f38ba752cfe8107
  skills_readme_sha256: b12a3f0c6591d061a178822bda82e72a7a701e526a49694f1ad5db2d717bc48f
  parent_base: 4129487f63fab930800a896ae7f932d7bd4e6e70
---

# OpenSpec 0.7.2 Fixed-Snapshot Re-review

The Review Gate is open and the result is **REQUEST CHANGES**. The immutable Git identity, executable, command package, manifest, full Rust test suite, and ordinary validation performance are reproducible. However, one Critical and two Required findings block Task 1.3, package acceptance, completed closure, archive, and integration.

The most serious issue is not theoretical: the packaged executable accepted a Windows junction at the project `openspec` root and performed a successful `domain create` outside the logical project. The English-only gate also passes while an OpenSpec-facing maintained document still declares Chinese as the default and while several non-English scripts are outside its blacklist. The package publisher's root guard similarly begins below the path it claims to protect and can stage, swap, or recursively clean through a linked Skill root.

## Fixed-snapshot evidence

- `Tools/openspec` was clean at `7fd7cfab8939565cf80dac35a684329fa9cb028a`.
- `v0.7.2` is an annotated tag object at `00675ed5c42032ea456c033c584021e34ea43a75`; it peels to the exact source commit.
- The packaged executable reports `openspec 0.7.2`, is 2,889,216 bytes, and has SHA-256 `d917d5fa7e3b750fd77f369e92ead88360b88fc25e60ea89071195f72d478154`.
- An independent locked Release rebuild produced the exact same executable SHA-256.
- The release manifest binds the source commit, annotated tag object and target, MSVC target, Release profile, toolchain, five release gates, executable hash and size, 32 command documents, and digest `df696be0e80c7b199af5b1f6139c438a69b78dbb5db1da61eaacbbe010abd1ed`.
- `cargo fmt --check` passed.
- `cargo clippy --locked --all-targets -- -D warnings` passed.
- `cargo test --locked --all-targets` passed: 145 passed, 0 failed.
- `cargo build --release --locked` passed and reproduced the packaged binary byte for byte.
- `OpenSpecSkill.Tests.ps1` passed under Windows PowerShell 5.1 and PowerShell 7.
- Packaged `doctor --json`, `workflow validate angelscript --json`, and strict validation of `hardness/refactor-skill-system` exited 0.
- `validate --archived --strict --json` exited 0 with zero selected archives. This proves empty-selection behavior only; it is not evidence for the eventual archived form of this change. The Rust closure fixtures cover completed, early abandoned, superseded, disposition, provenance, and successor-cycle behavior, while the final change still requires a real post-archive strict audit.
- Twenty-call medians on this host were approximately 16.77 ms for `--version`, 23.05 ms for `doctor --json`, and 25.80 ms for strict validation of the active change. No normal-path performance blocker was found.

## Finding 1 — A linked OpenSpec root escapes the project and permits external mutation

    severity: Critical
    status: resolved
    prior_finding: 1 was incomplete; this re-review supersedes its resolved disposition
    affected_tasks: 1.3, 3.1, 4.1, 4.2

Files and lines:

- `Tools/openspec/src/core/project_repository.rs:203-210`
- `Tools/openspec/src/core/project_repository.rs:236-254`
- `Tools/openspec/src/core/project_repository.rs:763-792`
- `Tools/openspec/src/cli/objects.rs:1027-1075`
- `Tools/openspec/src/core/workflow_definition.rs:535-625`
- `Tools/openspec/src/cli/workflow_definition.rs:40-55`
- `Tools/openspec/src/cli/workflow_definition.rs:707-760`

`ProjectRepository::inspect` starts with `Path::is_dir`, which follows a symbolic link or Windows junction. It never calls `symlink_metadata` on `openspec_root` and never proves that the physical repository remains inside the selected project. The direct object roots reject links only at their final component. This does not protect the `openspec` root itself, nor an intermediate component such as `archive` in `archive/changes`.

All object mutations trust the resulting snapshot and build targets below the lexical `openspec_root`. `apply_moves` then creates directories, renames trees, and writes manifests without a physical containment preflight. The existing `core/path_safety.rs` helpers are not used by any production call site.

The workflow surface has a second inconsistent route. `resolve_workflow` explicitly rejects a linked project `openspec` root, but `list_workflows` and `resolve_with_shadows` call `resolve_workflow_from_root` directly. They prove only that a package is inside the already-escaped `workflows` root. Consequently `workflow list` and `workflow which` accept the same project shape that `workflow validate`, `status`, and `instructions` reject.

### Reproduction evidence

The reproduction used only a generated system-temporary fixture and the packaged 0.7.2 executable.

1. Initialize a valid OpenSpec repository under a temporary `external-project` directory.
2. Create a separate temporary `project` directory.
3. Create `project/openspec` as a Windows junction to `external-project/openspec`.
4. From `project`, run `openspec domain create escaped --title Escaped --json`.
5. The command exits 0 and creates `external-project/openspec/domains/escaped/domain.yaml` outside the logical project.

A second fixture linked `project/openspec` to an external tree containing `workflows/evil`:

- `openspec workflow which evil --json` exited 0 and returned the external physical path.
- `openspec workflow list --json` exited 0 and exposed the external workflow description and artifact IDs.
- `openspec workflow validate evil --json` exited 1 with the expected reparse-root rejection.

Both temporary fixtures were removed after their exact paths and junction attributes were verified.

### Impact

- A repository path that appears to be project-local can redirect create, move, archive, manifest-write, initialization, and rollback operations to another filesystem tree.
- Archive targets can escape through an intermediate linked `archive` component even if `archive/changes` itself appears as a normal directory.
- Read-only workflow commands disagree with execution commands and can disclose external workflow metadata as project-owned content.
- The result violates the fixed package's stated physical-containment and reparse-rejection architecture and creates data-loss and prompt-boundary risk.

### Required resolution

- Add one fallible repository-root preflight used by `inspect`, `load_strict`, initialization, every object mutation, and archived validation. It must inspect `openspec_root` with `symlink_metadata`, reject symbolic links, Windows junctions, and all reparse points, canonicalize the project and OpenSpec roots, and prove physical containment.
- Inspect every existing managed path component, not only the leaf root. At minimum cover `openspec`, `domains`, `specs`, `changes`, `archive`, `archive/changes`, `workflows`, object ancestors, and every source/target parent used by create, move, and archive.
- Apply physical containment immediately before mutation as well as during repository inspection so a stale snapshot cannot authorize a changed path graph.
- Route `workflow list`, `workflow which`, `workflow validate`, resolver fallback, fork, status, and instructions through the same guarded project/user-root resolver. Do not silently flatten directory-entry or security-resolution errors on a project-owned workflow root.
- Add Windows-junction and Unix-symlink regressions for `doctor`, `init`, `domain create`, leaf/domain move, archive, `validate --archived`, `workflow list`, and `workflow which`. Each mutation test must assert that no external marker or target is created, moved, changed, or removed.
- Add an intermediate `openspec/archive` link fixture, not only a directly linked final root.
- Preserve immutable `v0.7.2`; source changes require a new version, clean commit, annotated tag, full locked gates, repackaging, and a new fixed-snapshot review.

## Finding 2 — The English-only gate misses an actual contradictory policy and broad script classes

    severity: Required
    status: resolved
    affected_tasks: 1.3, 3.1, 4.1

Files and lines:

- `.agents/skills/README.md:23-44`
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1:44-75`
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1:78-91`
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1:109-110`

The package test scans `Tools/openspec`, `.agents/skills/openspec`, the project `openspec` tree, and directories matching `.agents/skills/openspec-*`. It does not scan `.agents/skills/README.md`, even though that file is the maintained OpenSpec workflow and Skill guide. The omitted file currently says:

```text
Skills and references are English; project OpenSpec records default to Chinese.
```

That statement directly contradicts the current English-only project policy, yet the package test passes in both PowerShell hosts.

The content check is also a blacklist of selected Unicode blocks. A direct evaluation of the released test pattern returned `False` for all of these non-English samples:

```text
Greek:     alpha rendered as Greek alpha
Armenian:  Armenian-language letters
Georgian:  Georgian-language letters
Bengali:   Bengali-language letters
Tamil:     Tamil-language letters
Ethiopic:  Ethiopic-language letters
```

The file inventory is extension-based and omits maintained text such as `.gitignore` and extensionless text files. The current repository happens to contain no non-ASCII letters outside the `_ZH` exception among the files the reviewer enumerated, but the gate does not enforce the declared future invariant.

### Impact

- The release can claim a complete English-only gate while contradictory OpenSpec-facing policy remains checked in.
- Future non-English content in several major scripts or omitted text-file classes can pass both package test hosts.
- Passing gate evidence is therefore not equivalent to the user-approved language contract.

### Required resolution

- Correct `.agents/skills/README.md` so maintained OpenSpec records are English. The only temporary exception is a filename containing exact uppercase `_ZH` at the end of the stem or before its extension.
- Define the complete maintained OpenSpec surface once and include the root Skill guide plus every OpenSpec source, project record, lifecycle Skill, reference, command document, script, manifest, and relevant text control file.
- Replace the script-block blacklist with a Unicode-category policy that rejects non-ASCII letters and non-ASCII language digits while allowing intentional punctuation and diagram symbols. Enumerate Unicode scalar values so supplementary-plane letters cannot bypass the check.
- Keep the exemption filename-only, case-sensitive, and exact. A parent directory containing `_ZH`, lowercase `_zh`, or `_ZH` embedded in an unrelated suffix must not exempt a file.
- Add RED/GREEN fixtures for Greek, Armenian, Georgian, Bengali, Tamil, Ethiopic, supplementary letters, a non-English path segment, `.gitignore`, an extensionless text file, lowercase `_zh`, and the one valid uppercase `_ZH` filename.
- Run the gate under Windows PowerShell 5.1 and PowerShell 7 after the inventory and Unicode logic are shared or proven equivalent.

## Finding 3 — The publisher checks below the Skill root after staging has already begun

    severity: Required
    status: resolved
    prior_finding: 11 remains only partially closed for linked-root safety
    affected_tasks: 1.3, 3.1, 4.1

Files and lines:

- `.agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1:77-95`
- `.agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1:221-230`
- `.agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1:254-260`
- `.agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1:269-316`

`Assert-NoReparsePathComponents` initializes `$current` to `$rootFull` and then inspects only segments relative to it. It never inspects `$rootFull` itself or the existing components from the canonical project root to `.agents/skills/openspec`.

The publisher creates its staging directory and copies the executable and recursive command documentation before calling that helper for the three final targets. If `.agents/skills/openspec` is a junction or symlink, staging, backup, target replacement, rollback, and final recursive cleanup all operate in the linked external tree. The final cleanup uses `Remove-Item -Recurse -Force` on the generated stage and backup locations without revalidating their current physical identity.

The current package root is physical and the reviewed publish succeeded. This finding concerns the reusable safety contract of the publisher, not the identity of the already hashed executable.

### Required resolution

- Before running gates or creating a stage, resolve the project root, Skill root, package root, and every existing ancestor with a case-correct physical containment check; reject any symbolic link, junction, mount-style reparse point, or escaped canonical target.
- Inspect the Skill root itself, not only its descendants.
- Revalidate stage, backup, and target identity immediately before each move or recursive cleanup. If identity cannot be proven, preserve the recovery payload and report its exact path instead of deleting it.
- Make the root/path validator independently testable without invoking a real release. Add temporary junction/symlink fixtures for the Skill root, `bin`, `commands`, stage, and backup paths, and assert that no external marker changes.
- Retain the existing clean-source, annotated-tag, locked-gate, source-stability, manifest, digest, version, staged-swap, rollback, and rollback-error requirements.

## Prior-review disposition

- Prior Finding 1 is not accepted as fully resolved because the shared repository root and the `workflow list/which` routes remain outside the physical-containment policy. New Finding 1 above is authoritative for this snapshot.
- Prior Findings 2-10 and 12-13 were independently re-read against the fixed source and exercised by the 145-test locked suite. No additional blocker was found in completion confirmation, Clap/runtime command parity, supersession identity and cycles, early closure policy, optional apply defaults, invalid-DAG readiness, workflow-owned portable fields, bounded concurrency, transactional workflow replacement, lifecycle links, or archive provenance.
- Prior Finding 11's gate/tag/manifest/staged-swap behavior is reproducible, but its linked-root safety is incomplete and is now tracked by Finding 3.
- Prior Findings 14 and 15 remain deferred Advisory items assigned to `optimize-openspec-taskplan-and-rollback-diagnostics`. They are not Critical or Required blockers for this gate. No new performance regression or normal rollback failure was observed.

## Positive findings

- Correctness: source, tag, EXE, command docs, and manifest are mutually bound; the Release rebuild is byte-identical; full tests and both package hosts pass.
- Readability: closure types, stable successor UIDs, Task DAG parsing, effective concurrency, and workflow resolution are expressed through named structures rather than command-local ad hoc parsing.
- Architecture: the CLI remains a deterministic record primitive; archive is still a pure move with explicit closure and no hidden spec merge.
- Security: workflow package and template leaf checks, Windows special-path checks, completion confirmation, bounded concurrency, and package hash verification are substantial improvements. The open root findings identify the remaining trust-boundary gap.
- Performance: startup and project validation remain in the tens of milliseconds, and the worker pool is bounded by selected work, host parallelism, and the hard maximum of 32.
- Verification: archived closure behavior has focused fixtures, but the final project archive must still be validated after the real move rather than inferred from an empty archived selection.

## Gate conclusion

This review remains `open`. One Critical and two Required findings are unresolved, so the package must not be marked reviewed, Task 1.3 must not be completed, and the current change must not receive completed closure or archive approval.

Do not move or retag `v0.7.2`. Resolve the findings in a new source release, execute all locked release gates, publish a newly bound EXE/docs/manifest transaction, run both package-test hosts, and request another independent fixed-snapshot review. After all change tasks and review gates close, archive the real change and run `validate --archived --strict --json` against the resulting non-empty archive; a zero-item audit is not the final archive proof.

## Coordinator resolution and supersession

The original REQUEST_CHANGES evidence remains immutable. Task `1.5` reproduced all three findings and published the repaired, deterministic 0.7.4 boundary before later Task Graph releases:

- Finding 1 is resolved by centralized physical containment and reparse rejection across repository reads/writes, including project workflow discovery and linked-root fixtures.
- Finding 2 is resolved by the complete maintained-surface English gate, Unicode-category checks, exact `_ZH` filename exception, and PowerShell 5.1/7 package fixtures.
- Finding 3 is resolved by preflight and immediate revalidation of the Skill root, staging, backup, swap, rollback, and cleanup identities before mutation.

Task `1.5`, the preserved 0.7.4 release evidence, the subsequent 0.8.0 security review, and the closed 0.8.1 fixed-snapshot APPROVE provide the evidence chain. This file is therefore superseded without changing its historical verdict.
