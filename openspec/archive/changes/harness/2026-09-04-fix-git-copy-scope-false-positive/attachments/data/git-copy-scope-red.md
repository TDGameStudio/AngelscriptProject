# Exact scoped copy false-positive evidence

- Captured at: `2026-09-04T22:00:00+08:00`
- Command: Harness `git.commit` with exact Scenario-authoring Change paths and without the unchanged older archive path.
- Result: failed before commit; Harness restored the repository ref and live index and reported no completed repository commits.
- Diagnostic: `staged rename/copy crossing the requested scope: openspec/archive/changes/harness/2026-09-04-fix-unreal-execution-reliability/specs/harness/unreal/spec.md -> openspec/archive/changes/harness/2026-09-04-fix-scenario-detail-authoring-priority/specs/harness/unreal/spec.md`
- Control observation: adding the unchanged inferred source path to the allowed scope made the same target candidate pass preview and commit.

This evidence proves the false rejection and safe restoration. It does not prove the repair; GREEN evidence belongs to the direct Git operations fixture.
