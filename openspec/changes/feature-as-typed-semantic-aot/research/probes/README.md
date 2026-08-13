# Semantic AOT source and runtime probes

These probes are lightweight drift sentinels for evidence used by this OpenSpec
change. They do not replace compiler, VM, StaticJIT, or UE Automation tests.

Run from the repository root:

```powershell
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-FunctionTraitSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-ExternalImplicitThisRuntime.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-SemanticDependencyContract.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-SemanticExecutionSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-SemanticExceptionCleanupSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-SemanticExceptionCleanupContract.ps1
```

`Test-FunctionTraitSourceEvidence.ps1` checks the maintained fork rather than
assuming upstream AngelScript behavior. In particular, it proves the current
source still gives `external_implicit_this` the following shape:

- the declaration is a global function;
- declared parameter `0` is retained as an ordinary call/VM ABI argument;
- compiler body lookup aliases parameter `0` as the effective receiver;
- literal-asset lowering explicitly passes the asset object to that parameter;
- the existing asset regression uses unqualified property access in the body.
- every `asEFuncTrait` currently declared by the fork has one policy row in
  `function-traits-and-effective-receiver.md`, with no stale extra row.

If this probe fails after a compiler-fork update, inspect the source and update
the semantic model deliberately. Do not make the regex accept a changed shape
until the HIR, interpreter fallback, StaticJIT entry plan, and tests agree on the
new contract.

`Test-ExternalImplicitThisRuntime.ps1` executes
`external-implicit-this-native.as` through the already-built Standalone host.
It checks current compiler/VM behavior without Unreal Engine:

- the global function is called with its receiver as ordinary argument `0`;
- the named parameter remains readable inside the callee;
- unqualified property and method lookup resolve against the same receiver;
- property mutation is visible on the caller's object.

The script intentionally constructs the script object with
`Receiver Target = Receiver();`. In the current native profile, a bare
`Receiver Target;` is a null reference and would make this a fixture-lifetime
failure instead of a receiver-semantics test. Use `-KeepArtifacts` when the
Standalone result JSON or bytecode is needed for inspection.

`Test-SemanticDependencyContract.ps1` is a network-free synthetic contract
probe. It does not inspect bytecode or claim production implementation. It
proves the planned reconciliation and v1 eligibility decisions with virtual
stable keys:

- a folded global constant requires `HardValue`, while a mutable global
  requires `GlobalStorage`;
- every HIR semantic use must be covered, but extra authoritative compiler
  dependencies remain preserved;
- dependency coverage and backend eligibility are separate checks;
- mutable global storage and global initializer bodies remain v1 fallback;
- imported slots need a route that reads the current binding rather than a
  frozen `boundFunctionId`;
- visibility of a shared/external declaration does not imply body ownership.

`Test-SemanticExecutionSourceEvidence.ps1` is a network-free maintained-source
drift sentinel for execution and control-flow assumptions. Its 28 assertions
verify that:

- JIT execution uses `FScriptExecution` with no active VM context;
- `asGetActiveFunction()` uses a separate thread-local field that system-call
  scopes set/restore, rather than automatically reading the active JIT function;
- nested JIT dispatch occurs before the VM-only recursion guard;
- VM `asBC_SUSPEND` drives line/loop callbacks while Legacy StaticJIT currently
  implements that bytecode as a no-op;
- Legacy debug frames preserve position but line callbacks drive DebugServer,
  CodeCoverage, and the game-thread-only callback path independently;
- `for`, `while`, and `do-while` continue destinations retain their distinct
  phase order, and break/continue emit exited-scope destructors;
- switch selector normalization/default/exhaustive-enum exception behavior is
  still present;
- assignment/compound/postfix mutation order and the maintained power-operator
  boundary have not drifted.

If it fails after a maintained-fork change, update the HIR, execution-profile
eligibility, emitter, differential tests, and
`execution-observability-and-control-flow.md` together. Do not weaken a pattern
merely to preserve the previous assertion count.

`Test-SemanticExceptionCleanupSourceEvidence.ps1` checks the maintained VM,
Legacy StaticJIT, Runtime bridge, and current language tests together. It
proves that VM contexts retain rich exception metadata while `FScriptExecution`
currently retains only a flag, dynamic JIT-to-VM calls do not adopt the inner
payload, live-object cleanup depends on before/after-operation state, Legacy
exception cleanup currently emits forward declaration order while VM unwinding
uses reverse order, and the current source language still rejects
try/catch/rethrow despite dormant try-region plumbing in the fork. The proposed
reverse-order source/test edit is retained only in the research patch attachment.

`Test-SemanticExceptionCleanupContract.ps1` is a network-free virtual contract
probe. It proves first-failure-wins behavior, immediate suppression of later
effects, no duplicate reporting during VM-bridge adoption, reverse cleanup of
only constructed/live slots, preservation of the primary exception during a
cleanup failure, and exactly-once destruction. It does not claim the Runtime
already has the proposed structured failure record or lifetime HIR.
