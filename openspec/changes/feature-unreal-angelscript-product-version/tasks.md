## 1. OpenSpec Record

- [x] 1.1 <!-- Non-TDD --> Create the `feature-unreal-angelscript-product-version` change through the OpenSpec CLI.
- [x] 1.2 <!-- Non-TDD --> Record current version authority, approved decisions, compatibility break, impact boundaries, and batched-build discipline in proposal, background, design, and specifications.
- [x] 1.3 <!-- Non-TDD --> Validate the complete OpenSpec record with strict JSON validation.

## 2. Native Version Contract

- [x] 2.1 <!-- TDD --> Add CQTest-native SDK scenarios for owned identity, upstream lineage, current creation, legacy rejection, newer/different-major rejection, encoding, and synthetic SemVer compatibility.
- [x] 2.2 <!-- TDD --> Add the UE-independent canonical version header with 1.0.0 constants, encoding, compatibility, and upstream-lineage constants.
- [x] 2.3 <!-- TDD --> Route `angelscript.h`, `asGetLibraryVersion()`, `asCreateScriptEngine()`, and the new upstream-lineage API through the owned contract, marking the ThirdParty fork edit with `[UE++]`.
- [x] 2.4 <!-- TDD --> Replace obsolete 2.33 current-version assertions in existing HeaderShim, Functional Upgrade, and Functional Core coverage without duplicating the dedicated version matrix.

## 3. Descriptor and Release Validation

- [x] 3.1 <!-- Non-TDD --> Set the core descriptor to integer `10000`, display `1.0.0`, and friendly name `Unreal AngelScript`; leave optional plugin descriptors unchanged.
- [x] 3.2 <!-- TDD --> Add the plugin-owned non-mutating `ValidateVersion.ps1` with success and injected-drift verification modes.
- [x] 3.3 <!-- Non-TDD --> Update the active standalone release design/tasks so future CLI, package, and GitHub release output consume the canonical product version.

## 4. Documentation

- [x] 4.1 <!-- Non-TDD --> Update `AGENTS_ZH.md` first and synchronize `AGENTS.md` with product version, lineage, hard-cut, and SemVer rules.
- [x] 4.2 <!-- Non-TDD --> Update the plugin README and fork strategy so current product identity and upstream lineage are clearly separated.
- [x] 4.3 <!-- Non-TDD --> Classify remaining 2.33 references as lineage/history/rejection evidence or correct stale current-version wording.

## 5. Batched Verification

- [x] 5.1 <!-- Non-TDD --> Run version validation, script parser checks, strict OpenSpec validation, and scoped whitespace checks before the UE build.
- [x] 5.2 <!-- TDD --> After all source code is written, run one concentrated `RunBuild.ps1` build and record/fix every related compiler issue.
- [x] 5.3 <!-- TDD --> Run version, HeaderShim, Functional Upgrade, and Functional Core focused prefixes and record exact results.
- [x] 5.4 <!-- TDD --> Run the NativeCore suite and record pass/fail/crash/timeout evidence.
- [x] 5.5 <!-- TDD --> Run the full `All` suite and record every failure, missing report, crash, timeout, and unrelated pre-existing issue separately.
- [x] 5.6 <!-- Non-TDD --> Re-run strict OpenSpec/version/whitespace validation and complete `verification.md` and `issues.md`.

## 6. Scoped Commits

- [x] 6.1 <!-- Non-TDD --> Review parent and plugin diffs and ensure no unrelated dirty-worktree paths are included.
- [x] 6.2 <!-- Non-TDD --> Commit the plugin implementation first using the repository commit convention.
- [x] 6.3 <!-- Non-TDD --> Commit the parent OpenSpec, documentation, native coverage record, and plugin gitlink without unrelated changes; the pre-existing untracked standalone change remains outside this scoped commit.
