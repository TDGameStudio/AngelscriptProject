# Scenario Card contract RED evidence

- Captured: 2026-09-04T08:46:17+08:00
- Command: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Exit code: `1`
- Source run chunk: `c47de9`

## Output

```text
OpenSpec package safety tests passed.
Exception: OpenSpecSkill.Tests.ps1:9
Specification and Scenario Card reference is missing.
```

## Interpretation

The focused assertion was present before implementation and failed at the intended missing central authoring reference. This compact artifact preserves the relevant output; it does not claim that later GREEN gates passed.
