## Why

The explicit AngelScript binding surface is mature, but its coverage is intentionally uneven across Unreal Engine type families. The local UnrealCSharp reference offers a useful inventory of hand-authored value-type and wrapper APIs, while the AngelScript plugin may expose the same native functionality through explicit binds, reflection, templates, aliases, operators, or a different script-facing shape.

Ad-hoc filename and member-name comparisons therefore produce false gaps. We need a durable, evidence-based backlog that distinguishes genuinely useful missing script APIs from equivalent or intentionally unsupported surfaces, and that can be implemented in small, independently verifiable waves.

## What Changes

- Establish an `as-bind-surface-parity` capability for auditing and gradually improving the AngelScript binding surface.
- Maintain a normalized audit matrix that maps reference APIs to AngelScript explicit bindings, reflected/template-provided APIs, equivalent script-facing forms, or documented non-goals.
- Use UnrealCSharp as a discovery catalogue, not as a mandatory one-to-one compatibility target. Hazelight and Unreal Engine behavior remain the semantic references when deciding an API's value and shape.
- Prioritize small type-family waves, beginning with commonly used foundation value types and wrappers, and require behavioral script tests for every newly hand-authored API.
- Preserve the existing `EAngelscriptBindPhase` lifecycle, including `ExplicitBindings`; this work must not introduce a new phase or disturb generated/reflection binding paths merely to improve inventory coverage.
- Keep source-layout checks out of the parity work. Tests must validate script-visible behavior rather than the location or declaration style of a provider.
- Approve a high- and medium-priority wave for AssetManager value types,
  `FBox2D`, `FFrameNumber`, `FFrameTime`, and `FMatrix`; its concrete scope
  and current-engine type decisions are recorded in
  `high-medium-value-types-wave.md`.

## Capabilities

### New Capabilities

- `as-bind-surface-parity`: A repeatable, evidence-based process for classifying reference binding surfaces and incrementally adding high-value AngelScript APIs with behavioral coverage.

### Modified Capabilities

None.

## Impact

- Future implementation is expected mainly in `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` and focused tests under `Plugins/Angelscript/Source/AngelscriptTest/Bindings/`.
- The OpenSpec change owns the audit inventory and implementation backlog; individual waves may add focused notes and validation evidence here as they are completed.
- No runtime API, binding implementation, phase behavior, or test suite is changed by this proposal alone.
