## Why

`asCScriptEngine` left `typeCheckSwitchEnums` without a deterministic constructor
value, so independent raw engines could observe nondeterministic baseline and
restore behavior. Engine properties must start from explicit fork defaults for
reliable embedding and regression isolation.

## What Changes

- Explicitly initialize `typeCheckSwitchEnums` with the current fork default.
- Audit every engine-property field for deterministic constructor
  initialization.
- Keep profile set/read/restore and independent-engine isolation regressions.

## Capabilities

### New Capabilities

- `as-engine-property-defaults`: Defines deterministic per-engine property
  defaults and isolation.

### Modified Capabilities

None.

## Impact

- Vendored runtime: `as_scriptengine.cpp` constructor initialization.
- Tests: Engine property profile and isolation owners.
- No public API signature or intended current-fork default changes; the repair
  removes uninitialized-state nondeterminism.
- Related coverage record:
  `test-as-native-sdk-comprehensive-coverage/runtime-change-map.md`.
