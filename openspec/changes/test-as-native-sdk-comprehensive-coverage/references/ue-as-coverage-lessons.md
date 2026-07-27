# Lessons from the UE AngelScript Coverage Work

## Sources reviewed

This design explicitly references the completed `openspec/changes/test-coverage` record and the current `Plugins/Angelscript/Source/AngelscriptTest/Coverage` implementation. The review covered the main index, tasks, gap audit, basic-type, class, struct, control-flow/language, and debug/logging records, plus representative source implementations for integer functions, operator overloads, loops, class specifier combinations, and struct function/container combinations.

The reference is methodological. `Coverage/` exercises UE-integrated AngelScript and therefore cannot be copied into the bare native SDK layer.

## Practices to retain

### Actual source is authoritative

The prior coverage record corrected stale documentation by mechanically reconciling files, automation prefixes, and `TEST_METHOD`s against source. The new native record adopts that direction and strengthens it: the source audit also reconciles individual combination IDs, expected evidence, API symbols, and exclusions.

### One row represents one verifiable capability

The useful unit in the prior record is a concrete scenario rather than a filename or broad theme. Examples include integer parameter directions, integer width boundaries, bool short circuit, struct copy independence, class specifier ordering, switch fallthrough, and unsupported conversion forms. New native catalogs use the same granularity and add explicit combination axes.

### Covered, partial, pending, and unsupported are distinct

The prior record keeps supported behavior, enhancement ceilings, pending work, and fork-unsupported boundaries separate. The native suite uses the same semantic distinction:

- active current-fork behavior with passing evidence;
- partially closed behavior with exact missing combinations;
- pending implementation;
- active negative/rejection behavior;
- compiled Disabled selected-2.38 target;
- API-deferred target whose public symbol is absent.

Unsupported does not mean untested. Expressible current-fork rejection receives an enabled negative test with an exact result or diagnostic.

### Assertion-layer review matters

The previous OpenSpec's 2026-06-30 audit found that same-named methods and green compile assertions could create false confidence. It distinguished syntax-only compile ceilings from capabilities that require execution. The native suite makes this normative: every catalog row declares its required evidence layer, and the audit rejects a compile-only implementation for an executable, metadata, lifecycle, debug, or cleanup contract.

### Type and usage roles are separate axes

The prior integer coverage separates property, expression, and function roles, then covers all integer widths, parameter directions, returns, defaults, overloads, boundaries, and reflection. The native suite reuses this principle without UE properties/reflection: primitive and core object types are crossed with declaration, argument, return, expression, conversion, storage, lifetime, and debug-variable roles where those roles affect core semantics.

### Interaction products expose bugs that isolated cases miss

Useful previous patterns include struct parameter direction × container shape, class specifier order × inheritance, map key/value permutations, default object × instance independence, operator overload × expression result, and loop form × jump behavior. The new suite records interacting products explicitly instead of hiding them behind a broad method name.

### Negative and environmental ceilings stay visible

The previous gap record documents unsupported nested containers, unbound APIs, headless limitations, invalid specifiers, and compile-failure boundaries. The native suite similarly records explicit-handle rejection, script-interface rejection, mutable-global rejection, unsupported current-fork syntax, absent 2.38 APIs, invalid callback states, and invalid debug-frame/variable access.

## Practices to improve rather than copy

### Do not infer all combinations from one aggregate test

Several prior tests place many permutations in one very large `TEST_METHOD`. This provides breadth but can obscure whether every intended cell exists and can make failures hard to localize. Native combination catalogs assign a stable case ID to every expected cell. A method may execute a tightly related batch only when each case emits its ID, has independent assertions, and is reconciled by the audit.

### Do not create giant single-owner translation units

The previous struct source exceeds 16,000 lines. That demonstrates the likely scale of serious combination coverage, but the native suite will split by semantic ownership—parameter directions, returns, constructors, containers, metadata, diagnostics, and lifecycle—so review and unity-build failures remain tractable.

### Do not use generic coverage labels in new source names

The user asked that new files and test subjects state what they test rather than use a generic English label. New owners use names such as `FunctionParameterDirections`, `ConstructorFailureCleanup`, `ContextLocalVariables`, and `OperatorResolution`; no new file/class/method is named after a generic coverage label.

### Do not copy outdated fixture formatting

Some prior Coverage sources predate the current inline-AS rule and contain column-zero blocks or compact bodies. All new/modified native sources follow `UnitTest.md` and the current dedenting wrappers. Exact-layout cases use preserve-lines helpers with a reason.

### Do not import the UE execution layer

The prior sources use `FAngelscriptEngine`, Actors, reflected properties, UFUNCTIONs, containers, and UE types. Native SDK tests replace those observation points with raw module/context execution, SDK metadata, locally registered minimal native types, direct internal state, callbacks, bytecode, and lifecycle counters.

## Concrete application to the new suite

| Prior technique | Native-core adaptation |
| --- | --- |
| Integer widths × parameter directions | SDK primitive families × value/in/out/inout × position × arity × call target |
| Struct function/container permutations | Script object/value/reference categories × argument/return/lifetime/copy/exception behavior |
| Class specifier order and invalid combinations | Core declaration modifiers/access/inheritance/order/conflict products |
| Loop statement families | if/switch/for/while/do/foreach × zero/one/many × break/continue/return × nesting |
| Operator overload execution | built-in/overloaded operator × operand category × lvalue/const × conversion × resolution outcome |
| Assertion-layer audit | required compile/runtime/metadata/lifecycle/debug evidence per combination ID |
| Unsupported-boundary inventory | enabled fork rejection, Disabled 2.38 target, or API-deferred classification with evidence |
| Source reconciliation | generated expected-vs-implemented combination report that fails on missing or duplicate IDs |

## Review conclusion

The prior Coverage work confirms that comprehensive coverage naturally produces large, type- and role-specific sources. It also shows why count-only summaries and broad aggregate methods are insufficient. The new native suite adopts its scenario-level breadth and boundary discipline while adding stricter combination accounting, raw-SDK ownership, failure localization, formatting enforcement, and source-derived proof.
