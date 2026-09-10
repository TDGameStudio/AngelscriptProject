# AGENTS.md

This repository develops and validates `Plugins/Angelscript` as a reusable Unreal Engine 5.8 plugin. The host project exists to support that deliverable: keep plugin behavior in the owning plugin by default and keep `Source/AngelscriptProject/` minimal.

## Start here

- Project Skills are enabled, and Harness is the project workflow entry.
- Work in the current selected workspace by default. Create or switch to a worktree only when explicitly requested by the user, and preserve all unrelated uncommitted changes.
- When an OpenSpec Change exists, read its `tasks.md` and `attachments/INDEX.md` first. Then load only the one leaf Skill or focused reference needed for the current task.
- Use `.agents/skills/README.md` for Skill discovery, Harness and OpenSpec Skills for workflow policy, `openspec/specs/` for durable behavior, and `Reference/README.md` for external-source routing.
- Treat material under `Documents/` as migration or deletion-bound unless a current Skill or specification explicitly routes to it; do not move new project workflow policy there.

## OpenSpec lifecycle

- Name new Changes `<domain>/<type>-<scope>-<outcome>` and use the matching OpenSpec lifecycle Skill to create, continue, update, apply, verify, synchronize, and archive them.
- Each task declares a bounded outcome and one exact proving command. For behavior changes, plan concrete related tests, observe the feature group's RED together, implement it, and verify GREEN together; shared runs retain task-specific evidence.
- Diagnose and repair ordinary local failures inside the current task. Replan only when evidence invalidates a requirement, design boundary, Task DAG edge, verification contract, or required artifact.
- Review starts only when the user or an external agent explicitly requests one; normal completion proceeds through verification, specification synchronization when applicable, terminal evolution evidence, and archive.

## Verification

- Start with the smallest impact-related verification that can prove the change. Expand only for an affected shared contract, cross-component impact, adjacent failure evidence, a release gate, or an explicit user request.
- Do not treat `Quick`, `Performance`, `Integration`, an Unreal build, UE Automation, or a full suite as an unconditional daily gate. Select them only when their documented scope matches the demonstrated impact.
- Record the tests actually run and any intentionally omitted heavier tests with the reason. Load `.agents/skills/harness/references/verification.md` when choosing or expanding the verification scope.

## AngelScript reconstruction baseline

- The preserved legacy AngelScript runtime and old test corpus are intentionally dormant while the language stack is reconstructed; retained source is reference material, not a supported config-restorable path.
- New C++ Automation tests live under `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/` and use the public identity `Angelscript.UnitTest.<Area>.<Scenario>`.
- Treat `WITH_ANGELSCRIPT_UNITTESTS` as the disabled legacy gate and `WITH_ANGELSCRIPT_TESTS` as the enabled replacement gate. Route detailed startup and test behavior to `openspec/specs/angelscript/` and legacy-source isolation mechanics to `.agents/skills/angelscript-test-guide/references/legacy-source-isolation.md`.

## Execution and Git boundaries

- Route UE discovery, builds, tests, suites, commandlets, status, progress, and cancellation only through Harness `ue.*` routes for the selected workspace. Root `Tools` PowerShell wrappers are not a fallback.
- Import and invoke ordinary Harness routes directly in the current PowerShell 7 process. Only isolated tests, Git hooks or native fixtures, and Harness-managed Unreal workers may start a bounded child `pwsh`.
- Commit only the exact paths and hunks owned by the current Change. Integration, non-force push, and workspace removal are separate actions and each requires explicit user authorization.
