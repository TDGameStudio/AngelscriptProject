# Wave B: sealed field layout is fail-closed

Date: 2026-08-23  
Worktree: `D:\as-cta`  
Change: `refactor-as-canonical-typed-ast-compiler`

## Decision and invariant

`asCDecl::byteOffset` is a semantic layout fact produced by
`asCSema::LayoutScriptClassFields()` before `asCASTContext::Seal()`. Canonical
CodeGen may consume that sealed fact, but it must not create, cache, or recover a
replacement layout after sealing.

The resulting invariant is:

```text
Parser + Sema
    -> Sema.LayoutScriptClassFields()
    -> sealed AST (each materialized script field has byteOffset >= 0)
    -> CodeGen

missing byteOffset -> asINVALID_DECLARATION / no publication
```

The verifier was subsequently strengthened by the module-aware class-layout
work. The current boundary is stricter: a materialized script field with a
missing or out-of-bounds `byteOffset` fails `asCASTVerify` and `Seal()` with
`asAST_VERIFY_INVALID_CHILD` / `class-field-layout`. CodeGen then sees an
unsealed graph and returns `asAST_VERIFY_UNSEALED_PUBLICATION`. The earlier
CodeGen-local negative remains useful historical RED evidence, but a malformed
layout is no longer allowed to become a sealed snapshot.

This is intentionally stricter than the previous implementation. A structurally
valid AST can still lack a CodeGen-required layout fact; it is then rejected at the
CodeGen boundary rather than silently given a different runtime layout.

## What changed

### Removed a post-seal semantic fallback

`asCCanonicalFunctionEmitter::FindFieldOffset` now accepts only a `VAR` declaration
with `byteOffset >= 0`. It no longer searches a CodeGen-local `fieldOffsets[]` table
when the sealed declaration has no offset.

The now-unneeded `asSCodeGenFieldOffset` type and all of its collection, transport,
and emitter references were removed. This is important: keeping a dormant semantic
table would make future accidental reintroduction of a second layout authority much
easier.

### Made type registration obey the same invariant

`RegisterCanonicalScriptTypes` prevalidates each resolved script field before it
allocates an `asCObjectType`. A missing `byteOffset` returns
`asINVALID_DECLARATION`. The prior branch that aligned fields and assigned
`prop->byteOffset` inside CodeGen has been removed.

Prevalidation occurs before runtime type allocation, so the failure cannot leave a
partially created type that the artifact rollback was not yet tracking.

### Corrected the isolated CodeGen test harness

The production builder already calls `canonicalSema->LayoutScriptClassFields()` in
`asCBuilder::SealCanonicalAST()` before sealing. The Compiler/CanonicalAST isolated
helper and the generated-accessor rename test had manually called `Context.Seal()`
without this phase. The former `fieldOffsets[]` fallback hid that mismatch.

The isolated helper and direct rename fixture now mirror the production order:

```text
ParseScript -> Sema.LayoutScriptClassFields -> Seal -> CodeGen.Generate
```

This changed the script-corpus diagnostic from `lowered=6` to `lowered=8`; the two
additional successes are evidence that the tests now exercise the intended pipeline,
not a temporary CodeGen repair path.

## TDD evidence

New regression:

`GeneratedAccessorRejectsMissingSealedFieldOffset`

It parses a value type with `Stored`, runs `LayoutScriptClassFields`, verifies the
field received an offset, then deliberately changes that fact to `-1` before seal.
At the time of the original Wave B gate the graph remained structurally sealable,
and CodeGen had to return an error without reconstructing local state. The current
verifier contract rejects the same graph earlier, before a consumer can acquire a
sealed snapshot.

Before the production change, the exact test failed as expected:

```text
Totals: total=1 passed=0 failed=1 skipped=0
Error: CodeGen must fail closed when a generated accessor field has no sealed
       byteOffset instead of recovering it from fieldOffsets[].
```

The red run is retained at:

`Saved/Tests/cta-field-offset-red/20260823_011014_579_41a71224/`

During full regression, `GeneratedAccessorPlanSurvivesMethodRename` initially failed.
Root-cause tracing compared it with `asCBuilder::SealCanonicalAST()` and established
that the isolated test had skipped `Sema.LayoutScriptClassFields()`. A narrow
hypothesis test added only that required production phase; the rename test passed.
The negative test was then strengthened to run the same phase first and deliberately
erase the resulting fact. This distinguishes a malformed sealed layout from an
incomplete test setup.

## Final verification

All commands were run from `D:\as-cta` using the project-owned runners.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label cta-field-offset-remove-table-build -TimeoutMs 1800000 -NoXGE
```

Result: **PASS**. Runtime DLL linked.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.IsolatedDifferential.FCanonicalASTIsolatedDifferentialTests.GeneratedAccessorRejectsMissingSealedFieldOffset" `
  -Label cta-field-offset-remove-table-exact -TimeoutMs 600000
```

Result: **1/1 PASS**.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" `
  -Label cta-field-offset-remove-table-canonicalast -TimeoutMs 600000
```

Result: **323/323 PASS**.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" `
  -Label cta-field-offset-remove-table-compiler -TimeoutMs 600000
```

Result: **513/513 PASS**.

The build record is at
`Saved/Build/cta-field-offset-remove-table-build/20260823_012016_808_4172f6ec/`.
The final test summary is at
`Saved/Tests/cta-field-offset-remove-table-compiler/20260823_012157_847_2ba68149/Summary.json`.

## Later verifier-contract alignment (2026-08-24)

The complete CanonicalAST gate exposed that the negative test still expected
the older Seal behavior after `class-field-layout` validation had been added.
The production verifier was correct; relaxing it would have violated the
consumer firewall. The permanent test now asserts all current facts:

- `asCASTVerify` returns `asAST_VERIFY_INVALID_CHILD`;
- detail is exactly `class-field-layout`;
- the offending node is the exact field declaration;
- the named edge is `decl-parent` and the related node is the owning class;
- `Seal()` returns the same structural rejection;
- CodeGen returns `asAST_VERIFY_UNSEALED_PUBLICATION` and cannot recover layout.

Evidence:

- stale-contract reproduction:
  `Saved/Tests/cta-accessor-offset-failure-repro/20260824_234236_023_499f568f`
  — **0/1 PASS** at the old `Seal() == OK` assertion;
- exact aligned gate:
  `Saved/Tests/cta-field-offset-verifier-contract-green/20260824_234827_026_e13f7bee`
  — **1/1 PASS**;
- complete Compiler CanonicalAST gate after the alignment:
  `Saved/Tests/cta-keyed-foreach-canonicalast-green/20260824_234903_919_e1766cc0`
  — **389/389 PASS**.

## Scope truth

This closes the Wave B `fieldOffsets[]` fallback bite and reinforces the existing
sealed generated-accessor identity work. It does not prove that all canonical CodeGen
coverage is complete, nor does it complete atomic publication, snapshot/cache work,
the production default flip, the public AST ABI, or Tasks 4.2, 5.2, 5.4, 5.6, 5.9,
9.1, 9.5, 10.x, 13.2, 13.3, or 13.6. Do not check those boxes from this evidence.
