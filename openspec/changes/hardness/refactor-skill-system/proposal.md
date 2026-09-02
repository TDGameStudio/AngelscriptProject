## Why

The current `.agents/skills` tree mixes legacy loop protocols, duplicated OpenSpec lifecycle guidance, and Review/Replan records without one status contract. Native Goal mode cannot reliably resume, replan, and verify work without interrupting the user, while direct-workspace mode lacks a clear safety boundary. These entry points need to converge into a lightweight, auditable, progressively loaded Skill harness without coupling this core change to the separately evolving Unreal runner surface.

## What Changes

- Define Hardness as a static Skill router and unified PowerShell entry that supports native Goal worktrees and the current workspace.
- Make `tasks.md` the only Task DAG, place its versioned dependency map in YAML frontmatter for Hardness recognition, and establish strict Review triage, material implementation issue, decision, and immutable Replan-history protocols.
- Keep `unreal-engine-develop` and the public UE `Tools/` wrapper migration outside this delivery. The repository is undergoing a large refactor, so that leaf will be designed and verified in a separate change before Hardness publishes any UE route.
- Advance the portable OpenSpec package through immutable release snapshots: retain failed `v0.7.0`, retain technically valid but language-noncompliant `v0.7.1`, retain `v0.7.2` as the failed physical-root review snapshot, retain functionally repaired but non-reproducible `v0.7.3`, preserve deterministic and containment-safe `v0.7.4`, preserve reviewed `v0.8.0` as the first YAML-frontmatter Task Graph snapshot, and publish `v0.8.1` with BOM-safe frontmatter recognition and lexical quoted-ID enforcement.
- Repartition OpenSpec lifecycle Skills so the CLI supplies deterministic primitives while Hardness owns autonomous execution, Review Gates, and Replan decisions.
- Require English across maintained OpenSpec source documentation, Skills, workflows, records, manifests, and attachments; explicitly named `*_ZH` localization files are temporarily exempt for later user-directed removal.
- Add progressive loading, installation health checks, PowerShell 5.1/7 behavior tests, worktree safety tests, an English-language gate, and independent final review.
- Add a unified Hardness performance profile that measures cold and persistent-session paths in PowerShell 5.1 and 7, retains unique raw run artifacts under `Saved/`, and preserves one privacy-trimmed baseline summary with the change evidence.
- Commit only the final validated OpenSpec 0.8.1 Release EXE snapshot in the parent repository; candidate binaries remain source tags/review evidence rather than repeated binary commits.
- Remove legacy RalphLoop dependencies, duplicate review Skills, duplicate language mirrors other than the temporary `*_ZH` exception, and temporary drafts without reading, migrating, or refactoring the old `Tools` loop implementation.

## Capabilities

### New Capabilities

- `hardness/core`: Skill routing, Goal/Current workspace selection, Task DAG, Review/Replan, performance evidence, and OpenSpec lifecycle boundaries.

### Modified Capabilities

- None.

## Impact

- Parent repository: Hardness/Workspace/OpenSpec/Review Skills, `openspec/` project records, AGENTS guidance, and the worktree guide. Unreal runner and public UE wrapper changes are excluded.
- `Tools/openspec` submodule: Rust CLI 0.8.1 source, tests, English documentation, and immutable Release tag layered after preserved `v0.8.0`; all earlier candidate tags remain fixed and explicit `*_ZH` files remain untouched.
- No functional code changes under `Plugins/Angelscript*`, and no plugin logic moves back into `Source/AngelscriptProject`.
- Goal completion does not automatically merge, push, publish the parent repository, or remove its worktree; success ends at committed, verified, reviewed, and ready-to-integrate.
- StaticJIT All and the complete All suite are not acceptance gates for this change.
