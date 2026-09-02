# UE staged primary compiler canonical publisher gate — 2026-08-24

> Historical RED record. The staged contract described below was subsequently
> implemented and is now green. Current closure evidence is recorded in
> `canonical-provenance-closure-audit-2026-08-24.md`; do not treat the original
> “not yet cut over” wording as current state.

## Outcome

The real Unreal-hosted primary compiler is not yet cut over to canonical
Bytecode generation. Native `asCModule::Build()` and public
`asIScriptModule::CompileFunction()` are canonical when the Engine selects the
CANONICAL pipeline, but `FAngelscriptEngine` uses a separate four-stage batch
orchestration for initial compile and Hot Reload. Its final code stage still
calls `asCBuilder::BuildCompileCode()`, which invokes `asCCompiler`.

This audit reopens Task 13.1 and keeps Tasks 10.1, 10.4, and 13.6 open. It also
explains why the selection enum and native SDK cutover tests cannot by
themselves prove product-path cutover.

```text
native SDK / embedding Build()
  Parser -> Sema -> sealed AST -> asCBytecodeCodeGen -> CANONICAL_CODEGEN

UE primary / Hot Reload batch
  Stage 1 parse + type registration
  Stage 2 function registration
  Stage 3 builder->BuildCompileCode() -> asCCompiler -> COMPILER   <-- RED
  Stage 3 TakeCanonicalAST() -> retained snapshot sidecar
```

## AST-first gate card

- OpenSpec tasks: 0.2, 10.1, 10.4, 13.1, and 13.6.
- Test source:
  `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptPrimaryEngineCanonicalASTGenerateTests.cpp`.
- Test method: `PrimaryInitialCompileUsesCanonicalCodeGenPublisher`.
- Real host fixture: a temporary project `Script/PrimaryCanonicalAST.as`
  containing `int PrimaryCanonicalASTEntry() { return 1; }`, compiled by a
  normal `FAngelscriptEngine` initial compile with Cache V2 disabled and public
  AST retention enabled.
- Required facts: the active module that owns
  `PrimaryCanonicalASTEntry()` reports
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and an exact legacy compiler
  invocation count of zero.
- Why this is an AST-first/provenance gate: the fixture is parsed and a retained
  AST is available already. The failure proves that the retained graph is not
  the source of installed Bytecode, so downstream execution or StaticJIT
  success cannot be counted as canonical compiler evidence.

## RED evidence

- Build PASS:
  `Saved/Build/cta-primary-staged-canonical-publisher-red-build/20260824_203531_160_164b89b1`.
- Focused class group:
  `Saved/Tests/cta-primary-staged-canonical-publisher-red/20260824_203630_082_86afdf24`.
- Result: **9/10 PASS, 1/10 FAIL, 0 skipped**.
- Exact failure: `PrimaryInitialCompileUsesCanonicalCodeGenPublisher` at the
  publisher assertion. All preconditions passed: the engine was created, the
  initial compile succeeded, and the function was found in an active module.

The first attempted method-only prefix omitted CQTest's generated class segment
and therefore matched no tests. It is not used as semantic evidence; the class
prefix run above discovered and executed the permanent method.

## Root cause

`FAngelscriptEngine::CompileModule_Code_Stage3()` currently executes:

```text
ScriptModule->builder->BuildCompileCode()
ScriptModule->AdoptPendingCanonicalAST(builder->TakeCanonicalAST())
ScriptModule->PublishCanonicalASTSnapshot()
```

`BuildCompileCode()` compiles factories and functions through `asCCompiler`.
The snapshot publication protocol is reader-safe, but it pairs a canonical
sidecar with legacy-produced Bytecode. This is a compiler provenance failure,
not a snapshot locking failure.

## Required implementation boundary

The repair must preserve UE's staged cross-module declaration/layout ordering
while making Stage 3 consume the already sealed graph. Calling the existing
detached `asCBytecodeCodeGen::Generate()` directly on the builder-prepared
module is not safe: that API owns declaration/type/function publication and
rejects or duplicates script declarations already installed by Stages 1 and 2.

The next implementation slice therefore needs one explicit staged canonical
backend contract. It must:

1. bind each sealed declaration to the exact builder-prepared Runtime shell;
2. emit function/factory/global-initializer bodies into detached candidate
   state;
3. validate the complete module artifact before replacing any prepared body;
4. commit atomically while preserving existing Runtime IDs, UE descriptors,
   imported-module links, class layout, and build-artifact callbacks;
5. on failure, leave no partially installed body and publish no AST generation;
6. set the module publisher/digest from the exact sealed AST and leave the
   legacy invocation count at zero.

Until this contract is implemented and the gate is green, the production
default is only a canonical *selection flag* on the UE staged route. LEGACY
remains a necessary implementation path, not merely an isolated comparison
option.
