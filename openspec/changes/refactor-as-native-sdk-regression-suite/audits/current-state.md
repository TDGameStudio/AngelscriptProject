# Current-State Audit (2026-07-22)

## Inventory

| Metric | Observed value |
| --- | ---: |
| Flat SDK `.cpp` files | 76 |
| Root SDK headers | 6 |
| `TEST_CLASS_WITH_FLAGS` definitions | 76 |
| Source `TEST_METHOD` definitions | 433 |
| Methods compiled out by `WITH_ANGELSCRIPT_UNITTESTS && 0` | 12 |
| Source methods outside the three known constant-false blocks | 421 |
| Vendored `as_*.cpp` implementation units | 41 |
| Concrete internal classes in P0/P1 inventory | 36 |
| Public SDK interfaces | 12 |
| Files above 500 lines | 7 |
| Existing `EAutomationTestFlags::Disabled` SDK classes | 0 |

The documented `301/301 PASS` is a historical run snapshot, not a reliable count of the current 433 source definitions. The 421 value above is an exact static classification outside three known constant-false blocks, not a runtime discovery claim. Final active/disabled/discovered/pass totals must be regenerated after this change.

The seven files above 500 lines are baseline observations only. File size is not a completion quota; final splitting follows the exact subject ownership in `file-map.md` and allows a large cohesive owner with a recorded rationale.

## Structural findings

1. Every test and helper sits in one flat directory, so physical ownership does not match Engine/Frontend/Compiler/Runtime/Module/TypeSystem/Language/Embedding/Conformance responsibilities.
2. `AngelscriptNativeTestSupport.h` (1038 lines), `AngelscriptBuilderTestSupport.h` (631 lines), and `AngelscriptSDKTestExecutionHelpers.h` (466 lines) overlap on engine/module/context execution duties.
3. `AngelscriptBuilderTests.cpp` and `AngelscriptScriptModuleTests.cpp` are larger than 1200 lines in the audited baseline; bytecode, diagnostics, type, and reference files also exceed practical focused-review size.
4. `GetNativeFunctionByDecl` can fall back from declaration to name or a sole function, allowing the wrong overload to satisfy an exact-declaration test.
5. Context prepare/execute/release is duplicated. Float return handling is not consistently selected from the declared return type.
6. `FSDKBytecodeStream` and `FMemoryBinaryStream` duplicate one in-memory binary stream responsibility.
7. `FNativeTestEngine::Reset` does not express full test-case state ownership; registrations/modules and message state can make order visible.
8. Duplicate native smoke files register overlapping intent under stale flat prefixes.

## False or disabled coverage

- `AngelscriptAtomicTests.cpp`: four real `asCAtomic` tests are compiled out because the class lacks DLL export visibility.
- `AngelscriptThreadTests.cpp`: three real thread/TLS tests are compiled out for the same reason and include compressed one-line control flow that does not meet current rules.
- `AngelscriptStringUtilTests.cpp`: five tests are compiled out and test locally registered `std::strtol`/`std::strtod` lambdas rather than `as_string_util.cpp`.
- `AngelscriptRuntimeTests.cpp` names a suspend scenario without proving a real suspend/resume state transition.
- several calling-convention, object, OOP, auto/reference, and implicit-value cases stop at compilation while their names imply runtime execution.
- reference script-class cases accept multiple contradictory results or tolerate a null-pointer exception, hiding the current fork's actual contract.

## Layer violations

| File | Why it is not raw SDK coverage | Required destination |
| --- | --- | --- |
| `AngelscriptCompilerTests.cpp` | uses `FAngelscriptEngine::CompileModule` and plugin trace behavior | `Compiler.ModulePipeline` |
| `AngelscriptContextPoolTests.cpp` | tests plugin context pool ownership | `Engine.ContextPool` |
| `AngelscriptDebuggerValueTests.cpp` | tests plugin debugger value logic | `Debugger.Value` |
| `AngelscriptDebugReificationTests.cpp` | tests plugin debugger reification | `Debugger.Reification` |
| `AngelscriptFunctionCallerErasureTests.cpp` | tests runtime function-caller wrapper erasure | `Engine.FunctionCallers` |
| `AngelscriptStructCppOpsTests.cpp` + types | tests generated UE struct CppOps | `Generator.ASStruct.CppOps` |
| `AngelscriptTypeRegistryTests.cpp` | tests plugin engine type registry | `Engine.TypeRegistry` |
| `AngelscriptTypeUsageTests.cpp` | tests plugin type-usage integration | `Engine.TypeUsage` |

`AngelscriptDataTypeTests.cpp`, `AngelscriptGCInternalTests.cpp`, and `AngelscriptRestoreTests.cpp` contain valuable low-level behavior but use wrapper-era helpers; they are rewritten against raw SDK/internal APIs and stay in the SDK.

## Semantics findings

- The fork remains 2.33-based with selective 2.38 compatibility.
- Current intentional differences include const-only script globals, automatic references/no `@` syntax, no script `interface`, no `mixin class`, APV2 module/type behavior, UE memory, and fork bytecode restore layout.
- Existing tests sometimes document limitations instead of asserting one result. The new Conformance layer must make current fork behavior active and future 2.38 targets compiled-disabled.
- Core language behavior—especially class properties, virtual properties, constructors/copy/destructors, inheritance, and runtime object behavior—needs a named semantics coverage inventory independent of internal-source coverage.
- External `sdk/add_on` libraries are outside the requested core scope and should not be introduced as fixtures.

### Current language-theme depth assessment

This is a planning diagnosis, not a post-change score:

| Theme | Current evidence | Primary gap before closure |
| --- | --- | --- |
| Declarations | strong Parser declaration/error sources | raw module/metadata/runtime linkage and strict fork classification are incomplete |
| Functions | overload/default/ref/recursion cases exist | method/delegate/return-category/error and dispatch depth is uneven |
| Variables | global enumeration/reset/limits are strong | local inference/shadowing/lifetime and const mutation need focused language tests |
| Properties | some object/value-type scripts exist | core field/virtual-property runtime, access, inheritance, and negative shapes are weak |
| Constructors | metadata and a few chain cases exist | runtime construction/copy/order/cleanup is weak; several tests are permissive or exception-tolerant |
| Destructors | incidental cleanup only | focused normal/return/exception/member/base destruction ordering is missing |
| Inheritance | limited interface/mixin/metadata cases | multi-level runtime virtual dispatch/base call/state/access coverage is weak |
| References | several reference arguments/conversions exist | alias/null/identity/lifetime/cast behavior and strict fork boundaries are incomplete |
| Expressions | Parser expressions and primitive operators are broad | member/index/lvalue/error/runtime interaction depth is uneven |
| Operators | primitive arithmetic/comparison/logical/bit/assignment/precedence cases are good | overload error/ambiguity, evaluation order, and object interaction need depth |
| Conversions | numeric/bool/boundary cases exist | one implicit-value path is compile-only; overload/object/reference ambiguity needs execution/diagnostics |
| Control flow | compiler/syntax and function cases provide partial coverage | raw runtime zero/one/many/nested/switch/error behavior needs a coherent owner |
| Foreach | parser/compiler selective backport exists | end-to-end iteration protocol, mutation/lifetime, and invalid protocol coverage need confirmation/expansion |
| Exceptions | exception details/modulo/context reuse exist | the suspend case is not a real suspend/resume test; callbacks/unwind/nested state need depth |

Therefore no language theme is marked complete in advance. The implementation must map retained cases and fill these gaps before the complete audit can pass.

## Coordination findings

- `Plugins/Angelscript/.../as_builder.cpp` is clean at the reviewed plugin baseline. Its enum-description lifetime fix is committed in `b903571`; this change retains the regression without reapplying the implementation.
- Root test documentation, configuration, test-suite definitions, and `UnitTest.md` also contain pre-existing user changes. Patches must be narrow and preserve unrelated hunks.
- The repository guidance explicitly requires work in the current checkout unless the user asks for a worktree, so this implementation stays in the current parent/submodule checkouts.

## Definition of closure

The refactor is not closed by moving files or increasing a count. Closure requires:

1. no flat registering SDK sources;
2. five focused support owners plus two thin compatibility includes;
3. exact declaration lookup and one invocation/stream implementation;
4. no constant-false test registration;
5. 41/36/12 plus nine-domain and core-language depth evidence complete;
6. all 433 current methods reconciled through `test-methods.csv` and all required new scenarios implemented from `test-scenarios.md`;
7. no add-on dependencies;
8. all planned code/docs written before build;
9. fresh build and ordered narrow-to-broad verification evidence.
