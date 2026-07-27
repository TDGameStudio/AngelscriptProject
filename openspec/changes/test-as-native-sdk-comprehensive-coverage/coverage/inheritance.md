# Inheritance and Dispatch

## Dimensions

| Axis | Values |
| --- | --- |
| Depth | base only, base+derived, three levels, representative deep chain, invalid cycle |
| Member kind | field, non-virtual method, virtual method, override, ordinary getter/setter methods, constructor, destructor |
| View/call site | derived object, base-typed view, explicit base call, owner, derived implementation, unrelated caller |
| Dispatch | non-virtual static target, virtual most-derived, explicit base bypass, missing override, signature mismatch |
| Access | default/public, protected, private × member kind × call site |
| Class rule | concrete inheritance, active method-level `final`/`override`, raw-core rejection of disabled class-level `abstract`/`final`, invalid base, duplicate base, and cycles |
| Type relation | exact, upcast, downcast success, downcast failure/null, sibling cast, null |
| Lifecycle | base/member/derived construction and destruction, exception at each layer, copy/assignment through views |

## Required products

- `Depth × view × virtual dispatch target` for method and virtual-property paths.
- `Access × member kind × call site` with positive and rejection cells.
- `Current raw-core class-modifier boundary × concrete inheritance/method-final/override/base/cycle action`; class-level `abstract`/`final` desired semantics remain selected-2.38 Disabled.
- `Type relation × cast form × runtime object kind` with identity/null outcomes.
- `Depth × constructor/destructor phase × exception point` with exact order and cleanup.
- `Override signature dimension(parameter, return, constness, access) × outcome(exact, overload-not-override, invalid)`.
- Sixteen concrete raw class-modifier rejection, concrete inheritance, method-final, implicit/exact/deep override, invalid-base, cycle, and signature-mismatch scenarios × compile/diagnostic/metadata/runtime observation.
- Parameter type/count, return type, constness, visibility, and name hiding × exact/compatible-overload/incompatible variant × base/derived/explicit-base view.

The getter/setter rows mean ordinary explicit `GetX`/`SetX` methods. They do not reintroduce the removed script `property` decorator or virtual-property block syntax.

## Product ownership and scale

| Product ID | Cases | Purpose |
| --- | ---: | --- |
| `LANG-INH-DISPATCH` | 360 | Four depths × six member forms × five views × three invocation routes |
| `LANG-INH-ACCESS` | 60 | Default/protected/private × field/method/getter-setter/constructor × five sites |
| `LANG-INH-CAST` | 60 | Six runtime relations × mutable/const × five use sites |
| `LANG-INH-CLASS-RULE` | 64 | Sixteen current raw-core class-modifier/method/base/cycle/override scenarios × four observations |
| `LANG-INH-OVERRIDE-SIGNATURE` | 54 | Six signature dimensions × three variants × three views |

The five inheritance products contain 598 expected cases. `direct`, `virtual_route`, and `explicit_base` are invocation routes whose expected target depends on the member form; they are not predeclared outcomes multiplied over fields and non-virtual methods.

## Boundaries and interactions

Empty base, hidden overload, explicit base call inside override, inherited fields, field shadowing where allowed, ordinary getter/setter override, calling virtual behavior during construction/destruction, module rebuild, metadata relationship, invalid cycles, unsupported multiple inheritance, and script-interface rejection are required or explicitly classified.

## Current raw-core class-modifier boundary

The vendored parser and builder deliberately comment out the standard pre-class `abstract`/`final` modifier path. The UE preprocessing layer can carry separate class metadata, but this native SDK suite does not route raw-core tests through that wrapper. Active `LANG-INH-CLASS-RULE` cases therefore pin the located raw parser rejection and the still-enabled method-level `final`/`override` behavior. Desired 2.38 `abstract class` and `final class` parse, compile, metadata, runtime, and cleanup assertions are compiled only in the Disabled `V238-DESIRED-BEHAVIOR` owner with `#as-v238-backport`.

## Planned ownership

- `Language/Inheritance/AngelscriptNativeInheritanceDispatchTests.cpp`
- `Language/Inheritance/AngelscriptNativeInheritanceAccessTests.cpp`
- `Language/Inheritance/AngelscriptNativeInheritanceCastTests.cpp`
- `Language/Inheritance/AngelscriptNativeInheritanceRuleTests.cpp`
- `Language/Inheritance/AngelscriptNativeOverrideSignatureTests.cpp`
