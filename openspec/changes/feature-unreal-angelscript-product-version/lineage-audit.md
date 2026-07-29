# Remaining 2.33 Reference Audit

Audit command:

```powershell
rg -n "23300|2\.33\.0 WIP|AS 2\.33|AngelScript 2\.33" Plugins/Angelscript AGENTS.md AGENTS_ZH.md Documents/Guides
```

## Intentional Current References

- `UnrealAngelscriptVersion.h`: canonical upstream base integer/string and full lineage text.
- `AngelscriptNativeEngineVersionTests.cpp`: exact lineage assertion and old-header rejection input.
- `AngelscriptUpgradeCompatibilityTests.cpp`: source-baseline preservation assertion.
- Plugin README, agent guidance, and fork strategy: explicitly labelled source lineage and migration warning.

## Intentional Historical and Technical References

- Fork architecture, memory, binding, and refactor guides use `AS 2.33 fork` to describe the implementation state at the time of an audit or the absence of a particular upstream API.
- Bytecode documentation uses `2.33` to identify the retained restore/layout lineage.
- Roadmap text uses `2.33 Fork` for patch/backport inventory work.

## Stale Product References

No remaining checked reference presents `2.33`, `2.33.0 WIP`, or `23300` as the current product version. Current identity text is `Unreal AngelScript 1.0.0`.
