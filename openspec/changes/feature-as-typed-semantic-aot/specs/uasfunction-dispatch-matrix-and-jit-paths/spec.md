## ADDED Requirements

### Requirement: Semantic AOT preserves UASFunction dispatch boundaries

Semantic AOT SHALL reuse existing `UASFunction` VM/raw/parameter entry dispatch and SHALL NOT bypass virtual, event, RPC, thread-safety, or reflected-parameter behavior to obtain a direct call.

#### Scenario: Reflected scalar call reaches Semantic parameter entry

- **WHEN** an eligible generated `UASFunction` is invoked through `RuntimeCallEvent` with reflected scalar parameter memory
- **THEN** the existing parameter-entry branch reaches the Semantic-generated body
- **AND** arguments, return placement, exception state, and test-visible backend marker match the VM contract

#### Scenario: Direct scalar wrapper reaches Semantic raw entry

- **WHEN** an eligible final scalar function shape uses an existing optimized `UASFunction` wrapper with a raw JIT entry
- **THEN** that wrapper may invoke the Semantic raw entry through the current dispatch helper
- **AND** it does not require a Semantic-specific `UASFunction` subclass

#### Scenario: Virtual override is not bypassed

- **WHEN** a parent UFUNCTION has Semantic entries but the receiver resolves to an overriding child implementation
- **THEN** dispatch resolves the current child function before choosing a native or VM entry
- **AND** it never blindly invokes the parent's Semantic raw pointer

#### Scenario: Event and RPC functions remain routed

- **WHEN** a function is BlueprintEvent, BlueprintOverride, RPC/net, validation/event wrapper, or otherwise requires Unreal routing
- **THEN** UASFunction dispatch preserves its existing `ProcessEvent` or VM route
- **AND** Semantic eligibility does not attach a raw-direct entry that bypasses that route

#### Scenario: Thread-safe or unsupported wrapper remains on current path

- **WHEN** a thread-safe, WorldContext-sensitive, complex-signature, or otherwise unsupported wrapper shape is encountered
- **THEN** it uses its documented generic/legacy/VM dispatch behavior
- **AND** availability of Semantic AOT for another function does not change that wrapper selection
