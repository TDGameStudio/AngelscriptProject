## Why

`AngelscriptTest/AngelScriptSDK` has grown into a flat, mixed-purpose collection of 76 translation units and more than 400 test methods. It contains duplicated engine/context helpers, ambiguous function lookup, compile-only cases presented as runtime coverage, disabled source blocks, stale automation IDs, and UE integration tests that do not belong to the raw AngelScript SDK layer. That makes the suite difficult to audit and weakens its value as the regression boundary for changes to the vendored AngelScript fork.

The plugin deliberately remains an AngelScript 2.33-based UE fork with selective 2.38 compatibility. Before additional fork changes or backports land, the native suite needs a stable architecture that proves current fork behavior, records deliberately unsupported upstream semantics, and exposes future 2.38 expectations as discoverable but disabled tests.

## What Changes

- Reorganize the native SDK suite into nine logical test domains—`Engine`, `Frontend`, `Compiler`, `Runtime`, `Module`, `TypeSystem`, `Language`, `Embedding`, and `Conformance`—plus `Support`, all under the unchanged `AngelScriptSDK` root and still inside the single `AngelscriptTest` UE module.
- Replace the current helper god-headers with explicit engine, module, execution, compiler, and builder support headers while retaining `AngelscriptNativeTestSupport.h` and `AngelscriptTestAdapter.h` as thin compatibility entry points.
- Make engine creation profiles, context ownership, module ownership, exact declaration lookup, message capture, invocation, bytecode streams, and per-test cleanup explicit.
- Rename every native test ID to `Angelscript.TestModule.AngelScriptSDK.<Domain>.<Class>.<Method>` and remove historical `ASSDK`, reference-port branding, duplicate smoke, and flat-prefix aliases.
- Move tests that exercise `FAngelscriptEngine`, Debugger, function-caller erasure, generated struct CppOps, and UE type registries to their owning non-SDK test layers.
- Replace disabled `#if 0` Atomic/Thread/StringUtil coverage with compiled tests. Export the narrow internal AngelScript classes and string utility functions required for direct white-box regression coverage.
- Close the P0/P1 audit: every one of the 41 vendored `as_*.cpp` implementation units receives an explicit test disposition; all 36 concrete internal classes with out-of-line logic receive direct coverage; all 12 public SDK interfaces and their core method families receive behavioral or contract coverage.
- Preserve the current suite without silent loss through an exact 82-file map and a generated 433-method migration ledger; the 12 methods hidden by three constant-false blocks receive explicit real-implementation replacements.
- Require Coverage-grade behavioral depth in every SDK domain: successful behavior, representative input partitions, negative/error paths, lifecycle/cleanup, feature interactions, isolation, and fork/platform classification must have named evidence rather than a smoke case or count-only claim.
- Close a separate core-language semantics coverage inventory spanning declarations, functions, variables, class properties, virtual properties, constructors/destructors, inheritance, operators, conversions, control flow, exceptions, namespaces, imports, enums, typedefs, funcdefs, and fork reference behavior.
- Treat current fork semantics as active assertions. Add the seven expressible Future238 script subjects as compiled `EAutomationTestFlags::Disabled` cases tagged `#as-v238-backport`; record context serialization and JIT V2 as API-deferred until their absent public C++ symbols are selectively backported.
- Split oversized builder/module/bytecode/reference sources into focused ownership units, remove duplicated or obsolete files, and bring modified inline AngelScript fixtures under `Documents/UnitTest/UnitTest.md` and `ASInlineFormattingRule.md`.
- Add static coverage/ID/layout audits and update test configuration, catalogs, conventions, fork-difference guidance, plugin navigation, and Chinese-first documentation.
- Enforce low-frequency staged validation: finish the complete structural phase before one structure build, finish the complete coverage/integration phase before one final build, batch same-class fixes before rebuilding, then run nine domain prefixes, moved-test prefixes, the full SDK prefix, `NativeCore`, and `All`.

**BREAKING:** Native automation IDs below `Angelscript.TestModule.AngelScriptSDK` are intentionally replaced without legacy aliases. Internal ThirdParty classes/functions gain DLL export visibility for tests, but no AngelScript script API or consumer-facing plugin API changes.

## Capabilities

### New Capabilities

- `as-native-sdk-regression-architecture`: Defines the nine-domain suite inside the existing `AngelscriptTest` UE module, fork-versus-2.38 semantics policy, complete implementation/class/interface audit, ID migration, and staged verification contract.

### Modified Capabilities

- `as-native-sdk-test-coverage`: Replaces the historical four-layer/301-test snapshot with complete native SDK regression coverage, current inline-source rules, explicit runtime-versus-compile boundaries, and stable domain prefixes.
- `angelscript-test-helper-api`: Replaces the SDK helper implementation surface with five focused support headers while preserving the two documented compatibility includes.

## Impact

- **Parent repository:** OpenSpec artifacts, automation group filters, suite/test documentation, fork strategy/difference records, and test catalog baselines.
- **`Plugins/Angelscript` submodule:** `AngelscriptTest/AngelScriptSDK`, selected tests moved to Core/Debugger/Generator, `AngelscriptRuntime` ThirdParty headers, string utility declarations, and plugin test navigation documentation.
- **ABI/build surface:** Fourteen existing internal classes and seven existing string utility functions receive `ANGELSCRIPTRUNTIME_API` export visibility. Their layout and semantics do not change.
- **Automation consumers:** callers must migrate to the new domain-scoped test IDs. The root `Angelscript.TestModule.AngelScriptSDK` and `NativeCore` entry points remain stable.
- **Coordination:** the `as_builder.cpp` enum-description lifetime fix is committed in plugin baseline `b903571`. This change consumes that behavior and adds/retains regression coverage without reapplying the source fix.
- **Validation:** no per-file/per-test build loop is used. Two large phase builds are planned, and automation execution is deferred until the final integration build passes.
- **Scope exclusion:** AngelScript SDK add-ons such as scriptarray, dictionary, weakref, datetime, math/complex, and standard string are not tested by this core suite. Only the core engine's `asIStringFactory` host contract remains in scope.
