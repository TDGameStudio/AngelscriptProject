## ADDED Requirements

### Requirement: StaticJIT AOT fixtures cover TypedASTJIT generation

The StaticJIT AOT fixture workflow SHALL generate, compile, register, and execute representative TypedASTJIT UFUNCTIONs in addition to preserving the existing BytecodeJIT fixture path.

#### Scenario: TypedASTJIT generated source is deterministic

- **WHEN** the AOT generation fixture runs twice with BackendId `"typed-ast"` and identical source and environment
- **THEN** the normalized HIR dump and generated TypedASTJIT C++ artifacts are identical
- **AND** generated-output verification detects stale checked-in TypedASTJIT artifacts

#### Scenario: TypedASTJIT function registers through normal entries

- **WHEN** generated TypedASTJIT fixture code is rebuilt and the paired test data is loaded
- **THEN** the target UFUNCTION has the applicable VM/raw/parameter JIT entries
- **AND** a test-visible backend marker identifies TypedASTJIT rather than BytecodeJIT execution

#### Scenario: External native call links through the generated module

- **WHEN** a TypedASTJIT fixture directly calls a Runtime-owned scalar symbol or thunk advertised as externally callable
- **THEN** the generated project module includes its declared header, links against `AngelscriptRuntime`, and executes that exact direct target
- **AND** the test fails at the module link gate when the declaration lacks `ANGELSCRIPTRUNTIME_API` or the symbol has internal linkage

#### Scenario: Private FBind helper never leaks into generated code

- **WHEN** a fixture calls a scalar binding whose implementation remains provider-private and has no exported thunk
- **THEN** generated source contains no reference or redeclaration of the private helper symbol
- **AND** runtime proof observes the scalar bridge or the expected typed fallback

#### Scenario: Ineligible fixture proves BytecodeJIT fallback

- **WHEN** the fixture includes RPC/event, complex-signature, suspend, or unsupported-body functions
- **THEN** generation records the expected typed fallback reason for each function
- **AND** each function remains executable through BytecodeJIT or VM as specified

### Requirement: StaticJIT AOT fixtures compare BytecodeJIT and TypedASTJIT behavior

The StaticJIT AOT test workflow SHALL run isolated VM, BytecodeJIT, and TypedASTJIT fixtures against equivalent scalar state and fail on semantic divergence without registering a `"dual"` backend.

#### Scenario: Supported scalar matrix is equivalent

- **WHEN** differential fixtures cover scalar/enum locals, conversions, arithmetic, comparisons, bitwise/logical operators, assignment/compound/prefix/postfix mutation, supported structured control flow, returns, exported/inline/thunk direct calls, and scalar helper bridges
- **THEN** BytecodeJIT and TypedASTJIT executions produce identical return, parameter-memory, exception, and declared scalar-state results

#### Scenario: Scalar edge behavior is equivalent

- **WHEN** differential fixtures exercise signed/unsigned boundaries, wrapping add/subtract/multiply, narrowing, negative/width/oversized shift counts, logical/arithmetic shifts, integer division/remainder zero and minimum-value overflow, float/double conversion, enum representation, boolean normalization, and short-circuit side effects
- **THEN** BytecodeJIT and TypedASTJIT results and exception states match exactly

#### Scenario: Eager expression order is equivalent

- **WHEN** differential fixtures reuse the maintained eager-expression-order matrix for ordinary calls, constructors, indexes, call chains, member/index chains, assignment, compound assignment, binary expressions, and nested casts
- **THEN** TypedASTJIT executes receiver and operands in exactly the same authoritative order as VM/BytecodeJIT
- **AND** first/middle/last operand exceptions suppress every later effect

#### Scenario: Mutation evaluates storage once and returns the right value

- **WHEN** differential fixtures place side effects in scalar assignment and compound-assignment targets/RHS and observe prefix/postfix results plus final storage
- **THEN** TypedASTJIT matches VM/BytecodeJIT RHS/target order, evaluates each target once, performs one store, returns the updated prefix value, and returns the old postfix value
- **AND** an exception in either phase suppresses every later phase and store exactly like the oracle

#### Scenario: Continue targets the correct loop phase

- **WHEN** isolated differential fixtures put visible effects or exceptions in for/while/do-while condition, body, continue path, and for increment
- **THEN** TypedASTJIT matches VM/BytecodeJIT phase order for normal and continued iterations
- **AND** switch-in-loop and loop-in-switch fixtures prove `continue` targets a loop while `break` may target the inner switch

#### Scenario: Switch retains maintained validation and runtime behavior

- **WHEN** compiler/AOT fixtures cover duplicate/nonconstant cases, default-last, scoped declarations, explicit and implicit fallthrough, 32-bit selector boundaries, and exhaustive enum switches
- **THEN** compile-time diagnostics remain bytecode-capture invariant
- **AND** TypedASTJIT runtime matches VM/BytecodeJIT case/return/state behavior and the exhaustive invalid-enum exception

#### Scenario: Power support is not inferred from an opcode name

- **WHEN** the maintained native power matrix is run against claimed TypedASTJIT shapes
- **THEN** supported float/double forms match VM/BytecodeJIT conversions, results, and exception state
- **AND** compiler-rejected integer power remains a compile failure and never increments a TypedASTJIT entry counter

#### Scenario: Formal call order does not replace evaluation order

- **WHEN** a three-argument call binds formal arguments `0,1,2` while its HIR evaluation sequence is `2,1,0`
- **THEN** generated-output tests show temporaries materialized in `2,1,0` order and the target invoked with those temporaries in `0,1,2` order
- **AND** all direct and bridge dispositions pass the same runtime oracle

#### Scenario: Global-state boundary is explicit

- **WHEN** fixtures consume a folded primitive/enum pure global, mutable primitive global, object/container global, or global initializer body
- **THEN** only the folded value with matching hard-value dependency may be TypedASTJIT-eligible
- **AND** the remaining fixtures report `UnsupportedGlobalStorage` or `UnsupportedGlobalInitializer` while VM/BytecodeJIT behavior remains available

#### Scenario: Imported binding is not frozen

- **WHEN** a fixture binds, rebinds, unbinds, and rebinds an imported scalar function
- **THEN** any claimed TypedASTJIT route observes the current binding and unbound exception exactly like VM/BytecodeJIT
- **AND** a backend without that route reports `UnsupportedImportedRoute` instead of calling a stale target

#### Scenario: TypedASTJIT dependencies reconcile with compiler capture

- **WHEN** a fixture contains calls, types, folded global constants, and mutable storage uses and its HIR-derived manifest is compared with compiler `artifactDependencies`
- **THEN** compatible coverage succeeds, extra compiler dependencies remain preserved, and a missing/wrong-kind synthetic dependency fails with `SemanticDependencyMismatch`

#### Scenario: Claimed support cannot silently fall back in differential tests

- **WHEN** a fixture is expected to be TypedASTJIT-eligible but HIR verification or TypedASTJIT emission fails
- **THEN** the differential test fails with the eligibility or emitter diagnostic
- **AND** a passing BytecodeJIT execution does not hide the TypedASTJIT failure

### Requirement: StaticJIT AOT fixtures verify TypedASTJIT execution profiles and routing

The StaticJIT test workflow SHALL distinguish JIT frame-position metadata from debugger, coverage, timeout, abort/suspend, and recursion capabilities, and SHALL prove that a TypedASTJIT invocation either supplies every required capability across its direct call closure or uses the approved VM route.

#### Scenario: Public JIT execution position reports the live frame

- **WHEN** a real `FScriptExecution` contains one active `FScopeJITDebugCallstack` frame
- **THEN** `FAngelscriptEngine::GetAngelscriptExecutionFileAndLine()` returns that frame's filename and line
- **AND** nested frame push/pop restores the prior position

#### Scenario: Position-only artifact does not satisfy breakpoint routing

- **WHEN** a fixture has generated frame/line metadata but a breakpoint/step/local-inspection requirement is active
- **THEN** the fixture routes to VM unless it advertises an independently proven debugger-instrumented profile
- **AND** route and entry counters make the decision observable

#### Scenario: Coverage and timeout are preserved or routed

- **WHEN** fixtures execute with CodeCoverage recording or editor loop timeout requirements
- **THEN** approved TypedASTJIT hooks produce the same selected line/timeout observable behavior or the complete invocation routes to VM
- **AND** an uninstrumented direct helper cannot be entered from an instrumented root

#### Scenario: Native recursion stops before stack overflow

- **WHEN** self-recursive and mutually recursive TypedASTJIT scalar fixtures exceed the script frame budget
- **THEN** they finish with the expected script exception without process crash or native stack overflow
- **AND** a build/profile without the guard routes those fixtures to VM with `RecursionGuardUnavailable`

#### Scenario: Safe-point profile changes artifact identity

- **WHEN** the same HIR is generated once position-only and once with approved line/timeout safe-point instrumentation
- **THEN** the generated content/profile identities differ deterministically
- **AND** stale or cross-profile registration fails generated-output verification

### Requirement: StaticJIT AOT fixtures verify exception metadata and cleanup parity

The StaticJIT test workflow SHALL compare the primary exception payload and cleanup trace, not only an exception boolean or process log. It SHALL retain a real generated-output regression proving BytecodeJIT exceptional cleanup order while TypedASTJIT lifetime support remains fail-closed until explicit cleanup plans are implemented.

#### Scenario: Nested generated exception retains metadata

- **WHEN** a generated helper fails inside a generated root
- **THEN** the public result reports the original message, originating function and processed source row/column
- **AND** the root/helper return path does not replace the origin with the outer wrapper

#### Scenario: VM bridge retains nested origin

- **WHEN** a generated caller reaches an approved VM/scalar bridge whose nested context raises an exception
- **THEN** the caller and public context expose the nested primary payload exactly once
- **AND** route counters identify the bridge without converting propagation into a second exception

#### Scenario: BytecodeJIT exceptional cleanup is reverse declaration order

- **WHEN** a real compiled function constructs two live local values and raises before normal scope exit
- **THEN** generated BytecodeJIT exception cleanup destroys the second local before the first
- **AND** the checked generated-output regression fails if cleanup returns to forward declaration order

#### Scenario: Current exception-handler syntax remains rejected

- **WHEN** the maintained rejection fixture compiles `try`, `catch`, incomplete handler syntax or bare rethrow with and without HIR capture
- **THEN** both configurations produce the same rejection outcome and diagnostics
- **AND** no AOT artifact is generated for the invalid source
