## Context

`improve-as-cross-module-generation-allowlist` split runtime-linked modules from cross-module-only modules. Runtime-linked modules still come from `AngelscriptRuntime.Build.cs`; cross-module-only modules come from `cross-module-generation-modules.txt` and generate only target-module wrapper shards.

The current worktree uses a source engine: `Engine/Build/SourceDistribution.txt` and the engine `.git` directory are present, while `Engine/Build/InstalledBuild.txt` is absent. Source builds can compile generated target-module wrapper shards inside engine modules. Installed/binary engine builds are riskier because engine module outputs may not be writable or intended for regeneration, so their default cross-module-only expansion must remain conservative.

## Goals / Non-Goals

**Goals:**
- Make cross-module-only module selection data-driven through one JSON config file.
- Automatically choose a source or installed profile from the current engine root.
- Expand the source profile to cover the current `disabled-safe-cross-module` pool.
- Keep `AngelscriptRuntime.Build.cs` dependency boundaries unchanged.
- Make the selected profile visible in generated summary diagnostics.

**Non-Goals:**
- Do not expand parameter marshalling support.
- Do not direct-bind RPC/Net functions.
- Do not generate normal AngelscriptRuntime Direct/Stub shards for cross-module-only modules.
- Do not require project-local override configuration in this change.

## Decisions

- Use JSON rather than INI or C# constants. `AngelscriptUHTTool` already targets `net8.0` and uses `System.Text.Json`, so this adds no dependency and supports structured `common`, `source`, and `installed` profile arrays.
- The effective module set is `common + selectedProfile`, then runtime-linked modules are removed. This preserves the existing dependency split and keeps source/installed differences explicit.
- Engine profile detection uses files near the resolved `AngelscriptRuntime.Build.cs` engine root. `InstalledBuild.txt` selects `installed`; `SourceDistribution.txt` or engine `.git` selects `source`; unknown falls back to `installed` and emits a warning.
- `installed` is empty by default. This keeps binary engine users safe until modules are explicitly proven in that environment.
- Source profile starts with the current full `disabled-safe-cross-module` module pool. If build verification finds a module-specific compile failure, remove only the failing module and record the reason in this change.
- Cross-module wrapper shards carry the full per-entry include set, not only the declaring class header. Source profile expansion exposed by-value USTRUCT return/parameter wrappers whose declarations compile only when the defining struct header is included.
- Reference returns remain outside the automatic protocol and are classified as `needs-ref-return-protocol`. `TFieldPath` parameters/returns are classified as `needs-field-path-frame-protocol` until the AS generic frame protocol supports them.

## Risks / Trade-offs

- Source profile expansion may expose module-specific compile failures -> run a full serialized build and remove only proven failing modules.
- Editor-heavy source modules may add build churn -> keep them profile-gated to source engines and visible in summary diagnostics.
- The source safe pool is derived from current diagnostics and may change with engine updates -> configuration remains editable data, and skipped diagnostics continue to show future opportunities.
- Unknown engine layout could be misdetected -> default to installed/conservative and print a UHTTool warning.
