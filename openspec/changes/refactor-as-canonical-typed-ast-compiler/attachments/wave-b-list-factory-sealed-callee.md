# Wave B — list-pattern factory is a sealed canonical callee

Worktree: `D:\as-cta`
Change: `refactor-as-canonical-typed-ast-compiler`
Scope: one Generate-local canonical CodeGen re-lookup from
`wave-b-codegen-remaining.md`.

## Problem

The parser/Sema path correctly represented a brace initializer such as
`FSemaListBox Box = {1, 2}` as a structured `Construct` expression with
`literal=list-pattern`, but `ActOnAssign` only retagged its result type. Its
`resolvedDecl` remained empty. `EmitListFactoryInto` then reselected
`objectType->beh.listFactory` directly from the Engine. That made emitted
bytecode depend on a behaviour-table lookup absent from the sealed AST.

The pre-change sealed dump contained the decisive evidence:

```text
EXPR ... kind=Construct type=FSemaListBox literal=list-pattern callee= nargs=2 ...
```

## Canonical fact and lowering

1. `asCSema::InternNativeListFactoryForType` materializes exactly the registered
   native list factory as a constructor declaration beneath the canonical type
   declaration.
2. That declaration carries `asAST_TRAIT_LIST_FACTORY`. This semantic identity
   prevents a same-shaped ordinary constructor or ordinary factory from being
   mistaken for the list factory.
3. When a list-pattern `Construct` receives its assignment type,
   `ActOnAssign` writes that declaration to `Construct.resolvedDecl`.
4. `FindExactRegisteredListFactory` binds only declarations with that trait and
   checks exact owner, name, parameter types/reference directions, and the
   Engine's single registered `beh.listFactory` id. Ordinary constructor
   binding explicitly excludes this trait.
5. `EmitListFactoryInto` first resolves `FindFunc(expr->resolvedDecl)`. It
   fails with `asNO_FUNCTION` if the AST fact is missing/unbound, or if the
   resulting function no longer equals the target type's registered list
   factory. The remaining type lookup is a validation/ABI lookup (element
   layout and list-buffer cleanup), not a second callee selection.

This keeps the runtime bridge as the narrow native ABI validator while making
the chosen operation an immutable AST fact.

## TDD evidence

The semantic authority test was first strengthened to demand a non-empty list
factory callee on the exact structured list-pattern node. After rebuilding the
test module, it failed as intended:

- RED: `Saved/Tests/cta-list-factory-sealed-callee-red-live/20260823_030959_151_ac6d519b`
  — `1 total, 0 passed, 1 failed`; dump shows `callee=` empty.

After the implementation:

- Build: `Saved/Build/cta-list-factory-sealed-callee-green-build/20260823_031331_063_02aff427`
  — succeeded. The only warnings were the pre-existing fixture C5038/C4191
  warnings.
- Sema authority: `Saved/Tests/cta-list-factory-sealed-callee-sema-green/20260823_031405_072_66ef3c63`
  — `1/1 PASS`.
- Real canonical bytecode/execution:
  `Saved/Tests/cta-list-factory-sealed-callee-codegen-green/20260823_031446_777_a09174ed`
  — `1/1 PASS`. It builds through canonical CodeGen, executes `Box.Marker + 1`
  as `42`, and verifies the emitted bytecode calls the registered list-factory
  function id.
- Canonical CodeGen regression bucket:
  `Saved/Tests/cta-list-factory-sealed-callee-production-codegen/20260823_031643_708_54c332d8`
  — `53/53 PASS`, `0 failed`, `0 skipped`.
- Compiler regression bucket:
  `Saved/Tests/cta-list-factory-sealed-callee-compiler/20260823_031720_020_ab6e09c7`
  — `518/518 PASS`, `0 failed`, `0 skipped`.

The completion review additionally aligned the empty registered-function-name
fallback with Sema's type-name fallback. Fresh verification of the final source
revision is:

- Build: `Saved/Build/cta-list-factory-sealed-callee-fallback-name-build/20260823_031932_518_c6f82f63`
  — succeeded.
- Exact semantic authority test:
  `Saved/Tests/cta-list-factory-sealed-callee-fallback-name-sema/20260823_031945_751_2252e339`
  — `1/1 PASS`.
- ProductionCodeGen regression bucket:
  `Saved/Tests/cta-list-factory-sealed-callee-fallback-name-production/20260823_032020_834_67bf67ae`
  — `53/53 PASS`, `0 failed`, `0 skipped`.
- Compiler regression bucket:
  `Saved/Tests/cta-list-factory-sealed-callee-fallback-name-compiler/20260823_032056_449_66f34afa`
  — `518/518 PASS`, `0 failed`, `0 skipped`.

## Deliberate non-claims

- This closes only the list-factory callee re-lookup. It does **not** complete
  Tasks 5.2, 5.3, 5.9, 9.5, 13.2, or the section-10 cutover gates.
- `LEGACY` remains the default compiler pipeline. The test selects canonical
  explicitly.
- This does not serialize list-factory plans for Cache V2, remove parser-node
  Sema traversal, or provide full source-level overload/conversion/lifetime
  authority.
- No ordinary constructors/factories, container list patterns, or JIT routes
  were broadened beyond the existing canonical subset.
