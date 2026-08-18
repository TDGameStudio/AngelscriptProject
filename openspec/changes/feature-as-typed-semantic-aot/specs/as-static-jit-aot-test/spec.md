## ADDED Requirements

### Requirement: StaticJIT AOT fixtures cover TypedASTJIT generation

The StaticJIT AOT fixture workflow SHALL generate, compile, register, and execute representative TypedASTJIT UFUNCTIONs in addition to preserving the existing BytecodeJIT fixture path.

#### Scenario: TypedASTJIT generated source is deterministic

- **WHEN** the AOT generation fixture runs twice with BackendId `"typed-ast"` and identical source and environment
- **THEN** generated TypedASTJIT C++ artifacts and stable HIR-derived diagnostic/content fields are identical
- **AND** artifact generation does not require or produce a persisted HIR dump
- **AND** generated-output verification detects stale checked-in TypedASTJIT artifacts

#### Scenario: TypedASTJIT function registers through normal entries

- **WHEN** generated TypedASTJIT fixture code is rebuilt and the paired test data is loaded
- **THEN** the target UFUNCTION has the applicable VM/raw/parameter JIT entries
- **AND** a test-visible backend marker identifies TypedASTJIT rather than BytecodeJIT execution

#### Scenario: External native call links through the generated module

- **WHEN** a TypedASTJIT fixture directly calls a Runtime-owned scalar symbol or thunk advertised as externally callable
- **THEN** the generated project module includes its declared header, links against `AngelscriptRuntime`, and executes that exact direct target
- **AND** the test fails at the module link gate when the declaration lacks `ANGELSCRIPTRUNTIME_API` or the symbol has internal linkage

#### Scenario: Non-cacheable Provider module retains exact runtime identity

- **WHEN** normal compile succeeds for a module that has a loaded Static JIT Provider entry but complete Cache V2 graph capture rejects that module as non-cacheable
- **THEN** Runtime captures only that Provider-requested module's immutable current function facts for route matching
- **AND** the identity-only artifacts never enter Cache publication, packs, manifests, or lifecycle roots
- **AND** unrelated non-cacheable modules are not passed through the function-facts serializer
- **AND** an exact Provider entry may still publish and execute while Cache V2 remains fail-closed for the module

#### Scenario: Private FBind helper never leaks into generated code

- **WHEN** a fixture calls a scalar binding whose implementation remains provider-private and has no exported thunk
- **THEN** generated source contains no linkable C++ reference or redeclaration of the private helper symbol, while an immutable diagnostic metadata string may name the registered target
- **AND** the literal expression calls the header-defined typed `InvokeBound<Return, Args...>` template, the generated metadata names its fixed exported `InvokeBoundViaVM` Runtime DLL core separately, and the expression passes the named call-site row containing declaration, target display name, stable identity, expected ABI and slot index
- **AND** runtime proof shows that the validated slot supplies the current `asCScriptFunction`, whose prepared pooled context reaches its registered `CallFunctionCaller` or `CallGeneric` route and returns the same scalar result as VM
- **AND** changing the diagnostic display strings without changing the slot does not redirect execution, while rebind/unbind/Engine replacement refreshes or invalidates the slot without regenerating the `.jit.cpp`
- **AND** an ABI shape outside the reviewed bridge matrix produces the expected typed fallback

#### Scenario: Ineligible fixture proves BytecodeJIT fallback

- **WHEN** the fixture includes RPC/event, complex-signature, suspend, or unsupported-body functions
- **THEN** generation records the expected typed fallback reason for each function
- **AND** each function remains executable through BytecodeJIT or VM as specified

### Requirement: Script-root function corpus is adapted into inline TypedASTJIT tests

The suite SHALL adapt representative **function-level** cases from project `Script/Tests` and a small `Script/Examples` subset into C++-owned inline AngelScript fixtures. The goal is to prove that function JIT selection and VM results line up. The suite SHALL NOT treat Actor/`TArray`/`FVector`/BlueprintOverride teaching scripts as TypedASTJIT success cases.

Adapted bodies MAY add `UFUNCTION()` so a generation root is eligible. They MUST keep the original scalar arithmetic and expected integers. Class-constructing `Script/Tests` fixtures MUST remain VM-executable and MUST stay Typed-ineligible.

#### Scenario: Adapted scalar Script tests match VM results

- **WHEN** inline fixtures adapted from `Script/Tests/Test_Handles.as`, `Test_Enums.as`, `Test_Inheritance.as`, and `Test_GameplayTags.as` compile in a test Engine
- **THEN** each function executes on the interpreter VM
- **AND** the returned integers are `9`, `1`, `7`, and `1` respectively

#### Scenario: Adapted class Script tests still execute on VM

- **WHEN** inline fixtures adapted from `Script/Tests/Test_ActorLifecycle.as`, `Test_SystemUtils.as`, `Test_ExampleActorFixture.as`, and `Test_MathNamespace.as` compile in a test Engine
- **THEN** each function executes on the interpreter VM
- **AND** the returned integers are `21`, `13`, `42`, and `10` respectively
- **AND** the test does not require those functions to become TypedASTJIT roots

#### Scenario: UFUNCTION-wrapped scalar Script functions select TypedASTJIT

- **WHEN** the same four scalar Script-test bodies are adapted with `UFUNCTION()` and generated with BackendId `"typed-ast"`
- **THEN** each root's `ActualBackendId` is TypedASTJIT
- **AND** generation does not traverse bytecode for those bodies

#### Scenario: Class and container Script adaptations stay on BytecodeJIT or VM

- **WHEN** generation with BackendId `"typed-ast"` includes UFUNCTION-wrapped adaptations of the class `Script/Tests` fixtures and a `TArray`/`Log` reduction of `Script/Examples/Core/Example_Array.as`
- **THEN** those roots record a typed fallback reason such as `UnsupportedLifetime`, `UnsupportedType`, `InvalidCleanupPlan`, or `MissingTypedHIR`
- **AND** they remain executable through BytecodeJIT or VM
- **AND** the test fails if any of those roots reports TypedASTJIT as the actual backend

### Requirement: HIR snapshot tests are independent from StaticJIT AOT fixtures

The test suite SHALL provide a private compiler snapshot helper and a dedicated UE `AngelscriptHIRDump` integration surface for deterministic HIR/golden validation. These tests SHALL NOT use a StaticJIT backend to produce snapshots, and AOT generation SHALL NOT consume snapshot files.

#### Scenario: Native compiler snapshot test has no Provider behavior

- **WHEN** a native compiler or Standalone fixture requests text or JSON HIR
- **THEN** the helper compiles source in a test-owned `asCScriptEngine`, verifies HIR, and returns a deterministic normalized snapshot
- **AND** no C++ body, Provider entry, UASFunction registration, or TypedASTJIT-to-BytecodeJIT fallback is created

#### Scenario: UE dump integration uses a restricted generation Engine

- **WHEN** an automation test invokes `AngelscriptHIRDump` for a concrete target profile
- **THEN** one restricted generation Engine replays complete Binds and compiles the complete relevant source graph with HIR capture enabled
- **AND** the test verifies deterministic `.hir.txt`/`.hir.json` output plus zero UObject/CDO/reload/provider/global-state side effects

#### Scenario: Dump filters do not narrow semantic compilation

- **WHEN** an HIR integration snapshot filters by stable module or function identity
- **THEN** only emitted snapshot rows/files are filtered
- **AND** source compilation, Bind replay, descriptor analysis, dependency resolution, and helper closure still use the complete graph

#### Scenario: Snapshot and AOT paths cannot mask one another

- **WHEN** an HIR snapshot contains an unsupported-but-valid node or a verifier failure
- **THEN** the snapshot reports that compiler result without running BytecodeJIT fallback
- **AND** a separately requested TypedASTJIT AOT fixture independently proves its same-compilation eligibility/fallback and execution counter

#### Scenario: AOT ignores checked-in HIR goldens

- **WHEN** checked-in or generated HIR goldens are stale, missing, or intentionally modified
- **THEN** TypedASTJIT AOT generation still consumes only in-memory HIR from its own one-time source compilation
- **AND** the HIR snapshot test fails or updates independently without changing Provider artifact semantics

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

### Requirement: AST JIT and AOT tests remain partitioned by capability and scenario

The StaticJIT test module SHALL group independently evolving AST JIT and AOT
coverage beneath capability directories such as `StaticJIT/AOT/RuntimeRoutes/`
and `StaticJIT/AOT/Generation/`, plus boundary directories such as
`StaticJIT/AOT/Diagnostics/`, `StaticJIT/AOT/UASFunctionDispatch/` and
`StaticJIT/AOT/References/`, then
split distinct scenario families into bounded C++ test files. Runtime-route coverage SHALL keep debugger,
coverage/timeout, and frame/recursion scenarios separate; whole-generation
determinism, profile identity, stale-output, and expected-fallback verification
SHALL remain in the dedicated generation-verification surface. Shared fixture
lookup and assertion helpers MAY live in small support translation units, but
neither scenario bodies nor a replacement monolithic helper SHALL continue
accumulating in the general `AngelscriptStaticJITAotTests.cpp` file.

#### Scenario: New runtime requirement extends one bounded test surface

- **WHEN** a runtime capability or requirement adds an installed-AOT routing fixture
- **THEN** the test is placed in the matching debugger, coverage/timeout, or frame/recursion file beneath `StaticJIT/AOT/RuntimeRoutes/`
- **AND** only genuinely shared Engine/function lookup and counter helpers are added to the runtime-route support layer
- **AND** the `Angelscript.TestModule.StaticJIT.AOT.RuntimeRoutes` parent prefix continues to discover all of those focused tests

#### Scenario: Expensive whole-generation verification remains independently runnable

- **WHEN** determinism, profile identity, stale output, or expected Typed fallback needs integration coverage
- **THEN** the scenario is placed beneath `StaticJIT/AOT/Generation/` rather than the general AOT test translation unit
- **AND** its dedicated automation prefix permits the affected method to run without also running unrelated scalar, ABI, native-call, or runtime-route coverage
- **AND** non-default fault-injection profiles are verification-only and cannot overwrite checked-in generated artifacts

#### Scenario: Reflected UASFunction dispatch remains independently runnable

- **WHEN** a test covers VM, Raw, or Parms routing through a generated `UASFunction`
- **THEN** its automation class is placed beneath `StaticJIT/AOT/UASFunctionDispatch/`
- **AND** it reuses the existing shared fixture through a narrow test bridge instead of constructing an additional Engine per scenario
- **AND** the `Angelscript.TestModule.StaticJIT.AOT.UASFunctionDispatch` prefix continues to discover the complete reflected-dispatch matrix

#### Scenario: Diagnostics grow by contract surface rather than one translation unit

- **WHEN** generation-time artifact diagnostics, installed Provider/route diagnostics, or JSON/console serialization gains coverage
- **THEN** the test is placed beneath `StaticJIT/AOT/Diagnostics/` in the matching bounded scenario file
- **AND** generation facts are not conflated with installed runtime state or HIR-only inspection facts
- **AND** shared fixture access is exposed through a narrow support interface without duplicating Engine initialization in each translation unit
- **AND** the existing diagnostics automation prefix remains independently runnable while scenario-specific child prefixes MAY be introduced for focused validation

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
