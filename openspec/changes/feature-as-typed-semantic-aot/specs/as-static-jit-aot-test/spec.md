## ADDED Requirements

### Requirement: StaticJIT AOT fixtures cover Semantic generation

The StaticJIT AOT fixture workflow SHALL generate, compile, register, and execute representative Semantic AOT UFUNCTIONs in addition to preserving the existing legacy fixture path.

#### Scenario: Semantic generated source is deterministic

- **WHEN** the AOT generation fixture runs twice in Semantic mode with identical source and environment
- **THEN** the normalized HIR dump and generated Semantic C++ artifacts are identical
- **AND** generated-output verification detects stale checked-in Semantic artifacts

#### Scenario: Semantic function registers through normal entries

- **WHEN** generated Semantic fixture code is rebuilt and the paired test data is loaded
- **THEN** the target UFUNCTION has the applicable VM/raw/parameter JIT entries
- **AND** a test-visible backend marker identifies Semantic rather than legacy execution

#### Scenario: External native call links through the generated module

- **WHEN** a Semantic fixture directly calls a Runtime-owned scalar symbol or thunk advertised as externally callable
- **THEN** the generated project module includes its declared header, links against `AngelscriptRuntime`, and executes that exact direct target
- **AND** the test fails at the module link gate when the declaration lacks `ANGELSCRIPTRUNTIME_API` or the symbol has internal linkage

#### Scenario: Private FBind helper never leaks into generated code

- **WHEN** a fixture calls a scalar binding whose implementation remains provider-private and has no exported thunk
- **THEN** generated source contains no reference or redeclaration of the private helper symbol
- **AND** runtime proof observes the scalar bridge or the expected typed fallback

#### Scenario: Ineligible fixture proves legacy fallback

- **WHEN** the fixture includes RPC/event, complex-signature, suspend, or unsupported-body functions
- **THEN** generation records the expected typed fallback reason for each function
- **AND** each function remains executable through legacy StaticJIT or VM as specified

### Requirement: StaticJIT AOT fixtures compare legacy and Semantic behavior

The StaticJIT AOT test workflow SHALL provide Dual fixtures that execute independent legacy and Semantic implementations against isolated scalar state and fail on semantic divergence.

#### Scenario: Supported scalar matrix is equivalent

- **WHEN** Dual fixtures cover scalar/enum locals, conversions, arithmetic, comparisons, bitwise/logical operators, supported structured control flow, returns, exported/inline/thunk direct calls, and scalar helper bridges
- **THEN** legacy and Semantic executions produce identical return, parameter-memory, exception, and declared scalar-state results

#### Scenario: Scalar edge behavior is equivalent

- **WHEN** Dual fixtures exercise signed/unsigned boundaries, narrowing, shifts, integer division and divide-by-zero, float/double conversion, enum representation, and short-circuit side effects
- **THEN** legacy and Semantic results and exception states match exactly

#### Scenario: Claimed support cannot silently fall back in Dual mode

- **WHEN** a fixture is expected to be Semantic-eligible but HIR verification or Semantic emission fails
- **THEN** the Dual test fails with the eligibility or emitter diagnostic
- **AND** a passing legacy execution does not hide the Semantic failure
