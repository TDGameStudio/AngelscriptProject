## Why

The host `Script/` tree is too small and uneven to serve as a dependable AngelScript learning corpus or project-level validation surface. Most current script-test fixtures outside `Test_ReflectedScriptSuites.as` are only a few lines long and return arbitrary constants, while the much richer behavior covered by the plugin's Bindings, Coverage, Functional, FunctionLibraries, and Syntax tests is not available as organized, runnable `.as` material.

This change records a comprehensive, theme-based expansion plan so later implementation can build useful script examples and independent script-side functional tests without copying low-value inline test snippets or weakening the plugin-centric architecture.

## What Changes

- Establish `Script/<Theme>/` as a curated AngelScript corpus organized by user-facing areas such as Math, Containers, Reflection, Actor, Component, World, inheritance, interfaces, and engine systems.
- Establish `Script/Tests/<Theme>/` as a separate executable AS functional-test surface using `UAngelscriptTestSuite`; corpus examples and tests share taxonomy but are not required to be one-to-one pairs.
- Define corpus authoring rules that require realistic function purpose, prerequisites, observable results, meaningful names, deterministic behavior, and useful rather than noisy logging.
- Require API-dense corpus files to contain source-adjacent AS usage tables derived from the actual `Bind_*.cpp` and function-library surface, listing the AS-facing form, purpose, important parameters or side effects, example entry point, and current limitations.
- Add `Script/BlueprintLibraries/` workflows for UE-provided Blueprint libraries and AngelscriptRuntime function/mixin libraries, covering real static, namespace, receiver-mixin, WorldContext, callback, and asset/environment behavior rather than only listing functions.
- Add `Script/Bindings/` cases for AS-specific binding semantics that are difficult to learn from domain examples alone, including aliases, overloads, operators, construction/assignment, iterators, reference/out parameters, reflective calls, delegates, and expected diagnostics.
- Map all 204 current `Bind_*.cpp` files, 87 Bindings test sources, and 18 FunctionLibraries test sources through a logical provider-family crosswalk to an existing domain example, a BlueprintLibraries/Bindings case, or an explicit non-corpus disposition.
- Use a Chinese-first `Script/README.md` as the corpus catalogue and `Script/Tests/README.md` as the script-test authoring and execution guide; do not introduce a separately maintained JSON manifest in v1.
- Audit all manual bind providers and the existing Coverage, Bindings, Functional, FunctionLibraries, and Syntax suites into a user-capability matrix rather than mechanically mirroring every C++ test method.
- Plan missing C++ behavior tests in their correct existing layer when the audit finds that the test module itself has only a bind smoke test or a compile-only placeholder for a stable user-visible behavior.
- Plan test-only native `UFUNCTION`, `USTRUCT`, object, and delegate fixtures for real C++/AS marshalling tests without exposing those fixtures to corpus examples or production Runtime APIs.
- Add a future `ScriptCorpus` test-suite entry, themed script-test prefixes, corpus convention validation, and focused/full verification commands.
- Keep GameplayTags and GAS out of this change; their optional-plugin corpus and tests require separate records.
- Keep StaticJIT/AOT generation, eligibility, fallback, and parity testing out of this change; this corpus/test plan neither adds JIT metadata nor claims JIT coverage.
- Deliver this change first as a plan-only OpenSpec record. No `Script/`, plugin source, test source, tool, or guide implementation is part of the recording session.

## Capabilities

### New Capabilities

- `as-script-corpus`: Defines the theme taxonomy, semantic-quality rules, README catalogue, Bind-derived AS usage tables, discoverability, migration policy, and maintenance contract for the project AngelScript corpus.
- `as-script-functional-coverage`: Defines independent AS functional suites, World and lifecycle fixture policy, logging and assertion policy, native interop fixtures, C++ test-gap routing, capability matrices, suite integration, and verification requirements.

### Modified Capabilities

- None.

## Impact

- Future host-project script work under `Script/<Theme>/` and `Script/Tests/<Theme>/`, including classification of the current `Script/Examples/**` files and replacement or explicit disposition of placeholder root test fixtures.
- Future Blueprint library and binding-semantics material under `Script/BlueprintLibraries`, `Script/Bindings`, and their matching `Script/Tests/**` themes.
- Future test-only support and behavior tests in `Plugins/Angelscript/Source/AngelscriptTest/`, routed to Shared, Validation, Bindings, Coverage, FunctionLibraries, or the existing Functional themes according to behavior.
- Future suite and documentation updates in `Tools/Shared/TestSuiteDefinitions.ps1`, `Documents/Guides/Test.md`, and `Documents/Guides/TestCatalog.md`.
- No new production Runtime public API, plugin dependency, optional-plugin scope, or source-generation dependency is planned.
