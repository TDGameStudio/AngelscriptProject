# Canonical funcdef call ABI gate (2026-08-24)

This attachment records the AST-first and production-backend gate for the
host-registered `funcdef` call path. It is a focused slice of Tasks `5.3`,
`5.9`, `9.5`, `13.2`, and `13.6`; it does not close their broader language
surface.

### Gate card: host funcdef argument and indirect call retain one callable identity

- **OpenSpec task(s):** `5.3`, `5.9`, `9.5`, `13.2`, `13.6`.
- **Source fixture:**

  ```angelscript
  int Double(int X)
  {
      return X + X;
  }

  int Invoke(Callback Cb, int X)
  {
      return Cb(X);
  }

  int F()
  {
      return Invoke(Double, 21);
  }
  ```

  `Callback` is registered by the host as `funcdef int Callback(int)` before
  the module is built through the Canonical pipeline.
- **Canonical fact:** after `Parser -> Sema -> Seal`, the `Invoke` parameter
  `Cb` has canonical `FUNCDEF` type identity `Callback`; the indirect `Cb(X)`
  call resolves to that exact parameter declaration and keeps one `int`
  argument in reverse-formal storage; the outer `Invoke(Double, 21)` call
  resolves the exact `Invoke(Callback,int)` declaration and its `Double`
  argument is an owning callable value compatible with `Callback`, not a
  numeric or untyped declaration reference.
- **AST test:** permanent source-path method
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` as
  `HostFuncdefCallRecordsExactCallableTypeAndIndirectTarget`. It compiles the
  real source through Canonical `Module::Build()` and inspects the retained
  sealed internal context. The permanent assertions inspect node kinds,
  exact canonical types, resolved declarations, and child order without
  inferring them from VM output.
- **AST-red:** the new permanent source-path test failed exactly at the callable
  result contract: `Cb` was a `FUNCDEF Callback` parameter and both call targets
  were resolved, but the sealed `Cb(X)` node had `type=Callback` and was followed
  by `MaterializeTemporary`/`Cleanup` instead of having the funcdef signature's
  `int` result type. Focused result: `0/1`,
  `Saved/Tests/cta-funcdef-call-result-ast-red/20260824_112631_962_b94a9190/RunMetadata.json`.
  The failure proves the VM symptom originates in Sema: CodeGen receives an
  object-like call result and therefore cannot correctly consume the integer
  left by `CallPtr`.
- **AST-green:** `1/1`,
  `Saved/Tests/cta-funcdef-call-authoritative-type-ast-green/20260824_113146_894_3192d1d9/RunMetadata.json`.
  The sealed `Cb(X)` call now resolves to the exact `Callback Cb` parameter,
  keeps `X` as its sole reverse-formal child, and has primitive `int` result
  type. The outer call resolves `Invoke(Callback,int)`, stores `21` in formal
  slot zero and the `Double`-to-`Callback` conversion in slot one. Complete
  `SemaAuthority` regression: `263/263`,
  `Saved/Tests/cta-sema-authority-full-green/20260824_113829_460_c93b3afb/RunMetadata.json`.
- **CodeGen/provenance:** current backend RED is permanent method
  `CanonicalHostFuncdefBuildPublishesCodeGenAndExecutes` in
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`. Fresh reproduction:
  `0/1`,
  `Saved/Tests/cta-funcdef-abi-red-confirm/20260824_112054_787_e1e2f645/RunMetadata.json`.
  `Build()` succeeds and publishes Canonical CodeGen, but `F()` does not return
  `42`. Root cause was two-layered: `ActOnCallExpr` used a funcdef
  parameter's callable handle type as the call result instead of resolving the
  signature return type, and `ActOnCall` then overwrote its explicit result
  type with the callee declaration type. `ResolveCallableResultType` now maps
  a funcdef through `asCRuntimeTypeBridge` to the registered signature's
  return type, while `ActOnCall` preserves the authoritative type supplied by
  Sema. CodeGen consequently consumes the `CallPtr` value register as `int`
  instead of generating owning `Callback` temporary cleanup.
- **Lifecycle:** the focused fix must execute and tear down the owning funcdef
  handle without an exception, leak, double release, or Engine-destroy fault.
  The complete ProductionCodeGen group is the first lifecycle regression;
  broader Frontend/Compiler and Standalone gates follow if the shared standard-
  C++ backend changes. The focused execution and complete ProductionCodeGen
  process both exited normally without exception or Engine-destroy failure.
- **Focused regression:** backend method `1/1`, returning `42`,
  `Saved/Tests/cta-funcdef-call-result-codegen-green/20260824_113231_989_d0da950f/RunMetadata.json`;
  complete `ProductionCodeGen` `73/73`,
  `Saved/Tests/cta-production-codegen-funcdef-full-green/20260824_113928_978_dc931a1c/RunMetadata.json`.
- **Remaining boundary:** this card covers a host-registered funcdef passed as
  a script-call argument and invoked indirectly. It does not close script
  `funcdef` declarations (currently rejected), stored capturing closures,
  delegate object receivers, funcdef return values, Cache V2 funcdef replay,
  or the full Task `9.5` lifetime surface.

### Adjacent Sema-gate hygiene found by the full regression

The first complete `SemaAuthority` run exposed two unrelated operator tests
whose source used a script struct by value in `opEquals(T)` / `opCmp(T)`. That
made an AST-selection test depend on the still-open non-POD script value-object
copying part of Task `9.5`; CodeGen rejected the parameter before the AST
assertion could run. The fixtures now use the standard `const T&in` operator
parameter and assert the corresponding exact stable key. This does not claim
by-value script objects are supported. The operator slice is `8/8` at
`Saved/Tests/cta-sema-operator-key-green/20260824_113746_750_e26e9835/RunMetadata.json`.
