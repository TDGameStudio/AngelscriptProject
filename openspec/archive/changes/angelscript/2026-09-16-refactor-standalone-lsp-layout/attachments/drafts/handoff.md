Draft: `angelscript/standalone-lsp-layout` (accepted 2026-09-11)

# Problem

The dormant no-Unreal host already lives at `Plugins/Angelscript/AngelscriptLSP/`, but CMake, README, Guides, and Tools still name `Standalone/` and still compile against `ThirdParty/angelscript/source`. Prior records keep this tree dormant and keep JSON-RPC as later work.

# Success Criteria

- Live path strings use `AngelscriptLSP/`.
- CMake fork root is `Source/AngelscriptRuntime/angelscript`.
- Product names stay Standalone (`as-standalone`, CMake project, support matrix contract).
- `CheckRemovedAddons.py` is invoked at the new path as a source audit, not a binary certification.
- Other active Changes that still list `Standalone/` are listed for replan.

# Evidence

- Submodule: `Standalone/` deleted; `AngelscriptLSP/` untracked with the same CMake/CLI/Tests contents.
- `CMakeLists.txt` still uses `ThirdParty/angelscript/source`.
- `feature-frontend-diagnostics-tooling` reserved JSON-RPC; `Extensions/AngelscriptVSCode/` is unchanged.
- Archived language-surface Change kept the host dormant after add-on removal.

# Scope and Exclusions

In: CMake fork root, AngelscriptLSP README/SUPPORT_MATRIX identity sentence, plugin README contents, live Guides (`Build.md`, `AngelscriptStandaloneOfflineBundle.md`), `Tools/RunStandaloneExternalSmoke.ps1`, current specs only if they name the filesystem path, consumer list.

Out: JSON-RPC/LSP protocol; renaming the CLI; certifying a host binary; moving VS Code; TestCode/TestFramework; archives; ZH dumps.

# Constraints

Depends on the SDK directory already on disk (`refactor-runtime-owned-sdk-layout` for the canonical path string). Do not add an AngelscriptLSP UE module.

# Options

Forced: retarget paths, keep product names. Implementing LSP in this Change was rejected.

# Decision and Rationale

Directory name `AngelscriptLSP` is a filesystem rename of dormant Standalone. Product, CLI, and CMake identity stay Standalone so prior contracts remain readable.

# Flip Condition

A later Change that makes this tree the native JSON-RPC language server would rename product identity then; it is not this layout Change.

# Architecture, Components, and Data Flow

See `attachments/drafts/design.md`. Host tree compiles the same sources against the first-party SDK.

# Failures and Edge Cases

Scripts that still look under `Standalone/` fail closed. No dual-path search.

# Verification

Grep live docs/tools for `Plugins/Angelscript/Standalone` as a current path; CMake fork root check; `python Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py` as the existing source audit.

# OpenSpec Handoff

- Change ID: `angelscript/refactor-standalone-lsp-layout`
- Title: Retarget Standalone host to AngelscriptLSP
- Goal: Point CMake, live guides, and tools at `AngelscriptLSP/` while keeping dormant Standalone product identity and the later JSON-RPC boundary.
- Workflow: `angelscript`
- Affected areas: none required for a new capability; no synthetic spec delta unless a current spec names the old filesystem path.
- Required artifacts: proposal, design, tasks. Specs only if a current spec currently mandates `Standalone/` as a path.
- Task boundaries: (1) CMake fork root; (2) identity sentence in AngelscriptLSP README/SUPPORT_MATRIX; (3) plugin/parent README + Guides + smoke tool paths; (4) consumer-replan list.

# Exploration Carryover

Confirmed by the design-review answer that authorized handoff and Change creation.

Talk candidates:

- `log.md` Round 1 lsp_identity=dir_only → talk: directory vs product vs TypeScript LSP; JSON-RPC remains later.
- `log.md` Round 1 other_changes=replan_list → talk: `refactor-sdk-drop-native-gc` and peers replan Standalone paths themselves.

Knowledge candidates:

- `findings/directory-moves.md` → knowledge: `AngelscriptLSP/` is the dormant Standalone host directory; `Extensions/AngelscriptVSCode/` is the TypeScript client/server; `asCLanguageService` is in-process SDK, not this tree.

Discard: implementing a language-server protocol in this Change.
