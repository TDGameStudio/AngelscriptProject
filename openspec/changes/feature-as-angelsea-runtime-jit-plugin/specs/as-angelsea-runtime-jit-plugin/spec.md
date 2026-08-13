## ADDED Requirements

### Requirement: Angelsea Runtime JIT is an isolated optional plugin

The repository SHALL provide `AngelseaRuntimeJIT` as a disabled-by-default sibling plugin for Win64 Editor/Development. The plugin SHALL depend on `AngelscriptRuntime`, while the core plugin, VM, Static AOT, and LLVM plugin MUST NOT depend on it.

#### Scenario: Plugin is disabled

- **WHEN** a project builds or runs without enabling `AngelseaRuntimeJIT`
- **THEN** no MIR/c2mir source, library, module, backend factory, or executable memory is included for that plugin
- **AND** AngelScript execution remains available through configured AOT/VM paths

#### Scenario: Plugin is enabled on the supported target

- **WHEN** Win64 Editor/Development loads the plugin with the unified coordinator available
- **THEN** it registers exactly one current-revision factory under BackendId `angelsea-mir`
- **AND** it does not call `SetJITCompiler()`

### Requirement: Third-party MIR sources are pinned and self-contained

The plugin SHALL build only from plugin-owned, audited sources derived from Angelsea commit `1d367d431cdfd7e5e51b2341312078fd40cc10a4` and MIR commit `3cb30b39b81b2a8d7348cd4db66f8b219a9ebee0`. It MUST preserve BSD-2-Clause/MIT notices and MUST NOT compile from `Reference/angelsea` or import Angelsea's bundled AngelScript, fmt, tests, benchmarks, or unused MIR tools/targets.

#### Scenario: Build inputs are inspected

- **WHEN** the plugin's Build.cs, ThirdParty manifest, and source list are reviewed
- **THEN** every imported file has upstream path/commit/license provenance
- **AND** no path beneath `Reference/` or Angelsea's bundled AngelScript/fmt/test directories is a build input

#### Scenario: Upstream baseline changes

- **WHEN** a later change refreshes Angelsea-derived or MIR sources
- **THEN** it updates the pinned revision, copied-file manifest, local patch inventory, license review, and conformance results together

### Requirement: The backend compiles snapshots through BytecodeToC and MIR

For an eligible compile snapshot, the `angelsea-mir` session SHALL perform whole-function supported-subset validation, emit neutral C, compile it through c2mir/MIR, and return one Win64 x64 VMEntry plus an owned code lease. It MUST NOT consume live AngelScript/UE pointers or publish a Binding directly.

#### Scenario: Eligible function compiles

- **WHEN** the coordinator submits a valid first-slice scalar/control-flow snapshot
- **THEN** the session returns a compiled VMEntry whose revision matches the snapshot
- **AND** the coordinator can publish and execute it through the Runtime Binding path

#### Scenario: Result becomes stale

- **WHEN** the function revision changes before the coordinator publishes a successful MIR result
- **THEN** the coordinator rejects the result
- **AND** releasing its lease reclaims MIR/executable resources without attaching the entry

### Requirement: Scalar and control-flow semantics match the VM

The first backend slice SHALL support `bool`, signed/unsigned 32/64-bit integer, `float`, and `double` parameters/results/locals; scalar constants/load/store/conversions; arithmetic/bitwise/shift/comparison/boolean operations; and branch/loop control flow. Every supported operation MUST match maintained-fork VM values and exception behavior.

#### Scenario: Integer boundaries execute natively

- **WHEN** a supported function exercises signed/unsigned limits, narrowing, shifts, comparison, division, and modulo
- **THEN** Runtime execution matches VM return and exception state for all boundary inputs
- **AND** an execution marker proves the MIR entry ran

#### Scenario: Floating boundaries execute natively

- **WHEN** a supported function observes finite values, infinities, NaN, positive/negative zero, comparisons, and numeric conversions
- **THEN** Runtime execution matches the VM's declared scalar observations

#### Scenario: Loop-heavy function executes natively

- **WHEN** a supported function contains branches, loops, break/continue, and scalar accumulation
- **THEN** the compiled result and termination behavior match VM
- **AND** the native marker increments through the selected Runtime route

### Requirement: Unsupported semantics fall back for the complete function

The backend SHALL reject a complete function before publication when it contains any unsupported opcode, object/handle/reference lifetime, string/container/delegate operation, script/system/native/UFUNCTION/interface call, suspend/cleanup requirement, Raw/Parms requirement, or Entry ABI mismatch. It MUST NOT use Angelsea ignore hacks or resume VM at an internal bytecode offset.

#### Scenario: Function contains one unsupported call

- **WHEN** an otherwise eligible scalar function contains one unsupported call opcode
- **THEN** the backend returns `Unsupported` with a stable reason/offset
- **AND** the entire function executes through VM

#### Scenario: Function can suspend

- **WHEN** snapshot metadata or bytecode indicates suspend/latent behavior
- **THEN** no MIR code is published
- **AND** the function retains the VM's continuation semantics

#### Scenario: Source modifier requires an object receiver

- **WHEN** the coordinator profile identifies native-object, external-parameter-alias, mixin, or unknown receiver semantics
- **THEN** the MIR backend returns typed `Unsupported` without parsing source or maintained-fork trait bits
- **AND** it emits no C/native entry, does not erase declared parameter zero, and the complete function remains on VM

### Requirement: The backend operates under every coordinator compile policy

The `angelsea-mir` session SHALL satisfy EagerSync, EagerBackground, and LazyFirstCall conformance. Compilation SHALL be serialized within one session, while separate Engine sessions remain isolated. Each successful function revision SHALL use a disposable MIR context/code arena owned by its code lease rather than relying on per-function unload from one shared long-lived MIR context.

#### Scenario: Background compile overlaps Hot Reload

- **WHEN** an EagerBackground MIR compile is blocked while Hot Reload replaces the function
- **THEN** execution uses VM during the overlap
- **AND** the old result is discarded as stale without cross-revision publication

#### Scenario: Two Engines compile concurrently

- **WHEN** two Engines select `angelsea-mir`
- **THEN** each uses a separate MIR session/code namespace
- **AND** serialized work in one session does not attach resources or results to the other

#### Scenario: One function revision retires

- **WHEN** a MIR Runtime Binding and its final active reader release their code lease
- **THEN** the backend tears down that revision's isolated MIR context/code arena
- **AND** other compiled function revisions in the Engine session remain callable

### Requirement: MIR external symbols and code memory are closed and leased

Generated code SHALL resolve only the versioned scalar Runtime JIT helper allowlist and approved C math/memory functions. Every executable allocation SHALL be owned by the returned code lease, use reviewed write/execute transitions, and remain valid for active Binding readers.

#### Scenario: Generated code requests an unknown symbol

- **WHEN** emitted C/MIR references a symbol outside the allowlist
- **THEN** compilation fails closed with `BackendFailure` or `Unsupported`
- **AND** no arbitrary process symbol lookup is attempted

#### Scenario: Plugin unload overlaps active execution

- **WHEN** a MIR entry is executing as the plugin/backend session begins retirement
- **THEN** the executable allocation remains valid until the active reader exits
- **AND** unload completes only after all MIR code leases release

### Requirement: Correctness and performance evidence is reproducible

The plugin test module SHALL run a shared VM/MIR differential corpus and record compile latency, first/second-call policy latency, steady-state ns/op, generated code bytes, session memory, and release behavior for representative scalar/control-flow workloads. Performance results MUST NOT automatically enable the plugin or Shipping support.

#### Scenario: PoC benchmark is produced

- **WHEN** the Runtime JIT performance prefix runs on the documented Win64 Editor/Development configuration
- **THEN** its report identifies Engine/build configuration, BackendId, compile policy, function corpus, VM/MIR measurements, code size, and memory data
- **AND** it separately reports correctness failures and performance outcomes
