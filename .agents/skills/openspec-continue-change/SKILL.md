---
name: openspec-continue-change
description: Create the next missing planning artifact for an active project OpenSpec change. Use for proposal, optional specs/design, or required tasks; use openspec-update-change when an existing artifact must be revised.
---

# Continue a Change

1. Use the explicit change, or the Goal context's change. In interactive mode only, ask when multiple active changes remain genuinely ambiguous.
2. Call `openspec.status --change <id> --json` and select one missing artifact. Proposal and tasks are required; specs exist only for durable behavior; design exists only for non-obvious decisions.
3. Call `openspec.instructions <artifact> --change <id> --json`. Re-read its concrete context files. Apply context/rules as constraints, never copied prose.
4. Write one artifact to `writePath`; for a glob choose a concrete path permitted by `outputPattern`. Use the matching record/task reference from the `openspec` skill.
5. Run strict change validation and report the next ready artifact.

```text
status -> instructions -> one concrete artifact -> strict validate
```

Fast-forward through all missing planning artifacts only when implementation was requested or Goal mode already carries an approved objective. Do not hand-create manifest files, write implementation code, or replace existing artifacts in this skill.
