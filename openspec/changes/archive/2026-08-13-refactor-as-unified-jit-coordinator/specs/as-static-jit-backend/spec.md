## ADDED Requirements

### Requirement: Static generators use an internal backend contract

`AngelscriptRuntime` SHALL own an internal `IAngelscriptStaticJITBackend` contract whose implementations are created once per generation task. Static and Runtime JIT contracts MUST NOT derive from a common backend interface, and Static implementations MUST NOT install or replace an Engine `asIJITCompiler`.

#### Scenario: Bytecode backend is selected by default

- **WHEN** a caller uses an existing StaticJIT generation entry point without specifying a backend
- **THEN** the generator creates the internal backend identified by `"bytecode"`
- **AND** generated C++, stable identities, Provider ABI, and module layout remain compatible with the pre-refactor output

#### Scenario: Static and Runtime IDs are not interchangeable

- **WHEN** a Runtime BackendId is supplied where a Static BackendId is required
- **THEN** validation rejects the request before backend construction
- **AND** no backend is selected by registration order, display name, or pointer value

### Requirement: Static backends consume a complete generation task

Each Static backend instance SHALL receive one complete, synchronous generation view with separate `CompiledSourceGraph` and `EmitModuleSet` concepts. The compiled graph SHALL contain target/profile/Provider facts; every compiled module/function/type/global required for semantic resolution; stable identities; descriptor metadata and UFUNCTION-root mappings; shared Entry Plans; compiler artifact dependencies; external native-call descriptors; bytecode views; and optional verified typed HIR. `EmitModuleSet` SHALL restrict publication without hiding the rest of the compiled graph. A backend result MUST contain only backend-neutral emitted functions, stable references, provenance, and typed dispositions; it MUST NOT retain Engine-local pointers or IDs after the task returns.

#### Scenario: Backend performs task-wide analysis

- **WHEN** a backend requires cross-function reference collection or two-pass analysis
- **THEN** it can inspect every function and relevant descriptor/dependency in `CompiledSourceGraph` before emitting any body
- **AND** Provider packaging still emits one translation unit for each non-empty AS module

#### Scenario: Output selection does not truncate analysis context

- **WHEN** `EmitModuleSet` selects one module whose functions reference types, overloads, imports, globals, or helpers resolved elsewhere in the Provider source domain
- **THEN** the backend can inspect those dependencies through `CompiledSourceGraph`
- **AND** it emits Provider translation units only for modules in `EmitModuleSet`

#### Scenario: Temporary Engine is destroyed

- **WHEN** generation and Provider packaging finish and the temporary Engine is released
- **THEN** generated output contains no `asIScriptFunction`, `asITypeInfo`, descriptor, UObject pointer, FunctionId, PropertyId, or other Engine-local identity
- **AND** all cross-Engine references use stable module/function/profile/reference keys

### Requirement: Provider packaging is backend-neutral

`FAngelscriptStaticJITGenerator` SHALL select backends and fallback, while `FAngelscriptJITGeneration` SHALL remain the deterministic Provider packager. Backend provenance MUST be diagnostic metadata rather than a second Provider function namespace.

#### Scenario: One module mixes Static backends

- **WHEN** TypedASTJIT emits some functions and BytecodeJIT emits fallback functions from the same AS module
- **THEN** the packager emits exactly one module `.jit.cpp`
- **AND** every function retains the same stable Provider identity and entry ABI it would have under a single backend

#### Scenario: No Static backend emits a function

- **WHEN** the selected backend and all configured Static fallbacks report the function unsupported
- **THEN** no partial or synthetic Static entry is published for that function
- **AND** its current runtime route remains VM

### Requirement: Static generation uses stable backend IDs and typed fallback

The initial Static backend IDs SHALL be `"bytecode"` and `"typed-ast"`. `"dual"` MUST NOT be registered as a backend. A `"typed-ast"` production request SHALL fall back per function to `"bytecode"`, then to VM, only after the request capture profile has been validated.

#### Scenario: Typed function is unsupported

- **WHEN** a correctly captured function contains a typed construct unsupported by TypedASTJIT
- **THEN** the generator records the TypedASTJIT reason and offers that function to BytecodeJIT
- **AND** other eligible functions in the same module remain TypedASTJIT output

#### Scenario: Capture profile is inconsistent

- **WHEN** a `"typed-ast"` request is evaluated against an Engine compiled without typed-HIR capture
- **THEN** the complete generation fails with `CaptureProfileMismatch`
- **AND** the generator does not silently report an all-BytecodeJIT artifact as TypedASTJIT success

### Requirement: Generation Engines do not materialize script reflection

A StaticJIT generation Engine SHALL be created with explicit purpose `EAngelscriptEnginePurpose::StaticJITGeneration`, replay the complete sealed Bind collection, and compile the complete target-profile source graph for its Provider domain. Ordinary Runtime/Editor Engine creation SHALL remain the default purpose. The generation Engine MAY read existing native reflection, but it MUST perform script ClassGenerator descriptor analysis without creating script reflection objects or executing reload/materialization lifecycle.

#### Scenario: Source graph contains reflected script types

- **WHEN** generation compiles scripts declaring UCLASS, USTRUCT, delegate, UPROPERTY, and UFUNCTION surfaces
- **THEN** descriptor analysis resolves functions, receivers, signatures, UFUNCTION roots, and shared Entry Plans
- **AND** no script `UClass`, `UScriptStruct`, `UDelegateFunction`, `UFunction`, or CDO is created
- **AND** no Soft/Full Reload, class redirect, reinstancing, or default-object initialization runs

#### Scenario: Native Bind surface is replayed per generation Engine

- **WHEN** a generation Engine is created for a frozen target profile
- **THEN** the complete sealed Bind callbacks register native declarations, types, functions, properties, and native call metadata into that Engine's own `asIScriptEngine`
- **AND** existing native UE reflection may be referenced read-only but no native or script `UClass` is recreated for the temporary Engine
- **AND** Bind replay publishes no script routes or registrations into the current Editor/Runtime Engine

#### Scenario: Two generation Engines compile the same profile

- **WHEN** two generation Engines are alive simultaneously and compile the same source/profile
- **THEN** each owns independent AngelScript type/function objects and treats numeric IDs as Engine-local
- **AND** their normalized stable artifact identities are equal
- **AND** destroying either Engine cannot invalidate the other or the current Editor Engine

### Requirement: Typed HIR capture is source-only and opt-in

The generation orchestrator SHALL freeze typed-HIR capture before source compilation. Ordinary Editor/Runtime Engines and `"bytecode"` generation SHALL default to capture-off, and v1 MUST NOT restore or synthesize typed HIR from Cache V2.

#### Scenario: TypedASTJIT generation is requested

- **WHEN** orchestration selects `"typed-ast"`
- **THEN** it creates a generation-only Engine with capture enabled before any source function compiles
- **AND** it compiles the complete Provider source graph from source before constructing the generation view

#### Scenario: BytecodeJIT generation is requested

- **WHEN** orchestration selects `"bytecode"`
- **THEN** typed-HIR capture remains disabled
- **AND** the current bytecode-to-C++ path does not depend on typed-HIR model, verifier, or lifetime state
