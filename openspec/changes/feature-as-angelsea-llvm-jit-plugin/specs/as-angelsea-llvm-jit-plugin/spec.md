## ADDED Requirements

### Requirement: Angelsea LLVM JIT is an isolated optional plugin

The repository SHALL provide `AngelseaLLVMJIT` as a disabled-by-default sibling plugin for Win64 Editor/Development. The plugin SHALL depend on `AngelscriptRuntime`, while the core plugin, VM, Static AOT, and MIR plugin MUST NOT depend on it.

#### Scenario: Plugin is disabled

- **WHEN** a project builds or runs without enabling `AngelseaLLVMJIT`
- **THEN** it requires no LLVM SDK, headers, import library, DLL, module, or executable memory
- **AND** AngelScript execution remains available through configured AOT/VM paths

#### Scenario: Plugin is enabled on the supported target

- **WHEN** Win64 Editor/Development loads the plugin with a valid SDK and unified coordinator
- **THEN** it registers exactly one current-revision factory under BackendId `angelsea-llvm`
- **AND** it does not call `SetJITCompiler()` or depend on the MIR plugin

### Requirement: The plugin requires one exact external LLVM SDK

When enabled, the plugin SHALL read `Paths.LLVMRoot` and require a complete LLVM 21.1.8 Developer SDK with the configured `llvm-c` Core/Analysis/Target/ORC headers, `LLVM-C.lib`, `LLVM-C.dll`, matching architecture/version metadata, license, and required ORC exports. It MUST NOT silently use PATH, Unreal Engine, Visual Studio, another LLVM version, or a partial SDK.

#### Scenario: Exact SDK is available

- **WHEN** every required header/library/DLL/export exists beneath `Paths.LLVMRoot` and reports LLVM 21.1.8 for Win64 x64
- **THEN** the plugin's External module links/stages the declared LLVM C API runtime
- **AND** diagnostics record the resolved SDK/version without exposing machine secrets

#### Scenario: Enabled plugin has an incomplete SDK

- **WHEN** the plugin is enabled but `Paths.LLVMRoot` is absent, points to another version, or lacks a required component/export
- **THEN** the build fails before compiling backend source
- **AND** the error names the configured root, required version, and each missing/mismatched component

#### Scenario: Plugin is disabled with no SDK

- **WHEN** `Paths.LLVMRoot` is absent and `AngelseaLLVMJIT` is disabled
- **THEN** the main project and other plugins build without probing or staging LLVM

### Requirement: Bytecode lowers directly to verified LLVM IR and ORC

For an eligible snapshot, the `angelsea-llvm` session SHALL lower copied AngelScript bytecode/frame/control-flow directly through the LLVM C API, verify the module, validate Win64 x64 target/data layout/calling convention, and compile it with ORC LLJIT into one whole-function VMEntry. It MUST NOT emit C, invoke Clang, use MIR, consume typed semantic HIR, query live AngelScript/UE pointers, or publish a Binding directly.

#### Scenario: Eligible function compiles

- **WHEN** the coordinator submits a valid first-slice scalar/control-flow snapshot
- **THEN** LLVM verification succeeds, ORC returns the expected VMEntry symbol, and the result revision matches the snapshot
- **AND** coordinator publication/execution reaches that native entry

#### Scenario: IR verification fails

- **WHEN** an emitter defect produces invalid LLVM IR
- **THEN** the backend returns `BackendFailure` with verifier diagnostics
- **AND** no callable entry or partial ORC resource is published

#### Scenario: Target layout is incompatible

- **WHEN** snapshot and LLJIT target triple, pointer width, data layout, or calling convention disagree
- **THEN** compilation fails closed before publication
- **AND** the function remains VM-correct

### Requirement: LLVM scalar and control-flow semantics match the VM

The first backend slice SHALL support the same `bool`, signed/unsigned 32/64-bit integer, `float`, and `double` values, scalar frame operations/conversions, arithmetic/bitwise/shift/comparison/boolean operations, and branch/loop control flow as the MIR backend. Generated IR MUST avoid LLVM undefined/poison behavior that differs from the maintained VM.

#### Scenario: Integer boundaries execute natively

- **WHEN** supported fixtures exercise wrap boundaries, signedness, narrowing, shifts, division/modulo traps, and comparisons
- **THEN** LLVM Runtime return and exception state match VM for all boundary inputs
- **AND** a marker proves the ORC entry executed

#### Scenario: Floating boundaries execute natively

- **WHEN** fixtures exercise finite values, infinities, NaN, positive/negative zero, comparison, and float/integer conversion
- **THEN** LLVM Runtime observations match the VM-defined fixture observations

#### Scenario: Control flow executes natively

- **WHEN** a fixture contains branches, loops, break/continue, and scalar accumulation
- **THEN** native termination/result behavior matches VM

### Requirement: Unsupported semantics fall back for the complete function

The backend SHALL reject the complete function before ORC publication when it contains an unsupported opcode, managed lifetime, string/container/delegate operation, script/system/native/UFUNCTION/interface call, suspend/cleanup requirement, Raw/Parms requirement, or Entry ABI mismatch. It MUST NOT emit an internal VM-resume stub.

#### Scenario: Function contains one unsupported operation

- **WHEN** an otherwise eligible function contains one unsupported call, object, or suspend opcode
- **THEN** the backend returns `Unsupported` with a stable reason/offset
- **AND** the complete function executes through VM

#### Scenario: Function requires a host symbol outside the ABI

- **WHEN** lowering would require an unregistered UE/native/helper symbol
- **THEN** eligibility or ORC linking fails closed
- **AND** no unrestricted process symbol search occurs

#### Scenario: Function profile requires a receiver

- **WHEN** the coordinator view identifies native-object, external-parameter-alias, mixin, or unknown receiver semantics
- **THEN** the LLVM backend returns typed `Unsupported` without parsing source or maintained-fork trait bits
- **AND** it creates no LLVM module/native entry, does not erase declared parameter zero, and the complete function remains on VM

### Requirement: ORC sessions and resource trackers are Engine-local and leased

Each selected Engine SHALL own a distinct LLJIT/thread-safe context/session. Every compiled revision SHALL be removable through a resource tracker or equivalent ownership object retained by the coordinator code lease. Compilation is serialized within one first-slice session, and executable resources MUST remain valid for active Binding readers.

#### Scenario: Result becomes stale

- **WHEN** Hot Reload changes the function before an ORC result publishes
- **THEN** the coordinator rejects the result and releases its resource tracker
- **AND** the old symbol cannot be looked up or executed for the replacement function

#### Scenario: Two Engines select LLVM

- **WHEN** two Engines select `angelsea-llvm`
- **THEN** they own distinct LLJIT sessions, symbol namespaces, trackers, and cancellation state
- **AND** disposing one session cannot remove the other's entries

#### Scenario: Plugin unload overlaps execution

- **WHEN** an ORC entry is active while the backend begins retirement
- **THEN** its code lease keeps the session/tracker/DLL dependencies alive until the reader exits
- **AND** unload completes only after all leases release

### Requirement: The backend operates under every coordinator compile policy

The `angelsea-llvm` session SHALL satisfy EagerSync, EagerBackground, and LazyFirstCall conformance through the coordinator's common request/publication state machine.

#### Scenario: Eager background compile completes

- **WHEN** a valid LLVM snapshot is queued under EagerBackground
- **THEN** calls use VM while queued/compiling
- **AND** later calls use ORC Native only after revision-checked publication

#### Scenario: Lazy first call compiles once

- **WHEN** several threads first call one eligible LLVM function revision
- **THEN** the coordinator submits exactly one LLVM compile request
- **AND** calls holding the old route use VM before later Native publication

### Requirement: LLVM correctness and performance evidence is comparable

The LLVM test module SHALL run the shared VM/MIR/LLVM differential corpus and record SDK/Engine/build identity, compile latency, first/second-call policy latency, steady-state ns/op, generated code bytes, session memory, and resource-release behavior. Performance results MUST NOT automatically enable the plugin, distribute the SDK, or authorize Shipping.

#### Scenario: Cross-backend differential run completes

- **WHEN** the shared Runtime JIT corpus runs with explicit `VMOnly`, `angelsea-mir`, and `angelsea-llvm` Engines where both plugins are available
- **THEN** every supported observation is compared against VM
- **AND** a backend-specific unsupported result is reported separately from semantic mismatch

#### Scenario: LLVM benchmark is produced

- **WHEN** the documented Win64 Editor/Development performance prefix runs
- **THEN** its report includes exact LLVM SDK version, BackendId, policy, corpus, VM/LLVM measurements, code size, memory, and unload data
- **AND** it does not claim productization from steady-state microbenchmark speed alone
