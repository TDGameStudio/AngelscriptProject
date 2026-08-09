## ADDED Requirements

### Requirement: Native-module payloads are discoverable before binding seal

The system SHALL make every eligible, loaded NativeModuleFunctionAddress payload discoverable before the direct binding collection is sealed, without requiring a target Unreal module to depend on `AngelscriptRuntime`.

#### Scenario: Eligible target module is loaded

- **WHEN** a configured target module containing generated native function-address wrappers is loaded during binding startup
- **THEN** Runtime can enumerate its POD payload before primary-engine binding begins
- **AND** the target module has no dependency on `AngelscriptRuntime`

#### Scenario: Module load order is permuted

- **WHEN** the same eligible modules load in a different valid order before seal
- **THEN** Runtime discovers the same payload identities in deterministic order
- **AND** engine binding does not depend on modular-feature arrival timing

### Requirement: Pre-seal transport replaces dynamic engine injection

After the pre-seal transport is enabled, NativeModuleFunctionAddress binding SHALL NOT require pending payload queues, already-constructed-engine replay, object-construction injection, or binding-specific unload removal.

#### Scenario: Primary and secondary engines initialize

- **WHEN** two full AngelScript engines initialize after payload discovery completes
- **THEN** both consume the same immutable payload catalog through explicit engine contexts
- **AND** neither waits for a later module-arrival event

#### Scenario: Native provider changes after seal

- **WHEN** native wrapper code or its owning module changes after the transport is sealed
- **THEN** the runtime reports that process restart is required
- **AND** it does not mutate an already-published engine

### Requirement: Native payload ABI and fallback behavior remain compatible

The transport SHALL preserve NativeModuleFunctionAddress signature eligibility, target-module-local wrapper behavior, RPC/Net reflective fallback, generated diagnostics/statistics, and the versioned POD contract.

#### Scenario: RPC function is encountered

- **WHEN** UHT evaluates an RPC/Net UFunction
- **THEN** it remains in `BlueprintCallableReflectiveFallback`
- **AND** no raw native-module wrapper bypasses Unreal RPC routing

#### Scenario: Payload layout is unchanged

- **WHEN** the replacement transport uses the existing binding/view fields without a layout change
- **THEN** `native-module-function-binding-layout-version.txt` remains unchanged
- **AND** Runtime and generated shard layout tests pass byte-for-byte

#### Scenario: Payload layout intentionally changes

- **WHEN** the selected design requires a POD layout change
- **THEN** the layout version is bumped in the same change
- **AND** Runtime, UHT generation, fixtures, and compatibility diagnostics are updated together
