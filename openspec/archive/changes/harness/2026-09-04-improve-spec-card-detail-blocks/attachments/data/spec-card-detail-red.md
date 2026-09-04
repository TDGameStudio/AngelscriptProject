# Scenario Card detail-block RED

- Command: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Exit: non-zero
- First semantic failure: `Scenario Card contract is missing: > Details:`
- Preceding gate: OpenSpec package safety passed.

The failure was captured after correcting a local test-syntax mistake and before changing the Scenario Card reference, template, workflow prompts, lifecycle Skills, or current specifications. It proves that the maintained authoring surface did not visibly expose a Task-like Scenario-owned detail block.
