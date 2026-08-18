# Task 2.7 capture and archive parity

This attachment records the authoritative task-2.7 boundary, TDD failures,
repairs, and verification evidence. It intentionally distinguishes current
Cache V2 artifacts from the removed `PrecompiledScript*.Cache` protocol.

## Current persistence boundary

The original task text named `PrecompiledScript.Cache`, but current production
code no longer opens or writes that format:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
  states that Cache V2 starts from authoritative source or a validated Cache V2
  generation and that legacy `PrecompiledScript*.Cache` files are never opened;
- `Plugins/Angelscript/README.md` records that StaticJIT no longer uses the
  paired `PrecompiledScript.Cache` protocol;
- a source search has no production path naming `PrecompiledScript.Cache`;
- current Cache V2 clean capture serializes individual functions through
  `asCWriter::WriteFunctionArtifact()` in
  `Cache/AngelscriptCacheCleanCapture.cpp`;
- `FAngelscriptPrecompiledData` remains a StaticJIT/BytecodeJIT support model,
  not a live `PrecompiledScript.Cache` file reader/writer.

Task 2.7 and the normative spec therefore test the real current surfaces:
`SaveByteCode`, Cache V2 function artifacts, and bytecode-only restore. The
legacy filename remains a negative no-reader/no-writer/no-migration/no-dual-
write boundary; the test does not recreate obsolete production behavior.

## Test ownership

Two capability-owned translation units were added beneath
`AngelScriptSDK/Compiler/TypedSemanticIR/`:

- `AngelscriptNativeTypedSemanticIRCaptureParityTests.cpp` owns capture-on/off
  function-set, normalized bytecode, line/section/dependency metadata,
  traits/signature, VM and compile-out parity. Its source graph contains real
  external-implicit-this, mixin, default, hidden and compile-out fixtures.
- `AngelscriptNativeTypedSemanticIRArchiveIsolationTests.cpp` owns exact
  `SaveByteCode` and Cache V2 function-artifact equality, bytecode-only restore,
  absent restored HIR and restored VM behavior.

Each file contains one test method. This keeps the two independently
diagnosable observable capabilities separate and follows the AST JIT test
partition rule without creating a generic catch-all file.

## TDD failure: implicit default construction had no HIR initializer

The first valid capture-parity RED was:

```text
Saved/Tests/typed-semantic-task27-capture-parity-diagnostic/
  20260816_221700_508_6db5c741
0/1 PASS
local initializer capture is not owned by the current function:
  local=Counter expression=4294967295 expressionArena=0
```

The same source compiled, its capture-on/off bytecode and metadata already
matched, and VM compilation was valid. `CompileVariableDecl()` called the
authoritative no-node `CompileInitialization()` path for `FParityCounter
Counter;`; that path emitted the default constructor bytecode directly and had
no `asCExprContext` expression to transfer. `AddLocalDeclaration()` then
correctly rejected the invalid expression ID.

The repair does not synthesize a value and does not weaken verification. Only
the real no-node, non-handle, non-funcdef object-default-construction path now
attaches the existing typed `Unsupported/ConstructionOrLifetime` marker. The
original `CallDefaultConstructor()` and all VM bytecode remain authoritative.
An independent representable probe in the parity fixture requires capture-off
to own no HIR and capture-on to publish HIR containing this implicit lifetime
boundary.

## Scope correction: parity is not premature call-rewrite completion

The complex parity entry also contains call semantics assigned to tasks
2.10-2.14. Requiring that whole entry to publish complete HIR in task 2.7 was a
test overreach: the normative task-2.7 contract is non-interference, while
later tasks own external receiver, mixin/formal mapping, hidden/default origin,
compile-out rewrite and evaluation order. The complex entry therefore proves
bytecode/metadata/VM equality and safe fallback today; the independent probe
proves capture is genuinely enabled. Later focused tasks must remove the
entry's generic unsupported disposition through their own RED/GREEN coverage,
not by weakening this parity test.

## TDD failure: unequal module identities polluted the archive baseline

The first archive run failed exact `SaveByteCode` equality:

```text
Saved/Tests/typed-semantic-task27-archive-isolation-green/
  20260816_222441_469_3ed5f201
0/1 PASS
SaveByteCode bytes must be identical because HIR is not serialized
```

The capture-off and capture-on fixtures used different module/source-section
names (`...ArchiveOff` and `...ArchiveOn`). Debug section metadata is an
ordinary serialized input, so these were not equivalent archive baselines.
Both Engines are already isolated; using the same stable module identity was
the single-variable correction. No serializer code changed.

## Focused GREEN evidence

```text
Build, maintained-fork default-construction repair:
  Saved/Build/typed-semantic-task27-default-construction-green/
    20260816_222111_130_cbfe5f22
  PASS, 4/4 actions

Build, final parity boundary:
  Saved/Build/typed-semantic-task27-parity-boundary-build/
    20260816_222337_094_6c9c0e7a
  PASS, 4/4 actions

Capture parity:
  Saved/Tests/typed-semantic-task27-capture-parity-green-02/
    20260816_222356_473_8e3eddba
  1/1 PASS

Build, equivalent archive identity:
  Saved/Build/typed-semantic-task27-archive-equivalent-identity-build/
    20260816_222541_410_f28ecb7f
  PASS, 4/4 actions

Archive isolation:
  Saved/Tests/typed-semantic-task27-archive-isolation-equivalent-identity/
    20260816_222558_636_8163e349
  1/1 PASS

Complete compiler-HIR regression:
  Saved/Tests/typed-semantic-task27-full-green/
    20260816_222836_812_8b7864c0
  41/41 PASS, zero failed/skipped
```

The focused and complete compiler-HIR gates are GREEN. Strict OpenSpec
validation is the final record-integrity check for this task checkpoint.
