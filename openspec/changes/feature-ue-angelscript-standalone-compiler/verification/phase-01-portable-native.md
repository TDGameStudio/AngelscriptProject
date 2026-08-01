# Phase 01 portable fork and native runtime

Status: passed after the Compat-first minimization and V1 closeout. Current
counts, hashes, and external-consumer evidence are in
`v1-closeout-20260801.md`.

The maintained fork retains its UE-spelled containers, memory, atomics,
settings, and engine calls. The CMake-only `Standalone/Compat` include tree and
target-owned translation units provide the bounded non-UE implementation; the
fork has no standalone macro or public host-service table. CMake selects the
authoritative source files and maximum-portability mode; it does not keep a
copied compiler.

The native profile provides UTF-8 string, array, dictionary, math, print, and
assert with counted allocation and deadline/cancellation handling. It exposes
no file, network, process, dynamic-library, or arbitrary FFI API. Only the two
documented `main` signatures execute.

Historical phase evidence (superseded for final counts by the closeout):

- `AngelscriptStandalone.Smoke`, `SemanticObserver`, `Addons`, `Cli`,
  `CliEndToEnd`, `Runtime`, `Corpus`, and `Soak` passed within the then-current
  Standalone suite;
- tracked allocations return to zero after normal, failure, limit, and repeated
  engine shutdown;
- CLI exit/result/output replacement and deterministic compile/save-load
  assertions pass;
- active Native SDK prefix: `691/691`, report
  `Saved/Tests/native-core-release-fixed_01_AngelScriptSDK/20260731_085432_611_39d80b31`;
- final UE build after contract changes: succeeded at
  `Saved/Build/standalone-resource-parameter-contract/20260731_090809_936_e3ca1f61`.

The counted in-process memory/deadline controls are documented as
defense-in-depth limits, not as an operating-system sandbox.
