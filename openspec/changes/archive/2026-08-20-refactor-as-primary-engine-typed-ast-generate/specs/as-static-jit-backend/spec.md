## MODIFIED Requirements

### Requirement: Generation Engines do not materialize script reflection

A StaticJIT generation Engine SHALL be created for isolated commandlet Generate and for Editor Generate whose target profile is not the primary Engine profile, with explicit purpose `EAngelscriptEnginePurpose::StaticJITGeneration`. It SHALL replay the complete sealed Bind collection and compile the complete target-profile source graph for its Provider domain. Ordinary Runtime/Editor Engine creation SHALL remain the default purpose. Matching-profile Editor Generate SHALL use the primary Engine and MUST NOT create a generation Engine. A generation Engine MAY read existing native reflection, but it MUST perform script ClassGenerator descriptor analysis without creating script reflection objects or executing reload/materialization lifecycle.

#### Scenario: Source graph contains reflected script types

- **WHEN** generation compiles scripts declaring UCLASS, USTRUCT, delegate, UPROPERTY, and UFUNCTION surfaces
- **THEN** descriptor analysis resolves functions, receivers, signatures, UFUNCTION roots, and shared Entry Plans
- **AND** no script `UClass`, `UScriptStruct`, `UDelegateFunction`, `UFunction`, or CDO is created by a generation Engine
- **AND** no Soft/Full Reload, class redirect, reinstancing, or default-object initialization runs as part of generation

#### Scenario: Native Bind surface is replayed per generation Engine

- **WHEN** a generation Engine is created for a frozen target profile
- **THEN** the complete sealed Bind callbacks register native declarations, types, functions, properties, and native call metadata into that Engine's own `asIScriptEngine`
- **AND** existing native UE reflection may be referenced read-only but no native or script `UClass` is recreated for the temporary Engine
- **AND** Bind replay publishes no script routes or registrations into the primary Editor/Runtime Engine

#### Scenario: Matching-profile Editor skips generation Engines

- **WHEN** Editor Generate requests the primary Engine target profile
- **THEN** no `StaticJITGeneration` Engine is created
- **AND** destroying Generate request state cannot invalidate the primary Editor Engine

#### Scenario: Two commandlet processes compile the same profile

- **WHEN** two commandlet processes compile the same source/profile
- **THEN** each owns independent AngelScript type/function objects and treats numeric IDs as Engine-local
- **AND** their normalized stable artifact identities are equal

### Requirement: Typed HIR capture is source-only and opt-in

The generation orchestrator SHALL freeze typed-HIR capture before Engine create. `"bytecode"` Editor/Runtime Engines and `"bytecode"` generation SHALL default to capture-off. A primary Engine MAY optionally capture when the operator wants matching-profile `"typed-ast"` Generate without a generation Engine. A `"typed-ast"` generation Engine SHALL capture on for that request only. Cache V2 MAY restore typed HIR only from a pointer-free TypedHIR sidecar; dump files and bytecode FunctionBody payloads MUST NOT synthesize HIR.

#### Scenario: TypedASTJIT matching-profile generation is requested

- **WHEN** orchestration selects `"typed-ast"` for the primary target profile and the primary Engine has capture enabled with verified HIR
- **THEN** it uses the primary Engine
- **AND** it does not create a generation-only Engine

#### Scenario: TypedASTJIT matching-profile generation without capture is rejected

- **WHEN** orchestration selects `"typed-ast"` for the primary target profile and the primary Engine has capture off
- **THEN** the request fails with `CaptureRequired`
- **AND** it does not create a generation Engine to obtain matching-profile HIR

#### Scenario: TypedASTJIT non-matching or commandlet generation is requested

- **WHEN** orchestration selects `"typed-ast"` for a non-matching profile or a commandlet process
- **THEN** it creates a generation Engine with capture enabled before any source function compiles
- **AND** it compiles the complete Provider source graph from source, or ExactStartup-restores bytecode plus TypedHIR sidecars, before constructing the generation view

#### Scenario: BytecodeJIT generation is requested

- **WHEN** orchestration selects `"bytecode"`
- **THEN** typed-HIR capture remains disabled
- **AND** the current bytecode-to-C++ path does not depend on typed-HIR model, verifier, or lifetime state
