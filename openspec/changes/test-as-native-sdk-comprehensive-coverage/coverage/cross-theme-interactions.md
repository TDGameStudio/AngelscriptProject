# Cross-Theme Interaction Chains

Independent theme completion is insufficient. The following chains are mandatory because one feature changes another's resolution, lifetime, bytecode, or debug state.

| ID prefix | Themes | Required chain |
| --- | --- | --- |
| X-FN-CONV | Functions + Conversions | Parameter directions/defaults and implicit conversions select one overload; ambiguous/missing cells produce one diagnostic. |
| X-FN-REF | Functions + References | const/in/out/inout, alias source, null, return reference, and overload selection preserve identity/writeback/lifetime. |
| X-FN-CTOR | Functions + Constructors + Destructors | Value arguments/returns construct, copy, assign, unwind, and destruct exactly once across normal and exceptional calls. |
| X-CTOR-PROP | Constructors + Properties + Inheritance | Base/member initializers and constructors execute in declared order; virtual/stored property reads see the correct stage and final values. |
| X-CTOR-EX | Constructors + Destructors + Exceptions | Failure at base/member/derived stages destroys only the initialized prefix in reverse order and leaves the context reusable. |
| X-INH-DISP | Inheritance + Functions + Properties | Base/derived view, const receiver, method/property override, explicit base call, and overload hiding select the expected target. |
| X-OP-CONV | Operators + Conversions + Expressions | Built-in/overloaded result conversion participates in overloads, assignments, ternary common type, and control conditions. |
| X-OP-CF | Operators + Expressions + ControlFlow | comparison/logical/overloaded results drive branches; short circuit prevents mutation/exception. |
| X-VAR-CF | Variables + ControlFlow + Destructors | loop/branch/switch locals initialize and destruct for zero/one/many iterations and every transfer path. |
| X-FE-EX | Foreach + References + Exceptions | value/reference iteration mutation, iterator lifetime, return/break/continue, and exception unwind remain consistent. |
| X-NS-MOD | Declarations + Functions + Module | namespaces, shared/external declarations, imports, bind/unbind, rebuild, and exact lookup preserve identity and execution. |
| X-META-BC | Declarations + TypeSystem + Module | type/function/property metadata survives bytecode save/load and produces the same runtime result. |
| X-EX-DBG | Exceptions + NativeDebug | exception callback, stack, frames, locals, source location, `this`, cleanup, and context reuse agree at the same stop. |
| X-NEST-DBG | Functions + Exceptions + NativeDebug | push/inner execute/pop restores outer arguments, function/frame/locals/state and survives an inner exception. |
| X-OPT-DBG | Compiler + Expressions + NativeDebug | optimization preserves runtime result/control flow and records the supported line/local metadata behavior. |
| X-GC-MOD | References + RuntimeGC + Module | cycles/references are released or collected once across context release, module discard, and engine shutdown. |

## Chain dimensions

Each chain defines at least:

- one ordinary success;
- boundary values or empty/one/many shape;
- one resolution/state failure;
- one cleanup/reuse path;
- current-fork classification;
- save/load or optimize variants when the chain crosses those boundaries;
- exact observable markers at every participating theme rather than one final aggregate integer when intermediate order matters.

## Reduction rule

Cross-theme chains do not automatically multiply every value from every theme. The chain record names only dimensions that can alter the interaction. Any reduction must state why another theme value is independent and must retain at least one representative plus all boundaries.

## Ownership

The theme that owns the final risk-bearing transition owns the test file; the other themes reference the same coverage ID. No duplicate test is required merely to make two catalogs appear complete.
