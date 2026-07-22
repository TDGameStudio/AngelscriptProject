# Impact Map

## Change boundaries

| Repository | Owned by this change | Explicitly not owned |
| --- | --- | --- |
| Parent `AngelscriptProject` | OpenSpec record, SDK automation filters, test/fork documentation, audit script entry and generated inventory | unrelated active OpenSpecs, Wiki, UHT/function-binding work, host project behavior |
| `Plugins/Angelscript` submodule | ThirdParty export annotations, `AngelscriptTest/AngelScriptSDK` restructure, eight test-area moves, plugin test navigation | the committed semantic fix in `as_builder.cpp`, unrelated Runtime/Editor/Test edits |
| `Plugins/AngelscriptGAS` / `Plugins/AngelscriptGameplayTags` | verification only through broader suites | no source changes planned |

## Production code impact

| Area | Files/symbols | Change | Behavioral impact |
| --- | --- | --- | --- |
| Internal class visibility | `as_atomic.h`, `as_bytecode.h`, `as_configgroup.h`, `as_compiler.h` (expression helpers), `as_outputbuffer.h`, `as_string.h`, `as_thread.h`, `as_scriptobject.h`, `as_variablescope.h`, `as_typeinfo.h` | add `ANGELSCRIPTRUNTIME_API` to 14 existing classes with `[UE++]` rationale | DLL symbol visibility only; no layout, ownership, registration, or script semantics change |
| String utility visibility | `as_string_util.h` | export seven existing functions | DLL symbol visibility only; real implementation becomes directly testable |
| Builder | `as_builder.cpp` | no source ownership; consume the enum-description lifetime repair committed in `b903571` | regression coverage verifies baseline behavior; do not reapply or revert the production fix |
| Runtime build | `AngelscriptRuntime` ↔ `AngelscriptTest` | test DLL links newly visible symbols | possible link/export diagnostics; no new module dependency |

## Test source impact

| Area | Current state | End state |
| --- | --- | --- |
| SDK root | 76 flat `.cpp` plus six headers | no registering root `.cpp`; nine SDK domain directories plus `Support`; two thin root compatibility headers |
| Helpers | three overlapping implementation headers, two byte streams, multiple context flows | five focused support headers, one stream, one invoker, explicit profiles and RAII ownership |
| IDs | flat, historical reference-port segments, duplicate Smoke, historical naming | one domain-scoped ID scheme; no aliases |
| Disabled coverage | Atomic/Thread/StringUtil blocks excluded or testing local lambdas | compiled direct tests; seven expressible Future238 script subjects use Disabled flag/tag and absent host APIs remain explicitly deferred |
| Large files | builder/module/reference/bytecode mixed files above practical review size | split only by exact implementation/behavior ownership; allow a large cohesive owner with recorded rationale |
| Raw boundary | several UE wrapper/debugger/generator/type registry tests inside SDK | eight focused prefixes in owning external themes |

## Automation and tooling impact

| File/entry | Planned change | Compatibility |
| --- | --- | --- |
| `Config/DefaultEngine.ini` | remove stale SDK Smoke and ASSDK Smoke filters; retain root SDK group | `AngelscriptNative` root group remains stable |
| `Tools/Shared/TestSuiteDefinitions.ps1` | no native prefix split required; verify `NativeCore` points at SDK root | existing suite name remains stable |
| `openspec/.../scripts/AuditNativeSdkTests.ps1` | add source/coverage/layout/ID/gate/helper audit | local change validation only |
| `Tools/RunBuild.ps1` | execution only, no planned implementation change | standard build entry |
| `Tools/RunTests.ps1` | execution only, no planned implementation change | domain and moved-prefix runs |
| `Tools/RunTestSuite.ps1` | execution only unless existing suite mapping proves stale | `NativeCore` and `All` entry points retained |

## Documentation impact

Chinese/current guidance is updated before English/secondary summaries when both are affected.

| Document | Required update |
| --- | --- |
| `Documents/UnitTest/UnitTest.md` | add raw SDK-specific ownership/profile/disabled-2.38/ID rules without disturbing current user edits |
| `Documents/Guides/ASSDK_Fork_Differences.md` | replace unsafe compile-only assumptions with tested current boundaries; record active vs future-2.38 classification |
| `Documents/Guides/AngelscriptForkStrategy.md` | point selective backports at compiled-disabled conformance tests and audit-backed regression coverage |
| `Documents/Guides/Test.md` | nine SDK domain commands, moved-test commands, required full verification order |
| `Documents/Guides/TestConventions.md` | replace flat `Smoke` and historical column-0/ASSDK language with domain IDs and current inline fixture rule |
| `Documents/Guides/TestCatalog.md` | generated counts and latest verified outcomes; remove stale current `301/301` claim |
| `Documents/Guides/TechnicalDebtInventory.md` | reflect completed structural/coverage debt and any verified remaining disabled count |
| `AGENTS_ZH.md` then `AGENTS.md` | update SDK directory ownership, current test scale terminology, and test entry points while preserving unrelated guidance |
| `Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md` | support headers, domain layout, raw boundary, naming, verification |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/README.md` | retain stable SDK include pointers; do not advertise internal Support headers as extension API |

## ABI/API and downstream impact

- `ANGELSCRIPTRUNTIME_API` adds exported C++ symbols but does not add AngelScript registrations or public UE-facing feature APIs.
- `AngelscriptNativeTestSupport.h` and `AngelscriptTestAdapter.h` remain include-compatible stable entry points.
- Old internal helper headers are deleted; only sources inside this repository are expected consumers and all call sites are migrated atomically before build.
- Automation dashboards/bookmarks using old sub-prefixes must use `test-id-migration.md`. The stable root and `NativeCore` suite avoid breaking broad CI entry points.
- No asset, config schema, serialized bytecode, cache, network protocol, editor setting, or user data migration is involved.

## Failure modes and checks

| Risk | Detection | Containment |
| --- | --- | --- |
| Missed old include after helper deletion | static `rg` audit, then compiler | migration task remains incomplete until zero matches |
| Export macro produces linkage conflict | header audit, project build | only annotate declarations; preserve signatures and definitions |
| Test disappears during move | 433-row method ledger, old/new ID map, then discovery runs | require every current source key exactly once and execute all eight moved prefixes before broad suites |
| Theme is present but shallow | `test-scenarios.md` plus domain/language depth audit | require named positive, negative, execution, lifecycle, interaction, isolation, and classification evidence where applicable |
| Fake runtime coverage survives | audit compile-only names/body and coverage inventory | require explicit Compile/Metadata labels or real execution result |
| Add-on behavior expands the core scope | include/source audit | reject `sdk/add_on` dependencies; test only core syntax/runtime and host interfaces |
| Cross-test state leak | per-case engine/module/context RAII tests | no mutable global message collector or class-shared registered engine |
| 2.38 target silently changes fork | enabled/disabled/tag audit | current fork assertions remain active; future cases disabled |
| Inline source diagnostic coordinates shift | `ASTEST_AS_ANSI` wrapper and focused diagnostics | preserve-line helper only where explicitly documented |
| Unrelated dirty edit is lost | before/after scoped status and diff review | apply narrow hunks; never reset/checkout user files |

## Verification impact

No small-step build loop is used. Verification has two large build checkpoints:

1. complete exports/support/moves/layout/IDs, run structure static audit, then one structure build;
2. complete coverage/audit/config/documentation, run complete audit plus strict validation, then one final integration build;
3. nine SDK domain prefixes;
4. eight moved-test prefixes;
5. full `Angelscript.TestModule.AngelScriptSDK`;
6. `NativeCore`;
7. `All`.

Same-class compile fixes are batched before a rebuild. Automation tests never run between the two planned build checkpoints.

Each result records command, start/end time, pass/fail/disabled/not-found totals, process exit code, and log path in `verification.md`. Any failure invokes the systematic-debugging workflow and the narrowest affected command is rerun before continuing.
