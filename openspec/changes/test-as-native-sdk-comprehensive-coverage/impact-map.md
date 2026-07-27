# Impact Map

## Change boundaries

This is primarily a test-source expansion inside the `Plugins/Angelscript` submodule plus parent-repository OpenSpec/audit/documentation work. Production semantic changes already discovered during implementation are owned by linked root-cause OpenSpecs and the hunk map in `runtime-change-map.md`; they are not implicitly accepted as part of test coverage. Implementation may add, split, rename, or delete test files after exact reconciliation.

## Existing native SDK sources to review or supersede

All files under `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK` are in audit scope. The following current broad language files are expected to be split or replaced after their methods are mapped:

- `Language/AngelscriptNativeConstructorsTests.cpp`
- `Language/AngelscriptNativeControlFlowTests.cpp`
- `Language/AngelscriptNativeConversionsTests.cpp`
- `Language/AngelscriptNativeExpressionsTests.cpp`
- `Language/AngelscriptNativeFunctionsTests.cpp`
- `Language/AngelscriptNativeInheritanceTests.cpp`
- `Language/AngelscriptNativeOperatorsTests.cpp`
- `Language/AngelscriptNativeReferencesTests.cpp`
- `Language/AngelscriptNativeSemanticRejectionTests.cpp`
- `Language/AngelscriptNativeVariablesTests.cpp`

Deletion is permitted only after every current method and assertion maps to a stronger final owner or a recorded obsolete/duplicate rationale. Existing Frontend/Compiler/Runtime/Module/TypeSystem/Embedding/Engine/Conformance files follow the same rule when split.

## Planned language source groups

The following are planned owners, not fixed file quotas. They may be further split when one file accumulates unrelated failure domains.

| Group | Planned concrete subjects |
| --- | --- |
| `Language/Declarations` | publication, ordering, collisions, access, failure recovery |
| `Language/Functions` | parameter directions, positions, arity, defaults, returns, overload resolution, recursion, indirect calls, failures |
| `Language/Variables` | value/reference initialization and inference, scope/shadowing, assignment targets, loop-local frequency, transfer lifetime, storage/stress failures and recovery |
| `Language/Properties` | stored-field operations, visibility paths, committed-fork accessor rejection, compiled Disabled selected-2.38 registered/indexed accessor compatibility, base/member/derived initialization order, copy/reference independence, failures, rebuild and bytecode save/load |
| `Language/Constructors` | default/parameterized/overload/access, base-member order, copy/assignment, failure cleanup |
| `Language/Destructors` | block/control exits, exception unwind, inheritance, temporaries/copies, context teardown |
| `Language/Inheritance` | construction, dispatch, access, current raw class-modifier boundary, method final/override, casts, failures |
| `Language/References` | assignment, parameters, returns, constness, null, casts, lifetime, resolution |

The constructor/destructor/inheritance/reference stage owns 20 active executable products and 3,608 expected current-fork cases: Constructors 1,364, Destructors 882, Inheritance 598, and References 764. New source owners include constructor parameter/policy/transfer/boundary, destructor declaration/partial/owner-exit, inheritance rule/override-signature, and reference resolution/failure files in addition to the original owners. Selected-2.38 abstract/final class modifier assertions belong to the separate Disabled conformance product and are not counted as active inheritance cases.
| `Language/Expressions` | primary/composition, precedence, value categories, evaluation order, chains, failures |
| `Language/Operators` | unary, arithmetic, bit/shift, comparison, logical, assignment, inc/dec, overloads, failures |
| `Language/Conversions` | numeric, boundaries, bool, enum/alias, object/value casts, resolution, failures |
| `Language/ControlFlow` | conditionals, while/do/for, switch, nested jumps, lifetime, failures |
| `Language/Foreach` | values/references, transfers, nesting, protocol resolution, lifetime, failures |
| `Language/Exceptions` | propagation, current-fork handler rejection, future handler compatibility, metadata, cleanup, recovery, state interactions, failures |

The active current-fork handler-rejection owner is `Language/Exceptions/AngelscriptNativeExceptionHandlingRejectionTests.cpp`; it owns `LANG-EX-HANDLER-REJECTION` (24 feature/placement/line-ending cells) and prints both invalid and same-name recovery sources. The selected 2.38 positive handler behavior remains in the tagged Disabled conformance owner. The final translation-unit count is deliberately not estimated. It is determined by semantic ownership, failure isolation, unity-build safety, and reviewability so an early number cannot pressure implementation to merge or stop before the coverage catalogs are closed.

## Planned raw debug sources

New owners under `AngelScriptSDK/Runtime/Debug`:

- exception callback;
- instruction callback;
- line callback;
- stack-pop callback;
- call stack;
- source locations;
- local variables;
- `this` pointer/type;
- nested context state;
- concrete stack frames;
- script-function debug metadata;
- invalid debug states.

No file under `AngelscriptTest/Debugger` is expected to move into this suite. Existing dirty changes in `Debugger/AngelscriptDebuggerDatabaseTests.cpp` remain unrelated.

## Planned support changes

Potential new internal headers under `AngelScriptSDK/Support`:

- a stable coverage-ID/case descriptor and per-cell assertion helper;
- core type/value case definitions;
- lifecycle probes and locally registered value/reference fixture types;
- callback/debug event recorders;
- exact diagnostic/result assertions;
- source/line fixture utilities and preserve-lines helpers;
- catalog/report annotations consumed by static audits.

Existing `FNativeTestEngine`, module/context RAII, exact function invocation, compiler/builder access, diagnostic capture, and bytecode stream helpers remain the preferred base. A new helper is justified only when at least two final owners share the same semantic mechanism. The documented compatibility includes remain stable unless a separate helper-API requirement is approved.

## Non-language source impact

| Domain | Likely additions/splits |
| --- | --- |
| Engine | profile/property, independent-engine isolation, allocation/shutdown, atomic/thread/TLS depth |
| Frontend | complete tokens/adjacency, parser productions/recovery, node traversal/copy/ranges, position/layout |
| Compiler | stage failure/rebuild, diagnostics, instruction mutation, bytecode/control/debug optimization |
| Runtime | invocation ABI, state transitions/recovery, script-object lifecycle, GC graphs, all raw debug owners |
| Module | lifecycle/sections/lookups/imports/globals/state tables/save-load/corruption/restore |
| TypeSystem | data-type flags, groups/globals/scopes, type/object/enum/alias/funcdef/function metadata and traits |
| Embedding | registration/calling conventions/generic/object/interfaces/string factory/JIT/thread/user-data contracts |
| Conformance | current fork singular assertions and compiled Disabled selected-2.38 expectations |

## Runtime/core headers

Read/audit scope includes:

- `AngelscriptRuntime/Core/angelscript.h`;
- `AngelscriptRuntime/ThirdParty/angelscript/source/as_context.h/.cpp`;
- `as_scriptfunction.h/.cpp`;
- parser/tokenizer/script-node/compiler/builder/bytecode/type/module/engine implementation headers and sources covered by inventories.

`asCContext` already has runtime export visibility. If a required internal class/member is not link-visible, the preferred order is:

1. cover it through an existing public/exported interface;
2. add a narrow test accessor in the test module where legal;
3. add export visibility without changing layout/semantics;
4. record a concrete deferred reason if safe access is impossible.

Any production header edit requires ABI/build review and explicit task/diff
evidence. Vendored semantic implementation changes require a linked
root-cause OpenSpec, focused regression ownership, and hunk-level reconciliation
before they are accepted.

Current linked runtime changes:

- `fix-as-reference-bytecode-ownership-persistence`;
- `fix-as-script-class-restore-lifecycle`;
- `fix-as-object-last-native-calling-convention`;
- `fix-as-engine-property-default-initialization`;
- `fix-as-static-jit-debug-text-whitespace`;
- `fix-as-switch-int-max-lowering`;
- `fix-as-double-int64-bytecode-execution`.

The completed `refactor-as-native-sdk-regression-suite` remains the exact owner
of the two string-scan Runtime exports. P073/P074 are retained as explicitly
user-authorized, non-semantic terminology cleanup and have no behavioral
root-cause owner.

## Parent repository artifacts

New or modified parent files may include:

- this OpenSpec and its `coverage/`, `references/`, `audits/`, and `scripts/` records;
- `Documents/Guides/Test.md` for new domain/theme commands;
- `Documents/Guides/TestCatalog.md` for generated active/Disabled/domain/combination/pass totals;
- `Documents/Guides/TestConventions.md` if deeper native prefix/file organization needs documentation;
- `Documents/UnitTest/UnitTest.md` and `Documents/Rules/ASInlineFormattingRule.md` only if implementation discovers a missing rule, not to weaken current requirements;
- `Documents/Guides/AngelscriptForkStrategy.md` and `Documents/Guides/ASSDK_Fork_Differences.md` when characterization changes current/future classification;
- `AGENTS_ZH.md` first and `AGENTS.md` only if project-wide baselines or entry points materially change;
- the `Plugins/Angelscript` gitlink after the plugin commit.

## Configuration/build impact

- The stable `Angelscript.TestModule.AngelScriptSDK` and `NativeCore` roots should discover recursive source and deeper prefixes without `AngelscriptTest.Build.cs` source lists.
- `Config/DefaultEngine.ini` should not need a new group if its current prefix is broad enough. Because it is already dirty, any required edit must be isolated and reviewed before touching it.
- `Config/DefaultAngelscriptCompileOptions.ini` must keep `bCompileAngelscriptUnitTests=true` for test builds; disabled-unit-tests compilation remains a separate final verification.
- The enlarged module may increase unity-build memory and symbol collision risk. File-private helpers remain class-private or uniquely named.

## Static audit artifacts

Planned new files under this change:

- machine-readable expected coverage records split by theme/domain;
- predecessor scenario reconciliation;
- public API and native debug inventories;
- implementation-unit/internal-class dispositions;
- inline-AS fixture classification and exception catalog;
- automation-ID/source-owner migration records;
- scripts for catalog validation, source reconciliation, API-use checks, formatting checks, and final count/report generation;
- verification evidence with exact commands and report paths.

The final file format (CSV/JSON/PowerShell data) is selected during implementation for deterministic parsing. Markdown remains the human design source; generated results do not replace it.

## Test execution impact

New narrow prefixes follow:

`Angelscript.TestModule.AngelScriptSDK.<Domain>.<Theme>.<Contract>.<Method>`

Required execution levels:

- changed micro-contract prefix while repairing runtime failures;
- each changed theme;
- each of nine domains;
- full `Angelscript.TestModule.AngelScriptSDK`;
- configured `NativeCore` suite;
- `All` suite;
- unit-tests-disabled build/discovery check.

Large test runtime is expected. Report generation must preserve individual failures and must not time out silently.

## Dirty-worktree collision policy

Known unrelated plugin modifications currently include runtime engine code, Coverage tests, Debugger tests, and StaticJIT tests. New native work should avoid these paths. If a required shared/runtime edit overlaps a dirty file, inspect the exact diff and either work around it or ask the user before modifying. Never reset, discard, stage, or commit unrelated changes.

## Commit order

1. Verify plugin status and stage only native SDK/runtime-export changes belonging to this OpenSpec.
2. Commit the `Plugins/Angelscript` submodule using the repository commit format.
3. In the parent, stage only this OpenSpec, approved documentation/configuration edits, and the updated plugin gitlink.
4. Commit the parent separately. Do not force-push or modify unrelated submodules.
