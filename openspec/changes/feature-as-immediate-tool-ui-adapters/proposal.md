## Why

The planned stateful tool runner, Editor host extensions and Tool Workspace cover execution, lifecycle and source recovery, but they intentionally do not let user-owned AngelScript tools draw custom code-first UI. SlateIM, a future ImGui integration, UMG/EmmsUI-style reconciliation and a plugin-owned facade are all plausible directions; selecting one before characterizing its binding, hot-reload and failure behavior would couple the tool system to an unproven backend.

This is a **record-only, decision-pending** change. It preserves the research and the backend-independent safety boundaries now so a maintainer can choose a backend later without treating the current candidates as an implementation commitment.

## What Changes

- Record the current SlateIM, Hazelight immediate-handle and EmmsUI/UMG evidence, including licensing and local UE 5.8 source observations.
- Define backend-independent boundaries for user ownership, tool-host integration, draw-scope cleanup, hot reload and optional dependencies.
- Compare SlateIM, ImGui, UMG/EmmsUI and a plugin-owned facade without selecting a production backend.
- Define bounded characterization spikes and explicit decision gates that must be completed before implementation planning begins.
- Preserve the existing responsibilities of `feature-as-stateful-tool-execution`, `feature-as-editor-tool-host-extensions` and `feature-as-editor-tool-workspace`.
- Do not enable SlateIM, add an ImGui dependency, expose a production AS widget API, modify Runtime/Editor code or implement a tool catalogue in this record-only revision.

## Capabilities

### New Capabilities

- `as-immediate-tool-ui-adapters`: Candidate contract for optional immediate-mode UI adapters that let user-owned AngelScript tool instances draw through a selected backend while the native host owns unsafe UI lifecycle boundaries.

### Modified Capabilities

None. The existing tool-execution, Editor-host and workspace proposals remain unchanged until a backend decision explicitly revises their requirements.

## Impact

There is no production-code, build, plugin-descriptor, Runtime, Editor or Saved-data impact in the current record-only revision. A later implementation may introduce an optional sibling integration plugin or a narrowly scoped Editor adapter, plus focused bindings and tests, only after the decision gates in this change are resolved.

Potential future dependency surfaces include Epic's Experimental `SlateIM` plugin, a separately reviewed ImGui integration, UMG, Slate/SlateCore and the existing AngelScript Editor host. No dependency is selected or enabled by this proposal.
