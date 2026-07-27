# Variables and Scope

## Elements and dimensions

| Axis | Values |
| --- | --- |
| Storage | local, const local, inferred `auto`, loop initializer, branch local, catch/exception local where supported, const global, class/struct field linkage |
| Type | all primitive families, enum/alias, value object, automatic reference, funcdef, null/reference where legal |
| Initialization | implicit default, literal, expression, copy, constructor, function return, reference alias, conditional, invalid/incompatible, throwing initializer |
| Assignment | simple, compound, copy, self-assignment, reference rebinding/alias mutation, const rejection |
| Scope shape | function, nested block, if/else branch, switch case, for init/body/increment, while/do, foreach, nested function call |
| Shadow relation | no shadow, inner shadows outer, parameter shadows global/type member as permitted, sibling scopes, illegal duplicate same scope |
| Use point | before declaration, after declaration, inner scope, after inner exit, after owner exit, captured/returned reference where supported |
| Lifetime observation | construct, copy/move if applicable, assign, destruct, exception unwind, early return, loop repetition, module discard |

## Required products

- `Fifteen core value types × storage(local/const local/auto/loop initializer/branch local/const global/field linkage) × initialization(default/literal/expression/copy/constructor/function return/conditional)` is complete. Every legal cell validates value, declared or inferred metadata, visibility, lifecycle, and cleanup; impossible `auto`/default, const-global, and field forms are isolated rejections followed by a clean same-name rebuild.
- `Reference type × source × explicit/auto/const declaration × identity/mutation/argument/return/null use` covers automatic-reference variable initialization without treating value-type initialization as proof of reference semantics.
- `Five name relations × twenty-five concrete scope/use paths` covers resolution before/during/after functions, nested blocks, branches, switch cases, loops, foreach, nested calls, sibling calls, and owner exit. Scope and use location are paired so every cell names a real source position instead of relying on an ambiguous `inside_inner` label.
- `Lifetime-bearing type × exit path(normal/return/break/continue/exception) × nesting depth` validates exact construction/destruction counts and order.
- `Counted reference assignment × factory/overwrite/null/parameter-return/exception/save-load transition` validates bytecode and automatic-object metadata, exact construction/AddRef/Release/destruction counts, same-context recovery, and zero live references.
- `Seventeen value/reference types × assignment(simple/copy source/self/compound/reference rebind) × target state` covers mutable/const locals and fields, reference aliases, temporaries, and expression results. Legal cells require before/result/after values, identity, write count, and lifecycle; rejected cells require an owning diagnostic and recovery.
- `Script/native lifetime value × loop placement × iteration count(0/1/3/8) × exit(normal/break/continue/return/exception)` proves exact construction, visibility, body/increment visits, destruction frequency, stopped transfer trace, and context recovery.
- Fourteen named failure or storage-boundary scenarios × fresh or same-module/context recovery cover use-before/after-scope, duplicates, incompatible/throwing initialization, mutable/reference globals, uninitialized reads, failure atomicity, identifier/local/stack pressure, and module discard.

## Product ownership and scale

| Product ID | Cases | Purpose |
| --- | ---: | --- |
| `LANG-VAR-INIT-STORAGE` | 735 | Value type, storage, and initialization semantics |
| `LANG-VAR-SHADOW` | 125 | Scope identity and shadow resolution through concrete use paths; same-scope duplicates remain isolated failures |
| `LANG-VAR-LIFETIME` | 100 | Transfer-sensitive local lifetime |
| `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT` | 7 | Counted-reference assignment ownership across factory, overwrite, null, parameter/return, exception, and save/load transitions |
| `LANG-VAR-REFERENCE-INIT` | 150 | Automatic-reference declaration, inference, identity, and constness |
| `LANG-VAR-ASSIGN-TARGET` | 595 | Assignment target legality and observable mutation |
| `LANG-VAR-LOOP-DECL-LIFETIME` | 200 | Loop declaration frequency and cleanup |
| `LANG-VAR-FAILURE-BOUNDARY` | 28 | Isolated failures, stress boundaries, and recovery |

The products contain 1,940 expected cases. Base/derived views are deliberately owned by the References and Inheritance products rather than generating native-reference inheritance cells for a registered fixture that declares no native type relation. Same-scope duplicate declaration is owned once by `LANG-VAR-FAILURE-BOUNDARY`; multiplying that declaration failure by unreachable use points would add no observable distinction. Scope shape and use point are stored as twenty-five concrete paths so every shadow cell maps to a real statement location. Counts are not substitutes for assertions: each product states its runtime, metadata, debug, diagnostic, lifecycle, cleanup, or isolation evidence independently in the executable catalog.

## Boundaries

Uninitialized/default values, numeric min/max, long identifier, maximum practical local count/stack pressure, duplicate declarations, use-before-declare, out-of-scope access, incompatible initializer, illegal const mutation, failed initializer atomicity, and context reuse after initializer exception are required.

## Planned ownership

- `Language/Variables/AngelscriptNativeVariableInitializationTests.cpp`
- `Language/Variables/AngelscriptNativeVariableReferenceInitializationTests.cpp`
- `Language/Variables/AngelscriptNativeVariableTypeInferenceTests.cpp`
- `Language/Variables/AngelscriptNativeLanguageVariableScopeTests.cpp`
- `Language/Variables/AngelscriptNativeVariableShadowingTests.cpp`
- `Language/Variables/AngelscriptNativeVariableAssignmentTests.cpp`
- `Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp`
- `Language/Variables/AngelscriptNativeCountedReferenceAssignmentTests.cpp`
- `Language/Variables/AngelscriptNativeVariableLoopLifetimeTests.cpp`
- `Language/Variables/AngelscriptNativeVariableFailureBoundaryTests.cpp`
