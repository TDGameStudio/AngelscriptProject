# LANG-INH-CLASS-RULE

Author reference for `FInhClassRuleGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Scenario: `ABSTRACT_CLASS_KEYWORD_REJECTED` | `FINAL_CLASS_KEYWORD_REJECTED` | `CONCRETE_BASE_INHERIT` | `CONCRETE_INSTANTIATE` | `FINAL_METHOD_OVERRIDE` | `FINAL_METHOD_INHERIT` | `INVALID_BASE_NAME` | `INVALID_BASE_KIND` | `DUPLICATE_BASE` | `INHERITANCE_CYCLE_DIRECT` | `INHERITANCE_CYCLE_INDIRECT` | `IMPLICIT_OVERRIDE_WITHOUT_KEYWORD` | `EXACT_OVERRIDE` | `OVERRIDE_WITHOUT_BASE` | `RETURN_TYPE_MISMATCH` | `DEEP_OVERRIDE`
2. Observation: `COMPILE` | `DIAGNOSTIC` | `METADATA` | `RUNTIME`

Product ID prefix: `LANG-INH-CLASS-RULE`. Complete set: 16×4 = 64 cells. Normal-return aggregate = 24. Compile reject = 40. Runtime fault = 0.

Example: `LANG-INH-CLASS-RULE-CONCRETE_INSTANTIATE-RUNTIME` → `int EntryLangInhClassRuleConcreteInstantiateRuntime()`.

## Source branches

Accepted scenarios emit unique `FRule*` types and `Object.Value()`. Reject scenarios keep the illegal keyword, missing base, cycle, duplicate base, override-without-base, or return-type mismatch. Observation does not change the source body.

Accepted oracles: concrete_base_inherit 31, concrete_instantiate 41, final_method_inherit 61, implicit_override 122, exact_override 132, deep_override 163.

`BuildInheritanceRuleSource` is positive-only.
