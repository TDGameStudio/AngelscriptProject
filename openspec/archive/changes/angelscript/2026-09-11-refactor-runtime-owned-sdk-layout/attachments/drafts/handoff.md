Draft: `angelscript/runtime-owned-sdk-layout` (accepted 2026-09-11)

# Problem

The maintained SDK already lives at `Source/AngelscriptRuntime/angelscript/`, but live include paths, specs, and guides still name `ThirdParty/angelscript/source`. UBT and later tasks will target a deleted tree.

# Success Criteria

- `AngelscriptRuntime.Build.cs` includes only the first-party SDK root.
- Current specs and live ForkStrategy guidance describe `AngelscriptRuntime/angelscript/`.
- An Editor Development build succeeds against the moved tree.
- Other active Changes are listed for their own replan, not edited here.

# Evidence

- Submodule git: `ThirdParty/angelscript/source` deleted; `angelscript/` untracked; files flattened (no nested `source/`).
- `AngelscriptRuntime.Build.cs` still adds `ThirdParty/angelscript`.
- Current specs (`language/ast/core`, `language/frontend/reflection-dependencies`) still say ThirdParty organization.

# Scope and Exclusions

In: Build.cs, plugin README if needed, current specs/knowledges that prescribe the old path, `Documents/Guides/AngelscriptForkStrategy.md`, consumer list.

Out: CMake in AngelscriptLSP (other Change); archives; ZH dumps; TestCode/TestFramework; SDK behavior; `Core/angelscript.h` location.

# Constraints

Directory already moved. Do not restore ThirdParty or a nested `source/` folder. Do not edit other Changes' `tasks.md`.

# Options

Forced by the on-disk move: retarget live contracts. A symlink alias was rejected.

# Decision and Rationale

Treat the SDK as first-party Runtime source. Update include roots and current path language. Sibling Change owns the host CMake fork root.

# Flip Condition

A later decision to keep a ThirdParty-shaped vendor drop would reopen the include-root design.

# Architecture, Components, and Data Flow

See `attachments/drafts/design.md`. Include path: `ModuleDirectory/angelscript` for `as_*.h` and `frontend/`.

# Failures and Edge Cases

Missing new include root fails the Editor build. Historical archive paths stay historical.

# Verification

`ue.build` AngelscriptProjectEditor Win64 Development; spec validation; grep live specs/guides for current `ThirdParty/angelscript` instructions.

# OpenSpec Handoff

- Change ID: `angelscript/refactor-runtime-owned-sdk-layout`
- Title: Retarget first-party SDK layout
- Goal: Point UBT, current specs, and live fork-strategy guidance at `Source/AngelscriptRuntime/angelscript` after the ThirdParty tree was removed.
- Workflow: `angelscript`
- Affected areas: `angelscript/language/ast/core`, `angelscript/language/frontend/reflection-dependencies`
- Capabilities: modify path organization language only; no new capability.
- Required artifacts: proposal, spec deltas for the two capabilities above, design, tasks.
- Task boundaries: (1) Build.cs include root + editor build proof; (2) current specs/knowledges path language; (3) ForkStrategy guide; (4) consumer-replan list attachment.

# Exploration Carryover

Confirmed by the design-review answer that authorized handoff and Change creation.

Talk candidates:

- `log.md` Round 1 other_changes=replan_list → talk: other active Changes replan themselves; this Change does not rewrite their Files.
- `log.md` Round 1 split=two_layout → talk: SDK layout is a separate Change from AngelscriptLSP.

Knowledge candidates:

- `findings/directory-moves.md` → knowledge: first-party SDK root is `Source/AngelscriptRuntime/angelscript/` (flattened; `frontend/` remains a subdirectory). Reuse in later specs and tasks.

Discard: round navigation; VS Code extension discussion except as a non-goal of the sibling Change.
