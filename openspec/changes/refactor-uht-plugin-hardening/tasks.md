## 1. Establish audit baselines

- [x] 1.1 Capture default installed-engine FunctionBinding statistics, shard count, wrapper count, and representative generated include counts.
- [ ] 1.2 Add test fixtures for late registration, class-not-yet-available registration, feature unregister-before-queued-injection, and module reload. Late/deferred-unregister and reload fixtures are present; the real class-not-yet-available fixture remains part of source-engine E2E coverage.
- [x] 1.3 Record the supported UE versions and available UObject/module lifecycle delegates for class retry and feature unregistration.

## 2. Harden the Runtime target-module registry

- [x] 2.1 Introduce an owned registration record keyed by modular-feature instance and module/shard identity.
- [x] 2.2 Subscribe to modular-feature unregistration and remove bindings whose user data belongs to the unregistered feature.
- [x] 2.3 Replace raw queued feature-pointer captures with a validity-checked registration state or equivalent ownership token.
- [x] 2.4 Retain unresolved descriptors and retry them after class registration without duplicating successful bindings.
- [x] 2.5 Define behavior for existing handwritten/generated bindings when a target module unloads or reloads.
- [x] 2.6 Add Runtime tests proving no stale descriptor or module thunk survives unload/reload.

## 3. Unify configuration and engine classification

- [x] 3.1 Define the normalized FunctionBinding settings model and canonical method/module token contract.
- [x] 3.2 Implement complete UE array semantics for append, replace, clear, and remove operations or fail explicitly for unsupported syntax.
- [x] 3.3 Make Editor, Build.cs, and UHT consume the same effective settings contract and selected module set.
- [x] 3.4 Consolidate source/installed/unknown engine classification, including Git worktrees, source distributions, and non-Git source checkouts.
- [x] 3.5 Validate selected modules, missing session modules, editor-only modules, and dependency legality with module names in diagnostics.
- [x] 3.6 Add configuration vector tests covering Editor, UBT, UHT, `None`, Runtime-linked, and target-module modes.

## 4. Make function analysis conservative

- [x] 4.1 Replace string-based function and export flag checks with typed UHT flags.
- [x] 4.2 Split callable/event/RPC/custom-thunk eligibility into explicit policy functions and document their precedence.
- [x] 4.3 Replace broad signature fallback with fail-closed analysis outcomes.
- [x] 4.4 Replace hard-coded class/function signature exceptions with explicit policy data and focused tests.
- [x] 4.5 Rework declaration scanning to respect active preprocessor context, strings, nested scopes, access labels, whitespace, and inline bodies.
- [ ] 4.6 Add resolver fixtures for overloads, `public :`, macro attributes, conditional declarations, default arguments, inline definitions, references, and `const` variants.
- [x] 4.7 Ensure target-mode interfaces and every unsupported signature produce a stable skipped reason.

## 5. Refactor UHT responsibilities

- [x] 5.1 Extract configuration resolution from `AngelscriptFunctionBindingCodeGenerator`.
- [x] 5.2 Extract per-function analysis and typed category/failure models.
- [x] 5.3 Rename or narrow the header declaration resolver so its responsibility is explicit.
- [x] 5.4 Extract Runtime-linked and NativeModuleFunctionAddress emitters.
- [x] 5.5 Extract statistics/diagnostic artifact writing and schema versioning.
- [x] 5.6 Extract stale-output cleanup with explicit UHT-owned directory guards.
- [x] 5.7 Remove duplicated reclassification and make all emitters consume the shared analysis result.

## 6. Reduce generated build overhead

- [x] 6.1 Design a stable per-module aggregator/manifest that references only real generated shards.
- [x] 6.2 Replace fixed 64-wrapper generation with actual-shard or stable-aggregator compilation.
- [x] 6.3 Track include dependencies per shard and avoid repeating unrelated headers.
- [x] 6.4 Preserve deterministic shard names, external dependencies, incremental rebuild behavior, and the configured shard limit.
- [x] 6.5 Add generation and build-size benchmarks comparing wrapper count, include count, generated source size, and compile time.

## 7. Repair output lifecycle and diagnostics

- [x] 7.1 Add cleanup coverage for the NativeModuleFunctionAddress bridge probe and all retired migration outputs.
- [x] 7.2 Make stale output cleanup report missing module directories and deletion failures with actionable diagnostics.
- [x] 7.3 Add failure reason, result state, and artifact identity to per-function diagnostics.
- [x] 7.4 Recompute aggregate statistics from analysis results and assert category/count reconciliation.
- [x] 7.5 Update maintained documentation and generated-artifact troubleshooting guidance.

## 8. Verify the complete matrix

- [x] 8.1 Run focused UHT configuration, resolver, emitter, cleanup, and diagnostics tests.
- [x] 8.2 Run the default installed-engine Runtime-linked build and generated-binding tests.
- [x] 8.3 Run installed-engine rejection tests for NativeModuleFunctionAddress.
- [ ] 8.4 Run source-engine target-module generation and compilation with explicit Engine/plugin/project module selections. Blocked by the available UE 5.7.2 source checkout being incompatible with this repository's UE 5.8 code.
- [ ] 8.5 Run source-engine late-load, unload, reload, and script-call safety tests. Blocked until the source-engine compatibility gap is resolved.
- [x] 8.6 Run `openspec validate refactor-uht-plugin-hardening --strict` and record verification results.
