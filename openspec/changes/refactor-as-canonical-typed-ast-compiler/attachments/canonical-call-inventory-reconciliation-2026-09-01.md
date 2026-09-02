# Canonical remaining-call inventory reconciliation (CTA-S171)

## Scope and outcome

CTA-S171 is a test-and-record reconciliation card for task 5.3. It does not
claim a new production implementation or close 5.3 / 13.2. It strengthens
post-CTA-S170 semantic oracles, converts several previously informal
"remaining" entries into executable characterization gates, and narrows the
authentic open call-family boundary.

The formal OpenSpec count remains **107/136 complete (78.7%)**. Task 5.3 stays
`[ ]`. The remaining task-5.3 call-family inventory is now:

1. `opHndlAssign`;
2. reverse-operator family completeness beyond the existing `opAdd_r` gate.

The following entries are no longer open inventory items:

- implicit converting-constructor execution;
- mixin execution, including omitted defaults and method calls;
- imported-function execution, including named/default argument binding;
- funcdef-variable execution, including a local funcdef initialized from a
  named script function.

## Why this card was characterization-first

CTA-S170 changed an ordinary VALUE-to-reference `opImplConv` call argument
from a generic `Conversion` annotation into the Sema-owned expression that
will actually execute:

```text
MaterializeTemporary(
  Call(receiver=<source object>, callee=T::opImplConv, result=<formal type>))
```

The production behavior was already correct after CTA-S170. Two sibling Sema
tests still asserted the old compatibility `Conversion` shape and therefore
failed only when the wider `SemaAuthority` prefix was run. The first purpose
of CTA-S171 was to distinguish those stale test oracles from a product
regression before adding any implementation.

The other candidate gaps were also tested before implementation. They passed
immediately, so adding production code would have duplicated existing
behavior. Their tests now lock the behavior instead.

## Oracle correction: exact real-Call authentication

The pre-fix four-test reproduction was:

- label: `cta-sema-call-53-implconv-oracle-red`;
- run: `20260901_135850_454_d4aedb99`;
- result: **2/4 PASS, 2/4 FAIL**.

The two failures were:

- `SemaAuthority.ImplConvCall.ValueOpImplConvMakesRefFormalCallViable`;
- `SemaAuthority.TypeIdImplConvCall.TypeIdentifierValueOpImplConvMakesTwoArgCallViable`.

Both dumps contained the correct CTA-S170 `MaterializeTemporary(Call(...))`
shape; only the assertions still required `asAST_EXPR_CONVERSION`. The
corrected tests now authenticate:

- the exact `asSASTCallArgument` formal declaration, ordinal, origin and
  canonical formal type;
- an outer `MaterializeTemporary`;
- an inner ordinary `Call` to the selected `opImplConv` method;
- the exact receiver and result types;
- for the type-identifier case, the exact `__StaticType_CObj` receiver.

The template VALUE path was deliberately not rewritten: its compatibility
conversion remains a distinct, currently valid path, and its existing gate
continues to pass.

Post-fix evidence:

- exact oracle set: `cta-sema-call-53-implconv-oracle-green` /
  `20260901_140103_337_b7ea5cb1`, **4/4 PASS**;
- complete SemaAuthority prefix:
  `cta-sema-call-53-characterization-full` /
  `20260901_140141_107_39780a54`, **528/528 PASS**.

## Converting-constructor execution

`CanonicalImplicitCtorConversionSealsConstructPlan` now gives the converted
object observable state and executes the complete path:

```angelscript
class TConv
{
    int Stored = 0;
    TConv(int A) { Stored = A; }
}

int Consume(TConv Value) { return Value.Stored + 39; }
int Entry() { return Consume(3); }
```

The existing sealed `Construct` plan publishes through Canonical CodeGen,
does not invoke the LEGACY compiler, and returns `42`. This enhancement was
green immediately in the valid class-wide run; it is characterization, not a
newly implemented feature. A first method-level selection matched zero tests
and is intentionally excluded from all evidence counts. The valid execution
result is included in the **528/528** SemaAuthority gate above.

## Mixin and import execution

The following existing production tests were run together:

- `CanonicalMixinOmittedDefaultExecutesWithoutLegacyCompiler`;
- `CanonicalMixinMethodCallBuildsAndExecutes`;
- `CanonicalImportCallBuildPublishesCodeGenAndExecutes`;
- `CanonicalDirectImportOwnsAuthoredDefaultsAndExecutesNamedCall`.

Evidence:

- label: `cta-sema-call-53-mixin-import-inventory-green`;
- run: `20260901_140531_430_64cafb79`;
- result: **4/4 PASS**.

These gates cover execution, Canonical CodeGen publication and the relevant
default/named binding behavior. Mixin/import execute leftovers are therefore
not authentic remaining gaps.

## Funcdef-variable execution

`CanonicalHostFuncdefBuildPublishesCodeGenAndExecutes` was extended with a
local funcdef variable initialized from a named script function:

```angelscript
int InvokeLocal()
{
    Callback Cb = Double;
    return Cb(21);
}
```

The gate executes `InvokeLocal() == 42`, verifies Canonical CodeGen
publication and zero LEGACY compiler invocations, and requires the emitted
bytecode to contain `asBC_CallPtr`. The same test retains its existing
funcdef-parameter execution coverage.

Evidence:

- build: `Saved/Build/cta-sema-call-53-funcdef-local-characterization/`
  `20260901_140646_347_aba60165`, **PASS**;
- exact test: `cta-sema-call-53-funcdef-local-characterization` /
  `20260901_140705_459_d568628a`, **1/1 PASS**.

This was green immediately, so funcdef-variable calls are removed from the
remaining inventory.

## Production `opImplConv` execution lock

The existing VALUE-to-reference production gate was rerun independently:

- label: `cta-sema-call-53-implconv-production-green`;
- run: `20260901_140431_930_405f89d0`;
- result: **1/1 PASS**.

It proves the converted handle rather than the original value slot reaches
the formal, conversion executes once, Canonical CodeGen is the publisher, and
the LEGACY invocation count is zero.

## Final regression gates

- build after the final test changes:
  `Saved/Build/cta-sema-call-53-funcdef-local-characterization/`
  `20260901_140646_347_aba60165`, **PASS**;
- SemaAuthority full prefix:
  `Saved/Tests/cta-sema-call-53-characterization-full/`
  `20260901_140141_107_39780a54`, **528/528 PASS**;
- ProductionCodeGen full prefix, including subgroups such as ScriptCorpus,
  StaticTypeIdentifier and WildcardValueArg:
  `Saved/Tests/cta-sema-call-53-inventory-prodcodegen-full/`
  `20260901_140759_466_f2a66118`, **225/225 PASS**, zero failures/skips;
- plugin `git diff --check`: clean apart from expected Windows line-ending
  notices.

The ProductionCodeGen run logged UE network-connectivity probe timeouts and
some long DDC/ScriptCorpus ticks; every affected test completed successfully,
the harness exit code was zero, and these warnings are not compiler failures.

## Non-claims and next boundary

CTA-S171 does not close any OpenSpec checkbox. In particular it does not prove
the complete 5.3 call/conversion matrix, eliminate all backend `asCCompiler`
reruns, or close the path-A Sema/AST umbrella. The next authentic RED should
target `opHndlAssign`; the reverse-operator mapping should then receive a
family-complete structural/execution matrix rather than extrapolating from the
single `opAdd_r` gate.
