# Canonical whole-tree declaration replay retirement gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-22 — physically retire the Parser/Sema whole-tree declaration replay fallback |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | public Sema API-surface detection plus a source-built mixed declaration graph covered by the existing SemaAuthority/declaration/CodeGen matrices |
| Construction/sealed-AST assertion | every accepted declaration family continues to be published by its exact typed start/finish/body/default adapter; removing the generic fallback does not remove sealed declarations, owners, types, traits, bodies or dependencies |
| Architecture assertion | `asCSema` exposes no `ActOnParsedDeclaration` or `ActOnParsedScript`; Parser has no `NotifySema`, declaration-action counter, or zero-action whole-tree replay; declaration Sema has no `WalkOne`/`WalkDecls` node-kind switch |
| Expected RED | the permanent API-surface test observes both whole-tree Sema methods as still present before production edits |
| Production edit allowed after RED | delete the inactive Parser fallback/counter and Sema whole-tree declaration APIs/walkers plus helpers used only by that replay |

## Design decision

The retained whole-tree path is no longer a compatibility requirement. Every
accepted top-level declaration node kind is excluded from `NotifySema`, and its
Parser family already publishes typed actions. `semaDeclActions` is used only
to decide whether to invoke `ActOnParsedScript`; it is not a semantic metric or
consumer-visible result. Keeping the fallback therefore preserves a second
semantic entry point without preserving a real supported producer.

CTA-S-22 removes that entry point rather than adding another flag around it:

```text
before:
  Parser typed declaration actions
      + zero-action fallback -> ActOnParsedScript -> WalkOne/WalkDecls

after:
  Parser typed declaration actions only
      + explicitly named body/default/initializer adapters while their
        expression/statement families are migrated
```

The permanent test uses C++ API-surface detection, not a source-text grep. A
future reintroduction of either whole-tree method makes the test fail even if
the implementation has a different spelling or file layout. Existing
source-built AST assertions remain the behavior gate proving removal did not
erase declarations that were accidentally dependent on replay.

## TDD and mutation contract

The test must fail before production edits because:

- `asCSema::ActOnParsedDeclaration(asCScriptNode*, asCScriptCode*)` exists;
- `asCSema::ActOnParsedScript(asCScriptNode*, asCScriptCode*)` exists.

After deletion it must pass. It must fail again if either public semantic API
is restored. The focused behavior suites must fail if deleting the fallback
exposes a declaration family that has not actually completed its typed action
route.

## Required evidence

1. Test-only build and focused RED with the expected API-presence assertion.
2. Production deletion with zero fallback symbols in Parser/Sema.
3. Runtime/Editor build.
4. Complete SemaAuthority, Parser declarations, ProductionCodeGen and Frontend
   Type regressions; add a narrower mixed-declaration run if a gap appears.
5. Direct `asCScriptNode` inventory and forbidden-symbol scan.
6. Strict OpenSpec validation plus parent/plugin `git diff --check`.
7. Record every build/test/runner issue, root cause, correction and non-claim
   here and in the final issue log/execution ledger.

## Explicit non-claims before implementation

- This does not remove `asCScriptNode` as the Parser's transient syntax/recovery
  representation.
- Function/lambda bodies, parameter/default/enumerator/variable initializers,
  general expressions, statements, control and lifetime semantics still have
  explicitly named node adapters.
- This does not complete Tasks 4.2–4.6, 5.2–5.9, 10.6 or 13.2.
- Builder/LEGACY declaration registration remains the migration oracle and the
  compiler default remains LEGACY.
- Cache V2 remains default-disabled.

## Execution issue before RED

The TDD skill references `writing-good-tests.md` relative to its own
`test-driven-development/` directory. An initial read attempted the parent
`superpowers/` directory and failed with a missing-path error. The reference
was located with `rg --files` and read completely from the correct path before
any test edit. This is an execution-path correction, not product evidence or a
repository defect.

## Test-infrastructure issue exposed before the valid RED

The first supported test-only build failed before the new tests could execute:

`Saved/Build/cta-declaration-replay-red-test-build/20260827_161618_560_f16f8b65/RunMetadata.json`

Adaptive non-unity compilation isolated
`AngelscriptNativeContextReturnValueTests.cpp`; its four `ASTEST_AS_ANSI` uses
did not directly include `AngelscriptTestMacros.h`. This was the third
consecutive Canonical slice in which the same unity-include leak blocked the
supported build, so CTA-S-22 repaired the dependency rather than applying a
third temporary validation workaround.

A scan of all 450 test `.cpp` files using `ASTEST_AS` or `ASTEST_AS_ANSI`
found three real missing direct includes:

1. `AngelscriptNativeContextReturnValueTests.cpp`;
2. `AngelscriptNativeContextPublicApiDepthTests.cpp`;
3. `AngelscriptNativeContextInvocationTests.cpp`.

`StaticJIT/AngelscriptJITExecutionContextTests.cpp` was an initial scan false
positive because it correctly includes `Shared/AngelscriptTestMacros.h`. The
three real files had no logical diff from `HEAD` before the repair. Adding the
direct include to each made the supported test-only build pass:

`Saved/Build/cta-declaration-replay-red-test-build-fix1/20260827_161748_865_35cfc34c/RunMetadata.json`

This is a test-infrastructure dependency repair, not semantic credit for
CTA-S-22. Existing C5038/C4191 warnings in the native fixture support remain
visible and are not claimed fixed.

## RED evidence

Two permanent SFINAE API-surface tests were added before production edits:

- `SemaDoesNotExposeWholeTreeParsedDeclarationAction`;
- `SemaDoesNotExposeWholeTreeParsedScriptAction`.

The focused run was the expected valid RED: **339 total, 337 passed, 2 failed,
0 skipped**. Only those two tests failed because both obsolete methods still
existed:

`Saved/Tests/cta-declaration-replay-red/20260827_161809_396_b4bdbf7d/RunMetadata.json`

## Production result

The implementation physically removes:

- Parser `NotifySema`, `semaDeclActions`, every counter increment and the
  zero-action `ActOnParsedScript` fallback;
- Sema `ActOnParsedDeclaration` and `ActOnParsedScript` from the public API and
  implementation;
- declaration replay `WalkOne`/`WalkDecls` and their replay-only identifier,
  token, type-format, return-constant and function-trait walkers;
- the stale `WalkOne` constructor comment and the top-level exclusion list
  whose only purpose was to decide which completed shells entered replay.

Explicitly named body/default/initializer/expression/statement adapters remain.
They are not routed through a generic completed-declaration callback.

The Runtime/Editor build passed all 41 scheduled actions and linked both
Runtime and Test modules:

`Saved/Build/cta-declaration-replay-green-build/20260827_162535_044_2ed1c425/RunMetadata.json`

## GREEN repair and evidence

The first post-deletion SemaAuthority run was **335/339 PASS**:

`Saved/Tests/cta-declaration-replay-green-sema/20260827_162647_378_3f816b79/RunMetadata.json`

The four failures were source-architecture assertions from earlier migration
slices. They required the old exclusion-list text and a residual `WalkOne`
`snFunction` case to exist as proof that individual declarations were not
replayed. With the callback and walker physically absent, those positive
lookups had become stale. No source-built AST, type, lookup, call-plan,
CodeGen, or execution assertion failed.

The tests were strengthened to require global absence of `NotifySema(` and
`WalkOne(` instead of requiring an exclusion inside those mechanisms. The
test-module repair build passed:

`Saved/Build/cta-declaration-replay-green-test-repair-build/20260827_162848_770_7cf1decf/RunMetadata.json`

Final evidence is:

- SemaAuthority **339/339 PASS**:
  `Saved/Tests/cta-declaration-replay-green-sema-fix1/20260827_162908_093_8a7561d0/RunMetadata.json`;
- combined Canonical TypeSema, Parser declarations, ProductionCodeGen and
  Frontend Type matrix **152/152 PASS**:
  `Saved/Tests/cta-declaration-replay-green-regression-matrix/20260827_163022_003_215ff320/RunMetadata.json`.

The forbidden-symbol scan has zero matches for `NotifySema`,
`semaDeclActions`, `ActOnParsedDeclaration`, `ActOnParsedScript`, `WalkOne`,
`WalkDecls` and every deleted replay-only helper in the Parser/Sema production
files. Direct line-bearing `asCScriptNode` inventory is now declaration
**25**, expression **41**, statement **20** and core **5**, down from
**49/41/20/5** after CTA-S-21.

Final record verification also passes: strict OpenSpec validation reports the
change valid; parent and plugin `git diff --check` both exit zero. Their only
output is existing LF-to-CRLF conversion notices, not whitespace errors.

## Final non-claims

CTA-S-22 retires the generic declaration entry and closes that one execution-
plan bullet. It does not make the remaining 25 declaration-node references
action-only: parameter/default/enumerator/variable initializers, property and
function/lambda bodies still cross explicitly named adapters. Expression,
statement, control and lifetime Sema remain node-based, Builder/LEGACY remains
the migration oracle, compiler default remains LEGACY, and Cache V2 remains
default-disabled. Tasks 4.2–4.6, 5.2–5.9, 10.6 and 13.2 remain unchecked.
