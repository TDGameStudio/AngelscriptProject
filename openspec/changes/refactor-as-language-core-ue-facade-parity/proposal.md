## Why

Standalone V1 is complete without moving the mature UE `FAngelscriptPreprocessor`, descriptor graph, or ClassGenerator pipeline. A broad shared Language layer increased UE source churn and created a second architectural center, while the actual cross-host product boundary is the complete final-engine JSON bundle.

Long-term compatibility still has value, but it must be pursued only where a concrete algorithm needs identical behavior in both hosts and can remain independent of UE descriptors, reflection, IO, and lifecycle state.

## What Changes

- Keep the UE preprocessor as the authoritative UE frontend.
- Keep the Standalone frontend private to `Standalone/`.
- Evaluate compatibility one algorithm at a time, starting from behavior characterization rather than a shared-layer target.
- Permit short-term duplication when extracting a helper would broaden plugin dependencies or obscure host ownership.
- Require exact UE behavior preservation before any production delegation is considered.
- Prohibit a complete UE facade migration, portable descriptor lowering layer, shadow full parse, or Compat expansion into UE runtime simulation.

## Capabilities

### New Capabilities

- `ue-standalone-incremental-compatibility`: Govern evidence-backed, algorithm-level compatibility between the authoritative UE frontend and the private Standalone frontend.

### Modified Capabilities

- None.

## Impact

- Future work may add focused characterization tests around `FAngelscriptPreprocessor` and matching Standalone algorithms.
- No shared `AngelscriptLanguageCore`, UE `ITypeOracle` adapter, descriptor lowering graph, public macro, bind branch, ClassGenerator path, or new plugin module is planned.
- The Standalone offline JSON bundle, CLI, package, and security boundaries remain unchanged.
