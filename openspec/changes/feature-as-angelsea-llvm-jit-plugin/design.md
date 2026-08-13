## Context

The Angelsea/MIR backend uses C as a convenient intermediate language. LLVM can provide a stronger SSA optimizer and ORC lifetime model, but LLVM itself is not a C frontend: swapping c2mir calls for LLVM calls would not consume Angelsea's generated C. This change therefore implements a second optional backend that lowers the coordinator's immutable AngelScript bytecode snapshot directly to LLVM IR.

The plugin is intentionally independent of both the MIR plugin and `feature-as-typed-semantic-aot`. Typed semantic HIR exists only during selected source-generation builds and is not available for bytecode-only modules; the Runtime LLVM backend must remain bytecode-oriented.

Unreal's build toolchain is not a supported linkable Runtime LLVM SDK. The current local UE 5.8 installation contains no Engine ThirdParty LLVM library surface for modules. A local LLVM 21.1.8 `LLVM-C.dll` exports ORC LLJIT functions, but the installed Scoop package lacks the full Core/ORC development headers. The PoC must therefore define and validate an explicit external SDK contract instead of silently searching UE or PATH.

## Goals / Non-Goals

**Goals:**

- Add a disabled-by-default sibling `AngelseaLLVMJIT` plugin with BackendId `angelsea-llvm` for Win64 Editor/Development.
- Lower the shared first-slice bytecode snapshot directly to valid LLVM IR and compile it through ORC LLJIT.
- Use the LLVM C API boundary against one exact LLVM 21.1.8 Developer SDK configured by `Paths.LLVMRoot`.
- Own native code through Engine-local ORC sessions/resource trackers and coordinator code leases.
- Satisfy the same scalar/control-flow semantics, three policy contracts, VM differential fixtures, diagnostics, and performance schema as MIR.
- Leave the core plugin, VM, Static AOT, and MIR builds independent of LLVM.

**Non-Goals:**

- Compiling Angelsea-generated C, embedding Clang, invoking an external compiler process, or using MIR/llvm2mir.
- Lowering typed semantic HIR or making Runtime LLVM depend on source-only compiler data.
- Vendoring/building LLVM source or committing LLVM binaries in the first PoC.
- Automatically accepting another LLVM major/minor/patch, finding LLVM from PATH, or linking an Unreal-internal LLVM toolchain.
- Objects/handles/references/calls, Raw/Parms, ResumeVM, UE-aware IR, non-Windows targets, packaging, or Shipping.

## Decisions

### The plugin is optional and has no reverse dependency

The planned root is `Plugins/AngelseaLLVMJIT/` with:

- `AngelseaLLVMJIT`: factory/session, direct LLVM IR lowering, ORC integration, and host adapter;
- `AngelseaLLVMJITTest`: shared/backend-specific conformance and benchmarks;
- `Source/ThirdParty/LLVM`: External module/build contract, version checks, license/provenance, and no SDK payload.

The plugin is disabled by default and restricted to Win64 Editor/Development. `AngelscriptRuntime` exposes only the neutral backend ABI; it does not include LLVM headers or link LLVM libraries. The MIR plugin does not depend on or fall back to this plugin.

### The SDK contract is exact and machine-local

`AgentConfig.ini` gains optional `Paths.LLVMRoot`. The first supported value points to a complete LLVM 21.1.8 Developer SDK containing the required `llvm-c` Core/Analysis/Target/Orc/LLJIT headers, `LLVM-C.lib`, `LLVM-C.dll`, version metadata, and license.

Build rules validate exact major/minor/patch, target architecture, headers, import library, DLL, and required ORC C exports. If the plugin is disabled, no LLVM path is required. If it is enabled and the contract is incomplete, UBT fails with the configured root, expected version, and missing/mismatched components. It never chooses PATH, the current UE Engine, Visual Studio's Clang tools, or another SDK version.

The local Editor build may stage `LLVM-C.dll` from the configured SDK into the target output and use delay-load/explicit DLL-directory setup. The SDK and binary are not committed, and this PoC does not define redistribution.

Alternative rejected: link LLVM C++ component libraries. The C API keeps the UE boundary smaller and avoids exposing LLVM's C++ ABI, RTTI, exception, and build-option coupling.

Alternative rejected: vendor/build LLVM in the plugin. It would make the first feasibility change dominated by repository size and toolchain maintenance.

### Bytecode lowers directly to LLVM IR

The session pipeline is:

```text
FAngelscriptRuntimeJITCompileSnapshot
  -> shared first-slice supported-subset scan
  -> LLVM C API types/functions/basic blocks/SSA and explicit frame operations
  -> LLVM verifier
  -> target machine/data-layout validation
  -> ORC ThreadSafeModule + LLJIT resource tracker
  -> Win64 x64 whole-function VMEntry
  -> FAngelscriptRuntimeJITCompileResult + code lease
```

The emitter consumes only copied bytecode/frame/control-flow data and the neutral helper ABI. It does not parse source, traverse AST/HIR, emit C text, invoke Clang, or query a live AngelScript function. The exact Win64 target triple, pointer width, data layout, and VMEntry calling convention are checked against the snapshot and LLJIT before publication.

The copied input also includes the coordinator's versioned neutral function
profile. The backend does not interpret raw maintained-fork trait bits.
Non-`None` receiver profiles—including an `external_implicit_this` declared
parameter-zero alias—and unknown profile values reject before LLVM IR creation
in the first slice. Parameter zero remains part of the frame, no native object
slot is invented, and compiled-out source calls are not reconstructed from
diagnostic metadata. See the coordinator research attachment
`refactor-as-unified-jit-coordinator/research/function-modifier-and-receiver-boundary.md`.

### The supported semantics are shared with MIR

The LLVM backend supports the same first-slice types and operations as MIR: bool, signed/unsigned 32/64-bit integer, float/double values; scalar locals/params/results; conversions; arithmetic/bitwise/shifts/comparisons/boolean logic; branches/loops/break/continue; whole-function returns and maintained-fork exception state.

AngelScript rules are encoded explicitly rather than delegated to LLVM undefined/poison behavior. Integer overflow, division/modulo traps, shifts, signedness, narrowing, float-to-int conversion, NaN, infinities, and negative zero receive guards, well-defined instructions, or helper calls matching the VM. The verifier passing is necessary but not sufficient; differential tests define semantic acceptance.

Unsupported opcode/lifetime/call/suspend/cleanup/ABI cases reject the whole function before ORC publication. There is no IR stub that resumes VM at a bytecode offset.

### One Engine owns one serialized LLJIT session

The factory creates one ORC LLJIT/thread-safe context environment per selected Engine. The first slice advertises serialized compilation per session for deterministic context/resource management under all policies. EagerBackground scheduling remains coordinator-owned; different Engines may have independent sessions.

Each successful function/module revision receives a resource tracker or equivalent removable ORC ownership object. The returned coordinator code lease retains the session/tracker and removes code only after stale/unpublished results or all published Binding readers release. Backend/plugin unload waits for outstanding code leases.

No JIT symbol may resolve through an unrestricted process generator. Only the versioned scalar helper allowlist and reviewed runtime symbols are explicitly defined in the ORC dylib.

### The two backends share tests, not implementation dependency

The coordinator test support owns neutral inline AngelScript fixtures and expected VM observations. MIR and LLVM test modules instantiate those fixtures in separate Engines with explicit `RuntimeOnly` BackendId. A cross-backend run compares VM, MIR, and LLVM outputs but never selects a fallback chain within one Engine.

LLVM-specific tests additionally cover SDK probing, IR verifier failures, target/data-layout mismatch, unknown helper symbols, ORC resource removal, DLL load failure, and plugin-disabled builds. Benchmark reports use the same fields as MIR so compile cost, first-call cost, steady-state, code size, and memory are comparable.

## Risks / Trade-offs

- **LLVM SDK is large and machine-specific** → Keep the plugin disabled, pin one exact external SDK, validate it early, and defer distribution to a later productization change.
- **Current local LLVM package is incomplete** → Make SDK preflight the first implementation gate; do not begin IR work until required headers/libs/exports are present.
- **LLVM optimizations exploit undefined behavior unlike AngelScript** → Emit guards and defined IR, avoid `nsw`/`nuw` or poison-producing operations unless proven, and require boundary-value VM differential tests.
- **ORC resources outlive script revisions** → Bind each result to coordinator revision checks and retain/remove code through resource-tracker-backed leases.
- **Direct IR lowering duplicates some MIR semantics** → Share snapshot/eligibility fixtures and stable reason taxonomy, not emitter code or plugin dependencies.
- **A microbenchmark win hides compile/memory cost** → Report compile/first-call latency, code size, memory, and unload behavior alongside steady-state speed.

## Migration Plan

1. Land/freeze the unified Runtime backend ABI and shared scalar fixture corpus.
2. Add `Paths.LLVMRoot` parsing/template support and a build-time LLVM 21.1.8 SDK probe; demonstrate precise success/failure without enabling LLVM for normal builds.
3. Scaffold the disabled Win64 Editor plugin, stage/load `LLVM-C.dll`, register an empty `angelsea-llvm` factory/session, and pass coordinator conformance.
4. Create target/data-layout/VMEntry scaffolding and compile a constant scalar function through LLVM C API/ORC with resource-tracker cleanup.
5. Implement and differentially test the shared opcode families, explicit exception/overflow/shift/conversion semantics, and whole-function unsupported scan.
6. Pass EagerSync/EagerBackground/LazyFirstCall, stale-result, two-Engine, active-reader, DLL/session teardown, and shared VM/MIR/LLVM differential tests.
7. Produce benchmark/resource evidence and separately decide whether SDK distribution or wider semantics justify a follow-up.

Rollback is disabling/removing the optional plugin and `Paths.LLVMRoot`. No core cache, AOT artifact, or script source migration is required.

## Open Questions

There are no blocking design questions once a complete LLVM 21.1.8 Developer SDK is available. SDK redistribution, static-versus-dynamic LLVM packaging, optimization level policy, debug object/JIT symbols, non-Windows targets, calls/objects, and Shipping remain future changes.
