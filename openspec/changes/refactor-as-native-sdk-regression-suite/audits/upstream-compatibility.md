# Upstream Compatibility Classification

## Authority and policy

- Runtime authority: the repository fork reporting `ANGELSCRIPT_VERSION 23300` / `2.33.0 WIP`.
- Comparison authority: the pinned AngelScript 2.38.0 reference used by this repository.
- Strategy: current fork semantics stay enabled and authoritative; selected higher-version behavior is absorbed deliberately rather than through a wholesale upgrade.
- External add-ons are excluded. This record covers core language, core SDK interfaces, and host contracts only.

Classifications:

- **Fork**: enabled current behavior that intentionally differs from upstream.
- **Compatible**: enabled behavior shared with the pinned reference.
- **Future238**: desired script-visible behavior represented by a compiled Disabled CQTest when the current C++ SDK can express the test.
- **Future238 API Deferred**: desired host API cannot be referenced by the current C++ headers, so it is recorded with an enable condition rather than hidden in uncompilable code.
- **Structural NotApplicable**: implementation strategy rather than a portable language/SDK contract.

## Core language and semantic surface

| Capability | Upstream era | Classification | Required owner and assertion |
| --- | --- | --- | --- |
| anonymous functions / lambda expressions | introduced before 2.33, not complete in this fork strategy | Future238 | `Conformance/AngelscriptNativeLambda238Tests.cpp`; Disabled/tagged script compiles and invokes a captured-free anonymous function when enabled. The active Frontend parser test asserts the exact current parse shape separately and does not claim executable support. |
| shared and external entities | 2.32 | Compatible | Module and Language tests compile shared declarations, resolve identity across modules, bind an external declaration, execute it, and reject incompatible duplicate declarations with one diagnostic category. |
| try/catch | 2.33 | Compatible | `Language/AngelscriptNativeExceptionsTests.cpp`; throw, catch, nested propagation, rethrow, cleanup, uncaught context exception, and post-exception context reuse execute. |
| explicit constructors | 2.33 | Compatible | `Language/AngelscriptNativeConstructorsTests.cpp`; explicit constructor participates in direct construction and is rejected in implicit conversion. |
| `property` keyword and indexed properties | 2.34 surface already present in fork parser/builder | Compatible | `Language/AngelscriptNativePropertiesTests.cpp`; get/set/indexed access executes and malformed/ambiguous accessors report exact diagnostics. |
| using namespace | higher-version target not active in fork policy | Future238 | `Conformance/AngelscriptNativeUsingNamespace238Tests.cpp`; Disabled/tagged scenario resolves a type and function through a using directive. |
| member initialization | higher-version target not active in fork policy | Future238 | `Conformance/AngelscriptNativeMemberInitialization238Tests.cpp`; Disabled/tagged scenario initializes a member from a valid constructor expression and executes the value. |
| generated/default/copy special-member controls | 2.37+ | Future238 | `Conformance/AngelscriptNativeDefaultSpecialMembers238Tests.cpp`; Disabled/tagged scenarios cover generated default/copy behavior and explicit delete controls. |
| bool context | selective higher-version target | Future238 | `Conformance/AngelscriptNativeBoolContext238Tests.cpp`; Disabled/tagged scenario uses the target type in branch and loop conditions and asserts selected paths. |
| foreach | 2.38, selectively present | Compatible | `Language/AngelscriptNativeForeachTests.cpp`; iteration order, value/reference variables, break/continue, empty input, mutation/lifetime, invalid iterable, and interaction with return/exception are active. Core fixtures must not import an add-on container. |
| variadic script functions | 2.38 | Future238 | `Conformance/AngelscriptNativeVariadicFunction238Tests.cpp`; Disabled/tagged script declares and invokes a variadic function with zero and multiple trailing arguments. |
| function templates | 2.38 | Future238 | `Conformance/AngelscriptNativeTemplateFunction238Tests.cpp`; Disabled/tagged script instantiates a template function for two primitive types and asserts overload resolution. Internal partial structures do not count as active semantics. |
| automatic reference semantics | fork divergence | Fork | `Conformance/AngelscriptNativeReferenceSemanticsTests.cpp`; enabled cases assert the fork's implicit reference/null/identity rules and exact rejection of unsupported explicit handle forms. |
| const-only script globals | fork divergence | Fork | `Conformance/AngelscriptNativeGlobalSemanticsTests.cpp`; const initialization/read executes and mutable global declaration reports the one expected diagnostic category. |
| script interfaces | fork divergence | Fork | `Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp`; exact current declaration/inheritance rejection is asserted without an alternate-success branch. Host C++ interfaces remain an Embedding concern. |
| mixin global functions versus `mixin class` | fork divergence | Fork | Language/Module tests execute supported mixin global functions; Conformance asserts exact rejection of `mixin class`. |

## Host SDK and implementation surface

| Capability | Classification | Required treatment |
| --- | --- | --- |
| existing JIT compiler interface | Compatible | Active `Embedding/AngelscriptNativeJITCompilerTests.cpp` registers a deterministic test double and proves compile/release callback and assigned-function lifecycle through a real engine. |
| JIT V2 interface | Future238 API Deferred | Record missing interface symbols and the target compile/release/state contract. Convert to a compiled Disabled host test only after the selected header/interface backport lands. |
| context stack serialization/deserialization | Future238 API Deferred | Record target context state/register serialization methods and a future save/restore/resume round trip. Do not reference absent methods in current C++. |
| variadic/function-template metadata flags such as `asFUNC_TEMPLATE` and `IsVariadic` | Future238 API Deferred | Language Disabled tests represent desired script semantics; C++ metadata assertions are added only after the corresponding public symbols are backported. |
| computed-goto interpreter dispatch | Structural NotApplicable | No semantic test is created. Portable bytecode generation, branching, execution, exception, and result contracts remain active and backend-independent. |
| inactive call-function architecture backends | Structural NotApplicable | The 12 inactive backend units are inventory-classified only. Shared callfunc code and the active Win64 MSVC backend receive executable calling-convention coverage. |

## Future test registration contract

Every script-semantic `Future238` owner SHALL:

- use `TEST_CLASS_WITH_FLAGS_AND_TAGS`;
- include `EAutomationTestFlags::Disabled`;
- use `TEXT("#as-v238-backport")`;
- contain a real assertion body that compiles against the current C++ SDK;
- avoid `#if 0`, `&& 0`, commented-out bodies, and unregistered helper-only expectations;
- become active only through an explicit classification update and removal of the Disabled flag after the implementation is backported.

An absent C++ API is never simulated with a fake production declaration solely to make a future test compile. Its deferred entry must name the missing surface, desired contract, and conversion condition.
