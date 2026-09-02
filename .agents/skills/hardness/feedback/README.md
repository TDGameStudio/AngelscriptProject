# Harness Feedback

Problems with the harness itself (wrong route, stale path, unclear protocol, missing skill) are recorded here. Agents may only ADD files under `open/` or APPEND evidence to an existing entry. Evaluation and harness updates happen only in a developer-attended review session.

## Rules

- One problem per file. File name: `YYYY-MM-DD-<short-slug>.md` (e.g. `2026-09-02-openspec-route-stale.md`).
- Before creating a file, scan `open/` for a similar entry. If one exists, append a dated evidence line to it instead of creating a duplicate.
- Keep entries short — five fields, a few lines each.
- After review, entries move to `archived/` with a `Verdict:` line (accepted or rejected + reason). Never delete entries.

## Entry template

```markdown
# <short title>

- Harness version: <Version line from SKILL.md at the time>
- What happened: <observed behavior, 1-3 lines>
- Expected: <what the harness should have said/done>
- Involved route/skill: <route table row or skill path, if any>
- Suggestion: <proposed fix, optional>

## Evidence
- 2026-09-02: <where it occurred: change name / iteration dir / command>
```

## States

| Location | Meaning |
|---|---|
| `open/` | Awaiting developer review |
| `archived/` | Reviewed; `Verdict:` line records accepted/rejected and why |
