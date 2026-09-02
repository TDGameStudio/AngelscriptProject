---
state: closed
review_result: approve
reviewed_at: 2026-09-03T00:35:35.3913168+08:00
review_scope: Portable OpenSpec 0.8.1 fixed release, Task Graph compatibility repairs, archive boundary documentation, immutable package identity, publisher reproducibility, and package tests
snapshot:
  parent_base: 4129487f63fab930800a896ae7f932d7bd4e6e70
  source_base: 6492eb3f86238d0c445d06d0a980d8630480bfa1
  source_commit: 1930040ab18acba43d44fcd635d2a91a701f04ce
  source_tree: d7d534345e4d0aea046e8130d763a9f441a478dc
  source_tag: v0.8.1
  source_tag_kind: annotated
  source_tag_object: cd643b0bb1e12e09f32012bb2364f37e3f43db88
  source_tag_target: 1930040ab18acba43d44fcd635d2a91a701f04ce
  source_diff_sha256: b4a4966dc21434267f5ceac9a1e8b37cf2634a2ac3a35255e8d119c3c5d005e2
  release_exe_sha256: 0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658
  release_exe_size: 2970112
  release_manifest_sha256: 87f5379473f6e34bece95e6774a559bc6c197d755354e611c9fac55cfe75788f
  command_doc_count: 32
  command_docs_digest: 85e8399a09ae013c365dd3b1652ae633ed127e983fd4e4466a5f7b143331a825
  package_scope_sha256: e9b536a578461f4e12662913eda95790ee4b887ced75b0d68faf73f1a6a17979
  publisher_sha256: 7a049af3102a2f0d349219c3c09d4ba354115463d624e25665df96fb11edbe95
  package_test_sha256: de9a747270b8ca66a7ff345062b4a2a13b3b5878a5ef61b96bfd3ea0b0f3955d
verdict: APPROVE
---

# OpenSpec 0.8.1 Fixed-Snapshot Review

OpenSpec 0.8.1 resolves every blocking boundary defect from the immutable 0.8.0 review without moving or retagging 0.8.0. The repaired source, annotated release tag, packaged executable, release manifest, and 32 command documents form one reproducible fixed snapshot. No Critical, Required, or Advisory finding remains in this review scope.

## Immutable Identity and Scope

- `Tools/openspec` was clean at `1930040ab18acba43d44fcd635d2a91a701f04ce` throughout this review.
- Annotated tag object `cd643b0bb1e12e09f32012bb2364f37e3f43db88` is `v0.8.1` and peels exactly to the reviewed source commit.
- The reviewed repair is the full raw `git diff --binary --full-index` from immutable 0.8.0 commit `6492eb3f86238d0c445d06d0a980d8630480bfa1` to 0.8.1; its SHA-256 is `b4a4966dc21434267f5ceac9a1e8b37cf2634a2ac3a35255e8d119c3c5d005e2`.
- The package-scope digest is SHA-256 over the sorted package-relative path, NUL, file bytes, NUL sequence for `bin/openspec.exe`, `release-manifest.json`, and all 32 `commands/**/*.md` files. It is `e9b536a578461f4e12662913eda95790ee4b887ced75b0d68faf73f1a6a17979`.
- The packaged EXE reports `openspec 0.8.1`, is 2,970,112 bytes, and has SHA-256 `0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658`.
- The package and source command-document trees independently produce the same canonical digest, `85e8399a09ae013c365dd3b1652ae633ed127e983fd4e4466a5f7b143331a825`; the package test additionally verifies every document byte-for-byte.

## Resolution of the 0.8.0 Findings

### UTF-8 BOM and CRLF

`src/core/task_plan.rs` now recognizes exactly one leading UTF-8 BOM only when it directly precedes the opening top-of-file `---`. It does not relax the existing no-leading-blank-line boundary, and an additional BOM remains invalid. Parser and CLI integration tests cover BOM plus CRLF and prove the same `after`, `ready`, instructions, and strict-validation behavior as canonical BOM-free content. An independent packaged-EXE project probe reproduced the former 0.8.0 failure case and returned `state: ready`, a ready root node, and a passing strict validation.

### Directly quoted Task Graph IDs and flow compatibility

The parser retains semantic YAML decoding while independently validating the source representation of every `task_graph.depends_on` key and dependency. Direct single and double quotes are accepted; explicit tags, anchors, aliases, complex keys, block scalars, and escaped scalar encodings are rejected. The lexical multiset must equal the semantically decoded task/dependency multiset, so an indirect spelling cannot be balanced by a different graph value.

The follow-up preserves the documented YAML surface instead of narrowing it: block and flow mappings, single-line and multi-line flow collections, and plain or quoted `task_graph` / `depends_on` structural field names are covered. Source tests reject both block and flow `!!str` bypasses. Independent package probes confirmed that an inline flow graph remains ready and strictly valid, while the exact 0.8.0 `!!str` key/dependency reproduction returns `waiting`, reports `invalid-task-graph`, and fails strict validation.

### Archive ownership documentation

`README.md`, `docs/ARCHITECTURE.md`, and `docs/STATE.md` now match `docs/commands/change/archive.md` and production behavior. The CLI owns deterministic structural authorization: closure shape, Task DAG completion or exact incomplete-task dispositions, successor integrity, target collision safety, and the content-preserving move. The caller or Hardness still chooses closure kind, verifies implementation and reviews, and synchronizes durable specifications. The command does not merge specifications or rewrite project documents, and `validate --archived` remains a separate post-move history audit. A packaged-EXE probe also confirmed that a `completed` closure with an incomplete valid DAG is rejected before either the active directory or archive target is mutated.

## Verification Story

- `cargo fmt --check`: PASS.
- `cargo clippy --locked --all-targets -- -D warnings`: PASS.
- `cargo test --locked --all-targets`: PASS, 168 tests across all unit and integration targets, 0 failed.
- `cargo test --locked --test command_docs`: PASS, 3/3.
- `cargo run --quiet --locked -- workflow validate spec-driven --json`: PASS with no issues.
- `cargo run --quiet --locked -- doctor --json`: PASS with no diagnostics.
- `cargo run --quiet --locked -- validate --all --strict --json`: PASS, 2/2 records.
- `git diff --check v0.8.0..v0.8.1`: PASS.
- Independent isolated `cargo build --release --locked --target-dir <temporary>` using Rust/Cargo 1.95.0 produced the exact packaged EXE size and SHA-256, independently confirming the manifest's byte-reproducibility gate.
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`: PASS under PowerShell 7.6.0 and Windows PowerShell 5.1.26100.8875. These gates verify source/tag/manifest binding, release-gate metadata, executable hash and version, 32-document parity and digest, English package surfaces, package safety, project workflow validation, and normal package behavior.
- Independent package-level probes: BOM+CRLF PASS; block/flow compatibility PASS; explicit `!!str` rejection PASS; incomplete-completed archive preflight and no-mutation guarantee PASS.

## Review Dimensions

- Correctness: the original encoding and lexical-contract failures are directly reproduced against the package and now pass/fail at the intended boundaries; graph JSON compatibility and archive safety remain intact.
- Readability: maintained documentation states one consistent parser and archive ownership model. The source scanner is isolated behind small helpers and backed by adversarial fixtures rather than hidden policy.
- Architecture: OpenSpec remains the deterministic record primitive; it does not absorb Hardness scheduling, implementation verification, review policy, specification sync, or AI decisions.
- Security: indirect YAML encodings fail closed, and archive rejection occurs before repository mutation. No network, telemetry, daemon, dynamic loading, or new external-write surface was added.
- Performance: the additional work is bounded to one already-loaded frontmatter string and linear scans of its mapping/quoted scalars. No worker, polling loop, cache, or persistent process was introduced.
- Verification: source tests, package tests on both supported PowerShell hosts, independent adversarial package probes, and an isolated byte-identical Release rebuild all bind behavior to the same annotated release identity.

## Decision

**APPROVE.** This review is `closed`. OpenSpec 0.8.1 has no open Critical or Required finding and is suitable to satisfy the fixed-snapshot Review Gate. The earlier 0.8.0 review remains immutable history and should be resolved or superseded by the coordinator with links to this approved snapshot; this review does not rewrite that record or decide the coordinator's task state.
