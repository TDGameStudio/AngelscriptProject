# Typed Semantic AOT Implementation Reference Notes

This attachment records implementation-time reference research. It is kept
separate from `tasks.md` so that the task checklist remains concise while the
origin, scope, and non-copying boundaries of each borrowed design idea remain
auditable.

Reference policy for this change:

1. Inspect the repositories already available under the main checkout's
   `Reference/` directory first.
2. Fetch an additional reference repository only when the required mechanism
   is not represented locally.
3. Record the exact repository revision and source files consulted.
4. Record the design observation that influenced this implementation and the
   boundary that deliberately was not copied.
5. Never introduce a reference repository as a plugin build, runtime, or
   generated-output dependency.

## 2026-08-14 — function-local indexed IR identities and verification

Reference repository:

- Local path: `D:/Workspace/AngelscriptProject/Reference/fuzzilli`
- Revision: `357cc311e8513cb4ef68ea4f3efef5fd1c418abc`
- Files inspected:
  - `Sources/Fuzzilli/FuzzIL/Variable.swift`
  - `Sources/Fuzzilli/FuzzIL/Instruction.swift`
  - `Sources/Fuzzilli/FuzzIL/Code.swift`
  - `Sources/Fuzzilli/Base/ProgramBuilder.swift`

Relevant observations:

- A variable identity is a small numeric value local to one program, with an
  explicit invalid/unattached state rather than a process address.
- Appending an instruction assigns its stable index from the current arena
  count, so storage order and identity agree deterministically.
- Verification independently checks that stored instruction indices match
  their arena positions and that referenced variables are already defined,
  contiguous, and visible in the active scope.
- Builder convenience does not replace verifier authority: construction and
  validation are separate responsibilities.

How the observation influenced Typed Semantic HIR:

- `asTTypedSemanticId` is a typed function-local numeric identity with an
  explicit invalid sentinel.
- `AddSymbol`, `AddExpression`, and `AddStatement` assign IDs from their
  function-owned arena indices.
- The verifier rechecks arena/index agreement and rejects dangling or
  multiply-owned references; deterministic dumps enumerate the same arenas in
  index order.

Deliberate non-copying boundary:

- FuzzIL is a flat, mutation-oriented, SSA-like fuzzing IR implemented in
  Swift. Typed Semantic HIR is a structured, immutable-after-capture AngelScript
  semantic sidecar with exact `asCDataType` values, owned source spans, distinct
  symbol/expression/statement arenas, statement ownership, receiver shape, and
  control targets.
- No Swift source, FuzzIL operation schema, minimizer behavior, serialization
  format, or runtime dependency is copied or linked into the plugin.
- The local reference was sufficient for this model/lifetime question; no
  network fetch was needed.

## 2026-08-14 — function-owned builder and authoritative-input capture

Reference repository:

- Local path: `D:/Workspace/AngelscriptProject/Reference/luau`
- Revision: `ca128af4c531310d6f5c1b354df4b79fdd782ede`
- Files inspected:
  - `CodeGen/include/Luau/IrBuilder.h`
  - `CodeGen/src/IrBuilder.cpp`
  - `CodeGen/include/Luau/IrData.h`
  - `CodeGen/src/IrAnalysis.cpp`

Relevant observations:

- `IrBuilder` owns one `IrFunction`; its block, instruction, constant, and
  bytecode-mapping arenas therefore have one explicit function lifetime.
- The builder first reconstructs authoritative bytecode control-flow blocks,
  then translates instructions in source order, and only after generation
  computes derived use counts. This keeps capture input and post-capture
  analysis responsibilities distinct.
- Builder operations return indexed operands rather than exposing source
  object addresses. CFG analysis separately checks entry/live-in invariants
  after construction.

How the observation influenced Typed Semantic HIR capture:

- The maintained AngelScript compiler uses a compile-local provisional builder
  that owns exactly one candidate `asCTypedSemanticFunction`.
- Capture follows the compiler's already-resolved expression and statement
  path. It records exact semantic results without becoming authoritative for
  bytecode generation.
- Publication is transactional: only the finished candidate is independently
  verified and moved onto the script function. Capture-off, capture failure,
  or verification failure leaves ordinary bytecode and VM behavior unchanged.

Deliberate non-copying boundary:

- Luau's IR is a bytecode-to-native, register/CFG-oriented optimizing IR. The
  AngelScript sidecar is structured source-semantic HIR captured while the
  compiler still owns resolved types, symbols, source spans, and statement
  structure. It does not adopt Luau bytecode, VM registers, opcodes, native
  lowering, optimization passes, or host hooks.
- No Luau source or schema is copied, and the local checkout is not a build or
  runtime dependency. The available local repository answered the ownership
  and capture-order question, so no network fetch was needed.

## 2026-08-14 — fail-closed AOT text materialization

Reference repository:

- Local path: `D:/Workspace/AngelscriptProject/Reference/daScript`
- Revision: `ae21253fea2b8184f81c00013f2684c98c31174d`
- Files inspected:
  - `daslib/aot_cpp.das` (`fail_on_aot_emit_error`, `run_aot`, and
    `run_aot_function`)
  - `include/daScript/ast/ast_aot_cpp.h`

Relevant observations:

- The daScript AOT path writes function text into a temporary writer and copies
  it to the outer result only if the program has no macro/codegen failure.
- Its single-function path explicitly keeps the partial buffer private on the
  failure path, performs cleanup, and then surfaces the recorded error.
- Registration/output assembly occurs after the function-generation pass has
  passed that failure check.

How the observation influenced TypedASTJIT:

- Analysis runs before emission, and emission builds declaration/definition
  text in a local candidate.
- Final forbidden-token and structural checks run before any candidate text is
  returned as successful output.
- Every failure result is newly constructed and contains diagnostics only;
  declaration, definition, includes, and registration fragments remain empty.

Deliberate non-copying boundary:

- TypedASTJIT does not copy daScript's visitor, macro, module-registration,
  runtime-context, marker-extraction, or generated C++ schema. It emits only
  the reviewed scalar HIR subset from maintained-fork types and indexed nodes.
- No daScript source or runtime is compiled or linked. The local reference was
  sufficient, so no network fetch was required.
