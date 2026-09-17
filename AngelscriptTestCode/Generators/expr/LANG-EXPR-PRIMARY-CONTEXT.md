# LANG-EXPR-PRIMARY-CONTEXT

Author reference for `FExprPrimaryContextGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Context: `INITIALIZER` | `ASSIGNMENT_RHS` | `ASSIGNMENT_LHS` | `ARGUMENT` | `RETURN` | `CONDITION` | `LOOP_CLAUSE` | `SWITCH_SELECTOR` | `INDEX` | `PROPERTY_ACCESSOR`
2. Primary: `INT_LITERAL` | `BOOL_LITERAL` | `ENUM_LITERAL` | `NULL_LITERAL` | `LOCAL_IDENTIFIER` | `CONST_IDENTIFIER` | `REFERENCE_IDENTIFIER` | `SCOPED_CONSTANT` | `SCOPED_ENUM` | `PARENTHESIZED_SCALAR` | `PARENTHESIZED_LVALUE` | `GLOBAL_FUNCTION_CALL` | `METHOD_CALL` | `VALUE_CONSTRUCTOR` | `REFERENCE_CONSTRUCTOR` | `MEMBER_FIELD` | `VIRTUAL_PROPERTY` | `INDEXED_PROPERTY` | `EXPLICIT_NUMERIC_CAST` | `OBJECT_CAST` | `BASE_CAST` | `DERIVED_CAST`

Product ID prefix: `LANG-EXPR-PRIMARY-CONTEXT`. Complete set: 10×22 = 220 cells. Normal-return aggregate = 174. Compile reject = 46 (`IsLegal` false: assignment-lhs requires `bAssignable`, switch-selector requires `bIntegralContext`, index and property-accessor require int family). Runtime fault = 0.

Example: `LANG-EXPR-PRIMARY-CONTEXT-INITIALIZER-INT_LITERAL` → `int EntryLangExprPrimaryContextInitializerIntLiteral()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: `EPrimaryValue`, `PrimaryScope`, `FPrimaryValue`, script `FRefRoot`/`FRefDerived` stand-ins, `MakePrimaryInt`/`MakeRefRoot`/`MakeRefDerived`, `ObservePrimary` overloads, and `PreservePrimary` overloads.

Each non-return entry sets `LocalValue`, `ConstValue`, `ValueObject`, and the reference stand-ins, then uses the primary expression in the requested context. Return context emits a case-qualified `ReturnPrimary_<Entry>()` that returns the primary expression.

Reject assignment-lhs for `null_literal` and `value_constructor` uses `1 = 2;` so the invalid assignment stays in source without a missing-type crash pattern.

`BuildPrimaryExpressionSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Legal cells return the typed-context invariant `1`. `GetExpected` returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration and `SourceOnly` execution. Native `FRefRoot` host fixtures are replaced by script stand-ins for source inspection; host accessor registration is out of scope.
