# Wave B: sealed generated-accessor field identity

Date: 2026-08-23

## Problem

`EnsureGeneratedAccessors` synthesized `Get<Field>` / `Set<Field>` declarations, but did
not record which field each declaration represented. `asCBytecodeCodeGen::EmitGeneratedAccessor`
then re-derived that relationship by inspecting the `Get` / `Set` spelling, stripping
the prefix, and scanning the parent type's fields for a matching name.

That is semantic re-analysis after `asCASTContext::Seal()`: CodeGen depended on a
presentation convention and a later AST refactor could silently emit the wrong accessor.

## Implemented sealed fact

`asCDecl` now carries only the compact identity required by CodeGen:

```text
accessorKind  = None | Get | Set
accessorField = asASTDeclId
```

The internal construction API `asCASTContext::SetGeneratedAccessor` writes that fact
before sealing. Sema sets it when it synthesizes a getter or setter. This is a
maintained-fork construction API; it changes neither `asIScriptModule` nor the public
AST V1 ABI.

The verifier now rejects malformed accessor facts before seal publication:

- an accessor field without an accessor kind;
- an unknown kind;
- a non-generated/non-method accessor declaration;
- a missing, non-field, or different-owner field;
- a getter whose return type or parameter count does not match the field; and
- a setter that is not `void` with exactly one field-typed parameter.

`asCASTDump` renders the relationship in its existing address-free declaration line as
`accessor=Get:<Field>#<id>` or `accessor=Set:<Field>#<id>`. A dangling internal graph is
rendered as `<dangling>#<id>` so verifier failures remain diagnosable without a pointer
dump.

`EmitGeneratedAccessor` now consumes `accessorKind` and `accessorField` directly. It
still enumerates the setter's declared parameter to find its local slot; that is a direct
child relation, not name-based semantic lookup. The old `Get`/`Set` prefix and
field-name recovery loop is removed.

## Regression coverage

Two tests were written before the production implementation.

1. `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` now requires the retained sealed
   AST dump to contain both getter and setter identity facts.
2. `GeneratedAccessorPlanSurvivesMethodRename` parses a small value type through Sema,
   renames only the synthesized accessors to `ReadStored` and `WriteStored` before
   sealing, and requires CodeGen to install both methods with `RDR4` / `WRTV4` bodies.
   The former name-driven CodeGen necessarily failed because neither name began with
   `Get` or `Set`.

The rename test intentionally leaves each declaration's stable key unchanged. It proves
the accessor-body decision consumes the sealed field relation rather than the display
name; it does not claim arbitrary user-facing method renames are a source-language
transformation supported today.

## Verification

The standard build initially exposed a current-worktree compile blocker:
`AngelscriptNativeTypedSemanticIRExpressionOrderTests.cpp` used `AS_NATIVE_PRODUCT` and
`ENativeEvidence` without including their defining
`AngelscriptNativeCaseTestSupport.h`. The same test family includes that support header;
adding the missing include restored the intended build without changing test behavior.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label cta-accessor-plan-green-build -TimeoutMs 1800000 -NoXGE
```

Result: **PASS** (Runtime and Test DLLs linked).

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.GeneratedAccessorsHaveGeneratedTraitAndCallPlan" `
  -Label cta-accessor-dump-green -TimeoutMs 600000
```

Result: **1/1 PASS**.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.IsolatedDifferential.FCanonicalASTIsolatedDifferentialTests.GeneratedAccessorPlanSurvivesMethodRename" `
  -Label cta-accessor-rename-green -TimeoutMs 600000
```

Result: **1/1 PASS**.

CQTest's registered Automation path includes the C++ test class between its directory
and method. A prefix ending directly at the method, or a `+`-joined pair of such
prefixes, matches no test. For narrow verification, obtain the full path from an
existing report's `fullTestPath` and run one exact path at a time.

The relevant regression prefixes also stayed green after both new test definitions were
linked:

```text
Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST : 322/322 PASS
Angelscript.TestModule.AngelScriptSDK.Compiler              : 512/512 PASS
```

## Scope truth

This is one Wave B CodeGen semantic-identity closure. It does **not** complete the
canonical compiler migration, detached/atomic installation, public AST ABI correction,
snapshot publication concurrency, Cache V2 DTO work, or the remaining CodeGen control
flow and language coverage. Do not use this green result to check Tasks 4.2, 5.2, 5.4,
5.6, 5.9, 9.1, 9.5, 10.x, 13.2, 13.3, or 13.6.
