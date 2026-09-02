# Canonical Build Provenance Audit — 2026-08-23

## Why this audit exists

The prior cutover tests established only the final value of
`asCModule::GetLastBytecodePublisher()`.  That value alone is not sufficient
evidence that a `CANONICAL` selected source build stayed out of the legacy
backend: a future regression could invoke `asCCompiler`, then overwrite the
final publisher value when `asCBytecodeCodeGen` commits.

This audit adds a fork-internal, module-scoped provenance observation point.
It deliberately does **not** change the public AngelScript ABI.

```
source-compile request
        |
        +-- reset module.legacyCompilerInvocationCount
        |
        +-- any asCCompiler construction
        |       `-- RecordLegacyCompilerInvocation()
        |
        `-- test reads count + final publisher

CANONICAL Build:  publisher = CANONICAL_CODEGEN, legacy count = 0
LEGACY Build:     publisher = COMPILER,          legacy count > 0
```

The counter is reset at both public source-compilation entries:

- `asCModule::Build()`;
- `asCModule::CompileFunction()`.

It therefore reports the current request rather than an earlier build of the
same module.  `asCCompiler` records through its owning `asCBuilder::module` at
construction.  It observes the legacy semantic/Bytecode backend itself; it
does **not** mistake Parser recovery nodes or an `asCBuilder` used by canonical
CodeGen for an old compiler invocation.

The existing read-only `asCBytecodeCodeGenDumpModule()` output now includes the
same observation:

```text
module=<name> functions=<count> publisher=<0|1|2> legacyCompilerInvocations=<n>
```

This makes the signal usable while debugging a real module without having to
recreate the test-only assertion. It is a provenance aid, not a new execution
route and not a public ABI surface.

## Sealed-AST content fingerprint (second audit pass)

The publisher/count pair answers *which* backend most recently published, but
not whether the canonical graph inspected by a debugger is the graph that
reached the successful CodeGen commit. A backend could otherwise retain or
report a stale snapshot and still display `publisher=CANONICAL_CODEGEN` and
`legacyCompilerInvocations=0`.

The fork now records a module-private `canonicalAstDigest` only after
`asCBytecodeCodeGen::Generate()` has successfully committed its artifact. The
value is FNV-1a over `asCASTDump()` of the sealed canonical context. That dump
is address-free, so the observation does not expose AST pointers and can be
recomputed by a test or diagnostic consumer.

```text
Build selected as CANONICAL
        |
        v
  parse / sema / SealCanonicalAST
        |
        +---- retained sealed AST C --------------------+
        |                                               |
        v                                               v
  CodeGen.Generate(C) -> artifact.Commit() -> digest(C) -> module dump
                                                      |
                                                      +-- publisher=CANONICAL_CODEGEN
                                                      +-- legacyCompilerInvocations=0
                                                      `-- canonicalAstDigest=<digest(C)>
```

The ordering is intentional:

- a failed `Generate()` does **not** leave a digest that claims a publication;
- `InternalReset()`, `CompileFunction()`, and every non-canonical publisher
  clear the field, so an older canonical build cannot masquerade as the
  current request;
- this is fork-internal transient diagnostic state. It neither changes the
  public AngelScript ABI nor replaces Cache V2's canonical content identity,
  validation, or persistence keys.

`asCBytecodeCodeGenDumpModule()` therefore ends its summary line with either
`canonicalAstDigest=<16 lowercase hex digits>` for a successfully committed
canonical module or `canonicalAstDigest=<none>` for legacy/failed/no-current
canonical publication.

### Regression proof

`FCanonicalASTCutoverTests.CanonicalRetainedBuildDumpBindsPublisherToSealedSnapshot`
selects the canonical pipeline, builds a value-object fixture, independently
recomputes FNV-1a from the sealed retained context, and requires an exact
`canonicalAstDigest=%016llx` token in the module dump alongside the existing
canonical publisher / zero legacy-invocation assertions.

The test was first run before the digest implementation. It failed exactly
because the dump contained only:

```text
module=CanonicalDigest functions=5 publisher=2 legacyCompilerInvocations=0
```

and lacked the independently computed digest token. After the implementation,
the focused test and both affected regression groups passed:

| Scope | Command / label | Result |
|---|---|---|
| Focused red proof | `Tools\\RunTests.ps1 -TestPrefix "...Cutover.FCanonicalASTCutoverTests.CanonicalRetainedBuildDumpBindsPublisherToSealedSnapshot" -Label cta-canonical-ast-digest-red` | `1/1` expected failure: digest token absent |
| Focused green proof | same prefix, label `cta-canonical-ast-digest-green` | `1/1` passed |
| Cutover group | `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label cta-canonical-ast-digest-cutover` | `7/7` passed |
| Production CodeGen group | `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label cta-canonical-production-codegen-digest` | `56/56` passed |

The immediate post-change build was also invoked through `Tools\\RunBuild.ps1`.
An outer tool time limit interrupted its initial broad dependency fan-out; a
subsequent project-runner build with label `cta-canonical-ast-digest-green-rerun`
reported the target up to date, and the two fresh editor test processes above
loaded and executed the new assertion. The timeout is not counted as a clean
full rebuild result.

## Readiness contract corrected

`asCScriptEngine::IsCanonicalBytecodeCodeGenReady()` used to return `true`
unconditionally merely because the canonical backend is compiled into the
fork.  That created an incorrect external signal on the default LEGACY engine
and made isolated `asCBytecodeCodeGen::Generate()` unit tests appear like a
production pipeline selection.

The method now means:

| Engine selection | `IsCanonicalBytecodeCodeGenReady()` | Meaning |
|---|---:|---|
| `LEGACY` (the default) | `false` | The engine will not route a source Build to canonical CodeGen. |
| `CANONICAL` | `true` | A source Build is allowed to enter sealed-AST CodeGen; unsupported graphs must still fail before publication. |

Direct CodeGen unit tests remain valid, but must leave a LEGACY-selected Engine
with `Ready() == false`.  The Standalone canonical-AST test now explicitly
selects `CANONICAL` before its source builds.

## Tests added/updated

- `FCanonicalASTCutoverTests.CanonicalBuildProvenanceExcludesLegacyCompiler`
  builds the same simple function in isolated CANONICAL and LEGACY engines. It
  asserts the publisher and the actual backend invocation count for both
  cases.
- `FCanonicalASTCutoverTests.DefaultPipelineIsLegacyReadyIsFalseAndRejectsDual`
  locks the default/selection readiness state machine.
- CodeGen transaction tests assert that isolated `Generate()` does not alter
  engine selection readiness.
- The Standalone canonical-AST CTest performs an explicit selection and then
  exercises source builds.

## Fresh verification evidence

| Scope | Command / label | Result |
|---|---|---|
| UE incremental build after provenance API | `Tools\\RunBuild.ps1 -Label cta-canonical-provenance-build -NoXGE` | `166/166` actions, exit `0` |
| UE incremental build after readiness callers | `Tools\\RunBuild.ps1 -Label cta-canonical-provenance-ready-build -NoXGE` | `4/4` actions, exit `0` |
| UE incremental build after dump provenance | `Tools\\RunBuild.ps1 -Label cta-canonical-provenance-dump-build -NoXGE` | `7/7` actions, exit `0` |
| Cutover automated tests | `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label cta-canonical-provenance-cutover` | `6/6` passed, no skips/failures |
| Cutover tests with dump assertions | `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label cta-canonical-provenance-dump-green` | `6/6` passed, no skips/failures |
| CodeGen transaction tests | `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label cta-canonical-ready-transaction-green` | `12/12` passed, no skips/failures |
| Standalone Debug | `Tools\\RunTestSuite.ps1 -Suite Standalone -LabelPrefix cta-canonical-provenance-standalone` | `21/21` CTests passed |

The initially attempted transaction prefix omitted the registered `.CodeGen.`
segment and matched no automation tests.  No source/test assertion failed; the
correct registered prefix above was then run and is the only result counted as
verification.

## Honest status against the OpenSpec

This closes an evidence gap relevant to review blocker **13.1** and cutover
matrix **10.1**, but does not complete either task:

- It proves the currently covered CANONICAL `Build()` route does not silently
  invoke `asCCompiler` for the covered input.
- It does not prove every production input form is semantically represented by
  the canonical graph.
- `CompileFunction` remains a deliberately documented legacy single-function
  route. Its counter/reset makes that residual visible; it is not reclassified
  as canonical.
- Remaining blockers include canonical Sema authority (13.2), stable complete
  declaration identity (13.3), source-model end-to-end routing (13.10), full
  Cache DTO/remap fidelity (13.9), and the unsupported body/lifecycle/metadata
  portions of Bytecode CodeGen (9.5/9.6).

Accordingly, the checkbox state in `tasks.md` remains unchanged.  This audit
is a guardrail for the next migration increments, not a declaration that the
legacy AST can now be removed.
