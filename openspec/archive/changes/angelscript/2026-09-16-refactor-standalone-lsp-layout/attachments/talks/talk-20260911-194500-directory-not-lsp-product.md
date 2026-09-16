# Directory vs Standalone product vs TypeScript LSP

## Context

The host directory was renamed to `AngelscriptLSP`. Prior records already split in-process `asCLanguageService`, a later JSON-RPC adapter, and `Extensions/AngelscriptVSCode/`.

## Evidence

- `AngelscriptLSP/` contents are the old Standalone CMake/CLI/Tests tree; `project(AngelscriptStandalone)` unchanged.
- `feature-frontend-diagnostics-tooling` reserved JSON-RPC; TypeScript server stays in the parent `Extensions/` tree.
- User confirmed Round 1 `lsp_identity=dir_only`.

## Options

| Option | Result |
| --- | --- |
| A. Directory rename only | Product stays dormant Standalone |
| B. Product becomes the native LSP host in this Change | Would reopen JSON-RPC and VS Code scope |
| C. Implement JSON-RPC now | Rejected; later adapter Change |

## Settled Decision

Option A.

## Consequences and Flip Condition

Keep `as-standalone`, CMake project name, and `ue-as-standalone-v1`. If a later Change implements JSON-RPC here, rename product identity in that Change, not this one.

## Sources

- `attachments/drafts/design.md`
- `attachments/drafts/findings/directory-moves.md`
- `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/talks/talk-20260905-221408-diagnostics-tooling-lsp-boundary.md`
