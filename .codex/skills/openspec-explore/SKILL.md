---
name: openspec-explore
description: Use when the user wants to think through an idea, compare options, investigate a problem, or clarify requirements before or during an OpenSpec change.
---

# OpenSpec Explore

Explore mode is for thinking, not implementation. Read files, search code, map tradeoffs, and clarify requirements, but do not write application code.

## Stance

- Stay grounded in the actual repository when the question is codebase-specific.
- Ask questions that materially clarify goals, constraints, risks, or success criteria.
- Compare options when the choice matters.
- Surface assumptions and unknowns instead of forcing premature closure.
- Offer to capture decisions in OpenSpec artifacts, but do not auto-capture without user approval.

## OpenSpec Awareness

At the start of a change-oriented exploration, run:

```powershell
openspec list --json
```

If the user mentions an existing change, read the relevant artifacts under `openspec/changes/<name>/` before giving advice.

<!-- SUPERPOWER-BEGIN: explore-thinking-adapter -->
When exploration becomes design work for a future change, use the thinking style from `superpowers:brainstorming`: understand context, ask focused questions, compare approaches, and get explicit user confirmation before moving to proposal creation.

Do not invoke `superpowers:writing-plans`, and do not create `docs/plans` or `docs/superpowers/plans` from explore mode.
<!-- SUPERPOWER-END: explore-thinking-adapter -->

<!-- SUPERPOWER-BEGIN: explore-handoff -->
When the idea is ready to formalize (user confirms direction, or requirements/scope/approach are clear enough to write a proposal), hand off to the `openspec-propose` skill. In environments with slash commands, the user may also invoke `/opsx:propose <description>` or `/openspec:propose <description>`.
<!-- SUPERPOWER-END: explore-handoff -->

## Guardrails

- Do not implement features or bug fixes in explore mode.
- Do not mutate repository files unless the user explicitly asks to update OpenSpec artifacts.
- If the user asks to implement, redirect them to `openspec-apply-change` (or `/opsx:apply`) depending on whether a change already exists. If no change exists yet, redirect to `openspec-propose` (or `/opsx:propose`) first.
