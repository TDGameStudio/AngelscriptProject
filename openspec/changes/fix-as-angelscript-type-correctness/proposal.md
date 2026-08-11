## Why

`FAngelscriptType` currently has several independently reproducible correctness
hazards: one common `FAngelscriptTypeUsage` constructor leaves its payload union
indeterminate, failed property finders can leak partial results, explicit
type-database signature APIs still consult ambient engine state, non-byte enum
properties can be accepted by a byte-only adapter, and owned container template
operations are not released with their AngelScript type information. These must
be repaired before later type-system or Typed Semantic IR refactoring can rely on
the runtime type layer as a trustworthy lowering service.

## What Changes

- Initialize every `FAngelscriptTypeUsage` construction/reset path to a
  deterministic empty payload without changing the struct layout.
- Make `FAngelscriptTypeUsage::FromProperty` commit a type-finder candidate only
  when that finder succeeds with a valid result; failed finders cannot leak
  `Type`, subtype, or payload state.
- Make every API that accepts an explicit `FAngelscriptTypeDatabase` use that
  database end to end, including reflected function-signature construction and
  type-id/data-type conversion helpers used away from an ambient engine scope.
- **BREAKING (correctness tightening):** Retain the current one-byte AngelScript
  enum ABI, but stop publishing native enum value sets outside `0..255` and fail
  closed for non-byte native enum properties instead of accepting them and
  truncating or under-copying their values. Byte-safe enums are unaffected;
  genuine wide-enum support is deferred to a separate ABI change.
- Store `TArray`, `TMap`, `TSet`, and `TOptional` template operation objects in
  dedicated owned type-info user-data slots and delete them through registered
  cleanup callbacks.
- Add focused C++ automation regressions for each repaired contract and update
  the Chinese type-system knowledge document to match the current per-engine
  database implementation.
- Preserve ambient compatibility overloads, the existing bytecode/StaticJIT
  behavior, and all supported byte-backed enum behavior.

## Capabilities

### New Capabilities

- `as-runtime-type-correctness`: Defines deterministic type-usage state,
  transactional property resolution, explicit database routing, and safe enum
  representation at the runtime type boundary.

### Modified Capabilities

- `engine-shutdown-resource-cleanup`: Adds release of owned container template
  operation data when AngelScript type information is destroyed.

## Impact

- Runtime core:
  `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h`,
  `AngelscriptType.cpp`, and explicit signature construction in
  `Binds/Helper_FunctionSignature.h`.
- Runtime bindings: `Bind_UEnum.cpp` plus the `TArray`, `TMap`, `TSet`, and
  `TOptional` template-operation caches.
- Tests: existing Engine TypeUsage, TypeDatabase, and BindingArchitecture
  owners, plus focused enum-representation and template-user-data lifetime
  owners in `AngelscriptTest/Core`.
- Documentation: `Documents/Knowledges/ZH/Type_Core.md`.
- No public AngelScript SDK ABI, bytecode format, generated binding-layout
  version, canonical alias policy, or Typed Semantic IR schema changes.
