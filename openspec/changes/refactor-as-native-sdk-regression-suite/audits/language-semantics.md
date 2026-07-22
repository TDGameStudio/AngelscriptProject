# Core Language Semantics

This test inventory answers a different question from the implementation/class/interface inventories: can scripts use the core language correctly? It excludes all `sdk/add_on` libraries. `Active fork` is authoritative now; `Active compatible` is shared with the pinned 2.38 reference; `Future 2.38` uses `TEST_CLASS_WITH_FLAGS_AND_TAGS`, `EAutomationTestFlags::Disabled`, and `TEXT("#as-v238-backport")`; `Reject by design` actively asserts the fork diagnostic.

## Language test themes and files

The `Language` domain is split by user-visible behavior, not by implementation class and not by a generic “coverage” file name.

| Test file | Positive runtime/compile behavior | Negative/error behavior | Boundary |
| --- | --- | --- | --- |
| `Language/AngelscriptNativeDeclarationsTests.cpp` | function/class/method/property/namespace/enum/typedef/funcdef/import declaration forms | malformed/duplicate/illegal declaration diagnostics | detailed parser tree shape stays in Frontend; metadata enumeration stays in TypeSystem/Module |
| `Language/AngelscriptNativeFunctionsTests.cpp` | global/method calls, return values, overloads, default/named args, recursion, funcdef call, mixin global function | missing/ambiguous overload, wrong args/return, invalid recursion/declaration | native registration/calling convention stays in Embedding |
| `Language/AngelscriptNativeVariablesTests.cpp` | local declaration, inference, initialization, const, shadowing, scope lifetime, const globals | use-before-declare, invalid initialization, const mutation | mutable-global fork rejection stays in Conformance |
| `Language/AngelscriptNativePropertiesTests.cpp` | class fields, initializer values/order, read/write, inherited fields, virtual `get_`/`set_` properties | inaccessible, readonly/writeonly, invalid accessor signature | UE `UPROPERTY` is not core and stays outside this suite |
| `Language/AngelscriptNativeConstructorsTests.cpp` | implicit/default, parameterized, overloaded, copy construction and assignment, base/member construction order | no matching/ambiguous/private/failed constructor diagnostics | desired 2.38 default-copy/member-init changes stay Disabled in Conformance |
| `Language/AngelscriptNativeDestructorsTests.cpp` | cleanup on block exit, return, exception, reverse local/member destruction order | inaccessible/invalid destructor declaration where applicable | native object behavior registration stays in Embedding |
| `Language/AngelscriptNativeInheritanceTests.cpp` | base construction, inherited members, override, virtual dispatch, base calls, abstract implementation | invalid final/abstract/override/access behavior | native-interface registration stays in Embedding; script-interface rejection stays in Conformance |
| `Language/AngelscriptNativeReferencesTests.cpp` | fork automatic references, assignment, parameter/return, identity, null, implicit/explicit reference cast | null access exception, incompatible assignment/cast | explicit `@` rejection stays in Conformance |
| `Language/AngelscriptNativeExpressionsTests.cpp` | precedence/associativity, literals, member/index/call chains, ternary, named arguments | invalid lvalue, unresolved member/name, malformed expression | parser-only AST details stay in Frontend |
| `Language/AngelscriptNativeOperatorsTests.cpp` | unary/binary arithmetic, bit/logical/comparison, short circuit, compound assignment, inc/dec, overload dispatch | invalid operands/signatures and ambiguous overload | numeric ABI calls stay in Embedding |
| `Language/AngelscriptNativeConversionsTests.cpp` | integer widths, signed/unsigned, float/double, bool, explicit cast, object/reference conversions | invalid/ambiguous/narrowing boundaries as defined by the fork | desired 2.38 bool-context behavior stays Disabled in Conformance |
| `Language/AngelscriptNativeControlFlowTests.cpp` | if/else, ternary statement use, while/do/for, switch/case/default/fallthrough, break/continue/return | invalid break/continue/return/case and duplicate-case diagnostics | context state remains Runtime-owned |
| `Language/AngelscriptNativeForeachTests.cpp` | selectively backported `foreach` with `opFor*`, nesting, break/continue and observable iteration | missing/invalid `opFor*` contract diagnostics | parser/compiler internals remain Frontend/Compiler-owned |
| `Language/AngelscriptNativeExceptionsTests.cpp` | script/host exceptions, text, source location, call stack, cleanup, suspend/resume/abort as language-visible outcomes | invalid exception/control-state transitions | detailed context API methods remain Runtime-owned |

Cross-domain language support is deliberately not duplicated:

- `Module` owns sections, namespace lookup across sections, imports/binding, and save/load execution.
- `TypeSystem` owns enum/typedef/funcdef/object/function metadata and relationships.
- `Frontend` owns tokenizer/parser/script-node internal behavior and diagnostic recovery.
- `Compiler` owns builder/compiler/expression-state/bytecode internals.
- `Embedding` owns host registration, callbacks, string factory, JIT, native interfaces, and calling conventions.
- `Conformance` owns strict fork divergences and compiled-disabled 2.38 expectations.

## Theme depth gate

The existing plugin `Coverage/` suite demonstrates the required depth: it separates independent behavior, exercises representative type/value partitions, combines interacting features where resolution changes, verifies runtime state instead of compilation alone, and records unsupported boundaries explicitly. The native core suite adopts those principles without copying the `Coverage` filename convention or its UE/add-on scope.

Every language theme must close all applicable dimensions below. A theme is not complete merely because its file exists or one smoke case passes.

| Depth dimension | Completion evidence |
| --- | --- |
| Grammar/declaration | representative valid forms compile; malformed, duplicate, misplaced, or incomplete forms produce stable error categories |
| Resolution/type checking | overload/member/namespace/type resolution covers unambiguous success, missing target, ambiguity, access, constness, and incompatible types where applicable |
| Runtime execution | every behavior that can run on the raw engine executes and asserts a return value, mutated state, dispatch target, lifetime event, exception, or context state |
| Type/value partitions | signed/unsigned widths, float/double/bool, value/reference/object/null, zero/one/boundary values, and const/mutable forms are selected when they change semantics; redundant Cartesian products are not required |
| Interaction cases | feature combinations are added where one feature changes another's resolution or lifetime, such as overload+conversion, inheritance+property access, constructor+member initializer, or exception+destruction |
| Lifecycle/state | construction, copy/assignment, destruction, scope exit, context reuse, module discard, and cleanup are asserted for themes that own state |
| Negative/error behavior | invalid syntax/type/state calls assert result code plus stable diagnostic category/text fragment; “either outcome” assertions are forbidden |
| Fork/upstream classification | current fork behavior is enabled and singular; selected future 2.38 behavior is a separate Disabled/tagged class; structural non-applicability is documented |
| Isolation | the case owns engine/module/context/registration/message state and proves cleanup through RAII or an explicit postcondition |

Theme-specific minimum depth:

- **Declarations:** each declaration family has valid, duplicate/conflict, incomplete/malformed, namespace/access, and source-location behavior. Parser-only tree tests do not replace module build/metadata checks.
- **Functions:** global and method calls, overload/default/named args, recursion, by-value/reference directions, return categories, call resolution failures, and observable dispatch are covered.
- **Variables:** primitive/object/reference locals, initialization/inference, constness, shadowing/nested scopes, lifetime, const globals, limits, and invalid access/mutation are covered.
- **Properties:** primitive/object/reference fields, default/member initialization, read/write/const/access control, inherited fields, virtual getter/setter resolution, runtime mutation, and invalid accessor shapes are covered.
- **Constructors:** implicit/default, parameterized, overload selection/conversion, base/member order, explicit copy/assignment/self-assignment, exception/failure cleanup, inaccessible/deleted/ambiguous cases, and strict current fork defaults are covered.
- **Destructors:** normal block exit, early return, nested/reverse order, member/base order, exception unwind, copied objects, and module/context cleanup boundaries are covered where supported.
- **Inheritance:** single/multi-level base construction, inherited state, override/virtual dispatch through base and derived views, explicit base call, abstract/final/access rules, and invalid override signatures are covered.
- **References:** automatic reference assignment/pass/return, aliasing/identity, null creation/comparison/access exception, object/ref casts, constness, lifetime/weak flag integration, and explicit-handle rejection linkage are covered.
- **Expressions:** precedence/associativity, unary/binary/ternary, member/index/call chains, lvalue/rvalue/const behavior, short circuit, source ranges, and malformed/unresolved expressions are covered.
- **Operators:** arithmetic/bit/logical/comparison/assignment/inc-dec and overload dispatch cover representative types, boundaries, compound effects, invalid operands/signatures, ambiguity, and evaluation order.
- **Conversions:** widening/narrowing, signed/unsigned, float/double, bool, explicit/implicit, object/reference, overload interaction, boundary/overflow semantics, invalid/ambiguous conversions, and the separate future bool-context target are covered.
- **ControlFlow:** all branch/loop/switch forms cover zero/one/many iterations, nested break/continue/return, fallthrough/default, condition conversions, unreachable/invalid placement diagnostics, and observable results.
- **Foreach:** empty/one/many elements, nested loops, break/continue, value/reference iteration if supported, `opFor*` resolution/order, mutation/lifetime, and missing/invalid protocol diagnostics are covered.
- **Exceptions:** script and translated host exceptions, message/function/section/row/column/callstack, nested calls, cleanup/unwind, context reuse, suspend/resume/abort transitions, callbacks, and invalid state transitions are covered.

The complete audit checks that each listed dimension has at least one named owner method or an explicit “not applicable to this theme” rationale. It does not infer sufficiency from test count alone.

## Conformance test themes and files

| Test file | Classification | Required intent |
| --- | --- | --- |
| `Conformance/AngelscriptNativeGlobalSemanticsTests.cpp` | Active fork | const globals succeed; mutable globals fail with one stable diagnostic contract |
| `Conformance/AngelscriptNativeReferenceSemanticsTests.cpp` | Active fork | automatic references/null behavior succeed; explicit `@` syntax fails by design |
| `Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp` | Active fork | script `interface` is rejected; native interface registration is linked to Embedding tests |
| `Conformance/AngelscriptNativeMixinSemanticsTests.cpp` | Active fork | mixin global functions succeed; `mixin class` is rejected |
| `Conformance/AngelscriptNativeUsingNamespace238Tests.cpp` | Future 2.38 | Disabled/tagged desired namespace lookup assertions |
| `Conformance/AngelscriptNativeMemberInitialization238Tests.cpp` | Future 2.38 | Disabled/tagged desired member initialization modes/order |
| `Conformance/AngelscriptNativeDefaultSpecialMembers238Tests.cpp` | Future 2.38 | Disabled/tagged desired generated/deleted default and copy special-member behavior |
| `Conformance/AngelscriptNativeBoolContext238Tests.cpp` | Future 2.38 | Disabled/tagged desired bool-context conversion resolution |
| `Conformance/AngelscriptNativeLambda238Tests.cpp` | Future 2.38 | Disabled/tagged desired anonymous-function compile/invoke behavior; active parser-shape coverage stays in Frontend |
| `Conformance/AngelscriptNativeVariadicFunction238Tests.cpp` | Future 2.38 | Disabled/tagged desired zero/multiple trailing-argument execution |
| `Conformance/AngelscriptNativeTemplateFunction238Tests.cpp` | Future 2.38 | Disabled/tagged desired two-type instantiation and overload resolution |

| Domain | Core scenarios | Classification | Planned owner |
| --- | --- | --- | --- |
| Source and tokens | identifiers, keywords, decimal/hex numbers, integer/float/double suffixes, strings/chars, escapes, operators, comments, whitespace, BOM, EOF, malformed tokens | Active compatible + fork diagnostic details | Frontend/Tokenizer |
| Declarations | functions, parameters, default arguments, classes, fields, methods, namespaces, enums, typedefs, funcdefs, imports, virtual properties | Active compatible | Frontend/Parser + Language/Declarations |
| Variables | local declaration/inference/init, const locals, const globals, shadowing, scope lifetime | Active fork | Language/Variables + TypeSystem/VariableScope |
| Mutable script globals | declaration and mutation | Reject by design | Conformance/ForkGlobalSemantics |
| Functions | overloads, named/default args, recursion, return values/references, method calls, function traits | Active compatible/fork reference rules | Language/Functions |
| Class properties | primitive/object fields, initialization order, const/read/write access, inherited fields, virtual `get_`/`set_` properties | Active fork | Language/Properties |
| Default construction | implicit/default constructor, field initializer execution, local object construction | Active fork | Language/Constructors |
| Parameterized construction | overloaded constructors, argument conversions, construction failure diagnostics | Active fork | Language/Constructors |
| Copy construction/assignment | explicit copy path, self-assignment, property copy, current fork default-copy behavior | Active fork; selected 2.38 special-member target separate | Language/Constructors + Conformance/DefaultSpecialMembers238 |
| Destruction | block exit, return/exception cleanup, reverse local lifetime, object property cleanup | Active fork | Language/Destructors |
| Inheritance | base construction, inherited fields/methods, override, virtual dispatch, base calls, abstract/final restrictions | Active fork | Language/Inheritance |
| Script `interface` | declaration/implementation | Reject by design | Conformance/ForkInterfaces |
| Native interface contract | register interface/method, type relationship and call contract | Active fork | Embedding/Interfaces |
| Automatic references | object assignment/passing/return/null behavior without `@` | Active fork | Language/References |
| Explicit `@` handles | token/declaration use | Reject by design | Conformance/ForkReferences |
| Object identity/null | equality/inequality, null assignment/access exception, aliasing | Active fork | Language/References + Runtime/ScriptObject |
| Member access | fields, methods, virtual properties, namespace resolution, index/member chains | Active compatible/fork object model | Language/Expressions |
| Arithmetic | unary/binary integer and floating math, precedence, compound assignment, increment/decrement | Active compatible | Language/Operators |
| Bit/logical/comparison | bitwise shifts/and/or/xor, boolean short-circuit, comparisons, ternary | Active compatible | Language/Operators |
| Operator overloads | supported class/value operators and invalid signature diagnostics | Active fork | Language/Operators |
| Conversions | numeric, bool context, explicit cast, reference/object conversions, ambiguous conversion diagnostics | Active fork; selected bool-context 2.38 target separate | Language/Conversions + Conformance/BoolContext238 |
| Branching | `if`/`else`, ternary, nested branches | Active compatible | Language/ControlFlow |
| Loops | `while`, `do while`, classic `for`, nested break/continue | Active compatible | Language/ControlFlow |
| `foreach` | fork's selectively backported `opFor*` lowering and diagnostics | Active fork/selective 2.38 | Language/Foreach |
| Switch | cases/default/fallthrough/break, enum/integer selectors, duplicate-case diagnostics | Active compatible | Language/ControlFlow |
| Exceptions/runtime stops | null access, divide/error where applicable, host exception, script exception text/callstack, suspend, abort | Active fork | Runtime/Context + Language/Exceptions |
| Namespaces | declarations, qualification, nested lookup, default namespace embedding | Active compatible | Module/Namespaces + Language/Declarations |
| Imports | declaration, source module binding/unbinding, execution, missing/ambiguous imports | Active compatible/fork module storage | Module/Imports |
| Enums | declaration/values/expressions/lookup, enum description cleanup regression | Active fork | TypeSystem/Enums + Compiler/BuilderDiagnostics |
| Typedefs | declaration, underlying primitive, overload/type identity and diagnostics | Active compatible | TypeSystem/Typedefs |
| Funcdefs/delegates | declaration, signature identity, assignment/invocation/null, native registration | Active fork | TypeSystem/Funcdefs + Language/Functions |
| Mixin global functions | declaration and call | Active fork | Language/Functions |
| `mixin class` | declaration | Reject by design | Conformance/ForkMixins |
| Module sections | multiple sections, order, duplicate declarations, source coordinates | Active compatible/fork diagnostics | Module/Sections |
| Shared/external declarations | cross-module identity, compatible declaration binding/execution, incompatible duplicate rejection | Active compatible | Module/Sections + Language/Declarations |
| Try/catch/rethrow | handler selection, nested propagation, rethrow metadata, destructor unwind, uncaught context state | Active compatible | Language/Exceptions + Runtime/ContextException |
| Explicit constructors | direct construction succeeds; implicit conversion is rejected | Active compatible | Language/Constructors |
| `property` keyword and indexed properties | getter/setter/index resolution, side effects, const and malformed accessor diagnostics | Active compatible | Language/Properties |
| Bytecode persistence | save/load then execute equivalent function/object behavior | Active fork layout | Module/SaveLoad |
| Metadata/reflection | function/type/property enumeration, declaration strings, access masks and user data | Active compatible/fork flags | Embedding/Metadata + TypeSystem |
| 2.38 using namespace | desired parse/lookup behavior | Future 2.38 | Conformance/UsingNamespace238 (`#as-v238-backport`) |
| 2.38 member initialization modes | desired initializer/copy ordering | Future 2.38 | Conformance/MemberInitialization238 (`#as-v238-backport`) |
| 2.38 default/copy special members | desired generated and deleted special-member behavior | Future 2.38 | Conformance/DefaultSpecialMembers238 (`#as-v238-backport`) |
| 2.38 bool context conversion | desired conversion resolution | Future 2.38 | Conformance/BoolContext238 (`#as-v238-backport`) |
| anonymous-function execution | desired compile/invoke behavior beyond the current parser shape | Future 2.38 | Conformance/Lambda238 (`#as-v238-backport`) |
| variadic script functions | desired zero/multiple trailing-argument calls | Future 2.38 | Conformance/VariadicFunction238 (`#as-v238-backport`) |
| function templates | desired multi-type instantiation and overload resolution | Future 2.38 | Conformance/TemplateFunction238 (`#as-v238-backport`) |
| context stack serialization | desired save/restore/resume through higher-version context APIs absent from the current header | Future 2.38 API deferred | `audits/upstream-compatibility.md`; add a compiled host test only after the public symbols land |
| JIT V2 | desired higher-version JIT compile/release/state contract absent from the current header | Future 2.38 API deferred | `audits/upstream-compatibility.md`; do not fake declarations to compile a test |
| computed-goto dispatch | interpreter implementation strategy, not portable script semantics | Structural N/A | portable Compiler/Runtime bytecode and execution contracts only |

## Explicit add-on exclusions

The following are not core-suite requirements and must not be pulled in to make a language test convenient:

- `scriptarray`
- `scriptdictionary`
- `scriptstdstring` or other standard string registration
- `weakref`
- `datetime`
- `scriptmath`, `complex`, and math add-ons
- serializer, context manager, debugger, grid, filesystem, socket, and other SDK add-ons

Native test fixtures may register a minimal local value/reference type, global function/property, interface, JIT compiler, thread manager, or string factory through the core `asIScriptEngine` API. Those fixtures test embedding contracts; they are not add-on imports.

## Closure rules

- Every `Active` row must name at least one executing assertion unless the row is explicitly parser/diagnostic-only.
- Every `Reject by design` row must assert the exact failure category and a stable diagnostic substring.
- Every `Future 2.38` row must remain compiled and use the exact Disabled flags-and-tags registration policy defined above.
- Every `Future 2.38 API deferred` row must name the absent public symbols, desired contract, and conversion condition; it must not add dead or uncompilable C++.
- Compile-only cases must be labeled `Compile` or `Metadata`; they cannot stand in for constructor/property/runtime execution where the raw fork can execute the behavior.
