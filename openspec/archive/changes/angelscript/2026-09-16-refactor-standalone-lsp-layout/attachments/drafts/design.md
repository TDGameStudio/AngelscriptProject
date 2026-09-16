# Design: Standalone directory retarget to AngelscriptLSP

Status: approved

Change ID: `angelscript/refactor-standalone-lsp-layout`

## Why

The plugin already moved the dormant no-Unreal host from
`Plugins/Angelscript/Standalone/` to `Plugins/Angelscript/AngelscriptLSP/`.
Prior records keep this tree as **dormant Standalone tooling** (add-ons
removed; not build-certified against the reconstructed SDK).
`feature-frontend-diagnostics-tooling` already reserved JSON-RPC / a language
server process as later work; `Extensions/AngelscriptVSCode/` remains the
TypeScript LSP.

The directory name changed. CMake, README, SUPPORT_MATRIX, parent README,
Guides, and Tools still say `Standalone/` and still point the fork root at
`ThirdParty/angelscript/source`. Agents will write to a deleted tree.

This Change retargets those live paths and states the identity rule: the
**directory** is `AngelscriptLSP`; the **product** remains dormant Standalone
(`as-standalone`, CMake project `AngelscriptStandalone`). It does not
implement LSP, JSON-RPC, or VS Code migration.

## Scope

In:

- `Plugins/Angelscript/AngelscriptLSP/CMakeLists.txt`:
  `ANGELSCRIPT_FORK_ROOT` →
  `${ANGELSCRIPT_RUNTIME_ROOT}/angelscript`
  (depends on `angelscript/refactor-runtime-owned-sdk-layout`).
- `Plugins/Angelscript/AngelscriptLSP/README.md` and `SUPPORT_MATRIX.md`:
  one explicit sentence that the directory is `AngelscriptLSP` and the
  product remains dormant Standalone; replace `Standalone/` path examples
  that would not resolve.
- Plugin `README.md` contents list: `AngelscriptLSP/` instead of `Standalone/`.
- Parent `README.md` repository layout if it still lists `Standalone/` as a
  current plugin child (today it omits the host tree; add `AngelscriptLSP/`
  only if the layout block should name it).
- Live guides and tools that still route to `Plugins/Angelscript/Standalone/`:
  `Documents/Guides/Build.md`,
  `Documents/Guides/AngelscriptStandaloneOfflineBundle.md`,
  `Tools/RunStandaloneExternalSmoke.ps1`,
  and the README command that runs
  `Plugins/Angelscript/Standalone/Tests/CheckRemovedAddons.py`
  (now under `AngelscriptLSP/Tests/`).
- Current specs that mention the Standalone **path** as a current location
  (product name "Standalone" may stay).
- Consumer list: active Changes that still list
  `Plugins/Angelscript/Standalone/` (they replan; this Change does not edit
  their `tasks.md`). Known: `angelscript/refactor-sdk-drop-native-gc`.

Out:

- Renaming `as-standalone`, the CMake `project()`, test prefixes
  `AngelscriptStandalone.*`, or compiler contract `ue-as-standalone-v1`.
- Implementing JSON-RPC, document sync, a language-server process, or moving
  `Extensions/AngelscriptVSCode/`.
- Certifying a working Standalone/CMake binary (still dormant).
- Immutable archives and ZH knowledge dumps.
- `TestCode/` / `TestFramework/` placeholders.

## Architecture

```
Plugins/Angelscript
├─ [ue module] Source/AngelscriptRuntime/angelscript/     // First-party SDK (other Change)
├─ [host tree] AngelscriptLSP/                            // Directory name after this Change
│  ├─ CMakeLists.txt  project(AngelscriptStandalone)          // Product name unchanged
│  ├─ Source/ CLI, Compiler, Adapters, …                   // Same contents as old Standalone
│  └─ Tests/ CheckRemovedAddons.py                       // Path retarget only
└─ [unchanged] Extensions stay in the parent repo
   └─ AngelscriptVSCode/                                   // TypeScript LSP; not this tree
```

CMake continues to compile the same host sources against the Runtime SDK.
Only the filesystem location and fork-root string change.

## Vocabulary and naming

| Name | Role |
| --- | --- |
| `angelscript/refactor-standalone-lsp-layout` | This Change |
| `AngelscriptLSP/` | Plugin directory for the dormant host |
| Standalone / `as-standalone` / `AngelscriptStandalone` | Product, CLI, and CMake identity (unchanged) |

Rejected: treating this Change as the native LSP adapter; renaming the
executable in the same Change.

## Error handling and edges

- Scripts that still look under `Standalone/` must fail with a missing path,
  not search both names.
- `CheckRemovedAddons.py` documentation must use the new path; the script's
  own "repository root" assumptions may use `CMAKE_CURRENT_LIST_DIR/..`
  (plugin root) and need a one-line check, not a rewrite of the audit policy.
- Do not add an AngelscriptLSP module to `Angelscript.uplugin`.

## Verification

1. Grep live plugin README, parent README, listed Guides, and
   `Tools/RunStandaloneExternalSmoke.ps1` for `Plugins/Angelscript/Standalone`
   as a current path; remaining hits must be historical or archive.
2. CMake `ANGELSCRIPT_FORK_ROOT` equals
   `Source/AngelscriptRuntime/angelscript`.
3. `python Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py`
   still runs as a path-level source audit (same dormant meaning as before:
   not a binary certification).
4. Strict OpenSpec validation of any edited current spec.

Intentionally omit: UE Automation, a full CMake/CTest package of the host,
Quick / Performance / Integration. Dormant host execution is still out of
scope.

## Relationship

Depends on `angelscript/refactor-runtime-owned-sdk-layout` for the SDK
directory that CMake must compile. Either Change may land first in git if
CMake is updated only after the SDK path exists on disk (it already does).
Task DAG: this Change's CMake task lists the SDK Change as a coordinator
prerequisite, not a same-graph edge.

## Prior records

- Archived `refactor-language-surface-ue-focused`: keep the host, remove
  add-ons, do not claim a working binary.
- Active `feature-frontend-diagnostics-tooling`: in-process
  `asCLanguageService`; JSON-RPC later; TypeScript server stays in
  `Extensions/AngelscriptVSCode/`.
