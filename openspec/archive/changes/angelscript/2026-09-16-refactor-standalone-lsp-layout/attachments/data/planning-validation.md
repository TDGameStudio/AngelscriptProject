# Planning validation

Change: `angelscript/refactor-standalone-lsp-layout`
Date: 2026-09-11

## Coverage

Every proposal acceptance condition maps to a task:

| Item | Task |
|---|---|
| CMake fork root | 1.1 |
| Directory vs Standalone product identity; CheckRemovedAddons path | 2.1 |
| Plugin README, Guides, smoke tool, suite WorkingDirectory | 3.1 |
| Consumer-replan list | 4.1 |

No spec delta: current specs do not mandate `Standalone/` as a filesystem path.

## Placeholder scan

`tasks.md` contains none of: TBD, TODO, implement later, fill in details, add appropriate error handling, add validation, handle edge cases, write tests for the above, similar to Task, known values, existing fixtures.

## Symbol consistency

- Directory: `AngelscriptLSP/` (`attachments/drafts/glossary.md`).
- Product: Standalone / `as-standalone` / `AngelscriptStandalone` / `ue-as-standalone-v1`.
- Fork root: `${ANGELSCRIPT_RUNTIME_ROOT}/angelscript`.
- JSON-RPC and `Extensions/AngelscriptVSCode/` remain out of this Change.
