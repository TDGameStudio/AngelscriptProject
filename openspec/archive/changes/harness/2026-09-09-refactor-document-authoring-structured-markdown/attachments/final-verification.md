# Final verification

## Release identity and gates

OpenSpec 0.9.0 is installed from clean source `aa9754508c384e392eecd1c54201c623dca3404e`, annotated tag `v0.9.0` (tag object `b615468fb744feec706c8ce9c05a2beffc12c0dd`). The release EXE SHA-256 is `8710e36a59b970e311c666d336d7fef4f9e76c0375e232dd0f8d440d69c6c4f2`, size 3,212,288 bytes. The package has README plus 31 command documents; their digest is `35fbe97cd5e7238958fed1900891a2c2d67d47aebdcbc1458a2f6ba6de9bcaac`.

`& ./.agents/skills/openspec/scripts/Publish-OpenSpecPackage.ps1 -ProjectRoot D:/Workspace/AngelscriptProject -Version 0.9.0` passed all six existing release gates:

1. `cargo fmt --check`
2. `cargo clippy --locked --all-targets -- -D warnings`
3. `cargo test --locked --all-targets` — 189 passing tests
4. `cargo test --locked --test command_docs` — 3 passing parity tests
5. `cargo build --release --locked`
6. Isolated locked Release rebuild and exact byte comparison — identical EXE hash

The final manifest retains gate/toolchain/tag/hash evidence. No candidate binary was committed to the parent. Only the source scope and its parent gitlink were committed; other parent implementation/package changes remain in the user's worktree. Nothing was pushed.

## Focused consumer checks

- `& ./.agents/skills/harness/tests/Harness.Tests.ps1` — PASS on final Harness code, including real task.status graph cases, old-format zero-node diagnostics, current-package installation health and corrupted-package negative controls.
- `& ./.agents/skills/harness/tests/TaskOutput.Tests.ps1` — PASS. RED first showed that the native empty-vector omission replaced the migration issue with a missing-tasks error. The adapter now materializes an empty tasks array only for a diagnosed waiting zero-node plan; malformed/nonzero/undiagnosed responses are still rejected.
- `& ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1` — PASS after final Harness changes.
- `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths <the owned OpenSpec skills, workflow/config/core-spec/change and Tools/openspec scopes>` — PASS, including package safety, installed EXE/docs/source alignment, authoring examples/scaffolds, lifecycle links and English-surface checks.
- Skill Creator validation passed for openspec and the five modified lifecycle skills. PowerShell syntax checks passed for modified test scripts. `git diff --check` passed.
- Default and exercise-mode `Authoring.Tests.ps1` results are documented in authoring-exercise.md. Three synchronized owned Requirement cards are complete and pass isolated strict validation.

The first installation-health run correctly rejected the new package while Harness still pinned 0.8.1. Pins were updated from the verified publisher result; all positive and corruption-negative health fixtures then passed. No release-source changes were needed after publication.

## Exact workspace checks

- `task.status` for this Change: valid four-node new-format plan; final task execution completed.
- Strict exact active Change validation: passed, run `fb77488a316645eeadf289c5582d74bd` (rerun during closure for final records).
- `openspec.doctor --json`: passed, run `c6a88034c9ae40d890294034d88cc664`.
- `openspec.maintenance.status`: aligned clean source, gitlink, package and manifest, run `f444e5f592e9449280609b39fbb1a2f0`.
- Read-only old business-record check, `task.status` for `angelscript/refactor-defaults-constructor-unification`: `waiting`, explicit `unsupported-task-format`, zero Ready tasks, and identical task-file SHA-256 before/after; run `605b691a30f64c8fb686956e2b72d44d`.

## Scope and intentionally omitted checks

No web or plugin/runtime implementation was changed. Existing business Change tasks/specs and all pre-existing archives remain unmodified. Only three directly affected authoring requirements in the current Harness core spec were synchronized; other current-spec content remains deferred as requested.

Full historical/current-business validation is not a new-format acceptance gate. No claim is made that the existing corpus already satisfies the new parser. The historically coupled Protocol test is not used as closure proof; its previously observed missing archive INDEX entry remains outside this Change, while its maintained Task fixtures were updated and syntax-checked. Quick/Performance/Integration aggregate profiles and real Unreal build/Automation were omitted because they do not match this portable parser/authoring change. The actual Harness route and lifecycle consumers were exercised directly.

The raw before/after exercise outputs are one-off evidence, not new reusable capability knowledge. No automatic Review was requested or created. Closure uses exact terminal evolution, strict exact-record validation and an isolated post-move authoring check.
