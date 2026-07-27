## Why

`refactor-as-native-sdk-regression-suite` successfully reorganized the raw AngelScript SDK tests, but its final implementation did not meet its own behavioral-depth contract: only 25 of 222 explicitly required methods are present, all 100 exact core-language scenarios are absent, native debug/introspection APIs have almost no direct regression coverage, and many inline AngelScript fixtures still violate `Documents/UnitTest/UnitTest.md`. Passing counts therefore prove only that the implemented subset is green, not that the 2.33 fork plus selective 2.38 surface is comprehensively protected before future vendored-source changes.

## What Changes

- Supersede the depth and completeness claims of `refactor-as-native-sdk-regression-suite` with source-verifiable requirements while preserving that change as the historical structural-refactor record.
- Expand every core-language theme into explicit syntax elements, semantic dimensions, equivalence classes, boundaries, invalid forms, lifecycle outcomes, and interacting combinations; compact semantic contracts use complete Cartesian products, and every excluded combination requires a concrete independence or non-applicability reason.
- Add dedicated core-language owners for declarations, functions, variables, properties, constructors, destructors, inheritance, references, expressions, operators, conversions, control flow, `foreach`, and exceptions, plus cross-theme interaction coverage.
- Add raw SDK debug/introspection regression coverage for context callbacks, call stacks, source locations, locals, variable addresses/scope, `this`, nested context state, script-function debug metadata, fork stack callbacks, and context recovery. UE DebugServer, DAP, editor debugging, and VS Code integration remain outside this change.
- Close the 197 exact-scenario deficit from the predecessor record, but do not treat those inherited scenarios as sufficient: each becomes an input to the new combination-coverage catalogs.
- Re-audit Engine, Frontend, Compiler, Runtime, Module, TypeSystem, Embedding, and Conformance so non-language gaps exposed by the predecessor's unenforced records are also closed.
- Reformat ordinary executable/compile fixtures to the CQTest and inline-AS rules in `UnitTest.md`; preserve line-sensitive tokenizer/parser/diagnostic inputs only through explicit, audited exceptions that prove source offsets are intentional.
- Replace existence/count-only completion checks with source-derived audits that reconcile every required combination to a final test owner, expected evidence, implementation status, relevant API calls, and explicit exclusions.
- Do not set a physical-line target. Generated source is the preferred way to make a large set of independently identified semantic cases reviewable; semantic closure and verification remain the only completion criteria.
- Preserve the requested low-frequency validation workflow: implement a large coherent batch or complete stage before building, finish all planned code before the final integration build, then run focused domains and full regression suites.
- Continue to exclude AngelScript SDK add-ons. Enabled tests assert this fork's current behavior; selectively planned 2.38 behavior remains compiled, Disabled, and tagged until the required symbols/semantics are backported.
- Separate every production runtime repair discovered by the suite into a linked root-cause OpenSpec. This change owns the coverage contract and regressions, not an implicit bundle of unrelated vendored-runtime semantics.

## Capabilities

### New Capabilities

- `as-native-language-combination-coverage`: Defines exhaustive, auditable combination coverage for the raw fork's core language syntax and semantic interactions.
- `as-native-debug-introspection-coverage`: Defines direct raw-SDK regression coverage for execution callbacks, stack frames, variables, source locations, nested states, and function debug metadata.

### Modified Capabilities

- `as-native-sdk-test-coverage`: Replaces file/count-based completeness and stale snapshots with source-verifiable language, API, implementation, formatting, and combination-coverage closure.

## Impact

- **Primary implementation:** `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`, including substantial additions and splits under `Language`, `Runtime`, `Frontend`, `Compiler`, `Module`, `TypeSystem`, `Embedding`, `Engine`, `Conformance`, and `Support`.
- **Runtime repair ownership:** semantic repairs are tracked by `fix-as-reference-bytecode-ownership-persistence`, `fix-as-script-class-restore-lifecycle`, `fix-as-object-last-native-calling-convention`, `fix-as-engine-property-default-initialization`, `fix-as-static-jit-debug-text-whitespace`, `fix-as-switch-int-max-lowering`, and `fix-as-double-int64-bytecode-execution`; `runtime-change-map.md` defines hunk ownership. The completed `refactor-as-native-sdk-regression-suite` retains two exact string-scan exports. Test-only visibility remains in this change only when it does not alter behavior or public consumer contracts.
- **Parent repository:** the new OpenSpec records, generated static-audit inputs/results, test guides/catalogs, and any native-core suite configuration required for discoverability.
- **Test architecture:** additional focused CQTest classes and methods under the stable `Angelscript.TestModule.AngelScriptSDK` root; no add-on registrations and no UE debugger integration inside the raw SDK suite.
- **Build and runtime cost:** a broader `AngelscriptTest` source and automation surface with thousands of independently identifiable semantic combinations. File grouping and staged execution must keep compile memory, unity-build symbol hygiene, runtime, and failure localization manageable without treating generated text volume as value.
- **Historical record:** `refactor-as-native-sdk-regression-suite` remains unchanged and complete as a record of what was executed; this change explicitly corrects its unfulfilled depth assertions instead of rewriting history.
