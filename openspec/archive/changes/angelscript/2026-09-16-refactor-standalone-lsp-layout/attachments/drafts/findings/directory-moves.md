# Findings: plugin directory moves

Shared evidence with `../runtime-owned-sdk-layout/findings/directory-moves.md` (same inspection). This draft owns only the `Standalone/` → `AngelscriptLSP/` retarget.

Copy of the move-2 and prior-record sections from that file, for a draft that must not depend on a gitignored sibling path remaining stable.

## Move

`Standalone/` (deleted at HEAD) is now untracked `AngelscriptLSP/`. CMake project name, README, and SUPPORT_MATRIX still say Standalone. Fork root still points at `ThirdParty/angelscript/source`.

## Prior records

- `feature-frontend-diagnostics-tooling`: later JSON-RPC adapter; in-process `asCLanguageService` is not a server; `Extensions/AngelscriptVSCode/` remains the TypeScript LSP.
- Archived language-surface Change: Standalone retained as dormant; add-ons removed.
- Specs: Standalone is not build-certified.

## Open

Whether `AngelscriptLSP` is only a directory name for the dormant host, or the product identity of the future native LSP. Layout Change should not implement the protocol either way.
