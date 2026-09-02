# CTA-S89 registered method exact Runtime identity gate — 2026-08-30

## Outcome

CTA-S89 closes the confirmed reachable registered-native method binding defect
where Canonical Sema selected one receiver-qualified method declaration but
Canonical CodeGen could not relocate it to a unique Runtime function.

The concrete production case was:

```angelscript
int Read() const; // registered first, poison result 0
int Read();       // selected for a mutable receiver, result 42

int F()
{
    FBindBox b;
    return b.Read();
}
```

Sema correctly sealed the mutable `FBindBox::Read()` declaration. The old
`FindExactRegisteredMethod` implementation nevertheless ignored
`asCScriptFunction::IsReadOnly()` and compared return/parameter datatypes
through only token, type-info, reference and handle shape. Both Runtime
methods therefore survived the relocation filter, uniqueness failed, and the
module rejected publication with `missing callable relocation`.

The resolver now authenticates the complete direct native ABI:

1. exact receiver readonly state;
2. exact full return `asCDataType`;
3. exact full parameter `asCDataType` after any required template
   specialization;
4. exact parameter and `inOutFlags` vector lengths;
5. exact `in`, `out`, `inout`, or `none` entry for every formal.

This remains a registered native/system-function route. It deliberately does
not call `NormalizeScriptParameterABI`, which belongs only to matching script
source formals against normalized script Runtime shells.

## Production change

`as_bytecode_codegen.cpp::FindExactRegisteredMethod` now rejects a Runtime
candidate unless all of the following hold:

```text
Runtime method name == sealed Canonical method name
Runtime parameter count == sealed exact formal count
Runtime passing-vector count == sealed exact formal count
Runtime IsReadOnly == Canonical CONST_METHOD trait
specialized Runtime return datatype == sealed Canonical return datatype
specialized Runtime parameter datatype[N] == sealed Canonical formal datatype[N]
Runtime inOutFlags[N] == sealed Canonical formal passing[N]
```

Existing resolution policy is otherwise unchanged:

- generated Canonical methods do not enter the registered-native resolver;
- concrete template-instance methods remain preferred over their base-template
  candidates;
- inherited/base method search remains in place;
- duplicate Runtime IDs are still de-duplicated;
- multiple equally exact distinct candidates still fail closed.

## TDD evidence

### Valid RED

Test:

`CanonicalNativeConstAndMutableMemberExecutesReceiverQualifiedSelection`

Run:

`Saved/Tests/cta-s89-registered-method-readonly-red/20260830_115805_070_dbfb41f6`

Result:

```text
total=1 passed=0 failed=1 skipped=0
Canonical CodeGen failed code=-6:
missing callable relocation function=F()
targetKind=9 targetName=Read targetKey=FBindBox::Read()
```

This is a valid semantic RED:

- both native methods registered successfully;
- Parser and Canonical Sema completed;
- the diagnostic identifies the exact mutable sealed target key;
- failure occurred at registered method Runtime relocation;
- no fixture, engine-startup, compile or link error caused the failure.

### Focused GREEN

First focused repair run:

`Saved/Tests/cta-s89-registered-method-readonly-green/20260830_115941_674_f397da59`

Final post-cleanup focused run:

`Saved/Tests/cta-s89-registered-method-exact-final/20260830_120402_938_fca8c453`

Both are:

```text
total=1 passed=1 failed=0 skipped=0
```

The test additionally proves that:

- the module publisher is `CANONICAL_CODEGEN`;
- execution returns the mutable callback value `42`;
- published bytecode calls the mutable Runtime function ID;
- published bytecode does not call the const poison Runtime function ID.

### Build evidence

Pre-RED test build:

`Saved/Build/cta-s89-registered-method-readonly-red-build/20260830_115745_340_5847673d`

Repair build:

`Saved/Build/cta-s89-registered-method-readonly-green-build/20260830_115927_848_211b38ae`

Final source-state build after removing the invalid exploratory fixture:

`Saved/Build/cta-s89-registered-method-exact-final-build/20260830_120344_870_9b9183f1`

All three builds completed successfully through `Tools/RunBuild.ps1`.

### ProductionCodeGen regression gate

Run:

`Saved/Tests/cta-s89-production-codegen-method-exact-green/20260830_120022_332_67afe253`

Result:

```text
total=155 passed=155 failed=0 skipped=0
```

This covers the existing registered method, inherited/template method,
constructor, factory/list-factory, native call and CodeGen transaction-facing
fixtures in the ProductionCodeGen prefix. The count increased from CTA-S88's
154 to 155 because CTA-S89 adds one retained production test.

### Broad Compiler + TypedASTJIT + NativeBridge gate

Run:

`Saved/Tests/cta-s89-compiler-typedjit-nativebridge-full-green/20260830_120545_345_e809f82e`

Result:

```text
total=720 passed=720 failed=0 skipped=0
```

The count increased from CTA-S88's 719 to 720 only because of the retained
CTA-S89 test. HTTP connectivity timeouts reported as warnings by several
fixtures are environmental warnings; Automation and the runner both exited
zero, with no failed or skipped test.

## Excluded exploratory failure

An exploratory test registered these two global functions before Sema:

```angelscript
int HostRead(const FBindBox&in value);
int HostRead(FBindBox&in value);
```

The resulting run was:

`Saved/Tests/cta-s89-registered-global-parameter-const-red/20260830_120223_503_4ec16cdf`

It failed with `ambiguous-overload` and `unresolved-callee:HostRead` during
Canonical Sema, before CodeGen relocation. This is not a valid resolver RED
and is not counted as implementation evidence. The exploratory callbacks and
test were removed completely; the final build and focused GREEN were run only
after that cleanup.

The failure is still useful as a test-design constraint: a registered-global
resolver test for complete datatype identity must either use a naturally
Sema-distinguishable signature or seal the unique Canonical declaration before
injecting an additional Runtime-only candidate. It must not treat a source-
language ambiguous overload as a CodeGen defect.

## Remaining registered resolver scope

CTA-S89 closes only the confirmed registered-method production bug. These
resolvers remain statically coarse and need independent reachable TDD evidence
before behavior is changed:

- `FindRegisteredGlobalFunction`;
- `FindExactRegisteredConstructor`;
- `FindExactRegisteredListFactory`.

The required contract is still full datatype plus exact passing-vector
identity, but constructors and factories also own hidden Runtime prefixes.
Their tests and repair must preserve:

- `hiddenArgumentIndex` semantics;
- template TypeInfo prefixes;
- constructor-versus-factory source/Runtime representation differences;
- generated per-instance factory preference;
- list-pattern ownership.

The previous same-arity `bool`/`int` tests prove basic overload selection, but
they do not prove const-handle, datatype qualifier or `asTM_NONE` identity.
Those remaining routes are therefore not claimed complete.

## Scope and non-claims

- CTA-S89 does not switch the product default from LEGACY to CANONICAL.
- CTA-S89 does not remove the original native AngelScript parser AST.
- CTA-S89 does not reintroduce HIR.
- CTA-S89 does not close default-argument projection or ownership.
- CTA-S89 does not close generation-local TypedASTJIT type-binding
  authentication.
- Standalone remains explicitly deferred by user scope.
- The OpenSpec formal task count remains `102/136`; this slice is evidence
  under still-open family-wide CodeGen/cutover rows.

After the final evidence write,
`openspec validate refactor-as-canonical-typed-ast-compiler --strict` passed.
Parent and plugin `git diff --check` both exited zero; their only output was
the repository's existing LF-to-CRLF checkout warnings.
