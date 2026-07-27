# Automatic References, Aliasing, and Null

## Fork boundary

The suite tests this fork's automatic-reference semantics as current behavior. Explicit `@` handle syntax remains an enabled fork-rejection contract unless and until selectively changed. Add-on weakref behavior is excluded; the core weak-reference flag/API is covered only where exposed by core script objects.

## Dimensions

| Axis | Values |
| --- | --- |
| Object source | new/local object, field, parameter, return, base view, derived view, native registered object, null |
| Operation | initialize, assign/rebind, pass, return, compare identity, compare null, cast, field/member access, mutation through alias |
| Direction | value/default automatic reference, `&in`, `&out`, `&inout`, return reference where legal |
| Qualifier | mutable, const object/view, const reference input, invalid const removal |
| Alias relation | same object/two names, distinct objects, self-assignment, base+derived views, out replacement, inout mutation |
| Lifetime | owner live, owner scope exit, returned alias, module retained/discarded, context retained/released, GC cycle/release where core semantics apply |
| Null state | null creation, assignment, comparison, pass, return, member access, cast, out initialization |
| Resolution | exact reference overload, const overload, value-vs-ref overload, conversion/cast, ambiguous, incompatible |

## Required products

- `Object source × operation(assign/pass/return/compare/access)` for legal cells.
- `Direction × qualifier × argument source(lvalue/const lvalue/temporary/null)` as a complete constrained product.
- `Alias relation × mutation site × observation alias` proving shared identity or independent value behavior.
- `Null state × operation` with successful null-safe operations and exact null-access exceptions.
- `Base/derived runtime kind × view × cast direction` with success, null/failure, dispatch, and identity.
- `Lifetime state × retained alias × operation` with construction/refcount/weak flag/GC or exact invalid-lifetime diagnostics.
- `Reference overload dimension × conversion availability × outcome`.
- Ten concrete overload candidate sets × eight mutable/const/temporary/field/parameter/base/derived/null sources × direct/helper call site, with exact selection or owning diagnostic.
- Ten singular invalid-reference boundaries × fresh/same-state recovery so explicit handles, const removal, temporary out, expired return, unrelated assignment/cast, null access, stale module objects, ambiguous overloads, and incompatible inout are never hidden inside broad positive products.

## Product ownership and scale

| Product ID | Cases | Purpose |
| --- | ---: | --- |
| `LANG-REF-SOURCE-OP` | 288 | Eight sources × nine operations × four qualifiers |
| `LANG-REF-DIRECTION` | 96 | Four directions × six alias relations × four null states |
| `LANG-REF-LIFETIME` | 200 | Eight owner states × five reference states × five observations |
| `LANG-REF-RESOLUTION` | 160 | Ten candidate sets × eight sources × direct/helper sites |
| `LANG-REF-FAILURE` | 20 | Ten singular failures × fresh/same-state recovery |

The five reference products contain 764 expected cases. Automatic-reference behavior is the active fork contract; explicit `@` syntax remains a negative row. Weak observations use core weak-reference flags/APIs only and do not import add-on weakref behavior.

## Negative coverage

Explicit handle syntax, incompatible object assignment, const removal, invalid temporary/out binding, returned reference to expired local, unrelated cast, null member access, stale object after module/context teardown, and ambiguous reference overloads each require singular expectations.

## Planned ownership

- `Language/References/AngelscriptNativeReferenceIdentityTests.cpp`
- `Language/References/AngelscriptNativeReferenceDirectionTests.cpp`
- `Language/References/AngelscriptNativeReferenceLifetimeTests.cpp`
- `Language/References/AngelscriptNativeReferenceResolutionTests.cpp`
- `Language/References/AngelscriptNativeReferenceFailureTests.cpp`
