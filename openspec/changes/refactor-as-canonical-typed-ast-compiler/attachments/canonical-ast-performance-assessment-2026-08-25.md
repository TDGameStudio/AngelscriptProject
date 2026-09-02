# Canonical Typed AST performance assessment — 2026-08-25

## Executive conclusion

The new Canonical Typed AST should not currently be described as faster than
the legacy compiler. For already-supported forms, both pipelines ultimately
execute AngelScript VM Bytecode, so runtime performance should be close when
the emitted instruction stream and metadata are equivalent. The architectural
gain is stronger semantic authority, verification, tooling, deterministic
identity, and a reusable optimization/JIT/AOT input. Those gains make future
performance work safer and more local; they do not themselves make today's VM
instructions faster.

Current execution tests establish correctness and publisher provenance, not
timing. No quantitative compile-time, memory, hot-reload, or VM-speed claim is
approved until the benchmark matrix below is recorded.

## Expected comparison by phase

| Dimension | Current expectation | Reason and current evidence boundary |
|---|---|---|
| VM execution time | Near legacy parity for equivalent lowering; either side may win per fixture | Both execute VM Bytecode. Canonical tests prove results and publisher identity, not statistically stable timing or identical Bytecode. |
| Bytecode size/instruction count | Unknown | The new backend may choose different but equivalent instruction sequences. This must be measured separately from elapsed time. |
| Cold full compile latency | Canonical is likely slower today | It allocates the arena graph, performs explicit Sema, layout/lifetime finalization, verifies before publication, emits a detached candidate, and may retain a snapshot. During migration, comparison configurations can also perform legacy work. |
| Peak compile memory | Canonical is likely higher when snapshots are retained | Arena nodes, semantic references, source records, and detached publication candidates coexist. Bulk arena destruction is cheap, but retained snapshots deliberately keep data alive. |
| Discard-policy memory | Potentially competitive after publication | The arena allows bulk release and avoids per-node ownership overhead; this remains unmeasured. |
| Hot Reload / incremental compile | Better optimization potential, no present speed claim | Stable source/decl identity and immutable snapshots enable dependency-directed reuse. Cache V2 is default-off and scheduled for redesign, so cross-Engine restore is not evidence here. |
| Debugging and failure isolation | Already materially better | Dumps distinguish syntax fallback, sealed semantic plans, verifier failures, CodeGen publication, and legacy provenance. This reduces engineering diagnosis time, not necessarily machine execution time. |
| TypedASTJIT/AOT/LLVM lowering cost | Architecturally lower and safer | Backends receive resolved types, calls, control targets, layouts, and cleanup plans instead of rerunning frontend semantics. Actual generated-code quality still depends on the backend and optimization pipeline. |

## Why the architecture can improve performance later

```text
legacy-shaped path
  parser tree
      |
      v
  compiler repeatedly rediscovers semantic facts while emitting Bytecode
      |
      `-- hard to cache, inspect, transform, or share with another backend

canonical path
  Parser -> Sema -> sealed + verified Typed AST snapshot
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
        VM Bytecode    TypedASTJIT    future AOT/LLVM
             |             |             |
             `------ consume the same resolved semantic facts ------'
```

The useful optimization boundary is the sealed semantic graph. It gives a
pass or backend exact canonical types, declaration identity, overload result,
receiver and argument provenance, single-evaluation nodes, structured control
targets, object layout, and lifetime cleanup. Optimizations can therefore be
implemented once against a verified representation and shared by multiple
consumers, or lowered into a later CFG/SSA IR without reconstructing language
semantics from parser nodes or VM instructions.

The AST should still not be turned into LLVM IR itself. Its role is closer to
Clang's typed AST: preserve source-language semantics, ownership, diagnostics,
and stable identities. A future optimizer should lower selected functions from
the canonical AST into a CFG/SSA representation, then into LLVM IR or another
native backend. This keeps high-level language meaning out of the low-level IR
while allowing standard compiler optimizations where they fit.

## Required benchmark matrix before cutover claims

Run LEGACY and CANONICAL in isolated Engines with the same source bytes,
registered host surface, compiler properties, machine state, and build
configuration. Never benchmark a mode that silently invokes both pipelines as
if it represented either pipeline alone.

Measure at least:

1. Frontend phase latency: lex/parse, declaration Sema, body Sema, layout and
   lifetime finalization, verifier, CodeGen, candidate commit, and optional
   snapshot publication.
2. End-to-end compile latency: cold full module build, rebuild of the same
   source, one-file Hot Reload, multi-module dependency rebuild, and public
   `CompileFunction`.
3. Memory: peak process working set, AST arena allocated/used bytes, detached
   candidate bytes, published snapshot bytes, and post-discard steady state.
4. Backend output: function Bytecode bytes, instruction counts by opcode,
   stack/local size, debug/exception/cleanup metadata bytes, and publication
   count.
5. Runtime: representative microbenchmarks plus project scripts covering calls,
   loops, object/property access, containers, delegates, exceptions, and
   generated lifecycle. Include VM and TypedASTJIT results as separate modes.
6. Product settings: snapshot retain and discard policies separately; debug
   dump disabled; Cache V2 disabled by default. Any future Cache V2 redesign is
   a separate benchmark axis.

Use warm-up iterations, randomized pipeline order, multiple independent runs,
and report at least median and p95 with sample count. Keep raw measurements and
hardware/build metadata. A single automation duration or one successful VM
return is not a performance benchmark.

## Cutover interpretation

Correct semantic authority and failure atomicity are mandatory and cannot be
traded for a benchmark win. Compile latency and retained-snapshot memory may
temporarily carry a measured migration cost, but the project should set an
explicit acceptance budget only after the matrix has a stable baseline. Until
then, the honest statement is:

- runtime performance is expected to be broadly comparable on equivalent
  Bytecode, but is unmeasured;
- compile time and retained memory are currently expected to be worse;
- the new architecture is substantially better positioned for incremental
  compilation, semantic tooling, shared optimization passes, TypedASTJIT, AOT,
  and a possible LLVM backend;
- no numeric speedup or regression percentage is claimed yet.

