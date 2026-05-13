## Context

`Tools/RalphLoop` already contains the working PowerShell runner, provider profiles, prompt templates, wrappers, and deterministic mock tests. The main repository also has stale root-level copies of the runner scripts, while most active tooling already calls `Tools\RalphLoop\ralph-loop.ps1` directly. The desired direction is a standalone-ready RalphLoop repository that can later be added back as a submodule at the same path.

## Goals / Non-Goals

**Goals:**
- Keep the existing basic repeated-command loop behavior compatible.
- Make provider execution safer by default and require explicit trust for dangerous CLI flags.
- Add Claude as a first-class provider profile.
- Add a read-only PRD workflow that injects selected story context without mutating PRD, progress, or git state.
- Document the standalone/submodule direction and remove reliance on root-level duplicate entry points.

**Non-Goals:**
- Do not create or push the GitHub repository in this implementation pass.
- Do not convert `Tools/RalphLoop` into an actual submodule until the remote exists.
- Do not add automatic PRD updates, progress writes, branch checkout, commits, or Bash support.
- Do not change Unreal plugin runtime/editor/test behavior.

## Decisions

- Keep `Tools/RalphLoop` as the implementation root for now. This preserves all existing direct callers and makes the eventual submodule conversion a metadata change instead of a path migration.
- Use `-Workflow Basic|Prd` with `Basic` as the default. This keeps existing one-command repeated loop usage unchanged while giving PRD mode an explicit execution path.
- Use upstream Ralph-compatible PRD fields for v1: `project`, `branchName`, `description`, `userStories[]`, `id`, `title`, `description`, `acceptanceCriteria`, `priority`, `passes`, and `notes`.
- Make PRD mode read-only. The runner selects and injects a story, but leaves completion marking and commits to the called agent or the human.
- Add `TrustedCommandTemplate` to provider profiles and select it only when `-TrustAgent` is present. This keeps public defaults safer without removing the current unattended automation path.
- Keep tests mock-first. Real provider tests remain opt-in because they depend on local authentication and paid/external CLIs.

## Risks / Trade-offs

- Existing callers that expected dangerous Codex flags by default may need `-TrustAgent` for equivalent unattended behavior. Mitigation: document the new flag and keep custom `-AgentCommand` override behavior.
- PRD workflow may not cover every Ralph schema variant. Mitigation: support the upstream common schema first and fail with clear errors for invalid or empty PRD files.
- Actual submodule conversion is deferred. Mitigation: make the directory standalone-ready now and document the follow-up `git submodule add` step.
