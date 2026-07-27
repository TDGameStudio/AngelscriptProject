# Constructors and Object Initialization

## Dimensions

| Axis | Values |
| --- | --- |
| Object kind | script struct/value object, script class/reference object, base class, derived class, registered native value/reference fixture where relevant |
| Constructor kind | implicit/default, explicit declared default, parameterized, overloaded, copy, conversion, generated/deleted future-2.38 target |
| Arity/type | 0, 1, 2, representative many × primitive/value/reference parameter categories |
| Call form | local declaration, direct temporary, field/member initialization, return construction, argument construction, base call, copy declaration, assignment |
| Selection | exact, promotion, explicit cast, implicit conversion rejected, ambiguous, missing, inaccessible |
| Visibility | public/default, protected, private × owner/derived/unrelated call site |
| Initialization order | base, declaration-order first/middle/last fields, constructor body; flat, one-level nested, deep-nested, and base/derived-extra-member topologies |
| Failure point | before base, base body, member N, derived body, copy, conversion, argument evaluation |
| Observation | field values, selected marker, construct/copy/assign/destruct counters, published metadata, exception, cleanup, context reuse |

## Required products

- `Object kind × constructor kind × call form` for every legal combination.
- `Fifteen value parameter families × arity(one/two/five/sixteen) × exact/promotion/explicit-conversion/ambiguous/missing selection` with exact overload identity, argument order, runtime marker, located rejection, partial cleanup, and recovery.
- `Visibility × call site × object relation` including derived base-constructor calls.
- `Four real base + first/middle/last member + derived-body topologies × failure point × values/event-order/cleanup/context-reuse observation` with exact initialized-prefix cleanup in reverse order. No cell names a base/member/derived failure point that is absent from its topology.
- `Fourteen coherent value/reference source-and-route scenarios × eight local/field/argument/return/self/chained transfer workflows × four identity/value/mutation/lifecycle observations` proving value independence or reference alias semantics. Temporary and return routes have their own retained/expired-source assertions rather than pretending that a destroyed temporary can be mutated.
- `Explicitness × invocation form(direct/copy-init/argument/return) × conversion availability`.
- Sixteen explicit current-fork special-member scenarios × compile/metadata/runtime/lifecycle observation cover implicit/declared default, the fork-configured preservation of a generated default beside a parameterized constructor, the raw-SDK option-off suppression boundary, implicit/declared copy and assignment, user destructor interaction, class factories, derived generated/default-super behavior, the option-off missing-base-default rejection, copy after a user constructor, and self-assignment stability. Desired 2.38 generated/deleted special members remain separate Disabled cases.
- Sixteen singular declaration/base-call/recursion/retained-object boundaries × compile-or-execution/diagnostic-or-metadata/lifecycle/recovery-or-teardown observation. This owns malformed declarations, invalid `super` placement and resolution, direct/indirect recursive value layouts and runtime construction, plus module/engine teardown while a reference object is retained.

## Product ownership and scale

| Product ID | Cases | Purpose |
| --- | ---: | --- |
| `LANG-CTOR-KIND-CALL` | 288 | Six object kinds × six constructor kinds × eight call forms |
| `LANG-CTOR-TRANSFER` | 448 | Fourteen coherent source-and-route scenarios × eight transfer workflows × four observations |
| `LANG-CTOR-BOUNDARY` | 64 | Sixteen singular declaration/base-call/recursion/teardown scenarios × four observations |
| `LANG-CTOR-VISIBILITY` | 72 | Visibility/site/selection behavior and rejection |
| `LANG-CTOR-PARAM-SELECT` | 300 | Fifteen parameter families × four nonzero arities × five selection modes |
| `LANG-CTOR-SPECIAL-POLICY` | 64 | Sixteen current-fork special-member scenarios × four evidence observations |
| `LANG-CTOR-ORDER-FAILURE` | 128 | Four complete object topologies × failure point × value/order/cleanup/reuse observation |

The seven active constructor products contain 1,364 expected cases. Unsupported object/kind/call or type/selection cells are not silently skipped: they must own a located current-fork rejection and clean recovery. The selected-2.38 generated/deleted policy is counted only in the compiled Disabled product.

## Boundaries and invalid forms

No matching constructor, ambiguous conversions, private/protected access, deleted/missing default, invalid base call order, repeated base call, constructor return value, malformed declaration, recursive construction, partial initialization exception, self-assignment, and engine/module teardown with live instances are required.

## Planned ownership

- `Language/Constructors/AngelscriptNativeConstructorSelectionTests.cpp`
- `Language/Constructors/AngelscriptNativeConstructorTransferTests.cpp`
- `Language/Constructors/AngelscriptNativeConstructorBoundaryTests.cpp`
- `Language/Constructors/AngelscriptNativeConstructorVisibilityTests.cpp`
- `Language/Constructors/AngelscriptNativeConstructorParameterTests.cpp`
- `Language/Constructors/AngelscriptNativeConstructorPolicyTests.cpp`
- `Language/Constructors/AngelscriptNativeConstructorFailureTests.cpp`
- future behavior remains in `Conformance` with the 2.38 tag.
