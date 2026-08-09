# ExplicitBindings Naming Audit — 2026-08-09

## Decision

`EAngelscriptBindPhase::ManualBindings` is renamed to
`EAngelscriptBindPhase::ExplicitBindings`.

The phase still owns hand-written methods, constructors, properties,
behaviours, globals, namespace functions, and exact native overrides.  The
new name describes the API construction model — an explicitly authored bind
surface — instead of the incidental fact that a current implementation was
written by hand.

The phase order is unchanged:

```text
TypeDeclarations
TypeInfrastructure
ExplicitBindings
GeneratedBindings
ReflectionBindings
PostReflectionBindings
Finalization
```

The OpenSpec directory remains `refactor-as-manual-binding-architecture` as
the stable historical identity of the already-existing change; it is not an
API symbol and is intentionally not renamed.

## Audit result

The Runtime enum, default metadata values, diagnostic stringification, and
the direct callback/configuration test fixtures use `ExplicitBindings`.
The phase ordinal is unchanged, so collection ordering and persisted
observation indexing do not change.

The audit found these incomplete consumers:

| Scope | Remaining references | Consequence |
|---|---:|---|
| Runtime source-layout test | 29 | Expected source text and diagnostics still name `ManualBindings`; the source-layout assertions fail until migrated. |
| Runtime dump test | 1 | Expected phase label remains `ManualBindings`; the assertion becomes stale. |
| GAS binding-architecture test | 3 | Expected source text and diagnostic wording remain stale. |
| GameplayTags binding-architecture test | 1 | Expected source text remains stale. |
| Chinese-first documentation | 45 | Examples and phase descriptions teach the obsolete API spelling. |

The 34 test-source references are a mechanical naming migration only.  They
must retain existing behavioural assertions and must not be used as a reason
to introduce or expand source-layout testing.

## Fresh verification

`Tools\\RunTests.ps1` ran the focused
`Angelscript.TestModule.Engine.BindingArchitecture` prefix on 2026-08-09.
The report is at:

```text
Saved/Tests/explicit-bindings-naming-audit/20260809_110558_402_196dbfa7/Report/index.json
```

Result: **40/56 passed, 16 failed, 0 skipped**.  The failed methods are all
`FAngelscriptBindSourceLayoutTests` cases whose expected provider source
contains `EAngelscriptBindPhase::ManualBindings`.  The production phase order
and the direct callback runtime tests started successfully; this is a stale
source-text expectation failure, not a discovered binding behaviour change.

`Tools\\RunBuild.ps1` then completed successfully for
`AngelscriptProjectEditor` on 2026-08-09.  It compiled Runtime, Test, GAS,
GameplayTags, and their test modules.  Build metadata:

```text
Saved/Build/explicit-bindings-naming-audit/20260809_110828_483_2a37657c/RunMetadata.json
```

Result: **succeeded (67 actions, exit code 0)**.  This confirms the rename
has no C++ compilation omission; the outstanding work is the stale test and
documentation terminology recorded above.

## Required verification after the follow-up

1. `rg -n "\\bManualBindings\\b" Plugins Documents AGENTS.md AGENTS_ZH.md`
   returns no source, test, or documentation references. Historical audit
   records may retain the old word only when they explicitly describe the
   rename.
2. Run the focused binding architecture prefix through `Tools\\RunTests.ps1`.
3. Run the affected optional-plugin binding test prefixes through
   `Tools\\RunTests.ps1`.
4. Run `Tools\\RunBuild.ps1` before declaring the rename verified.
