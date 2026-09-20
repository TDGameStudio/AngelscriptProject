# AGENTS.md

This repository develops and validates `Plugins/Angelscript` as a reusable Unreal Engine 5.8 plugin. The host project exists to support that deliverable: keep plugin behavior in the owning plugin by default and keep `Source/AngelscriptProject/` minimal.

## Start here

- Project Skills are enabled, and Harness is the project workflow entry.
- Work in the current selected workspace by default. Create or switch to a worktree only when explicitly requested by the user, and preserve all unrelated uncommitted changes.
- The primary workspace is both control center and a full execution workspace. New workspaces are minimal project replicas with only selected plugins using Git worktrees; canonical OpenSpec remains in the primary workspace. Route ordered execution to `change-queue` and live status requests through Harness queries.
- When an OpenSpec Change exists, read its `tasks.md` and `attachments/INDEX.md` first. Then load only the one leaf Skill or focused reference needed for the current task.
- Use `.agents/skills/README.md` for Skill discovery, Harness and OpenSpec Skills for workflow policy, `openspec/specs/` for durable behavior, and `Reference/README.md` for external-source routing.
- Treat material under `Documents/` as migration or deletion-bound unless a current Skill or specification explicitly routes to it; do not move new project workflow policy there.

## OpenSpec lifecycle

- Harness owns one discussion/execution double loop plus peripheral tools. Explicit bounded direct edits and tool queries need no manufactured Change. Use `explaining-work` to explain architecture, relevant classes, callers/callees, key logic and terms; after every Grill answer re-display the complete relevant current view before the next questions.
- Automatically open substantial discussion drafts under ignored `openspec/drafts/<domain>/<topic>/`: README for identity/navigation, CONTEXT for key decisions/reasons/corrections/sources, optional research and indexed attachments, and `designs/<scope>/design.md`. Prepare handoff only after user-led convergence. No mandatory transcript dual-writing or migration of old logs/findings. Draft text follows the conversation language; final Change planning is English.
- Grill only explains and asks until the user proactively says ready; never suggest Change creation to end a round. Then present the exact version and ask Create/Replan, continue discussion, or park. A material revision invalidates the decision. After successful handoff always ask draft archive/keep plus execute/continue now or wait; no draft means no invented archive choice. All actual decisions retain provenance.
- Name new Changes `<domain>/<type>-<scope>-<outcome>`. Create through `harness.change.create` with a version-bound draft or direct-origin Gate. Export the accepted English design/handoff and required research/attachments, verify `harness.change.seed.verify`, then Ensure plan. Every new Change has root `design.md` with `## Call chains` and passes `harness.change.plan.verify`; historical contracts remain accepted.
- Draft archive is an explicit safe directory move into ignored `openspec/archive/drafts/`; show unresolved scopes first and preserve their states. Parked drafts stay active. Keep new scratch in `Saved/AgentTemp/<topic>/`; do not migrate/delete earlier Saved material.
- Every Change executes through the Harness queue core; a single Change uses its bounded adapter and never overwrites/reorders a configured queue. Bind session, workspace, ordered authorized UIDs and actual source. Pending feedback/decisions pause current implementation; acknowledgement is not approval. A post-handoff wait choice cannot revive an older execution request.
- Each task declares a bounded outcome and exact proving command. For behavior, observe related feature-group RED then GREEN and retain task-specific evidence. Fix ordinary local failures inside the task. Apply derives unlisted public names from convention and records `Naming assumed`; a user-owned choice or invalid requirement/design/task edge/verification contract returns through Update to a linked draft, explained Grill and the actual Replan Gate. Preserve accepted files until application.
- Unattended continuation executes only accepted authority and waits on unanswered necessary decisions. Attended answers may return through both Gates in the same session. Continue the authorized range until complete, paused or genuinely blocked; never infer authorization of appended work.
- Review starts only on explicit user/external-agent request. Normal completion uses verification, applicable spec sync, terminal evidence and archive. Automatically collect Harness friction; batch-confirm repair scope before editing unrelated Skills/tools. Post-archive discoveries never auto-create a successor Change.

## Verification

- Start with the smallest impact-related verification that can prove the change. Expand only for an affected shared contract, cross-component impact, adjacent failure evidence, a release gate, or an explicit user request.
- Do not treat `Quick`, `Performance`, `Integration`, an Unreal build, UE Automation, or a full suite as an unconditional daily gate. Select them only when their documented scope matches the demonstrated impact.
- Record the tests actually run and any intentionally omitted heavier tests with the reason. Load `.agents/skills/harness/references/verification.md` when choosing or expanding the verification scope.

## AngelScript reconstruction baseline

- The preserved legacy AngelScript runtime and old test corpus are intentionally dormant while the language stack is reconstructed; retained source is reference material, not a supported config-restorable path.
- New C++ Automation tests live under `Plugins/Angelscript/Source/AngelscriptTest/{NativeEngine,Bindings,Framework,FrameworkTests,Baseline}/`. NativeEngine identities are `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`; Bindings, Framework, and Baseline keep their existing prefixes. `NewVersion` is not a source root or identity segment.
- Treat `WITH_ANGELSCRIPT_UNITTESTS` as the disabled legacy gate and `WITH_ANGELSCRIPT_TESTS` as the enabled replacement gate. Route detailed startup and test behavior to `openspec/specs/angelscript/` and legacy-source isolation mechanics to `.agents/skills/angelscript-test/references/legacy-source-isolation.md`.

## Execution and Git boundaries

- Route UE discovery, builds, tests, suites, commandlets, status, progress, and cancellation only through Harness `ue.*` routes for the selected workspace. Root `Tools` PowerShell wrappers are not a fallback.
- Import and invoke ordinary Harness routes directly in the current PowerShell 7 process. Only isolated tests, Git hooks or native fixtures, and Harness-managed Unreal workers may start a bounded child `pwsh`.
- Commit only the exact paths and hunks owned by the current Change. Integration, non-force push, and workspace removal are separate actions and each requires explicit user authorization.
